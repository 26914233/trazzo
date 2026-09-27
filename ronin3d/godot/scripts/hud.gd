# HUD: vida de Akira, soldados derrotados, ayuda de controles, versión,
# textos de la historia (con efecto de máquina de escribir) y pausa.
extends CanvasLayer

const Datos := preload("res://scripts/datos.gd")
const VELOCIDAD_TEXTO := 45.0

var fuente: SystemFont
var fuente_negrita: SystemFont
var marcador: Control
var etiqueta_soldados: Label
var etiqueta_ayuda: Label
var etiqueta_version: Label
var texto_antes_de_pausa := false
var capa_texto: Control
var titulo: Label
var subtitulo: Label
var cuerpo: Label
var pie: Label
var capa_pausa: Control
var vida := Datos.VIDA_MAXIMA
var tiempo := 0.0
var tiempo_ayuda := -1.0
var letras := 0.0
var escribiendo := false


class MarcadorVida extends Control:
	var vida := 5
	var maximo := 5
	var fuente: Font
	var color_texto := Color.WHITE
	var color_vida := Color.RED

	func _draw() -> void:
		draw_string_outline(fuente, Vector2(0, 24), "AKIRA", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, 6, Color(0, 0, 0, 0.8))
		draw_string(fuente, Vector2(0, 24), "AKIRA", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, color_texto)
		for i in maximo:
			var centro := Vector2(108 + i * 26, 16)
			var puntos := PackedVector2Array([centro + Vector2(0, -10), centro + Vector2(9, 0),
				centro + Vector2(0, 10), centro + Vector2(-9, 0)])
			var relleno := color_vida if i < vida else Color(0.18, 0.11, 0.13)
			draw_colored_polygon(puntos, relleno)
			var borde := puntos.duplicate()
			borde.append(puntos[0])
			draw_polyline(borde, Color(1, 0.6, 0.5) if i < vida else Color(0.45, 0.3, 0.32), 2.0)


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	fuente = SystemFont.new()
	fuente.font_names = PackedStringArray(["Georgia", "Palatino Linotype", "Book Antiqua", "DejaVu Serif", "Liberation Serif", "serif"])
	fuente_negrita = fuente.duplicate()
	fuente_negrita.font_weight = 700

	marcador = MarcadorVida.new()
	marcador.fuente = fuente
	marcador.color_texto = Datos.CREMA
	marcador.color_vida = Datos.ROJO_VIDA
	marcador.position = Vector2(22, 16)
	marcador.size = Vector2(260, 40)
	marcador.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(marcador)

	# Las etiquetas se anclan a una esquina y se colocan con márgenes respecto a ella
	# (con «position» quedarían fuera de la pantalla).
	etiqueta_soldados = _etiqueta(18, Datos.CREMA)
	_colocar(etiqueta_soldados, Control.PRESET_TOP_RIGHT, Rect2(-320, 18, 298, 30))
	etiqueta_soldados.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	etiqueta_ayuda = _etiqueta(16, Datos.CREMA)
	_colocar(etiqueta_ayuda, Control.PRESET_CENTER_BOTTOM, Rect2(-600, -68, 1200, 30))
	etiqueta_ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta_ayuda.modulate.a = 0.0

	etiqueta_version = _etiqueta(15, Color(0.85, 0.82, 0.72))
	_colocar(etiqueta_version, Control.PRESET_BOTTOM_RIGHT, Rect2(-340, -34, 318, 24))
	etiqueta_version.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	_crear_capa_texto()
	_crear_capa_pausa()


# Ancla el control con «preset» y lo coloca con un rectángulo relativo a ese ancla.
func _colocar(control: Control, preset: Control.LayoutPreset, rectangulo: Rect2) -> void:
	control.set_anchors_preset(preset)
	control.offset_left = rectangulo.position.x
	control.offset_top = rectangulo.position.y
	control.offset_right = rectangulo.position.x + rectangulo.size.x
	control.offset_bottom = rectangulo.position.y + rectangulo.size.y


func _etiqueta(tamano: int, color: Color, negrita := false) -> Label:
	var etiqueta := Label.new()
	etiqueta.add_theme_font_override("font", fuente_negrita if negrita else fuente)
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", color)
	etiqueta.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	etiqueta.add_theme_constant_override("outline_size", 5)
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(etiqueta)
	return etiqueta


