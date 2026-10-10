# Estilo visual con variantes de diseño ("cielo", el principal; "papel" y
# "noche" y "contraste" (alto contraste), elegibles en Ajustes) y
# utilidades de interfaz: pantallas, botones, tarjetas, dialogos y avisos.
# Paletas de ui-ux-pro-max; texto con contraste >= 4.5 sobre su fondo.
class_name Estilo
extends RefCounted

const VARIANTES := {
	"cielo": {
		"nombre": "Cielo",
		"fondo": "#F0F9FF", "fondo_2": "#DCEFFD", "superficie": "#FFFFFF",
		"texto": "#0C4A6E", "texto_suave": "#3E6A85",
		"primario": "#0284C7", "sobre_primario": "#FFFFFF",
		"acento": "#F59E0B", "sobre_acento": "#3B2300",
		"borde": "#D3E9F8", "bloqueado": "#EEF4F8", "tablero": "#FFFFFF", "letra": "#0C4A6E",
		"radio": 30, "grosor": 0, "sombra": "#0C4A6E1F", "sombra_tam": 22, "sombra_y": 8,
		"titulo": "Fredoka-SemiBold.ttf", "texto_fuente": "Fredoka-Medium.ttf", "negrita": "Fredoka-SemiBold.ttf",
	},
	"papel": {
		"nombre": "Papel",
		"fondo": "#FAF7F2", "fondo_2": "#F1EBE1", "superficie": "#FFFFFF",
		"texto": "#1C1917", "texto_suave": "#57534E",
		"primario": "#1C1917", "sobre_primario": "#FFFFFF",
		"acento": "#A16207", "sobre_acento": "#FFFFFF",
		"borde": "#E7E2D9", "bloqueado": "#F2EEE7", "tablero": "#FFFFFF", "letra": "#1C1917",
		"radio": 18, "grosor": 2, "sombra": "#1C19170F", "sombra_tam": 14, "sombra_y": 4,
		"titulo": "Fraunces-Bold.ttf", "texto_fuente": "DMSans-Medium.ttf", "negrita": "DMSans-Bold.ttf",
	},
	"noche": {
		"nombre": "Noche",
		"fondo": "#0B1222", "fondo_2": "#1B1A3D", "superficie": "#172036",
		"texto": "#F1F5F9", "texto_suave": "#A3B1C6",
		"primario": "#34D399", "sobre_primario": "#052E1F",
		"acento": "#FBBF24", "sobre_acento": "#1C1400",
		"borde": "#26324D", "bloqueado": "#111A2C", "tablero": "#131C30", "letra": "#E2E8F0",
		"radio": 24, "grosor": 1, "sombra": "#00000059", "sombra_tam": 18, "sombra_y": 6,
		"titulo": "Nunito-ExtraBold.ttf", "texto_fuente": "Nunito-Bold.ttf", "negrita": "Nunito-ExtraBold.ttf",
	},
	# Alto contraste (accesibilidad): negro, blanco y amarillo, bordes marcados.
	"contraste": {
		"nombre": "Contraste",
		"fondo": "#000000", "fondo_2": "#000000", "superficie": "#111111",
		"texto": "#FFFFFF", "texto_suave": "#E6E6E6",
		"primario": "#FFD60A", "sobre_primario": "#000000",
		"acento": "#FFD60A", "sobre_acento": "#000000",
		"borde": "#FFFFFF", "bloqueado": "#1A1A1A", "tablero": "#000000", "letra": "#FFFFFF",
		"radio": 18, "grosor": 3, "sombra": "#00000000", "sombra_tam": 0, "sombra_y": 0,
		"titulo": "Nunito-ExtraBold.ttf", "texto_fuente": "Nunito-Bold.ttf", "negrita": "Nunito-ExtraBold.ttf",
	},
}

static var actual := ""
static var FONDO: Color
static var FONDO_2: Color
static var SUPERFICIE: Color
static var TEXTO: Color
static var TEXTO_SUAVE: Color
static var PRIMARIO: Color
static var SOBRE_PRIMARIO: Color
static var ACENTO: Color
static var SOBRE_ACENTO: Color
static var BORDE: Color
static var BLOQUEADO: Color
static var TABLERO: Color
static var LETRA: Color
static var RADIO := 18
static var GROSOR := 2
static var SOMBRA: Color
static var SOMBRA_TAM := 12
static var SOMBRA_Y := 4
static var FUENTE_TITULO: Font
static var FUENTE_TEXTO: Font
static var FUENTE_NEGRITA: Font
static var _tema: Theme


