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
var _hechos: Array = []        # cada paso: [[zona, antes, despues], ...]
var _deshechos: Array = []
var _trazo = null              # paso en curso al pintar arrastrando el dedo
## Por zona, 4 uint16: punto interior (x, y) y caja (ancho, alto). Ver herramientas/zonas.py.
var info_zonas := PackedByteArray()


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
	var cambio := [zona, colores[zona], color]
	if _trazo != null:
		_trazo.append(cambio)
	else:
		_hechos.append([cambio])
	_deshechos.clear()
	_poner(zona, color)
	return true


## Un trazo con el dedo cuenta como un solo paso para deshacer.
func empezar_trazo() -> void:
	terminar_trazo()
	_trazo = []


func terminar_trazo() -> void:
	if _trazo != null and not _trazo.is_empty():
		_hechos.append(_trazo)
	_trazo = null


## Se puso un segundo dedo (zoom): lo pintado en este trazo no cuenta.
func cancelar_trazo() -> void:
	if _trazo == null:
		return
	for i in range(_trazo.size() - 1, -1, -1):
		_poner(_trazo[i][0], _trazo[i][1])
	_trazo = null


func puede_deshacer() -> bool:
	return not _hechos.is_empty()


func puede_rehacer() -> bool:
	return not _deshechos.is_empty()


func deshacer() -> bool:
	terminar_trazo()
	if _hechos.is_empty():
		return false
	var paso: Array = _hechos.pop_back()
	_deshechos.append(paso)
	for i in range(paso.size() - 1, -1, -1):
		_poner(paso[i][0], paso[i][1])
	return true


func rehacer() -> bool:
	if _deshechos.is_empty():
		return false
	var paso: Array = _deshechos.pop_back()
	_hechos.append(paso)
	for c in paso:
		_poner(c[0], c[2])
	return true


func _poner(zona: int, color: Color) -> void:
	colores[zona] = color
	paleta.set_pixel(zona % LADO_PALETA, zona / LADO_PALETA, color)
	textura_paleta.update(paleta)


## Punto de la lamina dentro de la zona (el mas alejado de su borde).
func punto(zona: int) -> Vector2i:
	var i := (zona - 1) * 8
	if zona < 1 or i + 8 > info_zonas.size():
		return Vector2i(-1, -1)
	return Vector2i(info_zonas.decode_u16(i), info_zonas.decode_u16(i + 2))


## Ancho y alto de la caja que contiene la zona.
func caja(zona: int) -> Vector2i:
	var i := (zona - 1) * 8
	if zona < 1 or i + 8 > info_zonas.size():
		return Vector2i.ZERO
	return Vector2i(info_zonas.decode_u16(i + 4), info_zonas.decode_u16(i + 6))


## Zona en blanco mas cercana a un punto de la lamina (0 si no queda ninguna).
## evitar: zonas ya propuestas, para que pulsar otra vez lleve a otra.
func vacia_mas_cercana(desde: Vector2, evitar: Dictionary = {}) -> int:
	if info_zonas.size() < zonas * 8:
		return 0
	var mejor := 0
	var dist := INF
	for z in range(1, zonas + 1):
		if colores[z] != BLANCO or evitar.has(z):
			continue
		var d := desde.distance_squared_to(Vector2(punto(z)))
		if d < dist:
			dist = d
			mejor = z
	return mejor


func terminada() -> bool:
	for z in range(1, zonas + 1):
		if colores[z] == BLANCO:
			return false
	return zonas > 0


## La obra a tamano completo: color de cada zona con las lineas encima.
## En CPU (unos 0,4 s en escritorio): no depende de la pantalla y se puede probar.
func imagen() -> Image:
	var lin := textura_lineas.get_image()
	if lin.is_compressed():
		lin.decompress()
	lin.convert(Image.FORMAT_LA8)
	var reg := regiones
	if reg.get_format() != Image.FORMAT_RGB8:
		reg = regiones.duplicate()
		reg.convert(Image.FORMAT_RGB8)
	var r := reg.get_data()
	var l := lin.get_data()
	var pal := PackedByteArray()
	pal.resize((zonas + 1) * 3)
	for z in zonas + 1:
		var c := colores[z]
		pal[z * 3] = c.r8
		pal[z * 3 + 1] = c.g8
		pal[z * 3 + 2] = c.b8
	var n := reg.get_width() * reg.get_height()
	var out := PackedByteArray()
	out.resize(n * 3)
	for i in n:
		var z := r[i * 3] + r[i * 3 + 1] * 256
		if z > zonas:
			z = 0
		var luz := 255 - l[i * 2 + 1]       # la linea es negra con alfa
		var o := i * 3
		out[o] = pal[z * 3] * luz / 255
		out[o + 1] = pal[z * 3 + 1] * luz / 255
		out[o + 2] = pal[z * 3 + 2] * luz / 255
	return Image.create_from_data(reg.get_width(), reg.get_height(), false, Image.FORMAT_RGB8, out)


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
	_trazo = null
