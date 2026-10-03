# Interfaz de una caja. Ocupa poco: botones redondos con iconos en las esquinas (volver, pista,
# centrar), el progreso arriba, el inventario en columna a la izquierda y avisos abajo, con letra
# grande. Encima van las capas que piden atención: la cartela de la entrada, las notas que se leen, el
# visor para examinar objetos en 3D, la confirmación de salida y el resumen final.
extends CanvasLayer

const Estilo := preload("res://scripts/estilo.gd")

const MARGEN := 22.0
const BOTON := 92.0
const RANURA := 104.0

var mesa
var acento := Color.WHITE
var raiz: Control
var interfaz: Control                 # lo que se ve mientras se juega (oculto durante la entrada)
var boton_volver: Button
var boton_pista: Button
var boton_centrar: Button
var progreso: Label
var columna_inventario: VBoxContainer
var ranuras: Array = []               # botones del inventario
var boton_lupa: Button
var aviso: PanelContainer
var aviso_encabezado: Label
var aviso_texto: Label
var capa_nota: Control
var nota_titulo: Label
var nota_texto: Label
var nota_desplazable: ScrollContainer
var capa_salida: Control
var capa_final: Control
var final_titulo: Label
var final_texto: Label
var final_datos: Label
var boton_repetir: Button
var boton_salir: Button
var capa_examen: Control
var cartela: Control
var _vista_examen: SubViewport
var _pivote_examen: Node3D
var _camara_examen: Camera3D
var _distancia_examen := 1.0
var _toques_examen := {}
var _pellizco_examen := 0.0
var _aviso_animacion: Tween
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

	interfaz = Control.new()
	interfaz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	interfaz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(interfaz)

	boton_volver = _boton_esquina("volver", Control.PRESET_TOP_LEFT, Vector2(MARGEN, MARGEN))
	boton_volver.pressed.connect(_pedir_salida)
	boton_pista = _boton_esquina("pista", Control.PRESET_TOP_RIGHT, Vector2(-MARGEN - BOTON, MARGEN))
	boton_pista.pressed.connect(func(): mesa.pedir_pista())
	boton_centrar = _boton_esquina("centrar", Control.PRESET_TOP_RIGHT, Vector2(-MARGEN * 2.0 - BOTON * 2.0, MARGEN))
	boton_centrar.pressed.connect(func(): mesa.centrar())

	progreso = Estilo.sombra(Estilo.etiqueta("", 30, acento.lightened(0.2)))
	progreso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progreso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	interfaz.add_child(progreso)
	colocar(progreso, Control.PRESET_CENTER_TOP, Vector2(-300, MARGEN + 26), Vector2(600, 44))
	poner_progreso(0)

	columna_inventario = VBoxContainer.new()
	columna_inventario.add_theme_constant_override("separation", 12)
	interfaz.add_child(columna_inventario)
	colocar(columna_inventario, Control.PRESET_TOP_LEFT, Vector2(MARGEN, MARGEN + BOTON + 22), Vector2(RANURA, 500))
	boton_lupa = Estilo.boton_icono("lupa", acento, 76)
	boton_lupa.visible = false
	boton_lupa.pressed.connect(func(): mesa.examinar(mesa.seleccionado))
	interfaz.add_child(boton_lupa)

	aviso = PanelContainer.new()
	aviso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aviso.modulate.a = 0.0
	raiz.add_child(aviso)
	var columna_aviso := VBoxContainer.new()
	columna_aviso.add_theme_constant_override("separation", 4)
	columna_aviso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aviso.add_child(columna_aviso)
	aviso_encabezado = Estilo.etiqueta("", Estilo.LETRA_PEQUENA, acento.lightened(0.25), Estilo.FUENTE_NEGRITA)
	aviso_encabezado.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna_aviso.add_child(aviso_encabezado)
	aviso_texto = Estilo.etiqueta("", Estilo.LETRA)
	aviso_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	aviso_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	columna_aviso.add_child(aviso_texto)

	_crear_nota()
	_crear_salida()
	_crear_final()
	_crear_cartela(datos)


