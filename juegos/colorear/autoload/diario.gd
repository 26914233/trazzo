# Lamina del dia y su racha. Racha suave: faltar un solo dia no la rompe (las
# reseñas castigan las rachas que se pierden por un despiste). No vale dinero, asi
# que no se firma: si el archivo esta roto se empieza de cero.
extends Node

var ruta := "user://diario.json"
var datos: Dictionary = {}       # {ultimo: "AAAA-MM-DD", racha: int, mejor: int}
var misterios: Array = []        # laminas misterio ya reveladas (terminadas)


func _ready() -> void:
	cargar()


func cargar() -> void:
	datos = {}
	misterios = []
	if not FileAccess.file_exists(ruta):
		return
	var d = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if typeof(d) != TYPE_DICTIONARY:
		return
	for id in d.get("misterios", []):
		if typeof(id) == TYPE_STRING and Laminas.existe(id) and not id in misterios:
			misterios.append(id)
	var ultimo := str(d.get("ultimo", ""))
	var racha_ = d.get("racha", 0)
	var mejor_ = d.get("mejor", 0)
	if not Laminas._es_fecha(ultimo) or typeof(racha_) != TYPE_FLOAT or typeof(mejor_) != TYPE_FLOAT \
			or racha_ < 1 or mejor_ < racha_ or mejor_ > 100000:
		return
	datos = {"ultimo": ultimo, "racha": int(racha_), "mejor": int(mejor_)}


static func hoy() -> String:
	return Time.get_date_string_from_system()


static func _dias(desde: String, hasta: String) -> int:
	return int((Time.get_unix_time_from_datetime_string(hasta + "T12:00:00")
		- Time.get_unix_time_from_datetime_string(desde + "T12:00:00")) / 86400)


## Racha que se ve el dia `fecha` (aun sin haber pintado ese dia).
func racha(fecha: String) -> int:
	if datos.is_empty():
		return 0
	var d := _dias(datos["ultimo"], fecha)
	return datos["racha"] if d >= 0 and d <= 2 else 0


func mejor() -> int:
	return int(datos.get("mejor", 0))


## Se pinto la lamina del dia en `fecha`.
func marcar(fecha: String) -> void:
	if datos.is_empty():
		datos = {"ultimo": fecha, "racha": 1, "mejor": 1}
	else:
		var d := _dias(datos["ultimo"], fecha)
		if d <= 0:
			return             # mismo dia o fecha anterior (reloj cambiado): nada
		datos["racha"] = datos["racha"] + 1 if d <= 2 else 1
		datos["ultimo"] = fecha
		datos["mejor"] = maxi(datos["mejor"], datos["racha"])
	_guardar()


func revelado(id: String) -> bool:
	return id in misterios


func marcar_misterio(id: String) -> void:
	if id in misterios or not Laminas.existe(id):
		return
	misterios.append(id)
	_guardar()


func _guardar() -> void:
	var d := datos.duplicate()
	d["misterios"] = misterios
	Archivo.escribir(ruta, JSON.stringify(d))
