# Pruebas de Sopazz. Se ejecutan como escena para que los autoloads esten
# cargados igual que en el juego:
#
#   godot --headless --path juegos/sopazz res://tests/pruebas.tscn
#
# Sale con codigo 0 si todo pasa y 1 si algo falla.
extends Node

var _fallos := 0
var _total := 0
var _actual := ""


func _ready() -> void:
	# Las pruebas de guardado no deben pisar el progreso real.
	var ruta_real := Progreso.ruta
	Progreso.ruta = "user://prueba_progreso.save"
	Monetizacion.stub_demora_s = 0.01

	prueba_normalizar()
	prueba_celdas_en_linea()
	prueba_generador_basico()
	prueba_direcciones_por_dificultad()
	prueba_reproducible()
	prueba_caso_imposible()
	prueba_buscar_en()
	prueba_temas()
	prueba_todos_los_niveles_caben()
	prueba_economia()
	prueba_racha()
	prueba_reglas_anuncios()
	prueba_guardado_y_firma()
	prueba_pistas()
	prueba_completar_nivel()
	prueba_premiados_tope()
	await prueba_compras()
	await prueba_timeout_anuncio()
	prueba_ajustar_seleccion()
	await prueba_partida_completa()
	await prueba_pantallas()
	await prueba_pagos_play()
	prueba_adaptadores_sin_plugin()
	prueba_reloj_no_retrocede()
	prueba_esquema_guardado()
	prueba_lista_blanca_productos()
	await prueba_permanentes_desde_play()
	prueba_escapar_bbcode()

	DirAccess.remove_absolute(ProjectSettings.globalize_path(Progreso.ruta))
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


# ---------------------------------------------------------------- generador

func prueba_normalizar() -> void:
	caso("normalizar")
	comprobar(GeneradorSopa.normalizar("Águila") == "AGUILA", "tildes")
	comprobar(GeneradorSopa.normalizar("Nariño") == "NARINO", "eñe")
	comprobar(GeneradorSopa.normalizar("Óscar") == "OSCAR", "mayuscula con tilde")
	comprobar(GeneradorSopa.normalizar("güiro-de pie") == "GUIRODEPIE", "dieresis, guion y espacio")


func prueba_celdas_en_linea() -> void:
	caso("celdas_en_linea")
	var h := GeneradorSopa.celdas_en_linea(Vector2i(1, 1), Vector2i(4, 1))
	comprobar(h.size() == 4 and h[3] == Vector2i(4, 1), "horizontal")
	var d := GeneradorSopa.celdas_en_linea(Vector2i(3, 3), Vector2i(0, 0))
	comprobar(d.size() == 4 and d[1] == Vector2i(2, 2), "diagonal invertida")
	comprobar(GeneradorSopa.celdas_en_linea(Vector2i(0, 0), Vector2i(2, 1)).is_empty(), "no alineadas")
	comprobar(GeneradorSopa.celdas_en_linea(Vector2i(2, 2), Vector2i(2, 2)).size() == 1, "una sola celda")


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
	var palabras := PackedStringArray(["PERRO", "GATO", "LEÓN", "TIGRE", "OSO", "LOBO", "ZORRO", "ÁGUILA"])
	var sopa := GeneradorSopa.generar(palabras, 10, 3, 42)
	comprobar(sopa.colocadas.size() == 8, "coloca las 8 (colocadas %d, descartadas %s)" % [sopa.colocadas.size(), sopa.descartadas])
	comprobar(sopa.descartadas.is_empty(), "sin descartes")
	var bien := true
	for c in sopa.colocadas:
		bien = bien and _palabra_bien_colocada(sopa, c)
	comprobar(bien, "cada palabra esta en linea recta y con sus letras")
	var llena := true
	for fila in sopa.cuadricula:
		for l in fila:
			llena = llena and l.length() == 1 and l >= "A" and l <= "Z"
	comprobar(llena, "cuadricula llena solo con A-Z")
	var leon := sopa.colocadas.filter(func(c): return c.palabra == "LEON")
	comprobar(leon.size() == 1 and leon[0].original == "LEÓN", "conserva la forma original para la lista")