func _boton_esquina(nombre: String, ancla: Control.LayoutPreset, desplazamiento: Vector2) -> Button:
	var boton := Estilo.boton_icono(nombre, acento, BOTON)
	interfaz.add_child(boton)
	colocar(boton, ancla, desplazamiento, Vector2(BOTON, BOTON))
	return boton


# Coloca un control respecto a su ancla (esquina, centro de un borde…), sea cual sea la pantalla
static func colocar(control: Control, ancla: Control.LayoutPreset, desplazamiento: Vector2, tamano: Vector2) -> void:
	control.set_anchors_preset(ancla)
	control.offset_left = desplazamiento.x
	control.offset_top = desplazamiento.y
	control.offset_right = desplazamiento.x + tamano.x
	control.offset_bottom = desplazamiento.y + tamano.y


func _ancho() -> float:
	return raiz.get_viewport_rect().size.x if raiz.is_inside_tree() else 1280.0


# ¿Este toque cae sobre la interfaz? (los toques no los frena la interfaz por sí sola)
func toca_interfaz(posicion: Vector2) -> bool:
	if bloquea_todo():
		return true
	if not interfaz.visible:
		return false
	for control in [boton_volver, boton_pista, boton_centrar, boton_lupa] + ranuras:
		if control.is_visible_in_tree() and control.get_global_rect().grow(8).has_point(posicion):
			return true
	return false


func bloquea_todo() -> bool:
	return capa_nota.visible or capa_final.visible or capa_salida.visible or (capa_examen != null and capa_examen.visible)


# --- Entrada: cartela con el título mientras la cámara entra en la habitación --------------------

func _crear_cartela(datos: Dictionary) -> void:
	cartela = Control.new()
	cartela.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cartela.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cartela.visible = false
	raiz.add_child(cartela)
	var columna := VBoxContainer.new()
	columna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.add_theme_constant_override("separation", 6)
	cartela.add_child(columna)
	var titulo := Estilo.sombra(Estilo.etiqueta(datos.get("titulo", ""), 76, acento.lightened(0.3), Estilo.FUENTE_NEGRITA), 10)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(titulo)
	var nombre := Estilo.sombra(Estilo.etiqueta(datos.get("nombre", ""), 40, Estilo.TEXTO, Estilo.FUENTE_CURSIVA), 8)
	nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(nombre)
	var frase := Estilo.sombra(Estilo.etiqueta(datos.get("frase", ""), 30, Estilo.TEXTO_SUAVE, Estilo.FUENTE_CURSIVA), 8)
	frase.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	frase.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	frase.custom_minimum_size = Vector2(minf(900.0, _ancho() - 120.0), 0)
	frase.size = Vector2(frase.custom_minimum_size.x, 0.0)   # medir con su ancho (ver «mensaje»)
	columna.add_child(frase)
	var tamano := columna.get_combined_minimum_size()
	colocar(columna, Control.PRESET_CENTER_BOTTOM, Vector2(-tamano.x / 2.0, -tamano.y - 70.0), tamano)
	var saltar := Estilo.sombra(Estilo.etiqueta("Toca para saltar", Estilo.LETRA_PEQUENA, Estilo.TEXTO_SUAVE, Estilo.FUENTE_CURSIVA))
	saltar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cartela.add_child(saltar)
	colocar(saltar, Control.PRESET_BOTTOM_RIGHT, Vector2(-290, -58), Vector2(270, 40))
	saltar.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT


func empezar_entrada() -> void:
	interfaz.visible = false
	cartela.visible = true
	cartela.modulate.a = 0.0
	var animacion := create_tween()
	animacion.tween_interval(0.5)
	animacion.tween_property(cartela, "modulate:a", 1.0, 1.0)


func mostrar_interfaz() -> void:
	if cartela.visible:
		var salida := create_tween()
		salida.tween_property(cartela, "modulate:a", 0.0, 0.6)
		salida.tween_callback(cartela.hide)
	interfaz.visible = true
	interfaz.modulate.a = 0.0
	create_tween().tween_property(interfaz, "modulate:a", 1.0, 0.6)


# --- Avisos, pistas y progreso -------------------------------------------------------------

