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
	prueba_comodin()
	prueba_estadisticas()
	prueba_logros()
	prueba_sopa_aleatoria()
	prueba_palabras_extra()
	prueba_premio_extras()
	prueba_contrarreloj()
	prueba_medallas()
	prueba_eventos()
	prueba_progreso_evento()
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
	await prueba_partida_aleatoria()
	await prueba_partida_extra_y_reloj()
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

func prueba_comodin() -> void:
	caso("comodin de racha")
	comprobar(Economia.comodin_disponible("", HOY), "sin usar: disponible")
	comprobar(not Economia.comodin_disponible("2026-10-05", HOY), "usado hace 4 dias: no")
	comprobar(Economia.comodin_disponible("2026-10-02", HOY), "usado hace 7 dias: otra vez disponible")
	comprobar(Economia.comodin_salva("2026-10-07", HOY, true), "falto un dia y hay comodin: salva")
	comprobar(not Economia.comodin_salva("2026-10-07", HOY, false), "sin comodin no salva")
	comprobar(not Economia.comodin_salva("2026-10-06", HOY, true), "faltaron dos dias: no salva")
	comprobar(not Economia.comodin_salva("2026-10-08", HOY, true), "dia seguido: no hace falta")
	_reiniciar_progreso()
	Progreso.registrar_dia("2026-10-07")
	Progreso.registrar_dia("2026-10-08")
	comprobar(Progreso.registrar_dia(HOY) == 3 and Progreso.comodin_recien_usado == false, "seguidos sin comodin")
	comprobar(Progreso.registrar_dia("2026-10-11") == 4, "faltar el 10: el comodin la salva")
	comprobar(Progreso.comodin_recien_usado and Progreso.datos["comodin_usado"] == "2026-10-11", "queda marcado como usado")
	comprobar(Progreso.registrar_dia("2026-10-13") == 1, "otra falta en la misma semana: se reinicia")
	comprobar(int(Progreso.datos["racha_max"]) == 4, "se recuerda la mejor racha")


func prueba_estadisticas() -> void:
	caso("estadisticas")
	_reiniciar_progreso()
	Progreso.registrar_partida(1, 95.4, 9, 2, false)
	Progreso.registrar_partida(1, 61.0, 9, 0, false)
	Progreso.registrar_partida(1, 120.0, 9, 1, false)
	Progreso.registrar_partida(3, 300.0, 12, 0, true)
	var d := Progreso.datos
	comprobar(int(d["palabras"]) == 39, "palabras encontradas sumadas")
	comprobar(int(d["pistas_usadas"]) == 3, "pistas usadas sumadas")
	comprobar(int(d["mejor_tiempo"][1]) == 61 and int(d["mejor_tiempo"][3]) == 300 and int(d["mejor_tiempo"][0]) == 0, "mejor tiempo por dificultad")
	comprobar(int(d["aleatorias"]) == 1 and Progreso.completadas() == 1, "la aleatoria cuenta como partida y como aleatoria")
	Progreso.registrar_victoria("comida", "frutas", 1, 3, true, HOY)
	Progreso.registrar_victoria("comida", "frutas", 1, 3, true, HOY)
	comprobar(int(d["diarias"]) == 1, "la sopa del dia cuenta una vez por dia")
	var raro := Progreso.por_defecto()
	raro["mejor_tiempo"] = [-5, "x", 1e9]
	raro["palabras"] = -1
	raro["racha_max"] = 1e9
	raro["comodin_usado"] = "ayer"
	_escribir_firmado(raro)
	Progreso.cargar()
	d = Progreso.datos
	comprobar(d["mejor_tiempo"] == [0, 0, Progreso.TIEMPO_MAX, 0], "tiempos saneados a 4 valores validos: %s" % str(d["mejor_tiempo"]))
	comprobar(int(d["palabras"]) == 0 and int(d["racha_max"]) == Progreso.RACHA_MAX and d["comodin_usado"] == "", "contadores y fecha del comodin saneados")


