# Construye los escenarios de los capítulos 1 a 4 que no son el castillo (escenarios.gd): la planicie,
# la aldea del río, el templo de la montaña, el dojo del monte Kurama en el Kakuriyo, las ruinas del
# oeste, el sello de Bahamut y la planicie bajo la luna roja. Usa las piezas del castillo
# (constructor_mundo.gd) con la misma regla de luces: suelo en trozos y pocas luces, porque en el
# renderizador Compatibility cada luz vuelve a dibujar lo que toca.
#
# Todos tienen la misma forma de juego que el patio: Akira entra por el oeste (x = -22) y sale por el
# este (x > 23) cuando cae el guardián. El área jugable va de x = -26 a 26 y de z = -17 a 17.
extends "res://scripts/constructor_mundo.gd"

const LARGO := 52.0
const ANCHO := 34.0

var azar := RandomNumberGenerator.new()
var flotantes: Array = []             # farolillos del Kakuriyo que suben y bajan: {nodo, base, fase}


func construir_escenario(destino: Node3D, aspecto_del_juego, escenario: Dictionary) -> void:
	raiz = destino
	aspecto = aspecto_del_juego
	ambiente = escenario.get("ambiente", {})
	azar.seed = hash(String(escenario.id))
	_luna_y_ambiente()
	match String(escenario.mundo):
		"planicie":
			_planicie(false)
		"planicie_roja":
			_planicie(true)
		"aldea":
			_aldea()
		"templo":
			_templo()
		"dojo":
			_dojo()
		"ruinas":
			_ruinas()
		"santuario":
			_santuario()
	_limites()


func actualizar(delta: float) -> void:
	super.actualizar(delta)
	for flotante in flotantes:
		flotante.nodo.position.y = flotante.base + sin(tiempo * 1.3 + flotante.fase) * 0.25


# --- Piezas comunes ----------------------------------------------------------------------------

func _suelo(superficie: String, lejos := "tierra") -> void:
	var terreno := PlaneMesh.new()
	terreno.size = Vector2(220, 220)
	_malla(terreno, lejos, Vector3(0, -0.02, 0)).layers = CAPA_SOLO_LUNA
	for i in range(int(56 / TROZO)):
		for j in range(int(40 / TROZO)):
			var centro := Vector3(-28 + TROZO * (i + 0.5), -0.25, -20 + TROZO * (j + 0.5))
			caja(centro, Vector3(TROZO, 0.5, TROZO), superficie, false)
	var forma := BoxShape3D.new()
	forma.size = Vector3(80, 0.5, 60)
	_cuerpo(forma, Vector3(0, -0.25, 0))


# Paredes invisibles alrededor del área jugable (lo de fuera es decorado). Son bajas (2,6 m: nadie
# salta tanto) para que no corten el rayo con el que la cámara evita los muros.
func _limites() -> void:
	for lado in [-1, 1]:
		var muro := BoxShape3D.new()
		muro.size = Vector3(1, 2.6, ANCHO + 4)
		_cuerpo(muro, Vector3(lado * (LARGO / 2.0 + 0.5) + (2.0 if lado > 0 else 0.0), 1.3, 0))
		var largo := BoxShape3D.new()
		largo.size = Vector3(LARGO + 8, 2.6, 1)
		_cuerpo(largo, Vector3(0, 1.3, lado * (ANCHO / 2.0 + 0.5)))


func _franja(desde_x: float, hasta_x: float, z: float, ancho: float, superficie: String, alto := 0.01) -> void:
	sin_sombra = true
	caja(Vector3((desde_x + hasta_x) / 2.0, alto / 2.0, z), Vector3(hasta_x - desde_x, alto, ancho), superficie, false)
	sin_sombra = false


func _pino(base: Vector3, alto: float, hojas := "hojas_pino") -> void:
	cilindro(base, 0.18 * alto / 6.0 + 0.1, alto * 0.45, "corteza", true, 0.12, 8)
	for k in 3:
		var radio := (1.5 - k * 0.38) * alto / 6.0
		var cono := CylinderMesh.new()
		cono.bottom_radius = radio
		cono.top_radius = 0.0
		cono.height = alto * 0.38
		cono.radial_segments = 8
		cono.rings = 1
		_malla(cono, hojas, base + Vector3(0, alto * (0.38 + k * 0.2), 0))


