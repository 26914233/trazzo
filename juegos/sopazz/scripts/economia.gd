# Reglas de la economia de Sopazz. Valores en docs/MONETIZACION.md.
# Clase pura y estatica: se prueba sin escena.
class_name Economia
extends RefCounted

const PISTAS_GRATIS_INICIALES := 3
const COSTE_PISTA := 25
const COSTE_REVELAR := 60
const COSTE_TEMA := 300
const FICHAS_PREMIADO := 30
const PREMIADOS_MAX_DIA := 20
const RACHA := [10, 15, 20, 25, 30, 40, 60]

const DIFICULTADES := [
	{"nombre": "Fácil", "lado": 8, "palabras": 5, "max_largo": 7},
	{"nombre": "Normal", "lado": 10, "palabras": 8, "max_largo": 9},
	{"nombre": "Difícil", "lado": 12, "palabras": 11, "max_largo": 9},
	{"nombre": "Experto", "lado": 14, "palabras": 14, "max_largo": 9},
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


## Fichas que da completar un nivel.
static func recompensa_nivel(estrellas_obtenidas: int, primera_vez_tema: bool, es_diario: bool) -> int:
	var f := 20 if estrellas_obtenidas >= 3 else 10 + (estrellas_obtenidas - 1) * 5
	if primera_vez_tema:
		f += 25
	if es_diario:
		f *= 2
	return f


## Recompensa del dia N de racha (1 = primer dia). A partir del 7 se queda en el maximo.
static func recompensa_racha(dia: int) -> int:
	if dia < 1:
		return 0
	return RACHA[mini(dia, RACHA.size()) - 1]


## Nueva racha dado el ultimo dia jugado y hoy (fechas "AAAA-MM-DD").
## Devuelve [racha_nueva, cobra_recompensa_hoy].
static func avanzar_racha(racha: int, ultimo_dia: String, hoy: String) -> Array:
	if ultimo_dia == hoy:
		return [racha, false]
	if ultimo_dia != "" and _dias_entre(ultimo_dia, hoy) == 1:
		return [racha + 1, true]
	return [1, true]


static func _dias_entre(a: String, b: String) -> int:
	var ua := Time.get_unix_time_from_datetime_string(a + "T00:00:00")
	var ub := Time.get_unix_time_from_datetime_string(b + "T00:00:00")
	return int(round((ub - ua) / 86400.0))
