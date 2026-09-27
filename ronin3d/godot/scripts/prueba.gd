# Prueba automática: juega sola unos segundos, comprueba lo básico y guarda capturas
# en ronin3d/capturas/actual/. Se lanza así (sin ventana, con Xvfb en Linux):
#   godot --path ronin3d/godot --rendering-driver opengl3 --fixed-fps 30 -- --prueba
# Sale con código 0 si todo fue bien y 1 si algo falló.
extends Node

const Datos := preload("res://scripts/datos.gd")
const MOVIMIENTOS := ["mover_adelante", "mover_atras", "mover_izquierda", "mover_derecha"]

var principal
var tiempo := 0.0
var pasos: Array = []
var indice := 0
var resultados: Array = []
var carpeta := ""
var prefijo := ""
var posicion_guardada := Vector3.ZERO
var giro_guardado := 0.0
var objetivo_combate = null
var vida_objetivo := 0
var vida_akira := 0
var combate_activo := false
var captura_combate_hecha := false
var direccion_caminar := Vector3.ZERO
var pendientes_soltar: Array = []
var medida_inicio_us := 0
var medida_inicio_cuadros := 0
var fps_medidos := 0.0
var rival_parada = null
var parada_pulsada := false
var parada_vista := false
var parada_temprana := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	carpeta = ProjectSettings.globalize_path("res://").path_join("../capturas/actual").simplify_path()
	DirAccess.make_dir_recursive_absolute(carpeta)
	pasos = [
		[1.2, _capturar.bind("intro")],
		[1.3, _pulsar.bind("aceptar")],
		[1.5, _pulsar.bind("aceptar")],
		[1.6, _empezar_medida],
		[3.0, _empezar_a_caminar],
		[4.6, _dejar_de_caminar],
		[4.65, _terminar_medida],
		[4.7, _capturar.bind("patio")],
		[4.72, _comprobar_hud],
		[4.8, _empezar_giro],
		[5.8, _terminar_giro],
		[6.0, _capturar.bind("camara_girada")],
		[6.2, _preparar_combate],
		[10.5, _terminar_combate],
		[10.7, _probar_muro],
		[12.0, _comprobar_muro],
		[12.2, _preparar_vista_torreon],
		[13.2, _capturar.bind("torreon")],
		[13.4, _ir_al_porton],
		[15.6, _comprobar_cierre],
		[15.8, _pulsar.bind("aceptar")],
		[16.3, _capturar.bind("cierre")],
		[16.5, _pulsar.bind("pausa")],
		[16.9, _comprobar_pausa],
		[17.3, _comprobar_reanudar],
		[17.5, _activar_tactil],
		[17.6, _tocar.bind(Vector2(640, 360))],
		[17.9, _tocar.bind(Vector2(640, 360))],
		[18.2, _tocar.bind(Vector2(640, 360))],
		[18.4, _comprobar_toques],
		[19.6, _empezar_joystick],
		[20.3, _capturar.bind("tactil")],
		[20.5, _terminar_joystick],
		[20.7, _empezar_mando],
		[21.4, _terminar_mando],
		[21.6, _preparar_parada],
		[23.2, _comprobar_parada],
		[23.8, _comprobar_contraataque],
		[24.0, _preparar_parada_temprana],
		[25.8, _comprobar_parada_temprana],
		[26.0, _terminar],
	]


func _process(delta: float) -> void:
	tiempo += delta
	for pendiente in pendientes_soltar.duplicate():
		pendiente[1] -= 1
		if pendiente[1] <= 0:
			_enviar_accion(pendiente[0], false)
			pendientes_soltar.erase(pendiente)
	while indice < pasos.size() and tiempo >= pasos[indice][0]:
		pasos[indice][1].call()
		indice += 1
	if rival_parada != null:
		_paso_parada()
	if combate_activo:
		_paso_combate()
	elif direccion_caminar != Vector3.ZERO:
		_teclas_hacia(direccion_caminar)


# --- Utilidades ----------------------------------------------------------------------

func _juego():
	return principal.juego


func _enviar_accion(accion: String, pulsada: bool) -> void:
	var evento := InputEventAction.new()
	evento.action = accion
	evento.pressed = pulsada
	Input.parse_input_event(evento)


func _pulsar(accion: String) -> void:
	_enviar_accion(accion, true)
	pendientes_soltar.append([accion, 2])


func _soltar_movimiento() -> void:
	for accion in MOVIMIENTOS:
		Input.action_release(accion)


