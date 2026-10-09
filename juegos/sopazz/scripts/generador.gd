# Generador de sopas de letras.
#
# Clase pura: no toca nodos ni escenas, para poder probarla con
# `godot --headless --script res://tests/pruebas.gd`.
#
# Reglas:
#  - Las palabras se colocan en linea recta en una de las 8 direcciones.
#  - Dos palabras solo se cruzan si la letra compartida coincide.
#  - La misma semilla produce siempre la misma sopa (niveles reproducibles:
#    el "nivel del dia" es la misma sopa para todo el mundo sin servidor).
#  - Lo que no se pudo colocar se devuelve en `descartadas`. Nunca se calla.
class_name GeneradorSopa
extends RefCounted

const DIR_RECTAS: Array[Vector2i] = [Vector2i(1, 0), Vector2i(0, 1)]
const DIR_DIAGONALES: Array[Vector2i] = [Vector2i(1, 1), Vector2i(1, -1)]
const DIR_INVERSAS: Array[Vector2i] = [
	Vector2i(-1, 0), Vector2i(0, -1), Vector2i(-1, -1), Vector2i(-1, 1)
]

# Frecuencia aproximada de letras en español, para que el relleno no delate
# las palabras: una cuadricula llena de K, W y X canta demasiado.
const BOLSA_RELLENO := "AAAAAAAAAAAAEEEEEEEEEEEEOOOOOOOOOSSSSSSSSRRRRRRRNNNNNNNIIIIIIILLLLLDDDDDCCCCCTTTTTUUUUUMMMMPPPBBGGVVYYQQHHFFZJXKWÑ"

## Una palabra ya situada en la cuadricula.
class Colocada extends RefCounted:
	var palabra: String          ## normalizada, tal como aparece en la cuadricula
	var original: String         ## con tildes y Ñ, tal como se muestra al jugador
	var celdas: Array[Vector2i]

	func _init(p: String, o: String, c: Array[Vector2i]) -> void:
		palabra = p
		original = o
		celdas = c


## Resultado completo de una generacion.
class Sopa extends RefCounted:
	var lado: int
	var semilla: int
	var cuadricula: Array = []            ## Array de Array de String (una letra)
	var colocadas: Array[Colocada] = []
	var descartadas: PackedStringArray = []

	func letra(c: Vector2i) -> String:
		if c.x < 0 or c.y < 0 or c.x >= lado or c.y >= lado:
			return ""
		return cuadricula[c.y][c.x]

	func texto() -> String:
		var lineas: PackedStringArray = []
		for fila in cuadricula:
			lineas.append("".join(fila))
		return "\n".join(lineas)

	## Devuelve la palabra colocada cuyas celdas son exactamente `celdas`
	## (en un sentido o en el otro), o null si esa seleccion no es ninguna.
	func buscar_en(celdas: Array[Vector2i]) -> Colocada:
		if celdas.is_empty():
			return null
		var inv: Array[Vector2i] = celdas.duplicate()
		inv.reverse()
		for c in colocadas:
			if c.celdas == celdas or c.celdas == inv:
				return c
		return null


## Pasa una palabra a la forma que se usa en la cuadricula: mayusculas, sin
## tildes, sin espacios ni signos. La Ñ se conserva: en español es una letra,
## y convertirla en N cambia palabras (AÑO no es ANO).
## La misma tabla vive en herramientas/construir_temas.py, que comprueba que
## ninguna palabra de los temas trae una letra fuera de ella.
static func normalizar(palabra: String) -> String:
	var s := palabra.to_upper()
	var de := "ÁÉÍÓÚÀÈÌÒÙÄËÏÖÜÂÊÎÔÛÃÕÇ"
	var a := "AEIOUAEIOUAEIOUAEIOUAOC"
	var salida := ""
	for i in s.length():
		var ch := s[i]
		var pos := de.find(ch)
		if pos != -1:
			ch = a[pos]
		if (ch >= "A" and ch <= "Z") or ch == "Ñ":
			salida += ch
	return salida


## Direcciones permitidas segun la dificultad (0 facil .. 3 experto).
static func direcciones_para(dificultad: int) -> Array[Vector2i]:
	var dirs: Array[Vector2i] = DIR_RECTAS.duplicate()
	if dificultad >= 1:
		dirs.append_array(DIR_DIAGONALES)
	if dificultad >= 2:
		dirs.append_array(DIR_INVERSAS)
	return dirs


