# Partida: dibuja el estado de Partida, lee el dedo y convierte los eventos en
# sonido, particulas, temblor y textos.
extends Control

static var nivel_idx := 0

const HUD := 190.0
const COLOR_CAPSULA := {
	Partida.ANCHA: "#3A86FF", Partida.MULTIBOLA: "#9B5DE5", Partida.LASER: "#FF4D6D",
	Partida.IMAN: "#3DDC97", Partida.LENTA: "#22D3EE", Partida.FUEGO: "#FF9F1C",
	Partida.VIDA: "#EC4899", Partida.CORTA: "#6B7280",
}

var partida := Partida.new()
var _fondo := Fondo.new()
var _campo := Control.new()
var _escala := 1.0
var _temblor := 0.0
var _particulas: Array[CPUParticles2D] = []
var _siguiente_part := 0
var _textos: Array = []          # [{pos, texto, t}]
var _puntos: Label
var _vidas: Label
var _titulo: Label
var _pausado := false
var _terminado := false
var _t := 0.0
var _dedo_inicio := Vector2.ZERO


func _ready() -> void:
	Estilo.aplicar("espacio")
	theme = Estilo.tema()
	var n := Niveles.nivel(nivel_idx)
	_fondo.colores = Niveles.mundos()[int(n["mundo"])]["fondo"]
	add_child(_fondo)
	partida.cargar(n, nivel_idx + 1)
	_campo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_campo.draw.connect(_dibujar)
	add_child(_campo)
	for i in 12:
		var p := CPUParticles2D.new()
		p.emitting = false
		p.one_shot = true
		p.amount = 14
		p.lifetime = 0.6
		p.explosiveness = 1.0
		p.direction = Vector2(0, -1)
		p.spread = 180
		p.gravity = Vector2(0, 1400)
		p.initial_velocity_min = 180
		p.initial_velocity_max = 520
		p.scale_amount_min = 6
		p.scale_amount_max = 12
		_campo.add_child(p)
		_particulas.append(p)
	_hud()
	resized.connect(_colocar)
	_colocar()


func _hud() -> void:
	var barra := HBoxContainer.new()
	barra.position = Vector2(30, 60)
	barra.size = Vector2(size.x - 60, 110)
	barra.set_anchors_preset(Control.PRESET_TOP_WIDE)
	barra.offset_left = 30
	barra.offset_right = -30
	barra.offset_top = 56
	var pausa := Estilo.boton("II", "suave", 100)
	pausa.custom_minimum_size.x = 100
	pausa.add_theme_font_size_override("font_size", 44)
	pausa.pressed.connect(pausar)
	barra.add_child(pausa)
	_titulo = Estilo.titulo("Nivel %d" % (nivel_idx + 1), 50)
	_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_titulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	barra.add_child(_titulo)
	_puntos = Estilo.etiqueta("0", 46, Estilo.ACENTO, false, false)
	_puntos.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	barra.add_child(_puntos)
	_vidas = Estilo.etiqueta("", 46, Color("#FF4D6D"), false, false)
	_vidas.custom_minimum_size.x = 170
	_vidas.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_vidas.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	barra.add_child(_vidas)
	add_child(barra)


func _colocar() -> void:
	_escala = minf((size.x - 20) / Partida.CAMPO.x, (size.y - HUD - 20) / Partida.CAMPO.y)
	_campo.scale = Vector2(_escala, _escala)
	_campo.size = Partida.CAMPO
	_campo.position = Vector2((size.x - Partida.CAMPO.x * _escala) / 2.0, HUD)


# ---------------------------------------------------------------- entrada

func _a_campo(p: Vector2) -> Vector2:
	return (p - _campo.position) / _escala


func _gui_input(e: InputEvent) -> void:
	if _pausado or _terminado:
		return
	if e is InputEventScreenTouch or (e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT):
		if e.pressed:
			_dedo_inicio = e.position
			partida.mover_paleta(_a_campo(e.position).x)
		elif partida.esperando():
			partida.lanzar()
		accept_event()
	elif e is InputEventScreenDrag or (e is InputEventMouseMotion and e.button_mask & MOUSE_BUTTON_MASK_LEFT):
		partida.mover_paleta(_a_campo(e.position).x)
		accept_event()


