# La reliquia: un artefacto de otro mundo que flota. Un núcleo de luz, tres anillos que giran y un
# marco con ocho glifos. Cada anillo tiene dos surcos que desvían la luz de forma distinta: hay que
# girarlos para llevar la luz hasta el glifo que late. Con el cristal, la luz cambia y el camino también.
#
# Pasos: despertar el núcleo → luz en el primer anillo → luz en el glifo de abajo (se abre un hueco) →
# coger el cristal → ponerlo en el núcleo → luz en el glifo de arriba a la derecha → tocar el núcleo.
# Flota sobre el altar de un santuario circular (salas/santuario.gd), bajo un óculo abierto al cielo.
extends Puzle

const Santuario := preload("res://scripts/salas/santuario.gd")

const PASOS := 8                      # posiciones de cada anillo (45 grados)
const RADIOS := [[0.05, 0.08], [0.086, 0.116], [0.122, 0.154]]
const GROSOR := 0.018
const MARCO := [0.168, 0.205]
# Surcos de cada anillo: entrada (en pasos, en el propio anillo) y desvío al salir
const SURCOS := [
	[{"entrada": 0, "desvio": 1}, {"entrada": 4, "desvio": -2}],
	[{"entrada": 1, "desvio": 2}, {"entrada": 5, "desvio": 0}],
	[{"entrada": 2, "desvio": -1}, {"entrada": 5, "desvio": 3}],
]
const GIRO_INICIAL := [3, 6, 1]
const GLIFO_1 := 4                    # abajo
const GLIFO_2 := 7                    # arriba a la derecha
const CIAN := Color(0.3, 0.9, 1.0)
const VIOLETA := Color(0.75, 0.4, 1.0)

var artefacto: Node3D
var anillos: Array = []
var surcos_mallas: Array = []         # [anillo][surco] -> ShaderMaterial
var nucleo: PiezaPulsador
var material_nucleo: StandardMaterial3D
var zocalo: PiezaRanura
var cristal: PiezaRecogible
var hueco: Node3D
var petalos: Array = []
var glifos: Array = []                # materiales de los ocho glifos
var rayos: Array = []                 # rayo corto entre el último anillo y cada glifo
var rayo_nucleo: ShaderMaterial
var luz_nucleo: OmniLight3D
var holograma: Node3D
var despierta := false
var color_luz := CIAN
var final_luz := -1
var camino: Array = []                # [[anillo, surco]] por donde pasa la luz
var _rellenos := {}                   # material -> relleno objetivo
var sala: Node3D
var energia_nucleo := 0.15            # brillo del núcleo y de su luz, antes de que se retire
var energia_luz_nucleo := 0.0
var retiradas := 0                    # veces que la luz se retiró al núcleo (lo mira la prueba)
var _retraccion := 0.0
var _sobresalto := 0.0                # dormida, el núcleo late un instante, como quien se revuelve
var _tiempo := 0.0

var metal: Material


func construir() -> void:
	metal = Materiales.con_textura("metal_ajeno", 9.0, 0.38, 0.65, Color(0.75, 0.8, 0.9), 1.0)
	artefacto = Escena.grupo(self, Vector3.ZERO, "Artefacto")
	_marco()
	_anillos()
	_nucleo()
	_hueco_del_cristal()
	_holograma()
	_pasos()
	_zonas()
	_trazar()


func construir_sala() -> void:
	sala = Santuario.new()
	add_child(sala)
	sala.construir()


# Ángulo (desde +X, en sentido antihorario visto de frente) de la posición k: k = 0 es arriba
func _angulo(k: float) -> float:
	return PI / 2.0 + k * TAU / PASOS


func _polar(radio: float, angulo: float, z: float) -> Vector3:
	return Vector3(cos(angulo) * radio, sin(angulo) * radio, z)


# --- Marco: ocho pétalos con un glifo cada uno -------------------------------------------------------

