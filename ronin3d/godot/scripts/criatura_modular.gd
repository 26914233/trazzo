# Criatura modular: construye una criatura a partir de una receta (familia, tamaño, elemento,
# rol, partes y rango) con piezas 3D sencillas y cel-shading, y la anima por código.
# Sirve para comprobar si un bestiario de cientos de criaturas es viable sin un modelo hecho a
# mano para cada una: la mayoría salen de «una familia + piezas + paleta».
#
# Receta (Dictionary):
#   familia  bipedo · cuadrupedo · serpentino · alado · acuatico · flotante · artropodo
#   tamano   S · M · L · XL           elemento  fuego, agua, hielo, rayo, viento, tierra,
#   rol      veloz, poderoso…                    veneno, sombra, luz, sangre o ninguno
#   rango    1 base · 2 alfa (variante fuerte) · 3 silenciada
#   semilla  entero: misma semilla, misma criatura
#   partes   (opcional) lista; si falta se eligen según la familia y la semilla
#   paleta   (opcional) [principal, secundario, acento]
#   forma    (opcional) variante dentro de la familia: pez, pulpo, reptil, llama, fantasma
# Mira hacia +Z local, como VisualModelo.
extends Node3D

const VisualModelo := preload("res://scripts/visual_modelo.gd")

const ESCALA := {"S": 0.55, "M": 1.0, "L": 1.9, "XL": 3.8}
const PALETAS := {
	"fuego": [Color("b3321f"), Color("2a1c1a"), Color("ffb347")],
	"agua": [Color("2f7f8f"), Color("1d3b52"), Color("bfe8e0")],
	"hielo": [Color("9fc8e6"), Color("e8f2f8"), Color("4a78a8")],
	"rayo": [Color("d6b92a"), Color("3a2f5c"), Color("fff3a0")],
	"viento": [Color("7fb59a"), Color("e6efe8"), Color("3f6f5a")],
	"tierra": [Color("8a6b45"), Color("4a3b2a"), Color("c9b38a")],
	"veneno": [Color("6fa23a"), Color("3a2a52"), Color("d4f06a")],
	"sombra": [Color("3b3d52"), Color("14141f"), Color("b9b6e8")],
	"luz": [Color("e6d28a"), Color("f6f1de"), Color("fff6c8")],
	"sangre": [Color("8e1f2c"), Color("1c1014"), Color("e8a0a0")],
	"ninguno": [Color("7a6a58"), Color("3a3028"), Color("d8c9a8")],
}
const FRECUENCIA := 5.0

static var cache_materiales := {}

var aspecto
var receta: Dictionary = {}
var cuerpo: Node3D
var anclas := {}                      # cabeza, lomo, cola: dónde se enganchan las partes
var osciladores: Array = []           # [nodo, eje, amplitud, fase, frecuencia, base]
var piezas := 0                       # piezas 3D de la criatura (presupuesto de rendimiento)
var tiempo := 0.0
var acumulado := 0.0
var flota := false
var rng := RandomNumberGenerator.new()
var paleta: Array = []
var rango := 1
var partes: Array = []


func configurar(aspecto_del_juego, receta_nueva: Dictionary) -> void:
	aspecto = aspecto_del_juego
	receta = receta_nueva
	rango = int(receta.get("rango", 1))
	rng.seed = int(receta.get("semilla", 1)) * 7919 + 13
	cuerpo = Node3D.new()
	add_child(cuerpo)
	_calcular_paleta()
	partes = _elegir_partes()
	match String(receta.get("familia", "bipedo")):
		"cuadrupedo": _construir_cuadrupedo()
		"serpentino": _construir_serpentino()
		"alado": _construir_alado()
		"acuatico": _construir_acuatico()
		"flotante": _construir_flotante()
		"artropodo": _construir_artropodo()
		_: _construir_bipedo()
	_poner_partes()
	if rango == 2:
		_anillo_de_aura()
	var escala: float = ESCALA.get(String(receta.get("tamano", "M")), 1.0) * (1.2 if rango == 2 else 1.0)
	cuerpo.scale = Vector3.ONE * escala


# --- Aspecto ---------------------------------------------------------------------------------

