# Pruebas de Palabrario. Se ejecutan como escena para que los autoloads esten
# cargados igual que en el juego:
#
#   godot --headless --path juegos/palabrario res://tests/pruebas.tscn
#
# Sale con codigo 0 si todo pasa y 1 si algo falla.
extends Node

const FalsoBilling := preload("res://tests/falso_billing.gd")
const HOY := "2026-10-09"

var _fallos := 0
var _total := 0
var _actual := ""


func _ready() -> void:
	# Las pruebas de guardado no deben pisar el progreso real.
	var ruta_real := Progreso.ruta
	Progreso.ruta = "user://prueba_progreso.save"
	Tienda.simulada_demora_s = 0.01

	prueba_normalizar()
	prueba_celdas_en_linea()
	prueba_generador_basico()
	prueba_direcciones_por_dificultad()
	prueba_reproducible()
	prueba_caso_imposible()
	prueba_buscar_en()
	prueba_categorias()
	prueba_todas_las_sopas_caben()
	prueba_palabras_por_dificultad()
	prueba_sopa_del_dia_y_siguiente()
	prueba_economia()
	prueba_racha()
	await prueba_guardado_y_firma()
	prueba_esquema_guardado()
	prueba_reloj_no_retrocede()
	prueba_victorias()
	prueba_pistas()
	await prueba_tienda_simulada()
	await prueba_cobro_play()
	prueba_app_de_pago()
	prueba_integridad()
	prueba_ajustar_seleccion()
	prueba_escapar_bbcode()
	prueba_disenos()
	await prueba_partida_completa()
	await prueba_pantallas()

	DirAccess.remove_absolute(ProjectSettings.globalize_path(Progreso.ruta))
	for r in _rechazados():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(r))
	Progreso.ruta = ruta_real
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


func _reiniciar_progreso() -> void:
	Progreso.datos = Progreso.por_defecto()
	Progreso.guardar()


func _esperar_frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


# ---------------------------------------------------------------- generador

func prueba_normalizar() -> void:
	caso("normalizar")
	comprobar(GeneradorSopa.normalizar("Águila") == "AGUILA", "tildes")
	comprobar(GeneradorSopa.normalizar("Nariño") == "NARIÑO", "la eñe se conserva (AÑO no es ANO)")
	comprobar(GeneradorSopa.normalizar("Óscar") == "OSCAR", "mayuscula con tilde")
	comprobar(GeneradorSopa.normalizar("pão de queijo") == "PAODEQUEIJO", "a con virgulilla")
	comprobar(GeneradorSopa.normalizar("O'Higgins") == "OHIGGINS", "apostrofo")
	comprobar(GeneradorSopa.normalizar("güiro-de pie") == "GUIRODEPIE", "dieresis, guion y espacio")


func prueba_celdas_en_linea() -> void:
	caso("celdas_en_linea")
	var h := GeneradorSopa.celdas_en_linea(Vector2i(1, 1), Vector2i(4, 1))
	comprobar(h.size() == 4 and h[3] == Vector2i(4, 1), "horizontal")
	var d := GeneradorSopa.celdas_en_linea(Vector2i(3, 3), Vector2i(0, 0))
	comprobar(d.size() == 4 and d[1] == Vector2i(2, 2), "diagonal invertida")
	comprobar(GeneradorSopa.celdas_en_linea(Vector2i(0, 0), Vector2i(2, 1)).is_empty(), "no alineadas")


func _palabra_bien_colocada(sopa: GeneradorSopa.Sopa, c: GeneradorSopa.Colocada) -> bool:
	if c.celdas.size() != c.palabra.length():
		return false
	var paso := c.celdas[1] - c.celdas[0] if c.celdas.size() > 1 else Vector2i.ZERO
	for i in c.celdas.size():
		if sopa.letra(c.celdas[i]) != c.palabra[i]:
			return false
		if i > 0 and c.celdas[i] - c.celdas[i - 1] != paso:
			return false
	return true


