"""Criaturas que NO están en el catálogo del usuario y se añaden al bestiario de RONIN.

Cuatro grupos (ids a partir de 2001 para no chocar con los 1–1000 del catálogo):
  · 2001–2099  Huestes celestiales (ángeles): los nueve coros de la tradición cristiana más
               algunas variantes. Sensibilidad 1: son figuras de religiones vivas.
  · 2101–2199  Infierno: los 72 del *Ars Goetia* (grimorio del siglo XVII, dominio público) y
               unos demonios comunes. El rango del grimorio (rey, príncipe, duque…) es una escala
               natural de fuerza.
  · 2301–2399  Japón: los yōkai que el capítulo 1 y 2 necesitan y el catálogo no trae.
  · 2401–2499  Aliados y guardianes budistas: NO enemigos (sensibilidad 2). Sirven de PNJ.

Uso:  python3 criaturas_extra.py <salida.json>
"""
import json
import sys

CAMPOS = ["id", "nombre", "cultura", "tipo_entrada", "familia", "tamano", "rol", "elemento", "bioma",
          "modelado", "base_de", "sensibilidad", "prompt_en", "nota"]

LISTA = []


def e(id_, nombre, cultura, tipo, familia, tamano, rol, elemento, bioma, modelado, base_de,
      sensibilidad, prompt, nota=""):
    LISTA.append(dict(zip(CAMPOS, [id_, nombre, cultura, tipo, familia, tamano, rol, elemento, bioma,
                                   modelado, base_de, sensibilidad, prompt, nota])))


# ---------------------------------------------------------------------------------------------
# Huestes celestiales (ángeles). Sin nombres de arcángeles: se usan los coros, no las personas.
# ---------------------------------------------------------------------------------------------
H = "Huestes celestiales"
e(2001, "Serafín", H, "criatura", "alado", "L", "distancia", "fuego", "cielo", "propio", "", 1,
  "tall six-winged being of white-gold flame, two wings covering its blank face, two covering its feet, two spread open, body wrapped in burning light",
  "Sus llamas se leen como aviso largo; el iai las parte")
e(2002, "Querubín", H, "criatura", "alado", "L", "poderoso", "luz", "ruinas", "propio", "", 1,
  "winged guardian with four faces around one head, man, lion, ox and eagle, four feathered wings with eyes under them, bronze calf hooves, flaming sword",
  "Cuatro caras, cuatro avisos distintos")
e(2003, "Trono", H, "criatura", "flotante", "L", "gigante", "luz", "cielo", "propio", "", 1,
  "enormous golden wheels nested inside one another, rims covered in countless open eyes, hovering in silence with a faint hum of light",
  "Puntos débiles: los ojos de la rueda exterior")
e(2004, "Dominación", H, "criatura", "bipedo", "L", "apoyo", "luz", "ruinas", "variante", "", 1,
  "tall veiled warden in white and gold robes with a tall crown and a long scepter topped by a glowing orb, hovering slightly above the ground",
  "Protege a otros con un escudo de luz que hay que romper")
e(2005, "Virtud", H, "criatura", "bipedo", "M", "apoyo", "luz", "llanura", "variante", "", 1,
  "radiant armored saint with a breastplate engraved with stars, wings of pale light, open hands and a halo of rotating rings",
  "Cura a los demás; objetivo prioritario")
e(2006, "Potestad", H, "criatura", "bipedo", "L", "poderoso", "ninguno", "ruinas", "variante", "", 1,
  "heavy plate-armored celestial warrior with chained gauntlets, a helm with a glowing white slit, and a great shield engraved with a sun",
  "Golpes de escudo que no se pueden parar")
e(2007, "Principado", H, "criatura", "bipedo", "L", "distancia", "viento", "cielo", "variante", "", 1,
  "crowned celestial in layered robes holding a banner, standing on a floating platform of cloud, bow made of light",
  "Dispara flechas de luz desde una nube")
e(2008, "Arcángel de la espada llameante", H, "criatura", "bipedo", "L", "poderoso", "fuego", "ruinas", "propio", "", 1,
  "winged commander in gold armor wielding a sword wreathed in flame, cloak of feathers, face hidden behind a mask of light",
  "Jefe: cada tajo deja el suelo ardiendo")
e(2009, "Ángel soldado", H, "criatura", "alado", "M", "veloz", "luz", "cielo", "variante", "", 1,
  "slender winged soldier in a white tunic and silver breastplate, feathered wings, spear of light, hovering above the ground",
  "Embiste en picado")
