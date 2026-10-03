# Monedas «mon»: de cobre y con agujero cuadrado, como las del periodo Edo. Saltan al
# soltarse, giran de canto en el suelo, Akira las recoge al pasar (y las atrae desde un poco
# más lejos) y Shiro trae las que se quedan atrás.
extends Node3D

const Datos := preload("res://scripts/datos.gd")

signal recogidas(cantidad: int, punto: Vector3)

var akira                              # lo pone el juego
var monedas: Array = []                # cada una: {nodo, velocidad, en_suelo, suelo, edad, reservada}
var malla: ArrayMesh
var material: Material
var azar := RandomNumberGenerator.new()
var soltadas := 0                      # totales (los usa la prueba)
var recogidas_total := 0


func configurar(aspecto_del_juego, akira_del_juego) -> void:
	akira = akira_del_juego
	azar.seed = 11
	malla = crear_malla_moneda()
	material = aspecto_del_juego.material_emisivo(Datos.COBRE, 0.45)


# Moneda de canto: las caras miran a ±Z y gira sobre el eje Y del mundo. Una sola malla, sin
# texturas: el agujero cuadrado es geometría (Godot dibuja la cara delantera en sentido horario).
static func crear_malla_moneda(radio := 0.12, grueso := 0.026, medio_agujero := 0.034) -> ArrayMesh:
	var herramienta := SurfaceTool.new()
	herramienta.begin(Mesh.PRIMITIVE_TRIANGLES)
	var lados := 32                    # múltiplo de 8: las esquinas del agujero caen en un vértice
	var fuera: Array = []
	var dentro: Array = []
	for i in lados + 1:
		var angulo := TAU * i / lados
		var direccion := Vector2(cos(angulo), sin(angulo))
		fuera.append(direccion * radio)
		dentro.append(direccion / maxf(absf(direccion.x), absf(direccion.y)) * medio_agujero)
	var z := grueso / 2.0
	for i in lados:
		var a: Vector2 = fuera[i]
		var b: Vector2 = fuera[i + 1]
		var c: Vector2 = dentro[i + 1]
		var d: Vector2 = dentro[i]
		# cara de delante (+Z) y de detrás (−Z)
		_triangulo(herramienta, Vector3(0, 0, 1), [Vector3(a.x, a.y, z), Vector3(d.x, d.y, z), Vector3(b.x, b.y, z)])
		_triangulo(herramienta, Vector3(0, 0, 1), [Vector3(b.x, b.y, z), Vector3(d.x, d.y, z), Vector3(c.x, c.y, z)])
		_triangulo(herramienta, Vector3(0, 0, -1), [Vector3(a.x, a.y, -z), Vector3(b.x, b.y, -z), Vector3(d.x, d.y, -z)])
		_triangulo(herramienta, Vector3(0, 0, -1), [Vector3(b.x, b.y, -z), Vector3(c.x, c.y, -z), Vector3(d.x, d.y, -z)])
		# canto exterior
		var normal_a := Vector3(a.x, a.y, 0).normalized()
		var normal_b := Vector3(b.x, b.y, 0).normalized()
		_cuadrilatero(herramienta, [Vector3(a.x, a.y, z), Vector3(b.x, b.y, z), Vector3(b.x, b.y, -z), Vector3(a.x, a.y, -z)],
			[normal_a, normal_b, normal_b, normal_a])
		# paredes del agujero (miran hacia el centro)
		var normal_d := -Vector3(d.x, d.y, 0).normalized()
		var normal_c := -Vector3(c.x, c.y, 0).normalized()
		_cuadrilatero(herramienta, [Vector3(d.x, d.y, z), Vector3(d.x, d.y, -z), Vector3(c.x, c.y, -z), Vector3(c.x, c.y, z)],
			[normal_d, normal_d, normal_c, normal_c])
	return herramienta.commit()


static func _triangulo(herramienta: SurfaceTool, normal: Vector3, puntos: Array) -> void:
	for punto in puntos:
		herramienta.set_normal(normal)
		herramienta.add_vertex(punto)


static func _cuadrilatero(herramienta: SurfaceTool, puntos: Array, normales: Array) -> void:
	for i in [0, 1, 2, 0, 2, 3]:
		herramienta.set_normal(normales[i])
		herramienta.add_vertex(puntos[i])


# Suelta «cantidad» monedas que saltan desde «punto» en todas direcciones.
func soltar(punto: Vector3, cantidad: int, altura := 1.0) -> void:
	for i in cantidad:
		var nodo := MeshInstance3D.new()
		nodo.mesh = malla
		nodo.material_override = material
		nodo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(nodo)
		nodo.global_position = punto
		nodo.rotation.y = azar.randf() * TAU
		var angulo := TAU * (i + azar.randf() * 0.6) / cantidad
		var rapidez := azar.randf_range(1.0, 2.2)
		monedas.append({
			"nodo": nodo,
			"velocidad": Vector3(cos(angulo) * rapidez, azar.randf_range(3.5, 5.0) * altura, sin(angulo) * rapidez),
			"en_suelo": false,
			"suelo": 0.0,
			"edad": 0.0,
			"reservada": false,
		})
	soltadas += cantidad