func prueba_generador_basico() -> void:
	caso("generador basico")
	var palabras := PackedStringArray(["PERRO", "GATO", "LEÓN", "TIGRE", "OSO", "LOBO", "ZORRO", "ÁGUILA", "PIÑA"])
	var sopa := GeneradorSopa.generar(palabras, 10, 3, 42)
	comprobar(sopa.colocadas.size() == 9 and sopa.descartadas.is_empty(), "coloca las 9")
	var bien := true
	for c in sopa.colocadas:
		bien = bien and _palabra_bien_colocada(sopa, c)
	comprobar(bien, "cada palabra esta en linea recta y con sus letras")
	var llena := true
	for fila in sopa.cuadricula:
		for l in fila:
			llena = llena and l.length() == 1 and ((l >= "A" and l <= "Z") or l == "Ñ")
	comprobar(llena, "cuadricula llena solo con A-Z y Ñ")
	var pina := sopa.colocadas.filter(func(c): return c.palabra == "PIÑA")
	comprobar(pina.size() == 1, "PIÑA va con Ñ en la cuadricula")


func prueba_direcciones_por_dificultad() -> void:
	caso("direcciones segun dificultad")
	var palabras := PackedStringArray(["PERRO", "GATO", "TIGRE", "LOBO", "ZORRO"])
	var solo_rectas := true
	for semilla in 30:
		for c in GeneradorSopa.generar(palabras, 8, 0, semilla).colocadas:
			var paso: Vector2i = c.celdas[1] - c.celdas[0]
			solo_rectas = solo_rectas and (paso == Vector2i(1, 0) or paso == Vector2i(0, 1))
	comprobar(solo_rectas, "facil nunca usa diagonales ni inversas")


func prueba_reproducible() -> void:
	caso("reproducible por semilla")
	var palabras := PackedStringArray(["MANGO", "PERA", "UVA", "FRESA", "LIMÓN"])
	var a := GeneradorSopa.generar(palabras, 10, 2, 777).texto()
	comprobar(a == GeneradorSopa.generar(palabras, 10, 2, 777).texto(), "misma semilla, misma sopa")
	comprobar(a != GeneradorSopa.generar(palabras, 10, 2, 778).texto(), "otra semilla, otra sopa")


func prueba_caso_imposible() -> void:
	caso("caso imposible no falla en silencio")
	var sopa := GeneradorSopa.generar(PackedStringArray(["ELEFANTE", "SOL", "LUNA", "MAR", "PAZ", "RÍO"]), 3, 3, 1)
	comprobar("ELEFANTE" in sopa.descartadas, "la palabra que no cabe se reporta")
	comprobar(sopa.colocadas.size() + sopa.descartadas.size() == 6, "toda palabra acaba colocada o descartada")


func prueba_buscar_en() -> void:
	caso("buscar_en")
	var sopa := GeneradorSopa.generar(PackedStringArray(["CASA", "PERRO"]), 8, 0, 5)
	var casa: GeneradorSopa.Colocada = sopa.colocadas.filter(func(c): return c.palabra == "CASA")[0]
	comprobar(sopa.buscar_en(casa.celdas) == casa, "en su sentido")
	var al_reves: Array[Vector2i] = casa.celdas.duplicate()
	al_reves.reverse()
	comprobar(sopa.buscar_en(al_reves) == casa, "al reves tambien cuenta")
	comprobar(sopa.buscar_en(casa.celdas.slice(0, 3)) == null, "un trozo no cuenta")


# ---------------------------------------------------------------- contenido

func prueba_categorias() -> void:
	caso("categorias y sopas")
	comprobar(Temas.lista.size() >= 40, "40+ categorias (hay %d)" % Temas.lista.size())
	comprobar(Temas.total_sopas() >= 500, "500+ sopas (hay %d)" % Temas.total_sopas())
	var malas := 0
	for c in Temas.lista:
		for s in c["subtemas"]:
			if s["palabras"].size() != 12:
				malas += 1
	comprobar(malas == 0, "todas las sopas tienen 12 palabras (%d no)" % malas)


