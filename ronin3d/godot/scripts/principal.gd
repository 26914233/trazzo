# Punto de entrada: registra los controles (teclado, ratón, mando y pantalla táctil), crea
# el HUD y lleva el flujo intro → juego → cierre (o derrota → reintentar), con pausa.
#
# Opciones (después de «--» en la línea de órdenes):
#   --prueba   juega sola, comprueba lo básico y guarda capturas
#   --tactil   muestra los controles táctiles en el PC (el ratón hace de dedo)
#   --modelos3d  los personajes con los modelos de piezas en vez de los sprites pixel art
#   --galeria  abre la galería de criaturas del bestiario (con --capturas guarda imágenes y sale)
extends Node

const Datos := preload("res://scripts/datos.gd")
const Juego := preload("res://scripts/juego.gd")
const Hud := preload("res://scripts/hud.gd")
const Armas := preload("res://scripts/armas.gd")
const Prueba := preload("res://scripts/prueba.gd")
const ControlesTactiles := preload("res://scripts/controles_tactiles.gd")
const VisualModelo := preload("res://scripts/visual_modelo.gd")
const VisualSprite := preload("res://scripts/visual_sprite.gd")
const Galeria := preload("res://scripts/galeria.gd")
const Apariencias := preload("res://scripts/apariencias_akira.gd")
const Partida := preload("res://scripts/partida.gd")
const VERSION := "RONIN · prototipo 0.9"

var hud
var juego
var tactil
var galeria_abierta: Node
var tiempo_guardado := 0.0            # la partida se guarda un poco después de cada cambio


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# La prueba automática juega una partida nueva y no toca la guardada.
	if "--prueba" in OS.get_cmdline_user_args():
		Partida.modo_prueba = true
		Partida.reiniciar()
	else:
		Partida.cargar()
	Apariencias.cargar()
	# Android: «atrás» pausa en vez de cerrar el juego (ver _notification).
	get_tree().quit_on_go_back = false
	var argumentos := OS.get_cmdline_user_args()
	VisualSprite.activo = not "--modelos3d" in argumentos
	if "--galeria" in argumentos:
		var galeria = Galeria.new()
		add_child(galeria)
		galeria.iniciar("--capturas" in argumentos)
		return
	var con_tactil := DisplayServer.is_touchscreen_available() or "--tactil" in argumentos
	# En pantallas táctiles el clic izquierdo no ataca: cada toque lo simularía.
	_registrar_acciones(not con_tactil)
	hud = Hud.new()
	add_child(hud)
	hud.poner_version(VERSION)
	tactil = ControlesTactiles.new()
	tactil.principal = self
	add_child(tactil)
	if "--tactil" in argumentos:
		Input.emulate_touch_from_mouse = true
		tactil.activar(true)
	_iniciar_juego(true)
	if "--prueba" in argumentos:
		var prueba = Prueba.new()
		prueba.principal = self
		add_child(prueba)


