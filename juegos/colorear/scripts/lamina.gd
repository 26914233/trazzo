# Una lamina en coloreado: que zona hay en cada pixel, de que color esta cada
# zona y el historial para deshacer.
#
# Las zonas vienen precalculadas (regiones.png: id = R + G*256). El color de cada
# zona vive en una paleta de 64x64 que lee el shader: pintar una zona cambia un
# solo pixel, asi que rellenar es instantaneo aunque la zona sea enorme.
class_name Lamina
extends RefCounted

const LADO_PALETA := 64
const BLANCO := Color.WHITE

var id := ""
var zonas := 0
var textura_regiones: Texture2D
var textura_lineas: Texture2D
var regiones: Image
var colores := PackedColorArray()
var paleta: Image
var textura_paleta: ImageTexture
var _hechos: Array = []        # [zona, antes, despues]
var _deshechos: Array = []


func _init(id_: String, zonas_: int, reg: Texture2D, lin: Texture2D) -> void:
	id = id_
	zonas = zonas_
	textura_regiones = reg
	textura_lineas = lin
	regiones = reg.get_image() if reg else null
	if regiones and regiones.is_compressed():
		push_error("Las regiones de %s estan comprimidas con perdida: los ids se rompen" % id)
	colores.resize(zonas + 1)
	colores.fill(BLANCO)
	paleta = Image.create_empty(LADO_PALETA, LADO_PALETA, false, Image.FORMAT_RGBA8)
	paleta.fill(BLANCO)
	textura_paleta = ImageTexture.create_from_image(paleta)


## Zona bajo un pixel de la lamina (0 = ninguna).
func zona_en(p: Vector2i) -> int:
	if regiones == null or p.x < 0 or p.y < 0 or p.x >= regiones.get_width() or p.y >= regiones.get_height():
		return 0
	var c := regiones.get_pixelv(p)
	var z := c.r8 + c.g8 * 256
	return z if z <= zonas else 0


func pintar(zona: int, color: Color) -> bool:
	if zona <= 0 or zona > zonas or colores[zona] == color:
		return false
	_hechos.append([zona, colores[zona], color])
	_deshechos.clear()
	_poner(zona, color)
	return true


func puede_deshacer() -> bool:
	return not _hechos.is_empty()


func puede_rehacer() -> bool:
	return not _deshechos.is_empty()


func deshacer() -> bool:
	if _hechos.is_empty():
		return false
	var h: Array = _hechos.pop_back()
	_deshechos.append(h)
	_poner(h[0], h[1])
	return true


func rehacer() -> bool:
	if _deshechos.is_empty():
		return false
	var h: Array = _deshechos.pop_back()
	_hechos.append(h)
	_poner(h[0], h[2])
	return true


func _poner(zona: int, color: Color) -> void:
	colores[zona] = color
	paleta.set_pixel(zona % LADO_PALETA, zona / LADO_PALETA, color)
	textura_paleta.update(paleta)


## Zonas ya coloreadas (no blancas), de 0 a 1.
func avance() -> float:
	var n := 0
	for z in range(1, zonas + 1):
		if colores[z] != BLANCO:
			n += 1
	return float(n) / maxf(zonas, 1)


## Solo las zonas pintadas, en hex: compacto y facil de validar al leer.
func a_datos() -> Dictionary:
	var c := {}
	for z in range(1, zonas + 1):
		if colores[z] != BLANCO:
			c[str(z)] = colores[z].to_html(false)
	return {"colores": c}


func desde_datos(d: Dictionary) -> void:
	var c = d.get("colores", {})
	if typeof(c) != TYPE_DICTIONARY:
		return
	for k in c:
		var z := str(k).to_int()
		var hex := str(c[k])
		if z >= 1 and z <= zonas and Color.html_is_valid(hex):
			colores[z] = Color.html(hex)
			paleta.set_pixel(z % LADO_PALETA, z / LADO_PALETA, colores[z])
	textura_paleta.update(paleta)
	_hechos.clear()
	_deshechos.clear()
