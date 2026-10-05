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
usuario). Se juega en el móvil **en horizontal** (en vertical pide girarlo), mejor con sonido.

**En APK** (desde el 03-10-2026): `caja-viva-0.2-prueba.apk`, la misma página dentro de una app de Android, sin
conexión y siempre en horizontal. Cómo se construye y se firma: `apk/LEEME.md`.

**Es el juego** (DECISIONES 23 y 24, cerradas el 03-10-2026): una línea de niveles de la misma caja. El plan
está en `NIVELES.md`; se juegan el nivel 1 y el 2. Al terminar cada nivel sale una tarjeta con la cara como
marcador (las piezas que ha recuperado: 角 cuerno, 目 ojo y 声 voz) y la partida se guarda en el navegador; la
portada ofrece seguir. Con `?nivel=2` se empieza en el 2.

**Nivel 1 · El cuerno (unos 3-4 minutos):**
1. los nueve cajones del costado están cerrados: al tocar uno, la cámara se acerca al costado y se queda allí;
   se abren **tirando de ellos con el dedo** y se cierran empujándolos (dos tienen cerradura y no ceden);
2. la llave está en el cajón de abajo, pero la caja no deja cogerla mientras el ojo te mira: la lámpara lo
   distrae;
3. en el cajón de al lado está la nota: «Me falta un cuerno. Lo guarda el león que respira humo»;
4. la llave entra en la cerradura del león y se **gira con el dedo en círculo**; luego la tapa se **levanta
   arrastrando hacia arriba** y queda en la mesa;
5. el cuerno de las brasas va al hueco de la frente;
6. la caja despierta.

Detrás de la caja hay más cajones, un hueco con forma de ficha de shōgi y un cajón largo con otra cerradura
(para niveles futuros).

**Nivel 2 · La caja de dentro (solo en la B):**
1. la caja se calma y su trampilla sigue dando luz; **tirando de ella hacia arriba**, sube de dentro una caja
   pequeña y baja a la mesa;
2. de cerca se ve la caja pequeña con el ojo grande encima, vigilándola; arrastrar la gira en la mano;
3. sus cinco tablillas corren en orden, **deslizándolas con el dedo**, y la flecha de debajo de cada una dice
   cuál sigue;
4. la cara que ve el ojo grande no se mueve (la lámpara ya no lo distrae): hay que esconderle cada tablilla;
5. detrás de la tapa, un cajoncito (se **tira de él**) con una cajita roja; examinada, su tapa gira hasta que su
   marca dorada toca la del borde, y dentro hay un ojo de piedra de luna;
6. el ojo va a la cuenca vacía y la caja abre los dos ojos.

## Gestos y horizontal (03-10-2026, noche)

**Qué pidió el usuario:** «El juego tiene que ser horizontal cuando entre, para que sea más vistoso el panorama
también, permite que pellizque para acercar o alejar, para todo debe tener acción, me refiero que para abrir un
cajón […] cuando se acerque se mantenga para que pueda interactuar, que quede fijo en esa parte, que tenga
acción, es que jale el cajón, no solo tocar, ese tipo de movimientos».

**Qué cambió:**
- **Horizontal:** en un móvil en vertical, un aviso pide girarlo («Así se ve la sala entera»). Al entrar, la página
  pide pantalla completa en horizontal si el navegador lo deja. El APK va siempre en horizontal
  (`sensorLandscape`). Los encuadres de cerca se ajustaron al horizontal: el costado entero con los cajones de
  abajo abiertos, la cara de la frente a la boca y la caja con su trampilla. De cerca de los cajones y de la caja
  pequeña, los textos van a la derecha.
- **La cámara se queda:** en las vistas de cerca (caja, cajones, cara, incensario y caja pequeña) arrastrar ya no
  mueve la cámara y tocar fuera no devuelve a la sala. Se vuelve con «Sala», con el botón atrás o pellizcando. Un
  cajón tocado de lejos solo acerca la cámara al costado. La caja grande se gira desde la sala o la vista de la
  caja (y con «Girar»).
