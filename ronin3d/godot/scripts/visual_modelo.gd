# Personaje hecho con piezas 3D sencillas y cel-shading.
# Mira hacia +Z local; el nodo «cuerpo» gira hacia donde mira el personaje y las
# piernas, brazos y armas se animan por código.
# Animación limitada estilo anime: con «estilo_anime», las poses cambian 12 veces por
# segundo (y al instante cuando cambia la acción), aunque el personaje se desplaza suave.
extends Node3D

const Datos := preload("res://scripts/datos.gd")
const TEXTURA_SOMBRA := preload("res://recursos/sombra.png")

static var estilo_anime := true

var aspecto
var es_soldado := false
var cuerpo: Node3D
var torso: Node3D
var cadera_izq: Node3D
var cadera_der: Node3D
var hombro_izq: Node3D
var hombro_der: Node3D
var espada_mano: Node3D
var empunadura_cinto: Node3D
var estela: MeshInstance3D
var material_estela: StandardMaterial3D
var estela_iai: MeshInstance3D
var material_estela_iai: StandardMaterial3D
var lanza: Node3D
var cintas: Array = []
var materiales: Array = []
var aviso: Label3D
var fase := 0.0
var tiempo := 0.0
var angulo := 0.0
var acumulado := 0.0
var ultima_pose := ""
var ultima_muerte := -1.0
var ultimo_destello := 0.0
var actualizaciones := 0              # poses aplicadas (lo usa la prueba automática)


func configurar(aspecto_del_juego, soldado: bool) -> void:
	aspecto = aspecto_del_juego
	es_soldado = soldado
	cuerpo = Node3D.new()
	add_child(cuerpo)
	if soldado:
		_construir_soldado()
	else:
		_construir_akira()
	_crear_sombra_y_aviso()


# --- Piezas ------------------------------------------------------------------------

func _pivote(padre: Node3D, posicion: Vector3) -> Node3D:
	var pivote := Node3D.new()
	pivote.position = posicion
	padre.add_child(pivote)
	return pivote


func _pieza(padre: Node3D, malla: Mesh, color: Color, posicion: Vector3, por_normal := true,
		rotacion := Vector3.ZERO) -> MeshInstance3D:
	var instancia := MeshInstance3D.new()
	instancia.mesh = malla
	var material: Material = aspecto.material_personaje(color, por_normal)
	instancia.material_override = material
	materiales.append(material)
	instancia.position = posicion
	instancia.rotation = rotacion
	padre.add_child(instancia)
	return instancia


func _caja(padre: Node3D, tamano: Vector3, color: Color, posicion: Vector3,
		rotacion := Vector3.ZERO) -> MeshInstance3D:
	var malla := BoxMesh.new()
	malla.size = tamano
	return _pieza(padre, malla, color, posicion, false, rotacion)


func _cilindro(padre: Node3D, radio_abajo: float, radio_arriba: float, alto: float, color: Color,
		posicion: Vector3, rotacion := Vector3.ZERO) -> MeshInstance3D:
	var malla := CylinderMesh.new()
	malla.bottom_radius = radio_abajo
	malla.top_radius = radio_arriba
	malla.height = alto
	malla.radial_segments = 12
	malla.rings = 1
	return _pieza(padre, malla, color, posicion, true, rotacion)


func _esfera(padre: Node3D, radio: float, color: Color, posicion: Vector3, hemisferio := false) -> MeshInstance3D:
	var malla := SphereMesh.new()
	malla.radius = radio
	malla.height = radio if hemisferio else radio * 2.0
	malla.is_hemisphere = hemisferio
	malla.radial_segments = 16
	malla.rings = 8
	return _pieza(padre, malla, color, posicion)


func _capsula(padre: Node3D, radio: float, alto: float, color: Color, posicion: Vector3) -> MeshInstance3D:
	var malla := CapsuleMesh.new()
	malla.radius = radio
	malla.height = alto
	malla.radial_segments = 12
	malla.rings = 4
	return _pieza(padre, malla, color, posicion)


# --- Akira ---------------------------------------------------------------------------

