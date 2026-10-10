"""Lista de prompts para generar las láminas en Colab (la usa generar_laminas.ipynb).

Cada entrada: (id, categoria, prompt). Se generan SEMILLAS imágenes por prompt.
Los estilos son libres a propósito: cada lámina puede ser única.
"""

FINAL = (", black and white coloring book page for adults, clean bold black outlines, pure white background, "
         "line art only, no shading, no gray, no color, no gradients, closed shapes, centered composition, highly detailed")

ESTILOS = {
    "tatuaje": "{s}, tattoo design sketch, elegant fine linework, flowing ornamental swirls",
    "etnico": "{s}, ethnic zentangle style, the body filled with tribal ornaments and patterns, symmetrical, intricate",
    "realista": "{s}, realistic detailed illustration with a background of mountains and pine trees",
    "mandala": "{s} merged with mandala patterns, intricate ornamental details",
    "geometrico": "{s}, geometric tattoo, sacred geometry lines and circles around it",
    "nouveau": "{s}, art nouveau style, decorative frame with flowers and curves",
    "botanico": "{s}, vintage botanical illustration, detailed engraving style lines",
    "grabado": "{s}, vintage engraving style illustration, detailed",
    "steampunk": "{s}, steampunk style with gears and ornate details",
    "paisaje": "{s}, detailed landscape illustration",
}

ANIMALES = ["lion head", "tiger head", "wolf head", "fox", "bear", "panda", "koala", "monkey", "gorilla", "elephant",
            "giraffe", "zebra", "horse head", "deer with antlers", "ram with curled horns", "bull head", "rhinoceros",
            "hippopotamus", "cheetah", "leopard", "jaguar", "lynx", "cat", "sleeping cat", "dog", "german shepherd", "husky",
            "rabbit", "hare", "squirrel", "raccoon", "hedgehog", "otter", "red panda", "sloth", "kangaroo", "camel",
            "llama", "alpaca", "bison", "moose", "boar", "goat", "sheep", "cow", "pig", "chameleon", "iguana", "crocodile",
            "snake coiled", "cobra", "turtle", "frog", "gecko", "bat", "mouse", "badger", "armadillo", "anteater", "capybara"]
AVES = ["eagle head", "owl", "barn owl", "hummingbird", "peacock", "parrot", "toucan", "flamingo", "swan", "crane bird",
        "raven", "hawk", "falcon", "rooster", "hen with chicks", "penguin", "pelican", "kingfisher", "phoenix-like bird of paradise", "swallow birds"]
OCEANO = ["koi fish", "whale", "humpback whale", "dolphin", "octopus", "jellyfish", "sea turtle", "seahorse", "shark", "manta ray",
          "starfish and shells", "crab", "lobster", "clownfish in coral", "pufferfish", "angelfish", "orca", "narwhal", "nautilus shell", "coral reef"]
INSECTOS = ["butterfly", "moth", "dragonfly", "beetle", "honeybee", "ladybug", "praying mantis", "scorpion", "spider on web",
            "grasshopper", "snail", "caterpillar on leaf", "firefly", "stag beetle", "bumblebee on flower"]
FANTASIA = ["dragon", "chinese dragon", "phoenix", "unicorn", "pegasus", "griffin", "mermaid tail and shells", "kitsune nine tailed fox",
            "fairy house in a mushroom", "wizard castle", "treasure chest", "magic potion bottles", "crystal ball", "enchanted forest",
            "kraken", "hydra", "sea serpent", "centaur", "cerberus", "thunderbird", "fantasy owl with crown", "moon goddess cat",
            "floating island", "steampunk airship", "fairy wings", "dragon egg", "magic book", "fantasy sword", "witch hat and moon", "baby dragon"]
FLORES = ["rose", "lotus", "sunflower", "peony", "orchid", "lily", "tulips", "daisy bouquet", "cherry blossom branch", "hibiscus",
          "magnolia", "poppy", "lavender", "chrysanthemum", "dahlia", "iris flower", "camellia", "succulent plants", "cactus in pot", "fern leaves",
          "monstera leaves", "bonsai tree", "tree of life", "oak tree", "willow tree", "wreath of flowers", "flower vase", "mushrooms", "wildflowers", "water lily"]
COMIDA = ["apple", "pear", "strawberries", "cherries", "grapes", "orange slices", "lemon branch", "pineapple", "watermelon slice", "mango",
          "avocado", "pomegranate", "coconut", "banana bunch", "blueberries", "fig", "kiwi slices", "peach", "fruit basket", "cupcakes",
          "layered cake", "ice cream cones", "donuts", "coffee cup with steam", "teapot and cups", "macarons", "chocolate box", "pizza", "sushi set", "bread basket"]
OBJETOS = ["vintage pocket watch", "old key", "lantern", "teapot", "hot air balloon", "vintage camera", "gramophone", "typewriter", "compass",
           "hourglass", "antique clock", "violin", "guitar", "piano", "saxophone", "drum", "music box", "chandelier", "candle holder",
           "old books stack", "globe", "telescope", "anchor", "ship wheel", "dreamcatcher", "perfume bottles", "jewelry box", "crown", "masquerade mask",
           "fan with patterns", "umbrella", "bicycle", "sewing machine", "birdcage", "kettle", "rocking chair", "lamp", "teacup", "vase with patterns", "chess pieces"]
VEHICULOS = ["vintage car", "classic motorcycle", "steam locomotive", "sailing ship", "pirate ship", "submarine", "biplane", "rocket",
             "vintage truck", "tram", "hot rod car", "vespa scooter", "canoe on a lake", "lighthouse and boat", "gondola", "camper van",
             "fire truck", "tractor", "carriage", "zeppelin"]
