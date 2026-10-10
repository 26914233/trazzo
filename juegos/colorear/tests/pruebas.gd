# Pruebas del juego de colorear. Se ejecutan como escena (autoloads cargados):
#
#   godot --headless --path juegos/colorear res://tests/pruebas.tscn
#
# Sale con codigo 0 si todo pasa y 1 si algo falla.
extends Node

var _fallos := 0
var _total := 0
var _actual := ""


func _ready() -> void:
	# Las pruebas no deben pisar las obras ni los ajustes reales.
	Obras.carpeta = "user://prueba_obras/"
	_vaciar(Obras.carpeta)
	DirAccess.make_dir_recursive_absolute(Obras.carpeta)
	Ajustes.ruta = "user://prueba_ajustes.json"

	prueba_indice()
	prueba_regiones_sin_perdida()
	prueba_pintar_y_deshacer()
	prueba_trazos()
	prueba_arrastrar_pinta()
	prueba_datos_de_obra()
	prueba_obras()
	prueba_vista()
	prueba_paletas()
	prueba_integridad()
	await prueba_pantallas()

	_vaciar(Obras.carpeta)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Ajustes.ruta))
	print("\n%d/%d comprobaciones correctas" % [_total - _fallos, _total])
	if _fallos > 0:
		print("FALLAN %d" % _fallos)
	get_tree().quit(1 if _fallos > 0 else 0)


func comprobar(cond: bool, que: String) -> void:
	_total += 1
	if not cond:
		_fallos += 1
		printerr("  FALLO [%s] %s" % [_actual, que])


func caso(nombre: String) -> void:
	_actual = nombre
	print("- " + nombre)


func _vaciar(carpeta: String) -> void:
	if not DirAccess.dir_exists_absolute(carpeta):
		return
	for f in DirAccess.get_files_at(carpeta):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(carpeta.path_join(f)))


func prueba_indice() -> void:
	caso("indice de laminas")
	comprobar(Laminas.categorias.size() >= 4, "hay categorias")
	var faltan := []
	var ids := {}
	for c in Laminas.categorias:
		comprobar(not c["laminas"].is_empty(), "%s tiene laminas" % c["id"])
		for l in c["laminas"]:
			if ids.has(l["id"]):
				faltan.append("repetida " + l["id"])
			ids[l["id"]] = true
			for parte in ["lineas", "regiones", "mini"]:
				if not ResourceLoader.exists(Laminas.ruta(l["id"], parte)):
					faltan.append(Laminas.ruta(l["id"], parte))
			if int(l["zonas"]) < 2 or int(l["zonas"]) > 4095:
				faltan.append("zonas fuera de rango " + l["id"])
	comprobar(faltan.is_empty(), "todas las imagenes existen y sin ids repetidos %s" % str(faltan.slice(0, 3)))
	comprobar(Laminas.total() == ids.size(), "total coincide")
	var primera: String = Laminas.categorias[0]["laminas"][0]["id"]
	comprobar(Laminas.nombre(primera) == Laminas.categorias[0]["nombre"] + " 1", "nombre legible: %s" % Laminas.nombre(primera))
	comprobar(Laminas.total() >= 500, "más de 500 láminas (%d)" % Laminas.total())


## Si Godot comprimiera las regiones con perdida, los ids se romperian: se
## recorre la imagen entera de varias laminas y el id mas alto debe ser el
## numero de zonas del indice, sin ids de mas.
func prueba_regiones_sin_perdida() -> void:
	caso("regiones importadas sin perdida")
	for c in Laminas.categorias:
		var info: Dictionary = c["laminas"][0]
		var l := Laminas.abrir(info["id"])
		comprobar(l != null and not l.regiones.is_compressed(), "%s sin comprimir" % info["id"])
		var vistos := {}
		var img := l.regiones
		for y in range(0, img.get_height(), 3):
			for x in range(0, img.get_width(), 3):
				var p := img.get_pixel(x, y)
				vistos[p.r8 + p.g8 * 256] = true
		var maximo: int = vistos.keys().max()
		comprobar(maximo == l.zonas, "%s: id maximo %d = %d zonas" % [info["id"], maximo, l.zonas])
		comprobar(not vistos.has(0), "%s: ningun pixel sin zona" % info["id"])