func prueba_logros() -> void:
	caso("logros")
	_reiniciar_progreso()
	var l := Logros.lista(Progreso.datos)
	comprobar(l.size() >= 12, "al menos 12 logros (%d)" % l.size())
	comprobar(l.all(func(x): return not x["hecho"]), "partida nueva: ninguno")
	var ids := {}
	for x in l:
		ids[x["id"]] = true
		comprobar(x["nombre"] != "" and x["detalle"] != "" and x["meta"] > 0, "logro completo: %s" % x["id"])
	comprobar(ids.size() == l.size(), "ids unicos")
	Progreso.registrar_victoria("comida", "frutas", 3, 3, false, HOY)
	Progreso.registrar_partida(3, 50.0, 12, 0, false)
	var hechos := Logros.hechos(Progreso.datos)
	comprobar(hechos.has("primera") and hechos.has("experto"), "primera sopa y experto: %s" % str(hechos))
	comprobar(not hechos.has("sopas_10"), "10 sopas aun no")
	var cat: Dictionary = Temas.lista[0]
	for sub in cat["subtemas"]:
		Progreso.registrar_victoria(cat["id"], sub["id"], 0, 1, false, HOY)
	comprobar(Logros.hechos(Progreso.datos).has("tema_completo"), "resolver todo un tema")
	var antes := Logros.hechos(Progreso.datos)
	Progreso.datos["racha_max"] = 7
	comprobar(Logros.nuevos(antes, Progreso.datos).has("racha_7"), "detecta los logros recien conseguidos")
	var r10: Dictionary = l.filter(func(x): return x["id"] == "sopas_10")[0]
	comprobar(r10["meta"] == 10, "progreso con meta")


func prueba_sopa_aleatoria() -> void:
	caso("sopa al azar")
	var a := Temas.generar_aleatoria("animales", 1, 12345)
	var b := Temas.generar_aleatoria("animales", 1, 12345)
	comprobar(a.colocadas.size() == 9 and a.descartadas.is_empty(), "Normal: 9 palabras colocadas")
	var pa := a.colocadas.map(func(c): return c.palabra)
	comprobar(pa == b.colocadas.map(func(c): return c.palabra), "misma semilla, misma sopa")
	var distintas := {}
	for semilla in 20:
		var s := Temas.generar_aleatoria("animales", 1, semilla)
		distintas[",".join(PackedStringArray(s.colocadas.map(func(c): return c.palabra)))] = true
	comprobar(distintas.size() >= 18, "semillas distintas dan sopas distintas (%d de 20)" % distintas.size())
	var unicas := {}
	for p in pa:
		unicas[p] = true
	comprobar(unicas.size() == pa.size(), "sin palabras repetidas")
	var todas := {}
	for sub in Temas.categoria("animales")["subtemas"]:
		for p in sub["palabras"]:
			todas[GeneradorSopa.normalizar(p)] = true
	comprobar(pa.all(func(p): return todas.has(p)), "las palabras salen de esa categoria")
	var sel := Temas.nueva_aleatoria(2)
	comprobar(sel["aleatoria"] and not Temas.categoria(sel["categoria"]).is_empty() and sel["dificultad"] == 2 and not sel["diario"], "seleccion al azar valida")
	for d in 4:
		for c in Temas.lista:
			var s := Temas.generar_aleatoria(c["id"], d, 7)
			if not s.descartadas.is_empty():
				comprobar(false, "cabe en %s dificultad %d" % [c["id"], d])


func prueba_palabras_extra() -> void:
	caso("palabras extra ocultas")
	var c: Dictionary = Temas.categoria("animales")
	var sub: String = c["subtemas"][0]["id"]
	var s0 := Temas.generar("animales", sub, 0)
	comprobar(s0.extras.size() >= 1 and s0.extras.size() <= GeneradorSopa.MAX_EXTRAS, "Facil trae extras (%d)" % s0.extras.size())
	var principales := {}
	for col in s0.colocadas:
		principales[col.palabra] = true
	comprobar(s0.extras.all(func(e): return not principales.has(e.palabra)), "las extras no son de la lista")
	comprobar(s0.extras.all(func(e): return _se_lee(s0, e)), "cada extra se lee en la cuadricula")
	var e0: GeneradorSopa.Colocada = s0.extras[0]
	var inv: Array[Vector2i] = e0.celdas.duplicate()
	inv.reverse()
	comprobar(s0.buscar_extra(e0.celdas) == e0 and s0.buscar_extra(inv) == e0, "se encuentra en los dos sentidos")
	comprobar(s0.buscar_en(e0.celdas) == null, "no cuenta como palabra de la lista")
	comprobar(Temas.generar("animales", sub, 0).texto() == s0.texto(), "sigue siendo reproducible")
	var s3 := Temas.generar("animales", sub, 3)
	comprobar(s3.extras.size() >= 1, "en Experto tambien (de otros temas de la categoria)")
	comprobar(s3.descartadas.is_empty() and s3.colocadas.size() == 12, "las extras no quitan sitio a la lista")
	var sa := Temas.generar_aleatoria("animales", 1, 5)
	comprobar(sa.extras.size() >= 1, "la sopa al azar tambien trae")
	var sin := GeneradorSopa.generar(PackedStringArray(["GATO", "PERRO"]), 8, 0, 1)
	comprobar(sin.extras.is_empty(), "sin pedir extras no hay")
	var sin_total := 0
	for cat in Temas.lista:
		for st in cat["subtemas"]:
			if Temas.generar(cat["id"], st["id"], 1).extras.is_empty():
				sin_total += 1
	comprobar(sin_total * 10 < Temas.total_sopas(), "casi todas las sopas en Normal tienen extras (sin: %d)" % sin_total)


