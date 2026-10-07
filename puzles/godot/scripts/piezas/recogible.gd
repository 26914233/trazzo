# Objeto que se guarda en el inventario al tocarlo: vuela hacia la cámara, se encoge y aparece
# como icono abajo. «modelo» es su parte visible (sirve también para dibujar el icono).
class_name PiezaRecogible
extends Pieza

var nombre_objeto := ""
var modelo: Node3D
var recogido := false


func tocar() -> void:
	if recogido:
		return
	if not puede():
		rechazar()
		return
	recogido = true
	habilitada = false
	if mesa:
		mesa.sonido.sonar("recoger")
		mesa.vibrar(22, 0.5)
		mesa.agregar_objeto(id, nombre_objeto, modelo if modelo else self)
	controla_transform = false
	var camara: Camera3D = mesa.camara.camara if mesa else get_viewport().get_camera_3d()
	var destino := camara.global_transform * Vector3(0.0, -0.09, -0.22)
	var animacion := create_tween().set_parallel()
	animacion.tween_property(self, "global_position", destino, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	animacion.tween_property(self, "scale", Vector3.ONE * 0.05, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	animacion.chain().tween_callback(hide)
	accionada.emit(self)