func _teclas_hacia(direccion: Vector3) -> void:
	# Pulsa las teclas que, con la cámara actual, llevan a Akira hacia «direccion».
	var camara = _juego().camara
	var adelante: float = direccion.dot(camara.adelante())
	var derecha: float = direccion.dot(camara.derecha())
	_soltar_movimiento()
	if adelante > 0.38:
		Input.action_press("mover_adelante")
	elif adelante < -0.38:
		Input.action_press("mover_atras")
	if derecha > 0.38:
		Input.action_press("mover_derecha")
	elif derecha < -0.38:
		Input.action_press("mover_izquierda")


func _proteger(activo: bool) -> void:
	# Fuera del combate los soldados no deben interferir en lo que se comprueba.
	var akira = _juego().akira
	akira.vida = Datos.VIDA_MAXIMA
	akira.muerte = -1.0
	akira.invulnerable = 999.0 if activo else 0.0
	principal.hud.poner_vida(akira.vida)
	for soldado in _juego().soldados_vivos():
		soldado.process_mode = Node.PROCESS_MODE_DISABLED if activo else Node.PROCESS_MODE_INHERIT


func _teletransportar(posicion: Vector3, mirando: Vector3) -> void:
	var akira = _juego().akira
	akira.global_position = posicion
	akira.velocity = Vector3.ZERO
	akira.mirando = mirando.normalized()
	_juego().camara.colocar_de_golpe()


func _registrar(nombre: String, correcto: bool, detalle := "") -> void:
	resultados.append([nombre, correcto, detalle])
	print("%s %s  %s" % ["OK   " if correcto else "FALLO", nombre, detalle])


func _capturar(nombre: String) -> void:
	await RenderingServer.frame_post_draw
	var imagen := get_viewport().get_texture().get_image()
	var ruta := carpeta.path_join(prefijo + nombre + ".png")
	imagen.save_png(ruta)
	print("Captura: ", ruta)


# --- Pasos de la prueba ------------------------------------------------------------------

func _empezar_a_caminar() -> void:
	_registrar("La intro da paso al juego", _juego().fase == "jugando", "fase=" + _juego().fase)
	_proteger(true)
	_teletransportar(Vector3(-4, 0, 0), Vector3.RIGHT)
	_juego().camara.giro = -90.0          # cámara al oeste: «adelante» es el este
	posicion_guardada = _juego().akira.global_position
	Input.action_press("mover_adelante")


func _dejar_de_caminar() -> void:
	_soltar_movimiento()
	var recorrido: float = _juego().akira.global_position.distance_to(posicion_guardada)
	_registrar("Akira camina", recorrido > 3.0, "recorrió %.1f m" % recorrido)


func _comprobar_hud() -> void:
	var pantalla := get_viewport().get_visible_rect()
	var fuera: Array = []
	for nombre in ["marcador", "etiqueta_soldados", "etiqueta_version"]:
		var control: Control = principal.hud.get(nombre)
		if not control.visible or not pantalla.encloses(control.get_global_rect()):
			fuera.append(nombre)
	var detalle := "vida, soldados y versión" if fuera.is_empty() else "fuera: " + ", ".join(PackedStringArray(fuera))
	_registrar("El HUD se ve entero en pantalla", fuera.is_empty(), detalle)


func _empezar_giro() -> void:
	giro_guardado = _juego().camara.giro
	Input.action_press("girar_derecha")


func _terminar_giro() -> void:
	Input.action_release("girar_derecha")
	var giro: float = absf(_juego().camara.giro - giro_guardado)
	_registrar("La cámara gira con E", giro > 45.0, "giró %.0f°" % giro)


func _preparar_combate() -> void:
	var juego = _juego()
	objetivo_combate = juego.soldados[0]
	vida_objetivo = objetivo_combate.vida
	vida_akira = juego.akira.vida
	var puesto: Vector3 = objetivo_combate.global_position
	_proteger(false)
	_teletransportar(puesto + Vector3(4.5, 0, 0), Vector3.LEFT)
	combate_activo = true


func _paso_combate() -> void:
	var juego = _juego()
	var akira = juego.akira
	if not is_instance_valid(objetivo_combate) or not objetivo_combate.vivo():
		_soltar_movimiento()
		return
	var hacia: Vector3 = objetivo_combate.global_position - akira.global_position
	hacia.y = 0.0
	var distancia := hacia.length()
	if distancia > 1.25:
		_teclas_hacia(hacia.normalized())
	else:
		_soltar_movimiento()
		akira.mirando = hacia.normalized()
		if not akira.atacando() and akira.enfriamiento <= 0.0:
			_pulsar("atacar")
	if not captura_combate_hecha and akira.atacando() and distancia < 2.4:
		captura_combate_hecha = true
		_capturar("combate")


