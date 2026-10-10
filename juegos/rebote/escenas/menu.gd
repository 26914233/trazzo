# Menu: titulo con una bola que rebota, jugar, ajustes.
extends Control

var _bola := Control.new()
var _t := 0.0


func _ready() -> void:
	var fondo := Fondo.new()
	add_child(fondo)
	var col := Estilo.pantalla(self)
	move_child(fondo, 0)
	var hueco := Control.new()
	hueco.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(hueco)
	_bola.custom_minimum_size = Vector2(0, 260)
	_bola.draw.connect(_dibujar_logo)
	col.add_child(_bola)
	col.add_child(Estilo.titulo(str(ProjectSettings.get_setting("application/config/name")), 150, true))
	col.add_child(Estilo.etiqueta("%d niveles · sin anuncios" % Niveles.total(), 42, Estilo.TEXTO_SUAVE))
	var hueco2 := Control.new()
	hueco2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(hueco2)
	var siguiente := _siguiente_nivel()
	var jugar := Estilo.boton("Jugar nivel %d" % (siguiente + 1), "primario", 170)
	jugar.add_theme_font_size_override("font_size", 58)
	jugar.pressed.connect(func():
		preload("res://escenas/juego.gd").nivel_idx = siguiente
		Estilo.ir(self, "juego"))
	col.add_child(jugar)
	var mundos := Estilo.boton("Mundos", "normal", 140)
	mundos.pressed.connect(func(): Estilo.ir(self, "mundos"))
	col.add_child(mundos)
	var ajustes := Estilo.boton("Ajustes", "suave", 130)
	ajustes.pressed.connect(abrir_ajustes)
	col.add_child(ajustes)
	col.add_child(Estilo.etiqueta("★ %d de %d" % [Progreso.total_estrellas(), Niveles.total() * 3], 36, Estilo.ACENTO))


func _siguiente_nivel() -> int:
	for i in Niveles.total():
		if Progreso.desbloqueado(i) and Progreso.estrellas(i) == 0:
			return i
	return 0


func _process(delta: float) -> void:
	_t += delta
	_bola.queue_redraw()


## Logo animado: fila de ladrillos y una bola que rebota (motion-design: rebote
## con aceleracion de gravedad, no lineal).
func _dibujar_logo() -> void:
	var w := _bola.size.x
	var cols := 7
	var ancho := 120.0
	var x0 := (w - cols * ancho) / 2.0
	for k in cols:
		_bola.draw_texture_rect(Texturas.ladrillo(str(k % 6)), Rect2(x0 + k * ancho + 6, 10, ancho - 12, 50), false)
	var fase := fmod(_t * 1.25, 1.0)
	var alto := 4.0 * fase * (1.0 - fase)                 # parabola: sube frenando, baja acelerando
	var y := 230.0 - alto * 150.0
	var x := w / 2.0 + sin(_t * 0.9) * 220.0
	_bola.draw_circle(Vector2(x + 4, 240), 18 * (0.6 + 0.4 * (1.0 - alto)), Color(0, 0, 0, 0.3))
	_bola.draw_circle(Vector2(x, y), 22, Color("#C9D2E3"))
	_bola.draw_circle(Vector2(x, y) + Vector2(2, 3), 17, Color("#8E9BB5"))
	_bola.draw_circle(Vector2(x, y) - Vector2(6, 6), 9, Color(1, 1, 1, 0.9))


func abrir_ajustes() -> void:
	var m := Estilo.modal(self)
	var velo: ColorRect = m[0]
	var col: VBoxContainer = m[1]
	col.add_child(Estilo.titulo("Ajustes", 60, true))
	for a in [["Sonido", "sonido"], ["Vibración", "vibracion"]]:
		col.add_child(_interruptor(a[0], a[1]))
	var listo := Estilo.boton("Listo", "primario", 130)
	listo.pressed.connect(velo.queue_free)
	col.add_child(listo)


func _interruptor(texto: String, clave: String) -> Button:
	var b := Estilo.boton("", "normal", 124)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var pintar := func() -> void:
		var on := bool(Ajustes.valor(clave))
		b.text = "%s:  %s" % [texto, "Sí" if on else "No"]
		Estilo.colorear(b, Estilo.SUPERFICIE if on else Estilo.BLOQUEADO, Estilo.TEXTO if on else Estilo.TEXTO_SUAVE)
	b.pressed.connect(func():
		Ajustes.fijar(clave, not bool(Ajustes.valor(clave)))
		pintar.call())
	pintar.call()
	return b


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
