# La habitación de la caja del relojero: el taller de Edmund Whitcombe en Londres, 1891. El
# escritorio está en el centro (lo monta el puzle, con la carta y la lámpara); alrededor, friso de
# madera y papel pintado, una pared de relojes, el reloj de pie con su péndulo, la chimenea
# encendida, una ventana a la niebla y la puerta por la que se entra.
# La caja está en el origen; su base (y el tablero del escritorio), en y = 0.
extends Node3D

const SUELO := -0.76
const X0 := -2.6
const X1 := 2.6
const Z0 := -2.3
const Z1 := 2.9
const ALTO := 3.1
const FRISO := 1.0
const PUERTA_X := 0.15                # bisagra de la puerta (en la pared de delante)
const PUERTA_ANCHO := 0.95

var puerta: Node3D
var fuego: OmniLight3D
var llamas: Array = []
var pendulo: Node3D
var madera: Material
var papel: Material
var _tiempo := 0.0
var _ruido := FastNoiseLite.new()


func construir() -> void:
	madera = Materiales.con_textura("madera_oscura", 1.6, 0.42)
	papel = Materiales.con_textura("papel_pintado", 1.1, 0.85, 0.0, Color(0.85, 0.9, 0.85), 0.6)
	_ruido.frequency = 3.0
	_suelo_y_techo()
	_paredes()
	_estanteria_de_relojes()
	_reloj_de_pie()
	_chimenea()
	_pasillo()
	_lampara_de_techo()


func _suelo_y_techo() -> void:
	Arquitectura.losa(Vector3(X0, SUELO - 0.05, Z0), Vector3(X1, SUELO, Z1),
		Materiales.con_textura("tablones", 0.75, 0.6, 0.0, Color(0.75, 0.62, 0.55)), self)
	var alfombra := StandardMaterial3D.new()
	alfombra.albedo_texture = Materiales.textura("alfombra")
	alfombra.roughness = 0.95
	alfombra.uv1_scale = Vector3(1.0 / 3.2, 1.0 / 2.0, 1.0)
	alfombra.uv1_offset = Vector3(0.5, 0.5, 0.0)
	Arquitectura.losa(Vector3(-1.6, SUELO, -1.0), Vector3(1.6, SUELO + 0.012, 1.0), alfombra, self)
	var techo := Materiales.con_textura("yeso", 1.2, 0.95, 0.0, Color(0.55, 0.5, 0.45))
	Arquitectura.losa(Vector3(X0, SUELO + ALTO, Z0), Vector3(X1, SUELO + ALTO + 0.05, Z1), techo, self)
	for z in [-1.2, 0.3, 1.8]:
		Arquitectura.losa(Vector3(X0, SUELO + ALTO - 0.16, z - 0.08), Vector3(X1, SUELO + ALTO, z + 0.08), madera, self, 0.01)