func _se_lee(sopa: GeneradorSopa.Sopa, e: GeneradorSopa.Colocada) -> bool:
	var t := ""
	for c in e.celdas:
		t += sopa.letra(c)
	return t == e.palabra


func prueba_premio_extras() -> void:
	caso("premio por palabras extra")
	_reiniciar_progreso()
	var pistas := Progreso.pistas_compradas()
	comprobar(not Progreso.registrar_extra(HOY) and not Progreso.registrar_extra(HOY), "1 y 2: sin premio")
	comprobar(Progreso.registrar_extra(HOY) and Progreso.pistas_compradas() == pistas + 1, "3: una pista")
	for i in 3:
		Progreso.registrar_extra(HOY)
	comprobar(Progreso.pistas_compradas() == pistas + 2, "6: dos pistas")
	for i in 6:
		Progreso.registrar_extra(HOY)
	comprobar(Progreso.pistas_compradas() == pistas + Economia.PISTAS_EXTRA_DIA, "tope de %d pistas al dia por extras" % Economia.PISTAS_EXTRA_DIA)
	comprobar(int(Progreso.datos["extras"]) == 12, "se cuentan todas")
	for i in 3:
		Progreso.registrar_extra("2026-10-10")
	comprobar(Progreso.pistas_compradas() == pistas + Economia.PISTAS_EXTRA_DIA + 1, "al dia siguiente vuelve a premiar")
	comprobar(Logros.lista(Progreso.datos).any(func(l): return l["id"] == "extras_25"), "hay logro de palabras extra")


func prueba_contrarreloj() -> void:
	caso("contrarreloj")
	comprobar(Economia.tiempo_limite(6, 0) == 120 and Economia.tiempo_limite(12, 3) == 420, "tiempo generoso por palabra y dificultad")
	comprobar(Progreso.por_defecto()["contrarreloj"] == false, "apagado por defecto")
	_reiniciar_progreso()
	Progreso.registrar_partida(1, 100.0, 9, 0, false, true)
	comprobar(int(Progreso.datos["reloj_ganadas"]) == 1, "cuenta las ganadas a tiempo")
	Progreso.registrar_partida(1, 100.0, 9, 0, false)
	comprobar(int(Progreso.datos["reloj_ganadas"]) == 1, "sin contrarreloj no suma")


func prueba_medallas() -> void:
	caso("medallas del viaje")
	_reiniciar_progreso()
	var c: Dictionary = Temas.categoria("clima")          # 7 sopas
	comprobar(Progreso.medalla("clima") == 0, "sin nada: sin medalla")
	Progreso.registrar_victoria("clima", c["subtemas"][0]["id"], 0, 1, false, HOY)
	comprobar(Progreso.medalla("clima") == 0, "1 de 7: aun no")
	Progreso.registrar_victoria("clima", c["subtemas"][1]["id"], 3, 1, false, HOY)
	Progreso.registrar_victoria("clima", c["subtemas"][2]["id"], 1, 1, false, HOY)
	comprobar(Progreso.medalla("clima") == 1, "3 de 7 (en cualquier dificultad): bronce")
	for i in range(3, 5):
		Progreso.registrar_victoria("clima", c["subtemas"][i]["id"], 0, 1, false, HOY)
	comprobar(Progreso.medalla("clima") == 2, "5 de 7: plata")
	for i in range(5, 7):
		Progreso.registrar_victoria("clima", c["subtemas"][i]["id"], 0, 1, false, HOY)
	comprobar(Progreso.medalla("clima") == 3, "todas: oro")
	comprobar(Progreso.resueltas_cualquier("clima") == 7, "cuenta sopas distintas")
	comprobar(Progreso.siguiente_parada() == Temas.lista[0]["id"], "la siguiente parada es el primer tema sin oro")
	comprobar(Progreso.medallas() == [1, 0, 0], "recuento oro, plata, bronce: %s" % str(Progreso.medallas()))


