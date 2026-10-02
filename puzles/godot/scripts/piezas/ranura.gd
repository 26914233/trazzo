# Hueco donde encaja un objeto del inventario: se elige el objeto abajo y se toca la ranura.
# «colocado» es el modelo que aparece dentro al encajarlo (oculto hasta entonces).
class_name PiezaRanura
extends Pieza

var acepta := ""                      # id del objeto que encaja
var colocado: Node3D
var desde := Vector3(0.0, 0.0, 0.03)  # de dónde entra el modelo al encajarlo (local)
var aviso_vacia := "Aquí encaja algo."
var aviso_otro := "Eso no encaja aquí."
var sonido_encajar := "encajar"
var llena := false


func tocar() -> void:
	if llena:
		return
	if not puede():
		rechazar()
		return
	var elegido: String = mesa.seleccionado
	if elegido == "":
		mesa.sonido.sonar("toque", -6.0)
		mesa.mensaje(aviso_vacia if acepta == "" or not mesa.tiene(acepta) else
			"Elige abajo lo que quieres poner y vuelve a tocar.")
		return
	if elegido != acepta:
		rechazar()
		mesa.mensaje(aviso_otro)
		return
	llenar()


# También para el guion y la prueba automática
func llenar() -> void:
	if llena:
		return
	llena = true
	habilitada = false
	if mesa:
		mesa.quitar_objeto(acepta)
		mesa.sonido.sonar(sonido_encajar)
		mesa.vibrar(30, 0.7)
	if colocado:
		var final := colocado.position
		colocado.position = final + desde
		colocado.show()
		var animacion := create_tween()
		animacion.tween_property(colocado, "position", final, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	accionada.emit(self)
