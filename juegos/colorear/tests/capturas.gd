# Capturas de pantalla para revisar el diseño (necesita pantalla: xvfb-run).
#   xvfb-run godot --path juegos/colorear --resolution 1080x1920 res://tests/capturas.tscn -- --salida=/ruta
extends Node

var _salida := "user://capturas"


func _ready() -> void:
	await get_tree().process_frame
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--salida="):
			_salida = a.trim_prefix("--salida=")
		elif a.begins_with("--diseno="):
			Estilo.aplicar(a.trim_prefix("--diseno="))
	DirAccess.make_dir_recursive_absolute(_salida)
	Obras.carpeta = "user://capturas_obras/"
	DirAccess.make_dir_recursive_absolute(Obras.carpeta)
	await _captura("menu", "res://escenas/menu.tscn")
	var C = preload("res://escenas/colorear.gd")
	C.lamina_id = "mandalas_002"
	var e := await _captura("colorear_vacia", "res://escenas/colorear.tscn")
	# pinta la mitad de las zonas con la paleta para ver el resultado
	var cols := Paletas.colores(0)
	for z in range(1, e.lamina.zonas + 1, 2):
		e.lamina.pintar(z, cols[z % cols.size()])
	await _esperar(4)
	_guardar("colorear_pintada")
	e.vista.ampliar(3.0, e.vista.size / 2)
	await _esperar(4)
	_guardar("colorear_zoom")
	Obras.guardar(e.lamina)
	await _captura("menu_obras", "res://escenas/menu.tscn")
	get_tree().quit()


var _actual: Node


## Las pantallas se añaden como hijas: cambiar de escena mataria este script.
func _captura(nombre: String, escena: String) -> Node:
	if _actual:
		_actual.queue_free()
	_actual = load(escena).instantiate()
	add_child(_actual)
	await _esperar(6)
	_guardar(nombre)
	return _actual


func _esperar(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _guardar(nombre: String) -> void:
	get_viewport().get_texture().get_image().save_png(_salida.path_join(nombre + ".png"))
