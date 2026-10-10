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
var _modo: Button
var _evitar := {}               # zonas ya propuestas por "buscar zona sin pintar"
var _estaba_terminada := false
var _celebrando := false
var _guardando := false


func _ready() -> void:
	if lamina_id == "" or not Laminas.existe(lamina_id):
		lamina_id = Laminas.categorias[0]["laminas"][0]["id"]
	lamina = Laminas.abrir(lamina_id)
	Obras.cargar_en(lamina)

	var col := Estilo.pantalla(self)
	col.add_theme_constant_override("separation", 24)
	var botones := HBoxContainer.new()
	# Modo de pintar: pincel (arrastrar pinta) o tocar (solo la zona tocada).
	_modo = Estilo.boton("", "suave", 112)
	_modo.custom_minimum_size.x = 112
	_modo.add_theme_font_size_override("font_size", 52)
	_modo.pressed.connect(func():
		Ajustes.fijar("pincel", not bool(Ajustes.valor("pincel")))
		_poner_modo()
		Estilo.aviso(self, "Pincel: arrastra el dedo para pintar" if vista.arrastrar_pinta else "Tocar: se rellena la zona que tocas"))
	botones.add_child(_modo)
	_deshacer = _boton_icono("↶", func(): if lamina.deshacer(): _al_cambiar())
	_rehacer = _boton_icono("↷", func(): if lamina.rehacer(): _al_cambiar())
	botones.add_child(_deshacer)
	botones.add_child(_rehacer)
	botones.add_child(_boton_icono("⤓", guardar_imagen))
	Estilo.barra(col, Laminas.nombre(lamina_id), _salir, botones, 48)

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
	_poner_modo()

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
	var buscar := _boton_icono("◎", buscar_zona)
	var ver := _boton_icono("⤢", vista.reiniciar_zoom)
	for n in [antes, _nombre_paleta, despues, _goma, buscar, ver]:
		fila.add_child(n)
	col.add_child(fila)

	_rejilla.columns = 6
	_rejilla.add_theme_constant_override("h_separation", 20)
	_rejilla.add_theme_constant_override("v_separation", 20)
	col.add_child(_rejilla)
	_poner_paleta(int(Ajustes.valor("paleta")))
	_al_cambiar()
	_estaba_terminada = lamina.terminada()


func _boton_icono(texto: String, al_tocar: Callable) -> Button:
	var b := Estilo.boton(texto, "suave", 112)
	b.custom_minimum_size.x = 112
	b.add_theme_font_size_override("font_size", 56)
	b.pressed.connect(al_tocar)
	return b


func _poner_modo() -> void:
	vista.arrastrar_pinta = bool(Ajustes.valor("pincel"))
	_modo.text = "✎" if vista.arrastrar_pinta else "☝"


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
	var terminada := lamina.terminada()
	if terminada and not _estaba_terminada:
		_celebrar()
	_estaba_terminada = terminada


## Lleva la camara a la zona en blanco mas cercana al centro de lo que se ve.
## Pulsar otra vez sin pintarla lleva a la siguiente.
func buscar_zona() -> void:
	var centro := Vector2(vista.a_lamina(vista.size / 2.0))
	var z := lamina.vacia_mas_cercana(centro, _evitar)
	if z == 0 and not _evitar.is_empty():
		_evitar.clear()                 # ya se propusieron todas: se vuelve a empezar
		z = lamina.vacia_mas_cercana(centro)
	if z == 0:
		Estilo.aviso(self, "¡No quedan zonas sin pintar!" if lamina.info_zonas.size() > 0 else "Esta lámina no tiene ayuda de zonas")
		return
	_evitar[z] = true
	vista.enfocar(z)


func celebrando() -> bool:
	return _celebrando


## Recompensa al terminar: la lamina vuelve entera, las lineas se apagan un
## momento para ver solo el color, confeti y luego las opciones.
func _celebrar() -> void:
	_celebrando = true
	lamina.terminar_trazo()
	Obras.guardar(lamina)
	Sonido.tocar("victoria")
	Sonido.vibrar(60)
	vista.celebrar()
	_confeti()
	await get_tree().create_timer(1.3).timeout
	if not is_inside_tree():
		return
	var i := await Estilo.dialogo(self, "¡Lámina terminada!", "Quedó guardada en Mis obras.",
		["Guardar imagen", "Seguir pintando", "Elegir otra lámina"])
	_celebrando = false
	if not is_inside_tree():
		return
	if i == 0:
		guardar_imagen()
	elif i == 2:
		_salir()


func _confeti() -> void:
	var p := CPUParticles2D.new()
	p.position = Vector2(size.x / 2.0, -40)
	p.emitting = false
	p.one_shot = true
	p.amount = 140
	p.lifetime = 2.6
	p.explosiveness = 0.85
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(size.x / 2.0, 10)
	p.direction = Vector2(0, 1)
	p.spread = 25
	p.gravity = Vector2(0, 900)
	p.initial_velocity_min = 200
	p.initial_velocity_max = 700
	p.angular_velocity_min = -360
	p.angular_velocity_max = 360
	p.scale_amount_min = 10
	p.scale_amount_max = 22
	var g := Gradient.new()
	var colores := Paletas.colores(int(Ajustes.valor("paleta")))
	g.offsets = PackedFloat32Array(range(colores.size()).map(func(k): return float(k) / maxf(colores.size() - 1, 1)))
	g.colors = PackedColorArray(colores)
	p.color_initial_ramp = g
	add_child(p)
	p.emitting = true
	get_tree().create_timer(p.lifetime + 0.5).timeout.connect(p.queue_free)


## Guarda la obra como imagen en la galeria (Imagenes/Lienzo Zen).
func guardar_imagen() -> void:
	if _guardando:
		return
	_guardando = true
	lamina.terminar_trazo()
	_guardar()
	Estilo.aviso(self, "Guardando imagen…")
	# deja pintar el aviso antes del calculo (bloquea un momento)
	await get_tree().process_frame
	await get_tree().process_frame
	var r := Exportar.guardar(lamina)
	_guardando = false
	if not is_inside_tree():
		return
	if not r["ok"]:
		Estilo.aviso(self, "No se pudo guardar la imagen")
	elif r["en_galeria"]:
		Estilo.aviso(self, "Guardada en Imágenes › Lienzo Zen")
	else:
		Estilo.aviso(self, "No se pudo usar la galería: quedó en la carpeta de la app")


## Guarda la obra y, si es la lamina del dia, cuenta para la racha.
func _guardar() -> void:
	Obras.guardar(lamina)
	var hoy := Diario.hoy()
	if lamina_id == Laminas.del_dia(hoy) and not lamina.a_datos()["colores"].is_empty():
		Diario.marcar(hoy)


func _salir() -> void:
	lamina.terminar_trazo()
	_guardar()
	Estilo.ir(self, "menu")


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		_salir()
	elif que == NOTIFICATION_APPLICATION_PAUSED or que == NOTIFICATION_WM_CLOSE_REQUEST:
		if lamina:
			_guardar()