func _arbol_seco(base: Vector3, alto: float) -> void:
	cilindro(base, 0.16, alto, "corteza", true, 0.07, 6)
	for k in 3:
		var rama := caja(base + Vector3(0, alto * (0.55 + k * 0.13), 0), Vector3(1.4 - k * 0.3, 0.08, 0.08), "corteza", false)
		rama.rotation = Vector3(0, azar.randf() * TAU, 0.5 - k * 0.3)


func _roca(base: Vector3, tamano: float, superficie := "roca") -> void:
	var bola := SphereMesh.new()
	bola.radius = tamano
	bola.height = tamano * 1.3
	bola.radial_segments = 7
	bola.rings = 3
	var roca := _malla(bola, superficie, base + Vector3(0, tamano * 0.3, 0))
	roca.rotation.y = azar.randf() * TAU
	roca.scale = Vector3(1.0 + azar.randf() * 0.4, 1.0, 0.8 + azar.randf() * 0.4)
	var forma := CylinderShape3D.new()
	forma.radius = tamano * 0.9
	forma.height = tamano * 1.2
	_cuerpo(forma, base + Vector3(0, tamano * 0.6, 0))


func _colina(centro: Vector3, ancho: float, alto: float, superficie := "hierba") -> void:
	sin_sombra = true
	tronco_piramide(centro, ancho, ancho * 0.8, ancho * 0.35, ancho * 0.25, alto, superficie)
	sin_sombra = false


# Matas de hierba alta: una sola malla repetida (MultiMesh), sin colisión.
func _hierba(cantidad: int, color: Color, evitar_camino := true) -> void:
	var brizna := PrismMesh.new()
	brizna.size = Vector3(0.18, 0.7, 0.05)
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = brizna
	multi.instance_count = cantidad
	for i in cantidad:
		var x := azar.randf_range(-25.0, 25.0)
		var z := azar.randf_range(-16.0, 16.0)
		if evitar_camino and absf(z) < 3.0:
			z += 6.0 * signf(z if z != 0.0 else 1.0)
		var escala := azar.randf_range(0.6, 1.4)
		var giro := Basis(Vector3.UP, azar.randf() * TAU).scaled(Vector3(escala, escala, escala))
		multi.set_instance_transform(i, Transform3D(giro, Vector3(x, 0.3 * escala, z)))
	var instancia := MultiMeshInstance3D.new()
	instancia.multimesh = multi
	instancia.material_override = aspecto.material_toon(color, false, false)
	instancia.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	raiz.add_child(instancia)


func _agua(centro: Vector3, tamano: Vector2) -> void:
	sin_sombra = true
	caja(centro + Vector3(0, 0.015, 0), Vector3(tamano.x, 0.03, tamano.y), "agua", false)
	sin_sombra = false


func _puente(centro: Vector3, largo: float, ancho: float) -> void:
	caja(centro + Vector3(0, 0.12, 0), Vector3(largo, 0.12, ancho), "madera", false)
	for lado in [-1, 1]:
		caja(centro + Vector3(0, 0.75, lado * ancho / 2.0), Vector3(largo, 0.1, 0.1), "madera_oscura", false)
		for k in 4:
			caja(centro + Vector3(-largo / 2.0 + k * largo / 3.0, 0.45, lado * ancho / 2.0), Vector3(0.14, 0.7, 0.14), "madera_oscura")