## Celdas de la linea recta de `a` a `b`, o vacio si no estan alineadas
## en una de las 8 direcciones. Es lo que convierte un arrastre del dedo
## en una seleccion valida.
static func celdas_en_linea(a: Vector2i, b: Vector2i) -> Array[Vector2i]:
	var d := b - a
	var alineadas := d.x == 0 or d.y == 0 or absi(d.x) == absi(d.y)
	if not alineadas:
		return []
	var paso := Vector2i(signi(d.x), signi(d.y))
	var largo := maxi(absi(d.x), absi(d.y)) + 1
	var celdas: Array[Vector2i] = []
	for i in largo:
		celdas.append(a + paso * i)
	return celdas


## Genera una sopa. `palabras` llega como viene del tema (con tildes).
static func generar(
	palabras: PackedStringArray,
	lado: int,
	dificultad: int = 1,
	semilla: int = 0
) -> Sopa:
	var sopa := Sopa.new()
	sopa.lado = lado
	sopa.semilla = semilla
	var rng := RandomNumberGenerator.new()
	rng.seed = semilla

	# Cuadricula vacia: "" marca celda libre.
	for y in lado:
		var fila: Array = []
		fila.resize(lado)
		fila.fill("")
		sopa.cuadricula.append(fila)

	var dirs := direcciones_para(dificultad)

	# De la mas larga a la mas corta: las largas son las que de verdad
	# tienen pocos sitios donde caber.
	var ordenadas: Array = []
	var vistas := {}
	for original in palabras:
		var norm := normalizar(original)
		if norm.length() < 3 or norm.length() > lado:
			sopa.descartadas.append(original)
			continue
		if vistas.has(norm):
			continue  # repetida: ya va en la sopa, no se pierde nada
		vistas[norm] = true
		ordenadas.append({"norm": norm, "original": original})
	ordenadas.sort_custom(func(x, y): return x["norm"].length() > y["norm"].length())

	for item in ordenadas:
		if not _colocar(sopa, item["norm"], item["original"], lado, dirs, rng):
			sopa.descartadas.append(item["original"])

	_rellenar(sopa, lado, rng)
	return sopa


static func _colocar(
	sopa: Sopa,
	norm: String,
	original: String,
	lado: int,
	dirs: Array[Vector2i],
	rng: RandomNumberGenerator
) -> bool:
	# Se barajan todas las posiciones posibles (direccion, x, y) y se prueban en
	# orden: si existe un hueco, se encuentra. Nada de "20 intentos y me rindo".
	# Indices en un PackedInt32Array: en un movil barato, crear un diccionario
	# por posicion y palabra se nota.
	var por_dir := lado * lado
	var opciones := PackedInt32Array()
	opciones.resize(dirs.size() * por_dir)
	for i in opciones.size():
		opciones[i] = i
	_barajar_enteros(opciones, rng)

	var largo := norm.length()
	for op in opciones:
		var d: Vector2i = dirs[op / por_dir]
		var resto := op % por_dir
		var inicio := Vector2i(resto % lado, resto / lado)
		var fin := inicio + d * (largo - 1)
		if fin.x < 0 or fin.y < 0 or fin.x >= lado or fin.y >= lado:
			continue
		var cabe := true
		for i in largo:
			var c := inicio + d * i
			var actual: String = sopa.cuadricula[c.y][c.x]
			if actual != "" and actual != norm[i]:
				cabe = false
				break
		if not cabe:
			continue
		var celdas := _celdas_de(inicio, d, largo)
		for i in largo:
			sopa.cuadricula[celdas[i].y][celdas[i].x] = norm[i]
		sopa.colocadas.append(Colocada.new(norm, original, celdas))
		return true
	return false


static func _celdas_de(inicio: Vector2i, dir: Vector2i, largo: int) -> Array[Vector2i]:
	var celdas: Array[Vector2i] = []
	for i in largo:
		celdas.append(inicio + dir * i)
	return celdas


static func _rellenar(sopa: Sopa, lado: int, rng: RandomNumberGenerator) -> void:
	for y in lado:
		for x in lado:
			if sopa.cuadricula[y][x] == "":
				var i := rng.randi_range(0, BOLSA_RELLENO.length() - 1)
				sopa.cuadricula[y][x] = BOLSA_RELLENO[i]


static func _barajar(arr: Array, rng: RandomNumberGenerator) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t = arr[i]
		arr[i] = arr[j]
		arr[j] = t


static func _barajar_enteros(arr: PackedInt32Array, rng: RandomNumberGenerator) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t := arr[i]
		arr[i] = arr[j]
		arr[j] = t
