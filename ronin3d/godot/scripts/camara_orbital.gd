# Cámara que gira alrededor de Akira: Q/E, botón derecho + arrastrar, rueda o +/−
# para el zoom y R/F para inclinarla. Al bajarla mira un poco hacia arriba, para ver
# el torreón y la luna. Durante la intro muestra un plano fijo del castillo.
extends Node3D

const Datos := preload("res://scripts/datos.gd")
const DURACION_TRANSICION := 1.1

var objetivo: Node3D
var camara: Camera3D
var giro := Datos.CAMARA_GIRO
var inclinacion := Datos.CAMARA_INCLINACION
var distancia := Datos.CAMARA_DISTANCIA
var centro := Vector3.ZERO
var modo_presentacion := false
var transicion := 0.0
var tiempo := 0.0


func _ready() -> void:
	camara = Camera3D.new()
	camara.fov = Datos.CAMARA_FOV
	camara.near = 0.1
	camara.far = 320.0
	add_child(camara)
	camara.current = true
	colocar_de_golpe()


func colocar_de_golpe() -> void:
	if objetivo:
		centro = objetivo.global_position
	_colocar(1.0)


func empezar_a_seguir() -> void:
	# De la presentación a la órbita sobre Akira, con una transición suave.
	modo_presentacion = false
	transicion = DURACION_TRANSICION


func adelante() -> Vector3:
	var g := deg_to_rad(giro)
	return Vector3(-sin(g), 0.0, -cos(g))


func derecha() -> Vector3:
	var g := deg_to_rad(giro)
	return Vector3(cos(g), 0.0, -sin(g))


func altura_mirada() -> float:
	# 1 m con la cámara alta; hasta 2,2 m con la cámara baja (se mira hacia arriba).
	var t := clampf((inclinacion - Datos.CAMARA_INCLINACION_MIN) / (30.0 - Datos.CAMARA_INCLINACION_MIN), 0.0, 1.0)
	return lerpf(2.2, 1.0, t)


func _process(delta: float) -> void:
	tiempo += delta
	if not modo_presentacion and transicion <= 0.0:
		if Input.is_action_pressed("girar_izquierda"):
			giro -= 90.0 * delta
		if Input.is_action_pressed("girar_derecha"):
			giro += 90.0 * delta
		if Input.is_action_pressed("inclinar_arriba"):
			inclinacion += 40.0 * delta
		if Input.is_action_pressed("inclinar_abajo"):
			inclinacion -= 40.0 * delta
		if Input.is_action_pressed("acercar"):
			distancia -= 8.0 * delta
		if Input.is_action_pressed("alejar"):
			distancia += 8.0 * delta
	inclinacion = clampf(inclinacion, Datos.CAMARA_INCLINACION_MIN, Datos.CAMARA_INCLINACION_MAX)
	distancia = clampf(distancia, Datos.CAMARA_DISTANCIA_MIN, Datos.CAMARA_DISTANCIA_MAX)
	if objetivo:
		centro = centro.lerp(objetivo.global_position, minf(1.0, delta * 8.0))
	var mezcla := 1.0
	if modo_presentacion:
		mezcla = 0.0
	elif transicion > 0.0:
		transicion = maxf(0.0, transicion - delta)
		mezcla = smoothstep(0.0, 1.0, 1.0 - transicion / DURACION_TRANSICION)
	_colocar(mezcla)


func _colocar(mezcla: float) -> void:
	if camara == null:
		return
	var g := deg_to_rad(giro)
	var i := deg_to_rad(inclinacion)
	var mira_orbita := centro + Vector3(0, altura_mirada(), 0)
	var posicion_orbita := mira_orbita + Vector3(sin(g) * cos(i), sin(i), cos(g) * cos(i)) * distancia
	var vaiven := Vector3(sin(tiempo * 0.35) * 1.5, 0.0, 0.0)
	var posicion_presentacion := Datos.CAMARA_PRESENTACION_POSICION + vaiven
	var mira_presentacion := Datos.CAMARA_PRESENTACION_MIRA
	if mezcla > 0.0:
		posicion_orbita = _evitar_muros(mira_orbita, posicion_orbita)
	var posicion := posicion_presentacion.lerp(posicion_orbita, mezcla)
	var mira := mira_presentacion.lerp(mira_orbita, mezcla)
	camara.global_position = posicion
	camara.look_at(mira, Vector3.UP)


func _evitar_muros(desde: Vector3, hasta: Vector3) -> Vector3:
	# Rayo desde el punto mirado hasta la cámara: si choca con el escenario (capa 1),
	# la cámara se queda justo delante del obstáculo.
	if not is_inside_tree():
		return hasta
	var consulta := PhysicsRayQueryParameters3D.create(desde, hasta, 1)
	var choque := get_world_3d().direct_space_state.intersect_ray(consulta)
	if choque.is_empty():
		return hasta
	var punto: Vector3 = choque.position
	return punto + (desde - punto).normalized() * 0.4


func _unhandled_input(evento: InputEvent) -> void:
	if modo_presentacion or transicion > 0.0:
		return
	if evento is InputEventMouseMotion and (evento.button_mask & MOUSE_BUTTON_MASK_RIGHT):
		giro -= evento.relative.x * 0.3
		inclinacion += evento.relative.y * 0.2
	elif evento is InputEventMouseButton and evento.pressed:
		if evento.button_index == MOUSE_BUTTON_WHEEL_UP:
			distancia -= 1.0
		elif evento.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distancia += 1.0