func _marco() -> void:
	for k in PASOS:
		var centro := _angulo(k)
		var pivote := Escena.grupo(artefacto, _polar(MARCO[1], centro, 0.0), "Petalo%d" % k)
		var petalo := Escena.grupo(pivote, -_polar(MARCO[1], centro, 0.0), "Forma")
		var malla := Geometria.pieza(Geometria.anillo(MARCO[0], MARCO[1], GROSOR * 1.4, -centro - PI / 8.0 + 0.012,
			-centro + PI / 8.0 - 0.012, 24), metal, Vector3.ZERO, petalo)
		malla.rotation = Vector3(PI / 2.0, 0.0, 0.0)
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(0.05, 0.06, 0.08)
		material.emission_enabled = true
		material.emission = CIAN
		material.emission_texture = Materiales.textura("glifos")
		material.emission_energy_multiplier = 0.25
		material.albedo_texture = Materiales.textura("glifos")
		material.uv1_scale = Vector3(1.0 / PASOS, 1.0, 1.0)
		material.uv1_offset = Vector3(float(k) / PASOS, 0.0, 0.0)
		var glifo := MeshInstance3D.new()
		var quad := QuadMesh.new()
		quad.size = Vector2(0.026, 0.026)
		glifo.mesh = quad
		glifo.material_override = material
		glifo.position = _polar((MARCO[0] + MARCO[1]) / 2.0, centro, GROSOR * 0.7 + 0.0006)
		glifo.rotation = Vector3(0.0, 0.0, centro - PI / 2.0)
		petalo.add_child(glifo)
		glifos.append(material)
		var rayo := _cinta_material(0.0)
		var puntos := PackedVector3Array([_polar(RADIOS[2][1] + 0.001, centro, GROSOR * 0.5), _polar(MARCO[0] + 0.004, centro, GROSOR * 0.5)])
		Geometria.pieza(Geometria.cinta(puntos, 0.005), rayo, Vector3.ZERO, artefacto)
		rayos.append(rayo)
		petalos.append(pivote)


func _cinta_material(base := 0.12) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = preload("res://shaders/conducto.gdshader")
	material.set_shader_parameter("color", color_luz)
	material.set_shader_parameter("base", base)
	material.set_shader_parameter("relleno", 0.0)
	return material


# --- Anillos con sus dos surcos ---------------------------------------------------------------------

func _anillos() -> void:
	var tonos := [Color(0.72, 0.78, 0.9), Color(0.62, 0.68, 0.82), Color(0.55, 0.6, 0.75)]
	for i in 3:
		var anillo := PiezaGiratoria.new()
		anillo.id = "anillo_%d" % (i + 1)
		anillo.configurar(Vector3.BACK, TAU / PASOS)
		anillo.sonido_tope = "clic_metal"
		anillo.volumen_tope = -9.0
		anillo.sonido_mover = "deslizar_metal"
		anillo.radio_minimo = RADIOS[i][0]
		var forma := Geometria.anillo(RADIOS[i][0], RADIOS[i][1], GROSOR, 0.0, TAU, 72)
		var malla := Geometria.pieza(forma, Materiales.con_textura("metal_ajeno", 9.0, 0.35, 0.7, tonos[i], 1.0), Vector3.ZERO, anillo)
		malla.rotation = Vector3(PI / 2.0, 0.0, 0.0)
		anillo.colisor_malla(forma, Transform3D(Basis(Vector3.RIGHT, PI / 2.0), Vector3.ZERO))
		var materiales: Array = []
		for surco in SURCOS[i]:
			var entrada := _angulo(surco.entrada)
			var salida := _angulo(surco.entrada + surco.desvio)
			var puntos := PackedVector3Array()
			for j in 25:
				var t := j / 24.0
				var r := lerpf(RADIOS[i][0], RADIOS[i][1], t)
				puntos.append(_polar(r, lerpf(entrada, salida, smoothstep(0.0, 1.0, t)), GROSOR / 2.0 + 0.0007))
			var material := _cinta_material()
			Geometria.pieza(Geometria.cinta(puntos, 0.0065), material, Vector3.ZERO, anillo)
			materiales.append(material)
		surcos_mallas.append(materiales)
		anillo.angulo = GIRO_INICIAL[i] * TAU / PASOS
		anillo.reposo = anillo.angulo
		anillo.permiso = func() -> bool: return despierta
		anillo.aviso_bloqueo = "Los anillos no se mueven: la reliquia está dormida."
		agregar(anillo, artefacto)
		anillo.accionada.connect(func(_p): _trazar())
		anillos.append(anillo)


# --- Núcleo: se toca para despertarla; tiene un hueco para el cristal ---------------------------------

