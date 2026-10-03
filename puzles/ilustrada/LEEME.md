# La caja viva ilustrada (03-10-2026)

**Por qué existe.**
- El usuario vio la prueba de Blender y dijo que no se parecía nada al boceto. Le gustó la imagen del
  boceto, con su toque tétrico y misterioso, y pidió el juego en ese estilo animado e interactivo.
- La primera versión de esta página fue la ilustración misma (la A+C de frente, `../bocetos/caja_viva_ac.jpg`),
  animada por capas y jugable.
- Después pidió hacer las tres opciones de la DECISIÓN 29 (`../PLAN.md` §7), con movimiento y animación de
  cámara. Las jugó en el móvil y **eligió la B** (la DECISIÓN 29 está cerrada):
  - **B · Pintura sobre 3D, el juego:** la pintura del boceto proyectada sobre una caja, una mesa y una sala
    sencillas en 3D. La caja gira de verdad y la cámara se mueve.
  - **A · Ilustración por capas, el respaldo:** la pintura se mueve con profundidad y la caja gira como un
    teatro de papel. Solo se usa si el móvil no tiene WebGL (o con `?tecnica=A`).
  - **C · 3D con acuarela, retirada:** el modelo de Blender con tinta y acuarela. Su código sigue en
    `tecnica_3d.js` como referencia, sin mantener, y sus modelos (`pagina/modelos/`) ya no se publican.

**Para jugarla:** página privada https://claude.ai/artifact/7fC2cECS62soiVNBa2kMG3 (solo la puede abrir el
usuario). Funciona en el móvil, en horizontal y en vertical, mejor con sonido.

**En APK** (desde el 03-10-2026): `caja-viva-0.1-prueba.apk`, la misma página dentro de una app de Android, sin
conexión. Cómo se construye y se firma: `apk/LEEME.md`.

**Es el juego** (DECISIONES 23 y 24, cerradas el 03-10-2026): una línea de niveles de la misma caja. El plan
está en `NIVELES.md`; se juegan el nivel 1 y el 2. Al terminar cada nivel sale una tarjeta con la cara como
marcador (las piezas que ha recuperado: 角 cuerno, 目 ojo y 声 voz) y la partida se guarda en el navegador; la
portada ofrece seguir. Con `?nivel=2` se empieza en el 2.

**Nivel 1 · El cuerno (unos 3-4 minutos):**
1. los nueve cajones del costado están cerrados: al tocar uno, la cámara se acerca y se abre deslizándose
   (dos tienen cerradura y no ceden);
2. la llave está en el cajón de abajo, pero la caja no deja cogerla mientras el ojo te mira: la lámpara lo
   distrae;
3. en el cajón de al lado está la nota: «Me falta un cuerno. Lo guarda el león que respira humo»;
4. la llave abre el incensario y el león deja la tapa en la mesa;
5. el cuerno de las brasas va al hueco de la frente;
6. la caja despierta.

Detrás de la caja hay más cajones, un hueco con forma de ficha de shōgi y un cajón largo con otra cerradura
(para niveles futuros).

**Nivel 2 · La caja de dentro (solo en la B):**
1. la caja se calma y su trampilla sigue dando luz; al tocarla, sube de dentro una caja pequeña y baja a la mesa;
2. de cerca se ve la caja pequeña con el ojo grande encima, vigilándola; arrastrar la gira en la mano;
3. sus cinco tablillas corren en orden y la flecha de debajo de cada una dice cuál sigue;
4. la cara que ve el ojo grande no se mueve (la lámpara ya no lo distrae): hay que esconderle cada tablilla;
5. detrás de la tapa, un cajoncito con una cajita roja; examinada, su tapa gira hasta que su marca dorada toca
   la del borde, y dentro hay un ojo de piedra de luna;
6. el ojo va a la cuenca vacía y la caja abre los dos ojos.

## Qué hay