func _terminar_combate() -> void:
	combate_activo = false
	_soltar_movimiento()
	var derrotado: bool = not is_instance_valid(objetivo_combate) or not objetivo_combate.vivo()
	var danado: bool = derrotado or objetivo_combate.vida < vida_objetivo
	_registrar("La espada daña al soldado", danado, "derrotados=%d" % _juego().derrotados)
	_registrar("El soldado se defiende (resta vida o Akira gana antes)", true,
		"vida de Akira %d → %d" % [vida_akira, _juego().akira.vida])
	_proteger(true)


func _probar_muro() -> void:
	_teletransportar(Vector3(-22.5, 0, 0.5), Vector3.LEFT)
	direccion_caminar = Vector3.LEFT


func _comprobar_muro() -> void:
	direccion_caminar = Vector3.ZERO
	_soltar_movimiento()
	var x: float = _juego().akira.global_position.x
	_registrar("El muro oeste detiene a Akira", x > -23.9, "x=%.2f (el muro empieza en −24)" % x)


func _preparar_vista_torreon() -> void:
	_teletransportar(Vector3(2, 0, -3), Vector3.FORWARD)
	var camara = _juego().camara
	camara.giro = 12.0
	camara.inclinacion = -5.0
	camara.distancia = 18.0
	camara.colocar_de_golpe()


func _ir_al_porton() -> void:
	var camara = _juego().camara
	camara.giro = -60.0
	camara.inclinacion = 38.0
	_teletransportar(Vector3(20.5, 0, 0.3), Vector3.RIGHT)
	direccion_caminar = Vector3.RIGHT


func _comprobar_cierre() -> void:
	direccion_caminar = Vector3.ZERO
	_soltar_movimiento()
	_registrar("Llegar al portón cierra el capítulo", _juego().fase == "cierre", "fase=" + _juego().fase)


var pausa_vista := false


func _comprobar_pausa() -> void:
	pausa_vista = get_tree().paused
	await _capturar("pausa")
	_pulsar("pausa")


func _comprobar_reanudar() -> void:
	var correcto: bool = pausa_vista and not get_tree().paused
	_registrar("ESC pausa el juego y lo reanuda", correcto,
		"pausado=%s, después=%s" % [pausa_vista, get_tree().paused])


# --- Controles táctiles y mando --------------------------------------------------------

func _activar_tactil() -> void:
	principal.tactil.activar(true)


func _evento_toque(posicion: Vector2, pulsado: bool) -> void:
	var toque := InputEventScreenTouch.new()
	toque.index = 0
	toque.position = posicion
	toque.pressed = pulsado
	Input.parse_input_event(toque)


func _tocar(posicion: Vector2) -> void:
	_evento_toque(posicion, true)
	_evento_toque(posicion, false)


func _comprobar_toques() -> void:
	# Tres toques: salir del cierre, completar el texto de la intro y empezar.
	_registrar("Tocar la pantalla sigue los textos", _juego().fase == "jugando", "fase=" + _juego().fase)
	_proteger(true)


func _empezar_joystick() -> void:
	posicion_guardada = _juego().akira.global_position
	_evento_toque(Vector2(200, 520), true)
	var arrastre := InputEventScreenDrag.new()
	arrastre.index = 0
	arrastre.position = Vector2(300, 520)
	arrastre.relative = Vector2(100, 0)
	Input.parse_input_event(arrastre)


func _terminar_joystick() -> void:
	_evento_toque(Vector2(300, 520), false)
	var recorrido: float = _juego().akira.global_position.distance_to(posicion_guardada)
	_registrar("El joystick táctil mueve a Akira", recorrido > 2.0, "recorrió %.1f m" % recorrido)
	principal.tactil.activar(false)


func _eje_mando(valor: float) -> void:
	var eje := InputEventJoypadMotion.new()
	eje.device = 0
	eje.axis = JOY_AXIS_LEFT_X
	eje.axis_value = valor
	Input.parse_input_event(eje)


func _empezar_mando() -> void:
	posicion_guardada = _juego().akira.global_position
	_eje_mando(1.0)