- **Pellizcar acerca o aleja** alrededor de los dedos y se desplaza con ellos (también la rueda del ratón). Es una
  lupa sobre el encuadre, sin mover la cámara, así la pintura no se deforma. Cada vista tiene su margen (hasta
  unas 2,2 veces más cerca; de cerca, también un poco más lejos). Si se sigue alejando, se vuelve a la vista de
  antes: de los cajones o de la cara a la caja, y de la caja o del incensario a la sala.
- **Las acciones son gestos** (un toque solo avisa: la pieza asoma un poco y el mensaje dice qué hacer):

  | Qué | Gesto |
  |---|---|
  | Cajón del costado | Tirar de él hacia fuera (por la línea por la que sale) y empujarlo para cerrarlo. Sigue al dedo y, al soltarlo, acaba de salir con un rebote o se cierra con un golpe seco. Los de cerradura no se mueven: la caja contiene el aliento |
  | Llave en el león | Se mete con la llave del inventario y se gira con el dedo en círculo alrededor de la cerradura (en cualquier sentido). Desde la 0.3 tiene holgura al principio, cede y se frena en tres muescas; a tres cuartos de vuelta encaja, dentro corre un pestillo y la tapa salta. Si se suelta antes, vuelve |
  | Tapa del incensario | Suelta, queda entreabierta, con luz por la rendija (0.3). Se levanta arrastrando hacia arriba; arriba del todo, va a la mesa. Si se suelta pronto, cae y se queda entreabierta |
  | Trampilla (nivel 2) | Tirar hacia arriba: sube la caja pequeña |
  | Tablillas (nivel 2) | Deslizar con el dedo la que toca, por su línea; arrastrar en otra dirección (o cualquier otra tablilla) gira la caja pequeña. Si el ojo la ve, no se mueve |
  | Cajoncito (nivel 2) | Tirar de él hacia fuera |

- **Los cajones tienen física:** un muelle por cajón (cuánto ha salido, su velocidad y adónde va). Mientras el
  dedo lo agarra va donde lo lleve; al soltarlo, la velocidad del dedo cuenta (un tirón rápido lo abre).

## Tacto, sonido y causa → efecto (0.3, 05-10-2026)

**Por qué:** la auditoría (`../genero/07_auditoria_caja_viva.md` §5) puso primero el tacto con peso, el vocabulario de
sonido, las señales sin texto y la causa → efecto visible. Son lo que define el género y no necesitan arte nuevo.

**Qué cambió:**
- **El vocabulario de sonido y vibración** (`VOCABULARIO` y `sentir()` en `juego.js`; la tabla está en
  `../genero/05_gramatica_y_sistemas.md` §7). Cada cosa suena y vibra siempre igual:

  | Evento | Qué significa |
  |---|---|
  | holgura | la pieza asoma: se puede mover |
  | roce | algo se está moviendo |
  | tope | llegó al final |
  | clac | encajó en su sitio |
  | pestillo | algo corre dentro |
  | muesca | un paso del mecanismo (la llave) |
  | mecanismo | algo se mueve dentro de la caja |
  | desbloqueo | gran desbloqueo (grave y largo) |
  | trabado | no se puede, ahora |

  Hay cuatro sonidos nuevos: `holgura`, `clac`, `pestillo` y `desbloqueo` (`herramientas/sonidos_vocabulario.py`).
- **El silencio es tensión:** cuando la caja contiene el aliento, el ambiente baja unos 11 dB y luego vuelve.
- **Peso en las piezas** (`actualizarGesto`, en cada cuadro mientras el dedo mueve algo):
  - la llave tiene holgura: el primer trozo de giro solo la mueve en su hueco. Luego cede con un sonido, se frena en
    tres muescas con su clic y sigue al dedo con un poco de retraso;
  - un cajón del costado cerrado está asentado: hay que tirar un poco antes de que ceda (holgura), y su tope de fuera
    suena;
  - las tablillas y el cajoncito de la caja pequeña ceden igual. Siguen al dedo con retraso, suenan al llegar al tope
    y, al correr del todo, hacen clac;
  - la tapa del incensario sigue al dedo con retraso y se mece si se mueve de lado;
  - la caja grande, soltada con impulso, sigue girando un poco. La pequeña se asienta con un leve rebote: un muelle
    de giro (`girarConMuelle` en `tecnica_3d.js`) en vez de acercarse sin más.
