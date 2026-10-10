# Pruebas de Rebotazz. Se ejecutan como escena (autoloads cargados):
#
#   godot --headless --path juegos/rebote res://tests/pruebas.tscn
#
# Sale con codigo 0 si todo pasa y 1 si algo falla.
extends Node

const FalsoBilling := preload("res://tests/falso_billing.gd")

var _fallos := 0
var _total := 0
var _actual := ""


func _ready() -> void:
	Ajustes.ruta = "user://prueba_ajustes.json"
	Ajustes.datos["sonido"] = false
	Progreso.ruta = "user://prueba_progreso.save"
	Progreso.datos = Progreso.por_defecto()
	Monetizacion.simulado_demora_s = 0.0

	prueba_rebote_paleta()
	prueba_choque_circulo_rect()
	prueba_angulo_minimo()
	prueba_nivel_desde_texto()
	prueba_romper_ladrillo()
	prueba_ladrillos_especiales()
	prueba_no_atraviesa_rapido()
	prueba_perder_bola()
	prueba_potenciadores()
	prueba_anti_atasco()
	prueba_niveles_generados()
	prueba_todos_los_niveles_se_terminan()
	prueba_progreso()
	prueba_progreso_firmado()
	prueba_economia()
	prueba_aspectos()
	prueba_reglas_anuncios()
	prueba_revivir()
	prueba_arranques()
	await prueba_premiados()
	await prueba_intersticial()
	await prueba_compras_simuladas()
	await prueba_cobro_play()
	prueba_textos_sin_promesas_falsas()
	await prueba_pantallas()
	await prueba_flujos_tienda()
	await prueba_flujos_partida()

	DirAccess.remove_absolute(ProjectSettings.globalize_path(Ajustes.ruta))
	_borrar_progreso()
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


func prueba_rebote_paleta() -> void:
	caso("rebote en la paleta")
	var v := Fisica.rebote_paleta(500.0, 500.0, 200.0, 1000.0)
	comprobar(v.is_equal_approx(Vector2(0, -1000)), "centro: sale recta hacia arriba (%s)" % v)
	var d := Fisica.rebote_paleta(600.0, 500.0, 200.0, 1000.0)
	comprobar(is_equal_approx(rad_to_deg(atan2(d.x, -d.y)), 60.0), "borde derecho: 60 grados")
	var i := Fisica.rebote_paleta(400.0, 500.0, 200.0, 1000.0)
	comprobar(i.x < 0 and i.y < 0, "borde izquierdo: hacia la izquierda y arriba")
	var f := Fisica.rebote_paleta(800.0, 500.0, 200.0, 1000.0)
	comprobar(is_equal_approx(rad_to_deg(atan2(f.x, -f.y)), 60.0), "fuera del borde: se limita a 60")
	comprobar(is_equal_approx(d.length(), 1000.0), "conserva la rapidez")


func prueba_choque_circulo_rect() -> void:
	caso("choque bola contra rectangulo")
	var r := Rect2(100, 100, 96, 44)
	var arriba := Fisica.choque(Vector2(148, 90), 16, r)
	comprobar(arriba["choca"] and arriba["normal"].is_equal_approx(Vector2(0, -1)), "desde arriba: normal hacia arriba")
	var lado := Fisica.choque(Vector2(90, 122), 16, r)
	comprobar(lado["choca"] and lado["normal"].is_equal_approx(Vector2(-1, 0)), "desde la izquierda: normal hacia la izquierda")
	comprobar(not Fisica.choque(Vector2(148, 50), 16, r)["choca"], "lejos: no choca")
	var esquina := Fisica.choque(Vector2(90, 90), 16, r)
	comprobar(esquina["choca"] and esquina["normal"].x < 0 and esquina["normal"].y < 0, "en la esquina: normal diagonal")
	var dentro := Fisica.choque(Vector2(110, 122), 16, r)
	comprobar(dentro["choca"] and dentro["normal"].is_equal_approx(Vector2(-1, 0)), "centro dentro: sale por el lado mas cercano")
	comprobar(Fisica.reflejar(Vector2(100, 200), Vector2(0, -1)).is_equal_approx(Vector2(100, -200)), "refleja la velocidad")
	comprobar(Fisica.reflejar(Vector2(100, -200), Vector2(0, -1)).is_equal_approx(Vector2(100, -200)), "si ya se aleja, no la cambia")


func prueba_angulo_minimo() -> void:
	caso("la bola nunca va casi horizontal")
	var v := Fisica.corregir_angulo(Vector2(1000, 10))
	comprobar(absf(v.y) >= 0.3 * 1000.0 - 0.01 and is_equal_approx(v.length(), Vector2(1000, 10).length()), "sube la componente vertical sin cambiar la rapidez")
	comprobar(Fisica.corregir_angulo(Vector2(0, -900)).is_equal_approx(Vector2(0, -900)), "si ya esta bien, no cambia")
	comprobar(Fisica.corregir_angulo(Vector2(1000, -10)).y < 0, "conserva el sentido vertical")


func _partida(filas: Array, semilla: int = 1) -> Partida:
	var p := Partida.new()
	p.cargar({"filas": filas, "velocidad": 1.0, "mundo": 0}, semilla)
	return p


