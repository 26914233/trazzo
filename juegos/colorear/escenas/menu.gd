# Menu: categorias arriba y cuadricula de laminas. "Mis obras" primero si hay.
extends Control

static var categoria_actual := ""

var _rejilla := GridContainer.new()
var _ids: Array = []
var _chips := HBoxContainer.new()


func _ready() -> void:
	var col := Estilo.pantalla(self)
	col.add_theme_constant_override("separation", 28)
	var cabecera := HBoxContainer.new()
	var hueco := Control.new()
	hueco.custom_minimum_size.x = 112
	cabecera.add_child(hueco)
	var titulo := Estilo.titulo(str(ProjectSettings.get_setting("application/config/name")), 110, true)
	titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cabecera.add_child(titulo)
	var engranaje := Estilo.boton("⚙", "suave", 112)
	engranaje.custom_minimum_size.x = 112
	engranaje.add_theme_font_size_override("font_size", 56)
	engranaje.pressed.connect(abrir_ajustes)
	cabecera.add_child(engranaje)
	col.add_child(cabecera)
	col.add_child(Estilo.etiqueta("%d láminas para colorear" % Laminas.total(), 40, Estilo.TEXTO_SUAVE))
	col.add_child(_lamina_del_dia())
	col.add_child(_misterio())

	var desliza := ScrollContainer.new()
	desliza.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	desliza.custom_minimum_size.y = 120
	_chips.add_theme_constant_override("separation", 16)
	desliza.add_child(_chips)
	col.add_child(desliza)

	var lista := ScrollContainer.new()
	lista.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lista.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_rejilla.columns = 3
	_rejilla.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rejilla.add_theme_constant_override("h_separation", 24)
	_rejilla.add_theme_constant_override("v_separation", 24)
	lista.add_child(_rejilla)
	col.add_child(lista)

	var ids := ["obras"] if not Obras.lista().is_empty() else []
	for c in Laminas.categorias:
		ids.append(c["id"])
	if categoria_actual == "" or not categoria_actual in ids:
		categoria_actual = ids[0]
	for id in ids:
		var nombre: String = "Mis obras" if id == "obras" else Laminas.categoria(id)["nombre"]
		var chip := Estilo.boton(nombre, "primario" if id == categoria_actual else "normal", 104)
		chip.add_theme_font_size_override("font_size", 38)
		chip.custom_minimum_size.x = 0
		chip.pressed.connect(func():
			categoria_actual = id
			Estilo.ir(self, "menu"))
		_chips.add_child(chip)
	_llenar()


func _llenar() -> void:
	var ids: Array
	if categoria_actual == "obras":
		ids = Obras.lista()
	else:
		var todas: Array = Laminas.categoria(categoria_actual)["laminas"].map(func(l): return l["id"])
		var oculta := Laminas.misterio(Diario.hoy())
		if not Diario.revelado(oculta):
			todas.erase(oculta)        # el misterio de la semana no se destapa en su categoria
		ids = Obras.filtrar(todas, bool(Ajustes.valor("ocultar_terminadas")))
		if ids.is_empty() and not todas.is_empty():
			var aviso := Estilo.etiqueta("¡Terminaste todas las láminas de esta categoría!", 40, Estilo.TEXTO_SUAVE)
			aviso.custom_minimum_size.x = 900
			_rejilla.add_child(aviso)
	_ids = ids
	for id in ids:
		_rejilla.add_child(_miniatura(id))


func ids_en_rejilla() -> Array:
	return _ids


## Tarjeta del misterio de la semana: "?" hasta empezarla; el nombre, al terminarla.
func _misterio() -> Control:
	var id := Laminas.misterio(Diario.hoy())
	var t := Estilo.tarjeta(150, Estilo.SUPERFICIE, func():
		preload("res://escenas/colorear.gd").lamina_id = id
		Estilo.ir(self, "colorear"))
	var fila := HBoxContainer.new()
	fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila.size_flags_vertical = Control.SIZE_EXPAND_FILL
	(t[1] as VBoxContainer).add_child(fila)
	var revelada := Diario.revelado(id)
	if Obras.tiene(id):
		var img := TextureRect.new()
		img.texture = Obras.textura_mini(id)
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img.custom_minimum_size = Vector2(110, 90)
		img.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fila.add_child(img)
	else:
		var signo := Estilo.titulo("?", 80, true)
		signo.custom_minimum_size.x = 110
		signo.add_theme_color_override("font_color", Estilo.PRIMARIO)
		signo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fila.add_child(signo)
	var textos := VBoxContainer.new()
	textos.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textos.alignment = BoxContainer.ALIGNMENT_CENTER
	textos.add_theme_constant_override("separation", 2)
	var cabecera := Estilo.etiqueta("MISTERIO DE LA SEMANA", 30, Estilo.PRIMARIO, false, false)
	var texto := "Revelada: %s" % Laminas.nombre(id) if revelada else ("Sigue pintando para descubrirla" if Obras.tiene(id) else "No sabrás qué es hasta terminarla")
	var pie := Estilo.etiqueta(texto, 36, Estilo.TEXTO, false, false)
	for n in [cabecera, pie]:
		n.mouse_filter = Control.MOUSE_FILTER_IGNORE
		textos.add_child(n)
	fila.add_child(textos)
	return t[0]


