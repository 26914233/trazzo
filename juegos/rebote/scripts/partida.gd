# Una partida: ladrillos, bolas, paleta, potenciadores y reglas. Sin nodos ni
# dibujo, para probarla sin pantalla; la escena lee el estado y los eventos.
#
# Coordenadas del campo: 1000 x 1500 (la escena lo escala a la pantalla).
class_name Partida
extends RefCounted

const CAMPO := Vector2(1000, 1500)
const COLUMNAS := 10
const FILAS_MAX := 16
const CELDA := Vector2(100, 50)
const ARRIBA := 110.0                  # primera fila de ladrillos
const HUECO := Vector2(2, 3)           # separacion dentro de la celda
const RADIO := 16.0
const PALETA_Y := 1380.0
const PALETA_ALTO := 34.0
const PALETA_ANCHO := 200.0
const RAPIDEZ_BASE := 900.0
const RAPIDEZ_MAX := 1.6               # veces la inicial
const SUBIDA_CADA := 5.0               # s: la bola acelera un poco
const SUBIDA := 1.015
const SIN_LADRILLO_MAX := 8.0          # s sin tocar un ladrillo: empujon anti-atasco
const PROB_CAPSULA := 0.1
const CAIDA_CAPSULA := 380.0
const VIDAS := 3

enum { NORMAL, DURO, METAL, EXPLOSIVO, SORPRESA }
enum { ANCHA, MULTIBOLA, LASER, IMAN, LENTA, FUEGO, VIDA, CORTA }
const DURACION := {ANCHA: 15.0, LASER: 10.0, IMAN: 12.0, LENTA: 10.0, FUEGO: 8.0, CORTA: 12.0}
const BUENOS := [ANCHA, MULTIBOLA, LASER, IMAN, LENTA, FUEGO, VIDA]

var ladrillos: Array = []        # [{rect, tipo, golpes, color, celda}]
var _rejilla := {}               # Vector2i -> ladrillo
var bolas: Array = []            # [{pos, v, libre, pegada_x}]
var capsulas: Array = []         # [{pos, tipo}]
var laseres: Array = []          # [Vector2]
var paleta_x := CAMPO.x / 2.0
var vidas := VIDAS
var vidas_iniciales := VIDAS
var puntos := 0
var combo := 0
var rapidez := RAPIDEZ_BASE
var ganada := false
var perdida := false
var mundo := 0

var _rapidez_inicial := RAPIDEZ_BASE
var _efectos := {}               # tipo -> segundos que quedan
var _rng := RandomNumberGenerator.new()
var _t_subida := 0.0
var _sin_ladrillo := 0.0
var _empujon := 1.0
var _t_laser := 0.0
var _eventos: Array = []
var _cuenta_eventos := {}


func cargar(nivel: Dictionary, semilla: int) -> void:
	_rng.seed = semilla
	mundo = int(nivel.get("mundo", 0))
	ladrillos.clear()
	_rejilla.clear()
	var filas: Array = nivel.get("filas", [])
	for f in mini(filas.size(), FILAS_MAX):
		var fila: String = filas[f]
		for c in mini(fila.length(), COLUMNAS):
			var ch := fila[c]
			if ch == ".":
				continue
			var l := {"celda": Vector2i(c, f), "color": 0, "tipo": NORMAL, "golpes": 1,
				"rect": Rect2(Vector2(c, f) * CELDA + Vector2(0, ARRIBA) + HUECO, CELDA - HUECO * 2)}
			match ch:
				"D":
					l["tipo"] = DURO; l["golpes"] = 2
				"T":
					l["tipo"] = DURO; l["golpes"] = 3
				"M":
					l["tipo"] = METAL; l["golpes"] = -1
				"X":
					l["tipo"] = EXPLOSIVO
				"?":
					l["tipo"] = SORPRESA
				_:
					l["color"] = clampi(ch.to_int(), 1, 6) - 1 if ch.is_valid_int() else 0
			ladrillos.append(l)
			_rejilla[l["celda"]] = l
	_rapidez_inicial = RAPIDEZ_BASE * float(nivel.get("velocidad", 1.0))
	rapidez = _rapidez_inicial
	vidas = VIDAS
	vidas_iniciales = VIDAS
	_reiniciar_bola()


# ---------------------------------------------------------------- consultas

