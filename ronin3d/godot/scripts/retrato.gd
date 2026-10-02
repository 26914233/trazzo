# Retratos de cerca de un modelo detallado, para revisarlo: varias vistas y sus tres rangos.
# Uso: godot --path ronin3d/godot --script res://scripts/retrato.gd -- <id> [carpeta_salida]
extends SceneTree

const ModeloCriatura := preload("res://scripts/modelo_criatura.gd")
const Criatura := preload("res://scripts/criatura_modular.gd")
const Aspecto := preload("res://scripts/aspecto.gd")


func _initialize() -> void:
	var argumentos := OS.get_cmdline_user_args()
	var id := int(argumentos[0]) if argumentos.size() > 0 else 2315
	var carpeta := argumentos[1] if argumentos.size() > 1 else ProjectSettings.globalize_path("res://").path_join("../capturas/actual")
	DirAccess.make_dir_recursive_absolute(carpeta)
	_retratar.call_deferred(id, carpeta)


func _retratar(id: int, carpeta: String) -> void:
	var raiz := Node3D.new()
	root.add_child(raiz)
	root.size = Vector2i(1280, 720)
	var mundo := WorldEnvironment.new()
	var entorno := Environment.new()
	entorno.background_mode = Environment.BG_COLOR
	entorno.background_color = Color("1d1b26")
	entorno.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	entorno.ambient_light_color = Color("8a86a8")
	entorno.ambient_light_energy = 1.4
	entorno.glow_enabled = true
	entorno.glow_intensity = 0.9
	entorno.glow_bloom = 0.08
	entorno.glow_hdr_threshold = 1.0
	mundo.environment = entorno
	raiz.add_child(mundo)
	var sol := DirectionalLight3D.new()
	sol.light_color = Color("ffe6c8")
	sol.light_energy = 1.1
	sol.transform.basis = Basis.looking_at(Vector3(-0.4, -0.8, -0.6).normalized(), Vector3.UP)
	raiz.add_child(sol)
	var suelo := MeshInstance3D.new()
	var plano := PlaneMesh.new()
	plano.size = Vector2(30, 30)
	suelo.mesh = plano
	var aspecto = Aspecto.new()
	suelo.material_override = aspecto.material_toon(Color("3a3346"), false, false)
	raiz.add_child(suelo)
	var camara := Camera3D.new()
	camara.fov = 32.0
	raiz.add_child(camara)
	camara.current = true
	# Receta de cada criatura con modelo (la de piezas sale de la misma, para comparar)
	var recetas := {
		2315: {"familia": "bipedo", "tamano": "M", "elemento": "fuego", "rol": "poderoso",
			"partes": ["cuernos", "garrote", "ojos", "armadura"], "paleta": [Color("b3321f"), Color("33231c"), Color("f1e6c8")]},
		353: {"familia": "bipedo", "tamano": "S", "elemento": "agua", "rol": "veloz",
			"partes": ["caparazon", "plato", "pico", "ojos"], "paleta": [Color("3f8f7a"), Color("2c4a3a"), Color("f3e9a0")]},
		680: {"familia": "flotante", "tamano": "S", "elemento": "fuego", "rol": "enjambre",
			"partes": ["ojos", "llamas"], "paleta": [Color("eecd96"), Color("231c1e"), Color("ff9632")]},
	}
	var receta: Dictionary = recetas.get(id, recetas[2315]).duplicate()
	receta["id"] = id
	var grande: bool = receta["tamano"] != "S"
	# Fila: piezas · modelo base · alfa · silenciada
	var criaturas: Array = []
	var x := -3.3 if grande else -2.1
	for tipo in ["piezas", 1, 2, 3]:
		var c
		if tipo is String:
			c = Criatura.new()
			raiz.add_child(c)
			var de_piezas := receta.duplicate()
			de_piezas["semilla"] = id
			c.configurar(aspecto, de_piezas)
		else:
			c = ModeloCriatura.new()
			raiz.add_child(c)
			var r := receta.duplicate()
			r["rango"] = tipo
			c.configurar(null, r)
		c.position = Vector3(x, 0, 0)
		criaturas.append(c)
		x += 2.2 if grande else 1.4
	var k := 1.0 if grande else 0.62
	var vistas := [["frente", Vector3(0.0, 1.5 * k, 9.5 * k + 1.5), Vector3(0.0, 1.05 * k, 0.0)],
		["tres_cuartos", Vector3(6.5 * k, 2.2 * k, 7.5 * k + 1.0), Vector3(0.0, 1.05 * k, 0.0)]]
	for vista in vistas:
		camara.position = vista[1]
		camara.look_at(vista[2], Vector3.UP)
		for cuadro in 30:
			for c in criaturas:
				c.actualizar(1.0 / 30.0)
			await process_frame
		await RenderingServer.frame_post_draw
		var ruta := carpeta.path_join("modelo_%d_%s.png" % [id, vista[0]])
		root.get_texture().get_image().save_png(ruta)
		print("Retrato: ", ruta)
	# De cerca: solo el modelo base y el alfa
	for i in [1, 2]:
		var c = criaturas[i]
		camara.position = c.position + Vector3(0.9, 1.6, 3.4) * (1.0 if grande else 0.55)
		camara.look_at(c.position + Vector3(0, 1.15 if grande else 0.6, 0), Vector3.UP)
		for cuadro in 10:
			await process_frame
		await RenderingServer.frame_post_draw
		var ruta := carpeta.path_join("modelo_%d_cerca_rango%d.png" % [id, i])
		root.get_texture().get_image().save_png(ruta)
		print("Retrato: ", ruta)
	# Desde arriba, como la ve la cámara del juego (por detrás y por encima de Akira)
	var base = criaturas[1]
	camara.position = base.position + Vector3(0.7, 2.7, 3.3) * (1.0 if grande else 0.55)
	camara.look_at(base.position + Vector3(0, 1.1 if grande else 0.62, 0), Vector3.UP)
	for cuadro in 10:
		await process_frame
	await RenderingServer.frame_post_draw
	var ruta_arriba := carpeta.path_join("modelo_%d_arriba.png" % id)
	root.get_texture().get_image().save_png(ruta_arriba)
	print("Retrato: ", ruta_arriba)
	for c in criaturas:
		if c.has_method("get") and c.get("triangulos") != null:
			print("triángulos: ", c.triangulos)
	quit()
