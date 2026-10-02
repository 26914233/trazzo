# Conceptos 2D de RONIN

**Estilo de referencia: el del Bahamut** (`bahamut.jpg`). El 02-10-2026 el usuario pidió que las
demás imágenes tuvieran su nivel de detalle y su estilo, y se rehicieron así:

- **Una escena, no una ficha:** cada imagen enseña la criatura o el personaje en su sitio (patio
  del castillo, río, bosque de bambú, portón, gran salón), con niebla de tinta y detalles del
  entorno.
- **Un samurái para la escala:** pequeño ante los gigantes, de espaldas o a lo lejos ante los demás.
- **Mismo bloque de estilo** en todas, delante de la descripción:

  > 2D anime boss monster concept art, cel-shaded illustration, bold black ink outlines, flat color
  > bands with two-tone shading, sumi-e ink brush splatter accents, plain warm parchment background,
  > dark fantasy.

  En los personajes empieza por *2D anime character concept art*. Va al final *No text, no
  watermark.*
- **Herramienta:** Higgsfield, modelo `z_image`, a 0,15 créditos por imagen. Formato 4:3 para las
  criaturas y 3:4 para los personajes.

| Archivo | Qué es | Cambia a |
|---|---|---|
| `bahamut.jpg` | Bahamut encadenado en las ruinas (la referencia) | — |
| `oni.jpg` | Aka-oni con armadura en el patio del castillo, de noche | `fichas/oni.jpg` |
| `kappa.jpg` | Kappa en las piedras del río, bajo el puente | `fichas/kappa.jpg` |
| `onibi.jpg` | Enjambre de onibi en un sendero de bambú; un samurái con farol | `fichas/onibi.jpg` |
| `oni_gigante.jpg` | **Jefe del capítulo 1** ante el portón, con grietas de brasa | (no había) |
| `tamamo_zorro.jpg` | Tamamo-no-Mae en su forma final: la zorra de nueve colas sobre el castillo, luna roja | Su forma de dama con máscara sigue en `gran_yokai.jpg` |
| `akira.jpg` | Akira ante el castillo bajo la luna roja | `fichas/akira.jpg` |
| `genzo.jpg` | Genzo en el gran salón; la sombra de la zorra en los biombos (su pacto) | `fichas/genzo.jpg` |
| `takeda.jpg` | El shōgun Takeda en el gran salón, con el joven Akira de guardia | `fichas/takeda.jpg` |
| `gran_yokai.jpg`, `shijima.jpg` | Sin cambios: otra forma de Tamamo, y una propuesta (DECISIÓN 11) | — |

En el repositorio van en JPG de 1024 px. Los PNG originales, de 2048 × 1536 o 1536 × 2048, están en
Drive › `ronin/05-Arte/conceptos-2d/`.

## `fichas/`: los conceptos anteriores, para 3D

Son de cuerpo entero, sin fondo y de frente. Ese es el tipo de imagen que necesita la conversión
imagen → 3D: las escenas, con entorno y otro personaje, no sirven para eso. De estas fichas salieron
los modelos 3D del Aka-oni y del kappa (`godot/modelos/criaturas/LEEME.md`).

## Lo que se aprendió

- **El filtro de Higgsfield rechaza a los oni con el torso desnudo.** El oni gigante falló cuatro
  veces: tres el 01-10 (en negro y cobradas) y una el 02-10 (devuelta). El Aka-oni falló una vez el
  02-10 (devuelta). Con armadura (peto lacado, hombreras y faldón) salieron los dos a la primera.
  Todo apunta al filtro de desnudos.
- **Fallos:**
  - La IA a veces escribe pseudo-kanji aunque se le pida que no (los estandartes de `genzo.jpg`).
  - El garrote del Aka-oni tiene dos cabezas.
  - El oni gigante lleva dos garrotes.
  - Si se usan en una tienda o un tráiler, conviene retocarlos o repetirlos.
- **Coste:** 8 imágenes por 1,20 créditos (los 2 fallos se devolvieron).

## Prompts exactos

