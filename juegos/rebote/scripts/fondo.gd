# Fondo espacial: degradado del mundo, nebulosas suaves y estrellas que titilan.
class_name Fondo
extends Control

var colores: Array = ["#0B1026", "#1E1B4B"]
var _estrellas: Array = []      # [pos (0..1), tam, fase]
var _nebulosas: Array = []
var _t := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in 140:
		_estrellas.append([Vector2(rng.randf(), rng.randf()), rng.randf_range(1.0, 3.2), rng.randf() * TAU])
	for i in 4:
		_nebulosas.append([Vector2(rng.randf(), rng.randf_range(0.1, 0.9)), rng.randf_range(0.25, 0.5), rng.randi() % 3])


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var a := Color(colores[0])
	var b := Color(colores[1])
	var bandas := 24
	for i in bandas:
		var y0 := size.y * i / bandas
		draw_rect(Rect2(0, y0, size.x, size.y / bandas + 1), a.lerp(b, float(i) / (bandas - 1)))
	var tintes := [Color("#EC4899"), Color("#8B5CF6"), Color("#22D3EE")]
	for n in _nebulosas:
		var c: Color = tintes[n[2]]
		var centro: Vector2 = n[0] * size
		var r: float = n[1] * size.x
		for k in 6:
			draw_circle(centro, r * (1.0 - k * 0.15), Color(c, 0.025))
	for e in _estrellas:
		var brillo := 0.45 + 0.4 * sin(_t * 1.6 + e[2])
		draw_circle(e[0] * size, e[1], Color(1, 1, 1, brillo))