e(2010, "Heraldo de la trompeta", H, "criatura", "alado", "M", "distancia", "viento", "cielo", "variante", "", 1,
  "winged herald carrying a long golden trumpet, wind-swept robes, eyes closed, light rippling out of the bell",
  "Su toque hace vibrar la pantalla")
e(2011, "Guardián de la puerta", H, "criatura", "bipedo", "L", "poderoso", "fuego", "ruinas", "reskin",
  "Arcángel de la espada llameante", 1,
  "gatekeeper celestial with a revolving blade of flame, burnt gold armor, standing in a ruined archway",
  "Barre en círculo; hay que saltarlo")
e(2012, "Juez de la balanza", H, "criatura", "bipedo", "L", "engano", "luz", "ruinas", "variante", "", 1,
  "blindfolded celestial judge in white robes holding a giant golden scale, wings folded, chains floating around him",
  "Copia el golpe de Akira (duelo espejo)")
e(2013, "Ángel caído de ceniza", H, "criatura", "alado", "M", "veloz", "fuego", "ruinas", "reskin", "Ángel soldado", 1,
  "fallen angel with wings burnt to blackened bone and ash, charred armor, glowing ember cracks across the body",
  "")
e(2014, "Ángel caído de hielo", H, "criatura", "alado", "M", "distancia", "hielo", "nieve", "reskin", "Ángel soldado", 1,
  "frost-covered fallen angel with wings of ice shards, pale blue armor, frozen tears on a silent face",
  "")
e(2015, "Ángel caído de sombra", H, "criatura", "alado", "M", "emboscador", "sombra", "ruinas", "reskin", "Ángel soldado", 1,
  "black-feathered fallen angel half dissolved into shadow mist, silver armor stained dark, white eyes",
  "")
e(2016, "Centinela de luz", H, "criatura", "bipedo", "M", "poderoso", "luz", "ruinas", "variante", "", 1,
  "armored sentinel construct of white stone and gold, hollow helmet filled with light, folded wings of metal plates",
  "Autómata celestial: no es un ángel, es su herramienta")
e(2017, "Coro de ecos", H, "criatura", "flotante", "S", "enjambre", "luz", "cielo", "variante", "", 1,
  "swarm of small floating winged orbs with faceless white masks, glowing softly and humming in chorus",
  "Cada uno canta una nota; el corte de luna los silencia")