func mensaje(texto: String, segundos := 3.4, encabezado := "") -> void:
	aviso_encabezado.text = encabezado
	aviso_encabezado.visible = encabezado != ""
	aviso_texto.text = texto
	var maximo := minf(1000.0, _ancho() - 2.0 * (MARGEN + RANURA + 30.0)) - 48.0
	var natural := _ancho_texto(texto)
	if encabezado != "":
		natural = maxf(natural, _ancho_texto(encabezado))
	# Una etiqueta con ajuste de línea mide su alto con el ancho que tiene en ese momento. Vacía, el
	# contenedor la dejó en 1 px de ancho: medida así, cada letra iría en su línea y el marco saldría
	# de miles de píxeles. Por eso se le da el ancho antes de medir y se reajusta en el cuadro siguiente.
	var ancho := minf(natural, maximo)
	aviso_texto.custom_minimum_size = Vector2(ancho, 0.0)
	aviso_texto.size = Vector2(ancho, aviso_texto.size.y)
	_ajustar_aviso()
	_ajustar_aviso.call_deferred()
	if _aviso_animacion:
		_aviso_animacion.kill()
	_aviso_animacion = create_tween()
	_aviso_animacion.tween_property(aviso, "modulate:a", 1.0, 0.25)
	_aviso_animacion.tween_interval(segundos)
	_aviso_animacion.tween_property(aviso, "modulate:a", 0.0, 0.6)


func _ajustar_aviso() -> void:
	aviso.reset_size()
	var tamano := aviso.get_combined_minimum_size()
	colocar(aviso, Control.PRESET_CENTER_BOTTOM, Vector2(-tamano.x / 2.0, -tamano.y - MARGEN), tamano)


# Ancho que ocuparía el texto en una sola línea (para que los avisos cortos no salgan enormes)
func _ancho_texto(texto: String) -> float:
	var fuente: Font = aviso_texto.get_theme_font("font")
	return fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, Estilo.LETRA).x + 4.0


func mostrar_pista(texto: String, nivel: int, total: int) -> void:
	mensaje(texto, 7.0, "Pista %d de %d" % [nivel, total])


func poner_progreso(hechos: int) -> void:
	var marcas := ""
	for i in _total_pasos:
		marcas += ("●" if i < hechos else "○") + ("  " if i < _total_pasos - 1 else "")
	progreso.text = marcas


func modo_habitacion(_activo: bool) -> void:
	pass


# --- Inventario ------------------------------------------------------------------------------

func poner_inventario(objetos: Array, seleccionado: String) -> void:
	for ranura in ranuras:
		ranura.queue_free()
	ranuras.clear()
	var elegido: Button = null
	for objeto in objetos:
		var boton := Button.new()
		boton.custom_minimum_size = Vector2(RANURA, RANURA)
		boton.focus_mode = Control.FOCUS_NONE
		boton.toggle_mode = true
		boton.button_pressed = objeto.id == seleccionado
		if objeto.icono:
			boton.icon = objeto.icono
			boton.expand_icon = true
			boton.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			for estado in ["normal", "hover", "pressed", "hover_pressed", "focus"]:
				var caja: StyleBoxFlat = boton.get_theme_stylebox(estado).duplicate()
				caja.content_margin_left = 8
				caja.content_margin_right = 8
				caja.content_margin_top = 8
				caja.content_margin_bottom = 8
				boton.add_theme_stylebox_override(estado, caja)
		else:
			boton.text = objeto.nombre.left(1)
		boton.pressed.connect(func(): mesa.seleccionar(objeto.id))
		columna_inventario.add_child(boton)
		ranuras.append(boton)
		if objeto.id == seleccionado:
			elegido = boton
	boton_lupa.visible = elegido != null
	if elegido:
		var indice := ranuras.find(elegido)
		colocar(boton_lupa, Control.PRESET_TOP_LEFT,
			Vector2(MARGEN + RANURA + 14.0, MARGEN + BOTON + 22.0 + indice * (RANURA + 12.0) + (RANURA - 76.0) / 2.0), Vector2(76, 76))


