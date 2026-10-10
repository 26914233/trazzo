# Base de cada caja: construye la escena, define los pasos con sus tres pistas, las zonas a las que
# se acerca la cámara con el doble toque y el recorrido de entrada por la habitación. Las clases
# hijas rellenan construir_sala(), construir(), preparar_camara(), preparar_entorno(),
# ruta_entrada(), resolver_paso() (para la prueba automática) y final().
# En el menú, el mismo guion monta solo el objeto («vitrina»), sin habitación ni mesa.
class_name Puzle
extends Node3D

var mesa
var vitrina := false                  # true: solo el objeto, para el gabinete del menú
var pasos: Array = []                 # [{id, pistas: [tres textos], pieza: id de la pieza que se resalta}]
var hechos := {}
var piezas := {}
var zonas: Array = []                 # [{id, centro, distancia, guinada, cabeceo, radio}]
var titulo_final := "Abierta"
var texto_final := ""
var _insistencia := {"pieza": null, "veces": 0, "ms": 0}


# La habitación donde está la caja (no se monta en la vitrina del menú)
func construir_sala() -> void:
	pass


# El objeto del puzle con todas sus piezas
func construir() -> void:
	pass


func preparar_camara(_camara: CamaraPuzle) -> void:
	pass


func preparar_entorno(_entorno: Environment) -> void:
	pass


# Recorrido de la cámara al entrar: {puntos: [Vector3], miradas: [Vector3], duracion, fov}.
# El último tramo, hasta la vista de partida, lo añade la cámara.
func ruta_entrada() -> Dictionary:
	return {}


# Cuando empieza la entrada (abrir la puerta, el ambiente sonoro…)
func empezar() -> void:
	pass


# Cuando la cámara llega a la caja y empieza el juego
func al_llegar() -> void:
	pass


func actualizar(_delta: float) -> void:
	pass


# En el gabinete del menú: pequeñas animaciones del objeto («activa»: es el que se está mirando)
func animar_vitrina(_delta: float, _camara: Camera3D, _activa: bool) -> void:
	pass


# Hace lo necesario para completar ese paso (solo la prueba automática)
func resolver_paso(_id: String) -> void:
	pass


# Animación del final (puede esperar con await); después se enseña el resumen
func final() -> void:
	pass


# --- Resistencia ------------------------------------------------------------------------------

# Cómo se resiste el objeto cuando una pieza no se deja (la pieza ni se mueve ni se marca). Cada caja
# pone la suya; la de por defecto deja caer un poco de polvo de donde tocaste.
# «veces»: intentos seguidos sobre la misma pieza (1, 2, 3...), para que la reacción vaya a más.
func resistir(_pieza: Pieza, punto: Vector3, _veces: int) -> void:
	Efectos.polvo(self, punto)


# Cuenta los intentos seguidos sobre la misma pieza; se olvidan tras cinco segundos sin insistir
func insistencia(pieza: Pieza) -> int:
	var ahora := Time.get_ticks_msec()
	if _insistencia.pieza == pieza and ahora - int(_insistencia.ms) < 5000:
		_insistencia.veces += 1
	else:
		_insistencia = {"pieza": pieza, "veces": 1, "ms": ahora}
	_insistencia.ms = ahora
	return _insistencia.veces


# --- Pasos -----------------------------------------------------------------------------------

func paso(id: String, pistas: Array, pieza := "") -> void:
	pasos.append({"id": id, "pistas": pistas, "pieza": pieza})


func completar(id: String) -> void:
	if hechos.has(id):
		return
	hechos[id] = true
	mesa.paso_hecho(id)
	if hechos.size() >= pasos.size():
		mesa.terminar()


func hecho(id: String) -> bool:
	return hechos.has(id)


func paso_actual() -> Dictionary:
	for datos in pasos:
		if not hechos.has(datos.id):
			return datos
	return {}


# Para la prueba automática: espera a que la cámara llegue a donde se le pidió (máximo 4 s)
func esperar_camara() -> void:
	var fin := Time.get_ticks_msec() + 4000
	await get_tree().process_frame
	while not mesa.camara.quieta() and Time.get_ticks_msec() < fin:
		await get_tree().process_frame


# --- Zonas de cerca (doble toque) ------------------------------------------------------------

# Una zona: si el doble toque cae a menos de «radio» de «centro», la cámara viaja a mirarla desde
# «distancia», con esa guiñada y ese cabeceo (NAN: los deja como estén). Coordenadas del puzle.
func zona(id: String, centro: Vector3, distancia: float, guinada := NAN, cabeceo := NAN, radio := 0.07) -> void:
	zonas.append({"id": id, "centro": centro, "distancia": distancia, "guinada": guinada, "cabeceo": cabeceo,
		"radio": radio})


# La zona más cercana a un punto del mundo (vacío si no cae en ninguna)
func zona_en(punto: Vector3) -> Dictionary:
	var local := to_local(punto)
	var mejor := {}
	var mejor_distancia := INF
	for datos in zonas:
		var d: float = local.distance_to(datos.centro)
		if d <= datos.radio and d < mejor_distancia:
			mejor = datos
			mejor_distancia = d
	if mejor.is_empty():
		return {}
	var resultado := mejor.duplicate()
	resultado.centro = to_global(mejor.centro)
	return resultado


# --- Piezas ----------------------------------------------------------------------------------

func agregar(pieza: Pieza, padre: Node3D = null) -> Pieza:
	pieza.mesa = mesa
	piezas[pieza.id] = pieza
	if pieza.get_parent() == null:
		(padre if padre else self).add_child(pieza)
	return pieza
