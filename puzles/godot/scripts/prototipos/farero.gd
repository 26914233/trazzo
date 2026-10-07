# El cuarto del farero: una habitación de escape. Noviembre de 1903, tormenta, el farero no está y el
# barco del correo llega esta noche. Se recorre con puntos de vista (escritorio, estantería, ventana,
# escalera) y hay que encender la lámpara de la linterna.
#
# Pasos: leer el diario → leer la placa (1887) → abrir el candado → abrir el cajón → coger las
# cerillas → tirar del libro entre Fresnel y Stevenson → coger la llave → abrir la trampilla → encender.
extends Puzle

const RADIO := 2.0
const ALTO := 2.6
const COMBINACION := [1, 8, 8, 7]

var camara_rig: CamaraPuzle
var vistas := {}
var ventana: ShaderMaterial
var luz_ventana: OmniLight3D
var quinque: OmniLight3D
var llama: MeshInstance3D
var ruedas: Array = []
var numeros: Array = []
var candado: Node3D
var arco: Node3D
var cajon: PiezaDeslizante
var cerillas: PiezaRecogible
var libro: PiezaDeslizante
var escondite: Node3D
var llave: PiezaRecogible
var trampilla: Node3D
var cerradura: PiezaRanura
var subir: PiezaPuntoDeVista
var mecha: PiezaRanura
var lampara: OmniLight3D
var llama_grande: MeshInstance3D
var haz: Node3D
var puerta: Node3D
var candado_abierto := false
var encendido := false
var _proximo_rayo := 6.0
var _destello := 0.0
var rachas := 0                       # veces que la tormenta respondió a un bloqueo (lo mira la prueba)
var _racha := 0.0
var _lado_racha := 1.0
var _tiempo := 0.0
var _ruido := FastNoiseLite.new()

var madera: Material
var madera_clara: Material
var laton: Material
var hierro: Material


func construir() -> void:
	madera = Materiales.con_textura("madera_oscura", 2.5, 0.55)
	madera_clara = Materiales.con_textura("madera_clara", 3.0, 0.5, 0.0, Color(0.75, 0.65, 0.55))
	laton = Materiales.laton(0.32)
	hierro = Materiales.liso(Color(0.12, 0.12, 0.13), 0.55, 0.7)
	_habitacion()
	_ventana()
	_escritorio()
	_estanteria()
	_escalera()
	_linterna()
	_vistas()
	_pasos()


func _girar_hacia_centro(nodo: Node3D) -> void:
	var hacia := -Vector3(nodo.position.x, 0.0, nodo.position.z)
	nodo.rotation.y = atan2(hacia.x, hacia.z)


# --- Habitación redonda de piedra ------------------------------------------------------------------

func _habitacion() -> void:
	# muro redondo de piedra con el hueco de la puerta (mira a +Z, detrás de la vista de la sala)
	var piedra := Materiales.con_textura("piedra", 1.0, 0.85, 0.0, Color(0.85, 0.85, 0.85), 1.2)
	piedra = piedra.duplicate()
	piedra.uv1_scale = Vector3(0.64, 0.58, 1.0)
	Arquitectura.pared_curva(Vector3.ZERO, RADIO, ALTO, piedra, self, [PI / 2.0, 1.0, 2.05], 40, 0.35)
	_rellano(piedra)
	var suelo := Escena.bloque(Vector3(-RADIO, -0.05, -RADIO), Vector3(RADIO, 0.0, RADIO), Materiales.con_textura("tablones", 0.6, 0.7), self, 0.0, false)
	suelo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# techo de tablas con vigas y el hueco de la trampilla
	var techo := Materiales.con_textura("madera_oscura", 1.5, 0.7, 0.0, Color(0.55, 0.5, 0.45))
	Escena.bloque(Vector3(-RADIO, ALTO, -RADIO), Vector3(0.45, ALTO + 0.06, RADIO), techo, self, 0.0, false)
	Escena.bloque(Vector3(0.45, ALTO, -RADIO), Vector3(RADIO, ALTO + 0.06, 0.45), techo, self, 0.0, false)
	Escena.bloque(Vector3(0.95, ALTO, 0.45), Vector3(RADIO, ALTO + 0.06, RADIO), techo, self, 0.0, false)
	Escena.bloque(Vector3(0.45, ALTO, 0.95), Vector3(0.95, ALTO + 0.06, RADIO), techo, self, 0.0, false)
	for x in [-1.2, -0.4]:
		Escena.bloque(Vector3(x - 0.07, ALTO - 0.16, -RADIO), Vector3(x + 0.07, ALTO, RADIO), madera, self, 0.01, false)
	# la puerta, que se abre hacia dentro al llegar, con su marco
	for x in [-0.55, 0.47]:
		Escena.bloque(Vector3(x, 0.0, RADIO - 0.12), Vector3(x + 0.08, 2.1, RADIO - 0.04), madera, self, 0.008, false)
	Escena.bloque(Vector3(-0.55, 2.04, RADIO - 0.12), Vector3(0.55, 2.14, RADIO - 0.04), madera, self, 0.008, false)
	puerta = Arquitectura.puerta(self, Vector3(-0.46, 0.0, RADIO - 0.08), 0.92, 2.03, madera, laton)
	var alfombra := CylinderMesh.new()
	alfombra.top_radius = 0.9
	alfombra.bottom_radius = 0.9
	alfombra.height = 0.01
	Geometria.pieza(alfombra, Materiales.liso(Color(0.35, 0.12, 0.08), 0.95), Vector3(0.0, 0.005, 0.1), self)


