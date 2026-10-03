# La caja viva ilustrada: tres técnicas (03-10-2026)

**Por qué existe.**
- El usuario vio la prueba de Blender y dijo que no se parecía nada al boceto. Le gustó la imagen del
  boceto, con su toque tétrico y misterioso, y pidió el juego en ese estilo animado e interactivo.
- La primera versión de esta página fue la ilustración misma (la A+C de frente, `../bocetos/caja_viva_ac.jpg`),
  animada por capas y jugable.
- Después pidió hacer las tres opciones de la DECISIÓN 29 (`../PLAN.md` §7, que sigue **abierta**), con
  movimiento y animación de cámara.
- Las tres están en la misma página, con el mismo recorrido:
  - **A · Ilustración por capas:** la pintura se mueve con profundidad y la caja gira como un teatro de papel.
  - **B · Pintura sobre 3D:** la pintura proyectada sobre una caja, una mesa y una sala sencillas en 3D. La
    caja gira de verdad.
  - **C · 3D con acuarela:** el modelo de Blender con tinta y acuarela; la sala sigue pintada.

**Para jugarla:** página privada https://claude.ai/artifact/7fC2cECS62soiVNBa2kMG3 (solo la puede abrir el
usuario).
- Funciona en el móvil, mejor en horizontal y con sonido.
- La técnica se elige en la portada y se cambia jugando con los botones A, B y C de arriba.

**Recorrido (unos 3 minutos):**
1. la llave del cajón de abajo, que la caja no deja coger mientras el ojo te mira (la lámpara lo distrae);
2. la llave abre el incensario y el león deja la tapa en la mesa;
3. el cuerno de las brasas va al hueco de la frente;
4. la caja despierta.

La nota del cajón da la pista: «Me falta un cuerno. Lo guarda el león que respira humo». Detrás de la caja
hay más cajones, un hueco con forma de ficha de shōgi y un cajón largo con otra cerradura (para cajas futuras).

## Qué hay

| Ruta | Qué es |
|---|---|
| `fuentes/` | Las ilustraciones de Gemini, todas con el mismo encuadre (1376 × 768) |
| `preparar_capas.py` | Recorta de ellas las piezas, los parches de cada estado y las siluetas, y pasa los sonidos a 22 kHz |
| `herramientas/camara_boceto.py` | Calcula la cámara desde la que está pintado el boceto (`pagina/capas/camara.json`) |
| `herramientas/escena_boceto.py` | Ajusta la sala, la mesa, la peana y los objetos a esa cámara (`pagina/capas/escena.json`) |
| `herramientas/modelo_web.py` | Aligera los modelos de Blender para la técnica C (de 9 a 2,2 MB): `pagina/modelos/` |
| `pagina/index.html` | La página: la interfaz, el estilo y el mapa de módulos (Three.js r170 desde jsDelivr) |
| `pagina/juego.js` | Todo lo común: estado y recorrido, ojo, respiración, humo, luz, sonido, toques y la técnica A |
| `pagina/tecnica_3d.js` | Las técnicas B y C (se cargan solo al elegirlas) |
| `pagina/escena3d.js` | La sala del boceto en 3D y el material que proyecta la pintura |
| `pagina/capas/`, `pagina/sonidos/`, `pagina/modelos/` | Lo que generan los guiones |
| `prueba/` | `servir.py` (servidor local) y `jugar.mjs` (prueba automática) |

### Las fuentes

