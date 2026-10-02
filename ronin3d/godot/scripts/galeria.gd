# Galería de criaturas: pone en fila las criaturas del bestiario para verlas, medir cuántas
# piezas cuesta cada una y sacar capturas. Se abre con:
#   godot --path ronin3d/godot -- --galeria          (con ventana: ← → cambian de página)
#   xvfb-run -a godot --path ronin3d/godot --fixed-fps 30 -- --galeria --capturas
# Con --capturas guarda una imagen por página en ronin3d/capturas/actual/ y sale.
# Dentro del juego se abre desde la pausa (G en el PC, botón en el móvil). Para cambiar de
# página: flechas, o tocar el tercio izquierdo/derecho de la pantalla; para volver: ESC o
# tocar la esquina de arriba a la derecha. Sirve para medir los FPS con muchas criaturas.
extends Node3D

signal salio

const Aspecto := preload("res://scripts/aspecto.gd")
const Criatura := preload("res://scripts/criatura_modular.gd")
const ModeloCriatura := preload("res://scripts/modelo_criatura.gd")

const Apariencias := preload("res://scripts/apariencias_akira.gd")

const CATALOGO := "res://datos/bestiario.json"
const FAMILIAS := ["bipedo", "cuadrupedo", "serpentino", "alado", "acuatico", "flotante", "artropodo"]

var aspecto
var camara: Camera3D
var suelo: MeshInstance3D
var criaturas: Array = []
var rotulos: Array = []
var paginas: Array = []               # [{titulo, filas: [[receta, ...], ...]}]
var pagina := 0
var con_capturas := false
var rotulo_titulo: Label
var rotulo_datos: Label
var tiempo := 0.0
var carpeta_capturas := ""
var catalogo: Array = []
var tiempo_fps := 0.0
var texto_datos := ""


# Personajes en la galería (los aspectos de Akira y Shiro), con la misma interfaz que las
# criaturas: configurar, cuerpo, piezas y actualizar.
class Figura extends Node3D:
	const VisualModelo := preload("res://scripts/visual_modelo.gd")
	const VisualShiro := preload("res://scripts/visual_shiro.gd")
	var visual
	var cuerpo: Node3D
	var piezas := 0
	var es_shiro := false
	var pose := "normal"

	func configurar(aspecto, receta: Dictionary) -> void:
		es_shiro = receta.get("personaje") == "shiro"
		if es_shiro:
			visual = VisualShiro.new()
			visual.configurar(aspecto)
		else:
			visual = VisualModelo.new()
			visual.configurar(aspecto, false, String(receta.get("apariencia", "joven")))
		add_child(visual)
		cuerpo = visual.cuerpo
		piezas = _contar(visual)
		pose = String(receta.get("pose", "sentado" if es_shiro else "normal"))

	func _contar(nodo: Node) -> int:
		var cuenta := 1 if nodo is MeshInstance3D else 0
		for hijo in nodo.get_children():
			cuenta += _contar(hijo)
		return cuenta

	func actualizar(delta: float) -> void:
		if es_shiro:
			visual.actualizar(delta, {"mirando": Vector3.BACK, "pose": pose, "en_boca": false})
		else:
			visual.actualizar(delta, {"mirando": Vector3.BACK, "moviendose": false, "corriendo": false,
				"en_aire": false, "pose": pose, "progreso": 0.0, "visible": true, "destello": 0.0,
				"muerte": -1.0, "aviso": false})


func iniciar(solo_capturas: bool) -> void:
	con_capturas = solo_capturas
	process_mode = Node.PROCESS_MODE_ALWAYS
	Engine.time_scale = 1.0
	aspecto = Aspecto.new()
	_crear_escena()
	_crear_interfaz()
	catalogo = _cargar_catalogo()
	paginas = _definir_paginas()
	carpeta_capturas = ProjectSettings.globalize_path("res://").path_join("../capturas/actual").simplify_path()
	DirAccess.make_dir_recursive_absolute(carpeta_capturas)
	_mostrar_pagina(0)
	if con_capturas:
		_recorrer_y_capturar()