# ---------------------------------------------------------------------------------------------
# Infierno. Los 72 del Ars Goetia (dominio público). El rango sirve de escala de fuerza:
# Caballero < Presidente < Conde < Marqués < Duque < Príncipe < Rey.
# ---------------------------------------------------------------------------------------------
G = "Grimorios e infierno"
GOETIA = [
    # (n, nombre, rango, familia, tamano, rol, elemento, bioma, modelado, base_de, prompt)
    (1, "Bael", "Rey", "artropodo", "L", "poderoso", "sombra", "ruinas", "propio", "",
     "demon king with three heads, a toad, a crowned human and a cat, on a swollen spider-like body with long thin legs"),
    (2, "Agares", "Duque", "cuadrupedo", "L", "engano", "tierra", "pantano", "variante", "",
     "old man in ragged noble robes riding a large crocodile, a goshawk perched on his gloved fist"),
    (3, "Vassago", "Príncipe", "bipedo", "M", "apoyo", "sombra", "ruinas", "variante", "",
     "gaunt prince in dark robes holding a crystal ball, eyes of pale light, long thin fingers"),
    (4, "Samigina", "Marqués", "cuadrupedo", "S", "engano", "sombra", "ciudad_hogar", "variante", "",
     "small wild donkey-like horse with glassy black eyes, melting into a hooded human figure"),
    (5, "Marbas", "Presidente", "cuadrupedo", "L", "poderoso", "ninguno", "montana", "variante", "",
     "great lion with a mane of dark smoke whose face half changes into a bearded man"),
    (6, "Valefor", "Duque", "cuadrupedo", "L", "emboscador", "sombra", "ciudad_hogar", "variante", "",
     "sleek black lion with the head of a donkey, mouth open braying, crouching like a thief"),
    (7, "Amon", "Marqués", "cuadrupedo", "L", "distancia", "fuego", "ruinas", "propio", "",
     "wolf with a serpent tail vomiting flames, a raven-headed humanoid torso rising from its back, dog teeth"),
    (8, "Barbatos", "Duque", "bipedo", "M", "distancia", "ninguno", "bosque", "variante", "",
     "hunter demon in forest green leathers with a long horn and bow, pale knights following behind him"),
    (9, "Paimon", "Rey", "cuadrupedo", "L", "apoyo", "viento", "desierto", "propio", "",
     "crowned king with a youthful face riding a dromedary, red robes, trumpets and cymbals sounding around him"),
    (10, "Buer", "Presidente", "cuadrupedo", "M", "veloz", "ninguno", "montana", "propio", "",
     "star-shaped body, a lion's head with five goat legs radiating around it like the spokes of a wheel"),
    (11, "Gusion", "Duque", "bipedo", "M", "engano", "ninguno", "desierto", "variante", "",
     "baboon-faced duke in a patchwork cloak of many colors, mirror-bright eyes, very long arms and a hunched back"),
    (12, "Sitri", "Príncipe", "alado", "M", "engano", "fuego", "ruinas", "variante", "",
     "leopard-headed demon with griffin wings and a lean humanoid body wearing noble furs"),
    (13, "Beleth", "Rey", "cuadrupedo", "L", "poderoso", "sombra", "ruinas", "variante", "",
     "gaunt furious king riding a pale horse, trumpets and strange music around him, burning red eyes"),
    (14, "Leraje", "Marqués", "bipedo", "M", "distancia", "veneno", "bosque", "variante", "",
     "archer clad in green with a bow and a quiver, face in shadow, arrows dripping venom"),
    (15, "Eligos", "Duque", "bipedo", "M", "poderoso", "ninguno", "llanura", "variante", "",
     "dark plate-armored knight with a long lance and a banner shaped like a serpent"),
    (16, "Zepar", "Duque", "bipedo", "M", "engano", "sangre", "ciudad_hogar", "variante", "",
     "red-clad soldier with sleek black hair and a smiling porcelain mask, crimson cloak and a short curved sword"),
    (17, "Botis", "Presidente", "bipedo", "M", "emboscador", "veneno", "subsuelo", "variante", "",
     "viper-headed horned demon with great fangs, a sharp sword and long coiling tail"),
    (18, "Bathin", "Duque", "cuadrupedo", "L", "veloz", "sombra", "llanura", "variante", "",
     "strong man with a serpent's tail riding a pale horse, ragged cloak"),
    (19, "Sallos", "Duque", "cuadrupedo", "L", "engano", "tierra", "pantano", "reskin", "Agares",
     "gallant soldier with a ducal crown riding a large crocodile, polished armor, a plume on his helmet"),
    (20, "Purson", "Rey", "cuadrupedo", "L", "apoyo", "ninguno", "bosque", "variante", "",
     "lion-faced crowned man holding a viper, riding a bear, trumpets sounding before him"),
    (21, "Marax", "Conde", "cuadrupedo", "L", "poderoso", "tierra", "llanura", "variante", "",
     "huge bull with a bearded human face, very wide shoulders, rock-hard hide and heavy cracked hooves"),
    (22, "Ipos", "Conde", "bipedo", "M", "veloz", "ninguno", "bosque", "propio", "",
     "angelic torso with a lion's head, goose feet and a hare's tail"),
    (23, "Aim", "Duque", "serpentino", "L", "poderoso", "fuego", "ciudad_hogar", "propio", "",
     "handsome three-headed duke, a serpent, a man with two stars on his brow and a calf, riding a giant viper with a burning brand"),
    (24, "Naberius", "Marqués", "alado", "S", "veloz", "sombra", "cielo", "variante", "",
     "black crane flying in tight circles, hoarse cry, eyes of yellow glass"),
    (25, "Glasya-Labolas", "Presidente", "alado", "M", "veloz", "sangre", "ruinas", "variante", "",
     "large black dog with the feathered wings of a griffin, a stained muzzle, long ears and red eyes"),
    (26, "Bune", "Duque", "serpentino", "L", "poderoso", "tierra", "subsuelo", "propio", "",
     "dragon with three heads, a dog, a griffin and a man, green scales and a long thick tail"),
    (27, "Ronove", "Marqués", "bipedo", "M", "apoyo", "sombra", "ruinas", "variante", "",
     "stooped scholar-like monstrous figure with very long arms and an ivory mask, carrying scrolls"),
    (28, "Berith", "Duque", "cuadrupedo", "M", "poderoso", "fuego", "llanura", "variante", "",
     "red-clad soldier crowned with gold riding a red horse, flaming eyes, gilded sword"),
    (29, "Astaroth", "Duque", "alado", "L", "distancia", "sombra", "ruinas", "propio", "",
     "winged fallen noble with a tired face riding an infernal dragon, a viper in his right hand, tattered cloak"),
    (30, "Forneus", "Marqués", "acuatico", "L", "emboscador", "agua", "mar", "variante", "",
     "great sea monster with a fan of tentacles, sharp teeth and a long spiny back"),
    (31, "Foras", "Presidente", "bipedo", "M", "apoyo", "tierra", "bosque", "variante", "",
     "strong sage-demon with a staff of living roots, robes patterned with leaves"),
    (32, "Asmoday", "Rey", "bipedo", "L", "poderoso", "fuego", "ciudad_hogar", "propio", "",
     "three-headed king with a bull, a man and a ram head, serpent tail and goose feet, breathing fire, riding an infernal dragon with a lance"),
    (33, "Gaap", "Presidente", "bipedo", "L", "engano", "sombra", "ruinas", "variante", "",
     "tall demon prince with ember eyes surrounded by four crowned shadows that move with him"),
    (34, "Furfur", "Conde", "cuadrupedo", "M", "distancia", "rayo", "bosque", "variante", "",
     "tall hart with a flaming tail, antlers crackling with lightning, glowing hooves and a pale coat"),
    (35, "Marchosias", "Marqués", "alado", "L", "distancia", "fuego", "montana", "variante", "",
     "great she-wolf with griffin wings and a serpent tail, vomiting flames, grey fur streaked with soot"),
    (36, "Stolas", "Príncipe", "alado", "M", "apoyo", "viento", "bosque", "variante", "",
     "great owl demon with star-patterned plumage and wise amber eyes, long taloned legs"),
    (37, "Phenex", "Marqués", "alado", "M", "distancia", "fuego", "cielo", "variante", "",
     "phoenix-like bird singing with wings of orange and gold flame, long trailing tail"),
    (38, "Halphas", "Conde", "alado", "S", "distancia", "fuego", "llanura", "variante", "",
     "stork with grey and red plumage carrying a torch in its beak, hoarse voice"),
    (39, "Malphas", "Presidente", "alado", "M", "engano", "sombra", "ruinas", "variante", "",
     "crow-headed noble in black feathers who turns into a man, polished beak, gold ring on one claw"),
    (40, "Raum", "Conde", "alado", "S", "emboscador", "sombra", "ciudad_hogar", "reskin", "Malphas",
     "large crow with glinting eyes carrying a golden ring in its beak, ash-grey wings and sharp talons"),
    (41, "Focalor", "Duque", "alado", "M", "emboscador", "agua", "mar", "variante", "",
     "man with griffin wings and wet black hair wearing a cloak of drowning water"),
    (42, "Vepar", "Duque", "acuatico", "M", "distancia", "agua", "mar", "variante", "",
     "sea demon with a fish tail and scale armor carrying a trident, sharp fins on its arms"),
    (43, "Sabnock", "Marqués", "cuadrupedo", "L", "poderoso", "tierra", "ruinas", "variante", "",
     "armed soldier with the head of a lion riding a pale horse, building a stone fortress behind him"),
    (44, "Shax", "Marqués", "alado", "S", "engano", "ninguno", "llanura", "reskin", "Halphas",
     "tall stork with a hoarse voice and blind-looking pale eyes, dusty white plumage and a long red beak"),
    (45, "Vine", "Rey", "cuadrupedo", "L", "distancia", "fuego", "ruinas", "variante", "",
     "lion riding a black horse and holding a viper, fortress-builder, storm clouds behind"),
    (46, "Bifrons", "Conde", "bipedo", "M", "engano", "fuego", "ruinas", "variante", "",
     "charred monster that lights candles on graves, skin like cracked coal, long arms"),
    (47, "Vual", "Duque", "cuadrupedo", "L", "apoyo", "tierra", "desierto", "variante", "",
     "great dromedary-shaped demon with a long neck, ember eyes and sand blowing off its hide"),
    (48, "Haagenti", "Presidente", "alado", "L", "poderoso", "tierra", "montana", "reskin", "Zagan",
     "golden-hided bull with large griffin wings, polished curved horns, glowing nostrils and heavy hooves"),
    (49, "Crocell", "Duque", "bipedo", "M", "distancia", "agua", "rio_lago", "variante", "",
     "angelic duke surrounded by steaming water, sad pale eyes, wet drooping feathers and a robe of mist"),
    (50, "Furcas", "Caballero", "cuadrupedo", "M", "poderoso", "hielo", "nieve", "variante", "",
     "cruel old man with a long white beard riding a pale horse, ice-sharp spear"),
    (51, "Balam", "Rey", "cuadrupedo", "L", "poderoso", "fuego", "bosque", "variante", "",
     "three-headed king with a bull, a man and a ram head, serpent tail and flaming eyes, riding a bear with a hawk on his fist"),
    (52, "Alloces", "Duque", "cuadrupedo", "L", "poderoso", "fuego", "llanura", "variante", "",
     "soldier with a red lion's face and flaming eyes riding a great horse"),
    (53, "Caim", "Presidente", "alado", "M", "engano", "sombra", "bosque", "variante", "",
     "thrush-headed man in dark armor with a sharp sword, many animal voices"),
    (54, "Murmur", "Duque", "alado", "L", "distancia", "sombra", "cielo", "variante", "",
     "soldier crowned with a ducal crown riding a griffin, two trumpeters beside him"),
    (55, "Orobas", "Príncipe", "cuadrupedo", "L", "apoyo", "luz", "llanura", "variante", "",
     "horse-shaped demon with eyes of fire that turns into a calm prophet"),
    (56, "Gremory", "Duque", "cuadrupedo", "M", "engano", "ninguno", "desierto", "variante", "",
     "veiled noblewoman with a ducal crown around her waist riding a camel, silk scarves, mysterious smile"),
    (57, "Ose", "Presidente", "cuadrupedo", "M", "engano", "ninguno", "selva", "variante", "",
     "leopard-bodied demon with unsettling human eyes, a spotted coat whose pattern keeps shifting and a long tail"),
    (58, "Amy", "Presidente", "flotante", "M", "distancia", "fuego", "ruinas", "variante", "",
     "flaming spirit that takes the shape of a scholar made of fire, spiral sparks"),
    (59, "Orias", "Marqués", "cuadrupedo", "L", "poderoso", "veneno", "montana", "variante", "",
     "lion riding a horse with a serpent tail, holding two hissing serpents"),
    (60, "Vapula", "Duque", "alado", "L", "veloz", "ninguno", "montana", "reskin", "Zagan",
     "lion with griffin wings and a craftsman's belt of tools, lean and fast"),
    (61, "Zagan", "Rey", "alado", "L", "poderoso", "fuego", "montana", "propio", "",
     "bull with griffin wings, ember-red hide, golden horns, turning into a man in the end"),
    (62, "Valac", "Presidente", "alado", "S", "distancia", "veneno", "pantano", "variante", "",
     "small winged masked figure riding a two-headed dragon, snakes around its arms"),
    (63, "Andras", "Marqués", "cuadrupedo", "M", "emboscador", "sombra", "bosque", "variante", "",
     "angelic figure with a raven head riding a black wolf, wielding a sharp sword"),
    (64, "Flauros", "Duque", "cuadrupedo", "L", "poderoso", "fuego", "subsuelo", "variante", "",
     "terrible leopard with eyes of flame, fur like glowing embers, smoking claws and a snarling mouth"),
    (65, "Andrealphus", "Marqués", "alado", "M", "engano", "viento", "cielo", "variante", "",
     "peacock demon with a tail fan of a thousand eyes, geometric patterned wings"),
    (66, "Kimaris", "Marqués", "cuadrupedo", "L", "veloz", "sombra", "llanura", "variante", "",
     "strong warrior in black armor on a black horse, red plume, visor down"),
    (67, "Amdusias", "Duque", "cuadrupedo", "M", "distancia", "viento", "bosque", "variante", "",
     "unicorn-shaped demon whose spiral horn sounds like music, storm winds and pale lightning following behind"),
    (68, "Belial", "Rey", "bipedo", "L", "apoyo", "fuego", "ruinas", "propio", "",
     "two pale seated angels in a chariot of fire, honeyed voices, burning wheels"),
    (69, "Decarabia", "Marqués", "flotante", "S", "distancia", "luz", "ruinas", "variante", "",
     "star shining inside a drawn pentacle that takes the shape of a bird"),
    (70, "Seere", "Príncipe", "cuadrupedo", "M", "veloz", "viento", "llanura", "variante", "",
     "handsome rider on a winged horse, quick and swift, cloak of wind"),
    (71, "Dantalion", "Duque", "bipedo", "M", "engano", "sombra", "ciudad_hogar", "propio", "",
     "man with many faces, both men and women, holding a book, robes stitched with masks"),
    (72, "Andromalius", "Conde", "bipedo", "M", "engano", "veneno", "ruinas", "variante", "",
     "stern hooded man holding a great serpent coiled around his arm, scales on his forearms, dark robes"),
]
for n, nombre, rango, fam, tam, rol, elem, bioma, mod, base, prompt in GOETIA:
    e(2100 + n, nombre, G, "criatura", fam, tam, rol, elem, bioma, mod, base, 0, prompt,
      f"Rango del grimorio: {rango.lower()}")

