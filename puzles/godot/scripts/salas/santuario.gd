# La sala de la reliquia: un santuario circular de piedra bajo una cúpula con un óculo abierto a las
# estrellas. La reliquia flota sobre un altar escalonado; del altar salen canales de luz hacia las
# columnas, que se encienden cuando la reliquia despierta. Una banda de glifos recorre la pared y dos
# braseros arden con llama cian. Se entra por un pasillo bajo un arco.
# La reliquia está en el origen, flotando a la altura del pecho.
extends Node3D

const SUELO := -1.25
const RADIO := 3.2
const ALTO := 3.6
const PUERTA := PI / 2.0              # el arco de entrada mira a +Z
const ANCHO_PUERTA := 1.4
const ALTO_PUERTA := 2.6

var canales: Array = []               # materiales de los canales de luz del suelo
var braseros: Array = []              # [luz, llama]
var glifos: StandardMaterial3D
var _encendido := 0.0
var _objetivo := 0.0
var _tiempo := 0.0
var _ruido := FastNoiseLite.new()


func construir() -> void:
	_ruido.frequency = 2.5
	var piedra := Materiales.con_textura("piedra", 0.55, 0.85, 0.0, Color(0.62, 0.62, 0.68), 1.2)
	_suelo()
	_altar()
	Arquitectura.pared_curva(Vector3(0.0, SUELO, 0.0), RADIO, ALTO, piedra, self, [PUERTA, ANCHO_PUERTA, ALTO_PUERTA], 48, 0.4)
	_banda_de_glifos()
	_columnas(piedra)
	Arquitectura.cupula(Vector3(0.0, SUELO + ALTO, 0.0), RADIO, 2.1, 0.75,
		Materiales.con_textura("piedra", 0.7, 0.9, 0.0, Color(0.42, 0.42, 0.5), 1.2), self)
	_luz_de_luna()
	_braseros()
	_pasillo(piedra)


func _suelo() -> void:
	var losas := Materiales.con_textura("losas", 0.5, 0.75, 0.0, Color(0.85, 0.85, 0.9), 1.0)
	var disco := CylinderMesh.new()
	disco.top_radius = RADIO + 0.3
	disco.bottom_radius = RADIO + 0.3
	disco.height = 0.06
	disco.radial_segments = 64
	var material: StandardMaterial3D = losas.duplicate()
	material.uv1_scale = Vector3(3.3, 3.3, 3.3)
	var suelo := Geometria.pieza(disco, material, Vector3(0.0, SUELO - 0.03, 0.0), self)
	suelo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# círculos y canales de luz incrustados (se encienden con la reliquia)
	for radio in [1.25, 2.1]:
		var aro := TorusMesh.new()
		aro.inner_radius = radio - 0.025
		aro.outer_radius = radio + 0.025
		aro.rings = 96
		var material_aro := Materiales.emisivo(Color(0.3, 0.85, 0.95), 0.15, Color(0.05, 0.07, 0.09))
		var malla := Geometria.pieza(aro, material_aro, Vector3(0.0, SUELO + 0.002, 0.0), self)
		malla.scale = Vector3(1.0, 0.2, 1.0)
		malla.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		canales.append(material_aro)
	for k in 8:
		var angulo := PI / 8.0 + k * TAU / 8.0
		var material_canal := Materiales.emisivo(Color(0.3, 0.85, 0.95), 0.15, Color(0.05, 0.07, 0.09))
		var largo := RADIO - 0.95 - 1.0
		var tira := Escena.bloque(Vector3(-largo / 2.0, 0.0, -0.022), Vector3(largo / 2.0, 0.006, 0.022), material_canal, self, 0.0, false)
		tira.position = Vector3(cos(angulo) * (1.0 + largo / 2.0), SUELO + 0.003, sin(angulo) * (1.0 + largo / 2.0))
		tira.rotation.y = -angulo
		tira.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		canales.append(material_canal)


