# Viaje: los temas como paradas de un camino, con medalla segun lo resuelto
# (bronce 1/3, plata 2/3, oro todo, en cualquier dificultad). Nada se bloquea:
# es una forma de ver el progreso y de elegir el siguiente tema.
extends Control

const PASO := 210.0
const NODO := 132.0
const COLOR_MEDALLA := [Color.TRANSPARENT, Color("#CD7F32"), Color("#AEB8C2"), Color("#F2C230")]
const NOMBRE_MEDALLA := ["", "Bronce", "Plata", "Oro"]

var _scroll := ScrollContainer.new()
var _camino := Control.new()
var _puntos: Array[Vector2] = []
var _aqui := -1
var _t := 0.0


func _ready() -> void:
	var col := Estilo.pantalla(self)
	var lista := Estilo.boton("Lista", "suave", 104)
	lista.custom_minimum_size.x = 180
	lista.add_theme_font_size_override("font_size", 36)
	lista.pressed.connect(func(): Estilo.ir(self, "categorias"))
	Estilo.barra(col, "Viaje", func(): Estilo.ir(self, "menu"), lista)
	var m := Progreso.medallas()
	col.add_child(Estilo.etiqueta("Oro %d  ·  Plata %d  ·  Bronce %d  ·  %s" % [m[0], m[1], m[2], Economia.DIFICULTADES[int(Progreso.ajuste("dificultad"))]["nombre"]], 36, Estilo.TEXTO_SUAVE))
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(_scroll)
	_camino.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_camino.custom_minimum_size.y = PASO * Temas.lista.size() + 120
	_camino.draw.connect(_dibujar_camino)
	_scroll.add_child(_camino)
	var sig := Progreso.siguiente_parada()
	for i in Temas.lista.size():
		if Temas.lista[i]["id"] == sig:
			_aqui = i
	_camino.resized.connect(_colocar)
	(func():
		_colocar()
		if _aqui >= 0:
			_scroll.scroll_vertical = int(maxf(_puntos[_aqui].y - _scroll.size.y / 2.0, 0))).call_deferred()


func _process(delta: float) -> void:
	_t += delta
	_camino.queue_redraw()        # latido de "estas aqui"


func _colocar() -> void:
	for h in _camino.get_children():
		h.queue_free()
	_puntos.clear()
	var ancho := _camino.size.x
	for i in Temas.lista.size():
		var c: Dictionary = Temas.lista[i]
		var p := Vector2(ancho / 2.0 + sin(i * 1.1) * ancho * 0.27, 90 + i * PASO)
		_puntos.append(p)
		_parada(c, p, i)
	_camino.queue_redraw()


func _parada(c: Dictionary, p: Vector2, i: int) -> void:
	var medalla := Progreso.medalla(c["id"])
	var color := Color(c["color"])
	var b := Button.new()
	b.text = str(i + 1)
	b.size = Vector2(NODO, NODO)
	b.position = p - b.size / 2.0
	b.add_theme_font_override("font", Estilo.FUENTE_TITULO)
	b.add_theme_font_size_override("font_size", 48)
	var caja := Estilo.caja(color if medalla > 0 else Estilo.SUPERFICIE, int(NODO / 2), 8, medalla > 0)
	caja.border_color = COLOR_MEDALLA[medalla] if medalla > 0 else color
	for estado in ["normal", "hover", "pressed", "focus", "hover_pressed"]:
		b.add_theme_stylebox_override(estado, caja)
	var tinta := Color.WHITE if medalla > 0 and color.get_luminance() < 0.6 else Estilo.TEXTO
	if medalla > 0 and color.get_luminance() >= 0.6:
		tinta = Color("#1C1917")
	for estado in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(estado, tinta)
	b.pressed.connect(func():
		Sonido.tocar("clic")
		Temas.seleccion["categoria"] = c["id"]
		Temas.volver_a = "mapa"
		Estilo.ir(self, "sopas"))
	_camino.add_child(b)
	# nombre y progreso al lado con mas sitio
	var derecha := p.x < _camino.size.x / 2.0
	var textos := VBoxContainer.new()
	textos.add_theme_constant_override("separation", 0)
	textos.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var nombre := Estilo.titulo(c["nombre"], 40)
	var total: int = c["subtemas"].size()
	var detalle := "%d de %d" % [Progreso.resueltas_cualquier(c["id"]), total]
	if medalla > 0:
		detalle += "  ·  " + NOMBRE_MEDALLA[medalla]
	var pie := Estilo.etiqueta(detalle, 32, Estilo.TEXTO_SUAVE, false, false)
	for n in [nombre, pie]:
		n.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if derecha else HORIZONTAL_ALIGNMENT_RIGHT
		n.mouse_filter = Control.MOUSE_FILTER_IGNORE
		textos.add_child(n)
	var ancho_texto := 420.0
	textos.size = Vector2(ancho_texto, NODO)
	textos.alignment = BoxContainer.ALIGNMENT_CENTER
	textos.position = Vector2(p.x + NODO / 2.0 + 56 if derecha else p.x - NODO / 2.0 - 56 - ancho_texto, p.y - NODO / 2.0)   # deja sitio al anillo
	_camino.add_child(textos)


func _dibujar_camino() -> void:
	if _puntos.size() < 2:
		return
	var curva := Curve2D.new()
	for i in _puntos.size():
		var tangente := Vector2(0, PASO * 0.45)
		curva.add_point(_puntos[i], -tangente, tangente)
	_camino.draw_polyline(curva.tessellate(4, 3), Color(Estilo.TEXTO, 0.12), 18.0, true)
	# progreso dentro de cada parada
	for i in _puntos.size():
		var c: Dictionary = Temas.lista[i]
		var frac := float(Progreso.resueltas_cualquier(c["id"])) / maxf(c["subtemas"].size(), 1)
		if frac > 0.0 and frac < 1.0:
			_camino.draw_arc(_puntos[i], NODO / 2.0 + 14, -PI / 2, -PI / 2 + TAU * frac, 48, Color(c["color"]), 8.0, true)
	if _aqui >= 0:
		var r := NODO / 2.0 + 26 + 6 * sin(_t * 4.0)
		_camino.draw_arc(_puntos[_aqui], r, 0, TAU, 64, Estilo.ACENTO, 6.0, true)


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		Estilo.ir(self, "menu")
