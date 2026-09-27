# Akira en 3D: se mueve relativo a la cámara, corre, salta y ataca con la espada.
extends CharacterBody3D

const Datos := preload("res://scripts/datos.gd")

signal vida_cambiada(vida: int)
signal cayo
signal ataco
signal paro(atacante)

var visual: Node3D
var camara
var vida := Datos.VIDA_MAXIMA
var mirando := Vector3.RIGHT
var controlable := false
var invulnerable := 0.0
var empujado := 0.0
var tiempo_ataque := 0.0
var enfriamiento := 0.0
var golpeados: Array = []
var destello := 0.0
var muerte := -1.0
var moviendose := false
var corriendo := false
var buffer_salto := 0.0
var coyote := 0.0
var tiempo_parada := 0.0
var enfriamiento_parada := 0.0
var pose_parada := 0.0
var buscar_rival: Callable            # lo pone el juego: devuelve el soldado más cercano


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
	return vida > 0


func atacando() -> bool:
	return tiempo_ataque > 0.0


func progreso_ataque() -> float:
	return clampf(1.0 - tiempo_ataque / Datos.DURACION_ATAQUE, 0.0, 1.0)


func corte_activo() -> bool:
	var transcurrido := Datos.DURACION_ATAQUE - tiempo_ataque
	return atacando() and transcurrido >= Datos.INICIO_CORTE and transcurrido <= Datos.FIN_CORTE


func iniciar_ataque() -> void:
	if vivo() and enfriamiento <= 0.0 and empujado <= 0.0:
		tiempo_ataque = Datos.DURACION_ATAQUE
		enfriamiento = Datos.ENFRIAMIENTO_ATAQUE
		golpeados.clear()
		tiempo_parada = 0.0
		pose_parada = 0.0
		ataco.emit()


func iniciar_parada() -> void:
	if not vivo() or empujado > 0.0 or atacando() or enfriamiento_parada > 0.0:
		return
	tiempo_parada = Datos.VENTANA_PARADA
	enfriamiento_parada = Datos.ENFRIAMIENTO_PARADA
	pose_parada = Datos.POSE_PARADA
	# Ayuda: se gira hacia el soldado más cercano, para que parar no dependa de apuntar.
	if buscar_rival.is_valid():
		var rival = buscar_rival.call(global_position, Datos.ALCANCE_AYUDA_PARADA)
		if rival:
			var hacia: Vector3 = rival.global_position - global_position
			hacia.y = 0.0
			if hacia.length() > 0.01:
				mirando = hacia.normalized()


# La llama el soldado justo antes de que su estocada dé en Akira. Si Akira está parando
# y mira hacia él, desvía el golpe.
func intentar_parar(atacante) -> bool:
	if tiempo_parada <= 0.0 or not vivo():
		return false
	var hacia: Vector3 = atacante.global_position - global_position
	hacia.y = 0.0
	if hacia.length() > 0.01 and mirando.angle_to(hacia) > deg_to_rad(Datos.CONO_PARADA / 2.0):
		return false
	tiempo_parada = 0.0
	enfriamiento_parada = 0.0            # premio: puede contraatacar o volver a parar ya
	paro.emit(atacante)
	return true


func recibir_golpe(desde: Vector3) -> bool:
	if invulnerable > 0.0 or not vivo():
		return false
	vida -= 1
	vida_cambiada.emit(vida)
	invulnerable = Datos.TIEMPO_INVULNERABLE
	destello = 1.0
	tiempo_ataque = 0.0
	var empuje := global_position - desde
	empuje.y = 0.0
	empuje = empuje.normalized() if empuje.length() > 0.01 else -mirando
	velocity = empuje * Datos.EMPUJE_GOLPE + Vector3(0, 4.0, 0)
	empujado = Datos.TIEMPO_EMPUJE
	if vida <= 0:
		muerte = 0.0
		cayo.emit()
	return true


func _physics_process(delta: float) -> void:
	invulnerable = maxf(0.0, invulnerable - delta)
	empujado = maxf(0.0, empujado - delta)
	tiempo_ataque = maxf(0.0, tiempo_ataque - delta)
	enfriamiento = maxf(0.0, enfriamiento - delta)
	buffer_salto = maxf(0.0, buffer_salto - delta)
	coyote = maxf(0.0, coyote - delta)
	destello = maxf(0.0, destello - delta * 6.0)
	tiempo_parada = maxf(0.0, tiempo_parada - delta)
	enfriamiento_parada = maxf(0.0, enfriamiento_parada - delta)
	pose_parada = maxf(0.0, pose_parada - delta)

	var entrada := Vector2.ZERO
	if controlable and vivo():
		entrada = Input.get_vector("mover_izquierda", "mover_derecha", "mover_adelante", "mover_atras")
		if Input.is_action_just_pressed("saltar"):
			buffer_salto = 0.12
		if Input.is_action_just_pressed("atacar"):
			iniciar_ataque()
		if Input.is_action_just_pressed("parar"):
			iniciar_parada()
	var direccion: Vector3 = camara.derecha() * entrada.x - camara.adelante() * entrada.y

	if not vivo():
		velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)
		muerte = minf(1.0, muerte + delta / 0.8)
		moviendose = false
	elif empujado > 0.0:
		moviendose = false
	else:
		var rapidez := Datos.VELOCIDAD
		if controlable and Input.is_action_pressed("correr"):
			rapidez = Datos.VELOCIDAD_CORRER
		if (atacando() or pose_parada > 0.0) and is_on_floor():
			rapidez *= 0.4
		velocity.x = direccion.x * rapidez
		velocity.z = direccion.z * rapidez
		moviendose = direccion.length() > 0.1
		corriendo = moviendose and rapidez > Datos.VELOCIDAD
		if moviendose and not atacando() and pose_parada <= 0.0:
			mirando = direccion.normalized()
		if buffer_salto > 0.0 and (is_on_floor() or coyote > 0.0):
			velocity.y = Datos.IMPULSO_SALTO
			buffer_salto = 0.0
			coyote = 0.0

	if is_on_floor():
		coyote = 0.1
	else:
		velocity.y -= Datos.GRAVEDAD * delta
	move_and_slide()
	if visual:
		visual.actualizar(delta, info())


func info() -> Dictionary:
	var parpadea := invulnerable > 0.0 and invulnerable <= Datos.TIEMPO_INVULNERABLE \
		and vivo() and int(invulnerable * 14.0) % 2 == 0
	return {
		"mirando": mirando,
		"moviendose": moviendose,
		"corriendo": corriendo,
		"en_aire": not is_on_floor(),
		"pose": "ataque" if atacando() else ("guardia" if pose_parada > 0.0 else "normal"),
		"progreso": progreso_ataque(),
		"visible": not parpadea,
		"destello": destello,
		"muerte": muerte,
		"aviso": false,
	}