func _altar() -> void:
	var piedra := Materiales.con_textura("losas", 1.5, 0.7, 0.0, Color(0.7, 0.7, 0.76), 1.0)
	for escalon in [[1.0, 0.0, 0.09], [0.72, 0.09, 0.18]]:
		var disco := CylinderMesh.new()
		disco.top_radius = escalon[0]
		disco.bottom_radius = escalon[0]
		disco.height = float(escalon[2]) - float(escalon[1])
		disco.radial_segments = 48
		Geometria.pieza(disco, piedra, Vector3(0.0, SUELO + (float(escalon[1]) + float(escalon[2])) / 2.0, 0.0), self)
	var columna := Geometria.torno(PackedVector2Array([Vector2(0.3, 0.0), Vector2(0.3, 0.06), Vector2(0.2, 0.12), Vector2(0.17, 0.25),
		Vector2(0.16, 0.6), Vector2(0.18, 0.66), Vector2(0.28, 0.72), Vector2(0.3, 0.75), Vector2(0.0, 0.75)]), 32)
	Geometria.pieza(columna, piedra, Vector3(0.0, SUELO + 0.18, 0.0), self)
	var aro := TorusMesh.new()
	aro.inner_radius = 0.2
	aro.outer_radius = 0.235
	aro.rings = 48
	var material := Materiales.emisivo(Color(0.3, 0.85, 0.95), 0.4, Color(0.05, 0.07, 0.09))
	var malla := Geometria.pieza(aro, material, Vector3(0.0, SUELO + 0.93, 0.0), self)
	malla.scale = Vector3(1.0, 0.25, 1.0)
	canales.append(material)


func _banda_de_glifos() -> void:
	glifos = StandardMaterial3D.new()
	glifos.albedo_color = Color(0.1, 0.11, 0.13)
	glifos.albedo_texture = Materiales.textura("glifos")
	glifos.emission_enabled = true
	glifos.emission_texture = Materiales.textura("glifos")
	glifos.emission = Color(0.3, 0.85, 0.95)
	glifos.emission_energy_multiplier = 0.35
	glifos.uv1_scale = Vector3(1.0 / 2.6, -1.0 / 0.32, 1.0)
	Arquitectura.pared_curva(Vector3(0.0, SUELO + 2.3, 0.0), RADIO - 0.012, 0.32, glifos, self, [PUERTA, ANCHO_PUERTA + 0.1, 0.32], 48, 0.0)


func _columnas(piedra: Material) -> void:
	for k in 8:
		var angulo := k * TAU / 8.0
		if absf(wrapf(angulo - PUERTA, -PI, PI)) < 0.3:
			continue
		var lugar := Vector3(cos(angulo) * (RADIO - 0.42), SUELO, sin(angulo) * (RADIO - 0.42))
		var fuste := CylinderMesh.new()
		fuste.top_radius = 0.15
		fuste.bottom_radius = 0.17
		fuste.height = ALTO - 0.4
		fuste.radial_segments = 16
		var material: StandardMaterial3D = piedra.duplicate()
		material.uv1_scale = Vector3(1.5, 1.0, 1.0)
		var columna := Geometria.pieza(fuste, material, lugar + Vector3(0.0, 0.2 + (ALTO - 0.4) / 2.0, 0.0), self)
		columna.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for y in [0.0, ALTO - 0.2]:
			Arquitectura.losa(lugar + Vector3(-0.26, y, -0.26), lugar + Vector3(0.26, y + 0.2, 0.26), piedra, self, 0.01)


func _luz_de_luna() -> void:
	var luna := DirectionalLight3D.new()
	luna.light_color = Color(0.62, 0.72, 1.0)
	luna.light_energy = 0.45
	luna.light_specular = 0.5
	add_child(luna)
	luna.look_at_from_position(Vector3(0.6, 6.0, -0.3), Vector3.ZERO, Vector3.FORWARD)
	# haz de luz que baja del óculo
	var cono := CylinderMesh.new()
	cono.top_radius = 0.72
	cono.bottom_radius = 1.05
	cono.height = ALTO + 2.0
	cono.cap_top = false
	cono.cap_bottom = false
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.45, 0.6, 0.95, 0.045)
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var haz := Geometria.pieza(cono, material, Vector3(0.12, SUELO + (ALTO + 2.0) / 2.0, -0.06), self)
	haz.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	Escena.polvo(self, Vector3(0.8, 1.6, 0.8), Color(0.6, 0.8, 1.0, 0.5), 70, 0.006).position = Vector3(0.0, SUELO + 1.8, 0.0)


