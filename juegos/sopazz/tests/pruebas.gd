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
	Monetizacion.timeout_anuncio_s = 8.0
