# RONIN 3D — Comparativa de motores y estéticas

> **Decisión tomada (27-09-2026):** motor **Godot 4.7** y estética **cel-shading**. Este documento
> queda como registro de cómo se decidió. El proyecto de Godot ya solo tiene cel-shading: las
> otras dos estéticas se pueden recuperar del historial de git (commit `8ec4b1b`), y las teclas
> 1, 2 y 3 de la sección 6 solo funcionan en esa versión.

- **Fecha:** 27 de septiembre de 2026 · probado en la nube, sin tarjeta gráfica (OpenGL por software, 4 núcleos).
- **Página con las capturas lado a lado:** https://claude.ai/artifact/6urV5FCikt9CWAUV35gBCu (privada: solo tú puedes abrirla)
- **Jugar la versión Three.js en el navegador:** https://claude.ai/artifact/9QHgv2eQPDdww4HGcbYJaL (privada)
- **Hojas de capturas:** `capturas/comparativa_esteticas.jpg` y `capturas/comparativa_motores.jpg`

El capítulo 1 (el patio del castillo de Hoshiyama, de noche) está hecho cinco veces con la misma
especificación (`DISENO_3D.md`) y los mismos sprites y texturas (`recursos/`): tres estéticas en
Godot y la estética HD-2D en otros dos motores. Así se comparan por separado la estética y el motor.

| Versión | Motor | Estética | Prueba automática | Carpeta |
| --- | --- | --- | --- | --- |
| 1 | Godot 4.7.2 (GDScript) | HD-2D | 9 de 9 | `godot/` (tecla 1) |
| 2 | Godot 4.7.2 (GDScript) | Pixel art 3D | 9 de 9 | `godot/` (tecla 2) |
| 3 | Godot 4.7.2 (GDScript) | Cel-shading | 9 de 9 | `godot/` (tecla 3) |
| 4 | Three.js r170 (JavaScript) | HD-2D | 47 de 47 | `threejs/` |
| 5 | Ursina 7.0 (Python) | HD-2D | 34 de 34 | `ursina/` |

Las capturas de cada versión están en `capturas/` (`godot_<estética>_*.png`, `threejs_*.png`,
`ursina_*.png`). Los planos son los mismos (intro, patio, cámara girada, combate, torreón y cierre),
aunque el encuadre exacto cambia un poco porque cada prueba automática juega a su manera.

---

## 1. Las tres estéticas (en Godot)

Se cambian en caliente con las teclas 1, 2 y 3 sin mover a Akira ni la cámara.

| | HD-2D | Pixel art 3D | Cel-shading |
| --- | --- | --- | --- |
| **Cómo se ve** | Personajes en pixel art que siempre miran a la cámara, dentro de un escenario 3D con texturas pixel art, luz de antorchas, niebla, brillo y desenfoque de maqueta (estilo Octopath Traveler) | Todo 3D, también los personajes (hechos de piezas), dibujado a un tercio de resolución, sin suavizar y con tramado de colores | Modelos 3D con la luz en bandas planas, brillo en los bordes y contorno negro (estilo Zelda: The Wind Waker, Ōkami) |
| **A favor** | Lo más parecido a un juego 2D; sigue el pixel art del prototipo; un personaje nuevo es una hoja de sprites, no un modelo 3D; la que más ambiente tiene de noche | Los personajes se ven bien desde cualquier ángulo; la más ligera (9 veces menos píxeles); animaciones por código | Limpio y muy legible; encaja con la tinta y los grabados del Japón feudal; los modelos giran sin saltos |
| **En contra** | 3 vistas por personaje (frente, espalda, lado): al girar la cámara cambian de golpe; cada animación nueva se dibuja en las 3 vistas; desenfoque y brillo cuestan algo más (se pueden quitar) | Los personajes de ahora son piezas simples y habría que modelarlos mejor; los píxeles tiemblan un poco al mover la cámara; los detalles pequeños se leen peor | Se aleja del pixel art del prototipo; pide modelos más cuidados; el contorno dibuja cada pieza dos veces |
| **FPS en la nube** | 9,5 | 17,6 | 12,3 |
| **Memoria en la prueba** | 458 MB | 415 MB | 454 MB |

FPS medidos mientras Akira camina por el patio, dibujando sin tarjeta gráfica. En un PC normal,
aunque sea modesto, van mucho más rápido; sirven para comparar entre sí.

---

## 2. Los tres motores (con HD-2D)

