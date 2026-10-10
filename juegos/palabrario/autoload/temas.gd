# Categorias y sopas (datos/categorias/*.json, generados desde datos/fuente/*.txt
# con herramientas/construir_temas.py). Tambien guarda la sopa elegida entre escenas.
extends Node

const RUTA := "res://datos/categorias/"

var lista: Array[Dictionary] = []
var por_id: Dictionary = {}

## La sopa elegida para la proxima partida.
var seleccion: Dictionary = {"categoria": "", "subtema": "", "dificultad": 0, "diario": false}
## Pantalla a la que vuelve la lista de sopas: "mapa" (viaje) o "categorias" (lista).
var volver_a := "mapa"


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
	var extras := candidatas_extra(cat, sub, palabras, base)
	var sopa: GeneradorSopa.Sopa
	for intento in 40:
		if intento > 0 and intento % 10 == 0:
			lado += 1
		sopa = GeneradorSopa.generar(palabras, lado, dificultad, base + intento, extras)
		if sopa.descartadas.is_empty():
			return sopa
	push_error("Sopa incompleta: %s/%s dificultad %d" % [cat, sub, dificultad])
	return sopa


## Candidatas a palabra extra: primero las del tema que no entran en esta
## dificultad, luego las de otros temas de la categoria (orden fijo por semilla).
func candidatas_extra(cat: String, sub: String, usadas: PackedStringArray, semilla_: int) -> PackedStringArray:
	var fuera := {}
	for p in usadas:
		fuera[GeneradorSopa.normalizar(p)] = true
	var del_tema: Array = []
	var otras: Array = []
	for s in categoria(cat).get("subtemas", []):
		for p in s["palabras"]:
			var n := GeneradorSopa.normalizar(p)
			if fuera.has(n) or n.length() > 9:
				continue
			fuera[n] = true
			(del_tema if s["id"] == sub else otras).append(p)
	var rng := RandomNumberGenerator.new()
	rng.seed = semilla_ ^ 0x5EC12E7
	for lista_ in [del_tema, otras]:
		for i in range(lista_.size() - 1, 0, -1):
			var j := rng.randi_range(0, i)
			var t = lista_[i]
			lista_[i] = lista_[j]
			lista_[j] = t
	return PackedStringArray((del_tema + otras).slice(0, 8))


## Sopa al azar (modo sin fin): palabras de todos los temas de una categoria,
## mezcladas con la semilla. Misma semilla = misma sopa.
func generar_aleatoria(cat: String, dificultad: int, semilla_: int) -> GeneradorSopa.Sopa:
	var vistas := {}
	var pool: Array = []
	for s in categoria(cat).get("subtemas", []):
		for p in s["palabras"]:
			var n := GeneradorSopa.normalizar(p)
			if not vistas.has(n):
				vistas[n] = true
				pool.append(p)
	pool.sort()                          # orden fijo antes de barajar
	var rng := RandomNumberGenerator.new()
	rng.seed = semilla_
	for i in range(pool.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t = pool[i]
		pool[i] = pool[j]
		pool[j] = t
	var n: int = Economia.DIFICULTADES[dificultad]["palabras"]
	var palabras := PackedStringArray(pool.slice(0, n))
	var extras := PackedStringArray(pool.slice(n, n + 8).filter(func(p): return GeneradorSopa.normalizar(p).length() <= 9))
	var lado := lado_para(palabras, dificultad)
	var sopa: GeneradorSopa.Sopa
	for intento in 40:
		if intento > 0 and intento % 10 == 0:
			lado += 1
		sopa = GeneradorSopa.generar(palabras, lado, dificultad, semilla_ + intento, extras)
		if sopa.descartadas.is_empty():
			return sopa
	push_error("Sopa al azar incompleta: %s dificultad %d" % [cat, dificultad])
	return sopa


## Seleccion para una sopa al azar de cualquier categoria.
func nueva_aleatoria(dificultad: int) -> Dictionary:
	var c: Dictionary = lista[randi() % lista.size()]
	return {"categoria": c["id"], "subtema": "", "dificultad": dificultad, "diario": false,
		"aleatoria": true, "semilla": randi()}


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
