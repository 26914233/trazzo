# Punto de entrada. Prepara la vista 3D con la estética elegida, el HUD y el flujo
# intro → juego → cierre. Teclas 1/2/3: cambiar de estética sin perder la posición.
#
# Opciones (después de «--» en la línea de órdenes):
#   --estilo=hd2d | pixel | cel   estética inicial (por defecto hd2d)
#   --prueba                      juega sola, comprueba lo básico y guarda capturas
extends Node

const Datos := preload("res://scripts/datos.gd")
const Estilos := preload("res://scripts/estilos.gd")
const Juego := preload("res://scripts/juego.gd")
const Hud := preload("res://scripts/hud.gd")
const Prueba := preload("res://scripts/prueba.gd")
const SHADER_MAQUETA := preload("res://shaders/maqueta.gdshader")

var estilo := "hd2d"
var contenedor: SubViewportContainer
var vista: SubViewport
var capa_efectos: CanvasLayer
var hud
var juego


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_registrar_acciones()
	var argumentos := OS.get_cmdline_user_args()
	for argumento in argumentos:
		if argumento.begins_with("--estilo="):
			estilo = argumento.get_slice("=", 1)
	if not estilo in Estilos.ORDEN:
		estilo = "hd2d"
	hud = Hud.new()
	add_child(hud)
	_preparar_vista()
	_iniciar_juego(true)
	if "--prueba" in argumentos:
		var prueba = Prueba.new()
		prueba.principal = self
		add_child(prueba)


func _registrar_acciones() -> void:
	var teclas := {
		"mover_adelante": [KEY_W, KEY_UP],
		"mover_atras": [KEY_S, KEY_DOWN],
		"mover_izquierda": [KEY_A, KEY_LEFT],
		"mover_derecha": [KEY_D, KEY_RIGHT],
		"correr": [KEY_SHIFT],
		"saltar": [KEY_SPACE],
		"atacar": [KEY_J],
		"girar_izquierda": [KEY_Q],
		"girar_derecha": [KEY_E],
		"acercar": [KEY_PLUS, KEY_KP_ADD, KEY_EQUAL],
		"alejar": [KEY_MINUS, KEY_KP_SUBTRACT],
		"inclinar_arriba": [KEY_R],
		"inclinar_abajo": [KEY_F],
		"aceptar": [KEY_ENTER, KEY_KP_ENTER],
		"pausa": [KEY_ESCAPE],
		"estilo_1": [KEY_1, KEY_KP_1],
		"estilo_2": [KEY_2, KEY_KP_2],
		"estilo_3": [KEY_3, KEY_KP_3],
	}
	for accion in teclas:
		if InputMap.has_action(accion):
			InputMap.erase_action(accion)
		InputMap.add_action(accion)
		for tecla in teclas[accion]:
			var evento := InputEventKey.new()
			evento.keycode = tecla
			InputMap.action_add_event(accion, evento)
	var clic := InputEventMouseButton.new()
	clic.button_index = MOUSE_BUTTON_LEFT
	InputMap.action_add_event("atacar", clic)


func _preparar_vista() -> void:
	# Todo el mundo 3D se dibuja dentro de un SubViewport: así la estética pixel art
	# puede dibujarlo a menor resolución y escalarlo sin suavizar.
	if contenedor:
		contenedor.queue_free()
	if capa_efectos:
		capa_efectos.queue_free()
		capa_efectos = null
	var estilos = Estilos.new(estilo)
	contenedor = SubViewportContainer.new()
	contenedor.stretch = true
	contenedor.stretch_shrink = estilos.factor_pixelado()
	contenedor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	contenedor.material = estilos.material_contenedor()
	add_child(contenedor)
	contenedor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vista = SubViewport.new()
	vista.audio_listener_enable_3d = true
	contenedor.add_child(vista)
	if estilos.usa_maqueta():
		capa_efectos = CanvasLayer.new()
		capa_efectos.layer = 5
		add_child(capa_efectos)
		var efecto := ColorRect.new()
		efecto.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		efecto.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var material := ShaderMaterial.new()
		material.shader = SHADER_MAQUETA
		efecto.material = material
		capa_efectos.add_child(efecto)
	hud.poner_estilo("Godot · " + estilos.nombre())


func _iniciar_juego(con_intro: bool) -> void:
	if juego:
		juego.queue_free()
	juego = Juego.new()
	vista.add_child(juego)
	juego.fase_cambiada.connect(_al_cambiar_fase)
	juego.vida_cambiada.connect(hud.poner_vida)
	juego.derrotados_cambiados.connect(hud.poner_derrotados)
	juego.iniciar(estilo, con_intro)
	hud.poner_vida(Datos.VIDA_MAXIMA)
	hud.poner_derrotados(0, Datos.PATRULLAS.size())
	_al_cambiar_fase(juego.fase)


func cambiar_estilo(nuevo: String) -> void:
	if nuevo == estilo or not nuevo in Estilos.ORDEN:
		return
	# Se conserva dónde está Akira y cómo mira la cámara, para comparar el mismo plano.
	var posicion: Vector3 = juego.akira.global_position
	var mirando: Vector3 = juego.akira.mirando
	var camara_actual = juego.camara
	var giro: float = camara_actual.giro
	var inclinacion: float = camara_actual.inclinacion
	var distancia: float = camara_actual.distancia
	var fase_anterior: String = juego.fase
	estilo = nuevo
	_preparar_vista()
	_iniciar_juego(fase_anterior == "intro")
	if fase_anterior != "intro":
		juego.akira.global_position = posicion
		juego.akira.mirando = mirando
		juego.camara.giro = giro
		juego.camara.inclinacion = inclinacion
		juego.camara.distancia = distancia
		juego.camara.colocar_de_golpe()


func _al_cambiar_fase(fase: String) -> void:
	match fase:
		"intro":
			hud.mostrar_texto(Datos.TITULO, Datos.SUBTITULO, Datos.TEXTO_INTRO, "Pulsa ENTER para empezar")
		"jugando":
			hud.ocultar_texto()
			hud.mostrar_ayuda()
		"cierre":
			hud.mostrar_texto(Datos.TITULO_CIERRE, "El castillo de Hoshiyama", Datos.TEXTO_CIERRE,
				"Pulsa ENTER para volver a empezar")
		"derrota":
			hud.mostrar_texto(Datos.TITULO_DERROTA, "", Datos.TEXTO_DERROTA, "Pulsa ENTER para intentarlo de nuevo")


func _alternar_pausa() -> void:
	var pausado := not get_tree().paused
	get_tree().paused = pausado
	hud.poner_pausa(pausado)


func _input(evento: InputEvent) -> void:
	if evento.is_action_pressed("pausa"):
		_alternar_pausa()
		get_viewport().set_input_as_handled()
		return
	if get_tree().paused:
		if evento.is_action_pressed("aceptar"):
			_alternar_pausa()
		elif evento is InputEventKey and evento.pressed and evento.keycode == KEY_Q:
			get_tree().quit()
		get_viewport().set_input_as_handled()
		return
	for indice in Estilos.ORDEN.size():
		if evento.is_action_pressed("estilo_%d" % (indice + 1)):
			cambiar_estilo(Estilos.ORDEN[indice])
			get_viewport().set_input_as_handled()
			return
	if evento.is_action_pressed("aceptar"):
		_aceptar()


func _aceptar() -> void:
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