- **Causa → efecto en la cerradura del león.** Antes solo sonaba un clic y había que leer el mensaje. Ahora, en
  cadena: la llave llega al final (clac), dentro corre un pestillo, y la tapa salta, cae torcida y se queda
  entreabierta, con la luz de las brasas por la rendija y humo saliendo por ella. La tapa suelta se dibuja aparte:
  debajo se pinta la boca abierta (sin el cuerno) solo donde estaba la tapa (`bocaSinTapa`).
- **Señales sin texto:** un toque en algo que se mueve lo hace asomar con el sonido de holgura. Los textos largos de
  cada gesto salen solo la primera vez; después, uno corto («Gírala en círculo», «Arrastra hacia arriba»). Los
  grandes desbloqueos (el cuerno y el ojo de piedra de luna) suenan con el desbloqueo grave.
- **«Girar» va arriba**, junto a la pista y el sonido. Abajo a la izquierda tapaba el pie del incensario y se llevaba
  sus toques (fallo 1 de la auditoría).

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
- **Los cajones:** su forma en metros sale de `capas/cajones.json`. Se abren tirando de ellos y se cierran
  empujándolos (un muelle con rebote y golpe seco); los de cerradura resisten sin moverse; al despertar, todos
  traquetean. Tocar uno de lejos lleva la cámara a la vista del costado.
- **Los gestos** (`gestoEn`, `empezarGesto`, `moverGesto`, `actualizarGesto` y `soltarGesto`): al apoyar el dedo se
  mira qué hay debajo; el gesto empieza cuando el dedo se mueve y, si no era para eso, el arrastre gira la caja o, en
  la sala, mueve la cámara. Por dónde se tira de un cajón o se desliza una tablilla sale de su línea en la pantalla
  (dónde está cerrada y dónde abierta). El dedo marca adónde va la pieza y `actualizarGesto` la lleva en cada cuadro,
  con su retraso, sus muescas y sus topes.
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
  transiciones, un vaivén lento de cámara en mano y sacudidas. En la sala, arrastrar mira alrededor; de cerca, la
  cámara se queda quieta. Pellizcar acerca o aleja alrededor de los dedos.
- **La caja gira:** con el botón «Girar» o arrastrándola con el dedo desde la sala o la vista de la caja.

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
# los cuatro sonidos del vocabulario (holgura, clac, pestillo y desbloqueo), a 22 kHz
python3 puzles/ilustrada/herramientas/sonidos_vocabulario.py

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

