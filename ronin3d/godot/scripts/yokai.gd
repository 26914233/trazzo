# Yōkai del bestiario como enemigo (kappa, oni, onibi…): el perfil sale de enemigos.gd y el
# aspecto, de la receta del bestiario (modelo detallado si existe; si no, de piezas). Tiene la
# misma interfaz que soldado.gd, así que la espada, el iai, el corte de luna y la ayuda para
# encarar funcionan igual con ellos.
extends CharacterBody3D

const Datos := preload("res://scripts/datos.gd")
const Enemigos := preload("res://scripts/enemigos.gd")
const VisualYokai := preload("res://scripts/visual_yokai.gd")

enum Estado { QUIETO, ALERTA, PREPARANDO, ATACANDO, RECUPERANDO, ATURDIDO, REVERENCIA, MUERTO }

signal derrotado
signal aviso_iniciado
signal estocada_iniciada

# Solo un onibi del enjambre se lanza a la vez.
static var onibi_lanzandose = null

var tipo := ""
var perfil: Dictionary = {}
var visual: Node3D
var objetivo
var puesto := Vector3.ZERO
var estado := Estado.QUIETO
var vida := 1
var vida_maxima := 1
var mirando := Vector3.FORWARD
var temporizador := 0.0
var destello := 0.0
var postura := 0.0
var peso := 1.0
var rota := 0.0
var muerte := -1.0
var moviendose := false
var golpe_dado := false
var ataque: Dictionary = {}
var indice_ataque := 0
var tiempo_reverencia := 0.0          # (kappa) segundos con Akira en postura delante
var sin_agua := false                 # (kappa) derramó el agua del plato: un golpe lo derriba
var angulo_orbita := 0.0
var azar := RandomNumberGenerator.new()


func configurar(tipo_nuevo: String, lugar: Vector3, akira, aspecto) -> void:
	tipo = tipo_nuevo
	perfil = Enemigos.perfil(tipo)
	vida = int(perfil.vida)
	vida_maxima = vida
	peso = float(perfil.peso)
	objetivo = akira
	puesto = lugar
	position = lugar
	azar.seed = hash(lugar)
	angulo_orbita = azar.randf() * TAU
	visual = VisualYokai.new()
	visual.configurar(aspecto, perfil)
	add_child(visual)


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1 | 2
	floor_snap_length = 0.25
	var capsula := CapsuleShape3D.new()
	var escala: float = {"S": 0.6, "M": 1.0, "L": 1.5}.get(String(perfil.receta.tamano), 1.0)
	capsula.radius = Datos.RADIO_PERSONAJE * maxf(escala, 0.8)
	capsula.height = maxf(Datos.ALTO_PERSONAJE * escala, capsula.radius * 2.0 + 0.1)
	var forma := CollisionShape3D.new()
	forma.shape = capsula
	forma.position.y = capsula.height / 2.0 + (0.6 if perfil.get("flota", false) else 0.0)
	add_child(forma)
	if perfil.get("flota", false):
		collision_mask = 1


func vivo() -> bool:
	return estado != Estado.MUERTO


func persigue() -> bool:
	return estado in [Estado.ALERTA, Estado.PREPARANDO, Estado.ATACANDO, Estado.RECUPERANDO, Estado.ATURDIDO]


func postura_rota() -> bool:
	return rota > 0.0


func _plano(v: Vector3) -> Vector3:
	return Vector3(v.x, 0.0, v.z)


func _hacia_objetivo() -> Vector3:
	return _plano(objetivo.global_position - global_position)


func lo_ve() -> bool:
	if objetivo == null or not objetivo.vivo():
		return false
	return _hacia_objetivo().length() < float(perfil.vision) and absf(objetivo.global_position.y - global_position.y) < 2.5