func _crear_escena() -> void:
	var mundo := WorldEnvironment.new()
	var entorno := Environment.new()
	entorno.background_mode = Environment.BG_COLOR
	entorno.background_color = Color("e9e1cb")
	entorno.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	entorno.ambient_light_color = Color("fff4e0")
	entorno.ambient_light_energy = 0.8
	mundo.environment = entorno
	add_child(mundo)
	var sol := DirectionalLight3D.new()
	sol.light_color = Color("fff1d6")
	sol.light_energy = 0.9
	sol.transform.basis = Basis.looking_at(Vector3(-0.5, -1.0, -0.7).normalized(), Vector3.UP)
	add_child(sol)
	var plano := PlaneMesh.new()
	plano.size = Vector2(120, 120)
	suelo = MeshInstance3D.new()
	suelo.mesh = plano
	suelo.material_override = aspecto.material_toon(Color("9a8c6e"), false, false)
	add_child(suelo)
	camara = Camera3D.new()
	camara.fov = 38.0
	add_child(camara)
	camara.current = true


func _crear_interfaz() -> void:
	var capa := CanvasLayer.new()
	add_child(capa)
	rotulo_titulo = Label.new()
	rotulo_titulo.position = Vector2(24, 14)
	rotulo_titulo.add_theme_font_size_override("font_size", 28)
	rotulo_titulo.add_theme_color_override("font_color", Color("1c1830"))
	capa.add_child(rotulo_titulo)
	var ayuda := Label.new()
	ayuda.text = "← → o toca los lados: página · ESC o toca arriba a la derecha: volver"
	ayuda.position = Vector2(24, 82)
	ayuda.add_theme_font_size_override("font_size", 14)
	ayuda.add_theme_color_override("font_color", Color("5a5470"))
	capa.add_child(ayuda)
	rotulo_datos = Label.new()
	rotulo_datos.position = Vector2(24, 54)
	rotulo_datos.add_theme_font_size_override("font_size", 16)
	rotulo_datos.add_theme_color_override("font_color", Color("3a3450"))
	capa.add_child(rotulo_datos)


# --- Datos ---------------------------------------------------------------------------------------

func _cargar_catalogo() -> Array:
	if not FileAccess.file_exists(CATALOGO):
		return []
	var texto := FileAccess.get_file_as_string(CATALOGO)
	var datos = JSON.parse_string(texto)
	return datos if datos is Array else []


func _receta(familia: String, tamano: String, elemento: String, rol: String, semilla: int,
		extra := {}) -> Dictionary:
	var receta := {"familia": familia, "tamano": tamano, "elemento": elemento, "rol": rol,
		"semilla": semilla, "rango": 1}
	receta.merge(extra, true)
	return receta


func _con_rango(receta: Dictionary, rango: int) -> Dictionary:
	var copia := receta.duplicate(true)
	copia["rango"] = rango
	return copia


