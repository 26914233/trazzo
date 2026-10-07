# Zona de una habitación que lleva la cámara a un punto de vista (el escritorio, la estantería…).
class_name PiezaPuntoDeVista
extends Pieza

var destino := ""


func interactiva() -> bool:
	return super.interactiva() and mesa != null and mesa.camara.punto_actual != destino


func tocar() -> void:
	if mesa:
		mesa.sonido.sonar("pasos", -8.0)
		mesa.camara.ir_a(destino)
	accionada.emit(self)