static func aplicar(nombre: String) -> void:
	if not VARIANTES.has(nombre):
		nombre = "cielo"
	var v: Dictionary = VARIANTES[nombre]
	actual = nombre
	FONDO = Color(v["fondo"]); FONDO_2 = Color(v["fondo_2"]); SUPERFICIE = Color(v["superficie"])
	TEXTO = Color(v["texto"]); TEXTO_SUAVE = Color(v["texto_suave"])
	PRIMARIO = Color(v["primario"]); SOBRE_PRIMARIO = Color(v["sobre_primario"])
	ACENTO = Color(v["acento"]); SOBRE_ACENTO = Color(v["sobre_acento"])
	BORDE = Color(v["borde"]); BLOQUEADO = Color(v["bloqueado"])
	TABLERO = Color(v["tablero"]); LETRA = Color(v["letra"])
	RADIO = v["radio"]; GROSOR = v["grosor"]
	SOMBRA = Color(v["sombra"]); SOMBRA_TAM = v["sombra_tam"]; SOMBRA_Y = v["sombra_y"]
	FUENTE_TITULO = load("res://arte/fuentes/" + v["titulo"])
	FUENTE_TEXTO = load("res://arte/fuentes/" + v["texto_fuente"])
	FUENTE_NEGRITA = load("res://arte/fuentes/" + v["negrita"])
	_tema = null


static func _asegurar() -> void:
	if actual == "":
		aplicar("cielo")


static func es_oscuro() -> bool:
	_asegurar()
	return FONDO.get_luminance() < 0.3


## Color de una categoria adaptado al diseño: suave en los claros, intenso en el oscuro.
static func tinte(c: Color) -> Color:
	if actual == "contraste":
		return c.darkened(0.72)        # el texto blanco necesita un fondo muy oscuro
	return c.darkened(0.45) if es_oscuro() else c.lightened(0.78)


static func caja(fondo: Color, radio: int = -1, borde: int = -1, con_sombra: bool = true) -> StyleBoxFlat:
	_asegurar()
	var s := StyleBoxFlat.new()
	s.bg_color = fondo
	s.set_corner_radius_all(RADIO if radio < 0 else radio)
	s.set_border_width_all(GROSOR if borde < 0 else borde)
	s.border_color = BORDE
	if con_sombra:
		s.shadow_color = SOMBRA
		s.shadow_size = SOMBRA_TAM
		s.shadow_offset = Vector2(0, SOMBRA_Y)
	s.content_margin_left = 32
	s.content_margin_right = 32
	s.content_margin_top = 22
	s.content_margin_bottom = 22
	s.anti_aliasing = true
	return s


static func tema() -> Theme:
	_asegurar()
	if _tema:
		return _tema
	var t := Theme.new()
	t.default_font = FUENTE_TEXTO
	t.default_font_size = 44
	t.set_color("font_color", "Label", TEXTO)
	t.set_color("default_color", "RichTextLabel", TEXTO)
	t.set_font("normal_font", "RichTextLabel", FUENTE_TEXTO)
	t.set_font("bold_font", "RichTextLabel", FUENTE_NEGRITA)
	t.set_font("font", "Button", FUENTE_NEGRITA)
	t.set_font_size("font_size", "Button", 48)
	for estado in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		t.set_color(estado, "Button", TEXTO)
	t.set_color("font_disabled_color", "Button", TEXTO_SUAVE)
	t.set_stylebox("normal", "Button", caja(SUPERFICIE))
	t.set_stylebox("hover", "Button", caja(SUPERFICIE))
	t.set_stylebox("pressed", "Button", caja(SUPERFICIE.darkened(0.04), -1, -1, false))
	t.set_stylebox("disabled", "Button", caja(BLOQUEADO, -1, -1, false))
	var foco := caja(Color(0, 0, 0, 0), -1, 4, false)
	foco.border_color = ACENTO
	t.set_stylebox("focus", "Button", foco)
	t.set_stylebox("panel", "PanelContainer", caja(SUPERFICIE))
	t.set_constant("separation", "VBoxContainer", 28)
	t.set_constant("separation", "HBoxContainer", 22)
	t.set_stylebox("scroll", "VScrollBar", StyleBoxEmpty.new())
	t.set_stylebox("grabber", "VScrollBar", StyleBoxEmpty.new())
	_tema = t
	return t


