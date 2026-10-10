# Prueba de estilos de render (DECISIÓN 20 de PLAN_PRODUCCION.md): los mismos personajes dibujados
# con otros estilos además del cel-shading del juego. No cambia el juego: solo hace capturas.
#   - «retrato»: las cuatro skins, un soldado y Shiro en fila, y la cara de Akira de cerca.
#   - «patio»: un momento de combate en el patio de noche, visto con la cámara del juego.
# En cada estilo mide también cuánto tarda en dibujar el patio (en la nube, con OpenGL por software).
# Uso: godot --path ronin3d/godot --script res://scripts/estilos_render.gd -- [carpeta_salida]
# (por defecto ../capturas/estilos_render/). La hoja comparativa la monta
# ronin3d/herramientas/hoja_estilos.py.
extends SceneTree

const Aspecto := preload("res://scripts/aspecto.gd")
const ConstructorMundo := preload("res://scripts/constructor_mundo.gd")
const VisualModelo := preload("res://scripts/visual_modelo.gd")
const VisualShiro := preload("res://scripts/visual_shiro.gd")
const Apariencias := preload("res://scripts/apariencias_akira.gd")
const SHADER_TOON := preload("res://shaders/toon.gdshader")
const SHADER_CARA := preload("res://shaders/toon_cara.gdshader")
const SHADER_CARA_REALISTA := preload("res://shaders/estilos/cara_realista.gdshader")
const FILTROS := {
	"tinta": preload("res://shaders/estilos/tinta_manga.gdshader"),
	"sumie": preload("res://shaders/estilos/sumie.gdshader"),
	"ukiyoe": preload("res://shaders/estilos/ukiyoe.gdshader"),
	"pixel": preload("res://shaders/estilos/pixel.gdshader"),
}
const ESTILOS := ["cel", "tinta", "sumie", "ukiyoe", "pixel", "realista"]

var carpeta := ""
var contenedor: SubViewportContainer
var vista: SubViewport
var mundo: Node3D
var camara: Camera3D
var aspecto
var constructor
var figuras: Array = []               # [visual, info]
var perros: Array = []                # [visual, info]
var guardado := {}                    # lo que cambia un estilo, para dejarlo como estaba
var tiempos := {}


func _initialize() -> void:
	var argumentos := OS.get_cmdline_user_args()
	carpeta = argumentos[0] if argumentos.size() > 0 else ProjectSettings.globalize_path("res://").path_join("../capturas/estilos_render")
	DirAccess.make_dir_recursive_absolute(carpeta)
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	root.size = Vector2i(1280, 720)
	contenedor = SubViewportContainer.new()
	contenedor.stretch = true
	contenedor.size = Vector2(1280, 720)
	contenedor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.add_child(contenedor)
	vista = SubViewport.new()
	vista.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	contenedor.add_child(vista)
	for escena in ["retrato", "patio"]:
		_montar(escena)
		for estilo in ESTILOS:
			_aplicar_estilo(estilo)
			for nombre_vista in (["fila", "cara"] if escena == "retrato" else ["juego"]):
				_poner_vista(nombre_vista)
				for cuadro in 10:
					_animar(1.0 / 30.0)
					await process_frame
				await RenderingServer.frame_post_draw
				var ruta := carpeta.path_join("%s_%s.jpg" % [estilo, nombre_vista])
				root.get_texture().get_image().save_jpg(ruta, 0.92)
				print("Captura: ", ruta)
			if escena == "patio":
				# Coste: 60 cuadros con la cámara del juego (tras 20 para compilar los shaders)
				for cuadro in 20:
					_animar(1.0 / 30.0)
					await process_frame
				var inicio := Time.get_ticks_usec()
				for cuadro in 60:
					_animar(1.0 / 30.0)
					await process_frame
				tiempos[estilo] = (Time.get_ticks_usec() - inicio) / 1000.0 / 60.0
			_restaurar()
		_desmontar()
	for estilo in ESTILOS:
		print("COSTE %s: %.1f ms por cuadro (%.1f FPS) en el patio" % [estilo, tiempos[estilo], 1000.0 / tiempos[estilo]])
	quit()


# --- Escenas ---------------------------------------------------------------------------------