## Ajustes en un panel: sonido, musica, vibracion y ocultar terminadas.
func abrir_ajustes() -> void:
	var m := Estilo.modal(self)
	var velo: ColorRect = m[0]
	var col: VBoxContainer = m[1]
	col.add_child(Estilo.titulo("Ajustes", 60, true))
	for a in [["Sonido", "sonido"], ["Música ambiental", "musica"], ["Vibración", "vibracion"], ["Ocultar terminadas", "ocultar_terminadas"]]:
		col.add_child(_interruptor(a[0], a[1]))
	var listo := Estilo.boton("Listo", "primario", 130)
	col.add_child(listo)
	var cerrar := func():
		velo.queue_free()
		Estilo.ir(self, "menu")          # vuelve a pintar el menu con el filtro nuevo
	listo.pressed.connect(cerrar)
	velo.gui_input.connect(func(e):
		if e is InputEventScreenTouch and e.pressed:
			cerrar.call())


func _interruptor(texto: String, clave: String) -> Button:
	var b := Estilo.boton("", "normal", 124)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_font_size_override("font_size", 42)
	var pintar := func() -> void:
		var on := bool(Ajustes.valor(clave))
		b.text = "%s:  %s" % [texto, "Sí" if on else "No"]
		Estilo.colorear(b, Estilo.SUPERFICIE if on else Color(Estilo.TEXTO, 0.06), Estilo.TEXTO if on else Estilo.TEXTO_SUAVE)
	b.pressed.connect(func():
		Ajustes.fijar(clave, not bool(Ajustes.valor(clave)))
		if clave == "musica":
			Sonido.actualizar_musica()
		pintar.call())
	pintar.call()
	return b


## Tarjeta de la lamina del dia: miniatura, nombre y racha.
func _lamina_del_dia() -> Control:
	var hoy := Diario.hoy()
	var id := Laminas.del_dia(hoy)
	var t := Estilo.tarjeta(240, Estilo.SUPERFICIE, func():
		preload("res://escenas/colorear.gd").lamina_id = id
		Estilo.ir(self, "colorear"))
	var b: Button = t[0]
	var fila := HBoxContainer.new()
	fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila.size_flags_vertical = Control.SIZE_EXPAND_FILL
	(t[1] as VBoxContainer).add_child(fila)
	var img := TextureRect.new()
	img.texture = Obras.textura_mini(id)
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	img.custom_minimum_size = Vector2(180, 180)
	img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila.add_child(img)
	var textos := VBoxContainer.new()
	textos.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textos.alignment = BoxContainer.ALIGNMENT_CENTER
	textos.add_theme_constant_override("separation", 4)
	var cabecera := Estilo.etiqueta("LÁMINA DEL DÍA", 32, Estilo.PRIMARIO, false, false)
	var nombre := Estilo.titulo(Laminas.nombre(id), 52)
	var racha := Diario.racha(hoy)
	var texto_racha := "Píntala para empezar tu racha"
	if racha > 0:
		texto_racha = "Racha: %d %s" % [racha, "día" if racha == 1 else "días"]
	var pie := Estilo.etiqueta(texto_racha, 36, Estilo.TEXTO_SUAVE, false, false)
	for n in [cabecera, nombre, pie]:
		n.mouse_filter = Control.MOUSE_FILTER_IGNORE
		textos.add_child(n)
	fila.add_child(textos)
	return b


func _miniatura(id: String) -> Control:
	var t := Estilo.tarjeta(0, Estilo.SUPERFICIE, func():
		preload("res://escenas/colorear.gd").lamina_id = id
		Estilo.ir(self, "colorear"))
	var b: Button = t[0]
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.custom_minimum_size = Vector2(0, 300)
	var img := TextureRect.new()
	img.texture = Obras.textura_mini(id)
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	img.size_flags_vertical = Control.SIZE_EXPAND_FILL
	img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	(t[1] as VBoxContainer).add_child(img)
	if Obras.terminada(id):
		var marca := Estilo.etiqueta("✓", 44, Estilo.SOBRE_PRIMARIO, true, false)
		var fondo := PanelContainer.new()
		var caja := Estilo.caja(Estilo.PRIMARIO, 30, 0, false)
		caja.content_margin_left = 16
		caja.content_margin_right = 16
		fondo.add_theme_stylebox_override("panel", caja)
		fondo.add_child(marca)
		fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		marca.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fondo.position = Vector2(14, 14)
		b.add_child(fondo)
	return b


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
