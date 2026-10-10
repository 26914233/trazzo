# Progreso: estrellas, gemas, compras y personalizacion.
#
# Las gemas se pueden comprar con dinero, asi que el archivo va firmado (HMAC-SHA256,
# mismo esquema que Palabrario): dos lineas, firma y JSON. Un archivo editado a mano
# se aparta como .rechazado-<ms> y se empieza de cero. La compra "sin anuncios" se
# vuelve a pedir a Google Play al abrir la app (fuente de verdad).
# Limite conocido: la sal vive en el binario; con root se podria firmar un archivo
# falso. Riesgo aceptado (un jugador, sin ranking ni comercio entre jugadores).
extends Node

const SAL := "rebotazz-v1-4be19c07"
const VERSION := 1

var ruta := "user://progreso.save"
var datos: Dictionary = {}
var ultimo_rechazo := ""


func _ready() -> void:
	cargar()


static func por_defecto() -> Dictionary:
	return {
		"version": VERSION,
		"niveles": {},                 # "<indice>": {"estrellas": 0..3, "record": int}
		"gemas": 0,
		"sin_anuncios": false,
		"comprados": [],               # ids "tipo:id" de aspectos comprados
		"equipados": {"paleta": "clasica", "bola": "plata", "estela": "ninguna"},
		"premiados_dia": "",           # fecha de los anuncios con gemas
		"premiados_hoy": 0,
		"superados": 0,                # niveles superados en total (reglas de anuncios)
	}


# ---------------------------------------------------------------- disco

func _clave() -> PackedByteArray:
	return (SAL + "|" + OS.get_unique_id()).sha256_buffer()


func _firmar(texto: String) -> String:
	return Crypto.new().hmac_digest(HashingContext.HASH_SHA256, _clave(), texto.to_utf8_buffer()).hex_encode()


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
	var cuerpo := contenido.substr(corte + 1)
	if contenido.substr(0, corte) != _firmar(cuerpo):
		_rechazar("firma")
		return
	var d = JSON.parse_string(cuerpo)
	if typeof(d) != TYPE_DICTIONARY:
		_rechazar("json")
		return
	_sanear(d)


func _sanear(d: Dictionary) -> void:
	var niveles = d.get("niveles", {})
	if typeof(niveles) == TYPE_DICTIONARY:
		for k in niveles:
			var v = niveles[k]
			if typeof(k) == TYPE_STRING and k.is_valid_int() and typeof(v) == TYPE_DICTIONARY \
					and typeof(v.get("estrellas")) == TYPE_FLOAT and typeof(v.get("record")) == TYPE_FLOAT:
				datos["niveles"][k] = {"estrellas": clampi(int(v["estrellas"]), 0, 3), "record": clampi(int(v["record"]), 0, 99_999_999)}
	if typeof(d.get("gemas")) == TYPE_FLOAT:
		datos["gemas"] = clampi(int(d["gemas"]), 0, Economia.GEMAS_MAX)
	if typeof(d.get("sin_anuncios")) == TYPE_BOOL:
		datos["sin_anuncios"] = d["sin_anuncios"]
	if typeof(d.get("comprados")) == TYPE_ARRAY:
		for c in d["comprados"]:
			var p := str(c).split(":")
			if typeof(c) == TYPE_STRING and p.size() == 2 and not Aspectos.buscar(p[0], p[1]).is_empty() and not c in datos["comprados"]:
				datos["comprados"].append(c)
	if typeof(d.get("equipados")) == TYPE_DICTIONARY:
		for tipo in Aspectos.TIPOS:
			var id = d["equipados"].get(tipo)
			if typeof(id) == TYPE_STRING and tiene_aspecto(tipo, id):
				datos["equipados"][tipo] = id
	if typeof(d.get("premiados_dia")) == TYPE_STRING and d["premiados_dia"].length() == 10:
		datos["premiados_dia"] = d["premiados_dia"]
	if typeof(d.get("premiados_hoy")) == TYPE_FLOAT:
		datos["premiados_hoy"] = clampi(int(d["premiados_hoy"]), 0, Economia.PREMIADOS_DIA)
	if typeof(d.get("superados")) == TYPE_FLOAT:
		datos["superados"] = clampi(int(d["superados"]), 0, 10_000_000)


