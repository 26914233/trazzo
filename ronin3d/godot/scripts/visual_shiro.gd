# Shiro hecho con piezas y cel-shading, como los personajes: un perro japonés blanco (tipo
# shiba) con collar rojo, una moneda colgada y la cola enroscada (arte/conceptos/shiro.jpg). Mira hacia +Z local. Poses: andar, correr,
# quieto, sentado, olfatear, escarbar, alerta y salto; en estilo anime cambian 12 veces por
# segundo, como las de Akira.
extends Node3D

const Datos := preload("res://scripts/datos.gd")
const VisualModelo := preload("res://scripts/visual_modelo.gd")
const Monedas := preload("res://scripts/monedas.gd")
const TEXTURA_SOMBRA := preload("res://recursos/sombra.png")

var aspecto
var cuerpo: Node3D
var tronco: Node3D
var cabeza: Node3D
var cola: Node3D
var patas: Array = []                 # delante izquierda, delante derecha, detrás izquierda, detrás derecha
var moneda_boca: MeshInstance3D
var materiales := {}
var fase := 0.0
var tiempo := 0.0
var angulo := 0.0
var acumulado := 0.0
var ultima_pose := ""
var actualizaciones := 0              # poses aplicadas (lo usa la prueba automática)


func configurar(aspecto_del_juego) -> void:
	aspecto = aspecto_del_juego
	cuerpo = Node3D.new()
	add_child(cuerpo)
	tronco = _pivote(cuerpo, Vector3(0, 0.3, 0))
	var lomo := _capsula(tronco, 0.105, 0.46, Datos.SHIRO_BLANCO, Vector3.ZERO)
	lomo.rotation.x = PI / 2.0
	_esfera(tronco, 0.115, Datos.SHIRO_BLANCO, Vector3(0, 0.015, 0.13))       # pecho
	_esfera(tronco, 0.1, Datos.SHIRO_BLANCO, Vector3(0, 0.0, -0.14))         # grupa
	for punto in [Vector3(0.065, -0.03, 0.15), Vector3(-0.065, -0.03, 0.15),
			Vector3(0.065, -0.03, -0.15), Vector3(-0.065, -0.03, -0.15)]:
		var pata := _pivote(tronco, punto)
		_capsula(pata, 0.032, 0.27, Datos.SHIRO_BLANCO, Vector3(0, -0.12, 0))
		_esfera(pata, 0.034, Datos.SHIRO_CREMA, Vector3(0, -0.245, 0.012))    # pie
		patas.append(pata)
	# Cuello, collar y cabeza (con el hocico crema, la nariz negra y las orejas de punta)
	cabeza = _pivote(tronco, Vector3(0, 0.1, 0.2))
	var cuello := _capsula(cabeza, 0.062, 0.2, Datos.SHIRO_BLANCO, Vector3(0, 0.03, 0.0))
	cuello.rotation.x = 0.5
	var anillo := TorusMesh.new()
	anillo.inner_radius = 0.058
	anillo.outer_radius = 0.076
	anillo.rings = 12
	anillo.ring_segments = 6
	var collar := _pieza(cabeza, anillo, Datos.SHIRO_COLLAR, Vector3.ZERO)
	collar.rotation.x = 0.5
	_esfera(cabeza, 0.088, Datos.SHIRO_BLANCO, Vector3(0, 0.12, 0.06))
	# hocico: un óvalo crema que sale de la cara, con la nariz en la punta
	var hocico := _esfera(cabeza, 0.042, Datos.SHIRO_CREMA, Vector3(0, 0.095, 0.13))
	hocico.scale = Vector3(0.95, 0.75, 1.35)
	_esfera(cabeza, 0.015, Datos.SHIRO_NARIZ, Vector3(0, 0.108, 0.186), false)
	# la moneda que cuelga del collar (como en su concepto)
	var colgante := MeshInstance3D.new()
	colgante.mesh = Monedas.crear_malla_moneda(0.026, 0.008, 0.008)
	colgante.material_override = aspecto.material_emisivo(Datos.COBRE, 0.3)
	colgante.position = Vector3(0, -0.062, 0.07)
	cabeza.add_child(colgante)
	for lado in [-1.0, 1.0]:
		_esfera(cabeza, 0.016, Datos.SHIRO_NARIZ, Vector3(0.038 * lado, 0.142, 0.133), false)
		_esfera(cabeza, 0.009, Datos.SHIRO_CREMA, Vector3(0.03 * lado, 0.168, 0.128), false)   # «cejas» de shiba
		var oreja := _cono(cabeza, 0.036, 0.075, Datos.SHIRO_BLANCO, Vector3(0.045 * lado, 0.2, 0.04))
		oreja.rotation.z = -0.25 * lado
		var dentro := _cono(cabeza, 0.02, 0.05, Datos.SHIRO_CREMA, Vector3(0.045 * lado, 0.196, 0.052))
		dentro.rotation.z = -0.25 * lado
	moneda_boca = MeshInstance3D.new()
	moneda_boca.mesh = Monedas.crear_malla_moneda(0.07, 0.016, 0.02)
	moneda_boca.material_override = aspecto.material_emisivo(Datos.COBRE, 0.45)
	moneda_boca.position = Vector3(0, 0.07, 0.19)
	moneda_boca.rotation.y = PI / 2.0
	moneda_boca.visible = false
	cabeza.add_child(moneda_boca)
	# Cola enroscada sobre la grupa: un aro de canto
	cola = _pivote(tronco, Vector3(0, 0.1, -0.2))
	var rizo := TorusMesh.new()
	rizo.inner_radius = 0.028
	rizo.outer_radius = 0.07
	rizo.rings = 12
	rizo.ring_segments = 6
	var aro := _pieza(cola, rizo, Datos.SHIRO_BLANCO, Vector3(0, 0.05, 0.0))
	aro.rotation.z = PI / 2.0
	var sombra := Sprite3D.new()
	sombra.texture = TEXTURA_SOMBRA
	sombra.pixel_size = 0.016
	sombra.axis = Vector3.AXIS_Y
	sombra.position.y = 0.03
	sombra.shaded = false
	sombra.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(sombra)


