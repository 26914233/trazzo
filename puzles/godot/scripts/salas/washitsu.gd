# La habitación de la caja viva: un washitsu de ocho tatamis, de noche. La caja espera sobre una
# mesa baja (chabudai) en el centro. Al fondo, el tokonoma con un rollo colgante; a la izquierda,
# los shōji con la luna detrás y la sombra de unas cañas de bambú; a la derecha, muro de tierra; y
# delante, las fusuma pintadas en pan de oro: las dos del centro se abren al entrar.
# La caja está en el origen; su base, en y = -0.081.
extends Node3D

const PISO := -0.38                   # altura del tatami
const MESA := -0.0815                 # tablero de la mesa baja
const MITAD := 1.82                   # media habitación (ocho tatamis: 3,64 x 3,64 m)
const ALTO := 2.35
const ALTO_PUERTA := 1.8

var puertas: Array = []               # las dos fusuma del centro [nodo, cuánto se corren]
var andon: OmniLight3D
var papel_andon: StandardMaterial3D
var madera: Material
var madera_clara: Material
var yeso: Material
var _tiempo := 0.0
var _ruido := FastNoiseLite.new()


func construir() -> void:
	madera = Materiales.con_textura("madera_oscura", 2.0, 0.4)
	madera_clara = Materiales.con_textura("madera_clara", 1.6, 0.55, 0.0, Color(0.92, 0.85, 0.74))
	yeso = Materiales.con_textura("yeso", 1.3, 0.92)
	_suelo()
	_mesa_baja()
	_paredes()
	_tokonoma()
	_shoji()
	_fusuma()
	_pasillo()
	_techo()
	_andon()
	_ruido.frequency = 2.2


func _suelo() -> void:
	var tatami := Materiales.con_textura("tatami", 1.1, 0.85, 0.0, Color(1.0, 1.0, 1.0), 0.8)
	var heri := Materiales.liso(Color(0.07, 0.07, 0.09), 0.8)
	# 2 tatamis arriba, 4 en medio (girados) y 2 abajo
	var lista := [[-0.91, -1.365, false], [0.91, -1.365, false], [-1.365, 0.0, true], [-0.455, 0.0, true],
		[0.455, 0.0, true], [1.365, 0.0, true], [-0.91, 1.365, false], [0.91, 1.365, false]]
	for datos in lista:
		var nodo := Escena.grupo(self, Vector3(datos[0], PISO, datos[1]), "Tatami")
		if datos[2]:
			nodo.rotation.y = PI / 2.0
		Arquitectura.losa(Vector3(-0.905, -0.055, -0.45), Vector3(0.905, 0.0, 0.45), tatami, nodo, 0.006)
		for lado in [-1.0, 1.0]:
			Arquitectura.losa(Vector3(-0.905, -0.054, lado * 0.45 - 0.016), Vector3(0.905, 0.002, lado * 0.45 + 0.016), heri, nodo, 0.002)
	# cojín (zabuton) junto a la mesa
	var cojin := Escena.bloque(Vector3(-0.27, 0.0, -0.27), Vector3(0.27, 0.06, 0.27),
		Materiales.liso(Color(0.12, 0.14, 0.3), 0.95), self, 0.025, false)
	cojin.position += Vector3(0.05, PISO, 0.78)
	cojin.rotation.y = 0.12


func _mesa_baja() -> void:
	var tablero := CylinderMesh.new()
	tablero.top_radius = 0.42
	tablero.bottom_radius = 0.41
	tablero.height = 0.028
	tablero.radial_segments = 48
	var laca := Materiales.con_textura("madera_oscura", 4.0, 0.22, 0.0, Color(0.75, 0.6, 0.5))
	Geometria.pieza(tablero, laca, Vector3(0.0, MESA - 0.014, 0.0), self)
	var faldon := CylinderMesh.new()
	faldon.top_radius = 0.36
	faldon.bottom_radius = 0.36
	faldon.height = 0.05
	faldon.radial_segments = 40
	Geometria.pieza(faldon, laca, Vector3(0.0, MESA - 0.05, 0.0), self)
	for k in 4:
		var angulo := PI / 4.0 + k * PI / 2.0
		var pata := Escena.bloque(Vector3(-0.022, PISO, -0.022), Vector3(0.022, MESA - 0.028, 0.022), laca, self, 0.004, false)
		pata.position += Vector3(cos(angulo) * 0.3, 0.0, sin(angulo) * 0.3)