# Demonios comunes (sin nombre propio)
e(2181, "Diablillo", G, "criatura", "alado", "S", "enjambre", "fuego", "subsuelo", "variante", "", 0,
  "small red horned imp with bat wings, a pointed tail like a pitchfork and a mischievous grin",
  "Enjambre de 6; el corte de luna los barre")
e(2182, "Verdugo infernal", G, "criatura", "bipedo", "L", "poderoso", "fuego", "subsuelo", "variante", "", 0,
  "hulking executioner demon with an iron mask, a huge cleaver, chains and burning coals in its belly",
  "Golpe cargado imposible de parar")
e(2183, "Condenado en llamas", G, "criatura", "bipedo", "M", "enjambre", "fuego", "subsuelo", "variante", "", 0,
  "burning damned soul in tattered rags, flames pouring from its eyes, chained wrists",
  "Camina lento hacia Akira, prendiéndole fuego")
e(2184, "Gárgola infernal", G, "criatura", "alado", "M", "emboscador", "tierra", "ruinas", "variante", "", 0,
  "stone gargoyle with ember-red cracks and bat wings, crouched on a ledge with clawed hands",
  "Inmóvil como una estatua hasta que Akira pasa")
e(2185, "Jinete del abismo", G, "criatura", "cuadrupedo", "L", "veloz", "sombra", "llanura", "variante", "", 0,
  "skeletal knight on a black horse with a burning mane, tattered banner",
  "Carga en línea recta; se esquiva de lado")
