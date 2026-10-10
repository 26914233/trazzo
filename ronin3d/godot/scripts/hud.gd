# HUD: vida, espíritu y monedas de Akira, soldados derrotados, ayuda de controles, versión,
# avisos breves, textos de la historia (con efecto de máquina de escribir) y pausa.
extends CanvasLayer

const Datos := preload("res://scripts/datos.gd")
const VisualModelo := preload("res://scripts/visual_modelo.gd")
const Apariencias := preload("res://scripts/apariencias_akira.gd")
const Partida := preload("res://scripts/partida.gd")
const VELOCIDAD_TEXTO := 45.0

var fuente: SystemFont
var fuente_negrita: SystemFont
var marcador: Control
var etiqueta_soldados: Label
var barra_jefe: BarraJefe
var etiqueta_ayuda: Label
var etiqueta_version: Label
var texto_version := ""
var tiempo_fps := 0.0
var indicacion_pausa: Label
var boton_animacion: Label            # en la pausa: cambia la animación anime / suave
var boton_galeria: Label              # en la pausa: abre la galería de criaturas (prueba de rendimiento)
var boton_apariencia: Label           # en la pausa: el sastre enseña el siguiente aspecto de Akira
var boton_comprar: Label              # en la pausa: compra el aspecto que enseña el sastre
var aviso_interaccion: Label          # junto al jizō: qué hacer (en el móvil, se toca)
var texto_interaccion := ""
var etiqueta_mensaje: Label
var tiempo_mensaje := 0.0
var en_tactil := false
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


# Barra del jefe, arriba en el centro (como la vida del objetivo fijado en EthrA).
class BarraJefe extends Control:
	var nombre := ""
	var fraccion := 1.0
	var mostrada := 1.0
	var fuente: Font

	func _draw() -> void:
		var barra := Rect2(0, 22, size.x, 12)
		draw_rect(barra.grow(3.0), Color(0, 0, 0, 0.75))
		draw_rect(barra, Color(0.18, 0.08, 0.07))
		draw_rect(Rect2(barra.position, Vector2(barra.size.x * mostrada, barra.size.y)), Color(0.95, 0.85, 0.6))
		draw_rect(Rect2(barra.position, Vector2(barra.size.x * fraccion, barra.size.y)), Color(0.78, 0.16, 0.12))
		draw_string_outline(fuente, Vector2(0, 16), nombre, HORIZONTAL_ALIGNMENT_CENTER, size.x, 20, 5, Color(0, 0, 0, 0.85))
		draw_string(fuente, Vector2(0, 16), nombre, HORIZONTAL_ALIGNMENT_CENTER, size.x, 20, Color(0.95, 0.9, 0.8))


class MarcadorVida extends Control:
	var vida := 5
	var maximo := 5
	var espiritu := 0.0
	var aguante := 1.0                # 0-1, barra amarilla (como el «Aguante» de EthrA)
	var arma := "Katana"
	var latido := 0.0
	var monedas := 0
	var brillo_moneda := 0.0          # destello del contador al ganar monedas
	var color_moneda := Color(0.83, 0.58, 0.31)
	var fuente: Font
	var color_texto := Color.WHITE
	var color_vida := Color.RED

	func _draw() -> void:
		# Barra de espíritu bajo los rombos: dorada; llena, late y anuncia el corte de luna.
		var barra := Rect2(108 - 9, 34, 26 * maximo - 8, 7)
		draw_rect(barra.grow(2.0), Color(0, 0, 0, 0.7))
		draw_rect(barra, Color(0.16, 0.13, 0.1))
		var lleno := Rect2(barra.position, Vector2(barra.size.x * espiritu, barra.size.y))
		var dorado := Color(0.89, 0.73, 0.38)
		if espiritu >= 1.0:
			dorado = dorado.lerp(Color(1.0, 0.97, 0.85), 0.5 + 0.5 * sin(latido * 6.0))
		draw_rect(lleno, dorado)
		if espiritu >= 1.0:
			draw_string_outline(fuente, Vector2(barra.end.x + 8, 42), "LUNA", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, 4, Color(0, 0, 0, 0.8))
			draw_string(fuente, Vector2(barra.end.x + 8, 42), "LUNA", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, dorado)
		# Aguante bajo el espíritu: lo gastan la esquiva y el ataque cargado.
		var barra_aguante := Rect2(barra.position + Vector2(0, 11), Vector2(barra.size.x, 5))
		draw_rect(barra_aguante.grow(2.0), Color(0, 0, 0, 0.7))
		draw_rect(barra_aguante, Color(0.16, 0.13, 0.1))
		draw_rect(Rect2(barra_aguante.position, Vector2(barra_aguante.size.x * aguante, 5)), Color(0.95, 0.78, 0.25))
		# Arma en la mano
		draw_string_outline(fuente, Vector2(barra.end.x + 8, 58), arma, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, 4, Color(0, 0, 0, 0.8))
		draw_string(fuente, Vector2(barra.end.x + 8, 58), arma, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.85, 0.9, 1.0))
		# Monedas: un mon de cobre (con su agujero cuadrado) y la cantidad
		var centro_moneda := Vector2(9, 64)
		var cobre := color_moneda.lerp(Color(1.0, 0.95, 0.75), brillo_moneda)
		draw_circle(centro_moneda, 11.0, Color(0, 0, 0, 0.75))
		draw_circle(centro_moneda, 9.0, cobre)
		draw_arc(centro_moneda, 9.0, 0.0, TAU, 20, cobre.darkened(0.35), 1.5)
		draw_rect(Rect2(centro_moneda - Vector2(3, 3), Vector2(6, 6)), Color(0.1, 0.07, 0.05))
		var cantidad := "%d" % monedas
		var tamano := 20 + int(brillo_moneda * 4.0)
		draw_string_outline(fuente, Vector2(26, 71), cantidad, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, 5, Color(0, 0, 0, 0.8))
		draw_string(fuente, Vector2(26, 71), cantidad, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, color_texto.lerp(cobre, 0.5))
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