# Golpe de Akira. Con la postura rota (o el kappa sin agua) el golpe remata.
func recibir_golpe(desde: Vector3, letal := false, danio := 1, postura_golpe := 0.0,
		empuje_golpe := -1.0) -> bool:
	if not vivo():
		return false
	if rota > 0.0 or sin_agua:
		letal = true
	vida -= vida if letal else danio
	destello = 1.0
	var empuje := _plano(global_position - desde)
	empuje = empuje.normalized() if empuje.length() > 0.01 else -mirando
	if vida <= 0:
		_morir(empuje)
		return true
	postura += postura_golpe / maxf(peso * 0.6, 0.5)
	if estado != Estado.ATACANDO or peso < 2.0:
		# El oni no se inmuta si le pegan mientras golpea: solo el iai o romperle la postura.
		estado = Estado.ATURDIDO
		temporizador = Datos.TIEMPO_ATURDIDO
	if postura >= 1.0:
		postura = 0.0
		rota = Datos.TIEMPO_POSTURA_ROTA
		estado = Estado.ATURDIDO
		temporizador = Datos.TIEMPO_POSTURA_ROTA
	var fuerza := Datos.EMPUJE_SOLDADO if empuje_golpe < 0.0 else empuje_golpe
	velocity = empuje * fuerza / peso
	return false


# Iai perfecto contra su ataque. El oni lo aguanta (aturdido y con 3 menos); al kappa le
# derrama el agua del plato.
func recibir_iai(desde: Vector3) -> bool:
	if perfil.has("resiste_iai"):
		var resiste: Dictionary = perfil.resiste_iai
		var murio := recibir_golpe(desde, false, int(resiste.danio), 0.0, 4.0)
		if not murio:
			estado = Estado.ATURDIDO
			temporizador = float(resiste.aturdido)
			rota = float(resiste.aturdido)
		return murio
	return recibir_golpe(desde, true)


func _morir(empuje: Vector3) -> void:
	estado = Estado.MUERTO
	muerte = 0.0
	velocity = empuje * 3.0
	collision_layer = 0
	collision_mask = 1
	if onibi_lanzandose == self:
		onibi_lanzandose = null
	derrotado.emit()


func _empezar_ataque() -> void:
	var ataques: Array = perfil.ataques
	# El oni alterna: barrido, barrido, kanabō…
	ataque = ataques[indice_ataque % ataques.size()] if ataques.size() < 2 \
		else ataques[1 if indice_ataque % 3 == 2 else 0]
	indice_ataque += 1
	estado = Estado.PREPARANDO
	temporizador = float(ataque.aviso)
	aviso_iniciado.emit()


func _intentar_golpe() -> void:
	var hacia: Vector3 = objetivo.global_position - global_position
	if absf(hacia.y) > 1.5:
		return
	hacia.y = 0.0
	var a_lo_largo := hacia.dot(mirando)
	var de_lado := (hacia - mirando * a_lo_largo).length()
	if a_lo_largo > -0.3 and a_lo_largo < float(ataque.alcance) + Datos.RADIO_PERSONAJE \
			and de_lado < float(ataque.ancho) / 2.0 + Datos.RADIO_PERSONAJE:
		golpe_dado = true
		if ataque.parable and objetivo.has_method("intentar_parar") and objetivo.intentar_parar(self):
			return
		for i in int(ataque.danio):
			if objetivo.recibir_golpe(global_position) and i + 1 < int(ataque.danio):
				objetivo.invulnerable = 0.0       # el kanabō quita 2: el segundo, sin esperar