# Rellano de fuera: de ahí viene la cámara. Tiene un ventanuco con la misma tormenta.
func _rellano(piedra: Material) -> void:
	var z0 := RADIO - 0.2
	var z1 := RADIO + 1.7
	Arquitectura.losa(Vector3(-0.85, -0.05, z0), Vector3(0.85, 0.0, z1), Materiales.con_textura("tablones", 0.6, 0.7, 0.0, Color(0.6, 0.55, 0.5)), self)
	Arquitectura.losa(Vector3(-0.85, 2.45, z0), Vector3(0.85, 2.5, z1), piedra, self)
	Arquitectura.pared(Vector3(-0.85, 0.0, z1), Vector3.FORWARD, z1 - z0, 2.45, Vector3.RIGHT, piedra, self)
	Arquitectura.pared(Vector3(0.85, 0.0, z0), Vector3.BACK, z1 - z0, 2.45, Vector3.LEFT, piedra, self, [[0.75, 1.25, 1.2, 1.9]])
	Arquitectura.pared(Vector3(0.85, 0.0, z1), Vector3.LEFT, 1.7, 2.45, Vector3.FORWARD, piedra, self)
	var vista := QuadMesh.new()
	vista.size = Vector2(0.5, 0.7)
	_material_tormenta()
	var ventanuco := Geometria.pieza(vista, ventana, Vector3(0.9, 1.55, z0 + 1.0), self)
	ventanuco.rotation.y = -PI / 2.0
	Escena.luz(self, Vector3(-0.6, 1.9, z1 - 0.4), Color(1.0, 0.7, 0.4), 0.45, 2.4)


# El mismo cielo de tormenta en la ventana y en el ventanuco del rellano (los rayos iluminan los dos)
func _material_tormenta() -> void:
	if ventana == null:
		ventana = ShaderMaterial.new()
		ventana.shader = preload("res://shaders/tormenta.gdshader")


# --- Ventana con la tormenta y la placa ------------------------------------------------------------

func _ventana() -> void:
	var nodo := Escena.grupo(self, Vector3(0.0, 1.55, -RADIO + 0.08), "Ventana")
	var vista := QuadMesh.new()
	vista.size = Vector2(0.9, 1.2)
	_material_tormenta()
	Geometria.pieza(vista, ventana, Vector3.ZERO, nodo)
	for barra in [[Vector3(-0.5, -0.65, 0.0), Vector3(0.5, -0.57, 0.08)], [Vector3(-0.5, 0.57, 0.0), Vector3(0.5, 0.65, 0.08)],
			[Vector3(-0.5, -0.65, 0.0), Vector3(-0.44, 0.65, 0.08)], [Vector3(0.44, -0.65, 0.0), Vector3(0.5, 0.65, 0.08)],
			[Vector3(-0.025, -0.6, 0.0), Vector3(0.025, 0.6, 0.05)], [Vector3(-0.47, -0.02, 0.0), Vector3(0.47, 0.02, 0.05)]]:
		Escena.bloque(barra[0], barra[1], madera, nodo, 0.006, false)
	Escena.bloque(Vector3(-0.55, -0.72, 0.0), Vector3(0.55, -0.65, 0.2), madera, nodo, 0.008, false)
	luz_ventana = Escena.luz(self, Vector3(0.0, 1.6, -1.4), Color(0.55, 0.65, 0.9), 0.35, 4.0)
	var placa := PiezaNota.new()
	placa.id = "placa"
	placa.titulo = "Placa de latón"
	placa.texto = "FARO DE PUNTA NEGRA\n\nEncendido por primera vez en 1887.\n\n«Que ningún barco se pierda mientras quede aceite.»"
	placa.position = Vector3(-0.78, 1.5, -sqrt(RADIO * RADIO - 0.78 * 0.78) + 0.03)
	_girar_hacia_centro(placa)
	Escena.bloque(Vector3(-0.16, -0.09, -0.006), Vector3(0.16, 0.09, 0.0), laton, placa, 0.004, false)
	var texto := Label3D.new()
	texto.text = "FARO DE PUNTA NEGRA\nEncendido en 1887"
	texto.font = load("res://recursos/fuentes/LiberationSerif-Bold.ttf")
	texto.font_size = 48
	texto.pixel_size = 0.00048
	texto.modulate = Color(0.2, 0.13, 0.06)
	texto.outline_size = 0
	texto.shaded = true
	texto.position = Vector3(0.0, 0.0, 0.002)
	placa.add_child(texto)
	placa.colisor_caja(Vector3(0.34, 0.2, 0.03))
	placa.solo_desde = ["ventana"]
	agregar(placa)
	placa.accionada.connect(func(_p): completar("placa"))


# --- Escritorio: diario, quinqué, candado de cuatro ruedas y cajón --------------------------------

