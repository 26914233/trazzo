# Botón que se hunde al tocarlo (y vuelve, salvo que sea «fijo»).
class_name PiezaPulsador
extends Pieza

var eje := Vector3.FORWARD            # hacia dónde se hunde, en el espacio del padre
var recorrido := 0.004
var hundido := 0.0
var fijo := false
var sonido := "clic_metal"
var pulsado := false


func _transform_actual() -> Transform3D:
	return Transform3D(base.basis, base.origin + eje * hundido)


func tocar() -> void:
	if not puede():
		rechazar()
		return
	if fijo and pulsado:
		return
	pulsado = true
	var animacion := create_tween()
	animacion.tween_property(self, "hundido", recorrido, 0.06)
	if not fijo:
		animacion.tween_property(self, "hundido", 0.0, 0.16).set_delay(0.05)
	if mesa:
		mesa.sonido.sonar(sonido, -2.0)
		mesa.vibrar(16, 0.5)
	accionada.emit(self)


func soltar() -> void:
	pass
