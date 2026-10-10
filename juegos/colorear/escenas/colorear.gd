# Pantalla de coloreado: la lamina, deshacer/rehacer y la paleta.
extends Control

## Lamina a abrir (la fija la pantalla anterior).
static var lamina_id := ""

var lamina: Lamina
var vista := VistaLamina.new()
var color_actual := Color.WHITE
var _muestras: Array[Button] = []
var _rejilla := GridContainer.new()
var _nombre_paleta: Label
var _deshacer: Button
var _rehacer: Button
var _goma: Button


func _ready() -> void:
	if lamina_id == "" or not Laminas.existe(lamina_id):
		lamina_id = Laminas.categorias[0]["laminas"][0]["id"]
	lamina = Laminas.abrir(lamina_id)
	Obras.cargar_en(lamina)

	var col := Estilo.pantalla(self)
	col.add_theme_constant_override("separation", 24)
	var botones := HBoxContainer.new()
	_deshacer = _boton_icono("↶", func(): if lamina.deshacer(): _al_cambiar())
	_rehacer = _boton_icono("↷", func(): if lamina.rehacer(): _al_cambiar())
	botones.add_child(_deshacer)
	botones.add_child(_rehacer)
	Estilo.barra(col, Laminas.nombre(lamina_id), _salir, botones)

	vista.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vista.zona_tocada.connect(_pintar)
	vista.trazo_empezado.connect(func(): lamina.empezar_trazo())
	vista.trazo_terminado.connect(func():
		lamina.terminar_trazo()
		_al_cambiar())
	vista.trazo_cancelado.connect(func():
		lamina.cancelar_trazo()
		_al_cambiar())
	col.add_child(vista)
	vista.mostrar(lamina)

	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 16)
	var antes := _boton_icono("‹", func(): _cambiar_paleta(-1))
	var despues := _boton_icono("›", func(): _cambiar_paleta(1))
	_nombre_paleta = Estilo.etiqueta("", 40, Estilo.TEXTO, true, false)
	_nombre_paleta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_nombre_paleta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_goma = Estilo.boton("Goma", "normal", 112)
	_goma.custom_minimum_size.x = 200
	_goma.pressed.connect(func(): _elegir(Color.WHITE))
	var ver := _boton_icono("⤢", vista.reiniciar_zoom)
	for n in [antes, _nombre_paleta, despues, _goma, ver]:
		fila.add_child(n)
	col.add_child(fila)

	_rejilla.columns = 6
	_rejilla.add_theme_constant_override("h_separation", 20)
	_rejilla.add_theme_constant_override("v_separation", 20)
	col.add_child(_rejilla)
	_poner_paleta(int(Ajustes.valor("paleta")))
	_al_cambiar()


func _boton_icono(texto: String, al_tocar: Callable) -> Button:
	var b := Estilo.boton(texto, "suave", 112)
	b.custom_minimum_size.x = 112
	b.add_theme_font_size_override("font_size", 56)
	b.pressed.connect(al_tocar)
	return b


func _cambiar_paleta(paso: int) -> void:
	var i := posmod(int(Ajustes.valor("paleta")) + paso, Paletas.LISTA.size())
	Ajustes.fijar("paleta", i)
	_poner_paleta(i)


func _poner_paleta(i: int) -> void:
	_nombre_paleta.text = Paletas.nombre(i)
	for m in _muestras:
		m.queue_free()
	_muestras.clear()
	for c in Paletas.colores(i):
		var b := Button.new()
		b.custom_minimum_size = Vector2(0, 140)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.set_meta("color", c)
		b.pressed.connect(func():
			Sonido.tocar("clic")
			_elegir(c))
		_rejilla.add_child(b)
		_muestras.append(b)
	_elegir(Paletas.colores(i)[0])


func _elegir(c: Color) -> void:
	color_actual = c
	for b in _muestras:
		_estilo_muestra(b, b.get_meta("color"), b.get_meta("color") == c)
	_estilo_muestra(_goma, Estilo.SUPERFICIE, c == Color.WHITE, Estilo.TEXTO)


func _estilo_muestra(b: Button, c: Color, elegido: bool, tinta: Color = Color.TRANSPARENT) -> void:
	var caja := StyleBoxFlat.new()
	caja.bg_color = c
	caja.set_corner_radius_all(70)
	caja.set_border_width_all(10 if elegido else 2)
	caja.border_color = Estilo.TEXTO if elegido else Color(Estilo.TEXTO, 0.15)
	for estado in ["normal", "hover", "pressed", "focus", "hover_pressed"]:
		b.add_theme_stylebox_override(estado, caja)
	if tinta != Color.TRANSPARENT:
		for estado in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			b.add_theme_color_override(estado, tinta)


func _pintar(zona: int) -> void:
	if lamina.pintar(zona, color_actual):
		Sonido.vibrar(15)
		_al_cambiar()


func _al_cambiar() -> void:
	_deshacer.disabled = not lamina.puede_deshacer()
	_rehacer.disabled = not lamina.puede_rehacer()


func _salir() -> void:
	lamina.terminar_trazo()
	Obras.guardar(lamina)
	Estilo.ir(self, "menu")


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		_salir()
	elif que == NOTIFICATION_APPLICATION_PAUSED or que == NOTIFICATION_WM_CLOSE_REQUEST:
		if lamina:
			Obras.guardar(lamina)