func _calcular_paleta() -> void:
	var base: Array = receta.get("paleta", PALETAS.get(String(receta.get("elemento", "ninguno")), PALETAS["ninguno"])).duplicate()
	var giro := rng.randf_range(-0.05, 0.05)
	for i in base.size():
		var c: Color = base[i]
		base[i] = Color.from_hsv(fposmod(c.h + giro, 1.0), c.s, c.v)
	if rango == 2:
		for i in 2:
			var c: Color = base[i]
			base[i] = Color.from_hsv(c.h, minf(c.s * 1.25, 1.0), c.v * 0.78)
	elif rango == 3:
		base = [Color("e9e7e1"), Color("8c8b92"), Color("0e0e12")]
	paleta = base


func _material(color: Color, por_normal: bool, emision: float) -> Material:
	var clave := "%s_%s_%s" % [color.to_html(), por_normal, emision]
	if not cache_materiales.has(clave):
		var material: ShaderMaterial = aspecto.material_toon(color, true, por_normal)
		if emision > 0.0:
			material.set_shader_parameter("emision", emision)
		cache_materiales[clave] = material
	return cache_materiales[clave]


func _elegir_partes() -> Array:
	if receta.has("partes"):
		return receta.partes
	var familia := String(receta.get("familia", "bipedo"))
	var elemento := String(receta.get("elemento", "ninguno"))
	var rol := String(receta.get("rol", "veloz"))
	var tamano := String(receta.get("tamano", "M"))
	var elegidas: Array = []
	if familia in ["bipedo", "cuadrupedo", "serpentino", "alado"] and rng.randf() < 0.55:
		elegidas.append("cuernos")
	if rng.randf() < 0.7 or elemento in ["sombra", "fuego"]:
		elegidas.append("ojos")
	if familia == "cuadrupedo" and rng.randf() < 0.4:
		elegidas.append("melena")
	if familia in ["bipedo", "cuadrupedo", "serpentino"] and rng.randf() < 0.35:
		elegidas.append("espinas")
	if familia == "bipedo" and (rng.randf() < 0.25 or rol == "engano"):
		elegidas.append("mascara")
	if familia == "bipedo" and rol == "poderoso" and rng.randf() < 0.5:
		elegidas.append("armadura")
	if familia in ["bipedo", "cuadrupedo"] and rng.randf() < 0.2:
		elegidas.append("caparazon")
	if familia in ["bipedo", "cuadrupedo"] and rng.randf() < 0.15:
		elegidas.append("alas")
	if elemento == "fuego" and rng.randf() < 0.7:
		elegidas.append("llamas")
	if elemento == "luz" and rng.randf() < 0.7:
		elegidas.append("aureola")
	if familia == "bipedo" and rng.randf() < 0.1:
		elegidas.append("brazos_extra")
	if tamano in ["L", "XL"] and rng.randf() < 0.1:
		elegidas.append("cabeza_extra")
	if rango >= 2 and not "cuernos" in elegidas:
		elegidas.append("cuernos")
	return elegidas


# --- Piezas ------------------------------------------------------------------------------------

func _pivote(padre: Node3D, posicion: Vector3) -> Node3D:
	var nodo := Node3D.new()
	nodo.position = posicion
	padre.add_child(nodo)
	return nodo


func _pieza(padre: Node3D, malla: Mesh, color: Color, posicion: Vector3, rotacion: Vector3,
		por_normal: bool, emision: float) -> MeshInstance3D:
	var instancia := MeshInstance3D.new()
	instancia.mesh = malla
	instancia.material_override = _material(color, por_normal, emision)
	instancia.position = posicion
	instancia.rotation = rotacion
	instancia.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	padre.add_child(instancia)
	piezas += 1
	return instancia


func _caja(padre: Node3D, tamano: Vector3, color: Color, posicion: Vector3, rotacion := Vector3.ZERO,
		emision := 0.0) -> MeshInstance3D:
	var malla := BoxMesh.new()
	malla.size = tamano
	return _pieza(padre, malla, color, posicion, rotacion, false, emision)


func _esfera(padre: Node3D, radio: float, color: Color, posicion: Vector3, escala := Vector3.ONE,
		emision := 0.0) -> MeshInstance3D:
	var malla := SphereMesh.new()
	malla.radius = radio
	malla.height = radio * 2.0
	malla.radial_segments = 12
	malla.rings = 6
	var instancia := _pieza(padre, malla, color, posicion, Vector3.ZERO, true, emision)
	instancia.scale = escala
	return instancia


func _capsula(padre: Node3D, radio: float, alto: float, color: Color, posicion: Vector3,
		rotacion := Vector3.ZERO) -> MeshInstance3D:
	var malla := CapsuleMesh.new()
	malla.radius = radio
	malla.height = alto
	malla.radial_segments = 10
	malla.rings = 3
	return _pieza(padre, malla, color, posicion, rotacion, true, 0.0)