func prueba_eventos() -> void:
	caso("eventos de temporada")
	var nav := Eventos.activo("2026-12-24")
	comprobar(nav["id"] == "navidad" and nav["clave"] == "navidad-2026", "Navidad en diciembre")
	comprobar(Eventos.activo("2027-01-03")["clave"] == "navidad-2026", "Navidad cruza el año con la misma clave")
	comprobar(Eventos.activo("2026-10-31")["id"] == "halloween", "Halloween")
	var finde := Eventos.activo("2026-10-09")       # viernes sin fiesta
	comprobar(finde.get("id", "") == "finde", "fin de semana tematico un viernes")
	comprobar(Eventos.activo("2026-10-11")["clave"] == finde["clave"], "mismo evento todo el fin de semana")
	comprobar(Eventos.activo("2026-10-12").is_empty(), "un lunes sin fiesta: ninguno")
	comprobar(Eventos.activo("2026-10-16")["clave"] != finde["clave"], "el fin de semana siguiente es otro")
	for e in Eventos.FIJOS:
		comprobar(e["sopas"].size() == Eventos.SOPAS_POR_EVENTO, "%s tiene %d sopas" % [e["id"], Eventos.SOPAS_POR_EVENTO])
		for par in e["sopas"]:
			comprobar(not Temas.subtema(par[0], par[1]).is_empty(), "%s: existe %s/%s" % [e["id"], par[0], par[1]])
	comprobar(finde["sopas"].size() == Eventos.SOPAS_POR_EVENTO, "el fin de semana tambien trae %d" % Eventos.SOPAS_POR_EVENTO)
	comprobar(Eventos.dias_restantes(nav, "2026-12-24") == 14, "cuantos dias quedan contando hoy (24-dic a 6-ene)")
	var fechas := {}
	for e in Eventos.FIJOS:
		for d in Eventos.dias_de(e, 2026):
			comprobar(not fechas.has(d), "eventos sin solaparse (%s)" % d)
			fechas[d] = true


func prueba_progreso_evento() -> void:
	caso("progreso de un evento")
	_reiniciar_progreso()
	var hoy := "2026-10-30"
	var ev := Eventos.activo(hoy)
	var s0: Array = ev["sopas"][0]
	comprobar(Progreso.avance_evento(ev) == 0, "empieza en 0")
	comprobar(not Progreso.registrar_evento(s0[0], s0[1], hoy), "una sopa: no completa")
	comprobar(Progreso.avance_evento(ev) == 1, "1 de 5")
	Progreso.registrar_evento(s0[0], s0[1], hoy)
	comprobar(Progreso.avance_evento(ev) == 1, "repetir la misma no suma")
	Progreso.registrar_evento("comida", "frutas", hoy)
	comprobar(Progreso.avance_evento(ev) == 1, "una sopa de fuera del evento no suma")
	var completo := false
	for par in ev["sopas"].slice(1):
		completo = Progreso.registrar_evento(par[0], par[1], hoy)
	comprobar(completo and Progreso.evento_hecho(ev), "las 5: evento completado")
	comprobar(int(Progreso.datos["eventos_hechos"]) == 1, "cuenta eventos completados")
	comprobar(Logros.hechos(Progreso.datos).has("evento_1"), "logro de evento")
	comprobar(not Progreso.registrar_evento(s0[0], s0[1], "2026-11-20"), "fuera de la ventana no hace nada")
	var raro := Progreso.por_defecto()
	raro["eventos"] = {"halloween-2026": ["a/b", 5, "c/d"], 7: "x", "otro": "no-lista"}
	_escribir_firmado(raro)
	Progreso.cargar()
	comprobar(Progreso.datos["eventos"] == {"halloween-2026": ["a/b", "c/d"]}, "eventos saneados al leer: %s" % str(Progreso.datos["eventos"]))


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
	caso("diseños con contraste suficiente")
	for id in Estilo.VARIANTES:
		Estilo.aplicar(id)
		comprobar(Estilo.FUENTE_TITULO != null and Estilo.FUENTE_TEXTO != null, "%s: fuentes cargadas" % id)
		comprobar(_contraste(Estilo.TEXTO, Estilo.SUPERFICIE) >= 4.5, "%s: texto sobre tarjeta >= 4.5" % id)
		comprobar(_contraste(Estilo.TEXTO_SUAVE, Estilo.FONDO) >= 4.5, "%s: texto suave sobre fondo >= 4.5" % id)
		comprobar(_contraste(Estilo.SOBRE_PRIMARIO, Estilo.PRIMARIO) >= 3.0, "%s: boton principal >= 3 (texto grande)" % id)
		comprobar(_contraste(Estilo.LETRA, Estilo.TABLERO) >= 7.0, "%s: letras del tablero >= 7" % id)
		comprobar(_contraste(Estilo.TEXTO, Estilo.tinte(Estilo.ACENTO)) >= 4.5, "%s: texto sobre tarjeta tintada >= 4.5 (%.1f)" % [id, _contraste(Estilo.TEXTO, Estilo.tinte(Estilo.ACENTO))])
	comprobar(Estilo.VARIANTES.has("contraste"), "hay diseño de alto contraste")
	Estilo.aplicar("contraste")
	comprobar(_contraste(Estilo.TEXTO, Estilo.FONDO) >= 15.0, "alto contraste: texto >= 15")
	comprobar(_contraste(Estilo.TEXTO_SUAVE, Estilo.FONDO) >= 12.0, "alto contraste: texto suave >= 12")
	comprobar(_contraste(Estilo.SOBRE_PRIMARIO, Estilo.PRIMARIO) >= 12.0, "alto contraste: boton >= 12")
	comprobar(Progreso.DISENOS == Estilo.VARIANTES.keys(), "el guardado acepta todos los diseños")
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