# --- Notas -----------------------------------------------------------------------------------

func _crear_nota() -> void:
	capa_nota = Control.new()
	capa_nota.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	capa_nota.visible = false
	capa_nota.mouse_filter = Control.MOUSE_FILTER_STOP
	capa_nota.gui_input.connect(func(evento: InputEvent):
		if evento is InputEventMouseButton and evento.pressed and evento.button_index == MOUSE_BUTTON_LEFT:
			cerrar_nota())
	raiz.add_child(capa_nota)
	var oscuro := ColorRect.new()
	oscuro.color = Color(0, 0, 0, 0.66)
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
	nota_titulo = Estilo.etiqueta("", 44, Color(0.25, 0.16, 0.1), Estilo.FUENTE_NEGRITA)
	columna.add_child(nota_titulo)
	nota_desplazable = ScrollContainer.new()
	nota_desplazable.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	nota_desplazable.mouse_filter = Control.MOUSE_FILTER_PASS
	columna.add_child(nota_desplazable)
	nota_texto = Estilo.etiqueta("", 36, Color(0.17, 0.11, 0.07), Estilo.FUENTE_CURSIVA)
	nota_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nota_texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nota_desplazable.add_child(nota_texto)
	var cierre := Estilo.etiqueta("Toca para cerrar", 26, Color(0.42, 0.33, 0.24))
	cierre.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	columna.add_child(cierre)


func mostrar_nota(titulo: String, texto: String) -> void:
	nota_titulo.text = titulo
	nota_texto.text = texto
	var ancho := minf(1040.0, _ancho() - 140.0)
	nota_texto.custom_minimum_size = Vector2(ancho, 0)
	nota_texto.reset_size()
	var alto_texto := nota_texto.get_combined_minimum_size().y
	var alto_pantalla := raiz.get_viewport_rect().size.y
	nota_desplazable.custom_minimum_size = Vector2(ancho + 24.0, minf(alto_texto, alto_pantalla - 250.0))
	nota_desplazable.scroll_vertical = 0
	capa_nota.visible = true
	capa_nota.modulate.a = 0.0
	create_tween().tween_property(capa_nota, "modulate:a", 1.0, 0.2)


func cerrar_nota() -> void:
	capa_nota.visible = false


# --- Salir con confirmación -------------------------------------------------------------------

func _crear_salida() -> void:
	capa_salida = Control.new()
	capa_salida.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	capa_salida.visible = false
	capa_salida.mouse_filter = Control.MOUSE_FILTER_STOP
	raiz.add_child(capa_salida)
	var oscuro := ColorRect.new()
	oscuro.color = Color(0, 0, 0, 0.6)
	oscuro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	oscuro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa_salida.add_child(oscuro)
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	capa_salida.add_child(centro)
	var panel := PanelContainer.new()
	centro.add_child(panel)
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 20)
	panel.add_child(columna)
	var titulo := Estilo.etiqueta("¿Salir de esta caja?", 46, acento.lightened(0.25), Estilo.FUENTE_NEGRITA)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(titulo)
	var texto := Estilo.etiqueta("Volverás a la lista de cajas y se perderá lo que llevas hecho.", 32, Estilo.TEXTO)
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.custom_minimum_size = Vector2(620, 0)
	columna.add_child(texto)
	var botones := HBoxContainer.new()
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	botones.add_theme_constant_override("separation", 28)
	columna.add_child(botones)
	var seguir := Button.new()
	seguir.text = "Seguir aquí"
	seguir.custom_minimum_size = Vector2(250, 84)
	seguir.focus_mode = Control.FOCUS_NONE
	seguir.pressed.connect(func(): capa_salida.visible = false)
	botones.add_child(seguir)
	var salir := Button.new()
	salir.text = "Salir"
	salir.custom_minimum_size = Vector2(250, 84)
	salir.focus_mode = Control.FOCUS_NONE
	salir.pressed.connect(func(): mesa.salir.emit())
	botones.add_child(salir)


func _pedir_salida() -> void:
	capa_salida.visible = true
	capa_salida.modulate.a = 0.0
	create_tween().tween_property(capa_salida, "modulate:a", 1.0, 0.18)


