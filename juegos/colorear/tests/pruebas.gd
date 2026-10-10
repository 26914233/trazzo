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
	Ajustes.datos["sonido"] = false     # un sonido aun sonando al salir aparece como fuga
	Diario.ruta = "user://prueba_diario.json"
	Diario.cargar()
	Exportar.carpeta_galeria = "user://prueba_galeria/"

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
	prueba_buscar_zona()
	prueba_enfocar()
	prueba_terminada()
	prueba_imagen()
	prueba_lamina_del_dia()
	prueba_racha()
	prueba_terminadas()
	prueba_mis_colores()
	prueba_musica()
	prueba_misterio()
	await prueba_pantallas()
	await prueba_ajustes_menu()
	await prueba_celebracion()
	await prueba_misterio_en_pantalla()

	_vaciar(Obras.carpeta)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Ajustes.ruta))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Diario.ruta))
	_vaciar(Exportar.carpeta_galeria)
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


func prueba_buscar_zona() -> void:
	caso("buscar zona sin pintar")
	var l := Laminas.abrir("mandalas_001")
	comprobar(l.info_zonas.size() == l.zonas * 8, "hay datos de cada zona (8 bytes por zona)")
	var ok := true
	for z in range(1, l.zonas + 1):
		if l.zona_en(l.punto(z)) != z:
			ok = false
	comprobar(ok, "el punto de cada zona cae dentro de ella")
	var c := l.caja(1)
	comprobar(c.x > 0 and c.y > 0 and c.x <= Laminas.lado and c.y <= Laminas.lado, "caja con tamano valido")
	var centro := Vector2(640, 640)
	var z := l.vacia_mas_cercana(centro)
	comprobar(z > 0 and l.colores[z] == Color.WHITE, "devuelve una zona en blanco")
	var mejor := INF
	for k in range(1, l.zonas + 1):
		mejor = minf(mejor, centro.distance_to(Vector2(l.punto(k))))
	comprobar(is_equal_approx(centro.distance_to(Vector2(l.punto(z))), mejor), "la mas cercana al punto dado")
	l.pintar(z, Color.RED)
	comprobar(l.vacia_mas_cercana(centro) != z, "una zona pintada ya no se propone")
	var z2 := l.vacia_mas_cercana(centro)
	comprobar(l.vacia_mas_cercana(centro, {z2: true}) not in [z, z2, 0], "se pueden saltar las ya propuestas")
	for k in range(1, l.zonas + 1):
		l.pintar(k, Color.RED)
	comprobar(l.vacia_mas_cercana(centro) == 0, "todo pintado: ninguna")
	var sin_datos := Lamina.new("x", 3, null, null)
	comprobar(sin_datos.vacia_mas_cercana(centro) == 0 and sin_datos.punto(1) == Vector2i(-1, -1), "sin datos de zonas no falla")
	var faltan := 0
	for cat in Laminas.categorias:
		for lam in cat["laminas"]:
			if not FileAccess.file_exists(Laminas.ruta_zonas(lam["id"])):
				faltan += 1
	comprobar(faltan == 0, "todas las laminas tienen datos de zonas (faltan %d)" % faltan)


func prueba_enfocar() -> void:
	caso("la camara va a la zona")
	var v := VistaLamina.new()
	add_child(v)
	v.size = Vector2(1000, 1200)
	var l := Laminas.abrir("mandalas_001")
	v.mostrar(l)
	var z := 0
	for k in range(1, l.zonas + 1):       # una zona pequena y lejos del centro
		if maxi(l.caja(k).x, l.caja(k).y) < 120 and l.punto(k).x < 400:
			z = k
			break
	comprobar(z > 0, "hay una zona pequena para probar")
	v.enfocar(z, false)
	var p := Vector2(l.punto(z))
	var en_vista := v.desplazamiento + p / Laminas.lado * minf(v.size.x, v.size.y) * v.zoom
	comprobar(Rect2(Vector2.ZERO, v.size).has_point(en_vista), "la zona queda dentro de la vista")
	comprobar(v.zoom > 1.0, "acerca el zoom para verla")
	comprobar(v.resaltada == z, "la zona queda resaltada")
	v.quitar_resalte()
	comprobar(v.resaltada == 0, "el resalte se quita")
	v.enfocar(1, false)
	comprobar(v.zoom >= 1.0 and v.zoom <= VistaLamina.ZOOM_MAX, "zona enorme: zoom dentro de limites")
	v.queue_free()