func prueba_todas_las_sopas_caben() -> void:
	caso("cada sopa, en cada dificultad, coloca todas sus palabras")
	var malas := 0
	var generadas := 0
	for c in Temas.lista:
		for s in c["subtemas"]:
			for dif in Economia.DIFICULTADES.size():
				var sopa := Temas.generar(c["id"], s["id"], dif)
				generadas += 1
				var esperadas: int = Economia.DIFICULTADES[dif]["palabras"]
				if sopa.colocadas.size() != esperadas or not sopa.descartadas.is_empty():
					malas += 1
					if malas <= 5:
						printerr("    %s/%s dif %d: %d/%d %s" % [c["id"], s["id"], dif, sopa.colocadas.size(), esperadas, sopa.descartadas])
	comprobar(malas == 0, "%d de %d sopas incompletas" % [malas, generadas])


func prueba_palabras_por_dificultad() -> void:
	caso("palabras y tamaño segun dificultad")
	var c: Dictionary = Temas.categoria("comida")
	var s: String = c["subtemas"][0]["id"]
	comprobar(Temas.palabras_sopa("comida", s, 0).size() == 6, "facil: 6 palabras")
	comprobar(Temas.palabras_sopa("comida", s, 1).size() == 9, "normal: 9")
	comprobar(Temas.palabras_sopa("comida", s, 3).size() == 12, "experto: 12")
	comprobar(Temas.lado_para(PackedStringArray(["HAMBURGUESA"]), 0) == 11, "la cuadricula crece si una palabra no cabe")
	comprobar(Temas.generar("comida", s, 1).texto() == Temas.generar("comida", s, 1).texto(), "cada sopa es siempre la misma")


func prueba_sopa_del_dia_y_siguiente() -> void:
	caso("sopa del dia y siguiente")
	var d1 := Temas.sopa_del_dia("2026-10-09")
	comprobar(not d1.is_empty() and d1 == Temas.sopa_del_dia("2026-10-09"), "misma sopa el mismo dia")
	var distintas := {}
	for i in 20:
		distintas[str(Temas.sopa_del_dia("2026-11-%02d" % (i + 1)))] = true
	comprobar(distintas.size() > 15, "cambia de un dia a otro")
	var c0: Dictionary = Temas.lista[0]
	var sig := Temas.siguiente(c0["id"], c0["subtemas"][0]["id"])
	comprobar(sig["subtema"] == c0["subtemas"][1]["id"], "siguiente dentro de la categoria")
	var ult: Dictionary = c0["subtemas"][-1]
	comprobar(Temas.siguiente(c0["id"], ult["id"])["categoria"] == Temas.lista[1]["id"], "salta a la siguiente categoria")
	var cn: Dictionary = Temas.lista[-1]
	comprobar(Temas.siguiente(cn["id"], cn["subtemas"][-1]["id"]).is_empty(), "al final no hay siguiente")


# ---------------------------------------------------------------- reglas

func prueba_economia() -> void:
	caso("estrellas")
	comprobar(Economia.estrellas(30, 5, 0) == 3, "rapido y sin pistas: 3")
	comprobar(Economia.estrellas(90, 5, 0) == 2, "lento: 2")
	comprobar(Economia.estrellas(500, 5, 0) == 1, "muy lento: 1")
	comprobar(Economia.estrellas(30, 5, 5) == 1, "nunca menos de 1")


