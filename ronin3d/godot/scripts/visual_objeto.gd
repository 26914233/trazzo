# Aspecto de los objetivos que no son criaturas: el sello de papel (ofuda) del templo, clavado en un
# poste y con un brillo que late. Recibe el mismo «info» que los demás aspectos (destello y muerte).
extends Node3D

var papel: MeshInstance3D
var material_papel: StandardMaterial3D
var tiempo := 0.0


func configurar(modelo: String, aspecto) -> void:
	if modelo == "ofuda":
		var poste := MeshInstance3D.new()
		var caja := BoxMesh.new()
		caja.size = Vector3(0.18, 1.6, 0.18)
		poste.mesh = caja
		poste.material_override = aspecto.material_superficie("madera_oscura")
		poste.position.y = 0.8
		add_child(poste)
		papel = MeshInstance3D.new()
		var tira := BoxMesh.new()
		tira.size = Vector3(0.34, 0.75, 0.04)
		papel.mesh = tira
		material_papel = StandardMaterial3D.new()
		material_papel.albedo_color = Color("f2e8c8")
		material_papel.emission_enabled = true
		material_papel.emission = Color(1.0, 0.75, 0.35)
		material_papel.emission_energy_multiplier = 0.8
		papel.material_override = material_papel
		papel.position = Vector3(0, 1.15, 0.11)
		add_child(papel)
		var trazo := MeshInstance3D.new()
		var raya := BoxMesh.new()
		raya.size = Vector3(0.06, 0.55, 0.05)
		trazo.mesh = raya
		trazo.material_override = aspecto.material_emisivo(Color(0.75, 0.08, 0.06), 1.2)
		trazo.position = Vector3(0, 1.15, 0.12)
		add_child(trazo)


func actualizar(delta: float, info: Dictionary) -> void:
	tiempo += delta
	if material_papel == null:
		return
	var muerte: float = info.get("muerte", -1.0)
	material_papel.emission_energy_multiplier = 0.6 + 0.5 * (0.5 + 0.5 * sin(tiempo * 4.0)) + float(info.get("destello", 0.0)) * 3.0
	if muerte >= 0.0:
		scale = Vector3.ONE * maxf(0.01, 1.0 - muerte)
		papel.rotation.z = muerte * 3.0
