# Progreso del jugador: estrellas por sopa, compra, pistas del dia y ajustes.
#
# Se guarda en user://progreso.save con dos lineas:
#   1) HMAC-SHA256 del contenido (hex)
#   2) el contenido en JSON
# La firma se comprueba sobre el texto exacto de la linea 2 antes de parsearlo.
# Un archivo editado a mano se rechaza, se aparta en progreso.save.rechazado y
# se empieza de cero. Limites conocidos en docs/LANZAMIENTO.md (seccion 5).
extends Node

signal cambiado

const VERSION := 2
# La sal vive en el binario, asi que no es un secreto contra quien descompile
# el APK: solo sube el liston frente a editar el archivo (auditoria SEC-001).
# Por eso la compra se vuelve a pedir a Play en cada arranque.
const SAL := "sopazz-v1-7f3c91e2"
const ESCALAS := [0.85, 1.0, 1.15, 1.3]
const DISENOS := ["papel", "noche", "cielo"]

var ruta := "user://progreso.save"
var datos: Dictionary = {}
## Por que se descarto el ultimo archivo leido ("" si se leyo bien o no existia).
var ultimo_rechazo := ""


func _ready() -> void:
	cargar()
	Estilo.aplicar(str(datos["diseno"]))


static func por_defecto() -> Dictionary:
	return {
		"version": VERSION,
		"premium": false,          # pago unico (Play manda, ver fijar_premium)
		"estrellas": {},           # "categoria/subtema/dificultad" -> mejores estrellas
		"completadas": 0,          # victorias totales (reglas del intersticial)
		"ultima": {},              # ultima sopa jugada, para "Continuar"
		"racha": 0,
		"ultimo_dia": "",
		"max_dia": "",             # fecha mas alta vista: la del juego nunca retrocede
		"diario_hecho": "",
		"pistas_dia": "",
		"pistas_hoy": 0,
		"cortesia_dia": "",
		"premiados_dia": "",
		"premiados_hoy": 0,
		"sonido": true,
		"vibracion": true,
		"escala_texto": 1.0,
		"diseno": "papel",
		"dificultad": 0,
	}


# ---------------------------------------------------------------- disco

func _clave() -> PackedByteArray:
	return (SAL + "|" + OS.get_unique_id()).sha256_buffer()


func _firmar(texto: String) -> String:
	var c := Crypto.new()
	return c.hmac_digest(HashingContext.HASH_SHA256, _clave(), texto.to_utf8_buffer()).hex_encode()


func cargar() -> void:
	ultimo_rechazo = ""
	datos = por_defecto()
	if not FileAccess.file_exists(ruta):
		return
	var contenido := FileAccess.get_file_as_string(ruta)
	var corte := contenido.find("\n")
	if corte == -1:
		_rechazar("formato")
		return
	var firma := contenido.substr(0, corte)
	var cuerpo := contenido.substr(corte + 1)
	if firma != _firmar(cuerpo):
		_rechazar("firma")
		return
	var leido = JSON.parse_string(cuerpo)
	if typeof(leido) != TYPE_DICTIONARY:
		_rechazar("json")
		return
	# Solo entra lo que tiene el tipo esperado, y despues se acota (SEC-004).
	for k in leido:
		if datos.has(k) and _mismo_tipo(datos[k], leido[k]):
			datos[k] = leido[k]
	_sanear()


static func _mismo_tipo(esperado, valor) -> bool:
	var numeros := [TYPE_INT, TYPE_FLOAT]
	if typeof(esperado) in numeros:
		return typeof(valor) in numeros
	return typeof(esperado) == typeof(valor)


func _sanear() -> void:
	datos["version"] = VERSION
	for k in ["completadas", "racha"]:
		datos[k] = maxi(int(datos[k]), 0)
	datos["pistas_hoy"] = clampi(int(datos["pistas_hoy"]), 0, Economia.PISTAS_GRATIS_DIA)
	datos["premiados_hoy"] = clampi(int(datos["premiados_hoy"]), 0, Economia.PREMIADOS_MAX_DIA)
	if not float(datos["escala_texto"]) in ESCALAS:
		datos["escala_texto"] = 1.0
	if not str(datos["diseno"]) in DISENOS:
		datos["diseno"] = "papel"
	datos["dificultad"] = clampi(int(datos["dificultad"]), 0, Economia.DIFICULTADES.size() - 1)
	var estrellas := {}
	for k in datos["estrellas"]:
		var v = datos["estrellas"][k]
		if typeof(k) == TYPE_STRING and typeof(v) in [TYPE_INT, TYPE_FLOAT]:
			estrellas[k] = clampi(int(v), 0, 3)
	datos["estrellas"] = estrellas
	var u: Dictionary = datos["ultima"]
	if typeof(u.get("categoria")) != TYPE_STRING or typeof(u.get("subtema")) != TYPE_STRING:
		datos["ultima"] = {}


func _rechazar(motivo: String) -> void:
	ultimo_rechazo = motivo
	# El motivo solo en depuracion: en release le diria a quien manipula el
	# archivo que fallo exactamente (SEC-009).
	if OS.is_debug_build():
		push_warning("Progreso descartado (%s); se empieza de cero." % motivo)
	else:
		push_warning("Progreso no valido; se empieza de cero.")
	# Se aparta el original en vez de perderlo al siguiente guardado (SEC-006).
	DirAccess.rename_absolute(ProjectSettings.globalize_path(ruta), ProjectSettings.globalize_path(ruta + ".rechazado"))
	datos = por_defecto()


