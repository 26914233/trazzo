# Dibujo de la paleta, la bola y la estela con el aspecto elegido. Lo usan la
# partida y las vistas previas de Personalizar (asi se ve igual en los dos sitios).
class_name Dibujo
extends RefCounted

const LARGO_ESTELA := 10        ## posiciones que se recuerdan por bola


static func paleta(c: CanvasItem, r: Rect2, aspecto: Dictionary, con_laser: bool = false) -> void:
	var cuerpo_color := Color(aspecto.get("cuerpo", "#22D3EE"))
	var cuerpo := StyleBoxFlat.new()
	cuerpo.bg_color = cuerpo_color
	cuerpo.set_corner_radius_all(int(r.size.y / 2.0))
	cuerpo.border_color = Color(aspecto.get("borde", "#0E7490"))
	cuerpo.set_border_width_all(3)
	cuerpo.shadow_color = Color(cuerpo_color, 0.35)
	cuerpo.shadow_size = 14
	c.draw_style_box(cuerpo, r)
	c.draw_rect(Rect2(r.position + Vector2(18, r.size.y * 0.18), Vector2(maxf(r.size.x - 36, 0), r.size.y * 0.2)), Color(1, 1, 1, 0.55))
	for lado in [r.position.x + 8, r.end.x - 34]:
		var punta := StyleBoxFlat.new()
		punta.bg_color = Color(aspecto.get("puntas", "#EC4899"))
		punta.set_corner_radius_all(int((r.size.y - 8) / 2.0))
		c.draw_style_box(punta, Rect2(lado, r.position.y + 4, 26, r.size.y - 8))
	if con_laser:
		for x in [r.position.x + 14, r.end.x - 14]:
			c.draw_rect(Rect2(x - 5, r.position.y - 16, 10, 18), Color("#FF4D6D"))


static func bola(c: CanvasItem, pos: Vector2, r: float, aspecto: Dictionary, fuego: bool = false) -> void:
	if fuego:
		for k in 4:
			c.draw_circle(pos, r + 14 - k * 3, Color(1, 0.55, 0.1, 0.12 + k * 0.05))
		c.draw_circle(pos, r, Color("#FFB347"))
		return
	c.draw_circle(pos + Vector2(3, 5), r, Color(0, 0, 0, 0.35))
	c.draw_circle(pos, r, Color(aspecto.get("base", "#C9D2E3")))
	c.draw_circle(pos + Vector2(2, 3), r * 0.8, Color(aspecto.get("sombra", "#8E9BB5")))
	c.draw_circle(pos - Vector2(5, 5) * r / 16.0, r * 0.45, Color(1, 1, 1, 0.9))


## puntos: de la posicion mas vieja a la mas reciente. t: tiempo (para el arcoiris).
static func estela(c: CanvasItem, puntos: Array, r: float, aspecto: Dictionary, t: float = 0.0) -> void:
	var color_txt := str(aspecto.get("color", ""))
	if color_txt == "" or puntos.size() < 2:
		return
	var n := puntos.size()
	for i in n - 1:
		var f := float(i + 1) / n                       # 0 = viejo, 1 = reciente
		var col := Color.from_hsv(fmod(t * 0.6 + f * 0.8, 1.0), 0.75, 1.0) if color_txt == "arcoiris" else Color(color_txt)
		col.a = 0.55 * f
		c.draw_circle(puntos[i], r * (0.35 + 0.6 * f), col)
