# Punto de entrada: el gabinete (menú en 3D con los cuatro juegos y sus cajas) y, al elegir una caja,
# su mesa de puzle. Al salir o terminar una caja se vuelve a la lista de cajas de ese juego.
# Argumentos (después de «--»):
#   --prueba                 prueba automática: resuelve las cajas jugables y guarda capturas
#   --caja=<id>              abre esa caja directamente (caja_viva, relojero, reliquia, farero)
#   --juego=<id>             abre el gabinete en la lista de cajas de ese juego
extends Node

const Catalogo := preload("res://scripts/catalogo.gd")
const Gabinete := preload("res://scripts/gabinete.gd")
const Mesa := preload("res://scripts/mesa.gd")
const Prueba := preload("res://scripts/prueba.gd")

var actual: Node
var resultados := ConfigFile.new()
var _fundido: ColorRect
var _cambiando := false


func _ready() -> void:
	resultados.load("user://resultados.cfg")
	var capa := CanvasLayer.new()
	capa.layer = 100
	add_child(capa)
	_fundido = ColorRect.new()
	_fundido.color = Color.BLACK
	_fundido.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fundido.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fundido.modulate.a = 1.0
	capa.add_child(_fundido)
	var argumentos := OS.get_cmdline_user_args()
	if "--prueba" in argumentos:
		_fundido.modulate.a = 0.0
		var prueba := Prueba.new()
		prueba.principal = self
		add_child(prueba)
		return
	for argumento in argumentos:
		if argumento.begins_with("--caja=") or argumento.begins_with("--prototipo="):
			abrir_caja(argumento.get_slice("=", 1))
			_aclarar()
			return
		if argumento.begins_with("--juego="):
			abrir_gabinete("cajas", argumento.get_slice("=", 1))
			_aclarar()
			return
	abrir_gabinete("portada")
	_aclarar(1.2)


func abrir_gabinete(pantalla := "portada", juego := "") -> Node:
	var gabinete := Gabinete.new()
	gabinete.resultados = resultados
	gabinete.pantalla_inicial = pantalla
	gabinete.juego_inicial = juego
	gabinete.elegida.connect(func(id: String): _con_fundido(abrir_caja.bind(id)))
	_cambiar(gabinete)
	return gabinete


func abrir_caja(id: String, con_entrada := true) -> Node:
	var datos := Catalogo.caja(id)
	if datos.is_empty() or not Catalogo.jugable(datos):
		push_error("Caja desconocida o sellada: %s" % id)
		return abrir_gabinete("portada")
	var mesa := Mesa.new()
	mesa.datos = datos
	mesa.con_entrada = con_entrada
	mesa.salir.connect(func(): _con_fundido(abrir_gabinete.bind("cajas", datos.juego)))
	mesa.repetir.connect(func(): _con_fundido(abrir_caja.bind(id)))
	mesa.terminado.connect(_guardar_resultado)
	_cambiar(mesa)
	return mesa


func _cambiar(nodo: Node) -> void:
	if actual:
		actual.queue_free()
	actual = nodo
	add_child(nodo)


# Funde a negro, cambia de pantalla y vuelve a aclarar
func _con_fundido(accion: Callable) -> void:
	if _cambiando:
		return
	_cambiando = true
	var animacion := create_tween()
	animacion.tween_property(_fundido, "modulate:a", 1.0, 0.35)
	await animacion.finished
	accion.call()
	await get_tree().process_frame
	_cambiando = false
	_aclarar()


func _aclarar(duracion := 0.7) -> void:
	create_tween().tween_property(_fundido, "modulate:a", 0.0, duracion)


# Guarda el mejor tiempo de cada caja (y cuántas pistas usó), para enseñarlo en el gabinete
func _guardar_resultado(id: String, segundos: float, pistas: int) -> void:
	var mejor: float = resultados.get_value(id, "mejor_tiempo", INF)
	if segundos < mejor:
		resultados.set_value(id, "mejor_tiempo", segundos)
		resultados.set_value(id, "pistas_mejor", pistas)
	resultados.set_value(id, "veces", int(resultados.get_value(id, "veces", 0)) + 1)
	resultados.set_value(id, "ultimo_tiempo", segundos)
	resultados.set_value(id, "ultimas_pistas", pistas)
	resultados.save("user://resultados.cfg")