func _casa(centro: Vector3, ancho: float, fondo: float, de_paja := true) -> void:
	caja(centro + Vector3(0, 0.35, 0), Vector3(ancho + 0.3, 0.7, fondo + 0.3), "muro_piedra", false)
	caja(centro + Vector3(0, 1.6, 0), Vector3(ancho, 1.9, fondo), "yeso", false)
	for esquina in [Vector3(-1, 0, -1), Vector3(1, 0, -1), Vector3(-1, 0, 1), Vector3(1, 0, 1)]:
		caja(centro + Vector3(esquina.x * ancho / 2.0, 1.6, esquina.z * fondo / 2.0), Vector3(0.22, 1.9, 0.22), "madera_oscura", false)
	caja(centro + Vector3(0, 1.3, fondo / 2.0 + 0.02), Vector3(1.0, 1.6, 0.06), "madera_oscura", false)
	var ventana: Material = aspecto.material_emisivo(Color("ffb45a"), 1.6)
	caja(centro + Vector3(ancho * 0.28, 1.7, fondo / 2.0 + 0.03), Vector3(0.7, 0.5, 0.05), ventana, false)
	tronco_piramide(centro + Vector3(0, 2.55, 0), ancho + 1.4, fondo + 1.4, 0.4, fondo * 0.25, 1.8, "paja" if de_paja else "tejas")
	var forma := BoxShape3D.new()
	forma.size = Vector3(ancho + 0.3, 3.0, fondo + 0.3)
	_cuerpo(forma, centro + Vector3(0, 1.5, 0))


func _torii(base: Vector3, escala := 1.0, superficie := "bermellon") -> void:
	for lado in [-1, 1]:
		cilindro(base + Vector3(0, 0, lado * 1.6 * escala), 0.17 * escala, 3.4 * escala, superficie, true, 0.15 * escala, 10)
	caja(base + Vector3(0, 2.75 * escala, 0), Vector3(0.22 * escala, 0.2 * escala, 3.9 * escala), superficie, false)
	caja(base + Vector3(0, 3.45 * escala, 0), Vector3(0.36 * escala, 0.22 * escala, 4.6 * escala), superficie, false)
	caja(base + Vector3(0, 3.62 * escala, 0), Vector3(0.42 * escala, 0.12 * escala, 4.9 * escala), "madera_oscura", false)


func _farolillo(base: Vector3, color := Color("ff7a3a"), alto := 2.2, flotante := false) -> void:
	if not flotante:
		cilindro(base, 0.05, alto, "madera_oscura", false, 0.05, 6)
	var bola := SphereMesh.new()
	bola.radius = 0.22
	bola.height = 0.5
	bola.radial_segments = 8
	bola.rings = 4
	var farol := _malla(bola, aspecto.material_emisivo(color, 2.2), base + Vector3(0, alto, 0))
	farol.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if flotante:
		flotantes.append({"nodo": farol, "base": farol.position.y, "fase": azar.randf() * TAU})


func _luz(punto: Vector3, color: Color, energia := 1.2, alcance := 8.0) -> void:
	var luz := OmniLight3D.new()
	luz.light_color = color
	luz.light_energy = energia
	luz.omni_range = alcance
	luz.light_cull_mask = ~CAPA_SOLO_LUNA & 0xFFFFF
	luz.position = punto
	raiz.add_child(luz)


func _arco_salida(superficie: String) -> void:
	for lado in [-1, 1]:
		caja(Vector3(24.8, 2.0, lado * 3.4), Vector3(0.6, 4.0, 0.6), superficie)
	caja(Vector3(24.8, 4.2, 0), Vector3(0.8, 0.4, 7.6), superficie, false)


# Pinos y rocas por los bordes del área (dejan libre el centro y el camino).
func _bordes_de_bosque(cantidad: int, hojas := "hojas_pino", seco := false) -> void:
	for i in cantidad:
		var x := azar.randf_range(-25.0, 25.0)
		var lado := -1.0 if i % 2 == 0 else 1.0
		var z := lado * azar.randf_range(13.0, 16.5)
		if seco:
			_arbol_seco(Vector3(x, 0, z), azar.randf_range(3.0, 5.0))
		else:
			_pino(Vector3(x, 0, z), azar.randf_range(5.0, 8.0), hojas)
	for i in 10:
		var lejos := Vector3(azar.randf_range(-40.0, 40.0), 0, (1 if i % 2 == 0 else -1) * azar.randf_range(19.0, 28.0))
		if seco:
			_arbol_seco(lejos, 5.0)
		else:
			_pino(lejos, azar.randf_range(7.0, 11.0), hojas)


