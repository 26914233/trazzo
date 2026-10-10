# Piezas de arquitectura y mobiliario hechas por código, para las habitaciones de las cajas y el
# gabinete del menú: paredes con huecos (puertas, ventanas) y su grosor, paredes curvas, suelos,
# puertas con bisagra, estanterías con libros, relojes de pared, cuadros…
# Nada de esto lleva forma de choque: los toques y el doble toque solo encuentran el puzle.
# Las coordenadas de textura van en metros y siguen la pared, así que el papel pintado o el yeso
# continúan sin cortes alrededor de los huecos.
class_name Arquitectura
extends RefCounted


# Losa sin choque ni sombra (suelos, techos, molduras). Las luces están dentro de las habitaciones,
# así que la arquitectura no necesita proyectar sombras: se ahorra mucho en el móvil.
static func losa(desde: Vector3, hasta: Vector3, material: Material, padre: Node3D, bisel := 0.0) -> MeshInstance3D:
	var malla := Escena.bloque(desde, hasta, material, padre, bisel, false)
	malla.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return malla


# Pared recta vista desde dentro de la habitación. «inicio»: esquina de abajo de la cara interior;
# «direccion»: hacia dónde corre la pared (horizontal); «hacia_dentro»: normal de la cara interior.
# «huecos»: [[desde, hasta, abajo, arriba], …] en metros a lo largo de la pared y en altura.
static func pared(inicio: Vector3, direccion: Vector3, largo: float, alto: float, hacia_dentro: Vector3,
		material: Material, padre: Node3D, huecos := [], grosor := 0.12) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var marco := [inicio, direccion.normalized(), hacia_dentro.normalized()]
	var d: Vector3 = marco[1]
	var lista: Array = huecos.duplicate()
	lista.sort_custom(func(a, b): return a[0] < b[0])
	var cursor := 0.0
	for hueco in lista:
		var a: float = hueco[0]
		var b: float = hueco[1]
		var abajo: float = hueco[2]
		var arriba: float = hueco[3]
		_cara_pared(st, marco, cursor, a, 0.0, alto)
		_cara_pared(st, marco, a, b, 0.0, abajo)
		_cara_pared(st, marco, a, b, arriba, alto)
		# jambas: el grosor de la pared en los bordes del hueco
		_cuadro(st, _en_pared(marco, a, abajo, 0.0), _en_pared(marco, a, abajo, grosor), _en_pared(marco, a, arriba, grosor),
			_en_pared(marco, a, arriba, 0.0), d, Vector2(0.0, -abajo), Vector2(grosor, -arriba))
		_cuadro(st, _en_pared(marco, b, abajo, grosor), _en_pared(marco, b, abajo, 0.0), _en_pared(marco, b, arriba, 0.0),
			_en_pared(marco, b, arriba, grosor), -d, Vector2(0.0, -abajo), Vector2(grosor, -arriba))
		if arriba < alto - 0.001:
			_cuadro(st, _en_pared(marco, a, arriba, 0.0), _en_pared(marco, a, arriba, grosor), _en_pared(marco, b, arriba, grosor),
				_en_pared(marco, b, arriba, 0.0), Vector3.DOWN, Vector2(a, 0.0), Vector2(b, grosor))
		if abajo > 0.001:
			_cuadro(st, _en_pared(marco, a, abajo, grosor), _en_pared(marco, a, abajo, 0.0), _en_pared(marco, b, abajo, 0.0),
				_en_pared(marco, b, abajo, grosor), Vector3.UP, Vector2(a, 0.0), Vector2(b, grosor))
		cursor = b
	_cara_pared(st, marco, cursor, largo, 0.0, alto)
	st.generate_tangents()
	var instancia := MeshInstance3D.new()
	instancia.mesh = st.commit()
	instancia.material_override = material
	instancia.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	padre.add_child(instancia)
	return instancia


# Un punto de la pared: «s» a lo largo, «y» de altura y «fondo» hacia fuera desde la cara interior
static func _en_pared(marco: Array, s: float, y: float, fondo: float) -> Vector3:
	return (marco[0] as Vector3) + (marco[1] as Vector3) * s + Vector3.UP * y - (marco[2] as Vector3) * fondo


static func _cara_pared(st: SurfaceTool, marco: Array, s0: float, s1: float, y0: float, y1: float) -> void:
	if s1 - s0 < 0.0005 or y1 - y0 < 0.0005:
		return
	_cuadro(st, _en_pared(marco, s0, y0, 0.0), _en_pared(marco, s1, y0, 0.0), _en_pared(marco, s1, y1, 0.0),
		_en_pared(marco, s0, y1, 0.0), marco[2], Vector2(s0, -y0), Vector2(s1, -y1))


