# Hornea las hojas de sprites pixel art de los personajes (DECISIÓN 20, opción E, que el usuario
# eligió el 02-10-2026). Cada cuadro es el modelo de piezas (visual_modelo.gd y visual_shiro.gd) en
# una pose, visto desde 8 direcciones con cámaras ortográficas a poca resolución. Así no hay que
# dibujar a mano cada pose y cada dirección: se cambia el modelo y se vuelve a hornear.
# Deja las hojas en crudo y su descripción en ronin3d/herramientas/sprites_crudos/; después
# ronin3d/herramientas/pulir_sprites.py les pone el contorno de un píxel, reduce la paleta y las deja
# en godot/recursos/sprites/.
# Uso: godot --path ronin3d/godot --script res://scripts/hornear_sprites.gd -- [id ...]
extends SceneTree

const Aspecto := preload("res://scripts/aspecto.gd")
const VisualModelo := preload("res://scripts/visual_modelo.gd")
const VisualShiro := preload("res://scripts/visual_shiro.gd")

const PX_POR_METRO := 26.0            # resolución del pixel art: Akira mide unos 44 píxeles
const ELEVACION := 20.0               # grados: la cámara del horneado mira un poco desde arriba
const DIRECCIONES := 8
const MARGEN := 2                     # píxeles libres alrededor de cada cuadro (para el contorno)
const ANCHO_MAXIMO := 2048            # las hojas no pasan de 2048 de ancho (el mínimo de OpenGL ES 3)

# tam: tamaño del cuadro en píxeles; pies: fila de los pies (están en la columna del medio)
const PERSONAJES := [
	{"id": "akira_joven", "tipo": "akira", "apariencia": "joven", "tam": Vector2i(80, 84), "pies": 77},
	{"id": "akira_curtido", "tipo": "akira", "apariencia": "curtido", "tam": Vector2i(80, 84), "pies": 77},
	{"id": "akira_veterano", "tipo": "akira", "apariencia": "veterano", "tam": Vector2i(80, 84), "pies": 77},
	{"id": "akira_mujer", "tipo": "akira", "apariencia": "mujer", "tam": Vector2i(80, 84), "pies": 77},
	{"id": "soldado", "tipo": "soldado", "apariencia": "", "tam": Vector2i(104, 88), "pies": 81},
	{"id": "shiro", "tipo": "shiro", "apariencia": "", "tam": Vector2i(44, 36), "pies": 32},
]


func _initialize() -> void:
	_hornear.call_deferred()


func _hornear() -> void:
	var salida := ProjectSettings.globalize_path("res://").path_join("../herramientas/sprites_crudos")
	DirAccess.make_dir_recursive_absolute(salida)
	var elegidos := OS.get_cmdline_user_args()
	for personaje in PERSONAJES:
		if elegidos.size() > 0 and not personaje.id in elegidos:
			continue
		await _hornear_personaje(personaje, salida)
	quit()


# --- Animaciones: [nombre, cuadros, cuadros por segundo (0: los marca la fase del paso), pose] ---
# La función de cada una devuelve [info, fase, tiempo] para el cuadro k.

func _info(pose := "normal", moviendose := false, corriendo := false, en_aire := false,
		progreso := 0.0, muerte := -1.0) -> Dictionary:
	return {"mirando": Vector3.BACK, "moviendose": moviendose, "corriendo": corriendo, "en_aire": en_aire,
		"pose": pose, "progreso": progreso, "visible": true, "destello": 0.0, "muerte": muerte, "aviso": false}


