# Yōkai del capítulo 1 como datos, sacados de las fichas de ronin3d/BESTIARIO.md §3 (los
# números son los provisionales de las fichas). El aspecto es su hoja de sprites en el estilo del
# oni del usuario («hoja» y «alto», con visual_hoja.gd); la «receta» del bestiario queda para la
# galería y para jugar con --modelos3d. El comportamiento lo pone yokai.gd.
#
# Cada ataque: aviso (s con el «!» antes de golpear), activo (s en que hace daño), recuperacion,
# alcance y ancho (m, una franja hacia delante), danio, parable (si el iai lo desvía),
# embestida (m/s hacia delante mientras golpea; 0 = quieto) y rojo («!!»: no se puede parar).
extends RefCounted


static func _ataque(nombre: String, aviso: float, activo: float, recuperacion: float, alcance: float,
		ancho: float, danio: int, parable: bool, embestida := 0.0) -> Dictionary:
	return {"nombre": nombre, "aviso": aviso, "activo": activo, "recuperacion": recuperacion,
		"alcance": alcance, "ancho": ancho, "danio": danio, "parable": parable,
		"embestida": embestida, "rojo": not parable}


static func perfil(tipo: String) -> Dictionary:
	match tipo:
		"kappa":
			# Veloz: avisa 0,3 s, se mueve a 6 m/s y aguanta 2 golpes. El iai perfecto le derrama
			# el agua del plato y lo deja de un golpe. Si Akira se queda en postura de iai frente
			# a él 2 s sin atacar, hace la reverencia y derrama el agua solo.
			return {
				"nombre": "Kappa", "id": 353, "hoja": "kappa_hoja", "alto": 1.3, "vida": 2, "velocidad": 6.0, "peso": 0.7,
				"vision": 10.0, "correa": 9.0, "distancia_ataque": 2.2, "reverencia": true,
				"receta": {"familia": "bipedo", "tamano": "S", "elemento": "agua", "rol": "veloz",
					"semilla": 353, "id": 353, "rango": 1, "nombre": "Kappa",
					"partes": ["caparazon", "plato", "pico", "ojos"],
					"paleta": [Color("3f8f7a"), Color("2c4a3a"), Color("f3e9a0")]},
				"ataques": [_ataque("Embestida", 0.3, 0.25, 0.55, 1.4, 0.9, 1, true, 8.0)],
			}
		"oni":
			# Poderoso: barrido parable (aviso de 0,6 s; el iai lo aturde 1,5 s y le quita 3, pero no
			# lo mata) y golpe de kanabō que no se para («!!» rojo, 0,9 s). Si falla, el garrote
			# queda clavado 1 s y el oni queda abierto. Vida: 6.
			return {
				"nombre": "Aka-oni", "id": 2315, "hoja": "oni_jefe", "alto": 2.2, "vida": 6, "velocidad": 2.6, "peso": 2.5,
				"vision": 11.0, "correa": 10.0, "distancia_ataque": 2.4,
				"resiste_iai": {"danio": 3, "aturdido": 1.5},
				"receta": {"familia": "bipedo", "tamano": "M", "elemento": "fuego", "rol": "poderoso",
					"semilla": 2315, "id": 2315, "rango": 1, "nombre": "Aka-oni", "detallado": true,
					"partes": ["cuernos", "garrote", "ojos", "armadura"],
					"paleta": [Color("b3321f"), Color("33231c"), Color("f1e6c8")]},
				"ataques": [
					_ataque("Barrido", 0.6, 0.25, 0.6, 2.4, 2.6, 1, true),
					_ataque("Golpe de kanabō", 0.9, 0.2, 1.0, 2.7, 1.3, 2, false),
				],
			}
		"onibi":
			# Enjambre: grupos que giran alrededor de Akira y se lanzan de uno en uno (aviso de
			# 0,4 s). Queman 1 de vida, mueren de un golpe y cada uno da espíritu.
			return {
				"nombre": "Onibi", "id": 2301, "hoja": "onibi_hoja", "alto": 0.9, "vida": 1, "velocidad": 4.0, "peso": 0.4,
				"vision": 12.0, "correa": 14.0, "distancia_ataque": 3.4, "flota": true,
				"orbita": 3.0, "espiritu_al_morir": 0.2,
				"receta": {"familia": "flotante", "tamano": "S", "elemento": "fuego", "rol": "enjambre",
					"semilla": 2301, "id": 2301, "rango": 1, "nombre": "Onibi", "forma": "llama",
					"partes": ["ojos"], "paleta": [Color("7aa0ff"), Color("2c2468"), Color("e0ecff")]},
				"ataques": [_ataque("Llamarada", 0.4, 0.3, 0.7, 1.2, 0.9, 1, true, 9.0)],
			}
	return {}


# Dónde salen en el patio del castillo (entre las patrullas de los soldados).
const OLEADA_CAPITULO_1 := [
	["kappa", Vector3(3, 0, -7)],
	["kappa", Vector3(12, 0, 11)],
	["oni", Vector3(13, 0, -1)],
	["onibi", Vector3(-6, 0, 6)],
	["onibi", Vector3(-5, 0, 7)],
	["onibi", Vector3(-7, 0, 7)],
	["onibi", Vector3(-6, 0, 8)],
	["onibi", Vector3(-4, 0, 6)],
]
