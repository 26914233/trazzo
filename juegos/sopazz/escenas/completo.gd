# Version completa: un pago unico que desbloquea todo.
extends Control


func _ready() -> void:
	var col := Estilo.pantalla(self)
	Estilo.barra(col, "", func(): Estilo.ir(self, "menu"))
	var hueco := Control.new()
	hueco.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(hueco)
	col.add_child(Estilo.titulo("Sopazz completo", 92, true))
	col.add_child(Estilo.etiqueta("Un solo pago. Para siempre.", 44, Estilo.TEXTO_SUAVE))

	var panel := PanelContainer.new()
	var estilo := Estilo.caja(Estilo.SUPERFICIE, Estilo.RADIO + 8)
	estilo.content_margin_left = 48
	estilo.content_margin_right = 48
	estilo.content_margin_top = 40
	estilo.content_margin_bottom = 40
	panel.add_theme_stylebox_override("panel", estilo)
	var lista := VBoxContainer.new()
	lista.add_theme_constant_override("separation", 26)
	panel.add_child(lista)
	for texto in [
		"Las %d sopas de los %d temas" % [Temas.total_sopas(), Temas.lista.size()],
		"Sin ningún anuncio",
		"Pistas ilimitadas",
		"Sin suscripción: pagas una vez",
	]:
		var fila := HBoxContainer.new()
		var check := Estilo.etiqueta("✓", 48, Estilo.PRIMARIO if not Estilo.es_oscuro() else Estilo.PRIMARIO, false, false)
		check.add_theme_font_override("font", Estilo.FUENTE_NEGRITA)
		fila.add_child(check)
		var l := Estilo.etiqueta(texto, 42, Estilo.TEXTO, false)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.add_child(l)
		lista.add_child(fila)
	col.add_child(panel)
	var hueco2 := Control.new()
	hueco2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(hueco2)

	if Progreso.es_premium():
		col.add_child(Estilo.etiqueta("Ya tienes Sopazz completo. ¡Gracias!", 44, Estilo.TEXTO))
	else:
		var comprar := Estilo.boton("Desbloquear todo  ·  %s" % Monetizacion.PRECIO, "primario", 170)
		comprar.add_theme_font_size_override("font_size", 50)
		comprar.pressed.connect(func():
			comprar.disabled = true
			var ok := await Monetizacion.comprar(Monetizacion.PRODUCTO)
			comprar.disabled = false
			if ok:
				Estilo.aviso(self, "¡Listo! Ya tienes todo Sopazz.")
				await get_tree().create_timer(1.2).timeout
				Estilo.ir(self, "completo")
			else:
				Estilo.aviso(self, "La compra no se completó. No se te ha cobrado."))
		col.add_child(comprar)
	var restaurar := Estilo.boton("Restaurar compra", "suave", 120)
	restaurar.add_theme_font_size_override("font_size", 38)
	restaurar.pressed.connect(func():
		var n := await Monetizacion.restaurar_compras()
		Estilo.aviso(self, "Compra restaurada." if n > 0 else "No hay ninguna compra que restaurar.")
		if n > 0:
			Estilo.ir(self, "completo"))
	col.add_child(restaurar)


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		Estilo.ir(self, "menu")