| Archivo | Qué cambia respecto a la sala | SHA-256 (inicio) |
|---|---|---|
| `sala.jpg` | Es el boceto de la A+C (el de `bocetos/`, en su calidad original) | `3bde8202` |
| `sala_sin_llave.jpg` | El cajón de abajo, sin la llave (Gemini quitó también la nota: no se usa esa parte) | `e916bf0c` |
| `incensario_abierto.jpg` | Sin la tapa: brasas, el cuerno asomando y más humo | `00bd5b12` |
| `incensario_vacio.jpg` | El incensario abierto, ya sin el cuerno | `9150182f` |
| `despierta.jpg` | La caja despierta: ojos rojos, humo, trampilla abierta (puso un cuerno de más: se quita al recortar) | `5b3eb606` |
| `sala_detras.jpg` | La caja girada media vuelta en su sitio: la espalda, con cajones, un hueco de ficha y una borla | `5e9e55dd` |
| `sala_mesa_vacia.jpg` | La mesa sin la caja ni los objetos | `715c0a7c` |
| `sala_vacia.jpg` | La sala sin la mesa | `4219b267` |

**Cómo se hicieron:** Gemini (`gemini-3.1-flash-image`) editando la anterior.
- El prompt siempre empieza igual: «Edit this exact image and keep everything identical: same composition,
  same camera, same hand-drawn ink and watercolor style… Change only…». Después dice qué cambia, y
  termina con «Nothing else changes».
- Salen alineadas al píxel con la original. Se comprobó con correlación de fase: desplazamiento 0, 0.
- Salen unos 2 niveles más oscuras; el guion lo iguala en las capas que se superponen.
- Coste de los siete retoques: unos 0,32 USD **[Estimación]**.

## Cómo funciona

**Lo común a las tres técnicas**
- **La ilustración compuesta:** la sala más los cambios que ya han pasado (cajón vacío, incensario
  abierto, el cuerno puesto, el despertar). Se rehace al cambiar de estado.
- **Las planchas:** la pintura original y, solo detrás de cada objeto, lo que Gemini pintó en la sala vacía
  o en la mesa vacía. Quieta, la escena es el boceto exacto; al moverse, detrás de cada cosa hay algo.
- **El ojo:**
  - el iris se mueve con un muelle rápido, como los ojos de verdad, y el párpado parpadea o se entorna;
  - mira el dedo; si nadie lo toca, mira la sala; cuando la llama tiembla, mira la lámpara;
  - **la regla de la caja viva:** «no deja tocar mientras te ve». Un parpadeo no cuenta: es demasiado corto
    para aprovecharlo.
- **La respiración, el humo y la luz:**
  - la caja respira y, si la fuerzas, contiene el aliento;
  - el humo sube en cintas con el borde a tinta;
  - hay bocanadas por las juntas, la luz de la lámpara, las brasas, motas de polvo y, al despertar, los
    ojos rojos y la luz de la trampilla.
  - En B y C todo eso se dibuja encima, anclado a su sitio en 3D.
- **La cámara:** cuatro vistas (sala, caja, incensario y la cara del final) con transiciones, un vaivén
  lento de cámara en mano y sacudidas. Arrastrar mueve la cámara y pellizcar acerca.
- **La caja gira:** con el botón «Girar»; en B y C también arrastrándola con el dedo, y en A deslizándola.

**A · Ilustración por capas** (`juego.js`, en un lienzo 2D)
- La sala y la mesa se dibujan por franjas de 16 px. Cada franja se desplaza según su profundidad (sacada
  de la escena 3D).
- Lo que asoma por los bordes se rellena estirando la última columna.
- La caja se estrecha al girar y, pasada la mitad, aparece su espalda (el boceto de espaldas).

**B · Pintura sobre 3D** (`tecnica_3d.js` y `escena3d.js`)
- Cada superficie toma su color de la pintura vista desde la cámara del boceto (proyección).
- La caja guarda la posición en la que se pintó, así que la pintura gira con ella.
- El frente, la derecha y la tapa salen del boceto de frente; la espalda y la izquierda, del de espaldas.
- Los cajones abiertos tienen su propio bloque, recortado con la silueta de la caja.
- El incensario, la tetera y las tazas son cilindros recortados con su silueta (un poco más estrecha, para
  que no se vea un halo al girar).
- El ojo es un trocito de lienzo que se repinta en cada cuadro dentro de la textura de la caja.