# prueba automática: juega la partida entera con gestos de móvil y saca capturas (el juego es horizontal; en
# vertical solo comprueba el aviso de girar el móvil)
node puzles/ilustrada/prueba/jugar.mjs B horizontal <carpeta de capturas>
node puzles/ilustrada/prueba/jugar.mjs A horizontal <carpeta de capturas>
node puzles/ilustrada/prueba/jugar.mjs B vertical <carpeta de capturas>
node puzles/ilustrada/prueba/jugar_nivel2.mjs horizontal <carpeta de capturas>
```

- **Resultado (05-10-2026, 0.3, con el tacto y el vocabulario de sonido):** el nivel 1, 34 de 34 en la B y en la A
  (en horizontal); el nivel 2, 28 de 28. La web del APK 0.3, sin red: 36 de 36 y 30 de 30.
- **Resultado (03-10-2026, noche, con los gestos):** el nivel 1, 34 de 34 en la B y en la A (en horizontal); el
  aviso de girar el móvil en vertical, 3 de 3; el nivel 2, 28 de 28. La web del APK 0.2, sin red: 36 de 36 y 30 de
  30. Antes de los gestos: 24 de 24 y 25 de 25.
- **La prueba** usa Playwright y el Chromium del contenedor de Claude (`/opt/pw-browsers`). Comprueba esto:
  - que en horizontal no hay aviso y en vertical sí (y que se va al girar);
  - que los cajones empiezan cerrados, que tocar uno de lejos solo acerca la cámara, que un toque no lo abre y que
    tirando con el dedo sí (arrastres de verdad por su línea);
  - que de cerca la cámara se queda fija al tocar otra cosa;
  - que la llave resiste mientras el ojo mira, que un cajón con cerradura no cede al tirón y que la lámpara distrae;
  - pellizcar: acerca la vista y, alejándose del todo, vuelve a la caja;
  - la llave a la bandeja, el cajón vacío que se cierra empujándolo y la nota (se lee, se guarda y queda en la
    bandeja);
  - examinar un objeto manteniéndolo pulsado;
  - la espalda de la caja y su cajón largo;
  - que el incensario no se abre sin la llave; la llave en la cerradura, medio giro que no basta y el giro entero
    con el dedo en círculo;
  - la tapa: soltada pronto cae en su sitio; arrastrada hacia arriba queda en la mesa; el cuerno y el despertar;
  - la tarjeta del nivel 1 (en la A, que el nivel 2 necesita 3D);
  - volver a empezar (cajones cerrados y bandeja vacía);
  - y que no haya errores en la consola.
- **La prueba del nivel 2** empieza con «Seguir» en la portada y comprueba que un toque en la trampilla solo avisa
  y que tirando hacia arriba sube la caja hija; una tablilla fuera de orden; la de arriba vista por el ojo (ni
  tocándola ni deslizándola se mueve); que la lámpara ya no distrae; que un toque en la tablilla que toca solo la
  hace asomar; las cinco tablillas (cada una puesta de cara con arrastres de verdad al lado de la caja y deslizada
  con el dedo); el cajoncito (asoma con un toque y sale tirando); la cajita, su tapa, el ojo en la cuenca, la
  tarjeta y la partida guardada.
- **La B necesita WebGL.** Sin tarjeta gráfica se usa SwiftShader, que es lento (unos 3-11 cuadros por
  segundo). Por eso las esperas de la prueba van en tiempo de juego y comprobando el estado.
- **Antes de tocar algo**, la prueba comprueba que bajo el dedo está de verdad (y no el canto de una silueta) y que
  no hay un botón a menos de 14 px: el navegador del móvil lleva el toque al botón más cercano. Si no, vuelve antes
  a la sala.
- **Three.js** viene de jsDelivr: la prueba lo descarga con el `fetch` de Node y se lo pasa a la página.
- **Ganchos para probarla:** la página deja `window.__prueba` (estado, ojo, reloj, técnica, cara de la caja,
  ir a una vista, girar, dónde tocar para cada punto del boceto, el centro de cada cajón, cuánto está abierto,
  por dónde se tira de él, cuánto ha girado la llave, la lupa del pellizco, apartar el temblor solo de la llama y
  el inventario; y, del nivel 2, la caja hija, dónde tocar cada parte, por dónde se desliza, si el ojo ve una
  tablilla y la cajita) y `window.__tec`.
- **Para publicarla de nuevo** en la misma página privada: la herramienta Artifact, con `pagina/index.html`
  y, en `files`, los tres `.js` y todo `capas/` y `sonidos/`. La raíz es `pagina/`.

## Lo que falta para un juego [Opinión]

- **Más resolución:** la herramienta de hoy da 1376 × 768. Al acercarse en un móvil se ve algo blando, y
  la versión final pide 2K o 4K.
- **Los niveles 3 y final** (`NIVELES.md` §6 y §7).
- **El APK:** hecho, la página empaquetada tal cual (`apk/`). Para Google Play faltaría subir el SDK objetivo a
  35 y el AAB firmado con una clave de publicación.
