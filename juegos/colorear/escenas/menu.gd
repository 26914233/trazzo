# Menu: categorias arriba y cuadricula de laminas. "Mis obras" primero si hay.
extends Control

static var categoria_actual := ""

var _rejilla := GridContainer.new()
var _chips := HBoxContainer.new()


func _ready() -> void:
	var col := Estilo.pantalla(self)
	col.add_theme_constant_override("separation", 28)
	col.add_child(Estilo.titulo(str(ProjectSettings.get_setting("application/config/name")), 110, true))
	col.add_child(Estilo.etiqueta("%d láminas para colorear" % Laminas.total(), 40, Estilo.TEXTO_SUAVE))
	col.add_child(_lamina_del_dia())

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
	var ids: Array = Obras.lista() if categoria_actual == "obras" else Laminas.categoria(categoria_actual)["laminas"].map(func(l): return l["id"])
	for id in ids:
		_rejilla.add_child(_miniatura(id))


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
	return b


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