func _escritorio() -> void:
	var mesa_nodo := Escena.grupo(self, Vector3(-1.2, 0.0, -1.05), "Escritorio")
	_girar_hacia_centro(mesa_nodo)
	vistas["escritorio"] = mesa_nodo
	Escena.bloque(Vector3(-0.6, 0.74, -0.32), Vector3(0.6, 0.78, 0.32), madera, mesa_nodo, 0.008)
	for x in [-0.55, 0.55]:
		for z in [-0.27, 0.27]:
			Escena.bloque(Vector3(x - 0.03, 0.0, z - 0.03), Vector3(x + 0.03, 0.74, z + 0.03), madera, mesa_nodo, 0.005, false)
	Escena.bloque(Vector3(-0.58, 0.6, -0.3), Vector3(-0.2, 0.74, 0.29), madera, mesa_nodo, 0.005)
	Escena.bloque(Vector3(0.2, 0.6, -0.3), Vector3(0.58, 0.74, 0.29), madera, mesa_nodo, 0.005)
	# diario abierto
	var diario := PiezaNota.new()
	diario.id = "diario"
	diario.titulo = "Diario del farero"
	diario.texto = "14 de noviembre de 1903.\n\nTercer día de tormenta. El aceite se acaba y el barco del correo llega esta noche.\n\nHe cerrado el cajón con el candado: la combinación es el año en que este faro se encendió por primera vez.\n\nLa llave de la linterna la guardo donde guardo a los grandes: entre Fresnel y Stevenson.\n\nSi no estoy, que alguien encienda la luz."
	diario.position = Vector3(-0.18, 0.782, 0.02)
	diario.rotation.y = 0.12
	Escena.calcomania(Materiales.textura("diario"), Vector2(0.42, 0.26), Color.WHITE, diario,
		Transform3D(Basis(Vector3.RIGHT, -PI / 2.0), Vector3.ZERO))
	Escena.bloque(Vector3(-0.215, -0.012, -0.135), Vector3(0.215, -0.001, 0.135), Materiales.liso(Color(0.25, 0.08, 0.05), 0.7), diario, 0.002, false)
	diario.colisor_caja(Vector3(0.43, 0.02, 0.27))
	diario.solo_desde = ["escritorio"]
	agregar(diario, mesa_nodo)
	diario.accionada.connect(func(_p): completar("diario"))
	# quinqué con su llama
	var quinque_nodo := Escena.grupo(mesa_nodo, Vector3(0.38, 0.78, -0.12), "Quinque")
	var base := CylinderMesh.new()
	base.top_radius = 0.05
	base.bottom_radius = 0.07
	base.height = 0.08
	Geometria.pieza(base, laton, Vector3(0.0, 0.04, 0.0), quinque_nodo)
	var tubo := Geometria.torno(PackedVector2Array([Vector2(0.03, 0.08), Vector2(0.05, 0.13), Vector2(0.045, 0.2), Vector2(0.03, 0.26)]), 24)
	var vidrio := Geometria.pieza(tubo, Materiales.vidrio(Color(1.0, 0.9, 0.75, 0.2)), Vector3.ZERO, quinque_nodo)
	vidrio.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	llama = MeshInstance3D.new()
	var gota := SphereMesh.new()
	gota.radius = 0.012
	gota.height = 0.04
	llama.mesh = gota
	llama.material_override = Materiales.emisivo(Color(1.0, 0.65, 0.25), 5.0, Color(1.0, 0.7, 0.3))
	llama.position = Vector3(0.0, 0.135, 0.0)
	llama.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	quinque_nodo.add_child(llama)
	quinque = Escena.luz(quinque_nodo, Vector3(0.0, 0.16, 0.06), Color(1.0, 0.68, 0.38), 1.6, 4.5, true)
	_cajon(mesa_nodo)


func _cajon(mesa_nodo: Node3D) -> void:
	cajon = PiezaDeslizante.new()
	cajon.id = "cajon"
	cajon.position = Vector3(0.0, 0.67, 0.3)
	cajon.configurar(Vector3.BACK, 0.0, 0.3, [0.0, 0.3])
	cajon.sonido_tope = "tope_madera"
	Escena.bloque(Vector3(-0.19, -0.065, -0.012), Vector3(0.19, 0.065, 0.0), madera_clara, cajon, 0.004, false)
	var tirador := SphereMesh.new()
	tirador.radius = 0.012
	tirador.height = 0.024
	Geometria.pieza(tirador, laton, Vector3(0.0, 0.02, 0.008), cajon)
	var bandeja := Escena.grupo(cajon, Vector3(0.0, 0.0, -0.17), "Bandeja")
	Escena.bloque(Vector3(-0.18, -0.06, -0.16), Vector3(0.18, -0.05, 0.16), madera_clara, bandeja, 0.0, false)
	Escena.bloque(Vector3(-0.19, -0.06, -0.17), Vector3(-0.18, 0.04, 0.16), madera_clara, bandeja, 0.0, false)
	Escena.bloque(Vector3(0.18, -0.06, -0.17), Vector3(0.19, 0.04, 0.16), madera_clara, bandeja, 0.0, false)
	Escena.bloque(Vector3(-0.19, -0.06, -0.17), Vector3(0.19, 0.04, -0.16), madera_clara, bandeja, 0.0, false)
	cajon.colisor_caja(Vector3(0.4, 0.14, 0.03), Vector3(0.0, 0.0, 0.0))
	cajon.permiso = func() -> bool: return candado_abierto
	cajon.aviso_bloqueo = "El cajón está cerrado con un candado."
	cajon.solo_desde = ["escritorio", "candado"]
	agregar(cajon, mesa_nodo)
	cajon.accionada.connect(func(_p):
		if cajon.en(0.3):
			completar("cajon"))
	# cerillas dentro
	cerillas = PiezaRecogible.new()
	cerillas.id = "cerillas"
	cerillas.nombre_objeto = "Cerillas"
	cerillas.position = Vector3(0.06, -0.04, 0.02)
	cerillas.rotation.y = 0.4
	cerillas.modelo = Escena.grupo(cerillas, Vector3.ZERO, "Modelo")
	Escena.bloque(Vector3(-0.03, -0.01, -0.02), Vector3(0.03, 0.01, 0.02), Materiales.liso(Color(0.75, 0.12, 0.08), 0.6), cerillas.modelo, 0.002, false)
	Escena.calcomania(Materiales.textura("papel"), Vector2(0.04, 0.025), Color(0.95, 0.9, 0.6), cerillas.modelo,
		Transform3D(Basis(Vector3.RIGHT, -PI / 2.0), Vector3(0.0, 0.0102, 0.0)))
	cerillas.colisor_caja(Vector3(0.08, 0.04, 0.06))
	cerillas.permiso = func() -> bool: return cajon.reposo > 0.25
	cerillas.solo_desde = ["escritorio", "candado"]
	agregar(cerillas, bandeja)
	cerillas.accionada.connect(func(_p): completar("cerillas"))
	# candado de cuatro ruedas colgado del cajón
	candado = Escena.grupo(cajon, Vector3(0.0, -0.025, 0.03), "Candado")
	Escena.bloque(Vector3(-0.034, -0.032, -0.008), Vector3(0.034, 0.012, 0.008), laton, candado, 0.004, false)
	arco = Escena.grupo(candado, Vector3(0.0, 0.012, 0.0), "Arco")
	var curva := TorusMesh.new()
	curva.inner_radius = 0.016
	curva.outer_radius = 0.021
	var arco_malla := Geometria.pieza(curva, hierro, Vector3(0.0, 0.004, 0.0), arco)
	arco_malla.rotation = Vector3(PI / 2.0, 0.0, 0.0)
	arco_malla.scale = Vector3(1.0, 1.0, 1.3)
	for k in 4:
		var rueda := PiezaGiratoria.new()
		rueda.id = "rueda_%d" % k
		rueda.position = Vector3(-0.024 + k * 0.016, -0.018, 0.009)
		rueda.configurar(Vector3.RIGHT, TAU / 10.0)
		rueda.sonido_tope = "clic_metal"
		rueda.volumen_tope = -8.0
		rueda.radio_minimo = 0.008
		var cilindro := CylinderMesh.new()
		cilindro.top_radius = 0.009
		cilindro.bottom_radius = 0.009
		cilindro.height = 0.012
		cilindro.radial_segments = 10
		var malla := Geometria.pieza(cilindro, Materiales.liso(Color(0.15, 0.13, 0.12), 0.5, 0.6), Vector3.ZERO, rueda)
		malla.rotation = Vector3(0.0, 0.0, PI / 2.0)
		rueda.colisor_caja(Vector3(0.014, 0.022, 0.022))
		rueda.permiso = func() -> bool: return not candado_abierto
		rueda.solo_desde = ["candado"]
		agregar(rueda, candado)
		rueda.accionada.connect(func(_p): _comprobar_candado())
		ruedas.append(rueda)
		var numero := Label3D.new()
		numero.text = "0"
		numero.font = load("res://recursos/fuentes/LiberationSerif-Bold.ttf")
		numero.font_size = 64
		numero.pixel_size = 0.00018
		numero.modulate = Color(0.95, 0.92, 0.85)
		numero.outline_modulate = Color(0.05, 0.04, 0.03)
		numero.outline_size = 8
		numero.position = Vector3(-0.024 + k * 0.016, 0.0, 0.0092)
		candado.add_child(numero)
		numeros.append(numero)
	var zona := PiezaPuntoDeVista.new()
	zona.id = "zona_candado"
	zona.destino = "candado"
	zona.colisor_caja(Vector3(0.09, 0.08, 0.03), Vector3(0.0, -0.01, 0.01))
	zona.solo_desde = ["escritorio"]
	agregar(zona, candado)