# Pared curva (habitaciones redondas) vista desde dentro, con un hueco opcional para la puerta.
# «hueco»: [ángulo del centro, ancho en metros, alto]. El ángulo 0 mira a +X y PI/2 a +Z.
static func pared_curva(centro: Vector3, radio: float, alto: float, material: Material, padre: Node3D,
		hueco := [], segmentos := 48, grosor := 0.25) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var medio := 0.0
	var mitad := -1.0
	var alto_hueco := 0.0
	if hueco.size() == 3:
		medio = hueco[0]
		mitad = float(hueco[1]) / 2.0 / radio
		alto_hueco = hueco[2]
	var cortes: Array = []
	for k in segmentos + 1:
		cortes.append(TAU * k / segmentos)
	if mitad > 0.0:
		# los bordes del hueco son cortes exactos
		cortes.append(wrapf(medio - mitad, 0.0, TAU))
		cortes.append(wrapf(medio + mitad, 0.0, TAU))
		cortes.sort()
	for k in cortes.size() - 1:
		var a0: float = cortes[k]
		var a1: float = cortes[k + 1]
		if a1 - a0 < 0.0001:
			continue
		var centro_tramo := (a0 + a1) / 2.0
		var en_hueco := mitad > 0.0 and absf(wrapf(centro_tramo - medio, -PI, PI)) < mitad
		var y0 := alto_hueco if en_hueco else 0.0
		var n0 := -Vector3(cos(a0), 0.0, sin(a0))
		var n1 := -Vector3(cos(a1), 0.0, sin(a1))
		Geometria._cuadro_suave(st, _en_circulo(centro, a0, y0, radio), _en_circulo(centro, a1, y0, radio),
			_en_circulo(centro, a1, alto, radio), _en_circulo(centro, a0, alto, radio), n0, n1,
			Vector2(a0 * radio, -y0), Vector2(a1 * radio, -alto))
		if en_hueco:
			# dintel: la cara de abajo del hueco, con el grosor de la pared
			_cuadro(st, _en_circulo(centro, a0, alto_hueco, radio), _en_circulo(centro, a1, alto_hueco, radio),
				_en_circulo(centro, a1, alto_hueco, radio + grosor), _en_circulo(centro, a0, alto_hueco, radio + grosor),
				Vector3.DOWN, Vector2(a0 * radio, 0.0), Vector2(a1 * radio, grosor))
	if mitad > 0.0:
		for borde in [[medio - mitad, 1.0], [medio + mitad, -1.0]]:
			var a: float = borde[0]
			var tangente := Vector3(-sin(a), 0.0, cos(a)) * float(borde[1])
			_cuadro(st, _en_circulo(centro, a, 0.0, radio), _en_circulo(centro, a, 0.0, radio + grosor),
				_en_circulo(centro, a, alto_hueco, radio + grosor), _en_circulo(centro, a, alto_hueco, radio), tangente,
				Vector2(0.0, 0.0), Vector2(grosor, -alto_hueco))
	st.generate_tangents()
	var instancia := MeshInstance3D.new()
	instancia.mesh = st.commit()
	instancia.material_override = material
	instancia.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	padre.add_child(instancia)
	return instancia


static func _en_circulo(centro: Vector3, angulo: float, y: float, radio: float) -> Vector3:
	return centro + Vector3(cos(angulo) * radio, y, sin(angulo) * radio)


# Cúpula vista desde dentro, con un óculo (agujero) arriba por donde se ve el cielo
static func cupula(centro: Vector3, radio: float, alto: float, radio_oculo: float, material: Material, padre: Node3D,
		lados := 40) -> MeshInstance3D:
	var perfil := PackedVector2Array()
	var pasos := 14
	var inicio := asin(clampf(radio_oculo / radio, 0.0, 1.0))
	for k in pasos + 1:
		# de arriba (borde del óculo) hacia abajo: las caras miran hacia dentro
		var t := lerpf(inicio, PI / 2.0, float(k) / pasos)
		perfil.append(Vector2(sin(t) * radio, cos(t) * alto))
	var malla := Geometria.torno(perfil, lados)
	var instancia := Geometria.pieza(malla, material, centro, padre)
	instancia.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return instancia


