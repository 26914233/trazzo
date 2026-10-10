# Lo que se guarda entre partidas (user://partida.cfg): las monedas, las skins compradas al
# sastre, las bendiciones del jizō (DECISIÓN 16, A + C) y, desde la 0.16, el escenario en el que se
# va, el más lejano alcanzado y las técnicas aprendidas (el paso del tengu de Sōjōbō). Se guarda sola, poco después de cada
# cambio y al cerrar o mandar el juego a segundo plano.
# Los precios son un supuesto de partida: hay que medir cuántas monedas junta un jugador.
extends RefCounted

const ARCHIVO := "user://partida.cfg"
const PRECIOS_SKINS := {"curtido": 30, "mujer": 40, "veterano": 60}
const PRECIOS_BENDICION := [40, 80]           # cada una, +1 de vida máxima; dos como mucho

static var monedas := 0
static var compradas: Array = ["joven"]
static var bendiciones := 0
static var escenario := 0                     # el que se juega (escenarios.gd)
static var alcanzado := 0                     # el más lejano abierto: se puede volver a cualquiera anterior
static var tecnicas: Array = []
static var cargada := false
static var pendiente := false                 # hay cambios sin guardar
static var modo_prueba := false               # la prueba automática no toca la partida de verdad


static func cargar(ruta := ARCHIVO) -> void:
	cargada = true
	var archivo := ConfigFile.new()
	if archivo.load(ruta) != OK:
		return
	monedas = maxi(0, int(archivo.get_value("partida", "monedas", 0)))
	compradas = ["joven"]
	for id in archivo.get_value("partida", "compradas", []):
		if PRECIOS_SKINS.has(id) and not id in compradas:
			compradas.append(id)
	bendiciones = clampi(int(archivo.get_value("partida", "bendiciones", 0)), 0, PRECIOS_BENDICION.size())
	alcanzado = maxi(0, int(archivo.get_value("partida", "alcanzado", 0)))
	escenario = clampi(int(archivo.get_value("partida", "escenario", 0)), 0, alcanzado)
	tecnicas = []
	for id in archivo.get_value("partida", "tecnicas", []):
		tecnicas.append(String(id))


static func guardar(ruta := ARCHIVO) -> void:
	pendiente = false
	if modo_prueba and ruta == ARCHIVO:
		return
	var archivo := ConfigFile.new()
	archivo.set_value("partida", "monedas", monedas)
	archivo.set_value("partida", "compradas", compradas)
	archivo.set_value("partida", "bendiciones", bendiciones)
	archivo.set_value("partida", "escenario", escenario)
	archivo.set_value("partida", "alcanzado", alcanzado)
	archivo.set_value("partida", "tecnicas", tecnicas)
	archivo.save(ruta)


# Una partida nueva, en memoria (la usa la prueba automática).
static func reiniciar() -> void:
	monedas = 0
	compradas = ["joven"]
	bendiciones = 0
	escenario = 0
	alcanzado = 0
	tecnicas = []
	cargada = true
	pendiente = false


static func sumar_monedas(cantidad: int) -> void:
	monedas += cantidad
	pendiente = true


static func tiene(id: String) -> bool:
	return id in compradas


static func precio(id: String) -> int:
	return int(PRECIOS_SKINS.get(id, 0))


# El sastre: compra la skin si llegan las monedas.
static func comprar(id: String) -> bool:
	if tiene(id):
		return true
	if not PRECIOS_SKINS.has(id) or monedas < precio(id):
		return false
	monedas -= precio(id)
	compradas.append(id)
	guardar()
	return true


# Precio de la siguiente bendición del jizō, o -1 si ya no quedan.
static func precio_bendicion() -> int:
	return PRECIOS_BENDICION[bendiciones] if bendiciones < PRECIOS_BENDICION.size() else -1


static func bendecir() -> bool:
	var coste := precio_bendicion()
	if coste < 0 or monedas < coste:
		return false
	monedas -= coste
	bendiciones += 1
	guardar()
	return true


# Al terminar un escenario se abre el siguiente (y se aprende su técnica, si la tiene).
static func completar(indice: int, cantidad: int, tecnica := "") -> void:
	alcanzado = clampi(maxi(alcanzado, indice + 1), 0, cantidad - 1)
	if tecnica != "" and not tecnica in tecnicas:
		tecnicas.append(tecnica)
	guardar()


static func tiene_tecnica(id: String) -> bool:
	return id in tecnicas
