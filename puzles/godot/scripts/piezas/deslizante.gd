# Pieza que se desliza a lo largo de un eje y se queda en topes: paneles, cajones, libros.
# Se arrastra con el dedo (el movimiento se proyecta sobre el eje tal como se ve en pantalla)
# o se toca para ir al siguiente tope. Contra un límite bloqueado tiembla y suena seca.
class_name PiezaDeslizante
extends Pieza

var eje := Vector3.RIGHT              # dirección del movimiento, en el espacio del padre
var minimo := 0.0
var maximo := 0.05
var topes: Array = []                 # posiciones donde se queda al soltarla
var valor := 0.0
var reposo := 0.0                     # tope donde está quieta
var limite := Callable()              # opcional: func() -> Vector2, el tramo permitido ahora
var sonido_mover := "deslizar_madera"
var sonido_tope := "clic_madera"
var _animacion: Tween
var _choco := false


func configurar(eje_nuevo: Vector3, minimo_nuevo: float, maximo_nuevo: float, topes_nuevos := []) -> PiezaDeslizante:
	eje = eje_nuevo.normalized()
	minimo = minimo_nuevo
	maximo = maximo_nuevo
	topes = topes_nuevos if not topes_nuevos.is_empty() else [minimo_nuevo, maximo_nuevo]
	return self


func _transform_actual() -> Transform3D:
	return Transform3D(base.basis, base.origin + eje * valor)


func en(tope: float) -> bool:
	return absf(reposo - tope) < EPSILON


# Tramo por el que se puede mover ahora mismo
func rango() -> Vector2:
	if not puede():
		return Vector2(reposo, reposo)
	var tramo := Vector2(minimo, maximo)
	if limite.is_valid():
		var permitido: Vector2 = limite.call()
		tramo = Vector2(maxf(tramo.x, permitido.x), minf(tramo.y, permitido.y))
	return tramo


func empezar_arrastre(_punto: Vector3, _camara: Camera3D) -> void:
	if _animacion:
		_animacion.kill()
	_choco = false
	mesa.sonido.empezar_roce(sonido_mover)


func arrastrar(relativo: Vector2, _posicion: Vector2, camara: Camera3D) -> void:
	var eje_mundo: Vector3 = ((get_parent() as Node3D).global_basis * eje).normalized()
	var p0 := camara.unproject_position(global_position)
	var p1 := camara.unproject_position(global_position + eje_mundo * 0.05)
	var en_pantalla := (p1 - p0) / 0.05           # píxeles por metro a lo largo del eje
	if en_pantalla.length() < 60.0:
		return                                      # el eje apunta a la cámara: no se puede arrastrar
	var cambio := relativo.dot(en_pantalla) / en_pantalla.length_squared()
	var tramo := rango()
	var nuevo := valor + cambio
	if nuevo > tramo.y + EPSILON or nuevo < tramo.x - EPSILON:
		var por_bloqueo := tramo.x == tramo.y or (nuevo > tramo.y and tramo.y < maximo - EPSILON) \
			or (nuevo < tramo.x and tramo.x > minimo + EPSILON)
		if not _choco and absf(cambio) > 0.0003:
			_choco = true
			if por_bloqueo:
				rechazar()
			else:
				mesa.sonido.sonar(sonido_tope, -8.0, 0.8)
		nuevo = clampf(nuevo, tramo.x - 0.0012, tramo.y + 0.0012)
	var rapidez := absf(nuevo - valor) / maxf(get_process_delta_time(), 0.008)
	valor = nuevo
	mesa.sonido.roce(rapidez / 0.12)


func soltar() -> void:
	mesa.sonido.terminar_roce()
	var tramo := rango()
	_ir_a(_tope_cercano(clampf(valor, tramo.x, tramo.y), tramo), 0.14)


func tocar() -> void:
	if not puede():
		rechazar()
		return
	var disponibles := _topes_en(rango())
	if disponibles.size() < 2:
		rechazar()
		return
	var indice := 0
	for i in disponibles.size():
		if absf(disponibles[i] - reposo) < absf(disponibles[indice] - reposo):
			indice = i
	var destino: float = disponibles[indice + 1] if indice + 1 < disponibles.size() else disponibles[indice - 1]
	mesa.sonido.sonar(sonido_mover, -6.0)
	_ir_a(destino, 0.28)


# Para el guion del puzle y la prueba automática (no mira los permisos)
func mover_a(destino: float, duracion := 0.3) -> void:
	_ir_a(destino, duracion)


func _topes_en(tramo: Vector2) -> Array:
	var lista: Array = []
	for tope in topes:
		if tope >= tramo.x - EPSILON and tope <= tramo.y + EPSILON:
			lista.append(tope)
	lista.sort()
	return lista


func _tope_cercano(posicion: float, tramo: Vector2) -> float:
	var lista := _topes_en(tramo)
	if lista.is_empty():
		return clampf(posicion, tramo.x, tramo.y)
	var mejor: float = lista[0]
	for tope in lista:
		if absf(tope - posicion) < absf(mejor - posicion):
			mejor = tope
	return mejor


func _ir_a(destino: float, duracion: float) -> void:
	if _animacion:
		_animacion.kill()
	_animacion = create_tween()
	_animacion.tween_property(self, "valor", destino, duracion).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_animacion.tween_callback(_llegar.bind(destino))


func _llegar(destino: float) -> void:
	valor = destino
	if absf(destino - reposo) < EPSILON:
		return
	reposo = destino
	if mesa:
		mesa.sonido.sonar(sonido_tope, -2.0)
		mesa.vibrar(14, 0.45)
	accionada.emit(self)