# Puerta con bisagra: devuelve el nodo de la bisagra (girarlo en Y abre la puerta). La hoja va de
# la bisagra hacia +X local, de «ancho» por «alto», con un tirador.
static func puerta(padre: Node3D, bisagra: Vector3, ancho: float, alto: float, material: Material,
		material_tirador: Material, giro := 0.0) -> Node3D:
	var nodo := Escena.grupo(padre, bisagra, "Puerta")
	nodo.rotation.y = giro
	Escena.bloque(Vector3(0.005, 0.0, -0.025), Vector3(ancho - 0.005, alto, 0.025), material, nodo, 0.006, false)
	# cuarterones: cuatro paneles en relieve por cada cara
	for fila in 2:
		for columna in 2:
			var x0 := 0.08 + columna * (ancho - 0.16) / 2.0 + 0.03
			var x1 := 0.08 + (columna + 1) * (ancho - 0.16) / 2.0 - 0.03
			var y0 := 0.12 + fila * (alto - 0.24) / 2.0 + 0.04
			var y1 := 0.12 + (fila + 1) * (alto - 0.24) / 2.0 - 0.04
			Escena.bloque(Vector3(x0, y0, 0.024), Vector3(x1, y1, 0.034), material, nodo, 0.006, false)
			Escena.bloque(Vector3(x0, y0, -0.034), Vector3(x1, y1, -0.024), material, nodo, 0.006, false)
	for lado in [1.0, -1.0]:
		var pomo := SphereMesh.new()
		pomo.radius = 0.028
		pomo.height = 0.056
		Geometria.pieza(pomo, material_tirador, Vector3(ancho - 0.09, 1.0, 0.06 * lado), nodo)
	return nodo


# Estante de libros: fila de lomos de colores entre «desde_x» y «hasta_x», sobre la altura «y»
static func libros(padre: Node3D, desde_x: float, hasta_x: float, y: float, z: float, fondo: float,
		semilla: int, alto_minimo := 0.2, alto_maximo := 0.3) -> void:
	var azar := RandomNumberGenerator.new()
	azar.seed = semilla
	var colores := [Color(0.35, 0.08, 0.06), Color(0.1, 0.16, 0.3), Color(0.12, 0.25, 0.12), Color(0.4, 0.3, 0.12),
		Color(0.25, 0.1, 0.2), Color(0.5, 0.42, 0.3), Color(0.18, 0.12, 0.08)]
	var x := desde_x
	while x < hasta_x - 0.03:
		var ancho := azar.randf_range(0.025, 0.06)
		if x + ancho > hasta_x:
			break
		var alto := azar.randf_range(alto_minimo, alto_maximo)
		var color: Color = colores[azar.randi() % colores.size()]
		var inclinado := azar.randf() < 0.06
		var libro := Escena.bloque(Vector3(-ancho / 2.0, 0.0, -fondo / 2.0), Vector3(ancho / 2.0, alto, fondo / 2.0),
			Materiales.liso(color.darkened(azar.randf_range(0.0, 0.3)), 0.75), padre, 0.003, false)
		libro.position += Vector3(x + ancho / 2.0, y, z)
		if inclinado:
			libro.rotation.z = -0.25
		x += ancho + azar.randf_range(0.0, 0.006)
		if azar.randf() < 0.08:
			x += azar.randf_range(0.04, 0.12)


# Reloj de pared o de repisa: esfera de esmalte con bisel de latón y agujas a una hora dada
static func reloj(padre: Node3D, posicion: Vector3, radio: float, hora: float, minutos: float, giro_y := 0.0) -> Node3D:
	var nodo := Escena.grupo(padre, posicion, "Reloj")
	nodo.rotation.y = giro_y
	var caja := CylinderMesh.new()
	caja.top_radius = radio * 1.12
	caja.bottom_radius = radio * 1.18
	caja.height = radio * 0.25
	var cuerpo := Geometria.pieza(caja, Materiales.con_textura("madera_oscura", 6.0, 0.45), Vector3.ZERO, nodo)
	cuerpo.rotation.x = PI / 2.0
	var aro := TorusMesh.new()
	aro.inner_radius = radio * 0.98
	aro.outer_radius = radio * 1.1
	var bisel := Geometria.pieza(aro, Materiales.laton(0.3), Vector3(0.0, 0.0, radio * 0.13), nodo)
	bisel.rotation.x = PI / 2.0
	bisel.scale = Vector3(1.0, 0.5, 1.0)
	var esfera := QuadMesh.new()
	esfera.size = Vector2.ONE * radio * 2.0
	var material := StandardMaterial3D.new()
	material.albedo_texture = Materiales.textura("esfera_reloj")
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.roughness = 0.35
	Geometria.pieza(esfera, material, Vector3(0.0, 0.0, radio * 0.13), nodo)
	var acero := Materiales.liso(Color(0.05, 0.06, 0.1), 0.3, 0.6)
	for datos in [[(hora + minutos / 60.0) / 12.0, radio * 0.5, radio * 0.07], [minutos / 60.0, radio * 0.78, radio * 0.045]]:
		var aguja := Escena.grupo(nodo, Vector3(0.0, 0.0, radio * 0.15), "Aguja")
		aguja.rotation.z = -TAU * float(datos[0])
		Geometria.pieza(Geometria.caja(Vector3(float(datos[2]), float(datos[1]), radio * 0.02), 0.0), acero,
			Vector3(0.0, float(datos[1]) / 2.0 - float(datos[1]) * 0.12, 0.0), aguja)
	return nodo


