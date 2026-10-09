# Saca capturas de las pantallas para revisarlas y para la ficha de Play.
#   xvfb-run godot --path juegos/sopazz --resolution 1080x1920 res://tests/capturas.tscn -- --salida=/ruta
# Usa un guardado aparte para no tocar el progreso real.
extends Node

var _salida := "user://capturas"


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--salida="):
			_salida = a.trim_prefix("--salida=")
	DirAccess.make_dir_recursive_absolute(_salida)
	Progreso.ruta = "user://capturas_progreso.save"
	Progreso.datos = Progreso.por_defecto()
	Progreso.datos["fichas"] = 340
	Progreso.datos["racha"] = 4
	Progreso.datos["niveles_completados"] = 5
	Progreso.datos["niveles"] = {"animales|1": 7, "comida|1": 3, "colombia|1": 12}
	Progreso.guardar()
	Monetizacion.stub_demora_s = 0.01

	for nombre in ["menu", "selector", "tienda", "ajustes"]:
		await _capturar(nombre)

	# Partida a medias: 3 palabras encontradas y una seleccion en curso.
	Temas.seleccion = {"tema": "colombia", "dificultad": 1, "nivel": 12, "diario": false}
	var juego: Control = load("res://escenas/juego.tscn").instantiate()
	add_child(juego)
	await _esperar(4)
	var sopa: GeneradorSopa.Sopa = juego._sopa
	for i in 3:
		juego._al_seleccionar(sopa.colocadas[i].celdas.duplicate())
	juego._segundos = 47.0
	var t: Tablero = juego._tablero
	t._seleccion = sopa.colocadas[3].celdas.slice(0, 3)
	t.mostrar_pista(sopa.colocadas[5].celdas[0])
	await _esperar(6)
	await _guardar("juego")
	t._seleccion.clear()
	for i in range(3, sopa.colocadas.size()):
		juego._al_seleccionar(sopa.colocadas[i].celdas.duplicate())
	await get_tree().create_timer(1.3).timeout
	await _guardar("victoria")
	get_tree().quit()


func _capturar(nombre: String) -> void:
	var e: Node = load("res://escenas/%s.tscn" % nombre).instantiate()
	add_child(e)
	await _esperar(6)
	await _guardar(nombre)
	e.queue_free()
	await _esperar(2)


func _esperar(frames: int) -> void:
	for i in frames:
		await get_tree().process_frame


func _guardar(nombre: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(_salida.path_join(nombre + ".png"))
	print("captura: ", nombre)