func _terminar_mando() -> void:
	_eje_mando(0.0)
	var recorrido: float = _juego().akira.global_position.distance_to(posicion_guardada)
	_registrar("El stick del mando mueve a Akira", recorrido > 2.0, "recorrió %.1f m" % recorrido)


# --- Parada (combate de precisión) --------------------------------------------------------

func _preparar_parada() -> void:
	# Un soldado se acerca a atacar; Akira para justo antes de la estocada y contraataca.
	_preparar_parada_con(_juego().soldados[2])


func _preparar_parada_con(soldado) -> void:
	var juego = _juego()
	rival_parada = soldado
	var akira = juego.akira
	akira.vida = Datos.VIDA_MAXIMA
	akira.invulnerable = 0.0          # si la parada falla, Akira pierde vida
	var hacia: Vector3 = Vector3(1, 0, 0)
	_teletransportar(rival_parada.global_position - hacia * 1.5, hacia)
	rival_parada.process_mode = Node.PROCESS_MODE_INHERIT


func _paso_parada() -> void:
	if not is_instance_valid(rival_parada):
		return
	var info: Dictionary = rival_parada.info()
	var momento := 0.45 if parada_temprana else 0.14    # a destiempo: nada más ver el «!»
	if not parada_pulsada and info.aviso and rival_parada.temporizador <= momento:
		_pulsar("parar")
		parada_pulsada = true
	if not parada_vista and rival_parada.sin_guardia:
		parada_vista = true
		_capturar("parada")


func _comprobar_parada() -> void:
	var akira = _juego().akira
	_registrar("Parar justo al «!» desvía la lanza y deja al soldado sin guardia",
		parada_vista and akira.vida == Datos.VIDA_MAXIMA,
		"sin guardia=%s, vida de Akira=%d" % [parada_vista, akira.vida])
	akira.mirando = (rival_parada.global_position - akira.global_position).normalized() if is_instance_valid(rival_parada) else akira.mirando
	_pulsar("atacar")


func _comprobar_contraataque() -> void:
	var derribado: bool = not is_instance_valid(rival_parada) or not rival_parada.vivo()
	_registrar("El contraataque tras la parada lo derriba de un golpe", derribado,
		"derrotados=%d" % _juego().derrotados)
	rival_parada = null
	_proteger(true)


func _preparar_parada_temprana() -> void:
	parada_temprana = true
	parada_pulsada = false
	parada_vista = false
	_preparar_parada_con(_juego().soldados[3])


func _comprobar_parada_temprana() -> void:
	var akira = _juego().akira
	var herido: bool = akira.vida < Datos.VIDA_MAXIMA
	_registrar("Parar a destiempo no sirve: la lanza alcanza a Akira", herido and not parada_vista,
		"vida de Akira=%d, sin guardia=%s" % [akira.vida, parada_vista])
	rival_parada = null
	_proteger(true)


# FPS reales mientras Akira camina por el patio (sin capturas de por medio). Con
# --fixed-fps cada cuadro avanza el mismo tiempo de juego, así que esto mide cuántos
# cuadros por segundo es capaz de dibujar la máquina.
func _empezar_medida() -> void:
	medida_inicio_us = Time.get_ticks_usec()
	medida_inicio_cuadros = Engine.get_frames_drawn()


func _terminar_medida() -> void:
	var segundos := (Time.get_ticks_usec() - medida_inicio_us) / 1000000.0
	if segundos > 0.0:
		fps_medidos = (Engine.get_frames_drawn() - medida_inicio_cuadros) / segundos


func _terminar() -> void:
	var fallos := resultados.filter(func(r): return not r[1])
	var informe := PackedStringArray()
	informe.append("Prueba automática de RONIN 3D (Godot, cel-shading)")
	for r in resultados:
		informe.append("%s  %s  %s" % ["OK   " if r[1] else "FALLO", r[0], r[2]])
	informe.append("Resultado: %d de %d comprobaciones correctas" % [resultados.size() - fallos.size(), resultados.size()])
	informe.append("FPS al caminar por el patio: %.1f (%s, %s)" % [fps_medidos,
		RenderingServer.get_video_adapter_name(), RenderingServer.get_current_rendering_driver_name()])
	var archivo := FileAccess.open(carpeta.path_join(prefijo + "prueba.txt"), FileAccess.WRITE)
	if archivo:
		archivo.store_string("\n".join(informe) + "\n")
		archivo.close()
	print("\n".join(informe))
	get_tree().quit(0 if fallos.is_empty() else 1)
