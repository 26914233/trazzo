# Shiro, el perro de Akira. Lo sigue a un lado, se sienta cuando Akira se para y se queda
# atrás, agachado, cuando hay soldados alerta. En calma, de vez en cuando olfatea, escarba y
# desentierra unas monedas, y trae las que Akira deja atrás. No pelea y nadie le ataca:
# está en su propia capa de colisión (3) y solo choca con el escenario.
extends CharacterBody3D

const Datos := preload("res://scripts/datos.gd")

enum Estado { SEGUIR, OLFATEAR, IR_A_ESCARBAR, ESCARBAR, IR_A_MONEDA, TRAER }

signal ladro(punto: Vector3)                     # ha olido algo
signal empezo_a_escarbar(punto: Vector3)
signal desenterro(punto: Vector3)                # el juego suelta las monedas y la tierra
signal entrego(cantidad: int, punto: Vector3)    # trae monedas que Akira dejó atrás
signal aparecio(punto: Vector3)                  # se quedó lejos o atascado y vuelve junto a Akira

var visual: Node3D
var akira
var monedas                                      # el gestor de monedas del juego
var en_calma: Callable                           # lo pone el juego: ¿no hay soldados alerta cerca?
var activo := false                              # solo busca y escarba mientras se juega
var estado := Estado.SEGUIR
var mirando := Vector3.FORWARD
var azar := RandomNumberGenerator.new()
var espera_hallazgo := Datos.SHIRO_PRIMER_HALLAZGO
var temporizador := 0.0
var destino := Vector3.ZERO
var altura_destino := 0.0
var moneda_objetivo = null
var en_boca := 0
var quieto := 0.0                                # segundos parado junto a Akira (se sienta)
var atascado := 0.0
var buscar_monedas := 0.0
var moviendose := false
var corriendo := false
var alerta := false
var hallazgos := 0                               # los usa la prueba
var entregadas := 0


func _ready() -> void:
	azar.seed = 23
	collision_layer = 4
	collision_mask = 1
	floor_snap_length = 0.25
	var capsula := CapsuleShape3D.new()
	capsula.radius = 0.2
	capsula.height = 0.56
	var forma := CollisionShape3D.new()
	forma.shape = capsula
	forma.position.y = 0.28
	add_child(forma)


func _plano(vector: Vector3) -> Vector3:
	return Vector3(vector.x, 0.0, vector.z)


func _hacia(punto: Vector3, rapidez: float) -> Vector3:
	altura_destino = punto.y
	var hacia := _plano(punto - global_position)
	var distancia := hacia.length()
	if distancia < 0.05:
		return Vector3.ZERO
	# frena al llegar, para no pasarse
	return hacia / distancia * minf(rapidez, distancia * 4.0 + 1.0)


func _physics_process(delta: float) -> void:
	if akira == null:
		return
	moviendose = false
	corriendo = false
	alerta = false
	var calma: bool = activo and akira.vivo() and (not en_calma.is_valid() or en_calma.call())
	var distancia_akira := _plano(akira.global_position - global_position).length()
	if distancia_akira > Datos.SHIRO_DISTANCIA_MAXIMA:
		aparecer_junto_a_akira()
		return
	# Si empieza una pelea, deja lo que hacía (salvo traer lo que ya lleva en la boca).
	if not calma and estado in [Estado.OLFATEAR, Estado.IR_A_ESCARBAR, Estado.ESCARBAR, Estado.IR_A_MONEDA]:
		_dejar_moneda()
		estado = Estado.SEGUIR
	var deseada := Vector3.ZERO
	match estado:
		Estado.SEGUIR:
			deseada = _seguir(delta, calma)
		Estado.OLFATEAR:
			temporizador -= delta
			if temporizador <= 0.0:
				_elegir_sitio()
		Estado.IR_A_ESCARBAR:
			deseada = _hacia(destino, Datos.SHIRO_VELOCIDAD_CORRER)
			if _plano(destino - global_position).length() < 0.3 or atascado > 1.2:
				_escarbar()
		Estado.ESCARBAR:
			temporizador -= delta
			if temporizador <= 0.0:
				hallazgos += 1
				estado = Estado.SEGUIR
				espera_hallazgo = azar.randf_range(Datos.SHIRO_ESPERA_HALLAZGO.x, Datos.SHIRO_ESPERA_HALLAZGO.y)
				desenterro.emit(global_position + mirando * 0.3)
		Estado.IR_A_MONEDA:
			if not monedas.sigue_ahi(moneda_objetivo):
				moneda_objetivo = null
				estado = Estado.SEGUIR
			else:
				var punto: Vector3 = moneda_objetivo.nodo.global_position
				deseada = _hacia(punto, Datos.SHIRO_VELOCIDAD_CORRER)
				if _plano(punto - global_position).length() < 0.45:
					en_boca += monedas.tomar(moneda_objetivo)
					moneda_objetivo = null
					# llena la boca con las que haya cerca antes de volver
					if en_boca < 6:
						moneda_objetivo = monedas.buscar_cercana(global_position, 2.5, akira.global_position)
					if moneda_objetivo == null:
						estado = Estado.TRAER if en_boca > 0 else Estado.SEGUIR
				elif atascado > 2.0:
					_dejar_moneda()
					estado = Estado.SEGUIR
		Estado.TRAER:
			deseada = _hacia(akira.global_position, Datos.SHIRO_VELOCIDAD_CORRER)
			if distancia_akira < 1.3:
				_entregar()

	velocity.x = deseada.x
	velocity.z = deseada.z
	if deseada.length() > 0.1:
		moviendose = true
		corriendo = deseada.length() > Datos.SHIRO_VELOCIDAD + 0.3
		mirando = deseada.normalized()
		# Un escalón le corta el paso y lo que busca está más alto: salta.
		if is_on_floor() and is_on_wall() and altura_destino > global_position.y + 0.3:
			velocity.y = 6.8
	if not is_on_floor():
		velocity.y -= Datos.GRAVEDAD * delta
	move_and_slide()
	if moviendose and _plano(get_real_velocity()).length() < 0.5:
		atascado += delta
	else:
		atascado = 0.0
	if atascado > 2.5 and estado in [Estado.SEGUIR, Estado.TRAER]:
		aparecer_junto_a_akira()
	if visual:
		visual.actualizar(delta, info())