| Ruta | Qué es |
|---|---|
| `fuentes/` | Las ilustraciones de Gemini, todas con el mismo encuadre (1376 × 768) |
| `fuentes/planos/` | Los costados y la tapa aplanados (`*_plano.jpg`) y su repintado de frente (`*_gemini.jpg`) |
| `preparar_capas.py` | Recorta de las fuentes las piezas, los parches de cada estado y las siluetas, y pasa los sonidos a 22 kHz |
| `herramientas/camara_boceto.py` | Calcula la cámara desde la que está pintado el boceto (`pagina/capas/camara.json`) |
| `herramientas/escena_boceto.py` | Ajusta la sala, la mesa, la peana y los objetos a esa cámara (`pagina/capas/escena.json`) |
| `herramientas/cajones_boceto.py` | Mide los nueve cajones del costado sobre el boceto (`pagina/capas/cajones.json`) |
| `herramientas/caras_boceto.py` | Aplana los costados y la tapa, y deja sus repintados igualados en `pagina/capas/cara_*.webp` |
| `herramientas/modelo_web.py` | Aligeraba los modelos de Blender para la técnica C, ya retirada (`pagina/modelos/`) |
| `pagina/index.html` | La página: la interfaz, el estilo y el mapa de módulos (Three.js r170 desde jsDelivr) |
| `pagina/juego.js` | Todo lo común: estado y recorrido, cajones, inventario, ojo, respiración, humo, luz, decoración viva, sonido, toques y la técnica A |
| `pagina/tecnica_3d.js` | La técnica B (y la C retirada); se carga mientras se ve la portada |
| `pagina/caja_hija.js` | La caja hija del nivel 2: el cubo con sus tablillas, sus flechas, el cajoncito y la cajita |
| `herramientas/nivel2_capas.py` | Las capas del nivel 2: las caras de la caja hija, la cajita y el ojo nuevo (`capas/nivel2.json`) |
| `NIVELES.md` | El plan de niveles: la cara como puzle grande y los cuatro niveles |
| `apk/` | El APK de Android: la página dentro de un WebView, sin conexión (`apk/LEEME.md`) |
| `pagina/escena3d.js` | La sala del boceto en 3D, el material que proyecta la pintura, la caja pintada y sus cajones |
| `pagina/capas/`, `pagina/sonidos/` | Lo que generan los guiones |
| `prueba/` | `servir.py` (servidor local), `jugar.mjs` (prueba del nivel 1) y `jugar_nivel2.mjs` (del nivel 2) |

### Las fuentes

| Archivo | Qué cambia respecto a la sala | SHA-256 (inicio) |
|---|---|---|
| `sala.jpg` | Es el boceto de la A+C (el de `bocetos/`, en su calidad original) | `3bde8202` |
| `sala_cajones_cerrados.jpg` | Los cajones del costado, cerrados (solo se usa el costado) | `92615bc0` |
| `sala_sin_llave.jpg` | El cajón de abajo, sin la llave (ya no se usa: los cajones empiezan cerrados) | `e916bf0c` |
| `incensario_abierto.jpg` | Sin la tapa: brasas, el cuerno asomando y más humo | `00bd5b12` |
| `incensario_vacio.jpg` | El incensario abierto, ya sin el cuerno | `9150182f` |
| `despierta.jpg` | La caja despierta: ojos rojos, humo, trampilla abierta (puso un cuerno de más: se quita al recortar) | `5b3eb606` |
| `sala_detras.jpg` | La caja girada media vuelta en su sitio: la espalda, con cajones, un hueco de ficha y una borla | `5e9e55dd` |
| `sala_mesa_vacia.jpg` | La mesa sin la caja ni los objetos | `715c0a7c` |
| `sala_vacia.jpg` | La sala sin la mesa | `4219b267` |
| `planos/derecha_gemini.jpg` | El costado de los cajones, repintado de frente | `295b1d19` |
| `planos/izquierda_gemini.jpg` | El costado de la borla, repintado de frente | `9180ca1a` |
| `planos/arriba_gemini.jpg` | La tapa con la trampilla, repintada de frente | `5d7cc4ba` |
| `sala_dos_ojos.jpg` | Nivel 2: el ojo de piedra de luna puesto en la cuenca (para animarlo como el viejo) | `02d5f0f3` |
| `nivel2/cara_asanoha.jpg` | Nivel 2: una cara de la caja hija, de frente (mosaico asanoha) | `c0a6a9ca` |
| `nivel2/cara_kikko.jpg` | Nivel 2: otra cara de la caja hija (mosaico kikko) | `e0f23490` |
| `nivel2/cara_frente_ojo.jpg` | Nivel 2: el frente de la caja hija, con el párpado tallado | `6e9bd230` |
| `nivel2/cajita.jpg` | Nivel 2: la cajita de laca roja vista desde arriba | `32af5ae5` |

**Cómo se hicieron:** Gemini (`gemini-3.1-flash-image`) editando la anterior.
- El prompt siempre empieza igual: «Edit this exact image and keep everything identical: same composition,
  same camera, same hand-drawn ink and watercolor style… Change only…». Después dice qué cambia, y
  termina con «Nothing else changes».