func prueba_pintar_y_deshacer() -> void:
	caso("pintar, deshacer y rehacer")
	var l := Laminas.abrir("mandalas_001")
	var rojo := Color.html("#F94144")
	var azul := Color.html("#277DA1")
	var z := l.zona_en(Vector2i(640, 640))
	comprobar(z > 0, "el centro tiene zona")
	comprobar(l.zona_en(Vector2i(-1, 5)) == 0 and l.zona_en(Vector2i(5000, 5)) == 0, "fuera de la imagen: ninguna")
	comprobar(not l.puede_deshacer(), "recien abierta no hay nada que deshacer")
	comprobar(l.pintar(z, rojo), "pinta")
	comprobar(l.paleta.get_pixel(z % 64, z / 64) == rojo, "la paleta del shader cambia")
	comprobar(not l.pintar(z, rojo), "mismo color: no cuenta como cambio")
	comprobar(not l.pintar(0, rojo) and not l.pintar(l.zonas + 1, rojo), "zonas invalidas no se pintan")
	l.pintar(z, azul)
	comprobar(l.deshacer() and l.colores[z] == rojo, "deshacer vuelve al color anterior")
	comprobar(l.deshacer() and l.colores[z] == Color.WHITE, "y al blanco")
	comprobar(not l.deshacer(), "no hay mas")
	comprobar(l.rehacer() and l.colores[z] == rojo, "rehacer")
	l.pintar(1, azul)
	comprobar(not l.puede_rehacer(), "pintar algo nuevo borra el rehacer")
	comprobar(is_equal_approx(l.avance(), 2.0 / l.zonas), "avance = zonas pintadas / total")


func prueba_trazos() -> void:
	caso("pintar arrastrando: un trazo = un paso de deshacer")
	var l := Laminas.abrir("mandalas_001")
	var rojo := Color.html("#F94144")
	l.empezar_trazo()
	for z in [3, 4, 5, 6]:
		l.pintar(z, rojo)
	l.terminar_trazo()
	comprobar(l.colores[3] == rojo and l.colores[6] == rojo, "el trazo pinta todas sus zonas")
	comprobar(l.deshacer(), "se deshace")
	comprobar(l.colores[3] == Color.WHITE and l.colores[6] == Color.WHITE, "un solo deshacer quita el trazo entero")
	comprobar(l.rehacer() and l.colores[5] == rojo, "y se rehace entero")
	l.empezar_trazo()
	l.pintar(10, rojo)
	l.pintar(3, Color.html("#277DA1"))
	l.cancelar_trazo()
	comprobar(l.colores[10] == Color.WHITE and l.colores[3] == rojo, "cancelar (segundo dedo) devuelve los colores de antes")
	l.empezar_trazo()
	l.terminar_trazo()
	comprobar(l.deshacer() and l.colores[3] == Color.WHITE, "un trazo vacío no ocupa un paso")


func _tocar(v: Control, idx: int, p: Vector2, pulsado: bool) -> void:
	var e := InputEventScreenTouch.new()
	e.index = idx
	e.position = p
	e.pressed = pulsado
	v._gui_input(e)


func _arrastrar(v: Control, idx: int, p: Vector2) -> void:
	var e := InputEventScreenDrag.new()
	e.index = idx
	e.position = p
	v._gui_input(e)


