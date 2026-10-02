# El capítulo 1 en 3D: construye el patio, crea a Akira, a Shiro (su perro), los soldados y
# la cámara, resuelve los golpes de espada, lleva la cuenta de las monedas y decide cuándo se
# gana o se pierde.
extends Node3D

const Datos := preload("res://scripts/datos.gd")
const Aspecto := preload("res://scripts/aspecto.gd")
const ConstructorMundo := preload("res://scripts/constructor_mundo.gd")
const Akira := preload("res://scripts/akira.gd")
const Soldado := preload("res://scripts/soldado.gd")
const CamaraOrbital := preload("res://scripts/camara_orbital.gd")
const VisualModelo := preload("res://scripts/visual_modelo.gd")
const Efectos := preload("res://scripts/efectos.gd")
const Shiro := preload("res://scripts/shiro.gd")
const VisualShiro := preload("res://scripts/visual_shiro.gd")
const Monedas := preload("res://scripts/monedas.gd")
const Apariencias := preload("res://scripts/apariencias_akira.gd")

signal fase_cambiada(fase: String)
signal vida_cambiada(vida: int)
signal derrotados_cambiados(cantidad: int, total: int)
signal espiritu_cambiado(valor: float)
signal mensaje(texto: String)
signal monedas_cambiadas(total: int)

var aspecto
var efectos
var constructor
var akira
var camara
var soldados: Array = []
var shiro
var monedas_suelo                    # las monedas que hay por el suelo (monedas.gd)
var monedas := 0                     # las que lleva Akira
var azar := RandomNumberGenerator.new()
var derrotados := 0
var fase := "intro"          # intro, jugando, cierre, derrota
var tiempo_derrota := 0.0


func iniciar(con_intro := true, monedas_iniciales := 0) -> void:
	monedas = monedas_iniciales
	azar.seed = 5
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
	akira.desenvaino.connect(func(): efectos.desenvaine(akira.global_position + Vector3.UP * 1.2))
	akira.paro.connect(_al_iai_perfecto)
	akira.pidio_corte_de_luna.connect(_al_pedir_corte_de_luna)
	akira.espiritu_cambiado.connect(func(valor): espiritu_cambiado.emit(valor))
	akira.vida_cambiada.connect(func(_vida): efectos.herido(akira.global_position + Vector3.UP * 1.1))

	monedas_suelo = Monedas.new()
	add_child(monedas_suelo)
	monedas_suelo.configurar(aspecto, akira)
	monedas_suelo.recogidas.connect(_al_recoger_monedas)
	_crear_shiro()

	for patrulla in Datos.PATRULLAS:
		var soldado = Soldado.new()
		add_child(soldado)
		soldado.configurar(patrulla[0], patrulla[1], akira)
		soldado.visual = _crear_visual(true)
		soldado.add_child(soldado.visual)
		soldado.derrotado.connect(_al_derrotar)
		soldado.derrotado.connect(func(): _soltar_monedas(soldado))
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
	modelo.configurar(aspecto, soldado, "" if soldado else Apariencias.elegida)
	return modelo


func _crear_shiro() -> void:
	shiro = Shiro.new()
	add_child(shiro)
	shiro.position = Datos.INICIO_AKIRA + Vector3(-1.0, 0, 1.1)
	shiro.mirando = Vector3.RIGHT
	shiro.akira = akira
	shiro.monedas = monedas_suelo
	shiro.en_calma = en_calma
	shiro.visual = VisualShiro.new()
	shiro.visual.configurar(aspecto)
	shiro.add_child(shiro.visual)
	shiro.ladro.connect(func(punto): efectos.ladrido(punto))
	shiro.empezo_a_escarbar.connect(func(punto): efectos.escarbar(punto, Datos.SHIRO_ESCARBADO))
	shiro.desenterro.connect(_al_desenterrar)
	shiro.entrego.connect(_al_recoger_monedas)
	shiro.aparecio.connect(func(punto): efectos.polvo(punto))


# Cambia el aspecto de Akira en el momento (también en pausa): la pose se aplica al instante.
func cambiar_apariencia_akira() -> void:
	var anterior: Node3D = akira.visual
	akira.visual = _crear_visual(false)
	akira.add_child(akira.visual)
	akira.visual.actualizar(0.0, akira.info())
	anterior.queue_free()


# En calma: ningún soldado persigue a Akira cerca. Solo entonces Shiro busca monedas.
func en_calma() -> bool:
	for soldado in soldados_vivos():
		if soldado.persigue() and soldado.global_position.distance_to(akira.global_position) < Datos.SHIRO_CALMA:
			return false
	return akira.vivo()


func _soltar_monedas(soldado) -> void:
	var cantidad := azar.randi_range(Datos.MONEDAS_SOLDADO.x, Datos.MONEDAS_SOLDADO.y)
	monedas_suelo.soltar(soldado.global_position + Vector3.UP * 0.9, cantidad)


func _al_desenterrar(punto: Vector3) -> void:
	efectos.desenterrar(punto)
	efectos.sonar("moneda", punto, -4.0, 0.0)
	monedas_suelo.soltar(punto + Vector3.UP * 0.2, azar.randi_range(Datos.MONEDAS_HALLAZGO.x, Datos.MONEDAS_HALLAZGO.y), 0.9)
	if shiro.hallazgos == 1:
		mensaje.emit("¡Shiro ha desenterrado unas monedas!")


func _al_recoger_monedas(cantidad: int, punto: Vector3) -> void:
	monedas += cantidad
	monedas_cambiadas.emit(monedas)
	efectos.moneda(punto)


func comenzar() -> void:
	if camara.modo_presentacion:
		camara.empezar_a_seguir()
	akira.controlable = true
	_cambiar_fase("jugando")


func _cambiar_fase(nueva: String) -> void:
	fase = nueva
	shiro.activo = fase == "jugando"
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


# Iai perfecto: Akira desvía la estocada y derriba al soldado de un solo corte.
func _al_iai_perfecto(atacante) -> void:
	efectos.iai_perfecto(_punto_entre(akira, atacante))
	atacante.recibir_golpe(akira.global_position, true)


# Corte de luna: solo se gasta la barra si hay alguien a quien cortar.
func _al_pedir_corte_de_luna() -> void:
	var objetivos: Array = soldados_vivos().filter(func(s):
		return s.global_position.distance_to(akira.global_position) <= Datos.RADIO_CORTE_LUNA)
	if objetivos.is_empty():
		mensaje.emit("No hay enemigos cerca para el corte de luna")
		return
	akira.lanzar_corte_de_luna()
	var puntos: Array = objetivos.map(func(s): return s.global_position + Vector3.UP * 1.1)
	efectos.corte_de_luna(puntos, func():
		for soldado in objetivos:
			if is_instance_valid(soldado) and soldado.vivo():
				soldado.recibir_golpe(akira.global_position, true))


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
				akira.ganar_espiritu(Datos.ESPIRITU_POR_GOLPE)
	if akira.vivo() and akira.global_position.x > Datos.LIMITE_PORTON_X and absf(akira.global_position.z) < 3.0:
		akira.controlable = false
		_cambiar_fase("cierre")
	elif not akira.vivo():
		tiempo_derrota += delta
		if tiempo_derrota > 1.4:
			_cambiar_fase("derrota")
