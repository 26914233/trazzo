# Catalogo de niveles (datos/niveles.json, generado por herramientas/niveles.py).
extends Node

const RUTA := "res://datos/niveles.json"

var _mundos: Array = []          # [{nombre, fondo: [c1, c2], niveles: [...]}]
var _todos: Array = []           # niveles en orden, con "mundo"


func _ready() -> void:
	var d = JSON.parse_string(FileAccess.get_file_as_string(RUTA))
	if typeof(d) != TYPE_DICTIONARY or typeof(d.get("mundos")) != TYPE_ARRAY:
		push_error("No se pudo leer %s" % RUTA)
		return
	_mundos = d["mundos"]
	for m in _mundos.size():
		for n in _mundos[m]["niveles"]:
			n["mundo"] = m
			_todos.append(n)


func total() -> int:
	return _todos.size()


func nivel(i: int) -> Dictionary:
	return _todos[clampi(i, 0, _todos.size() - 1)]


func mundos() -> Array:
	return _mundos


## Indice del primer nivel de un mundo.
func inicio_mundo(m: int) -> int:
	var i := 0
	for k in m:
		i += _mundos[k]["niveles"].size()
	return i