func _construir_akira() -> void:
	cadera_izq = _pivote(cuerpo, Vector3(0.11, 0.8, 0))
	cadera_der = _pivote(cuerpo, Vector3(-0.11, 0.8, 0))
	for cadera in [cadera_izq, cadera_der]:
		_cilindro(cadera, 0.17, 0.11, 0.74, Datos.HAKAMA, Vector3(0, -0.37, 0))
		_caja(cadera, Vector3(0.14, 0.07, 0.24), Datos.TABI, Vector3(0, -0.76, 0.04))
	torso = _pivote(cuerpo, Vector3(0, 0.8, 0))
	_caja(torso, Vector3(0.44, 0.52, 0.28), Datos.KIMONO, Vector3(0, 0.27, 0))
	_caja(torso, Vector3(0.46, 0.1, 0.3), Datos.OBI, Vector3(0, 0.05, 0))
	_caja(torso, Vector3(0.05, 0.24, 0.02), Datos.HACHIMAKI, Vector3(0.06, 0.42, 0.142), Vector3(0, 0, 0.45))
	_caja(torso, Vector3(0.05, 0.24, 0.02), Datos.HACHIMAKI, Vector3(-0.06, 0.42, 0.142), Vector3(0, 0, -0.45))
	hombro_izq = _pivote(torso, Vector3(0.29, 0.48, 0))
	hombro_der = _pivote(torso, Vector3(-0.29, 0.48, 0))
	for hombro in [hombro_izq, hombro_der]:
		_capsula(hombro, 0.075, 0.5, Datos.KIMONO_OSCURO, Vector3(0, -0.22, 0))
		_esfera(hombro, 0.06, Datos.PIEL, Vector3(0, -0.47, 0))
	var cabeza := _pivote(torso, Vector3(0, 0.72, 0))
	_esfera(cabeza, 0.16, Datos.PIEL, Vector3.ZERO)
	_esfera(cabeza, 0.172, Datos.PELO, Vector3(0, 0.02, -0.025), true)
	_esfera(cabeza, 0.066, Datos.PELO, Vector3(0, 0.2, -0.05))
	_caja(cabeza, Vector3(0.03, 0.04, 0.02), Datos.PELO, Vector3(0.055, -0.01, 0.152))
	_caja(cabeza, Vector3(0.03, 0.04, 0.02), Datos.PELO, Vector3(-0.055, -0.01, 0.152))
	var anillo := TorusMesh.new()
	anillo.inner_radius = 0.158
	anillo.outer_radius = 0.19
	anillo.rings = 16
	anillo.ring_segments = 6
	_pieza(cabeza, anillo, Datos.HACHIMAKI, Vector3(0, 0.05, 0))
	for lado in [-1, 1]:
		var cinta := _pivote(cabeza, Vector3(0.035 * lado, 0.05, -0.17))
		_caja(cinta, Vector3(0.035, 0.02, 0.28), Datos.HACHIMAKI, Vector3(0, 0, -0.14))
		cintas.append(cinta)
	# katana envainada a la izquierda (vaina hacia atrás y abajo, empuñadura delante)
	var cinto := _pivote(torso, Vector3(0.25, 0.05, 0.03))
	cinto.rotation.x = -0.35
	_caja(cinto, Vector3(0.045, 0.045, 0.8), Datos.SAYA, Vector3(0, 0, -0.3))
	empunadura_cinto = _pivote(cinto, Vector3(0, 0, 0.2))
	_caja(empunadura_cinto, Vector3(0.04, 0.04, 0.24), Datos.TSUKA, Vector3.ZERO)
	# katana en la mano derecha, visible al atacar
	espada_mano = _pivote(hombro_der, Vector3(0, -0.47, 0))
	_caja(espada_mano, Vector3(0.04, 0.04, 0.22), Datos.TSUKA, Vector3(0, 0, 0.05))
	_caja(espada_mano, Vector3(0.025, 0.05, 0.85), Datos.ACERO, Vector3(0, 0, 0.58))
	espada_mano.visible = false
	estela = _crear_estela(Vector3(-0.15, 1.25, 0.05), false)
	material_estela = estela.material_override
	estela_iai = _crear_estela(Vector3(-0.1, 1.2, 0.0), true)
	material_estela_iai = estela_iai.material_override