func _paredes() -> void:
	# fondo (norte): el tokonoma a la izquierda, muro a la derecha
	Arquitectura.pared(Vector3(-MITAD, PISO, -MITAD), Vector3.RIGHT, MITAD * 2.0, ALTO, Vector3.BACK, yeso, self,
		[[0.06, MITAD - 0.06, 0.0, ALTO_PUERTA + 0.1]])
	# derecha (este): muro de tierra
	Arquitectura.pared(Vector3(MITAD, PISO, -MITAD), Vector3.BACK, MITAD * 2.0, ALTO, Vector3.LEFT, yeso, self)
	# izquierda (oeste) y delante (sur): el yeso por encima de shōji y fusuma
	Arquitectura.pared(Vector3(-MITAD, PISO + ALTO_PUERTA, MITAD), Vector3.FORWARD, MITAD * 2.0, ALTO - ALTO_PUERTA, Vector3.RIGHT, yeso, self)
	Arquitectura.pared(Vector3(MITAD, PISO + ALTO_PUERTA, MITAD), Vector3.LEFT, MITAD * 2.0, ALTO - ALTO_PUERTA, Vector3.FORWARD, yeso, self)
	# pilares en las esquinas y a media pared, y el nageshi (viga) alrededor a la altura de las puertas
	for esquina in [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1), Vector2(1, 0)]:
		var x: float = esquina.x * (MITAD - 0.05)
		var z: float = esquina.y * (MITAD - 0.05)
		Escena.bloque(Vector3(x - 0.05, PISO, z - 0.05), Vector3(x + 0.05, PISO + ALTO, z + 0.05), madera_clara, self, 0.006, false)
	var bordes := [[Vector3(-MITAD, 0, -MITAD + 0.0), Vector3(MITAD, 0, -MITAD + 0.07)], [Vector3(MITAD - 0.07, 0, -MITAD), Vector3(MITAD, 0, MITAD)],
		[Vector3(-MITAD, 0, MITAD - 0.07), Vector3(MITAD, 0, MITAD)], [Vector3(-MITAD, 0, -MITAD), Vector3(-MITAD + 0.07, 0, MITAD)]]
	for k in bordes.size():
		var desde: Vector3 = bordes[k][0]
		var hasta: Vector3 = bordes[k][1]
		Arquitectura.losa(Vector3(desde.x, PISO + ALTO_PUERTA, desde.z), Vector3(hasta.x, PISO + ALTO_PUERTA + 0.1, hasta.z), madera_clara, self, 0.006)
		if k < 2:
			# zócalo (solo en las paredes de muro)
			Arquitectura.losa(Vector3(desde.x, PISO, desde.z), Vector3(hasta.x, PISO + 0.05, hasta.z), madera, self, 0.004)


