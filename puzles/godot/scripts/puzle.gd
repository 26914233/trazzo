# Base de cada prototipo: construye la escena, define los pasos con sus tres pistas y decide qué
# desbloquea cada acción. Las clases hijas rellenan construir(), preparar_camara(),
# preparar_entorno(), resolver_paso() (para la prueba automática) y final().
class_name Puzle
extends Node3D

var mesa
var pasos: Array = []                 # [{id, pistas: [tres textos], pieza: id de la pieza que se resalta}]
var hechos := {}
var piezas := {}
var titulo_final := "Abierta"
var texto_final := ""


func construir() -> void:
	pass


func preparar_camara(_camara: CamaraPuzle) -> void:
	pass


func preparar_entorno(_entorno: Environment) -> void:
	pass


# Al empezar: ambiente sonoro, primer mensaje
func empezar() -> void:
	pass


func actualizar(_delta: float) -> void:
	pass


# Hace lo necesario para completar ese paso (solo la prueba automática)
func resolver_paso(_id: String) -> void:
	pass


# Animación del final (puede esperar con await); después se enseña el resumen
func final() -> void:
	pass


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


# --- Piezas ----------------------------------------------------------------------------------

func agregar(pieza: Pieza, padre: Node3D = null) -> Pieza:
	pieza.mesa = mesa
	piezas[pieza.id] = pieza
	if pieza.get_parent() == null:
		(padre if padre else self).add_child(pieza)
	return pieza