# Estela del corte: media luna blanca que aparece con el tajo y se apaga. La del tajo es
# vertical (de encima de la cabeza a delante y abajo); la del iai, horizontal (de la
# cadera izquierda hacia la derecha, el desenvaine).
func _crear_estela(centro: Vector3, horizontal: bool) -> MeshInstance3D:
	var herramienta := SurfaceTool.new()
	herramienta.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	var pasos := 24
	for i in range(pasos + 1):
		var t := float(i) / pasos
		var angulo := lerpf(1.15, -1.35, t) if horizontal else lerpf(1.45, -0.55, t)
		var interior := lerpf(0.55, 0.7, sin(t * PI)) if horizontal else lerpf(0.55, 0.75, sin(t * PI))
		var exterior := lerpf(1.3, 1.85, sin(t * PI)) if horizontal else lerpf(1.2, 1.75, sin(t * PI))
		var direccion := Vector3(sin(angulo), 0.0, cos(angulo)) if horizontal \
			else Vector3(0.0, sin(angulo), cos(angulo))
		var alfa := sin(t * PI)
		herramienta.set_color(Color(1, 1, 1, alfa * 0.2))
		herramienta.add_vertex(centro + direccion * interior)
		herramienta.set_color(Color(1, 1, 1, alfa))
		herramienta.add_vertex(centro + direccion * exterior)
	var malla := MeshInstance3D.new()
	malla.mesh = herramienta.commit()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(0.92, 0.96, 1.0, 0.0)
	malla.material_override = material
	malla.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	malla.visible = false
	if horizontal:
		malla.rotation.z = 0.12            # el iai sube un poco al cruzar
	cuerpo.add_child(malla)
	return malla


# --- Soldado ---------------------------------------------------------------------------

func _construir_soldado() -> void:
	var oscuro := Color("26242c")
	cadera_izq = _pivote(cuerpo, Vector3(0.1, 0.78, 0))
	cadera_der = _pivote(cuerpo, Vector3(-0.1, 0.78, 0))
	for cadera in [cadera_izq, cadera_der]:
		_cilindro(cadera, 0.085, 0.095, 0.74, Datos.PANTALON, Vector3(0, -0.37, 0))
		_caja(cadera, Vector3(0.14, 0.22, 0.15), oscuro, Vector3(0, -0.52, 0.01))
		_caja(cadera, Vector3(0.13, 0.06, 0.22), oscuro, Vector3(0, -0.76, 0.03))
	torso = _pivote(cuerpo, Vector3(0, 0.78, 0))
	_cilindro(torso, 0.3, 0.24, 0.28, Datos.ARMADURA_OSCURA, Vector3(0, 0.04, 0))
	_caja(torso, Vector3(0.46, 0.5, 0.3), Datos.ARMADURA, Vector3(0, 0.4, 0))
	for y in [0.3, 0.42, 0.54]:
		_caja(torso, Vector3(0.475, 0.035, 0.31), Datos.ARMADURA_CLARA, Vector3(0, y, 0))
	hombro_izq = _pivote(torso, Vector3(0.31, 0.6, 0))
	hombro_der = _pivote(torso, Vector3(-0.31, 0.6, 0))
	for hombro in [hombro_izq, hombro_der]:
		var lado := 1.0 if hombro == hombro_izq else -1.0
		_caja(hombro, Vector3(0.16, 0.24, 0.3), Datos.ARMADURA, Vector3(0.03 * lado, -0.06, 0))
		_capsula(hombro, 0.065, 0.46, Datos.PANTALON, Vector3(0, -0.22, 0))
		_esfera(hombro, 0.055, Datos.PIEL, Vector3(0, -0.45, 0))
	var cabeza := _pivote(torso, Vector3(0, 0.86, 0))
	_esfera(cabeza, 0.15, Datos.PIEL, Vector3.ZERO)
	_caja(cabeza, Vector3(0.03, 0.03, 0.02), Datos.PELO, Vector3(0.05, -0.01, 0.142))
	_caja(cabeza, Vector3(0.03, 0.03, 0.02), Datos.PELO, Vector3(-0.05, -0.01, 0.142))
	_cilindro(cabeza, 0.44, 0.02, 0.22, Datos.SOMBRERO, Vector3(0, 0.15, 0))
	_cilindro(cabeza, 0.45, 0.45, 0.025, Datos.SOMBRERO.darkened(0.3), Vector3(0, 0.045, 0))
	lanza = _pivote(cuerpo, Vector3(-0.36, 1.25, 0.12))
	_cilindro(lanza, 0.025, 0.025, 2.4, Datos.MADERA_LANZA, Vector3.ZERO)
	_cilindro(lanza, 0.05, 0.0, 0.24, Datos.ACERO, Vector3(0, 1.32, 0))


