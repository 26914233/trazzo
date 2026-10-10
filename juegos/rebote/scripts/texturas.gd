# Texturas de ladrillos, bola y paleta generadas en codigo (estilo "chunky" con
# brillo y bisel). Se crean una vez y se reutilizan.
class_name Texturas
extends RefCounted

const COLORES := ["#FF4D6D", "#FF9F1C", "#FFD60A", "#3DDC97", "#3A86FF", "#9B5DE5"]
const TAM := Vector2i(96, 44)

static var _cache := {}


static func ladrillo(clave: String) -> Texture2D:
	if _cache.has(clave):
		return _cache[clave]
	var base: Color
	match clave:
		"metal":
			base = Color("#9AA5B8")
		"duro":
			base = Color("#5B6B8C")
		"explosivo":
			base = Color("#E63946")
		"sorpresa":
			base = Color("#F5B700")
		_:
			base = Color(COLORES[clave.to_int() % COLORES.size()])
	var img := Image.create_empty(TAM.x, TAM.y, false, Image.FORMAT_RGBA8)
	var radio := 9.0
	for y in TAM.y:
		for x in TAM.x:
			var dx := maxf(maxf(radio - x, x - (TAM.x - 1 - radio)), 0.0)
			var dy := maxf(maxf(radio - y, y - (TAM.y - 1 - radio)), 0.0)
			var d := sqrt(dx * dx + dy * dy)
			if d > radio + 0.5:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
			var alfa := clampf(radio + 0.5 - d, 0.0, 1.0)
			var t := float(y) / (TAM.y - 1)
			var c := base.lightened(0.28 * (1.0 - t)).darkened(0.25 * t)
			var borde := minf(minf(x, TAM.x - 1 - x), minf(y, TAM.y - 1 - y))
			if borde < 3.0 or d > radio - 2.5:
				c = base.darkened(0.35)                       # bisel oscuro
			elif y < 12 and x > 10 and x < TAM.x - 10:
				c = c.lerp(Color.WHITE, 0.35 * (1.0 - y / 12.0))   # brillo arriba
			if clave == "metal" and absf((x - y * 1.2) - 30.0) < 6.0:
				c = c.lerp(Color.WHITE, 0.45)                 # reflejo diagonal
			c.a = alfa
			img.set_pixel(x, y, c)
	var tex := ImageTexture.create_from_image(img)
	_cache[clave] = tex
	return tex


static func clave_de(l: Dictionary) -> String:
	match l["tipo"]:
		Partida.METAL:
			return "metal"
		Partida.DURO:
			return "duro"
		Partida.EXPLOSIVO:
			return "explosivo"
		Partida.SORPRESA:
			return "sorpresa"
	return str(l["color"])