func prueba_direcciones_por_dificultad() -> void:
	caso("direcciones segun dificultad")
	var palabras := PackedStringArray(["PERRO", "GATO", "TIGRE", "LOBO", "ZORRO"])
	for semilla in 30:
		var sopa := GeneradorSopa.generar(palabras, 8, 0, semilla)
		for c in sopa.colocadas:
			var paso: Vector2i = c.celdas[1] - c.celdas[0]
			if paso != Vector2i(1, 0) and paso != Vector2i(0, 1):
				comprobar(false, "facil solo horizontal/vertical (semilla %d, %s)" % [semilla, paso])
				return
	comprobar(true, "facil nunca usa diagonales ni inversas")


func prueba_reproducible() -> void:
	caso("reproducible por semilla")
	var palabras := PackedStringArray(["MANGO", "PERA", "UVA", "FRESA", "LIMÓN"])
	var a := GeneradorSopa.generar(palabras, 10, 2, 777).texto()
	var b := GeneradorSopa.generar(palabras, 10, 2, 777).texto()
	var c := GeneradorSopa.generar(palabras, 10, 2, 778).texto()
	comprobar(a == b, "misma semilla, misma sopa")
	comprobar(a != c, "otra semilla, otra sopa")


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


# ---------------------------------------------------------------- temas

func prueba_temas() -> void:
	caso("temas")
	comprobar(Temas.lista.size() >= 12, "se cargan los 12 temas (hay %d)" % Temas.lista.size())
	var gratis := Temas.lista.filter(func(t): return t.get("gratis", false)).size()
	comprobar(gratis >= 6, "al menos 6 gratis (hay %d)" % gratis)
	for t in Temas.lista:
		comprobar(t["palabras"].size() >= 30, "%s tiene 30+ palabras" % t["id"])
		for p in t["palabras"]:
			var n := GeneradorSopa.normalizar(p).length()
			if n < 3 or n > 9:
				comprobar(false, "%s: '%s' mide %d" % [t["id"], p, n])


func prueba_todos_los_niveles_caben() -> void:
	caso("todos los temas x dificultades x 25 niveles colocan todas sus palabras")
	var malos := 0
	var generadas := 0
	for t in Temas.lista:
		for dif in Economia.DIFICULTADES.size():
			var esperadas: int = Economia.DIFICULTADES[dif]["palabras"]
			for nivel in range(1, 26):
				var sopa := Temas.generar_nivel(t["id"], dif, Temas.semilla_nivel(t["id"], dif, nivel))
				generadas += 1
				if sopa.colocadas.size() != esperadas or not sopa.descartadas.is_empty():
					malos += 1
					if malos <= 3:
						printerr("    %s dif %d nivel %d: %d/%d %s" % [t["id"], dif, nivel, sopa.colocadas.size(), esperadas, sopa.descartadas])
	comprobar(malos == 0, "%d de %d sopas incompletas" % [malos, generadas])


# ---------------------------------------------------------------- economia

func prueba_economia() -> void:
	caso("economia")
	comprobar(Economia.estrellas(30, 5, 0) == 3, "rapido y sin pistas: 3")
	comprobar(Economia.estrellas(90, 5, 0) == 2, "lento: 2")
	comprobar(Economia.estrellas(500, 5, 0) == 1, "muy lento: 1")
	comprobar(Economia.estrellas(30, 5, 5) == 1, "nunca menos de 1")
	comprobar(Economia.recompensa_nivel(3, false, false) == 20, "3 estrellas = 20")
	comprobar(Economia.recompensa_nivel(1, false, false) == 10, "1 estrella = 10")
	comprobar(Economia.recompensa_nivel(3, true, true) == 90, "tema nuevo y diario: (20+25)*2")


