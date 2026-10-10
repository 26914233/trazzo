# Eventos de temporada sin servidor: fechas fijas del calendario y, cuando no hay
# ninguna, un "fin de semana tematico" (viernes a domingo) con un tema destacado.
# Cada evento son SOPAS_POR_EVENTO sopas que ya existen; completarlas todas dentro
# de la ventana da la insignia del evento (Progreso.registrar_evento).
class_name Eventos
extends RefCounted

const SOPAS_POR_EVENTO := 5

# desde/hasta en "MM-DD"; si desde > hasta, cruza el año (la clave usa el año de inicio).
const FIJOS := [
	{"id": "san-valentin", "nombre": "San Valentín", "desde": "02-07", "hasta": "02-14", "sopas": [
		["fiestas", "san-valentin"], ["palabras", "sentimientos"], ["familia-y-personas", "amistad"],
		["ropa-y-moda", "joyas"], ["naturaleza", "flores"]]},
	{"id": "idioma", "nombre": "Día del Idioma", "desde": "04-20", "hasta": "04-26", "sopas": [
		["literatura", "escritores-latinoamericanos"], ["literatura", "poesia"], ["palabras", "palindromos"],
		["escuela", "gramatica"], ["literatura", "cien-anos-de-soledad"]]},
	{"id": "medio-ambiente", "nombre": "Semana del Medio Ambiente", "desde": "06-01", "hasta": "06-07", "sopas": [
		["naturaleza", "medio-ambiente"], ["electricidad", "energias-renovables"], ["naturaleza", "el-agua"],
		["naturaleza", "selva-y-bosque"], ["biologia", "ecosistemas"]]},
	{"id": "vacaciones", "nombre": "Vacaciones", "desde": "07-01", "hasta": "07-14", "sopas": [
		["viajes", "playa"], ["viajes", "equipaje"], ["viajes", "camping"],
		["mar-y-oceano", "la-playa"], ["viajes", "maravillas-del-mundo"]]},
	{"id": "independencia", "nombre": "Independencia de Colombia", "desde": "07-16", "hasta": "07-22", "sopas": [
		["colombia", "simbolos-patrios"], ["historia", "independencia-de-america"], ["colombia", "departamentos"],
		["colombia", "ritmos-colombianos"], ["colombia", "regiones-naturales"]]},
	{"id": "halloween", "nombre": "Halloween y Día de Muertos", "desde": "10-24", "hasta": "11-02", "sopas": [
		["fiestas", "halloween"], ["fiestas", "dia-de-muertos"], ["cine-y-television", "terror"],
		["mitologia", "leyendas-latinoamericanas"], ["mitologia", "monstruos-legendarios"]]},
	{"id": "navidad", "nombre": "Navidad y Año Nuevo", "desde": "12-01", "hasta": "01-06", "sopas": [
		["fiestas", "navidad"], ["fiestas", "ano-nuevo"], ["ropa-y-moda", "ropa-de-invierno"],
		["comida", "postres"], ["clima", "frio-y-calor"]]},
]


static func _unix(fecha: String) -> int:
	return Time.get_unix_time_from_datetime_string(fecha + "T12:00:00")


static func _fecha(u: int) -> String:
	return Time.get_date_string_from_unix_time(u)


## Evento activo en `fecha` ("AAAA-MM-DD"): {id, nombre, clave, desde, hasta, sopas}
## con desde/hasta como fechas completas, o {} si no hay.
static func activo(fecha: String) -> Dictionary:
	if not Progreso.es_fecha(fecha):
		return {}
	var anio := fecha.substr(0, 4).to_int()
	var md := fecha.substr(5)
	for e in FIJOS:
		var cruza: bool = e["desde"] > e["hasta"]
		var dentro: bool = (md >= e["desde"] or md <= e["hasta"]) if cruza else (md >= e["desde"] and md <= e["hasta"])
		if dentro:
			var inicio := anio if not cruza or md >= e["desde"] else anio - 1
			return {"id": e["id"], "nombre": e["nombre"], "clave": "%s-%d" % [e["id"], inicio],
				"desde": "%d-%s" % [inicio, e["desde"]], "hasta": "%d-%s" % [inicio + (1 if cruza else 0), e["hasta"]],
				"sopas": e["sopas"]}
	return _fin_de_semana(fecha)


## Viernes a domingo: un tema distinto cada semana y 5 de sus sopas.
static func _fin_de_semana(fecha: String) -> Dictionary:
	var u := _unix(fecha)
	var dia: int = Time.get_datetime_dict_from_unix_time(u)["weekday"]    # 0 domingo .. 6 sabado
	var desde_viernes: int = {5: 0, 6: 1, 0: 2}.get(dia, -1)
	if desde_viernes < 0 or Temas.lista.is_empty():
		return {}
	var viernes := _fecha(u - desde_viernes * 86400)
	var semana := int(_unix(viernes) / 86400 / 7)
	var n := Temas.lista.size()
	var paso := 17
	while _mcd(paso, n) != 1:
		paso += 1
	var cat: Dictionary = Temas.lista[posmod(semana * paso, n)]
	var subs: Array = cat["subtemas"].duplicate()
	var rng := RandomNumberGenerator.new()
	rng.seed = semana
	for i in range(subs.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t = subs[i]
		subs[i] = subs[j]
		subs[j] = t
	var sopas := []
	for s in subs.slice(0, SOPAS_POR_EVENTO):
		sopas.append([cat["id"], s["id"]])
	return {"id": "finde", "nombre": "Fin de semana: %s" % cat["nombre"], "clave": "finde-" + viernes,
		"desde": viernes, "hasta": _fecha(_unix(viernes) + 2 * 86400), "sopas": sopas}


static func _mcd(a: int, b: int) -> int:
	while b != 0:
		var t := b
		b = a % b
		a = t
	return a


## Dias que quedan contando hoy (el ultimo dia cuenta como 1).
static func dias_restantes(ev: Dictionary, hoy: String) -> int:
	return int((_unix(ev["hasta"]) - _unix(hoy)) / 86400) + 1


## Todas las fechas de la edicion que empieza en `anio` (para pruebas de solape).
static func dias_de(e: Dictionary, anio: int) -> PackedStringArray:
	var ini := _unix("%d-%s" % [anio, e["desde"]])
	var fin := _unix("%d-%s" % [anio + (1 if e["desde"] > e["hasta"] else 0), e["hasta"]])
	var out := PackedStringArray()
	var u := ini
	while u <= fin:
		out.append(_fecha(u))
		u += 86400
	return out


## La sopa forma parte del evento.
static func incluye(ev: Dictionary, cat: String, sub: String) -> bool:
	for par in ev.get("sopas", []):
		if par[0] == cat and par[1] == sub:
			return true
	return false
