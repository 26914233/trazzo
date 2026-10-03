# Prueba automática: recorre el gabinete (portada, juegos, cajas) y abre cada caja jugable con su
# entrada por la habitación. Comprueba el doble toque (acercar y volver), que una pieza bloqueada no
# se mueve, que se puede examinar un objeto en 3D, las pistas, un arrastre de verdad con eventos de
# toque, y la resuelve paso a paso con las mismas piezas que usa el jugador. Guarda capturas en
# puzles/capturas/.
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
	await _probar_gabinete()
	for datos in Catalogo.cajas_jugables():
		if solo != "" and datos.id != solo:
			continue
		await _probar(datos)
	var gabinete = principal.abrir_gabinete("cajas", "caja_viva")
	await _esperar(2.0)
	await _capturar("gabinete_resultados")
	var fallos := 0
	for resultado in resultados:
		if not resultado.bien:
			fallos += 1
	print("\n=== PRUEBA: %d de %d comprobaciones correctas ===" % [resultados.size() - fallos, resultados.size()])
	for resultado in resultados:
		print(("  ok    " if resultado.bien else "  FALLO ") + resultado.nombre + ("" if resultado.detalle == "" else "  (" + resultado.detalle + ")"))
	get_tree().quit(0 if fallos == 0 else 1)


# --- Gabinete -----------------------------------------------------------------------------------

func _probar_gabinete() -> void:
	var gabinete = principal.abrir_gabinete("portada")
	await _esperar(2.5)
	_registrar("gabinete: los cuatro juegos en sus pedestales", gabinete.vitrinas.size() == Catalogo.JUEGOS.size())
	await _capturar("gabinete_portada")
	var medida := await _medir_fps(1.5)
	_registrar("gabinete: FPS medidos (orientativo: esta máquina no tiene tarjeta gráfica)", true, "%.1f FPS" % medida)
	# un toque en la portada lleva a los juegos
	_tocar_pantalla(get_viewport().get_visible_rect().size * Vector2(0.5, 0.6))
	await _esperar(2.0)
	_registrar("gabinete: un toque en la portada lleva a los juegos", gabinete.pantalla == "juegos")
	await _capturar("gabinete_juegos")
	# deslizar cambia de juego
	var antes: int = gabinete.indice
	await _deslizar_pantalla(Vector2(0.75, 0.5), Vector2(0.35, 0.5))
	await _esperar(1.8)
	_registrar("gabinete: deslizar pasa al juego siguiente", gabinete.indice == posmod(antes + 1, gabinete.vitrinas.size()))
	await _capturar("gabinete_juegos_2")
	gabinete.ir_a_cajas(0)
	await _esperar(1.8)
	var botones: Dictionary = gabinete.botones_cajas
	_registrar("gabinete: la lista de cajas del juego", gabinete.pantalla == "cajas" and botones.size() == 3,
		"%d cajas" % botones.size())
	_registrar("gabinete: la primera caja se puede jugar y las otras están selladas",
		botones.has("caja_viva") and not botones["caja_viva"].disabled and botones.has("caja_viva_2") and botones["caja_viva_2"].disabled)
	await _capturar("gabinete_cajas")
	# elegir la caja lleva a su mesa (con el fundido) y «salir» vuelve a la lista de cajas
	botones["caja_viva"].pressed.emit()
	await _esperar_hasta(func() -> bool: return principal.actual.has_method("pedir_pista"), 6.0)
	_registrar("gabinete: elegir una caja abre su mesa", principal.actual.has_method("pedir_pista"))
	await _esperar(1.0)
	principal.actual.salir.emit()
	await _esperar_hasta(func() -> bool: return principal.actual.has_method("ir_a_cajas"), 6.0)
	await _esperar(0.6)
	_registrar("gabinete: al salir de una caja se vuelve a las cajas de su juego",
		principal.actual.has_method("ir_a_cajas") and principal.actual.pantalla == "cajas" and principal.actual.indice == 0)


# --- Cada caja ------------------------------------------------------------------------------------

