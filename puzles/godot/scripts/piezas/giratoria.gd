# Pieza que gira sobre un eje: diales, ruedas de candado, manivelas, agujas, anillos.
# Al arrastrar, el dedo empuja el punto agarrado a lo largo de su giro (sirve se vea de frente o de
# canto); si se agarra por el centro, cuenta el ángulo alrededor del eje en pantalla.
# Con «paso» tiene topes: suena un clic en cada uno y al soltarla se queda en el más cercano.
class_name PiezaGiratoria
extends Pieza

var eje := Vector3.BACK               # eje de giro, en el espacio del padre
var angulo := 0.0
var minimo := -INF
var maximo := INF
var paso := 0.0                       # separación entre topes (0: gira libre)
var reposo := 0.0                     # ángulo donde quedó quieta
var radio_minimo := 0.02
var sonido_mover := ""                # roce continuo (opcional)
var sonido_tope := "clic_madera"
var volumen_tope := -6.0
var _agarre_local := Vector3.ZERO
var _ultimo_tope := 0
var _animacion: Tween
var _choco := false


func configurar(eje_nuevo: Vector3, paso_nuevo := 0.0, minimo_nuevo := -INF, maximo_nuevo := INF) -> PiezaGiratoria:
	eje = eje_nuevo.normalized()
	paso = paso_nuevo
	minimo = minimo_nuevo
	maximo = maximo_nuevo
	return self


func _transform_actual() -> Transform3D:
	return Transform3D(Basis(eje, angulo) * base.basis, base.origin)


# Tope en el que está (0, 1, 2…), contado desde 0 y dando la vuelta si hay «topes_por_vuelta»
func tope(topes_por_vuelta := 0) -> int:
	if paso <= 0.0:
		return 0
	var numero := int(round(reposo / paso))
	return posmod(numero, topes_por_vuelta) if topes_por_vuelta > 0 else numero


func vueltas() -> float:
	return angulo / TAU


func empezar_arrastre(punto: Vector3, _camara: Camera3D) -> void:
	if _animacion:
		_animacion.kill()
	_agarre_local = to_local(punto)
	_choco = false
	_ultimo_tope = int(round(angulo / paso)) if paso > 0.0 else 0
	if sonido_mover != "":
		mesa.sonido.empezar_roce(sonido_mover)


func arrastrar(relativo: Vector2, posicion: Vector2, camara: Camera3D) -> void:
	if not puede():
		if not _choco:
			_choco = true
			rechazar()
		return
	var centro := global_position
	var eje_mundo: Vector3 = ((get_parent() as Node3D).global_basis * eje).normalized()
	var agarre := to_global(_agarre_local)
	var radial := agarre - centro
	radial -= eje_mundo * radial.dot(eje_mundo)
	var cambio := 0.0
	var en_pantalla := Vector2.ZERO
	if radial.length() > radio_minimo * 0.5:
		var tangente := eje_mundo.cross(radial).normalized()
		var p0 := camara.unproject_position(agarre)
		var p1 := camara.unproject_position(agarre + tangente * 0.02)
		en_pantalla = (p1 - p0) / 0.02
	if en_pantalla.length() >= 60.0:
		cambio = (relativo.dot(en_pantalla) / en_pantalla.length_squared()) / maxf(radial.length(), radio_minimo)
	else:
		cambio = _cambio_en_pantalla(relativo, posicion, camara, centro, eje_mundo)
	_girar(cambio)
	if sonido_mover != "":
		mesa.sonido.roce(absf(cambio) / maxf(get_process_delta_time(), 0.008) / 4.0)


func _cambio_en_pantalla(relativo: Vector2, posicion: Vector2, camara: Camera3D, centro: Vector3, eje_mundo: Vector3) -> float:
	var c := camara.unproject_position(centro)
	var antes := posicion - relativo - c
	var ahora := posicion - c
	if antes.length() < 4.0 or ahora.length() < 4.0:
		return 0.0
	var giro := wrapf(ahora.angle() - antes.angle(), -PI, PI)
	# En pantalla la Y va hacia abajo: si el eje mira a la cámara, el giro positivo se ve al revés
	var hacia_camara := eje_mundo.dot(camara.global_position - centro) > 0.0
	return -giro if hacia_camara else giro


func _girar(cambio: float) -> void:
	var nuevo := angulo + cambio
	if nuevo > maximo or nuevo < minimo:
		if not _choco:
			_choco = true
			mesa.sonido.sonar(sonido_tope, -8.0, 0.8)
		nuevo = clampf(nuevo, minimo, maximo)
	angulo = nuevo
	if paso > 0.0:
		var numero := int(round(angulo / paso))
		if numero != _ultimo_tope:
			_ultimo_tope = numero
			mesa.sonido.sonar(sonido_tope, volumen_tope, 1.1)
			mesa.vibrar(8, 0.3)


func soltar() -> void:
	if sonido_mover != "":
		mesa.sonido.terminar_roce()
	var destino := angulo
	if paso > 0.0:
		destino = clampf(round(angulo / paso) * paso, minimo, maximo)
	_ir_a(destino, 0.12)


func tocar() -> void:
	if not puede():
		rechazar()
		return
	if paso <= 0.0:
		return
	var destino := reposo + paso
	if destino > maximo + EPSILON:
		destino = minimo if minimo > -INF else reposo - paso
	mesa.sonido.sonar(sonido_tope, -3.0)
	_ir_a(destino, 0.22)


func mover_a(destino: float, duracion := 0.3) -> void:
	_ir_a(destino, duracion)


func _ir_a(destino: float, duracion: float) -> void:
	if _animacion:
		_animacion.kill()
	_animacion = create_tween()
	_animacion.tween_property(self, "angulo", destino, duracion).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_animacion.tween_callback(_llegar.bind(destino))


func _llegar(destino: float) -> void:
	angulo = destino
	if absf(destino - reposo) < 0.0001:
		return
	reposo = destino
	if mesa:
		mesa.vibrar(10, 0.35)
	accionada.emit(self)
