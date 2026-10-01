# Soldado con lanza: patrulla entre dos puntos, persigue a Akira sin alejarse de su
# puesto, avisa con «!» antes de atacar y lanza una estocada que alcanza más que la espada.
extends CharacterBody3D

const Datos := preload("res://scripts/datos.gd")

enum Estado { PATRULLA, ALERTA, PREPARANDO, ATACANDO, RECUPERANDO, ATURDIDO, VOLVIENDO, MUERTO }

signal derrotado
signal aviso_iniciado
signal estocada_iniciada

var visual: Node3D
var objetivo
var punto_a := Vector3.ZERO
var punto_b := Vector3.ZERO
var destino := Vector3.ZERO
var estado := Estado.PATRULLA
var vida := Datos.VIDA_SOLDADO
var mirando := Vector3.FORWARD
var temporizador := 0.0
var sin_ver := 0.0
var destello := 0.0
var muerte := -1.0
var moviendose := false
var golpe_dado := false


func configurar(a: Vector3, b: Vector3, akira) -> void:
	punto_a = a
	punto_b = b
	destino = b
	objetivo = akira
	position = a
	var recorrido := b - a
	recorrido.y = 0.0
	if recorrido.length() > 0.01:
		mirando = recorrido.normalized()


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1 | 2
	floor_snap_length = 0.25
	var capsula := CapsuleShape3D.new()
	capsula.radius = Datos.RADIO_PERSONAJE
	capsula.height = Datos.ALTO_PERSONAJE
	var forma := CollisionShape3D.new()
	forma.shape = capsula
	forma.position.y = Datos.ALTO_PERSONAJE / 2.0
	add_child(forma)


func vivo() -> bool:
	return estado != Estado.MUERTO


func _plano(vector: Vector3) -> Vector3:
	return Vector3(vector.x, 0.0, vector.z)


func _hacia(punto: Vector3, rapidez: float) -> Vector3:
	var diferencia := _plano(punto - global_position)
	if diferencia.length() < 0.05:
		return Vector3.ZERO
	return diferencia.normalized() * rapidez


func _distancia_al_puesto(punto: Vector3) -> float:
	var ab := _plano(punto_b - punto_a)
	var ap := _plano(punto - punto_a)
	var t := 0.0 if ab.length_squared() < 0.001 else clampf(ap.dot(ab) / ab.length_squared(), 0.0, 1.0)
	return (ap - ab * t).length()


func _punto_del_puesto() -> Vector3:
	var ab := _plano(punto_b - punto_a)
	var ap := _plano(global_position - punto_a)
	var t := 0.0 if ab.length_squared() < 0.001 else clampf(ap.dot(ab) / ab.length_squared(), 0.0, 1.0)
	return punto_a + (punto_b - punto_a) * t


func lo_ve() -> bool:
	if objetivo == null or not objetivo.vivo():
		return false
	var hacia: Vector3 = objetivo.global_position - global_position
	if absf(hacia.y) > 2.5:
		return false
	hacia.y = 0.0
	var distancia := hacia.length()
	if distancia < Datos.VISION_CERCANA:
		return true
	if distancia > Datos.VISION:
		return false
	return mirando.angle_to(hacia) <= deg_to_rad(Datos.CONO_VISION / 2.0)


# «letal»: el iai perfecto y el corte de luna derriban de un solo corte.
func recibir_golpe(desde: Vector3, letal := false) -> bool:
	if not vivo():
		return false
	vida -= vida if letal else 1
	destello = 1.0
	var empuje := _plano(global_position - desde)
	empuje = empuje.normalized() if empuje.length() > 0.01 else -mirando
	if vida <= 0:
		estado = Estado.MUERTO
		muerte = 0.0
		velocity = Vector3.ZERO
		collision_layer = 0
		collision_mask = 1
		mirando = -empuje
		derrotado.emit()
		return true
	estado = Estado.ATURDIDO
	temporizador = Datos.TIEMPO_ATURDIDO
	velocity = empuje * Datos.EMPUJE_SOLDADO
	mirando = -empuje
	return false