## Raiz de pantalla: fondo en degradado, margenes con zona segura y columna.
static func pantalla(raiz: Control) -> VBoxContainer:
	raiz.theme = tema()
	raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	var grad := Gradient.new()
	grad.set_color(0, FONDO)
	grad.set_color(1, FONDO_2)
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill_from = Vector2(0, 0)
	tex.fill_to = Vector2(0, 1)
	tex.width = 8
	tex.height = 256
	var fondo := TextureRect.new()
	fondo.texture = tex
	fondo.stretch_mode = TextureRect.STRETCH_SCALE
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(fondo)
	var margen := MarginContainer.new()
	margen.set_anchors_preset(Control.PRESET_FULL_RECT)
	for lado in ["left", "right"]:
		margen.add_theme_constant_override("margin_" + lado, 52)
	margen.add_theme_constant_override("margin_top", 64 + _margen_muesca(raiz))
	margen.add_theme_constant_override("margin_bottom", 60)
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


static func etiqueta(texto: String, tam: int = 44, color: Color = Color.TRANSPARENT, centrar: bool = true, ajustar: bool = true) -> Label:
	_asegurar()
	var l := Label.new()
	l.text = texto
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", TEXTO if color == Color.TRANSPARENT else color)
	if centrar:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Con ajuste de linea, dentro de un HBoxContainer sin EXPAND la etiqueta pide
	# ancho 0 y se parte letra a letra. Ahi usar ajustar=false.
	if ajustar:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


static func titulo(texto: String, tam: int = 64, centrar: bool = false) -> Label:
	var l := etiqueta(texto, tam, TEXTO, centrar, false)
	l.add_theme_font_override("font", FUENTE_TITULO)
	return l


## tipo: "normal", "primario", "acento" o "suave" (sin fondo).
static func boton(texto: String, tipo: String = "normal", alto: int = 140) -> Button:
	_asegurar()
	var b := Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(0, alto)
	var fondo := SUPERFICIE
	var tinta := TEXTO
	match tipo:
		"primario":
			fondo = PRIMARIO
			tinta = SOBRE_PRIMARIO
		"acento":
			fondo = ACENTO
			tinta = SOBRE_ACENTO
		"suave":
			fondo = Color(TEXTO, 0.06)
	colorear(b, fondo, tinta, tipo != "suave")
	b.pressed.connect(func(): Sonido.tocar("clic"))
	return b


static func colorear(b: Button, fondo: Color, tinta: Color, con_sombra: bool = true) -> void:
	var borde := 0 if fondo != SUPERFICIE else -1
	for estado in ["normal", "hover", "focus"]:
		b.add_theme_stylebox_override(estado, caja(fondo, -1, borde, con_sombra))
	for estado in ["pressed", "hover_pressed"]:
		b.add_theme_stylebox_override(estado, caja(fondo.darkened(0.08), -1, borde, false))
	for estado in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(estado, tinta)


## Fila superior: boton atras, titulo y un hueco opcional a la derecha.
static func barra(col: VBoxContainer, texto: String, al_volver: Callable, derecha: Control = null) -> void:
	var fila := HBoxContainer.new()
	var atras := boton("‹", "suave", 112)
	atras.custom_minimum_size.x = 112
	atras.add_theme_font_size_override("font_size", 60)
	atras.pressed.connect(al_volver)
	fila.add_child(atras)
	var t := titulo(texto, 58)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	t.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	t.clip_text = true
	fila.add_child(t)
	if derecha:
		fila.add_child(derecha)
	col.add_child(fila)


