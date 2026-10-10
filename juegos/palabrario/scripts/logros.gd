# Logros locales. No se guardan: se calculan del progreso (estrellas y
# estadisticas), asi nunca se desincronizan y no hay nada nuevo que firmar.
# Google Play Games (logros en la nube y clasificacion) queda para mas adelante.
class_name Logros
extends RefCounted

# [id, nombre, detalle, medida, meta]
const LISTA := [
	["primera", "Primera sopa", "Resuelve tu primera sopa.", "completadas", 1],
	["sopas_10", "Buscador", "Resuelve 10 sopas distintas.", "resueltas", 10],
	["sopas_50", "Ojo de lince", "Resuelve 50 sopas distintas.", "resueltas", 50],
	["sopas_150", "Incansable", "Resuelve 150 sopas distintas.", "resueltas", 150],
	["sopas_todas", "Palabrario completo", "Resuelve todas las sopas.", "resueltas", -1],
	["tema_completo", "Tema completo", "Resuelve todas las sopas de un tema.", "temas_completos", 1],
	["experto", "Experto", "Resuelve una sopa en Experto.", "expertas", 1],
	["perfectas_25", "Tres estrellas", "Consigue 3 estrellas en 25 sopas.", "perfectas", 25],
	["rapido", "Relámpago", "Resuelve una sopa en Normal en menos de un minuto.", "rapida", 1],
	["racha_3", "Tres días seguidos", "Juega 3 días seguidos.", "racha_max", 3],
	["racha_7", "Una semana", "Juega 7 días seguidos.", "racha_max", 7],
	["racha_30", "Un mes", "Juega 30 días seguidos.", "racha_max", 30],
	["diarias_10", "Fiel a la cita", "Resuelve 10 sopas del día.", "diarias", 10],
	["azar_10", "Sin guion", "Resuelve 10 sopas al azar.", "aleatorias", 10],
	["palabras_1000", "Mil palabras", "Encuentra 1000 palabras.", "palabras", 1000],
	["extras_25", "Cazapalabras", "Encuentra 25 palabras extra escondidas.", "extras", 25],
	["reloj_10", "Contra el reloj", "Gana 10 sopas en contrarreloj.", "reloj_ganadas", 10],
]


## [{id, nombre, detalle, actual, meta, hecho}] en el orden de LISTA.
static func lista(d: Dictionary) -> Array:
	var medidas := _medidas(d)
	var out := []
	for l in LISTA:
		var meta: int = l[4] if l[4] > 0 else Temas.total_sopas()
		var actual: int = medidas[l[3]]
		out.append({"id": l[0], "nombre": l[1], "detalle": l[2], "actual": mini(actual, meta), "meta": meta, "hecho": actual >= meta})
	return out


static func hechos(d: Dictionary) -> Dictionary:
	var h := {}
	for l in lista(d):
		if l["hecho"]:
			h[l["id"]] = true
	return h


## Ids conseguidos ahora que no estaban en `antes`.
static func nuevos(antes: Dictionary, d: Dictionary) -> Array:
	return hechos(d).keys().filter(func(id): return not antes.has(id))


static func nombre(id: String) -> String:
	for l in LISTA:
		if l[0] == id:
			return l[1]
	return id


static func _medidas(d: Dictionary) -> Dictionary:
	var sopas := {}           # "cat/sub" resueltas en alguna dificultad
	var perfectas := {}
	var expertas := 0
	for k in d.get("estrellas", {}):
		var partes: PackedStringArray = str(k).split("/")
		if partes.size() != 3:
			continue
		var e := int(d["estrellas"][k])
		if e <= 0:
			continue
		var sopa := partes[0] + "/" + partes[1]
		sopas[sopa] = true
		if e >= 3:
			perfectas[sopa] = true
		if partes[2] == "3":
			expertas += 1
	var completos := 0
	for c in Temas.lista:
		if c["subtemas"].all(func(s): return sopas.has(c["id"] + "/" + s["id"])):
			completos += 1
	var normal := int(d.get("mejor_tiempo", [0, 0, 0, 0])[1])
	return {
		"completadas": int(d.get("completadas", 0)),
		"resueltas": sopas.size(),
		"temas_completos": completos,
		"expertas": expertas,
		"perfectas": perfectas.size(),
		"rapida": 1 if normal > 0 and normal < 60 else 0,
		"racha_max": int(d.get("racha_max", 0)),
		"diarias": int(d.get("diarias", 0)),
		"aleatorias": int(d.get("aleatorias", 0)),
		"palabras": int(d.get("palabras", 0)),
		"extras": int(d.get("extras", 0)),
		"reloj_ganadas": int(d.get("reloj_ganadas", 0)),
	}
