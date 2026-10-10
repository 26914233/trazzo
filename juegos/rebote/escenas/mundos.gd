# Mundos y niveles: 6 mundos de 20 niveles con sus estrellas. Se abren en orden.
extends Control


func _ready() -> void:
	var fondo := Fondo.new()
	add_child(fondo)
	var col := Estilo.pantalla(self)
	remove_child(fondo)
	add_child(fondo)
	move_child(fondo, 0)
	Estilo.barra(col, "Mundos", func(): Estilo.ir(self, "menu"))
	col.add_child(Estilo.etiqueta("★ %d de %d" % [Progreso.total_estrellas(), Niveles.total() * 3], 40, Estilo.ACENTO))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	var lista := VBoxContainer.new()
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lista.add_theme_constant_override("separation", 26)
	scroll.add_child(lista)
	var foco: Control = null
	var mundos := Niveles.mundos()
	for m in mundos.size():
		var inicio := Niveles.inicio_mundo(m)
		var n: int = mundos[m]["niveles"].size()
		var estrellas := 0
		for k in n:
			estrellas += Progreso.estrellas(inicio + k)
		var cab := HBoxContainer.new()
		var nombre := Estilo.titulo("%d · %s" % [m + 1, mundos[m]["nombre"]], 52)
		nombre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cab.add_child(nombre)
		cab.add_child(Estilo.etiqueta("★ %d/%d" % [estrellas, n * 3], 38, Estilo.ACENTO, false, false))
		lista.add_child(cab)
		var rejilla := GridContainer.new()
		rejilla.columns = 5
		rejilla.add_theme_constant_override("h_separation", 18)
		rejilla.add_theme_constant_override("v_separation", 18)
		for k in n:
			var i := inicio + k
			var b := _boton_nivel(i, Color(mundos[m]["fondo"][1]))
			rejilla.add_child(b)
			if foco == null and Progreso.desbloqueado(i) and Progreso.estrellas(i) == 0:
				foco = b
		lista.add_child(rejilla)
	Estilo.permitir_arrastre(lista)
	if foco:
		(func(): scroll.scroll_vertical = int(maxf(foco.global_position.y - scroll.global_position.y - 300, 0))).call_deferred()


func _boton_nivel(i: int, color: Color) -> Button:
	var abierto := Progreso.desbloqueado(i)
	var b := Button.new()
	b.custom_minimum_size = Vector2(0, 168)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	Estilo.colorear(b, color.lightened(0.15) if abierto else Estilo.BLOQUEADO, Estilo.TEXTO if abierto else Estilo.TEXTO_SUAVE)
	b.disabled = not abierto
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var num := Estilo.titulo(str(i + 1), 50, true)
	var e := Progreso.estrellas(i)
	var est := Estilo.etiqueta("★".repeat(e) + "☆".repeat(3 - e) if abierto else "—", 30, Estilo.ACENTO if abierto else Estilo.TEXTO_SUAVE)
	for x in [num, est]:
		x.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(x)
	b.add_child(v)
	b.pressed.connect(func():
		Sonido.tocar("clic")
		preload("res://escenas/juego.gd").nivel_idx = i
		Estilo.ir(self, "juego"))
	return b


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		Estilo.ir(self, "menu")
