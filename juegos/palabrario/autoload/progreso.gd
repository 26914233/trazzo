# Progreso del jugador: estrellas por sopa, pistas, racha, sopa del dia y ajustes.
#
# Se guarda en user://progreso.save con dos lineas:
#   1) HMAC-SHA256 del contenido (hex)
#   2) el contenido en JSON
# La firma se comprueba sobre el texto exacto de la linea 2 antes de parsearlo.
# Un archivo editado a mano se rechaza, se aparta en progreso.save.rechazado y
# se empieza de cero. Limites conocidos en docs/LANZAMIENTO.md (seccion 4).
extends Node

signal cambiado

const VERSION := 2
# La sal vive en el binario, asi que no es un secreto contra quien descompile
# el APK: solo sube el liston frente a editar el archivo. El saldo de pistas
# compradas vive aqui: quien tenga root y extraiga la sal puede inflarlo
# (riesgo aceptado: valor bajo, un jugador, sin ranking; docs/LANZAMIENTO.md).
const SAL := "palabrario-v1-7f3c91e2"
const ESCALAS := [0.85, 1.0, 1.15, 1.3]
const DISENOS := ["cielo", "papel", "noche"]
const RACHA_MAX := 3650            # diez años seguidos
const COMPLETADAS_MAX := 10_000_000
# Si la fecha mas alta vista queda mas de esto por delante del reloj, el reloj
# estuvo mal (p. ej. en otro año) y se vuelve a la fecha real para no dejar la
# sopa del dia congelada. Atrasos cortos siguen sin devolver nada (SEC-002).
const DIAS_RELOJ_ROTO := 30
const FECHAS := ["ultimo_dia", "max_dia", "diario_hecho", "pistas_dia"]

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
		"estrellas": {},           # "categoria/subtema/dificultad" -> mejores estrellas
		"completadas": 0,          # victorias totales (reglas del intersticial)
		"ultima": {},              # ultima sopa jugada, para "Continuar"
		"racha": 0,
		"ultimo_dia": "",
		"max_dia": "",             # fecha mas alta vista: la del juego nunca retrocede
		"diario_hecho": "",
		"pistas_dia": "",          # fecha de las pistas gratis usadas
		"pistas_hoy": 0,           # pistas gratis usadas ese dia
		"pistas_compradas": 0,     # saldo comprado (no caduca)
		"sonido": true,
		"vibracion": true,
		"escala_texto": 1.0,
		"diseno": "cielo",
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
	datos["completadas"] = clampi(int(datos["completadas"]), 0, COMPLETADAS_MAX)
	datos["racha"] = clampi(int(datos["racha"]), 0, RACHA_MAX)
	for k in FECHAS:
		if not es_fecha(str(datos[k])):
			datos[k] = ""
	datos["pistas_hoy"] = clampi(int(datos["pistas_hoy"]), 0, Economia.PISTAS_GRATIS_DIA)
	datos["pistas_compradas"] = clampi(int(datos["pistas_compradas"]), 0, Economia.PISTAS_MAX)
	if not float(datos["escala_texto"]) in ESCALAS:
		datos["escala_texto"] = 1.0
	if not str(datos["diseno"]) in DISENOS:
		datos["diseno"] = "cielo"
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


## "AAAA-MM-DD" valida (lo que escribe Time.get_date_string_from_system).
static func es_fecha(s: String) -> bool:
	if s.length() != 10 or s[4] != "-" or s[7] != "-":
		return false
	for i in [0, 1, 2, 3, 5, 6, 8, 9]:
		if not s[i].is_valid_int():
			return false
	var mes := s.substr(5, 2).to_int()
	var dia := s.substr(8, 2).to_int()
	return mes >= 1 and mes <= 12 and dia >= 1 and dia <= 31


func _rechazar(motivo: String) -> void:
	ultimo_rechazo = motivo
	# El motivo solo en depuracion: en release le diria a quien manipula el
	# archivo que fallo exactamente (SEC-009).
	if OS.is_debug_build():
		push_warning("Progreso descartado (%s); se empieza de cero." % motivo)
	else:
		push_warning("Progreso no valido; se empieza de cero.")
	# Se aparta el original en vez de perderlo al siguiente guardado, con la
	# hora en el nombre para que un segundo rechazo no pise al primero (SEC-007).
	var apartado := "%s.rechazado-%d" % [ruta, int(Time.get_unix_time_from_system() * 1000.0)]
	DirAccess.rename_absolute(ProjectSettings.globalize_path(ruta), ProjectSettings.globalize_path(apartado))
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

func pistas_gratis_hoy(hoy: String) -> int:
	if datos["pistas_dia"] != hoy:
		return Economia.PISTAS_GRATIS_DIA
	return Economia.PISTAS_GRATIS_DIA - int(datos["pistas_hoy"])


func pistas_compradas() -> int:
	return int(datos["pistas_compradas"])


## Gasta una pista: primero las gratis del dia, luego las compradas.
## Devuelve "gratis", "comprada" o "" si no queda ninguna.
func usar_pista(hoy: String) -> String:
	if pistas_gratis_hoy(hoy) > 0:
		if datos["pistas_dia"] != hoy:
			datos["pistas_dia"] = hoy
			datos["pistas_hoy"] = 0
		datos["pistas_hoy"] = int(datos["pistas_hoy"]) + 1
		guardar()
		return "gratis"
	if pistas_compradas() > 0:
		datos["pistas_compradas"] = pistas_compradas() - 1
		guardar()
		return "comprada"
	return ""


func sumar_pistas(n: int) -> void:
	if n <= 0:
		return
	datos["pistas_compradas"] = mini(pistas_compradas() + n, Economia.PISTAS_MAX)
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
## Atrasar el reloj no repite las pistas gratis ni la sopa del dia, ni rompe
## la racha (SEC-002).
func fecha_juego(sistema: String = "") -> String:
	if sistema == "":
		sistema = Time.get_date_string_from_system()
	var maximo := str(datos["max_dia"])
	if maximo != "" and Economia.dias_entre(sistema, maximo) > DIAS_RELOJ_ROTO:
		_volver_a(sistema)
	elif sistema > maximo:
		datos["max_dia"] = sistema
	return str(datos["max_dia"])


## El reloj estuvo muy adelantado: se vuelve a la fecha real. Las pistas
## gratis de ese dia cuentan como usadas y la racha sigue desde hoy (SEC-006).
func _volver_a(sistema: String) -> void:
	datos["max_dia"] = sistema
	if str(datos["ultimo_dia"]) > sistema:
		datos["ultimo_dia"] = sistema
	if str(datos["pistas_dia"]) > sistema:
		datos["pistas_dia"] = sistema
	if str(datos["diario_hecho"]) > sistema:
		datos["diario_hecho"] = ""
	guardar()


func hoy() -> String:
	return fecha_juego()


# ---------------------------------------------------------------- ajustes

func ajuste(nombre: String):
	return datos.get(nombre)


func fijar_ajuste(nombre: String, valor) -> void:
	datos[nombre] = valor
	guardar()
