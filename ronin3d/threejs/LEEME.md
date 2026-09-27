# RONIN · Capítulo 1 — versión Three.js (estética HD-2D)

Versión 3D del capítulo 1 (el patio del castillo de Hoshiyama, de noche) hecha con
**Three.js r170** en el navegador. Sigue la especificación común `../DISENO_3D.md`
(medidas, personajes, cámara, controles, HUD, sprites y texturas de `../recursos/`) y
los textos de `../../samurai.py`.

## Cómo abrirlo

- **Doble clic en `ronin3d.html`.** Es un único archivo: el código y las imágenes van
  dentro (las imágenes como data URI). Solo necesita internet para descargar Three.js
  desde `cdn.jsdelivr.net` (el navegador lo guarda en caché). Necesita WebGL 2. Solo se
  ha probado en Chromium (sin ventana, en la prueba automática); debería funcionar en
  Chrome, Edge, Firefox y Safari recientes, pero no se ha comprobado.
- **O con un servidor local** (por si algún navegador pone pegas con `file://`):

  ```
  python3 -m http.server 8000
  ```

  y abrir <http://localhost:8000/ronin3d.html>.
- Opción: `ronin3d.html?sinpost` desactiva el post-proceso (bloom y desenfoque), para
  equipos muy lentos.

## Controles

| Tecla | Acción |
| --- | --- |
| W A S D / flechas | Moverse (relativo a la cámara) |
| SHIFT | Correr |
| ESPACIO | Saltar |
| J / clic izquierdo | Atacar con la espada |
| Q / E, botón derecho + arrastrar | Girar la cámara (el arrastre también inclina) |
| Rueda, + / − | Zoom (7 a 18 m) |
| R / F | Inclinar la cámara (−5° a 60°) |
| ENTER (o ESPACIO, o tocar) | Continuar en los textos |
| ESC | Pausa (Q en pausa: salir al título) |

**Pantallas táctiles** (solo aparecen en ellas): joystick virtual a la izquierda (al
borde, corre), botones *Saltar* y *Atacar* a la derecha, botón de pausa, y arrastrar un
dedo por la zona libre de la pantalla gira e inclina la cámara. Tocar continúa en los textos.

## Archivos

| Archivo | Qué es |
| --- | --- |
| `ronin3d_fuente.html` | Plantilla con todo el código (HTML, CSS y JS). Las imágenes van como marcadores `{{akira.png}}`. **Es el archivo que se edita.** |
| `construir.py` | Sustituye los marcadores por los PNG de `../recursos/` en base64 y escribe `ronin3d.html`. |
| `ronin3d.html` | El juego generado (no se edita a mano). |
| `prueba/prueba.mjs`, `prueba/package.json`, `prueba/package-lock.json` | Prueba automática con Playwright (sin `node_modules`: se instala con `npm install`). |

Después de cambiar la plantilla o los recursos: `python3 construir.py`.

## Qué está hecho

- **Flujo completo**: introducción (título, subtítulo y texto letra a letra, ENTER) →
  patio → tocar el portón → texto de cierre (ENTER vuelve al título). Con la vida a 0:
  «Akira ha caído» → ENTER para reintentar. Fundidos entre escenas y pausa con ESC.
- **Presentación** durante la intro: plano fijo desde (6, 3, 12) mirando a (0, 9, −20)
  con un leve vaivén; al pulsar ENTER la cámara pasa en 1 s a la órbita sobre Akira.
  El texto de cierre usa el mismo plano del torreón.
- **Patio con las medidas exactas**: suelo de losas 48 × 32, terreno exterior, muros con
  base de piedra de 1,2 m, yeso y tejadillo de tejas (1,6 × 0,4), portón macizo con
  postes, dintel y tejado, pasarela con escalón, muro bajo, bloques A y B, cuatro linternas
  de piedra con luz tenue, pozo con tejadillo sobre dos postes, tres cajas (una encima) y
  dos barriles. **Torreón** al norte con base de piedra, tres pisos con tejados, remate
  dorado y ventanas iluminadas. Texturas pixel art de `recursos/` con filtro *nearest* y
  repetidas una vez por metro (el portón usa su textura entera, sin estirar).