func _tokonoma() -> void:
	var fondo := -MITAD - 0.62
	var x0 := -MITAD + 0.06
	var x1 := -0.06
	var suelo_toko := PISO + 0.1
	# tarima de madera pulida, paredes y techo del hueco
	Arquitectura.losa(Vector3(x0, PISO, fondo), Vector3(x1, suelo_toko, -MITAD + 0.02),
		Materiales.con_textura("madera_oscura", 2.0, 0.18, 0.0, Color(0.85, 0.7, 0.6)), self, 0.006)
	Arquitectura.pared(Vector3(x0, PISO, fondo), Vector3.RIGHT, x1 - x0, ALTO_PUERTA + 0.1, Vector3.BACK, yeso, self)
	Arquitectura.pared(Vector3(x0, PISO, -MITAD), Vector3.FORWARD, 0.62, ALTO_PUERTA + 0.1, Vector3.RIGHT, yeso, self)
	Arquitectura.pared(Vector3(x1, PISO, fondo), Vector3.BACK, 0.62, ALTO_PUERTA + 0.1, Vector3.LEFT, yeso, self)
	Arquitectura.losa(Vector3(x0, PISO + ALTO_PUERTA + 0.1, fondo), Vector3(x1, PISO + ALTO_PUERTA + 0.13, -MITAD), madera_clara, self)
	# pilar de madera natural (tokobashira)
	var pilar := CylinderMesh.new()
	pilar.top_radius = 0.05
	pilar.bottom_radius = 0.058
	pilar.height = ALTO
	Geometria.pieza(pilar, Materiales.con_textura("madera_clara", 3.0, 0.6, 0.0, Color(0.7, 0.55, 0.42), 1.4), Vector3(x1 + 0.02, PISO + ALTO / 2.0, -MITAD + 0.02), self)
	# rollo colgante (kakejiku)
	var rollo := QuadMesh.new()
	rollo.size = Vector2(0.44, 1.32)
	var material := StandardMaterial3D.new()
	material.albedo_texture = Materiales.textura("kakejiku")
	material.roughness = 0.85
	Geometria.pieza(rollo, material, Vector3((x0 + x1) / 2.0, suelo_toko + 1.02, fondo + 0.012), self)
	# el rollo es una pista de la caja: se puede mirar de cerca con un doble toque
	var cuerpo := StaticBody3D.new()
	var forma := CollisionShape3D.new()
	forma.shape = BoxShape3D.new()
	(forma.shape as BoxShape3D).size = Vector3(0.46, 1.34, 0.02)
	cuerpo.add_child(forma)
	cuerpo.position = Vector3((x0 + x1) / 2.0, suelo_toko + 1.02, fondo + 0.02)
	add_child(cuerpo)
	var varilla := CylinderMesh.new()
	varilla.top_radius = 0.012
	varilla.bottom_radius = 0.012
	varilla.height = 0.52
	var palo := Geometria.pieza(varilla, madera, Vector3((x0 + x1) / 2.0, suelo_toko + 0.35, fondo + 0.03), self)
	palo.rotation.z = PI / 2.0
	# jarrón con una rama de pino
	var jarron := Geometria.torno(PackedVector2Array([Vector2(0.0, 0.0), Vector2(0.07, 0.0), Vector2(0.1, 0.08),
		Vector2(0.085, 0.2), Vector2(0.04, 0.27), Vector2(0.045, 0.31), Vector2(0.0, 0.31)]), 28)
	var ceramica := Materiales.liso(Color(0.2, 0.26, 0.3), 0.25)
	var base_jarron := Vector3(x0 + 0.42, suelo_toko, fondo + 0.3)
	Geometria.pieza(jarron, ceramica, base_jarron, self)
	var azar := RandomNumberGenerator.new()
	azar.seed = 3108
	var punta := base_jarron + Vector3(0.0, 0.3, 0.0)
	for k in 5:
		var siguiente := punta + Vector3(azar.randf_range(0.04, 0.12), azar.randf_range(0.05, 0.13), azar.randf_range(-0.04, 0.05))
		var tramo := CylinderMesh.new()
		tramo.top_radius = 0.008
		tramo.bottom_radius = 0.012
		tramo.height = punta.distance_to(siguiente)
		var rama := Geometria.pieza(tramo, Materiales.liso(Color(0.25, 0.17, 0.1), 0.85), (punta + siguiente) / 2.0, self)
		rama.look_at_from_position((punta + siguiente) / 2.0, siguiente, Vector3.FORWARD)
		rama.rotate_object_local(Vector3.RIGHT, PI / 2.0)
		if k % 2 == 1 or k == 4:
			var mata := SphereMesh.new()
			mata.radius = 0.05
			mata.height = 0.06
			Geometria.pieza(mata, Materiales.liso(Color(0.12, 0.24, 0.14), 0.9), siguiente, self)
		punta = siguiente