func prueba_nivel_desde_texto() -> void:
	caso("nivel desde texto")
	var p := _partida(["1.2", "MDX", "T?."])
	comprobar(p.ladrillos.size() == 7, "cuenta los ladrillos (%d)" % p.ladrillos.size())
	comprobar(p.rompibles_restantes() == 6, "el metal no cuenta para terminar")
	var duro: Dictionary = p.ladrillos.filter(func(l): return l["tipo"] == Partida.DURO)[0]
	comprobar(duro["golpes"] == 2, "duro: 2 golpes")
	var t: Dictionary = p.ladrillos.filter(func(l): return l["golpes"] == 3)[0]
	comprobar(t["tipo"] == Partida.DURO, "T: duro de 3 golpes")


func _lanzar_hacia(p: Partida, objetivo: Vector2) -> void:
	p.lanzar()
	p.bolas[0]["v"] = (objetivo - p.bolas[0]["pos"]).normalized() * p.rapidez


func prueba_romper_ladrillo() -> void:
	caso("romper un ladrillo y ganar")
	var p := _partida(["....1....."])
	comprobar(not p.bolas[0]["libre"], "la bola espera en la paleta")
	p.mover_paleta(450)
	var l: Dictionary = p.ladrillos[0]
	_lanzar_hacia(p, l["rect"].get_center())
	for i in 600:
		p.paso(1.0 / 120)
		if p.ganada:
			break
	comprobar(p.ganada and p.ladrillos.is_empty(), "rompe el unico ladrillo y gana")
	comprobar(p.puntos > 0, "suma puntos")
	comprobar(p.eventos_de("rompe") >= 1, "avisa para el sonido y las particulas")


func prueba_ladrillos_especiales() -> void:
	caso("ladrillos duros, metal y explosivos")
	var p := _partida(["....D....."])
	p.golpear(p.ladrillos[0])
	comprobar(p.ladrillos.size() == 1 and p.ladrillos[0]["golpes"] == 1, "duro: aguanta un golpe")
	p.golpear(p.ladrillos[0])
	comprobar(p.ladrillos.is_empty(), "y se rompe al segundo")
	p = _partida(["....M....."])
	p.golpear(p.ladrillos[0])
	comprobar(p.ladrillos.size() == 1, "metal: no se rompe")
	p = _partida(["...111....", "...1X1....", "...111...M"])
	p.golpear(p.ladrillos.filter(func(l): return l["tipo"] == Partida.EXPLOSIVO)[0])
	comprobar(p.ladrillos.size() == 1 and p.ladrillos[0]["tipo"] == Partida.METAL, "explosivo: rompe sus 8 vecinos (el metal lejano queda)")
	p = _partida(["XX........"])
	p.golpear(p.ladrillos[0])
	comprobar(p.ladrillos.is_empty(), "las explosiones se encadenan")
	p = _partida(["?........."])
	p.golpear(p.ladrillos[0])
	comprobar(p.capsulas.size() == 1, "sorpresa: siempre suelta un potenciador")


func prueba_no_atraviesa_rapido() -> void:
	caso("a mucha velocidad no atraviesa ladrillos")
	var p := _partida(["....1....."])
	p.mover_paleta(450)
	p.lanzar()
	var l: Dictionary = p.ladrillos[0]
	p.bolas[0]["pos"] = l["rect"].get_center() + Vector2(0, 300)
	p.bolas[0]["v"] = Vector2(0, -6000)       # 50 px por paso de fisica
	for i in 10:
		p.paso(1.0 / 120)
	comprobar(p.ladrillos.is_empty(), "lo rompe en vez de atravesarlo")
	comprobar(p.bolas[0]["v"].y > 0, "y rebota hacia abajo")


func prueba_perder_bola() -> void:
	caso("perder la bola y las vidas")
	var p := _partida(["1........."])
	var vidas := p.vidas
	p.lanzar()
	p.bolas[0]["pos"] = Vector2(900, 1300)
	p.bolas[0]["v"] = Vector2(0, 1200)
	p.mover_paleta(100)
	for i in 120:
		p.paso(1.0 / 120)
	comprobar(p.vidas == vidas - 1, "pierde una vida")
	comprobar(p.bolas.size() == 1 and not p.bolas[0]["libre"], "la bola vuelve a la paleta")
	p.vidas = 1
	p.lanzar()
	p.bolas[0]["pos"] = Vector2(900, 1300)
	p.bolas[0]["v"] = Vector2(0, 1200)
	for i in 120:
		p.paso(1.0 / 120)
	comprobar(p.perdida, "sin vidas: partida perdida")