e(2186, "Heraldo infernal", G, "criatura", "alado", "M", "apoyo", "fuego", "ruinas", "variante", "", 0,
  "winged demon blowing a bone horn, torn banner on its back, soot-black wings",
  "Llama refuerzos con el cuerno")
e(2187, "Príncipe de la ceniza", G, "criatura", "bipedo", "L", "poderoso", "fuego", "ruinas", "propio", "", 0,
  "ash-grey demon prince in cracked obsidian armor with a crown of embers and a long cloak of smoke",
  "Jefe: cada fase pierde una pieza de armadura")
e(2188, "Cuervo de brasas", G, "criatura", "alado", "S", "enjambre", "fuego", "cielo", "variante", "", 0,
  "crow made of glowing embers with bright eyes, trailing sparks behind its wings",
  "Se deshace en chispas al morir")

# ---------------------------------------------------------------------------------------------
# Japón: lo que el capítulo 1 y el 2 necesitan y el catálogo no trae.
# ---------------------------------------------------------------------------------------------
J = "Japón"
e(2301, "Onibi", J, "criatura", "flotante", "S", "enjambre", "fuego", "ciudad_hogar", "variante", "", 0,
  "seven floating ghostly fireballs of pale blue and violet flame with hollow anguished faces and trailing flame tails",
  "Capítulo 1. Enjambre de 5-8; cada uno llena la barra de espíritu")