func prueba_racha() -> void:
	caso("racha diaria")
	comprobar(Economia.avanzar_racha(0, "", "2026-10-09") == [1, true], "primer dia")
	comprobar(Economia.avanzar_racha(3, "2026-10-08", "2026-10-09") == [4, true], "dia siguiente suma")
	comprobar(Economia.avanzar_racha(3, "2026-10-09", "2026-10-09") == [3, false], "mismo dia no cobra dos veces")
	comprobar(Economia.avanzar_racha(5, "2026-10-01", "2026-10-09") == [1, true], "hueco reinicia sin castigar")
	comprobar(Economia.avanzar_racha(2, "2026-02-28", "2026-03-01") == [3, true], "cambio de mes")
	comprobar(Economia.recompensa_racha(1) == 10 and Economia.recompensa_racha(30) == 60, "escala y tope")


func prueba_reglas_anuncios() -> void:
	caso("reglas del intersticial")
	var base := {"niveles_completados": 10, "desde_ultimo_s": INF, "completados_desde_ultimo": 3}
	comprobar(ReglasAnuncios.intersticial_permitido(base), "caso normal permite")
	comprobar(not ReglasAnuncios.intersticial_permitido(base.merged({"sin_anuncios": true}, true)), "quitar anuncios")
	comprobar(not ReglasAnuncios.intersticial_permitido(base.merged({"en_partida": true}, true)), "nunca en partida")
	comprobar(not ReglasAnuncios.intersticial_permitido(base.merged({"abandono": true}, true)), "nunca tras abandonar")
	comprobar(not ReglasAnuncios.intersticial_permitido(base.merged({"niveles_completados": 3}, true)), "onboarding limpio")
	comprobar(not ReglasAnuncios.intersticial_permitido(base.merged({"desde_ultimo_s": 60.0}, true)), "separacion de 90 s")
	comprobar(not ReglasAnuncios.intersticial_permitido(base.merged({"completados_desde_ultimo": 2}, true)), "1 de cada 3")


# ---------------------------------------------------------------- guardado

func prueba_guardado_y_firma() -> void:
	caso("guardado firmado")
	_reiniciar_progreso()
	Progreso.sumar_fichas(123)
	Progreso.cargar()
	comprobar(Progreso.fichas() == 123 and Progreso.ultimo_rechazo == "", "guarda y carga")

	# Manipular el archivo a mano: subir las fichas sin rehacer la firma.
	var texto := FileAccess.get_file_as_string(Progreso.ruta)
	var f := FileAccess.open(Progreso.ruta, FileAccess.WRITE)
	f.store_string(texto.replace("\"fichas\":123", "\"fichas\":999999"))
	f.close()
	Progreso.cargar()
	comprobar(Progreso.ultimo_rechazo == "firma", "detecta la manipulacion (%s)" % Progreso.ultimo_rechazo)
	comprobar(Progreso.fichas() == 0, "y vuelve a cero, no al valor inflado")

	f = FileAccess.open(Progreso.ruta, FileAccess.WRITE)
	f.store_string("basura")
	f.close()
	Progreso.cargar()
	comprobar(Progreso.ultimo_rechazo == "formato", "archivo roto no revienta")


func prueba_pistas() -> void:
	caso("pistas")
	_reiniciar_progreso()
	var r := []
	for i in 3:
		r.append(Progreso.pagar_pista())
	comprobar(r == ["gratis", "gratis", "gratis"], "3 gratis al empezar")
	comprobar(Progreso.pagar_pista() == "", "sin fichas pide anuncio")
	Progreso.sumar_fichas(30)
	comprobar(Progreso.pagar_pista() == "fichas" and Progreso.fichas() == 5, "luego cuesta 25 fichas")
	comprobar(Progreso.usar_cortesia("2026-10-09"), "cortesia del dia")
	comprobar(not Progreso.usar_cortesia("2026-10-09"), "solo una al dia")