func prueba_potenciadores() -> void:
	caso("potenciadores")
	var p := _partida(["1111111111"])
	var ancho := p.ancho_paleta()
	p.aplicar(Partida.ANCHA)
	comprobar(p.ancho_paleta() > ancho, "paleta ancha")
	p.lanzar()
	p.aplicar(Partida.MULTIBOLA)
	comprobar(p.bolas.size() == 3, "multibola: 3 bolas")
	var vidas := p.vidas
	p.aplicar(Partida.VIDA)
	comprobar(p.vidas == vidas + 1, "vida extra")
	p.aplicar(Partida.LENTA)
	comprobar(p.bolas[0]["v"].length() < p.rapidez_base() * 1.0, "bola lenta")
	p.aplicar(Partida.FUEGO)
	var antes := p.ladrillos.size()
	p.bolas = [p.bolas[0]]
	p.bolas[0]["pos"] = p.ladrillos[3]["rect"].get_center() + Vector2(0, 80)
	p.bolas[0]["v"] = Vector2(0, -900)
	for i in 15:
		p.paso(1.0 / 120)
	comprobar(p.ladrillos.size() < antes and p.bolas[0]["v"].y < 0, "fuego: rompe sin rebotar")
	p = _partida(["1111111111"])
	p.aplicar(Partida.LASER)
	for i in 240:
		p.paso(1.0 / 120)
	comprobar(p.ladrillos.size() < 10, "laser: dispara y rompe ladrillos")
	p = _partida(["1........."])
	p.aplicar(Partida.IMAN)
	p.lanzar()
	p.bolas[0]["pos"] = Vector2(p.paleta_x, 1300)
	p.bolas[0]["v"] = Vector2(0, 900)
	for i in 60:
		p.paso(1.0 / 120)
	comprobar(not p.bolas[0]["libre"], "iman: atrapa la bola")
	p = _partida(["1........."])
	p.soltar_capsula(Partida.ANCHA, Vector2(p.paleta_x, 1200))
	for i in 120:
		p.paso(1.0 / 120)
	comprobar(p.capsulas.is_empty() and p.efecto_activo(Partida.ANCHA), "la capsula cae y se recoge con la paleta")
	p = _partida(["1........."])
	p.soltar_capsula(Partida.ANCHA, Vector2(50, 1200))
	p.mover_paleta(900)
	for i in 240:
		p.paso(1.0 / 120)
	comprobar(p.capsulas.is_empty() and not p.efecto_activo(Partida.ANCHA), "si no se recoge, se pierde")


func prueba_anti_atasco() -> void:
	caso("la bola no se queda en un bucle")
	var p := _partida(["M.......1M"])
	p.lanzar()
	p.bolas[0]["pos"] = Vector2(500, 600)
	p.bolas[0]["v"] = Vector2(0, -1000)        # arriba y abajo para siempre si nadie la mueve
	var x0: float = p.bolas[0]["pos"].x
	for i in 120 * 14:
		p.mover_paleta(p.bolas[0]["pos"].x)    # paleta siempre debajo: bucle perfecto
		p.paso(1.0 / 120)
	comprobar(absf(p.bolas[0]["pos"].x - x0) > 30 or absf(p.bolas[0]["v"].x) > 1, "tras unos segundos sin ladrillos, cambia el angulo")


func prueba_niveles_generados() -> void:
	caso("niveles generados")
	comprobar(Niveles.total() >= 120, "al menos 120 niveles (%d)" % Niveles.total())
	comprobar(Niveles.mundos().size() == 6, "6 mundos")
	var ok := true
	for i in Niveles.total():
		var n := Niveles.nivel(i)
		var p := Partida.new()
		p.cargar(n, 1)
		if p.rompibles_restantes() == 0 or n["filas"].size() > Partida.FILAS_MAX:
			ok = false
			printerr("    nivel %d invalido" % i)
	comprobar(ok, "todos tienen ladrillos que romper y caben")


## Un jugador automatico (paleta siempre bajo la bola que mas baja) juega cada nivel:
## si alguno no se termina en un tiempo razonable, hay un atasco o un nivel imposible.
func prueba_todos_los_niveles_se_terminan() -> void:
	caso("cada nivel se puede terminar")
	var lentos := []
	var tiempos := []
	for i in Niveles.total():
		var p := Partida.new()
		p.cargar(Niveles.nivel(i), 7)
		p.lanzar()
		var t := 0.0
		while not p.ganada and not p.perdida and t < 360.0:
			var objetivo := p.bola_mas_baja()
			p.mover_paleta(objetivo.x + sin(t * 1.7) * p.ancho_paleta() * 0.3)
			if p.esperando():
				p.lanzar()
			p.paso(1.0 / 60)
			t += 1.0 / 60
		tiempos.append(t)
		if not p.ganada:
			lentos.append("%d (%s, %.0f s, quedan %d)" % [i + 1, "perdida" if p.perdida else "sin terminar", t, p.rompibles_restantes()])
	comprobar(lentos.is_empty(), "todos se terminan: fallan %s" % str(lentos.slice(0, 5)))
	var medio := 0.0
	for t in tiempos:
		medio += t
	print("    tiempo medio del jugador automatico: %.0f s; max %.0f s" % [medio / maxf(tiempos.size(), 1), tiempos.max() if not tiempos.is_empty() else 0])


func _borrar_progreso() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Progreso.ruta))
	for f in DirAccess.get_files_at("user://"):
		if f.begins_with(Progreso.ruta.get_file() + ".rechazado-"):
			DirAccess.remove_absolute(ProjectSettings.globalize_path("user://" + f))


func _reiniciar_progreso() -> void:
	_borrar_progreso()
	Progreso.datos = Progreso.por_defecto()


## Escribe un archivo de progreso con firma valida (como lo dejaria el juego).
func _escribir_firmado(d: Dictionary) -> void:
	var cuerpo := JSON.stringify(d)
	var f := FileAccess.open(Progreso.ruta, FileAccess.WRITE)
	f.store_string(Progreso._firmar(cuerpo) + "\n" + cuerpo)
	f.close()