func prueba_racha() -> void:
	caso("racha diaria")
	comprobar(Economia.avanzar_racha(0, "", HOY) == [1, true], "primer dia")
	comprobar(Economia.avanzar_racha(3, "2026-10-08", HOY) == [4, true], "dia siguiente suma")
	comprobar(Economia.avanzar_racha(3, HOY, HOY) == [3, false], "mismo dia no cuenta dos veces")
	comprobar(Economia.avanzar_racha(5, "2026-10-01", HOY) == [1, true], "hueco reinicia sin castigar")
	comprobar(Economia.avanzar_racha(2, "2026-02-28", "2026-03-01") == [3, true], "cambio de mes")
	comprobar(Economia.avanzar_racha(4, HOY, "2026-10-02") == [4, false], "fecha anterior: ni reinicia ni cuenta")


# ---------------------------------------------------------------- guardado

func _escribir_firmado(datos: Dictionary) -> void:
	var cuerpo := JSON.stringify(datos)
	var f := FileAccess.open(Progreso.ruta, FileAccess.WRITE)
	f.store_string(Progreso._firmar(cuerpo) + "\n" + cuerpo)
	f.close()


func prueba_guardado_y_firma() -> void:
	caso("guardado firmado")
	for r in _rechazados():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(r))
	_reiniciar_progreso()
	Progreso.registrar_victoria("comida", "frutas", 1, 3, false, HOY)
	Progreso.cargar()
	comprobar(Progreso.estrellas_de("comida", "frutas", 1) == 3 and Progreso.ultimo_rechazo == "", "guarda y carga")
	# Manipular el archivo a mano: cambiar la racha sin rehacer la firma.
	var texto := FileAccess.get_file_as_string(Progreso.ruta)
	var f := FileAccess.open(Progreso.ruta, FileAccess.WRITE)
	f.store_string(texto.replace("\"racha\":0", "\"racha\":999"))
	f.close()
	Progreso.cargar()
	comprobar(Progreso.ultimo_rechazo == "firma", "detecta la manipulacion")
	comprobar(int(Progreso.datos["racha"]) == 0, "y no acepta el valor inventado")
	comprobar(_rechazados().size() == 1, "el original se aparta en .rechazado-<hora>")
	f = FileAccess.open(Progreso.ruta, FileAccess.WRITE)
	f.store_string("basura")
	f.close()
	await get_tree().create_timer(0.01).timeout
	Progreso.cargar()
	comprobar(Progreso.ultimo_rechazo == "formato", "archivo roto no revienta")
	comprobar(_rechazados().size() == 2, "un segundo rechazo no pisa al primero")


## Archivos apartados por Progreso._rechazar() junto al guardado de prueba.
func _rechazados() -> Array:
	var dir := Progreso.ruta.get_base_dir()
	var base := Progreso.ruta.get_file() + ".rechazado"
	var r := []
	for nombre in DirAccess.get_files_at(dir):
		if nombre.begins_with(base):
			r.append(dir.path_join(nombre))
	return r


func prueba_esquema_guardado() -> void:
	caso("guardado con firma valida pero valores absurdos")
	var raro := Progreso.por_defecto()
	raro["vibracion"] = "infinita"
	raro["estrellas"] = {"comida/frutas/1": 99, "x": "mucho"}
	raro["escala_texto"] = 50
	raro["completadas"] = -7
	raro["pistas_compradas"] = 1e12
	raro["pistas_hoy"] = 99
	raro["diseno"] = "hackeado"
	raro["dificultad"] = 42
	raro["ultima"] = {"categoria": 5}
	raro["racha"] = 10_000_000
	raro["ultimo_dia"] = "mañana"
	raro["max_dia"] = "9999-99-99"
	raro["pistas_dia"] = "2026-10-0x"
	_escribir_firmado(raro)
	Progreso.cargar()
	comprobar(Progreso.ajuste("vibracion") == true, "tipo incorrecto se descarta")
	comprobar(int(Progreso.datos["racha"]) == Progreso.RACHA_MAX, "racha acotada")
	comprobar(Progreso.datos["ultimo_dia"] == "" and Progreso.datos["max_dia"] == "" and Progreso.datos["pistas_dia"] == "", "fechas mal formadas se vacian")
	comprobar(Progreso.estrellas_de("comida", "frutas", 1) == 3, "estrellas acotadas a 3")
	comprobar(not Progreso.datos["estrellas"].has("x"), "valor no numerico fuera")
	comprobar(float(Progreso.ajuste("escala_texto")) == 1.0, "escala fuera de las opciones vuelve a 1.0")
	comprobar(Progreso.completadas() == 0, "contadores negativos acotados")
	comprobar(Progreso.pistas_compradas() == Economia.PISTAS_MAX, "saldo de pistas acotado")
	comprobar(int(Progreso.datos["pistas_hoy"]) == Economia.PISTAS_GRATIS_DIA, "pistas del dia acotadas")
	comprobar(Progreso.ajuste("diseno") == "cielo" and int(Progreso.ajuste("dificultad")) == 3, "diseño y dificultad saneados")
	comprobar(Progreso.ultima().is_empty(), "ultima sopa con tipos raros se descarta")