func _prisma(padre: Node3D, tamano: Vector3, color: Color, posicion: Vector3, rotacion := Vector3.ZERO) -> MeshInstance3D:
	var malla := PrismMesh.new()
	malla.size = tamano
	return _pieza(padre, malla, color, posicion, rotacion, false, 0.0)


# Barra (pata, tentáculo, cuerno, espina): sale de «inicio» hacia «direccion» con el ancho que
# se indica en cada extremo.
func _barra(padre: Node3D, inicio: Vector3, direccion: Vector3, largo: float, radio_ini: float,
		radio_fin: float, color: Color, emision := 0.0) -> MeshInstance3D:
	var malla := CylinderMesh.new()
	malla.bottom_radius = radio_ini
	malla.top_radius = radio_fin
	malla.height = largo
	malla.radial_segments = 8
	malla.rings = 1
	var dir := direccion.normalized()
	var instancia := _pieza(padre, malla, color, inicio + dir * largo / 2.0, Vector3.ZERO, true, emision)
	if dir.is_equal_approx(Vector3.DOWN):
		instancia.basis = Basis(Vector3.RIGHT, PI)
	elif not dir.is_equal_approx(Vector3.UP):
		instancia.basis = Basis(Quaternion(Vector3.UP, dir))
	return instancia


func _oscilar(nodo: Node3D, eje: int, amplitud: float, fase := 0.0, frecuencia := 1.0) -> void:
	osciladores.append([nodo, eje, amplitud, fase, frecuencia, nodo.rotation[eje]])


# Cadena de segmentos que se curva (cola, tentáculo, cuerpo de serpiente).
func _cadena(padre: Node3D, inicio: Vector3, direccion: Vector3, cantidad: int, largo: float,
		radio_ini: float, radio_fin: float, color: Color, eje: int, amplitud: float, fase := 0.0) -> Array:
	var nodos: Array = []
	var actual := padre
	for i in cantidad:
		var pivote := _pivote(actual, inicio if i == 0 else direccion.normalized() * largo)
		var r0 := lerpf(radio_ini, radio_fin, float(i) / cantidad)
		var r1 := lerpf(radio_ini, radio_fin, float(i + 1) / cantidad)
		_barra(pivote, Vector3.ZERO, direccion, largo, r0, r1, color)
		_oscilar(pivote, eje, amplitud, fase + i * 0.55, 0.8)
		nodos.append(pivote)
		actual = pivote
	return nodos


func _ojos(cabeza: Node3D, separacion: float, altura: float, fondo: float, radio: float) -> void:
	var brillo: Color = Color("0e0e12") if rango == 3 else paleta[2]
	for lado in [-1.0, 1.0]:
		_esfera(cabeza, radio, brillo, Vector3(separacion * lado, altura, fondo), Vector3.ONE, 0.0 if rango == 3 else 1.6)


# --- Familias ----------------------------------------------------------------------------------

func _construir_bipedo() -> void:
	var c1: Color = paleta[0]
	var c2: Color = paleta[1]
	var ancho := rng.randf_range(0.8, 1.3)
	var largo_piernas := rng.randf_range(0.7, 0.95)
	for lado in [-1.0, 1.0]:
		var cadera := _pivote(cuerpo, Vector3(0.13 * ancho * lado, largo_piernas, 0))
		_barra(cadera, Vector3.ZERO, Vector3.DOWN, largo_piernas, 0.1 * ancho, 0.07, c2)
		_caja(cadera, Vector3(0.14, 0.07, 0.26), c2, Vector3(0, -largo_piernas, 0.05))
		_oscilar(cadera, 0, 0.6, 0.0 if lado < 0.0 else PI)
	var torso := _pivote(cuerpo, Vector3(0, largo_piernas, 0))
	_caja(torso, Vector3(0.48 * ancho, 0.62, 0.3), c1, Vector3(0, 0.33, 0))
	_caja(torso, Vector3(0.5 * ancho, 0.08, 0.32), c2, Vector3(0, 0.04, 0))
	for lado in [-1.0, 1.0]:
		var hombro := _pivote(torso, Vector3((0.26 * ancho + 0.08) * lado, 0.58, 0))
		_barra(hombro, Vector3.ZERO, Vector3.DOWN, 0.6, 0.08, 0.06, c1)
		_esfera(hombro, 0.075, paleta[2].darkened(0.3) if rango != 3 else c2, Vector3(0, -0.62, 0))
		_oscilar(hombro, 0, 0.5, PI if lado < 0.0 else 0.0)
	var cabeza := _pivote(torso, Vector3(0, 0.82, 0))
	_esfera(cabeza, 0.18, c1.lightened(0.1), Vector3.ZERO)
	_ojos(cabeza, 0.07, 0.02, 0.16, 0.035)
	anclas = {"cabeza": cabeza, "lomo": _pivote(torso, Vector3(0, 0.45, -0.17)), "cola": _pivote(torso, Vector3(0, 0.0, -0.15)),
		"torso": torso, "hombro_altura": 0.58}