# Cuadro con marco dorado: una textura (o un color) dentro de un marco
static func cuadro(padre: Node3D, posicion: Vector3, tamano: Vector2, contenido: Material, giro_y := 0.0) -> Node3D:
	var nodo := Escena.grupo(padre, posicion, "Cuadro")
	nodo.rotation.y = giro_y
	var marco := Materiales.laton(0.45)
	var g := 0.05
	for barra in [[Vector3(-tamano.x / 2.0 - g, -tamano.y / 2.0 - g, 0.0), Vector3(tamano.x / 2.0 + g, -tamano.y / 2.0, 0.04)],
			[Vector3(-tamano.x / 2.0 - g, tamano.y / 2.0, 0.0), Vector3(tamano.x / 2.0 + g, tamano.y / 2.0 + g, 0.04)],
			[Vector3(-tamano.x / 2.0 - g, -tamano.y / 2.0, 0.0), Vector3(-tamano.x / 2.0, tamano.y / 2.0, 0.04)],
			[Vector3(tamano.x / 2.0, -tamano.y / 2.0, 0.0), Vector3(tamano.x / 2.0 + g, tamano.y / 2.0, 0.04)]]:
		Escena.bloque(barra[0], barra[1], marco, nodo, 0.01, false)
	var lienzo := QuadMesh.new()
	lienzo.size = tamano
	Geometria.pieza(lienzo, contenido, Vector3(0.0, 0.0, 0.012), nodo)
	return nodo


# Ventana con marco de madera y cristales (lo de fuera lo pone «paisaje»)
static func ventana(padre: Node3D, posicion: Vector3, tamano: Vector2, madera: Material, paisaje: Material,
		giro_y := 0.0, divisiones := Vector2i(2, 3)) -> Node3D:
	var nodo := Escena.grupo(padre, posicion, "Ventana")
	nodo.rotation.y = giro_y
	var vista := QuadMesh.new()
	vista.size = tamano
	Geometria.pieza(vista, paisaje, Vector3(0.0, 0.0, -0.02), nodo)
	var g := 0.05
	var w := tamano.x / 2.0
	var h := tamano.y / 2.0
	for barra in [[Vector3(-w - g, -h - g, -0.03), Vector3(w + g, -h, 0.05)], [Vector3(-w - g, h, -0.03), Vector3(w + g, h + g, 0.05)],
			[Vector3(-w - g, -h, -0.03), Vector3(-w, h, 0.05)], [Vector3(w, -h, -0.03), Vector3(w + g, h, 0.05)]]:
		Escena.bloque(barra[0], barra[1], madera, nodo, 0.006, false)
	for i in range(1, divisiones.x):
		var x := lerpf(-w, w, float(i) / divisiones.x)
		Escena.bloque(Vector3(x - 0.015, -h, -0.02), Vector3(x + 0.015, h, 0.02), madera, nodo, 0.004, false)
	for j in range(1, divisiones.y):
		var y := lerpf(-h, h, float(j) / divisiones.y)
		Escena.bloque(Vector3(-w, y - 0.015, -0.02), Vector3(w, y + 0.015, 0.02), madera, nodo, 0.004, false)
	Escena.bloque(Vector3(-w - 0.09, -h - 0.1, -0.03), Vector3(w + 0.09, -h - g, 0.16), madera, nodo, 0.008, false)
	return nodo


# Cuadrilátero plano con coordenadas de textura dadas por sus esquinas opuestas
static func _cuadro(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, normal: Vector3,
		uv_a: Vector2, uv_c: Vector2) -> void:
	var vertices := [[a, uv_a], [b, Vector2(uv_c.x, uv_a.y)], [c, uv_c], [d, Vector2(uv_a.x, uv_c.y)]]
	for triangulo in [[0, 1, 2], [0, 2, 3]]:
		var orden: Array = triangulo.duplicate()
		var pa: Vector3 = vertices[orden[0]][0]
		var pb: Vector3 = vertices[orden[1]][0]
		var pc: Vector3 = vertices[orden[2]][0]
		if (pb - pa).cross(pc - pa).dot(normal) > 0.0:
			orden = [orden[0], orden[2], orden[1]]
		for indice in orden:
			st.set_normal(normal)
			st.set_uv(vertices[indice][1])
			st.add_vertex(vertices[indice][0])