func prueba_progreso() -> void:
	caso("progreso y estrellas")
	_reiniciar_progreso()
	comprobar(Progreso.estrellas(0) == 0 and Progreso.desbloqueado(0) and not Progreso.desbloqueado(1), "empieza con el primer nivel abierto")
	Progreso.registrar(0, 2, 1500)
	comprobar(Progreso.estrellas(0) == 2 and Progreso.desbloqueado(1), "guarda estrellas y abre el siguiente")
	Progreso.registrar(0, 1, 900)
	comprobar(Progreso.estrellas(0) == 2 and Progreso.record(0) == 1500, "se queda con lo mejor")
	Progreso.cargar()
	comprobar(Progreso.estrellas(0) == 2, "se guarda en disco")
	_escribir_firmado({"niveles": {"0": {"estrellas": 9, "record": -5}, "x": 3}, "gemas": -40})
	Progreso.cargar()
	comprobar(Progreso.estrellas(0) == 3 and Progreso.record(0) == 0 and Progreso.gemas() == 0, "datos raros aunque firmados: se acotan")
	comprobar(Partida.estrellas_por(3, 3) == 3 and Partida.estrellas_por(3, 2) == 2 and Partida.estrellas_por(3, 1) == 1, "estrellas segun vidas perdidas")


func prueba_progreso_firmado() -> void:
	caso("progreso firmado: las gemas no se editan a mano")
	_reiniciar_progreso()
	Progreso.sumar_gemas(120)
	Progreso.cargar()
	comprobar(Progreso.gemas() == 120 and Progreso.ultimo_rechazo == "", "lo guardado por el juego se lee")
	var f := FileAccess.open(Progreso.ruta, FileAccess.WRITE)
	f.store_string('{"gemas": 999999, "sin_anuncios": true}')
	f.close()
	Progreso.cargar()
	comprobar(Progreso.gemas() == 0 and not Progreso.sin_anuncios() and Progreso.ultimo_rechazo == "formato", "JSON sin firma: se rechaza")
	Progreso.sumar_gemas(30)
	var texto := FileAccess.get_file_as_string(Progreso.ruta).replace('"gemas":30', '"gemas":90000')
	f = FileAccess.open(Progreso.ruta, FileAccess.WRITE)
	f.store_string(texto)
	f.close()
	Progreso.cargar()
	comprobar(Progreso.gemas() == 0 and Progreso.ultimo_rechazo == "firma", "cambiar las gemas rompe la firma")
	var apartados := Array(DirAccess.get_files_at("user://")).filter(func(n): return n.begins_with(Progreso.ruta.get_file() + ".rechazado-"))
	comprobar(apartados.size() == 2, "el archivo rechazado se aparta, no se borra (%d)" % apartados.size())
	_reiniciar_progreso()


func prueba_economia() -> void:
	caso("economia de gemas")
	_reiniciar_progreso()
	comprobar(Economia.gemas_por_nivel(0, 3) == Economia.GEMAS_NIVEL + 3 * Economia.GEMAS_ESTRELLA, "primera vez con 3 estrellas")
	comprobar(Economia.gemas_por_nivel(3, 1) == Economia.GEMAS_NIVEL, "repetir sin mejorar: solo la base")
	var g := Progreso.registrar(0, 2, 100)
	comprobar(g == Economia.gemas_por_nivel(0, 2) and Progreso.gemas() == g, "superar un nivel da gemas")
	var g2 := Progreso.registrar(0, 3, 100)
	comprobar(g2 == Economia.GEMAS_NIVEL + Economia.GEMAS_ESTRELLA and Progreso.gemas() == g + g2, "solo las estrellas nuevas suman extra")
	comprobar(Progreso.registrar(1, 0, 0) == 0, "sin estrellas (no superado) no da gemas")
	var antes := Progreso.gemas()
	comprobar(not Progreso.gastar_gemas(antes + 1) and Progreso.gemas() == antes, "no se gasta lo que no hay")
	comprobar(not Progreso.gastar_gemas(-10) and Progreso.gemas() == antes, "gasto negativo no regala")
	comprobar(Progreso.gastar_gemas(antes) and Progreso.gemas() == 0, "se gasta lo justo")
	Progreso.sumar_gemas(-50)
	comprobar(Progreso.gemas() == 0, "sumar negativo no resta")
	# Ritmo: jugando sin pagar, ¿cuanto cuesta lo mas caro? (referencia para el balance)
	var por_mundo := 20 * Economia.gemas_por_nivel(0, 2)
	comprobar(Aspectos.buscar("paleta", "oro")["precio"] <= 2 * por_mundo, "la paleta mas cara se gana en <= 2 mundos (%d gemas por mundo)" % por_mundo)
	for k in Economia.ARRANQUES:
		comprobar(Economia.ARRANQUES[k]["precio"] <= 4 * Economia.gemas_por_nivel(0, 2), "potenciador %s: como mucho 4 niveles de gemas" % k)