func _registrar_acciones(clic_ataca: bool) -> void:
	var teclas := {
		"mover_adelante": [KEY_W, KEY_UP],
		"mover_atras": [KEY_S, KEY_DOWN],
		"mover_izquierda": [KEY_A, KEY_LEFT],
		"mover_derecha": [KEY_D, KEY_RIGHT],
		"correr": [KEY_SHIFT],
		"saltar": [KEY_SPACE],
		"atacar": [KEY_J],
		"parar": [KEY_K],
		"especial": [KEY_L],
		"esquivar": [KEY_C],
		"cambiar_arma": [KEY_I],
		"depurar_golpes": [KEY_F3],
		"estilo_animacion": [KEY_T],
		"galeria": [KEY_G],
		"apariencia": [KEY_V],
		"comprar": [KEY_B],
		"interactuar": [KEY_ENTER, KEY_KP_ENTER],
		"girar_izquierda": [KEY_Q],
		"girar_derecha": [KEY_E],
		"acercar": [KEY_PLUS, KEY_KP_ADD, KEY_EQUAL],
		"alejar": [KEY_MINUS, KEY_KP_SUBTRACT],
		"inclinar_arriba": [KEY_R],
		"inclinar_abajo": [KEY_F],
		"aceptar": [KEY_ENTER, KEY_KP_ENTER],
		"pausa": [KEY_ESCAPE],
	}
	for accion in teclas:
		if InputMap.has_action(accion):
			InputMap.erase_action(accion)
		InputMap.add_action(accion)
		for tecla in teclas[accion]:
			var evento := InputEventKey.new()
			evento.keycode = tecla
			InputMap.action_add_event(accion, evento)
	if clic_ataca:
		var clic := InputEventMouseButton.new()
		clic.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event("atacar", clic)
	# Mando: stick izquierdo para moverse, derecho para la cámara (arriba mira hacia arriba)
	var ejes := {
		"mover_izquierda": [JOY_AXIS_LEFT_X, -1.0], "mover_derecha": [JOY_AXIS_LEFT_X, 1.0],
		"mover_adelante": [JOY_AXIS_LEFT_Y, -1.0], "mover_atras": [JOY_AXIS_LEFT_Y, 1.0],
		"girar_izquierda": [JOY_AXIS_RIGHT_X, -1.0], "girar_derecha": [JOY_AXIS_RIGHT_X, 1.0],
		"inclinar_abajo": [JOY_AXIS_RIGHT_Y, -1.0], "inclinar_arriba": [JOY_AXIS_RIGHT_Y, 1.0],
	}
	for accion in ejes:
		var eje := InputEventJoypadMotion.new()
		eje.axis = ejes[accion][0]
		eje.axis_value = ejes[accion][1]
		InputMap.action_add_event(accion, eje)
		InputMap.action_set_deadzone(accion, 0.2)
	var botones := {
		"saltar": JOY_BUTTON_A, "aceptar": JOY_BUTTON_A, "atacar": JOY_BUTTON_X, "interactuar": JOY_BUTTON_B,
		"parar": JOY_BUTTON_LEFT_SHOULDER, "especial": JOY_BUTTON_Y,
		"estilo_animacion": JOY_BUTTON_BACK,
		"correr": JOY_BUTTON_RIGHT_SHOULDER, "pausa": JOY_BUTTON_START,
		"acercar": JOY_BUTTON_DPAD_UP, "alejar": JOY_BUTTON_DPAD_DOWN,
		"esquivar": JOY_BUTTON_B, "cambiar_arma": JOY_BUTTON_DPAD_RIGHT,
	}
	for accion in botones:
		var boton := InputEventJoypadButton.new()
		boton.button_index = botones[accion]
		InputMap.action_add_event(accion, boton)


func _iniciar_juego(con_intro: bool) -> void:
	if juego:
		juego.queue_free()
	juego = Juego.new()
	# «principal» se procesa siempre (para atender la pausa); el juego, no: sin esto, los
	# soldados seguían moviéndose con el juego en pausa (arreglado en la 0.6).
	juego.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(juego)
	move_child(juego, 0)          # el HUD queda por encima en el árbol
	juego.fase_cambiada.connect(_al_cambiar_fase)
	juego.vida_cambiada.connect(hud.poner_vida)
	juego.derrotados_cambiados.connect(hud.poner_derrotados)
	juego.espiritu_cambiado.connect(hud.poner_espiritu)
	juego.aguante_cambiado.connect(hud.poner_aguante)
	juego.arma_cambiada.connect(func(arma):
		hud.poner_arma(Armas.datos(arma).nombre)
		hud.mostrar_mensaje("Arma: %s" % Armas.datos(arma).nombre, 1.2))
	juego.mensaje.connect(hud.mostrar_mensaje)
	juego.monedas_cambiadas.connect(_al_cambiar_monedas)
	juego.vida_maxima_cambiada.connect(hud.poner_vida_maxima)
	juego.aviso_interaccion.connect(hud.poner_aviso_interaccion)
	hud.poner_espiritu(0.0)
	hud.poner_aviso_interaccion("")
	juego.iniciar(con_intro)
	hud.poner_aguante(juego.akira.aguante)
	hud.poner_arma(Armas.datos(juego.akira.arma).nombre)
	hud.poner_monedas(Partida.monedas, false)
	hud.poner_vida_maxima(juego.akira.vida_maxima)
	hud.poner_vida(juego.akira.vida)
	hud.poner_derrotados(0, Datos.PATRULLAS.size())
	_al_cambiar_fase(juego.fase)


func _al_cambiar_monedas(total: int) -> void:
	hud.poner_monedas(total)


func _process(delta: float) -> void:
	if Partida.pendiente:
		tiempo_guardado += delta
		if tiempo_guardado > 2.0:
			tiempo_guardado = 0.0
			Partida.guardar()


func salir() -> void:
	Partida.guardar()
	get_tree().quit()


func _al_cambiar_fase(fase: String) -> void:
	match fase:
		"intro":
			hud.mostrar_texto(Datos.TITULO, Datos.SUBTITULO, Datos.TEXTO_INTRO, _pie("empezar"))
		"jugando":
			hud.ocultar_texto()
			hud.mostrar_ayuda(tactil.activo)
		"cierre":
			hud.mostrar_texto(Datos.TITULO_CIERRE, "El castillo de Hoshiyama", Datos.TEXTO_CIERRE,
				_pie("volver a empezar"))
		"derrota":
			hud.mostrar_texto(Datos.TITULO_DERROTA, "", Datos.TEXTO_DERROTA, _pie("intentarlo de nuevo"))