func prueba_terminada() -> void:
	caso("lamina terminada")
	var l := Laminas.abrir("mandalas_001")
	comprobar(not l.terminada(), "recien abierta no esta terminada")
	for k in range(1, l.zonas):
		l.pintar(k, Color.RED)
	comprobar(not l.terminada(), "falta una zona")
	l.pintar(l.zonas, Color.BLUE)
	comprobar(l.terminada(), "todas pintadas = terminada")
	l.pintar(3, Color.WHITE)
	comprobar(not l.terminada(), "borrar con la goma la deja sin terminar")


func prueba_imagen() -> void:
	caso("guardar imagen")
	var l := Laminas.abrir("mandalas_001")
	var z := l.zona_en(Vector2i(640, 640))
	l.pintar(z, Color.html("#F94144"))
	var img := l.imagen()
	comprobar(img.get_width() == Laminas.lado and img.get_height() == Laminas.lado, "a resolucion completa")
	var p := l.punto(z)
	comprobar(img.get_pixelv(p).is_equal_approx(Color.html("#F94144")), "la zona sale con su color")
	var p2 := l.punto(l.vacia_mas_cercana(Vector2(640, 640)))
	comprobar(img.get_pixelv(p2).is_equal_approx(Color.WHITE), "lo no pintado sale blanco")
	var hay_linea := false
	for x in range(0, Laminas.lado, 7):
		if img.get_pixel(x, 640).v < 0.2:
			hay_linea = true
			break
	comprobar(hay_linea, "las lineas salen oscuras")
	var r := Exportar.guardar(l)
	comprobar(r["ok"] and FileAccess.file_exists(r["ruta"]), "se guarda el PNG: %s" % str(r))
	var leida := Image.load_from_file(r["ruta"]) if r["ok"] else null
	comprobar(leida != null and leida.get_pixelv(p).is_equal_approx(Color.html("#F94144")), "el PNG guardado se lee igual")
	comprobar(str(r["ruta"]).get_file().begins_with("lienzo-zen-mandalas_001"), "nombre con la lamina")


func prueba_lamina_del_dia() -> void:
	caso("lamina del dia")
	var a := Laminas.del_dia("2026-10-10")
	comprobar(Laminas.existe(a), "es una lamina que existe")
	comprobar(Laminas.del_dia("2026-10-10") == a, "el mismo dia, la misma")
	var vistas := {}
	for d in 60:
		vistas[Laminas.del_dia(Time.get_date_string_from_unix_time(1790000000 + d * 86400))] = true
	comprobar(vistas.size() == 60, "60 dias seguidos sin repetir (%d distintas)" % vistas.size())
	var cats := {}
	for d in 7:
		cats[Laminas.categoria_de(Laminas.del_dia(Time.get_date_string_from_unix_time(1790000000 + d * 86400)))] = true
	comprobar(cats.size() >= 4, "una semana pasa por varias categorias (%d)" % cats.size())
	comprobar(Laminas.del_dia("basura") == "" , "fecha invalida: ninguna")


func prueba_racha() -> void:
	caso("racha de laminas del dia")
	Diario.datos = {}
	comprobar(Diario.racha("2026-10-10") == 0, "sin nada: 0")
	Diario.marcar("2026-10-10")
	comprobar(Diario.racha("2026-10-10") == 1, "pintar la del dia: 1")
	Diario.marcar("2026-10-10")
	comprobar(Diario.racha("2026-10-10") == 1, "dos veces el mismo dia no suma")
	Diario.marcar("2026-10-11")
	comprobar(Diario.racha("2026-10-11") == 2, "dia siguiente: 2")
	comprobar(Diario.racha("2026-10-12") == 2, "el dia siguiente sin pintar aun se mantiene")
	Diario.marcar("2026-10-13")
	comprobar(Diario.racha("2026-10-13") == 3, "racha suave: faltar un dia no la rompe")
	comprobar(Diario.racha("2026-10-16") == 0, "faltar dos dias si la rompe")
	Diario.marcar("2026-10-16")
	comprobar(Diario.racha("2026-10-16") == 1 and Diario.mejor() == 3, "empieza de nuevo y guarda la mejor")
	Diario.marcar("2026-09-01")
	comprobar(Diario.racha("2026-10-16") == 1, "una fecha anterior no la altera")
	Diario.cargar()
	comprobar(Diario.racha("2026-10-16") == 1 and Diario.mejor() == 3, "se guarda en disco")
	var f := FileAccess.open(Diario.ruta, FileAccess.WRITE)
	f.store_string("{\"ultimo\": \"no-fecha\", \"racha\": -5, \"mejor\": \"x\"}")
	f.close()
	Diario.cargar()
	comprobar(Diario.racha("2026-10-16") == 0 and Diario.mejor() == 0, "datos rotos: empieza de cero")