func rompibles_restantes() -> int:
	return ladrillos.filter(func(l): return l["tipo"] != METAL).size()


func ancho_paleta() -> float:
	if efecto_activo(ANCHA):
		return PALETA_ANCHO * 1.5
	if efecto_activo(CORTA):
		return PALETA_ANCHO * 0.65
	return PALETA_ANCHO


func rapidez_base() -> float:
	return rapidez


func velocidad_actual() -> float:
	return rapidez * (0.7 if efecto_activo(LENTA) else 1.0)


func efecto_activo(tipo: int) -> bool:
	return _efectos.get(tipo, 0.0) > 0.0


func tiempo_efecto(tipo: int) -> float:
	return _efectos.get(tipo, 0.0)


func esperando() -> bool:
	return bolas.any(func(b): return not b["libre"])


func bola_mas_baja() -> Vector2:
	var mejor := Vector2(paleta_x, 0)
	for b in bolas:
		if b["pos"].y > mejor.y:
			mejor = b["pos"]
	return mejor


static func estrellas_por(vidas_al_empezar: int, vidas_al_terminar: int) -> int:
	var perdidas := vidas_al_empezar - vidas_al_terminar
	return 3 if perdidas <= 0 else 2 if perdidas == 1 else 1


## Eventos desde la ultima llamada (para sonidos, particulas y textos).
func tomar_eventos() -> Array:
	var e := _eventos
	_eventos = []
	return e


func eventos_de(tipo: String) -> int:
	return _cuenta_eventos.get(tipo, 0)


func _evento(tipo: String, datos: Dictionary = {}) -> void:
	datos["tipo"] = tipo
	_eventos.append(datos)
	_cuenta_eventos[tipo] = _cuenta_eventos.get(tipo, 0) + 1


# ---------------------------------------------------------------- acciones

func mover_paleta(x: float) -> void:
	var m := ancho_paleta() / 2.0
	paleta_x = clampf(x, m, CAMPO.x - m)


## Suelta las bolas pegadas a la paleta.
func lanzar() -> void:
	for b in bolas:
		if not b["libre"]:
			b["libre"] = true
			var desvio: float = clampf(b["pegada_x"] / (ancho_paleta() / 2.0), -0.5, 0.5)
			b["v"] = Fisica.rebote_paleta(paleta_x + desvio * ancho_paleta() / 2.0, paleta_x, ancho_paleta(), velocidad_actual())
			if b["v"].x == 0.0:
				b["v"] = Vector2(0.18, -1).normalized() * velocidad_actual()   # nunca perfectamente recto al empezar
			_evento("lanza")


func aplicar(tipo: int) -> void:
	match tipo:
		MULTIBOLA:
			var base: Dictionary = bolas[0] if not bolas.is_empty() else {}
			if base.is_empty():
				return
			if not base["libre"]:
				lanzar()
			for giro in [-0.45, 0.45]:
				bolas.append({"pos": base["pos"], "v": base["v"].rotated(giro), "libre": true, "pegada_x": 0.0})
		VIDA:
			vidas = mini(vidas + 1, 9)
		LENTA:
			_efectos[LENTA] = DURACION[LENTA]
			_ajustar_rapidez()
		ANCHA:
			_efectos.erase(CORTA)
			_efectos[ANCHA] = DURACION[ANCHA]
		CORTA:
			_efectos.erase(ANCHA)
			_efectos[CORTA] = DURACION[CORTA]
		_:
			_efectos[tipo] = DURACION[tipo]
	mover_paleta(paleta_x)
	_evento("potenciador", {"potenciador": tipo})


func soltar_capsula(tipo: int, pos: Vector2) -> void:
	capsulas.append({"pos": pos, "tipo": tipo})


## Golpe a un ladrillo (bola, laser o explosion).
func golpear(l: Dictionary) -> void:
	if not _rejilla.has(l["celda"]):
		return
	if l["tipo"] == METAL:
		_evento("metal", {"pos": l["rect"].get_center()})
		return
	l["golpes"] -= 1
	_sin_ladrillo = 0.0
	if l["golpes"] > 0:
		_evento("agrieta", {"pos": l["rect"].get_center()})
		return
	_romper(l)


