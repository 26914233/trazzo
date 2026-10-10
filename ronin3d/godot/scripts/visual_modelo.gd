# Personaje hecho con piezas 3D sencillas y cel-shading.
# Mira hacia +Z local; el nodo «cuerpo» gira hacia donde mira el personaje y las
# piernas, brazos y armas se animan por código.
# Animación limitada estilo anime: con «estilo_anime», las poses cambian 12 veces por
# segundo (y al instante cuando cambia la acción), aunque el personaje se desplaza suave.
extends Node3D

const Datos := preload("res://scripts/datos.gd")
const TEXTURA_SOMBRA := preload("res://recursos/sombra.png")
const Apariencias := preload("res://scripts/apariencias_akira.gd")

static var estilo_anime := true
const CARA := Vector3(0.9, 1.0, 0.95)        # la cabeza de Akira, algo más estrecha que una bola
# Rasgos dibujados de cada cara (ojos, cejas, nariz, boca): recursos/caras/generar_caras.py
const CARAS := {
	"joven": preload("res://recursos/caras/cara_joven.png"),
	"curtido": preload("res://recursos/caras/cara_curtido.png"),
	"veterano": preload("res://recursos/caras/cara_veterano.png"),
	"mujer": preload("res://recursos/caras/cara_mujer.png"),
	"soldado": preload("res://recursos/caras/cara_soldado.png"),
}

var aspecto
var es_soldado := false
var apariencia := ""                  # aspecto de Akira (apariencias_akira.gd); vacío: el elegido
var cuerpo: Node3D
var torso: Node3D
var cadera_izq: Node3D
var cadera_der: Node3D
var hombro_izq: Node3D
var hombro_der: Node3D
var espada_mano: Node3D
var yari_mano: Node3D                 # armas de Akira además de la katana (armas.gd)
var nodachi_mano: Node3D
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


func configurar(aspecto_del_juego, soldado: bool, id_apariencia := "") -> void:
	aspecto = aspecto_del_juego
	es_soldado = soldado
	apariencia = id_apariencia
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
		rotacion := Vector3.ZERO, plano := false) -> MeshInstance3D:
	var instancia := MeshInstance3D.new()
	instancia.mesh = malla
	var material: Material = aspecto.material_personaje(color, por_normal, plano)
	instancia.material_override = material
	materiales.append(material)
	instancia.position = posicion
	instancia.rotation = rotacion
	padre.add_child(instancia)
	return instancia


# Detalles pequeños (la cicatriz, las solapas, el relieve de la máscara): sin contorno, que en piezas
# tan pequeñas lo convierte todo en manchas negras. Los ojos y las cejas van dibujados en la cara.
func _detalle(padre: Node3D, tamano: Vector3, color: Color, posicion: Vector3,
		rotacion := Vector3.ZERO) -> MeshInstance3D:
	var malla := BoxMesh.new()
	malla.size = tamano
	var instancia := MeshInstance3D.new()
	instancia.mesh = malla
	var material: Material = aspecto.material_toon(color, false)
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
		posicion: Vector3, rotacion := Vector3.ZERO, lados := 12, plano := false) -> MeshInstance3D:
	var malla := CylinderMesh.new()
	malla.bottom_radius = radio_abajo
	malla.top_radius = radio_arriba
	malla.height = alto
	malla.radial_segments = lados
	malla.rings = 1
	return _pieza(padre, malla, color, posicion, true, rotacion, plano)


func _esfera(padre: Node3D, radio: float, color: Color, posicion: Vector3, hemisferio := false,
		plano := false) -> MeshInstance3D:
	var malla := SphereMesh.new()
	malla.radius = radio
	malla.height = radio if hemisferio else radio * 2.0
	malla.is_hemisphere = hemisferio
	malla.radial_segments = 16
	malla.rings = 8
	return _pieza(padre, malla, color, posicion, true, Vector3.ZERO, plano)


