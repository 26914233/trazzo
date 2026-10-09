# Tablero de la sopa: dibuja la cuadricula y convierte el arrastre del dedo
# en una seleccion recta. No sabe nada de reglas: emite `seleccion_hecha` y
# la escena de juego decide si es una palabra.
class_name Tablero
extends Control

signal seleccion_hecha(celdas: Array[Vector2i])

const GROSOR_TRAZO := 0.78   ## fraccion del tamaño de celda

var sopa: GeneradorSopa.Sopa
var color_tema := Color.WHITE
var escala_texto := 1.0
var activo := true

var _encontradas: Array = []          ## [{celdas, color}]
var _seleccion: Array[Vector2i] = []
var _inicio := Vector2i(-1, -1)
var _dedo := -1
var _pista := Vector2i(-1, -1)
var _t := 0.0
var _sacudida := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(queue_redraw)


func _process(delta: float) -> void:
	_t += delta
	if _sacudida > 0.0:
		_sacudida = maxf(0.0, _sacudida - delta * 3.0)
	if _pista.x >= 0 or _sacudida > 0.0:
		queue_redraw()


func preparar(nueva: GeneradorSopa.Sopa, color: Color) -> void:
	sopa = nueva
	color_tema = color
	_encontradas.clear()
	_seleccion.clear()
	_pista = Vector2i(-1, -1)
	queue_redraw()


func marcar_encontrada(celdas: Array[Vector2i], color: Color) -> void:
	_encontradas.append({"celdas": celdas, "color": color})
	if _pista in celdas:
		_pista = Vector2i(-1, -1)
	queue_redraw()


func sacudir() -> void:
	_sacudida = 1.0


func mostrar_pista(celda: Vector2i) -> void:
	_pista = celda


# ---------------------------------------------------------------- geometria

func _lado_celda() -> float:
	return minf(size.x, size.y) / float(sopa.lado)


func _origen() -> Vector2:
	var total := _lado_celda() * sopa.lado
	return (size - Vector2(total, total)) / 2.0


func _centro(c: Vector2i) -> Vector2:
	var l := _lado_celda()
	return _origen() + Vector2(c) * l + Vector2(l, l) / 2.0


func _celda_en(pos: Vector2) -> Vector2:
	return (pos - _origen()) / _lado_celda() - Vector2(0.5, 0.5)


## Convierte el punto donde esta el dedo (en coordenadas de celda, con
## decimales) en una linea recta desde `inicio`: se ajusta a la direccion
## de 45 grados mas cercana y se recorta para no salirse del tablero.
static func ajustar_seleccion(inicio: Vector2i, dedo: Vector2, lado: int) -> Array[Vector2i]:
	var d := dedo - Vector2(inicio)
	if d.length() < 0.5:
		return [inicio]
	var octante := wrapi(roundi(d.angle() / (PI / 4.0)), 0, 8)
	var dir := Vector2i(Vector2.RIGHT.rotated(octante * PI / 4.0).round())
	var largo := roundi(maxf(absf(d.x), absf(d.y)))
	if dir.x != 0 and dir.y != 0:
		largo = roundi((absf(d.x) + absf(d.y)) / 2.0)
	var celdas: Array[Vector2i] = []
	for i in largo + 1:
		var c := inicio + dir * i
		if c.x < 0 or c.y < 0 or c.x >= lado or c.y >= lado:
			break
		celdas.append(c)
	return celdas


# ---------------------------------------------------------------- entrada

func _gui_input(evento: InputEvent) -> void:
	if sopa == null or not activo:
		return
	# Solo eventos tactiles: en escritorio el raton se emula como toque
	# (project.godot), y asi no se procesa cada gesto dos veces en Android.
	if evento is InputEventScreenTouch:
		if evento.pressed and _dedo == -1:
			var c := _celda_en(evento.position).round()
			var ci := Vector2i(c)
			if ci.x < 0 or ci.y < 0 or ci.x >= sopa.lado or ci.y >= sopa.lado:
				return
			_dedo = evento.index
			_inicio = ci
			_seleccion = [ci]
			Sonido.tocar("clic")
			queue_redraw()
		elif not evento.pressed and evento.index == _dedo:
			_dedo = -1
			var hecha := _seleccion.duplicate()
			_seleccion.clear()
			queue_redraw()
			if hecha.size() > 1:
				seleccion_hecha.emit(hecha)
		accept_event()
	elif evento is InputEventScreenDrag and evento.index == _dedo:
		var nueva := ajustar_seleccion(_inicio, _celda_en(evento.position), sopa.lado)
		if nueva != _seleccion:
			_seleccion = nueva
			queue_redraw()
		accept_event()


# ---------------------------------------------------------------- dibujo

func _draw() -> void:
	if sopa == null:
		return
	var l := _lado_celda()
	var total := l * sopa.lado
	var desplaza := Vector2(sin(_t * 60.0) * 14.0 * _sacudida, 0)
	var marco := Rect2(_origen() - Vector2(18, 18), Vector2(total, total) + Vector2(36, 36))
	draw_style_box(Estilo.caja(Estilo.TABLERO, Estilo.RADIO + 10), marco)
	var alfa := 0.55 if Estilo.es_oscuro() else 0.38

	for e in _encontradas:
		_trazo(e["celdas"], Color(e["color"], alfa), Vector2.ZERO)
	if _seleccion.size() > 0:
		_trazo(_seleccion, Color(Estilo.PRIMARIO, 0.45), desplaza)
	if _pista.x >= 0:
		var r := l * (0.42 + 0.06 * sin(_t * 6.0))
		draw_circle(_centro(_pista), r, Color(Estilo.ACENTO, 0.35))
		draw_arc(_centro(_pista), r, 0, TAU, 40, Estilo.ACENTO, 5.0, true)

	var fuente: Font = Estilo.FUENTE_NEGRITA
	var tam := int(l * 0.58 * escala_texto)
	var en_seleccion := {}
	for c in _seleccion:
		en_seleccion[c] = true
	for y in sopa.lado:
		for x in sopa.lado:
			var c := Vector2i(x, y)
			var letra := sopa.letra(c)
			var ancho := fuente.get_string_size(letra, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x
			var base := _centro(c) + Vector2(-ancho / 2.0, tam * 0.36)
			if en_seleccion.has(c):
				base += desplaza
			draw_string(fuente, base, letra, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, Estilo.LETRA)


func _trazo(celdas: Array, color: Color, desplaza: Vector2) -> void:
	var l := _lado_celda()
	var a := _centro(celdas[0]) + desplaza
	var b := _centro(celdas[celdas.size() - 1]) + desplaza
	var r := l * GROSOR_TRAZO / 2.0
	draw_line(a, b, color, r * 2.0, true)
	draw_circle(a, r, color)
	draw_circle(b, r, color)
