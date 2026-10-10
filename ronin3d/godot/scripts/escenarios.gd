# Los escenarios del juego, en orden, con su historia, su mundo, sus enemigos y sus jefes.
# Siguen la sinopsis aprobada (HISTORIA.md §4 y §6: capítulos 1 a 4) y el reparto del bestiario
# por capítulos (BESTIARIO.md §8). Los textos del castillo son los aprobados (DECISIÓN 8A y 17A);
# los demás se escribieron el 10-10-2026 a partir de la sinopsis y esperan el visto bueno del
# usuario (HISTORIA.md §10).
#
# Cada escenario:
#   mundo       cómo se construye (constructor_escenarios.gd; «castillo» usa constructor_mundo.gd)
#   ambiente    cielo, luna, niebla y luz (aspecto.configurar_entorno)
#   inicio      dónde aparece Akira; salida_x: se sale al pasar de esa x con |z| < salida_ancho
#   patrullas   soldados de Genzo [desde, hasta]
#   yokai       [tipo de enemigos.gd, lugar]
#   objetivos   [tipo, lugar] que hay que destruir para abrir la salida (sellos del templo y de Bahamut)
#   jefes       en orden: el siguiente aparece al caer el anterior; con todos vencidos se abre la salida
#   jizo        estatua jizō (bendiciones); aldeanos: [hoja, fila, lugar, frases]; kodama: guías
#   tecnica     lo que se aprende al terminarlo (partida.gd)
extends RefCounted

const Datos := preload("res://scripts/datos.gd")

const LUNA_ROJA := Color(1.0, 0.45, 0.38)


static func cantidad() -> int:
	return lista().size()


static func datos(indice: int) -> Dictionary:
	var todos := lista()
	return todos[clampi(indice, 0, todos.size() - 1)]


