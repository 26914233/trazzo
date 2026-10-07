extends SceneTree
# Prueba de calidad (DECISIÓN 28): la caja viva A+C hecha en Blender (modelos/caja_viva/), en su
# washitsu y con la luz del juego. Saca fotos desde el ángulo de los bocetos. No va en el APK.
#   xvfb-run -a godot --path puzles/godot --rendering-driver opengl3 --fixed-fps 30 \
#     --script res://scripts/prueba_calidad.gd -- --salida=/ruta/
const Washitsu := preload("res://scripts/salas/washitsu.gd")

var salida := "user://calidad/"
var raiz: Node3D
var camara: Camera3D


func _initialize() -> void:
	for argumento in OS.get_cmdline_user_args():
		if argumento.begins_with("--salida="):
			salida = argumento.split("=")[1].trim_suffix("/") + "/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(salida))
	raiz = Node3D.new()
	root.add_child(raiz)
	var sala := Washitsu.new()
	raiz.add_child(sala)
	sala.construir()
	_entorno(sala)
	var caja: Node3D = load("res://modelos/caja_viva/caja_viva_ac.glb").instantiate()
	raiz.add_child(caja)
	caja.position = Vector3(0.0, Washitsu.MESA, 0.0)
	var mesa: Node3D = load("res://modelos/caja_viva/mesa_caja_viva.glb").instantiate()
	raiz.add_child(mesa)
	mesa.position = Vector3(0.0, Washitsu.MESA, 0.0)
	camara = Camera3D.new()
	raiz.add_child(camara)
	camara.current = true
	correr.call_deferred()


# La misma luz que la caja viva del juego (caja_viva.gd, preparar_entorno)
func _entorno(sala) -> void:
	var entorno := Environment.new()
	Escena.cielo(entorno, {
		"arriba": Color(0.015, 0.02, 0.05), "horizonte": Color(0.07, 0.055, 0.1), "abajo": Color(0.01, 0.008, 0.015),
		"resplandor": Color(0.45, 0.2, 0.08), "direccion_resplandor": Vector3(-0.6, 0.3, 0.7), "apertura": 5.0,
		"nubes": 0.5, "color_nubes": Color(0.1, 0.08, 0.13), "estrellas": 0.5}, false)
	entorno.background_mode = Environment.BG_COLOR
	entorno.background_color = Color(0.01, 0.01, 0.015)
	entorno.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	entorno.ambient_light_color = Color(0.42, 0.42, 0.55)
	entorno.ambient_light_energy = 0.24
	entorno.tonemap_mode = Environment.TONE_MAPPER_ACES
	entorno.tonemap_exposure = 1.05
	entorno.glow_enabled = true
	entorno.glow_intensity = 0.9
	entorno.glow_bloom = 0.04
	var mundo := WorldEnvironment.new()
	mundo.environment = entorno
	raiz.add_child(mundo)
	Escena.luz(raiz, Vector3(0.1, 0.9, 0.25), Color(1.0, 0.8, 0.6), 0.35, 1.8)
	Escena.luz(raiz, Vector3(0.0, 0.42, 0.42), Color(1.0, 0.86, 0.7), 0.22, 1.0)


func esperar(cuadros: int) -> void:
	for i in cuadros:
		await process_frame


func foto(nombre: String, desde: Vector3, hacia: Vector3, fov: float) -> void:
	camara.fov = fov
	camara.look_at_from_position(desde, hacia)
	await esperar(8)
	root.get_viewport().get_texture().get_image().save_png(salida + nombre + ".png")


func correr() -> void:
	await esperar(10)
	var mesa_y := Washitsu.MESA
	# como el boceto: de frente y a la derecha, un poco desde arriba
	await foto("frente", Vector3(0.42, mesa_y + 0.42, 0.62), Vector3(0.0, mesa_y + 0.12, 0.0), 27.0)
	# por detrás y a la izquierda, como el segundo boceto
	await foto("detras", Vector3(-0.42, mesa_y + 0.42, -0.62), Vector3(0.0, mesa_y + 0.12, 0.0), 27.0)
	# de cerca, la cara
	await foto("cara", Vector3(0.05, mesa_y + 0.17, 0.42), Vector3(0.0, mesa_y + 0.14, 0.0), 30.0)
	quit()
