# Aspecto de la interfaz: letra con serifa y GRANDE (se juega en el móvil), paneles oscuros
# translúcidos, botones redondos con iconos y un color de acento por juego (rojo bermellón, latón,
# cian o ámbar). Los tamaños están pensados para una pantalla de 720 de alto.
extends RefCounted

const FUENTE := preload("res://recursos/fuentes/LiberationSerif-Regular.ttf")
const FUENTE_NEGRITA := preload("res://recursos/fuentes/LiberationSerif-Bold.ttf")
const FUENTE_CURSIVA := preload("res://recursos/fuentes/LiberationSerif-Italic.ttf")
const TEXTO := Color(0.96, 0.93, 0.87)
const TEXTO_SUAVE := Color(0.8, 0.76, 0.7)
const RUTA_ICONOS := "res://recursos/iconos/%s.png"

# Tamaños de letra
const LETRA := 34                     # texto normal
const LETRA_PEQUENA := 28             # lo mínimo: avisos secundarios
const LETRA_BOTON := 34
const LETRA_TITULO := 64


static func tema(acento: Color) -> Theme:
	var tema := Theme.new()
	tema.default_font = FUENTE
	tema.default_font_size = LETRA
	var normal := _caja(Color(0.04, 0.035, 0.05, 0.7), acento.darkened(0.3), 2)
	var encima := _caja(Color(0.08, 0.07, 0.09, 0.82), acento, 2)
	var pulsado := _caja(Color(acento.r, acento.g, acento.b, 0.34), acento.lightened(0.2), 3)
	var apagado := _caja(Color(0.04, 0.035, 0.05, 0.4), Color(0.3, 0.3, 0.3, 0.5), 1)
	for estado in [["normal", normal], ["hover", encima], ["pressed", pulsado], ["focus", encima],
			["disabled", apagado], ["hover_pressed", pulsado]]:
		tema.set_stylebox(estado[0], "Button", estado[1])
	tema.set_font_size("font_size", "Button", LETRA_BOTON)
	tema.set_color("font_color", "Button", TEXTO)
	tema.set_color("font_hover_color", "Button", Color.WHITE)
	tema.set_color("font_pressed_color", "Button", Color.WHITE)
	tema.set_color("font_focus_color", "Button", TEXTO)
	tema.set_color("font_disabled_color", "Button", Color(0.6, 0.6, 0.6))
	tema.set_color("icon_normal_color", "Button", TEXTO)
	tema.set_color("icon_hover_color", "Button", Color.WHITE)
	tema.set_color("icon_pressed_color", "Button", Color.WHITE)
	tema.set_color("icon_focus_color", "Button", TEXTO)
	tema.set_constant("h_separation", "Button", 14)
	tema.set_color("font_color", "Label", TEXTO)
	tema.set_color("default_color", "RichTextLabel", TEXTO)
	tema.set_font("normal_font", "RichTextLabel", FUENTE)
	tema.set_font("bold_font", "RichTextLabel", FUENTE_NEGRITA)
	tema.set_font("italics_font", "RichTextLabel", FUENTE_CURSIVA)
	tema.set_stylebox("panel", "PanelContainer", _caja(Color(0.03, 0.025, 0.04, 0.84), acento.darkened(0.4), 2))
	tema.set_stylebox("panel", "Panel", _caja(Color(0.03, 0.025, 0.04, 0.84), acento.darkened(0.4), 2))
	# barras de desplazamiento gruesas (para el dedo)
	var barra := StyleBoxFlat.new()
	barra.bg_color = Color(acento.r, acento.g, acento.b, 0.6)
	barra.set_corner_radius_all(6)
	barra.content_margin_left = 8
	barra.content_margin_right = 8
	tema.set_stylebox("grabber", "VScrollBar", barra)
	tema.set_stylebox("grabber_highlight", "VScrollBar", barra)
	tema.set_stylebox("grabber_pressed", "VScrollBar", barra)
	var fondo_barra := StyleBoxFlat.new()
	fondo_barra.bg_color = Color(0, 0, 0, 0.15)
	fondo_barra.content_margin_left = 8
	fondo_barra.content_margin_right = 8
	tema.set_stylebox("scroll", "VScrollBar", fondo_barra)
	return tema