- Los repintados de frente parten del aplanado (`planos/*_plano.jpg`) y piden lo mismo: «repaint it crisp…
  no perspective… Nothing moves».
- Salen alineadas al píxel con la original. Se comprobó con correlación de fase: desplazamiento 0, 0.
- Salen unos 2 niveles más oscuras o con más contraste; los guiones lo igualan.
- Coste de los once retoques: unos 0,50 USD **[Estimación]**.
- Las del nivel 2 (cinco más) siguen la misma receta; `herramientas/nivel2_capas.py` las prepara. Unos 0,25 USD
  **[Estimación]**.

## Cómo funciona

**Lo común (juego.js)**
- **La ilustración compuesta:** la sala más los cambios que ya han pasado (incensario abierto, el cuerno
  puesto, el despertar). Se rehace al cambiar de estado.
- **Las planchas:** la pintura original y, solo detrás de cada objeto, lo que Gemini pintó en la sala vacía
  o en la mesa vacía. Quieta, la escena es el boceto exacto; al moverse, detrás de cada cosa hay algo.
- **El ojo:**
  - el iris se mueve con un muelle rápido, como los ojos de verdad, y el párpado parpadea o se entorna;
  - mira el dedo; si nadie lo toca, mira la sala; cuando la llama tiembla, mira la lámpara;
  - **la regla de la caja viva:** «no deja tocar mientras te ve». Un parpadeo no cuenta: es demasiado corto
    para aprovecharlo.
- **La respiración, el humo y la luz:** la caja respira y, si la fuerzas, contiene el aliento; el humo sube
  en cintas con el borde a tinta; hay bocanadas por las juntas, la luz de la lámpara, las brasas, motas de
  polvo y, al despertar, los ojos rojos y la luz de la trampilla.
- **Los cajones:** su forma en metros sale de `capas/cajones.json`. Cada uno se abre con un rebote y se
  cierra con un golpe seco; los de cerradura resisten sin moverse; al despertar, todos traquetean. Al tocar
  uno, la cámara va a la vista del costado.
- **El inventario:** una bandeja lacada con cuatro huecos. Tocar un objeto dice su nombre y lo elige; tocarlo
  otra vez (o mantenerlo pulsado) lo examina en grande; arrastrarlo lo usa donde se suelte. La nota se
  guarda y se relee.
- **La decoración viva:**
  - el viento sopla a ráfagas o al tocar el shoji: mece las sombras del bambú, el rollo colgado, la llama y
    el humo;
  - tres polillas rondan la lámpara y se posan en el papel; la llama, el viento o el dedo las espantan;
  - la tapa de la tetera tiembla con el vapor;
  - el té hace ondas cuando algo golpea la mesa;
  - el dedo aparta el polvo y el humo.
- **La cámara:** cinco vistas (sala, caja, costado de los cajones, incensario y la cara del final) con
  transiciones, un vaivén lento de cámara en mano y sacudidas. Arrastrar mueve la cámara y pellizcar acerca.
- **La caja gira:** con el botón «Girar» o arrastrándola con el dedo.

**B · Pintura sobre 3D** (`tecnica_3d.js` y `escena3d.js`)
- Cada superficie toma su color de la pintura vista desde la cámara del boceto (proyección).
- La caja guarda la posición en la que se pintó, así que la pintura gira con ella. El frente sale del boceto
  de frente y la espalda, del de espaldas.
- **Los costados y la tapa** se ven muy de lado en los bocetos. Llevan además su repintado de frente, que se
  mezcla según lo lejos que esté la cámara de la del boceto: quieta, el boceto exacto; al girar, la pintura
  de frente, nítida.
- **Los cajones:** cerrados, los pinta la caja. Al abrirse, cada uno sale con su frente pintado (la misma
  proyección y el mismo repintado que el costado), paredes de laca más bajas que el frente (para ver lo que
  guarda), el hueco oscuro y su sombra. La llave y la nota van dentro, tal como están pintadas.
- El incensario, la tetera y las tazas son cilindros recortados con su silueta. La tetera y las tazas se
  recortan además con su forma (si no, arrastraban un rectángulo de mesa) y llevan sombra de contacto.
- Las sombras del bambú son un plano pegado a la pared del shoji (la caja lo tapa) y el rollo, un plano con
  su pintura que gira desde su gancho.
- El ojo es un trocito de lienzo que se repinta en cada cuadro dentro de la textura de la caja.

**A · Ilustración por capas** (`juego.js`, en un lienzo 2D; el respaldo)
- La sala y la mesa se dibujan por franjas de 16 px. Cada franja se desplaza según su profundidad (sacada
  de la escena 3D).