func digito(rueda: PiezaGiratoria) -> int:
	return posmod(int(round(rueda.angulo / (TAU / 10.0))), 10)


func _comprobar_candado() -> void:
	if candado_abierto:
		return
	for k in 4:
		if digito(ruedas[k]) != COMBINACION[k]:
			return
	candado_abierto = true
	completar("candado")
	mesa.sonido.sonar("candado_abre", 0.0)
	mesa.vibrar(50, 0.8)
	mesa.mensaje("¡Clac! El candado se ha abierto.", 2.6)
	var animacion := create_tween()
	animacion.tween_property(arco, "position", arco.position + Vector3(0.0, 0.012, 0.0), 0.15)
	animacion.tween_interval(0.6)
	animacion.tween_property(candado, "scale", Vector3.ONE * 0.01, 0.35)
	animacion.tween_callback(candado.hide)
	animacion.tween_callback(func(): mesa.camara.volver())


# --- Estantería con los libros (el de en medio es una palanca) ----------------------------------

func _estanteria() -> void:
	var nodo := Escena.grupo(self, Vector3(1.32, 0.0, -1.0), "Estanteria")
	_girar_hacia_centro(nodo)
	vistas["estanteria"] = nodo
	Escena.bloque(Vector3(-0.5, 0.0, -0.18), Vector3(0.5, 1.9, -0.15), madera, nodo, 0.004)
	for x in [-0.5, 0.5]:
		Escena.bloque(Vector3(x - 0.02, 0.0, -0.18), Vector3(x + 0.02, 1.9, 0.12), madera, nodo, 0.004)
	for y in [0.1, 0.6, 1.1, 1.6]:
		Escena.bloque(Vector3(-0.5, y - 0.025, -0.16), Vector3(0.5, y, 0.12), madera, nodo, 0.004)
	var azar := RandomNumberGenerator.new()
	azar.seed = 1903
	var titulos := {2: {3: "FRESNEL", 4: "FAROS DEL NORTE", 5: "STEVENSON"}, 1: {1: "MAREAS", 6: "NAUFRAGIOS"},
		3: {2: "ATLAS", 5: "ASTRONOMÍA"}, 0: {4: "DIARIO 1899"}}
	var colores := [Color(0.35, 0.08, 0.06), Color(0.1, 0.16, 0.3), Color(0.12, 0.25, 0.12), Color(0.4, 0.3, 0.12),
		Color(0.25, 0.1, 0.2), Color(0.5, 0.42, 0.3)]
	for estante in 4:
		var x := -0.46
		var y := 0.1 + estante * 0.5
		var k := 0
		while x < 0.4:
			var ancho := azar.randf_range(0.035, 0.065)
			var alto := azar.randf_range(0.26, 0.38)
			var titulo: String = titulos.get(estante, {}).get(k, "")
			var color: Color = colores[azar.randi() % colores.size()]
			if titulo == "FAROS DEL NORTE":
				libro = PiezaDeslizante.new()
				libro.id = "libro"
				libro.position = Vector3(x + ancho / 2.0, y + alto / 2.0, 0.0)
				libro.configurar(Vector3.BACK, 0.0, 0.08, [0.0, 0.08])
				libro.sonido_mover = "libro"
				libro.sonido_tope = "tope_madera"
				_libro(libro, ancho, alto, Color(0.45, 0.32, 0.12), titulo)
				libro.colisor_caja(Vector3(ancho, alto, 0.24), Vector3(0.0, 0.0, -0.03))
				libro.solo_desde = ["estanteria"]
				agregar(libro, nodo)
				libro.accionada.connect(func(_p):
					if libro.en(0.08) and not hecho("libro"):
						completar("libro")
						_abrir_escondite())
			else:
				var adorno := Escena.grupo(nodo, Vector3(x + ancho / 2.0, y + alto / 2.0, 0.0))
				_libro(adorno, ancho, alto, color, titulo)
			x += ancho + 0.004
			k += 1
	# escondite: un cajoncito bajo el estante de abajo, con la llave
	escondite = Escena.grupo(nodo, Vector3(0.0, 0.04, 0.0), "Escondite")
	Escena.bloque(Vector3(-0.2, -0.035, -0.14), Vector3(0.2, 0.035, 0.1), madera, escondite, 0.004, false)
	Escena.bloque(Vector3(-0.18, -0.02, -0.12), Vector3(0.18, 0.036, 0.08), Materiales.liso(Color(0.3, 0.05, 0.05), 0.9), escondite, 0.0, false)
	llave = PiezaRecogible.new()
	llave.id = "llave"
	llave.nombre_objeto = "Llave de hierro"
	llave.position = Vector3(0.0, 0.04, -0.02)
	llave.modelo = Escena.grupo(llave, Vector3.ZERO, "Modelo")
	var aro := TorusMesh.new()
	aro.inner_radius = 0.012
	aro.outer_radius = 0.019
	Geometria.pieza(aro, hierro, Vector3(-0.05, 0.0, 0.0), llave.modelo)
	Escena.bloque(Vector3(-0.034, -0.004, -0.004), Vector3(0.05, 0.004, 0.004), hierro, llave.modelo, 0.001, false)
	Escena.bloque(Vector3(0.03, -0.004, 0.0), Vector3(0.05, 0.004, 0.02), hierro, llave.modelo, 0.001, false)
	llave.colisor_caja(Vector3(0.13, 0.03, 0.06))
	llave.permiso = func() -> bool: return hecho("libro")
	llave.solo_desde = ["estanteria"]
	agregar(llave, escondite)
	llave.accionada.connect(func(_p): completar("llave"))


