# Efectos de un instante para la resistencia de los objetos: humo que se escapa por una junta, polvo
# que cae de lo que se fuerza y motas de luz que vuelven a su origen. Se crean, se ven y se borran
# solos. «escala» agranda el efecto en las habitaciones, donde todo está más lejos.
class_name Efectos
extends RefCounted

static var _textura_suave: Texture2D


# Mancha redonda y difuminada: sirve de humo, de polvo y de mota
static func textura_suave() -> Texture2D:
	if _textura_suave == null:
		var degradado := Gradient.new()
		degradado.set_color(0, Color(1.0, 1.0, 1.0, 1.0))
		degradado.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
		var textura := GradientTexture2D.new()
		textura.gradient = degradado
		textura.fill = GradientTexture2D.FILL_RADIAL
		textura.fill_from = Vector2(0.5, 0.5)
		textura.fill_to = Vector2(0.5, 0.0)
		textura.width = 64
		textura.height = 64
		_textura_suave = textura
	return _textura_suave


static func _material_particula(aditivo: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if aditivo:
		material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	material.vertex_color_use_as_albedo = true
	material.albedo_texture = textura_suave()
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	return material


static func _particulas(padre: Node3D, punto: Vector3, cantidad: int, vida: float, tamano: float,
		aditivo: bool) -> CPUParticles3D:
	var particulas := CPUParticles3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(tamano, tamano)
	# el material va en la malla: con material_override, el renderizador Compatibility las pinta negras
	quad.material = _material_particula(aditivo)
	particulas.mesh = quad
	particulas.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	particulas.amount = cantidad
	particulas.lifetime = vida
	particulas.one_shot = true
	particulas.explosiveness = 0.8
	particulas.randomness = 0.6
	particulas.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	padre.add_child(particulas)
	particulas.global_position = punto
	particulas.finished.connect(particulas.queue_free)
	particulas.emitting = true
	return particulas


# Hilo de humo que se escapa por una junta, como un aliento contenido. Es aditivo: con mezcla normal,
# el renderizador Compatibility pinta negras las partículas recién nacidas.
static func humo(padre: Node3D, punto: Vector3, color := Color(0.86, 0.84, 0.8), cantidad := 12,
		escala := 1.0) -> void:
	var particulas := _particulas(padre, punto, cantidad, 2.4, 0.026 * escala, true)
	particulas.explosiveness = 0.55
	particulas.emission_sphere_radius = 0.005 * escala
	particulas.direction = Vector3.UP
	particulas.spread = 25.0
	particulas.initial_velocity_min = 0.015 * escala
	particulas.initial_velocity_max = 0.04 * escala
	particulas.gravity = Vector3(0.0, 0.02 * escala, 0.0)
	particulas.damping_min = 0.008 * escala
	particulas.damping_max = 0.016 * escala
	particulas.angular_velocity_min = -40.0
	particulas.angular_velocity_max = 40.0
	particulas.scale_amount_min = 0.8
	particulas.scale_amount_max = 1.4
	var crece := Curve.new()
	crece.add_point(Vector2(0.0, 0.3))
	crece.add_point(Vector2(1.0, 1.0))
	particulas.scale_amount_curve = crece
	var rampa := Gradient.new()
	rampa.set_color(0, Color(color, 0.0))
	rampa.set_color(1, Color(color, 0.0))
	rampa.add_point(0.12, Color(color, 0.42))
	rampa.add_point(0.55, Color(color, 0.2))
	particulas.color_ramp = rampa


# Polvo que cae de lo que se ha forzado
static func polvo(padre: Node3D, punto: Vector3, color := Color(0.9, 0.82, 0.62), cantidad := 16,
		escala := 1.0) -> void:
	var particulas := _particulas(padre, punto, cantidad, 1.3, 0.005 * escala, true)
	particulas.emission_sphere_radius = 0.01 * escala
	particulas.direction = Vector3.UP
	particulas.spread = 70.0
	particulas.initial_velocity_min = 0.03 * escala
	particulas.initial_velocity_max = 0.08 * escala
	particulas.gravity = Vector3(0.0, -0.25 * escala, 0.0)
	particulas.damping_min = 0.05 * escala
	particulas.damping_max = 0.1 * escala
	particulas.scale_amount_min = 0.5
	particulas.scale_amount_max = 1.3
	var rampa := Gradient.new()
	rampa.set_color(0, Color(color, 0.9))
	rampa.set_color(1, Color(color, 0.0))
	particulas.color_ramp = rampa


# Motas de luz que salen de un punto y vuelven a «destino» (un nodo que puede moverse), por un
# camino curvo y cada una a su ritmo
static func motas_hacia(padre: Node3D, desde: Vector3, destino: Node3D, color: Color, cantidad := 8,
		dispersion := 0.012, escala := 1.0) -> void:
	var malla := QuadMesh.new()
	malla.size = Vector2(0.016, 0.016) * escala
	var material := _material_particula(true)
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.vertex_color_use_as_albedo = false
	material.albedo_color = color.lightened(0.3)
	for i in cantidad:
		var mota := MeshInstance3D.new()
		mota.mesh = malla
		mota.material_override = material
		mota.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		padre.add_child(mota)
		var salida := desde + Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)).normalized() * dispersion * randf_range(0.3, 1.0)
		var desvio := Vector3(randf_range(-1.0, 1.0), randf_range(-0.2, 1.0), randf_range(-1.0, 1.0)) \
			* 0.035 * escala
		mota.global_position = salida
		mota.scale = Vector3.ZERO
		# curva de Bézier: sale, se abre hacia un lado y entra en el destino (aunque se haya movido)
		var mover := func(t: float) -> void:
			if not is_instance_valid(destino) or not is_instance_valid(mota):
				return
			var llegada := destino.global_position
			var control := (salida + llegada) / 2.0 + desvio
			mota.global_position = salida.lerp(control, t).lerp(control.lerp(llegada, t), t)
			mota.scale = Vector3.ONE * sin(clampf(t, 0.0, 1.0) * PI) * 1.4
		var animacion := mota.create_tween()
		animacion.tween_interval(i * 0.045)
		animacion.tween_method(mover, 0.0, 1.0, randf_range(0.55, 0.85)) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		animacion.tween_callback(mota.queue_free)