func _romper(l: Dictionary) -> void:
	if not _rejilla.has(l["celda"]):
		return
	_rejilla.erase(l["celda"])
	ladrillos.erase(l)
	combo += 1
	puntos += 10 * (1 + combo / 4)
	_evento("rompe", {"pos": l["rect"].get_center(), "color": l["color"], "tipo_ladrillo": l["tipo"]})
	if l["tipo"] == SORPRESA or (l["tipo"] != EXPLOSIVO and _rng.randf() < PROB_CAPSULA):
		soltar_capsula(_capsula_al_azar(), l["rect"].get_center())
	if l["tipo"] == EXPLOSIVO:
		_evento("explota", {"pos": l["rect"].get_center()})
		for dy in [-1, 0, 1]:
			for dx in [-1, 0, 1]:
				var v: Dictionary = _rejilla.get(l["celda"] + Vector2i(dx, dy), {})
				if not v.is_empty() and v["tipo"] != METAL:
					_romper(v)
	if rompibles_restantes() == 0:
		ganada = true
		_evento("gana")


func _capsula_al_azar() -> int:
	# la paleta corta solo aparece desde el mundo 3, y poco
	if mundo >= 3 and _rng.randf() < 0.12:
		return CORTA
	var pesos := [3, 2, 2, 2, 2, 1, 1]     # ancha, multibola, laser, iman, lenta, fuego, vida
	var total := 0
	for p in pesos:
		total += p
	var r := _rng.randi_range(1, total)
	for i in pesos.size():
		r -= pesos[i]
		if r <= 0:
			return BUENOS[i]
	return ANCHA


func _reiniciar_bola() -> void:
	bolas = [{"pos": Vector2(paleta_x, PALETA_Y - RADIO - 1), "v": Vector2.ZERO, "libre": false, "pegada_x": 0.0}]
	capsulas.clear()
	laseres.clear()
	_efectos.clear()
	combo = 0
	_sin_ladrillo = 0.0


func _ajustar_rapidez() -> void:
	for b in bolas:
		if b["libre"] and b["v"] != Vector2.ZERO:
			b["v"] = b["v"].normalized() * velocidad_actual()


# ---------------------------------------------------------------- simulacion

func paso(dt: float) -> void:
	if ganada or perdida:
		return
	for k in _efectos.keys():
		_efectos[k] -= dt
		if _efectos[k] <= 0.0:
			_efectos.erase(k)
			if k == LENTA:
				_ajustar_rapidez()
			if k == ANCHA or k == CORTA:
				mover_paleta(paleta_x)
	var alguna_libre := bolas.any(func(b): return b["libre"])
	if alguna_libre:
		_t_subida += dt
		if _t_subida >= SUBIDA_CADA:
			_t_subida = 0.0
			rapidez = minf(rapidez * SUBIDA, _rapidez_inicial * RAPIDEZ_MAX)
			_ajustar_rapidez()
		_sin_ladrillo += dt
		if _sin_ladrillo > SIN_LADRILLO_MAX:
			_sin_ladrillo = 0.0
			_empujon = -_empujon
			for b in bolas:
				if b["libre"]:
					b["v"] = Fisica.corregir_angulo(b["v"].rotated(0.35 * _empujon))
			_evento("empujon")
	for b in bolas.duplicate():
		_mover_bola(b, dt)
		if ganada:
			return
	bolas = bolas.filter(func(b): return b["pos"].y <= CAMPO.y + RADIO)
	if bolas.is_empty():
		vidas -= 1
		_evento("pierde")
		if vidas <= 0:
			perdida = true
			_evento("fin")
			return
		_reiniciar_bola()
	_mover_capsulas(dt)
	_mover_laseres(dt)


func _mover_bola(b: Dictionary, dt: float) -> void:
	if not b["libre"]:
		b["pos"] = Vector2(paleta_x + b["pegada_x"], PALETA_Y - RADIO - 1)
		return
	var n := Fisica.subpasos(b["v"].length() * dt, RADIO)
	var h := dt / n
	for i in n:
		b["pos"] += b["v"] * h
		# paredes
		if b["pos"].x < RADIO:
			b["pos"].x = RADIO
			b["v"].x = absf(b["v"].x)
			_evento("pared")
		elif b["pos"].x > CAMPO.x - RADIO:
			b["pos"].x = CAMPO.x - RADIO
			b["v"].x = -absf(b["v"].x)
			_evento("pared")
		if b["pos"].y < RADIO:
			b["pos"].y = RADIO
			b["v"].y = absf(b["v"].y)
			_evento("pared")
		_choque_ladrillos(b)
		if ganada:
			return
		if _choque_paleta(b):
			return
		if b["pos"].y > CAMPO.y + RADIO:
			return


