# La caja viva ilustrada (prueba de estilo, 03-10-2026)

**Por qué existe.** El usuario vio la prueba de Blender y dijo que no se parecía nada al boceto. Le
gustó la imagen del boceto, con su toque tétrico y misterioso, y pidió que el juego tenga ese estilo
animado y sea interactivo. Esta prueba responde a eso: es la ilustración misma (la A+C de frente,
`../bocetos/caja_viva_ac.jpg`), animada por capas y jugable. La técnica es la DECISIÓN 29
(`../PLAN.md` §7), que sigue **abierta**.

- **Para jugarla:** página privada https://claude.ai/artifact/7fC2cECS62soiVNBa2kMG3 (solo la puede abrir el
  usuario). Funciona en el móvil, mejor en horizontal y con sonido.
- **Recorrido (unos 3 minutos):**
  1. la llave del cajón de abajo, que la caja no deja coger mientras el ojo te mira (la lámpara lo distrae);
  2. la llave abre el incensario y el león deja la tapa en la mesa;
  3. el cuerno de las brasas va al hueco de la frente;
  4. la caja despierta.
- **La nota del cajón** da la pista: «Me falta un cuerno. Lo guarda el león que respira humo».

## Qué hay

| Ruta | Qué es |
|---|---|
| `fuentes/` | Las cinco ilustraciones de Gemini, todas con el mismo encuadre (1376 × 768) |
| `preparar_capas.py` | Recorta de ellas las piezas y los parches de cada estado, y pasa los sonidos a 22 kHz |
| `pagina/index.html` | El juego: un lienzo con la ilustración, las capas y los efectos, más la interfaz |
| `pagina/capas/` | Lo que genera el guion: WebP con transparencia y `capas.json` con la posición de cada uno |
| `pagina/sonidos/` | Los sonidos del juego de Godot (`generar_sonidos.py`) a 22 kHz |
| `prueba/` | `servir.py` (servidor local) y `jugar.mjs` (prueba automática) |

### Las fuentes

| Archivo | Qué cambia respecto a la sala | SHA-256 (inicio) |
|---|---|---|
| `sala.jpg` | Es el boceto de la A+C (el de `bocetos/`, en su calidad original) | `3bde8202` |
| `sala_sin_llave.jpg` | El cajón de abajo, sin la llave (Gemini quitó también la nota: no se usa esa parte) | `e916bf0c` |
| `incensario_abierto.jpg` | Sin la tapa: brasas, el cuerno asomando y más humo | `00bd5b12` |
| `incensario_vacio.jpg` | El incensario abierto, ya sin el cuerno | `9150182f` |
| `despierta.jpg` | La caja despierta: ojos rojos, humo, trampilla abierta (puso un cuerno de más: se quita al recortar) | `5b3eb606` |

**Cómo se hicieron:** Gemini (`gemini-3.1-flash-image`) editando la anterior. El prompt siempre empieza
igual: «Edit this exact image and keep everything identical: same composition, same camera, same
hand-drawn ink and watercolor style… Change only…». Después dice qué cambia, y termina con «Nothing
else changes».

- Salen alineadas al píxel con la original. Se comprobó con correlación de fase: desplazamiento 0, 0.
- Salen unos 2 niveles más oscuras; el guion lo iguala.
- Coste de los cuatro retoques: unos 0,18 USD **[Estimación]**.

## Cómo funciona la página

- **La ilustración compuesta:** la sala más los cambios que ya han pasado (cajón vacío, incensario
  abierto, la tapa en la mesa, el cuerno puesto). Se rehace al cambiar de estado.
- **La caja respira:** se dibuja otra vez con el borde difuminado (`caja_mascara`) y una escala mínima
  que sube desde la peana. Si la fuerzas, contiene el aliento.
- **El ojo:**
  - el hueco entre los párpados se rellena sin iris (`ojo_vacio`);
  - el iris (`iris`) se mueve dentro de ese hueco con un muelle rápido, como los ojos de verdad;
  - el párpado que parpadea o se entorna se pinta con el color de la madera;
  - mira el dedo; si nadie lo toca, mira la sala; cuando la llama tiembla, mira la lámpara.
  - **La regla de la caja viva:** «no deja tocar mientras te ve». Un parpadeo no cuenta: es demasiado
    corto para aprovecharlo.
- **El humo:** cintas que se retuercen, con borde a tinta, como el de la ilustración. Las bocanadas de
  las juntas son nubes suaves.
- **La luz:** el resplandor de la lámpara (tiembla sola de vez en cuando, y así se aprende que el ojo la
  mira), las brasas, las motas de polvo y, al despertar, los ojos que laten y la luz de la trampilla.
- **La cámara:** tres vistas (sala, caja e incensario) y la cara para el final, con un vaivén lento de cámara
  en mano. En vertical, la sala sigue arriba y abajo, muy difuminada.
- **Los objetos:** se tocan para elegirlos y luego se toca dónde usarlos, o se arrastran.

## Comandos

```
# rehacer las capas y los sonidos de la página
python3 puzles/ilustrada/preparar_capas.py

# probarla en local (la página es un fragmento: el servidor le pone doctype y head, como al publicarla)
python3 puzles/ilustrada/prueba/servir.py &          # http://localhost:8765/

# prueba automática: juega la partida entera con toques de móvil, comprueba cada paso y saca capturas
node puzles/ilustrada/prueba/jugar.mjs horizontal <carpeta de capturas>
node puzles/ilustrada/prueba/jugar.mjs vertical <carpeta de capturas>
```

- **Resultado:** 14 de 14 en las dos orientaciones (03-10-2026).
- **La prueba:** usa Playwright y el Chromium del contenedor de Claude (`/opt/pw-browsers`). Comprueba
  esto:
  - que la llave resiste mientras el ojo mira y que la lámpara lo distrae;
  - que la nota se abre y se cierra;
  - que el incensario no se abre sin la llave;
  - la tapa en la mesa, el cuerno y el despertar;
  - volver a empezar;
  - y que no haya errores en la consola.
- **Ganchos para probarla:** la página deja `window.__prueba` (estado, ojo y paso de coordenadas de la
  ilustración a la pantalla).
- **Para publicarla de nuevo** en la misma página privada: la herramienta Artifact, con
  `pagina/index.html` y, en `files`, todo `capas/` y `sonidos/`. La raíz es `pagina/`.

## Lo que falta para un juego [Opinión]

- **Más resolución:** la herramienta de hoy da 1376 × 768. Al acercarse en un móvil se ve algo blando, y
  la versión final pide 2K o 4K.
- **Más vistas pintadas:** la cara de cerca, el costado de los cajones y la parte de atrás. Para que
  encajen entre sí, se puede usar el modelo de Blender como maqueta y que Gemini lo pinte.
- **La mecánica completa** de la caja viva (19 pasos) sobre este estilo.
- **El APK:** se propone pasar el núcleo a Godot 2D, y la firma sigue pendiente.