func _construir_cuadrupedo() -> void:
	var c1: Color = paleta[0]
	var c2: Color = paleta[1]
	var largo := rng.randf_range(1.2, 1.5)
	var alto_patas := rng.randf_range(0.5, 0.7)
	var tronco := _pivote(cuerpo, Vector3(0, alto_patas + 0.22, 0))
	_capsula(tronco, 0.27, largo, c1, Vector3.ZERO, Vector3(PI / 2, 0, 0))
	_caja(tronco, Vector3(0.3, 0.1, largo * 0.8), c2, Vector3(0, 0.25, 0))
	for z in [-0.34, 0.34]:
		for lado in [-1.0, 1.0]:
			var pata := _pivote(tronco, Vector3(0.18 * lado, -0.05, largo * z))
			_barra(pata, Vector3.ZERO, Vector3.DOWN, alto_patas + 0.15, 0.09, 0.06, c1)
			_caja(pata, Vector3(0.13, 0.06, 0.2), c2, Vector3(0, -alto_patas - 0.13, 0.04))
			_oscilar(pata, 0, 0.55, (0.0 if (lado * z) > 0.0 else PI))
	var cuello := _pivote(tronco, Vector3(0, 0.1, largo * 0.42))
	cuello.rotation.x = -0.6
	_barra(cuello, Vector3.ZERO, Vector3.UP, 0.5, 0.15, 0.12, c1)
	var cabeza := _pivote(tronco, Vector3(0, 0.45, largo * 0.42 + 0.3))
	_esfera(cabeza, 0.19, c1.lightened(0.05), Vector3.ZERO)
	_caja(cabeza, Vector3(0.2, 0.15, 0.3), c1, Vector3(0, -0.05, 0.22))
	_caja(cabeza, Vector3(0.18, 0.05, 0.24), c2, Vector3(0, -0.14, 0.2))
	_ojos(cabeza, 0.1, 0.07, 0.13, 0.035)
	for lado in [-1.0, 1.0]:
		_barra(cabeza, Vector3(0.1 * lado, 0.15, -0.02), Vector3(0.3 * lado, 1.0, -0.2), 0.16, 0.05, 0.01, c1)
	var cola := _cadena(tronco, Vector3(0, 0.1, -largo * 0.5), Vector3(0, -0.2, -1.0), 3, 0.3, 0.1, 0.04, c1, 1, 0.5)
	anclas = {"cabeza": cabeza, "lomo": _pivote(tronco, Vector3(0, 0.27, 0)), "cola": cola[cola.size() - 1],
		"torso": tronco, "largo": largo}


func _construir_serpentino() -> void:
	var c1: Color = paleta[0]
	var c2: Color = paleta[1]
	var cantidad := 14 + (4 if String(receta.get("tamano", "M")) in ["L", "XL"] else 0)
	var cabeza := _pivote(cuerpo, Vector3(0, 0.66, 0.4))
	_esfera(cabeza, 0.2, c1.lightened(0.08), Vector3.ZERO, Vector3(0.9, 0.8, 1.35))
	_ojos(cabeza, 0.1, 0.07, 0.14, 0.035)
	_caja(cabeza, Vector3(0.22, 0.04, 0.2), c2, Vector3(0, -0.1, 0.12))
	var nodos := _cadena(cabeza, Vector3(0, 0, -0.1), Vector3(0, 0, -1.0), cantidad, 0.3, 0.2, 0.04, c1, 1, 0.38)
	# El cuello se levanta y vuelve al suelo: postura de cobra
	var curvas := [-0.3, -0.3, 0.3, 0.3]
	for i in mini(curvas.size(), nodos.size()):
		nodos[i].rotation.x = curvas[i]
	for i in nodos.size():
		if i % 3 == 1:
			_barra(nodos[i], Vector3(0, 0.1, 0), Vector3.UP, 0.12 if rango == 1 else 0.2, 0.03, 0.0, c2)
	anclas = {"cabeza": cabeza, "lomo": nodos[2] if nodos.size() > 2 else cabeza, "cola": nodos[nodos.size() - 1],
		"torso": cabeza}
	flota = false