func _animaciones(tipo: String) -> Array:
	if tipo == "shiro":
		var perro := func(pose: String): return {"mirando": Vector3.BACK, "pose": pose, "en_boca": false}
		return [
			["quieto", 4, 3.2, func(k): return [perro.call("quieto"), 0.0, k * 1.257 / 4.0]],
			["sentado", 4, 1.9, func(k): return [perro.call("sentado"), 0.0, k * 2.094 / 4.0]],
			["andar", 6, 0.0, func(k): return [perro.call("andar"), TAU * k / 6.0, k * 0.52 / 6.0]],
			["correr", 4, 0.0, func(k): return [perro.call("correr"), TAU * k / 4.0, k * 0.37 / 4.0]],
			["olfatear", 4, 4.4, func(k): return [perro.call("olfatear"), 0.0, k * 0.9 / 4.0]],
			["escarbar", 4, 12.0, func(k): return [perro.call("escarbar"), 0.0, k * 0.242 / 4.0]],
			["alerta", 1, 0.0, func(_k): return [perro.call("alerta"), 0.0, 0.0]],
			["salto", 1, 0.0, func(_k): return [perro.call("salto"), 0.0, 0.0]],
		]
	var comunes := [
		["andar", 8, 0.0, func(k): return [_info("normal", true), TAU * k / 8.0, k / 12.0]],
		["correr", 6, 0.0, func(k): return [_info("normal", true, true), TAU * k / 6.0, k / 12.0]],
		["salto", 1, 0.0, func(_k): return [_info("normal", false, false, true), 0.0, 0.0]],
		["muerte", 4, 0.0, func(k): return [_info("normal", false, false, false, 0.0, 0.1 * (k + 1)), 0.0, 0.0]],
	]
	if tipo == "soldado":
		return [["normal", 1, 0.0, func(_k): return [_info(), 0.0, 0.0]]] + comunes + [
			["preparando", 1, 0.0, func(_k): return [_info("preparando"), 0.0, 0.0]],
			["estocada", 1, 0.0, func(_k): return [_info("estocada"), 0.0, 0.0]],
		]
	return [["normal", 4, 5.7, func(k): return [_info(), 0.0, k * 0.175]]] + comunes + [
		["ataque", 4, 0.0, func(k): return [_info("ataque", false, false, false, (k + 0.5) / 4.0), 0.0, 0.0]],
		["postura", 1, 0.0, func(_k): return [_info("postura"), 0.0, 0.0]],
		["desenvaine", 4, 0.0, func(k): return [_info("desenvaine", false, false, false, (k + 0.5) / 4.0), 0.0, 0.0]],
		["remate", 1, 0.0, func(_k): return [_info("remate"), 0.0, 0.0]],
	]


# --- Horneado ----------------------------------------------------------------------------------