func guardar() -> void:
	var cuerpo := JSON.stringify(datos)
	var tmp := ruta + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_error("No se pudo guardar el progreso: %s" % error_string(FileAccess.get_open_error()))
		return
	f.store_string(_firmar(cuerpo) + "\n" + cuerpo)
	f.close()
	# Escritura atomica: si la app muere a mitad, queda el archivo anterior entero.
	var err := DirAccess.rename_absolute(tmp, ruta)
	if err != OK:
		push_error("No se pudo reemplazar el progreso: %s" % error_string(err))
	cambiado.emit()


# ---------------------------------------------------------------- compra

func es_premium() -> bool:
	return bool(datos["premium"])


func activar_premium() -> void:
	fijar_premium(true)


## Estado de la compra segun Play (fuente de verdad): si Play dice que no la
## tiene (guardado forjado, reembolso), se retira. Solo se llama con una
## respuesta correcta de Play; sin conexion no se toca.
func fijar_premium(valor: bool) -> void:
	if bool(datos["premium"]) == valor:
		return
	datos["premium"] = valor
	guardar()


## La sopa se puede jugar: version completa, o una de las gratis.
func desbloqueada(cat: String, sub: String) -> bool:
	return es_premium() or Temas.es_gratis(cat, sub)


# ---------------------------------------------------------------- sopas

static func _clave_sopa(cat: String, sub: String, dificultad: int) -> String:
	return "%s/%s/%d" % [cat, sub, dificultad]


func estrellas_de(cat: String, sub: String, dificultad: int) -> int:
	return int(datos["estrellas"].get(_clave_sopa(cat, sub, dificultad), 0))


func completadas() -> int:
	return int(datos["completadas"])


## Sopas de una categoria resueltas en esa dificultad.
func resueltas_en(cat: String, dificultad: int) -> int:
	var n := 0
	for s in Temas.categoria(cat).get("subtemas", []):
		if estrellas_de(cat, s["id"], dificultad) > 0:
			n += 1
	return n


func resueltas_total() -> int:
	var sopas := {}
	for k in datos["estrellas"]:
		var partes: PackedStringArray = str(k).split("/")
		if partes.size() == 3:
			sopas[partes[0] + "/" + partes[1]] = true
	return sopas.size()


func registrar_victoria(cat: String, sub: String, dificultad: int, estrellas: int, diario: bool, hoy: String) -> void:
	var k := _clave_sopa(cat, sub, dificultad)
	datos["estrellas"][k] = maxi(int(datos["estrellas"].get(k, 0)), clampi(estrellas, 1, 3))
	datos["completadas"] = completadas() + 1
	if diario:
		datos["diario_hecho"] = hoy
	guardar()


func diario_hecho(hoy: String) -> bool:
	return datos["diario_hecho"] == hoy


func ultima() -> Dictionary:
	return datos["ultima"]


func fijar_ultima(cat: String, sub: String) -> void:
	datos["ultima"] = {"categoria": cat, "subtema": sub}
	guardar()


# ---------------------------------------------------------------- pistas

func pistas_restantes(hoy: String) -> int:
	if datos["pistas_dia"] != hoy:
		return Economia.PISTAS_GRATIS_DIA
	return Economia.PISTAS_GRATIS_DIA - int(datos["pistas_hoy"])


## Intenta usar una pista. "premium" (ilimitadas), "gratis" (de las del dia)
## o "" si hace falta un anuncio premiado.
func pagar_pista(hoy: String) -> String:
	if es_premium():
		return "premium"
	if pistas_restantes(hoy) <= 0:
		return ""
	if datos["pistas_dia"] != hoy:
		datos["pistas_dia"] = hoy
		datos["pistas_hoy"] = 0
	datos["pistas_hoy"] = int(datos["pistas_hoy"]) + 1
	guardar()
	return "gratis"


## Una pista de cortesia al dia cuando el anuncio no carga: que una mala
## conexion no deje a nadie atascado.
func usar_cortesia(hoy: String) -> bool:
	if datos["cortesia_dia"] == hoy:
		return false
	datos["cortesia_dia"] = hoy
	guardar()
	return true


func premiado_disponible(hoy: String) -> bool:
	return datos["premiados_dia"] != hoy or int(datos["premiados_hoy"]) < Economia.PREMIADOS_MAX_DIA


func registrar_premiado(hoy: String) -> void:
	if datos["premiados_dia"] != hoy:
		datos["premiados_dia"] = hoy
		datos["premiados_hoy"] = 0
	datos["premiados_hoy"] = int(datos["premiados_hoy"]) + 1
	guardar()


# ---------------------------------------------------------------- racha y fecha

## Al abrir la app: avanza la racha. Devuelve la racha actual.
func registrar_dia(hoy: String) -> int:
	var r := Economia.avanzar_racha(int(datos["racha"]), datos["ultimo_dia"], hoy)
	if r[1]:
		datos["racha"] = r[0]
		datos["ultimo_dia"] = hoy
		guardar()
	return int(datos["racha"])


## Fecha del juego: la del sistema, pero nunca anterior a la mas alta ya vista.
## Atrasar el reloj no repite las pistas del dia, la sopa del dia ni los
## premiados (SEC-002).
func fecha_juego(sistema: String = "") -> String:
	if sistema == "":
		sistema = Time.get_date_string_from_system()
	if sistema > str(datos["max_dia"]):
		datos["max_dia"] = sistema
	return str(datos["max_dia"])


func hoy() -> String:
	return fecha_juego()


# ---------------------------------------------------------------- ajustes

func ajuste(nombre: String):
	return datos.get(nombre)


func fijar_ajuste(nombre: String, valor) -> void:
	datos[nombre] = valor
	guardar()