func _crear_sombra_y_aviso() -> void:
	var sombra := Sprite3D.new()
	sombra.texture = TEXTURA_SOMBRA
	sombra.pixel_size = 0.032
	sombra.axis = Vector3.AXIS_Y
	sombra.position.y = 0.03
	sombra.shaded = false
	sombra.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(sombra)
	aviso = Label3D.new()
	aviso.text = "!"
	aviso.font_size = 96
	aviso.pixel_size = 0.006
	aviso.modulate = Color(1.0, 0.22, 0.16)
	aviso.outline_modulate = Color(0.12, 0.0, 0.0)
	aviso.outline_size = 18
	aviso.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	aviso.no_depth_test = true
	aviso.position.y = 2.3
	aviso.visible = false
	add_child(aviso)


# --- Animación -----------------------------------------------------------------------------

# En estilo anime la pose se aplica a pasos de 1/12 s; un cambio de acción, un golpe o la
# caída se aplican al instante para que el control no se note retrasado.
func actualizar(delta: float, info: Dictionary) -> void:
	acumulado += delta
	var cambio: bool = info.pose != ultima_pose or (info.muerte >= 0.0) != (ultima_muerte >= 0.0) \
		or info.destello > ultimo_destello + 0.3
	ultimo_destello = info.destello
	if estilo_anime and acumulado < Datos.PASO_ANIME and not cambio:
		return
	ultima_pose = info.pose
	ultima_muerte = info.muerte
	actualizaciones += 1
	_aplicar(acumulado, info)
	acumulado = 0.0


func _aplicar(delta: float, info: Dictionary) -> void:
	tiempo += delta
	var mirando: Vector3 = info.mirando
	angulo = lerp_angle(angulo, atan2(mirando.x, mirando.z), minf(1.0, delta * 14.0))
	cuerpo.rotation = Vector3(0, angulo, 0)
	cuerpo.position = Vector3.ZERO

	var paso := 0.0
	if info.moviendose and not info.en_aire:
		fase += delta * (13.0 if info.corriendo else 9.0)
		paso = sin(fase)
	cadera_izq.rotation.x = paso * 0.6
	cadera_der.rotation.x = -paso * 0.6
	hombro_izq.rotation.x = -paso * 0.45
	hombro_der.rotation.x = paso * 0.45
	cuerpo.position.y = absf(paso) * 0.04
	torso.rotation.x = 0.0
	if info.en_aire:
		cadera_izq.rotation.x = -0.55
		cadera_der.rotation.x = 0.3

	if es_soldado:
		_animar_lanza(info.pose)
	else:
		_animar_espada(info)

	for material in materiales:
		aspecto.poner_destello(material, info.destello)
	visible = info.visible
	if info.muerte >= 0.0:
		var caida := minf(1.0, info.muerte * 2.5)
		cuerpo.rotation.x = -PI / 2.0 * caida
		cuerpo.position.y = 0.18 * caida
		visible = info.muerte < 0.85
	aviso.visible = info.aviso and int(tiempo * 12.0) % 2 == 0