| Criterio | **Godot 4.7.2** | Three.js r170 | Ursina 7.0 |
| --- | --- | --- | --- |
| Lenguaje | GDScript (parecido a Python) | JavaScript | Python (el del prototipo 2D) |
| Qué instalas | Un solo programa de 78 MB (ya lo usas para Trazzo) | Nada: se abre en el navegador, también en el móvil | Python y `pip install ursina` (unos 135 MB con Panda3D) |
| Editor visual | Sí: escenas, inspector, animaciones | No: todo por código | No: todo por código |
| Android | Sí, APK como Trazzo | En el navegador del móvil; APK solo con un envoltorio | No |
| Windows y web | Sí, exporta a los dos | Sí, la web es su casa | Solo Windows (con Python o empaquetado) |
| Estéticas hechas | Las tres | HD-2D | HD-2D |
| Prueba automática | 9 de 9 | 47 de 47 | 34 de 34 |
| FPS en la nube (HD-2D) | 9,5 | 6,3 | 20,1 |
| Memoria en la prueba | 458 MB | 728 MB | 276 MB |
| Código | 2 260 líneas en 16 archivos, más 310 de prueba | 2 620 líneas en un solo HTML, más 1 040 de prueba | 2 540 líneas en un solo archivo, más 460 de prueba |
| Lo que se vio al probar | HD-2D es la estética que más cuesta (desenfoque y brillo a pantalla completa); Pixel art 3D va casi el doble de rápido. | Funciona abierto como archivo y en el móvil, con controles táctiles. Necesita internet la primera vez. El navegador es lo que más memoria gasta. | El más rápido en la nube y el que menos memoria usa; tiene un modo --ligero para PC justos. |
| Para crecer (planicie, aldea, templo, dojo, ruinas) | Trae escenas, físicas, navegación, animación, interfaz y audio | Físicas, interfaz, sonido y editor hay que añadirlos o hacerlos a mano | Sencillo para empezar; se queda corto en un mundo grande y en móviles |

FPS: medidos en la misma máquina y con el mismo renderizador por software (llvmpipe), a 1280 × 720,
mientras Akira camina por el patio; varían un 20 % de una ejecución a otra. Memoria: lo máximo que
ocupó el juego (en Three.js, todos los procesos de un navegador abierto solo para el juego). Con
tarjeta gráfica real todo cambia, pero sirve para comparar. Cada prueba automática comprueba cosas
distintas, así que el número de comprobaciones no se compara entre motores.

---

## 3. Otras opciones que existen (no probadas)

| Motor | Lenguaje | Por qué no se probó |
| --- | --- | --- |
| Babylon.js | JavaScript (web) | Como Three.js pero con más cosas de motor hechas (colisiones, físicas, interfaz, inspector). **Se podría probar.** |
| PlayCanvas | JavaScript (web) | Motor web con editor en línea; el editor vive en su página. **Se podría probar.** |
| raylib | C (y Python) | Muy ligero, pero básico en 3D: luces, sombras y colisiones a mano. **Se podría probar.** |
| Panda3D | Python | La base de Ursina, con más control y los mismos límites (no llega a Android). Aporta poco sobre Ursina. |
| Defold | Lua | Ligero y muy bueno para móviles, pero pensado para 2D; su 3D es limitado. |
| Bevy | Rust | Moderno y rápido, sin editor; compilarlo pide varios GB de RAM. Pesado para tu PC. |
| Unity | C# | Muy usado, pero el editor ocupa varios GB y pide 8 GB de RAM o más. Pesado para tu PC. |
| Unreal Engine 5 | C++ / Blueprints | El motor del HD-2D original (Octopath Traveler usó Unreal 4); pide un PC potente y más de 100 GB. |
| GDevelop, RPG Maker | Sin programar | Pensados para 2D: no giran la cámara en 3D como queremos. |

---

## 4. Recomendación

- **Motor: Godot.** Es el único de los tres que llega a Android como Trazzo, además de Windows y
  web; tiene editor, ya lo conoces y en él ya están las tres estéticas con la prueba completa.
  Three.js queda útil para enseñar el juego en el navegador; Ursina no conviene porque no llega
  al móvil.
- **Estética: HD-2D.** Es la que más se parece a un juego 2D, conserva el pixel art del prototipo
  y es la que mejor luce de noche con las antorchas. Si prefieres girar la cámara sin que los
  personajes cambien de vista de golpe, la alternativa es Pixel art 3D, que además es la más
  ligera.

## 5. Lo que decides tú