func _physics_process(delta: float) -> void:
	destello = maxf(0.0, destello - delta * 6.0)
	rota = maxf(0.0, rota - delta)
	if estado != Estado.ATURDIDO and rota <= 0.0:
		postura = maxf(0.0, postura - delta * Datos.RECUPERA_POSTURA)
	var deseada := Vector3.ZERO
	moviendose = false
	var hacia := _hacia_objetivo() if objetivo else Vector3.ZERO
	match estado:
		Estado.MUERTO:
			muerte = minf(1.0, muerte + delta / Datos.TIEMPO_DESAPARECER)
			if muerte >= 1.0:
				queue_free()
				return
		Estado.QUIETO:
			if lo_ve():
				estado = Estado.ALERTA
		Estado.ALERTA:
			if hacia.length() > 0.01:
				mirando = hacia.normalized()
			if perfil.get("reverencia", false) and not sin_agua and _esperado_en_postura(hacia):
				_mirar_reverencia(delta)
			elif not lo_ve() and _plano(global_position - puesto).length() > 0.5:
				deseada = _plano(puesto - global_position).normalized() * float(perfil.velocidad) * 0.6
				if _plano(puesto - global_position).length() < 0.6:
					estado = Estado.QUIETO
			elif perfil.has("orbita"):
				deseada = _orbitar(delta, hacia)
			elif hacia.length() > float(perfil.distancia_ataque):
				if _plano(global_position + mirando - puesto).length() < float(perfil.correa):
					deseada = mirando * float(perfil.velocidad)
			else:
				_empezar_ataque()
		Estado.PREPARANDO:
			temporizador -= delta
			if temporizador > float(ataque.aviso) * 0.4 and hacia.length() > 0.01:
				mirando = hacia.normalized()
			if temporizador <= 0.0:
				estado = Estado.ATACANDO
				temporizador = float(ataque.activo)
				golpe_dado = false
				estocada_iniciada.emit()
		Estado.ATACANDO:
			temporizador -= delta
			deseada = mirando * float(ataque.embestida)
			if not golpe_dado:
				_intentar_golpe()
			if estado == Estado.ATACANDO and temporizador <= 0.0:
				estado = Estado.RECUPERANDO
				temporizador = float(ataque.recuperacion)
		Estado.RECUPERANDO:
			temporizador -= delta
			if temporizador <= 0.0:
				estado = Estado.ALERTA
				if onibi_lanzandose == self:
					onibi_lanzandose = null
		Estado.ATURDIDO:
			temporizador -= delta
			if temporizador <= 0.0:
				estado = Estado.ALERTA
		Estado.REVERENCIA:
			temporizador -= delta
			if temporizador <= 0.0:
				estado = Estado.ALERTA

	if estado in [Estado.ATURDIDO, Estado.MUERTO, Estado.REVERENCIA]:
		velocity.x = move_toward(velocity.x, 0.0, 14.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 14.0 * delta)
	else:
		velocity.x = deseada.x
		velocity.z = deseada.z
		moviendose = deseada.length() > 0.1
	if perfil.get("flota", false):
		velocity.y = 0.0
	elif not is_on_floor():
		velocity.y -= Datos.GRAVEDAD * delta
	move_and_slide()
	if visual:
		visual.actualizar(delta, info())


# El enjambre gira alrededor de Akira; de vez en cuando uno se lanza (solo uno a la vez).
func _orbitar(delta: float, hacia: Vector3) -> Vector3:
	angulo_orbita += delta * 0.9
	var radio := float(perfil.orbita)
	var punto: Vector3 = objetivo.global_position + Vector3(cos(angulo_orbita), 0.0, sin(angulo_orbita)) * radio
	var deseada := _plano(punto - global_position)
	if onibi_lanzandose == null and hacia.length() < float(perfil.distancia_ataque) \
			and azar.randf() < delta * 0.6:
		onibi_lanzandose = self
		_empezar_ataque()
		return Vector3.ZERO
	return deseada.limit_length(1.0) * float(perfil.velocidad)


# El kappa es cortés: si Akira lo espera en postura de iai, de frente y cerca, el kappa no
# ataca; a los 2 s hace la reverencia y se le derrama el agua del plato.
func _esperado_en_postura(hacia: Vector3) -> bool:
	var de_frente: bool = objetivo.en_postura and hacia.length() < 4.0 and hacia.length() > 0.01 \
		and objetivo.mirando.dot(-hacia.normalized()) > 0.6
	if not de_frente:
		tiempo_reverencia = 0.0
	return de_frente


func _mirar_reverencia(delta: float) -> void:
	tiempo_reverencia += delta
	if tiempo_reverencia >= 2.0:
		tiempo_reverencia = 0.0
		sin_agua = true
		estado = Estado.REVERENCIA
		temporizador = 1.2


func info() -> Dictionary:
	var pose := "normal"
	if estado == Estado.PREPARANDO:
		pose = "preparando"
	elif estado == Estado.ATACANDO:
		pose = "estocada"
	elif estado == Estado.REVERENCIA:
		pose = "reverencia"
	elif estado == Estado.ATURDIDO:
		pose = "aturdido"
	return {
		"mirando": mirando,
		"moviendose": moviendose,
		"pose": pose,
		"destello": destello,
		"muerte": muerte,
		"aviso": estado == Estado.PREPARANDO,
		"rojo": estado == Estado.PREPARANDO and ataque.get("rojo", false),
		"rota": rota > 0.0,
		"sin_agua": sin_agua,
	}
