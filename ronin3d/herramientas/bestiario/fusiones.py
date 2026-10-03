"""Fusiones a mano de entradas que son la misma criatura con otro nombre.

«canónico»: [alias, ...]. Los nombres iguales entre los dos archivos (98) se fusionan solos
en fusionar.py; aquí solo van los casos que el nombre exacto no detecta (versiones
«grecorromanas», traducciones, ortografías, etc.). Las variantes REALES (Cadejo blanco y
negro, perros negros británicos, caballos de agua…) no se fusionan: son criaturas distintas
de la misma familia.
"""

FUSIONES = {
    # Grecia y Roma
    "Cerbero": ["Cerbero grecorromano"],
    "Minotauro": ["Minotauro grecorromano"],
    "Quimera": ["Quimera grecorromana"],
    "Hidra de Lerna": ["Hidra grecorromana"],
    "Harpías": ["Harpías grecorromanas"],
    "Sirenas": ["Sirenas grecorromanas"],
    "Centauros": ["Centauros grecorromanos"],
    "Sátiros": ["Sátiros grecorromanos"],
    "Fauno": ["Faunus silvestre"],
    "Equidna": ["Equidna grecorromana"],
    "Escila": ["Scylla romana"],
    # Europa
    "Tarasca": ["Tarasca italiana", "Tarasca provenzal"],
    "Mantícora": ["Manticora", "Manticore persa", "Mantícora europea"],
    "Tatzelwurm": ["Tatzelwurm de los Alpes"],
    "Lindworm": ["Lindworm de Europa central"],
    "Boggart": ["Boggart de Lancashire"],
    "Ceffyl Dŵr": ["Ceffyl y Dŵr"],
    "Rawhead": ["Bloody Bones", "Rawhead and Bloody Bones"],
    "Baba Roga": ["Baba Roga de Croacia", "Baba Roga balcánica"],
    "Kikimora": ["Kikimora del hogar"],
    "Likho": ["Licho"],
    "Vila": ["Vila samovila"],
    # Mesopotamia y Egipto
    "Anzû": ["Anzud"],
    "Mušḫuššu": ["Mushussu", "Sirrush"],
    "Lahmu": ["Lahmu guardian"],
    "Lahamu": ["Lahamu guardian"],
    "Gallu": ["Gallû"],
    "Lilu": ["Lilû"],
    "Bašmu": ["Basmu"],
    "Ammit": ["Ammut", "Devorador de corazones"],
    "Apep/Apophis": ["Apep's serpents", "Serpientes del Duat"],
    "Bennu": ["Bennu-fénix"],
    "Bes": ["Beset"],
    "Guardianes de las puertas del Duat": ["Demonios guardianes del Duat", "Demonios de las puertas"],
    "Serpopardo": ["Serpopard"],
    "Esfinge egipcia": ["Sphinx of Giza type", "Sphinx of Egypt"],
    # Persia, Arabia, Levante, India y Asia
    "Azhdaha": ["Azhdaha of Caucasus", "Azhdar"],
    "Huma": ["Homa"],
    "Ghoul": ["Ghul-e biyaban"],
    "Ifrit": ["Ifrit del Magreb"],
    "Jinn": ["Djinn del Sahara", "Jinn del oasis"],
    "Daitya": ["Daitya serpent"],
    "Yaksha": ["Yaksha guardian"],
    "Kinnara": ["Kinnaras of Himalaya", "Kinnara sudeste asiático"],
    "Makara": ["Makara de templo"],
    "Khyung": ["Khyungchen"],
    "Snow Lion": ["León de nieve"],
    "Mongolian death worm": ["Gusano de la muerte mongol", "Olgoi-Khorkhoi"],
    "Kui": ["Kui Niu"],
    "Umibōzu": ["Umi-bōzu"],
    "Karakasa-obake": ["Karakasa-kozo"],
    "Dokkaebi": ["Dokkaebi nocturno", "Dokkaebi goblin"],
    "Gumiho": ["Gumiho de nueve colas", "Kumiho fox spirit"],
    "Imugi": ["Imoogi"],
    "Phi Krasue": ["Krasue"],
    # África
    "Tokoloshe": ["Tikoloshe acuático"],
    "Inkanyamba": ["Inkanyamba sudafricano"],
    "Ninki Nanka": ["Wolof Ninki Nanka"],
    "Aicha Kandicha": ["Aisha Qandisha"],
    "Bouda": ["Bouda etíope"],
    "Karkadann": ["Karkadann del norte de África"],
    # América y Oceanía
    "Camazotz": ["Camazotz maya"],
    "Tzitzimime": ["Tzitzimitl"],
    "Mbói Tu'ĩ": ["Mboi Tu'i", "Mboi Tu'i de la mitología guaraní"],
    "Jasy Jatere": ["Yasy Yateré"],
    "Madre de aguas": ["Madre de Agua"],
    "Piasa Bird": ["Piasa"],
    "Huay Chivo": ["Huay Chivo de Yucatán"],
    "Nahual": ["Nagual jaguar"],
}
