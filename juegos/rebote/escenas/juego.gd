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
var _aspecto_paleta: Dictionary = Progreso.equipado("paleta")
var _aspecto_bola: Dictionary = Progreso.equipado("bola")
var _aspecto_estela: Dictionary = Progreso.equipado("estela")
var _estelas: Array = []         # por bola: posiciones recientes
var _arranques: HBoxContainer      # potenciadores a la venta antes del primer lanzamiento
var _ya_siguio := false          # "Seguir" solo una vez por intento

const NIVEL_ARRANQUES := 3       ## desde el nivel 4 (los 3 primeros son de aprender)


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
	if nivel_idx >= NIVEL_ARRANQUES:
		_crear_arranques()
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
	if _arranques:
		_arranques.position = Vector2(40, _campo.position.y + (Partida.PALETA_Y - 420) * _escala)
		_arranques.size = Vector2(size.x - 80, 150)


# ---------------------------------------------------------------- potenciadores al empezar

func _crear_arranques() -> void:
	_arranques = HBoxContainer.new()
	_arranques.alignment = BoxContainer.ALIGNMENT_CENTER
	_arranques.add_theme_constant_override("separation", 18)
	for id in Economia.ARRANQUES:
		var a: Dictionary = Economia.ARRANQUES[id]
		var b := Estilo.boton("", "normal", 150)
		b.name = "Arranque_" + id
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var v := VBoxContainer.new()
		v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		v.alignment = BoxContainer.ALIGNMENT_CENTER
		v.add_theme_constant_override("separation", 4)
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var nombre := Estilo.etiqueta(a["nombre"], 32, Estilo.TEXTO, true, false)
		nombre.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(nombre)
		var precio := HBoxContainer.new()
		precio.alignment = BoxContainer.ALIGNMENT_CENTER
		precio.mouse_filter = Control.MOUSE_FILTER_IGNORE
		precio.add_child(Estilo.gema(34))
		var num := Estilo.etiqueta(str(a["precio"]), 34, Estilo.ACENTO, false, false)
		num.name = "Precio"
		num.mouse_filter = Control.MOUSE_FILTER_IGNORE
		precio.add_child(num)
		v.add_child(precio)
		b.add_child(v)
		b.pressed.connect(comprar_arranque.bind(id, b))
		_arranques.add_child(b)
	add_child(_arranques)


func comprar_arranque(id: String, boton: Button = null) -> bool:
	var a: Dictionary = Economia.ARRANQUES[id]
	if not partida.esperando() or Progreso.gemas() < int(a["precio"]):
		Estilo.aviso(self, "Necesitas %d gemas. Se ganan jugando o en la Tienda." % a["precio"])
		return false
	if not partida.preparar_arranque(a["potenciador"]) or not Progreso.gastar_gemas(int(a["precio"])):
		return false
	Sonido.tocar("potenciador")
	if boton:
		boton.disabled = true
		var num := boton.find_child("Precio", true, false) as Label
		if num:
			num.text = "✓"
	return true


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
	_actualizar_estelas()
	if _arranques and _arranques.visible and partida._lanzada:
		_arranques.visible = false
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
		"revive":
			Sonido.tocar("potenciador")
			_texto("potenciador", Vector2(partida.paleta_x, Partida.PALETA_Y - 60), "¡Sigue!")


func _actualizar_estelas() -> void:
	if str(_aspecto_estela.get("color", "")) == "":
		return
	if _estelas.size() != partida.bolas.size():
		_estelas = []
		for b in partida.bolas:
			_estelas.append([])
	for k in partida.bolas.size():
		var b: Dictionary = partida.bolas[k]
		var e: Array = _estelas[k]
		if not b["libre"]:
			e.clear()
			continue
		e.append(b["pos"])
		if e.size() > Dibujo.LARGO_ESTELA:
			e.pop_front()


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
	var fuego := partida.efecto_activo(Partida.FUEGO)
	for k in partida.bolas.size():
		if k < _estelas.size():
			Dibujo.estela(c, _estelas[k], Partida.RADIO, _aspecto_estela, _t)
		Dibujo.bola(c, partida.bolas[k]["pos"], Partida.RADIO, _aspecto_bola, fuego)
	if partida.esperando():
		c.draw_string(fuente, Vector2(0, Partida.PALETA_Y - 140), "Toca para lanzar", HORIZONTAL_ALIGNMENT_CENTER, Partida.CAMPO.x, 46, Color(1, 1, 1, 0.55 + 0.35 * sin(_t * 4)))
	for t in _textos:
		var alfa: float = 1.0 - t["t"] / 0.9
		c.draw_string(fuente, t["pos"] + Vector2(-300, -30 - 60 * t["t"]), t["texto"], HORIZONTAL_ALIGNMENT_CENTER, 600, 44, Color(1, 0.9, 0.4, alfa))