# El castillo a lo lejos, al oeste (el que Akira acaba de dejar, o al que vuelve).
func _castillo_lejano(centro: Vector3, ardiendo: bool) -> void:
	sin_sombra = true
	var ventana: Material = aspecto.material_emisivo(Color("ff6a2a") if ardiendo else Color("ffb45a"), 2.6)
	tronco_piramide(centro, 14, 14, 12, 12, 4, "muro_piedra")
	caja(centro + Vector3(0, 6, 0), Vector3(10, 4, 10), "yeso", false)
	caja(centro + Vector3(5.05, 6.4, 0), Vector3(0.1, 0.8, 6), ventana, false)
	tronco_piramide(centro + Vector3(0, 8, 0), 13, 13, 7, 7, 2, "tejas")
	caja(centro + Vector3(0, 10.5, 0), Vector3(6, 3, 6), "yeso", false)
	tronco_piramide(centro + Vector3(0, 12, 0), 9, 9, 1, 1, 2.5, "tejas")
	sin_sombra = false
	if ardiendo:
		_luz(centro + Vector3(8, 6, 0), Color("ff6a2a"), 2.0, 22.0)


# --- Planicie (capítulo 1) y planicie bajo la luna roja (capítulo 4) ------------------------------

func _planicie(roja: bool) -> void:
	_suelo("hierba_roja" if roja else "hierba", "hierba_roja" if roja else "hierba")
	_franja(-28, 28, 0, 5, "camino")
	# El arroyo que cruza de norte a sur, con su puente (los kappa salen de él).
	_agua(Vector3(6, 0, -9.5), Vector2(3.0, 15.0))
	_agua(Vector3(6, 0, 9.5), Vector2(3.0, 15.0))
	_agua(Vector3(6, -0.05, 0), Vector2(3.0, 4.5))
	_puente(Vector3(6, 0, 0), 4.0, 4.0)
	for z in [-14.0, -8.0, 8.0, 14.0]:
		_roca(Vector3(4.2, 0, z), 0.6, "roca_oscura")
		_roca(Vector3(7.9, 0, z + 1.5), 0.5, "roca_oscura")
	_hierba(520, Color("6a2a20") if roja else Color("3a4a2a"))
	_bordes_de_bosque(16, "hojas_pino", roja)
	for i in 9:
		_roca(Vector3(azar.randf_range(-22.0, 22.0), 0, (1 if i % 2 else -1) * azar.randf_range(5.0, 12.0)), azar.randf_range(0.4, 0.9))
	for i in 6:
		_colina(Vector3(-60 + i * 24, 0, -34 if i % 2 else 34), 30, 8, "hierba_roja" if roja else "hierba")
	# La torre de vigía quemada.
	for esquina in [Vector3(-1, 0, -1), Vector3(1, 0, -1), Vector3(-1, 0, 1), Vector3(1, 0, 1)]:
		caja(Vector3(-6, 2.2, -12) + esquina * 1.1, Vector3(0.24, 4.4, 0.24), "madera_oscura")
	caja(Vector3(-6, 3.4, -12), Vector3(2.7, 0.18, 2.7), "madera_oscura", false)
	_castillo_lejano(Vector3(-62, 0, -6), true)
	# Hogueras de los soldados de Genzo.
	antorcha(Vector3(-12, 0, 9), 1.0, 0.0, 1.6, 9.0)
	antorcha(Vector3(13, 0, -9), 3.0, 0.0, 1.6, 9.0)
	if roja:
		# Tumbas de madera y huesos por la hierba: los muertos sin enterrar del gashadokuro.
		for i in 14:
			var lugar := Vector3(azar.randf_range(-20.0, 20.0), 0, (1 if i % 2 else -1) * azar.randf_range(4.0, 12.0))
			caja(lugar + Vector3(0, 0.6, 0), Vector3(0.14, 1.2, 0.3), "madera_oscura", false)
			caja(lugar + Vector3(0, 0.08, 0.6), Vector3(0.7, 0.12, 0.18), "hueso", false)
		antorcha(Vector3(18, 0, 10), 5.0, 0.0, 1.8, 10.0)
	_arco_salida("madera_oscura")


