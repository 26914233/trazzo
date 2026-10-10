# Personalizacion (solo estetica): paletas, bolas y estelas. Se compran con gemas.
class_name Aspectos
extends RefCounted

const PALETAS := [
	{"id": "clasica", "nombre": "Clásica", "precio": 0, "cuerpo": "#22D3EE", "borde": "#0E7490", "puntas": "#EC4899"},
	{"id": "lava", "nombre": "Lava", "precio": 150, "cuerpo": "#FF7A1A", "borde": "#9A3412", "puntas": "#FFD60A"},
	{"id": "bosque", "nombre": "Bosque", "precio": 150, "cuerpo": "#3DDC97", "borde": "#166534", "puntas": "#A16207"},
	{"id": "hielo", "nombre": "Hielo", "precio": 250, "cuerpo": "#E0F2FE", "borde": "#38BDF8", "puntas": "#818CF8"},
	{"id": "neon", "nombre": "Neón", "precio": 300, "cuerpo": "#F0ABFC", "borde": "#A21CAF", "puntas": "#22D3EE"},
	{"id": "oro", "nombre": "Oro", "precio": 450, "cuerpo": "#FACC15", "borde": "#A16207", "puntas": "#FFFFFF"},
]
const BOLAS := [
	{"id": "plata", "nombre": "Plata", "precio": 0, "base": "#C9D2E3", "sombra": "#8E9BB5"},
	{"id": "rubi", "nombre": "Rubí", "precio": 100, "base": "#FF6B81", "sombra": "#B5172F"},
	{"id": "esmeralda", "nombre": "Esmeralda", "precio": 100, "base": "#6EE7B7", "sombra": "#047857"},
	{"id": "sol", "nombre": "Sol", "precio": 200, "base": "#FDE047", "sombra": "#EA580C"},
	{"id": "galaxia", "nombre": "Galaxia", "precio": 350, "base": "#C4B5FD", "sombra": "#4C1D95"},
	{"id": "carbon", "nombre": "Carbón", "precio": 250, "base": "#6B7280", "sombra": "#111827"},
]
const ESTELAS := [
	{"id": "ninguna", "nombre": "Sin estela", "precio": 0, "color": ""},
	{"id": "chispas", "nombre": "Chispas", "precio": 150, "color": "#FDE047"},
	{"id": "cometa", "nombre": "Cometa", "precio": 250, "color": "#38BDF8"},
	{"id": "rosa", "nombre": "Rosa", "precio": 250, "color": "#EC4899"},
	{"id": "arcoiris", "nombre": "Arcoíris", "precio": 400, "color": "arcoiris"},
]
const TIPOS := {"paleta": PALETAS, "bola": BOLAS, "estela": ESTELAS}


static func lista(tipo: String) -> Array:
	return TIPOS.get(tipo, [])


static func buscar(tipo: String, id: String) -> Dictionary:
	for a in lista(tipo):
		if a["id"] == id:
			return a
	return {}


static func por_defecto(tipo: String) -> String:
	return lista(tipo)[0]["id"]
