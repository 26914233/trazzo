# Construye el patio del castillo de Hoshiyama con las medidas de DISENO_3D.md:
# suelo, muros, portón, torreón, pasarela, obstáculos, linternas, pozo, antorchas,
# luna y ambiente. Los materiales salen de aspecto.gd (cel-shading).
extends RefCounted

const Datos := preload("res://scripts/datos.gd")
# Con el renderizador Compatibility, cada luz que toca un objeto lo vuelve a dibujar entero.
# Por eso el suelo y los muros van en trozos (cada trozo recibe solo las luces cercanas) y
# el terreno de fuera va en una capa que solo ilumina la luna.
const CAPA_SOLO_LUNA := 2
const TROZO := 8.0

var aspecto
var raiz: Node3D
var antorchas: Array = []     # {"luz", "fuego", "fase", "base"}
var tiempo := 0.0
var sin_sombra := false       # las piezas que se crean mientras es true no dan sombra
var ambiente: Dictionary = {}  # el del escenario (escenarios.gd); vacío: la noche del capítulo 1


func construir(destino: Node3D, aspecto_del_juego, ambiente_del_escenario := {}) -> void:
	raiz = destino
	aspecto = aspecto_del_juego
	ambiente = ambiente_del_escenario
	_luna_y_ambiente()
	_suelos()
	_muros()
	_porton()
	_torreon()
	_pasarela_y_obstaculos()
	_linternas()
	_pozo()
	_cajas_y_barriles()
	_antorchas()


func actualizar(delta: float) -> void:
	tiempo += delta
	for antorcha in antorchas:
		var t: float = tiempo * 9.0 + antorcha.fase
		antorcha.luz.light_energy = antorcha.base * (0.86 + 0.09 * sin(t) + 0.06 * sin(t * 2.7))
		antorcha.fuego.scale = Vector3(1.0, 0.85 + 0.25 * abs(sin(t * 0.7)), 1.0)


# --- Piezas básicas -----------------------------------------------------------------

func _material(superficie) -> Material:
	return superficie if superficie is Material else aspecto.material_superficie(superficie)


func _malla(malla: Mesh, superficie, posicion: Vector3) -> MeshInstance3D:
	var instancia := MeshInstance3D.new()
	instancia.mesh = malla
	instancia.material_override = _material(superficie)
	instancia.position = posicion
	if sin_sombra:
		instancia.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	raiz.add_child(instancia)
	return instancia


func _cuerpo(forma: Shape3D, posicion: Vector3) -> void:
	var cuerpo := StaticBody3D.new()
	cuerpo.position = posicion
	var colision := CollisionShape3D.new()
	colision.shape = forma
	cuerpo.add_child(colision)
	raiz.add_child(cuerpo)


func caja(centro: Vector3, tamano: Vector3, superficie, solida := true) -> MeshInstance3D:
	var malla := BoxMesh.new()
	malla.size = tamano
	var instancia := _malla(malla, superficie, centro)
	if solida:
		var forma := BoxShape3D.new()
		forma.size = tamano
		_cuerpo(forma, centro)
	return instancia


func cilindro(base: Vector3, radio: float, alto: float, superficie, solido := true,
		radio_arriba := -1.0, lados := 16) -> MeshInstance3D:
	var malla := CylinderMesh.new()
	malla.bottom_radius = radio
	malla.top_radius = radio if radio_arriba < 0.0 else radio_arriba
	malla.height = alto
	malla.radial_segments = lados
	malla.rings = 1
	var centro := base + Vector3(0, alto / 2.0, 0)
	var instancia := _malla(malla, superficie, centro)
	if solido:
		var forma := CylinderShape3D.new()
		forma.radius = maxf(radio, malla.top_radius)
		forma.height = alto
		_cuerpo(forma, centro)
	return instancia


