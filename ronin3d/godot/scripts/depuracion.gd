# Vista de depuración del combate (F3, o arrancar con «-- --depurar»): dibuja en el suelo el
# cono y el alcance del corte en curso de Akira (amarillo en la anticipación, rojo mientras corta,
# gris en la recuperación), las zonas donde se puede golpear a cada enemigo (círculos verdes) y
# la franja de los ataques enemigos (naranja al avisar, rojo al golpear).
extends MeshInstance3D

var juego
var activa := false
var malla := ImmediateMesh.new()


func _ready() -> void:
	mesh = malla
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	material.no_depth_test = true
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material_override = material
	top_level = true
	process_mode = Node.PROCESS_MODE_ALWAYS


func alternar() -> void:
	activa = not activa
	malla.clear_surfaces()


func _process(_delta: float) -> void:
	if not activa or juego == null:
		return
	malla.clear_surfaces()
	malla.surface_begin(Mesh.PRIMITIVE_LINES)
	var akira = juego.akira
	if akira.atacando():
		var corte: Dictionary = akira.ataque
		var color := Color(0.6, 0.6, 0.6)
		if akira.corte_activo():
			color = Color(1.0, 0.15, 0.1)
		elif akira.tiempo_en_ataque < corte.anticipacion:
			color = Color(1.0, 0.9, 0.2)
		_cono(akira.global_position, akira.mirando, float(corte.alcance), float(corte.cono), color)
	if akira.esquivando():
		_circulo(akira.global_position, 0.5, Color(0.3, 0.8, 1.0) if akira.invulnerable_por_esquiva() else Color(0.5, 0.5, 0.6))
	for enemigo in juego.soldados_vivos():
		for punto in juego.puntos_de_golpe(enemigo):
			_circulo(punto.posicion, float(punto.radio), Color(0.2, 1.0, 0.3))
		_franja_enemiga(enemigo)
	malla.surface_end()


func _linea(a: Vector3, b: Vector3, color: Color) -> void:
	malla.surface_set_color(color)
	malla.surface_add_vertex(a + Vector3.UP * 0.05)
	malla.surface_set_color(color)
	malla.surface_add_vertex(b + Vector3.UP * 0.05)


func _circulo(centro: Vector3, radio: float, color: Color) -> void:
	var lados := 24
	for i in lados:
		var a := TAU * i / lados
		var b := TAU * (i + 1) / lados
		_linea(Vector3(centro.x + cos(a) * radio, centro.y, centro.z + sin(a) * radio),
			Vector3(centro.x + cos(b) * radio, centro.y, centro.z + sin(b) * radio), color)


func _cono(origen: Vector3, frente: Vector3, alcance: float, grados: float, color: Color) -> void:
	var base := atan2(frente.z, frente.x)
	var mitad := deg_to_rad(minf(grados, 360.0) / 2.0)
	var pasos := 20
	var anterior := Vector3.ZERO
	for i in pasos + 1:
		var angulo := base - mitad + 2.0 * mitad * i / pasos
		var punto := origen + Vector3(cos(angulo), 0, sin(angulo)) * alcance
		if i > 0:
			_linea(anterior, punto, color)
		if grados < 360.0 and (i == 0 or i == pasos):
			_linea(origen, punto, color)
		anterior = punto


# Franja del ataque enemigo (alcance × ancho hacia delante), si está avisando o golpeando.
func _franja_enemiga(enemigo) -> void:
	var ataque: Dictionary = enemigo.get("ataque") if enemigo.get("ataque") is Dictionary else {}
	var info: Dictionary = enemigo.info() if enemigo.has_method("info") else {}
	# En soldado.gd y yokai.gd el estado 3 es ATACANDO.
	var golpeando: bool = enemigo.get("estado") is int and int(enemigo.get("estado")) == 3
	if not info.get("aviso", false) and not golpeando:
		return
	var alcance := float(ataque.get("alcance", 2.1))
	var ancho := float(ataque.get("ancho", 0.8))
	var frente: Vector3 = enemigo.get("mirando") if enemigo.get("mirando") is Vector3 else Vector3.FORWARD
	var lado := Vector3(-frente.z, 0, frente.x) * ancho / 2.0
	var o: Vector3 = enemigo.global_position
	var color := Color(1.0, 0.55, 0.1) if info.get("aviso", false) else Color(1.0, 0.1, 0.1)
	_linea(o + lado, o + lado + frente * alcance, color)
	_linea(o - lado, o - lado + frente * alcance, color)
	_linea(o + lado + frente * alcance, o - lado + frente * alcance, color)