# --- La aldea del río (capítulo 1) --------------------------------------------------------------

func _aldea() -> void:
	_suelo("tierra", "hierba")
	_franja(-28, 28, 1, 6, "camino")
	# El río del norte, de donde salen los kappa, y sus piedras.
	_agua(Vector3(0, 0, -13.5), Vector2(60, 4.5))
	for i in 12:
		_roca(Vector3(-24 + i * 4.3, 0, -11.0 + azar.randf_range(-0.4, 0.4)), 0.45, "roca_oscura")
	_hierba(260, Color("3a4a2a"))
	# Casas a los dos lados de la calle.
	for x in [-8.0, 2.0, 12.0]:
		_casa(Vector3(x, 0, 11.5), 4.2, 3.6)
	for x in [-16.0, 6.0]:
		_casa(Vector3(x, 0, -6.8), 3.8, 3.0)
	# Campos de arroz inundados al sureste.
	for k in 3:
		_agua(Vector3(18 + (k % 2) * 4.5, 0, 9 + (k / 2) * 4.5), Vector2(4.0, 4.0))
		caja(Vector3(18 + (k % 2) * 4.5, 0.08, 6.8 + (k / 2) * 4.5), Vector3(4.2, 0.16, 0.25), "barro", false)
	# Farolillos de papel a lo largo de la calle.
	for x in [-20.0, -10.0, 0.0, 10.0, 20.0]:
		_farolillo(Vector3(x, 0, 4.6))
	_luz(Vector3(-5, 2.6, 4.6), Color("ff9a5a"), 1.0, 10.0)
	_luz(Vector3(10, 2.6, 4.6), Color("ff9a5a"), 1.0, 10.0)
	# La hoguera del descanso y el puesto del sastre.
	antorcha(Vector3(-15, 0, 10), 2.0, 0.0, 1.5, 8.0)
	for lado in [-1, 1]:
		caja(Vector3(-12 + lado * 1.1, 1.1, -5.2), Vector3(0.12, 2.2, 0.12), "madera_oscura")
	caja(Vector3(-12, 2.25, -5.0), Vector3(2.6, 0.08, 1.4), aspecto.material_emisivo(Color("a02e2a"), 0.4), false)
	caja(Vector3(-12, 0.45, -5.2), Vector3(2.0, 0.9, 0.7), "madera")
	_bordes_de_bosque(10)
	_castillo_lejano(Vector3(-70, 0, 20), true)
	_arco_salida("madera_oscura")
	caja(Vector3(24.8, 4.6, 0), Vector3(1.2, 0.5, 8.2), "paja", false)


# --- El templo de la montaña (capítulo 2) ------------------------------------------------------------

