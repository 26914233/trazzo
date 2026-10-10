# Tapa o puerta con bisagra: se abre arrastrándola o tocándola. El nodo está en el eje de la
# bisagra y la geometría cuelga de él. Al soltarla se queda abierta si pasó de la mitad.
class_name PiezaBisagra
extends PiezaGiratoria

var abierto := 1.6                     # ángulo de apertura (con signo)
var sonido_abrir := "bisagra"
var sonido_cerrar := "tope_madera"


func configurar_bisagra(eje_nuevo: Vector3, angulo_abierto: float) -> PiezaBisagra:
	eje = eje_nuevo.normalized()
	abierto = angulo_abierto
	minimo = minf(0.0, angulo_abierto)
	maximo = maxf(0.0, angulo_abierto)
	paso = 0.0
	sonido_tope = ""
	return self


func abierta() -> bool:
	return absf(reposo - abierto) < 0.01


func empezar_arrastre(punto: Vector3, camara: Camera3D) -> void:
	super.empezar_arrastre(punto, camara)
	if puede() and not abierta():
		mesa.sonido.sonar(sonido_abrir, -4.0)


func soltar() -> void:
	var destino := abierto if absf(angulo) > absf(abierto) * 0.45 else 0.0
	_ir_a(destino, 0.35)


func tocar() -> void:
	if not puede():
		rechazar()
		return
	if abierta():
		cerrar()
	else:
		abrir()


func abrir(duracion := 0.9) -> void:
	if mesa:
		mesa.sonido.sonar(sonido_abrir, -2.0)
	_ir_a(abierto, duracion)


func cerrar(duracion := 0.5) -> void:
	_ir_a(0.0, duracion)


func _girar(cambio: float) -> void:
	angulo = clampf(angulo + cambio, minimo, maximo)


func _llegar(destino: float) -> void:
	angulo = destino
	if absf(destino - reposo) < 0.0001:
		return
	reposo = destino
	if mesa:
		mesa.sonido.sonar(sonido_cerrar if destino == 0.0 else "tope_madera", -6.0)
		mesa.vibrar(18, 0.5)
	accionada.emit(self)
