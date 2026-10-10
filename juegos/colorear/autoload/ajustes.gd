# Ajustes del jugador (sonido, vibracion, diseño). JSON con escritura atomica.
# No se firma: no guarda nada que valga dinero (todo el contenido viene incluido).
extends Node

const POR_DEFECTO := {"sonido": true, "vibracion": true, "diseno": "cielo", "paleta": 0, "pincel": true}

var ruta := "user://ajustes.json"
var datos: Dictionary = {}


func _ready() -> void:
	cargar()
	Estilo.aplicar(str(datos["diseno"]))


func cargar() -> void:
	datos = POR_DEFECTO.duplicate()
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
