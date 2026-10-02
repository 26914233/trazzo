# Interfaz de una partida: menú, pistas, centrar/volver, progreso por pasos, inventario abajo,
# avisos cortos, notas que se leen en grande y el resumen final con el tiempo y las pistas.
extends CanvasLayer

const Estilo := preload("res://scripts/estilo.gd")

var mesa
var acento := Color.WHITE
var raiz: Control
var boton_menu: Button
var boton_pista: Button
var boton_centrar: Button
var progreso: Label
var barra: HBoxContainer
var ranuras: Array = []               # botones del inventario
var aviso: PanelContainer
var aviso_texto: Label
var capa_nota: Control
var nota_titulo: Label
var nota_texto: Label
var capa_final: Control
var final_titulo: Label
var final_texto: Label
var final_datos: Label
var boton_repetir: Button
var boton_salir: Button
var portada: Control
var _aviso_animacion: Tween
var _salida_pedida := 0.0
var _total_pasos := 0


func configurar(datos: Dictionary, total_pasos: int) -> void:
	acento = datos.acento
	_total_pasos = total_pasos
	layer = 10
	raiz = Control.new()
	raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.theme = Estilo.tema(acento)
	add_child(raiz)

	var vineta := ColorRect.new()
	vineta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vineta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vineta.material = _material_vineta()
	raiz.add_child(vineta)

	boton_menu = _boton("‹  Menú", Control.PRESET_TOP_LEFT, Vector2(28, 24))
	boton_menu.pressed.connect(_pedir_salida)
	boton_pista = _boton("Pista", Control.PRESET_TOP_RIGHT, Vector2(-160, 24))
	boton_pista.pressed.connect(func(): mesa.pedir_pista())
	boton_centrar = _boton("Centrar", Control.PRESET_TOP_RIGHT, Vector2(-312, 24))
	boton_centrar.pressed.connect(func(): mesa.centrar())

	progreso = Estilo.etiqueta("", 30, acento.lightened(0.15))
	progreso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progreso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(progreso)
	colocar(progreso, Control.PRESET_CENTER_TOP, Vector2(-260, 34), Vector2(520, 40))
	poner_progreso(0)

	barra = HBoxContainer.new()
	barra.alignment = BoxContainer.ALIGNMENT_CENTER
	barra.add_theme_constant_override("separation", 14)
	raiz.add_child(barra)
	colocar(barra, Control.PRESET_CENTER_BOTTOM, Vector2(-300, -120), Vector2(600, 96))

	aviso = PanelContainer.new()
	aviso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aviso.modulate.a = 0.0
	raiz.add_child(aviso)
	aviso_texto = Estilo.etiqueta("", 26)
	aviso_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	aviso_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	aviso_texto.custom_minimum_size = Vector2(620, 0)
	aviso.add_child(aviso_texto)

	_crear_nota()
	_crear_final()
	_crear_portada(datos)


func _boton(texto: String, ancla: Control.LayoutPreset, desplazamiento: Vector2) -> Button:
	var boton := Button.new()
	boton.text = texto
	boton.custom_minimum_size = Vector2(136, 64)
	boton.focus_mode = Control.FOCUS_NONE
	raiz.add_child(boton)
	colocar(boton, ancla, desplazamiento, Vector2(136, 64))
	return boton


# Coloca un control respecto a su ancla (esquina, centro de un borde…), sea cual sea la pantalla
static func colocar(control: Control, ancla: Control.LayoutPreset, desplazamiento: Vector2, tamano: Vector2) -> void:
	control.set_anchors_preset(ancla)
	control.offset_left = desplazamiento.x
	control.offset_top = desplazamiento.y
	control.offset_right = desplazamiento.x + tamano.x
	control.offset_bottom = desplazamiento.y + tamano.y


# ¿Este toque cae sobre la interfaz? (los toques no los frena la interfaz por sí sola)
func toca_interfaz(posicion: Vector2) -> bool:
	if capa_nota.visible or capa_final.visible:
		return true
	for control in [boton_menu, boton_pista, boton_centrar] + ranuras:
		if control.is_visible_in_tree() and control.get_global_rect().grow(6).has_point(posicion):
			return true
	return false