func prueba_celebracion() -> void:
	caso("celebracion al terminar")
	var escena_script = load("res://escenas/colorear.gd")
	escena_script.lamina_id = "mandalas_001"
	var e: Control = load("res://escenas/colorear.tscn").instantiate()
	add_child(e)
	await get_tree().process_frame
	for k in range(1, e.lamina.zonas):
		e.lamina.pintar(k, Color.RED)
	comprobar(not e.celebrando(), "sin terminar no celebra")
	e._pintar(e.lamina.zonas)
	comprobar(e.celebrando(), "al pintar la ultima zona celebra")
	e._pintar(e.lamina.zonas)
	e.queue_free()
	await get_tree().process_frame
	Obras.borrar("mandalas_001")


func prueba_terminadas() -> void:
	caso("ocultar laminas terminadas")
	var l := Laminas.abrir("mandalas_002")
	for k in range(1, l.zonas + 1):
		l.pintar(k, Color.RED)
	Obras.guardar(l)
	var m := Laminas.abrir("mandalas_003")
	m.pintar(1, Color.RED)
	Obras.guardar(m)
	comprobar(Obras.terminada("mandalas_002") and not Obras.terminada("mandalas_003"), "sabe cual esta terminada")
	comprobar(not Obras.terminada("mandalas_004"), "sin obra: no terminada")
	Obras.olvidar_cache()
	comprobar(Obras.terminada("mandalas_002") and not Obras.terminada("mandalas_003"), "se lee del disco")
	var ids := ["mandalas_002", "mandalas_003", "mandalas_004"]
	comprobar(Obras.filtrar(ids, true) == ["mandalas_003", "mandalas_004"], "ocultar quita solo las terminadas")
	comprobar(Obras.filtrar(ids, false) == ids, "sin ocultar: todas")
	m.desde_datos({})
	for k in range(1, m.zonas + 1):
		m.pintar(k, Color.BLUE)
	m.pintar(2, Color.WHITE)
	Obras.guardar(m)
	comprobar(not Obras.terminada("mandalas_003"), "borrar una zona la deja sin terminar")
	Obras.borrar("mandalas_002")
	comprobar(not Obras.terminada("mandalas_002"), "al borrar la obra deja de contar")
	Obras.borrar("mandalas_003")


func prueba_mis_colores() -> void:
	caso("mis colores")
	Ajustes.fijar("mis_colores", [])
	comprobar(Ajustes.mis_colores().is_empty(), "empieza vacia")
	Ajustes.agregar_color(Color.html("#123456"))
	Ajustes.agregar_color(Color.html("#123456"))
	comprobar(Ajustes.mis_colores() == [Color.html("#123456")], "sin repetidos")
	for i in 15:
		Ajustes.agregar_color(Color(0.05 * i, 0.5, 0.5))
	comprobar(Ajustes.mis_colores().size() == Ajustes.MAX_COLORES, "tope de %d" % Ajustes.MAX_COLORES)
	comprobar(not Color.html("#123456") in Ajustes.mis_colores(), "al llenarse sale el mas antiguo")
	Ajustes.agregar_color(Color.WHITE)
	comprobar(not Color.WHITE in Ajustes.mis_colores(), "el blanco no (es la goma)")
	var f := FileAccess.open(Ajustes.ruta, FileAccess.WRITE)
	f.store_string('{"mis_colores": ["#ff0000", "basura", 5, "#00ff00"]}')
	f.close()
	Ajustes.cargar()
	Ajustes.datos["sonido"] = false
	comprobar(Ajustes.mis_colores() == [Color.html("#ff0000"), Color.html("#00ff00")], "al leer se descartan los invalidos")
	comprobar(Paletas.MIS_COLORES == Paletas.LISTA.size(), "Mis colores va despues de las curadas")
	Ajustes.fijar("mis_colores", [])


func prueba_musica() -> void:
	caso("musica ambiental")
	Ajustes.fijar("musica", true)
	Sonido.actualizar_musica()
	comprobar(Sonido.musica_activa(), "se enciende")
	comprobar((Sonido.MUSICA as AudioStreamOggVorbis).loop, "en bucle")
	Ajustes.fijar("musica", false)
	Sonido.actualizar_musica(true)
	comprobar(not Sonido.musica_activa(), "se apaga")
	comprobar(Ajustes.POR_DEFECTO["musica"] == false, "apagada por defecto")


