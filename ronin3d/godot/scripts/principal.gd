# Punto de entrada: registra los controles (teclado, ratón, mando y pantalla táctil), crea
# el HUD y lleva el flujo intro → juego → cierre (o derrota → reintentar), con pausa.
#
# Opciones (después de «--» en la línea de órdenes):
#   --prueba   juega sola, comprueba lo básico y guarda capturas
#   --tactil   muestra los controles táctiles en el PC (el ratón hace de dedo)
#   --galeria  abre la galería de criaturas del bestiario (con --capturas guarda imágenes y sale)
extends Node

const Datos := preload("res://scripts/datos.gd")
const Juego := preload("res://scripts/juego.gd")
const Hud := preload("res://scripts/hud.gd")
const Prueba := preload("res://scripts/prueba.gd")
const ControlesTactiles := preload("res://scripts/controles_tactiles.gd")
const VisualModelo := preload("res://scripts/visual_modelo.gd")
const Galeria := preload("res://scripts/galeria.gd")
const VERSION := "RONIN · prototipo 0.4"

var hud
var juego
var tactil
var galeria_abierta: Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Android: «atrás» pausa en vez de cerrar el juego (ver _notification).
	get_tree().quit_on_go_back = false
	var argumentos := OS.get_cmdline_user_args()
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
		"estilo_animacion": [KEY_T],
		"galeria": [KEY_G],
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
		"saltar": JOY_BUTTON_A, "aceptar": JOY_BUTTON_A, "atacar": JOY_BUTTON_X,
		"parar": JOY_BUTTON_LEFT_SHOULDER, "especial": JOY_BUTTON_Y,
		"estilo_animacion": JOY_BUTTON_BACK,
		"correr": JOY_BUTTON_RIGHT_SHOULDER, "pausa": JOY_BUTTON_START,
		"acercar": JOY_BUTTON_DPAD_UP, "alejar": JOY_BUTTON_DPAD_DOWN,
	}
	for accion in botones:
		var boton := InputEventJoypadButton.new()
		boton.button_index = botones[accion]
		InputMap.action_add_event(accion, boton)


func _iniciar_juego(con_intro: bool) -> void:
	if juego:
		juego.queue_free()
	juego = Juego.new()
	add_child(juego)
	move_child(juego, 0)          # el HUD queda por encima en el árbol
	juego.fase_cambiada.connect(_al_cambiar_fase)
	juego.vida_cambiada.connect(hud.poner_vida)
	juego.derrotados_cambiados.connect(hud.poner_derrotados)
	juego.espiritu_cambiado.connect(hud.poner_espiritu)
	juego.mensaje.connect(hud.mostrar_mensaje)
	hud.poner_espiritu(0.0)
	juego.iniciar(con_intro)
	hud.poner_vida(Datos.VIDA_MAXIMA)
	hud.poner_derrotados(0, Datos.PATRULLAS.size())
	_al_cambiar_fase(juego.fase)


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
	hud.poner_pausa(pausado, tactil.activo)


# En el móvil, el botón o gesto «atrás» pausa (y en pausa, cierra), y el juego se pausa
# solo si pasa a segundo plano (una llamada, cambiar de aplicación).
func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		if get_tree().paused:
			get_tree().quit()
		else:
			alternar_pausa()
	elif que == NOTIFICATION_APPLICATION_PAUSED:
		if juego and juego.fase == "jugando" and not get_tree().paused:
			alternar_pausa()


# Animación limitada estilo anime (poses a 12 por segundo) o suave, para comparar.
func alternar_estilo_animacion() -> void:
	VisualModelo.estilo_anime = not VisualModelo.estilo_anime
	hud.poner_estilo_animacion()
	hud.mostrar_mensaje("Animación anime: 12 poses por segundo" if VisualModelo.estilo_anime
		else "Animación suave")


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
			get_tree().quit()
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