func _probar(datos: Dictionary) -> void:
	var mesa = principal.abrir_caja(datos.id)
	var puzle: Puzle = mesa.puzle
	await _esperar(1.6)
	_registrar(datos.id + ": la entrada empieza en la puerta, sin tocar la caja", mesa.bloqueado and mesa.camara.en_entrada)
	await _capturar(datos.id + "_entrada")
	await _esperar_hasta(func() -> bool: return not mesa.bloqueado, 15.0)
	_registrar(datos.id + ": la entrada termina en la vista de la caja", not mesa.bloqueado and mesa.camara.quieta())
	await _esperar(0.8)
	await _capturar(datos.id + "_inicio")
	_registrar(datos.id + ": tiene sus pasos", puzle.pasos.size() >= 5, "%d pasos" % puzle.pasos.size())
	var medida := await _medir_fps(1.5)
	_registrar(datos.id + ": FPS medidos (orientativo: esta máquina no tiene tarjeta gráfica)", true, "%.1f FPS" % medida)

	# El primer aviso se ajusta a su texto (en la 0.2 salía un marco de miles de píxeles)
	await _esperar_hasta(func() -> bool: return mesa.hud.aviso.modulate.a > 0.9, 6.0)
	var alto_aviso: float = mesa.hud.aviso.size.y
	_registrar(datos.id + ": el primer aviso se ajusta a su texto", mesa.hud.aviso.modulate.a > 0.9
		and alto_aviso < get_viewport().get_visible_rect().size.y * 0.35, "%d px de alto" % int(alto_aviso))
	await _capturar(datos.id + "_primer_aviso")

	# Bloqueo: la pieza no se mueve, suena y lo cuenta
	if puzle.has_method("bloqueo_de_prueba"):
		# se mira respecto a su padre: la caja viva respira y la reliquia flota
		var pieza: Pieza = puzle.bloqueo_de_prueba()
		var antes: Transform3D = pieza.transform
		var bloqueos_antes: int = mesa.bloqueos
		pieza.tocar()
		var se_movio := false
		var fin := Time.get_ticks_msec() + 600
		while Time.get_ticks_msec() < fin:
			await get_tree().process_frame
			if not pieza.transform.is_equal_approx(antes):
				se_movio = true
		_registrar(datos.id + ": una pieza bloqueada no se mueve, pero avisa", not se_movio and mesa.bloqueos > bloqueos_antes
			and "trabado" in mesa.sonido.sonados)

	# Doble toque: acerca la cámara y, sobre el vacío, la devuelve
	await _probar_doble_toque(datos, mesa)

	# Pistas: tres niveles del primer paso
	for i in 3:
		mesa.pedir_pista()
	_registrar(datos.id + ": tres pistas para el primer paso", mesa.pistas_total == 3)
	await _esperar(0.3)
	await _capturar(datos.id + "_pista")

	# Un arrastre de verdad, con eventos de toque, si el prototipo dice cuál (desde la vista de partida)
	mesa.camara.centrar()
	await _esperar_hasta(func() -> bool: return mesa.camara.quieta(), 4.0)
	if puzle.has_method("arrastre_de_prueba"):
		var prueba: Dictionary = puzle.arrastre_de_prueba()
		if prueba.get("pixeles", 120.0) <= 0.0:
			_tocar_en(mesa, prueba.get("punto", prueba.pieza.global_position))
		else:
			await _arrastrar(mesa, prueba.get("punto", prueba.pieza.global_position), prueba.direccion, prueba.get("pixeles", 120.0))
		await _esperar_hasta(prueba.comprobar, 4.0)
		_registrar(datos.id + ": arrastrar con el dedo mueve la pieza", bool(prueba.comprobar.call()))

	var capturas: Array = puzle.capturas_de_prueba() if puzle.has_method("capturas_de_prueba") else []
	var examinado := false
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
		# el primer objeto que se guarda se examina en 3D
		if not examinado and not mesa.inventario.is_empty():
			examinado = true
			await _esperar_hasta(func() -> bool: return mesa.inventario[0].icono != null, 4.0)
			mesa.examinar(mesa.inventario[0].id)
			await _esperar(0.8)
			_registrar(datos.id + ": se puede examinar un objeto en 3D", mesa.hud.examinando())
			await _capturar(datos.id + "_examen")
			mesa.hud.cerrar_examen()
			await _esperar(0.3)
	if puzle.has_method("comprobaciones"):
		for comprobacion in puzle.comprobaciones():
			_registrar(datos.id + ": " + comprobacion[0], comprobacion[1])
	_registrar(datos.id + ": el inventario dibujó sus iconos", _iconos_listos(mesa))
	await _esperar_hasta(func() -> bool: return mesa.hud.capa_final.visible and mesa.hud.capa_final.modulate.a > 0.95, 20.0)
	await _capturar(datos.id + "_final")
	_registrar(datos.id + ": resumen final con tiempo y pistas", mesa.hud.capa_final.visible)


