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
	for f in DirAccess.get_files_at(Obras.carpeta):     # cada corrida empieza sin obras
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Obras.carpeta.path_join(f)))
	await _captura("menu", "res://escenas/menu.tscn")
	var C = preload("res://escenas/colorear.gd")
	C.lamina_id = "animales_i010"
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
	e.vista.reiniciar_zoom()
	e.buscar_zona()
	await _esperar(40)                   # animacion de camara + latido
	_guardar("colorear_buscar")
	for z in range(1, e.lamina.zonas):
		e.lamina.pintar(z, cols[z % cols.size()])
	e._pintar(e.lamina.zonas)
	await _esperar(30)
	_guardar("colorear_celebra")
	await get_tree().create_timer(1.6).timeout
	_guardar("colorear_terminada")
	e.lamina.imagen().save_png(_salida.path_join("imagen_exportada.png"))
	Obras.guardar(e.lamina)
	Ajustes.fijar("mis_colores", ["#e63946", "#2a9d8f", "#e9c46a"])
	e._poner_paleta(Paletas.MIS_COLORES)
	e.elegir_color_libre()
	await _esperar(20)
	_guardar("color_libre")
	await _captura("menu_obras", "res://escenas/menu.tscn")
	preload("res://escenas/menu.gd").categoria_actual = "animales"
	var mn := await _captura("menu_animales", "res://escenas/menu.tscn")
	mn.abrir_ajustes()
	await _esperar(20)
	_guardar("menu_ajustes")
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