# ---------------------------------------------------------------- bucle

func _physics_process(delta: float) -> void:
	if _pausado or _terminado:
		return
	partida.paso(delta)
	for ev in partida.tomar_eventos():
		_al_evento(ev)
	if partida.ganada:
		_fin(true)
	elif partida.perdida:
		_fin(false)


func _process(delta: float) -> void:
	_t += delta
	if _temblor > 0.0:
		_temblor = maxf(0.0, _temblor - delta)
		var a := 14.0 * _temblor / 0.25
		_campo.position.x = (size.x - Partida.CAMPO.x * _escala) / 2.0 + randf_range(-a, a)
		_campo.position.y = HUD + randf_range(-a, a)
	for t in _textos.duplicate():
		t["t"] += delta
		if t["t"] > 0.9:
			_textos.erase(t)
	_puntos.text = str(partida.puntos)
	_vidas.text = "♥ %d" % partida.vidas
	_campo.queue_redraw()


func _al_evento(ev: Dictionary) -> void:
	match ev["tipo"]:
		"rompe":
			Sonido.tocar("rompe", 1.0 + minf(partida.combo, 12) * 0.03)
			var c := Color("#C0C8D8") if ev["tipo_ladrillo"] != Partida.NORMAL else Color(Texturas.COLORES[ev["color"]])
			_explosion_particulas(ev["pos"], c)
			if partida.combo >= 5 and partida.combo % 5 == 0:
				_texto("combo", ev["pos"], "Combo x%d" % partida.combo)
		"agrieta":
			Sonido.tocar("agrieta")
		"metal":
			Sonido.tocar("metal")
		"explota":
			Sonido.tocar("explota")
			Sonido.vibrar(40)
			_temblor = 0.25
		"paleta":
			Sonido.tocar("paleta")
		"pared":
			Sonido.tocar("pared")
		"laser":
			Sonido.tocar("laser")
		"potenciador":
			Sonido.tocar("potenciador")
			_texto("potenciador", Vector2(partida.paleta_x, Partida.PALETA_Y - 60), _nombre_potenciador(ev["potenciador"]))
		"pierde":
			Sonido.tocar("pierde")
			Sonido.vibrar(80)


## Un texto flotante por tipo: el nuevo reemplaza al anterior (no se amontonan).
func _texto(tipo: String, pos: Vector2, texto: String) -> void:
	_textos = _textos.filter(func(t): return t["clase"] != tipo)
	_textos.append({"clase": tipo, "pos": pos, "texto": texto, "t": 0.0})


func _explosion_particulas(pos: Vector2, c: Color) -> void:
	var p := _particulas[_siguiente_part]
	_siguiente_part = (_siguiente_part + 1) % _particulas.size()
	p.position = pos
	p.color = c
	p.restart()
	p.emitting = true


static func _nombre_potenciador(tipo: int) -> String:
	return {Partida.ANCHA: "¡Paleta ancha!", Partida.MULTIBOLA: "¡Multibola!", Partida.LASER: "¡Láser!",
		Partida.IMAN: "¡Imán!", Partida.LENTA: "Bola lenta", Partida.FUEGO: "¡Bola de fuego!",
		Partida.VIDA: "¡Vida extra!", Partida.CORTA: "Paleta corta"}.get(tipo, "")


# ---------------------------------------------------------------- dibujo

