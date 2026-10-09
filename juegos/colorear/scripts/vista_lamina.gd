# Muestra una lamina y la deja colorear: toque = rellenar zona, dos dedos =
# zoom y desplazar, un dedo con zoom = desplazar. Rueda del raton en escritorio.
class_name VistaLamina
extends Control

signal zona_tocada(zona: int)

const ZOOM_MAX := 8.0
const MOVER_TOQUE := 24.0      # px que puede moverse un dedo y seguir siendo toque

var lamina: Lamina
var zoom := 1.0
var desplazamiento := Vector2.ZERO   # posicion del contenido dentro de la vista

var _contenido := Control.new()
var _zonas := TextureRect.new()
var _lineas := TextureRect.new()
var _dedos := {}                     # indice -> posicion
var _inicio_toque := Vector2.ZERO
var _es_toque := false
var _pellizco := 0.0


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_contenido.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_contenido)
	for t in [_zonas, _lineas]:
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_SCALE
		t.set_anchors_preset(Control.PRESET_FULL_RECT)
		_contenido.add_child(t)
	_zonas.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var m := ShaderMaterial.new()
	m.shader = preload("res://shaders/zonas.gdshader")
	_zonas.material = m
	resized.connect(_colocar)


func mostrar(l: Lamina) -> void:
	lamina = l
	_zonas.texture = l.textura_regiones
	(_zonas.material as ShaderMaterial).set_shader_parameter("paleta", l.textura_paleta)
	_lineas.texture = l.textura_lineas
	reiniciar_zoom()


func reiniciar_zoom() -> void:
	zoom = 1.0
	desplazamiento = Vector2.ZERO
	_colocar()


func _lado_base() -> float:
	return minf(size.x, size.y)


func _colocar() -> void:
	var lado := _lado_base() * zoom
	var hueco := size - Vector2(lado, lado)
	# Centrado mientras cabe; si no, sin dejar ver fuera de la lamina.
	for eje in 2:
		if hueco[eje] >= 0:
			desplazamiento[eje] = hueco[eje] / 2
		else:
			desplazamiento[eje] = clampf(desplazamiento[eje], hueco[eje], 0)
	_contenido.position = desplazamiento
	_contenido.size = Vector2(lado, lado)


## Punto de la vista -> pixel de la lamina.
func a_lamina(p: Vector2) -> Vector2i:
	if lamina == null:
		return Vector2i(-1, -1)
	var px := (p - desplazamiento) / (_lado_base() * zoom) * lamina.regiones.get_width()
	return Vector2i(floori(px.x), floori(px.y))


func ampliar(factor: float, centro: Vector2) -> void:
	var nuevo := clampf(zoom * factor, 1.0, ZOOM_MAX)
	desplazamiento = centro - (centro - desplazamiento) * (nuevo / zoom)
	zoom = nuevo
	_colocar()


func _gui_input(e: InputEvent) -> void:
	if e is InputEventScreenTouch:
		if e.pressed:
			_dedos[e.index] = e.position
			_es_toque = _dedos.size() == 1
			_inicio_toque = e.position
			if _dedos.size() == 2:
				_pellizco = _distancia_dedos()
		else:
			_dedos.erase(e.index)
			if _es_toque and _dedos.is_empty():
				_tocar(e.position)
			_es_toque = false
			if _dedos.size() == 1:
				_pellizco = 0.0
		accept_event()
	elif e is InputEventScreenDrag:
		if not _dedos.has(e.index):
			return
		var antes: Vector2 = _dedos[e.index]
		_dedos[e.index] = e.position
		if _es_toque and e.position.distance_to(_inicio_toque) > MOVER_TOQUE:
			_es_toque = false
		if _dedos.size() == 2:
			var d := _distancia_dedos()
			var centro := _centro_dedos()
			if _pellizco > 0.0:
				ampliar(d / _pellizco, centro)
			_pellizco = d
			desplazamiento += (e.position - antes) / 2.0
			_colocar()
		elif not _es_toque and zoom > 1.0:
			desplazamiento += e.position - antes
			_colocar()
		accept_event()
	elif e is InputEventMouseButton and e.pressed:
		if e.button_index == MOUSE_BUTTON_WHEEL_UP:
			ampliar(1.15, e.position)
		elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			ampliar(1 / 1.15, e.position)


func _distancia_dedos() -> float:
	var v := _dedos.values()
	return (v[0] as Vector2).distance_to(v[1])


func _centro_dedos() -> Vector2:
	var v := _dedos.values()
	return ((v[0] as Vector2) + (v[1] as Vector2)) / 2.0


func _tocar(p: Vector2) -> void:
	if lamina == null:
		return
	var z := lamina.zona_en(a_lamina(p))
	if z > 0:
		zona_tocada.emit(z)
