# Prueba automática: abre cada prototipo y lo resuelve paso a paso con las mismas piezas que usa el
# jugador (tocar, elegir objetos, ranuras), comprueba que cada paso se cumple, que los bloqueos
# funcionan, que las pistas y el inventario responden, y que un arrastre de verdad (eventos de toque)
# mueve la pieza. Guarda capturas en puzles/capturas/.
#   xvfb-run -a godot --path puzles/godot --rendering-driver opengl3 -- --prueba [--solo=<id>]
# Sale con código 0 si todo fue bien y 1 si algo falló.
extends Node

const Catalogo := preload("res://scripts/catalogo.gd")

var principal
var resultados: Array = []
var carpeta := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	carpeta = ProjectSettings.globalize_path("res://").path_join("../capturas").simplify_path()
	DirAccess.make_dir_recursive_absolute(carpeta)
	_correr.call_deferred()


func _correr() -> void:
	var solo := ""
	for argumento in OS.get_cmdline_user_args():
		if argumento.begins_with("--solo="):
			solo = argumento.get_slice("=", 1)
	principal.abrir_menu()
	await _esperar(0.8)
	_registrar("menú con los cuatro prototipos", principal.actual.tarjetas.size() == Catalogo.PROTOTIPOS.size())
	await _capturar("menu")
	for datos in Catalogo.PROTOTIPOS:
		if solo != "" and datos.id != solo:
			continue
		if not ResourceLoader.exists(datos.script):
			_registrar(datos.id + ": existe el guion", false)
			continue
		await _probar(datos)
	principal.abrir_menu()
	await _esperar(0.6)
	await _capturar("menu_resultados")
	var fallos := 0
	for resultado in resultados:
		if not resultado.bien:
			fallos += 1
	print("\n=== PRUEBA: %d de %d comprobaciones correctas ===" % [resultados.size() - fallos, resultados.size()])
	for resultado in resultados:
		print(("  ok    " if resultado.bien else "  FALLO ") + resultado.nombre + ("" if resultado.detalle == "" else "  (" + resultado.detalle + ")"))
	get_tree().quit(0 if fallos == 0 else 1)


func _probar(datos: Dictionary) -> void:
	var mesa = principal.abrir_prototipo(datos.id)
	await _esperar(1.2)
	var puzle: Puzle = mesa.puzle
	_registrar(datos.id + ": tiene sus pasos", puzle.pasos.size() >= 5, "%d pasos" % puzle.pasos.size())
	await _capturar(datos.id + "_inicio")
	await _esperar(3.0)
	var medida := await _medir_fps(1.5)
	_registrar(datos.id + ": FPS medidos (orientativo: esta máquina no tiene tarjeta gráfica)", true, "%.1f FPS" % medida)

	# Pistas: tres niveles del primer paso
	for i in 3:
		mesa.pedir_pista()
	_registrar(datos.id + ": tres pistas para el primer paso", mesa.pistas_total == 3)
	await _esperar(0.3)
	await _capturar(datos.id + "_pista")

	# Un arrastre de verdad, con eventos de toque, si el prototipo dice cuál
	if puzle.has_method("arrastre_de_prueba"):
		var prueba: Dictionary = puzle.arrastre_de_prueba()
		if prueba.get("pixeles", 120.0) <= 0.0:
			_tocar_en(mesa, prueba.get("punto", prueba.pieza.global_position))
		else:
			await _arrastrar(mesa, prueba.get("punto", prueba.pieza.global_position), prueba.direccion, prueba.get("pixeles", 120.0))
		await _esperar_hasta(prueba.comprobar, 4.0)
		_registrar(datos.id + ": arrastrar con el dedo mueve la pieza", bool(prueba.comprobar.call()))

	var capturas: Array = puzle.capturas_de_prueba() if puzle.has_method("capturas_de_prueba") else []
	for paso in puzle.pasos:
		var id: String = paso.id
		if not puzle.hecho(id):
			await puzle.resolver_paso(id)
			await _esperar_hasta(func() -> bool: return puzle.hecho(id), 6.0)
			await _esperar(0.4)
		_registrar("%s: paso «%s»" % [datos.id, id], puzle.hecho(id))
		if not puzle.hecho(id):
			break
		if id in capturas:
			await _capturar("%s_%s" % [datos.id, id])
	if puzle.has_method("comprobaciones"):
		for comprobacion in puzle.comprobaciones():
			_registrar(datos.id + ": " + comprobacion[0], comprobacion[1])
	_registrar(datos.id + ": el inventario dibujó sus iconos", _iconos_listos(mesa))
	await _esperar_hasta(func() -> bool: return mesa.hud.capa_final.visible and mesa.hud.capa_final.modulate.a > 0.95, 20.0)
	await _capturar(datos.id + "_final")
	_registrar(datos.id + ": resumen final con tiempo y pistas", mesa.hud.capa_final.visible)


