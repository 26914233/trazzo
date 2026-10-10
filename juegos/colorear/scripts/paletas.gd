# Paletas curadas de 12 colores. La goma (blanco) va aparte.
class_name Paletas
extends RefCounted

const LISTA := [
	{"nombre": "Primavera", "colores": ["#F94144", "#F3722C", "#F8961E", "#F9C74F", "#90BE6D", "#43AA8B", "#4D908E", "#577590", "#277DA1", "#F28482", "#B5E48C", "#9D4EDD"]},
	{"nombre": "Pastel", "colores": ["#FFADAD", "#FFD6A5", "#FDFFB6", "#CAFFBF", "#9BF6FF", "#A0C4FF", "#BDB2FF", "#FFC6FF", "#F1C0E8", "#CFBAF0", "#A3C4F3", "#B9FBC0"]},
	{"nombre": "Océano", "colores": ["#03045E", "#023E8A", "#0077B6", "#0096C7", "#00B4D8", "#48CAE4", "#90E0EF", "#CAF0F8", "#2A9D8F", "#E9C46A", "#F4A261", "#E76F51"]},
	{"nombre": "Atardecer", "colores": ["#355070", "#6D597A", "#B56576", "#E56B6F", "#EAAC8B", "#FFB4A2", "#E5989B", "#FFCDB2", "#F6BD60", "#F28482", "#84A59D", "#F5CAC3"]},
	{"nombre": "Bosque", "colores": ["#283618", "#606C38", "#DDA15E", "#BC6C25", "#FEFAE0", "#2D6A4F", "#40916C", "#52B788", "#95D5B2", "#8D6346", "#582F0E", "#E9EDC9"]},
	{"nombre": "Joyas", "colores": ["#9B2226", "#AE2012", "#BB3E03", "#CA6702", "#EE9B00", "#E9D8A6", "#94D2BD", "#0A9396", "#005F73", "#3A0CA3", "#7209B7", "#F72585"]},
	{"nombre": "Tierra", "colores": ["#6F1D1B", "#BB9457", "#432818", "#99582A", "#FFE6A7", "#A98467", "#ADC178", "#DDE5B6", "#F0EAD2", "#6C584C", "#B08968", "#E6CCB2"]},
	{"nombre": "Neutros", "colores": ["#111111", "#343A40", "#495057", "#6C757D", "#ADB5BD", "#DEE2E6", "#3D405B", "#81B29A", "#F2CC8F", "#E07A5F", "#F4F1DE", "#8E9AAF"]},
]


## Indice de la paleta propia del jugador ("Mis colores"), tras las curadas.
const MIS_COLORES := 8


static func colores(i: int) -> Array:
	return LISTA[posmod(i, LISTA.size())]["colores"].map(func(h): return Color.html(h))


static func nombre(i: int) -> String:
	return LISTA[posmod(i, LISTA.size())]["nombre"]