func _paredes() -> void:
	var tormenta := ShaderMaterial.new()
	tormenta.shader = preload("res://shaders/niebla_londres.gdshader")
	# [inicio, dirección, largo, hacia dentro, huecos de la parte de abajo, huecos de la de arriba]
	var paredes := [
		[Vector3(X0, SUELO, Z0), Vector3.RIGHT, X1 - X0, Vector3.BACK, [], []],
		[Vector3(X0, SUELO, Z1), Vector3.FORWARD, Z1 - Z0, Vector3.RIGHT, [], [[2.1, 3.5, 0.15, 1.6]]],
		[Vector3(X1, SUELO, Z0), Vector3.BACK, Z1 - Z0, Vector3.LEFT, [], []],
		[Vector3(X1, SUELO, Z1), Vector3.LEFT, X1 - X0, Vector3.FORWARD,
			[[X1 - PUERTA_X - PUERTA_ANCHO, X1 - PUERTA_X, 0.0, FRISO]], [[X1 - PUERTA_X - PUERTA_ANCHO, X1 - PUERTA_X, 0.0, 1.2]]],
	]
	for datos in paredes:
		var inicio: Vector3 = datos[0]
		Arquitectura.pared(inicio, datos[1], datos[2], FRISO, datos[3], madera, self, datos[4])
		Arquitectura.pared(inicio + Vector3.UP * FRISO, datos[1], datos[2], ALTO - FRISO, datos[3], papel, self, datos[5])
	# molduras: el friso, el zócalo y la cornisa (menos en el hueco de la puerta)
	for datos in [[Vector3(X0, 0, Z0), Vector3(X1, 0, Z0 + 0.05)], [Vector3(X0, 0, Z0), Vector3(X0 + 0.05, 0, Z1)],
			[Vector3(X1 - 0.05, 0, Z0), Vector3(X1, 0, Z1)], [Vector3(X0, 0, Z1 - 0.05), Vector3(PUERTA_X - 0.05, 0, Z1)],
			[Vector3(PUERTA_X + PUERTA_ANCHO + 0.05, 0, Z1 - 0.05), Vector3(X1, 0, Z1)]]:
		var desde: Vector3 = datos[0]
		var hasta: Vector3 = datos[1]
		Arquitectura.losa(Vector3(desde.x, SUELO + FRISO - 0.02, desde.z), Vector3(hasta.x, SUELO + FRISO + 0.03, hasta.z), madera, self, 0.008)
		Arquitectura.losa(Vector3(desde.x, SUELO, desde.z), Vector3(hasta.x, SUELO + 0.14, hasta.z), madera, self, 0.004)
	for datos in [[Vector3(X0, 0, Z0), Vector3(X1, 0, Z0 + 0.09)], [Vector3(X0, 0, Z0), Vector3(X0 + 0.09, 0, Z1)],
			[Vector3(X1 - 0.09, 0, Z0), Vector3(X1, 0, Z1)], [Vector3(X0, 0, Z1 - 0.09), Vector3(X1, 0, Z1)]]:
		var desde: Vector3 = datos[0]
		var hasta: Vector3 = datos[1]
		Arquitectura.losa(Vector3(desde.x, SUELO + ALTO - 0.14, desde.z), Vector3(hasta.x, SUELO + ALTO, hasta.z), madera, self, 0.01)
	# ventana a la izquierda, con la niebla de Londres
	Arquitectura.ventana(self, Vector3(X0 + 0.02, SUELO + FRISO + 0.875, Z1 - 2.8), Vector2(1.3, 1.35), madera, tormenta, PI / 2.0)
	var calle := OmniLight3D.new()
	calle.light_color = Color(0.6, 0.66, 0.85)
	calle.light_energy = 0.5
	calle.omni_range = 3.2
	calle.position = Vector3(X0 + 0.5, SUELO + 1.9, Z1 - 2.8)
	add_child(calle)
	# marco de la puerta y la puerta, que se abre hacia dentro al entrar
	var marco := Materiales.con_textura("madera_oscura", 3.0, 0.4)
	for x in [PUERTA_X - 0.07, PUERTA_X + PUERTA_ANCHO]:
		Arquitectura.losa(Vector3(x, SUELO, Z1 - 0.06), Vector3(x + 0.07, SUELO + 2.28, Z1 + 0.02), marco, self, 0.006)
	Arquitectura.losa(Vector3(PUERTA_X - 0.07, SUELO + 2.2, Z1 - 0.06), Vector3(PUERTA_X + PUERTA_ANCHO + 0.07, SUELO + 2.3, Z1 + 0.02), marco, self, 0.006)
	puerta = Arquitectura.puerta(self, Vector3(PUERTA_X, SUELO, Z1 - 0.03), PUERTA_ANCHO, 2.2, marco, Materiales.laton(0.3))
	puerta.rotation.y = PI
	puerta.position.x = PUERTA_X + PUERTA_ANCHO


func _estanteria_de_relojes() -> void:
	# la pared del fondo: estantería ancha con libros y, encima y alrededor, relojes que marcan horas distintas
	var nodo := Escena.grupo(self, Vector3(-0.2, SUELO, Z0 + 0.22), "Estanteria")
	var fondo := Escena.bloque(Vector3(-1.1, 0.0, -0.2), Vector3(1.1, 2.0, -0.17), madera, nodo, 0.004, false)
	fondo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for x in [-1.1, 1.1]:
		Escena.bloque(Vector3(x - 0.03, 0.0, -0.2), Vector3(x + 0.03, 2.05, 0.2), madera, nodo, 0.006, false)
	Escena.bloque(Vector3(-1.14, 2.0, -0.2), Vector3(1.14, 2.1, 0.22), madera, nodo, 0.008, false)
	for k in 4:
		var y := 0.12 + k * 0.48
		Escena.bloque(Vector3(-1.08, y - 0.025, -0.17), Vector3(1.08, y, 0.18), madera, nodo, 0.004, false)
		if k < 3:
			Arquitectura.libros(nodo, -1.05, 1.05, y, 0.0, 0.24, 1891 + k * 7, 0.18, 0.32)
	# relojes en la repisa de arriba y en la pared
	var horas := [[3.0, 0.0], [9.0, 45.0], [12.0, 10.0], [6.0, 30.0], [1.0, 50.0], [7.0, 5.0], [11.0, 20.0]]
	var lugares := [Vector3(-0.85, 2.28, 0.0), Vector3(-0.25, 2.32, 0.0), Vector3(0.45, 2.3, 0.0), Vector3(1.0, 2.27, 0.0),
		Vector3(-1.55, 1.6, -0.18), Vector3(1.55, 1.75, -0.18), Vector3(1.6, 1.15, -0.18)]
	var radios := [0.13, 0.16, 0.12, 0.1, 0.14, 0.12, 0.09]
	for k in lugares.size():
		Arquitectura.reloj(nodo, lugares[k], radios[k], horas[k][0], horas[k][1])
	# en el estante de en medio, relojes de bolsillo abiertos y una lupa de relojero
	for k in 3:
		var bolsillo := CylinderMesh.new()
		bolsillo.top_radius = 0.026
		bolsillo.bottom_radius = 0.026
		bolsillo.height = 0.008
		var reloj := Geometria.pieza(bolsillo, Materiales.laton(0.3), Vector3(-0.6 + k * 0.12, 0.66, 0.08), nodo)
		reloj.rotation.x = -1.2