func _animar_espada(info: Dictionary) -> void:
	var pose: String = info.pose
	var en_mano: bool = pose in ["ataque", "desenvaine", "remate"]
	espada_mano.visible = en_mano
	empunadura_cinto.visible = not en_mano
	espada_mano.rotation = Vector3.ZERO
	hombro_der.rotation = Vector3(hombro_der.rotation.x, 0.0, 0.0)
	hombro_izq.rotation = Vector3(hombro_izq.rotation.x, 0.0, 0.0)
	torso.rotation.y = 0.0
	var brillo := 0.0
	var brillo_iai := 0.0
	match pose:
		"ataque":
			var giro := clampf(info.progreso / 0.55, 0.0, 1.0)
			hombro_der.rotation.x = lerpf(-2.9, -0.5, ease(giro, 0.4))
			hombro_izq.rotation.x = lerpf(-2.6, -0.8, ease(giro, 0.4))
			torso.rotation.x = lerpf(-0.12, 0.2, giro)
			brillo = _brillo(info.progreso, 0.35, 0.35)
		"postura":
			# Iaidō: la mano derecha en la empuñadura, a la izquierda; el cuerpo bajo y
			# adelantado, la pierna izquierda delante.
			hombro_der.rotation = Vector3(-0.32, 0.0, 0.86)
			hombro_izq.rotation = Vector3(-0.35, 0.0, -0.3)
			torso.rotation = Vector3(0.2, 0.3, 0.0)
			cadera_izq.rotation.x = -0.4
			cadera_der.rotation.x = 0.35
			cuerpo.position.y = -0.04
		"desenvaine":
			# Corte horizontal al desenvainar, de la cadera izquierda hacia la derecha.
			var barrido := clampf((info.progreso - 0.15) / 0.55, 0.0, 1.0)
			hombro_der.rotation = Vector3(-PI / 2.0 + 0.15, lerpf(1.1, -1.25, ease(barrido, 0.35)), 0.0)
			espada_mano.rotation = Vector3(PI / 2.0, 0.0, 0.0)
			hombro_izq.rotation = Vector3(-0.4, 0.0, -0.3)
			torso.rotation = Vector3(0.12, lerpf(0.35, -0.45, barrido), 0.0)
			cadera_izq.rotation.x = -0.5
			cadera_der.rotation.x = 0.4
			brillo_iai = _brillo(info.progreso, 0.45, 0.32)
		"remate":
			# Zanshin tras el iai perfecto: brazo extendido a la derecha, hoja en línea.
			hombro_der.rotation = Vector3(-PI / 2.0 + 0.3, -1.3, 0.0)
			espada_mano.rotation = Vector3(PI / 2.0, 0.0, 0.0)
			hombro_izq.rotation = Vector3(-0.2, 0.0, -0.2)
			torso.rotation = Vector3(0.1, -0.5, 0.0)
			cadera_izq.rotation.x = -0.55
			cadera_der.rotation.x = 0.45
	estela.visible = brillo > 0.01
	material_estela.albedo_color.a = brillo * 0.9
	estela_iai.visible = brillo_iai > 0.01
	material_estela_iai.albedo_color.a = brillo_iai * 0.95
	var reposo := -0.25 if info.moviendose else -1.15
	for i in cintas.size():
		cintas[i].rotation.x = reposo + sin(tiempo * 9.0 + i * 1.7) * 0.22


func _animar_lanza(pose: String) -> void:
	match pose:
		"preparando":
			lanza.position = Vector3(-0.25, 1.05, -0.55)
			lanza.rotation = Vector3(PI / 2.0, 0, 0)
			hombro_der.rotation.x = -1.2
			hombro_izq.rotation.x = -1.0
			torso.rotation.x = -0.12
		"estocada":
			lanza.position = Vector3(-0.2, 1.05, 0.62)
			lanza.rotation = Vector3(PI / 2.0, 0, 0)
			hombro_der.rotation.x = -1.55
			hombro_izq.rotation.x = -1.45
			torso.rotation.x = 0.22
		_:
			lanza.position = Vector3(-0.36, 1.25, 0.12)
			lanza.rotation = Vector3.ZERO
			hombro_der.rotation.x = -0.3


# Brillo de una estela según el avance del corte. En estilo anime es todo o nada: el
# «borrón» ocupa uno o dos cuadros enteros, como en la animación limitada.
func _brillo(progreso: float, centro: float, ancho: float) -> float:
	var valor := clampf(1.0 - absf(progreso - centro) / ancho, 0.0, 1.0)
	if estilo_anime:
		return 1.0 if valor > 0.25 else 0.0
	return valor
