# Reglas del juego y del modelo de pago. Valores en docs/MONETIZACION.md.
# Clase pura y estatica: se prueba sin escena.
class_name Economia
extends RefCounted

## Version gratis: estas primeras sopas de cada categoria, mas la sopa del dia.
## El pago unico desbloquea las demas, quita los anuncios y da pistas ilimitadas.
const SOPAS_GRATIS_POR_CATEGORIA := 3
const PISTAS_GRATIS_DIA := 3
const PREMIADOS_MAX_DIA := 20

## Cada sopa tiene 12 palabras; la dificultad decide cuantas entran, el tamaño
## minimo de la cuadricula y las direcciones (ver GeneradorSopa).
const DIFICULTADES := [
	{"nombre": "Fácil", "lado": 8, "palabras": 6},
	{"nombre": "Normal", "lado": 10, "palabras": 9},
	{"nombre": "Difícil", "lado": 12, "palabras": 12},
	{"nombre": "Experto", "lado": 14, "palabras": 12},
]


## Estrellas de 1 a 3 segun segundos empleados y pistas usadas.
## Referencia: unos 12 s por palabra es un ritmo "bueno".
static func estrellas(segundos: float, palabras: int, pistas: int) -> int:
	var objetivo := 12.0 * palabras
	var e := 3
	if segundos > objetivo:
		e -= 1
	if segundos > objetivo * 2.0:
		e -= 1
	e -= pistas
	return clampi(e, 1, 3)


## Nueva racha dado el ultimo dia jugado y hoy (fechas "AAAA-MM-DD").
## Devuelve [racha_nueva, es_dia_nuevo].
static func avanzar_racha(racha: int, ultimo_dia: String, hoy: String) -> Array:
	if ultimo_dia == hoy or (ultimo_dia != "" and hoy < ultimo_dia):
		return [racha, false]  # mismo dia, o fecha anterior: ni reinicia ni cuenta
	if ultimo_dia != "" and _dias_entre(ultimo_dia, hoy) == 1:
		return [racha + 1, true]
	return [1, true]


static func _dias_entre(a: String, b: String) -> int:
	var ua := Time.get_unix_time_from_datetime_string(a + "T00:00:00")
	var ub := Time.get_unix_time_from_datetime_string(b + "T00:00:00")
	return int(round((ub - ua) / 86400.0))
