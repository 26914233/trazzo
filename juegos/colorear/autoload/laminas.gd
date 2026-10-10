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


func categoria_de(id: String) -> String:
	return _por_id[id]["categoria"] if existe(id) else ""


func ruta_zonas(id: String) -> String:
	return "%s%s/%s_zonas.bin" % [RAIZ, _por_id[id]["categoria"], id]


## Lamina del dia para una fecha "AAAA-MM-DD": la misma para todos ese dia y sin
## repetir hasta recorrer todas. El paso salta entre categorias (el indice va por
## categorias) y es coprimo con el total, asi que pasa por todas las laminas.
func del_dia(fecha: String) -> String:
	if not _es_fecha(fecha) or _por_id.is_empty():
		return ""
	var dia := int(Time.get_unix_time_from_datetime_string(fecha + "T12:00:00") / 86400)
	var ids := _por_id.keys()
	var n := ids.size()
	var paso := 7919
	while _mcd(paso, n) != 1:
		paso += 1
	return ids[posmod(dia * paso, n)]


## Lamina misterio de la semana (lunes a domingo): una ilustrada, la misma para
## todos, que nunca coincide con la lamina del dia de esa semana.
func misterio(fecha: String) -> String:
	if not _es_fecha(fecha):
		return ""
	var dia := int(Time.get_unix_time_from_datetime_string(fecha + "T12:00:00") / 86400)
	var lunes := dia - posmod(dia + 3, 7)          # el 1-1-1970 fue jueves
	var ilustradas := _por_id.keys().filter(func(id): return "_i" in id)
	var n := ilustradas.size()
	if n == 0:
		return ""
	var paso := 4999
	while _mcd(paso, n) != 1:
		paso += 1
	var del_dia_semana := {}
	for d in 7:
		del_dia_semana[del_dia(Time.get_date_string_from_unix_time((lunes + d) * 86400 + 43200))] = true
	var i := posmod((lunes / 7) * paso, n)
	for intento in n:
		var id: String = ilustradas[posmod(i + intento, n)]
		if not del_dia_semana.has(id):
			return id
	return ilustradas[i]


static func _es_fecha(s: String) -> bool:
	var p := s.split("-")
	return p.size() == 3 and p[0].length() == 4 and p[0].is_valid_int() and p[1].is_valid_int() and p[2].is_valid_int() \
		and int(p[1]) >= 1 and int(p[1]) <= 12 and int(p[2]) >= 1 and int(p[2]) <= 31


static func _mcd(a: int, b: int) -> int:
	while b != 0:
		var t := b
		b = a % b
		a = t
	return a


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
	var l := Lamina.new(id, _por_id[id]["zonas"], reg, lin)
	if FileAccess.file_exists(ruta_zonas(id)):
		l.info_zonas = FileAccess.get_file_as_bytes(ruta_zonas(id))
	else:
		push_warning("Sin datos de zonas para %s: no se podra buscar zona sin pintar" % id)
	return l