func _libro(nodo: Node3D, ancho: float, alto: float, color: Color, titulo: String) -> void:
	Escena.bloque(Vector3(-ancho / 2.0, -alto / 2.0, -0.13), Vector3(ancho / 2.0, alto / 2.0, 0.1), Materiales.liso(color, 0.75), nodo, 0.004, false)
	if titulo != "":
		var lomo := Label3D.new()
		lomo.text = titulo
		lomo.font = load("res://recursos/fuentes/LiberationSerif-Bold.ttf")
		lomo.font_size = 40
		lomo.pixel_size = 0.0005
		lomo.modulate = Color(0.95, 0.85, 0.55)
		lomo.outline_size = 0
		lomo.shaded = true
		lomo.rotation = Vector3(0.0, 0.0, PI / 2.0)
		lomo.position = Vector3(0.0, 0.0, 0.101)
		nodo.add_child(lomo)


func _abrir_escondite() -> void:
	mesa.sonido.sonar("mecanismo", -4.0)
	var animacion := create_tween()
	animacion.tween_property(escondite, "position", escondite.position + Vector3(0.0, 0.0, 0.2), 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	mesa.mensaje("Algo se ha movido abajo, en la estantería.", 3.0)


# --- Escalera, trampilla y la linterna de arriba -----------------------------------------------------

func _escalera() -> void:
	var nodo := Escena.grupo(self, Vector3(0.7, 0.0, 0.7), "Escalera")
	for lado in [-0.22, 0.22]:
		var larguero := Geometria.pieza(Geometria.caja(Vector3(0.05, 2.75, 0.06), 0.008), madera, Vector3(lado, 1.32, 0.38), nodo)
		larguero.rotation.x = -0.2
	for k in 9:
		var y := 0.25 + k * 0.27
		var peldano := Geometria.pieza(Geometria.caja(Vector3(0.44, 0.035, 0.05), 0.006), madera, Vector3(0.0, y, 0.38 + (1.32 - y) * 0.2), nodo)
		peldano.rotation.x = -0.2
	trampilla = Escena.grupo(self, Vector3(0.45, ALTO + 0.03, 0.45), "Trampilla")
	var tapa := Escena.grupo(trampilla, Vector3.ZERO, "Tapa")
	Escena.bloque(Vector3(0.0, -0.03, 0.0), Vector3(0.5, 0.03, 0.5), madera, tapa, 0.006, false)
	for z in [0.08, 0.42]:
		Escena.bloque(Vector3(0.02, -0.045, z - 0.02), Vector3(0.48, -0.03, z + 0.02), hierro, tapa, 0.003, false)
	cerradura = PiezaRanura.new()
	cerradura.id = "cerradura"
	cerradura.acepta = "llave"
	cerradura.aviso_vacia = "Una cerradura grande. La trampilla está cerrada con llave."
	cerradura.position = Vector3(0.25, -0.05, 0.25)
	Escena.bloque(Vector3(-0.04, -0.01, -0.05), Vector3(0.04, 0.01, 0.05), hierro, cerradura, 0.003, false)
	var colocada := Escena.grupo(cerradura, Vector3(0.0, -0.02, 0.0), "Llave")
	Escena.bloque(Vector3(-0.004, -0.04, -0.004), Vector3(0.004, 0.0, 0.004), hierro, colocada, 0.001, false)
	colocada.hide()
	cerradura.colocado = colocada
	cerradura.desde = Vector3(0.0, -0.05, 0.0)
	cerradura.colisor_caja(Vector3(0.16, 0.06, 0.16))
	cerradura.solo_desde = ["trampilla"]
	agregar(cerradura, tapa)
	cerradura.accionada.connect(func(_p):
		completar("trampilla")
		_abrir_trampilla(tapa))
	subir = PiezaPuntoDeVista.new()
	subir.id = "subir"
	subir.destino = "linterna"
	subir.position = Vector3(0.25, 0.1, 0.25)
	subir.colisor_caja(Vector3(0.5, 0.1, 0.5))
	subir.solo_desde = ["trampilla"]
	subir.habilitada = false
	agregar(subir, trampilla)


func _abrir_trampilla(tapa: Node3D) -> void:
	mesa.sonido.sonar("llave", 0.0)
	await get_tree().create_timer(0.6).timeout
	mesa.sonido.sonar("trampilla", 0.0)
	var animacion := create_tween()
	animacion.tween_property(tapa, "rotation", Vector3(0.0, 0.0, 1.9), 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await animacion.finished
	subir.habilitada = true
	mesa.mensaje("La trampilla está abierta. Toca el hueco para subir.", 3.4)


func _linterna() -> void:
	var nodo := Escena.grupo(self, Vector3(0.0, ALTO + 0.06, 0.0), "Linterna")
	for k in 8:
		var angulo := TAU * k / 8.0
		var poste := Geometria.pieza(Geometria.caja(Vector3(0.06, 1.8, 0.06), 0.006), hierro, Vector3(cos(angulo) * 1.2, 0.9, sin(angulo) * 1.2), nodo)
		poste.rotation.y = -angulo
	var cristal := CylinderMesh.new()
	cristal.top_radius = 1.2
	cristal.bottom_radius = 1.2
	cristal.height = 1.8
	cristal.radial_segments = 8
	cristal.cap_top = false
	cristal.cap_bottom = false
	var vidrio := Geometria.pieza(cristal, Materiales.vidrio(Color(0.6, 0.7, 0.8, 0.1)), Vector3(0.0, 0.9, 0.0), nodo)
	vidrio.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var techo := CylinderMesh.new()
	techo.top_radius = 0.1
	techo.bottom_radius = 1.35
	techo.height = 0.6
	Geometria.pieza(techo, hierro, Vector3(0.0, 2.1, 0.0), nodo)
	# lente de Fresnel (anillos de cristal) y la lámpara de aceite dentro
	for k in 7:
		var anillo := TorusMesh.new()
		anillo.inner_radius = 0.34 - absf(k - 3) * 0.035
		anillo.outer_radius = anillo.inner_radius + 0.05
		var malla := Geometria.pieza(anillo, Materiales.vidrio(Color(0.8, 0.95, 1.0, 0.35), 0.02), Vector3(0.0, 0.55 + k * 0.09, 0.0), nodo)
		malla.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var pie := CylinderMesh.new()
	pie.top_radius = 0.12
	pie.bottom_radius = 0.2
	pie.height = 0.5
	Geometria.pieza(pie, laton, Vector3(0.0, 0.25, 0.0), nodo)
	mecha = PiezaRanura.new()
	mecha.id = "mecha"
	mecha.acepta = "cerillas"
	mecha.aviso_vacia = "La mecha de la lámpara está apagada."
	mecha.sonido_encajar = "cerilla"
	mecha.position = Vector3(0.0, 0.83, 0.0)
	var quemador := CylinderMesh.new()
	quemador.top_radius = 0.035
	quemador.bottom_radius = 0.05
	quemador.height = 0.06
	Geometria.pieza(quemador, laton, Vector3(0.0, -0.03, 0.0), mecha)
	mecha.colisor_caja(Vector3(0.6, 0.6, 0.6), Vector3(0.0, 0.0, 0.0))
	mecha.solo_desde = ["linterna"]
	agregar(mecha, nodo)
	mecha.accionada.connect(func(_p): completar("lampara"))
	llama_grande = MeshInstance3D.new()
	var gota := SphereMesh.new()
	gota.radius = 0.035
	gota.height = 0.12
	llama_grande.mesh = gota
	llama_grande.material_override = Materiales.emisivo(Color(1.0, 0.7, 0.3), 8.0, Color(1.0, 0.75, 0.35))
	llama_grande.position = Vector3(0.0, 0.89, 0.0)
	llama_grande.hide()
	nodo.add_child(llama_grande)
	lampara = Escena.luz(nodo, Vector3(0.0, 0.95, 0.0), Color(1.0, 0.78, 0.45), 0.0, 6.0)
	haz = Escena.grupo(nodo, Vector3(0.0, 0.9, 0.0), "Haz")
	var cono := CylinderMesh.new()
	cono.top_radius = 1.6
	cono.bottom_radius = 0.12
	cono.height = 14.0
	cono.cap_top = false
	cono.cap_bottom = false
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(1.0, 0.85, 0.55, 0.12)
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var rayo := Geometria.pieza(cono, material, Vector3(0.0, 0.0, 7.0), haz)
	rayo.rotation = Vector3(PI / 2.0, 0.0, 0.0)
	rayo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	haz.hide()


# --- Puntos de vista -------------------------------------------------------------------------------

func _mirar(desde: Vector3, hacia: Vector3) -> Transform3D:
	return Transform3D(Basis.looking_at(hacia - desde, Vector3.UP), desde)


func _vistas() -> void:
	var escritorio: Node3D = vistas["escritorio"]
	var estanteria: Node3D = vistas["estanteria"]
	var frente_escritorio := Basis(Vector3.UP, escritorio.rotation.y).z
	var frente_estanteria := Basis(Vector3.UP, estanteria.rotation.y).z
	var lugar_candado := escritorio.position + Basis(Vector3.UP, escritorio.rotation.y) * Vector3(0.0, 0.645, 0.34)
	vistas.clear()
	vistas["sala"] = _mirar(Vector3(0.25, 1.62, 1.55), Vector3(-0.35, 1.15, -1.0))
	vistas["escritorio"] = _mirar(escritorio.position + frente_escritorio * 0.78 + Vector3(0.0, 1.38, 0.0), escritorio.position + Vector3(0.0, 0.72, 0.0) + frente_escritorio * 0.05)
	vistas["candado"] = _mirar(lugar_candado + frente_escritorio * 0.13 + Vector3(0.0, 0.03, 0.0), lugar_candado + Vector3(0.0, -0.008, 0.0))
	vistas["estanteria"] = _mirar(estanteria.position + frente_estanteria * 1.15 + Vector3(0.0, 1.32, 0.0), estanteria.position + Vector3(0.0, 0.95, 0.0))
	vistas["ventana"] = _mirar(Vector3(-0.1, 1.52, -0.5), Vector3(-0.32, 1.5, -RADIO))
	vistas["trampilla"] = _mirar(Vector3(0.35, 1.45, 1.35), Vector3(0.7, ALTO, 0.7))
	vistas["linterna"] = _mirar(Vector3(0.75, ALTO + 1.25, 0.75), Vector3(0.0, ALTO + 0.85, 0.0))
	# zonas que llevan a cada punto desde la sala
	for datos in [["ir_escritorio", "escritorio", escritorio.position + Vector3(0.0, 0.7, 0.0), Vector3(1.4, 1.4, 1.0), escritorio.rotation.y],
			["ir_estanteria", "estanteria", estanteria.position + Vector3(0.0, 0.95, 0.0), Vector3(1.1, 1.9, 0.6), estanteria.rotation.y],
			["ir_ventana", "ventana", Vector3(-0.2, 1.5, -RADIO + 0.25), Vector3(1.9, 1.4, 0.3), 0.0],
			["ir_trampilla", "trampilla", Vector3(0.7, 1.4, 0.95), Vector3(0.8, 2.6, 0.8), 0.0]]:
		var zona := PiezaPuntoDeVista.new()
		zona.id = datos[0]
		zona.destino = datos[1]
		zona.position = datos[2]
		zona.rotation.y = datos[4]
		zona.colisor_caja(datos[3])
		zona.solo_desde = ["sala"]
		agregar(zona)


# --- Pasos y pistas ----------------------------------------------------------------------------------

func _pasos() -> void:
	paso("diario", [
		"El farero dejó algo escrito.",
		"Mira el escritorio.",
		"Toca el diario que hay sobre el escritorio."], "diario")
	paso("placa", [
		"El diario habla de un año.",
		"Junto a la ventana hay una placa de latón.",
		"Ve a la ventana y toca la placa."], "placa")
	paso("candado", [
		"El cajón del escritorio tiene un candado de cuatro ruedas.",
		"La combinación es el año en que se encendió el faro.",
		"Pon 1-8-8-7 en las ruedas del candado (tócalas o arrástralas)."], "rueda_0")
	paso("cajon", [
		"El candado se ha abierto.",
		"Ya se puede abrir el cajón del escritorio.",
		"Tira del cajón hacia ti."], "cajon")
	paso("cerillas", [
		"En el cajón hay algo útil para una lámpara.",
		"Una caja de cerillas.",
		"Toca las cerillas para guardarlas."], "cerillas")
	paso("libro", [
		"El diario dice dónde está la llave: «entre Fresnel y Stevenson».",
		"Busca esos dos nombres en los lomos de la estantería.",
		"Tira del libro que está entre FRESNEL y STEVENSON."], "libro")
	paso("llave", [
		"Algo se abrió abajo, en la estantería.",
		"Hay una llave en el escondite.",
		"Toca la llave para guardarla."], "llave")
	paso("trampilla", [
		"La llave es grande, de hierro, como de una puerta.",
		"Arriba, al final de la escalera, hay una trampilla con cerradura.",
		"Ve a la escalera, elige la llave a la izquierda y toca la cerradura de la trampilla."], "cerradura")
	paso("lampara", [
		"Sube a la linterna del faro.",
		"La lámpara de aceite está apagada.",
		"Elige las cerillas a la izquierda y toca la lámpara."], "mecha")
	titulo_final = "El faro brilla"
	texto_final = "La luz barrió el mar y, entre la lluvia, el barco del correo viró a tiempo.\nDel farero, ni rastro: solo su chaqueta, todavía mojada, colgada junto a la lámpara."


# --- Cámara, luz y ambiente ------------------------------------------------------------------------

func preparar_camara(camara: CamaraPuzle) -> void:
	camara.camara.fov = 55.0
	camara.configurar_puntos(vistas, "sala", 55.0)
	camara.poner_luz(0.3, 2.2)


# Del rellano, por la puerta, hasta la vista de la sala
func ruta_entrada() -> Dictionary:
	return {"puntos": [Vector3(0.0, 1.62, RADIO + 1.35), Vector3(0.03, 1.62, RADIO + 0.35)],
		"miradas": [Vector3(-0.1, 1.3, 0.0), Vector3(-0.2, 1.25, -0.6)],
		"duracion": 5.0, "fov": 58.0}


func preparar_entorno(entorno: Environment) -> void:
	Escena.cielo(entorno, {
		"arriba": Color(0.02, 0.025, 0.035), "horizonte": Color(0.05, 0.06, 0.08), "abajo": Color(0.01, 0.015, 0.02),
		"resplandor": Color(0.1, 0.12, 0.16), "direccion_resplandor": Vector3(0.0, 0.2, -1.0), "apertura": 2.0,
		"nubes": 0.7, "color_nubes": Color(0.07, 0.08, 0.1), "estrellas": 0.0})
	entorno.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	entorno.ambient_light_color = Color(0.45, 0.5, 0.6)
	entorno.ambient_light_energy = 0.18
	entorno.tonemap_mode = Environment.TONE_MAPPER_ACES
	entorno.glow_enabled = true
	entorno.glow_intensity = 0.8
	entorno.fog_enabled = true
	entorno.fog_light_color = Color(0.08, 0.09, 0.11)
	entorno.fog_density = 0.04
	Escena.polvo(self, Vector3(1.4, 1.0, 1.4), Color(1.0, 0.85, 0.6, 0.4), 80, 0.006).position = Vector3(0.0, 1.2, 0.0)


# Al entrar: la tormenta y la puerta que se abre
func empezar() -> void:
	_ruido.frequency = 2.0
	mesa.sonido.bucle("lluvia", -10.0, 2.0)
	mesa.sonido.bucle("viento", -16.0, 3.0)
	mesa.sonido.sonar("puerta", -3.0)
	var animacion := create_tween()
	animacion.tween_interval(0.3)
	animacion.tween_property(puerta, "rotation:y", 1.6, 1.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func al_llegar() -> void:
	await get_tree().create_timer(1.0).timeout
	if hechos.is_empty():
		mesa.mensaje("Toca un mueble para acercarte; toca dos veces para mirar un punto de cerca. El botón de la esquina te devuelve a la sala.", 5.5)


func actualizar(delta: float) -> void:
	_tiempo += delta
	# la llama del quinqué tiembla sola; con una racha se agacha y la habitación se apaga un instante
	_racha = move_toward(_racha, 0.0, delta * 1.2)
	var golpe := sin(_racha * PI / 2.0)
	var temblor := sin(_tiempo * 38.0) * 0.25 * golpe
	quinque.light_energy = (1.6 + _ruido.get_noise_1d(_tiempo * 4.0) * 0.18) * (1.0 - 0.75 * golpe + temblor)
	llama.scale = Vector3(1.0 + 0.3 * golpe,
		(1.0 + _ruido.get_noise_1d(_tiempo * 6.0 + 9.0) * 0.15) * (1.0 - 0.55 * golpe), 1.0)
	llama.rotation.z = (golpe * 0.75 + temblor) * _lado_racha
	for k in numeros.size():
		(numeros[k] as Label3D).text = str(digito(ruedas[k]))
	_proximo_rayo -= delta
	if _proximo_rayo <= 0.0:
		_proximo_rayo = randf_range(9.0, 16.0)
		_destello = 1.0
		_trueno()
	_destello = maxf(0.0, _destello - delta * 2.5)
	var parpadeo := _destello * (0.6 + 0.4 * sin(_tiempo * 60.0))
	ventana.set_shader_parameter("destello", parpadeo)
	luz_ventana.light_energy = 0.35 + parpadeo * 3.0
	if encendido:
		haz.rotation.y += delta * 0.9
		lampara.light_energy = 2.2 + _ruido.get_noise_1d(_tiempo * 5.0) * 0.2


# --- La resistencia: la tormenta responde ---------------------------------------------------------

# Cuando algo no se deja, ni se mueve ni se marca: la tormenta responde. Una racha golpea la ventana,
# la llama del quinqué se agacha (la habitación se apaga un instante) y cae polvo de lo que tocaste.
# Si insistes, truena.
func resistir(_pieza: Pieza, punto: Vector3, veces: int) -> void:
	rachas += 1
	Efectos.polvo(self, punto, Color(0.85, 0.8, 0.72), 16 + 4 * mini(veces, 3), 4.5)
	_racha = 1.0
	_lado_racha = -_lado_racha
	mesa.sonido.sonar("racha", -5.0)
	if veces >= 3:
		_destello = 1.0
		_trueno()


func _trueno() -> void:
	await get_tree().create_timer(randf_range(0.4, 1.4)).timeout
	mesa.sonido.sonar("trueno", -3.0, randf_range(0.85, 1.1), 0.0)


# --- Final --------------------------------------------------------------------------------------------

func final() -> void:
	encendido = true
	llama_grande.show()
	haz.show()
	mesa.sonido.sonar("cerilla", -2.0)
	var animacion := create_tween()
	animacion.tween_property(lampara, "light_energy", 2.2, 1.2)
	await get_tree().create_timer(1.0).timeout
	mesa.sonido.sonar("final_farero", 0.0, 1.0, 0.0)
	await get_tree().create_timer(4.0).timeout


# --- Prueba automática --------------------------------------------------------------------------------

func _ir(vista: String) -> void:
	mesa.camara.ir_a(vista, 0.5)
	var fin := Time.get_ticks_msec() + 4000
	await get_tree().process_frame
	while not mesa.camara.quieta() and Time.get_ticks_msec() < fin:
		await get_tree().process_frame


func resolver_paso(id: String) -> void:
	match id:
		"diario":
			await _ir("escritorio")
			piezas["diario"].tocar()
			await get_tree().create_timer(0.3).timeout
			mesa.hud.cerrar_nota()
		"placa":
			mesa.camara.volver()
			await _ir("ventana")
			piezas["placa"].tocar()
			await get_tree().create_timer(0.3).timeout
			mesa.hud.cerrar_nota()
		"candado":
			mesa.camara.volver()
			await _ir("escritorio")
			await _ir("candado")
			for k in 4:
				ruedas[k].mover_a(COMBINACION[k] * TAU / 10.0, 0.15)
				await get_tree().create_timer(0.3).timeout
		"cajon":
			await _ir("escritorio")
			cajon.tocar()
		"cerillas":
			var fin := Time.get_ticks_msec() + 3000
			while cajon.reposo < 0.25 and Time.get_ticks_msec() < fin:
				await get_tree().process_frame
			cerillas.tocar()
		"libro":
			mesa.camara.volver()
			await _ir("estanteria")
			libro.tocar()
		"llave":
			await get_tree().create_timer(1.0).timeout
			llave.tocar()
		"trampilla":
			mesa.camara.volver()
			await _ir("trampilla")
			mesa.seleccionar("llave")
			cerradura.tocar()
		"lampara":
			var fin := Time.get_ticks_msec() + 5000
			while not subir.habilitada and Time.get_ticks_msec() < fin:
				await get_tree().process_frame
			subir.tocar()
			await _ir("linterna")
			mesa.seleccionar("cerillas")
			mecha.tocar()


func arrastre_de_prueba() -> Dictionary:
	# en el primer punto de vista: tocar el escritorio lleva la cámara hasta él
	var zona: Pieza = piezas["ir_escritorio"]
	return {"pieza": zona, "punto": zona.global_position, "direccion": Vector3.UP, "pixeles": 0.0,
		"comprobar": func() -> bool: return mesa.camara.punto_actual == "escritorio"}


# Una pieza bloqueada al empezar (la prueba comprueba que no se mueve al tocarla)
func bloqueo_de_prueba() -> Pieza:
	return cajon

func capturas_de_prueba() -> Array:
	return ["diario", "placa", "candado", "libro", "trampilla"]


func comprobaciones() -> Array:
	return [["el candado se abrió con 1887", candado_abierto], ["la lámpara del faro está encendida", encendido],
		["si algo no se deja, la tormenta responde (sin destello)", rachas >= 1]]