func _templo() -> void:
	_suelo("piedra_musgo", "hierba")
	_franja(-28, 28, 0, 4, "losa")
	# Torii en fila a lo largo del sendero, y linternas de piedra.
	for x in [-16.0, -8.0, 0.0, 8.0]:
		_torii(Vector3(x, 0, 0), 1.0)
	for x in [-12.0, -4.0, 4.0, 12.0]:
		for lado in [-1, 1]:
			linterna(Vector3(x, 0, lado * 3.2), x == -4.0 or x == 12.0)
	# La fila de jizō de piedra (entre ellos se esconden tanuki).
	var Jizo = load("res://scripts/jizo.gd")
	for punto in [Vector3(-8.5, 0, -5), Vector3(-3.5, 0, -5), Vector3(0.5, 0, 5), Vector3(3.5, 0, 5)]:
		var estatua = Jizo.new()
		raiz.add_child(estatua)
		estatua.configurar(aspecto)
		estatua.position = punto
		estatua.rotation.y = PI / 2.0
	# Plataforma de piedra con escalones (allí está uno de los sellos).
	caja(Vector3(4, 0.8, -12.5), Vector3(6, 1.6, 3), "muro_piedra")
	caja(Vector3(4, 0.27, -10.3), Vector3(3, 0.55, 1.4), "piedra_clara")
	caja(Vector3(4, 0.55, -10.8), Vector3(3, 1.1, 0.6), "piedra_clara")
	# Campanario (shōrō).
	for esquina in [Vector3(-1, 0, -1), Vector3(1, 0, -1), Vector3(-1, 0, 1), Vector3(1, 0, 1)]:
		caja(Vector3(-12, 1.6, -11) + esquina * 1.2, Vector3(0.22, 3.2, 0.22), "madera_oscura")
	tronco_piramide(Vector3(-12, 3.2, -11), 4.2, 4.2, 0.6, 0.6, 1.4, "tejas")
	cilindro(Vector3(-12, 1.4, -11), 0.55, 1.4, "hierro", false, 0.45, 12)
	# Cedros alrededor y el santuario al fondo, tras la salida.
	_bordes_de_bosque(18, "hojas_cedro")
	sin_sombra = true
	caja(Vector3(32, 0.6, 0), Vector3(10, 1.2, 12), "muro_piedra", false)
	caja(Vector3(32, 2.8, 0), Vector3(8, 3.2, 10), "madera", false)
	tronco_piramide(Vector3(32, 4.4, 0), 12, 14, 3, 5, 3.2, "tejas")
	sin_sombra = false
	_torii(Vector3(24.8, 0, 0), 1.35)
	antorcha(Vector3(20, 0, -5), 1.5)
	antorcha(Vector3(20, 0, 5), 2.5)


# --- El dojo del monte Kurama, en el Kakuriyo (capítulo 2) ---------------------------------------------

func _dojo() -> void:
	_suelo("kakuriyo_suelo", "kakuriyo_suelo")
	_franja(-28, 12, 0, 3.5, "losa")
	# El patio del dojo: tarima de madera.
	caja(Vector3(17, 0.08, 0), Vector3(14, 0.16, 12), "tatami", false)
	for x in [10.5, 23.5]:
		for z in [-6.0, 6.0]:
			caja(Vector3(x, 1.3, z), Vector3(0.3, 2.6, 0.3), "madera_oscura")
	# Cedros gigantes del otro mundo y farolillos que flotan.
	_bordes_de_bosque(16, "kakuriyo_hojas")
	for i in 14:
		var lugar := Vector3(azar.randf_range(-22.0, 22.0), 0, (1 if i % 2 else -1) * azar.randf_range(4.0, 12.0))
		_farolillo(lugar, Color("b08aff") if i % 3 else Color("7affd0"), azar.randf_range(2.2, 3.4), true)
	_luz(Vector3(-8, 3, 0), Color("a080ff"), 1.0, 12.0)
	_luz(Vector3(8, 3, 0), Color("80ffd0"), 1.0, 12.0)
	_torii(Vector3(-16, 0, 0), 1.1, "kakuriyo_hojas")
	_torii(Vector3(2, 0, 0), 1.1, "kakuriyo_hojas")
	for i in 6:
		_roca(Vector3(azar.randf_range(-20.0, 8.0), 0, (1 if i % 2 else -1) * azar.randf_range(6.0, 11.0)), azar.randf_range(0.6, 1.1), "roca_oscura")
	# El edificio del dojo, tras la salida.
	sin_sombra = true
	caja(Vector3(31, 2.2, 0), Vector3(8, 4.4, 12), "madera", false)
	tronco_piramide(Vector3(31, 4.4, 0), 11, 15, 2, 5, 3.0, "tejas")
	sin_sombra = false
	_arco_salida("madera_oscura")
	antorcha(Vector3(11, 0, -7), 0.5, 2.4, 1.4, 8.0)
	antorcha(Vector3(11, 0, 7), 2.0, 2.4, 1.4, 8.0)


# --- Las ruinas del oeste (capítulo 3) ----------------------------------------------------------------

func _pilar(base: Vector3, alto: float, con_glifo := true) -> void:
	cilindro(base, 0.65, alto, "ruina", true, 0.55, 8)
	if con_glifo:
		cilindro(base + Vector3(0, alto * 0.55, 0), 0.67, 0.18, aspecto.material_emisivo(Color("6ad8e0"), 1.6), false, 0.6, 8)