# Ancho de los textos: cabe en la pantalla vertical (720 px de ancho) con margen.
const ANCHO_UTIL := 660.0


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
	marcador.color_moneda = Datos.COBRE
	marcador.position = Vector2(22, 16)
	marcador.size = Vector2(300, 82)
	marcador.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(marcador)

	# Las etiquetas se anclan a una esquina y se colocan con márgenes respecto a ella
	# (con «position» quedarían fuera de la pantalla).
	etiqueta_soldados = _etiqueta(18, Datos.CREMA)
	_colocar(etiqueta_soldados, Control.PRESET_TOP_RIGHT, Rect2(-320, 18, 298, 30))
	etiqueta_soldados.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	# En vertical la ayuda va arriba, bajo el marcador: abajo están los botones táctiles.
	etiqueta_ayuda = _etiqueta(16, Datos.CREMA)
	_colocar(etiqueta_ayuda, Control.PRESET_CENTER_TOP, Rect2(-ANCHO_UTIL / 2.0, 104, ANCHO_UTIL, 64))
	etiqueta_ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta_ayuda.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiqueta_ayuda.modulate.a = 0.0

	etiqueta_version = _etiqueta(15, Color(0.85, 0.82, 0.72))
	_colocar(etiqueta_version, Control.PRESET_BOTTOM_RIGHT, Rect2(-340, -34, 318, 24))
	etiqueta_version.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	aviso_interaccion = _etiqueta(20, Datos.CREMA)
	_colocar(aviso_interaccion, Control.PRESET_CENTER_TOP, Rect2(-ANCHO_UTIL / 2.0, 230, ANCHO_UTIL, 44))
	aviso_interaccion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	aviso_interaccion.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var marco_aviso := StyleBoxFlat.new()
	marco_aviso.bg_color = Color(0.08, 0.07, 0.12, 0.8)
	marco_aviso.border_color = Datos.DORADO
	marco_aviso.set_border_width_all(2)
	marco_aviso.set_corner_radius_all(8)
	aviso_interaccion.add_theme_stylebox_override("normal", marco_aviso)
	aviso_interaccion.visible = false

	etiqueta_mensaje = _etiqueta(20, Datos.DORADO)
	_colocar(etiqueta_mensaje, Control.PRESET_CENTER_TOP, Rect2(-ANCHO_UTIL / 2.0, 176, ANCHO_UTIL, 32))
	etiqueta_mensaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta_mensaje.modulate.a = 0.0

	barra_jefe = BarraJefe.new()
	barra_jefe.fuente = fuente
	barra_jefe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(barra_jefe)
	_colocar(barra_jefe, Control.PRESET_CENTER_TOP, Rect2(-ANCHO_UTIL / 2.0 + 30, 206, ANCHO_UTIL - 60, 40))
	barra_jefe.visible = false

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
	caja.custom_minimum_size = Vector2(ANCHO_UTIL, 0)
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
	cuerpo.custom_minimum_size = Vector2(ANCHO_UTIL, 180)
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
	indicacion_pausa = _etiqueta(22, Datos.CREMA)
	remove_child(indicacion_pausa)
	capa_pausa.add_child(indicacion_pausa)
	_colocar(indicacion_pausa, Control.PRESET_CENTER, Rect2(-ANCHO_UTIL / 2.0, 0, ANCHO_UTIL, 36))
	indicacion_pausa.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boton_animacion = _etiqueta(20, Datos.CREMA)
	remove_child(boton_animacion)
	capa_pausa.add_child(boton_animacion)
	_colocar(boton_animacion, Control.PRESET_CENTER, Rect2(-300, 64, 600, 46))
	boton_animacion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boton_animacion.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var marco := StyleBoxFlat.new()
	marco.bg_color = Color(0.08, 0.07, 0.12, 0.85)
	marco.border_color = Datos.DORADO
	marco.set_border_width_all(2)
	marco.set_corner_radius_all(8)
	boton_animacion.add_theme_stylebox_override("normal", marco)
	boton_galeria = _etiqueta(20, Datos.CREMA)
	remove_child(boton_galeria)
	capa_pausa.add_child(boton_galeria)
	_colocar(boton_galeria, Control.PRESET_CENTER, Rect2(-300, 124, 600, 46))
	boton_galeria.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boton_galeria.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	boton_galeria.add_theme_stylebox_override("normal", marco)
	boton_apariencia = _etiqueta(20, Datos.CREMA)
	remove_child(boton_apariencia)
	capa_pausa.add_child(boton_apariencia)
	_colocar(boton_apariencia, Control.PRESET_CENTER, Rect2(-300, 184, 600, 46))
	boton_apariencia.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boton_apariencia.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	boton_apariencia.add_theme_stylebox_override("normal", marco)
	boton_comprar = _etiqueta(20, Datos.DORADO)
	remove_child(boton_comprar)
	capa_pausa.add_child(boton_comprar)
	_colocar(boton_comprar, Control.PRESET_CENTER, Rect2(-300, 244, 600, 46))
	boton_comprar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boton_comprar.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	boton_comprar.add_theme_stylebox_override("normal", marco)
	boton_comprar.visible = false
	capa_pausa.visible = false