func prueba_completar_nivel() -> void:
	caso("completar nivel")
	_reiniciar_progreso()
	var g := Progreso.completar_nivel("animales", 1, 1, 3, false, "2026-10-09")
	comprobar(g == 45, "primer nivel de un tema: 20 + 25 (dio %d)" % g)
	comprobar(Progreso.nivel_actual("animales", 1) == 2, "avanza al nivel 2")
	Progreso.completar_nivel("animales", 1, 1, 1, false, "2026-10-09")
	comprobar(Progreso.estrellas_de("animales", 1, 1) == 3, "guarda la mejor marca, no la ultima")
	comprobar(Progreso.nivel_actual("animales", 1) == 2, "repetir un nivel no salta niveles")
	var d1 := Progreso.completar_nivel("comida", 1, 1, 3, true, "2026-10-09")
	var d2 := Progreso.completar_nivel("comida", 1, 1, 3, true, "2026-10-09")
	comprobar(d1 == 90 and d2 == 20, "el diario paga doble una sola vez (%d, %d)" % [d1, d2])


func prueba_premiados_tope() -> void:
	caso("tope de premiados")
	_reiniciar_progreso()
	for i in Economia.PREMIADOS_MAX_DIA:
		Progreso.registrar_premiado("2026-10-09")
	comprobar(not Progreso.premiado_disponible("2026-10-09"), "tope diario")
	comprobar(Progreso.premiado_disponible("2026-10-10"), "se reinicia al dia siguiente")


# ---------------------------------------------------------------- monetizacion

func prueba_compras() -> void:
	caso("compras (stub)")
	_reiniciar_progreso()
	Monetizacion.stub_exito = true
	var ok: bool = await Monetizacion.comprar("fichas_500")
	comprobar(ok and Progreso.fichas() == 500, "compra de fichas entrega")
	Monetizacion.stub_exito = false
	ok = await Monetizacion.comprar("fichas_500")
	comprobar(not ok and Progreso.fichas() == 500, "compra fallida no regala nada")
	Monetizacion.stub_exito = true
	await Monetizacion.comprar("sin_anuncios")
	Monetizacion.conceder("sin_anuncios")  # como si se restaurara
	comprobar(Progreso.sin_anuncios() and Progreso.fichas() == 800, "quitar anuncios regala 300 una sola vez")
	var shown: bool = await Monetizacion.intentar_intersticial()
	comprobar(not shown, "con quitar anuncios no sale intersticial")
	await Monetizacion.comprar("tema_mitologia")
	comprobar(Progreso.tema_desbloqueado("mitologia"), "tema suelto")
	comprobar(not Progreso.tema_desbloqueado("ciencia"), "los demas siguen bloqueados")
	await Monetizacion.comprar("todos_los_temas")
	comprobar(Progreso.tema_desbloqueado("ciencia") and Progreso.tema_desbloqueado("cine"), "todos los temas")
	ok = await Monetizacion.comprar("hackeo")
	comprobar(not ok, "producto desconocido se rechaza")


signal _nunca(ok: bool)

func prueba_timeout_anuncio() -> void:
	caso("anuncio que nunca responde")
	Monetizacion.timeout_anuncio_s = 0.2
	var t0 := Time.get_ticks_msec()
	var ok: bool = await Monetizacion._con_timeout(_nunca)
	comprobar(not ok, "devuelve false")
	comprobar(Time.get_ticks_msec() - t0 < 2000, "y no se queda colgado")
	Monetizacion.timeout_anuncio_s = 180.0


# ---------------------------------------------------------------- tablero y escenas

func prueba_ajustar_seleccion() -> void:
	caso("arrastre del dedo -> linea recta")
	var h := Tablero.ajustar_seleccion(Vector2i(2, 2), Vector2(5.2, 2.3), 10)
	comprobar(h == [Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2)], "horizontal aunque el dedo tiemble")
	var d := Tablero.ajustar_seleccion(Vector2i(2, 2), Vector2(4.8, 4.6), 10)
	comprobar(d.size() == 4 and d[3] == Vector2i(5, 5), "diagonal imprecisa (%s)" % [d])
	var b := Tablero.ajustar_seleccion(Vector2i(2, 2), Vector2(-3.0, 2.0), 10)
	comprobar(b == [Vector2i(2, 2), Vector2i(1, 2), Vector2i(0, 2)], "se recorta en el borde")
	comprobar(Tablero.ajustar_seleccion(Vector2i(2, 2), Vector2(2.1, 2.2), 10) == [Vector2i(2, 2)], "sin moverse: una celda")
	var arriba := Tablero.ajustar_seleccion(Vector2i(3, 5), Vector2(3.2, 1.0), 10)
	comprobar(arriba.size() == 5 and arriba[4] == Vector2i(3, 1), "vertical hacia arriba")