func _choque_ladrillos(b: Dictionary) -> void:
	var p: Vector2 = b["pos"]
	var c0 := floori((p.x - RADIO) / CELDA.x)
	var c1 := floori((p.x + RADIO) / CELDA.x)
	var f0 := floori((p.y - RADIO - ARRIBA) / CELDA.y)
	var f1 := floori((p.y + RADIO - ARRIBA) / CELDA.y)
	var mejor: Dictionary = {}
	var info: Dictionary = {}
	for f in range(f0, f1 + 1):
		for c in range(c0, c1 + 1):
			var l: Dictionary = _rejilla.get(Vector2i(c, f), {})
			if l.is_empty():
				continue
			var ch := Fisica.choque(p, RADIO, l["rect"])
			if ch["choca"] and (info.is_empty() or ch["profundidad"] > info["profundidad"]):
				mejor = l
				info = ch
	if mejor.is_empty():
		return
	if efecto_activo(FUEGO) and mejor["tipo"] != METAL:
		_romper(mejor)               # la bola de fuego atraviesa
		_sin_ladrillo = 0.0
		return
	b["pos"] += info["normal"] * info["profundidad"]
	b["v"] = Fisica.corregir_angulo(Fisica.reflejar(b["v"], info["normal"]))
	golpear(mejor)


func _choque_paleta(b: Dictionary) -> bool:
	if b["v"].y <= 0.0:
		return false
	var ancho := ancho_paleta()
	var r := Rect2(paleta_x - ancho / 2.0, PALETA_Y, ancho, PALETA_ALTO)
	var ch := Fisica.choque(b["pos"], RADIO, r)
	if not ch["choca"] or b["pos"].y > PALETA_Y + PALETA_ALTO / 2.0:
		return false
	combo = 0
	_evento("paleta")
	if efecto_activo(IMAN):
		b["libre"] = false
		b["pegada_x"] = clampf(b["pos"].x - paleta_x, -ancho / 2.0, ancho / 2.0)
		b["pos"] = Vector2(paleta_x + b["pegada_x"], PALETA_Y - RADIO - 1)
		return true
	b["v"] = Fisica.rebote_paleta(b["pos"].x, paleta_x, ancho, velocidad_actual())
	b["pos"].y = PALETA_Y - RADIO
	return true


func _mover_capsulas(dt: float) -> void:
	var ancho := ancho_paleta()
	var r := Rect2(paleta_x - ancho / 2.0, PALETA_Y - 10, ancho, PALETA_ALTO + 20)
	for c in capsulas.duplicate():
		c["pos"].y += CAIDA_CAPSULA * dt
		if r.grow(20).has_point(c["pos"]):
			capsulas.erase(c)
			aplicar(c["tipo"])
		elif c["pos"].y > CAMPO.y + 40:
			capsulas.erase(c)


func _mover_laseres(dt: float) -> void:
	if efecto_activo(LASER):
		_t_laser -= dt
		if _t_laser <= 0.0:
			_t_laser = 0.3
			var m := ancho_paleta() / 2.0 - 14
			laseres.append(Vector2(paleta_x - m, PALETA_Y))
			laseres.append(Vector2(paleta_x + m, PALETA_Y))
			_evento("laser")
	var vivos: Array = []
	for p in laseres:
		var q: Vector2 = p + Vector2(0, -1600 * dt)
		var golpe := false
		var c := floori(q.x / CELDA.x)
		for f in range(floori((p.y - ARRIBA) / CELDA.y), floori((q.y - ARRIBA) / CELDA.y) - 1, -1):
			var l: Dictionary = _rejilla.get(Vector2i(c, f), {})
			if not l.is_empty() and l["rect"].has_point(Vector2(q.x, clampf(l["rect"].get_center().y, q.y, p.y))):
				golpear(l)
				golpe = true
				break
		if not golpe and q.y > 0:
			vivos.append(q)
	laseres = vivos