func _physics_process(delta: float) -> void:
	if monedas.is_empty():
		return
	var espacio := get_world_3d().direct_space_state
	var centro_akira: Vector3 = akira.global_position + Vector3.UP * 0.7 if akira else Vector3.INF
	for moneda in monedas.duplicate():
		var nodo: MeshInstance3D = moneda.nodo
		moneda.edad += delta
		nodo.rotation.y += delta * 3.2
		# Akira las atrae y las recoge (las que lleva Shiro en la boca ya no están aquí)
		if akira and akira.vivo() and not moneda.reservada and moneda.edad > Datos.ESPERA_IMAN:
			var distancia := nodo.global_position.distance_to(centro_akira)
			if distancia < Datos.RADIO_RECOGER:
				_recoger(moneda)
				continue
			if distancia < Datos.RADIO_IMAN:
				moneda.en_suelo = false
				moneda.velocidad = (centro_akira - nodo.global_position).normalized() * 9.0
				nodo.global_position += moneda.velocidad * delta
				continue
		if moneda.en_suelo:
			nodo.global_position.y = moneda.suelo + 0.14 + sin(moneda.edad * 3.0) * 0.03
			continue
		moneda.velocidad.y -= Datos.GRAVEDAD * delta
		var siguiente: Vector3 = nodo.global_position + moneda.velocidad * delta
		if moneda.velocidad.y < 0.0:
			var consulta := PhysicsRayQueryParameters3D.create(nodo.global_position + Vector3.UP * 0.05,
				siguiente - Vector3.UP * 0.14, 1)
			var choque := espacio.intersect_ray(consulta)
			if not choque.is_empty() and choque.normal.y > 0.6:
				moneda.en_suelo = true
				moneda.suelo = choque.position.y
				siguiente = choque.position + Vector3.UP * 0.14
		if siguiente.y < -2.0:              # por si cae fuera del patio
			siguiente.y = 0.14
			moneda.en_suelo = true
			moneda.suelo = 0.0
		nodo.global_position = siguiente


func _recoger(moneda: Dictionary) -> void:
	var punto: Vector3 = moneda.nodo.global_position
	monedas.erase(moneda)
	moneda.nodo.queue_free()
	recogidas_total += 1
	recogidas.emit(1, punto)


func en_suelo() -> int:
	return monedas.size()


# --- Para Shiro ------------------------------------------------------------------------

# La moneda quieta más cercana a Shiro que Akira ha dejado atrás (fuera de su imán y no
# demasiado lejos de él). La deja reservada para que nadie más la cuente.
func buscar_para_shiro(desde: Vector3, centro: Vector3):
	var mejor = null
	var mejor_distancia := INF
	for moneda in monedas:
		if moneda.reservada or not moneda.en_suelo or moneda.edad < 2.0:
			continue
		var punto: Vector3 = moneda.nodo.global_position
		var a_akira := punto.distance_to(centro)
		if a_akira < Datos.RADIO_IMAN + 1.0 or a_akira > Datos.SHIRO_ALCANCE_TRAER:
			continue
		var distancia := punto.distance_to(desde)
		if distancia < mejor_distancia:
			mejor = moneda
			mejor_distancia = distancia
	if mejor != null:
		mejor.reservada = true
	return mejor


# Otra moneda quieta y libre cerca de «punto», lejos del imán de Akira: Shiro llena la boca
# antes de volver.
func buscar_cercana(punto: Vector3, radio: float, centro: Vector3):
	var mejor = null
	var mejor_distancia := radio
	for moneda in monedas:
		if moneda.reservada or not moneda.en_suelo:
			continue
		var posicion: Vector3 = moneda.nodo.global_position
		if posicion.distance_to(centro) < Datos.RADIO_IMAN + 0.5:
			continue
		var distancia := posicion.distance_to(punto)
		if distancia < mejor_distancia:
			mejor = moneda
			mejor_distancia = distancia
	if mejor != null:
		mejor.reservada = true
	return mejor


func sigue_ahi(moneda) -> bool:
	return moneda != null and monedas.has(moneda)


# Shiro coge la moneda y, de paso, las que estén pegadas a ella. Devuelve cuántas lleva.
func tomar(moneda) -> int:
	if not sigue_ahi(moneda):
		return 0
	var centro: Vector3 = moneda.nodo.global_position
	var cogidas := 0
	for otra in monedas.duplicate():
		if otra == moneda or (otra.en_suelo and not otra.reservada
				and otra.nodo.global_position.distance_to(centro) < 0.6):
			monedas.erase(otra)
			otra.nodo.queue_free()
			cogidas += 1
	return cogidas


func liberar(moneda) -> void:
	if sigue_ahi(moneda):
		moneda.reservada = false
