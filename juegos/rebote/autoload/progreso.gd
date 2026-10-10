# Progreso: estrellas y record por nivel. No vale dinero (todo incluido), asi que no
# se firma; al leer se acota todo y lo raro se descarta.
extends Node

var ruta := "user://progreso.json"
var datos: Dictionary = {}       # {"niveles": {"<indice>": {"estrellas": 0..3, "record": int}}}


func _ready() -> void:
	cargar()


func cargar() -> void:
	datos = {"niveles": {}}
	if not FileAccess.file_exists(ruta):
		return
	var d = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if typeof(d) != TYPE_DICTIONARY or typeof(d.get("niveles")) != TYPE_DICTIONARY:
		return
	for k in d["niveles"]:
		var v = d["niveles"][k]
		if typeof(k) != TYPE_STRING or not k.is_valid_int() or typeof(v) != TYPE_DICTIONARY:
			continue
		var e = v.get("estrellas", 0)
		var r = v.get("record", 0)
		if typeof(e) != TYPE_FLOAT or typeof(r) != TYPE_FLOAT:
			continue
		datos["niveles"][k] = {"estrellas": clampi(int(e), 0, 3), "record": clampi(int(r), 0, 99_999_999)}


func _nivel(i: int) -> Dictionary:
	return datos.get("niveles", {}).get(str(i), {})


func estrellas(i: int) -> int:
	return int(_nivel(i).get("estrellas", 0))


func record(i: int) -> int:
	return int(_nivel(i).get("record", 0))


## El primero siempre; los demas al superar el anterior.
func desbloqueado(i: int) -> bool:
	return i == 0 or estrellas(i - 1) > 0


func total_estrellas() -> int:
	var t := 0
	for k in datos.get("niveles", {}):
		t += int(datos["niveles"][k]["estrellas"])
	return t


func registrar(i: int, estrellas_: int, puntos: int) -> void:
	if not datos.has("niveles"):
		datos["niveles"] = {}
	var n := _nivel(i)
	datos["niveles"][str(i)] = {"estrellas": maxi(int(n.get("estrellas", 0)), clampi(estrellas_, 0, 3)),
		"record": maxi(int(n.get("record", 0)), maxi(puntos, 0))}
	Archivo.escribir(ruta, JSON.stringify(datos))