static func _caja(fondo: Color, borde: Color, grosor: int, radio := 18) -> StyleBoxFlat:
	var caja := StyleBoxFlat.new()
	caja.bg_color = fondo
	caja.border_color = borde
	caja.set_border_width_all(grosor)
	caja.set_corner_radius_all(radio)
	caja.content_margin_left = 24
	caja.content_margin_right = 24
	caja.content_margin_top = 12
	caja.content_margin_bottom = 12
	caja.anti_aliasing = true
	return caja


static func icono(nombre: String) -> Texture2D:
	var ruta := RUTA_ICONOS % nombre
	return load(ruta) if ResourceLoader.exists(ruta) else null


# Botón redondo con un icono (volver, pista, centrar, lupa, cerrar…)
static func boton_icono(nombre: String, acento: Color, tamano := 92.0) -> Button:
	var boton := Button.new()
	boton.icon = icono(nombre)
	boton.expand_icon = true
	boton.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boton.focus_mode = Control.FOCUS_NONE
	boton.custom_minimum_size = Vector2(tamano, tamano)
	var radio := int(tamano / 2.0)
	var margen := tamano * 0.24
	for estado in [["normal", Color(0.04, 0.035, 0.05, 0.62), acento.darkened(0.25), 2],
			["hover", Color(0.08, 0.07, 0.09, 0.78), acento, 2], ["pressed", Color(acento.r, acento.g, acento.b, 0.4), acento.lightened(0.2), 3],
			["hover_pressed", Color(acento.r, acento.g, acento.b, 0.4), acento.lightened(0.2), 3],
			["focus", Color(0.04, 0.035, 0.05, 0.62), acento.darkened(0.25), 2],
			["disabled", Color(0.04, 0.035, 0.05, 0.3), Color(0.3, 0.3, 0.3, 0.5), 1]]:
		var caja := _caja(estado[1], estado[2], estado[3], radio)
		caja.content_margin_left = margen
		caja.content_margin_right = margen
		caja.content_margin_top = margen
		caja.content_margin_bottom = margen
		boton.add_theme_stylebox_override(estado[0], caja)
	for color in ["icon_normal_color", "icon_focus_color"]:
		boton.add_theme_color_override(color, TEXTO)
	for color in ["icon_hover_color", "icon_pressed_color", "icon_hover_pressed_color"]:
		boton.add_theme_color_override(color, Color.WHITE)
	return boton


# Papel envejecido para las notas que se leen (cartas, diarios, placas)
static func papel() -> StyleBoxFlat:
	var caja := StyleBoxFlat.new()
	caja.bg_color = Color(0.91, 0.86, 0.75)
	caja.border_color = Color(0.55, 0.45, 0.32)
	caja.set_border_width_all(2)
	caja.set_corner_radius_all(6)
	caja.content_margin_left = 48
	caja.content_margin_right = 48
	caja.content_margin_top = 36
	caja.content_margin_bottom = 30
	caja.shadow_color = Color(0, 0, 0, 0.5)
	caja.shadow_size = 18
	return caja


static func etiqueta(texto: String, tamano := LETRA, color := TEXTO, fuente: Font = null) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", color)
	if fuente:
		etiqueta.add_theme_font_override("font", fuente)
	return etiqueta


# Sombra suave bajo un texto que va encima de la escena (se lee sobre cualquier fondo)
static func sombra(etiqueta: Label, tamano := 6) -> Label:
	etiqueta.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	etiqueta.add_theme_constant_override("shadow_offset_x", 0)
	etiqueta.add_theme_constant_override("shadow_offset_y", 2)
	etiqueta.add_theme_constant_override("shadow_outline_size", tamano)
	return etiqueta


static func formato_tiempo(segundos: float) -> String:
	if segundos == INF:
		return "—"
	var total := int(round(segundos))
	return "%d:%02d" % [total / 60, total % 60]