func _iconos_listos(mesa) -> bool:
	for objeto in mesa.inventario:
		if objeto.icono == null:
			return false
	return true


# Arrastra con eventos de toque: desde un punto del mundo (visto en pantalla), en la dirección (del
# mundo) indicada, a lo largo de unos píxeles
func _arrastrar(mesa, punto: Vector3, direccion: Vector3, pixeles: float) -> void:
	var camara: Camera3D = mesa.camara.camara
	var desde := camara.unproject_position(punto)
	var hacia := camara.unproject_position(punto + direccion.normalized() * 0.03)
	var paso := (hacia - desde).normalized() * pixeles / 12.0
	var toque := InputEventScreenTouch.new()
	toque.index = 0
	toque.position = desde
	toque.pressed = true
	Input.parse_input_event(toque)
	await _esperar(0.05)
	var posicion := desde
	for i in 12:
		posicion += paso
		var arrastre := InputEventScreenDrag.new()
		arrastre.index = 0
		arrastre.position = posicion
		arrastre.relative = paso
		Input.parse_input_event(arrastre)
		await get_tree().process_frame
	var suelta := InputEventScreenTouch.new()
	suelta.index = 0
	suelta.position = posicion
	suelta.pressed = false
	Input.parse_input_event(suelta)


# Toque breve (pulsar y soltar en el mismo cuadro) sobre un punto del mundo
func _tocar_en(mesa, punto: Vector3) -> void:
	var posicion: Vector2 = mesa.camara.camara.unproject_position(punto)
	for pulsado in [true, false]:
		var toque := InputEventScreenTouch.new()
		toque.index = 0
		toque.position = posicion
		toque.pressed = pulsado
		Input.parse_input_event(toque)


func _medir_fps(segundos: float) -> float:
	var inicio := Time.get_ticks_usec()
	var cuadros := Engine.get_frames_drawn()
	await _esperar(segundos)
	return (Engine.get_frames_drawn() - cuadros) / ((Time.get_ticks_usec() - inicio) / 1000000.0)


func _registrar(nombre: String, bien: bool, detalle := "") -> void:
	resultados.append({"nombre": nombre, "bien": bien, "detalle": detalle})
	print(("[ok] " if bien else "[FALLO] ") + nombre + ("" if detalle == "" else " (" + detalle + ")"))


func _capturar(nombre: String) -> void:
	await RenderingServer.frame_post_draw
	var imagen := get_viewport().get_texture().get_image()
	imagen.save_png(carpeta.path_join(nombre + ".png"))


# Espera en tiempo real y al menos dos cuadros (sin tarjeta gráfica, un cuadro puede tardar
# segundos mientras se compilan los sombreadores, y un temporizador se adelantaría a las animaciones)
func _esperar(segundos: float) -> void:
	var fin := Time.get_ticks_msec() + int(segundos * 1000.0)
	var cuadros := 0
	while Time.get_ticks_msec() < fin or cuadros < 2:
		await get_tree().process_frame
		cuadros += 1


func _esperar_hasta(condicion: Callable, maximo: float) -> void:
	var fin := Time.get_ticks_msec() + int(maximo * 1000.0)
	await get_tree().process_frame
	while not bool(condicion.call()) and Time.get_ticks_msec() < fin:
		await get_tree().process_frame
	await get_tree().process_frame