func prueba_ajustes_menu() -> void:
	caso("ajustes desde el menu")
	var log := ContadorErrores.new()
	OS.add_logger(log)
	var menu: Control = load("res://escenas/menu.tscn").instantiate()
	add_child(menu)
	await get_tree().process_frame
	menu.abrir_ajustes()
	await get_tree().process_frame
	var textos := menu.find_children("*", "Button", true, false).map(func(b): return b.text)
	comprobar(textos.any(func(t): return t.begins_with("Música")), "hay interruptor de musica")
	comprobar(textos.any(func(t): return t.begins_with("Ocultar terminadas")), "hay interruptor de ocultar terminadas")
	menu.queue_free()
	await get_tree().process_frame
	OS.remove_logger(log)
	comprobar(log.errores.is_empty(), "sin errores: %s" % str(log.errores.slice(0, 3)))


func prueba_misterio() -> void:
	caso("lamina misterio de la semana")
	var lunes := "2026-10-12"
	var m := Laminas.misterio(lunes)
	comprobar(Laminas.existe(m) and "_i" in m, "es una lamina ilustrada")
	var igual := true
	for d in 7:
		if Laminas.misterio(Time.get_date_string_from_unix_time(Time.get_unix_time_from_datetime_string(lunes + "T12:00:00") + d * 86400)) != m:
			igual = false
	comprobar(igual, "la misma de lunes a domingo")
	comprobar(Laminas.misterio("2026-10-19") != m, "la semana siguiente es otra")
	var distintas := {}
	var choca := false
	for w in 30:
		var f := Time.get_date_string_from_unix_time(1790000000 + w * 7 * 86400)
		distintas[Laminas.misterio(f)] = true
		for d in 7:
			var dia := Time.get_date_string_from_unix_time(1790000000 + (w * 7 + d) * 86400)
			if Laminas.misterio(dia) == Laminas.del_dia(dia):
				choca = true
	comprobar(distintas.size() == 30, "30 semanas sin repetir")
	comprobar(not choca, "nunca coincide con la lamina del dia")
	Diario.datos = {}
	Diario.misterios = []
	comprobar(not Diario.revelado(m), "sin revelar")
	Diario.marcar_misterio(m)
	Diario.marcar_misterio(m)
	comprobar(Diario.revelado(m) and Diario.misterios.size() == 1, "revelada una vez")
	Diario.cargar()
	comprobar(Diario.revelado(m), "se guarda")
	var f := FileAccess.open(Diario.ruta, FileAccess.WRITE)
	f.store_string('{"misterios": ["animales_i001", 5, "no_existe"]}')
	f.close()
	Diario.cargar()
	comprobar(Diario.misterios == ["animales_i001"], "al leer solo quedan ids validos")
	Diario.misterios = []


func prueba_misterio_en_pantalla() -> void:
	caso("misterio en el menu y al colorear")
	var hoy := Diario.hoy()
	var m := Laminas.misterio(hoy)
	Diario.misterios = []
	Obras.borrar(m)
	load("res://escenas/menu.gd").categoria_actual = Laminas.categoria_de(m)
	var menu: Control = load("res://escenas/menu.tscn").instantiate()
	add_child(menu)
	await get_tree().process_frame
	comprobar(not m in menu.ids_en_rejilla(), "sin revelar no sale en su categoria")
	menu.queue_free()
	await get_tree().process_frame
	var escena_script = load("res://escenas/colorear.gd")
	escena_script.lamina_id = m
	var e: Control = load("res://escenas/colorear.tscn").instantiate()
	add_child(e)
	await get_tree().process_frame
	comprobar(e.titulo_visible() == "Misterio", "al colorear no se dice cual es")
	comprobar(e.vista.en_misterio(), "las lineas se descubren al pintar")
	for k in range(1, e.lamina.zonas):
		e.lamina.pintar(k, Color.RED)
	e._pintar(e.lamina.zonas)
	comprobar(Diario.revelado(m), "al terminarla queda revelada")
	comprobar(e.titulo_visible() == Laminas.nombre(m), "y se ve su nombre")
	comprobar(not e.vista.en_misterio(), "y el dibujo completo")
	e.queue_free()
	await get_tree().process_frame
	Obras.borrar(m)
	Diario.misterios = []
