# Mallas hechas por código para los prototipos: cajas con los cantos biselados (la luz brilla en
# el bisel y la madera parece madera), anillos, prismas extruidos, piezas de torno y engranajes.
# Las coordenadas de textura van en metros: el material decide cuántas veces se repite por metro.
class_name Geometria
extends RefCounted


# --- Caja con bisel ----------------------------------------------------------------------------

static func caja(tamano: Vector3, bisel := 0.0) -> ArrayMesh:
	var h := tamano / 2.0
	var b := clampf(bisel, 0.0, minf(h.x, minf(h.y, h.z)) * 0.95)
	var i := h - Vector3.ONE * b
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for eje in 3:
		var u := (eje + 1) % 3
		var v := (eje + 2) % 3
		for signo in [-1.0, 1.0]:
			var normal := Vector3.ZERO
			normal[eje] = signo
			var esquinas: Array = []
			for par in [[-1.0, -1.0], [1.0, -1.0], [1.0, 1.0], [-1.0, 1.0]]:
				var punto := Vector3.ZERO
				punto[eje] = signo * h[eje]
				punto[u] = par[0] * i[u]
				punto[v] = par[1] * i[v]
				esquinas.append(punto)
			_poligono(st, esquinas, normal)
	if b > 0.0:
		for a in 3:
			for c in range(a + 1, 3):
				var t := 3 - a - c
				var largo := Vector3.ZERO
				largo[t] = i[t]
				for sa in [-1.0, 1.0]:
					for sc in [-1.0, 1.0]:
						var normal := Vector3.ZERO
						normal[a] = sa
						normal[c] = sc
						var p1 := Vector3.ZERO
						p1[a] = sa * h[a]
						p1[c] = sc * i[c]
						var p2 := Vector3.ZERO
						p2[a] = sa * i[a]
						p2[c] = sc * h[c]
						_poligono(st, [p1 - largo, p1 + largo, p2 + largo, p2 - largo], normal.normalized())
		for sx in [-1.0, 1.0]:
			for sy in [-1.0, 1.0]:
				for sz in [-1.0, 1.0]:
					_poligono(st, [Vector3(sx * h.x, sy * i.y, sz * i.z), Vector3(sx * i.x, sy * h.y, sz * i.z),
						Vector3(sx * i.x, sy * i.y, sz * h.z)], Vector3(sx, sy, sz).normalized())
	st.generate_tangents()
	return st.commit()


# --- Anillo (o un trozo de anillo), plano en XZ y con el eje en Y ------------------------------

static func anillo(radio_interior: float, radio_exterior: float, alto: float, desde := 0.0, hasta := TAU,
		segmentos := 64) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := maxi(2, int(ceil(segmentos * (hasta - desde) / TAU)))
	var arriba := Vector3.UP * alto / 2.0
	for k in n:
		var a0 := lerpf(desde, hasta, float(k) / n)
		var a1 := lerpf(desde, hasta, float(k + 1) / n)
		var d0 := Vector3(cos(a0), 0.0, sin(a0))
		var d1 := Vector3(cos(a1), 0.0, sin(a1))
		_poligono(st, [d0 * radio_interior + arriba, d0 * radio_exterior + arriba, d1 * radio_exterior + arriba,
			d1 * radio_interior + arriba], Vector3.UP)
		_poligono(st, [d0 * radio_interior - arriba, d0 * radio_exterior - arriba, d1 * radio_exterior - arriba,
			d1 * radio_interior - arriba], Vector3.DOWN)
		_cuadro_suave(st, d0 * radio_exterior - arriba, d1 * radio_exterior - arriba, d1 * radio_exterior + arriba,
			d0 * radio_exterior + arriba, d0, d1, Vector2(a0 * radio_exterior, alto / 2.0), Vector2(a1 * radio_exterior, -alto / 2.0))
		_cuadro_suave(st, d0 * radio_interior - arriba, d1 * radio_interior - arriba, d1 * radio_interior + arriba,
			d0 * radio_interior + arriba, -d0, -d1, Vector2(a0 * radio_interior, alto / 2.0), Vector2(a1 * radio_interior, -alto / 2.0))
	if hasta - desde < TAU - 0.0001:
		for extremo in [[desde, -1.0], [hasta, 1.0]]:
			var a: float = extremo[0]
			var d := Vector3(cos(a), 0.0, sin(a))
			var normal := Vector3(-sin(a), 0.0, cos(a)) * float(extremo[1])
			_poligono(st, [d * radio_interior - arriba, d * radio_exterior - arriba, d * radio_exterior + arriba,
				d * radio_interior + arriba], normal)
	st.generate_tangents()
	return st.commit()