func _ruinas() -> void:
	_suelo("barro", "tierra")
	_franja(-28, 28, 0, 4, "ruina")
	for x in [-18.0, -12.0, 0.0, 6.0, 12.0]:
		for lado in [-1, 1]:
			var alto := azar.randf_range(1.2, 4.5)
			_pilar(Vector3(x, 0, lado * 4.0), alto, alto > 2.0)
	# Pilares caídos y muros rotos.
	for i in 6:
		var caido := caja(Vector3(azar.randf_range(-20.0, 16.0), 0.5, (1 if i % 2 else -1) * azar.randf_range(7.0, 12.0)),
			Vector3(3.5, 1.0, 1.0), "ruina")
		caido.rotation.y = azar.randf() * PI
	for i in 4:
		caja(Vector3(-20 + i * 11, 1.0, (1 if i % 2 else -1) * 14.0), Vector3(5, 2.0, 1.0), "ruina")
	# El torii de piedra entre los dos komainu.
	_torii(Vector3(-4, 0, 0), 1.0, "ruina")
	# El nido de la tsuchigumo: hilos de seda entre las piedras.
	for k in 8:
		var hilo := caja(Vector3(18, 2.0, 0), Vector3(0.05, 0.05, 9.0), "papel", false)
		hilo.rotation = Vector3(0.3 * k, k * 0.4, 0.2)
	for k in 5:
		_roca(Vector3(16 + azar.randf_range(-3.0, 4.0), 0, azar.randf_range(-6.0, 6.0)), 0.35, "papel")
	_bordes_de_bosque(12, "hojas_cedro")
	_luz(Vector3(-12, 2.5, 4), Color("6ad8e0"), 0.9, 9.0)
	_luz(Vector3(6, 2.5, -4), Color("6ad8e0"), 0.9, 9.0)
	antorcha(Vector3(-20, 0, 5), 1.0)
	_arco_salida("ruina")


# --- El sello de Bahamut (capítulo 3) -------------------------------------------------------------------

func _santuario() -> void:
	_suelo("roca_oscura", "roca_oscura")
	# Anillos de piedra con glifos alrededor del sello, cristales de nácar y cadenas por el suelo.
	sin_sombra = true
	for radio in [6.0, 10.0, 14.0]:
		var anillo := CylinderMesh.new()
		anillo.top_radius = radio
		anillo.bottom_radius = radio
		anillo.height = 0.04
		anillo.radial_segments = 48
		_malla(anillo, aspecto.material_emisivo(Color("8aa8ff"), 0.5) if radio == 10.0 else aspecto.material_superficie("ruina"),
			Vector3(14, 0.02 + radio * 0.001, 0))
	sin_sombra = false
	for i in 10:
		var angulo := i * TAU / 10.0
		var punto := Vector3(14, 0, 0) + Vector3(cos(angulo), 0, sin(angulo)) * 16.0
		if punto.x < -24.0 or punto.x > 26.0 or absf(punto.z) > 16.5:
			continue
		var cristal := CylinderMesh.new()
		cristal.top_radius = 0.0
		cristal.bottom_radius = 0.5
		cristal.height = azar.randf_range(2.0, 3.6)
		cristal.radial_segments = 5
		_malla(cristal, aspecto.material_emisivo(Color("cfd6e6"), 1.4), punto + Vector3(0, cristal.height / 2.0, 0))
	for x in [-18.0, -10.0, -2.0]:
		for lado in [-1, 1]:
			_pilar(Vector3(x, 0, lado * 5.0), azar.randf_range(2.5, 4.0))
	for i in 6:
		var cadena := caja(Vector3(azar.randf_range(4.0, 20.0), 0.08, azar.randf_range(-10.0, 10.0)), Vector3(4.0, 0.12, 0.12), "cadena", false)
		cadena.rotation.y = azar.randf() * PI
	_luz(Vector3(14, 4, 0), Color("c8d8ff"), 0.9, 14.0)
	_luz(Vector3(-10, 3, 0), Color("6ad8e0"), 0.8, 10.0)
	_arco_salida("ruina")