func bloquea_todo() -> bool:
	return capa_nota.visible or capa_final.visible


# --- Avisos, pistas y progreso -------------------------------------------------------------

func mensaje(texto: String, segundos := 3.4) -> void:
	aviso_texto.text = texto
	var tamano := aviso.get_combined_minimum_size()
	var alto_barra := 120.0 if not ranuras.is_empty() else 0.0
	colocar(aviso, Control.PRESET_CENTER_BOTTOM, Vector2(-tamano.x / 2.0, -tamano.y - 34.0 - alto_barra), tamano)
	if _aviso_animacion:
		_aviso_animacion.kill()
	_aviso_animacion = create_tween()
	_aviso_animacion.tween_property(aviso, "modulate:a", 1.0, 0.25)
	_aviso_animacion.tween_interval(segundos)
	_aviso_animacion.tween_property(aviso, "modulate:a", 0.0, 0.6)


func mostrar_pista(texto: String, nivel: int, total: int) -> void:
	mensaje("Pista %d de %d · %s" % [nivel, total, texto], 6.0)


func poner_progreso(hechos: int) -> void:
	var marcas := ""
	for i in _total_pasos:
		marcas += ("●" if i < hechos else "○") + (" " if i < _total_pasos - 1 else "")
	progreso.text = marcas


func modo_habitacion(activo: bool) -> void:
	boton_centrar.text = "Volver" if activo else "Centrar"


# --- Inventario ------------------------------------------------------------------------------

func poner_inventario(objetos: Array, seleccionado: String) -> void:
	for ranura in ranuras:
		ranura.queue_free()
	ranuras.clear()
	for objeto in objetos:
		var boton := Button.new()
		boton.custom_minimum_size = Vector2(96, 96)
		boton.focus_mode = Control.FOCUS_NONE
		boton.toggle_mode = true
		boton.button_pressed = objeto.id == seleccionado
		boton.tooltip_text = objeto.nombre
		if objeto.icono:
			boton.icon = objeto.icono
			boton.expand_icon = true
			boton.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		else:
			boton.text = objeto.nombre.left(1)
		boton.pressed.connect(func(): mesa.seleccionar(objeto.id))
		barra.add_child(boton)
		ranuras.append(boton)
	var ancho := maxf(96.0, ranuras.size() * 110.0)
	colocar(barra, Control.PRESET_CENTER_BOTTOM, Vector2(-ancho / 2.0, -120), Vector2(ancho, 96))


# --- Notas -----------------------------------------------------------------------------------

func _crear_nota() -> void:
	capa_nota = Control.new()
	capa_nota.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	capa_nota.visible = false
	capa_nota.mouse_filter = Control.MOUSE_FILTER_STOP
	capa_nota.gui_input.connect(func(evento: InputEvent):
		if (evento is InputEventMouseButton and evento.pressed) or (evento is InputEventScreenTouch and evento.pressed):
			cerrar_nota())
	raiz.add_child(capa_nota)
	var oscuro := ColorRect.new()
	oscuro.color = Color(0, 0, 0, 0.6)
	oscuro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	oscuro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa_nota.add_child(oscuro)
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa_nota.add_child(centro)
	var hoja := PanelContainer.new()
	hoja.add_theme_stylebox_override("panel", Estilo.papel())
	hoja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	centro.add_child(hoja)
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 14)
	columna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hoja.add_child(columna)
	nota_titulo = Estilo.etiqueta("", 34, Color(0.25, 0.16, 0.1), Estilo.FUENTE_NEGRITA)
	columna.add_child(nota_titulo)
	nota_texto = Estilo.etiqueta("", 28, Color(0.18, 0.12, 0.08), Estilo.FUENTE_CURSIVA)
	nota_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nota_texto.custom_minimum_size = Vector2(760, 0)
	columna.add_child(nota_texto)
	var cierre := Estilo.etiqueta("Toca para cerrar", 20, Color(0.4, 0.32, 0.24))
	cierre.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	columna.add_child(cierre)


func mostrar_nota(titulo: String, texto: String) -> void:
	nota_titulo.text = titulo
	nota_texto.text = texto
	capa_nota.visible = true
	capa_nota.modulate.a = 0.0
	create_tween().tween_property(capa_nota, "modulate:a", 1.0, 0.2)