func _construir_alado() -> void:
	var c1: Color = paleta[0]
	var c2: Color = paleta[1]
	var tronco := _pivote(cuerpo, Vector3(0, 1.1, 0))
	_capsula(tronco, 0.2, 0.75, c1, Vector3.ZERO, Vector3(PI / 2 * 0.8, 0, 0))
	var cabeza := _pivote(tronco, Vector3(0, 0.15, 0.48))
	_esfera(cabeza, 0.14, c1.lightened(0.08), Vector3.ZERO)
	_barra(cabeza, Vector3(0, -0.02, 0.1), Vector3.BACK, 0.26, 0.07, 0.0, paleta[2].darkened(0.1))
	_ojos(cabeza, 0.07, 0.05, 0.1, 0.03)
	for lado in [-1.0, 1.0]:
		var ala := _pivote(tronco, Vector3(0.2 * lado, 0.12, 0.05))
		_caja(ala, Vector3(0.85, 0.04, 0.4), c1, Vector3(0.42 * lado, 0, 0))
		var punta := _pivote(ala, Vector3(0.85 * lado, 0, 0))
		_caja(punta, Vector3(0.75, 0.03, 0.32), c2, Vector3(0.36 * lado, 0, -0.05), Vector3(0, 0.25 * lado, 0))
		_oscilar(ala, 2, 0.75 * lado, 0.0, 1.6)
		_oscilar(punta, 2, 0.45 * lado, 0.7, 1.6)
		_barra(tronco, Vector3(0.1 * lado, -0.1, -0.1), Vector3(0.2 * lado, -1.0, 0.2), 0.4, 0.04, 0.025, c2)
	var cola := _cadena(tronco, Vector3(0, -0.05, -0.4), Vector3(0, -0.1, -1.0), 3, 0.25, 0.1, 0.04, c2, 0, 0.3)
	anclas = {"cabeza": cabeza, "lomo": _pivote(tronco, Vector3(0, 0.2, 0)), "cola": cola[cola.size() - 1], "torso": tronco}
	flota = true


