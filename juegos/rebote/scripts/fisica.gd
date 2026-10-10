# Fisica propia y determinista de la bola: rebotes contra rectangulos (ladrillos,
# paredes) y contra la paleta. Clase pura y estatica: se prueba sin escena.
class_name Fisica
extends RefCounted

const ANGULO_MAX := deg_to_rad(60.0)      # salida maxima desde la vertical en la paleta
const VERTICAL_MIN := 0.3                 # parte minima de la rapidez en vertical


## Velocidad tras tocar la paleta: el angulo depende de donde golpea
## (centro = recto hacia arriba, bordes = ANGULO_MAX). Es lo que da control.
static func rebote_paleta(x_bola: float, x_paleta: float, ancho: float, rapidez: float) -> Vector2:
	var t := clampf((x_bola - x_paleta) / (ancho / 2.0), -1.0, 1.0)
	var a := t * ANGULO_MAX
	return Vector2(sin(a), -cos(a)) * rapidez


## Choque de un circulo con un rectangulo: {choca, normal, profundidad}.
## La normal apunta del rectangulo hacia la bola.
static func choque(centro: Vector2, radio: float, r: Rect2) -> Dictionary:
	var cerca := Vector2(clampf(centro.x, r.position.x, r.end.x), clampf(centro.y, r.position.y, r.end.y))
	var d := centro - cerca
	if d == Vector2.ZERO:
		# centro dentro: sale por el lado mas cercano
		var izq := centro.x - r.position.x
		var der := r.end.x - centro.x
		var arr := centro.y - r.position.y
		var aba := r.end.y - centro.y
		var m := minf(minf(izq, der), minf(arr, aba))
		var n := Vector2(-1, 0) if m == izq else Vector2(1, 0) if m == der else Vector2(0, -1) if m == arr else Vector2(0, 1)
		return {"choca": true, "normal": n, "profundidad": m + radio}
	var dist := d.length()
	if dist >= radio:
		return {"choca": false, "normal": Vector2.ZERO, "profundidad": 0.0}
	return {"choca": true, "normal": d / dist, "profundidad": radio - dist}


## Refleja la velocidad en la normal solo si se mueve hacia la superficie.
static func reflejar(v: Vector2, n: Vector2) -> Vector2:
	if v.dot(n) >= 0.0:
		return v
	return v - 2.0 * v.dot(n) * n


## Evita trayectorias casi horizontales (eternas entre paredes): sube la parte
## vertical hasta VERTICAL_MIN de la rapidez, sin cambiar la rapidez ni los sentidos.
static func corregir_angulo(v: Vector2) -> Vector2:
	var rapidez := v.length()
	if rapidez == 0.0 or absf(v.y) >= VERTICAL_MIN * rapidez:
		return v
	var vy := VERTICAL_MIN * rapidez * (1.0 if v.y >= 0.0 else -1.0)
	var vx := sqrt(maxf(rapidez * rapidez - vy * vy, 0.0)) * (1.0 if v.x >= 0.0 else -1.0)
	return Vector2(vx, vy)


## Subpasos para que la bola avance como mucho medio radio en cada uno.
static func subpasos(desplazamiento: float, radio: float) -> int:
	return maxi(1, ceili(desplazamiento / (radio * 0.5)))