func prueba_arrastrar_pinta() -> void:
	caso("vista: el dedo pinta lo que recorre; dos dedos no pintan")
	var v := VistaLamina.new()
	add_child(v)
	v.size = Vector2(1000, 1000)
	var l := Laminas.abrir("mandalas_001")
	v.mostrar(l)
	var color := Color.html("#43AA8B")
	v.zona_tocada.connect(func(z): l.pintar(z, color))
	v.trazo_empezado.connect(l.empezar_trazo)
	v.trazo_terminado.connect(l.terminar_trazo)
	v.trazo_cancelado.connect(l.cancelar_trazo)
	_tocar(v, 0, Vector2(100, 500), true)
	_arrastrar(v, 0, Vector2(900, 500))
	_tocar(v, 0, Vector2(900, 500), false)
	var pintadas := 0
	for z in range(1, l.zonas + 1):
		if l.colores[z] == color:
			pintadas += 1
	comprobar(pintadas >= 8, "un arrastre de lado a lado pinta muchas zonas (%d)" % pintadas)
	comprobar(l.deshacer() and l.avance() == 0.0, "y se deshace de una vez")
	_tocar(v, 0, Vector2(200, 200), true)
	_tocar(v, 1, Vector2(600, 600), true)
	_arrastrar(v, 1, Vector2(800, 800))
	_tocar(v, 1, Vector2(800, 800), false)
	_tocar(v, 0, Vector2(200, 200), false)
	comprobar(l.avance() == 0.0, "al poner el segundo dedo no queda nada pintado")
	comprobar(v.zoom > 1.0, "y los dos dedos hacen zoom")

	caso("modo tocar: solo la zona tocada; arrastrar mueve")
	v.reiniciar_zoom()
	v.arrastrar_pinta = false
	_tocar(v, 0, Vector2(500, 500), true)
	_tocar(v, 0, Vector2(500, 500), false)
	var z := l.zona_en(v.a_lamina(Vector2(500, 500)))
	comprobar(l.colores[z] == color and is_equal_approx(l.avance(), 1.0 / l.zonas), "tocar rellena una sola zona")
	comprobar(l.deshacer() and l.avance() == 0.0, "y se deshace")
	v.ampliar(3.0, Vector2(500, 500))
	var antes := v.desplazamiento
	_tocar(v, 0, Vector2(300, 500), true)
	_arrastrar(v, 0, Vector2(500, 500))
	_tocar(v, 0, Vector2(500, 500), false)
	comprobar(l.avance() == 0.0, "arrastrar no pinta")
	comprobar(v.desplazamiento != antes, "arrastrar mueve el dibujo ampliado")
	v.queue_free()


func prueba_datos_de_obra() -> void:
	caso("guardar los colores de una obra")
	var l := Laminas.abrir("vitrales_001")
	l.pintar(3, Color.html("#0A9396"))
	l.pintar(7, Color.html("#EE9B00"))
	var d := l.a_datos()
	comprobar(d["colores"].size() == 2, "solo se guardan las zonas pintadas")
	var otra := Laminas.abrir("vitrales_001")
	otra.desde_datos(JSON.parse_string(JSON.stringify(d)))
	comprobar(otra.colores[3] == l.colores[3] and otra.colores[7] == l.colores[7], "ida y vuelta por JSON")
	comprobar(not otra.puede_deshacer(), "al cargar no hay historial que deshacer")
	var mala := Laminas.abrir("vitrales_001")
	mala.desde_datos({"colores": {"0": "#FF0000", "99999": "#FF0000", "-3": "#FF0000", "5": "no-es-color", "6": "#00FF00"}})
	comprobar(mala.colores[0] == Color.WHITE and mala.colores[5] == Color.WHITE, "ids y colores invalidos se ignoran")
	comprobar(mala.colores[6] == Color.html("#00FF00"), "los validos entran")
	mala.desde_datos({"colores": "basura"})
	comprobar(true, "datos con otro tipo no revientan")