# Mechón de pelo: un cono con la base en «base» y la punta hacia «direccion». Es lo que rompe la
# silueta de bola de la cabeza, como en el dibujo de anime.
func _mechon(padre: Node3D, base: Vector3, direccion: Vector3, largo: float, grosor: float,
		color: Color) -> MeshInstance3D:
	var malla := CylinderMesh.new()
	malla.top_radius = 0.0
	malla.bottom_radius = grosor
	malla.height = largo
	malla.radial_segments = 5
	malla.rings = 1
	var sentido := direccion.normalized()
	var mechon := _pieza(padre, malla, color, base + sentido * largo / 2.0)
	mechon.basis = Basis(Quaternion(Vector3.UP, sentido))
	return mechon


# Une varias piezas del mismo color en una sola malla (una llamada de dibujo en vez de veinte):
# el pelo tiene muchos mechones y el móvil lo agradece.
func _fusionar(padre: Node3D, piezas: Array, color: Color, nombre := "Pelo") -> MeshInstance3D:
	var herramienta := SurfaceTool.new()
	for pieza in piezas:
		herramienta.append_from(pieza.mesh, 0, pieza.transform)
		materiales.erase(pieza.material_override)
		pieza.free()
	var instancia := MeshInstance3D.new()
	instancia.mesh = herramienta.commit()
	var material: Material = aspecto.material_personaje(color)
	# línea fina: con la gruesa, las puntas de los mechones se redondeaban
	material.next_pass.set_shader_parameter("grosor", 0.015)
	instancia.material_override = material
	materiales.append(material)
	instancia.name = nombre
	padre.add_child(instancia)
	return instancia


# La cara con los rasgos dibujados: cambia el material de la pieza (la cabeza o el mentón) por
# el de la cara, medido en el espacio de la cabeza.
func _poner_cara(pieza: MeshInstance3D, color: Color, rasgos: Texture2D) -> void:
	materiales.erase(pieza.material_override)
	var material: Material = aspecto.material_cara(color, rasgos, pieza.transform)
	pieza.material_override = material
	materiales.append(material)


func _capsula(padre: Node3D, radio: float, alto: float, color: Color, posicion: Vector3) -> MeshInstance3D:
	var malla := CapsuleMesh.new()
	malla.radius = radio
	malla.height = alto
	malla.radial_segments = 12
	malla.rings = 4
	return _pieza(padre, malla, color, posicion)


# --- Akira ---------------------------------------------------------------------------