func _reloj_de_pie() -> void:
	var nodo := Escena.grupo(self, Vector3(X0 + 0.45, SUELO, Z0 + 0.35), "RelojDePie")
	nodo.rotation.y = 0.6
	var caja := Materiales.con_textura("caoba", 2.5, 0.32, 0.0, Color(0.75, 0.6, 0.55))
	Escena.bloque(Vector3(-0.24, 0.0, -0.16), Vector3(0.24, 0.42, 0.16), caja, nodo, 0.01, false)
	Escena.bloque(Vector3(-0.18, 0.42, -0.12), Vector3(0.18, 1.55, 0.12), caja, nodo, 0.008, false)
	Escena.bloque(Vector3(-0.25, 1.55, -0.17), Vector3(0.25, 2.12, 0.17), caja, nodo, 0.01, false)
	Escena.bloque(Vector3(-0.28, 2.12, -0.19), Vector3(0.28, 2.22, 0.19), caja, nodo, 0.01, false)
	# ventana del péndulo
	var cristal := QuadMesh.new()
	cristal.size = Vector2(0.24, 0.9)
	Geometria.pieza(cristal, Materiales.vidrio(Color(0.6, 0.6, 0.55, 0.18)), Vector3(0.0, 1.0, 0.125), nodo)
	Escena.bloque(Vector3(-0.13, 0.55, 0.0), Vector3(0.13, 1.45, 0.11), Materiales.liso(Color(0.05, 0.04, 0.03), 0.8), nodo, 0.0, false)
	pendulo = Escena.grupo(nodo, Vector3(0.0, 1.45, 0.112), "Pendulo")
	Escena.bloque(Vector3(-0.006, -0.72, -0.003), Vector3(0.006, 0.0, 0.003), Materiales.laton(0.3), pendulo, 0.0, false)
	var disco := CylinderMesh.new()
	disco.top_radius = 0.055
	disco.bottom_radius = 0.055
	disco.height = 0.012
	var lenteja := Geometria.pieza(disco, Materiales.laton(0.25), Vector3(0.0, -0.72, 0.004), pendulo)
	lenteja.rotation.x = PI / 2.0
	Arquitectura.reloj(nodo, Vector3(0.0, 1.85, 0.12), 0.15, 9.0, 45.0)


func _chimenea() -> void:
	var nodo := Escena.grupo(self, Vector3(X1 - 0.04, SUELO, -0.2), "Chimenea")
	nodo.rotation.y = -PI / 2.0
	var marmol := Materiales.liso(Color(0.36, 0.33, 0.31), 0.35)
	Escena.bloque(Vector3(-0.85, 0.0, 0.0), Vector3(-0.55, 1.15, 0.32), marmol, nodo, 0.01, false)
	Escena.bloque(Vector3(0.55, 0.0, 0.0), Vector3(0.85, 1.15, 0.32), marmol, nodo, 0.01, false)
	Escena.bloque(Vector3(-0.55, 0.85, 0.0), Vector3(0.55, 1.15, 0.32), marmol, nodo, 0.01, false)
	Escena.bloque(Vector3(-0.95, 1.15, -0.02), Vector3(0.95, 1.22, 0.4), marmol, nodo, 0.012, false)
	Escena.bloque(Vector3(-0.55, 0.0, -0.05), Vector3(0.55, 0.85, 0.0), Materiales.liso(Color(0.03, 0.025, 0.02), 0.9), nodo, 0.0, false)
	Escena.bloque(Vector3(-0.8, 0.0, 0.32), Vector3(0.8, 0.04, 0.62), marmol, nodo, 0.01, false)
	# brasas y llamas
	for k in 3:
		var tronco := CylinderMesh.new()
		tronco.top_radius = 0.045
		tronco.bottom_radius = 0.05
		tronco.height = 0.6
		var leno := Geometria.pieza(tronco, Materiales.liso(Color(0.12, 0.07, 0.04), 0.9), Vector3(0.0, 0.08 + k * 0.05, 0.12 + k * 0.02), nodo)
		leno.rotation = Vector3(0.0, 0.3 - k * 0.3, PI / 2.0)
	for k in 5:
		var llama := MeshInstance3D.new()
		var gota := SphereMesh.new()
		gota.radius = 0.07
		gota.height = 0.3
		llama.mesh = gota
		llama.material_override = Materiales.emisivo(Color(1.0, 0.5 + k * 0.05, 0.18), 4.0, Color(1.0, 0.45, 0.15))
		llama.position = Vector3(-0.28 + k * 0.14, 0.24, 0.14)
		llama.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		nodo.add_child(llama)
		llamas.append(llama)
	fuego = Escena.luz(nodo, Vector3(0.0, 0.5, 0.75), Color(1.0, 0.55, 0.25), 1.6, 4.5)
	# reloj de repisa
	Arquitectura.reloj(nodo, Vector3(0.0, 1.38, 0.2), 0.12, 3.0, 0.0)
	Arquitectura.reloj(nodo, Vector3(0.0, 2.05, -0.0), 0.3, 12.0, 0.0)