func _shoji() -> void:
	# papel con la luna detrás (brilla un poco) y su enrejado de madera clara
	var papel := StandardMaterial3D.new()
	papel.albedo_texture = Materiales.textura("shoji")
	papel.emission_enabled = true
	papel.emission_texture = Materiales.textura("shoji")
	papel.emission = Color(0.55, 0.62, 0.85)
	papel.emission_energy_multiplier = 0.55
	papel.roughness = 0.9
	var hoja := QuadMesh.new()
	hoja.size = Vector2(MITAD * 2.0, ALTO_PUERTA)
	var plano := Geometria.pieza(hoja, papel, Vector3(-MITAD - 0.01, PISO + ALTO_PUERTA / 2.0, 0.0), self)
	plano.rotation.y = PI / 2.0
	var x := -MITAD + 0.005
	for k in 4:
		var z0 := -MITAD + k * 0.91
		var z1 := z0 + 0.91
		for barra in [[z0, z0 + 0.035, 0.0, ALTO_PUERTA], [z1 - 0.035, z1, 0.0, ALTO_PUERTA], [z0, z1, 0.0, 0.08], [z0, z1, ALTO_PUERTA - 0.05, ALTO_PUERTA]]:
			Arquitectura.losa(Vector3(x, PISO + barra[2], barra[0]), Vector3(x + 0.035, PISO + barra[3], barra[1]), madera_clara, self)
		for i in range(1, 3):
			var z := z0 + i * 0.91 / 3.0
			Arquitectura.losa(Vector3(x + 0.008, PISO + 0.08, z - 0.008), Vector3(x + 0.026, PISO + ALTO_PUERTA - 0.05, z + 0.008), madera_clara, self)
		for j in range(1, 6):
			var y := PISO + 0.08 + j * (ALTO_PUERTA - 0.13) / 6.0
			Arquitectura.losa(Vector3(x + 0.008, y - 0.008, z0 + 0.035), Vector3(x + 0.026, y + 0.008, z1 - 0.035), madera_clara, self)
	# la luz de la luna entra por los shōji
	var luna := DirectionalLight3D.new()
	luna.light_color = Color(0.55, 0.65, 1.0)
	luna.light_energy = 0.32
	luna.light_specular = 0.4
	add_child(luna)
	luna.look_at_from_position(Vector3(-3.0, 1.6, 0.6), Vector3(0.0, -0.1, 0.0), Vector3.UP)


func _fusuma() -> void:
	var pintura := Materiales.textura("fusuma")
	var negro := Materiales.liso(Color(0.04, 0.035, 0.035), 0.25)
	for k in 4:
		var x0 := -MITAD + k * 0.91
		var panel := Escena.grupo(self, Vector3(x0, PISO, MITAD - 0.03 - (0.03 if k == 1 or k == 2 else 0.0)), "Fusuma")
		var material := StandardMaterial3D.new()
		material.albedo_texture = pintura
		material.roughness = 0.55
		material.metallic_specular = 0.7
		material.uv1_scale = Vector3(0.5, 1.0, 1.0)
		material.uv1_offset = Vector3(0.5 if k % 2 == 1 else 0.0, 0.0, 0.0)
		var cara := QuadMesh.new()
		cara.size = Vector2(0.91, ALTO_PUERTA)
		var malla := Geometria.pieza(cara, material, Vector3(0.455, ALTO_PUERTA / 2.0, -0.012), panel)
		malla.rotation.y = PI
		Escena.bloque(Vector3(0.0, 0.0, -0.01), Vector3(0.91, ALTO_PUERTA, 0.01), Materiales.liso(Color(0.3, 0.26, 0.2), 0.8), panel, 0.002, false)
		for barra in [[Vector3(0.0, 0.0, -0.016), Vector3(0.025, ALTO_PUERTA, 0.016)], [Vector3(0.885, 0.0, -0.016), Vector3(0.91, ALTO_PUERTA, 0.016)],
				[Vector3(0.0, 0.0, -0.016), Vector3(0.91, 0.025, 0.016)], [Vector3(0.0, ALTO_PUERTA - 0.025, -0.016), Vector3(0.91, ALTO_PUERTA, 0.016)]]:
			Escena.bloque(barra[0], barra[1], negro, panel, 0.003, false)
		var tirador := CylinderMesh.new()
		tirador.top_radius = 0.028
		tirador.bottom_radius = 0.028
		tirador.height = 0.006
		var hikite := Geometria.pieza(tirador, Materiales.laton(0.4), Vector3(0.08 if k % 2 == 1 else 0.83, 0.85, -0.016), panel)
		hikite.rotation.x = PI / 2.0
		if k == 1:
			puertas.append([panel, -0.86])
		elif k == 2:
			puertas.append([panel, 0.86])