## Tarjeta tocable con contenido libre (Button plano con hijos que no capturan).
static func tarjeta(alto: int, fondo: Color, al_tocar: Callable) -> Array:
	var b := Button.new()
	b.custom_minimum_size = Vector2(0, alto)
	colorear(b, fondo, TEXTO)
	b.pressed.connect(func():
		Sonido.tocar("clic")
		al_tocar.call())
	var m := MarginContainer.new()
	m.set_anchors_preset(Control.PRESET_FULL_RECT)
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for lado in ["left", "right", "top", "bottom"]:
		m.add_theme_constant_override("margin_" + lado, 30)
	b.add_child(m)
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_theme_constant_override("separation", 8)
	m.add_child(v)
	return [b, v]


static func estrellas_texto(n: int) -> String:
	return "★".repeat(n) + "☆".repeat(3 - n)


## Texto de datos dentro de un RichTextLabel con BBCode: el corchete se escapa
## para que una palabra no pueda abrir etiquetas (SEC-010).
static func escapar_bbcode(texto: String) -> String:
	return texto.replace("[", "[lb]")


static func ir(desde: Node, escena: String) -> void:
	desde.get_tree().change_scene_to_file("res://escenas/%s.tscn" % escena)


## Aviso breve abajo de la pantalla que se desvanece solo.
static func aviso(raiz: Control, texto: String) -> void:
	var capa := MarginContainer.new()
	capa.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa.add_theme_constant_override("margin_bottom", 300)
	capa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_END
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var c := CenterContainer.new()
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", caja(TEXTO, 40, 0, false))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l := etiqueta(texto, 40, FONDO)
	l.custom_minimum_size.x = 760
	p.add_child(l)
	c.add_child(p)
	v.add_child(c)
	capa.add_child(v)
	raiz.add_child(capa)
	var tw := capa.create_tween()
	tw.tween_interval(2.2)
	tw.tween_property(capa, "modulate:a", 0.0, 0.35)
	tw.tween_callback(capa.queue_free)


## Panel modal centrado sobre un velo. Devuelve [velo, columna].
static func modal(raiz: Control, ancho: int = 920) -> Array:
	var velo := ColorRect.new()
	velo.color = Color(0, 0, 0, 0.5)
	velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	raiz.add_child(velo)
	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE  # fuera del panel, el toque llega al velo
	velo.add_child(centro)
	var panel := PanelContainer.new()
	var estilo := caja(SUPERFICIE, RADIO + 8, -1, true)
	estilo.content_margin_left = 48
	estilo.content_margin_right = 48
	estilo.content_margin_top = 48
	estilo.content_margin_bottom = 48
	panel.add_theme_stylebox_override("panel", estilo)
	panel.custom_minimum_size = Vector2(ancho, 0)
	centro.add_child(panel)
	var col := VBoxContainer.new()
	panel.add_child(col)
	# Entrada suave. Ojo: el panel ya esta en el arbol, asi que su señal ready
	# ya paso; la animacion se lanza aqui y el pivote se fija al final del
	# frame, cuando el contenedor ya le dio tamaño.
	panel.scale = Vector2(0.94, 0.94)
	panel.modulate.a = 0.0
	(func(): panel.pivot_offset = panel.size / 2.0).call_deferred()
	var tw := panel.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.set_parallel()
	tw.tween_property(panel, "scale", Vector2.ONE, 0.22)
	tw.tween_property(panel, "modulate:a", 1.0, 0.18)
	return [velo, col]


## Dialogo modal. `await Estilo.dialogo(...)` devuelve el indice elegido,
## o -1 si se cierra tocando fuera.
static func dialogo(raiz: Control, encabezado: String, texto: String, opciones: Array) -> int:
	var m := modal(raiz)
	var velo: ColorRect = m[0]
	var col: VBoxContainer = m[1]
	col.add_child(titulo(encabezado, 56, true))
	if texto != "":
		col.add_child(etiqueta(texto, 40, TEXTO_SUAVE))
	var res := {"i": -2}
	for i in opciones.size():
		var b := boton(opciones[i], "primario" if i == 0 else "suave", 130)
		b.pressed.connect(func(): res["i"] = i)
		col.add_child(b)
	velo.gui_input.connect(func(e):
		if e is InputEventScreenTouch and e.pressed:
			res["i"] = -1)
	while res["i"] == -2 and is_instance_valid(velo):
		await raiz.get_tree().process_frame
	if is_instance_valid(velo):
		velo.queue_free()
	return res["i"]
