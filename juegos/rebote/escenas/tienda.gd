# Tienda: quitar anuncios, paquetes de gemas y gemas gratis con un anuncio.
# Las gemas solo compran aspectos y ayudas: ningun nivel se cierra tras un pago.
extends Control

var _lista := VBoxContainer.new()
var _contador: HBoxContainer
var _ocupado := false


func _ready() -> void:
	var fondo := Fondo.new()
	add_child(fondo)
	var col := Estilo.pantalla(self)
	move_child(fondo, 0)
	_contador = Estilo.contador_gemas(46)
	Estilo.barra(col, "Tienda", func(): Estilo.ir(self, "menu"), _contador)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	_lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lista.add_theme_constant_override("separation", 24)
	scroll.add_child(_lista)
	Monetizacion.compra_completada.connect(_al_comprar)
	construir()


func construir() -> void:
	for h in _lista.get_children():
		_lista.remove_child(h)
		h.queue_free()
	Estilo.refrescar_gemas(_contador)
	var sin := Progreso.sin_anuncios()
	_lista.add_child(_fila("sin_anuncios", "Quitar anuncios",
		"Sin anuncios entre niveles y «Seguir» gratis al perder. Para siempre.",
		"Comprado ✓" if sin else Monetizacion.precio("sin_anuncios"), sin, null))
	_lista.add_child(_seccion("Gemas"))
	for id in ["gemas_500", "gemas_1500", "gemas_4000"]:
		var p: Dictionary = Monetizacion.PRODUCTOS[id]
		var desc := "El mejor precio por gema" if p.get("destacado", false) else "Para aspectos y ayudas"
		_lista.add_child(_fila(id, p["nombre"], desc, Monetizacion.precio(id), false, Estilo.gema(70)))
	_lista.add_child(_seccion("Gemas gratis"))
	var quedan := Progreso.premiados_restantes(Progreso.hoy())
	var gratis := _fila("anuncio", "+%d gemas" % Economia.GEMAS_PREMIADO,
		"Mira un anuncio corto. Quedan %d hoy." % quedan if quedan > 0 else "Ya viste todos los de hoy. Vuelve mañana.",
		"Ver anuncio", quedan <= 0 or not Monetizacion.hay_anuncios(), Estilo.gema(70))
	_lista.add_child(gratis)
	var nota := Estilo.etiqueta("Todos los niveles se juegan gratis. Las gemas también se ganan jugando: %d por nivel y %d por cada estrella nueva." % [Economia.GEMAS_NIVEL, Economia.GEMAS_ESTRELLA], 34, Estilo.TEXTO_SUAVE)
	_lista.add_child(nota)
	var restaurar := Estilo.boton("Restaurar compras", "suave", 110)
	restaurar.pressed.connect(func():
		Monetizacion.restaurar_compras()
		Estilo.aviso(self, "Buscando tus compras en Google Play…"))
	_lista.add_child(restaurar)
	Estilo.permitir_arrastre(_lista)


func _seccion(texto: String) -> Label:
	var l := Estilo.titulo(texto, 48)
	l.add_theme_color_override("font_color", Estilo.ACENTO)
	return l


func _fila(id: String, titulo: String, desc: String, boton: String, apagado: bool, icono: Control) -> PanelContainer:
	var panel := PanelContainer.new()
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 26)
	panel.add_child(h)
	if icono:
		icono.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(icono)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 6)
	v.add_child(Estilo.titulo(titulo, 46))
	v.add_child(Estilo.etiqueta(desc, 32, Estilo.TEXTO_SUAVE, false))
	h.add_child(v)
	var b := Estilo.boton(boton, "suave" if apagado else ("acento" if id == "anuncio" else "primario"), 112)
	b.custom_minimum_size.x = 260
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.add_theme_font_size_override("font_size", 38)
	b.disabled = apagado
	b.name = "Comprar_" + id
	b.pressed.connect(func():
		if id == "anuncio":
			ver_anuncio()
		else:
			comprar(id))
	h.add_child(b)
	return panel


func comprar(producto: String) -> void:
	if _ocupado:
		return
	_ocupado = true
	var ok: bool = await Monetizacion.comprar(producto)
	_ocupado = false
	if not is_inside_tree():
		return
	if not ok:
		Estilo.aviso(self, "La compra no se completó. Si quedó pendiente de pago, llegará sola al confirmarse.")
	construir()


func ver_anuncio() -> void:
	if _ocupado:
		return
	_ocupado = true
	var ok: bool = await Monetizacion.mostrar_premiado("gemas")
	_ocupado = false
	if not is_inside_tree():
		return
	Estilo.aviso(self, "¡+%d gemas!" % Economia.GEMAS_PREMIADO if ok else "El anuncio no está listo. Prueba en un momento.")
	if ok:
		Sonido.tocar("potenciador")
	construir()


func _al_comprar(producto: String) -> void:
	if not is_inside_tree():
		return
	var p: Dictionary = Monetizacion.PRODUCTOS.get(producto, {})
	Sonido.tocar("gana")
	Estilo.aviso(self, "¡Listo! Ya no verás anuncios entre niveles." if producto == "sin_anuncios" else "¡+%d gemas!" % int(p.get("gemas", 0)))
	construir()


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		Estilo.ir(self, "menu")