func _pasillo() -> void:
	# pasillo de madera tras las fusuma (de ahí viene la cámara)
	var suelo := Materiales.con_textura("madera_clara", 1.2, 0.35, 0.0, Color(0.7, 0.6, 0.5))
	Arquitectura.losa(Vector3(-1.3, PISO - 0.06, MITAD - 0.02), Vector3(1.3, PISO - 0.01, 3.6), suelo, self)
	Arquitectura.losa(Vector3(-1.3, PISO + 2.2, MITAD), Vector3(1.3, PISO + 2.25, 3.6), madera, self)
	var oscuro := Materiales.con_textura("yeso", 1.3, 0.95, 0.0, Color(0.5, 0.45, 0.4))
	Arquitectura.pared(Vector3(-1.3, PISO - 0.01, 3.6), Vector3.FORWARD, 3.6 - MITAD, 2.21, Vector3.RIGHT, oscuro, self)
	Arquitectura.pared(Vector3(1.3, PISO - 0.01, MITAD), Vector3.BACK, 3.6 - MITAD, 2.21, Vector3.LEFT, oscuro, self)
	Arquitectura.pared(Vector3(1.3, PISO - 0.01, 3.6), Vector3.LEFT, 2.6, 2.21, Vector3.FORWARD, oscuro, self)
	Escena.luz(self, Vector3(-0.9, PISO + 1.6, 3.3), Color(1.0, 0.7, 0.42), 0.35, 2.2)


func _techo() -> void:
	var tablas := Materiales.con_textura("madera_clara", 1.0, 0.7, 0.0, Color(0.72, 0.64, 0.55))
	Arquitectura.losa(Vector3(-MITAD, PISO + ALTO, -MITAD - 0.62), Vector3(MITAD, PISO + ALTO + 0.04, MITAD), tablas, self)
	var x := -MITAD + 0.45
	while x < MITAD:
		Arquitectura.losa(Vector3(x - 0.015, PISO + ALTO - 0.03, -MITAD), Vector3(x + 0.015, PISO + ALTO, MITAD), madera_clara, self)
		x += 0.45


func _andon() -> void:
	var nodo := Escena.grupo(self, Vector3(-0.8, PISO, 0.38), "Andon")
	nodo.rotation.y = 0.35
	Escena.bloque(Vector3(-0.15, 0.0, -0.15), Vector3(0.15, 0.03, 0.15), madera, nodo, 0.004, false)
	for x in [-0.12, 0.12]:
		for z in [-0.12, 0.12]:
			Escena.bloque(Vector3(x - 0.012, 0.03, z - 0.012), Vector3(x + 0.012, 0.66, z + 0.012), madera, nodo, 0.003, false)
	Escena.bloque(Vector3(-0.135, 0.64, -0.135), Vector3(0.135, 0.66, 0.135), madera, nodo, 0.003, false)
	papel_andon = StandardMaterial3D.new()
	papel_andon.albedo_color = Color(1.0, 0.92, 0.78)
	papel_andon.albedo_texture = Materiales.textura("papel")
	papel_andon.emission_enabled = true
	papel_andon.emission = Color(1.0, 0.68, 0.36)
	papel_andon.emission_energy_multiplier = 1.6
	papel_andon.cull_mode = BaseMaterial3D.CULL_DISABLED
	for lado in 4:
		var hoja := QuadMesh.new()
		hoja.size = Vector2(0.22, 0.5)
		var cara := Geometria.pieza(hoja, papel_andon, Vector3.ZERO, nodo)
		var angulo := lado * PI / 2.0
		cara.position = Vector3(sin(angulo) * 0.115, 0.38, cos(angulo) * 0.115)
		cara.rotation.y = angulo
		cara.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	andon = Escena.luz(nodo, Vector3(0.0, 0.42, 0.0), Color(1.0, 0.7, 0.42), 1.7, 3.4, true)
	andon.shadow_bias = 0.03
	Escena.polvo(self, Vector3(0.9, 0.5, 0.9), Color(1.0, 0.85, 0.6, 0.45), 60, 0.003).position = Vector3(-0.3, 0.15, 0.2)


# La llama del andon tiembla un poco
func actualizar(delta: float) -> void:
	_tiempo += delta
	var temblor := _ruido.get_noise_1d(_tiempo * 3.0)
	andon.light_energy = 1.7 + temblor * 0.18
	papel_andon.emission_energy_multiplier = 1.6 + temblor * 0.2


# Las dos fusuma del centro se corren a los lados (al empezar la entrada)
func abrir_puertas(sonido) -> void:
	if sonido:
		sonido.sonar("corredera", -4.0)
	for datos in puertas:
		var panel: Node3D = datos[0]
		var animacion := create_tween()
		animacion.tween_interval(0.25)
		animacion.tween_property(panel, "position:x", panel.position.x + float(datos[1]), 1.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