func prueba_reloj_no_retrocede() -> void:
	caso("cambiar la fecha del movil no repite lo diario")
	_reiniciar_progreso()
	comprobar(Progreso.fecha_juego(HOY) == HOY, "fecha normal")
	comprobar(Progreso.fecha_juego("2026-10-05") == HOY, "atrasar el reloj no retrocede la fecha del juego")
	Progreso.registrar_victoria("comida", "frutas", 1, 3, true, Progreso.fecha_juego(HOY))
	comprobar(Progreso.diario_hecho(Progreso.fecha_juego("2026-10-01")), "atrasar el reloj no reabre la sopa del dia")
	for i in 3:
		Progreso.usar_pista(Progreso.fecha_juego(HOY))
	comprobar(Progreso.usar_pista(Progreso.fecha_juego("2026-10-01")) == "", "atrasar el reloj no devuelve las pistas gratis")

	caso("reloj que estuvo muy adelantado")
	_reiniciar_progreso()
	var futuro := "2027-03-01"
	Progreso.registrar_dia(Progreso.fecha_juego(futuro))
	for i in 3:
		Progreso.usar_pista(Progreso.fecha_juego(futuro))
	comprobar(Progreso.fecha_juego(HOY) == HOY, "vuelve a la fecha real en vez de congelar el dia")
	comprobar(Progreso.pistas_gratis_hoy(HOY) == 0, "y no regala pistas gratis al volver")
	comprobar(Progreso.registrar_dia(Progreso.fecha_juego("2026-10-10")) == 2, "la racha sigue desde hoy")
	comprobar(Progreso.es_fecha("2026-10-09") and not Progreso.es_fecha("2026-13-01") and not Progreso.es_fecha("x"), "formato de fecha")


func prueba_victorias() -> void:
	caso("victorias y estrellas")
	_reiniciar_progreso()
	Progreso.registrar_victoria("comida", "frutas", 1, 3, false, HOY)
	Progreso.registrar_victoria("comida", "frutas", 1, 1, false, HOY)
	comprobar(Progreso.estrellas_de("comida", "frutas", 1) == 3, "guarda la mejor marca")
	comprobar(Progreso.estrellas_de("comida", "frutas", 0) == 0, "cada dificultad aparte")
	comprobar(Progreso.resueltas_en("comida", 1) == 1 and Progreso.completadas() == 2, "cuenta resueltas y victorias")
	Progreso.registrar_victoria("ciencia", "x", 0, 2, true, HOY)
	comprobar(Progreso.diario_hecho(HOY), "sopa del dia marcada")


func prueba_pistas() -> void:
	caso("pistas: 3 gratis al dia, luego las compradas")
	_reiniciar_progreso()
	var r := []
	for i in 3:
		r.append(Progreso.usar_pista(HOY))
	comprobar(r == ["gratis", "gratis", "gratis"], "3 gratis")
	comprobar(Progreso.usar_pista(HOY) == "", "sin saldo, no hay pista")
	Progreso.sumar_pistas(2)
	comprobar(Progreso.usar_pista(HOY) == "comprada" and Progreso.pistas_compradas() == 1, "despues gasta las compradas")
	comprobar(Progreso.pistas_gratis_hoy("2026-10-10") == 3, "al dia siguiente vuelven las gratis")
	comprobar(Progreso.usar_pista("2026-10-10") == "gratis" and Progreso.pistas_compradas() == 1, "las gratis van antes que las compradas")


