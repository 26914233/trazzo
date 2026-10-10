# Muestra una lamina y la deja colorear. Dos modos:
#   pincel  un dedo pinta cada zona por la que pasa (tocar = una zona)
#   tocar   solo se rellena la zona tocada; arrastrar un dedo mueve el dibujo
# En los dos, dos dedos = zoom y desplazar. Rueda del raton en escritorio.
class_name VistaLamina
extends Control

signal zona_tocada(zona: int)
signal trazo_empezado
signal trazo_terminado
signal trazo_cancelado     # entro un segundo dedo: lo pintado no vale

const PASO_TRAZO := 4.0    # px de pantalla entre muestras del recorrido
const MOVER_TOQUE := 24.0  # modo tocar: px que puede moverse el dedo y seguir siendo toque

## true = pincel (arrastrar pinta); false = tocar (solo la zona tocada).
var arrastrar_pinta := true

const ZOOM_MAX := 8.0

const SEGUNDOS_RESALTE := 4.0

var lamina: Lamina
var resaltada := 0                   # zona que late tras "buscar zona sin pintar"
var zoom := 1.0
var desplazamiento := Vector2.ZERO   # posicion del contenido dentro de la vista

var _contenido := Control.new()
var _zonas := TextureRect.new()
var _lineas := TextureRect.new()
var _dedos := {}                     # indice -> posicion
var _pellizco := 0.0
var _pintando := false
var _inicio_toque := Vector2.ZERO
var _es_toque := false
var _animacion: Tween
var _t_resalte := 0.0


func _ready() -> void:
	set_process(false)
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
	_parar_animacion()
	zoom = 1.0
	desplazamiento = Vector2.ZERO
	_colocar()


## Lleva la camara a la zona, con zoom para que se vea bien, y la hace latir.
func enfocar(zona: int, animar: bool = true) -> void:
	if lamina == null or lamina.punto(zona).x < 0:
		return
	var ancho := float(lamina.regiones.get_width())
	var c := lamina.caja(zona)
	# la zona ocupa ~1/4 de la vista; no se aleja si ya estaba mas cerca
	var objetivo := clampf(0.25 * ancho / maxf(maxi(c.x, c.y), 1), 1.0, ZOOM_MAX)
	if zoom > objetivo and zoom < objetivo * 2.0:
		objetivo = zoom
	var p := Vector2(lamina.punto(zona)) / ancho
	_parar_animacion()
	if animar and is_inside_tree():
		var z0 := zoom
		var d0 := desplazamiento
		var d1 := _desplazamiento_para(p, objetivo)
		_animacion = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_animacion.tween_method(func(t: float):
			zoom = lerpf(z0, objetivo, t)
			desplazamiento = d0.lerp(d1, t)
			_colocar(), 0.0, 1.0, 0.45)
	else:
		zoom = objetivo
		desplazamiento = _desplazamiento_para(p, objetivo)
		_colocar()
	resaltar(zona)


## Animacion de lamina terminada: vuelve a verse entera, late una vez y las
## lineas se apagan un momento para ver solo el color.
func celebrar() -> void:
	quitar_resalte()
	_parar_animacion()
	var z0 := zoom
	var d0 := desplazamiento
	_animacion = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_animacion.tween_method(func(t: float):
		zoom = lerpf(z0, 1.0, t)
		desplazamiento = d0.lerp(Vector2.ZERO, t)
		_colocar(), 0.0, 1.0, 0.5)
	_animacion.tween_callback(func(): _contenido.pivot_offset = _contenido.size / 2.0)
	_animacion.tween_property(_contenido, "scale", Vector2(1.04, 1.04), 0.18).set_trans(Tween.TRANS_QUAD)
	_animacion.tween_property(_contenido, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK)
	var lineas := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	lineas.tween_interval(0.5)
	lineas.tween_property(_lineas, "modulate:a", 0.0, 0.45)
	lineas.tween_interval(0.5)
	lineas.tween_property(_lineas, "modulate:a", 1.0, 0.6)


func _desplazamiento_para(p: Vector2, z: float) -> Vector2:
	return size / 2.0 - p * _lado_base() * z


func resaltar(zona: int) -> void:
	resaltada = zona
	(_zonas.material as ShaderMaterial).set_shader_parameter("resaltada", zona)
	_t_resalte = 0.0
	set_process(zona > 0)


func quitar_resalte() -> void:
	resaltar(0)


func _process(delta: float) -> void:
	_t_resalte += delta
	if resaltada == 0 or _t_resalte > SEGUNDOS_RESALTE or lamina.colores[resaltada] != Lamina.BLANCO:
		quitar_resalte()
		return
	# late suave (0,45 a 0,85, unas 0,8 veces por segundo) con rayas en marcha
	var m := _zonas.material as ShaderMaterial
	m.set_shader_parameter("fuerza_resalte", 0.45 + 0.4 * (0.5 - 0.5 * cos(_t_resalte * 5.0)))
	m.set_shader_parameter("fase_resalte", _t_resalte * 1.5)


func _parar_animacion() -> void:
	if _animacion and _animacion.is_valid():
		_animacion.kill()


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
			_parar_animacion()
			_dedos[e.index] = e.position
			_es_toque = _dedos.size() == 1 and not arrastrar_pinta
			_inicio_toque = e.position
			if _dedos.size() == 1 and arrastrar_pinta:
				_pintando = true
				_ultima_zona = 0
				trazo_empezado.emit()
				_pintar_en(e.position)
			elif _pintando:
				_pintando = false
				trazo_cancelado.emit()
			if _dedos.size() == 2:
				_pellizco = _distancia_dedos()
		else:
			_dedos.erase(e.index)
			if _es_toque and _dedos.is_empty():
				_ultima_zona = 0
				trazo_empezado.emit()
				_pintar_en(e.position)
				trazo_terminado.emit()
			_es_toque = false
			if _pintando and _dedos.is_empty():
				_pintando = false
				trazo_terminado.emit()
			if _dedos.size() < 2:
				_pellizco = 0.0
		accept_event()
	elif e is InputEventScreenDrag:
		if not _dedos.has(e.index):
			return
		var antes: Vector2 = _dedos[e.index]
		_dedos[e.index] = e.position
		if _es_toque and e.position.distance_to(_inicio_toque) > MOVER_TOQUE:
			_es_toque = false
		if _dedos.size() >= 2:
			_es_toque = false
		if _dedos.size() == 2:
			var d := _distancia_dedos()
			var centro := _centro_dedos()
			if _pellizco > 0.0:
				ampliar(d / _pellizco, centro)
			_pellizco = d
			desplazamiento += (e.position - antes) / 2.0
			_colocar()
		elif not arrastrar_pinta and not _es_toque:
			desplazamiento += e.position - antes
			_colocar()
		elif _pintando:
			# todas las zonas del recorrido, aunque el dedo vaya rapido
			var n := maxi(1, ceili(antes.distance_to(e.position) / PASO_TRAZO))
			for k in range(1, n + 1):
				_pintar_en(antes.lerp(e.position, float(k) / n))
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


var _ultima_zona := 0


func _pintar_en(p: Vector2) -> void:
	if lamina == null:
		return
	var z := lamina.zona_en(a_lamina(p))
	if z > 0 and z != _ultima_zona:
		_ultima_zona = z
		zona_tocada.emit(z)
