# Carga los temas de datos/temas/*.json y prepara las palabras de cada nivel.
# Tambien guarda la seleccion actual (tema, dificultad, nivel) entre escenas.
extends Node

const RUTA := "res://datos/temas/"

var lista: Array[Dictionary] = []
var por_id: Dictionary = {}

## Lo que el jugador eligio para la proxima partida.
var seleccion: Dictionary = {"tema": "animales", "dificultad": 0, "nivel": 1, "diario": false}


func _ready() -> void:
	cargar()


func cargar() -> void:
	lista.clear()
	por_id.clear()
	for archivo in DirAccess.get_files_at(RUTA):
		# En el APK los JSON pueden venir con sufijo .remap/.import; solo leemos .json.
		if not archivo.ends_with(".json"):
			continue
		var texto := FileAccess.get_file_as_string(RUTA + archivo)
		var datos = JSON.parse_string(texto)
		if not _tema_valido(datos):
			push_error("Tema invalido: %s" % archivo)
			continue
		lista.append(datos)
		por_id[datos["id"]] = datos
	lista.sort_custom(func(a, b): return a.get("orden", 0) < b.get("orden", 0))
	if lista.is_empty():
		push_error("No se cargo ningun tema desde %s" % RUTA)


static func _tema_valido(d) -> bool:
	if typeof(d) != TYPE_DICTIONARY:
		return false
	if typeof(d.get("id")) != TYPE_STRING or d["id"] == "" or typeof(d.get("palabras")) != TYPE_ARRAY:
		return false
	return d["palabras"].all(func(p): return typeof(p) == TYPE_STRING)


func tema(id: String) -> Dictionary:
	return por_id.get(id, {})


## Semilla de un nivel: el nivel 7 de Animales en Normal es siempre la misma sopa.
static func semilla_nivel(id_tema: String, dificultad: int, nivel: int) -> int:
	return hash("%s|%d|%d" % [id_tema, dificultad, nivel])


## Semilla del nivel del dia: igual para todos los jugadores ese dia, sin servidor.
static func semilla_diaria(fecha: String) -> int:
	return hash("diario|" + fecha)


## Elige las palabras de un nivel de forma reproducible.
func palabras_nivel(id_tema: String, dificultad: int, semilla: int) -> PackedStringArray:
	var d: Dictionary = Economia.DIFICULTADES[dificultad]
	var candidatas: Array = []
	for p in tema(id_tema).get("palabras", []):
		var largo := GeneradorSopa.normalizar(p).length()
		if largo >= 3 and largo <= d["max_largo"] and largo <= d["lado"]:
			candidatas.append(p)
	var rng := RandomNumberGenerator.new()
	rng.seed = semilla
	GeneradorSopa._barajar(candidatas, rng)
	var elegidas := PackedStringArray()
	for p in candidatas.slice(0, d["palabras"]):
		elegidas.append(p)
	return elegidas


## Sopa completa lista para jugar.
func generar_nivel(id_tema: String, dificultad: int, semilla: int) -> GeneradorSopa.Sopa:
	var d: Dictionary = Economia.DIFICULTADES[dificultad]
	return GeneradorSopa.generar(palabras_nivel(id_tema, dificultad, semilla), d["lado"], dificultad, semilla)
