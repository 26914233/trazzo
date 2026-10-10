# Oni gigante, jefe del capítulo 1 en el portón (ficha en ronin3d/BESTIARIO.md §3):
#   1. Puñetazos: su sombra marca dónde caerá el golpe (aviso enorme, no se puede parar). Tras
#      cada golpe el puño queda en el suelo: cortarlo 3 veces inutiliza ese brazo. Son dos.
#   2. De rodillas: sin brazos, embiste con la cabeza («!», se puede parar). Un iai perfecto en
#      la embestida lo remata; los cortes a la cabeza también le quitan vida.
# Despierta cuando Akira se acerca; mientras viva, el portón no deja salir del castillo.
# Interfaz como soldado.gd, más puntos_de_golpe() y recibir_golpe_en() (dónde se le corta).
extends Node3D

const Datos := preload("res://scripts/datos.gd")
const CriaturaModular := preload("res://scripts/criatura_modular.gd")

enum Fase { DORMIDO, PUNOS, RODILLAS, MUERTO }
enum Paso { ESPERA, SOMBRA, CAIDA, EN_SUELO, VOLVER, AVISO_EMBESTIDA, EMBESTIDA, REGRESO }

signal derrotado
signal desperto
signal vida_cambiada(fraccion: float)
signal aviso_iniciado
signal estocada_iniciada
signal punetazo(punto: Vector3)
signal brazo_roto(lado: int)

const RADIO_DESPERTAR := 13.0
const ALCANCE_PUNO := 8.0
const RADIO_IMPACTO := 1.9
const AVISO_SOMBRA := 1.1
const CAIDA := 0.14
const EN_SUELO := 1.8
const GOLPES_POR_BRAZO := 3
const VIDA_CABEZA := 6
const AVISO_EMBESTIDA := 0.8
const EMBESTIDA := 0.45
const RAPIDEZ_EMBESTIDA := 13.0

var objetivo
var aspecto
var cuerpo: Node3D
var criatura: Node3D
var punos: Array = []                  # MeshInstance3D de cada puño
var reposo_puno: Array = []            # dónde descansa cada puño (local)
var golpes_brazo := [0, 0]
var brazo_vivo := [true, true]
var sombra: MeshInstance3D
var material_sombra: StandardMaterial3D
var aviso: Label3D
var fase := Fase.DORMIDO
var paso := Paso.ESPERA
var temporizador := 1.2
var lado := 0                           # brazo que golpea ahora
var punto_golpe := Vector3.ZERO
var vida_cabeza := VIDA_CABEZA
var vida := 1                           # para el HUD y las pruebas: vida que le queda en total
var destello := 0.0
var mirando := Vector3.LEFT
var inicio := Vector3.ZERO
var direccion_embestida := Vector3.ZERO
var golpe_dado := false
var muerte := -1.0
var cuerpo_estatico: StaticBody3D


func configurar(lugar: Vector3, akira, aspecto_del_juego) -> void:
	objetivo = akira
	aspecto = aspecto_del_juego
	position = lugar
	inicio = lugar
	vida = GOLPES_POR_BRAZO * 2 + VIDA_CABEZA


func _ready() -> void:
	cuerpo = Node3D.new()
	add_child(cuerpo)
	criatura = CriaturaModular.new()
	criatura.configurar(aspecto, {"familia": "bipedo", "tamano": "XL", "elemento": "fuego",
		"rol": "gigante", "semilla": 2326, "id": 2326, "rango": 1, "nombre": "Oni gigante",
		"partes": ["cuernos", "ojos"], "paleta": [Color("8e2a1c"), Color("2a1a14"), Color("ffb347")]})
	cuerpo.add_child(criatura)
	cuerpo.rotation.y = atan2(mirando.x, mirando.z)
	# Puños: grandes, oscuros, con brasas (se ven desde lejos con la cámara del móvil).
	for i in 2:
		var puno := MeshInstance3D.new()
		var esfera := SphereMesh.new()
		esfera.radius = 0.85
		esfera.height = 1.5
		puno.mesh = esfera
		var material := StandardMaterial3D.new()
		material.albedo_color = Color("6e1f15")
		material.emission_enabled = true
		material.emission = Color("ff6a2a")
		material.emission_energy_multiplier = 0.25
		puno.material_override = material
		var reposo := Vector3(-1.2, 4.2, -2.3 if i == 0 else 2.3)
		puno.position = reposo
		add_child(puno)
		punos.append(puno)
		reposo_puno.append(reposo)
	sombra = MeshInstance3D.new()
	var disco := CylinderMesh.new()
	disco.top_radius = RADIO_IMPACTO
	disco.bottom_radius = RADIO_IMPACTO
	disco.height = 0.03
	sombra.mesh = disco
	material_sombra = StandardMaterial3D.new()
	material_sombra.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material_sombra.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material_sombra.albedo_color = Color(0.05, 0.0, 0.0, 0.6)
	sombra.material_override = material_sombra
	sombra.top_level = true
	sombra.visible = false
	add_child(sombra)
	aviso = Label3D.new()
	aviso.font_size = 128
	aviso.pixel_size = 0.01
	aviso.outline_size = 22
	aviso.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	aviso.no_depth_test = true
	aviso.position.y = 7.6
	aviso.visible = false
	add_child(aviso)
	# Su cuerpo no se atraviesa (capa 2, como los personajes).
	cuerpo_estatico = StaticBody3D.new()
	cuerpo_estatico.collision_layer = 2
	var forma := CollisionShape3D.new()
	var capsula := CapsuleShape3D.new()
	capsula.radius = 1.6
	capsula.height = 6.0
	forma.shape = capsula
	forma.position.y = 3.0
	cuerpo_estatico.add_child(forma)
	add_child(cuerpo_estatico)