func prueba_tienda_simulada() -> void:
	caso("tienda de pistas (sin plugin)")
	_reiniciar_progreso()
	Tienda.simulada_exito = false
	var ok: bool = await Tienda.comprar("pistas_10")
	comprobar(not ok and Progreso.pistas_compradas() == 0, "compra fallida no da pistas")
	Tienda.simulada_exito = true
	ok = await Tienda.comprar("pistas_30")
	comprobar(ok and Progreso.pistas_compradas() == 30, "compra da su paquete")
	ok = await Tienda.comprar("pistas_gratis_infinitas")
	comprobar(not ok and Progreso.pistas_compradas() == 30, "producto desconocido se rechaza")
	Tienda.conceder("desbloquear_todo")
	comprobar(Progreso.pistas_compradas() == 30, "conceder fuera del catalogo no da nada")
	# Fuera del editor (APK exportado) sin plugin de pagos, la compra nunca regala.
	Tienda.permitir_simulada = false
	ok = await Tienda.comprar("pistas_100")
	comprobar(not ok and Progreso.pistas_compradas() == 30, "fuera del editor sin plugin: no regala pistas")
	Tienda.permitir_simulada = true


func prueba_cobro_play() -> void:
	caso("cobro de pistas con Google Play Billing (cliente falso)")
	_reiniciar_progreso()
	var falso := FalsoBilling.new()
	# Compra de una sesion anterior: pagada pero sin consumir (la app se cerro).
	falso.compras_previas = [FalsoBilling.compra("pistas_10", 1, "tok_viejo")]
	var ids := PackedStringArray(Tienda.PAQUETES.keys())
	var pagos := PagosPlay.new(falso, ids, ids)
	pagos.compra_confirmada.connect(Tienda.conceder)
	Tienda.pagos = pagos
	await _esperar_frames(4)
	comprobar("tok_viejo" in falso.consumidos and Progreso.pistas_compradas() == 10, "recupera al abrir la compra sin entregar")
	var ok: bool = await Tienda.comprar("pistas_30")
	comprobar(ok and Progreso.pistas_compradas() == 40, "se cobra, se consume y se entrega UNA vez")
	falso.modo = "cancelar"
	ok = await Tienda.comprar("pistas_30")
	comprobar(not ok and Progreso.pistas_compradas() == 40, "cancelada: nada y sin colgarse")
	falso.modo = "falla_confirmar"
	ok = await Tienda.comprar("pistas_30")
	comprobar(not ok and Progreso.pistas_compradas() == 40, "si Play no confirma el consumo, no se entrega")
	falso.modo = "pendiente"
	ok = await Tienda.comprar("pistas_100")
	comprobar(not ok and Progreso.pistas_compradas() == 40, "pendiente (pago en efectivo): aun no")
	falso.on_purchase_updated.emit({"response_code": 0, "purchases": [FalsoBilling.compra("pistas_100", 1, "tok_p")]})
	await _esperar_frames(3)
	comprobar("tok_p" in falso.consumidos and Progreso.pistas_compradas() == 140, "cuando se paga, llega sola")
	Tienda.pagos = null