func _braseros() -> void:
	var bronce := Materiales.laton(0.45)
	for lado in [-1.0, 1.0]:
		var nodo := Escena.grupo(self, Vector3(lado * 1.9, SUELO, -1.75), "Brasero")
		for k in 3:
			var angulo := k * TAU / 3.0
			var pata := Escena.bloque(Vector3(-0.015, 0.0, -0.015), Vector3(0.015, 0.75, 0.015), bronce, nodo, 0.004, false)
			pata.position = Vector3(cos(angulo) * 0.16, 0.375, sin(angulo) * 0.16)
			pata.rotation = Vector3(sin(angulo) * 0.15, 0.0, -cos(angulo) * 0.15)
		var cuenco := Geometria.torno(PackedVector2Array([Vector2(0.0, 0.0), Vector2(0.12, 0.02), Vector2(0.24, 0.12), Vector2(0.26, 0.16)]), 28)
		var material_cuenco: StandardMaterial3D = bronce.duplicate()
		material_cuenco.cull_mode = BaseMaterial3D.CULL_DISABLED
		Geometria.pieza(cuenco, material_cuenco, Vector3(0.0, 0.72, 0.0), nodo)
		var llama := MeshInstance3D.new()
		var gota := SphereMesh.new()
		gota.radius = 0.075
		gota.height = 0.26
		llama.mesh = gota
		llama.material_override = Materiales.emisivo(Color(0.35, 0.9, 1.0), 2.2, Color(0.3, 0.8, 1.0))
		llama.position = Vector3(0.0, 0.98, 0.0)
		llama.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		nodo.add_child(llama)
		var luz := Escena.luz(nodo, Vector3(0.0, 1.05, 0.0), Color(0.35, 0.85, 1.0), 0.9, 3.6)
		braseros.append([luz, llama])


func _pasillo(piedra: Material) -> void:
	var z0 := RADIO - 0.1
	var z1 := RADIO + 2.6
	var mitad := ANCHO_PUERTA / 2.0
	Arquitectura.losa(Vector3(-mitad, SUELO - 0.05, z0), Vector3(mitad, SUELO, z1), Materiales.con_textura("losas", 0.5, 0.75), self)
	Arquitectura.losa(Vector3(-mitad, SUELO + ALTO_PUERTA, z0), Vector3(mitad, SUELO + ALTO_PUERTA + 0.1, z1), piedra, self)
	Arquitectura.pared(Vector3(-mitad, SUELO, z1), Vector3.FORWARD, z1 - z0, ALTO_PUERTA, Vector3.RIGHT, piedra, self)
	Arquitectura.pared(Vector3(mitad, SUELO, z0), Vector3.BACK, z1 - z0, ALTO_PUERTA, Vector3.LEFT, piedra, self)
	Arquitectura.pared(Vector3(mitad, SUELO, z1), Vector3.LEFT, ANCHO_PUERTA, ALTO_PUERTA, Vector3.FORWARD, piedra, self)
	Escena.luz(self, Vector3(0.0, SUELO + 2.2, z1 - 0.5), Color(0.4, 0.6, 1.0), 0.35, 2.6)


# Brillo de los canales: 0 dormida, 1 despierta, 2 con el cristal
func encender(nivel: float) -> void:
	_objetivo = nivel


func actualizar(delta: float) -> void:
	_tiempo += delta
	_encendido = move_toward(_encendido, _objetivo, delta * 0.6)
	var pulso := 0.85 + 0.15 * sin(_tiempo * 2.0)
	for material in canales:
		(material as StandardMaterial3D).emission_energy_multiplier = (0.15 + _encendido * 1.1) * pulso
	glifos.emission_energy_multiplier = 0.35 + _encendido * 0.6
	for k in braseros.size():
		var datos: Array = braseros[k]
		var temblor := _ruido.get_noise_1d(_tiempo * 2.0 + k * 50.0)
		(datos[0] as OmniLight3D).light_energy = 0.9 + temblor * 0.25
		(datos[1] as MeshInstance3D).scale = Vector3(1.0, 0.85 + 0.3 * (0.5 + 0.5 * sin(_tiempo * 8.0 + k)), 1.0)


func poner_color(color: Color) -> void:
	for material in canales:
		(material as StandardMaterial3D).emission = color
	glifos.emission = color