func vivo() -> bool:
	return fase != Fase.MUERTO


func persigue() -> bool:
	return fase in [Fase.PUNOS, Fase.RODILLAS]


func postura_rota() -> bool:
	return paso == Paso.EN_SUELO and fase == Fase.PUNOS


func despierto() -> bool:
	return fase != Fase.DORMIDO


func fraccion_vida() -> float:
	return float(vida) / float(GOLPES_POR_BRAZO * 2 + VIDA_CABEZA)


func _cabeza() -> Vector3:
	return global_position + Vector3(-1.4, 1.4, 0.0) if fase == Fase.RODILLAS else global_position + Vector3(0, 6.5, 0)


# Dónde se le puede cortar: el puño que está en el suelo (fase 1) o la cabeza (fase 2).
func puntos_de_golpe() -> Array:
	var puntos: Array = []
	if fase == Fase.PUNOS and paso == Paso.EN_SUELO and brazo_vivo[lado]:
		puntos.append({"posicion": punos[lado].global_position - Vector3(0, 0.6, 0), "radio": 1.0, "parte": "puno"})
	elif fase == Fase.RODILLAS:
		puntos.append({"posicion": _cabeza() - Vector3(0, 1.2, 0), "radio": 1.1, "parte": "cabeza"})
	return puntos


func recibir_golpe(desde: Vector3, letal := false, danio := 1, _postura := 0.0, _empuje := -1.0) -> bool:
	# Golpes sin parte (corte de luna): solo cuentan donde se le puede cortar ahora.
	var puntos := puntos_de_golpe()
	if puntos.is_empty():
		return false
	return recibir_golpe_en(String(puntos[0].parte), desde, 2 if letal else danio)


func recibir_golpe_en(parte: String, _desde: Vector3, danio := 1, _postura := 0.0, _empuje := -1.0) -> bool:
	if not vivo():
		return false
	destello = 1.0
	if parte == "puno" and brazo_vivo[lado]:
		golpes_brazo[lado] += 1
		vida -= 1
		if golpes_brazo[lado] >= GOLPES_POR_BRAZO:
			brazo_vivo[lado] = false
			(punos[lado].material_override as StandardMaterial3D).albedo_color = Color("2a2522")
			(punos[lado].material_override as StandardMaterial3D).emission_enabled = false
			brazo_roto.emit(lado)
			paso = Paso.VOLVER
			temporizador = 0.6
			if not brazo_vivo[0] and not brazo_vivo[1]:
				_arrodillarse()
	elif parte == "cabeza":
		vida_cabeza -= danio
		vida -= danio
		if vida_cabeza <= 0:
			_morir()
			vida_cambiada.emit(0.0)
			return true
	vida_cambiada.emit(fraccion_vida())
	return false


# Iai perfecto contra la embestida: lo remata.
func recibir_iai(_desde: Vector3) -> bool:
	if fase != Fase.RODILLAS:
		return false
	vida -= vida_cabeza
	vida_cabeza = 0
	_morir()
	vida_cambiada.emit(0.0)
	return true


func _arrodillarse() -> void:
	fase = Fase.RODILLAS
	paso = Paso.ESPERA
	temporizador = 1.4
	var bajar := create_tween()
	bajar.tween_property(cuerpo, "position:y", -2.2, 0.6).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	bajar.parallel().tween_property(cuerpo, "rotation:z", 0.0, 0.6)


func _morir() -> void:
	fase = Fase.MUERTO
	muerte = 0.0
	aviso.visible = false
	sombra.visible = false
	cuerpo_estatico.collision_layer = 0
	derrotado.emit()


func _plano(v: Vector3) -> Vector3:
	return Vector3(v.x, 0.0, v.z)


func _physics_process(delta: float) -> void:
	destello = maxf(0.0, destello - delta * 6.0)
	if criatura.has_method("actualizar"):
		criatura.actualizar(delta, 1.0 if despierto() else 0.2)
	match fase:
		Fase.DORMIDO:
			if objetivo and objetivo.vivo() and _plano(objetivo.global_position - global_position).length() < RADIO_DESPERTAR:
				fase = Fase.PUNOS
				paso = Paso.ESPERA
				temporizador = 1.0
				desperto.emit()
		Fase.PUNOS:
			_paso_punos(delta)
		Fase.RODILLAS:
			_paso_rodillas(delta)
		Fase.MUERTO:
			muerte = minf(1.0, muerte + delta / 2.0)
			cuerpo.position.y = -2.2 - muerte * 4.0
			cuerpo.scale = Vector3.ONE * maxf(0.05, 1.0 - muerte * 0.8)
			for puno in punos:
				puno.scale = Vector3.ONE * maxf(0.01, 1.0 - muerte)
			if muerte >= 1.0:
				visible = false
	var parpadeo := destello > 0.0 and int(destello * 20.0) % 2 == 0
	for i in 2:
		var material: StandardMaterial3D = punos[i].material_override
		if brazo_vivo[i]:
			material.emission_energy_multiplier = 2.5 if parpadeo else 0.25


