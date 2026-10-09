# Temas: dificultad y rejilla de categorias con su progreso.
extends Control

var _rejilla: GridContainer
var _botones_dif: Array[Button] = []


func _ready() -> void:
	var col := Estilo.pantalla(self)
	Estilo.barra(col, "Temas", func(): Estilo.ir(self, "menu"))

	var difs := HBoxContainer.new()
	difs.add_theme_constant_override("separation", 12)
	for i in Economia.DIFICULTADES.size():
		var b := Estilo.boton(Economia.DIFICULTADES[i]["nombre"], "normal", 104)
		b.add_theme_font_size_override("font_size", 34)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(func():
			Progreso.fijar_ajuste("dificultad", i)
			_pintar())
		_botones_dif.append(b)
		difs.add_child(b)
	col.add_child(difs)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	_rejilla = GridContainer.new()
	_rejilla.columns = 2
	_rejilla.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rejilla.add_theme_constant_override("h_separation", 24)
	_rejilla.add_theme_constant_override("v_separation", 24)
	scroll.add_child(_rejilla)
	_pintar()


func _pintar() -> void:
	var dif := int(Progreso.ajuste("dificultad"))
	for i in _botones_dif.size():
		var elegido := i == dif
		Estilo.colorear(_botones_dif[i], Estilo.PRIMARIO if elegido else Estilo.SUPERFICIE,
			Estilo.SOBRE_PRIMARIO if elegido else Estilo.TEXTO, false)
	for h in _rejilla.get_children():
		h.queue_free()
	for c in Temas.lista:
		_rejilla.add_child(_tarjeta(c, dif))


func _tarjeta(c: Dictionary, dif: int) -> Button:
	var color := Color(c["color"])
	var t := Estilo.tarjeta(232, Estilo.SUPERFICIE, func():
		Temas.seleccion["categoria"] = c["id"]
		Estilo.ir(self, "sopas"))
	var b: Button = t[0]
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v: VBoxContainer = t[1]
	var punto := Panel.new()
	punto.custom_minimum_size = Vector2(40, 40)
	punto.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	punto.add_theme_stylebox_override("panel", Estilo.caja(color, 22, 0, false))
	v.add_child(punto)
	var nombre := Estilo.titulo(c["nombre"], 40)
	nombre.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(nombre)
	var total: int = c["subtemas"].size()
	var hechas := Progreso.resueltas_en(c["id"], dif)
	v.add_child(Estilo.etiqueta("%d de %d" % [hechas, total], 32, Estilo.TEXTO_SUAVE, false))
	var barra := ProgressBar.new()
	barra.show_percentage = false
	barra.custom_minimum_size = Vector2(0, 12)
	barra.max_value = total
	barra.value = hechas
	barra.add_theme_stylebox_override("background", Estilo.caja(Color(Estilo.TEXTO, 0.08), 6, 0, false))
	barra.add_theme_stylebox_override("fill", Estilo.caja(color, 6, 0, false))
	v.add_child(barra)
	for h in v.get_children():
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return b


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		Estilo.ir(self, "menu")