func _definir_paginas() -> Array:
	var kappa := _receta("bipedo", "S", "agua", "veloz", 353, {"nombre": "Kappa", "forma": "",
		"partes": ["caparazon", "plato", "pico", "ojos"], "paleta": [Color("3f8f7a"), Color("2c4a3a"), Color("f3e9a0")]})
	var oni := _receta("bipedo", "M", "fuego", "poderoso", 2315, {"nombre": "Aka-oni",
		"partes": ["cuernos", "garrote", "ojos", "armadura"], "paleta": [Color("b3321f"), Color("33231c"), Color("f1e6c8")]})
	var onibi := _receta("flotante", "S", "fuego", "enjambre", 2301, {"nombre": "Onibi", "forma": "llama",
		"partes": ["ojos"], "paleta": [Color("7aa0ff"), Color("2c2468"), Color("e0ecff")]})
	var oni_gigante := _receta("bipedo", "XL", "fuego", "gigante", 2326, {"nombre": "Oni gigante",
		"partes": ["cuernos", "garrote", "ojos"], "paleta": [Color("8e2a1c"), Color("2a1a14"), Color("ffb347")]})
	var lista: Array = []
	# Akira (el joven endurecido y sus tres skins) y Shiro, desde la 0.6
	var personajes: Array = []
	for id in Apariencias.ORDEN:
		personajes.append({"personaje": "akira", "apariencia": id, "tamano": "M",
			"nombre": String(Apariencias.APARIENCIAS[id].nombre)})
	personajes.insert(1, {"personaje": "shiro", "tamano": "S", "nombre": "Shiro"})
	lista.append({"titulo": "Akira (el joven endurecido y sus tres skins) y Shiro", "filas": [personajes]})
	if ModeloCriatura.tiene_modelo(2315):
		var detallado := {"detallado": true, "id": 2315}
		var oni_modelo := _receta("bipedo", "M", "fuego", "poderoso", 2315, detallado.merged({"nombre": "Aka-oni (modelo)"}))
		var oni_piezas := oni.duplicate(true)
		oni_piezas["nombre"] = "Aka-oni (piezas)"
		# Rótulos cortos en los rangos para que no se pisen: «Alfa (rango 2)», «Silenciada (rango 3)»
		var filas_modelo: Array = [[oni_piezas, oni_modelo, _con_rango(oni_modelo, 2).merged({"nombre": "Alfa"}, true),
			_con_rango(oni_modelo, 3).merged({"nombre": "Silenciada"}, true)]]
		if ModeloCriatura.tiene_modelo(353):
			var kappa_modelo := _receta("bipedo", "S", "agua", "veloz", 353, {"detallado": true, "id": 353, "nombre": "Kappa (modelo)"})
			var kappa_piezas := kappa.duplicate(true)
			kappa_piezas["nombre"] = "Kappa (piezas)"
			# Los kappa (pequeños) van delante para que no los tapen los oni
			filas_modelo.push_front([kappa_piezas, kappa_modelo, _con_rango(kappa_modelo, 2).merged({"nombre": "Alfa"}, true),
				_con_rango(kappa_modelo, 3).merged({"nombre": "Silenciada"}, true)])
		if ModeloCriatura.tiene_modelo(680):
			var chochin_modelo := _receta("flotante", "S", "fuego", "enjambre", 680, {"detallado": true, "id": 680, "nombre": "Chōchin (SketchUp)"})
			var chochin_piezas := _receta("flotante", "S", "fuego", "enjambre", 680, {"nombre": "Chōchin (piezas)",
				"partes": ["ojos", "llamas"], "paleta": [Color("eecd96"), Color("231c1e"), Color("ff9632")]})
			filas_modelo.push_front([chochin_piezas, chochin_modelo, _con_rango(chochin_modelo, 2).merged({"nombre": "Alfa"}, true),
				_con_rango(chochin_modelo, 3).merged({"nombre": "Silenciada"}, true)])
		lista.append({"titulo": "Modelos detallados (prueba): piezas frente a modelo propio, con sus tres rangos",
			"filas": filas_modelo})
	lista.append({"titulo": "Capítulo 1 (hechas a mano, un día de trabajo cada una)",
		"filas": [[kappa, oni, onibi, oni_gigante]]})
	lista.append({"titulo": "Tres rangos de cada criatura: base · alfa (variante fuerte) · silenciada",
		"filas": [[onibi, _con_rango(onibi, 2), _con_rango(onibi, 3)], [kappa, _con_rango(kappa, 2), _con_rango(kappa, 3)],
			[oni, _con_rango(oni, 2), _con_rango(oni, 3)]]})
	var por_familia: Array = []
	for i in FAMILIAS.size():
		var elemento: String = ["sombra", "fuego", "veneno", "rayo", "agua", "luz", "tierra"][i]
		por_familia.append(_receta(FAMILIAS[i], "M", elemento, "veloz", 100 + i * 17,
			{"nombre": FAMILIAS[i]}))
	lista.append({"titulo": "Las 7 familias de cuerpo, sin retoques (lo que sale solo)", "filas": [por_familia]})
	var iconicas: Array = [
		_receta("alado", "XL", "luz", "gigante", 263, {"nombre": "Bahamut (aprox.)", "partes": ["cuernos", "espinas", "ojos"],
			"paleta": [Color("d9d6cf"), Color("5f6a73"), Color("6fe0d8")]}),
		_receta("artropodo", "L", "veneno", "emboscador", 355, {"nombre": "Jorōgumo (aprox.)"}),
		_receta("serpentino", "XL", "agua", "gigante", 2310, {"nombre": "Yamata no Orochi (1 de 8)"}),
		_receta("cuadrupedo", "L", "rayo", "engano", 2307, {"nombre": "Nue (aprox.)", "partes": ["cuernos", "espinas", "ojos"]}),
	]
	lista.append({"titulo": "Criaturas que necesitan modelo propio: así quedan con solo piezas de familia", "filas": [iconicas]})
	# Muestras del catálogo agrupadas por tamaño: así cada fila tiene criaturas parecidas y la cámara
	# no se aleja de más por culpa de un gigante. La primera página es la «prueba de carga» (24 a la vez).
	var carga := _muestras_del_catalogo("M", 24)
	if not carga.is_empty():
		lista.append({"titulo": "Prueba de carga: 24 criaturas medianas del catálogo, sin retoques",
			"filas": _en_filas(carga, 8)})
		lista.append({"titulo": "Pequeñas del catálogo (muestra al azar, sin retoques)",
			"filas": _en_filas(_muestras_del_catalogo("S", 21), 7)})
		lista.append({"titulo": "Grandes del catálogo (muestra al azar, sin retoques)",
			"filas": _en_filas(_muestras_del_catalogo("L", 12), 6)})
		lista.append({"titulo": "Gigantes del catálogo (muestra al azar, sin retoques)",
			"filas": _en_filas(_muestras_del_catalogo("XL", 8), 4)})
	return lista