func _pasillo() -> void:
	# el pasillo de detrás de la puerta (de ahí viene la cámara)
	var x0 := PUERTA_X - 0.8
	var x1 := PUERTA_X + PUERTA_ANCHO + 0.8
	var fondo := Z1 + 1.9
	Arquitectura.losa(Vector3(x0, SUELO - 0.05, Z1), Vector3(x1, SUELO, fondo), Materiales.con_textura("tablones", 0.75, 0.6, 0.0, Color(0.5, 0.42, 0.38)), self)
	Arquitectura.losa(Vector3(x0, SUELO + 2.6, Z1), Vector3(x1, SUELO + 2.65, fondo), madera, self)
	var oscuro := Materiales.con_textura("papel_pintado", 1.1, 0.85, 0.0, Color(0.45, 0.45, 0.42), 0.6)
	Arquitectura.pared(Vector3(x0, SUELO, fondo), Vector3.FORWARD, fondo - Z1, 2.6, Vector3.RIGHT, oscuro, self)
	Arquitectura.pared(Vector3(x1, SUELO, Z1), Vector3.BACK, fondo - Z1, 2.6, Vector3.LEFT, oscuro, self)
	Arquitectura.pared(Vector3(x1, SUELO, fondo), Vector3.LEFT, x1 - x0, 2.6, Vector3.FORWARD, oscuro, self)
	Escena.luz(self, Vector3(x1 - 0.2, SUELO + 1.9, fondo - 0.6), Color(1.0, 0.72, 0.42), 0.45, 2.6)


func _lampara_de_techo() -> void:
	var nodo := Escena.grupo(self, Vector3(0.0, SUELO + ALTO, 0.0), "LamparaTecho")
	var cadena := CylinderMesh.new()
	cadena.top_radius = 0.008
	cadena.bottom_radius = 0.008
	cadena.height = 1.1
	Geometria.pieza(cadena, Materiales.laton(0.4), Vector3(0.0, -0.55, 0.0), nodo)
	var pantalla := Geometria.torno(PackedVector2Array([Vector2(0.24, -1.32), Vector2(0.2, -1.22), Vector2(0.08, -1.12), Vector2(0.03, -1.1)]), 32)
	var vidrio := Materiales.emisivo(Color(1.0, 0.82, 0.55), 0.8, Color(0.4, 0.32, 0.2))
	vidrio.cull_mode = BaseMaterial3D.CULL_DISABLED
	Geometria.pieza(pantalla, vidrio, Vector3.ZERO, nodo)
	Escena.luz(nodo, Vector3(0.0, -1.3, 0.0), Color(1.0, 0.8, 0.55), 0.7, 3.2)


func actualizar(delta: float) -> void:
	_tiempo += delta
	var temblor := _ruido.get_noise_1d(_tiempo)
	fuego.light_energy = 1.6 + temblor * 0.35
	for k in llamas.size():
		var llama: MeshInstance3D = llamas[k]
		llama.scale = Vector3(1.0, 0.8 + 0.35 * (0.5 + 0.5 * sin(_tiempo * (7.0 + k) + k)), 1.0)
	pendulo.rotation.z = sin(_tiempo * PI) * 0.14


func abrir_puerta(sonido) -> void:
	if sonido:
		sonido.sonar("puerta", -4.0)
	var animacion := create_tween()
	animacion.tween_interval(0.2)
	animacion.tween_property(puerta, "rotation:y", PI - 1.75, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
