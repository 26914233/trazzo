# Aspecto de la interfaz: letra con serifa, paneles oscuros translúcidos y un color de acento por
# prototipo (rojo bermellón, latón, cian o ámbar).
extends RefCounted

const FUENTE := preload("res://recursos/fuentes/LiberationSerif-Regular.ttf")
const FUENTE_NEGRITA := preload("res://recursos/fuentes/LiberationSerif-Bold.ttf")
const FUENTE_CURSIVA := preload("res://recursos/fuentes/LiberationSerif-Italic.ttf")
const TEXTO := Color(0.95, 0.92, 0.86)
const TEXTO_SUAVE := Color(0.78, 0.74, 0.68)


static func tema(acento: Color) -> Theme:
	var tema := Theme.new()
	tema.default_font = FUENTE
	tema.default_font_size = 26
	var normal := _caja(Color(0.04, 0.035, 0.05, 0.62), acento.darkened(0.35), 2)
	var encima := _caja(Color(0.08, 0.07, 0.09, 0.78), acento, 2)
	var pulsado := _caja(Color(acento.r, acento.g, acento.b, 0.32), acento.lightened(0.2), 2)
	var apagado := _caja(Color(0.04, 0.035, 0.05, 0.35), Color(0.3, 0.3, 0.3, 0.5), 1)
	for estado in [["normal", normal], ["hover", encima], ["pressed", pulsado], ["focus", encima],
			["disabled", apagado], ["hover_pressed", pulsado]]:
		tema.set_stylebox(estado[0], "Button", estado[1])
	tema.set_color("font_color", "Button", TEXTO)
	tema.set_color("font_hover_color", "Button", Color.WHITE)
	tema.set_color("font_pressed_color", "Button", Color.WHITE)
	tema.set_color("font_disabled_color", "Button", Color(0.6, 0.6, 0.6))
	tema.set_color("font_color", "Label", TEXTO)
	tema.set_color("default_color", "RichTextLabel", TEXTO)
	tema.set_font("normal_font", "RichTextLabel", FUENTE)
	tema.set_font("bold_font", "RichTextLabel", FUENTE_NEGRITA)
	tema.set_font("italics_font", "RichTextLabel", FUENTE_CURSIVA)
	tema.set_stylebox("panel", "PanelContainer", _caja(Color(0.03, 0.025, 0.04, 0.78), acento.darkened(0.45), 1))
	tema.set_stylebox("panel", "Panel", _caja(Color(0.03, 0.025, 0.04, 0.78), acento.darkened(0.45), 1))
	return tema


static func _caja(fondo: Color, borde: Color, grosor: int) -> StyleBoxFlat:
	var caja := StyleBoxFlat.new()
	caja.bg_color = fondo
	caja.border_color = borde
	caja.set_border_width_all(grosor)
	caja.set_corner_radius_all(16)
	caja.content_margin_left = 20
	caja.content_margin_right = 20
	caja.content_margin_top = 10
	caja.content_margin_bottom = 10
	caja.anti_aliasing = true
	return caja


# Papel envejecido para las notas que se leen (cartas, diarios, placas)
static func papel() -> StyleBoxFlat:
	var caja := StyleBoxFlat.new()
	caja.bg_color = Color(0.9, 0.85, 0.74)
	caja.border_color = Color(0.55, 0.45, 0.32)
	caja.set_border_width_all(2)
	caja.set_corner_radius_all(6)
	caja.content_margin_left = 44
	caja.content_margin_right = 44
	caja.content_margin_top = 34
	caja.content_margin_bottom = 34
	caja.shadow_color = Color(0, 0, 0, 0.5)
	caja.shadow_size = 18
	return caja


static func etiqueta(texto: String, tamano := 26, color := TEXTO, fuente: Font = null) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", color)
	if fuente:
		etiqueta.add_theme_font_override("font", fuente)
	return etiqueta
