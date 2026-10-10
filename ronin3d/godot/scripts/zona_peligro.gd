# Zona de peligro en el suelo. Primero avisa (una marca que se va llenando: roja si no se puede parar)
# y luego hace daño a Akira si está dentro. La usan los golpes de área (el salto de la tsuchigumo,
# los puños del gólem, la columna de fuego del ifrit, el abanico de Sōjōbō, el látigo de colas de
# Tamamo, el aliento de Bahamut) y el fuego que deja el kasha al rodar.
# Forma: «circulo» (centro y radio) o «linea» (desde el origen hacia «direccion», largo y ancho).
# Si es parable (el aliento de Bahamut), un iai perfecto en el momento del golpe lo parte en dos.
extends Node3D

signal impacto(punto: Vector3)

const MARGEN := 0.3                   # el radio de Akira: basta con que el borde lo toque

var forma := "circulo"
var radio := 2.0
var largo := 6.0
var ancho := 1.6
var direccion := Vector3.RIGHT
var aviso := 1.0
var activo := 0.25
var danio := 1
var parable := false
var persistente := false              # daña todo el tiempo que está activa (fuego en el suelo)
var color := Color(0.85, 0.08, 0.05)
var dueno
var objetivo
var efectos
var tiempo := 0.0
var golpeo := false
var activada := false
var partida := false                  # un iai la partió: ya no hace daño
var marca: MeshInstance3D
var relleno: MeshInstance3D
var material_marca: StandardMaterial3D
var material_relleno: StandardMaterial3D


func configurar(datos: Dictionary, dueno_nuevo, objetivo_nuevo, efectos_nuevos) -> void:
	top_level = true
	dueno = dueno_nuevo
	objetivo = objetivo_nuevo
	efectos = efectos_nuevos
	forma = String(datos.get("forma_zona", "circulo"))
	radio = float(datos.get("radio", 2.0))
	largo = float(datos.get("largo", 6.0))
	ancho = float(datos.get("ancho", 1.6))
	aviso = float(datos.get("aviso", 1.0))
	activo = float(datos.get("activo", 0.25))
	danio = int(datos.get("danio", 1))
	parable = bool(datos.get("parable", false))
	persistente = bool(datos.get("persistente", false))
	color = datos.get("color", Color(0.85, 0.08, 0.05) if not parable else Color(1.0, 0.85, 0.3))
	direccion = datos.get("direccion", Vector3.RIGHT)
	direccion.y = 0.0
	direccion = direccion.normalized() if direccion.length() > 0.01 else Vector3.RIGHT
	material_marca = _material(Color(color.r, color.g, color.b, 0.28))
	material_relleno = _material(Color(color.r, color.g, color.b, 0.45))
	marca = _pieza(material_marca, 0.02)
	relleno = _pieza(material_relleno, 0.03)
	relleno.scale = Vector3(0.01, 1.0, 0.01) if forma == "circulo" else Vector3(1.0, 1.0, 0.01)
	add_child(marca)
	add_child(relleno)


func _material(c: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = c
	material.no_depth_test = false
	return material


func _pieza(material: Material, alto: float) -> MeshInstance3D:
	var pieza := MeshInstance3D.new()
	pieza.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	pieza.material_override = material
	if forma == "circulo":
		var disco := CylinderMesh.new()
		disco.top_radius = radio
		disco.bottom_radius = radio
		disco.height = 0.02
		disco.radial_segments = 24
		disco.rings = 1
		pieza.mesh = disco
		pieza.position.y = alto
	else:
		var tira := BoxMesh.new()
		tira.size = Vector3(ancho, 0.02, largo)
		pieza.mesh = tira
		pieza.basis = Basis.looking_at(direccion, Vector3.UP)
		pieza.position = direccion * largo / 2.0 + Vector3.UP * alto
	return pieza


func dentro(punto: Vector3) -> bool:
	var local := punto - global_position
	if absf(local.y) > 1.6:
		return false
	local.y = 0.0
	if forma == "circulo":
		return local.length() < radio + MARGEN
	var a := local.dot(direccion)
	var lateral := (local - direccion * a).length()
	return a >= -MARGEN and a <= largo + MARGEN and lateral < ancho / 2.0 + MARGEN


func _physics_process(delta: float) -> void:
	tiempo += delta
	if tiempo < aviso:
		var t := tiempo / aviso
		if forma == "circulo":
			relleno.scale = Vector3(t, 1.0, t)
		else:
			relleno.scale = Vector3(1.0, 1.0, 1.0)
			relleno.position = direccion * largo * t / 2.0 + Vector3.UP * 0.03
			relleno.scale.z = maxf(t, 0.01)
		material_marca.albedo_color.a = 0.22 + 0.12 * (0.5 + 0.5 * sin(tiempo * 18.0))
		return
	if tiempo < aviso + activo:
		if not activada:
			activada = true
			relleno.scale = Vector3.ONE
			relleno.position = Vector3.UP * 0.03 if forma == "circulo" else direccion * largo / 2.0 + Vector3.UP * 0.03
			material_relleno.albedo_color.a = 0.8
			impacto.emit(global_position)
		if partida:
			return
		if objetivo != null and objetivo.vivo() and (persistente or not golpeo) and dentro(objetivo.global_position):
			if parable and dueno != null and is_instance_valid(dueno) and objetivo.intentar_parar(dueno):
				partida = true
				material_relleno.albedo_color = Color(0.7, 0.9, 1.0, 0.5)
				if efectos:
					efectos.texto_flotante(objetivo.global_position + Vector3.UP * 2.4, "¡Partido en dos!", Color(0.8, 0.95, 1.0), 0.008)
				return
			if objetivo.recibir_golpe(global_position):
				golpeo = true
				for i in range(1, danio):
					objetivo.invulnerable = 0.0
					objetivo.recibir_golpe(global_position)
		if persistente:
			material_relleno.albedo_color.a = 0.55 + 0.25 * sin(tiempo * 20.0)
		return
	var final := (tiempo - aviso - activo) / 0.3
	material_relleno.albedo_color.a = maxf(0.0, 0.8 * (1.0 - final))
	material_marca.albedo_color.a = maxf(0.0, 0.22 * (1.0 - final))
	if final >= 1.0:
		queue_free()
