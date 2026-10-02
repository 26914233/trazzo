# Cuatro cajas: prototipos de juegos de puzles tipo The Room

Cuatro prototipos jugables sobre un mismo núcleo, para descubrir con pruebas reales cuál merece
convertirse en juego. Se decidió el 02-10-2026 (DECISIÓN 22, en `PLAN.md`). RONIN queda en pausa
en la versión 0.9 mientras tanto.

- **Plan, decisiones y cómo se valida:** `PLAN.md`.
- **Proyecto de Godot 4.7 (renderizador Compatibility, Android):** `godot/`.
- **Herramientas** (texturas y sonidos hechos por código, sin créditos de imágenes): `herramientas/`.
- **Capturas:** `capturas/cuatro_prototipos.jpg` (los cuatro en juego), `capturas/portadas.jpg` y
  `capturas/menu.jpg`. Las PNG que deja la prueba automática no se suben a git.

## Los cuatro prototipos (versión 0.1)

| Prototipo | La idea en una frase | Lo que lo hace distinto | Pasos |
| --- | --- | --- | --- |
| **La caja viva** | Una caja secreta japonesa de cien años que ha cobrado vida y no quiere que la abras. | Una *himitsu-bako* que es un *tsukumogami*: tiene un ojo y no se deja tocar mientras te ve. | 8 |
| **La caja del relojero** | Un relojero desapareció en 1891. Su caja solo se abre a las horas que importan. | El reloj es la llave: cuerda, horas sacadas de una carta y un billete, engranaje que falta. | 7 |
| **La reliquia** | Un artefacto de otro mundo flota frente a ti. Guía su luz y escucha lo que despierta. | Anillos con surcos que desvían la luz: un puzle de caminos que cambia con el cristal. | 7 |
| **El cuarto del farero** | La tormenta arrecia, el farero no está y un barco se acerca. Enciende el faro. | Habitación de escape por puntos de vista: candado de ruedas, libro palanca, trampilla. | 9 |

Cada uno dura unos 5-15 minutos **[Estimación, sin probar aún con jugadores]**.

## Cómo se juega

- **Un dedo sobre una pieza:** arrastrarla (paneles, cajones, diales, manivela, anillos, tapas). Si
  apenas se mueve el dedo, es un toque: la pieza avanza a su siguiente posición o se abre.
- **Un dedo en el vacío:** girar alrededor del objeto (en el farero, mirar alrededor).
- **Dos dedos:** acercar o alejar. En el PC, la rueda del ratón.
- **Objetos:** se tocan para guardarlos; abajo aparecen como iconos. Se elige uno y se toca donde
  se quiere usar.
- **Pista:** tres niveles por paso, de vaga a explícita. La tercera hace brillar la pieza.
- **Centrar / Volver:** vuelve a la vista de partida (o, en el farero, al punto de vista anterior).
- **Menú:** pide confirmación (se pierde lo avanzado).
- Al terminar, una pantalla muestra **el tiempo, las pistas usadas y los intentos bloqueados**, y el
  menú guarda el mejor tiempo de cada prototipo. Son los datos que se piden a los probadores.

## Estructura de `godot/`

- `principal.gd`: menú ↔ prototipo. Argumentos: `--prueba`, `--prototipo=<id>`.
- `catalogo.gd`: los cuatro prototipos (título, frase, color, guion).
- Núcleo común:
  - `mesa.gd`: monta la partida y reparte los toques entre la cámara y las piezas; lleva las pistas,
    el inventario con iconos, las métricas y el final.
  - `camara_puzle.gd`: órbita con inercia, pellizco, enfoque de detalles y puntos de vista.
  - `hud.gd`: menú, pistas, progreso, inventario, avisos, notas y el resumen final.
  - `sonido.gd` y `estilo.gd`.
  - `piezas/`: deslizante, giratoria, bisagra, pulsador, recogible, ranura, nota y punto de vista.
  - `puzle.gd`: base de cada prototipo (pasos, pistas y lo que la prueba necesita).
  - `geometria.gd`, `materiales.gd` y `escena.gd`: mallas, materiales y montaje de escenas, todo
    hecho por código.
- `prototipos/`: `caja_viva.gd`, `relojero.gd`, `reliquia.gd` y `farero.gd`.
- `shaders/`: cielo, brillo de ayuda, surcos de luz y la tormenta de la ventana.
- `recursos/`: texturas, sonidos, portadas del menú y fuentes (Liberation Serif, licencia OFL;
  `recursos/fuentes/LICENCIA_OFL.txt`).

## Comandos

```bash
# Prueba automática: resuelve los cuatro, comprueba bloqueos, pistas, inventario y un arrastre real
xvfb-run -a godot --path puzles/godot --rendering-driver opengl3 -- --prueba        # 64 comprobaciones
xvfb-run -a godot --path puzles/godot --rendering-driver opengl3 -- --prueba --solo=farero

# Revisar que todos los guiones compilan, sin abrir el juego
godot --headless --path puzles/godot --script res://scripts/comprobar_guiones.gd

# Volver a generar texturas, sonidos y portadas del menú
python3 puzles/herramientas/generar_texturas.py [nombre ...]
python3 puzles/herramientas/generar_sonidos.py
xvfb-run -a godot --path puzles/godot --rendering-driver opengl3 --script res://scripts/hacer_portadas.gd
```

- **Tras generar texturas nuevas hay que reimportar** con `godot --headless --path puzles/godot --import`.
  En sus `.import`:
  - `compress/mode=2`, `mipmaps/generate=true` y `detect_3d/compress_to=0`;
  - en las `_n` (relieve) y en la esfera del reloj, `process/size_limit=512` (así el APK pesa 13 MB
    menos).
- **El símbolo del ofuda** («百年封印», sello de cien años) se dibuja con la fuente IPAGothic del
  sistema solo para crear la imagen. La fuente no va dentro del juego.

## Exportar el APK

Igual que RONIN (`ronin3d/godot/LEEME.md`, sección «Exportar»): plantillas de Godot 4.7.2, SDK de
Android y la clave de prueba con las variables `GODOT_ANDROID_KEYSTORE_RELEASE_*`.

```bash
godot --headless --path puzles/godot --export-release Android exportaciones/puzles-0.1-prueba.apk
```

La versión 0.1 cumple lo siguiente **[Hecho, comprobado con apksigner y aapt2]**:

| Dato | Valor |
| --- | --- |
| Peso | 43,9 MB (24 MB son del motor) |
| Paquete | `com.thunderdarkness.puzles`, nombre «Cuatro cajas» |
| Android | 64 bits; pide permiso de vibración |
| Firma | Clave de prueba de RONIN (`CN=RONIN prueba`) |
| SHA-256 | `cd6e78861cac07ac8700d18eb92b676b1012ed3a1738011c0394c458529b32e2` |

Está en Google Drive, en `Respaldos Claude/puzles/`.