func _construir_akira() -> void:
	var a: Dictionary = Apariencias.datos(apariencia)
	var ancho: float = a.ancho
	cuerpo.scale = Vector3.ONE * float(a.escala)
	cadera_izq = _pivote(cuerpo, Vector3(0.11, 0.8, 0))
	cadera_der = _pivote(cuerpo, Vector3(-0.11, 0.8, 0))
	for cadera in [cadera_izq, cadera_der]:
		_cilindro(cadera, 0.17, 0.11, 0.74, a.hakama, Vector3(0, -0.37, 0))
		_caja(cadera, Vector3(0.14, 0.07, 0.24), Datos.WARAJI, Vector3(0, -0.76, 0.04))
	torso = _pivote(cuerpo, Vector3(0, 0.8, 0))
	_caja(torso, Vector3(0.44 * ancho, 0.52, 0.28), a.kimono, Vector3(0, 0.27, 0))
	_caja(torso, Vector3(0.46 * ancho, 0.1, 0.3), a.obi, Vector3(0, 0.05, 0))
	# solapas del kimono, sin contorno (con él hacían una mancha negra bajo el cuello)
	_detalle(torso, Vector3(0.05, 0.24, 0.02), a.solapa, Vector3(0.06, 0.42, 0.142), Vector3(0, 0, 0.45))
	_detalle(torso, Vector3(0.05, 0.24, 0.02), a.solapa, Vector3(-0.06, 0.42, 0.142), Vector3(0, 0, -0.45))
	# ropa gastada: un remiendo delante y otro detrás
	_caja(torso, Vector3(0.11, 0.09, 0.012), a.remiendo, Vector3(0.13 * ancho, 0.33, 0.142), Vector3(0, 0, 0.12))
	_caja(torso, Vector3(0.12, 0.1, 0.012), a.remiendo, Vector3(-0.09 * ancho, 0.22, -0.142), Vector3(0, 0, -0.2))
	if a.tasuki:
		# cuerda que recoge las mangas: una X en el pecho y otra en la espalda
		for z in [0.145, -0.145]:
			for giro in [0.72, -0.72]:
				_caja(torso, Vector3(0.025, 0.6, 0.012), Datos.CUERDA, Vector3(0, 0.3, z), Vector3(0, 0, giro))
	if a.sombrero:
		# sugegasa (sombrero de paja) colgado a la espalda
		_cilindro(torso, 0.36, 0.03, 0.15, Datos.PAJA, Vector3(0, 0.46, -0.24), Vector3(-1.25, 0, 0), 16)
	hombro_izq = _pivote(torso, Vector3(0.29 * ancho, 0.48, 0))
	hombro_der = _pivote(torso, Vector3(-0.29 * ancho, 0.48, 0))
	for hombro in [hombro_izq, hombro_der]:
		_capsula(hombro, 0.075, 0.5, a.manga, Vector3(0, -0.22, 0))
		_esfera(hombro, 0.06, a.piel, Vector3(0, -0.47, 0), false, true)
		if a.vendas:
			_cilindro(hombro, 0.079, 0.079, 0.13, Datos.VENDAS, Vector3(0, -0.37, 0))
	# Cuello y cabeza. La cabeza ya no es una bola: algo más estrecha, con el mentón en punta, y el
	# pelo (mechones de punta, flequillo y patillas a los lados de la cara) le rompe la silueta.
	# (El cuello y el mentón van sin contorno: con él parecían una perilla negra.)
	var cuello := _cilindro(torso, 0.055, 0.06, 0.14, a.piel, Vector3(0, 0.6, -0.01), Vector3.ZERO, 10, true)
	cuello.material_override.next_pass = null
	var cabeza := _pivote(torso, Vector3(0, 0.72, 0))
	# La cara: ojos, cejas, nariz y boca van dibujados en una imagen (como en los juegos de anime en
	# 3D) y la cabeza solo pone la forma. El mentón, sin contorno, que con él parecía una perilla.
	var id: String = apariencia if apariencia != "" else Apariencias.elegida
	var rasgos: Texture2D = CARAS.get(id, CARAS["joven"])
	var craneo := _esfera(cabeza, 0.16, a.piel, Vector3.ZERO, false, true)
	craneo.scale = CARA
	_poner_cara(craneo, a.piel, rasgos)
	var menton := _cilindro(cabeza, 0.03, 0.115, 0.1, a.piel, Vector3(0, -0.115, 0.035), Vector3(-0.3, 0, 0), 8, true)
	menton.scale = Vector3(1.0, 1.0, 0.85)
	_poner_cara(menton, a.piel, rasgos)
	menton.material_override.next_pass = null
	_peinado(cabeza, a)
	_cicatriz(cabeza)
	# Cinta (hachimaki) deshilachada: pegada a la frente, por encima del pelo a los lados y anudada
	# detrás, con las puntas al viento
	var banda := _pieza(cabeza, _malla_cinta(), a.cinta, Vector3.ZERO)
	banda.material_override.next_pass.set_shader_parameter("grosor", 0.008)
	banda.name = "Cinta"
	var punto_nudo: Array = _punto_cinta(PI - 0.5, 0.0)
	var posicion_nudo: Vector3 = punto_nudo[0] + punto_nudo[1] * 0.012
	var nudo := _esfera(cabeza, 0.022, a.cinta, posicion_nudo)
	nudo.scale = Vector3(1.0, 0.8, 0.75)
	for lado in [-1, 1]:
		var cinta := _pivote(cabeza, posicion_nudo + Vector3(0.012 * lado, 0, -0.008))
		cinta.rotation.y = 0.35
		_caja(cinta, Vector3(0.035, 0.012, 0.3), a.cinta, Vector3(0, 0, -0.15))
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
	# yari: asta larga con la hoja delante; nodachi: hoja de casi 1,4 m y empuñadura larga
	yari_mano = _pivote(hombro_der, Vector3(0, -0.47, 0))
	_caja(yari_mano, Vector3(0.035, 0.035, 2.0), Datos.MADERA_LANZA, Vector3(0, 0, 0.3))
	_caja(yari_mano, Vector3(0.025, 0.07, 0.32), Datos.ACERO, Vector3(0, 0, 1.45))
	yari_mano.visible = false
	nodachi_mano = _pivote(hombro_der, Vector3(0, -0.47, 0))
	_caja(nodachi_mano, Vector3(0.045, 0.045, 0.38), Datos.TSUKA, Vector3(0, 0, 0.02))
	_caja(nodachi_mano, Vector3(0.03, 0.065, 1.35), Datos.ACERO, Vector3(0, 0, 0.88))
	nodachi_mano.visible = false
	estela = crear_estela(cuerpo, Vector3(-0.15, 1.25, 0.05), false)
	material_estela = estela.material_override
	estela_iai = crear_estela(cuerpo, Vector3(-0.1, 1.2, 0.0), true)
	material_estela_iai = estela_iai.material_override