class ContadorErrores extends Logger:
	var errores: Array[String] = []
	func _log_error(_f: String, file: String, line: int, code: String, rationale: String, _n: bool, tipo: int, _bt: Array[ScriptBacktrace]) -> void:
		if tipo != ERROR_TYPE_WARNING:
			errores.append("%s:%d %s %s" % [file, line, code, rationale])
	func _log_message(_m: String, _e: bool) -> void:
		pass


func prueba_partida_completa() -> void:
	caso("partida completa sobre la escena real")
	_reiniciar_progreso()
	Temas.seleccion = {"tema": "animales", "dificultad": 1, "nivel": 1, "diario": false}
	var juego: Control = load("res://escenas/juego.tscn").instantiate()
	add_child(juego)
	await get_tree().process_frame
	var sopa: GeneradorSopa.Sopa = juego._sopa
	comprobar(sopa.colocadas.size() == 8, "Normal: 8 palabras")
	# Un error (seleccion que no es palabra) no cuenta.
	juego._al_seleccionar([Vector2i(0, 0), Vector2i(1, 1)] as Array[Vector2i])
	comprobar(juego._encontradas.size() == 0, "seleccion falsa no cuenta")
	for i in sopa.colocadas.size():
		var c: GeneradorSopa.Colocada = sopa.colocadas[i]
		var celdas: Array[Vector2i] = c.celdas.duplicate()
		if i % 2 == 1:
			celdas.reverse()  # la mitad, de atras hacia adelante
		juego._al_seleccionar(celdas)
	comprobar(juego._terminado, "al encontrar todas, victoria")
	comprobar(Progreso.nivel_actual("animales", 1) == 2, "el nivel 2 queda abierto")
	comprobar(Progreso.fichas() > 0, "da fichas")
	await get_tree().create_timer(0.8).timeout
	juego.queue_free()
	await get_tree().process_frame


func prueba_pantallas() -> void:
	caso("las 5 pantallas cargan sin errores")
	var log := ContadorErrores.new()
	OS.add_logger(log)
	for nombre in ["menu", "selector", "juego", "tienda", "ajustes"]:
		var escena: Node = load("res://escenas/%s.tscn" % nombre).instantiate()
		add_child(escena)
		for f in 5:
			await get_tree().process_frame
		escena.queue_free()
		await get_tree().process_frame
	# Ganar fichas con las pantallas ya cerradas no debe tocar nodos liberados.
	Progreso.sumar_fichas(1)
	OS.remove_logger(log)
	comprobar(log.errores.is_empty(), "errores: %s" % [log.errores])


# ---------------------------------------------------------------- pagos reales (con Billing falso)

const FalsoBilling := preload("res://tests/falso_billing.gd")