func _construir_acuatico() -> void:
	var c1: Color = paleta[0]
	var c2: Color = paleta[1]
	var forma := String(receta.get("forma", ["pez", "pulpo", "reptil"][rng.randi() % 3]))
	if forma == "pulpo":
		var cabeza := _pivote(cuerpo, Vector3(0, 0.75, 0))
		_esfera(cabeza, 0.36, c1, Vector3(0, 0.15, 0), Vector3(1, 1.25, 1))
		_ojos(cabeza, 0.15, 0.1, 0.32, 0.06)
		for i in 8:
			var angulo := TAU * i / 8.0
			var direccion := Vector3(sin(angulo), -0.9, cos(angulo))
			_cadena(cabeza, Vector3(sin(angulo) * 0.2, -0.1, cos(angulo) * 0.2), direccion, 3, 0.33, 0.1, 0.03, c2 if i % 2 else c1,
				0 if i % 2 else 2, 0.4, i * 0.4)
		anclas = {"cabeza": cabeza, "lomo": _pivote(cabeza, Vector3(0, 0.5, 0)), "cola": cabeza, "torso": cabeza}
		flota = true
	elif forma == "reptil":
		var tronco := _pivote(cuerpo, Vector3(0, 0.3, 0))
		_capsula(tronco, 0.22, 1.2, c1, Vector3.ZERO, Vector3(PI / 2, 0, 0))
		var cabeza := _pivote(tronco, Vector3(0, 0.0, 0.8))
		_caja(cabeza, Vector3(0.3, 0.18, 0.6), c1.lightened(0.05), Vector3(0, 0, 0.1))
		_caja(cabeza, Vector3(0.28, 0.06, 0.5), c2, Vector3(0, -0.1, 0.1))
		_ojos(cabeza, 0.12, 0.12, 0.0, 0.035)
		for z in [-0.35, 0.35]:
			for lado in [-1.0, 1.0]:
				var pata := _pivote(tronco, Vector3(0.22 * lado, -0.1, z))
				_barra(pata, Vector3.ZERO, Vector3(0.4 * lado, -1.0, 0.0), 0.3, 0.07, 0.05, c2)
				_oscilar(pata, 0, 0.4, (0.0 if lado * z > 0.0 else PI))
		var cola := _cadena(tronco, Vector3(0, 0, -0.6), Vector3(0, 0, -1.0), 4, 0.33, 0.2, 0.04, c1, 1, 0.45)
		for i in 5:
			_caja(tronco, Vector3(0.06, 0.1, 0.12), c2, Vector3(0, 0.24, 0.5 - i * 0.25))
		anclas = {"cabeza": cabeza, "lomo": _pivote(tronco, Vector3(0, 0.22, 0)), "cola": cola[cola.size() - 1], "torso": tronco}
	else:
		var tronco := _pivote(cuerpo, Vector3(0, 0.75, 0))
		_esfera(tronco, 0.4, c1, Vector3.ZERO, Vector3(0.7, 0.85, 1.9))
		var cabeza := _pivote(tronco, Vector3(0, 0.0, 0.62))
		_ojos(cabeza, 0.2, 0.1, 0.08, 0.055)
		_caja(cabeza, Vector3(0.34, 0.05, 0.12), c2, Vector3(0, -0.12, 0.12))
		_prisma(tronco, Vector3(0.06, 0.45, 0.55), c2, Vector3(0, 0.45, -0.1), Vector3(0, PI / 2, 0))
		for lado in [-1.0, 1.0]:
			var aleta := _pivote(tronco, Vector3(0.28 * lado, -0.12, 0.25))
			_caja(aleta, Vector3(0.4, 0.04, 0.25), c2, Vector3(0.2 * lado, 0, 0))
			_oscilar(aleta, 2, 0.5 * lado, 0.0, 1.4)
		var cola := _pivote(tronco, Vector3(0, 0, -0.7))
		_prisma(cola, Vector3(0.06, 0.6, 0.55), c2, Vector3(0, 0, -0.25), Vector3(0, -PI / 2, 0))
		_oscilar(cola, 1, 0.5, 0.0, 1.5)
		anclas = {"cabeza": cabeza, "lomo": _pivote(tronco, Vector3(0, 0.38, 0)), "cola": cola, "torso": tronco}
		flota = true


func _construir_flotante() -> void:
	var c1: Color = paleta[0]
	var c2: Color = paleta[1]
	var forma := String(receta.get("forma", ["llama", "fantasma"][rng.randi() % 2]))
	var centro := _pivote(cuerpo, Vector3(0, 1.1, 0))
	if forma == "llama":
		_esfera(centro, 0.3, c1, Vector3.ZERO, Vector3.ONE, 0.9)
		_barra(centro, Vector3(0, 0.2, 0), Vector3.UP, 0.45, 0.2, 0.0, c1, 0.9)
		var cola := _cadena(centro, Vector3(0, -0.05, -0.2), Vector3(0, 0.2, -1.0), 3, 0.28, 0.2, 0.02, c1.lightened(0.15), 1, 0.4)
		anclas = {"cabeza": centro, "lomo": _pivote(centro, Vector3(0, 0.3, 0)), "cola": cola[cola.size() - 1], "torso": centro}
	else:
		_esfera(centro, 0.26, c1.lightened(0.12), Vector3(0, 0.2, 0))
		_barra(centro, Vector3(0, 0.15, 0), Vector3.DOWN, 0.6, 0.26, 0.34, c1)
		for i in 5:
			var a := TAU * i / 5.0
			_cadena(centro, Vector3(sin(a) * 0.25, -0.42, cos(a) * 0.25), Vector3(0, -1.0, 0), 2, 0.18, 0.1, 0.02, c1, 2, 0.4, i)
		anclas = {"cabeza": centro, "lomo": _pivote(centro, Vector3(0, 0.45, 0)), "cola": centro, "torso": centro}
		centro.position.y += 0.3
	_ojos(centro, 0.1, 0.1 if forma == "llama" else 0.3, 0.24 if forma == "llama" else 0.2, 0.05)
	_caja(centro, Vector3(0.14, 0.06, 0.05), c2, Vector3(0, -0.04 if forma == "llama" else 0.18, 0.28 if forma == "llama" else 0.22))
	flota = true