# --- Piezas (un material por color: Shiro no destella) -------------------------------------

func _pivote(padre: Node3D, posicion: Vector3) -> Node3D:
	var pivote := Node3D.new()
	pivote.position = posicion
	padre.add_child(pivote)
	return pivote


func _pieza(padre: Node3D, malla: Mesh, color: Color, posicion: Vector3, contorno := true) -> MeshInstance3D:
	var clave := [color, contorno]
	if not materiales.has(clave):
		materiales[clave] = aspecto.material_personaje(color) if contorno else aspecto.material_toon(color, false)
	var instancia := MeshInstance3D.new()
	instancia.mesh = malla
	instancia.material_override = materiales[clave]
	instancia.position = posicion
	padre.add_child(instancia)
	return instancia


func _caja(padre: Node3D, tamano: Vector3, color: Color, posicion: Vector3) -> MeshInstance3D:
	var malla := BoxMesh.new()
	malla.size = tamano
	return _pieza(padre, malla, color, posicion)


func _esfera(padre: Node3D, radio: float, color: Color, posicion: Vector3, contorno := true) -> MeshInstance3D:
	var malla := SphereMesh.new()
	malla.radius = radio
	malla.height = radio * 2.0
	malla.radial_segments = 14
	malla.rings = 7
	return _pieza(padre, malla, color, posicion, contorno)


func _capsula(padre: Node3D, radio: float, alto: float, color: Color, posicion: Vector3) -> MeshInstance3D:
	var malla := CapsuleMesh.new()
	malla.radius = radio
	malla.height = alto
	malla.radial_segments = 10
	malla.rings = 3
	return _pieza(padre, malla, color, posicion)