func prueba_aspectos() -> void:
	caso("personalizacion: comprar y equipar")
	_reiniciar_progreso()
	for tipo in Aspectos.TIPOS:
		comprobar(Progreso.equipado(tipo)["id"] == Aspectos.por_defecto(tipo) and int(Progreso.equipado(tipo)["precio"]) == 0, "%s: el de serie es gratis y va puesto" % tipo)
		var ids := {}
		for a in Aspectos.lista(tipo):
			ids[a["id"]] = true
		comprobar(ids.size() == Aspectos.lista(tipo).size(), "%s: ids sin repetir" % tipo)
	comprobar(not Progreso.equipar("bola", "rubi"), "no se equipa lo que no se tiene")
	comprobar(not Progreso.comprar_aspecto("bola", "rubi") and not Progreso.tiene_aspecto("bola", "rubi"), "sin gemas no se compra")
	comprobar(not Progreso.comprar_aspecto("bola", "inventada"), "aspecto inexistente: no")
	Progreso.sumar_gemas(130)
	comprobar(Progreso.comprar_aspecto("bola", "rubi") and Progreso.gemas() == 30, "comprar cobra su precio")
	comprobar(Progreso.comprar_aspecto("bola", "rubi") and Progreso.gemas() == 30, "comprarlo otra vez no cobra")
	comprobar(Progreso.equipar("bola", "rubi") and Progreso.equipado("bola")["id"] == "rubi", "y se equipa")
	Progreso.cargar()
	comprobar(Progreso.tiene_aspecto("bola", "rubi") and Progreso.equipado("bola")["id"] == "rubi", "se guarda")
	_escribir_firmado({"comprados": ["bola:sol", "paleta:nada", 7], "equipados": {"paleta": "oro", "bola": "sol", "estela": "x"}})
	Progreso.cargar()
	comprobar(Progreso.tiene_aspecto("bola", "sol") and Progreso.equipado("bola")["id"] == "sol", "comprados validos se leen")
	comprobar(Progreso.equipado("paleta")["id"] == "clasica" and Progreso.equipado("estela")["id"] == "ninguna", "equipado sin comprar o inventado: vuelve al de serie")
	_reiniciar_progreso()


func prueba_reglas_anuncios() -> void:
	caso("reglas de anuncios a pantalla completa")
	var base := {"superados": 30, "desde_ultimo_s": INF, "superados_desde_ultimo": 3}
	comprobar(ReglasAnuncios.intersticial_permitido(base), "jugador veterano tras 3 niveles: si")
	var c := base.duplicate()
	c["superados"] = ReglasAnuncios.NIVELES_SIN_ANUNCIOS
	comprobar(not ReglasAnuncios.intersticial_permitido(c), "los 10 primeros niveles sin anuncios")
	c = base.duplicate()
	c["sin_anuncios"] = true
	comprobar(not ReglasAnuncios.intersticial_permitido(c), "compro quitar anuncios: nunca")
	c = base.duplicate()
	c["tras_perder"] = true
	comprobar(not ReglasAnuncios.intersticial_permitido(c), "tras perder: nunca")
	c = base.duplicate()
	c["abandono"] = true
	comprobar(not ReglasAnuncios.intersticial_permitido(c), "al abandonar: nunca")
	c = base.duplicate()
	c["desde_ultimo_s"] = 60.0
	comprobar(not ReglasAnuncios.intersticial_permitido(c), "menos de 3 minutos desde el anterior: no")
	c = base.duplicate()
	c["superados_desde_ultimo"] = 2
	comprobar(not ReglasAnuncios.intersticial_permitido(c), "menos de 3 niveles desde el anterior: no")


func prueba_revivir() -> void:
	caso("seguir tras perder")
	var p := _partida(["1111111111"])
	p.revivir()
	comprobar(not p.perdida and p.vidas == Partida.VIDAS, "sin haber perdido no hace nada")
	p.vidas = 1
	p.lanzar()
	p.bolas[0]["pos"] = Vector2(900, 1300)
	p.bolas[0]["v"] = Vector2(0, 1200)
	p.mover_paleta(100)
	for i in 120:
		p.paso(1.0 / 120)
	comprobar(p.perdida, "pierde la ultima vida")
	var ladrillos := p.ladrillos.size()
	p.revivir()
	comprobar(not p.perdida and p.vidas == 1 and p.esperando() and p.ladrillos.size() == ladrillos, "sigue con 1 vida, la bola en la paleta y los ladrillos como estaban")
	comprobar(p.eventos_de("revive") == 1, "avisa a la escena")


func prueba_arranques() -> void:
	caso("potenciadores comprados al empezar")
	var p := _partida(["1111111111"])
	comprobar(p.preparar_arranque(Partida.MULTIBOLA) and p.bolas.size() == 1 and p.esperando(), "multibola: espera al lanzamiento")
	comprobar(not p.preparar_arranque(Partida.MULTIBOLA), "el mismo, solo una vez")
	var ancho := p.ancho_paleta()
	comprobar(p.preparar_arranque(Partida.ANCHA), "paleta ancha preparada")
	for i in 240:
		p.paso(1.0 / 120)
	comprobar(p.ancho_paleta() == ancho, "mientras la bola espera no se gasta su tiempo")
	var vidas := p.vidas
	comprobar(p.preparar_arranque(Partida.VIDA) and p.vidas == vidas + 1, "vida extra: al momento")
	p.lanzar()
	comprobar(p.bolas.size() == 3 and p.efecto_activo(Partida.ANCHA) and is_equal_approx(p.tiempo_efecto(Partida.ANCHA), Partida.DURACION[Partida.ANCHA]), "al lanzar: 3 bolas y la paleta ancha entera")
	comprobar(not p.preparar_arranque(Partida.ANCHA), "ya lanzada: no se compran mas")