e(2302, "Hitodama", J, "criatura", "flotante", "S", "enjambre", "fuego", "ruinas", "reskin", "Onibi", 0,
  "pale green soul-flames the size of a fist with tiny ghostly eyes, drifting in slow loops",
  "Más lentos que los onibi pero hacen estallar un gas frío")
e(2303, "Kodama", J, "criatura", "flotante", "S", "apoyo", "ninguno", "bosque", "variante", "", 0,
  "tiny white tree spirits with round blank faces and faintly glowing bodies, sitting on mossy branches",
  "No atacan; guían por el Kakuriyo")
e(2304, "Karasu-tengu", J, "criatura", "alado", "M", "veloz", "viento", "montana", "variante", "", 0,
  "crow-faced mountain warrior in a yamabushi robe with black wings and a short katana, geta sandals",
  "Duelista rápido; baja en picado")
e(2305, "Sōjōbō", J, "criatura", "bipedo", "L", "poderoso", "viento", "montana", "propio", "", 0,
  "king of the tengu, tall red-faced long-nosed master in white and gold robes with a feather fan and great black wings",
  "Jefe del capítulo 2: duelo de iaidō puro; al vencerle enseña una técnica")
e(2306, "Tsuchigumo", J, "criatura", "artropodo", "XL", "gigante", "veneno", "subsuelo", "propio", "", 0,
  "colossal earth spider with a pale human-like face on its abdomen, banded legs and a nest of webs in a cave",
  "Jefe intermedio de las ruinas")