func _nucleo() -> void:
	nucleo = PiezaPulsador.new()
	nucleo.id = "nucleo"
	nucleo.eje = Vector3.FORWARD
	nucleo.recorrido = 0.003
	nucleo.sonido = "pulso"
	var bola := SphereMesh.new()
	bola.radius = 0.034
	bola.height = 0.068
	material_nucleo = Materiales.emisivo(CIAN, 0.15, Color(0.04, 0.06, 0.09))
	material_nucleo.metallic = 0.6
	material_nucleo.roughness = 0.2
	Geometria.pieza(bola, material_nucleo, Vector3.ZERO, nucleo)
	var forma := SphereShape3D.new()
	forma.radius = 0.036
	nucleo.colisor(forma)
	agregar(nucleo, artefacto)
	nucleo.accionada.connect(func(_p): _tocar_nucleo())
	luz_nucleo = Escena.luz(artefacto, Vector3(0.0, 0.0, 0.08), CIAN, 0.0, 0.9)
	rayo_nucleo = _cinta_material(0.0)
	var puntos := PackedVector3Array([_polar(0.03, _angulo(0), GROSOR / 2.0 + 0.0007), _polar(RADIOS[0][0] + 0.001, _angulo(0), GROSOR / 2.0 + 0.0007)])
	Geometria.pieza(Geometria.cinta(puntos, 0.006), rayo_nucleo, Vector3.ZERO, artefacto)
	# zócalo del cristal (se activa cuando hay cristal)
	zocalo = PiezaRanura.new()
	zocalo.id = "zocalo"
	zocalo.acepta = "cristal"
	zocalo.aviso_vacia = "El núcleo tiene un hueco con forma de cristal."
	zocalo.position = Vector3(0.0, 0.0, 0.034)
	var dentro := Escena.grupo(zocalo, Vector3.ZERO, "Cristal")
	_modelo_cristal(dentro, 0.7)
	dentro.hide()
	zocalo.colocado = dentro
	zocalo.desde = Vector3(0.0, 0.0, 0.05)
	zocalo.colisor_caja(Vector3(0.03, 0.03, 0.012), Vector3(0.0, 0.0, 0.004))
	zocalo.habilitada = false
	agregar(zocalo, artefacto)
	zocalo.accionada.connect(func(_p):
		completar("zocalo")
		color_luz = VIOLETA
		material_nucleo.emission = VIOLETA
		luz_nucleo.light_color = VIOLETA
		mesa.sonido.sonar("cristal", -2.0)
		if sala:
			sala.poner_color(VIOLETA)
		mesa.mensaje("La luz ha cambiado de color. Ahora late otro glifo.", 3.4)
		_trazar())


func _modelo_cristal(padre: Node3D, escala := 1.0) -> void:
	var forma := PackedVector2Array([Vector2(0.0, 0.03), Vector2(0.009, 0.006), Vector2(0.006, -0.02), Vector2(0.0, -0.026),
		Vector2(-0.006, -0.02), Vector2(-0.009, 0.006)])
	var material := Materiales.emisivo(Color(0.55, 0.85, 1.0), 1.6, Color(0.5, 0.8, 1.0))
	material.roughness = 0.05
	material.metallic_specular = 1.0
	var malla := Geometria.pieza(Geometria.extruir(forma, 0.008), material, Vector3.ZERO, padre)
	malla.scale = Vector3.ONE * escala
	malla.rotation = Vector3(0.0, 0.0, 0.5)


func _tocar_nucleo() -> void:
	if not despierta:
		despierta = true
		completar("despertar")
		mesa.sonido.sonar("despertar", -1.0)
		mesa.sonido.bucle("zumbido", -10.0, 2.0)
		var animacion := create_tween().set_parallel()
		animacion.tween_property(self, "energia_nucleo", 2.2, 1.5)
		animacion.tween_property(self, "energia_luz_nucleo", 1.4, 1.5)
		if sala:
			sala.encender(1.0)
		mesa.mensaje("La reliquia despierta. La luz sale del núcleo hacia arriba.", 3.6)
		_trazar()
	elif hecho("glifo_2") and not hecho("despliegue"):
		completar("despliegue")


# --- Hueco del cristal (se abre en el pétalo de abajo) ------------------------------------------------

