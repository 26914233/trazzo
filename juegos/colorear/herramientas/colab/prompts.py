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

TANDAS = [
    ("animales", ANIMALES, ["tatuaje", "etnico", "realista", "mandala"]),
    ("aves", AVES, ["tatuaje", "etnico", "realista"]),
    ("oceano", OCEANO, ["tatuaje", "etnico", "mandala"]),
    ("insectos", INSECTOS, ["tatuaje", "etnico", "geometrico"]),
    ("fantasia", FANTASIA, ["tatuaje", "etnico", "nouveau"]),
    ("flores", FLORES, ["botanico", "mandala", "nouveau"]),
    ("comida", COMIDA, ["botanico", "etnico"]),
    ("objetos", OBJETOS, ["grabado", "steampunk"]),
    ("vehiculos", VEHICULOS, ["grabado", "paisaje"]),
    ("lugares", LUGARES, ["paisaje", "grabado"]),
]


def lista():
    salida = []
    for cat, temas, estilos in TANDAS:
        for i, tema in enumerate(temas):
            for e in estilos:
                salida.append(("%s_%03d_%s" % (cat, i + 1, e), cat, ESTILOS[e].format(s=tema) + FINAL))
    for i, tema in enumerate(MANDALAS):
        salida.append(("mandalas_%03d" % (i + 1), "mandalas", "intricate mandala made of " + tema + FINAL))
    return salida


if __name__ == "__main__":
    l = lista()
    print(len(l), "prompts")
