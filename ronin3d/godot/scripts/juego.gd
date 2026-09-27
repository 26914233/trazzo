# El capítulo 1 en 3D: construye el patio, crea a Akira, los soldados y la cámara,
# resuelve los golpes de espada y decide cuándo se gana o se pierde.
extends Node3D

const Datos := preload("res://scripts/datos.gd")
const Aspecto := preload("res://scripts/aspecto.gd")
const ConstructorMundo := preload("res://scripts/constructor_mundo.gd")
const Akira := preload("res://scripts/akira.gd")
const Soldado := preload("res://scripts/soldado.gd")
const CamaraOrbital := preload("res://scripts/camara_orbital.gd")
const VisualModelo := preload("res://scripts/visual_modelo.gd")
const Efectos := preload("res://scripts/efectos.gd")

signal fase_cambiada(fase: String)
signal vida_cambiada(vida: int)
signal derrotados_cambiados(cantidad: int, total: int)

var aspecto
var efectos
var constructor
var akira
var camara
var soldados: Array = []
var derrotados := 0
var fase := "intro"          # intro, jugando, cierre, derrota
var tiempo_derrota := 0.0


func iniciar(con_intro := true) -> void:
	aspecto = Aspecto.new()
	constructor = ConstructorMundo.new()
	constructor.construir(self, aspecto)

	akira = Akira.new()
	add_child(akira)
	akira.position = Datos.INICIO_AKIRA
	akira.visual = _crear_visual(false)
	akira.add_child(akira.visual)
	akira.vida_cambiada.connect(func(vida): vida_cambiada.emit(vida))

	camara = CamaraOrbital.new()
	camara.objetivo = akira
	add_child(camara)
	akira.camara = camara

	efectos = Efectos.new()
	efectos.camara = camara
	add_child(efectos)
	akira.buscar_rival = soldado_mas_cercano
	akira.ataco.connect(func(): efectos.tajo(akira.global_position + Vector3.UP * 1.2))
	akira.paro.connect(func(atacante): efectos.parada(_punto_entre(akira, atacante)))
	akira.vida_cambiada.connect(func(_vida): efectos.herido(akira.global_position + Vector3.UP * 1.1))

	for patrulla in Datos.PATRULLAS:
		var soldado = Soldado.new()
		add_child(soldado)
		soldado.configurar(patrulla[0], patrulla[1], akira)
		soldado.visual = _crear_visual(true)
		soldado.add_child(soldado.visual)
		soldado.derrotado.connect(_al_derrotar)
		soldado.aviso_iniciado.connect(func(): efectos.aviso(soldado.global_position + Vector3.UP * 2.0))
		soldado.estocada_iniciada.connect(func(): efectos.estocada(soldado.global_position + Vector3.UP * 1.1))
		soldados.append(soldado)

	if con_intro:
		camara.modo_presentacion = true
		_cambiar_fase("intro")
	else:
		comenzar()


func _crear_visual(soldado: bool) -> Node3D:
	var modelo = VisualModelo.new()
	modelo.configurar(aspecto, soldado)
	return modelo


func comenzar() -> void:
	if camara.modo_presentacion:
		camara.empezar_a_seguir()
	akira.controlable = true
	_cambiar_fase("jugando")


func _cambiar_fase(nueva: String) -> void:
	fase = nueva
	fase_cambiada.emit(fase)


func _al_derrotar() -> void:
	derrotados += 1
	derrotados_cambiados.emit(derrotados, Datos.PATRULLAS.size())


func _en_alcance_espada(soldado) -> bool:
	var hacia: Vector3 = soldado.global_position - akira.global_position
	if absf(hacia.y) > 1.2:
		return false
	hacia.y = 0.0
	var distancia := hacia.length()
	if distancia > Datos.ALCANCE_ESPADA + Datos.RADIO_PERSONAJE:
		return false
	if distancia < 0.5:
		return true
	return akira.mirando.angle_to(hacia) <= deg_to_rad(Datos.CONO_ESPADA / 2.0)


func soldados_vivos() -> Array:
	return soldados.filter(func(s): return is_instance_valid(s) and s.vivo())


func soldado_mas_cercano(desde: Vector3, alcance: float):
	var mejor = null
	var mejor_distancia := alcance
	for soldado in soldados_vivos():
		var distancia: float = soldado.global_position.distance_to(desde)
		if distancia < mejor_distancia:
			mejor = soldado
			mejor_distancia = distancia
	return mejor


func _punto_entre(a: Node3D, b: Node3D) -> Vector3:
	return (a.global_position + b.global_position) / 2.0 + Vector3.UP * 1.15


func _physics_process(delta: float) -> void:
	constructor.actualizar(delta)
	if fase != "jugando":
		return
	if akira.corte_activo():
		for soldado in soldados_vivos():
			if not akira.golpeados.has(soldado) and _en_alcance_espada(soldado):
				akira.golpeados.append(soldado)
				var mortal: bool = soldado.recibir_golpe(akira.global_position)
				efectos.golpe(_punto_entre(akira, soldado), mortal)
	if akira.vivo() and akira.global_position.x > Datos.LIMITE_PORTON_X and absf(akira.global_position.z) < 3.0:
		akira.controlable = false
		_cambiar_fase("cierre")
	elif not akira.vivo():
		tiempo_derrota += delta
		if tiempo_derrota > 1.4:
			_cambiar_fase("derrota")