func _montar(escena: String) -> void:
	mundo = Node3D.new()
	vista.add_child(mundo)
	aspecto = Aspecto.new()
	camara = Camera3D.new()
	mundo.add_child(camara)
	camara.current = true
	figuras = []
	perros = []
	constructor = null
	if escena == "retrato":
		_escena_retrato()
	else:
		_escena_patio()


func _desmontar() -> void:
	mundo.free()


# La misma que retrato.gd: fondo oscuro, luz cálida y suelo; en fila las cuatro skins, un soldado y
# Shiro sentado.
func _escena_retrato() -> void:
	var ambiente := WorldEnvironment.new()
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
	ambiente.environment = entorno
	mundo.add_child(ambiente)
	var sol := DirectionalLight3D.new()
	sol.light_color = Color("ffe6c8")
	sol.light_energy = 1.1
	sol.transform.basis = Basis.looking_at(Vector3(-0.4, -0.8, -0.6).normalized(), Vector3.UP)
	mundo.add_child(sol)
	var suelo := MeshInstance3D.new()
	var plano := PlaneMesh.new()
	plano.size = Vector2(30, 30)
	suelo.mesh = plano
	suelo.material_override = aspecto.material_toon(Color("3a3346"), false, false)
	mundo.add_child(suelo)
	var x := -3.2
	for id in Apariencias.ORDEN:
		_figura(false, id, Vector3(x, 0, 0), _info(Vector3.BACK, "normal"))
		x += 1.6
	_figura(true, "", Vector3(x, 0, 0), _info(Vector3.BACK, "normal"))
	_perro(Vector3(-2.4, 0, 0.9), {"mirando": Vector3(0.5, 0, 1).normalized(), "pose": "sentado", "en_boca": false})


# Un momento de combate en el patio, de noche: Akira en postura de iai frente a un soldado que
# avisa del golpe, otro soldado que llega y Shiro agachado detrás.
func _escena_patio() -> void:
	constructor = ConstructorMundo.new()
	constructor.construir(mundo, aspecto)
	_figura(false, "joven", Vector3(-6, 0, 6), _info(Vector3.RIGHT, "postura"))
	var aviso := _info(Vector3.LEFT, "preparando")
	aviso["aviso"] = true
	_figura(true, "", Vector3(-4.5, 0, 6.2), aviso)
	_figura(true, "", Vector3(-3.6, 0, 3.9), _info(Vector3(-0.8, 0, 0.6).normalized(), "normal"))
	_perro(Vector3(-7.1, 0, 6.9), {"mirando": Vector3.RIGHT, "pose": "alerta", "en_boca": false})


func _info(mirando: Vector3, pose: String) -> Dictionary:
	return {"mirando": mirando, "moviendose": false, "corriendo": false, "en_aire": false, "pose": pose,
		"progreso": 0.0, "visible": true, "destello": 0.0, "muerte": -1.0, "aviso": false}


func _figura(soldado: bool, apariencia: String, posicion: Vector3, info: Dictionary) -> void:
	var visual = VisualModelo.new()
	visual.configurar(aspecto, soldado, apariencia)
	mundo.add_child(visual)
	visual.position = posicion
	figuras.append([visual, info])


func _perro(posicion: Vector3, info: Dictionary) -> void:
	var visual = VisualShiro.new()
	visual.configurar(aspecto)
	mundo.add_child(visual)
	visual.position = posicion
	perros.append([visual, info])


func _animar(delta: float) -> void:
	for figura in figuras:
		figura[0].actualizar(delta, figura[1])
	for perro in perros:
		perro[0].actualizar(delta, perro[1])
	if constructor:
		constructor.actualizar(delta)


func _poner_vista(nombre: String) -> void:
	match nombre:
		"fila":
			camara.fov = 32.0
			camara.position = Vector3(0, 1.6, 8.8)
			camara.look_at(Vector3(0, 0.95, 0), Vector3.UP)
		"cara":
			var p: Vector3 = figuras[0][0].position
			camara.fov = 32.0
			camara.position = p + Vector3(0.15, 1.68, 1.15)
			camara.look_at(p + Vector3(0, 1.48, 0), Vector3.UP)
		"juego":
			# Como camara_orbital.gd: 12 m, 38° de inclinación y -60° de giro, mirando a 1 m de altura
			var g := deg_to_rad(-60.0)
			var i := deg_to_rad(38.0)
			var mira: Vector3 = figuras[0][0].position + Vector3(0, 1.0, 0)
			camara.fov = 38.0
			camara.position = mira + Vector3(sin(g) * cos(i), sin(i), cos(g) * cos(i)) * 12.0
			camara.look_at(mira, Vector3.UP)