# --- API usada por principal.gd ----------------------------------------------------------

func poner_vida(valor: int) -> void:
	vida = valor
	marcador.vida = valor
	marcador.queue_redraw()


func poner_derrotados(cantidad: int, total: int) -> void:
	etiqueta_soldados.text = "Enemigos: %d/%d" % [cantidad, total]


func poner_monedas(total: int, con_destello := true) -> void:
	marcador.monedas = total
	if con_destello:
		marcador.brillo_moneda = 1.0
	marcador.queue_redraw()


func poner_vida_maxima(maxima: int) -> void:
	marcador.maximo = maxima
	marcador.queue_redraw()


# Junto al jizō: el aviso dice qué cuesta y cómo rezar (ENTER, B en el mando o tocarlo).
func poner_aviso_interaccion(texto: String) -> void:
	texto_interaccion = texto
	aviso_interaccion.visible = texto != ""
	if texto != "":
		aviso_interaccion.text = ("Toca aquí · " if en_tactil else "ENTER · ") + texto


# El sastre en la pausa: qué aspecto enseña, si es suyo o cuánto cuesta, y el botón de comprar.
func poner_apariencia() -> void:
	var id: String = Apariencias.mostrada
	var nombre: String = Apariencias.datos(id).nombre
	var como := "toca aquí: siguiente" if en_tactil else "V: siguiente"
	if Apariencias.mostrada_bloqueada():
		var precio := Partida.precio(id)
		boton_apariencia.text = "Sastre · %s: %d mon · %s" % [nombre, precio, como]
		boton_comprar.visible = true
		if Partida.monedas >= precio:
			boton_comprar.text = "Comprar por %d mon (tienes %d) · %s" % [precio, Partida.monedas, "toca aquí" if en_tactil else "B"]
		else:
			boton_comprar.text = "Te faltan %d mon (tienes %d)" % [precio - Partida.monedas, Partida.monedas]
	else:
		boton_apariencia.text = "Sastre · %s: puesto · %s" % [nombre, como]
		boton_comprar.visible = false


func poner_version(texto: String) -> void:
	texto_version = texto
	etiqueta_version.text = texto


func poner_jefe(nombre: String, fraccion: float) -> void:
	barra_jefe.visible = fraccion >= 0.0
	if fraccion < 0.0:
		return
	barra_jefe.nombre = nombre
	barra_jefe.fraccion = fraccion
	barra_jefe.queue_redraw()


func poner_aguante(valor: float) -> void:
	marcador.aguante = clampf(valor / 100.0, 0.0, 1.0)
	marcador.queue_redraw()


func poner_arma(nombre: String) -> void:
	marcador.arma = nombre
	marcador.queue_redraw()


