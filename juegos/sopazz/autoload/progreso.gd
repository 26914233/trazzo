# Progreso del jugador: niveles, fichas, compras y ajustes.
#
# Se guarda en user://progreso.save con dos lineas:
#   1) HMAC-SHA256 del contenido (hex)
#   2) el contenido en JSON
# La firma se comprueba sobre el texto exacto de la linea 2 antes de parsearlo.
# Un archivo editado a mano se rechaza y se vuelve a valores seguros (cero
# fichas), nunca a valores generosos, y el archivo rechazado se aparta en
# progreso.save.rechazado. Limites conocidos en docs/LANZAMIENTO.md (seccion 5).
extends Node

signal fichas_cambiadas(total: int)
signal cambiado

const VERSION := 1
# La sal vive en el binario, asi que no es un secreto contra quien descompile
# el APK: solo sube el liston frente a editar el archivo (auditoria SEC-001).
# Por eso las compras permanentes se vuelven a pedir a Play en cada arranque.
const SAL := "sopazz-v1-7f3c91e2"
const FICHAS_MAX := 10_000_000
const ESCALAS := [0.85, 1.0, 1.15, 1.3]

var ruta := "user://progreso.save"
var datos: Dictionary = {}
## Por que se descarto el ultimo archivo leido ("" si se leyo bien o no existia).
var ultimo_rechazo := ""


func _ready() -> void:
	cargar()