func prueba_obras() -> void:
	caso("mis obras")
	var l := Laminas.abrir("flores_001")
	Obras.guardar(l)
	comprobar(not Obras.tiene("flores_001"), "abrir y salir sin pintar no crea obra")
	var z := l.zona_en(Vector2i(10, 10))
	l.pintar(z, Color.html("#F94144"))
	Obras.guardar(l)
	comprobar(Obras.tiene("flores_001"), "al pintar se guarda")
	comprobar(Obras.lista() == ["flores_001"], "aparece en la lista")
	var otra := Laminas.abrir("flores_001")
	Obras.cargar_en(otra)
	comprobar(otra.colores[z] == Color.html("#F94144"), "se recupera al volver a abrir")
	var mini := Obras.miniatura(otra)
	comprobar(mini.get_width() == Obras.MINI, "miniatura de 320")
	comprobar(mini.get_pixel(2, 2).r > 0.8 and mini.get_pixel(2, 2).g < 0.5, "la miniatura lleva el color")
	comprobar(Obras.textura_mini("flores_001") != null and Obras.textura_mini("mandalas_003") != null, "miniaturas con y sin obra")
	var f := FileAccess.open(Obras.carpeta + "flores_001.json", FileAccess.WRITE)
	f.store_string("{roto")
	f.close()
	var tercera := Laminas.abrir("flores_001")
	Obras.cargar_en(tercera)
	comprobar(tercera.colores[z] == Color.WHITE, "obra ilegible: se abre en blanco sin romper")
	Obras.borrar("flores_001")
	comprobar(Obras.lista().is_empty(), "borrar")


func prueba_vista() -> void:
	caso("vista: zoom y coordenadas")
	var v := VistaLamina.new()
	add_child(v)
	v.size = Vector2(1000, 1200)
	v.mostrar(Laminas.abrir("mandalas_001"))
	comprobar(v.desplazamiento == Vector2(0, 100), "centrada en vertical")
	comprobar(v.a_lamina(Vector2(500, 600)) == Vector2i(640, 640), "centro de la vista = centro de la lamina")
	v.ampliar(100.0, Vector2(500, 600))
	comprobar(v.zoom == VistaLamina.ZOOM_MAX, "zoom con tope")
	comprobar(v.a_lamina(Vector2(500, 600)).distance_to(Vector2i(640, 640)) < 2, "el punto bajo los dedos no se mueve al ampliar")
	v.ampliar(0.001, Vector2(0, 0))
	comprobar(v.zoom == 1.0 and v.desplazamiento == Vector2(0, 100), "alejar al minimo vuelve a centrar")
	v.queue_free()


func prueba_paletas() -> void:
	caso("paletas")
	for i in Paletas.LISTA.size():
		var cols := Paletas.colores(i)
		comprobar(cols.size() == 12, "%s tiene 12 colores" % Paletas.nombre(i))
		comprobar(not Color.WHITE in cols, "%s sin blanco (es la goma)" % Paletas.nombre(i))
	comprobar(Paletas.nombre(Paletas.LISTA.size()) == Paletas.nombre(0), "da la vuelta")


func prueba_integridad() -> void:
	caso("antipirateria")
	comprobar(Integridad.evaluar(true, true, "com.android.vending") == "ok", "desde Play: juega")
	comprobar(Integridad.evaluar(true, true, "com.google.android.packageinstaller") == "copia", "APK a mano: bloquea")
	comprobar(Integridad.evaluar(true, true, null) == "desconocido", "sin respuesta: deja jugar")
	comprobar(Integridad.evaluar(false, true, "") == "ok", "fuera de Android release: no aplica")


class ContadorErrores extends Logger:
	var errores: Array[String] = []
	func _log_error(_f: String, file: String, line: int, code: String, rationale: String, _n: bool, tipo: int, _bt: Array[ScriptBacktrace]) -> void:
		if tipo != ERROR_TYPE_WARNING:
			errores.append("%s:%d %s %s" % [file, line, code, rationale])
	func _log_message(_m: String, _e: bool) -> void:
		pass


func prueba_pantallas() -> void:
	caso("las pantallas cargan sin errores en los 3 diseños")
	var log := ContadorErrores.new()
	OS.add_logger(log)
	for id in Estilo.VARIANTES:
		Estilo.aplicar(id)
		for nombre in ["menu", "colorear", "copia_no_valida"]:
			var escena: Node = load("res://escenas/%s.tscn" % nombre).instantiate()
			add_child(escena)
			for i in 3:
				await get_tree().process_frame
			escena.queue_free()
			await get_tree().process_frame
	OS.remove_logger(log)
	comprobar(log.errores.is_empty(), "sin errores: %s" % str(log.errores.slice(0, 3)))
	Estilo.aplicar("cielo")
