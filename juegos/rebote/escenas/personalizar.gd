# Personalizar: paletas, bolas y estelas (solo estetica). Se compran con gemas.
extends Control

const PESTANAS := [["paleta", "Paletas"], ["bola", "Bolas"], ["estela", "Estelas"]]

var tipo := "paleta"
var _contador: HBoxContainer
var _pestanas := HBoxContainer.new()
var _rejilla := GridContainer.new()
var _vistas: Array[Control] = []
var _t := 0.0


func _ready() -> void:
	var fondo := Fondo.new()
	add_child(fondo)
	var col := Estilo.pantalla(self)
	move_child(fondo, 0)
	_contador = Estilo.contador_gemas(46)
	Estilo.barra(col, "Personalizar", func(): Estilo.ir(self, "menu"), _contador)
	col.add_child(_pestanas)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	_rejilla.columns = 2
	_rejilla.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rejilla.add_theme_constant_override("h_separation", 24)
	_rejilla.add_theme_constant_override("v_separation", 24)
	scroll.add_child(_rejilla)
	construir()


func construir() -> void:
	Estilo.refrescar_gemas(_contador)
	for h in _pestanas.get_children():
		_pestanas.remove_child(h)
		h.queue_free()
	for p in PESTANAS:
		var b := Estilo.boton(p[1], "primario" if p[0] == tipo else "suave", 110)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(func():
			tipo = p[0]
			construir())
		_pestanas.add_child(b)
	for h in _rejilla.get_children():
		_rejilla.remove_child(h)
		h.queue_free()
	_vistas.clear()
	var puesto: String = Progreso.equipado(tipo)["id"]
	for a in Aspectos.lista(tipo):
		_rejilla.add_child(_tarjeta(a, a["id"] == puesto))
	Estilo.permitir_arrastre(_rejilla)


func _tarjeta(a: Dictionary, puesto: bool) -> Button:
	var t := Estilo.tarjeta(330, Estilo.SUPERFICIE.lightened(0.08) if puesto else Estilo.SUPERFICIE, func(): elegir(a["id"]))
	var b: Button = t[0]
	var v: VBoxContainer = t[1]
	b.name = "Aspecto_" + a["id"]
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if puesto:
		var borde := Estilo.caja(Estilo.SUPERFICIE.lightened(0.08), -1, 5)
		borde.border_color = Estilo.ACENTO
		b.add_theme_stylebox_override("normal", borde)
	var vista := Control.new()
	vista.custom_minimum_size = Vector2(0, 150)
	vista.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vista.draw.connect(_dibujar_vista.bind(vista, a))
	v.add_child(vista)
	_vistas.append(vista)
	var nombre := Estilo.titulo(a["nombre"], 42, true)
	nombre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(nombre)
	var estado := HBoxContainer.new()
	estado.alignment = BoxContainer.ALIGNMENT_CENTER
	estado.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if puesto:
		estado.add_child(Estilo.etiqueta("En uso ✓", 34, Estilo.ACENTO, false, false))
	elif Progreso.tiene_aspecto(tipo, a["id"]):
		estado.add_child(Estilo.etiqueta("Usar", 34, Estilo.TEXTO_SUAVE, false, false))
	else:
		estado.add_child(Estilo.gema(36))
		estado.add_child(Estilo.etiqueta(str(a["precio"]), 34, Estilo.TEXTO, false, false))
	for c in estado.get_children():
		(c as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(estado)
	return b


func _dibujar_vista(c: Control, a: Dictionary) -> void:
	var centro := c.size / 2.0
	match tipo:
		"paleta":
			Dibujo.paleta(c, Rect2(centro - Vector2(130, 17), Vector2(260, 34)), a)
		"bola":
			Dibujo.bola(c, centro, 34.0, a)
		"estela":
			var puntos: Array = []
			for k in Dibujo.LARGO_ESTELA:
				var f := float(k) / (Dibujo.LARGO_ESTELA - 1)
				puntos.append(centro + Vector2(-150 + 260 * f, sin(_t * 3.0 + f * 3.0) * 26.0 * (1.0 - f)))
			Dibujo.estela(c, puntos, 22.0, a, _t)
			Dibujo.bola(c, puntos[-1], 22.0, Progreso.equipado("bola"))


func _process(delta: float) -> void:
	_t += delta
	if tipo == "estela":
		for v in _vistas:
			if is_instance_valid(v):
				v.queue_redraw()


## Toca un aspecto: si es tuyo se pone; si no, se compra (con confirmacion).
func elegir(id: String) -> void:
	var a := Aspectos.buscar(tipo, id)
	if a.is_empty():
		return
	if Progreso.tiene_aspecto(tipo, id):
		Progreso.equipar(tipo, id)
		construir()
		return
	var precio := int(a["precio"])
	if Progreso.gemas() < precio:
		var i := await Estilo.dialogo(self, a["nombre"], "Te faltan %d gemas. Se ganan jugando o en la Tienda." % (precio - Progreso.gemas()), ["Ir a la Tienda", "Cerrar"])
		if i == 0 and is_inside_tree():
			Estilo.ir(self, "tienda")
		return
	var j := await Estilo.dialogo(self, a["nombre"], "¿Comprar por %d gemas? Te quedarán %d." % [precio, Progreso.gemas() - precio], ["Comprar y usar", "Cancelar"])
	if j != 0 or not is_inside_tree():
		return
	if Progreso.comprar_aspecto(tipo, id):
		Progreso.equipar(tipo, id)
		Sonido.tocar("gana")
	construir()


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		Estilo.ir(self, "menu")