1. **Estética:** HD-2D, Pixel art 3D o Cel-shading (también se pueden mezclar, por ejemplo el
   escenario HD-2D con personajes 3D pixelados).
2. **Motor:** Godot, Three.js o Ursina.
3. **Textos de la intro y el cierre:** son provisionales; revísalos cuando quieras.

## 6. Cómo probarlas en tu PC

Descarga la rama desde GitHub (Code → Download ZIP) o el ZIP de Drive. Abre una cosa pesada a la vez.

- **Godot:** Godot 4.7 → Importar → `ronin3d/godot/project.godot` → F5. Teclas 1, 2 y 3 para
  cambiar de estética.
- **Three.js:** abre `ronin3d/threejs/ronin3d.html` en el navegador (necesita internet la primera
  vez para cargar Three.js), o el enlace de arriba. En el móvil aparecen controles táctiles.
- **Ursina:** con Python instalado, `pip install ursina` y `python ronin3d/ursina/ronin3d_ursina.py`
  (`--ligero` para un PC justo).

## 7. Otros motores que corren en tu PC y APK para los que no lo traen

Investigado el 27-09-2026. **[Hecho]** = comprobado en la fuente; **[Opinión]** = criterio nuestro.

**Tu PC** (Windows, 0,5-1 GB de RAM libre): la documentación de Godot pide 4 GB de RAM para el
editor y 2 GB "podrían bastar" con un sistema ligero **[Hecho]**, y en tu PC ya funciona. Un
motor con un editor más pesado que Godot no conviene **[Opinión]**.

| Motor | ¿Corre en tu PC? | ¿Saca APK? |
| --- | --- | --- |
| **Godot 4.7** (elegido) | Sí, ya lo usas | Sí, directo (como Trazzo) |
| Defold | Probable: su FAQ dice que 4 GB de RAM bastan para proyectos pequeños **[Hecho]** | Sí, sin Android Studio **[Hecho]**; pero sus herramientas están hechas para 2D y en 3D «hay que hacer mucho trabajo pesado uno mismo» **[Hecho]** |
| raylib | Sí, es una librería muy ligera | Sí, compilando con el NDK de Android a mano **[Opinión: costoso]** |
| Three.js, Babylon.js | Sí (en el navegador) | No directamente: ver abajo |
| Ursina, Panda3D | Sí | Experimental: ver abajo |
| Unity, Unreal, Bevy | No recomendables: pesados | Sí, pero no aplica |

**Cómo sacar APK de los que no lo traen:**

- **Three.js (o cualquier juego web):**
  - **PWABuilder** (de Microsoft, código abierto) genera el APK en la nube con Bubblewrap, la
    herramienta de Google para Trusted Web Activities, sin instalar Android Studio **[Hecho]**.
    Pide que el juego esté publicado en una dirección https (por ejemplo GitHub Pages), así que
    **habría que hacerlo público**: lo decides tú.
  - **Capacitor** (Ionic) mete la web dentro de una app nativa; es compatible con WebGL y
    Three.js **[Hecho]**, funciona desde Android 7 (API 24) **[Hecho]** y necesita Android Studio
    y el SDK para compilar.
- **Ursina (Python):** **UrsinaForMobile** es un proyecto de la comunidad para exportar juegos de
  Ursina a Android **[Hecho]**. Se apoya en el soporte de Android de Panda3D 1.11, que su propia
  documentación marca como experimental y «NOT production-ready» **[Hecho]**. Sirve para
  curiosear, no para un juego que queremos publicar **[Opinión]**.

**Recomendación [Opinión]:** no dedicar más tiempo a otros motores. Buscábamos PC + Android, y
Godot ya lo cubre. Si quieres ver la versión Three.js en el móvil como app, la vía más barata es
PWABuilder (unos minutos), pero exige publicarla en internet.

**Fuentes:** [requisitos de Godot](https://docs.godotengine.org/en/stable/about/system_requirements.html) ·
[FAQ de Defold](https://defold.com/faq/faq/) ·
[Defold en Android (Android Developers)](https://developer.android.com/games/engines/defold/defold-configure) ·
[Panda3D: Building for Android](https://docs.panda3d.org/1.11/cpp/distribution/building-for-android) ·
[UrsinaForMobile](https://github.com/PaologGithub/UrsinaForMobile) ·
[Capacitor para Android](https://capacitorjs.com/docs/android) ·
[Capacitor y juegos](https://capacitorjs.com/docs/guides/games) ·
[PWABuilder: APK en la nube](https://github.com/pwa-builder/pwabuilder-google-play)