# Cinta de la frente: un óvalo que va pegado a la frente y, a los lados y detrás, por encima del
# pelo, algo más bajo en la nuca (como se ata un hachimaki). Un aro redondo (TorusMesh) no se
# ajustaba a la cabeza y flotaba como un halo oscuro. Devuelve [posición, normal hacia fuera] del
# borde de la cinta en el ángulo dado (0 = delante, hacia +x = el lado izquierdo del personaje);
# «altura» va de -1 (borde de abajo) a 1 (borde de arriba).
func _punto_cinta(angulo: float, altura: float) -> Array:
	var s := sin(angulo)
	var c := cos(angulo)
	var semi_x := 0.168
	var semi_z := 0.149 if c >= 0.0 else 0.2
	var radio := 1.0 / sqrt(pow(s / semi_x, 2.0) + pow(c / semi_z, 2.0))
	var alto := lerpf(0.03, 0.036, (c + 1.0) / 2.0)
	var y := 0.026 + 0.026 * c + altura * alto / 2.0
	var normal := Vector3(s / (semi_x * semi_x), 0.0, c / (semi_z * semi_z)).normalized()
	return [Vector3(s * radio, y, c * radio), normal]


func _malla_cinta() -> ArrayMesh:
	var herramienta := SurfaceTool.new()
	herramienta.begin(Mesh.PRIMITIVE_TRIANGLES)
	var tramos := 32
	for i in tramos:
		var angulo_a := TAU * i / tramos
		var angulo_b := TAU * (i + 1) / tramos
		var arriba_a: Array = _punto_cinta(angulo_a, 1.0)
		var arriba_b: Array = _punto_cinta(angulo_b, 1.0)
		var abajo_a: Array = _punto_cinta(angulo_a, -1.0)
		var abajo_b: Array = _punto_cinta(angulo_b, -1.0)
		# dos triángulos por tramo, en el orden de las agujas del reloj visto desde fuera
		for punto in [arriba_a, arriba_b, abajo_b, arriba_a, abajo_b, abajo_a]:
			herramienta.set_normal(punto[1])
			herramienta.add_vertex(punto[0])
	return herramienta.commit()