func _intentar_golpe() -> void:
	var hacia: Vector3 = objetivo.global_position - global_position
	if absf(hacia.y) > 1.2:
		return
	hacia.y = 0.0
	var a_lo_largo := hacia.dot(mirando)
	var de_lado := (hacia - mirando * a_lo_largo).length()
	if a_lo_largo > 0.0 and a_lo_largo < Datos.ALCANCE_LANZA + Datos.RADIO_PERSONAJE \
			and de_lado < Datos.ANCHO_LANZA / 2.0 + Datos.RADIO_PERSONAJE:
		golpe_dado = true
		# Si Akira acaba de desenvainar, desvía la lanza y el juego resuelve el corte.
		if not (objetivo.has_method("intentar_parar") and objetivo.intentar_parar(self)):
			objetivo.recibir_golpe(global_position)


func _physics_process(delta: float) -> void:
	destello = maxf(0.0, destello - delta * 6.0)
	var deseada := Vector3.ZERO
	moviendose = false
	match estado:
		Estado.MUERTO:
			muerte = minf(1.0, muerte + delta / Datos.TIEMPO_DESAPARECER)
			if muerte >= 1.0:
				queue_free()
				return
		Estado.PATRULLA:
			deseada = _hacia(destino, Datos.VEL_PATRULLA)
			if _plano(destino - global_position).length() < 0.3:
				destino = punto_a if destino.is_equal_approx(punto_b) else punto_b
			if lo_ve():
				estado = Estado.ALERTA
				sin_ver = 0.0
		Estado.ALERTA:
			var hacia := _plano(objetivo.global_position - global_position)
			if hacia.length() > 0.01:
				mirando = hacia.normalized()
			sin_ver = 0.0 if lo_ve() else sin_ver + delta
			if sin_ver > Datos.TIEMPO_SIN_VER or not objetivo.vivo():
				estado = Estado.VOLVIENDO
			elif hacia.length() > Datos.DISTANCIA_ATAQUE:
				if _distancia_al_puesto(global_position + mirando * 0.5) < Datos.CORREA:
					deseada = mirando * Datos.VEL_PERSECUCION
			elif absf(objetivo.global_position.y - global_position.y) < 1.0:
				estado = Estado.PREPARANDO
				temporizador = Datos.TIEMPO_AVISO
				aviso_iniciado.emit()
		Estado.PREPARANDO:
			temporizador -= delta
			if temporizador > Datos.TIEMPO_AVISO * 0.5:
				var hacia := _plano(objetivo.global_position - global_position)
				if hacia.length() > 0.01:
					mirando = hacia.normalized()
			if temporizador <= 0.0:
				estado = Estado.ATACANDO
				temporizador = Datos.TIEMPO_ESTOCADA
				golpe_dado = false
				estocada_iniciada.emit()
		Estado.ATACANDO:
			temporizador -= delta
			if not golpe_dado:
				_intentar_golpe()
			# Un iai perfecto lo puede haber derribado durante su propia estocada.
			if estado == Estado.ATACANDO and temporizador <= 0.0:
				estado = Estado.RECUPERANDO
				temporizador = Datos.TIEMPO_RECUPERACION
		Estado.RECUPERANDO:
			temporizador -= delta
			if temporizador <= 0.0:
				estado = Estado.ALERTA
		Estado.ATURDIDO:
			temporizador -= delta
			if temporizador <= 0.0:
				estado = Estado.ALERTA
		Estado.VOLVIENDO:
			var punto := _punto_del_puesto()
			deseada = _hacia(punto, Datos.VEL_PATRULLA)
			if _plano(punto - global_position).length() < 0.4:
				estado = Estado.PATRULLA
			elif lo_ve():
				estado = Estado.ALERTA
				sin_ver = 0.0

	if estado == Estado.ATURDIDO or estado == Estado.MUERTO:
		velocity.x = move_toward(velocity.x, 0.0, 14.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 14.0 * delta)
	else:
		velocity.x = deseada.x
		velocity.z = deseada.z
		if deseada.length() > 0.1:
			moviendose = true
			if estado != Estado.ALERTA:
				mirando = deseada.normalized()
	if not is_on_floor():
		velocity.y -= Datos.GRAVEDAD * delta
	move_and_slide()
	if visual:
		visual.actualizar(delta, info())


func info() -> Dictionary:
	var pose := "normal"
	if estado == Estado.PREPARANDO:
		pose = "preparando"
	elif estado == Estado.ATACANDO:
		pose = "estocada"
	return {
		"mirando": mirando,
		"moviendose": moviendose,
		"corriendo": estado == Estado.ALERTA,
		"en_aire": not is_on_floor(),
		"pose": pose,
		"progreso": 0.0,
		"visible": true,
		"destello": destello,
		"muerte": muerte,
		"aviso": estado == Estado.PREPARANDO,
	}