e(2307, "Nue", J, "criatura", "cuadrupedo", "L", "engano", "rayo", "montana", "propio", "", 0,
  "chimera with the face of a monkey, the body of a tanuki, tiger legs and a snake for a tail, trailing black storm clouds",
  "Cada parte ataca distinto; llega con nubes negras")
e(2308, "Kasha", J, "criatura", "cuadrupedo", "L", "poderoso", "fuego", "ciudad_hogar", "variante", "", 0,
  "huge two-tailed cat demon wreathed in flames, burning wheel-like rings around its legs, snatching at corpses",
  "Rueda de fuego; deja el suelo ardiendo")
e(2309, "Raijū", J, "criatura", "cuadrupedo", "M", "veloz", "rayo", "montana", "variante", "", 0,
  "beast of thunder, a lean weasel-wolf wrapped in crackling lightning with trailing mane of sparks",
  "Carga en zigzag; el destello es el aviso")
e(2310, "Yamata no Orochi", J, "criatura", "serpentino", "XL", "gigante", "agua", "rio_lago", "propio", "", 0,
  "eight-headed eight-tailed giant serpent with red glowing eyes and moss growing on its back, coiled over eight valleys",
  "Jefe: ocho cabezas, ocho puntos débiles")
e(2311, "Gaki", J, "criatura", "bipedo", "S", "enjambre", "sombra", "ruinas", "variante", "", 0,
  "hungry ghost with a swollen belly, thin limbs and a gaping mouth, grey wasted skin",
  "Hordas lentas que se agarran")
e(2312, "Ōkuri-inu", J, "criatura", "cuadrupedo", "M", "veloz", "sombra", "bosque", "variante", "", 0,
  "pack wolf with grey fur and pale eyes that follows travellers in the dark, ghostly breath",
  "Rodea sin atacar; si Akira cae, atacan todos")
e(2313, "Daidarabotchi", J, "criatura", "bipedo", "XL", "gigante", "tierra", "montana", "propio", "", 0,
  "mountain-sized giant covered in moss and trees, forest on his shoulders, small kind eyes",
  "Jefe-escenario: se sube por la espalda")
e(2314, "Hannya", J, "criatura", "bipedo", "M", "engano", "fuego", "ciudad_hogar", "variante", "", 0,
  "demon woman with long curved horns, a pale fanged face like a noh theatre mask, flowing white and red robes",
  "Cambia de rostro entre dolor y furia")
e(2315, "Aka-oni", J, "criatura", "bipedo", "M", "poderoso", "fuego", "montana", "variante", "", 0,
  "hulking red oni with two short ivory horns, wild black hair, tiger-skin loincloth and a spiked iron club",
  "Capítulo 1. Barrido que se para y garrotazo que se esquiva")
e(2316, "Ao-oni", J, "criatura", "bipedo", "M", "veloz", "hielo", "montana", "reskin", "Aka-oni", 0,
  "lean blue-skinned oni with a three-pronged iron club, one long horn and cold white eyes",
  "Tres barridos seguidos")
e(2317, "Ki-oni", J, "criatura", "bipedo", "M", "poderoso", "rayo", "montana", "reskin", "Aka-oni", 0,
  "yellow-skinned oni with crackling static in its hair, two horns and a drum slung on its back",
  "Su tambor es el aviso")
e(2318, "Kuro-oni", J, "criatura", "bipedo", "L", "emboscador", "sombra", "bosque", "reskin", "Aka-oni", 0,
  "black-skinned oni half hidden in shadow, red eyes, a broad kanabo club and a ragged cloak",
  "Ataca desde las sombras del patio")
e(2319, "Midori-oni", J, "criatura", "bipedo", "M", "distancia", "veneno", "pantano", "reskin", "Aka-oni", 0,
  "green-skinned oni with mossy horns spitting toxic mist from a gourd, ragged straw coat",
  "Nube tóxica que hay que rodear")
e(2320, "Gozu", J, "criatura", "bipedo", "L", "poderoso", "fuego", "inframundo", "variante", "", 1,
  "ox-headed hell warden in iron armor with a long spiked staff and heavy chains",
  "Guardián del infierno budista; con cuidado")