# Se queda detrás y a la derecha de Akira; con soldados alerta, más atrás y agachado.
func _seguir(delta: float, calma: bool) -> Vector3:
	var frente: Vector3 = akira.mirando
	var derecha := frente.cross(Vector3.UP).normalized()
	var punto: Vector3 = akira.global_position - frente * 0.9 + derecha * 0.9
	if activo and not calma and akira.vivo():
		punto = akira.global_position - frente * 2.4
		alerta = true
	var lejos := _plano(punto - global_position).length()
	if calma:
		espera_hallazgo -= delta
		buscar_monedas -= delta
		if espera_hallazgo <= 0.0:
			estado = Estado.OLFATEAR
			temporizador = Datos.SHIRO_OLFATEO
			return Vector3.ZERO
		if buscar_monedas <= 0.0 and en_boca == 0:
			buscar_monedas = 0.5
			moneda_objetivo = monedas.buscar_para_shiro(global_position, akira.global_position)
			if moneda_objetivo != null:
				estado = Estado.IR_A_MONEDA
				return Vector3.ZERO
	if lejos > 0.6:
		quieto = 0.0
		var rapidez := Datos.SHIRO_VELOCIDAD
		if akira.corriendo or lejos > 4.0:
			rapidez = Datos.SHIRO_VELOCIDAD_CORRER
		return _hacia(punto, rapidez)
	# Junto a Akira: lo mira y, si Akira no se mueve, al rato se sienta.
	var hacia_akira := _plano(akira.global_position - global_position)
	if hacia_akira.length() > 0.05:
		mirando = hacia_akira.normalized()
	if akira.moviendose:
		quieto = 0.0
	else:
		quieto += delta
	return Vector3.ZERO


# Tras olfatear, elige un sitio libre en el suelo, por delante de Akira y a unos metros
# (así las monedas quedan en su camino). Si no encuentra ninguno, escarba donde está.
func _elegir_sitio() -> void:
	var espacio := get_world_3d().direct_space_state
	var base: Vector3 = akira.global_position
	for intento in 10:
		var giro := azar.randf_range(-1.2, 1.2)
		var direccion: Vector3 = akira.mirando.rotated(Vector3.UP, giro)
		var punto: Vector3 = base + direccion * azar.randf_range(2.2, 4.2)
		if absf(punto.x) > 22.5 or absf(punto.z) > 14.5:
			continue
		var consulta := PhysicsRayQueryParameters3D.create(punto + Vector3.UP * 4.0, punto - Vector3.UP * 2.0, 1)
		var choque := espacio.intersect_ray(consulta)
		if choque.is_empty() or choque.normal.y < 0.9 or absf(choque.position.y - global_position.y) > 0.3:
			continue
		destino = choque.position
		estado = Estado.IR_A_ESCARBAR
		ladro.emit(global_position + Vector3.UP * 0.5)
		return
	destino = global_position
	ladro.emit(global_position + Vector3.UP * 0.5)
	_escarbar()


func _escarbar() -> void:
	estado = Estado.ESCARBAR
	temporizador = Datos.SHIRO_ESCARBADO
	empezo_a_escarbar.emit(global_position + mirando * 0.3)


func _dejar_moneda() -> void:
	if moneda_objetivo != null:
		monedas.liberar(moneda_objetivo)
		moneda_objetivo = null


func _entregar() -> void:
	if en_boca > 0:
		entregadas += en_boca
		entrego.emit(en_boca, global_position + Vector3.UP * 0.5)
	en_boca = 0
	estado = Estado.SEGUIR


# Aparece detrás de Akira (un poco de polvo lo disimula). Si llevaba monedas, las entrega.
func aparecer_junto_a_akira() -> void:
	_dejar_moneda()
	global_position = akira.global_position - akira.mirando * 1.3 + Vector3.UP * 0.1
	velocity = Vector3.ZERO
	atascado = 0.0
	if estado == Estado.TRAER or en_boca > 0:
		_entregar()
	estado = Estado.SEGUIR
	aparecio.emit(global_position)


# La prueba automática la usa para no esperar al azar.
func forzar_hallazgo() -> void:
	espera_hallazgo = 0.0


func info() -> Dictionary:
	var pose := "quieto"
	match estado:
		Estado.OLFATEAR:
			pose = "olfatear"
		Estado.ESCARBAR:
			pose = "escarbar"
	if pose == "quieto":
		if not is_on_floor():
			pose = "salto"
		elif moviendose:
			pose = "correr" if corriendo else "andar"
		elif alerta:
			pose = "alerta"
		elif quieto > 1.5:
			pose = "sentado"
	return {"mirando": mirando, "pose": pose, "en_boca": en_boca > 0}