func _paso_punos(delta: float) -> void:
	temporizador -= delta
	var puno: MeshInstance3D = punos[lado]
	match paso:
		Paso.ESPERA:
			if temporizador <= 0.0:
				if not brazo_vivo[lado]:
					lado = 1 - lado
				# La sombra sale donde está Akira (sin pasar del alcance del brazo).
				var hacia := _plano(objetivo.global_position - global_position)
				punto_golpe = global_position + hacia.limit_length(ALCANCE_PUNO)
				punto_golpe.y = 0.02
				paso = Paso.SOMBRA
				temporizador = AVISO_SOMBRA
				sombra.visible = true
				sombra.global_position = punto_golpe
				aviso.text = "!!"
				aviso.modulate = Color(1.0, 0.18, 0.12)
				aviso.visible = true
				aviso_iniciado.emit()
		Paso.SOMBRA:
			var t := 1.0 - temporizador / AVISO_SOMBRA
			sombra.scale = Vector3.ONE * lerpf(0.35, 1.0, t)
			material_sombra.albedo_color.a = lerpf(0.25, 0.75, t)
			puno.global_position = puno.global_position.lerp(punto_golpe + Vector3(0, 6.0, 0), minf(1.0, delta * 6.0))
			if temporizador <= 0.0:
				paso = Paso.CAIDA
				temporizador = CAIDA
				aviso.visible = false
		Paso.CAIDA:
			var t := 1.0 - temporizador / CAIDA
			puno.global_position = (punto_golpe + Vector3(0, 6.0, 0)).lerp(punto_golpe + Vector3(0, 0.75, 0), t * t)
			if temporizador <= 0.0:
				puno.global_position = punto_golpe + Vector3(0, 0.75, 0)
				sombra.visible = false
				paso = Paso.EN_SUELO
				temporizador = EN_SUELO
				punetazo.emit(punto_golpe)
				var akira_plano := _plano(objetivo.global_position - punto_golpe)
				if akira_plano.length() < RADIO_IMPACTO + Datos.RADIO_PERSONAJE and objetivo.global_position.y < 1.6:
					objetivo.recibir_golpe(punto_golpe)
		Paso.EN_SUELO:
			if temporizador <= 0.0:
				paso = Paso.VOLVER
				temporizador = 0.5
		Paso.VOLVER:
			puno.position = puno.position.lerp(reposo_puno[lado], minf(1.0, delta * 8.0))
			if temporizador <= 0.0:
				puno.position = reposo_puno[lado] if brazo_vivo[lado] else puno.position
				lado = 1 - lado
				paso = Paso.ESPERA
				temporizador = 0.7


func _paso_rodillas(delta: float) -> void:
	temporizador -= delta
	match paso:
		Paso.ESPERA:
			if temporizador <= 0.0:
				paso = Paso.AVISO_EMBESTIDA
				temporizador = AVISO_EMBESTIDA
				aviso.text = "!"
				aviso.modulate = Color(1.0, 0.92, 0.6)
				aviso.position.y = 4.0
				aviso.visible = true
				aviso_iniciado.emit()
		Paso.AVISO_EMBESTIDA:
			var hacia := _plano(objetivo.global_position - global_position)
			if hacia.length() > 0.01:
				mirando = hacia.normalized()
				cuerpo.rotation.y = lerp_angle(cuerpo.rotation.y, atan2(mirando.x, mirando.z), minf(1.0, delta * 6.0))
			if temporizador <= 0.0:
				paso = Paso.EMBESTIDA
				temporizador = EMBESTIDA
				direccion_embestida = mirando
				golpe_dado = false
				aviso.visible = false
				estocada_iniciada.emit()
		Paso.EMBESTIDA:
			global_position += direccion_embestida * RAPIDEZ_EMBESTIDA * delta
			if not golpe_dado:
				var cabeza := global_position + direccion_embestida * 1.6
				if _plano(objetivo.global_position - cabeza).length() < 1.7:
					golpe_dado = true
					if not (objetivo.has_method("intentar_parar") and objetivo.intentar_parar(self)):
						objetivo.recibir_golpe(global_position)
			if temporizador <= 0.0 and vivo():
				paso = Paso.REGRESO
				temporizador = 1.2
		Paso.REGRESO:
			global_position = global_position.lerp(inicio, minf(1.0, delta * 2.0))
			if temporizador <= 0.0:
				paso = Paso.ESPERA
				temporizador = 0.9


func info() -> Dictionary:
	return {"aviso": aviso.visible, "rojo": fase == Fase.PUNOS}