**oni.jpg:** …Aka-oni, a red oni warrior from Japanese folklore: crimson skin, two short ivory horns, a
wild black mane, fanged grimace, glowing yellow eyes, wearing battered black samurai armor with iron
shoulder guards, a lacquered breastplate and a tiger-pattern armored skirt, iron bracers, a huge
spiked iron kanabo club resting on its shoulder, standing guard in the moonlit stone courtyard of a
Japanese castle among toppled stone lanterns, drifting embers and ink-wash mist. Full body.

**kappa.jpg:** …Kappa, a Japanese river yokai: a hunched amphibious creature the size of a child,
slick blue-green skin, a dark mossy turtle shell on its back, a hard beak-like mouth, big yellow eyes,
webbed clawed hands and feet, a shallow dish of water on top of its head with water dripping over the
rim, crouching on smooth wet stones at the edge of a misty river beneath an old wooden bridge with
tall reeds, a lone samurai standing on the bridge above seen from behind for scale. Anatomically
coherent.

**onibi.jpg:** …Onibi, Japanese ghost fires: a swarm of eerie pale-blue spirit flames with hollow dark
eye holes drifting in a slow spiral along a foggy bamboo forest path at night, old moss-covered stone
lanterns and stepping stones, wisps of blue light reflected on the ground, a lone samurai holding a
paper lantern walking through the swarm for scale.

**oni_gigante.jpg:** …A colossal oni guardian from Japanese folklore, taller than a castle gate: dark
red skin with glowing orange ember lines like cooling lava, three curved horns, burning yellow eyes,
wild black hair, wearing massive black iron samurai armor with a lacquered breastplate, broad
shoulder guards and a tiger-pattern armored skirt, broken iron shackles on its wrists, an enormous
iron kanabo club resting on its shoulder, standing in front of the great wooden gate of a Japanese
castle at night with smoke and drifting embers, a tiny samurai standing before it for scale.

**tamamo_zorro.jpg:** …Tamamo-no-Mae in her final form, the great nine-tailed fox yokai as large as a
temple: a colossal white and gold fox with glowing violet foxfire flames, exactly nine enormous
flowing tails fanned out across the night sky, elegant and menacing, golden slit eyes, a red
ceremonial cord around its neck, looming over the curved roofs and towers of a Japanese castle under
a blood-red moon, violet foxfire orbs floating around it, a tiny samurai standing on the castle wall
before it for scale. Anatomically coherent.

**akira.jpg:** …Akira, a young ronin swordsman, former bodyguard of the shogun: lean and determined,
long black hair in a high ponytail, a white headband, dark indigo kimono and hakama with a red sash,
straw sandals, his hand resting on the hilt of a sheathed katana in a calm iaido stance, standing
alone on the stone steps of a Japanese castle at night under a blood-red moon, torn banners and
embers drifting in the wind, ink-wash clouds. Full body.

**genzo.jpg:** …General Genzo, a tall imposing samurai general about 55 years old, short grey-streaked
hair and a trimmed beard, stern but sorrowful eyes, ornate crimson and black lacquered o-yoroi armor
with gold trim, horned kabuto helmet held under one arm, long nodachi sword on his back, tattered
black cape, a faint violet aura curling around his left arm, standing in the great hall of a Japanese
castle keep among war banners, the shadow of a nine-tailed fox faintly cast on the painted folding
screens behind him. Full body.

**takeda.jpg** (con *feudal Japan* en lugar de *dark fantasy*): …Shogun Takeda, a wise and kind
elderly shogun with a white beard and a black court cap, dark blue formal robes with a silver family
crest, holding a closed folding fan, seated in the great hall of a Japanese castle before painted
folding screens of cranes and pine trees, warm candlelight, a loyal young samurai bodyguard with a
white headband kneeling respectfully nearby, ink-wash mist.

Para las 825 criaturas del bestiario, el cuaderno de Colab (`../../colab/`) tiene el modo **escena**,
que imita este estilo con el hábitat y el tamaño de cada criatura. El modo **ficha** sirve para
sacar imágenes para 3D.
