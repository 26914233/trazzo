# Controles táctiles para el móvil: joystick a la izquierda (en el borde, corre), botones
# de atacar, iai, corte de luna y saltar a la derecha, arrastrar por el resto de la
# pantalla para girar la cámara, botón de pausa arriba y tocar para seguir en los textos.
# Solo aparecen en pantallas táctiles (o con la opción --tactil para probarlos en el PC).
extends CanvasLayer

const RADIO_JOYSTICK := 95.0
const ZONA_JOYSTICK := 0.45           # fracción de la pantalla, desde la izquierda
const MOVIMIENTOS := ["mover_izquierda", "mover_derecha", "mover_adelante", "mover_atras"]


# Dibuja el joystick y los botones encima del juego.
class Dibujo extends Control:
	var mando

	func _draw() -> void:
		var tinta := Color(0.93, 0.9, 0.82, 0.85)
		var fondo := Color(0.05, 0.05, 0.1, 0.35)
		if mando.dedo_joystick >= 0:
			var radio: float = mando.RADIO_JOYSTICK
			draw_circle(mando.centro_joystick, radio, fondo)
			draw_arc(mando.centro_joystick, radio, 0.0, TAU, 48, tinta, 3.0, true)
			draw_circle(mando.centro_joystick + mando.vector * radio, 38.0, Color(0.93, 0.9, 0.82, 0.55))
		else:
			var reposo: Vector2 = mando.centro_reposo()
			draw_arc(reposo, mando.RADIO_JOYSTICK, 0.0, TAU, 48, Color(0.93, 0.9, 0.82, 0.3), 3.0, true)
		for nombre in mando.botones:
			var boton: Dictionary = mando.botones[nombre]
			var pulsado: bool = boton.dedo >= 0
			draw_circle(boton.centro, boton.radio, Color(0.75, 0.2, 0.16, 0.7) if pulsado else fondo)
			draw_arc(boton.centro, boton.radio, 0.0, TAU, 40, tinta, 3.0, true)
			if nombre == "especial":
				# El botón de la luna se llena con el espíritu; lleno, brilla en dorado.
				var espiritu: float = mando.espiritu
				var dorado := Color(0.89, 0.73, 0.38, 0.95)
				if espiritu >= 1.0:
					draw_circle(boton.centro, boton.radio - 4.0, Color(0.89, 0.73, 0.38, 0.45))
				draw_arc(boton.centro, boton.radio + 5.0, -PI / 2.0, -PI / 2.0 + TAU * espiritu, 40, dorado, 6.0, true)
			var ancho: float = mando.fuente.get_string_size(boton.texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
			draw_string(mando.fuente, boton.centro + Vector2(-ancho / 2.0, 8.0), boton.texto,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 22, tinta)


var principal
var activo := false
var fuente: Font
var dibujo: Dibujo
var botones := {}                     # nombre → {centro, radio, texto, accion, dedo}
var dedo_joystick := -1
var centro_joystick := Vector2.ZERO
var vector := Vector2.ZERO
var dedo_camara := -1
var espiritu := 0.0


func _ready() -> void:
	layer = 8                         # por debajo del HUD (textos y pausa en la capa 10)
	process_mode = Node.PROCESS_MODE_ALWAYS
	var sistema := SystemFont.new()
	sistema.font_names = PackedStringArray(["Georgia", "DejaVu Serif", "serif"])
	fuente = sistema
	dibujo = Dibujo.new()
	dibujo.mando = self
	dibujo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dibujo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dibujo)
	get_viewport().size_changed.connect(_colocar_botones)
	_colocar_botones()
	activar(DisplayServer.is_touchscreen_available())


func activar(valor: bool) -> void:
	activo = valor
	visible = valor
	# Con los controles táctiles, un toque no debe convertirse además en un clic de ratón.
	Input.emulate_mouse_from_touch = not valor
	_soltar_todo()


func centro_reposo() -> Vector2:
	var pantalla := get_viewport().get_visible_rect().size
	return Vector2(170.0, pantalla.y - 170.0)


func _colocar_botones() -> void:
	var pantalla := get_viewport().get_visible_rect().size
	botones = {
		"atacar": {"centro": pantalla - Vector2(150, 150), "radio": 72.0, "texto": "Atacar", "accion": "atacar", "dedo": -1},
		"parar": {"centro": pantalla - Vector2(150, 330), "radio": 56.0, "texto": "Iai", "accion": "parar", "dedo": -1},
		"especial": {"centro": pantalla - Vector2(310, 250), "radio": 50.0, "texto": "Luna", "accion": "especial", "dedo": -1},
		"saltar": {"centro": pantalla - Vector2(300, 90), "radio": 56.0, "texto": "Saltar", "accion": "saltar", "dedo": -1},
		"pausa": {"centro": Vector2(pantalla.x - 60, 110), "radio": 34.0, "texto": "II", "accion": "", "dedo": -1},
	}