static func por_defecto() -> Dictionary:
	return {
		"version": VERSION,
		"fichas": 0,
		"pistas_gratis": Economia.PISTAS_GRATIS_INICIALES,
		"niveles": {},              # "tema|dificultad" -> siguiente nivel a jugar
		"estrellas": {},            # "tema|dificultad|nivel" -> mejores estrellas
		"temas_jugados": [],
		"temas_comprados": [],      # comprados en Play (Play manda, ver sincronizar_permanentes)
		"temas_con_fichas": [],     # desbloqueados con fichas (solo local)
		"max_dia": "",              # fecha mas alta vista: la del juego nunca retrocede
		"sin_anuncios": false,
		"niveles_completados": 0,
		"racha": 0,
		"ultimo_dia": "",
		"diario_hecho": "",
		"premiados_dia": "",
		"premiados_hoy": 0,
		"cortesia_dia": "",
		"sonido": true,
		"musica": false,
		"vibracion": true,
		"escala_texto": 1.0,
		"consentimiento": "desconocido",
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
	# Se fusiona sobre los valores por defecto: un guardado de una version
	# anterior sin una clave nueva sigue funcionando. Solo entra lo que tiene
	# el tipo esperado, y despues se acota (auditoria SEC-004).
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
	datos["fichas"] = clampi(int(datos["fichas"]), 0, FICHAS_MAX)
	datos["pistas_gratis"] = clampi(int(datos["pistas_gratis"]), 0, Economia.PISTAS_GRATIS_INICIALES)
	datos["racha"] = maxi(int(datos["racha"]), 0)
	datos["niveles_completados"] = maxi(int(datos["niveles_completados"]), 0)
	if not float(datos["escala_texto"]) in ESCALAS:
		datos["escala_texto"] = 1.0
	for lista in ["temas_jugados", "temas_comprados", "temas_con_fichas"]:
		datos[lista] = datos[lista].filter(func(x): return typeof(x) == TYPE_STRING)
	for mapa in ["niveles", "estrellas"]:
		var limpio := {}
		for k in datos[mapa]:
			var v = datos[mapa][k]
			if typeof(k) == TYPE_STRING and typeof(v) in [TYPE_INT, TYPE_FLOAT]:
				limpio[k] = clampi(int(v), 0, 1_000_000)
		datos[mapa] = limpio


func _rechazar(motivo: String) -> void:
	ultimo_rechazo = motivo
	# El motivo solo en depuracion: en release le diria a quien manipula el
	# archivo que fallo exactamente (auditoria SEC-009).
	if OS.is_debug_build():
		push_warning("Progreso descartado (%s); se empieza de cero." % motivo)
	else:
		push_warning("Progreso no valido; se empieza de cero.")
	# Se aparta el original en vez de perderlo al siguiente guardado: un cambio
	# de ID del dispositivo o de version no debe borrar el progreso (SEC-006).
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


# ---------------------------------------------------------------- fichas

func fichas() -> int:
	return int(datos["fichas"])


func sumar_fichas(n: int) -> void:
	if n <= 0:
		return
	datos["fichas"] = fichas() + n
	guardar()
	fichas_cambiadas.emit(fichas())


func gastar_fichas(n: int) -> bool:
	if n <= 0 or fichas() < n:
		return false
	datos["fichas"] = fichas() - n
	guardar()
	fichas_cambiadas.emit(fichas())
	return true


# ---------------------------------------------------------------- pistas

func pistas_gratis() -> int:
	return int(datos["pistas_gratis"])


## Intenta pagar una pista. Devuelve "gratis", "fichas" o "" si hace falta
## un anuncio premiado (o comprar fichas).
func pagar_pista(coste: int = Economia.COSTE_PISTA) -> String:
	if pistas_gratis() > 0:
		datos["pistas_gratis"] = pistas_gratis() - 1
		guardar()
		return "gratis"
	if gastar_fichas(coste):
		return "fichas"
	return ""


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


# ---------------------------------------------------------------- niveles

func _clave_nivel(tema: String, dificultad: int) -> String:
	return "%s|%d" % [tema, dificultad]


func nivel_actual(tema: String, dificultad: int) -> int:
	return int(datos["niveles"].get(_clave_nivel(tema, dificultad), 1))


func estrellas_de(tema: String, dificultad: int, nivel: int) -> int:
	return int(datos["estrellas"].get("%s|%d|%d" % [tema, dificultad, nivel], 0))


func niveles_completados() -> int:
	return int(datos["niveles_completados"])


## Registra un nivel ganado y devuelve las fichas que da.
func completar_nivel(tema: String, dificultad: int, nivel: int, estrellas: int, diario: bool, hoy: String) -> int:
	var primera_vez: bool = not (tema in datos["temas_jugados"])
	if primera_vez:
		datos["temas_jugados"].append(tema)
	if diario:
		if datos["diario_hecho"] == hoy:
			diario = false  # el doble solo se cobra una vez al dia
		else:
			datos["diario_hecho"] = hoy
	else:
		var k := _clave_nivel(tema, dificultad)
		datos["niveles"][k] = maxi(nivel_actual(tema, dificultad), nivel + 1)
		var ke := "%s|%d|%d" % [tema, dificultad, nivel]
		datos["estrellas"][ke] = maxi(estrellas_de(tema, dificultad, nivel), estrellas)
	datos["niveles_completados"] = niveles_completados() + 1
	var ganadas := Economia.recompensa_nivel(estrellas, primera_vez, diario)
	datos["fichas"] = fichas() + ganadas
	guardar()
	fichas_cambiadas.emit(fichas())
	return ganadas


func diario_hecho(hoy: String) -> bool:
	return datos["diario_hecho"] == hoy


## Al abrir la app: avanza la racha y paga la recompensa del dia si toca.
func registrar_dia(hoy: String) -> int:
	var r := Economia.avanzar_racha(int(datos["racha"]), datos["ultimo_dia"], hoy)
	datos["racha"] = r[0]
	datos["ultimo_dia"] = hoy
	var premio := Economia.recompensa_racha(r[0]) if r[1] else 0
	datos["fichas"] = fichas() + premio
	guardar()
	if premio > 0:
		fichas_cambiadas.emit(fichas())
	return premio


# ---------------------------------------------------------------- temas y compras

func tema_desbloqueado(id: String) -> bool:
	var t: Dictionary = Temas.tema(id) if is_inside_tree() else {}
	return t.get("gratis", false) or id in datos["temas_comprados"] or id in datos["temas_con_fichas"]


func desbloquear_tema(id: String) -> void:
	if not (id in datos["temas_comprados"]):
		datos["temas_comprados"].append(id)
		guardar()


func desbloquear_con_fichas(id: String) -> bool:
	if tema_desbloqueado(id):
		return true
	if not gastar_fichas(Economia.COSTE_TEMA):
		return false
	datos["temas_con_fichas"].append(id)
	guardar()
	return true


func sin_anuncios() -> bool:
	return bool(datos["sin_anuncios"])


func activar_sin_anuncios() -> void:
	datos["sin_anuncios"] = true
	guardar()


## Las compras permanentes segun Play (fuente de verdad): lo que no aparece
## se retira (guardado forjado, reembolso). Solo se llama con una respuesta
## correcta de Play; sin conexion no se revoca nada.
func sincronizar_permanentes(sin_anuncios_comprado: bool, temas: Array) -> void:
	datos["sin_anuncios"] = sin_anuncios_comprado
	datos["temas_comprados"] = temas.duplicate()
	guardar()


# ---------------------------------------------------------------- ajustes

func ajuste(nombre: String):
	return datos.get(nombre)


func fijar_ajuste(nombre: String, valor) -> void:
	datos[nombre] = valor
	guardar()


## Fecha del juego: la del sistema, pero nunca anterior a la mas alta ya
## vista. Atrasar el reloj del movil no vuelve a pagar la racha, el diario,
## la pista de cortesia ni los premiados (auditoria SEC-002). Adelantarlo no
## se puede detectar sin servidor, pero deja de rendir al volver a la fecha real.
func fecha_juego(sistema: String = "") -> String:
	if sistema == "":
		sistema = Time.get_date_string_from_system()
	if sistema > str(datos["max_dia"]):
		datos["max_dia"] = sistema
	return str(datos["max_dia"])


func hoy() -> String:
	return fecha_juego()
