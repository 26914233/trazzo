# Pruebas de Rebotazz. Se ejecutan como escena (autoloads cargados):
#
#   godot --headless --path juegos/rebote res://tests/pruebas.tscn
#
# Sale con codigo 0 si todo pasa y 1 si algo falla.
extends Node

var _fallos := 0
var _total := 0
var _actual := ""


func _ready() -> void:
	Ajustes.ruta = "user://prueba_ajustes.json"
	Ajustes.datos["sonido"] = false
	Progreso.ruta = "user://prueba_progreso.json"
	Progreso.datos = {}

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
	await prueba_pantallas()

	DirAccess.remove_absolute(ProjectSettings.globalize_path(Ajustes.ruta))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Progreso.ruta))
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


func prueba_progreso() -> void:
	caso("progreso y estrellas")
	Progreso.datos = {}
	comprobar(Progreso.estrellas(0) == 0 and Progreso.desbloqueado(0) and not Progreso.desbloqueado(1), "empieza con el primer nivel abierto")
	Progreso.registrar(0, 2, 1500)
	comprobar(Progreso.estrellas(0) == 2 and Progreso.desbloqueado(1), "guarda estrellas y abre el siguiente")
	Progreso.registrar(0, 1, 900)
	comprobar(Progreso.estrellas(0) == 2 and Progreso.record(0) == 1500, "se queda con lo mejor")
	Progreso.cargar()
	comprobar(Progreso.estrellas(0) == 2, "se guarda en disco")
	var f := FileAccess.open(Progreso.ruta, FileAccess.WRITE)
	f.store_string('{"niveles": {"0": {"estrellas": 9, "record": -5}, "x": 3}}')
	f.close()
	Progreso.cargar()
	comprobar(Progreso.estrellas(0) == 3 and Progreso.record(0) == 0, "datos raros: se acotan")
	comprobar(Partida.estrellas_por(3, 3) == 3 and Partida.estrellas_por(3, 2) == 2 and Partida.estrellas_por(3, 1) == 1, "estrellas segun vidas perdidas")


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
	for nombre in ["menu", "mundos", "juego"]:
		var escena: Node = load("res://escenas/%s.tscn" % nombre).instantiate()
		add_child(escena)
		for i in 30:
			await get_tree().process_frame
		escena.queue_free()
		await get_tree().process_frame
	OS.remove_logger(log)
	comprobar(log.errores.is_empty(), "sin errores: %s" % str(log.errores.slice(0, 3)))