func _hueco_del_cristal() -> void:
	var centro := _angulo(GLIFO_1)
	hueco = Escena.grupo(petalos[GLIFO_1].get_child(0), _polar((MARCO[0] + MARCO[1]) / 2.0, centro, 0.0), "Hueco")
	Geometria.pieza(Geometria.caja(Vector3(0.03, 0.018, 0.02), 0.002), Materiales.liso(Color(0.02, 0.03, 0.05), 0.3, 0.8), Vector3.ZERO, hueco)
	cristal = PiezaRecogible.new()
	cristal.id = "cristal"
	cristal.nombre_objeto = "Cristal"
	cristal.position = Vector3(0.0, 0.0, 0.006)
	cristal.rotation = Vector3(0.0, 0.0, PI / 2.0)
	cristal.modelo = Escena.grupo(cristal, Vector3.ZERO, "Modelo")
	_modelo_cristal(cristal.modelo)
	cristal.colisor_caja(Vector3(0.06, 0.03, 0.02))
	cristal.habilitada = false
	agregar(cristal, hueco)
	cristal.accionada.connect(func(_p):
		completar("fragmento")
		zocalo.habilitada = true)
	hueco.hide()


# --- Holograma del final: un mapa de estrellas ---------------------------------------------------------

func _holograma() -> void:
	holograma = Escena.grupo(self, Vector3(0.0, 0.0, 0.05), "Holograma")
	var azar := RandomNumberGenerator.new()
	azar.seed = 1891
	var puntos := PackedVector3Array()
	for k in 140:
		var direccion := Vector3(azar.randf_range(-1, 1), azar.randf_range(-0.5, 0.5), azar.randf_range(-1, 1)).normalized()
		puntos.append(direccion * azar.randf_range(0.12, 0.42))
	var multimalla := MultiMesh.new()
	multimalla.transform_format = MultiMesh.TRANSFORM_3D
	multimalla.instance_count = puntos.size()
	var esfera := SphereMesh.new()
	esfera.radius = 0.0025
	esfera.height = 0.005
	esfera.radial_segments = 6
	esfera.rings = 3
	multimalla.mesh = esfera
	for k in puntos.size():
		multimalla.set_instance_transform(k, Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * azar.randf_range(0.6, 1.8)), puntos[k]))
	var estrellas := MultiMeshInstance3D.new()
	estrellas.multimesh = multimalla
	estrellas.material_override = Materiales.emisivo(Color(0.6, 0.85, 1.0), 3.0, Color(0.6, 0.85, 1.0))
	holograma.add_child(estrellas)
	var lejana := MeshInstance3D.new()
	var bola := SphereMesh.new()
	bola.radius = 0.008
	bola.height = 0.016
	lejana.mesh = bola
	lejana.material_override = Materiales.emisivo(VIOLETA, 6.0, VIOLETA)
	lejana.position = Vector3(0.21, 0.11, -0.25)
	lejana.name = "Lejana"
	holograma.add_child(lejana)
	holograma.scale = Vector3.ONE * 0.01
	holograma.hide()


# --- La luz: por qué surcos pasa y a qué glifo llega ----------------------------------------------------

func _trazar() -> void:
	camino.clear()
	final_luz = -1
	var luz := 0
	var llega := despierta
	if llega:
		for i in 3:
			var giro: int = anillos[i].tope(PASOS)
			var encontrado := -1
			for j in SURCOS[i].size():
				if posmod(SURCOS[i][j].entrada + giro, PASOS) == luz:
					encontrado = j
			if encontrado < 0:
				llega = false
				break
			camino.append([i, encontrado])
			luz = posmod(luz + SURCOS[i][encontrado].desvio, PASOS)
		if llega:
			final_luz = luz
	_pintar_luz()
	if not despierta:
		return
	if not camino.is_empty() and not hecho("primer_anillo"):
		completar("primer_anillo")
	if final_luz == GLIFO_1 and not hecho("glifo_1"):
		completar("glifo_1")
		_abrir_hueco()
	elif final_luz == GLIFO_2 and hecho("zocalo") and not hecho("glifo_2"):
		completar("glifo_2")
		mesa.sonido.sonar("despertar", -3.0, 1.3)
		if sala:
			sala.encender(1.6)
		mesa.mensaje("Toda la reliquia vibra. El núcleo espera.", 3.4)
	elif final_luz >= 0:
		mesa.sonido.sonar("luz_fluye", -8.0)


