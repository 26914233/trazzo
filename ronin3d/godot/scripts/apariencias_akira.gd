# Aspectos de Akira. «joven» es el de la historia desde el 02-10-2026: un ronin joven y
# endurecido, con una cicatriz que le cruza la cara, la mirada dura, la cinta deshilachada y
# la ropa gastada. Los otros tres son skins que pidió el usuario ese mismo día: curtido
# (unos 30), veterano (unos 40) y Akira mujer. Todos llevan la cicatriz.
# El elegido se guarda en user://ajustes.cfg.
extends RefCounted

const ORDEN := ["joven", "curtido", "veterano", "mujer"]
const APARIENCIAS := {
	"joven": {
		"nombre": "Joven endurecido",
		"kimono": Color("2f3a5c"), "manga": Color("222a44"), "remiendo": Color("56628a"),
		"hakama": Color("34343e"), "obi": Color("8a2e2a"), "cinta": Color("8e2a26"), "solapa": Color("cfc8b4"),
		"pelo": Color("141218"), "piel": Color("dcb48e"),
		"ancho": 1.0, "escala": 1.0, "peinado": "coleta_revuelta", "barba": "",
		"vendas": true, "tasuki": false, "sombrero": false,
	},
	"curtido": {
		"nombre": "Curtido (unos 30)",
		"kimono": Color("5a4632"), "manga": Color("3e3024"), "remiendo": Color("7a6450"),
		"hakama": Color("2a2a30"), "obi": Color("6a5a3a"), "cinta": Color("3a3a40"), "solapa": Color("b8ac90"),
		"pelo": Color("1a1614"), "piel": Color("c9a07a"),
		"ancho": 1.08, "escala": 1.0, "peinado": "moño", "barba": "de_dias",
		"vendas": true, "tasuki": true, "sombrero": false,
	},
	"veterano": {
		"nombre": "Veterano (unos 40)",
		"kimono": Color("2a2a32"), "manga": Color("1c1c22"), "remiendo": Color("44444f"),
		"hakama": Color("3a3442"), "obi": Color("5a2622"), "cinta": Color("5a2622"), "solapa": Color("8a8a90"),
		"pelo": Color("6a6a72"), "piel": Color("c49c78"),
		"ancho": 1.12, "escala": 1.02, "peinado": "moño", "barba": "corta",
		"vendas": false, "tasuki": false, "sombrero": true,
	},
	"mujer": {
		"nombre": "Akira mujer",
		"kimono": Color("3a2f5c"), "manga": Color("2a2244"), "remiendo": Color("5a4e82"),
		"hakama": Color("4a1e24"), "obi": Color("b8923e"), "cinta": Color("a8302a"), "solapa": Color("e6e0d2"),
		"pelo": Color("141218"), "piel": Color("e2bc98"),
		"ancho": 0.9, "escala": 0.96, "peinado": "coleta_larga", "barba": "",
		"vendas": true, "tasuki": false, "sombrero": false,
	},
}
const ARCHIVO := "user://ajustes.cfg"

static var elegida := "joven"
static var cargada := false


static func datos(id := "") -> Dictionary:
	return APARIENCIAS.get(id if id != "" else elegida, APARIENCIAS["joven"])


static func cargar() -> void:
	if cargada:
		return
	cargada = true
	var ajustes := ConfigFile.new()
	if ajustes.load(ARCHIVO) == OK:
		var id: String = ajustes.get_value("akira", "apariencia", "joven")
		if APARIENCIAS.has(id):
			elegida = id


static func siguiente() -> String:
	elegida = ORDEN[(ORDEN.find(elegida) + 1) % ORDEN.size()]
	var ajustes := ConfigFile.new()
	ajustes.load(ARCHIVO)
	ajustes.set_value("akira", "apariencia", elegida)
	ajustes.save(ARCHIVO)
	return elegida