LUGARES = ["cabin in the woods", "lighthouse on cliffs", "waterfall in forest", "mountain lake", "japanese temple", "european street with cafes",
           "medieval castle", "windmill in fields", "tropical beach with palm trees", "cottage with garden", "old town houses", "bridge over river",
           "greenhouse with plants", "treehouse", "village in valley", "desert with cactus", "snowy mountains", "rice terraces", "harbor with boats",
           "underwater city", "colonial street with balconies", "victorian house", "gothic cathedral", "pagoda", "farm with barn", "city skyline",
           "library interior", "cozy kitchen interior", "garden with fountain", "market stalls"]
MANDALAS = ["flower", "sun", "moon and stars", "ocean waves", "feathers", "leaves", "hearts", "butterflies", "lotus", "geometric shapes",
            "snowflakes", "fire", "peacock feathers", "seashells", "birds", "cats", "owls", "paisley", "celtic knots", "art deco",
            "fruits", "musical notes", "coffee", "cosmic planets", "roses", "mushrooms", "elephants", "fish", "dragons", "autumn"]

# Animales fantásticos: animales reales con algo imposible (alas, cristales,
# fuego, estrellas, engranajes...). Sustituyen a la comida.
CRIATURAS = [
    "winged lion with feathered wings", "crystal stag with glowing antlers made of quartz", "fox with nine flowing tails and flames",
    "celestial whale swimming among stars and moons", "owl with a crescent moon on its chest and starry wings",
    "wolf howling made of smoke and galaxies", "tiger with butterfly wings", "cat with a cosmic nebula inside its body",
    "turtle carrying a tiny island with a castle on its shell", "koi fish with dragon horns and long whiskers",
    "horse with a mane of ocean waves", "elephant with flowers growing on its back and a waterfall",
    "bear made of forest leaves and mushrooms", "hummingbird with peacock feathers and jewels",
    "rabbit with deer antlers (jackalope) in a flower meadow", "snake with feathered wings (quetzalcoatl)",
    "octopus with tentacles turning into vines and flowers", "raven with clockwork gears and keys",
    "lion with a mane of sun rays", "deer with a forest growing from its antlers",
    "jellyfish shaped like a lantern with tiny houses inside", "butterfly with wings made of stained glass cathedral windows",
    "frog wearing a crown sitting on a giant mushroom", "hedgehog with crystal spikes", "sea turtle with a coral reef city on its shell",
    "dolphin made of water swirls", "griffin perched on a cliff", "baby dragon hatching from an egg among flowers",
    "phoenix rising from flames with long tail feathers", "unicorn with a flowing mane of flowers",
    "pegasus flying over clouds", "kirin (chinese unicorn) with scales and flames", "mermaid cat with a fish tail",
    "flying fish with bird wings over waves", "steampunk mechanical owl", "steampunk mechanical elephant",
    "lion with a crown and royal ornaments", "wolf with tribal moon symbols", "fox spirit with masks and lanterns",
    "tortoise carrying a pagoda", "sloth hanging from a crescent moon", "panda floating with bamboo and lanterns in the sky",
    "seahorse knight with armor", "beetle with a jeweled shell like a brooch", "moth with moon phases on its wings",
    "chameleon wrapped around a magic staff with crystals", "giant snail with a house shell", "bee queen with a crown and honeycomb",
    "squirrel with acorn armor", "hare jumping over the moon", "white tiger with yin yang symbols",
    "dragon coiled around a crystal tower", "sea serpent around a lighthouse", "owl librarian with books and candles",
    "cat wizard with a hat and potions", "fox with flower crown in an enchanted forest", "bear guardian with runes",
    "whale carrying a ship on its back", "octopus playing instruments", "flying turtle with wings among clouds",
]

TANDAS = [
    ("animales", ANIMALES, ["tatuaje", "etnico", "realista", "mandala"]),
    ("aves", AVES, ["tatuaje", "etnico", "realista"]),
    ("oceano", OCEANO, ["tatuaje", "etnico", "mandala"]),
    ("insectos", INSECTOS, ["tatuaje", "etnico", "geometrico"]),
    ("fantasia", FANTASIA, ["tatuaje", "etnico", "nouveau"]),
    ("flores", FLORES, ["botanico", "mandala", "nouveau"]),
    ("objetos", OBJETOS, ["grabado", "steampunk"]),
    ("vehiculos", VEHICULOS, ["grabado", "paisaje"]),
    ("lugares", LUGARES, ["paisaje", "grabado"]),
]


TANDAS_EXTRA = [
    ("criaturas", CRIATURAS, ["tatuaje", "etnico", "nouveau"]),
]


def lista(solo=""):
    """Prompts de una tanda ("" = la tanda original completa)."""
    if solo:
        salida = []
        for cat, temas, estilos in TANDAS + TANDAS_EXTRA:
            if cat == solo:
                for i, tema in enumerate(temas):
                    for e in estilos:
                        salida.append(("%s_%03d_%s" % (cat, i + 1, e), cat, ESTILOS[e].format(s=tema) + FINAL))
        return salida
    salida = []
    for cat, temas, estilos in TANDAS:
        for i, tema in enumerate(temas):
            for e in estilos:
                salida.append(("%s_%03d_%s" % (cat, i + 1, e), cat, ESTILOS[e].format(s=tema) + FINAL))
    for i, tema in enumerate(MANDALAS):
        salida.append(("mandalas_%03d" % (i + 1), "mandalas", "intricate mandala made of " + tema + FINAL))
    return salida


if __name__ == "__main__":
    import sys
    l = lista(sys.argv[1] if len(sys.argv) > 1 else "")
    print(len(l), "prompts")