func _pie(para: String) -> String:
	return ("Toca la pantalla para " if tactil.activo else "Pulsa ENTER para ") + para


func alternar_pausa() -> void:
	var pausado := not get_tree().paused
	get_tree().paused = pausado
	# Al salir del sastre, Akira vuelve a llevar lo que tiene puesto (lo que no se compró no se queda).
	if not pausado and Apariencias.mostrada != Apariencias.elegida:
		Apariencias.cerrar_sastre()
		if juego:
			juego.cambiar_apariencia_akira(Apariencias.elegida)
	hud.poner_pausa(pausado, tactil.activo)


# En el móvil, el botón o gesto «atrás» pausa (y en pausa, cierra), y el juego se pausa
# solo si pasa a segundo plano (una llamada, cambiar de aplicación).
func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		if get_tree().paused:
			salir()
		else:
			alternar_pausa()
	elif que == NOTIFICATION_APPLICATION_PAUSED:
		Partida.guardar()
		if juego and juego.fase == "jugando" and not get_tree().paused:
			alternar_pausa()
	elif que == NOTIFICATION_WM_CLOSE_REQUEST:
		Partida.guardar()


# Animación limitada estilo anime (poses a 12 por segundo) o suave, para comparar.
func alternar_estilo_animacion() -> void:
	VisualModelo.estilo_anime = not VisualModelo.estilo_anime
	hud.poner_estilo_animacion()
	hud.mostrar_mensaje("Animación anime: 12 poses por segundo" if VisualModelo.estilo_anime
		else "Animación suave")


# El sastre (en la pausa mientras no hay aldea): enseña el siguiente aspecto de Akira. Si ya es
# suyo se lo pone; si no, enseña el precio y se puede comprar (B o el botón).
func cambiar_apariencia() -> void:
	Apariencias.siguiente()
	if juego:
		juego.cambiar_apariencia_akira(Apariencias.mostrada)
	hud.poner_apariencia()


func comprar_apariencia() -> void:
	if Apariencias.mostrada_bloqueada() and Apariencias.comprar_mostrada():
		if juego:
			juego.monedas = Partida.monedas
		hud.poner_monedas(Partida.monedas, false)
	hud.poner_apariencia()


# Galería de criaturas del bestiario (prueba de rendimiento): sustituye al juego mientras está
# abierta y, al volver, deja el juego en pausa tal como estaba.
func abrir_galeria() -> void:
	if galeria_abierta != null or juego == null:
		return
	var era_tactil: bool = tactil.activo
	get_tree().paused = false
	hud.poner_pausa(false, era_tactil)
	hud.visible = false
	tactil.activar(false)
	remove_child(juego)
	galeria_abierta = Galeria.new()
	add_child(galeria_abierta)
	galeria_abierta.salio.connect(cerrar_galeria.bind(era_tactil))
	galeria_abierta.iniciar(false)


func cerrar_galeria(era_tactil := false) -> void:
	if galeria_abierta == null:
		return
	galeria_abierta.queue_free()
	galeria_abierta = null
	add_child(juego)
	move_child(juego, 0)
	hud.visible = true
	tactil.activar(era_tactil)
	alternar_pausa()


func _input(evento: InputEvent) -> void:
	if galeria_abierta != null:
		return
	if get_tree().paused and evento.is_action_pressed("galeria"):
		abrir_galeria()
		get_viewport().set_input_as_handled()
		return
	if get_tree().paused and evento.is_action_pressed("apariencia"):
		cambiar_apariencia()
		get_viewport().set_input_as_handled()
		return
	if get_tree().paused and evento.is_action_pressed("comprar"):
		comprar_apariencia()
		get_viewport().set_input_as_handled()
		return
	if evento.is_action_pressed("estilo_animacion"):
		alternar_estilo_animacion()
		get_viewport().set_input_as_handled()
		return
	if evento.is_action_pressed("pausa"):
		alternar_pausa()
		get_viewport().set_input_as_handled()
		return
	if get_tree().paused:
		if evento.is_action_pressed("aceptar"):
			alternar_pausa()
		elif evento is InputEventKey and evento.pressed and evento.keycode == KEY_Q:
			salir()
		get_viewport().set_input_as_handled()
		return
	if juego.fase == "jugando" and evento.is_action_pressed("interactuar"):
		juego.interactuar()
		get_viewport().set_input_as_handled()
		return
	if evento.is_action_pressed("aceptar"):
		aceptar()


func aceptar() -> void:
	if juego.fase == "jugando":
		return
	if not hud.texto_completo():
		hud.completar_texto()
		return
	match juego.fase:
		"intro":
			juego.comenzar()
		"cierre":
			_iniciar_juego(true)
		"derrota":
			_iniciar_juego(false)
