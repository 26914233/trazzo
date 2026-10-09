# Capturas de las pantallas en cada diseño, para elegir diseño y para la ficha de Play.
#   xvfb-run godot --path juegos/palabrario --resolution 1080x1920 res://tests/capturas.tscn -- --salida=/ruta [--diseno=papel]
# Usa un guardado aparte para no tocar el progreso real.
extends Node

var _salida := "user://capturas"
var _disenos: Array = Estilo.VARIANTES.keys()


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--salida="):
			_salida = a.trim_prefix("--salida=")
		if a.begins_with("--diseno="):
			_disenos = [a.trim_prefix("--diseno=")]
	Progreso.ruta = "user://capturas_progreso.save"
	for id in _disenos:
		await _serie(id)
	get_tree().quit()


func _preparar_progreso() -> void:
	Progreso.datos = Progreso.por_defecto()
	Progreso.datos["racha"] = 4
	Progreso.datos["ultimo_dia"] = Progreso.hoy()
	Progreso.datos["dificultad"] = 1
	# Algunas sopas resueltas para que el progreso se vea.
	var n := 0
	for c in Temas.lista.slice(0, 8):
		for s in c["subtemas"].slice(0, 3 - (n % 3)):
			Progreso.datos["estrellas"]["%s/%s/1" % [c["id"], s["id"]]] = 1 + (n % 3)
			n += 1
	var comida: Dictionary = Temas.categoria("comida")
	Progreso.datos["ultima"] = {"categoria": "comida", "subtema": comida["subtemas"][1]["id"]}
	Progreso.guardar()


func _serie(id: String) -> void:
	Estilo.aplicar(id)
	_preparar_progreso()
	var dir := _salida.path_join(id)
	DirAccess.make_dir_recursive_absolute(dir)
	Temas.seleccion = {"categoria": "comida", "subtema": "", "dificultad": 1, "diario": false}
	for nombre in ["menu", "categorias", "sopas", "ajustes"]:
		await _capturar(nombre, dir)

	# Partida a medias: 4 palabras encontradas, una seleccion en curso y una pista.
	var c: Dictionary = Temas.categoria("colombia")
	Temas.seleccion = {"categoria": "colombia", "subtema": c["subtemas"][5]["id"], "dificultad": 1, "diario": false}
	var juego: Control = load("res://escenas/juego.tscn").instantiate()
	add_child(juego)
	await _esperar(4)
	var sopa: GeneradorSopa.Sopa = juego._sopa
	for i in 4:
		juego._al_seleccionar(sopa.colocadas[i].celdas.duplicate())
	juego._segundos = 52.0
	var t: Tablero = juego._tablero
	t._seleccion = sopa.colocadas[4].celdas.slice(0, 3)
	t.mostrar_pista(sopa.colocadas[6].celdas[0])
	await _esperar(6)
	await _guardar("juego", dir)
	# Tienda de pistas abierta sobre la partida.
	juego._tienda_pistas()
	await get_tree().create_timer(0.4).timeout
	await _guardar("tienda_pistas", dir)
	var velo := juego.get_child(juego.get_child_count() - 1)
	velo.queue_free()
	await _esperar(2)
	t._seleccion.clear()
	for i in range(4, sopa.colocadas.size()):
		juego._al_seleccionar(sopa.colocadas[i].celdas.duplicate())
	await get_tree().create_timer(1.3).timeout
	await _guardar("victoria", dir)
	juego.queue_free()
	await _esperar(2)
	print("diseño %s listo" % id)


func _capturar(nombre: String, dir: String) -> void:
	var e: Node = load("res://escenas/%s.tscn" % nombre).instantiate()
	add_child(e)
	await _esperar(8)
	await _guardar(nombre, dir)
	e.queue_free()
	await _esperar(2)


func _esperar(frames: int) -> void:
	for i in frames:
		await get_tree().process_frame


func _guardar(nombre: String, dir: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(dir.path_join(nombre + ".png"))