func cerrar_nota() -> void:
	capa_nota.visible = false


# --- Final -----------------------------------------------------------------------------------

func _crear_final() -> void:
	capa_final = Control.new()
	capa_final.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	capa_final.visible = false
	capa_final.mouse_filter = Control.MOUSE_FILTER_STOP
	raiz.add_child(capa_final)
	var oscuro := ColorRect.new()
	oscuro.color = Color(0, 0, 0, 0.55)
	oscuro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	oscuro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa_final.add_child(oscuro)
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	capa_final.add_child(centro)
	var panel := PanelContainer.new()
	centro.add_child(panel)
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 16)
	panel.add_child(columna)
	final_titulo = Estilo.etiqueta("", 52, acento.lightened(0.25), Estilo.FUENTE_NEGRITA)
	final_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(final_titulo)
	final_texto = Estilo.etiqueta("", 26, Estilo.TEXTO, Estilo.FUENTE_CURSIVA)
	final_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	final_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	final_texto.custom_minimum_size = Vector2(720, 0)
	columna.add_child(final_texto)
	final_datos = Estilo.etiqueta("", 26, Estilo.TEXTO_SUAVE)
	final_datos.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(final_datos)
	var botones := HBoxContainer.new()
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	botones.add_theme_constant_override("separation", 24)
	columna.add_child(botones)
	boton_repetir = Button.new()
	boton_repetir.text = "Otra vez"
	boton_repetir.custom_minimum_size = Vector2(200, 66)
	boton_repetir.pressed.connect(func(): mesa.repetir.emit())
	botones.add_child(boton_repetir)
	boton_salir = Button.new()
	boton_salir.text = "Volver al menú"
	boton_salir.custom_minimum_size = Vector2(260, 66)
	boton_salir.pressed.connect(func(): mesa.salir.emit())
	botones.add_child(boton_salir)


func mostrar_final(titulo: String, texto: String, resumen: String) -> void:
	final_titulo.text = titulo
	final_texto.text = texto
	final_datos.text = resumen
	for control in [boton_menu, boton_pista, boton_centrar, barra]:
		control.visible = false
	capa_final.visible = true
	capa_final.modulate.a = 0.0
	create_tween().tween_property(capa_final, "modulate:a", 1.0, 0.8)


# --- Portada (título y frase al empezar) -------------------------------------------------------

func _crear_portada(datos: Dictionary) -> void:
	portada = VBoxContainer.new()
	portada.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portada.add_theme_constant_override("separation", 8)
	raiz.add_child(portada)
	var titulo := Estilo.etiqueta(datos.titulo, 64, acento.lightened(0.3), Estilo.FUENTE_NEGRITA)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portada.add_child(titulo)
	var frase := Estilo.etiqueta(datos.frase, 28, Estilo.TEXTO, Estilo.FUENTE_CURSIVA)
	frase.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	frase.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	frase.custom_minimum_size = Vector2(820, 0)
	portada.add_child(frase)
	var tamano := portada.get_combined_minimum_size()
	colocar(portada, Control.PRESET_CENTER, Vector2(-tamano.x / 2.0, -tamano.y / 2.0 - 120.0), tamano)
	var animacion := create_tween()
	animacion.tween_interval(3.2)
	animacion.tween_property(portada, "modulate:a", 0.0, 1.2)
	animacion.tween_callback(portada.hide)


# --- Salir con confirmación -------------------------------------------------------------------

func _pedir_salida() -> void:
	var ahora := Time.get_ticks_msec() * 0.001
	if ahora - _salida_pedida < 2.5:
		mesa.salir.emit()
		return
	_salida_pedida = ahora
	mensaje("Toca «Menú» otra vez para salir (se pierde lo avanzado).", 2.2)


func _material_vineta() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
void fragment() {
	vec2 p = UV - 0.5;
	float sombra = smoothstep(0.35, 0.85, length(p * vec2(1.15, 1.6)));
	float grano = fract(sin(dot(floor(FRAGCOORD.xy), vec2(12.9898, 78.233)) + TIME * 0.0) * 43758.5453);
	COLOR = vec4(vec3(grano * 0.04), sombra * 0.55);
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material
