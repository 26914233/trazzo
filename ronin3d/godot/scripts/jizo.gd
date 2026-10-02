# Estatua jizō: el protector de los viajeros, de piedra y con su babero rojo. Rezarle cuesta
# monedas y da a Akira +1 de vida máxima (dos veces como mucho), además de curarle del todo
# (DECISIÓN 16A; precios en partida.gd). Más adelante será también donde se guarda la partida.
extends Node3D

const Datos := preload("res://scripts/datos.gd")

const PIEDRA := Color("8a8a86")
const PIEDRA_OSCURA := Color("5e5e5c")
const BABERO := Color("c0302a")

var aspecto
var llama: MeshInstance3D
var brillo := 0.0                    # destello al recibir una ofrenda
var tiempo := 0.0
var materiales: Array = []


func configurar(aspecto_del_juego) -> void:
	aspecto = aspecto_del_juego
	_caja(Vector3(0.62, 0.16, 0.5), PIEDRA_OSCURA, Vector3(0, 0.08, 0))                  # peana
	var cuerpo := CapsuleMesh.new()
	cuerpo.radius = 0.17
	cuerpo.height = 0.62
	_pieza(cuerpo, PIEDRA, Vector3(0, 0.47, 0))
	var cabeza := SphereMesh.new()
	cabeza.radius = 0.14
	cabeza.height = 0.28
	_pieza(cabeza, PIEDRA, Vector3(0, 0.88, 0))
	var babero := CylinderMesh.new()                                                      # el babero rojo
	babero.top_radius = 0.1
	babero.bottom_radius = 0.2
	babero.height = 0.2
	babero.radial_segments = 12
	_pieza(babero, BABERO, Vector3(0, 0.66, 0.02))
	var gorro := SphereMesh.new()
	gorro.radius = 0.145
	gorro.height = 0.145
	gorro.is_hemisphere = true
	_pieza(gorro, BABERO, Vector3(0, 0.92, 0))
	# Una vela y dos monedas de ofrenda en la peana
	var vela := CylinderMesh.new()
	vela.top_radius = 0.025
	vela.bottom_radius = 0.025
	vela.height = 0.1
	_pieza(vela, Color("efe6d0"), Vector3(0.2, 0.21, 0.16))
	var fuego := SphereMesh.new()
	fuego.radius = 0.025
	fuego.height = 0.06
	llama = MeshInstance3D.new()
	llama.mesh = fuego
	llama.material_override = aspecto.material_emisivo(Datos.LUZ_ANTORCHA, 3.0)
	llama.position = Vector3(0.2, 0.29, 0.16)
	add_child(llama)
	for x in [-0.18, -0.1]:
		var moneda := CylinderMesh.new()
		moneda.top_radius = 0.035
		moneda.bottom_radius = 0.035
		moneda.height = 0.01
		_pieza(moneda, Datos.COBRE, Vector3(x, 0.165, 0.17))
	# Que no se pueda atravesar
	var cuerpo_solido := StaticBody3D.new()
	var forma := CollisionShape3D.new()
	var cilindro := CylinderShape3D.new()
	cilindro.radius = 0.32
	cilindro.height = 1.0
	forma.shape = cilindro
	forma.position.y = 0.5
	cuerpo_solido.add_child(forma)
	add_child(cuerpo_solido)


func _pieza(malla: Mesh, color: Color, posicion: Vector3) -> MeshInstance3D:
	var instancia := MeshInstance3D.new()
	instancia.mesh = malla
	var material: Material = aspecto.material_personaje(color)
	instancia.material_override = material
	materiales.append(material)
	instancia.position = posicion
	add_child(instancia)
	return instancia


func _caja(tamano: Vector3, color: Color, posicion: Vector3) -> MeshInstance3D:
	var malla := BoxMesh.new()
	malla.size = tamano
	return _pieza(malla, color, posicion)


func bendecir() -> void:
	brillo = 1.0


func _process(delta: float) -> void:
	tiempo += delta
	llama.scale = Vector3.ONE * (0.85 + 0.25 * absf(sin(tiempo * 9.0)))
	if brillo > 0.0:
		brillo = maxf(0.0, brillo - delta * 1.5)
		for material in materiales:
			aspecto.poner_destello(material, brillo)