# --- Estilos -----------------------------------------------------------------------------------

func _aplicar_estilo(estilo: String) -> void:
	guardado = {"materiales": {}, "contornos": {}, "planos": {}, "sombras": {}}
	contenedor.stretch_shrink = 4 if estilo == "pixel" else 1
	contenedor.material = null
	if FILTROS.has(estilo):
		var filtro := ShaderMaterial.new()
		filtro.shader = FILTROS[estilo]
		contenedor.material = filtro
	match estilo:
		"pixel":
			_contornos(4.0, 4.0)          # una línea de 1 píxel en la imagen de 320 × 180
		"ukiyoe":
			_luz_plana()
			_contornos(2.0, 5.0)
		"sumie":
			_contornos(2.0, 6.0)
		"realista":
			_materiales_realistas()


func _mallas() -> Array:
	return mundo.find_children("*", "MeshInstance3D", true, false)


func _contornos(minimo: float, maximo: float) -> void:
	for malla in _mallas():
		var material = malla.material_override
		if material is ShaderMaterial and material.next_pass is ShaderMaterial:
			var contorno: ShaderMaterial = material.next_pass
			if not guardado.contornos.has(contorno):
				guardado.contornos[contorno] = [contorno.get_shader_parameter("minimo_px"), contorno.get_shader_parameter("maximo_px")]
			contorno.set_shader_parameter("minimo_px", minimo)
			contorno.set_shader_parameter("maximo_px", maximo)


func _luz_plana() -> void:
	for malla in _mallas():
		var material = malla.material_override
		if material is ShaderMaterial and material.shader == SHADER_TOON and not guardado.planos.has(material):
			guardado.planos[material] = material.get_shader_parameter("plano")
			material.set_shader_parameter("plano", 1.0)


# 3D «normal»: materiales de Godot con su luz (sin bandas ni contorno) y sombras de verdad.
func _materiales_realistas() -> void:
	var cambios := {}
	for malla in _mallas():
		var material = malla.material_override
		if not material is ShaderMaterial:
			continue
		if not cambios.has(material):
			if material.shader == SHADER_TOON:
				var estandar := StandardMaterial3D.new()
				estandar.albedo_color = material.get_shader_parameter("color")
				estandar.roughness = 0.8
				var emision = material.get_shader_parameter("emision")
				if emision != null and float(emision) > 0.0:
					estandar.emission_enabled = true
					estandar.emission = estandar.albedo_color
					estandar.emission_energy_multiplier = float(emision)
				cambios[material] = estandar
			elif material.shader == SHADER_CARA:
				var cara := ShaderMaterial.new()
				cara.shader = SHADER_CARA_REALISTA
				for parametro in ["color", "rasgos", "a_cabeza"]:
					cara.set_shader_parameter(parametro, material.get_shader_parameter(parametro))
				cambios[material] = cara
			else:
				continue
		guardado.materiales[malla] = material
		malla.material_override = cambios[material]
	for luz in mundo.find_children("*", "Light3D", true, false):
		guardado.sombras[luz] = luz.shadow_enabled
		luz.shadow_enabled = true


func _restaurar() -> void:
	for malla in guardado.get("materiales", {}):
		malla.material_override = guardado.materiales[malla]
	for contorno in guardado.get("contornos", {}):
		contorno.set_shader_parameter("minimo_px", guardado.contornos[contorno][0])
		contorno.set_shader_parameter("maximo_px", guardado.contornos[contorno][1])
	for material in guardado.get("planos", {}):
		material.set_shader_parameter("plano", guardado.planos[material])
	for luz in guardado.get("sombras", {}):
		luz.shadow_enabled = guardado.sombras[luz]
	guardado = {}
