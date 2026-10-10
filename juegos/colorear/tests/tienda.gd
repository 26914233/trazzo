# Pantallas para la ficha de Play: laminas pintadas con armonia (no al azar) y las
# pantallas principales. Necesita pantalla (xvfb-run):
#   xvfb-run godot --path juegos/colorear --resolution 1080x1920 res://tests/tienda.tscn -- --salida=docs/capturas
# Usa obras y ajustes aparte para no tocar los del jugador.
extends Node

var _salida := "user://tienda"
var _actual: Node

# lamina, paleta, semilla: elegidas a mano por como quedan
const OBRAS := [
	["animales_i010", 0, 3], ["mandalas_i018", 3, 1], ["mandalas_001", 5, 2], ["fantasia_i003", 2, 4],
	["insectos_i002", 1, 5], ["oceano_i025", 2, 6], ["vitrales_001", 5, 7], ["aves_i025", 0, 8],
	["animales_i034", 2, 9],
]


func _ready() -> void:
	await get_tree().process_frame
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--salida="):
			_salida = a.trim_prefix("--salida=")
	DirAccess.make_dir_recursive_absolute(_salida)
	Obras.carpeta = "user://tienda_obras/"
	DirAccess.make_dir_recursive_absolute(Obras.carpeta)
	for f in DirAccess.get_files_at(Obras.carpeta):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Obras.carpeta.path_join(f)))
	Obras.olvidar_cache()
	Ajustes.ruta = "user://tienda_ajustes.json"
	Ajustes.datos["sonido"] = false
	Diario.ruta = "user://tienda_diario.json"
	Diario.cargar()

	# obras terminadas (para Mis obras y el grafico destacado)
	for o in OBRAS:
		var l := Laminas.abrir(o[0])
		pintar_bonito(l, Paletas.colores(o[1]), o[2], 1.0)
		Obras.guardar(l)
		l.imagen().save_png(_salida.path_join("obra_%s.png" % o[0]))

	var C = preload("res://escenas/colorear.gd")
	var M = preload("res://escenas/menu.gd")
	# 1. pintando (casi terminada) con zoom suave
	C.lamina_id = "aves_i005"
	var e: Node = await _pantalla("res://escenas/colorear.tscn")
	pintar_bonito(e.lamina, Paletas.colores(3), 1, 0.8)   # aves_i005 no esta en OBRAS: empieza en blanco
	e._estaba_terminada = false
	e._poner_paleta(3)
	await _esperar(6)
	_guardar("1-pintando")
	# 2. buscar zona sin pintar
	# la zona en blanco mas grande (de tamaño medio) para que el resalte se vea en la ficha
	var objetivo := 0
	var mejor := 0
	for z in range(1, e.lamina.zonas + 1):
		var c: Vector2i = e.lamina.caja(z)
		var lado := maxi(c.x, c.y)
		if e.lamina.colores[z] == Color.WHITE and lado < 260 and lado > mejor:
			mejor = lado
			objetivo = z
	e.vista.enfocar(objetivo)
	await _esperar(46)
	_guardar("2-buscar-zona")
	e.vista.reiniciar_zoom()
	# 3. terminada (celebracion)
	for z in range(1, e.lamina.zonas + 1):
		if e.lamina.colores[z] == Color.WHITE:
			e.lamina.pintar(z, Paletas.colores(3)[z % 12])
	e._estaba_terminada = false
	e._al_cambiar()
	await get_tree().create_timer(0.4).timeout     # confeti en el aire, lineas aun visibles
	_guardar("3-terminada")
	await get_tree().create_timer(2.0).timeout
	# 4. menu con la lamina del dia y la biblioteca
	M.categoria_actual = "animales"
	await _pantalla("res://escenas/menu.tscn")
	_guardar("4-biblioteca")
	# 5. mis obras
	M.categoria_actual = "obras"
	await _pantalla("res://escenas/menu.tscn")
	_guardar("5-mis-obras")
	# 6. color libre
	Ajustes.fijar("mis_colores", ["#e63946", "#f4a261", "#2a9d8f", "#264653", "#e9c46a", "#8338ec"])
	C.lamina_id = "mandalas_001"
	e = await _pantalla("res://escenas/colorear.tscn")
	e._poner_paleta(Paletas.MIS_COLORES)
	e.elegir_color_libre()
	await _esperar(20)
	_guardar("6-color-libre")
	get_tree().quit()


## Colores por campos suaves segun la posicion de cada zona: zonas vecinas se
## parecen y el conjunto se ve armonioso. Solo la zona mas grande (el fondo) va
## clara y las grandes, suavizadas. cuanto: parte de las zonas que se pintan.
static func pintar_bonito(l: Lamina, cols: Array, semilla: int, cuanto: float) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = semilla
	var a := rng.randf() * TAU
	var b := rng.randf() * TAU
	var ancho := float(l.regiones.get_width())
	var area := _areas(l)
	var total := ancho * ancho
	var fondo := 1
	for z in range(1, l.zonas + 1):
		if area[z] > area[fondo]:
			fondo = z
	var n := cols.size()
	for z in range(1, l.zonas + 1):
		if rng.randf() > cuanto:
			continue
		if z == fondo:
			l.pintar(z, cols[semilla % n].lerp(Color.WHITE, 0.7))
			continue
		var p := Vector2(l.punto(z)) / ancho
		var f := sin(p.x * 4.1 + a) + cos(p.y * 3.3 + b) + 0.5 * sin((p.x - p.y) * 7.0 + a)
		var i := int(floor((f + 2.5) / 5.0 * n * 1.6)) + (z % 2)
		var c: Color = cols[posmod(i, n)]
		if area[z] > total * 0.06:
			c = c.lerp(Color.WHITE, 0.3)      # zonas grandes: algo mas suaves
		l.pintar(z, c)


static func _areas(l: Lamina) -> PackedInt32Array:
	var r: Image = l.regiones.duplicate()
	r.convert(Image.FORMAT_RGB8)
	var d: PackedByteArray = r.get_data()
	var area := PackedInt32Array()
	area.resize(l.zonas + 1)
	for i in range(0, d.size(), 3):
		var z: int = d[i] + d[i + 1] * 256
		if z <= l.zonas:
			area[z] += 1
	return area


static func _limpiar(l: Lamina) -> void:
	for z in range(1, l.zonas + 1):
		l.pintar(z, Color.WHITE)


func _pantalla(escena: String) -> Node:
	if _actual:
		_actual.queue_free()
		await _esperar(2)
	_actual = load(escena).instantiate()
	add_child(_actual)
	await _esperar(8)
	return _actual


func _esperar(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _guardar(nombre: String) -> void:
	get_viewport().get_texture().get_image().save_png(_salida.path_join(nombre + ".png"))