func _esperar_frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func prueba_pagos_play() -> void:
	caso("cobro con Google Play Billing (cliente falso)")
	_reiniciar_progreso()
	var falso := FalsoBilling.new()
	# Compra que quedo a medias en una sesion anterior: pagada, sin consumir.
	falso.compras_previas = [FalsoBilling.compra("fichas_1500", 1, "tok_viejo")]
	var pagos := PagosPlay.new(falso, Monetizacion.ids_productos(), Monetizacion.ids_consumibles())
	pagos.compra_confirmada.connect(Monetizacion.conceder)
	Monetizacion.pagos = pagos
	await _esperar_frames(4)
	comprobar(pagos.conectado, "conecta")
	comprobar("tok_viejo" in falso.consumidos and Progreso.fichas() == 1500, "recupera al abrir la compra que quedo sin entregar (%d)" % Progreso.fichas())

	var ok: bool = await Monetizacion.comprar("fichas_500")
	comprobar(ok and Progreso.fichas() == 2000, "consumible: se cobra, se consume y se entrega UNA vez (%d)" % Progreso.fichas())

	falso.modo = "cancelar"
	ok = await Monetizacion.comprar("fichas_500")
	comprobar(not ok and Progreso.fichas() == 2000, "cancelada: no entrega y no se queda colgada")

	falso.modo = "falla_confirmar"
	ok = await Monetizacion.comprar("fichas_500")
	comprobar(not ok and Progreso.fichas() == 2000, "si Play no confirma, no se entrega (Play la reembolsara)")

	falso.modo = "pendiente"
	ok = await Monetizacion.comprar("tema_cine")
	comprobar(not ok and not Progreso.tema_desbloqueado("cine"), "pendiente (pago en efectivo): aun no se entrega")
	falso.on_purchase_updated.emit({"response_code": 0, "purchases": [FalsoBilling.compra("tema_cine", 1, "tok_cine")]})
	await _esperar_frames(3)
	comprobar("tok_cine" in falso.reconocidos and Progreso.tema_desbloqueado("cine"), "cuando se paga, se reconoce y se entrega sola")

	falso.modo = "ok"
	ok = await Monetizacion.comprar("sin_anuncios")
	comprobar(ok and Progreso.sin_anuncios() and falso.reconocidos.size() == 2, "permanente: se reconoce (si no, Play reembolsa en 3 dias)")
	var fichas_antes := Progreso.fichas()
	# Restaurar en otro movil: Play devuelve la compra ya reconocida.
	falso.compras_previas = [FalsoBilling.compra("sin_anuncios", 1, "tok_sa", true)]
	var n: int = await Monetizacion.restaurar_compras()
	comprobar(n == 1 and Progreso.fichas() == fichas_antes, "restaurar no regala las 300 fichas otra vez")
	Monetizacion.pagos = null


func prueba_adaptadores_sin_plugin() -> void:
	caso("sin plugins: el juego cae al stub")
	comprobar(not AnunciosAdMob.disponible(), "AdMob no disponible aqui")
	comprobar(not Monetizacion.anuncios_reales() and not Monetizacion.pagos_reales(), "monetizacion usa el stub")
	comprobar(Monetizacion.ids_anuncios()["premiado"] == Monetizacion.ADMOB_TEST_PREMIADO, "depuracion usa unidades de prueba")
	comprobar("tema_mitologia" in Monetizacion.ids_productos() and not ("tema_animales" in Monetizacion.ids_productos()), "solo los temas de pago son productos")
	comprobar(Monetizacion.ids_consumibles().size() == 4, "4 paquetes de fichas consumibles")


# ---------------------------------------------------------------- correcciones de la auditoria

func prueba_reloj_no_retrocede() -> void:
	caso("SEC-002: cambiar la fecha del movil no regala fichas")
	_reiniciar_progreso()
	comprobar(Progreso.fecha_juego("2026-10-09") == "2026-10-09", "fecha normal")
	comprobar(Progreso.fecha_juego("2026-10-05") == "2026-10-09", "atrasar el reloj no hace retroceder la fecha del juego")
	var total := 0
	for i in 30:
		var f := "2026-10-08" if i % 2 == 0 else "2026-10-09"
		total += Progreso.registrar_dia(Progreso.fecha_juego(f))
	comprobar(total == 10, "alternar dos fechas solo paga el primer dia (pago %d)" % total)
	comprobar(Economia.avanzar_racha(4, "2026-10-09", "2026-10-02") == [4, false], "fecha anterior: ni reinicia ni cobra")


func _escribir_firmado(datos: Dictionary) -> void:
	var cuerpo := JSON.stringify(datos)
	var f := FileAccess.open(Progreso.ruta, FileAccess.WRITE)
	f.store_string(Progreso._firmar(cuerpo) + "\n" + cuerpo)
	f.close()


