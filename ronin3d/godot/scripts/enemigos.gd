# Criaturas del bestiario como datos, sacadas de las fichas de ronin3d/BESTIARIO.md (§3 para el
# capítulo 1; §4 a §6 para los capítulos 2 a 4). Los números son provisionales: se ajustan probando.
# El aspecto es su hoja de sprites en el estilo del oni del usuario («hoja» y «alto», con
# visual_hoja.gd); la «receta» del bestiario queda para la galería y para jugar con --modelos3d. El
# comportamiento lo pone yokai.gd.
#
# Cada ataque: aviso (s con el «!» antes de golpear), activo (s en que hace daño), recuperacion,
# alcance y ancho (m, una franja hacia delante), danio, parable (si el iai lo desvía),
# embestida (m/s hacia delante mientras golpea; 0 = quieto) y rojo («!!»: no se puede parar).
# Y, desde la 0.16:
#   forma        «franja» (por defecto), «disparo» (proyectil.gd), «area» (zona_peligro.gd) o «invoca»
#   golpes       cadena de golpes seguidos (aviso_cadena entre uno y otro): hay que parar cada uno
#   centro       (área) «objetivo» (donde está Akira), «propio» (alrededor) o «frente»; radio; linea, largo
#   salto        (área) salta hasta donde caerá el golpe
#   efecto       «atrapa» (Akira no se mueve un momento); drena (cura a quien golpea)
#   rastro_fuego deja fuego en el suelo al embestir; anim: fila de la hoja («ataque» o «area»)
#   uso          distancia desde la que lo usa (si no, la de su alcance)
#
# Conductas del perfil (yokai.gd):
#   reverencia (kappa), resiste_iai (aguanta el iai: aturdido y con menos vida), orbita y prisa (enjambre),
#   manada (okuri-inu: atacan cuando Akira tropieza), familia (para enjambres y curas), cura (cada N s),
#   copias y copia (ilusiones), falsa (la ilusión: no hace daño, cae de un golpe y no da sombra),
#   disfraz («jizo», «farol», «estatua») y despierta / despierta_si_corre, espejo (responde a cada corte),
#   vuela (altura), escudo_frontal (grados), coraza (solo con la postura rota), piedra_si_mira,
#   divide, revive, niebla, crias, mantiene_distancia, jefe, patron, fases, queda, transforma,
#   objetivo (sello que hay que cortar), tinte, alfa, sin_monedas, visual_akira.
extends RefCounted

const VIOLETA := Color(0.75, 0.35, 1.0)
const AZUL_ZORRO := Color(0.45, 0.75, 1.0)


static func _ataque(nombre: String, aviso: float, activo: float, recuperacion: float, alcance: float,
		ancho: float, danio: int, parable: bool, embestida := 0.0) -> Dictionary:
	return {"nombre": nombre, "aviso": aviso, "activo": activo, "recuperacion": recuperacion,
		"alcance": alcance, "ancho": ancho, "danio": danio, "parable": parable,
		"embestida": embestida, "rojo": not parable}


static func _mas(base: Dictionary, extra: Dictionary) -> Dictionary:
	var resultado := base.duplicate()
	resultado.merge(extra, true)
	return resultado


static func _disparo(nombre: String, aviso: float, danio: int, parable: bool, extra := {}) -> Dictionary:
	return _mas(_ataque(nombre, aviso, 0.1, 0.8, 1.0, 1.0, danio, parable), _mas({"forma": "disparo"}, extra))


static func _area(nombre: String, aviso: float, radio: float, danio: int, extra := {}) -> Dictionary:
	return _mas(_ataque(nombre, aviso, 0.25, 0.9, radio, radio, danio, extra.get("parable", false)),
		_mas({"forma": "area", "radio": radio}, extra))


static func _base(nombre: String, hoja: String, alto: float, vida: int, velocidad: float, peso: float,
		extra := {}) -> Dictionary:
	return _mas({"nombre": nombre, "hoja": hoja, "alto": alto, "vida": vida, "velocidad": velocidad,
		"peso": peso, "vision": 11.0, "correa": 10.0, "distancia_ataque": 2.2, "tamano": "M"}, extra)