func _paleta(c: Control) -> void:
	var ancho := partida.ancho_paleta()
	var r := Rect2(partida.paleta_x - ancho / 2.0, Partida.PALETA_Y, ancho, Partida.PALETA_ALTO)
	Dibujo.paleta(c, r, _aspecto_paleta, partida.efecto_activo(Partida.LASER))


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
	if not gano and not _ya_siguio:
		await get_tree().create_timer(0.5).timeout
		if not is_inside_tree():
			return
		if await ofrecer_seguir():
			return
	var estrellas := 0
	var gemas := 0
	if gano:
		estrellas = Partida.estrellas_por(partida.vidas_iniciales, partida.vidas)
		gemas = Progreso.registrar(nivel_idx, estrellas, partida.puntos)
		Monetizacion.nivel_superado()
		Sonido.tocar("gana")
		await get_tree().create_timer(0.7).timeout
	if not is_inside_tree():
		return
	var hay_siguiente := nivel_idx + 1 < Niveles.total()
	var puede_doblar := gano and gemas > 0 and Monetizacion.hay_anuncios()
	while true:
		var opciones: Array = []
		if gano:
			opciones = (["Siguiente nivel"] if hay_siguiente else []) + (["Doblar gemas (anuncio)"] if puede_doblar else []) + ["Repetir", "Mundos"]
		else:
			opciones = ["Reintentar", "Mundos"]
		var texto := "%s   ·   %d puntos\n+%d gemas" % [Estilo.estrellas_texto(estrellas), partida.puntos, gemas] if gano else "Te quedaste sin vidas. Sin esperas: vuelve a intentarlo."
		var i := await Estilo.dialogo(self, "¡Nivel superado!" if gano else "Fin de la partida", texto, opciones)
		if not is_inside_tree():
			return
		var elegido: String = opciones[i] if i >= 0 else "Mundos"
		if elegido == "Doblar gemas (anuncio)":
			puede_doblar = false
			if await Monetizacion.mostrar_premiado("doble"):
				Progreso.sumar_gemas(gemas)
				gemas *= 2
				Sonido.tocar("potenciador")
			elif is_inside_tree():
				Estilo.aviso(self, "El anuncio no está listo. Tus gemas ya están guardadas.")
			continue
		# Intersticial solo al salir de un nivel GANADO (nunca tras perder ni al abandonar);
		# las reglas deciden si toca (ReglasAnuncios).
		if gano:
			await Monetizacion.intentar_intersticial()
			if not is_inside_tree():
				return
		match elegido:
			"Siguiente nivel":
				nivel_idx += 1
				Estilo.ir(self, "juego")
			"Repetir", "Reintentar":
				Estilo.ir(self, "juego")
			_:
				Estilo.ir(self, "mundos")
		return


## Tras perder la ultima vida: seguir con una vida (anuncio, gemas o gratis con
## "quitar anuncios"). Una vez por intento. Devuelve true si la partida sigue.
func ofrecer_seguir() -> bool:
	var opciones: Array = []
	if Progreso.sin_anuncios():
		opciones.append("Seguir gratis")
	else:
		if Monetizacion.hay_anuncios():
			opciones.append("Seguir (anuncio)")
		if Progreso.gemas() >= Economia.PRECIO_SEGUIR:
			opciones.append("Seguir por %d gemas" % Economia.PRECIO_SEGUIR)
	if opciones.is_empty():
		return false
	opciones.append("No, gracias")
	var i := await Estilo.dialogo(self, "¡Casi!", "Sigue con una vida y los ladrillos como están.", opciones)
	if not is_inside_tree() or i < 0:
		return false
	var elegido: String = opciones[i]
	var ok := false
	if elegido == "Seguir gratis":
		ok = true
	elif elegido == "Seguir (anuncio)":
		ok = await Monetizacion.mostrar_premiado("seguir")
		if not ok and is_inside_tree():
			Estilo.aviso(self, "El anuncio no está listo.")
	elif elegido.begins_with("Seguir por"):
		ok = Progreso.gastar_gemas(Economia.PRECIO_SEGUIR)
	if not ok or not is_inside_tree():
		return false
	_ya_siguio = true
	partida.revivir()
	_terminado = false
	return true


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		pausar()
	elif que == NOTIFICATION_APPLICATION_PAUSED:
		pausar()       # al salir de la app (llamada, otra app) la partida queda en pausa