func _en_filas(recetas: Array, por_fila: int) -> Array:
	var filas: Array = []
	var n := 0
	while n < recetas.size():
		filas.append(recetas.slice(n, n + por_fila))
		n += por_fila
	return filas


# Elige criaturas del catálogo de un tamaño, repartidas por familias (siempre las mismas: semilla fija).
func _muestras_del_catalogo(tamano: String, cantidad: int) -> Array:
	var candidatas: Array = catalogo.filter(func(e):
		return e.get("tipo_entrada", "criatura") in ["criatura"] and int(e.get("sensibilidad", 0)) < 2 \
			and e.get("tamano") == tamano)
	var azar := RandomNumberGenerator.new()
	azar.seed = 2026
	var salida: Array = []
	var por_familia := {}
	for familia in FAMILIAS:
		por_familia[familia] = candidatas.filter(func(e): return e.get("familia") == familia)
	var i := 0
	while salida.size() < cantidad and not candidatas.is_empty():
		var familia: String = FAMILIAS[i % FAMILIAS.size()]
		i += 1
		var grupo: Array = por_familia[familia]
		if grupo.is_empty():
			if i > 200:
				break
			continue
		var elegida: Dictionary = grupo[azar.randi() % grupo.size()]
		grupo.erase(elegida)
		salida.append(_receta(familia, tamano, String(elegida.get("elemento", "ninguno")),
			String(elegida.get("rol", "veloz")), int(elegida.get("id", 1)), {"nombre": String(elegida.get("nombre", "?"))}))
	return salida


# --- Páginas -------------------------------------------------------------------------------------

func _limpiar() -> void:
	for c in criaturas:
		c.queue_free()
	for r in rotulos:
		r.queue_free()
	criaturas.clear()
	rotulos.clear()


func _mostrar_pagina(numero: int) -> void:
	pagina = clampi(numero, 0, paginas.size() - 1)
	_limpiar()
	var datos: Dictionary = paginas[pagina]
	var filas: Array = datos.filas
	var ancho_max := 0.0
	var total_piezas := 0
	var z := 0.0                      # profundidad de la fila actual (hacia atrás es negativo)
	for f in filas.size():
		var fila: Array = filas[f]
		var ancho_fila := 0.0
		var escala_fila := 0.5
		for receta in fila:
			ancho_fila += _separacion(receta)
			escala_fila = maxf(escala_fila, _escala(receta))
		ancho_max = maxf(ancho_max, ancho_fila)
		var x := -ancho_fila / 2.0
		for receta in fila:
			var ancho := _separacion(receta)
			var criatura
			if receta.has("personaje"):
				criatura = Figura.new()
			elif receta.get("detallado", false):
				criatura = ModeloCriatura.new()
			else:
				criatura = Criatura.new()
			add_child(criatura)
			criatura.configurar(aspecto, receta)
			criatura.position = Vector3(x + ancho / 2.0, 0.0, z)
			criatura.rotation.y = 0.35
			criaturas.append(criatura)
			total_piezas += criatura.piezas
			var rotulo := Label3D.new()
			rotulo.text = String(receta.get("nombre", "")) + ("" if int(receta.get("rango", 1)) == 1 else "  (rango %d)" % int(receta.rango))
			rotulo.font_size = 40
			rotulo.pixel_size = 0.0065 * maxf(0.7, minf(ancho / 2.6, 2.2))
			rotulo.modulate = Color("1c1830")
			rotulo.outline_size = 0
			rotulo.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			rotulo.no_depth_test = true       # que el suelo y las criaturas no se coman las letras
			rotulo.position = Vector3(x + ancho / 2.0, 0.22, z + 0.9 * _escala(receta) + 0.4)
			add_child(rotulo)
			rotulos.append(rotulo)
			x += ancho
		z -= 2.6 + 2.0 * escala_fila
	_encuadrar(ancho_max, -(z + 2.6 + 2.0 * 0.5), filas.size())
	rotulo_titulo.text = String(datos.titulo)
	texto_datos = "página %d de %d · %d criaturas · %d piezas en total (%.0f por criatura)" % [
		pagina + 1, paginas.size(), criaturas.size(), total_piezas, float(total_piezas) / maxf(criaturas.size(), 1.0)]
	rotulo_datos.text = texto_datos + (" · %d FPS" % Engine.get_frames_per_second())