func prueba_partida_aleatoria() -> void:
	caso("partida al azar sobre la escena real")
	_reiniciar_progreso()
	Temas.seleccion = {"categoria": "animales", "subtema": "", "dificultad": 0, "diario": false, "aleatoria": true, "semilla": 99}
	var juego: Control = load("res://escenas/juego.tscn").instantiate()
	add_child(juego)
	await get_tree().process_frame
	var sopa: GeneradorSopa.Sopa = juego._sopa
	comprobar(sopa.colocadas.size() == 6, "Facil: 6 palabras")
	for c in sopa.colocadas:
		juego._al_seleccionar(c.celdas.duplicate())
	comprobar(juego._terminado, "victoria")
	comprobar(int(Progreso.datos["aleatorias"]) == 1 and Progreso.datos["estrellas"].is_empty(), "cuenta como aleatoria y no toca las estrellas de las sopas")
	comprobar(Progreso.ultima().is_empty(), "no cambia Continuar")
	await get_tree().create_timer(1.2).timeout
	var botones := juego.find_children("*", "Button", true, false).filter(func(b): return b.text == "Otra al azar")
	comprobar(botones.size() == 1, "el panel ofrece otra al azar")
	juego.queue_free()
	await get_tree().process_frame


func prueba_partida_extra_y_reloj() -> void:
	caso("palabra extra y contrarreloj en la escena real")
	_reiniciar_progreso()
	Progreso.fijar_ajuste("contrarreloj", true)
	var c: Dictionary = Temas.categoria("animales")
	Temas.seleccion = {"categoria": "animales", "subtema": c["subtemas"][0]["id"], "dificultad": 0, "diario": false}
	var juego: Control = load("res://escenas/juego.tscn").instantiate()
	add_child(juego)
	await get_tree().process_frame
	var sopa: GeneradorSopa.Sopa = juego._sopa
	comprobar(juego._reloj.text == "2:00", "el reloj cuenta hacia atras desde el limite (%s)" % juego._reloj.text)
	juego._al_seleccionar(sopa.extras[0].celdas.duplicate())
	comprobar(juego._extras.size() == 1 and int(Progreso.datos["extras"]) == 1, "la extra cuenta")
	comprobar(juego._encontradas.is_empty(), "y no como palabra de la lista")
	juego._al_seleccionar(sopa.extras[0].celdas.duplicate())
	comprobar(int(Progreso.datos["extras"]) == 1, "repetirla no suma")
	juego._segundos = 200.0
	juego._process(0.1)
	await get_tree().process_frame
	comprobar(juego._agotado, "al pasar el limite se acaba el tiempo")
	juego._seguir_sin_reloj()
	comprobar(not juego._contrarreloj and juego._tablero.activo, "se puede seguir sin reloj")
	for col in sopa.colocadas:
		juego._al_seleccionar(col.celdas.duplicate())
	comprobar(juego._terminado and int(Progreso.datos["reloj_ganadas"]) == 0, "ganar tras agotar el tiempo no cuenta como contrarreloj")
	Progreso.fijar_ajuste("contrarreloj", false)
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
	caso("las pantallas cargan sin errores en todos los diseños")
	var log := ContadorErrores.new()
	OS.add_logger(log)
	Temas.seleccion = {"categoria": "comida", "subtema": "frutas", "dificultad": 0, "diario": false}
	for id in Estilo.VARIANTES:
		Estilo.aplicar(id)
		for nombre in ["menu", "categorias", "mapa", "evento", "sopas", "juego", "ajustes", "logros", "copia_no_valida"]:
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
