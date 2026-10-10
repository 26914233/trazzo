# Ajustes del jugador (sonido, vibracion, diseño). JSON con escritura atomica.
# No se firma: no guarda nada que valga dinero (todo el contenido viene incluido).
extends Node

const POR_DEFECTO := {"sonido": true, "vibracion": true, "diseno": "cielo", "paleta": 0, "pincel": true,
	"musica": false, "ocultar_terminadas": false, "mis_colores": []}
const MAX_COLORES := 12

var ruta := "user://ajustes.json"
var datos: Dictionary = {}


func _ready() -> void:
	cargar()
	Estilo.aplicar(str(datos["diseno"]))


func cargar() -> void:
	datos = POR_DEFECTO.duplicate(true)
	var leido = JSON.parse_string(FileAccess.get_file_as_string(ruta)) if FileAccess.file_exists(ruta) else null
	if typeof(leido) == TYPE_DICTIONARY:
		for k in leido:
			if datos.has(k) and typeof(leido[k]) == typeof(datos[k]):
				datos[k] = leido[k]
	# solo colores validos, sin repetir y con tope
	var colores := []
	for h in datos["mis_colores"]:
		if typeof(h) == TYPE_STRING and Color.html_is_valid(h) and not h.to_lower() in colores and colores.size() < MAX_COLORES:
			colores.append(h.to_lower())
	datos["mis_colores"] = colores


func valor(nombre: String):
	return datos.get(nombre)


func fijar(nombre: String, v) -> void:
	datos[nombre] = v
	Archivo.escribir(ruta, JSON.stringify(datos))


func mis_colores() -> Array:
	return datos["mis_colores"].map(func(h): return Color.html(h))


## Añade un color a "Mis colores" (al final). Lleno: sale el mas antiguo.
func agregar_color(c: Color) -> void:
	if c.is_equal_approx(Color.WHITE):
		return
	var h := c.to_html(false).to_lower()
	var lista: Array = datos["mis_colores"].duplicate()
	if h in lista:
		return
	lista.append(h)
	while lista.size() > MAX_COLORES:
		lista.pop_front()
	fijar("mis_colores", lista)