func _cono(padre: Node3D, radio: float, alto: float, color: Color, posicion: Vector3) -> MeshInstance3D:
	var malla := CylinderMesh.new()
	malla.bottom_radius = radio
	malla.top_radius = 0.0
	malla.height = alto
	malla.radial_segments = 4
	malla.rings = 1
	return _pieza(padre, malla, color, posicion)


# --- Animación -------------------------------------------------------------------------------

func actualizar(delta: float, info: Dictionary) -> void:
	acumulado += delta
	var cambio: bool = info.pose != ultima_pose
	if VisualModelo.estilo_anime and acumulado < Datos.PASO_ANIME and not cambio:
		return
	ultima_pose = info.pose
	actualizaciones += 1
	_aplicar(acumulado, info)
	acumulado = 0.0


func _aplicar(delta: float, info: Dictionary) -> void:
	tiempo += delta
	var mirando: Vector3 = info.mirando
	angulo = lerp_angle(angulo, atan2(mirando.x, mirando.z), minf(1.0, delta * 12.0))
	cuerpo.rotation = Vector3(0, angulo, 0)
	tronco.position = Vector3(0, 0.3, 0)
	tronco.rotation = Vector3.ZERO
	cabeza.rotation = Vector3.ZERO
	cola.rotation = Vector3.ZERO
	for pata in patas:
		pata.rotation = Vector3.ZERO
	var meneo := 5.0                  # rapidez del meneo de la cola (0: quieta)
	match info.pose:
		"andar", "correr":
			var corre: bool = info.pose == "correr"
			fase += delta * (17.0 if corre else 12.0)
			var paso := sin(fase) * (0.75 if corre else 0.5)
			# trote: se mueven a la vez las patas en diagonal
			patas[0].rotation.x = paso
			patas[3].rotation.x = paso
			patas[1].rotation.x = -paso
			patas[2].rotation.x = -paso
			tronco.position.y = 0.3 + absf(cos(fase)) * (0.035 if corre else 0.02)
			tronco.rotation.x = sin(fase * 2.0) * (0.06 if corre else 0.02)
			meneo = 11.0
		"sentado":
			# el pecho arriba, la grupa en el suelo y las patas de atrás dobladas hacia delante
			tronco.rotation.x = -0.55
			tronco.position = Vector3(0, 0.25, -0.05)
			patas[0].rotation.x = 0.55
			patas[1].rotation.x = 0.55
			patas[2].rotation.x = -1.0
			patas[3].rotation.x = -1.0
			cabeza.rotation.x = 0.45
			meneo = 3.0
		"olfatear":
			cabeza.rotation = Vector3(0.75, sin(tiempo * 7.0) * 0.3, 0)
			tronco.rotation.x = 0.08
			patas[0].rotation.x = -0.08
			patas[1].rotation.x = -0.08
			meneo = 9.0
		"escarbar":
			tronco.rotation.x = 0.3
			tronco.position.y = 0.29
			cabeza.rotation.x = 0.35
			var golpe := sin(tiempo * 26.0) * 0.7
			patas[0].rotation.x = -0.6 + golpe
			patas[1].rotation.x = -0.6 - golpe
			patas[2].rotation.x = -0.3
			patas[3].rotation.x = -0.3
			meneo = 14.0
		"alerta":
			# agachado, la cabeza baja y la cola entre las patas
			tronco.rotation.x = 0.14
			tronco.position.y = 0.26
			cabeza.rotation.x = 0.15
			patas[0].rotation.x = -0.25
			patas[1].rotation.x = -0.25
			patas[2].rotation.x = 0.1
			patas[3].rotation.x = 0.1
			cola.rotation.x = 0.9
			meneo = 0.0
		"salto":
			patas[0].rotation.x = -0.9
			patas[1].rotation.x = -0.9
			patas[2].rotation.x = 0.8
			patas[3].rotation.x = 0.8
			tronco.rotation.x = -0.18
		_:
			cabeza.rotation.y = sin(tiempo * 0.9) * 0.25
	if meneo > 0.0:
		cola.rotation.z = sin(tiempo * meneo) * 0.35
	moneda_boca.visible = info.en_boca