e(2321, "Mezu", J, "criatura", "bipedo", "L", "veloz", "fuego", "inframundo", "reskin", "Gozu", 1,
  "horse-headed hell warden in lighter iron armor with a trident and flowing mane",
  "")
e(2322, "Ushi-oni", J, "criatura", "artropodo", "XL", "gigante", "agua", "mar", "propio", "", 0,
  "giant bull-headed sea demon with a spider-like body, rising from the shore, shell-crusted horns",
  "Jefe marino")
e(2323, "Rasetsu", J, "criatura", "bipedo", "M", "emboscador", "sombra", "ruinas", "variante", "", 1,
  "predatory demon in tattered monk robes with bright claws and fangs, hidden among ruined temple beams",
  "Variante budista del ráksasa")
e(2324, "Ibaraki-dōji", J, "criatura", "bipedo", "L", "poderoso", "fuego", "montana", "propio", "", 0,
  "one-armed oni general with a scarred iron mask, torn armor and a broken sword, loyal lieutenant of a demon king",
  "Jefe: busca su brazo perdido")
e(2325, "Hashihime", J, "criatura", "flotante", "M", "engano", "agua", "ciudad_hogar", "variante", "", 0,
  "pale bridge-keeper woman in a white robe with an iron crown holding five candles, red lips and black hair floating",
  "Aparece en puentes")
e(2326, "Oni gigante del portón", J, "criatura", "bipedo", "XL", "gigante", "fuego", "ciudad_hogar", "propio", "Aka-oni", 0,
  "colossal oni as tall as a castle gate with three curved horns, ember-red cracked skin, thick straw rope belt and broken shackles",
  "Jefe del capítulo 1: se cortan los brazos")
e(2327, "Tamamo-no-Mae", J, "criatura", "bipedo", "L", "engano", "fuego", "ruinas", "propio", "", 0,
  "nine-tailed fox sorceress in black and red court robes with a white fox mask, nine violet foxfire tails and a halo like a pale moon",
  "El gran yōkai (DECISIÓN 9A): ilusiones, fuego fatuo y posesión")

# ---------------------------------------------------------------------------------------------
# Aliados y guardianes budistas: NO son enemigos (sensibilidad 2); sirven de PNJ y de lore.
# ---------------------------------------------------------------------------------------------
for n, nombre, prompt, nota in [
    (1, "Niō (guardián abierto)", "muscular temple guardian statue come alive, mouth open, fist raised, flowing scarf and stone skin",
     "Prueba al jugador en el templo"),
    (2, "Niō (guardián cerrado)", "muscular temple guardian statue come alive, mouth closed, holding a vajra, flowing scarf and stone skin",
     "Pareja del anterior"),
    (3, "Jikokuten (Rey del Este)", "armored heavenly king of the east in Buddhist temple art, holding a sword, stern face, layered armor and swirling scarves",
     "Guardián del este del kekkai"),
    (4, "Zōchōten (Rey del Sur)", "armored heavenly king of the south holding a spear, fierce face, layered armor",
     "Guardián del sur del kekkai"),
    (5, "Kōmokuten (Rey del Oeste)", "armored heavenly king of the west holding a brush and scroll, wide watchful eyes",
     "Guardián del oeste del kekkai"),
    (6, "Bishamonten (Rey del Norte)", "armored heavenly king of the north holding a pagoda and a spear, golden armor, flames behind his back",
     "Guardián del norte del kekkai"),
    (7, "Fudō Myōō", "wrathful wisdom king with a blue-black skin, a sword and a rope, seated before a halo of flames",
     "Maestro del dojo: enseña la técnica de la llama"),
    (8, "Tennin (doncella celeste)", "celestial maiden in flowing feather-light robes and scarves, hovering, serene closed eyes",
     "Aliada en el Kakuriyo"),
]:
    e(2400 + n, nombre, J, "deidad", "bipedo" if n != 8 else "flotante", "L" if n != 8 else "M", "apoyo", "luz",
      "ruinas", "variante", "", 2, prompt, "NO enemigo. " + nota)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(1)
    json.dump(LISTA, open(sys.argv[1], "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    por_grupo = {}
    for c in LISTA:
        por_grupo[c["cultura"]] = por_grupo.get(c["cultura"], 0) + 1
    print(f"{len(LISTA)} criaturas extra en {sys.argv[1]}:", por_grupo)