# Pone la cámara para que quepan el ancho de la fila más ancha y la criatura más alta.
func _encuadrar(ancho: float, profundidad: float, filas: int) -> void:
	var alto := 2.0
	for c in criaturas:
		alto = maxf(alto, 3.0 * c.cuerpo.scale.y)
	var formato := get_viewport().get_visible_rect().size
	var fov_v := deg_to_rad(camara.fov)
	var fov_h := 2.0 * atan(tan(fov_v / 2.0) * formato.x / formato.y)
	var d_ancho := (ancho / 2.0 + 1.0) / tan(fov_h / 2.0)
	var d_alto := (alto / 2.0 + 0.8) / tan(fov_v / 2.0)
	var distancia := (maxf(d_ancho, d_alto) + profundidad * 0.8) * 1.06
	# con varias filas la cámara sube para que no se tapen unas a otras
	var elevacion := 0.3 if filas <= 1 else 0.5
	camara.position = Vector3(0, distancia * elevacion + alto * 0.35, distancia - profundidad * 0.3)
	camara.look_at(Vector3(0, alto * 0.45, -profundidad * 0.5), Vector3.UP)


# Ancho que ocupa cada criatura en la fila (según su tamaño)
func _separacion(receta: Dictionary) -> float:
	return maxf(1.3, 1.7 * _escala(receta) + 0.7)


func _escala(receta: Dictionary) -> float:
	return Criatura.ESCALA.get(String(receta.get("tamano", "M")), 1.0) * (1.2 if int(receta.get("rango", 1)) == 2 else 1.0)


func _process(delta: float) -> void:
	tiempo += delta
	for c in criaturas:
		c.actualizar(delta)
	tiempo_fps += delta
	if tiempo_fps >= 0.5:
		tiempo_fps = 0.0
		rotulo_datos.text = texto_datos + (" · %d FPS" % Engine.get_frames_per_second())


func _input(evento: InputEvent) -> void:
	if con_capturas:
		return
	var tamano := get_viewport().get_visible_rect().size
	if evento is InputEventKey and evento.pressed:
		if evento.keycode == KEY_RIGHT:
			_mostrar_pagina(pagina + 1)
		elif evento.keycode == KEY_LEFT:
			_mostrar_pagina(pagina - 1)
		elif evento.keycode == KEY_ESCAPE:
			_salir()
		get_viewport().set_input_as_handled()
	elif evento is InputEventScreenTouch and evento.pressed:
		_tocar(evento.position, tamano)
		get_viewport().set_input_as_handled()
	elif evento is InputEventMouseButton and evento.pressed and evento.device != InputEvent.DEVICE_ID_EMULATION:
		_tocar(evento.position, tamano)
		get_viewport().set_input_as_handled()


func _tocar(posicion: Vector2, tamano: Vector2) -> void:
	if posicion.x > tamano.x - 120.0 and posicion.y < 120.0:
		_salir()
	elif posicion.x < tamano.x * 0.33:
		_mostrar_pagina(pagina - 1)
	elif posicion.x > tamano.x * 0.67:
		_mostrar_pagina(pagina + 1)


func _salir() -> void:
	if get_parent() != null and get_parent().has_method("cerrar_galeria"):
		salio.emit()
	else:
		get_tree().quit()


func _recorrer_y_capturar() -> void:
	for i in paginas.size():
		_mostrar_pagina(i)
		for cuadro in 40:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var imagen := get_viewport().get_texture().get_image()
		var ruta := carpeta_capturas.path_join("bestiario_%02d.png" % (i + 1))
		imagen.save_png(ruta)
		print("Captura: ", ruta, "  ·  ", texto_datos)
	get_tree().quit()