func _rechazar(motivo: String) -> void:
	ultimo_rechazo = motivo
	push_warning("Progreso no valido (%s); se empieza de cero." % motivo if OS.is_debug_build() else "Progreso no valido; se empieza de cero.")
	var apartado := "%s.rechazado-%d" % [ruta, int(Time.get_unix_time_from_system() * 1000.0)]
	var base := apartado
	var n := 1
	while FileAccess.file_exists(apartado):      # dos rechazos en el mismo milisegundo
		apartado = "%s-%d" % [base, n]
		n += 1
	DirAccess.rename_absolute(ProjectSettings.globalize_path(ruta), ProjectSettings.globalize_path(apartado))
	datos = por_defecto()


func guardar() -> void:
	var cuerpo := JSON.stringify(datos)
	Archivo.escribir(ruta, _firmar(cuerpo) + "\n" + cuerpo)


# ---------------------------------------------------------------- niveles

func _nivel(i: int) -> Dictionary:
	return datos["niveles"].get(str(i), {})


func estrellas(i: int) -> int:
	return int(_nivel(i).get("estrellas", 0))


func record(i: int) -> int:
	return int(_nivel(i).get("record", 0))


## El primero siempre; los demas al superar el anterior.
func desbloqueado(i: int) -> bool:
	return i == 0 or estrellas(i - 1) > 0


func total_estrellas() -> int:
	var t := 0
	for k in datos["niveles"]:
		t += int(datos["niveles"][k]["estrellas"])
	return t


## Nivel superado: guarda lo mejor y da gemas. Devuelve las gemas ganadas.
func registrar(i: int, estrellas_: int, puntos: int) -> int:
	var antes := estrellas(i)
	var n := _nivel(i)
	datos["niveles"][str(i)] = {"estrellas": maxi(antes, clampi(estrellas_, 0, 3)), "record": maxi(int(n.get("record", 0)), maxi(puntos, 0))}
	datos["superados"] = int(datos["superados"]) + 1
	var gemas := Economia.gemas_por_nivel(antes, clampi(estrellas_, 0, 3)) if estrellas_ > 0 else 0
	sumar_gemas(gemas)       # guarda
	return gemas


# ---------------------------------------------------------------- gemas

func gemas() -> int:
	return int(datos["gemas"])


func sumar_gemas(n: int) -> void:
	datos["gemas"] = clampi(gemas() + maxi(n, 0), 0, Economia.GEMAS_MAX)
	guardar()


## Gasta si hay suficientes. Devuelve si se pudo.
func gastar_gemas(n: int) -> bool:
	if n < 0 or gemas() < n:
		return false
	datos["gemas"] = gemas() - n
	guardar()
	return true


func premiados_restantes(hoy: String) -> int:
	if datos["premiados_dia"] != hoy:
		return Economia.PREMIADOS_DIA
	return Economia.PREMIADOS_DIA - int(datos["premiados_hoy"])


func registrar_premiado(hoy: String) -> void:
	if datos["premiados_dia"] != hoy:
		datos["premiados_dia"] = hoy
		datos["premiados_hoy"] = 0
	datos["premiados_hoy"] = int(datos["premiados_hoy"]) + 1
	guardar()


# ---------------------------------------------------------------- compras y aspectos

func sin_anuncios() -> bool:
	return bool(datos["sin_anuncios"])


func fijar_sin_anuncios(v: bool) -> void:
	datos["sin_anuncios"] = v
	guardar()


func tiene_aspecto(tipo: String, id: String) -> bool:
	var a := Aspectos.buscar(tipo, id)
	return not a.is_empty() and (int(a["precio"]) == 0 or ("%s:%s" % [tipo, id]) in datos["comprados"])


## Compra con gemas. Devuelve si se pudo (ya tenerlo cuenta como si).
func comprar_aspecto(tipo: String, id: String) -> bool:
	var a := Aspectos.buscar(tipo, id)
	if a.is_empty():
		return false
	if tiene_aspecto(tipo, id):
		return true
	if not gastar_gemas(int(a["precio"])):
		return false
	datos["comprados"].append("%s:%s" % [tipo, id])
	guardar()
	return true


func equipar(tipo: String, id: String) -> bool:
	if not tiene_aspecto(tipo, id):
		return false
	datos["equipados"][tipo] = id
	guardar()
	return true


func equipado(tipo: String) -> Dictionary:
	return Aspectos.buscar(tipo, str(datos["equipados"].get(tipo, Aspectos.por_defecto(tipo))))


func hoy() -> String:
	return Time.get_date_string_from_system()
