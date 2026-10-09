# Tienda: fichas, quitar anuncios y todos los temas.
extends Control

var _lista: VBoxContainer


func _ready() -> void:
	var col := Estilo.pantalla(self)
	var barra := HBoxContainer.new()
	var atras := Estilo.boton("‹", Estilo.TARJETA, 120)
	atras.custom_minimum_size.x = 120
	atras.pressed.connect(func(): Estilo.ir(self, "menu"))
	barra.add_child(atras)
	var t := Estilo.etiqueta("Tienda", 64, Estilo.TEXTO, false)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	barra.add_child(t)
	barra.add_child(Estilo.pildora_fichas())
	col.add_child(barra)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	_lista = VBoxContainer.new()
	_lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_lista)
	_pintar()

	var restaurar := Estilo.boton("Restaurar compras", Estilo.TARJETA, 120)
	restaurar.add_theme_font_size_override("font_size", 40)
	restaurar.pressed.connect(func():
		var n := await Monetizacion.restaurar_compras()
		Estilo.aviso(self, "Compras restauradas: %d" % n if n > 0 else "No hay compras que restaurar.")
		_pintar())
	col.add_child(restaurar)


func _pintar() -> void:
	for h in _lista.get_children():
		h.queue_free()
	var orden := ["sin_anuncios", "fichas_500", "fichas_1500", "fichas_4000", "fichas_10000", "todos_los_temas"]
	for id in orden:
		var p: Dictionary = Monetizacion.PRODUCTOS[id]
		var ya: bool = id == "sin_anuncios" and Progreso.sin_anuncios()
		var fondo := Estilo.ORO if p.get("destacado", false) else Estilo.TARJETA
		if id == "sin_anuncios":
			fondo = Estilo.PRIMARIO
		var texto := "%s  ·  %s" % [p["nombre"], p["precio"]]
		if id == "sin_anuncios":
			texto = "Quitar anuncios + 300 fichas  ·  %s" % p["precio"]
		if p.get("destacado", false):
			texto += "\nEl mejor valor"
		if ya:
			texto = "Anuncios quitados. ¡Gracias!"
		var b := Estilo.boton(texto, fondo, 170)
		b.add_theme_font_size_override("font_size", 44)
		b.disabled = ya
		b.pressed.connect(_comprar.bind(id, b))
		_lista.add_child(b)
	var nota := Estilo.etiqueta("Los anuncios con premio (pistas) siguen disponibles si quieres usarlos: siempre son opcionales.", 36, Estilo.TEXTO_SUAVE)
	_lista.add_child(nota)


func _comprar(id: String, b: Button) -> void:
	b.disabled = true
	var ok := await Monetizacion.comprar(id)
	b.disabled = false
	Estilo.aviso(self, "¡Listo! Ya es tuyo." if ok else "La compra no se completó. No se te ha cobrado.")
	_pintar()


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		Estilo.ir(self, "menu")