func prueba_app_de_pago() -> void:
	caso("app de pago: contenido completo y sin anuncios")
	comprobar(not ProjectSettings.has_setting("autoload/Monetizacion"), "sin capa de anuncios")
	comprobar(ProjectSettings.has_setting("autoload/Tienda"), "tienda de pistas presente")
	var presets := FileAccess.get_file_as_string("res://export_presets.cfg")
	comprobar(not ("permissions/internet=true" in presets), "sin permiso de internet")
	comprobar(presets.contains("permissions/vibrate=true"), "solo vibracion")
	var abiertas := true
	for c in Temas.lista:
		for s2 in c["subtemas"]:
			abiertas = abiertas and Temas.subtema(c["id"], s2["id"]).has("palabras")
	comprobar(abiertas, "las %d sopas se pueden abrir" % Temas.total_sopas())


func prueba_integridad() -> void:
	caso("antipirateria: decision ante cada respuesta de Android")
	comprobar(Integridad.evaluar(true, true, "com.android.vending") == "ok", "instalada desde Play: juega")
	comprobar(Integridad.evaluar(true, true, "com.google.android.packageinstaller") == "copia", "APK pasado a mano: bloquea")
	comprobar(Integridad.evaluar(true, true, "") == "copia", "Android dice que nadie la instalo: bloquea")
	comprobar(Integridad.evaluar(true, true, null) == "desconocido", "no se pudo preguntar: deja jugar")
	comprobar(Integridad.evaluar(false, true, "") == "ok", "en depuracion/escritorio no aplica")
	comprobar(Integridad.evaluar(true, false, "") == "ok", "el dueño puede apagarla")
	comprobar(Integridad.elegir_instalador("com.android.shell", "com.android.vending") == "com.android.shell", "adb install -i com.android.vending no engaña")
	comprobar(Integridad.elegir_instalador("com.android.vending", "com.android.vending") == "com.android.vending", "instalacion normal desde Play")
	comprobar(Integridad.elegir_instalador(null, "com.android.vending") == "com.android.vending", "sin iniciador se usa el instalador")
	comprobar(Integridad.elegir_instalador("com.google.android.gms", "com.android.vending") == "com.android.vending", "iniciador raro (restauracion) no bloquea")
	comprobar(Integridad.resultado != "copia", "en este entorno no bloquea")


# ---------------------------------------------------------------- interfaz

func prueba_ajustar_seleccion() -> void:
	caso("arrastre del dedo -> linea recta")
	var h := Tablero.ajustar_seleccion(Vector2i(2, 2), Vector2(5.2, 2.3), 10)
	comprobar(h == [Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2)], "horizontal aunque el dedo tiemble")
	var d := Tablero.ajustar_seleccion(Vector2i(2, 2), Vector2(4.8, 4.6), 10)
	comprobar(d.size() == 4 and d[3] == Vector2i(5, 5), "diagonal imprecisa")
	var b := Tablero.ajustar_seleccion(Vector2i(2, 2), Vector2(-3.0, 2.0), 10)
	comprobar(b == [Vector2i(2, 2), Vector2i(1, 2), Vector2i(0, 2)], "se recorta en el borde")


func prueba_escapar_bbcode() -> void:
	caso("palabras con corchetes no inyectan BBCode")
	comprobar(Estilo.escapar_bbcode("A[b]C") == "A[lb]b]C", "se escapa el corchete")


func prueba_disenos() -> void:
	caso("tres diseños con contraste suficiente")
	for id in Estilo.VARIANTES:
		Estilo.aplicar(id)
		comprobar(Estilo.FUENTE_TITULO != null and Estilo.FUENTE_TEXTO != null, "%s: fuentes cargadas" % id)
		comprobar(_contraste(Estilo.TEXTO, Estilo.SUPERFICIE) >= 4.5, "%s: texto sobre tarjeta >= 4.5" % id)
		comprobar(_contraste(Estilo.TEXTO_SUAVE, Estilo.FONDO) >= 4.5, "%s: texto suave sobre fondo >= 4.5" % id)
		comprobar(_contraste(Estilo.SOBRE_PRIMARIO, Estilo.PRIMARIO) >= 3.0, "%s: boton principal >= 3 (texto grande)" % id)
		comprobar(_contraste(Estilo.LETRA, Estilo.TABLERO) >= 7.0, "%s: letras del tablero >= 7" % id)
	Estilo.aplicar("cielo")