static func perfil(tipo: String) -> Dictionary:
	match tipo:
		# --- Capítulo 1 -------------------------------------------------------------------------
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
		"aka_oni_puente":
			# Guardián de la planicie: un aka-oni más grande que salta sobre Akira (área con sombra).
			return _base("Aka-oni del puente", "oni_jefe", 2.5, 12, 2.8, 3.0, {
				"jefe": true, "despierta": 11.0, "tamano": "L", "resiste_iai": {"danio": 3, "aturdido": 1.5},
				"mensaje_despertar": "Un aka-oni salta sobre el puente y cierra el paso",
				"ataques": [
					_ataque("Barrido", 0.6, 0.25, 0.6, 2.5, 2.6, 1, true),
					_ataque("Golpe de kanabō", 0.9, 0.2, 1.0, 2.8, 1.3, 2, false),
					_area("Salto del oni", 1.0, 2.0, 2, {"salto": true, "centro": "objetivo", "uso": 8.0}),
				],
				"patron": [0, 0, 2, 0, 1],
				"fases": [{"umbral": 0.5, "velocidad": 1.25, "aviso": 0.85, "mensaje": "¡El aka-oni se enfurece!"}],
			})
		"oni_azul":
			# La variante de la ficha del oni: el oni azul, más rápido, con tres barridos seguidos.
			return _base("Ao-oni", "oni_azul_hoja", 2.4, 12, 3.4, 2.6, {
				"jefe": true, "despierta": 11.0, "tamano": "L", "resiste_iai": {"danio": 3, "aturdido": 1.2},
				"mensaje_despertar": "Un oni azul baja del monte: tres barridos seguidos, para cada uno",
				"ataques": [
					_mas(_ataque("Tres barridos", 0.55, 0.22, 0.7, 2.5, 2.6, 1, true, 3.0), {"golpes": 3, "aviso_cadena": 0.32}),
					_ataque("Golpe de kanabō", 0.8, 0.2, 0.9, 2.8, 1.3, 2, false),
				],
				"patron": [0, 1, 0, 0, 1],
			})
		# --- Capítulo 2 · El velo ----------------------------------------------------------------
		"tsukumogami":
			# Farolillo de cien años (chōchin-obake): parece un farolillo más hasta que Akira pasa cerca.
			return _base("Chōchin-obake", "tsukumogami_hoja", 1.0, 1, 3.6, 0.5, {
				"disfraz": "farol", "flota": true, "altura_flota": 0.15, "tamano": "S",
				"ataques": [
					_ataque("Lengüetazo", 0.35, 0.2, 0.6, 1.6, 0.9, 1, true, 5.0),
					_area("Llamarada", 0.7, 1.4, 1, {"centro": "frente", "linea": true, "largo": 3.0, "ancho": 1.2, "uso": 3.0}),
				],
				"patron": [0, 0, 1],
			})
		"hitodama":
			# Almas en forma de llama: la variante pálida del onibi, más rápida.
			return _base("Hitodama", "hitodama_hoja", 0.9, 1, 4.8, 0.4, {
				"flota": true, "orbita": 2.6, "prisa": 0.8, "espiritu_al_morir": 0.2, "tamano": "S",
				"vision": 12.0, "correa": 14.0, "distancia_ataque": 3.2,
				"ataques": [_ataque("Llamarada fría", 0.35, 0.3, 0.6, 1.2, 0.9, 1, true, 10.0)],
			})
		"tanuki":
			# Se disfraza de estatua jizō junto al camino; al acercarse Akira, sale del humo con su mazo.
			return _base("Tanuki", "tanuki_hoja", 1.25, 3, 3.4, 1.0, {
				"disfraz": "jizo", "despierta": 2.4, "tamano": "S",
				"mensaje_despertar": "¡Esa estatua jizō era un tanuki!",
				"ataques": [_ataque("Mazazo", 0.5, 0.25, 0.7, 1.8, 1.4, 1, true, 4.0)],
			})
		"kitsune":
			# Zorro de tres colas: al verse en peligro crea dos copias falsas. Las copias no dan sombra.
			return _base("Kitsune", "kitsune_hoja", 1.6, 3, 4.0, 1.0, {
				"copias": 2, "copia": "kitsune_ilusion", "despierta": 8.0,
				"mensaje_despertar": "La kitsune se multiplica: la de verdad es la única que da sombra",
				"ataques": [
					_ataque("Corte de zorro", 0.45, 0.25, 0.6, 2.0, 1.4, 1, true, 5.0),
					_disparo("Fuego de zorro", 0.6, 1, true, {"color": AZUL_ZORRO, "rapidez": 11.0}),
				],
				"patron": [0, 1, 0],
			})
		"kitsune_ilusion":
			return _base("Kitsune", "kitsune_hoja", 1.6, 1, 4.0, 0.5, {
				"falsa": true, "sin_monedas": true,
				"ataques": [_ataque("Corte de zorro", 0.45, 0.25, 0.6, 2.0, 1.4, 1, true, 5.0)],
			})
		"noppera_bo":
			# Fantasma sin cara: copia a Akira y responde a cada corte con su propio iai.
			return _base("Noppera-bō", "noppera_bo_hoja", 1.75, 3, 3.0, 1.0, {
				"espejo": true,
				"ataques": [_ataque("Iai sin rostro", 0.5, 0.22, 0.7, 2.1, 1.2, 1, true, 6.0)],
			})
		"karasu_tengu":
			# Hombre cuervo: vuela alto y baja en picado.
			return _base("Karasu-tengu", "karasu_tengu_hoja", 1.7, 3, 4.6, 0.9, {
				"vuela": 1.6, "distancia_ataque": 3.0,
				"ataques": [_ataque("Picado", 0.45, 0.3, 0.7, 2.4, 1.2, 1, true, 10.0)],
			})
		"kamaitachi":
			# Comadrejas del viento, siempre en trío: una de ellas cura a las otras.
			return _base("Kamaitachi", "kamaitachi_hoja", 0.85, 2, 6.2, 0.5, {
				"familia": "kamaitachi", "tamano": "S", "distancia_ataque": 2.6,
				"ataques": [_ataque("Hoz de viento", 0.3, 0.22, 0.5, 1.6, 1.0, 1, true, 9.0)],
			})
		"kamaitachi_curandera":
			return _base("Kamaitachi curandera", "kamaitachi_hoja", 0.85, 2, 6.2, 0.5, {
				"familia": "kamaitachi", "tamano": "S", "cura": 3.0, "distancia_ataque": 2.6,
				"tinte": Color(0.75, 1.0, 0.8),
				"ataques": [_ataque("Hoz de viento", 0.3, 0.22, 0.5, 1.6, 1.0, 1, true, 9.0)],
			})
		"okuri_inu":
			# Lobos que siguen al viajero de noche: rodean sin atacar y, si Akira tropieza, se lanzan.
			return _base("Okuri-inu", "okuri_inu_hoja", 1.1, 2, 5.4, 0.8, {
				"orbita": 3.4, "manada": true, "prisa": 0.15, "familia": "okuri_inu", "distancia_ataque": 4.0,
				"ataques": [_ataque("Mordisco", 0.35, 0.25, 0.5, 1.4, 1.0, 1, true, 9.0)],
			})
		"sello_ofuda":
			# Sello de papel que alimenta la barrera del santuario del templo.
			return {"nombre": "Sello", "modelo": "ofuda", "vida": 1, "velocidad": 0.0, "peso": 9.0,
				"vision": 0.0, "correa": 0.0, "distancia_ataque": 0.0, "objetivo": true, "sin_monedas": true,
				"tamano": "S", "ataques": []}
		"ilusion_tamamo":
			# Guardiana del templo: una ilusión de Tamamo-no-Mae (HISTORIA.md §7: en el capítulo 2,
			# «una ilusión»). Semitransparente, con copias y fuego de zorro.
			return _base("Ilusión de Tamamo-no-Mae", "tamamo_hoja", 1.85, 12, 3.0, 2.0, {
				"jefe": true, "despierta": 10.0, "alfa": 0.8, "copias": 2, "copia": "tamamo_copia",
				"resiste_iai": {"danio": 3, "aturdido": 1.2},
				"mensaje_despertar": "«¿Buscas a quien mató a tu señor, guardia?» Solo una de las tres es la ilusión de verdad",
				"ataques": [
					_mas(_ataque("Abanico", 0.45, 0.22, 0.6, 2.2, 1.6, 1, true, 4.0), {"golpes": 2, "aviso_cadena": 0.35}),
					_disparo("Llama violeta", 0.6, 1, true, {"color": VIOLETA}),
					_area("Fuego de zorro", 0.9, 1.8, 1, {"centro": "objetivo", "color": VIOLETA, "anim": "area"}),
				],
				"patron": [0, 1, 2, 0],
			})
		"tamamo_copia":
			return _base("Tamamo-no-Mae", "tamamo_hoja", 1.85, 1, 3.0, 0.5, {
				"falsa": true, "sin_monedas": true, "alfa": 0.8,
				"ataques": [_ataque("Abanico", 0.45, 0.22, 0.6, 2.2, 1.6, 1, true, 4.0)],
			})
		"sojobo":
			# Rey de los tengu: duelo de iaidō puro. Cadenas de tajos que hay que parar uno a uno y un
			# abanico de viento alrededor (rojo: salir de él). A media vida llama a sus cuervos.
			return _base("Sōjōbō, rey de los tengu", "sojobo_hoja", 2.6, 20, 3.6, 3.0, {
				"jefe": true, "despierta": 12.0, "tamano": "L", "resiste_iai": {"danio": 3, "aturdido": 1.2},
				"mensaje_despertar": "Sōjōbō abre las alas: «Enséñame tu iai, ronin»",
				"ataques": [
					_mas(_ataque("Tajo del tengu", 0.5, 0.22, 0.6, 2.6, 1.6, 1, true, 5.0), {"golpes": 3, "aviso_cadena": 0.32}),
					_area("Abanico de viento", 0.95, 3.2, 1, {"centro": "propio", "color": Color(0.35, 0.95, 0.55), "anim": "area"}),
					_disparo("Vendaval", 0.55, 1, true, {"color": Color(0.5, 1.0, 0.6), "rapidez": 13.0, "anim": "area"}),
				],
				"patron": [0, 1, 0, 2, 0, 1],
				"fases": [{"umbral": 0.5, "velocidad": 1.25, "aviso": 0.85, "invoca": ["karasu_tengu", 2],
					"mensaje": "Sōjōbō llama a sus cuervos"}],
			})
		# --- Capítulo 3 · Lo que dormía ------------------------------------------------------------
		"haniwa":
			return _base("Haniwa", "haniwa_hoja", 1.4, 2, 2.2, 1.0, {
				"ataques": [_ataque("Tajo de barro", 0.55, 0.25, 0.7, 1.9, 1.3, 1, true, 3.0)],
			})
		"dogu":
			# Autómata de barro: rayo de los ojos en línea (rojo: apartarse) y golpe corto.
			return _base("Dogū", "dogu_hoja", 1.55, 4, 1.7, 2.0, {
				"ataques": [
					_ataque("Golpe de barro", 0.55, 0.25, 0.7, 1.8, 1.4, 1, true, 2.0),
					_area("Rayo de los ojos", 0.8, 1.0, 1, {"centro": "frente", "linea": true, "largo": 7.0,
						"ancho": 1.0, "color": Color(0.3, 0.95, 1.0), "uso": 7.0}),
				],
				"patron": [1, 0, 0],
			})
		"komainu":
			# Leones-perro de piedra: duermen como estatuas mientras se camina con respeto; si Akira
			# corre cerca, despiertan. De frente no les entra la espada.
			return _base("Komainu", "komainu_hoja", 1.45, 4, 4.4, 3.0, {
				"despierta_si_corre": 6.0, "disfraz": "estatua", "escudo_frontal": 120.0, "tamano": "M",
				"mensaje_despertar": "¡El komainu despierta! De frente es de piedra: rodéalo",
				"ataques": [_ataque("Embestida de piedra", 0.5, 0.3, 0.8, 2.0, 1.4, 1, true, 8.0)],
			})
		"goblin":
			return _base("Goblin", "goblin_hoja", 1.1, 1, 5.0, 0.5, {
				"tamano": "S", "ataques": [_ataque("Puñalada", 0.3, 0.2, 0.5, 1.5, 0.9, 1, true, 7.0)],
			})
		"slime":
			# Se divide al cortarlo: el corte de luna es la respuesta.
			return _base("Limo", "slime_hoja", 0.85, 2, 2.0, 0.8, {
				"divide": {"tipo": "slime_pequeno", "cantidad": 2}, "tamano": "S",
				"ataques": [_ataque("Salto viscoso", 0.5, 0.25, 0.7, 1.6, 1.2, 1, true, 6.0)],
			})
		"slime_pequeno":
			return _base("Limo pequeño", "slime_hoja", 0.5, 1, 2.6, 0.4, {
				"tamano": "S", "sin_monedas": true,
				"ataques": [_ataque("Salto viscoso", 0.45, 0.25, 0.7, 1.3, 1.0, 1, true, 6.0)],
			})
		"gaki":
			# Fantasmas hambrientos: lentos, pero si agarran no sueltan (Akira queda atrapado).
			return _base("Gaki", "gaki_hoja", 1.45, 2, 1.7, 0.8, {
				"ataques": [_mas(_ataque("Agarrón", 0.6, 0.25, 0.8, 1.6, 1.0, 1, true, 3.0), {"efecto": "atrapa"})],
			})
		"gargola":
			# De piedra mientras Akira la mira: solo se mueve cuando le da la espalda.
			return _base("Gárgola", "gargola_hoja", 1.6, 3, 5.6, 1.5, {
				"piedra_si_mira": true, "vision": 14.0,
				"ataques": [_ataque("Zarpazo en picado", 0.4, 0.25, 0.6, 2.0, 1.2, 1, true, 9.0)],
			})
		"jorogumo":
			return _base("Jorōgumo", "jorogumo_hoja", 1.9, 5, 2.6, 1.6, {
				"tamano": "L", "crias": {"tipo": "cria_arana", "cada": 6.0, "maximo": 3},
				"ataques": [
					_disparo("Tela", 0.6, 1, true, {"efecto": "atrapa", "visual": "tela", "color": Color(0.92, 0.92, 1.0), "rapidez": 10.0}),
					_ataque("Patas", 0.45, 0.25, 0.6, 2.2, 1.8, 1, true, 3.0),
				],
				"patron": [0, 1, 1],
			})
		"cria_arana":
			return _base("Cría de araña", "tsuchigumo_hoja", 0.55, 1, 5.0, 0.3, {
				"tamano": "S", "sin_monedas": true, "tinte": Color(0.6, 0.45, 0.75),
				"ataques": [_ataque("Mordisco", 0.3, 0.2, 0.5, 1.2, 0.9, 1, true, 6.0)],
			})
		"tsuchigumo":
			# Guardiana de las ruinas: salta sobre Akira (sombra roja), lanza telas y suelta crías.
			return _base("Tsuchigumo", "tsuchigumo_hoja", 2.4, 16, 3.0, 3.0, {
				"jefe": true, "despierta": 12.0, "tamano": "L", "resiste_iai": {"danio": 3, "aturdido": 1.4},
				"mensaje_despertar": "La tsuchigumo baja de su nido",
				"crias": {"tipo": "cria_arana", "cada": 9.0, "maximo": 2},
				"ataques": [
					_area("Salto de la araña", 1.0, 2.3, 2, {"salto": true, "centro": "objetivo", "uso": 9.0}),
					_mas(_ataque("Patas", 0.5, 0.25, 0.6, 2.6, 2.4, 1, true, 3.0), {"golpes": 2, "aviso_cadena": 0.35}),
					_disparo("Tela", 0.6, 1, true, {"efecto": "atrapa", "visual": "tela", "color": Color(0.92, 0.92, 1.0)}),
				],
				"patron": [0, 1, 2, 1],
				"fases": [{"umbral": 0.5, "velocidad": 1.2, "invoca": ["cria_arana", 2], "mensaje": "¡El nido se abre!"}],
			})
		"omukade":
			# Ciempiés gigante: su coraza para la espada; un iai perfecto (o romperle la postura a
			# fuerza de golpes) deja la cabeza al descubierto.
			return _base("Ōmukade", "omukade_hoja", 1.9, 8, 3.0, 3.0, {
				"coraza": true, "tamano": "L", "resiste_iai": {"danio": 2, "aturdido": 2.5},
				"ataques": [
					_ataque("Pinzas", 0.5, 0.25, 0.7, 2.6, 1.6, 1, true, 7.0),
					_area("Coletazo", 0.8, 2.6, 1, {"centro": "propio"}),
				],
				"patron": [0, 0, 1],
			})
		"hombre_lagarto":
			# El séquito de Bahamut: escudo de bronce por delante y cimitarra en cadena.
			return _base("Hombre lagarto", "hombre_lagarto_hoja", 1.85, 4, 3.0, 1.5, {
				"escudo_frontal": 100.0,
				"ataques": [_mas(_ataque("Cimitarra", 0.45, 0.22, 0.7, 2.1, 1.4, 1, true, 4.0), {"golpes": 2, "aviso_cadena": 0.35})],
			})
		"golem":
			# Gólem de barro: la espada no lo araña hasta que un iai le rompe la guardia y deja ver la
			# palabra de su frente.
			return _base("Gólem", "golem_hoja", 2.4, 8, 1.5, 4.0, {
				"coraza": true, "tamano": "L", "resiste_iai": {"danio": 3, "aturdido": 2.2},
				"ataques": [
					_ataque("Manotazo", 0.6, 0.25, 0.8, 2.2, 1.8, 1, true, 2.0),
					_area("Puños de barro", 1.0, 2.0, 2, {"centro": "frente"}),
				],
				"patron": [0, 1],
			})
		"sello_dogu":
			# Los tres dogū gigantes que encadenan a Bahamut.
			return _base("Dogū del sello", "dogu_hoja", 3.0, 5, 0.0, 9.0, {
				"objetivo": true, "sin_monedas": true, "tamano": "L", "tinte": Color(0.85, 0.95, 1.05),
				"ataques": [],
			})
		"bahamut":
			# BESTIARIO.md §6: encadenado (romper los sellos de los dogū mientras su cola busca a
			# Akira), libre (su aliento se carga y un iai perfecto lo parte en dos) y herido en el suelo.
			return _base("Bahamut", "bahamut_hoja", 4.4, 26, 1.8, 6.0, {
				"jefe": true, "despierta": 16.0, "tamano": "XL", "resiste_iai": {"danio": 4, "aturdido": 1.6},
				"sellos": [Vector3(-3, 0, -7), Vector3(-3, 0, 7), Vector3(6, 0, 0)],
				"mensaje_despertar": "Bahamut abre los ojos. Rompe los tres dogū que sujetan sus cadenas",
				"mensaje_libre": "¡Las cadenas caen! Bahamut es libre: espera su aliento y pártelo con el iai",
				"ataques": [
					_ataque("Coletazo", 0.65, 0.3, 0.8, 4.2, 4.0, 1, true, 0.0),
					_area("Aliento de nácar", 1.5, 1.0, 2, {"centro": "frente", "linea": true, "largo": 13.0, "ancho": 2.4,
						"parable": true, "color": Color(0.85, 0.92, 1.0), "anim": "area", "uso": 13.0}),
					_area("Pisotón", 1.0, 2.6, 2, {"centro": "objetivo", "uso": 6.0}),
				],
				"patron": [0, 1, 0, 2, 1],
				"fases": [{"umbral": 0.35, "velocidad": 0.6, "recibe": 1.6,
					"mensaje": "Bahamut cae herido: sus alas y aletas quedan a tu alcance"}],
			})
		# --- Capítulo 4 · El regreso ----------------------------------------------------------------
		"kasha":
			# Gato de fuego: rueda en llamas (rojo) y deja el suelo ardiendo.
			return _base("Kasha", "kasha_hoja", 1.35, 4, 4.8, 1.2, {
				"ataques": [
					_ataque("Zarpazo", 0.4, 0.22, 0.6, 1.8, 1.3, 1, true, 5.0),
					_mas(_ataque("Rueda de fuego", 0.7, 0.6, 0.9, 1.4, 1.2, 1, false, 11.0), {"rastro_fuego": true, "uso": 7.0}),
				],
				"patron": [1, 0, 0],
			})
		"nue":
			# Quimera: cada parte ataca distinto (zarpa de tigre, cola de serpiente y rayo de su nube).
			return _base("Nue", "nue_hoja", 2.1, 6, 4.0, 1.8, {
				"ataques": [
					_ataque("Zarpa de tigre", 0.45, 0.25, 0.6, 2.0, 1.4, 1, true, 7.0),
					_ataque("Cola de serpiente", 0.35, 0.2, 0.6, 3.4, 0.8, 1, true),
					_area("Rayo de la nube", 0.9, 1.6, 1, {"centro": "objetivo", "color": VIOLETA, "uso": 9.0}),
				],
				"patron": [0, 1, 2],
			})
		"gashadokuro":
			# Esqueleto gigante de los muertos sin enterrar: se desarma y se vuelve a montar.
			return _base("Gashadokuro", "gashadokuro_hoja", 4.2, 16, 1.9, 5.0, {
				"jefe": true, "despierta": 14.0, "tamano": "XL", "revive": true,
				"resiste_iai": {"danio": 3, "aturdido": 1.5},
				"mensaje_despertar": "Los huesos de la planicie se levantan en un solo cuerpo: el gashadokuro",
				"ataques": [
					_ataque("Barrido de huesos", 0.7, 0.3, 0.8, 3.4, 3.0, 1, true, 0.0),
					_area("Mano de huesos", 1.1, 2.4, 2, {"centro": "objetivo", "color": Color(0.5, 1.0, 0.5), "uso": 9.0}),
				],
				"patron": [0, 1, 0, 0, 1],
			})
		"vampiro":
			# Bebe vida al golpear y, cada dos golpes que recibe, se vuelve niebla y reaparece a la
			# espalda. El iai perfecto lo derriba.
			return _base("Vampiro", "vampiro_hoja", 1.85, 5, 3.6, 1.2, {
				"niebla": true,
				"ataques": [_mas(_ataque("Garras", 0.4, 0.22, 0.6, 2.0, 1.2, 1, true, 8.0), {"drena": true})],
			})
		"hombre_lobo":
			return _base("Hombre lobo", "hombre_lobo_hoja", 2.0, 5, 5.8, 1.4, {
				"ataques": [_mas(_ataque("Zarpazos", 0.35, 0.2, 0.6, 1.9, 1.4, 1, true, 7.0), {"golpes": 2, "aviso_cadena": 0.28})],
			})
		"elfo_oscuro":
			# Arquero: guarda la distancia. Sus flechas se devuelven con un iai perfecto.
			return _base("Elfo oscuro", "elfo_oscuro_hoja", 1.85, 3, 3.2, 1.0, {
				"mantiene_distancia": 7.0, "vision": 14.0, "correa": 14.0,
				"ataques": [
					_disparo("Flecha violeta", 0.7, 1, true, {"color": VIOLETA, "visual": "flecha", "rapidez": 15.0}),
					_ataque("Daga", 0.35, 0.2, 0.6, 1.6, 1.0, 1, true, 4.0),
				],
				"patron": [0, 0, 1],
			})
		"ogro":
			# El primo extranjero del oni.
			return _base("Ogro", "ogro_hoja", 2.4, 6, 2.4, 3.0, {
				"tamano": "L", "resiste_iai": {"danio": 3, "aturdido": 1.5},
				"ataques": [
					_ataque("Garrote", 0.6, 0.25, 0.7, 2.4, 2.0, 1, true, 2.0),
					_area("Mazazo", 0.9, 2.0, 2, {"centro": "frente"}),
				],
				"patron": [0, 0, 1],
			})
		"ifrit":
			# Genio de fuego: bolas de fuego desde lejos y columnas de fuego bajo los pies de Akira.
			return _base("Ifrit", "ifrit_hoja", 2.2, 5, 2.6, 1.2, {
				"flota": true, "altura_flota": 0.3, "mantiene_distancia": 6.0, "vision": 14.0, "correa": 14.0,
				"ataques": [
					_disparo("Bola de fuego", 0.6, 1, true, {"color": Color(1.0, 0.5, 0.15)}),
					_area("Columna de fuego", 1.0, 1.6, 1, {"centro": "objetivo", "color": Color(1.0, 0.4, 0.1)}),
				],
				"patron": [0, 1],
			})
		"doppelganger":
			# El doble de Akira: su misma cara, más oscura; responde a cada corte (prepara a Genzo).
			return _base("Doble de Akira", "noppera_bo_hoja", 1.75, 6, 4.4, 1.0, {
				"visual_akira": true, "espejo": true, "tinte": Color(0.42, 0.3, 0.5),
				"ataques": [_mas(_ataque("Corte gemelo", 0.45, 0.22, 0.6, 1.9, 1.3, 1, true, 5.0), {"golpes": 3, "aviso_cadena": 0.3})],
			})
		"soldado_yokai":
			return _base("Soldado poseído", "soldado_hoja", 2.2, 3, 3.2, 1.0, {
				"tinte": Color(0.9, 0.7, 1.0),
				"ataques": [_ataque("Estocada", 0.5, 0.2, 0.6, 2.1, 0.8, 1, true, 3.0)],
			})
		"genzo":
			# El general: tajos en cadena, una estocada rápida y la hendidura violeta (rojo). A media
			# vida llama a sus soldados, poseídos por Tamamo. Cae de rodillas (no muere).
			return _base("General Genzo", "genzo_hoja", 1.9, 22, 3.6, 3.0, {
				"jefe": true, "despierta": 10.0, "queda": true, "resiste_iai": {"danio": 3, "aturdido": 1.0},
				"mensaje_despertar": "Genzo: «Takeda iba a perder Japón por no ensuciarse las manos. Yo no»",
				"ataques": [
					_mas(_ataque("Tajo del general", 0.45, 0.22, 0.6, 2.4, 1.6, 1, true, 5.0), {"golpes": 3, "aviso_cadena": 0.3}),
					_ataque("Estocada", 0.3, 0.2, 0.6, 2.6, 0.8, 1, true, 8.0),
					_area("Hendidura violeta", 1.0, 1.0, 2, {"centro": "frente", "linea": true, "largo": 8.0, "ancho": 1.8,
						"color": VIOLETA, "anim": "area", "uso": 8.0}),
				],
				"patron": [0, 1, 2, 0, 0, 2],
				"fases": [{"umbral": 0.5, "velocidad": 1.2, "aviso": 0.9, "invoca": ["soldado_yokai", 2],
					"mensaje": "Genzo: «¡A mí, soldados!» Sus ojos brillan violeta"}],
			})
		"tamamo":
			# Tamamo-no-Mae con su máscara de zorro: abanico, llamas violeta y copias falsas. Al caer,
			# se transforma en la zorra de nueve colas (el juego trae la forma siguiente).
			return _base("Tamamo-no-Mae", "tamamo_hoja", 1.9, 16, 3.2, 2.5, {
				"jefe": true, "despierta": 30.0, "transforma": true, "copias": 2, "copia": "tamamo_copia",
				"resiste_iai": {"danio": 3, "aturdido": 1.0},
				"mensaje_despertar": "Tamamo-no-Mae: «Gracias por el castillo, Genzo». Solo una de las tres da sombra",
				"ataques": [
					_mas(_ataque("Abanico", 0.42, 0.22, 0.6, 2.2, 1.6, 1, true, 4.0), {"golpes": 2, "aviso_cadena": 0.32}),
					_disparo("Llama violeta", 0.55, 1, true, {"color": VIOLETA}),
					_area("Fuego de zorro", 0.9, 2.0, 1, {"centro": "objetivo", "color": VIOLETA, "anim": "area"}),
				],
				"patron": [0, 1, 2, 0, 1],
			})
		"tamamo_zorro":
			# La forma final: la zorra de nueve colas. Zarpazo parable, látigo de colas alrededor
			# (rojo) y fuegos de zorro que vuelan alrededor de Akira.
			return _base("Tamamo-no-Mae, la zorra de nueve colas", "tamamo_zorro_hoja", 4.0, 28, 4.0, 6.0, {
				"jefe": true, "despierta": 30.0, "tamano": "XL", "resiste_iai": {"danio": 4, "aturdido": 1.2},
				"ataques": [
					_ataque("Zarpa", 0.5, 0.3, 0.7, 3.6, 3.0, 1, true, 4.0),
					_area("Látigo de nueve colas", 1.1, 4.2, 2, {"centro": "propio", "color": VIOLETA, "anim": "area"}),
					_mas(_ataque("Nueve fuegos", 0.8, 0.2, 0.8, 1.0, 1.0, 0, false), {"forma": "invoca", "tipo": "kitsunebi", "cantidad": 3}),
					_disparo("Fuego de zorro", 0.5, 1, true, {"color": VIOLETA, "rapidez": 13.0}),
				],
				"patron": [0, 1, 0, 3, 2, 0, 1],
				"fases": [{"umbral": 0.5, "velocidad": 1.25, "aviso": 0.85, "mensaje": "Las nueve colas arden"}],
			})
		"kitsunebi":
			return _base("Fuego de zorro", "kitsunebi_hoja", 0.8, 1, 4.6, 0.4, {
				"flota": true, "orbita": 3.0, "prisa": 0.7, "familia": "kitsunebi", "sin_monedas": true,
				"espiritu_al_morir": 0.25, "tamano": "S", "vision": 16.0, "correa": 20.0, "distancia_ataque": 3.4,
				"ataques": [_ataque("Llamarada violeta", 0.4, 0.3, 0.7, 1.2, 0.9, 1, true, 9.0)],
			})
	return {}


# Tipos que dan monedas y espíritu como un enemigo normal (las ilusiones, sellos y crías no).
static func da_monedas(datos: Dictionary) -> bool:
	return not datos.get("sin_monedas", false) and not datos.get("falsa", false)


# Todos los tipos, para la galería y las pruebas.
const TIPOS := ["kappa", "oni", "onibi", "aka_oni_puente", "oni_azul", "tsukumogami", "hitodama", "tanuki",
	"kitsune", "kitsune_ilusion", "noppera_bo", "karasu_tengu", "kamaitachi", "kamaitachi_curandera",
	"okuri_inu", "sello_ofuda", "ilusion_tamamo", "tamamo_copia", "sojobo", "haniwa", "dogu", "komainu",
	"goblin", "slime", "slime_pequeno", "gaki", "gargola", "jorogumo", "cria_arana", "tsuchigumo", "omukade",
	"hombre_lagarto", "golem", "sello_dogu", "bahamut", "kasha", "nue", "gashadokuro", "vampiro",
	"hombre_lobo", "elfo_oscuro", "ogro", "ifrit", "doppelganger", "soldado_yokai", "genzo", "tamamo",
	"tamamo_zorro", "kitsunebi"]