func _hornear_personaje(personaje: Dictionary, salida: String) -> void:
	var tam: Vector2i = personaje.tam
	var mundo := World3D.new()
	var vistas: Array = []
	for d in DIRECCIONES:
		var vista := SubViewport.new()
		vista.size = tam
		vista.transparent_bg = true
		vista.world_3d = mundo
		vista.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(vista)
		var camara := Camera3D.new()
		camara.projection = Camera3D.PROJECTION_ORTHOGONAL
		camara.keep_aspect = Camera3D.KEEP_HEIGHT
		camara.size = tam.y / PX_POR_METRO
		camara.near = 0.1
		camara.far = 40.0
		vista.add_child(camara)
		camara.current = true
		# La dirección d es la cámara a 45° · d alrededor del personaje, que mira hacia +Z
		# (visual_sprite.gd elige la fila con la misma cuenta).
		var giro := deg_to_rad(45.0 * d)
		var elevacion := deg_to_rad(ELEVACION)
		var altura: float = (float(personaje.pies) - tam.y / 2.0) / (PX_POR_METRO * cos(elevacion))
		var foco := Vector3(0, altura, 0)
		camara.position = foco + Vector3(sin(giro) * cos(elevacion), sin(elevacion), cos(giro) * cos(elevacion)) * 12.0
		camara.look_at(foco, Vector3.UP)
		vistas.append(vista)
	var escena := Node3D.new()
	vistas[0].add_child(escena)
	# Luz neutra e igual desde todas las direcciones: de arriba y ambiente. La del juego (antorchas,
	# luna) tiñe después el sprite.
	var ambiente := WorldEnvironment.new()
	var entorno := Environment.new()
	entorno.background_mode = Environment.BG_CLEAR_COLOR
	entorno.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	entorno.ambient_light_color = Color("c8c4d8")
	entorno.ambient_light_energy = 0.75
	ambiente.environment = entorno
	escena.add_child(ambiente)
	var luz := DirectionalLight3D.new()
	luz.light_energy = 0.85
	luz.light_color = Color("fff2e0")
	luz.transform.basis = Basis.looking_at(Vector3(0.0, -1.0, -0.25).normalized(), Vector3.FORWARD)
	escena.add_child(luz)
	var aspecto = Aspecto.new()
	var visual
	if personaje.tipo == "shiro":
		visual = VisualShiro.new()
		visual.configurar(aspecto)
	else:
		visual = VisualModelo.new()
		visual.configurar(aspecto, personaje.tipo == "soldado", personaje.apariencia)
	escena.add_child(visual)
	# Sin la línea del cel-shading: el contorno de un píxel lo pone pulir_sprites.py
	for malla in visual.find_children("*", "MeshInstance3D", true, false):
		if malla.material_override is ShaderMaterial:
			malla.material_override.next_pass = null
	var animaciones := _animaciones(personaje.tipo)
	var total := 0
	for animacion in animaciones:
		total += animacion[1]
	var celda := tam + Vector2i(MARGEN * 2, MARGEN * 2)
	var columnas := ANCHO_MAXIMO / celda.x
	var filas := ceili(float(total * DIRECCIONES) / columnas)
	var hoja := Image.create(columnas * celda.x, filas * celda.y, false, Image.FORMAT_RGBA8)
	var descripcion := {"id": personaje.id, "tam": [tam.x, tam.y], "margen": MARGEN,
		"pies": [tam.x / 2, personaje.pies], "px_por_metro": PX_POR_METRO, "elevacion": ELEVACION,
		"direcciones": DIRECCIONES, "columnas": columnas, "cuadros_por_direccion": total, "animaciones": {}}
	var indice := 0
	for animacion in animaciones:
		descripcion.animaciones[animacion[0]] = {"inicio": indice, "cuadros": animacion[1], "fps": animacion[2]}
		for k in animacion[1]:
			var datos: Array = animacion[3].call(k)
			_posar(visual, personaje.tipo, datos[0], datos[1], datos[2])
			await process_frame
			await RenderingServer.frame_post_draw
			for d in DIRECCIONES:
				var imagen: Image = vistas[d].get_texture().get_image()
				imagen.convert(Image.FORMAT_RGBA8)
				var numero: int = d * total + indice
				var destino := Vector2i((numero % columnas) * celda.x + MARGEN, (numero / columnas) * celda.y + MARGEN)
				hoja.blit_rect(imagen, Rect2i(Vector2i.ZERO, tam), destino)
			indice += 1
	hoja.save_png(salida.path_join(personaje.id + ".png"))
	var archivo := FileAccess.open(salida.path_join(personaje.id + ".json"), FileAccess.WRITE)
	archivo.store_string(JSON.stringify(descripcion, "\t"))
	archivo.close()
	print("Horneado: %s (%d cuadros × %d direcciones)" % [personaje.id, total, DIRECCIONES])
	for vista in vistas:
		vista.queue_free()
	await process_frame


# Pone el modelo en la pose del cuadro, sin depender del tiempo real: mirando hacia +Z, con la fase
# del paso y el tiempo (las cintas, la cola de Shiro) que tocan.
func _posar(visual, tipo: String, info: Dictionary, fase: float, tiempo: float) -> void:
	visual.angulo = 0.0
	visual.fase = fase
	visual.tiempo = tiempo
	visual._aplicar(0.0, info)
	visual.visible = true
	# fuera la sombra del suelo, el aviso, las estelas y la moneda de la boca: van aparte en el juego
	for hijo in visual.get_children():
		if hijo is Sprite3D or hijo is Label3D:
			hijo.visible = false
	if tipo == "akira":
		visual.estela.visible = false
		visual.estela_iai.visible = false
	if tipo == "shiro":
		visual.moneda_boca.visible = false
