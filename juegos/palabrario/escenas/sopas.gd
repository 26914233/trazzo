# Las sopas de una categoria, con sus estrellas en la dificultad elegida.
extends Control

var _cat: Dictionary


func _ready() -> void:
	_cat = Temas.categoria(Temas.seleccion.get("categoria", ""))
	if _cat.is_empty():
		_cat = Temas.lista[0]
	var dif := int(Progreso.ajuste("dificultad"))
	var col := Estilo.pantalla(self)
	Estilo.barra(col, _cat["nombre"], func(): Estilo.ir(self, Temas.volver_a))
	col.add_child(Estilo.etiqueta("%s · %d de %d resueltas" % [Economia.DIFICULTADES[dif]["nombre"], Progreso.resueltas_en(_cat["id"], dif), _cat["subtemas"].size()], 36, Estilo.TEXTO_SUAVE, false))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	var lista := VBoxContainer.new()
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lista.add_theme_constant_override("separation", 18)
	scroll.add_child(lista)
	var subs: Array = _cat["subtemas"]
	for i in subs.size():
		lista.add_child(_fila(i, subs[i], dif))


func _fila(i: int, s: Dictionary, dif: int) -> Button:
	var t := Estilo.tarjeta(150, Estilo.SUPERFICIE, func(): _abrir(s, dif))
	var v: VBoxContainer = t[1]
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	var h := HBoxContainer.new()
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var num := Estilo.titulo(str(i + 1), 46)
	num.custom_minimum_size.x = 80
	var c_cat := Color(_cat["color"])
	num.add_theme_color_override("font_color", c_cat.lightened(0.25) if Estilo.es_oscuro() else c_cat.darkened(0.35))
	h.add_child(num)
	var nombre := Estilo.etiqueta(s["nombre"], 42, Estilo.TEXTO, false, false)
	nombre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nombre.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	nombre.clip_text = true
	h.add_child(nombre)
	h.add_child(Estilo.etiqueta(Estilo.estrellas_texto(Progreso.estrellas_de(_cat["id"], s["id"], dif)), 44, Estilo.ACENTO, false, false))
	for c in h.get_children():
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(h)
	return t[0]


func _abrir(s: Dictionary, dif: int) -> void:
	Temas.seleccion = {"categoria": _cat["id"], "subtema": s["id"], "dificultad": dif, "diario": false}
	Estilo.ir(self, "juego")


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		Estilo.ir(self, Temas.volver_a)
