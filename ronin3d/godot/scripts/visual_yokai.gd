# Aspecto de un yōkai enemigo: la criatura del bestiario (modelo detallado si lo hay; si no,
# de piezas) con las poses del combate hechas inclinando el cuerpo entero: se echa atrás al
# avisar (anticipación), se lanza al golpear, se tambalea aturdido y hace la reverencia
# (el kappa). Encima, el aviso: «!» blanco si se puede parar y «!!» rojo si hay que esquivar.
extends Node3D

const CriaturaModular := preload("res://scripts/criatura_modular.gd")
const ModeloCriatura := preload("res://scripts/modelo_criatura.gd")

var criatura: Node3D
var pivote: Node3D
var aviso: Label3D
var perfil: Dictionary
var angulo := 0.0
var inclinacion := 0.0
var estiramiento := 1.0
var tiempo := 0.0


func configurar(aspecto, perfil_nuevo: Dictionary) -> void:
	perfil = perfil_nuevo
	pivote = Node3D.new()
	add_child(pivote)
	var receta: Dictionary = perfil.receta
	if receta.get("detallado", false) and ModeloCriatura.tiene_modelo(int(receta.id)):
		criatura = ModeloCriatura.new()
	else:
		criatura = CriaturaModular.new()
	criatura.configurar(aspecto, receta)
	pivote.add_child(criatura)
	if perfil.get("flota", false):
		pivote.position.y = 0.6
	aviso = Label3D.new()
	aviso.text = "!"
	aviso.font_size = 96
	aviso.pixel_size = 0.006
	aviso.outline_size = 18
	aviso.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	aviso.no_depth_test = true
	aviso.position.y = 2.2 if String(receta.tamano) != "S" else 1.5
	aviso.visible = false
	add_child(aviso)


func actualizar(delta: float, info: Dictionary) -> void:
	tiempo += delta
	var mirando: Vector3 = info.mirando
	angulo = lerp_angle(angulo, atan2(mirando.x, mirando.z), minf(1.0, delta * 12.0))
	pivote.rotation.y = angulo
	var objetivo_inclinacion := 0.0
	var objetivo_estiramiento := 1.0
	match String(info.pose):
		"preparando":
			objetivo_inclinacion = -0.22          # se echa atrás: anticipación
			objetivo_estiramiento = 0.92
		"estocada":
			objetivo_inclinacion = 0.35           # se lanza hacia delante
			objetivo_estiramiento = 1.08
		"reverencia":
			objetivo_inclinacion = 0.7
		"aturdido":
			objetivo_inclinacion = -0.12 + sin(tiempo * 18.0) * 0.08
	inclinacion = lerpf(inclinacion, objetivo_inclinacion, minf(1.0, delta * 16.0))
	estiramiento = lerpf(estiramiento, objetivo_estiramiento, minf(1.0, delta * 16.0))
	pivote.rotation.x = inclinacion
	pivote.scale = Vector3(1.0 / sqrt(estiramiento), estiramiento, 1.0 / sqrt(estiramiento))
	var muerte: float = info.muerte
	if muerte >= 0.0:
		# Se encoge y se hunde mientras sale el polvo de píxeles.
		pivote.scale *= maxf(0.01, 1.0 - muerte)
		pivote.position.y = -muerte * 0.4 + (0.6 if perfil.get("flota", false) else 0.0)
	if criatura.has_method("poner_destello"):
		criatura.poner_destello(info.destello)
	elif info.destello > 0.0:
		pivote.scale *= 1.0 + info.destello * 0.08
	criatura.actualizar(delta, 1.0 if info.moviendose or info.pose != "normal" else 0.3)
	aviso.visible = info.aviso and int(tiempo * 12.0) % 2 == 0
	aviso.text = "!!" if info.rojo else "!"
	aviso.modulate = Color(1.0, 0.18, 0.12) if info.rojo else Color(1.0, 0.92, 0.6)
	aviso.outline_modulate = Color(0.15, 0.0, 0.0) if info.rojo else Color(0.1, 0.07, 0.0)