func poner_espiritu(valor: float) -> void:
	marcador.espiritu = valor
	marcador.queue_redraw()


func mostrar_mensaje(texto: String, segundos := 2.4) -> void:
	etiqueta_mensaje.text = texto
	tiempo_mensaje = segundos


func poner_estilo_animacion() -> void:
	var nombre := "anime (12 poses por segundo)" if VisualModelo.estilo_anime else "suave"
	var como := "toca aquí para cambiar" if en_tactil else "T para cambiar"
	boton_animacion.text = "Animación: %s · %s" % [nombre, como]


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


const AYUDA_TECLADO := "WASD: moverse · SHIFT: correr · ESPACIO: saltar · J: atacar (mantén: cargado) · C: esquivar · I: arma · TAB: fijar · K: iaidō (mantén y suelta al «!») · L: corte de luna · Q/E: cámara · T: animación · ESC: pausa"
const AYUDA_TACTIL := "Joystick: moverse · «Atacar» encadena cortes; mantenlo para cargar\n«Iai»: suéltalo justo al «!» · «Esquivar» · «Arma» cambia de arma · «Fijar» cambia de objetivo"


func mostrar_ayuda(tactil := false) -> void:
	en_tactil = tactil
	if texto_interaccion != "":
		poner_aviso_interaccion(texto_interaccion)
	# En el móvil la ayuda va arriba: abajo están el joystick y los botones.
	# En el móvil, además, con letra más grande: la pantalla es pequeña.
	# La ayuda siempre arriba, bajo el marcador, y en varias líneas (abajo van los botones).
	_colocar(etiqueta_ayuda, Control.PRESET_CENTER_TOP, Rect2(-ANCHO_UTIL / 2.0, 104, ANCHO_UTIL, 96))
	etiqueta_ayuda.add_theme_font_size_override("font_size", 20 if tactil else 16)
	etiqueta_ayuda.text = AYUDA_TACTIL if tactil else AYUDA_TECLADO
	tiempo_ayuda = 0.0


# En pausa se oculta el texto de la historia (si lo había) para que no se mezcle con el
# menú de pausa, y el texto deja de escribirse hasta volver.
func poner_pausa(activa: bool, tactil := false) -> void:
	en_tactil = tactil
	indicacion_pausa.text = "Toca la pantalla para continuar      «Atrás»: salir del juego" if tactil \
		else "ESC o ENTER: continuar      Q: salir del juego"
	boton_galeria.text = "Galería de criaturas (prueba) · " + ("toca aquí" if tactil else "G")
	poner_estilo_animacion()
	poner_apariencia()
	if activa and not capa_pausa.visible:
		texto_antes_de_pausa = capa_texto.visible
		capa_texto.visible = false
	elif not activa and capa_pausa.visible:
		capa_texto.visible = texto_antes_de_pausa
	capa_pausa.visible = activa


func _process(delta: float) -> void:
	if barra_jefe.visible and barra_jefe.mostrada > barra_jefe.fraccion:
		# El daño reciente se ve en claro y baja despacio, como en los juegos de acción.
		barra_jefe.mostrada = maxf(barra_jefe.fraccion, barra_jefe.mostrada - delta * 0.6)
		barra_jefe.queue_redraw()
	if capa_pausa.visible:
		return
	tiempo += delta
	if marcador.espiritu >= 1.0:
		marcador.latido = tiempo
		marcador.queue_redraw()
	if marcador.brillo_moneda > 0.0:
		marcador.brillo_moneda = maxf(0.0, marcador.brillo_moneda - delta * 3.0)
		marcador.queue_redraw()
	if tiempo_mensaje > 0.0:
		tiempo_mensaje -= delta
		etiqueta_mensaje.modulate.a = clampf(tiempo_mensaje / 0.5, 0.0, 1.0)
	# FPS junto a la versión, para las pruebas en el móvil (meta: 30 o más).
	tiempo_fps += delta
	if tiempo_fps >= 0.5:
		tiempo_fps = 0.0
		etiqueta_version.text = "%s · %d FPS" % [texto_version, Engine.get_frames_per_second()]
	if escribiendo:
		letras += VELOCIDAD_TEXTO * delta
		cuerpo.visible_characters = int(letras)
		if letras >= cuerpo.get_total_character_count():
			completar_texto()
	pie.visible = capa_texto.visible and not escribiendo and int(tiempo * 2.0) % 2 == 0
	if tiempo_ayuda >= 0.0:
		tiempo_ayuda += delta
		etiqueta_ayuda.modulate.a = clampf(minf(tiempo_ayuda / 0.6, (10.0 - tiempo_ayuda) / 1.5), 0.0, 1.0)