# --- Prisma: un contorno en XY (en sentido antihorario) con grosor en Z ------------------------

static func extruir(contorno: PackedVector2Array, grosor: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var z := grosor / 2.0
	var indices := Geometry2D.triangulate_polygon(contorno)
	for k in range(0, indices.size(), 3):
		var a := contorno[indices[k]]
		var b := contorno[indices[k + 1]]
		var c := contorno[indices[k + 2]]
		_poligono(st, [Vector3(a.x, a.y, z), Vector3(b.x, b.y, z), Vector3(c.x, c.y, z)], Vector3.BACK)
		_poligono(st, [Vector3(a.x, a.y, -z), Vector3(b.x, b.y, -z), Vector3(c.x, c.y, -z)], Vector3.FORWARD)
	var horario := _area(contorno) < 0.0
	for k in contorno.size():
		var p := contorno[k]
		var q := contorno[(k + 1) % contorno.size()]
		var lado := q - p
		var fuera := Vector3(lado.y, -lado.x, 0.0).normalized()
		if horario:
			fuera = -fuera
		_poligono(st, [Vector3(p.x, p.y, -z), Vector3(q.x, q.y, -z), Vector3(q.x, q.y, z), Vector3(p.x, p.y, z)], fuera)
	st.generate_tangents()
	return st.commit()


static func _area(contorno: PackedVector2Array) -> float:
	var suma := 0.0
	for k in contorno.size():
		var p := contorno[k]
		var q := contorno[(k + 1) % contorno.size()]
		suma += p.x * q.y - q.x * p.y
	return suma / 2.0


# --- Torno: un perfil (radio, altura) de abajo arriba que gira alrededor de Y ------------------

static func torno(perfil: PackedVector2Array, lados := 32) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var recorrido := 0.0
	for j in perfil.size() - 1:
		var p := perfil[j]
		var q := perfil[j + 1]
		var tramo := q - p
		if tramo.length() < 0.00001:
			continue
		var normal_2d := Vector2(tramo.y, -tramo.x).normalized()
		for k in lados:
			var a0 := TAU * k / lados
			var a1 := TAU * (k + 1) / lados
			var d0 := Vector3(cos(a0), 0.0, sin(a0))
			var d1 := Vector3(cos(a1), 0.0, sin(a1))
			var n0 := (d0 * normal_2d.x + Vector3.UP * normal_2d.y).normalized()
			var n1 := (d1 * normal_2d.x + Vector3.UP * normal_2d.y).normalized()
			var v0 := Vector2(a0 * 0.05, -recorrido)
			var v1 := Vector2(a1 * 0.05, -recorrido - tramo.length())
			_cuadro_suave(st, d0 * p.x + Vector3.UP * p.y, d1 * p.x + Vector3.UP * p.y, d1 * q.x + Vector3.UP * q.y,
				d0 * q.x + Vector3.UP * q.y, n0, n1, v0, v1)
		recorrido += tramo.length()
	st.generate_tangents()
	return st.commit()


# --- Engranaje plano en XY (eje en Z) ------------------------------------------------------------

static func engranaje(radio: float, dientes: int, grosor: float, profundidad := 0.16) -> ArrayMesh:
	var contorno := PackedVector2Array()
	var raiz := radio * (1.0 - profundidad)
	var paso := TAU / dientes
	for k in dientes:
		var a := k * paso
		for parte in [[0.0, raiz], [0.18, raiz], [0.3, radio], [0.58, radio], [0.7, raiz]]:
			var angulo: float = a + float(parte[0]) * paso
			contorno.append(Vector2(cos(angulo), sin(angulo)) * float(parte[1]))
	return extruir(contorno, grosor)


# Cinta plana que sigue una curva (surcos de luz): UV.x va de 0 a 1 a lo largo, UV.y a lo ancho
static func cinta(puntos: PackedVector3Array, ancho: float, normal := Vector3.BACK) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var largo := 0.0
	var acumulado: Array = [0.0]
	for k in range(1, puntos.size()):
		largo += puntos[k].distance_to(puntos[k - 1])
		acumulado.append(largo)
	var bordes: Array = []
	for k in puntos.size():
		var antes := puntos[maxi(0, k - 1)]
		var despues := puntos[mini(puntos.size() - 1, k + 1)]
		var lado := normal.cross(despues - antes).normalized() * ancho / 2.0
		bordes.append([puntos[k] - lado, puntos[k] + lado, float(acumulado[k]) / maxf(largo, 0.0001)])
	for k in puntos.size() - 1:
		var a: Array = bordes[k]
		var b: Array = bordes[k + 1]
		for triangulo in [[[a[0], a[2], 0.0], [b[0], b[2], 0.0], [b[1], b[2], 1.0]], [[a[0], a[2], 0.0], [b[1], b[2], 1.0], [a[1], a[2], 1.0]]]:
			var p0: Vector3 = triangulo[0][0]
			var p1: Vector3 = triangulo[1][0]
			var p2: Vector3 = triangulo[2][0]
			var orden := [0, 1, 2] if (p1 - p0).cross(p2 - p0).dot(normal) <= 0.0 else [0, 2, 1]
			for i in orden:
				st.set_normal(normal)
				st.set_uv(Vector2(triangulo[i][1], triangulo[i][2]))
				st.add_vertex(triangulo[i][0])
	return st.commit()


# Polígono regular en XY (para extruir): círculos, hexágonos…
static func poligono_regular(radio: float, lados: int, giro := 0.0) -> PackedVector2Array:
	var puntos := PackedVector2Array()
	for k in lados:
		var a := giro + TAU * k / lados
		puntos.append(Vector2(cos(a), sin(a)) * radio)
	return puntos


# --- Ayudas internas ----------------------------------------------------------------------------

# Coordenadas de textura proyectando sobre el plano que más mira la cara
static func _uv(punto: Vector3, normal: Vector3) -> Vector2:
	var a := normal.abs()
	if a.x >= a.y and a.x >= a.z:
		return Vector2(punto.z * (-1.0 if normal.x >= 0.0 else 1.0), -punto.y)
	if a.y >= a.z:
		return Vector2(punto.x, punto.z * (1.0 if normal.y >= 0.0 else -1.0))
	return Vector2(punto.x * (1.0 if normal.z >= 0.0 else -1.0), -punto.y)


# Polígono convexo plano, en abanico. Godot dibuja la cara delantera en sentido horario.
static func _poligono(st: SurfaceTool, puntos: Array, normal: Vector3) -> void:
	for k in range(1, puntos.size() - 1):
		var a: Vector3 = puntos[0]
		var b: Vector3 = puntos[k]
		var c: Vector3 = puntos[k + 1]
		if (b - a).cross(c - a).dot(normal) > 0.0:
			var cambio := b
			b = c
			c = cambio
		for punto in [a, b, c]:
			st.set_normal(normal)
			st.set_uv(_uv(punto, normal))
			st.add_vertex(punto)


# Cuadrilátero con normales suaves a lo ancho (paredes de anillos y piezas de torno)
static func _cuadro_suave(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3,
		normal_ad: Vector3, normal_bc: Vector3, uv_a: Vector2, uv_c: Vector2) -> void:
	var vertices := [[a, normal_ad, uv_a], [b, normal_bc, Vector2(uv_c.x, uv_a.y)],
		[c, normal_bc, uv_c], [d, normal_ad, Vector2(uv_a.x, uv_c.y)]]
	var media := (normal_ad + normal_bc).normalized()
	for triangulo in [[0, 1, 2], [0, 2, 3]]:
		var orden: Array = triangulo.duplicate()
		var pa: Vector3 = vertices[orden[0]][0]
		var pb: Vector3 = vertices[orden[1]][0]
		var pc: Vector3 = vertices[orden[2]][0]
		if (pb - pa).cross(pc - pa).dot(media) > 0.0:
			orden = [orden[0], orden[2], orden[1]]
		for indice in orden:
			st.set_normal(vertices[indice][1])
			st.set_uv(vertices[indice][2])
			st.add_vertex(vertices[indice][0])


# Nodo con una malla y su material
static func pieza(malla: Mesh, material: Material, posicion := Vector3.ZERO, padre: Node3D = null) -> MeshInstance3D:
	var instancia := MeshInstance3D.new()
	instancia.mesh = malla
	instancia.material_override = material
	instancia.position = posicion
	if padre:
		padre.add_child(instancia)
	return instancia
