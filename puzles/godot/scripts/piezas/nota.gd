# Algo que se lee: carta, diario, placa. Al tocarlo se abre en grande en la pantalla.
class_name PiezaNota
extends Pieza

var titulo := ""
var texto := ""
var leida := false


func tocar() -> void:
	if not puede():
		rechazar()
		return
	if mesa:
		mesa.sonido.sonar("papel", -2.0)
		mesa.nota(titulo, texto)
	if not leida:
		leida = true
		accionada.emit(self)