func _construir_artropodo() -> void:
	var c1: Color = paleta[0]
	var c2: Color = paleta[1]
	var base := _pivote(cuerpo, Vector3(0, 0.5, 0))
	_esfera(base, 0.36, c1, Vector3(0, 0, -0.35), Vector3(0.85, 0.75, 1.3))
	_esfera(base, 0.23, c2, Vector3(0, 0.02, 0.1))
	var cabeza := _pivote(base, Vector3(0, 0.0, 0.38))
	_esfera(cabeza, 0.16, c1.lightened(0.08), Vector3.ZERO)
	_ojos(cabeza, 0.07, 0.06, 0.12, 0.04)
	for lado in [-1.0, 1.0]:
		_barra(cabeza, Vector3(0.05 * lado, -0.08, 0.12), Vector3(0.4 * lado, -0.4, 1.0), 0.2, 0.04, 0.0, c2)
	for i in 4:
		for lado in [-1.0, 1.0]:
			var pata := _pivote(base, Vector3(0.12 * lado, 0, 0.3 - i * 0.22))
			var arriba := Vector3(lado * 0.9, 0.5, (i - 1.5) * 0.25).normalized()
			_barra(pata, Vector3.ZERO, arriba, 0.5, 0.045, 0.03, c2)
			var rodilla := arriba * 0.5
			var abajo := _pivote(pata, rodilla)
			_barra(abajo, Vector3.ZERO, Vector3(lado * 0.5, -1.0, 0.0), 0.75, 0.03, 0.015, c2)
			_oscilar(pata, 1, 0.35, (0.0 if (i + (1 if lado > 0.0 else 0)) % 2 == 0 else PI))
	anclas = {"cabeza": cabeza, "lomo": _pivote(base, Vector3(0, 0.3, -0.3)), "cola": _pivote(base, Vector3(0, 0, -0.9)), "torso": base}


# --- Partes ------------------------------------------------------------------------------------