# --- Examinar un objeto del inventario en 3D -------------------------------------------------------

func mostrar_examen(nombre: String, modelo: Node3D) -> void:
	cerrar_examen()
	capa_examen = Control.new()
	capa_examen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	capa_examen.mouse_filter = Control.MOUSE_FILTER_STOP
	raiz.add_child(capa_examen)
	var oscuro := ColorRect.new()
	oscuro.color = Color(0.0, 0.0, 0.0, 0.93)
	oscuro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	oscuro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa_examen.add_child(oscuro)
	var contenedor := SubViewportContainer.new()
	contenedor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	contenedor.stretch = true
	contenedor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa_examen.add_child(contenedor)
	_vista_examen = SubViewport.new()
	_vista_examen.own_world_3d = true
	_vista_examen.transparent_bg = true
	_vista_examen.msaa_3d = Viewport.MSAA_2X
	contenedor.add_child(_vista_examen)
	var copia: Node3D = mesa.copia_de(modelo)
	var caja: AABB = mesa.caja_de(copia)
	_pivote_examen = Node3D.new()
	_vista_examen.add_child(_pivote_examen)
	copia.position = -caja.get_center()
	_pivote_examen.add_child(copia)
	_pivote_examen.rotation = Vector3(0.35, -0.5, 0.0)
	_distancia_examen = maxf(caja.size.length(), 0.01) * 2.2
	_camara_examen = Camera3D.new()
	_camara_examen.fov = 32.0
	_camara_examen.near = 0.005
	_camara_examen.position = Vector3(0.0, 0.0, _distancia_examen)
	_vista_examen.add_child(_camara_examen)
	var principal := DirectionalLight3D.new()
	principal.rotation = Vector3(-0.7, 0.5, 0.0)
	principal.light_energy = 1.5
	principal.light_color = Color(1.0, 0.94, 0.86)
	_vista_examen.add_child(principal)
	var relleno := DirectionalLight3D.new()
	relleno.rotation = Vector3(0.4, -2.4, 0.0)
	relleno.light_energy = 0.6
	relleno.light_color = Color(0.7, 0.78, 1.0)
	_vista_examen.add_child(relleno)
	var ambiente := WorldEnvironment.new()
	ambiente.environment = mesa.entorno_estudio()
	_vista_examen.add_child(ambiente)

	var titulo := Estilo.sombra(Estilo.etiqueta(nombre, 46, acento.lightened(0.3), Estilo.FUENTE_NEGRITA), 8)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa_examen.add_child(titulo)
	colocar(titulo, Control.PRESET_CENTER_TOP, Vector2(-400, MARGEN + 16), Vector2(800, 60))
	var ayuda := Estilo.sombra(Estilo.etiqueta("Gira el objeto con el dedo · pellizca para acercarlo", Estilo.LETRA_PEQUENA,
		Estilo.TEXTO_SUAVE, Estilo.FUENTE_CURSIVA))
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ayuda.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa_examen.add_child(ayuda)
	colocar(ayuda, Control.PRESET_CENTER_BOTTOM, Vector2(-450, -MARGEN - 44), Vector2(900, 44))
	var cerrar := Estilo.boton_icono("cerrar", acento, BOTON)
	cerrar.pressed.connect(cerrar_examen)
	capa_examen.add_child(cerrar)
	colocar(cerrar, Control.PRESET_TOP_RIGHT, Vector2(-MARGEN - BOTON, MARGEN), Vector2(BOTON, BOTON))
	capa_examen.modulate.a = 0.0
	create_tween().tween_property(capa_examen, "modulate:a", 1.0, 0.2)
	_toques_examen.clear()


func cerrar_examen() -> void:
	if capa_examen:
		capa_examen.queue_free()
	capa_examen = null
	_vista_examen = null
	_pivote_examen = null
	_toques_examen.clear()


func examinando() -> bool:
	return capa_examen != null and is_instance_valid(capa_examen) and capa_examen.visible


