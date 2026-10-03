# Los cuatro juegos y sus cajas (niveles). Cada juego es una identidad distinta sobre el mismo
# núcleo (cámara táctil, piezas, pistas, inventario). Hoy cada juego tiene una caja jugable; las
# demás están selladas hasta que se decida cuál se convierte en juego (DECISIÓN 23).
extends RefCounted

const VERSION := "Cuatro cajas · prototipos 0.2.1"

const JUEGOS := [
	{
		"id": "caja_viva",
		"titulo": "La caja viva",
		"frase": "Cajas secretas japonesas de cien años que han cobrado vida y no quieren que las abras.",
		"acento": Color(0.88, 0.24, 0.18),
		"fondo": Color(0.07, 0.06, 0.1),
		"unidad": "Caja",
		"cajas": [
			{"id": "caja_viva", "frase": "Le quitaron la cara para que durmiera. Devuélvesela.",
				"script": "res://scripts/prototipos/caja_viva.gd"},
			{"id": "caja_viva_2"},
			{"id": "caja_viva_3"},
		],
	},
	{
		"id": "relojero",
		"titulo": "La caja del relojero",
		"frase": "Un relojero desapareció en 1891. Sus cajas solo se abren a las horas que importan.",
		"acento": Color(0.88, 0.68, 0.34),
		"fondo": Color(0.09, 0.06, 0.04),
		"unidad": "Caja",
		"cajas": [
			{"id": "relojero", "frase": "El reloj de la tapa es la llave.",
				"script": "res://scripts/prototipos/relojero.gd"},
			{"id": "relojero_2"},
			{"id": "relojero_3"},
		],
	},
	{
		"id": "reliquia",
		"titulo": "La reliquia",
		"frase": "Artefactos de otro mundo. Guía su luz y escucha lo que despierta.",
		"acento": Color(0.32, 0.86, 0.92),
		"fondo": Color(0.03, 0.05, 0.09),
		"unidad": "Reliquia",
		"cajas": [
			{"id": "reliquia", "frase": "Tres anillos desvían la luz hasta los glifos.",
				"script": "res://scripts/prototipos/reliquia.gd"},
			{"id": "reliquia_2"},
			{"id": "reliquia_3"},
		],
	},
	{
		"id": "farero",
		"titulo": "El cuarto del farero",
		"frase": "La tormenta arrecia, el farero no está y un barco se acerca. Enciende el faro.",
		"acento": Color(0.96, 0.74, 0.38),
		"fondo": Color(0.04, 0.06, 0.08),
		"unidad": "Sala",
		"cajas": [
			{"id": "farero", "frase": "La habitación de la linterna, en plena tormenta.",
				"script": "res://scripts/prototipos/farero.gd"},
			{"id": "farero_2"},
			{"id": "farero_3"},
		],
	},
]


static func juego(id: String) -> Dictionary:
	for datos in JUEGOS:
		if datos.id == id:
			return datos
	return {}


static func juego_de(caja_id: String) -> Dictionary:
	for datos in JUEGOS:
		for caja in datos.cajas:
			if caja.id == caja_id:
				return datos
	return {}


# Los datos completos de una caja: los de su juego más los suyos (nombre «Caja 1», frase, guion)
static func caja(id: String) -> Dictionary:
	for datos in JUEGOS:
		var cajas: Array = datos.cajas
		for numero in cajas.size():
			if cajas[numero].id != id:
				continue
			var resultado: Dictionary = datos.duplicate()
			resultado.erase("cajas")
			resultado.merge(cajas[numero], true)
			resultado.juego = datos.id
			resultado.numero = numero + 1
			resultado.nombre = "%s %d" % [datos.unidad, numero + 1]
			resultado.frase_juego = datos.frase
			if not resultado.has("frase"):
				resultado.frase = ""
			return resultado
	return {}


static func jugable(caja_datos: Dictionary) -> bool:
	return caja_datos.has("script") and ResourceLoader.exists(caja_datos.script)


# Todas las cajas jugables (lo usa la prueba automática)
static func cajas_jugables() -> Array:
	var lista: Array = []
	for datos in JUEGOS:
		for caja_datos in datos.cajas:
			if caja_datos.has("script"):
				lista.append(caja(caja_datos.id))
	return lista
