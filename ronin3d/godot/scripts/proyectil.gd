# Proyectil de un enemigo: la flecha del elfo oscuro, la tela de la jorōgumo, la bola de fuego del
# ifrit, el fuego de zorro de la kitsune y de Tamamo, el viento de Sōjōbō. Vuela recto hacia donde
# estaba Akira al soltarlo. Si lo toca, le hace daño (la tela, además, lo deja atrapado); pero un iai
# perfecto en el momento justo lo devuelve contra quien lo lanzó (como desviar una flecha).
extends Node3D

const Datos := preload("res://scripts/datos.gd")

var dueno                             # el enemigo que lo lanzó
var objetivo                          # Akira
var efectos
var velocidad := Vector3.ZERO
var rapidez := 12.0
var vida_restante := 2.6
var radio := 0.4
var danio := 1
var parable := true
var efecto := ""                      # «atrapa»: deja a Akira sin poder moverse un momento
var devuelto := false
var color := Color(1.0, 0.55, 0.2)
var pieza: MeshInstance3D


func lanzar(desde: Vector3, hacia: Vector3, ataque: Dictionary, dueno_nuevo, objetivo_nuevo, efectos_nuevos) -> void:
	top_level = true
	dueno = dueno_nuevo
	objetivo = objetivo_nuevo
	efectos = efectos_nuevos
	rapidez = float(ataque.get("rapidez", 12.0))
	danio = int(ataque.danio)
	parable = bool(ataque.parable)
	efecto = String(ataque.get("efecto", ""))
	color = ataque.get("color", color)
	var direccion := hacia - desde
	direccion.y = 0.0
	direccion = direccion.normalized() if direccion.length() > 0.01 else Vector3.RIGHT
	velocidad = direccion * rapidez
	pieza = MeshInstance3D.new()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 2.5
	pieza.material_override = material
	pieza.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if ataque.get("visual", "bola") == "flecha":
		var flecha := BoxMesh.new()
		flecha.size = Vector3(0.06, 0.06, 0.8)
		pieza.mesh = flecha
	elif ataque.get("visual", "bola") == "tela":
		var tela := SphereMesh.new()
		tela.radius = 0.32
		tela.height = 0.2
		tela.radial_segments = 8
		tela.rings = 3
		pieza.mesh = tela
	else:
		var bola := SphereMesh.new()
		bola.radius = 0.22
		bola.height = 0.44
		bola.radial_segments = 10
		bola.rings = 5
		pieza.mesh = bola
	add_child(pieza)
	global_position = desde
	_orientar()


func _orientar() -> void:
	if velocidad.length() > 0.01:
		pieza.look_at_from_position(global_position, global_position + velocidad, Vector3.UP)


func vivo() -> bool:
	return not devuelto


# Iai perfecto: el proyectil vuelve, más rápido, contra quien lo lanzó.
func recibir_iai(_desde: Vector3) -> bool:
	devuelto = true
	vida_restante = 2.0
	if dueno != null and is_instance_valid(dueno):
		var hacia: Vector3 = dueno.global_position + Vector3.UP * 1.0 - global_position
		velocidad = hacia.normalized() * rapidez * 1.5
	else:
		velocidad = -velocidad * 1.5
	_orientar()
	return false


func recibir_golpe(_desde: Vector3, _letal := false, _danio := 1, _postura := 0.0, _empuje := -1.0) -> bool:
	return false


func _physics_process(delta: float) -> void:
	vida_restante -= delta
	if vida_restante <= 0.0:
		queue_free()
		return
	global_position += velocidad * delta
	pieza.rotate_object_local(Vector3.FORWARD, delta * 8.0)
	if devuelto:
		if dueno != null and is_instance_valid(dueno) and dueno.vivo() \
				and (dueno.global_position + Vector3.UP * 1.0).distance_to(global_position) < 1.2:
			dueno.recibir_golpe(global_position, false, 2, 0.8)
			if efectos:
				efectos.chispas(global_position, 20, color, 6.0, 0.5)
				efectos.texto_flotante(global_position + Vector3.UP * 0.6, "¡Devuelto!", Color(0.7, 0.9, 1.0), 0.007)
			queue_free()
		return
	if objetivo == null or not objetivo.vivo():
		return
	var hacia: Vector3 = objetivo.global_position + Vector3.UP * 1.0 - global_position
	if Vector2(hacia.x, hacia.z).length() < radio + Datos.RADIO_PERSONAJE and absf(hacia.y) < 1.3:
		# El juego, al recibir la señal del iai, llama a recibir_iai() de este proyectil.
		if parable and objetivo.intentar_parar(self):
			return
		if objetivo.recibir_golpe(global_position):
			if efecto == "atrapa" and objetivo.has_method("atrapar"):
				objetivo.atrapar(1.4)
				if efectos:
					efectos.texto_flotante(objetivo.global_position + Vector3.UP * 2.2, "¡Atrapado!", Color(0.95, 0.95, 1.0), 0.007)
			for i in range(1, danio):
				objetivo.invulnerable = 0.0
				objetivo.recibir_golpe(global_position)
		if efectos:
			efectos.chispas(global_position, 10, color, 4.0, 0.35)
		queue_free()