static func lista() -> Array:
	return [
		# --- Capítulo 1 · La noche de Hoshiyama ------------------------------------------------
		{
			"id": "castillo", "capitulo": 1, "titulo": Datos.TITULO, "nombre": Datos.SUBTITULO,
			"mundo": "castillo", "ambiente": {},
			"intro": Datos.TEXTO_INTRO,
			"titulo_cierre": "Hoshiyama queda atrás", "cierre": Datos.TEXTO_CIERRE,
			"inicio": Datos.INICIO_AKIRA, "salida_x": Datos.LIMITE_PORTON_X, "salida_ancho": 3.0,
			"patrullas": Datos.PATRULLAS,
			"yokai": [
				["kappa", Vector3(3, 0, -7)], ["kappa", Vector3(12, 0, 11)], ["oni", Vector3(13, 0, -1)],
				["onibi", Vector3(-6, 0, 6)], ["onibi", Vector3(-5, 0, 7)], ["onibi", Vector3(-7, 0, 7)],
				["onibi", Vector3(-6, 0, 8)], ["onibi", Vector3(-4, 0, 6)],
			],
			"jefes": [{"tipo": "oni_porton", "posicion": Datos.JEFE_POSICION}],
			"jizo": Datos.JIZO_POSICION,
		},
		{
			"id": "planicie", "capitulo": 1, "titulo": "Capítulo 1 · La noche de Hoshiyama",
			"nombre": "La planicie de Hoshiyama", "mundo": "planicie",
			"ambiente": {"tinte_luna": Color(1.0, 0.78, 0.7), "luz_luna": Color("b8b0ff"), "niebla": Color("221c34"),
				"cielo_horizonte": Color("3a2238"), "ambiente": Color("262440"), "energia_ambiente": 2.9, "densidad_niebla": 0.014,
				"direccion_luna": Vector3(0.5, 0.35, -0.8)},
			"intro": [
				"La planicie de Hoshiyama. Por el camino del este huyen los aldeanos; detrás, el castillo arde bajo la luna.",
				"Los soldados de Genzo cierran los caminos y, entre la hierba alta, los fuegos fatuos buscan a los vivos. La barrera ya no los contiene.",
				"La aldea del río es el único refugio antes del amanecer. Un oni rojo vigila el puente.",
			],
			"titulo_cierre": "El puente", "cierre": [
				"Akira cruza el puente. Shiro se adelanta, olfateando el humo de los hogares.",
				"Al otro lado, las campanas de la aldea tocan a rebato.",
			],
			"inicio": Vector3(-22, 0, 0), "salida_x": 23.0, "salida_ancho": 3.0,
			"patrullas": [
				[Vector3(-12, 0, -6), Vector3(-12, 0, 6)], [Vector3(-2, 0, 8), Vector3(6, 0, 8)],
				[Vector3(10, 0, -8), Vector3(10, 0, -2)],
			],
			"yokai": [
				["onibi", Vector3(-4, 0, -6)], ["onibi", Vector3(-3, 0, -7)], ["onibi", Vector3(-5, 0, -7)],
				["onibi", Vector3(-4, 0, -8)], ["kappa", Vector3(6, 0, -10)], ["kappa", Vector3(6, 0, 10)],
				["onibi", Vector3(14, 0, 9)], ["onibi", Vector3(15, 0, 10)],
			],
			"jefes": [{"tipo": "aka_oni_puente", "posicion": Vector3(18, 0, 0)}],
		},
		{
			"id": "aldea", "capitulo": 1, "titulo": "Capítulo 1 · La noche de Hoshiyama",
			"nombre": "La aldea del río", "mundo": "aldea",
			"ambiente": {"luz_luna": Color("a8bcff"), "niebla": Color("1a2236"), "ambiente": Color("1c2238"),
				"direccion_luna": Vector3(-0.6, 0.4, -0.7)},
			"intro": [
				"La aldea del río. Los kappa han salido del agua y un oni azul ha bajado del monte.",
				"Los soldados de Genzo dicen que vienen a proteger al pueblo, pero se cobran en arroz. Algunos aldeanos les dan la razón: con Genzo, dicen, al menos hay orden.",
				"Akira no puede salvar a todo Japón esta noche. Pero puede salvar esta aldea.",
			],
			"titulo_cierre": "Fin del capítulo 1", "cierre": [
				"El oni azul cae al río. Los aldeanos salen de sus casas y miran al ronin sin saber si darle las gracias.",
				"Un anciano le cuenta que, en el templo de la montaña, los monjes sabían cruzar el velo: la frontera con el mundo de los yōkai.",
				"Al amanecer, Akira y Shiro toman el sendero del monte.",
			],
			"inicio": Vector3(-22, 0, 2), "salida_x": 23.0, "salida_ancho": 3.0,
			"patrullas": [[Vector3(-8, 0, 4), Vector3(0, 0, 4)], [Vector3(8, 0, 6), Vector3(8, 0, 12)]],
			"yokai": [
				["kappa", Vector3(-6, 0, -9)], ["kappa", Vector3(2, 0, -10)], ["kappa", Vector3(10, 0, -9)],
				["onibi", Vector3(4, 0, 9)], ["onibi", Vector3(5, 0, 10)], ["onibi", Vector3(3, 0, 10)],
				["oni", Vector3(12, 0, 2)],
			],
			"jefes": [{"tipo": "oni_azul", "posicion": Vector3(18, 0, 0)}],
			"jizo": Vector3(-19, 0, -4),
			"descanso": Vector3(-14, 0, 9),
			"aldeanos": [
				["aldeanos_hoja", "anciano", Vector3(-17, 0, 6), [
					"«El shōgun Takeda nunca dejó que los yōkai bajaran del monte. Esta noche han bajado todos.»",
					"«En el templo de la montaña hubo monjes que sabían cruzar el velo. Si alguien sabe qué ha pasado, son ellos.»"]],
				["aldeanos_hoja", "aldeana", Vector3(-9, 0, 10), [
					"«Los soldados del general dicen que nos protegen. Se han llevado medio granero.»",
					"«Mi hermano dice que con Genzo habrá orden. Yo solo quiero que los kappa vuelvan al río.»"]],
				["aldeanos_hoja", "sastre", Vector3(-12, 0, -3), [
					"«¿Ropa nueva para el camino? Abre la pausa: allí tengo mi género.»"]],
			],
		},
		# --- Capítulo 2 · El velo ----------------------------------------------------------------
		{
			"id": "templo", "capitulo": 2, "titulo": "Capítulo 2 · El velo",
			"nombre": "El templo de la montaña", "mundo": "templo",
			"ambiente": {"cielo_arriba": Color("1a1430"), "cielo_horizonte": Color("7a3a3a"), "cielo_suelo": Color("1a0e10"),
				"tinte_luna": Color(1.0, 0.85, 0.75), "luz_luna": Color("ffc0a0"), "energia_luna": 0.85,
				"niebla": Color("3a2430"), "ambiente": Color("2a1e30"), "energia_ambiente": 2.2,
				"direccion_luna": Vector3(0.8, 0.18, -0.5)},
			"intro": [
				"Capítulo 2 · El velo. El templo de la montaña está vacío: los monjes huyeron y los farolillos se han quedado solos demasiado tiempo.",
				"Los objetos que cumplen cien años despiertan con alma propia. Y entre las estatuas jizō del camino, alguna no es de piedra.",
				"Tres sellos de papel cierran el santuario. Al fondo, alguien espera con una máscara de zorro.",
			],
			"titulo_cierre": "Una ilusión", "cierre": [
				"La dama se deshace en fuego violeta. No era de carne: solo una ilusión de Tamamo-no-Mae, la zorra de nueve colas.",
				"Su risa queda colgada entre los cedros: «Corre, guardia sin señor. Cada grieta que abres es una puerta para mí».",
				"Tras el altar, un sendero sube al monte Kurama y se pierde en la niebla. Allí, dicen, enseña el rey de los tengu.",
			],
			"inicio": Vector3(-22, 0, 0), "salida_x": 23.0, "salida_ancho": 3.0,
			"patrullas": [],
			"yokai": [
				["tsukumogami", Vector3(-12, 0, -4)], ["tsukumogami", Vector3(-12, 0, 4)],
				["tanuki", Vector3(-6, 0, -5)], ["tanuki", Vector3(2, 0, 5)],
				["hitodama", Vector3(-1, 0, -9)], ["hitodama", Vector3(0, 0, -10)], ["hitodama", Vector3(1, 0, -9)],
				["kitsune", Vector3(6, 0, -3)], ["noppera_bo", Vector3(10, 0, 6)],
				["tsukumogami", Vector3(12, 0, -4)], ["tsukumogami", Vector3(12, 0, 4)],
			],
			"objetivos": [
				["sello_ofuda", Vector3(-4, 0, 11)], ["sello_ofuda", Vector3(4, 1.6, -11.5)],
				["sello_ofuda", Vector3(14, 0, 9)],
			],
			"jefes": [{"tipo": "ilusion_tamamo", "posicion": Vector3(18, 0, 0)}],
			"jizo": Vector3(-18, 0, 5),
		},
		{
			"id": "dojo", "capitulo": 2, "titulo": "Capítulo 2 · El velo",
			"nombre": "El dojo del monte Kurama, al otro lado del velo", "mundo": "dojo",
			"ambiente": {"cielo_arriba": Color("140a2a"), "cielo_horizonte": Color("2a5a5a"), "cielo_suelo": Color("0a1420"),
				"tinte_luna": Color(0.7, 1.0, 0.85), "luz_luna": Color("a0ffd8"), "energia_luna": 0.8,
				"niebla": Color("1e1a3a"), "densidad_niebla": 0.02, "ambiente": Color("221a40"), "energia_ambiente": 2.2,
				"direccion_luna": Vector3(-0.2, 0.6, -0.8)},
			"intro": [
				"Al otro lado del velo. Akira ha cruzado al Kakuriyo, el mundo oculto: los colores están del revés y los árboles susurran.",
				"Los kodama, espíritus de los árboles, le señalan el camino. Los cuervos del monte, en cambio, prueban su espada en cada recodo.",
				"En el dojo del monte Kurama espera Sōjōbō, el rey de los tengu, que enseñó la espada a Minamoto no Yoshitsune. Solo enseña a quien lo vence.",
			],
			"titulo_cierre": "Fin del capítulo 2", "cierre": [
				"Sōjōbō baja el abanico y se ríe como un trueno. «Tu iai es bueno. Tus pies, no».",
				"Le enseña el paso del tengu: desde hoy, esquivar le cuesta a Akira la mitad de aguante.",
				"«La grieta más honda está en las ruinas del oeste. Allí duerme algo que no es de esta tierra.»",
			],
			"inicio": Vector3(-22, 0, 0), "salida_x": 23.0, "salida_ancho": 3.5,
			"patrullas": [],
			"yokai": [
				["karasu_tengu", Vector3(-10, 0, -5)], ["karasu_tengu", Vector3(-8, 0, 6)],
				["kamaitachi", Vector3(-2, 0, -6)], ["kamaitachi", Vector3(-1, 0, -8)], ["kamaitachi_curandera", Vector3(0, 0, -6)],
				["okuri_inu", Vector3(5, 0, 7)], ["okuri_inu", Vector3(6, 0, 9)], ["okuri_inu", Vector3(4, 0, 9)],
				["karasu_tengu", Vector3(10, 0, -4)],
			],
			"jefes": [{"tipo": "sojobo", "posicion": Vector3(17, 0, 0)}],
			"kodama": [Vector3(-16, 0, -3), Vector3(-6, 0, 2), Vector3(3, 0, -2), Vector3(11, 0, 3)],
			"tecnica": "paso_del_tengu",
		},
		# --- Capítulo 3 · Lo que dormía ------------------------------------------------------------
		{
			"id": "ruinas", "capitulo": 3, "titulo": "Capítulo 3 · Lo que dormía",
			"nombre": "Las ruinas del oeste", "mundo": "ruinas",
			"ambiente": {"cielo_arriba": Color("0a1418"), "cielo_horizonte": Color("1e3a3a"), "cielo_suelo": Color("060c0c"),
				"tinte_luna": Color(0.85, 1.0, 1.0), "luz_luna": Color("a8e0e0"), "energia_luna": 0.85,
				"niebla": Color("16282a"), "densidad_niebla": 0.016, "ambiente": Color("1a2a2e"), "energia_ambiente": 2.4,
				"direccion_luna": Vector3(-0.5, 0.45, -0.75)},
			"intro": [
				"Capítulo 3 · Lo que dormía. Antes de los shōgun y de los templos, aquí vivió un pueblo que hacía guardianes de barro.",
				"Los dogū y los haniwa siguen de guardia, y los komainu de piedra no perdonan a quien corre en suelo sagrado.",
				"Por las grietas han llegado otros: goblins de tierras lejanas, limos y gárgolas. Y en lo más hondo, una araña de tierra teje su nido.",
			],
			"titulo_cierre": "La escalera de nácar", "cierre": [
				"La tsuchigumo cae y su nido se rompe. Debajo, una escalera baja hacia una luz de nácar.",
				"Por ella suben hombres lagarto, armados como un ejército. No vienen a por Akira: vienen a liberar a su rey.",
			],
			"inicio": Vector3(-22, 0, 0), "salida_x": 23.0, "salida_ancho": 3.0,
			"patrullas": [],
			"yokai": [
				["haniwa", Vector3(-14, 0, -4)], ["haniwa", Vector3(-14, 0, 4)], ["dogu", Vector3(-9, 0, 0)],
				["komainu", Vector3(-4, 0, -6)], ["komainu", Vector3(-4, 0, 6)],
				["goblin", Vector3(2, 0, 9)], ["goblin", Vector3(3, 0, 10)], ["goblin", Vector3(1, 0, 10)],
				["slime", Vector3(4, 0, -8)], ["gaki", Vector3(8, 0, 4)], ["gaki", Vector3(9, 0, 6)], ["gaki", Vector3(7, 0, 6)],
				["gargola", Vector3(10, 0, -9)], ["jorogumo", Vector3(12, 0, 8)],
			],
			"jefes": [{"tipo": "tsuchigumo", "posicion": Vector3(18, 0, 0)}],
			"jizo": Vector3(-19, 0, 6),
		},
		{
			"id": "santuario", "capitulo": 3, "titulo": "Capítulo 3 · Lo que dormía",
			"nombre": "El sello de Bahamut", "mundo": "santuario",
			"ambiente": {"cielo_arriba": Color("060a1a"), "cielo_horizonte": Color("1a2a4a"), "cielo_suelo": Color("04060c"),
				"tinte_luna": Color(0.9, 0.95, 1.1), "luz_luna": Color("c8d8ff"), "energia_luna": 0.7,
				"niebla": Color("141a30"), "densidad_niebla": 0.014, "ambiente": Color("181c34"), "energia_ambiente": 2.0,
				"direccion_luna": Vector3(0.3, 0.6, -0.75)},
			"intro": [
				"El sello de Bahamut. Hace milenios, un pez inmenso que sostenía el mundo cruzó una grieta y se hizo dragón. El pueblo de los dogū lo encadenó aquí.",
				"Al caer la barrera, el sello se debilita. Sus hombres lagarto quieren liberarlo; Tamamo-no-Mae lo quiere de su lado.",
				"Tres dogū gigantes sujetan sus cadenas y lo protegen a la vez. Para llegar a él, Akira tendrá que romperlos.",
			],
			"titulo_cierre": "Fin del capítulo 3", "cierre": [
				"Bahamut se derrumba sobre las cadenas rotas y cierra los ojos. Duerme, o finge dormir.",
				"Pero la grieta que abrió al despertar ya no se cierra. Por ella entran criaturas de tierras que Akira no conoce: vampiros, lobos con forma de hombre, genios de fuego.",
				"Todas caminan hacia el mismo sitio: Hoshiyama.",
			],
			"inicio": Vector3(-22, 0, 0), "salida_x": 23.0, "salida_ancho": 3.0,
			"patrullas": [],
			"yokai": [
				["hombre_lagarto", Vector3(-12, 0, -5)], ["hombre_lagarto", Vector3(-12, 0, 5)],
				["omukade", Vector3(-4, 0, 9)], ["golem", Vector3(-3, 0, -7)],
				["hombre_lagarto", Vector3(3, 0, 0)],
			],
			"jefes": [{"tipo": "bahamut", "posicion": Vector3(15, 0, 0)}],
		},
		# --- Capítulo 4 · El regreso -----------------------------------------------------------------
		{
			"id": "planicie_roja", "capitulo": 4, "titulo": "Capítulo 4 · El regreso",
			"nombre": "La planicie bajo la luna roja", "mundo": "planicie_roja",
			"ambiente": {"cielo_arriba": Color("1a0608"), "cielo_horizonte": Color("5a1a14"), "cielo_suelo": Color("100404"),
				"tinte_luna": LUNA_ROJA, "luz_luna": Color("ff9a8a"), "energia_luna": 0.9,
				"niebla": Color("3a1014"), "densidad_niebla": 0.016, "ambiente": Color("2e1418"), "energia_ambiente": 2.4,
				"direccion_luna": Vector3(0.5, 0.35, -0.8)},
			"intro": [
				"Capítulo 4 · El regreso. La planicie de Hoshiyama, otra vez. La luna está tan roja que la hierba parece sangre.",
				"En las tierras de Genzo los yōkai no atacaban: era parte del trato. Pero las criaturas de otras tierras no saben de tratos.",
				"Los muertos sin enterrar se levantan en un solo cuerpo. El gashadokuro corta el camino del castillo.",
			],
			"titulo_cierre": "Las puertas abiertas", "cierre": [
				"Los huesos del gashadokuro se esparcen por la hierba. Delante, las puertas de Hoshiyama están abiertas.",
				"Nadie las vigila. Genzo espera dentro.",
			],
			"inicio": Vector3(-22, 0, 0), "salida_x": 23.0, "salida_ancho": 3.0,
			"patrullas": [],
			"yokai": [
				["kasha", Vector3(-12, 0, -6)], ["hombre_lobo", Vector3(-10, 0, 6)],
				["elfo_oscuro", Vector3(-3, 0, -10)], ["elfo_oscuro", Vector3(-1, 0, 10)],
				["nue", Vector3(2, 0, 0)], ["ogro", Vector3(7, 0, -6)], ["vampiro", Vector3(9, 0, 6)],
				["ifrit", Vector3(12, 0, -2)],
			],
			"jefes": [{"tipo": "gashadokuro", "posicion": Vector3(18, 0, 0)}],
			"jizo": Vector3(-19, 0, -5),
		},
		{
			"id": "hoshiyama", "capitulo": 4, "titulo": "Capítulo 4 · El regreso",
			"nombre": "El castillo de Hoshiyama", "mundo": "castillo",
			"ambiente": {"cielo_arriba": Color("12040a"), "cielo_horizonte": Color("4a1430"), "cielo_suelo": Color("0a0206"),
				"tinte_luna": LUNA_ROJA, "luz_luna": Color("e0b4bc"), "energia_luna": 0.9,
				"niebla": Color("1e0a14"), "ambiente": Color("201420"), "energia_ambiente": 2.3},
			"intro": [
				"El castillo de Hoshiyama. Todo empezó aquí, la noche en que cayó el shōgun Takeda.",
				"Una sombra con la cara de Akira le cierra el paso: algo en el castillo ha aprendido a copiarlo.",
				"Al pie del torreón, el general Genzo desenvaina. Todavía cree que salvó Japón.",
			],
			"titulo_cierre": "Fin", "cierre": [
				"La zorra de nueve colas se deshace en fuego violeta sobre el torreón. Genzo, herido, mira lo que ayudó a liberar.",
				"La historia termina donde empezó: en Hoshiyama, bajo la luna. Pero la barrera sigue rota, y alguien tendrá que rehacerla.",
				"Akira envaina. Fuera ha hecho justicia. Dentro, por primera vez desde aquella noche, siente algo parecido al honor.",
			],
			"inicio": Datos.INICIO_AKIRA, "salida_x": INF, "salida_ancho": 0.0,
			"patrullas": [[Vector3(-14, 0, -4), Vector3(-14, 0, 6)], [Vector3(-2, 0, 4), Vector3(6, 0, 10)]],
			"yokai": [
				["doppelganger", Vector3(-6, 0, 0)], ["ogro", Vector3(4, 0, -8)], ["hombre_lobo", Vector3(6, 0, 9)],
			],
			"jefes": [
				{"tipo": "genzo", "posicion": Vector3(14, 0, -4)},
				{"tipo": "tamamo", "posicion": Vector3(14, 0, -4),
					"mensaje": "Genzo cae de rodillas. La consejera de la corte se quita la máscara: ¡es Tamamo-no-Mae!"},
				{"tipo": "tamamo_zorro", "posicion": Vector3(14, 0, -4),
					"mensaje": "Tamamo-no-Mae muestra su forma verdadera: la zorra de nueve colas"},
			],
			"jizo": Datos.JIZO_POSICION,
		},
	]