func _poner_partes() -> void:
	var c1: Color = paleta[0]
	var c2: Color = paleta[1]
	var c3: Color = paleta[2]
	var cabeza: Node3D = anclas.get("cabeza", cuerpo)
	var lomo: Node3D = anclas.get("lomo", cuerpo)
	for parte in partes:
		match String(parte):
			"cuernos":
				var cantidad := 2 + (2 if rango == 2 else 0)
				for i in cantidad:
					var lado := -1.0 if i % 2 == 0 else 1.0
					var fila := float(i / 2)
					_barra(cabeza, Vector3(0.09 * lado, 0.12 + fila * 0.03, -0.03 - fila * 0.05),
						Vector3(0.45 * lado, 1.0, -0.2 - fila * 0.4), 0.28 + fila * 0.1, 0.045, 0.0, c3.darkened(0.15) if rango != 3 else c2)
			"ojos":
				pass   # los ojos ya van en cada familia
			"melena":
				for i in 5:
					_barra(cabeza, Vector3(0, 0.1, -0.1 - i * 0.07), Vector3(0, 1.0, -0.6), 0.22 - i * 0.02, 0.07, 0.0, c2)
			"espinas":
				for i in 5:
					_barra(lomo, Vector3(0, 0.0, 0.3 - i * 0.16), Vector3(0, 1.0, -0.3), 0.2, 0.05, 0.0, c3.darkened(0.2))
			"mascara":
				_caja(cabeza, Vector3(0.26, 0.28, 0.04), c3.lightened(0.3) if rango != 3 else c1, Vector3(0, 0, 0.17))
				_barra(cabeza, Vector3(0.05, -0.1, 0.19), Vector3(0.4, -1.0, 0.5), 0.1, 0.02, 0.0, c2)
			"armadura":
				var torso: Node3D = anclas.get("torso", cuerpo)
				for lado in [-1.0, 1.0]:
					_caja(torso, Vector3(0.28, 0.12, 0.36), c2, Vector3(0.36 * lado, 0.6, 0), Vector3(0, 0, 0.3 * lado))
				_caja(torso, Vector3(0.52, 0.2, 0.34), c2, Vector3(0, 0.35, 0.02))
			"caparazon":
				_esfera(lomo, 0.4, c2, Vector3(0, 0.05, -0.05), Vector3(1.0, 0.55, 1.2))
			"alas":
				for lado in [-1.0, 1.0]:
					var ala := _pivote(lomo, Vector3(0.12 * lado, 0.2, -0.05))
					_caja(ala, Vector3(0.7, 0.04, 0.4), c3.darkened(0.25), Vector3(0.35 * lado, 0.1, -0.1), Vector3(0, 0, 0.3 * lado))
					_oscilar(ala, 2, 0.35 * lado, 0.0, 1.2)
			"llamas":
				for i in 3:
					_barra(lomo, Vector3((i - 1) * 0.12, 0.1, 0.0), Vector3(0, 1.0, -0.2), 0.4 - abs(i - 1) * 0.1, 0.09, 0.0, c3, 1.4)
			"aureola":
				var anillo := TorusMesh.new()
				anillo.inner_radius = 0.2
				anillo.outer_radius = 0.26
				anillo.rings = 20
				anillo.ring_segments = 6
				_pieza(cabeza, anillo, c3, Vector3(0, 0.38, -0.05), Vector3(0.2, 0, 0), false, 1.4)
			"brazos_extra":
				var torso: Node3D = anclas.get("torso", cuerpo)
				for lado in [-1.0, 1.0]:
					var brazo := _pivote(torso, Vector3(0.3 * lado, 0.38, 0))
					_barra(brazo, Vector3.ZERO, Vector3(0.5 * lado, -1.0, 0.4), 0.5, 0.06, 0.04, c1)
					_oscilar(brazo, 0, 0.5, PI if lado < 0.0 else 0.0)
			"cabeza_extra":
				for lado in [-1.0, 1.0]:
					var cabeza_nueva := _pivote(cabeza, Vector3(0.3 * lado, -0.05, -0.05))
					_esfera(cabeza_nueva, 0.14, c1.lightened(0.05), Vector3.ZERO)
					_ojos(cabeza_nueva, 0.06, 0.03, 0.11, 0.03)
			"plato":
				# Plato con agua en la coronilla (kappa)
				_barra(cabeza, Vector3(0, 0.14, 0), Vector3.UP, 0.04, 0.19, 0.19, c2)
				_barra(cabeza, Vector3(0, 0.17, 0), Vector3.UP, 0.02, 0.15, 0.15, Color("8fd3e8") if rango != 3 else c3, 0.0 if rango == 3 else 0.5)
			"pico":
				_barra(cabeza, Vector3(0, -0.03, 0.14), Vector3(0, 0, 1), 0.2, 0.08, 0.0, c3.darkened(0.1))
			"garrote":
				# Garrote de hierro con púas apoyado en el hombro (oni)
				var torso: Node3D = anclas.get("torso", cuerpo)
				var mango := _pivote(torso, Vector3(-0.38, 0.5, 0.1))
				var direccion := Vector3(-0.15, 1.0, 0.35).normalized()
				_barra(mango, Vector3.ZERO, direccion, 1.1, 0.045, 0.075, Color("6b4a2b") if rango != 3 else c2)
				var cabeza_garrote := direccion * 1.15
				_esfera(mango, 0.15, Color("3a3a42") if rango != 3 else c2, cabeza_garrote)
				for i in 6:
					var angulo := TAU * i / 6.0
					_barra(mango, cabeza_garrote, Vector3(sin(angulo), 0.3, cos(angulo)), 0.2, 0.04, 0.0, Color("5a5a66") if rango != 3 else c2)


# Rango 2 (alfa): anillo de aura del color del elemento bajo la criatura.
func _anillo_de_aura() -> void:
	var anillo := TorusMesh.new()
	anillo.inner_radius = 0.7
	anillo.outer_radius = 0.8
	anillo.rings = 24
	anillo.ring_segments = 4
	_pieza(cuerpo, anillo, paleta[2], Vector3(0, 0.04, 0), Vector3.ZERO, false, 1.5)


# --- Animación ---------------------------------------------------------------------------------

# En estilo anime las poses cambian 12 veces por segundo, igual que en VisualModelo.
func actualizar(delta: float, movimiento := 1.0) -> void:
	acumulado += delta
	if VisualModelo.estilo_anime and acumulado < 1.0 / 12.0:
		return
	tiempo += acumulado
	acumulado = 0.0
	for o in osciladores:
		var nodo: Node3D = o[0]
		var rotacion: Vector3 = nodo.rotation
		rotacion[o[1]] = o[5] + sin(tiempo * FRECUENCIA * o[4] + o[3]) * o[2] * movimiento
		nodo.rotation = rotacion
	if flota:
		cuerpo.position.y = sin(tiempo * 2.2) * 0.08 * movimiento
	else:
		cuerpo.position.y = absf(sin(tiempo * FRECUENCIA)) * 0.04 * movimiento