- La caja se estrecha al girar y, pasada la mitad, aparece su espalda. Los cajones se dibujan con la cámara
  del boceto: el frente es la pintura llevada a su sitio y las paredes, la laca de un cajón abierto del
  boceto original.

## Comandos

```
# rehacer las capas, las siluetas y los sonidos de la página
python3 puzles/ilustrada/preparar_capas.py

# la cámara del boceto, la escena y los cajones (solo si cambia el boceto)
python3 puzles/ilustrada/herramientas/camara_boceto.py
python3 puzles/ilustrada/herramientas/escena_boceto.py
python3 puzles/ilustrada/herramientas/cajones_boceto.py

# los costados y la tapa: aplanarlos y, con los repintados en fuentes/planos/, igualarlos
python3 puzles/ilustrada/herramientas/caras_boceto.py

# probarla en local (la página es un fragmento: el servidor le pone doctype y head, como al publicarla)
python3 puzles/ilustrada/prueba/servir.py &          # http://localhost:8765/   (la A: /?tecnica=A)

# las capas del nivel 2 (si cambian sus ilustraciones de fuentes/nivel2/ o sala_dos_ojos.jpg)
python3 puzles/ilustrada/herramientas/nivel2_capas.py

# prueba automática: juega la partida entera con toques de móvil y saca capturas
node puzles/ilustrada/prueba/jugar.mjs B horizontal <carpeta de capturas>
node puzles/ilustrada/prueba/jugar.mjs A vertical <carpeta de capturas>
node puzles/ilustrada/prueba/jugar_nivel2.mjs vertical <carpeta de capturas>
```

- **Resultado (03-10-2026, noche):** el nivel 1, 24 de 24 en la B y en la A, en horizontal y en vertical; el
  nivel 2, 25 de 25 en horizontal y en vertical.
- **La prueba** usa Playwright y el Chromium del contenedor de Claude (`/opt/pw-browsers`). Comprueba esto:
  - que los cajones empiezan cerrados, se abren con su animación y acercan la cámara;
  - que la llave resiste mientras el ojo mira, que un cajón con cerradura no cede y que la lámpara distrae;
  - la llave a la bandeja, el cajón vacío que se cierra y la nota (se lee, se guarda y queda en la bandeja);
  - examinar un objeto manteniéndolo pulsado;
  - la espalda de la caja y su cajón largo;
  - que el incensario no se abre sin la llave;
  - la tapa en la mesa, el cuerno y el despertar;
  - la tarjeta del nivel 1 (en la A, que el nivel 2 necesita 3D);
  - volver a empezar (cajones cerrados y bandeja vacía);
  - y que no haya errores en la consola.
- **La prueba del nivel 2** empieza con «Seguir» en la portada y comprueba la subida de la caja hija, una
  tablilla fuera de orden, la de arriba vista por el ojo, que la lámpara ya no distrae, las cinco tablillas
  (cada una puesta de cara con arrastres de verdad), el cajoncito, la cajita, su tapa, el ojo en la cuenca, la
  tarjeta y la partida guardada.
- **La B necesita WebGL.** Sin tarjeta gráfica se usa SwiftShader, que es lento (unos 3-11 cuadros por
  segundo). Por eso las esperas de la prueba van en tiempo de juego y comprobando el estado.
- **Three.js** viene de jsDelivr: la prueba lo descarga con el `fetch` de Node y se lo pasa a la página.
- **Ganchos para probarla:** la página deja `window.__prueba` (estado, ojo, reloj, técnica, cara de la caja,
  ir a una vista, girar, dónde tocar para cada punto del boceto, el centro de cada cajón, cuánto está abierto
  y el inventario; y, del nivel 2, la caja hija, dónde tocar cada parte, si el ojo ve una tablilla y la
  cajita) y `window.__tec`.
- **Para publicarla de nuevo** en la misma página privada: la herramienta Artifact, con `pagina/index.html`
  y, en `files`, los tres `.js` y todo `capas/` y `sonidos/`. La raíz es `pagina/`.

## Lo que falta para un juego [Opinión]

- **Más resolución:** la herramienta de hoy da 1376 × 768. Al acercarse en un móvil se ve algo blando, y
  la versión final pide 2K o 4K.
- **Los niveles 3 y final** (`NIVELES.md` §6 y §7).
- **El APK:** hecho, la página empaquetada tal cual (`apk/`). Para Google Play faltaría subir el SDK objetivo a
  35 y el AAB firmado con una clave de publicación.