func prueba_esquema_guardado() -> void:
	caso("SEC-004/006: guardado con firma valida pero valores absurdos")
	var raro := Progreso.por_defecto()
	raro["temas_comprados"] = "paisescinecienciamitologiamusicaoficios"
	raro["fichas"] = 1e15
	raro["escala_texto"] = 50
	raro["pistas_gratis"] = 999
	raro["niveles"] = {"animales|1": "muchos"}
	_escribir_firmado(raro)
	Progreso.cargar()
	comprobar(typeof(Progreso.datos["temas_comprados"]) == TYPE_ARRAY, "tipo incorrecto se descarta")
	comprobar(not Progreso.tema_desbloqueado("cine"), "un String no desbloquea temas por subcadena")
	comprobar(Progreso.fichas() <= Progreso.FICHAS_MAX, "fichas acotadas (%d)" % Progreso.fichas())
	comprobar(float(Progreso.datos["escala_texto"]) == 1.0, "escala fuera de las opciones vuelve a 1.0")
	comprobar(Progreso.pistas_gratis() <= Economia.PISTAS_GRATIS_INICIALES, "pistas gratis acotadas")
	comprobar(Progreso.nivel_actual("animales", 1) == 1, "nivel con tipo raro se ignora")
	# Rechazo por firma: el original se aparta en vez de perderse.
	var rechazado := Progreso.ruta + ".rechazado"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(rechazado))
	var f := FileAccess.open(Progreso.ruta, FileAccess.WRITE)
	f.store_string("firma_falsa\n{\"fichas\": 5}")
	f.close()
	Progreso.cargar()
	Progreso.sumar_fichas(1)
	comprobar(FileAccess.file_exists(rechazado), "el guardado rechazado se conserva en .rechazado")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(rechazado))


func prueba_lista_blanca_productos() -> void:
	caso("SEC-005: productos fuera del catalogo")
	_reiniciar_progreso()
	Monetizacion.conceder("producto_nuevo")
	Monetizacion.conceder("tema_inventado")
	Monetizacion.conceder("tema_animales")  # gratis: no es un producto
	comprobar(Progreso.fichas() == 0 and Progreso.datos["temas_comprados"].is_empty(), "no se entrega nada ni revienta")
	comprobar(Monetizacion.producto_valido("tema_cine") and Monetizacion.producto_valido("fichas_500"), "los del catalogo si")


func prueba_permanentes_desde_play() -> void:
	caso("SEC-001/003: Play manda sobre las compras permanentes")
	_reiniciar_progreso()
	# Un guardado forjado (o un reembolso) dice que tiene esto...
	Progreso.activar_sin_anuncios()
	Progreso.desbloquear_tema("cine")
	Progreso.sumar_fichas(400)
	Progreso.desbloquear_con_fichas("ciencia")
	var falso := FalsoBilling.new()
	falso.compras_previas = [FalsoBilling.compra("tema_mitologia", 1, "tok_m", true)]
	var pagos := PagosPlay.new(falso, Monetizacion.ids_productos(), Monetizacion.ids_consumibles())
	pagos.compra_confirmada.connect(Monetizacion.conceder)
	pagos.permanentes_sincronizados.connect(Monetizacion.sincronizar_permanentes)
	await _esperar_frames(4)
	comprobar(not Progreso.sin_anuncios(), "sin_anuncios no comprado en Play se retira")
	comprobar(not Progreso.tema_desbloqueado("cine"), "tema no comprado en Play se retira")
	comprobar(Progreso.tema_desbloqueado("mitologia"), "el comprado en Play se mantiene")
	comprobar(Progreso.tema_desbloqueado("ciencia"), "el desbloqueado con fichas no se toca")
	# Si Play no responde bien, no se revoca nada.
	Progreso.activar_sin_anuncios()
	falso.query_purchases_response.emit({"response_code": 6, "debug_message": "sin red"})
	await _esperar_frames(2)
	comprobar(Progreso.sin_anuncios(), "sin respuesta de Play no se quita nada")


func prueba_escapar_bbcode() -> void:
	caso("SEC-010: palabras con corchetes no inyectan BBCode")
	comprobar(Estilo.escapar_bbcode("A[b]C") == "A[lb]b]C", "se escapa el corchete")