- **Noche**: cielo en degradado (#06081a → #2a244c) con estrellas que titilan, luna grande
  (`luna.png`) en normalizar(−0.3, 0.32, −0.9) detrás del torreón, luz de luna #9fb4ff con
  sombras, luz ambiente #1a1f3a, niebla suave y **8 antorchas** con luz #ffae5c de 9 m que
  parpadea y llama animada con los 4 cuadros de `fuego.png`.
- **Akira**: sprite *billboard* vertical (solo gira en Y) en un `PlaneGeometry` con
  `MeshLambertMaterial`, `alphaTest` y `NearestFilter`; el cuadro se elige con
  `offset/repeat` y se voltea con `repeat.x` negativo. Vista frente/espalda/lado con la
  regla f·v de la especificación, paso A/B cada 0,15 s (0,1 s corriendo), ataque en dos
  cuadros, `sombra.png` bajo los pies y efecto `tajo.png` durante el corte. Se mueve
  relativo a la cámara (5 m/s, 8 m/s con SHIFT), salta 7,5 m/s con gravedad 22 (sube
  1,28 m), choca con muros, obstáculos y portón (cajas AABB y cilindros) y puede subirse a
  la pasarela, al escalón, a los bloques, a las cajas y al brocal del pozo (la prueba lo
  comprueba con los dos bloques y la pasarela).
- **Seis soldados** con la IA de la especificación: patrulla A↔B a 2 m/s, visión de 9 m en
  un cono de 120° (o 3 m alrededor) con línea de visión, persecución a 3,5 m/s con correa
  de 8 m, aviso «!» de 0,5 s, estocada de 0,2 s (alcance 2,1 m, ancho 0,8 m; se esquiva
  saltando), recuperación 0,6 s, aturdido 0,4 s con retroceso, muerte que cae de lado y se
  desvanece en 1,2 s, y vuelta a la patrulla si pierden de vista a Akira 2 s. 2 de vida.
- **Combate**: espada con alcance 1,6 m en un cono de 100°, corte entre 0,05 y 0,2 s,
  enfriamiento 0,4 s y un golpe por soldado y ataque; chispas al golpear. Akira tiene 5
  de vida, 1 s de invulnerabilidad (parpadea) y retroceso de 6 m/s durante 0,25 s.
- **Cámara orbital** exactamente como la especificación: giro, inclinación, distancia,
  punto mirado a pies + h (1,0 m a ≥ 30°, hasta 2,2 m a −5°), FOV 38, suavizado del
  seguimiento. Q/E a 90°/s, botón derecho + arrastrar, rueda y + / −, R / F.
- **HUD** en HTML/CSS: «AKIRA» con 5 rombos, «Soldados derrotados: n/6», ayuda de
  controles los primeros 10 s, «!» rojo sobre el soldado que va a atacar y
  «Three.js · HD-2D» abajo a la derecha.
- **Post-proceso**: *bloom* suave (`UnrealBloomPass`: llamas, ventanas, luna, tajo) y un
  pase propio de efecto maqueta (desenfoque que crece hacia arriba y hacia abajo) con
  viñeta; tono *Neutral* de Khronos. Si el post-proceso fallara al crearse, el juego sigue
  sin él.

## Prueba automática

```
cd prueba
npm install        # Playwright 1.56.1 (usa el Chromium ya instalado; no descarga navegadores)
node prueba.mjs
```

Sirve la carpeta con `http.createServer`, abre `ronin3d.html` en Chromium sin ventana con
WebGL por software (`--use-gl=angle --use-angle=swiftshader --enable-unsafe-swiftshader`)
y lee `window.estadoJuego` (una instantánea congelada, de solo lectura). Falla si hay
errores en la consola o excepciones. Comprueba, simulando teclas y ratón:

- intro con los textos de `samurai.py`, post-proceso activo y cámara de presentación;
- el patio: posición inicial, cámara por defecto (d 12, 38°, −60°, FOV 38), HUD completo;
- combate: atacar con J cerca del soldado 1 le quita vida; el segundo golpe lo derrota,
  cae, desaparece y el contador sube a 1/6;
- cámara baja (−5°) mirando al norte: se ven el torreón y la luna;
- caminar ≈ 5 m/s en la dirección de la cámara, correr ≈ 8 m/s, saltar ≈ 1,28 m;
- Q/E, + / −, rueda, R/F y botón derecho + arrastrar mueven la cámara;
- Akira no atraviesa los muros oeste y norte; sube de un salto al bloque A y de ahí al B,
  y desde el suelo a la pasarela;
- los soldados avisan con «!» antes de la estocada; con la vida a 0 sale «Akira ha caído»
  y ENTER reinicia el patio;
- llegar al portón muestra el texto de cierre; ESC pausa y Q en pausa vuelve al título;
- el HTML también funciona abierto como archivo (`file://`);
- en un móvil emulado (pantalla táctil): tocar continúa los textos, aparecen los controles
  táctiles, el joystick mueve a Akira, los botones atacan y saltan y arrastrar gira la cámara.

Guarda en `../../capturas/`: `threejs_intro.png`, `threejs_patio.png`,
`threejs_camara_girada.png`, `threejs_combate.png`, `threejs_torreon.png`,
`threejs_cierre.png` (1280 × 720) y, además, `threejs_tactil.png` (móvil, 800 × 400).

Detalles de la prueba:

- El render por software es muy lento, así que los recorridos se hacen en una ventana de
  640 × 360 y las capturas y la medida de FPS a 1280 × 720.
- Si Chromium no puede llegar a `cdn.jsdelivr.net` (en este entorno, un proxy con
  certificado propio que el Chromium sin ventana no reconoce), la prueba le sirve los
  archivos de Three.js descargándolos desde Node, que sí valida ese certificado. No se
  desactiva ninguna comprobación TLS.
- Si la versión de Playwright no coincide con el Chromium instalado, busca uno en
  `PLAYWRIGHT_BROWSERS_PATH` (por defecto `/opt/pw-browsers`).

### Resultado de la última ejecución

- **47 de 47 comprobaciones correctas**, sin errores en la consola ni excepciones
  (unos 4 minutos, casi todo por el render por software).
- **FPS en Chromium sin ventana con WebGL por software (SwiftShader, 4 núcleos)**: unos
  **2,3 FPS a 1280 × 720** con post-proceso y unos **5,5 FPS a 640 × 360**. En una prueba
  aparte, sin post-proceso (`?sinpost`), unos 3,7 FPS a 1280 × 720. Son cifras solo
  orientativas: no se ha podido medir en una tarjeta gráfica real.
- Tamaño de `ronin3d.html`: unos 134 KB (14 KB de PNG incrustados).

## Limitaciones y lo que falta

- **Sin sonido** (la especificación no lo pide).
- Necesita **WebGL 2** y conexión para descargar Three.js la primera vez.
- Si el navegador va a menos de 10 FPS, el juego va a cámara lenta en vez de saltar (se
  simulan como mucho 0,1 s por fotograma). Por encima de 10 FPS no se nota nada.
- En móviles se reduce la resolución interna (máximo 1,5 × la densidad de píxeles) y no
  se usa antialiasing en el post-proceso, para que vaya fluido.
- Los controles táctiles se han probado en Chromium con un móvil emulado, no en un
  teléfono real.

## Desviaciones de la especificación (y por qué)

- **Cámara y muros**: si un muro del recinto se interpone entre la cámara y Akira y la
  cámara quedaría por debajo de su parte alta, la cámara se acerca lo justo (como en
  cualquier juego en tercera persona); si la cámara está por encima del muro, no se mueve
  y el muro se abre con un agujero tramado alrededor de Akira. Sin esto, al bajar la
  cámara a −5° junto a un muro solo se veía el muro.
- **Soldados en la intro**: esperan quietos en su punto A mientras se lee la intro y
  empiezan a patrullar al entrar en el patio, para que cada partida empiece igual. Con
  las posiciones de la especificación, el soldado 1 (en A mirando hacia B) ve a Akira
  nada más empezar y va a por él.
- **Texto de cierre**: el pie original era «Pulsa ENTER para salir a la planicie»; aquí
  no hay planicie, así que dice «Pulsa ENTER para volver a empezar» y vuelve al título.
  Los tres párrafos son los de `samurai.py`, sin cambios.
- **Iluminación de los sprites**: la parte difusa se «envuelve» (0,6 + 0,4 · N·L) para
  que el sprite no quede negro cuando la luz le llega por detrás; sigue recibiendo la
  luna, las antorchas, las linternas y las sombras de los muros.
- La base de piedra del torreón mide 18 × 18 abajo y se estrecha a 16,6 arriba (muro
  inclinado de castillo japonés); el resto de medidas son las de la especificación.
- El «!», la pose de ataque y el tajo se dibujan al menos en un fotograma aunque el
  fotograma sea más largo que su duración (0,2–0,5 s), para que no se pierdan en equipos lentos.
- La tierra del exterior es una textura generada en el propio código (no hay PNG para
  ella en `recursos/`).
