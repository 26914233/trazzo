# Los cuatro prototipos: un mismo núcleo (cámara táctil, piezas, pistas, inventario) y cuatro
# identidades distintas para probar cuál engancha más. Cada uno es una sola pieza de 5 a 15 minutos.
extends RefCounted

const VERSION := "Puzles · prototipos 0.1"

const PROTOTIPOS := [
	{
		"id": "caja_viva",
		"titulo": "La caja viva",
		"frase": "Una caja secreta japonesa de cien años que ha cobrado vida y no quiere que la abras.",
		"script": "res://scripts/prototipos/caja_viva.gd",
		"acento": Color(0.86, 0.2, 0.16),
		"fondo": Color(0.07, 0.06, 0.1),
	},
	{
		"id": "relojero",
		"titulo": "La caja del relojero",
		"frase": "Un relojero desapareció en 1891. Su caja solo se abre a las horas que importan.",
		"script": "res://scripts/prototipos/relojero.gd",
		"acento": Color(0.85, 0.66, 0.32),
		"fondo": Color(0.09, 0.06, 0.04),
	},
	{
		"id": "reliquia",
		"titulo": "La reliquia",
		"frase": "Un artefacto de otro mundo flota frente a ti. Guía su luz y escucha lo que despierta.",
		"script": "res://scripts/prototipos/reliquia.gd",
		"acento": Color(0.3, 0.85, 0.9),
		"fondo": Color(0.03, 0.05, 0.09),
	},
	{
		"id": "farero",
		"titulo": "El cuarto del farero",
		"frase": "La tormenta arrecia, el farero no está y un barco se acerca. Enciende el faro.",
		"script": "res://scripts/prototipos/farero.gd",
		"acento": Color(0.95, 0.72, 0.36),
		"fondo": Color(0.04, 0.06, 0.08),
	},
]


static func buscar(id: String) -> Dictionary:
	for prototipo in PROTOTIPOS:
		if prototipo.id == id:
			return prototipo
	return {}