# Peinados, hechos de mechones de punta sobre un casquete que deja la frente libre: coleta revuelta
# (el Akira joven), moño de samurái (curtido y veterano) y coleta larga (Akira mujer). Al final se
# unen en una sola malla.
func _peinado(cabeza: Node3D, a: Dictionary) -> void:
	var pelo: Color = a.pelo
	var piezas: Array = []
	var casquete := _esfera(cabeza, 0.172, pelo, Vector3(0, 0.03, -0.03), true)
	casquete.scale = Vector3(0.95, 1.05, 1.0)
	casquete.rotation.x = -0.15              # algo inclinado hacia atrás: tapa más la nuca que la frente
	piezas.append(casquete)
	match a.peinado:
		"coleta_revuelta":
			# puntas revueltas en la coronilla y la nuca
			for m in [[Vector3(0, 0.15, -0.04), Vector3(0, 0.7, -0.7), 0.15],
					[Vector3(0.08, 0.13, -0.03), Vector3(0.6, 0.6, -0.5), 0.14],
					[Vector3(-0.08, 0.13, -0.03), Vector3(-0.6, 0.6, -0.5), 0.14],
					[Vector3(0.11, 0.05, -0.09), Vector3(0.8, 0.1, -0.6), 0.12],
					[Vector3(-0.11, 0.05, -0.09), Vector3(-0.8, 0.1, -0.6), 0.12],
					[Vector3(0.02, 0.14, 0.07), Vector3(0.1, 0.9, 0.45), 0.11]]:
				piezas.append(_mechon(cabeza, m[0], m[1], m[2], 0.055, pelo))
			# flequillo (deja libre la ceja de la cicatriz)
			for m in [[Vector3(-0.07, 0.13, 0.1), Vector3(-0.2, -0.8, 0.55)],
					[Vector3(-0.02, 0.14, 0.11), Vector3(0.05, -0.85, 0.5)],
					[Vector3(0.03, 0.135, 0.11), Vector3(0.25, -0.85, 0.45)]]:
				piezas.append(_mechon(cabeza, m[0], m[1], 0.11, 0.04, pelo))
			# patillas largas a los lados de la cara: tapan la redondez de las mejillas
			for lado in [-1.0, 1.0]:
				piezas.append(_mechon(cabeza, Vector3(0.135 * lado, 0.07, 0.04), Vector3(0.12 * lado, -1.0, 0.12), 0.18, 0.045, pelo))
			# coleta: el nudo y tres mechones que caen hacia atrás
			piezas.append(_esfera(cabeza, 0.05, pelo, Vector3(0, 0.08, -0.17)))
			for x in [-0.25, 0.0, 0.25]:
				piezas.append(_mechon(cabeza, Vector3(0, 0.07, -0.19), Vector3(x, -0.55, -0.8), 0.24, 0.05, pelo))
		"coleta_larga":
			# flequillo recto, patillas hasta la barbilla y una coleta alta y larga
			for x in [-0.08, -0.04, 0.0, 0.04]:
				piezas.append(_mechon(cabeza, Vector3(x, 0.135, 0.1), Vector3(x * 1.5, -0.9, 0.45), 0.12, 0.035, pelo))
			for lado in [-1.0, 1.0]:
				piezas.append(_mechon(cabeza, Vector3(0.13 * lado, 0.08, 0.05), Vector3(0.08 * lado, -1.0, 0.1), 0.24, 0.045, pelo))
			piezas.append(_esfera(cabeza, 0.055, pelo, Vector3(0, 0.16, -0.13)))
			for x in [-0.2, 0.0, 0.2]:
				piezas.append(_mechon(cabeza, Vector3(0, 0.15, -0.16), Vector3(x, -0.85, -0.5), 0.46, 0.055, pelo))
		_:
			# Moño de ronin: sin la coronilla afeitada, el pelo recogido en un moño (chonmage) que
			# apunta hacia delante, mechones sueltos sobre la frente, patillas hasta la mandíbula y
			# puntas en la nuca. Con el casquete solo, parecía un casco.
			piezas.append(_esfera(cabeza, 0.042, pelo, Vector3(0, 0.175, -0.07)))
			piezas.append(_mechon(cabeza, Vector3(0, 0.185, -0.06), Vector3(0, 0.3, 0.95), 0.14, 0.032, pelo))
			for m in [[Vector3(0.08, 0.12, -0.04), Vector3(0.5, 0.35, -0.8)],
					[Vector3(-0.08, 0.12, -0.04), Vector3(-0.5, 0.35, -0.8)],
					[Vector3(0.1, 0.07, -0.1), Vector3(0.6, 0.1, -0.8)],
					[Vector3(-0.1, 0.07, -0.1), Vector3(-0.6, 0.1, -0.8)]]:
				piezas.append(_mechon(cabeza, m[0], m[1], 0.08, 0.045, pelo))
			# mechones sueltos: sobre la frente (el veterano, con entradas, no los tiene) y en las sienes
			if a.get("flequillo", true):
				for m in [[Vector3(0.035, 0.13, 0.11), Vector3(0.3, -0.9, 0.35)],
						[Vector3(-0.045, 0.125, 0.11), Vector3(-0.2, -0.92, 0.35)]]:
					piezas.append(_mechon(cabeza, m[0], m[1], 0.1, 0.022, pelo))
			for lado in [-1.0, 1.0]:
				piezas.append(_mechon(cabeza, Vector3(0.115 * lado, 0.1, 0.0), Vector3(0.65 * lado, 0.6, -0.35), 0.065, 0.035, pelo))
			for lado in [-1.0, 1.0]:
				piezas.append(_mechon(cabeza, Vector3(0.138 * lado, 0.07, 0.03), Vector3(0.12 * lado, -1.0, 0.08), 0.16, 0.045, pelo))
			for lado in [-1.0, 0.0, 1.0]:
				piezas.append(_mechon(cabeza, Vector3(0.07 * lado, 0.01, -0.15), Vector3(0.35 * lado, -0.55, -0.75), 0.12, 0.05, pelo))
	_fusionar(cabeza, piezas, pelo)
	if a.barba == "corta":
		# Barba corta del veterano: mechones que bajan por la mandíbula hasta la barbilla. (La de
		# pocos días del curtido va dibujada en su cara, y el bigote del veterano también.)
		var barba: Array = []
		for m in [[Vector3(0, -0.13, 0.055), Vector3(0, -0.8, 0.6), 0.065, 0.05],
				[Vector3(0.045, -0.125, 0.045), Vector3(0.25, -0.9, 0.4), 0.055, 0.042],
				[Vector3(-0.045, -0.125, 0.045), Vector3(-0.25, -0.9, 0.4), 0.055, 0.042],
				[Vector3(0.085, -0.105, 0.03), Vector3(0.4, -0.88, 0.25), 0.05, 0.04],
				[Vector3(-0.085, -0.105, 0.03), Vector3(-0.4, -0.88, 0.25), 0.05, 0.04],
				[Vector3(0.115, -0.07, 0.01), Vector3(0.5, -0.85, 0.1), 0.045, 0.035],
				[Vector3(-0.115, -0.07, 0.01), Vector3(-0.5, -0.85, 0.1), 0.045, 0.035]]:
			barba.append(_mechon(cabeza, m[0], m[1], m[2], m[3], pelo))
		_fusionar(cabeza, barba, pelo, "Barba")