func _probar_doble_toque(datos: Dictionary, mesa) -> void:
	var camara: CamaraPuzle = mesa.camara
	var pantalla := get_viewport().get_visible_rect().size
	if camara.modo == CamaraPuzle.Modo.PUNTO:
		await _doble_toque(pantalla * Vector2(0.4, 0.55))
		await _esperar(1.0)
		var cerca := camara.de_cerca
		await _capturar(datos.id + "_doble_toque")
		await _doble_toque(pantalla * Vector2(0.4, 0.55))
		await _esperar(1.0)
		_registrar(datos.id + ": el doble toque acerca la vista y otro la aleja", cerca and not camara.de_cerca)
		return
	var antes: float = camara.distancia
	await _doble_toque(camara.camara.unproject_position(camara.objetivo))
	await _esperar_hasta(func() -> bool: return camara.quieta(), 3.0)
	await _esperar(0.3)
	var cerca: bool = camara.distancia < antes * 0.8
	await _capturar(datos.id + "_doble_toque")
	# doble toque en el vacío (donde no haya nada de la caja): vuelve a la vista general
	var vacio := pantalla * Vector2(0.5, 0.06)
	for candidato in [Vector2(0.5, 0.06), Vector2(0.3, 0.1), Vector2(0.75, 0.9), Vector2(0.25, 0.9), Vector2(0.9, 0.5), Vector2(0.15, 0.5)]:
		if mesa._impacto(pantalla * candidato) == null:
			vacio = pantalla * candidato
			break
	await _doble_toque(vacio)
	await _esperar_hasta(func() -> bool: return camara.quieta(), 3.0)
	await _esperar(0.3)
	_registrar(datos.id + ": el doble toque acerca la cámara y otro en el vacío la devuelve",
		cerca and camara.distancia > antes * 0.95 and mesa.dobles_toques >= 2, "%.2f → cerca → %.2f m" % [antes, camara.distancia])


func _iconos_listos(mesa) -> bool:
	for objeto in mesa.inventario:
		if objeto.icono == null:
			return false
	return true


# --- Toques simulados ---------------------------------------------------------------------------

func _toque_pantalla(posicion: Vector2, pulsado: bool) -> void:
	var toque := InputEventScreenTouch.new()
	toque.index = 0
	toque.position = posicion
	toque.pressed = pulsado
	Input.parse_input_event(toque)


func _tocar_pantalla(posicion: Vector2) -> void:
	_toque_pantalla(posicion, true)
	_toque_pantalla(posicion, false)


# Los dos toques van en el mismo cuadro: sin tarjeta gráfica un cuadro puede durar más que el margen
# del doble toque
func _doble_toque(posicion: Vector2) -> void:
	_tocar_pantalla(posicion)
	_tocar_pantalla(posicion)
	await get_tree().process_frame


func _deslizar_pantalla(desde: Vector2, hasta: Vector2) -> void:
	var pantalla := get_viewport().get_visible_rect().size
	var a := desde * pantalla
	var b := hasta * pantalla
	_toque_pantalla(a, true)
	await get_tree().process_frame
	for i in 8:
		var arrastre := InputEventScreenDrag.new()
		arrastre.index = 0
		arrastre.position = a.lerp(b, (i + 1) / 8.0)
		arrastre.relative = (b - a) / 8.0
		Input.parse_input_event(arrastre)
		await get_tree().process_frame
	_toque_pantalla(b, false)


# Arrastra con eventos de toque: desde un punto del mundo (visto en pantalla), en la dirección (del
# mundo) indicada, a lo largo de unos píxeles
func _arrastrar(mesa, punto: Vector3, direccion: Vector3, pixeles: float) -> void:
	var camara: Camera3D = mesa.camara.camara
	var desde := camara.unproject_position(punto)
	var hacia := camara.unproject_position(punto + direccion.normalized() * 0.03)
	var paso := (hacia - desde).normalized() * pixeles / 12.0
	_toque_pantalla(desde, true)
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
	_toque_pantalla(posicion, false)


# Toque breve (pulsar y soltar en el mismo cuadro) sobre un punto del mundo
func _tocar_en(mesa, punto: Vector3) -> void:
	_tocar_pantalla(mesa.camara.camara.unproject_position(punto))


# --- Utilidades -----------------------------------------------------------------------------------

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
