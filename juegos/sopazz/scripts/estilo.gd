# Estilo visual compartido (claymorphism: bordes gruesos, esquinas grandes,
# sombra suave) y utilidades de interfaz: navegacion, dialogos y avisos.
# Paleta tomada de ui-ux-pro-max para "casual word puzzle", contraste >= 4.5.
class_name Estilo
extends RefCounted

const FONDO := Color("#FDF2F8")
const TARJETA := Color("#FFFFFF")
const TEXTO := Color("#0F172A")
const TEXTO_SUAVE := Color("#475569")
const PRIMARIO := Color("#EC4899")
const SECUNDARIO := Color("#8B5CF6")
const ORO := Color("#F59E0B")
const BORDE := Color("#0F172A")
const ERROR := Color("#DC2626")
const BLOQUEADO := Color("#E2E8F0")

const RADIO := 28
const GROSOR := 5

static var _tema: Theme


static func caja(fondo: Color, radio: int = RADIO, borde: int = GROSOR, sombra: int = 8) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fondo
	s.set_corner_radius_all(radio)
	s.set_border_width_all(borde)
	s.border_color = BORDE
	s.shadow_color = Color(BORDE, 0.9)
	s.shadow_size = 0
	s.shadow_offset = Vector2(0, sombra)
	if sombra > 0:
		s.shadow_size = 1
	s.content_margin_left = 32
	s.content_margin_right = 32
	s.content_margin_top = 22
	s.content_margin_bottom = 22
	s.anti_aliasing = true
	return s


static func tema() -> Theme:
	if _tema:
		return _tema
	var t := Theme.new()
	t.default_font_size = 46
	t.set_color("font_color", "Label", TEXTO)
	t.set_color("default_color", "RichTextLabel", TEXTO)
	for estado in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		t.set_color(estado, "Button", TEXTO)
	t.set_color("font_disabled_color", "Button", TEXTO_SUAVE)
	t.set_font_size("font_size", "Button", 52)
	t.set_stylebox("normal", "Button", caja(TARJETA))
	t.set_stylebox("hover", "Button", caja(TARJETA))
	var pulsado := caja(Color("#FCE7F3"), RADIO, GROSOR, 2)
	pulsado.content_margin_top = 28  # "se hunde" al pulsar
	pulsado.content_margin_bottom = 16
	t.set_stylebox("pressed", "Button", pulsado)
	t.set_stylebox("disabled", "Button", caja(BLOQUEADO, RADIO, GROSOR, 0))
	var foco := caja(Color(0, 0, 0, 0), RADIO, 6, 0)
	foco.border_color = SECUNDARIO
	t.set_stylebox("focus", "Button", foco)
	t.set_stylebox("panel", "PanelContainer", caja(TARJETA))
	t.set_constant("separation", "VBoxContainer", 28)
	t.set_constant("separation", "HBoxContainer", 24)
	t.set_stylebox("grabber_area", "HSlider", caja(PRIMARIO, 12, 3, 0))
	t.set_stylebox("slider", "HSlider", caja(BLOQUEADO, 12, 3, 0))
	_tema = t
	return t


## Raiz de pantalla: fondo, margenes con zona segura (muescas) y columna.
static func pantalla(raiz: Control) -> VBoxContainer:
	raiz.theme = tema()
	raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	var fondo := ColorRect.new()
	fondo.color = FONDO
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(fondo)
	var margen := MarginContainer.new()
	margen.set_anchors_preset(Control.PRESET_FULL_RECT)
	var arriba := 56 + _margen_muesca(raiz)
	for lado in ["left", "right"]:
		margen.add_theme_constant_override("margin_" + lado, 48)
	margen.add_theme_constant_override("margin_top", arriba)
	margen.add_theme_constant_override("margin_bottom", 56)
	raiz.add_child(margen)
	var col := VBoxContainer.new()
	margen.add_child(col)
	return col


static func _margen_muesca(raiz: Control) -> int:
	if not OS.has_feature("mobile"):
		return 0
	var seguro := DisplayServer.get_display_safe_area()
	var pantalla_px := DisplayServer.screen_get_size()
	if pantalla_px.y == 0:
		return 0
	var escala := raiz.get_viewport_rect().size.y / float(pantalla_px.y)
	return int(seguro.position.y * escala)


static func etiqueta(texto: String, tam: int = 46, color: Color = TEXTO, centrar: bool = true) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", color)
	if centrar:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


static func boton(texto: String, fondo: Color = TARJETA, alto: int = 150) -> Button:
	var b := Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(0, alto)
	if fondo != TARJETA:
		b.add_theme_stylebox_override("normal", caja(fondo))
		b.add_theme_stylebox_override("hover", caja(fondo))
		var p := caja(fondo.darkened(0.12), RADIO, GROSOR, 2)
		p.content_margin_top = 28
		p.content_margin_bottom = 16
		b.add_theme_stylebox_override("pressed", p)
	b.pressed.connect(func(): Sonido.tocar("clic"))
	return b


## Pildora con el contador de fichas, que se actualiza sola.
static func pildora_fichas() -> PanelContainer:
	var p := PanelContainer.new()
	var s := caja(ORO, 60, 4, 4)
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	p.add_theme_stylebox_override("panel", s)
	var l := etiqueta("", 44)
	var poner := func(total: int) -> void: l.text = "%s fichas" % miles(total)
	poner.call(Progreso.fichas())
	Progreso.fichas_cambiadas.connect(poner)
	p.add_child(l)
	return p


static func miles(n: int) -> String:
	var s := str(absi(n))
	var out := ""
	while s.length() > 3:
		out = "." + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return ("-" if n < 0 else "") + s + out


static func ir(desde: Node, escena: String) -> void:
	desde.get_tree().change_scene_to_file("res://escenas/%s.tscn" % escena)


## Aviso breve abajo de la pantalla que se desvanece solo.
static func aviso(raiz: Control, texto: String) -> void:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", caja(TEXTO, 40, 0, 0))
	var l := etiqueta(texto, 42, Color.WHITE)
	p.add_child(l)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(p)
	p.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 260)
	p.custom_minimum_size.x = 860
	p.position.x = (raiz.size.x - 860) / 2.0
	var tw := p.create_tween()
	tw.tween_interval(2.2)
	tw.tween_property(p, "modulate:a", 0.0, 0.35)
	tw.tween_callback(p.queue_free)


## Dialogo modal. `await Estilo.dialogo(...)` devuelve el indice elegido,
## o -1 si se cierra tocando fuera / con el boton atras.
static func dialogo(raiz: Control, titulo: String, texto: String, opciones: Array) -> int:
	var velo := ColorRect.new()
	velo.color = Color(TEXTO, 0.55)
	velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	raiz.add_child(velo)
	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	velo.add_child(centro)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(900, 0)
	centro.add_child(panel)
	var col := VBoxContainer.new()
	panel.add_child(col)
	col.add_child(etiqueta(titulo, 64))
	if texto != "":
		col.add_child(etiqueta(texto, 44, TEXTO_SUAVE))
	var res := {"i": -2}
	for i in opciones.size():
		var fondo := PRIMARIO if i == 0 else TARJETA
		var b := boton(opciones[i], fondo, 140)
		b.pressed.connect(func(): res["i"] = i)
		col.add_child(b)
	velo.gui_input.connect(func(e):
		if e is InputEventScreenTouch and e.pressed and not panel.get_global_rect().has_point(e.position):
			res["i"] = -1)
	while res["i"] == -2 and is_instance_valid(velo):
		await raiz.get_tree().process_frame
	if is_instance_valid(velo):
		velo.queue_free()
	return res["i"]
