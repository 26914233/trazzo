# Ajustes del jugador (sonido, musica, vibracion). JSON con escritura atomica.
extends Node

const POR_DEFECTO := {"sonido": true, "vibracion": true}

var ruta := "user://ajustes.json"
var datos: Dictionary = {}


func _ready() -> void:
	cargar()
	Estilo.aplicar("espacio")


func cargar() -> void:
	datos = POR_DEFECTO.duplicate(true)
	var leido = JSON.parse_string(FileAccess.get_file_as_string(ruta)) if FileAccess.file_exists(ruta) else null
	if typeof(leido) == TYPE_DICTIONARY:
		for k in leido:
			if datos.has(k) and typeof(leido[k]) == typeof(datos[k]):
				datos[k] = leido[k]


func valor(nombre: String):
	return datos.get(nombre)


func fijar(nombre: String, v) -> void:
	datos[nombre] = v
	Archivo.escribir(ruta, JSON.stringify(datos))
