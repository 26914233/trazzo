# Catalogo de laminas (datos/laminas/indice.json, generado por herramientas/laminas.py).
extends Node

const RAIZ := "res://datos/laminas/"

var lado := 1280
var categorias: Array = []      # [{id, nombre, laminas: [{id, zonas}]}]
var _por_id := {}               # id -> {categoria, zonas}


func _ready() -> void:
	var d = JSON.parse_string(FileAccess.get_file_as_string(RAIZ + "indice.json"))
	if typeof(d) != TYPE_DICTIONARY:
		push_error("No se pudo leer el indice de laminas")
		return
	lado = int(d.get("lado", 1280))
	categorias = d["categorias"]
	for c in categorias:
		for l in c["laminas"]:
			_por_id[l["id"]] = {"categoria": c["id"], "zonas": int(l["zonas"])}


func existe(id: String) -> bool:
	return _por_id.has(id)


func categoria(id: String) -> Dictionary:
	for c in categorias:
		if c["id"] == id:
			return c
	return {}


## "Mandala 12", "Vitral 3"...
func nombre(id: String) -> String:
	var cat := categoria(_por_id[id]["categoria"]) if existe(id) else {}
	return "%s %d" % [cat.get("nombre", "Lámina"), numero(id)]


## Número de la lámina dentro de su categoría (las hechas por código y las
## ilustradas se numeran seguidas: primero las ilustradas).
func numero(id: String) -> int:
	if not existe(id):
		return 0
	var lista: Array = categoria(_por_id[id]["categoria"])["laminas"]
	for i in lista.size():
		if lista[i]["id"] == id:
			return i + 1
	return 0


func total() -> int:
	return _por_id.size()


func ruta(id: String, parte: String) -> String:
	return "%s%s/%s_%s.png" % [RAIZ, _por_id[id]["categoria"], id, parte]


## Lamina lista para colorear (sin colores guardados).
func abrir(id: String) -> Lamina:
	if not existe(id):
		return null
	var reg: Texture2D = load(ruta(id, "regiones"))
	var lin: Texture2D = load(ruta(id, "lineas"))
	if reg == null or lin == null:
		push_error("Faltan las imagenes de la lamina %s" % id)
		return null
	return Lamina.new(id, _por_id[id]["zonas"], reg, lin)