# Cicatriz: dos tramos finos pegados a la cara (la cabeza es una esfera de 0,16 m), de la ceja
# izquierda, por encima de la nariz, a la mejilla derecha.
func _cicatriz(cabeza: Node3D) -> void:
	var puntos := [Vector2(0.064, 0.032), Vector2(0.0, 0.004), Vector2(-0.062, -0.07)]
	var radio := 0.168
	for i in 2:
		var a: Vector2 = puntos[i]
		var b: Vector2 = puntos[i + 1]
		var a3 := _sobre_la_cara(a, radio)
		var b3 := _sobre_la_cara(b, radio)
		var normal := ((a3 + b3) / 2.0).normalized()
		var eje_y := (b3 - a3).normalized()
		var eje_x := eje_y.cross(normal).normalized()
		var eje_z := eje_x.cross(eje_y).normalized()
		var tramo := _detalle(cabeza, Vector3(0.011, a3.distance_to(b3) + 0.008, 0.01), Datos.CICATRIZ, (a3 + b3) / 2.0)
		tramo.basis = Basis(eje_x, eje_y, eje_z)
		tramo.name = "Cicatriz%d" % i


# Punto de la cara (que es una esfera aplastada por CARA) a la altura y anchura dadas.
func _sobre_la_cara(punto: Vector2, radio: float) -> Vector3:
	var x := punto.x / CARA.x
	var y := punto.y / CARA.y
	return Vector3(punto.x, punto.y, CARA.z * sqrt(maxf(0.0, radio * radio - x * x - y * y)))