func _dibujar() -> void:
	var c := _campo
	# marco del campo
	c.draw_rect(Rect2(Vector2.ZERO, Partida.CAMPO), Color(1, 1, 1, 0.03))
	c.draw_rect(Rect2(Vector2.ZERO, Partida.CAMPO), Color(1, 1, 1, 0.12), false, 3.0)
	var fuente: Font = Estilo.FUENTE_NEGRITA
	for l in partida.ladrillos:
		var r: Rect2 = l["rect"]
		c.draw_texture_rect(Texturas.ladrillo(Texturas.clave_de(l)), r, false)
		match l["tipo"]:
			Partida.DURO:
				for k in l["golpes"]:
					c.draw_circle(r.position + Vector2(r.size.x / 2.0 - 12 + k * 12, r.size.y / 2.0), 4, Color(1, 1, 1, 0.7))
			Partida.EXPLOSIVO:
				var centro := r.get_center()
				for k in 8:
					var a := k * TAU / 8 + _t * 2.0
					c.draw_line(centro + Vector2.from_angle(a) * 6, centro + Vector2.from_angle(a) * 15, Color("#FFE5E5"), 3)
			Partida.SORPRESA:
				c.draw_string(fuente, r.position + Vector2(0, r.size.y * 0.78), "?", HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 34, Color("#5A3E00"))
	for cap in partida.capsulas:
		_capsula(c, cap)
	for p in partida.laseres:
		c.draw_line(p, p + Vector2(0, 30), Color("#FF4D6D"), 6)
		c.draw_line(p, p + Vector2(0, 30), Color(1, 1, 1, 0.8), 2)
	_paleta(c)
	for b in partida.bolas:
		_bola(c, b["pos"])
	if partida.esperando():
		c.draw_string(fuente, Vector2(0, Partida.PALETA_Y - 140), "Toca para lanzar", HORIZONTAL_ALIGNMENT_CENTER, Partida.CAMPO.x, 46, Color(1, 1, 1, 0.55 + 0.35 * sin(_t * 4)))
	for t in _textos:
		var alfa: float = 1.0 - t["t"] / 0.9
		c.draw_string(fuente, t["pos"] + Vector2(-300, -30 - 60 * t["t"]), t["texto"], HORIZONTAL_ALIGNMENT_CENTER, 600, 44, Color(1, 0.9, 0.4, alfa))


func _paleta(c: Control) -> void:
	var ancho := partida.ancho_paleta()
	var r := Rect2(partida.paleta_x - ancho / 2.0, Partida.PALETA_Y, ancho, Partida.PALETA_ALTO)
	var cuerpo := StyleBoxFlat.new()
	cuerpo.bg_color = Color("#22D3EE")
	cuerpo.set_corner_radius_all(17)
	cuerpo.border_color = Color("#0E7490")
	cuerpo.set_border_width_all(3)
	cuerpo.shadow_color = Color(0.13, 0.83, 0.93, 0.35)
	cuerpo.shadow_size = 14
	c.draw_style_box(cuerpo, r)
	c.draw_rect(Rect2(r.position + Vector2(18, 6), Vector2(r.size.x - 36, 7)), Color(1, 1, 1, 0.55))
	for lado in [r.position.x + 8, r.end.x - 34]:
		var punta := StyleBoxFlat.new()
		punta.bg_color = Color("#EC4899")
		punta.set_corner_radius_all(13)
		c.draw_style_box(punta, Rect2(lado, r.position.y + 4, 26, r.size.y - 8))
	if partida.efecto_activo(Partida.LASER):
		for x in [r.position.x + 14, r.end.x - 14]:
			c.draw_rect(Rect2(x - 5, r.position.y - 16, 10, 18), Color("#FF4D6D"))


func _bola(c: Control, pos: Vector2) -> void:
	var r := Partida.RADIO
	if partida.efecto_activo(Partida.FUEGO):
		for k in 4:
			c.draw_circle(pos, r + 14 - k * 3, Color(1, 0.55, 0.1, 0.12 + k * 0.05))
		c.draw_circle(pos, r, Color("#FFB347"))
	else:
		c.draw_circle(pos + Vector2(3, 5), r, Color(0, 0, 0, 0.35))
		c.draw_circle(pos, r, Color("#C9D2E3"))
		c.draw_circle(pos + Vector2(2, 3), r * 0.8, Color("#8E9BB5"))
		c.draw_circle(pos - Vector2(5, 5), r * 0.45, Color(1, 1, 1, 0.9))


