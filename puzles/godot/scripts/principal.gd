# Punto de entrada: el menú con los cuatro prototipos y, al elegir uno, su mesa de puzle.
# Argumentos (después de «--»):
#   --prueba                 prueba automática: resuelve los cuatro y guarda capturas
#   --prototipo=<id>         abre ese prototipo directamente (caja_viva, relojero, reliquia, farero)
extends Node

const Catalogo := preload("res://scripts/catalogo.gd")
const Menu := preload("res://scripts/menu.gd")
const Mesa := preload("res://scripts/mesa.gd")
const Prueba := preload("res://scripts/prueba.gd")

var actual: Node
var resultados := ConfigFile.new()


func _ready() -> void:
	resultados.load("user://resultados.cfg")
	var argumentos := OS.get_cmdline_user_args()
	if "--prueba" in argumentos:
		var prueba := Prueba.new()
		prueba.principal = self
		add_child(prueba)
		return
	for argumento in argumentos:
		if argumento.begins_with("--prototipo="):
			abrir_prototipo(argumento.get_slice("=", 1))
			return
	abrir_menu()


func abrir_menu() -> void:
	var menu := Menu.new()
	menu.resultados = resultados
	menu.elegido.connect(abrir_prototipo)
	_cambiar(menu)


func abrir_prototipo(id: String) -> Node:
	var datos := Catalogo.buscar(id)
	if datos.is_empty():
		push_error("Prototipo desconocido: %s" % id)
		abrir_menu()
		return null
	var mesa := Mesa.new()
	mesa.datos = datos
	mesa.salir.connect(abrir_menu)
	mesa.repetir.connect(abrir_prototipo.bind(id))
	mesa.terminado.connect(_guardar_resultado)
	_cambiar(mesa)
	return mesa


func _cambiar(nodo: Node) -> void:
	if actual:
		actual.queue_free()
	actual = nodo
	add_child(nodo)


# Guarda el mejor tiempo de cada prototipo (y cuántas pistas usó), para enseñarlo en el menú
func _guardar_resultado(id: String, segundos: float, pistas: int) -> void:
	var mejor: float = resultados.get_value(id, "mejor_tiempo", INF)
	if segundos < mejor:
		resultados.set_value(id, "mejor_tiempo", segundos)
		resultados.set_value(id, "pistas_mejor", pistas)
	resultados.set_value(id, "veces", int(resultados.get_value(id, "veces", 0)) + 1)
	resultados.set_value(id, "ultimo_tiempo", segundos)
	resultados.set_value(id, "ultimas_pistas", pistas)
	resultados.save("user://resultados.cfg")