func _cuadrilatero(herramienta: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	for vertice in [a, b, c, a, c, d]:
		herramienta.add_vertex(vertice)


func tronco_piramide(base: Vector3, ancho_abajo: float, fondo_abajo: float, ancho_arriba: float,
		fondo_arriba: float, alto: float, superficie) -> MeshInstance3D:
	# Tejados y bases en talud: pirámide truncada de base rectangular, con caras planas.
	var herramienta := SurfaceTool.new()
	herramienta.begin(Mesh.PRIMITIVE_TRIANGLES)
	var ab := ancho_abajo / 2.0
	var pb := fondo_abajo / 2.0
	var aa := ancho_arriba / 2.0
	var pa := fondo_arriba / 2.0
	var abajo := [Vector3(-ab, 0, -pb), Vector3(ab, 0, -pb), Vector3(ab, 0, pb), Vector3(-ab, 0, pb)]
	var arriba := [Vector3(-aa, alto, -pa), Vector3(aa, alto, -pa), Vector3(aa, alto, pa), Vector3(-aa, alto, pa)]
	for i in 4:
		var j := (i + 1) % 4
		_cuadrilatero(herramienta, abajo[i], abajo[j], arriba[j], arriba[i])
	_cuadrilatero(herramienta, arriba[0], arriba[1], arriba[2], arriba[3])
	_cuadrilatero(herramienta, abajo[3], abajo[2], abajo[1], abajo[0])
	herramienta.generate_normals()
	return _malla(herramienta.commit(), superficie, base)


# --- Cielo, luna y ambiente -------------------------------------------------------------

func _luna_y_ambiente() -> void:
	var mundo := WorldEnvironment.new()
	var entorno := Environment.new()
	aspecto.configurar_entorno(entorno, ambiente)
	mundo.environment = entorno
	raiz.add_child(mundo)
	var luna := DirectionalLight3D.new()
	luna.light_color = ambiente.get("luz_luna", Datos.LUZ_LUNA)
	luna.light_energy = ambiente.get("energia_luna", 0.95)
	luna.shadow_enabled = true
	luna.shadow_opacity = 0.75    # la sombra deja pasar algo de luna: se lee mejor el patio
	luna.directional_shadow_max_distance = 35.0
	var direccion: Vector3 = ambiente.get("direccion_luna", Datos.DIRECCION_LUNA)
	luna.transform.basis = Basis.looking_at(-direccion.normalized(), Vector3.UP)
	raiz.add_child(luna)


# --- Suelo y muros -----------------------------------------------------------------------

func _suelos() -> void:
	var terreno := PlaneMesh.new()
	terreno.size = Vector2(220, 220)
	_malla(terreno, "tierra", Vector3(0, -0.02, 0)).layers = CAPA_SOLO_LUNA
	for i in range(int(48 / TROZO)):
		for j in range(int(32 / TROZO)):
			var centro := Vector3(-24 + TROZO * (i + 0.5), -0.25, -16 + TROZO * (j + 0.5))
			caja(centro, Vector3(TROZO, 0.5, TROZO), "losa", false)
	var forma := BoxShape3D.new()
	forma.size = Vector3(48, 0.5, 32)
	_cuerpo(forma, Vector3(0, -0.25, 0))


func _muro(centro: Vector3, tamano: Vector3) -> void:
	var base := 1.2
	var alto_yeso := tamano.y - base
	var a_lo_largo_x := tamano.x > tamano.z
	var largo := tamano.x if a_lo_largo_x else tamano.z
	# base de piedra y yeso, en trozos a lo largo del muro
	var trozos := int(ceil(largo / TROZO))
	for t in range(trozos):
		var medio := -largo / 2.0 + (t + 0.5) * largo / trozos
		var lugar := Vector3(centro.x + medio, 0, centro.z) if a_lo_largo_x else Vector3(centro.x, 0, centro.z + medio)
		var tramo := Vector3(largo / trozos, 0, tamano.z) if a_lo_largo_x else Vector3(tamano.x, 0, largo / trozos)
		var hundido := Vector3(0, 0, 0.08) if a_lo_largo_x else Vector3(0.08, 0, 0)
		caja(lugar + Vector3(0, base / 2.0, 0), tramo + Vector3(0, base, 0), "muro_piedra", false)
		caja(lugar + Vector3(0, base + alto_yeso / 2.0, 0), tramo + Vector3(0, alto_yeso, 0) - hundido, "yeso", false)
	caja(Vector3(centro.x, 3.25, centro.z), Vector3(tamano.x + 0.04, 0.2, tamano.z + 0.04), "madera_oscura", false)
	# pilares de madera cada 5 m, que atraviesan el muro
	var cantidad := int(largo / 5.0)
	for k in range(cantidad + 1):
		var desplazamiento := -largo / 2.0 + k * largo / maxf(cantidad, 1)
		var posicion := Vector3(centro.x + desplazamiento, base + alto_yeso / 2.0, centro.z) if a_lo_largo_x \
			else Vector3(centro.x, base + alto_yeso / 2.0, centro.z + desplazamiento)
		var grosor := Vector3(0.26, alto_yeso, tamano.z + 0.06) if a_lo_largo_x else Vector3(tamano.x + 0.06, alto_yeso, 0.26)
		caja(posicion, grosor, "madera_oscura", false)
	# tejadillo
	if a_lo_largo_x:
		tronco_piramide(Vector3(centro.x, tamano.y, centro.z), tamano.x + 0.5, 1.9, tamano.x + 0.1, 0.3, 0.55, "tejas")
	else:
		tronco_piramide(Vector3(centro.x, tamano.y, centro.z), 1.9, tamano.z + 0.5, 0.3, tamano.z + 0.1, 0.55, "tejas")
	var forma := BoxShape3D.new()
	forma.size = tamano
	_cuerpo(forma, centro)


func _muros() -> void:
	_muro(Vector3(0, 2, -16.5), Vector3(50, 4, 1))
	_muro(Vector3(0, 2, 16.5), Vector3(50, 4, 1))
	_muro(Vector3(-24.5, 2, 0), Vector3(1, 4, 32))
	_muro(Vector3(24.5, 2, -9.5), Vector3(1, 4, 13))
	_muro(Vector3(24.5, 2, 9.5), Vector3(1, 4, 13))


func _porton() -> void:
	for z in [-3.5, 3.5]:
		caja(Vector3(24.5, 2.5, z), Vector3(1, 5, 1), "madera_oscura")
	caja(Vector3(24.5, 5.3, 0), Vector3(1.4, 0.6, 8.5), "madera_oscura", false)
	tronco_piramide(Vector3(24.5, 5.6, 0), 2.8, 9.8, 0.4, 7.6, 1.5, "tejas")
	caja(Vector3(24.6, 2.2, 0), Vector3(0.3, 4.4, 6), aspecto.material_superficie("porton"))


# --- Torreón (tenshu), al norte, fuera del patio -------------------------------------------

func _ventanas(centro: Vector3, ancho: float, y: float, cantidad: int, material: Material) -> void:
	for k in cantidad:
		var d := -ancho / 2.0 + (k + 0.5) * ancho / cantidad
		caja(Vector3(centro.x + d, y, centro.z + ancho / 2.0 + 0.02), Vector3(0.7, 0.8, 0.08), material, false)
		caja(Vector3(centro.x + d, y, centro.z - ancho / 2.0 - 0.02), Vector3(0.7, 0.8, 0.08), material, false)
		caja(Vector3(centro.x + ancho / 2.0 + 0.02, y, centro.z + d), Vector3(0.08, 0.8, 0.7), material, false)
		caja(Vector3(centro.x - ancho / 2.0 - 0.02, y, centro.z + d), Vector3(0.08, 0.8, 0.7), material, false)


func _torreon() -> void:
	# La luna está baja detrás del torreón: su sombra taparía casi todo el patio y no se
	# vería a los personajes. El torreón no da sombra (solo se nota que falta si se busca).
	sin_sombra = true
	var c := Vector3(0, 0, -32)
	var ventana: Material = aspecto.material_emisivo(Color("ffb45a"), 2.2)
	tronco_piramide(c, 18, 18, 16.2, 16.2, 6, "muro_piedra")
	# piso 1
	caja(c + Vector3(0, 8.25, 0), Vector3(13, 4.5, 13), "yeso", false)
	_ventanas(c, 13, 8.6, 4, ventana)
	tronco_piramide(c + Vector3(0, 10.4, 0), 17, 17, 9.5, 9.5, 2.5, "tejas")
	# piso 2
	caja(c + Vector3(0, 13, 0), Vector3(10, 4, 10), "yeso", false)
	_ventanas(c, 10, 13.6, 3, ventana)
	tronco_piramide(c + Vector3(0, 15, 0), 13, 13, 6.8, 6.8, 2.2, "tejas")
	# piso 3
	caja(c + Vector3(0, 17.25, 0), Vector3(7, 3.5, 7), "yeso", false)
	_ventanas(c, 7, 17.6, 2, ventana)
	tronco_piramide(c + Vector3(0, 19, 0), 10, 10, 1.4, 1.4, 3, "tejas")
	# remate dorado (shachihoko)
	caja(c + Vector3(0, 22.1, 0), Vector3(1.6, 0.25, 0.3), "dorado", false)
	for lado in [-1, 1]:
		caja(c + Vector3(0.75 * lado, 22.5, 0), Vector3(0.22, 0.7, 0.22), "dorado", false)
	sin_sombra = false


# --- Obstáculos ------------------------------------------------------------------------

func _pasarela_y_obstaculos() -> void:
	caja(Vector3(-3, 0.6, -12), Vector3(10, 1.2, 4), "madera")
	for x in [-7.8, -3, 1.8]:           # vigas del borde, solo decoración
		caja(Vector3(x, 0.6, -9.95), Vector3(0.3, 1.2, 0.12), "madera_oscura", false)
	caja(Vector3(-3, 0.3, -9.5), Vector3(2, 0.6, 1), "madera")
	caja(Vector3(-8, 0.6, 4), Vector3(0.8, 1.2, 6), "muro_piedra")
	caja(Vector3(6, 0.4, -6), Vector3(2, 0.8, 2), "muro_piedra")
	caja(Vector3(8.2, 0.8, -6), Vector3(2, 1.6, 2), "muro_piedra")


func _linternas() -> void:
	for punto in Datos.LINTERNAS:
		linterna(Vector3(punto.x, 0, punto.y))


# Linterna de piedra (tōrō) con su luz; la usan también los escenarios de los capítulos siguientes.
func linterna(base: Vector3, con_luz := true) -> void:
	var luz_interior: Material = aspecto.material_emisivo(Color("ffcf8a"), 2.5)
	cilindro(base, 0.42, 0.22, "piedra_clara", false, 0.36, 8)
	cilindro(base + Vector3(0, 0.22, 0), 0.12, 0.66, "piedra_clara", false, 0.12, 8)
	caja(base + Vector3(0, 1.08, 0), Vector3(0.52, 0.36, 0.52), "piedra_clara", false)
	caja(base + Vector3(0, 1.08, 0), Vector3(0.56, 0.16, 0.3), luz_interior, false)
	caja(base + Vector3(0, 1.08, 0), Vector3(0.3, 0.16, 0.56), luz_interior, false)
	tronco_piramide(base + Vector3(0, 1.26, 0), 0.86, 0.86, 0.14, 0.14, 0.3, "piedra_clara")
	caja(base + Vector3(0, 1.6, 0), Vector3(0.12, 0.12, 0.12), "piedra_clara", false)
	var forma := CylinderShape3D.new()
	forma.radius = 0.4
	forma.height = 1.6
	_cuerpo(forma, base + Vector3(0, 0.8, 0))
	if not con_luz:
		return
	var luz := OmniLight3D.new()
	luz.light_color = Color("ffc278")
	luz.light_energy = 0.45
	luz.omni_range = 3.5
	luz.light_cull_mask = ~CAPA_SOLO_LUNA & 0xFFFFF
	luz.position = base + Vector3(0, 1.1, 0)
	raiz.add_child(luz)


func _pozo() -> void:
	var base := Vector3(0, 0, 8)
	cilindro(base, 1.0, 0.9, "muro_piedra", true, -1.0, 20)
	cilindro(base + Vector3(0, 0.84, 0), 0.8, 0.07, "agua", false, -1.0, 20)
	for x in [-0.95, 0.95]:
		caja(base + Vector3(x, 1.25, 0), Vector3(0.15, 2.5, 0.15), "madera_oscura", false)
	var tejado := PrismMesh.new()
	tejado.size = Vector3(2.6, 0.7, 1.8)
	_malla(tejado, "tejas", base + Vector3(0, 2.8, 0))
	caja(base + Vector3(0, 2.1, 0), Vector3(2.0, 0.1, 0.1), "madera_oscura", false)


func _cajas_y_barriles() -> void:
	caja(Vector3(16, 0.5, 12), Vector3.ONE, "madera")
	caja(Vector3(17.2, 0.5, 12.4), Vector3.ONE, "madera")
	caja(Vector3(16.6, 1.5, 12.2), Vector3.ONE, "madera")
	for punto in [Vector3(-18, 0, -12), Vector3(-18.9, 0, -11.3)]:
		cilindro(punto, 0.45, 1.0, "madera", true, 0.42, 12)
		cilindro(punto + Vector3(0, 0.18, 0), 0.47, 0.08, "hierro", false, 0.47, 12)
		cilindro(punto + Vector3(0, 0.74, 0), 0.45, 0.08, "hierro", false, 0.45, 12)


# --- Antorchas: poste, fuego, luz que parpadea y chispas ----------------------------------

func _antorchas() -> void:
	var azar := RandomNumberGenerator.new()
	azar.seed = 11
	for punto in Datos.ANTORCHAS:
		antorcha(Vector3(punto.x, 0, punto.y), azar.randf() * 10.0)


# Antorcha: poste, fuego, luz que parpadea y chispas. «alto» 0 deja solo el fuego en el suelo (hoguera).
func antorcha(base: Vector3, fase: float, alto := 2.6, energia := 1.7, alcance := 9.0) -> void:
	if alto > 0.0:
		cilindro(base, 0.07, alto, "madera_oscura", true, 0.06, 8)
		cilindro(base + Vector3(0, alto - 0.05, 0), 0.08, 0.16, "hierro", false, 0.21, 10)
	var fuego := Node3D.new()
	fuego.position = base + Vector3(0, alto + 0.1, 0)
	var tamano := 1.0 if alto > 0.0 else 2.2
	for capa in [[0.17, 0.62, Color("ff6a1e")], [0.1, 0.4, Color("ffd66a")]]:
		var cono := CylinderMesh.new()
		cono.bottom_radius = capa[0] * tamano
		cono.top_radius = 0.0
		cono.height = capa[1] * tamano
		cono.radial_segments = 8
		var llama := MeshInstance3D.new()
		llama.mesh = cono
		llama.material_override = aspecto.material_emisivo(capa[2], 3.0)
		llama.position.y = capa[1] * tamano / 2.0
		llama.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		fuego.add_child(llama)
	raiz.add_child(fuego)
	var luz := OmniLight3D.new()
	luz.light_color = Datos.LUZ_ANTORCHA
	luz.light_energy = energia
	luz.omni_range = alcance
	luz.light_cull_mask = ~CAPA_SOLO_LUNA & 0xFFFFF
	luz.position = base + Vector3(0, alto + 0.4, 0)
	raiz.add_child(luz)
	raiz.add_child(_chispas(base + Vector3(0, alto + 0.4, 0)))
	antorchas.append({"luz": luz, "fuego": fuego, "fase": fase, "base": energia})


func _chispas(posicion: Vector3) -> CPUParticles3D:
	var chispas := CPUParticles3D.new()
	chispas.position = posicion
	chispas.amount = 6
	chispas.lifetime = 1.3
	chispas.direction = Vector3.UP
	chispas.spread = 25.0
	chispas.initial_velocity_min = 0.4
	chispas.initial_velocity_max = 1.1
	chispas.gravity = Vector3(0, 0.6, 0)
	chispas.scale_amount_min = 0.5
	chispas.scale_amount_max = 1.0
	var degradado := Gradient.new()
	degradado.set_color(0, Color(1.0, 0.85, 0.45, 1.0))
	degradado.set_color(1, Color(0.9, 0.25, 0.05, 0.0))
	chispas.color_ramp = degradado
	var punto := QuadMesh.new()
	punto.size = Vector2(0.06, 0.06)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	punto.material = material
	chispas.mesh = punto
	return chispas