func prueba_premiados() -> void:
	caso("anuncios premiados (simulados en depuracion)")
	_reiniciar_progreso()
	var hoy := Progreso.hoy()
	var ok: bool = await Monetizacion.mostrar_premiado("gemas")
	comprobar(ok and Progreso.gemas() == Economia.GEMAS_PREMIADO, "ver un anuncio da gemas")
	comprobar(Progreso.premiados_restantes(hoy) == Economia.PREMIADOS_DIA - 1, "cuenta para el tope del dia")
	ok = await Monetizacion.mostrar_premiado("doble")
	comprobar(ok and Progreso.gemas() == Economia.GEMAS_PREMIADO and Progreso.premiados_restantes(hoy) == Economia.PREMIADOS_DIA - 1, "doblar o seguir: no suman gemas solos ni gastan el tope")
	for i in Economia.PREMIADOS_DIA:
		await Monetizacion.mostrar_premiado("gemas")
	comprobar(Progreso.gemas() == Economia.GEMAS_PREMIADO * Economia.PREMIADOS_DIA and Progreso.premiados_restantes(hoy) == 0, "tope de %d al dia" % Economia.PREMIADOS_DIA)
	comprobar(Progreso.premiados_restantes("2099-01-01") == Economia.PREMIADOS_DIA, "al dia siguiente se renueva")
	Monetizacion.simulado_exito = false
	_reiniciar_progreso()
	ok = await Monetizacion.mostrar_premiado("gemas")
	comprobar(not ok and Progreso.gemas() == 0, "anuncio cerrado antes de tiempo: sin premio")
	Monetizacion.simulado_exito = true
	Monetizacion.permitir_anuncio_simulado = false
	ok = await Monetizacion.mostrar_premiado("gemas")
	comprobar(not ok and Progreso.gemas() == 0, "release sin plugin de anuncios: no regala")
	Monetizacion.permitir_anuncio_simulado = true
	comprobar(Monetizacion.ids_anuncios()["premiado"] == Monetizacion.ADMOB_TEST_PREMIADO, "en depuracion siempre las unidades de prueba de AdMob")


func prueba_intersticial() -> void:
	caso("anuncio entre niveles: cuando sale")
	_reiniciar_progreso()
	Monetizacion._ultimo_intersticial_ms = -1
	Monetizacion._superados_desde_ultimo = 0
	for i in 12:
		Progreso.registrar(i, 2, 100)
		Monetizacion.nivel_superado()
	comprobar(not await Monetizacion.intentar_intersticial(true), "tras perder no sale")
	comprobar(not await Monetizacion.intentar_intersticial(false, true), "al abandonar no sale")
	comprobar(await Monetizacion.intentar_intersticial(), "nivel 12 superado, 3+ desde el ultimo: sale")
	Monetizacion.nivel_superado()
	Monetizacion.nivel_superado()
	Monetizacion.nivel_superado()
	comprobar(not await Monetizacion.intentar_intersticial(), "otro enseguida: no (3 minutos)")
	Monetizacion._ultimo_intersticial_ms = -1
	Progreso.fijar_sin_anuncios(true)
	comprobar(not await Monetizacion.intentar_intersticial(), "con quitar anuncios: no")
	_reiniciar_progreso()


func prueba_compras_simuladas() -> void:
	caso("compras (simuladas en el editor)")
	_reiniciar_progreso()
	var ok: bool = await Monetizacion.comprar("gemas_500")
	comprobar(ok and Progreso.gemas() == 500, "paquete de gemas")
	ok = await Monetizacion.comprar("sin_anuncios")
	comprobar(ok and Progreso.sin_anuncios(), "quitar anuncios")
	ok = await Monetizacion.comprar("gemas_infinitas")
	comprobar(not ok and Progreso.gemas() == 500, "producto desconocido: no")
	Monetizacion.conceder("gemas_infinitas")
	comprobar(Progreso.gemas() == 500, "conceder fuera del catalogo no da nada")
	Monetizacion.permitir_compra_simulada = false
	ok = await Monetizacion.comprar("gemas_4000")
	comprobar(not ok and Progreso.gemas() == 500, "APK sin plugin de pagos: no regala")
	Monetizacion.permitir_compra_simulada = true
	for k in Monetizacion.PRODUCTOS:
		comprobar(k == k.to_lower() and k.length() <= 40, "id de producto valido para Play: %s" % k)
	_reiniciar_progreso()


