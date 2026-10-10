# Reglas del juego. App de pago sin anuncios (docs/MONETIZACION.md): todo el
# contenido incluido; las pistas son lo unico que se compra dentro.
# Clase pura y estatica: se prueba sin escena.
class_name Economia
extends RefCounted

## Pistas de regalo cada dia. Las compradas se suman aparte y no caducan.
const PISTAS_GRATIS_DIA := 3
const PISTAS_MAX := 100_000   ## tope de saneado del saldo guardado

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
	if ultimo_dia != "" and dias_entre(ultimo_dia, hoy) == 1:
		return [racha + 1, true]
	return [1, true]


## Palabras extra: cada EXTRAS_POR_PISTA encontradas dan una pista, con tope
## diario (si no, las sopas al azar serian pistas infinitas).
const EXTRAS_POR_PISTA := 3
const PISTAS_EXTRA_DIA := 2


## Contrarreloj opcional: generoso, para que sea un reto y no un castigo.
static func tiempo_limite(palabras: int, dificultad: int) -> int:
	return palabras * (20 + 5 * clampi(dificultad, 0, 3))


## Un comodin por semana: si faltas un solo dia, la racha sigue (las reseñas
## castigan perder una racha larga por un despiste).
const DIAS_COMODIN := 7


static func comodin_disponible(usado: String, hoy: String) -> bool:
	return usado == "" or dias_entre(usado, hoy) >= DIAS_COMODIN


## true si entre el ultimo dia y hoy falto exactamente un dia y hay comodin.
static func comodin_salva(ultimo_dia: String, hoy: String, disponible: bool) -> bool:
	return disponible and ultimo_dia != "" and dias_entre(ultimo_dia, hoy) == 2


static func dias_entre(a: String, b: String) -> int:
	var ua := Time.get_unix_time_from_datetime_string(a + "T00:00:00")
	var ub := Time.get_unix_time_from_datetime_string(b + "T00:00:00")
	return int(round((ub - ua) / 86400.0))