func _crear_capa_texto() -> void:
	capa_texto = Control.new()
	capa_texto.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	capa_texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(capa_texto)
	var velo := ColorRect.new()
	velo.color = Color(0.02, 0.02, 0.05, 0.45)
	velo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa_texto.add_child(velo)
	var caja := VBoxContainer.new()
	caja.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	caja.custom_minimum_size = Vector2(820, 0)
	caja.grow_horizontal = Control.GROW_DIRECTION_BOTH
	caja.grow_vertical = Control.GROW_DIRECTION_BOTH
	caja.add_theme_constant_override("separation", 10)
	caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa_texto.add_child(caja)
	titulo = _etiqueta(62, Datos.DORADO, true)
	subtitulo = _etiqueta(22, Color(0.72, 0.72, 0.8))
	cuerpo = _etiqueta(22, Datos.CREMA)
	pie = _etiqueta(17, Datos.DORADO)
	for etiqueta in [titulo, subtitulo, cuerpo, pie]:
		remove_child(etiqueta)
		caja.add_child(etiqueta)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pie.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cuerpo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cuerpo.custom_minimum_size = Vector2(820, 180)
	var fondo_cuerpo := StyleBoxFlat.new()
	fondo_cuerpo.bg_color = Color(0.04, 0.035, 0.07, 0.72)
	fondo_cuerpo.border_color = Color(0.55, 0.45, 0.28)
	fondo_cuerpo.set_border_width_all(2)
	fondo_cuerpo.set_corner_radius_all(6)
	fondo_cuerpo.set_content_margin_all(22)
	cuerpo.add_theme_stylebox_override("normal", fondo_cuerpo)
	capa_texto.visible = false


func _crear_capa_pausa() -> void:
	capa_pausa = Control.new()
	capa_pausa.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	capa_pausa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(capa_pausa)
	var velo := ColorRect.new()
	velo.color = Color(0, 0, 0, 0.6)
	velo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa_pausa.add_child(velo)
	var texto := _etiqueta(64, Datos.DORADO, true)
	remove_child(texto)
	capa_pausa.add_child(texto)
	texto.text = "PAUSA"
	_colocar(texto, Control.PRESET_CENTER, Rect2(-300, -110, 600, 80))
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var indicacion := _etiqueta(22, Datos.CREMA)
	remove_child(indicacion)
	capa_pausa.add_child(indicacion)
	indicacion.text = "ESC o ENTER: continuar      Q: salir del juego"
	_colocar(indicacion, Control.PRESET_CENTER, Rect2(-400, 0, 800, 36))
	indicacion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	capa_pausa.visible = false


# --- API usada por principal.gd ----------------------------------------------------------

func poner_vida(valor: int) -> void:
	vida = valor
	marcador.vida = valor
	marcador.queue_redraw()


func poner_derrotados(cantidad: int, total: int) -> void:
	etiqueta_soldados.text = "Soldados derrotados: %d/%d" % [cantidad, total]


func poner_version(texto: String) -> void:
	etiqueta_version.text = texto


func mostrar_texto(texto_titulo: String, texto_subtitulo: String, parrafos: Array, texto_pie: String) -> void:
	capa_texto.visible = true
	titulo.text = texto_titulo
	subtitulo.text = texto_subtitulo
	subtitulo.visible = texto_subtitulo != ""
	cuerpo.text = "\n\n".join(PackedStringArray(parrafos))
	cuerpo.visible_characters = 0
	letras = 0.0
	escribiendo = true
	pie.text = texto_pie
	pie.visible = false
	marcador.visible = false
	etiqueta_soldados.visible = false


func ocultar_texto() -> void:
	capa_texto.visible = false
	marcador.visible = true
	etiqueta_soldados.visible = true


func texto_completo() -> bool:
	return not escribiendo


func completar_texto() -> void:
	escribiendo = false
	cuerpo.visible_characters = -1


const AYUDA_TECLADO := "WASD: moverse   SHIFT: correr   ESPACIO: saltar   J: atacar   Q/E: girar cámara   rueda: zoom   R/F: inclinar   ESC: pausa"
const AYUDA_TACTIL := "Joystick: moverse (al borde, correr) · Atacar y Saltar: botones\nArrastra el dedo por la pantalla: girar la cámara"


func mostrar_ayuda(tactil := false) -> void:
	# En el móvil la ayuda va arriba: abajo están el joystick y los botones.
	if tactil:
		_colocar(etiqueta_ayuda, Control.PRESET_CENTER_TOP, Rect2(-420, 66, 840, 56))
	else:
		_colocar(etiqueta_ayuda, Control.PRESET_CENTER_BOTTOM, Rect2(-600, -68, 1200, 30))
	etiqueta_ayuda.text = AYUDA_TACTIL if tactil else AYUDA_TECLADO
	tiempo_ayuda = 0.0


# En pausa se oculta el texto de la historia (si lo había) para que no se mezcle con el
# menú de pausa, y el texto deja de escribirse hasta volver.
func poner_pausa(activa: bool) -> void:
	if activa and not capa_pausa.visible:
		texto_antes_de_pausa = capa_texto.visible
		capa_texto.visible = false
	elif not activa and capa_pausa.visible:
		capa_texto.visible = texto_antes_de_pausa
	capa_pausa.visible = activa


func _process(delta: float) -> void:
	if capa_pausa.visible:
		return
	tiempo += delta
	if escribiendo:
		letras += VELOCIDAD_TEXTO * delta
		cuerpo.visible_characters = int(letras)
		if letras >= cuerpo.get_total_character_count():
			completar_texto()
	pie.visible = capa_texto.visible and not escribiendo and int(tiempo * 2.0) % 2 == 0
	if tiempo_ayuda >= 0.0:
		tiempo_ayuda += delta
		etiqueta_ayuda.modulate.a = clampf(minf(tiempo_ayuda / 0.6, (10.0 - tiempo_ayuda) / 1.5), 0.0, 1.0)
