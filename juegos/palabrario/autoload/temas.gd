# Categorias y sopas (datos/categorias/*.json, generados desde datos/fuente/*.txt
# con herramientas/construir_temas.py). Tambien guarda la sopa elegida entre escenas.
extends Node

const RUTA := "res://datos/categorias/"

var lista: Array[Dictionary] = []
var por_id: Dictionary = {}

## La sopa elegida para la proxima partida.
var seleccion: Dictionary = {"categoria": "", "subtema": "", "dificultad": 0, "diario": false}


func _ready() -> void:
	cargar()


func cargar() -> void:
	lista.clear()
	por_id.clear()
	for archivo in DirAccess.get_files_at(RUTA):
		if not archivo.ends_with(".json"):
			continue
		var datos = JSON.parse_string(FileAccess.get_file_as_string(RUTA + archivo))
		if not _categoria_valida(datos):
			push_error("Categoria invalida: %s" % archivo)
			continue
		lista.append(datos)
		por_id[datos["id"]] = datos
	lista.sort_custom(func(a, b): return a.get("orden", 0) < b.get("orden", 0))
	if lista.is_empty():
		push_error("No se cargo ninguna categoria desde %s" % RUTA)


static func _categoria_valida(d) -> bool:
	if typeof(d) != TYPE_DICTIONARY or typeof(d.get("id")) != TYPE_STRING or d["id"] == "":
		return false
	if typeof(d.get("subtemas")) != TYPE_ARRAY or d["subtemas"].is_empty():
		return false
	for s in d["subtemas"]:
		if typeof(s) != TYPE_DICTIONARY or typeof(s.get("id")) != TYPE_STRING:
			return false
		if typeof(s.get("palabras")) != TYPE_ARRAY or not s["palabras"].all(func(p): return typeof(p) == TYPE_STRING):
			return false
	return true


func categoria(id: String) -> Dictionary:
	return por_id.get(id, {})


func indice_subtema(cat: String, sub: String) -> int:
	var subs: Array = categoria(cat).get("subtemas", [])
	for i in subs.size():
		if subs[i]["id"] == sub:
			return i
	return -1


func subtema(cat: String, sub: String) -> Dictionary:
	var i := indice_subtema(cat, sub)
	return categoria(cat)["subtemas"][i] if i >= 0 else {}


func total_sopas() -> int:
	var n := 0
	for c in lista:
		n += c["subtemas"].size()
	return n


## Palabras de una sopa segun la dificultad: las mas cortas primero, asi en
## Facil caben en una cuadricula pequeña y en Dificil entran todas.
func palabras_sopa(cat: String, sub: String, dificultad: int) -> PackedStringArray:
	var todas: Array = subtema(cat, sub).get("palabras", []).duplicate()
	var orden := {}
	for i in todas.size():
		orden[todas[i]] = i
	todas.sort_custom(func(a, b):
		var la := GeneradorSopa.normalizar(a).length()
		var lb := GeneradorSopa.normalizar(b).length()
		return la < lb if la != lb else orden[a] < orden[b])
	var n: int = Economia.DIFICULTADES[dificultad]["palabras"]
	return PackedStringArray(todas.slice(0, n))


## Lado de la cuadricula: el de la dificultad, o mas si una palabra no cabe.
static func lado_para(palabras: PackedStringArray, dificultad: int) -> int:
	var lado: int = Economia.DIFICULTADES[dificultad]["lado"]
	for p in palabras:
		lado = maxi(lado, GeneradorSopa.normalizar(p).length())
	return lado


## Cada sopa tiene una disposicion fija por dificultad: la sopa 7 de Comida en
## Normal es la misma para todos (comparable, y sin servidor).
static func semilla(cat: String, sub: String, dificultad: int) -> int:
	return hash("%s|%s|%d" % [cat, sub, dificultad])


## Si con una disposicion no caben todas las palabras (pasa con varias palabras
## largas en poco espacio), se prueba otra y, si hace falta, una fila mas.
## Sigue siendo deterministico: la misma sopa sale igual en todos los moviles.
func generar(cat: String, sub: String, dificultad: int) -> GeneradorSopa.Sopa:
	var palabras := palabras_sopa(cat, sub, dificultad)
	var lado := lado_para(palabras, dificultad)
	var base := semilla(cat, sub, dificultad)
	var sopa: GeneradorSopa.Sopa
	for intento in 40:
		if intento > 0 and intento % 10 == 0:
			lado += 1
		sopa = GeneradorSopa.generar(palabras, lado, dificultad, base + intento)
		if sopa.descartadas.is_empty():
			return sopa
	push_error("Sopa incompleta: %s/%s dificultad %d" % [cat, sub, dificultad])
	return sopa


## Sopa del dia: la misma para todo el mundo cada fecha, elegida entre todas.
func sopa_del_dia(fecha: String) -> Dictionary:
	var total := total_sopas()
	if total == 0:
		return {}
	var k := absi(hash("diario|" + fecha)) % total
	for c in lista:
		var n: int = c["subtemas"].size()
		if k < n:
			return {"categoria": c["id"], "subtema": c["subtemas"][k]["id"]}
		k -= n
	return {}


## La sopa que va despues de esta: la siguiente de la categoria, o la primera
## de la siguiente categoria. {} al final del todo.
func siguiente(cat: String, sub: String) -> Dictionary:
	var i := indice_subtema(cat, sub)
	var c := categoria(cat)
	if i >= 0 and i + 1 < c["subtemas"].size():
		return {"categoria": cat, "subtema": c["subtemas"][i + 1]["id"]}
	var ci := lista.find(c)
	if ci >= 0 and ci + 1 < lista.size():
		return {"categoria": lista[ci + 1]["id"], "subtema": lista[ci + 1]["subtemas"][0]["id"]}
	return {}