func _capsula(c: Control, cap: Dictionary) -> void:
	var col := Color(COLOR_CAPSULA[cap["tipo"]])
	var r := Rect2(cap["pos"] - Vector2(44, 20), Vector2(88, 40))
	var s := StyleBoxFlat.new()
	s.bg_color = col
	s.set_corner_radius_all(20)
	s.border_color = Color.WHITE
	s.set_border_width_all(3)
	c.draw_style_box(s, r)
	var centro := r.get_center()
	var blanco := Color.WHITE
	match cap["tipo"]:
		Partida.ANCHA, Partida.CORTA:
			c.draw_line(centro - Vector2(22, 0), centro + Vector2(22, 0), blanco, 4)
			var d := 1 if cap["tipo"] == Partida.ANCHA else -1
			for s2 in [-1, 1]:
				var punta := centro + Vector2(22 * s2, 0)
				c.draw_line(punta, punta + Vector2(-8 * s2 * d, -7), blanco, 4)
				c.draw_line(punta, punta + Vector2(-8 * s2 * d, 7), blanco, 4)
		Partida.MULTIBOLA:
			for k in [-14, 0, 14]:
				c.draw_circle(centro + Vector2(k, 0), 5.5, blanco)
		Partida.LASER:
			for k in [-8, 8]:
				c.draw_line(centro + Vector2(k, -11), centro + Vector2(k, 11), blanco, 5)
		Partida.IMAN:
			c.draw_arc(centro + Vector2(0, -2), 11, 0, PI, 16, blanco, 5)
			c.draw_line(centro + Vector2(-11, -2), centro + Vector2(-11, -11), blanco, 5)
			c.draw_line(centro + Vector2(11, -2), centro + Vector2(11, -11), blanco, 5)
		Partida.LENTA:
			c.draw_arc(centro, 12, 0, TAU, 20, blanco, 3)
			c.draw_line(centro, centro + Vector2(0, -8), blanco, 3)
			c.draw_line(centro, centro + Vector2(6, 0), blanco, 3)
		Partida.FUEGO:
			c.draw_colored_polygon(PackedVector2Array([centro + Vector2(0, -14), centro + Vector2(10, 6), centro + Vector2(0, 12), centro + Vector2(-10, 6)]), blanco)
		Partida.VIDA:
			c.draw_circle(centro + Vector2(-6, -3), 7, blanco)
			c.draw_circle(centro + Vector2(6, -3), 7, blanco)
			c.draw_colored_polygon(PackedVector2Array([centro + Vector2(-12, 0), centro + Vector2(12, 0), centro + Vector2(0, 13)]), blanco)


# ---------------------------------------------------------------- pausa y fin

func pausar() -> void:
	if _pausado or _terminado:
		return
	_pausado = true
	var i := await Estilo.dialogo(self, "Pausa", "", ["Continuar", "Reiniciar nivel", "Salir"])
	_pausado = false
	if not is_inside_tree():
		return
	if i == 1:
		Estilo.ir(self, "juego")
	elif i == 2:
		Estilo.ir(self, "mundos")


func _fin(gano: bool) -> void:
	_terminado = true
	var estrellas := 0
	if gano:
		estrellas = Partida.estrellas_por(partida.vidas_iniciales, partida.vidas)
		Progreso.registrar(nivel_idx, estrellas, partida.puntos)
		Sonido.tocar("gana")
	await get_tree().create_timer(0.7).timeout
	if not is_inside_tree():
		return
	var opciones := ["Siguiente nivel", "Repetir", "Mundos"] if gano and nivel_idx + 1 < Niveles.total() else ["Reintentar", "Mundos"]
	if gano and nivel_idx + 1 >= Niveles.total():
		opciones = ["Repetir", "Mundos"]
	var texto := "%s   ·   %d puntos" % ["★".repeat(estrellas) + "☆".repeat(3 - estrellas), partida.puntos] if gano else "Te quedaste sin vidas. Sin esperas: vuelve a intentarlo."
	var i := await Estilo.dialogo(self, "¡Nivel superado!" if gano else "Fin de la partida", texto, opciones)
	if not is_inside_tree():
		return
	var elegido: String = opciones[i] if i >= 0 else "Mundos"
	match elegido:
		"Siguiente nivel":
			nivel_idx += 1
			Estilo.ir(self, "juego")
		"Repetir", "Reintentar":
			Estilo.ir(self, "juego")
		_:
			Estilo.ir(self, "mundos")


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		pausar()
	elif que == NOTIFICATION_APPLICATION_PAUSED:
		pausar()       # al salir de la app (llamada, otra app) la partida queda en pausa
