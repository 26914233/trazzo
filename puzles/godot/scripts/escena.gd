# Ayudas para montar las escenas de los prototipos: bloques de madera con su forma de choque,
# calcomanías (símbolos pintados), luces, el cielo de fondo y el polvo que flota en el aire.
class_name Escena
extends RefCounted

const SHADER_CIELO := preload("res://shaders/cielo.gdshader")


# Bloque entre dos esquinas. Con «opaco», tapa los toques que vienen de detrás (como una pared).
static func bloque(desde: Vector3, hasta: Vector3, material: Material, padre: Node3D, bisel := 0.0015,
		opaco := true) -> MeshInstance3D:
	var tamano := (hasta - desde).abs()
	var centro := (desde + hasta) / 2.0
	var malla := Geometria.pieza(Geometria.caja(tamano, bisel), material, centro, padre)
	if opaco:
		var cuerpo := StaticBody3D.new()
		var forma := CollisionShape3D.new()
		forma.shape = BoxShape3D.new()
		(forma.shape as BoxShape3D).size = tamano
		cuerpo.add_child(forma)
		malla.add_child(cuerpo)
	return malla


# Un símbolo pintado sobre una superficie (textura con transparencia, teñida de un color)
static func calcomania(textura: Texture2D, tamano: Vector2, color: Color, padre: Node3D,
		transformacion := Transform3D.IDENTITY, brillo := 0.0) -> MeshInstance3D:
	var quad := QuadMesh.new()
	quad.size = tamano
	var material := StandardMaterial3D.new()
	material.albedo_texture = textura
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.alpha_scissor_threshold = 0.5
	material.roughness = 0.6
	if brillo > 0.0:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = brillo
		material.emission_texture = textura
	var instancia := MeshInstance3D.new()
	instancia.mesh = quad
	instancia.material_override = material
	instancia.transform = transformacion
	instancia.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	padre.add_child(instancia)
	return instancia


static func luz(padre: Node3D, posicion: Vector3, color: Color, energia: float, alcance: float,
		sombras := false) -> OmniLight3D:
	var foco := OmniLight3D.new()
	foco.position = posicion
	foco.light_color = color
	foco.light_energy = energia
	foco.omni_range = alcance
	foco.omni_attenuation = 1.2
	foco.shadow_enabled = sombras
	foco.shadow_bias = 0.02
	foco.shadow_normal_bias = 1.5
	padre.add_child(foco)
	return foco


static func luz_lejana(padre: Node3D, desde: Vector3, color: Color, energia: float) -> DirectionalLight3D:
	var sol := DirectionalLight3D.new()
	sol.light_color = color
	sol.light_energy = energia
	padre.add_child(sol)
	sol.look_at_from_position(desde, Vector3.ZERO, Vector3.UP if absf(desde.normalized().y) < 0.95 else Vector3.BACK)
	return sol


static func cielo(entorno: Environment, parametros: Dictionary, como_fondo := true) -> void:
	var material := ShaderMaterial.new()
	material.shader = SHADER_CIELO
	for clave in parametros:
		material.set_shader_parameter(clave, parametros[clave])
	var cielo_nuevo := Sky.new()
	cielo_nuevo.sky_material = material
	cielo_nuevo.radiance_size = Sky.RADIANCE_SIZE_64
	entorno.sky = cielo_nuevo
	if como_fondo:
		entorno.background_mode = Environment.BG_SKY
	entorno.reflected_light_source = Environment.REFLECTION_SOURCE_SKY


# Motas de polvo que flotan despacio y brillan con la luz
static func polvo(padre: Node3D, extension: Vector3, color: Color, cantidad := 50, tamano := 0.003) -> CPUParticles3D:
	var particulas := CPUParticles3D.new()
	particulas.amount = cantidad
	particulas.lifetime = 9.0
	particulas.preprocess = 9.0
	particulas.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	particulas.emission_box_extents = extension
	particulas.direction = Vector3.UP
	particulas.spread = 180.0
	particulas.gravity = Vector3(0.0, 0.004, 0.0)
	particulas.initial_velocity_min = 0.002
	particulas.initial_velocity_max = 0.012
	particulas.scale_amount_min = 0.6
	particulas.scale_amount_max = 1.4
	var rampa := Gradient.new()
	rampa.set_color(0, Color(color, 0.0))
	rampa.set_color(1, Color(color, 0.0))
	rampa.add_point(0.25, color)
	rampa.add_point(0.75, color)
	particulas.color_ramp = rampa
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE * tamano
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	material.vertex_color_use_as_albedo = true
	material.albedo_texture = _punto()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	quad.material = material
	particulas.mesh = quad
	padre.add_child(particulas)
	return particulas


static var _textura_punto: Texture2D


static func _punto() -> Texture2D:
	if _textura_punto == null:
		var imagen := Image.create(32, 32, false, Image.FORMAT_RGBA8)
		for y in 32:
			for x in 32:
				var d := Vector2(x - 15.5, y - 15.5).length() / 15.5
				var a := clampf(1.0 - d, 0.0, 1.0)
				imagen.set_pixel(x, y, Color(1, 1, 1, a * a))
		_textura_punto = ImageTexture.create_from_image(imagen)
	return _textura_punto


# Un nodo vacío en una posición (para agrupar piezas)
static func grupo(padre: Node3D, posicion := Vector3.ZERO, nombre := "") -> Node3D:
	var nodo := Node3D.new()
	nodo.position = posicion
	if nombre != "":
		nodo.name = nombre
	padre.add_child(nodo)
	return nodo