**C · 3D con acuarela** (`tecnica_3d.js`)
- `modelos/caja_viva.json` y `modelos/mesa.json` (glTF con la geometría dentro; las texturas, en JPEG aparte), con material de dibujo animado (bandas de luz), papel,
  manchas de pigmento, bordes más oscuros y contorno a tinta (la malla un poco hinchada y vuelta del revés).
- El ojo se pinta en la textura de la cara: el iris se mueve, el párpado baja y, al despertar, brilla en rojo.
- Lo mecánico es 3D: la tapa con el león vuela a la mesa, hay brasas que se mueven, el cuerno se pone en el
  hueco y la trampilla se abre con luz.
- Cada pieza del modelo representa un sitio del boceto: tocar el cajón de la llave es tocar la llave. Así
  las tres técnicas comparten el mismo recorrido.

## Comandos

```
# rehacer las capas, las siluetas y los sonidos de la página
python3 puzles/ilustrada/preparar_capas.py

# la cámara del boceto y la escena (solo si cambia el boceto)
python3 puzles/ilustrada/herramientas/camara_boceto.py
python3 puzles/ilustrada/herramientas/escena_boceto.py

# los modelos ligeros de la técnica C (Blender por código, sin ventana)
/root/herramientas/blender-4.5.14-linux-x64/blender -b --factory-startup --python puzles/ilustrada/herramientas/modelo_web.py

# probarla en local (la página es un fragmento: el servidor le pone doctype y head, como al publicarla)
python3 puzles/ilustrada/prueba/servir.py &          # http://localhost:8765/

# prueba automática: juega la partida entera con toques de móvil en la técnica elegida y saca capturas
node puzles/ilustrada/prueba/jugar.mjs A horizontal <carpeta de capturas>
node puzles/ilustrada/prueba/jugar.mjs B vertical <carpeta de capturas>
```

- **Resultado (03-10-2026):** 18 de 18 en A y 20 de 20 en B y C, en horizontal y en vertical.
- **La prueba** usa Playwright y el Chromium del contenedor de Claude (`/opt/pw-browsers`). Comprueba esto:
  - que la llave resiste mientras el ojo mira y que la lámpara lo distrae;
  - la nota;
  - la espalda de la caja y su cajón largo;
  - que el incensario no se abre sin la llave;
  - la tapa en la mesa, el cuerno y el despertar;
  - en B y C, cambiar de técnica a mitad de partida;
  - volver a empezar;
  - y que no haya errores en la consola.
- **B y C necesitan WebGL.** Sin tarjeta gráfica se usa SwiftShader, que es lento (unos 3-11 cuadros por
  segundo). Por eso las esperas de la prueba van en tiempo de juego y comprobando el estado.
- **Three.js** viene de jsDelivr: la prueba lo descarga con el `fetch` de Node y se lo pasa a la página.
- **Ganchos para probarla:** la página deja `window.__prueba` (estado, ojo, reloj, técnica, cara de la caja,
  ir a una vista, girar y dónde tocar para cada punto del boceto) y `window.__tec`.
- **Para publicarla de nuevo** en la misma página privada: la herramienta Artifact, con
  `pagina/index.html` y, en `files`, los tres `.js` y todo `capas/`, `sonidos/` y `modelos/`. La raíz es
  `pagina/`.

## Lo que falta para un juego [Opinión]

- **Más resolución:** la herramienta de hoy da 1376 × 768. Al acercarse en un móvil se ve algo blando, y
  la versión final pide 2K o 4K.
- **Si se elige la B:** pintar los costados de la caja. Con solo el frente y la espalda, a partir de unos
  30° de giro la pintura se estira.
- **Si se elige la C:** modelar bien cada objeto. El incensario de la prueba de Blender es tosco.
- **La mecánica completa** de la caja viva (19 pasos) sobre la técnica elegida.
- **El APK:** la página ya funciona en el móvil. Falta decidir si se empaqueta tal cual o se pasa a Godot,
  y la firma sigue pendiente.