# Estela del corte: media luna blanca que aparece con el tajo y se apaga. La del tajo es
# vertical (de encima de la cabeza a delante y abajo); la del iai, horizontal (de la
# cadera izquierda hacia la derecha, el desenvaine).
static func crear_estela(cuerpo: Node3D, centro: Vector3, horizontal: bool) -> MeshInstance3D:
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
	# La cara, dibujada: la sombra del sombrero le tapa los ojos y solo se ven dos rendijas claras
	_poner_cara(_esfera(cabeza, 0.15, Datos.PIEL, Vector3.ZERO, false, true), Datos.PIEL, CARAS["soldado"])
	# Protector de cuello (shikoro) bajo el sombrero, abierto por delante, y máscara (menpō) en la
	# mitad de abajo de la cara: la cabeza deja de verse como una bola y el soldado da más miedo.
	var protector := CylinderMesh.new()
	protector.top_radius = 0.15
	protector.bottom_radius = 0.2
	protector.height = 0.17
	protector.radial_segments = 12
	protector.rings = 1
	protector.cap_top = false
	protector.cap_bottom = false
	_pieza(cabeza, protector, Datos.ARMADURA_OSCURA, Vector3(0, -0.01, -0.085))
	_caja(cabeza, Vector3(0.21, 0.09, 0.07), Datos.ARMADURA_OSCURA, Vector3(0, -0.08, 0.11))
	_detalle(cabeza, Vector3(0.12, 0.014, 0.012), Datos.ARMADURA_CLARA, Vector3(0, -0.065, 0.149))
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
	var en_mano: bool = pose in ["ataque", "desenvaine", "remate", "kesa", "gyaku", "giro"]
	var con_yari: bool = pose == "tsuki"
	var con_nodachi: bool = pose in ["barrido", "barrido_giro"]
	espada_mano.visible = en_mano
	empunadura_cinto.visible = not en_mano
	if yari_mano:
		yari_mano.visible = con_yari
		nodachi_mano.visible = con_nodachi
		yari_mano.rotation = Vector3.ZERO
		yari_mano.position = Vector3(0, -0.47, 0)
		nodachi_mano.rotation = Vector3.ZERO
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
			brillo = brillo_estela(info.progreso, 0.35, 0.35)
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
			brillo_iai = brillo_estela(info.progreso, 0.45, 0.32)
		"kesa":
			# Kesa-giri: diagonal de arriba a la derecha hacia abajo a la izquierda.
			var t := clampf((info.progreso - 0.15) / 0.55, 0.0, 1.0)
			hombro_der.rotation = Vector3(lerpf(-2.7, -0.6, ease(t, 0.4)), lerpf(0.7, -0.7, t), 0.0)
			hombro_izq.rotation = Vector3(lerpf(-2.4, -0.8, ease(t, 0.4)), lerpf(0.5, -0.5, t), 0.0)
			torso.rotation = Vector3(lerpf(-0.1, 0.22, t), lerpf(0.35, -0.4, t), 0.0)
			cadera_izq.rotation.x = -0.45
			cadera_der.rotation.x = 0.35
			brillo = brillo_estela(info.progreso, 0.35, 0.35)
		"gyaku":
			# Gyaku-kesa: la diagonal de vuelta, de abajo a la izquierda hacia arriba a la derecha.
			var t := clampf((info.progreso - 0.15) / 0.55, 0.0, 1.0)
			hombro_der.rotation = Vector3(lerpf(-0.5, -2.5, ease(t, 0.4)), lerpf(-0.8, 0.75, t), 0.0)
			hombro_izq.rotation = Vector3(lerpf(-0.7, -2.2, ease(t, 0.4)), lerpf(-0.6, 0.5, t), 0.0)
			torso.rotation = Vector3(lerpf(0.2, -0.1, t), lerpf(-0.45, 0.4, t), 0.0)
			cadera_izq.rotation.x = 0.35
			cadera_der.rotation.x = -0.45
			brillo = brillo_estela(info.progreso, 0.35, 0.35)
		"giro":
			# Iai de luna creciente: una vuelta entera con la hoja extendida.
			var t := clampf((info.progreso - 0.2) / 0.55, 0.0, 1.0)
			hombro_der.rotation = Vector3(-PI / 2.0 + 0.15, -1.25, 0.0)
			espada_mano.rotation = Vector3(PI / 2.0, 0.0, 0.0)
			hombro_izq.rotation = Vector3(-0.3, 0.0, -0.6)
			torso.rotation = Vector3(0.15, -TAU * ease(t, 0.6), 0.0)
			cadera_izq.rotation.x = -0.55
			cadera_der.rotation.x = 0.45
			cuerpo.position.y = -0.06
			brillo_iai = brillo_estela(info.progreso, 0.45, 0.4)
		"tsuki":
			# Estocada de yari: se recoge (anticipación) y extiende los brazos con el cuerpo detrás.
			var t := clampf((info.progreso - 0.25) / 0.2, 0.0, 1.0)
			hombro_der.rotation = Vector3(-PI / 2.0 + 0.25, 0.15, 0.0)
			hombro_izq.rotation = Vector3(-PI / 2.0 + 0.35, -0.2, 0.0)
			yari_mano.rotation = Vector3(PI / 2.0 - 0.25, 0.0, 0.0)
			yari_mano.position = Vector3(0, -0.47, 0) + Vector3(0, 0.0, lerpf(-0.45, 0.35, ease(t, 0.3)))
			torso.rotation = Vector3(lerpf(-0.15, 0.3, t), lerpf(0.3, -0.1, t), 0.0)
			cadera_izq.rotation.x = lerpf(-0.2, -0.65, t)
			cadera_der.rotation.x = lerpf(0.2, 0.5, t)
			brillo = brillo_estela(info.progreso, 0.35, 0.3) * 0.6
		"barrido", "barrido_giro":
			# Nodachi: barrido ancho a dos manos, lento y pesado (el giro da la vuelta entera).
			var t := clampf((info.progreso - 0.3) / 0.45, 0.0, 1.0)
			var giro := TAU * ease(t, 0.6) if pose == "barrido_giro" else 0.0
			hombro_der.rotation = Vector3(-PI / 2.0 + 0.2, lerpf(1.45, -1.5, ease(t, 0.35)), 0.0)
			hombro_izq.rotation = Vector3(-PI / 2.0 + 0.3, lerpf(1.25, -1.3, ease(t, 0.35)), 0.0)
			nodachi_mano.rotation = Vector3(PI / 2.0, 0.0, 0.0)
			torso.rotation = Vector3(0.18, lerpf(0.65, -0.7, t) - giro, 0.0)
			cadera_izq.rotation.x = -0.6
			cadera_der.rotation.x = 0.5
			cuerpo.position.y = -0.07
			brillo = brillo_estela(info.progreso, 0.5, 0.35)
		"esquiva":
			# Paso rápido agachado: el cuerpo bajo y adelantado, los brazos atrás.
			var t := sin(clampf(info.progreso, 0.0, 1.0) * PI)
			cuerpo.position.y = -0.22 * t
			torso.rotation = Vector3(0.55 * t, 0.0, 0.0)
			cadera_izq.rotation.x = -0.9 * t
			cadera_der.rotation.x = 0.6 * t
			hombro_der.rotation = Vector3(0.6 * t, 0.0, 0.2)
			hombro_izq.rotation = Vector3(0.6 * t, 0.0, -0.2)
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
static func brillo_estela(progreso: float, centro: float, ancho: float) -> float:
	var valor := clampf(1.0 - absf(progreso - centro) / ancho, 0.0, 1.0)
	if estilo_anime:
		return 1.0 if valor > 0.25 else 0.0
	return valor