func _esperar_frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func prueba_cobro_play() -> void:
	caso("cobro con Google Play Billing (cliente falso)")
	_reiniciar_progreso()
	var falso := FalsoBilling.new()
	# Sesion anterior: gemas pagadas sin consumir (la app se cerro) y quitar anuncios ya reconocido.
	falso.compras_previas = [FalsoBilling.compra("gemas_500", 1, "tok_viejo"), FalsoBilling.compra("sin_anuncios", 1, "tok_sa", true)]
	falso.precios = {"gemas_500": "1,09 €"}
	comprobar(Monetizacion.precio("gemas_500").begins_with("≈"), "sin Play: precio de referencia marcado como aproximado")
	var pagos := PagosPlay.new(falso, PackedStringArray(Monetizacion.PRODUCTOS.keys()), Monetizacion.consumibles())
	pagos.compra_confirmada.connect(Monetizacion.conceder)
	pagos.permanentes_sincronizados.connect(Monetizacion.sincronizar_permanentes)
	Monetizacion.pagos = pagos
	await _esperar_frames(4)
	comprobar("tok_viejo" in falso.consumidos and Progreso.gemas() == 500, "recupera al abrir las gemas sin entregar")
	comprobar(Progreso.sin_anuncios() and not ("tok_sa" in falso.consumidos), "restaura quitar anuncios (no se consume)")
	comprobar(Monetizacion.precio("gemas_500") == "1,09 €", "muestra el precio local que da Play")
	var ok: bool = await Monetizacion.comprar("gemas_1500")
	comprobar(ok and Progreso.gemas() == 2000, "se cobra, se consume y se entrega UNA vez")
	falso.modo = "cancelar"
	ok = await Monetizacion.comprar("gemas_1500")
	comprobar(not ok and Progreso.gemas() == 2000, "cancelada: nada y sin colgarse")
	falso.modo = "falla_confirmar"
	ok = await Monetizacion.comprar("gemas_500")
	comprobar(not ok and Progreso.gemas() == 2000, "si Play no confirma el consumo, no se entrega")
	falso.modo = "ok"
	falso.compras_previas = []
	Monetizacion.restaurar_compras()
	await _esperar_frames(3)
	comprobar(not Progreso.sin_anuncios(), "Play ya no tiene quitar anuncios (reembolso): se retira")
	ok = await Monetizacion.comprar("sin_anuncios")
	await _esperar_frames(2)
	comprobar(ok and Progreso.sin_anuncios() and falso.reconocidos.size() == 1, "compra nueva de quitar anuncios: se reconoce (acknowledge)")
	Monetizacion.pagos = null
	_reiniciar_progreso()


## El menu decia "sin anuncios" cuando el juego era de pago: con anuncios seria publicidad engañosa.
func prueba_textos_sin_promesas_falsas() -> void:
	caso("textos coherentes con un juego gratis con anuncios")
	for f in ["res://escenas/menu.gd", "res://escenas/mundos.gd", "res://escenas/juego.gd"]:
		comprobar(not FileAccess.get_file_as_string(f).to_lower().contains("· sin anuncios"), "%s no promete 'sin anuncios'" % f.get_file())
	var presets := FileAccess.get_file_as_string("res://export_presets.cfg")
	comprobar(presets.contains("permissions/internet=true") and presets.contains("permissions/access_network_state=true"), "export con permisos de red (AdMob y Billing)")


class ContadorErrores extends Logger:
	var errores: Array[String] = []
	func _log_error(_f: String, file: String, line: int, code: String, rationale: String, _n: bool, tipo: int, _bt: Array[ScriptBacktrace]) -> void:
		if tipo != ERROR_TYPE_WARNING:
			errores.append("%s:%d %s %s" % [file, line, code, rationale])
	func _log_message(_m: String, _e: bool) -> void:
		pass


func prueba_pantallas() -> void:
	caso("las pantallas cargan sin errores")
	var log := ContadorErrores.new()
	OS.add_logger(log)
	for nombre in ["menu", "mundos", "juego", "tienda", "personalizar"]:
		var ruta := "res://escenas/%s.tscn" % nombre
		comprobar(ResourceLoader.exists(ruta), "existe %s" % ruta)
		if not ResourceLoader.exists(ruta):
			continue
		var escena: Node = load(ruta).instantiate()
		add_child(escena)
		for i in 30:
			await get_tree().process_frame
		escena.queue_free()
		await get_tree().process_frame
	OS.remove_logger(log)
	comprobar(log.errores.is_empty(), "sin errores: %s" % str(log.errores.slice(0, 3)))


func _boton(raiz: Node, texto: String) -> Button:
	for b in raiz.find_children("*", "Button", true, false):
		if (b as Button).text == texto and b.is_visible_in_tree():
			return b
	return null


func _esperar_s(t: float) -> void:
	await get_tree().create_timer(t).timeout


## Pulsa el boton de un dialogo en cuanto aparece (los dialogos son await).
## Espera por tiempo, no por frames: sin pantalla los frames duran casi nada.
func _pulsar(raiz: Node, texto: String, espera_s: float = 3.0) -> bool:
	var limite := Time.get_ticks_msec() + int(espera_s * 1000)
	while Time.get_ticks_msec() < limite:
		var b := _boton(raiz, texto)
		if b:
			b.pressed.emit()
			await _esperar_s(0.05)
			return true
		await get_tree().process_frame
	return false


func _textos_botones(raiz: Node) -> Array:
	return raiz.find_children("*", "Button", true, false).map(func(b): return b.text)