func _process(_delta: float) -> void:
	if not activo or principal == null or principal.juego == null:
		return
	var actual: float = principal.juego.akira.espiritu
	if actual != espiritu:
		espiritu = actual
		dibujo.queue_redraw()


func _jugando() -> bool:
	return principal != null and principal.juego != null and principal.juego.fase == "jugando" \
		and not get_tree().paused


func _input(evento: InputEvent) -> void:
	if not activo:
		return
	if evento is InputEventScreenTouch:
		_tocar(evento)
		get_viewport().set_input_as_handled()
	elif evento is InputEventScreenDrag:
		_arrastrar(evento)
		get_viewport().set_input_as_handled()


func _tocar(evento: InputEventScreenTouch) -> void:
	if not _jugando():
		# En los textos o en pausa, tocar la pantalla equivale a ENTER (o a continuar). En la
		# pausa, los botones cambian la animación (anime o suave) y el aspecto de Akira, y
		# abren la galería.
		if not evento.pressed:
			if get_tree().paused:
				if principal.hud.boton_animacion.get_global_rect().has_point(evento.position):
					principal.alternar_estilo_animacion()
				elif principal.hud.boton_galeria.get_global_rect().has_point(evento.position):
					principal.abrir_galeria()
				elif principal.hud.boton_apariencia.get_global_rect().has_point(evento.position):
					principal.cambiar_apariencia()
				else:
					principal.alternar_pausa()
			else:
				principal.aceptar()
		_soltar_todo()
		return
	if evento.pressed:
		for nombre in botones:
			var boton: Dictionary = botones[nombre]
			if evento.position.distance_to(boton.centro) <= boton.radio * 1.15:
				boton.dedo = evento.index
				if nombre == "pausa":
					principal.alternar_pausa()
				else:
					Input.action_press(boton.accion)
				dibujo.queue_redraw()
				return
		var pantalla := get_viewport().get_visible_rect().size
		if evento.position.x < pantalla.x * ZONA_JOYSTICK and dedo_joystick < 0:
			dedo_joystick = evento.index
			centro_joystick = evento.position
			vector = Vector2.ZERO
		elif dedo_camara < 0:
			dedo_camara = evento.index
	else:
		for nombre in botones:
			var boton: Dictionary = botones[nombre]
			if boton.dedo == evento.index:
				boton.dedo = -1
				if boton.accion != "":
					Input.action_release(boton.accion)
		if evento.index == dedo_joystick:
			dedo_joystick = -1
			_mover(Vector2.ZERO)
		if evento.index == dedo_camara:
			dedo_camara = -1
	dibujo.queue_redraw()


func _arrastrar(evento: InputEventScreenDrag) -> void:
	if not _jugando():
		return
	if evento.index == dedo_joystick:
		_mover((evento.position - centro_joystick).limit_length(RADIO_JOYSTICK) / RADIO_JOYSTICK)
	elif evento.index == dedo_camara:
		principal.juego.camara.girar_por_arrastre(evento.relative)


func _mover(nuevo: Vector2) -> void:
	vector = nuevo
	# Las acciones de movimiento admiten fuerza: el joystick es analógico.
	for accion in MOVIMIENTOS:
		Input.action_release(accion)
	if vector.x < 0.0:
		Input.action_press("mover_izquierda", -vector.x)
	elif vector.x > 0.0:
		Input.action_press("mover_derecha", vector.x)
	if vector.y < 0.0:
		Input.action_press("mover_adelante", -vector.y)
	elif vector.y > 0.0:
		Input.action_press("mover_atras", vector.y)
	if vector.length() > 0.95:
		Input.action_press("correr")
	else:
		Input.action_release("correr")
	dibujo.queue_redraw()


func _soltar_todo() -> void:
	dedo_joystick = -1
	dedo_camara = -1
	if botones.is_empty():
		return
	_mover(Vector2.ZERO)
	for nombre in botones:
		var boton: Dictionary = botones[nombre]
		if boton.dedo >= 0 and boton.accion != "":
			Input.action_release(boton.accion)
		boton.dedo = -1
	dibujo.queue_redraw()