func _pintar_luz() -> void:
	rayo_nucleo.set_shader_parameter("color", color_luz)
	_rellenos[rayo_nucleo] = 1.0 if despierta else 0.0
	for i in 3:
		for j in 2:
			var material: ShaderMaterial = surcos_mallas[i][j]
			material.set_shader_parameter("color", color_luz)
			_rellenos[material] = 0.0
	for paso_luz in camino:
		_rellenos[surcos_mallas[paso_luz[0]][paso_luz[1]]] = 1.0
	for k in PASOS:
		var rayo: ShaderMaterial = rayos[k]
		rayo.set_shader_parameter("color", color_luz)
		_rellenos[rayo] = 1.0 if k == final_luz else 0.0
		(glifos[k] as StandardMaterial3D).emission = color_luz


func _abrir_hueco() -> void:
	hueco.show()
	var centro := _angulo(GLIFO_1)
	var destino := hueco.position + _polar(0.035, centro, 0.012)
	var animacion := create_tween()
	animacion.tween_property(hueco, "position", destino, 1.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	animacion.tween_callback(func(): cristal.habilitada = true)
	mesa.sonido.sonar("despliegue", -4.0, 1.4)
	mesa.camara.enfocar(Vector3(0.0, -0.2, 0.02), 0.42, 0.0, -0.35, 1.5)
	mesa.mensaje("La luz llegó al glifo y el borde se abrió.", 3.4)


# --- Pasos y pistas -------------------------------------------------------------------------------------

func _pasos() -> void:
	paso("despertar", [
		"La reliquia está dormida.",
		"El centro parece responder al tacto.",
		"Toca el núcleo del centro."], "nucleo")
	paso("primer_anillo", [
		"La luz sale del núcleo hacia arriba y se detiene en el primer anillo.",
		"Los anillos giran. Busca un surco que reciba la luz.",
		"Gira el anillo interior hasta que un surco quede justo encima del núcleo."], "anillo_1")
	paso("glifo_1", [
		"Un glifo del borde late, como si llamara a la luz.",
		"Cada anillo tiene dos surcos, y cada uno desvía la luz de forma distinta.",
		"Lleva la luz al glifo de abajo: el interior por el surco que gira poco, y los otros dos hasta que la luz baje."], "anillo_3")
	paso("fragmento", [
		"El borde se ha abierto donde llegó la luz.",
		"Hay un cristal en el hueco de abajo.",
		"Toca el cristal para guardarlo."], "cristal")
	paso("zocalo", [
		"El cristal encaja en algún sitio.",
		"El núcleo tiene un hueco en el centro.",
		"Elige el cristal a la izquierda y toca el núcleo."], "zocalo")
	paso("glifo_2", [
		"Ahora late otro glifo.",
		"El camino de antes ya no sirve: prueba los otros surcos.",
		"Lleva la luz al glifo de arriba a la derecha: usa el otro surco en los tres anillos."], "anillo_1")
	paso("despliegue", [
		"La reliquia está lista.",
		"El núcleo vibra.",
		"Toca el núcleo."], "nucleo")
	titulo_final = "Coordenadas recibidas"
	texto_final = "La reliquia proyectó un mapa de estrellas que nadie reconoce. En un extremo late una, muy lejos, que se acaba de encender.\nAlgo, allí, sabe ahora dónde estás."


# --- Cámara, luz y ambiente ---------------------------------------------------------------------------

# Zonas de cerca para el doble toque
func _zonas() -> void:
	zona("nucleo", Vector3(0.0, 0.0, 0.03), 0.38, 0.0, 0.05, 0.045)
	zona("glifo_abajo", _polar((MARCO[0] + MARCO[1]) / 2.0, _angulo(GLIFO_1), 0.02), 0.4, 0.0, -0.15, 0.05)
	zona("glifo_arriba", _polar((MARCO[0] + MARCO[1]) / 2.0, _angulo(GLIFO_2), 0.02), 0.4, 0.2, 0.25, 0.05)
	zona("anillos", Vector3(0.0, 0.0, 0.01), 0.62, 0.0, 0.08, 0.17)


func preparar_camara(camara: CamaraPuzle) -> void:
	camara.camara.fov = 40.0
	camara.configurar_orbita(Vector3.ZERO, 0.25, 0.12, 1.3, Vector2(0.3, 2.2), Vector2(-0.8, 1.0), Vector2(-1.3, 1.3))
	camara.altura_minima = -0.95
	camara.poner_luz(0.4, 1.8, Color(0.85, 0.92, 1.0))


# Del pasillo, bajo el arco, hasta el altar
func ruta_entrada() -> Dictionary:
	var suelo: float = Santuario.SUELO
	return {"puntos": [Vector3(0.0, suelo + 1.65, 5.45), Vector3(0.0, suelo + 1.62, 3.7), Vector3(0.12, suelo + 1.5, 2.3)],
		"miradas": [Vector3(0.0, -0.1, 0.0), Vector3(0.0, -0.05, 0.0), Vector3(0.0, 0.0, 0.0)],
		"duracion": 6.0, "fov": 55.0}


func preparar_entorno(entorno: Environment) -> void:
	Escena.cielo(entorno, {
		"arriba": Color(0.01, 0.015, 0.035), "horizonte": Color(0.04, 0.03, 0.08), "abajo": Color(0.005, 0.01, 0.02),
		"resplandor": Color(0.25, 0.1, 0.35), "direccion_resplandor": Vector3(0.6, 0.3, -0.7), "apertura": 3.0,
		"nubes": 0.55, "color_nubes": Color(0.06, 0.1, 0.16), "estrellas": 0.9})
	entorno.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	entorno.ambient_light_color = Color(0.35, 0.4, 0.6)
	entorno.ambient_light_energy = 0.25
	entorno.tonemap_mode = Environment.TONE_MAPPER_ACES
	entorno.glow_enabled = true
	entorno.glow_intensity = 1.1
	entorno.glow_bloom = 0.08
	entorno.glow_hdr_threshold = 0.9
	Escena.luz(self, Vector3(-0.5, 0.45, 0.6), Color(0.6, 0.7, 1.0), 0.9, 2.5, true)
	if not sala:
		Escena.luz_lejana(self, Vector3(0.7, 0.5, -0.9), Color(0.7, 0.4, 1.0), 0.9)
	Escena.polvo(self, Vector3(0.6, 0.4, 0.4), Color(0.4, 0.8, 1.0, 0.6), 70, 0.003)


func empezar() -> void:
	mesa.sonido.bucle("viento", -24.0, 3.0)


func al_llegar() -> void:
	await get_tree().create_timer(1.2).timeout
	if hechos.is_empty():
		mesa.mensaje("Gira alrededor con un dedo. Toca dos veces para mirar de cerca; pellizca para alejarte.", 5.0)


func actualizar(delta: float) -> void:
	if sala:
		sala.actualizar(delta)
	_tiempo += delta
	artefacto.position.y = sin(_tiempo * 0.9) * 0.008
	artefacto.rotation.z = sin(_tiempo * 0.5) * 0.015
	for material in _rellenos:
		var actual: float = material.get_shader_parameter("relleno")
		material.set_shader_parameter("relleno", move_toward(actual, _rellenos[material], delta * 2.2))
	# el glifo que espera la luz late
	var objetivo := GLIFO_2 if hecho("zocalo") else GLIFO_1
	for k in PASOS:
		var material: StandardMaterial3D = glifos[k]
		var energia := 0.25
		if k == final_luz:
			energia = 3.0
		elif despierta and k == objetivo and not hecho("glifo_2"):
			energia = 0.6 + 0.8 * (0.5 + 0.5 * sin(_tiempo * 4.0))
		material.emission_energy_multiplier = energia
	if hecho("glifo_2"):
		energia_nucleo = 2.2 + sin(_tiempo * 9.0) * 1.0
	# el núcleo y su luz: se apagan un instante si la luz se retira; dormida, laten al revolverse
	_retraccion = move_toward(_retraccion, 0.0, delta * 1.3)
	_sobresalto = move_toward(_sobresalto, 0.0, delta * 1.6)
	var apagado := 1.0 - 0.85 * sin(_retraccion * PI / 2.0)
	var latido := sin(_sobresalto * PI)
	material_nucleo.emission_energy_multiplier = energia_nucleo * apagado + 2.4 * latido
	luz_nucleo.light_energy = energia_luz_nucleo * apagado + 0.9 * latido
	if holograma.visible:
		holograma.rotation.y += delta * 0.15


# --- La resistencia: la luz se retira ----------------------------------------------------------------

# Cuando algo no se deja, ni se mueve ni se marca: la luz se retira. Unas motas salen de donde tocaste y
# vuelven al núcleo, que se apaga un instante, como si contuviera la luz. Si la reliquia duerme, el
# núcleo se revuelve en sueños: late una vez al recibirlas. Si insistes, late grave.
func resistir(pieza: Pieza, punto: Vector3, veces: int) -> void:
	retiradas += 1
	var dispersion := 0.06 if pieza == nucleo else 0.02
	Efectos.motas_hacia(self, punto, nucleo, color_luz, 9 + 3 * mini(veces, 3), dispersion, 1.8)
	if despierta:
		_retraccion = 1.0
	else:
		_sobresalto = 1.0
	if veces >= 3:
		mesa.sonido.sonar("pulso", -9.0, 0.6)


# En el gabinete del menú: flota y el núcleo late más cuando la miras
func animar_vitrina(delta: float, _camara: Camera3D, activa: bool) -> void:
	_tiempo += delta
	artefacto.position.y = sin(_tiempo * 0.9) * 0.012
	artefacto.rotation.z = sin(_tiempo * 0.5) * 0.02
	var energia := 1.2 + 0.6 * sin(_tiempo * 3.0) if activa else 0.7
	material_nucleo.emission_energy_multiplier = lerpf(material_nucleo.emission_energy_multiplier, energia, minf(1.0, delta * 3.0))
	luz_nucleo.light_energy = lerpf(luz_nucleo.light_energy, 0.5 if activa else 0.0, minf(1.0, delta * 3.0))


# --- Final --------------------------------------------------------------------------------------------

func final() -> void:
	mesa.sonido.sonar("despliegue", -2.0)
	mesa.camara.enfocar(Vector3(0.0, 0.0, 0.05), 1.05, 0.0, 0.15, 2.5)
	var animacion := create_tween().set_parallel()
	for k in PASOS:
		var pivote: Node3D = petalos[k]
		var tangente := Vector3(-sin(_angulo(k)), cos(_angulo(k)), 0.0)
		animacion.tween_property(pivote, "basis", Basis(tangente, -1.1), 1.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(k * 0.06)
	await get_tree().create_timer(1.4).timeout
	holograma.show()
	mesa.sonido.sonar("final_reliquia", -1.0, 1.0, 0.0)
	var crece := create_tween()
	crece.tween_property(holograma, "scale", Vector3.ONE, 1.6).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(3.4).timeout


# --- Prueba automática ------------------------------------------------------------------------------------

func _girar_a(giros: Array) -> void:
	for i in 3:
		anillos[i].mover_a(giros[i] * TAU / PASOS, 0.2)
		await get_tree().create_timer(0.35).timeout


func resolver_paso(id: String) -> void:
	match id:
		"despertar":
			nucleo.tocar()
		"primer_anillo":
			anillos[0].mover_a(0.0, 0.2)
		"glifo_1":
			await _girar_a([0, 4, 4])
		"fragmento":
			var fin := Time.get_ticks_msec() + 4000
			while not cristal.habilitada and Time.get_ticks_msec() < fin:
				await get_tree().process_frame
			cristal.tocar()
		"zocalo":
			mesa.seleccionar("cristal")
			zocalo.tocar()
		"glifo_2":
			await _girar_a([4, 5, 6])
		"despliegue":
			nucleo.tocar()


func arrastre_de_prueba() -> Dictionary:
	# se despierta y se arrastra el anillo exterior agarrándolo por arriba
	if not despierta:
		nucleo.tocar()
	var punto: Vector3 = artefacto.to_global(_polar((RADIOS[2][0] + RADIOS[2][1]) / 2.0, _angulo(0), GROSOR / 2.0))
	return {"pieza": anillos[2], "punto": punto, "direccion": Vector3.LEFT, "pixeles": 110.0,
		"comprobar": func() -> bool: return absf(anillos[2].reposo - GIRO_INICIAL[2] * TAU / PASOS) > 0.01}


# Una pieza bloqueada al empezar (la prueba comprueba que no se mueve al tocarla)
# Para los clips de la resistencia: los anillos y el núcleo
func encuadre_de_prueba() -> Dictionary:
	return {"centro": Vector3(0.0, 0.0, 0.01), "distancia": 0.62, "guinada": 0.3, "cabeceo": 0.12}


func bloqueo_de_prueba() -> Pieza:
	return anillos[0]

func capturas_de_prueba() -> Array:
	return ["primer_anillo", "glifo_1", "zocalo", "glifo_2"]


func comprobaciones() -> Array:
	return [["la luz llega al glifo de arriba a la derecha", final_luz == GLIFO_2],
		["si algo no se deja, la luz se retira al núcleo (sin destello)", retiradas >= 1],
		["el cristal cambió el color de la luz", color_luz == VIOLETA]]