# Girar con un dedo y acercar con dos, mientras se examina un objeto
func _input(evento: InputEvent) -> void:
	if not examinando() or _pivote_examen == null:
		return
	if evento is InputEventScreenTouch:
		if evento.pressed:
			_toques_examen[evento.index] = evento.position
			if _toques_examen.size() == 2:
				_pellizco_examen = _distancia_examen_toques()
		else:
			_toques_examen.erase(evento.index)
	elif evento is InputEventScreenDrag and _toques_examen.has(evento.index):
		_toques_examen[evento.index] = evento.position
		if _toques_examen.size() >= 2:
			var distancia := _distancia_examen_toques()
			if _pellizco_examen > 10.0 and distancia > 10.0:
				_acercar_examen(_pellizco_examen / distancia)
			_pellizco_examen = distancia
		else:
			var escala := 720.0 / maxf(1.0, raiz.get_viewport_rect().size.y)
			_pivote_examen.rotate(Vector3.UP, evento.relative.x * escala * 0.012)
			_pivote_examen.rotate(Vector3.RIGHT, evento.relative.y * escala * 0.012)
	elif evento is InputEventMouseButton and evento.pressed:
		if evento.button_index == MOUSE_BUTTON_WHEEL_UP:
			_acercar_examen(0.9)
		elif evento.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_acercar_examen(1.1)


func _distancia_examen_toques() -> float:
	var lista := _toques_examen.values()
	return (lista[0] as Vector2).distance_to(lista[1]) if lista.size() >= 2 else 0.0


func _acercar_examen(factor: float) -> void:
	if _camara_examen == null:
		return
	var actual := _camara_examen.position.z
	_camara_examen.position.z = clampf(actual * factor, _distancia_examen * 0.4, _distancia_examen * 1.6)


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
	columna.add_theme_constant_override("separation", 18)
	panel.add_child(columna)
	final_titulo = Estilo.etiqueta("", 60, acento.lightened(0.25), Estilo.FUENTE_NEGRITA)
	final_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(final_titulo)
	final_texto = Estilo.etiqueta("", 32, Estilo.TEXTO, Estilo.FUENTE_CURSIVA)
	final_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	final_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(final_texto)
	final_datos = Estilo.etiqueta("", 30, Estilo.TEXTO_SUAVE)
	final_datos.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	final_datos.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	columna.add_child(final_datos)
	var botones := HBoxContainer.new()
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	botones.add_theme_constant_override("separation", 28)
	columna.add_child(botones)
	boton_repetir = Button.new()
	boton_repetir.text = "Otra vez"
	boton_repetir.icon = Estilo.icono("repetir")
	boton_repetir.expand_icon = false
	boton_repetir.add_theme_constant_override("icon_max_width", 40)
	boton_repetir.custom_minimum_size = Vector2(250, 84)
	boton_repetir.focus_mode = Control.FOCUS_NONE
	boton_repetir.pressed.connect(func(): mesa.repetir.emit())
	botones.add_child(boton_repetir)
	boton_salir = Button.new()
	boton_salir.text = "Volver a las cajas"
	boton_salir.custom_minimum_size = Vector2(380, 84)
	boton_salir.focus_mode = Control.FOCUS_NONE
	boton_salir.pressed.connect(func(): mesa.salir.emit())
	botones.add_child(boton_salir)


func mostrar_final(titulo: String, texto: String, resumen: String) -> void:
	final_titulo.text = titulo
	final_texto.text = texto
	final_datos.text = resumen
	var ancho := minf(960.0, _ancho() - 160.0)
	final_texto.custom_minimum_size = Vector2(ancho, 0)
	final_datos.custom_minimum_size = Vector2(ancho, 0)
	interfaz.visible = false
	aviso.modulate.a = 0.0
	capa_final.visible = true
	capa_final.modulate.a = 0.0
	create_tween().tween_property(capa_final, "modulate:a", 1.0, 0.8)


func _material_vineta() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
void fragment() {
	vec2 p = UV - 0.5;
	float sombra = smoothstep(0.38, 0.9, length(p * vec2(1.1, 1.5)));
	COLOR = vec4(vec3(0.0), sombra * 0.5);
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material
