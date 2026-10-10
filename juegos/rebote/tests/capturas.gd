# Capturas para revisar el diseño (necesita pantalla: xvfb-run).
#   xvfb-run godot --path juegos/rebote --resolution 1080x1920 res://tests/capturas.tscn -- --salida=/ruta
extends Node

var _salida := "user://capturas"
var _actual: Node


func _ready() -> void:
	await get_tree().process_frame
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--salida="):
			_salida = a.trim_prefix("--salida=")
	DirAccess.make_dir_recursive_absolute(_salida)
	Progreso.ruta = "user://capturas_progreso.save"
	Progreso.datos = Progreso.por_defecto()
	Progreso.datos["gemas"] = 640
	Progreso.datos["comprados"] = ["bola:sol", "estela:arcoiris", "paleta:lava"]
	Progreso.datos["equipados"] = {"paleta": "lava", "bola": "sol", "estela": "arcoiris"}
	for i in 13:
		Progreso.datos["niveles"][str(i)] = {"estrellas": 1 + i % 3, "record": 1000}
	Ajustes.datos["sonido"] = false
	await _captura("menu", "res://escenas/menu.tscn")
	await _captura("mundos", "res://escenas/mundos.tscn")
	await _captura("tienda", "res://escenas/tienda.tscn")
	var pers: Node = await _captura("personalizar_paletas", "res://escenas/personalizar.tscn")
	for t in ["bola", "estela"]:
		pers.tipo = t
		pers.construir()
		await _esperar(6)
		_guardar("personalizar_%s" % t)
	preload("res://escenas/juego.gd").nivel_idx = 12
	await _captura("juego_13_potenciadores", "res://escenas/juego.tscn")
	for nivel in [0, 41, 97]:
		preload("res://escenas/juego.gd").nivel_idx = nivel
		var j: Node = await _captura("juego_%d_inicio" % (nivel + 1), "res://escenas/juego.tscn")
		# juega un rato con el jugador automatico para ver ladrillos rotos y potenciadores
		var p: Partida = j.partida
		p.lanzar()
		p.aplicar(Partida.MULTIBOLA)
		p.aplicar(Partida.LASER)
		for k in 60 * 9:
			p.mover_paleta(p.bola_mas_baja().x)
			p.paso(1.0 / 60)
			for ev in p.tomar_eventos():
				j._al_evento(ev)
		p.soltar_capsula(Partida.FUEGO, Vector2(300, 900))
		p.soltar_capsula(Partida.ANCHA, Vector2(700, 1000))
		await _esperar(4)
		_guardar("juego_%d_jugando" % (nivel + 1))
	get_tree().quit()


func _captura(nombre: String, escena: String) -> Node:
	if _actual:
		_actual.queue_free()
		await _esperar(2)
	_actual = load(escena).instantiate()
	add_child(_actual)
	await _esperar(10)
	_guardar(nombre)
	return _actual


func _esperar(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _guardar(nombre: String) -> void:
	get_viewport().get_texture().get_image().save_png(_salida.path_join(nombre + ".png"))


func _exit_tree() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Progreso.ruta))