static func _lum(c: Color) -> float:
	var f := func(x: float) -> float: return x / 12.92 if x <= 0.03928 else pow((x + 0.055) / 1.055, 2.4)
	return 0.2126 * f.call(c.r) + 0.7152 * f.call(c.g) + 0.0722 * f.call(c.b)


static func _contraste(a: Color, b: Color) -> float:
	var la := _lum(a)
	var lb := _lum(b)
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)


func prueba_partida_completa() -> void:
	caso("partida completa sobre la escena real")
	_reiniciar_progreso()
	var c: Dictionary = Temas.categoria("animales")
	Temas.seleccion = {"categoria": "animales", "subtema": c["subtemas"][0]["id"], "dificultad": 1, "diario": false}
	var juego: Control = load("res://escenas/juego.tscn").instantiate()
	add_child(juego)
	await get_tree().process_frame
	var sopa: GeneradorSopa.Sopa = juego._sopa
	comprobar(sopa.colocadas.size() == 9, "Normal: 9 palabras")
	juego._al_seleccionar([Vector2i(0, 0), Vector2i(1, 1)] as Array[Vector2i])
	comprobar(juego._encontradas.size() == 0, "seleccion falsa no cuenta")
	Progreso.sumar_pistas(4)
	for i in 5:
		juego._pedir_pista()
	await _esperar_frames(2)
	comprobar(juego._pistas_usadas == 5 and Progreso.pistas_compradas() == 2, "3 gratis + 2 compradas en la partida")
	for i in sopa.colocadas.size():
		var celdas: Array[Vector2i] = sopa.colocadas[i].celdas.duplicate()
		if i % 2 == 1:
			celdas.reverse()
		juego._al_seleccionar(celdas)
	comprobar(juego._terminado, "al encontrar todas, victoria")
	comprobar(Progreso.estrellas_de("animales", c["subtemas"][0]["id"], 1) > 0, "guarda las estrellas")
	comprobar(Progreso.ultima()["subtema"] == c["subtemas"][0]["id"], "recuerda la ultima sopa para Continuar")
	await get_tree().create_timer(1.2).timeout
	var paneles := juego.find_children("*", "PanelContainer", true, false)
	comprobar(not paneles.is_empty() and paneles[-1].modulate.a > 0.99, "el panel de victoria se ve (no se queda transparente)")
	juego.queue_free()
	await get_tree().process_frame


class ContadorErrores extends Logger:
	var errores: Array[String] = []
	func _log_error(_f: String, file: String, line: int, code: String, rationale: String, _n: bool, tipo: int, _bt: Array[ScriptBacktrace]) -> void:
		if tipo != ERROR_TYPE_WARNING:
			errores.append("%s:%d %s %s" % [file, line, code, rationale])
	func _log_message(_m: String, _e: bool) -> void:
		pass


func prueba_pantallas() -> void:
	caso("las 6 pantallas cargan sin errores en los 3 diseños")
	var log := ContadorErrores.new()
	OS.add_logger(log)
	Temas.seleccion = {"categoria": "comida", "subtema": "frutas", "dificultad": 0, "diario": false}
	for id in Estilo.VARIANTES:
		Estilo.aplicar(id)
		for nombre in ["menu", "categorias", "sopas", "juego", "ajustes", "copia_no_valida"]:
			var escena: Node = load("res://escenas/%s.tscn" % nombre).instantiate()
			add_child(escena)
			for f in 4:
				await get_tree().process_frame
			escena.queue_free()
			await get_tree().process_frame
	# El script de capturas no se ejecuta en esta bateria, pero debe compilar.
	comprobar(load("res://tests/capturas.gd") != null, "el script de capturas compila")
	OS.remove_logger(log)
	Estilo.aplicar("cielo")
	comprobar(log.errores.is_empty(), "errores: %s" % [log.errores.slice(0, 5)])