func prueba_flujos_tienda() -> void:
	caso("tienda y personalizar, tocando botones")
	_reiniciar_progreso()
	var tienda: Node = load("res://escenas/tienda.tscn").instantiate()
	add_child(tienda)
	await _esperar_frames(3)
	(tienda.find_child("Comprar_gemas_500", true, false) as Button).pressed.emit()
	await _esperar_s(0.5)
	comprobar(Progreso.gemas() == 500, "comprar 500 gemas desde la tienda")
	(tienda.find_child("Comprar_anuncio", true, false) as Button).pressed.emit()
	await _esperar_s(0.2)
	comprobar(Progreso.gemas() == 500 + Economia.GEMAS_PREMIADO, "boton de anuncio: +%d" % Economia.GEMAS_PREMIADO)
	(tienda.find_child("Comprar_sin_anuncios", true, false) as Button).pressed.emit()
	await _esperar_s(0.5)
	var b := tienda.find_child("Comprar_sin_anuncios", true, false) as Button
	comprobar(Progreso.sin_anuncios() and b and b.disabled and b.text.begins_with("Comprado"), "quitar anuncios: comprado y el boton lo dice")
	tienda.queue_free()
	await _esperar_frames(2)

	var pers: Node = load("res://escenas/personalizar.tscn").instantiate()
	add_child(pers)
	await _esperar_frames(3)
	pers.tipo = "bola"
	pers.construir()
	await _esperar_frames(2)
	(pers.find_child("Aspecto_galaxia", true, false) as Button).pressed.emit()
	comprobar(await _pulsar(pers, "Comprar y usar"), "pide confirmar la compra")
	comprobar(Progreso.tiene_aspecto("bola", "galaxia") and Progreso.equipado("bola")["id"] == "galaxia" and Progreso.gemas() == 525 - 350, "compra y se pone la bola")
	(pers.find_child("Aspecto_plata", true, false) as Button).pressed.emit()
	await _esperar_frames(2)
	comprobar(Progreso.equipado("bola")["id"] == "plata" and Progreso.gemas() == 175, "volver a la de serie: sin cobrar")
	pers.tipo = "paleta"
	pers.construir()
	await _esperar_frames(2)
	(pers.find_child("Aspecto_oro", true, false) as Button).pressed.emit()
	comprobar(await _pulsar(pers, "Cerrar"), "sin gemas suficientes: lo dice y ofrece la tienda")
	comprobar(not Progreso.tiene_aspecto("paleta", "oro") and Progreso.gemas() == 175, "y no cobra")
	pers.queue_free()
	await _esperar_frames(2)
	_reiniciar_progreso()


func prueba_flujos_partida() -> void:
	caso("partida: potenciadores, seguir y doblar gemas")
	_reiniciar_progreso()
	Progreso.sumar_gemas(100)
	var Juego = load("res://escenas/juego.gd")
	Juego.nivel_idx = 0
	var j: Node = load("res://escenas/juego.tscn").instantiate()
	add_child(j)
	await _esperar_frames(3)
	comprobar(j.find_child("Arranque_ancha", true, false) == null, "niveles 1 a 3: no se venden potenciadores")
	j.queue_free()
	await _esperar_frames(2)

	Juego.nivel_idx = 5
	j = load("res://escenas/juego.tscn").instantiate()
	add_child(j)
	await _esperar_frames(3)
	var ancha := j.find_child("Arranque_ancha", true, false) as Button
	comprobar(ancha != null and ancha.is_visible_in_tree(), "nivel 6: potenciadores a la venta antes de lanzar")
	ancha.pressed.emit()
	await _esperar_frames(1)
	comprobar(Progreso.gemas() == 100 - Economia.ARRANQUES["ancha"]["precio"] and ancha.disabled, "comprar paleta ancha cobra y se bloquea")
	j.partida.lanzar()
	await _esperar_frames(2)
	comprobar(not ancha.is_visible_in_tree() and j.partida.efecto_activo(Partida.ANCHA), "al lanzar: se activa y la fila se esconde")

	# Perder la ultima vida: ofrece seguir.
	j.partida.perdida = true
	comprobar(await _pulsar(j, "Seguir por %d gemas" % Economia.PRECIO_SEGUIR), "al perder ofrece seguir con gemas")
	await _esperar_frames(2)
	comprobar(not j.partida.perdida and j.partida.vidas == 1 and Progreso.gemas() == 20, "sigue con 1 vida y cobra %d" % Economia.PRECIO_SEGUIR)
	j.partida.perdida = true
	await _esperar_s(1.0)
	# (no se pulsa: "Reintentar" cambia de escena y se llevaria por delante a este ejecutor)
	comprobar(_boton(j, "Reintentar") != null and not ("No, gracias" in _textos_botones(j)), "la segunda vez ya no ofrece seguir")
	j.queue_free()
	await _esperar_frames(2)

	# Ganar: gemas y doblarlas con un anuncio (simulado).
	j = load("res://escenas/juego.tscn").instantiate()
	add_child(j)
	await _esperar_frames(3)
	var antes := Progreso.gemas()
	j.partida.ganada = true
	j.partida.vidas = j.partida.vidas_iniciales
	comprobar(await _pulsar(j, "Doblar gemas (anuncio)"), "al ganar ofrece doblar las gemas")
	await _esperar_s(0.2)
	var ganadas := Economia.gemas_por_nivel(0, 3)
	comprobar(Progreso.gemas() == antes + 2 * ganadas, "gemas dobladas (%d -> %d)" % [antes, Progreso.gemas()])
	await _esperar_s(0.2)
	comprobar(_boton(j, "Siguiente nivel") != null and _boton(j, "Doblar gemas (anuncio)") == null, "vuelve el dialogo sin la opcion de doblar")
	j.queue_free()
	await _esperar_frames(2)

	# Con "quitar anuncios": seguir gratis.
	Progreso.fijar_sin_anuncios(true)
	j = load("res://escenas/juego.tscn").instantiate()
	add_child(j)
	await _esperar_frames(3)
	j.partida.perdida = true
	await _esperar_s(1.0)
	comprobar("Seguir gratis" in _textos_botones(j) and not ("Seguir (anuncio)" in _textos_botones(j)), "con quitar anuncios: seguir gratis, sin anuncio")
	j.queue_free()
	await _esperar_frames(2)
	_reiniciar_progreso()
