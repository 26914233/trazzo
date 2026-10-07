# RONIN — Índice del proyecto

Juego de samuráis en un Japón invadido por yōkai. Akira, guardia del shōgun Takeda, queda como
ronin tras la traición del general Genzo, que pactó con el gran yōkai creyendo proteger Japón.
Busca justicia por fuera y recuperar su honor por dentro. Empieza y termina en el castillo de
Hoshiyama.

**Estado:** prototipo 0.9 del capítulo 1 en **Godot 4.7, con los personajes en pixel art** dentro de
un mundo 3D (desde la 0.9; antes, cel-shading). Jugable con teclado, mando y pantalla táctil.
- Incluye una **galería de criaturas** (pausa → botón, o tecla G) para ver el sistema que permitiría
  construir cientos de monstruos.
- Desde la 0.5 trae los **tres primeros enemigos con modelo detallado** (Aka-oni, kappa y
  Chōchin-obake, página 2 de la galería).
- Desde la 0.6:
  - **Akira es un joven endurecido con una cicatriz en la cara**, con tres skins;
  - le acompaña **Shiro**, su perro, que desentierra **monedas**.
- Desde la 0.7, las monedas se gastan en una **estatua jizō** (+1 de vida) y en el **sastre** (las
  skins, bloqueadas hasta comprarlas), y la partida se guarda.
- Desde la 0.8, **las cabezas ya no son bolas**: pelo en mechones, **caras dibujadas** (ojos, cejas y
  boca son una imagen 2D, como en los juegos de anime en 3D) y línea de dibujo de grosor casi
  constante. Antes y después: `capturas/comparativa_cabezas.jpg`.
- Desde la 0.9, **los personajes son pixel art** (DECISIÓN 20E, tu referencia: Ethra):
  - sprites en 8 direcciones horneados desde los modelos, con todas sus poses y las 4 skins;
  - el mundo sigue en 3D, sin línea negra y con un desenfoque de profundidad al estilo HD-2D;
  - en `capturas/sprites_pixel_art.png` y `capturas/comparativa_pixel_art.jpg`.

- **Combate:** iaidō. Se mantiene y se suelta justo al aviso; con la barra llena hay un corte de
  luna.
- **Animación:** estilo anime limitado, que se puede cambiar a la suave para comparar.
- **APK de prueba para Android:** `ronin-0.9-prueba.apk`, en la carpeta de Drive.
- **Bestiario universal:** 939 criaturas (tu catálogo limpio + ángeles, demonios y yōkai que faltaban), cada
  una con su variante fuerte; ver `BESTIARIO_UNIVERSAL.md`.
- **Decidido:**
  - núcleo + variaciones y lanzamiento por capítulos (opción C), y combate de precisión con iaidō;
  - desde el 02-10-2026, el Akira joven endurecido, el perro Shiro, las monedas para el jizō y el
    sastre (16 A + C), el origen de Shiro y de la cicatriz (17A), la tinta para las ilustraciones de
    la historia (18A) y **el pixel art para los personajes (20E)**.
- **Siguiente hito:** **vertical slice**, base del primer capítulo (ver `PLAN_PRODUCCION.md`).

**Última actualización:** 2 de octubre de 2026

---

## Cómo está organizado

```
ronin/                         (Google Drive: Respaldos Claude › ronin)
├── LEEME.md                   Este índice
├── ronin-0.9-prueba.apk       APK de prueba para instalar en el móvil (Android 7.0 o superior)
├── RONIN_rama_completa.zip    Todo el código y las capturas (copia de la rama de GitHub)
├── 01-Diseno/                 Traspaso, plan, propuesta yōkai, historia, bestiario, especificación…
├── 06-Bestiario/              Catálogo limpio (CSV/JSON), prompts_colab.csv, cuaderno de Colab, imágenes
│                              (cuando se hagan) y tus dos Excel originales en fuentes/
├── 02-Prototipo-2D/           samurai.py (Pygame, un solo archivo)
├── 03-Godot/                  Versión Godot: LEEME, pruebas, huellas SHA-256, capturas y
│                              firma-prueba/ (clave de los APK de prueba; privada)
├── 04-Otros-motores/          Three.js y Ursina (solo como referencia)
├── 05-Arte/conceptos-2d/      Conceptos 2D en PNG a tamaño completo (Higgsfield), al estilo del Bahamut;
│                              las fichas anteriores (para 3D) en fichas/; el nuevo Akira en 4 estilos
│                              en estilos/
├── 05-Arte/modelos3d/         Modelos 3D de enemigos (GLB, el .skp de SketchUp) y sus retratos
└── Versiones anteriores (RONIN)/  APK anteriores (0.2 a 0.8) y capturas retiradas
```

En GitHub (`26914233/trazzo`, rama `claude/ronin-pygame-setup-szn3rn`):

```
CLAUDE.md                      Instrucciones de trabajo para Claude (equipo de videojuegos)
samurai.py                     Prototipo 2D
ronin3d/
├── LEEME.md                   Este índice
├── HANDOFF_RONIN.md           Traspaso para seguir en otra sesión
├── PLAN_PRODUCCION.md         Visión, alcance, vertical slice, riesgos y decisiones
├── PROPUESTA_MUNDO_YOKAI.md   Japón con yōkai, iaidō, planos, animación (decisiones 2-7 cerradas)
├── HISTORIA.md                Sinopsis aprobada (8A, 9A) y la capa del Silencio (DECISIÓN 11, abierta)
├── BESTIARIO.md               Criaturas por capítulos, fichas del capítulo 1 y Bahamut (DECISIÓN 10B cerrada)
├── BESTIARIO_UNIVERSAL.md     El catálogo grande: limpieza, cifras, modelado, rangos, Colab (DECISIONES 12-14)
├── bestiario/                 Catálogo limpio (CSV/JSON), informe de calidad, rúbrica y clasificacion/ (fuente de verdad)
├── colab/                     Cuaderno de Colab para las imágenes del bestiario y su receta
├── DISENO_3D.md               Especificación del patio y de las reglas de combate
├── COMPARATIVA.md             Cómo se eligieron motor y estética (y otros motores y APK)
├── godot/                     El juego (principal)
├── arte/conceptos/            Conceptos 2D de personajes y criaturas (JPG) y su LEEME (estilo y prompts)
├── capturas/                  Capturas: actual/ = versión de hoy (con GIF); el resto, de la comparativa
├── herramientas/              hacer_gifs.py (GIF de la prueba) y bestiario/ (limpiar, clasificar y unir el catálogo)
├── recursos/                  Sprites y texturas pixel art de la comparativa
├── threejs/                   Versión web de la comparativa (referencia)
└── ursina/                    Versión Python de la comparativa (referencia)
```

---

## Decisiones ya cerradas

| Tema | Decisión |
| --- | --- |
| **Historia** | La base de siempre (Akira, Takeda, Genzo, estructura circular en Hoshiyama), con dos cambios tuyos del 1-10-2026: **Takeda es el shōgun** y **Genzo pactó con el gran yōkai** creyendo proteger Japón. No se cambia nada más sin consultar |
| **Mapa** | Castillo, aldea, templo, dojo, ruinas y la planicie que los une |
| **Dirección** | 3D con cámara que gira alrededor |
| **Motor** | Godot 4.7 con el renderizador Compatibility (27-09-2026) |
| **Estética** | Cel-shading (27-09-2026) |
| **Alcance** | Un núcleo (duelo + exploración) y cada lugar como variación; lanzamiento por capítulos, empezando por castillo + planicie + aldea (27-09-2026) |
| **Combate** | Precisión con **iaidō** (1-10-2026) |
| **Mundo** | Japón en la era de los yōkai (1-10-2026) |
| **Bestiario** | Yōkai japoneses con variantes, más criaturas, las de otras tierras y **Bahamut como dragón** (1-10-2026). Las de otras tierras llegan **desde el capítulo 3** (DECISIÓN 10B) y cada criatura tiene su **variante más fuerte** |
| **Sinopsis** | Aprobada tal cual (8A) y el gran yōkai es **Tamamo-no-Mae** (9A), 1-10-2026 |
| **Escenas de historia** | Ilustración 2D con tinta; pixel art solo para los recuerdos de Akira (1-10-2026) |
| **Animación** | Estilo anime limitado, en prueba (1-10-2026) |
| **Farmeo automático** | No: la caza se juega (1-10-2026) |
| **Textos de intro y cierre** | Cambiados el 1-10-2026 (sinopsis aprobada): shōgun Takeda, yōkai y luna roja. Están en el juego desde la 0.4 |
| **Reglas** | Todo en español, nombres de variables en español |

## Propuestas abiertas (no son decisiones)

| Tema | Propuesta | Cuándo se cierra |
| --- | --- | --- |
| **El Silencio (Shijima)** | Una entidad nacida de la oscuridad más callada, que ni los yōkai quieren pisar y rompe el equilibrio. Recomendada: gancho final + rango «silenciado» de cada enemigo | DECISIÓN 11 (`HISTORIA.md` §8) |
| **El gancho del juego** | Precisión de iaidō + el bestiario más grande (la cantidad apoya, no lidera) | DECISIÓN 12 (`BESTIARIO_UNIVERSAL.md`) |
| **Cómo se modelan las icónicas** | Híbrido: piezas para variantes y reskins; prueba de 10 criaturas con imagen → 3D antes de decidir (ahora dentro de la 15) | DECISIÓN 13 |
| **Enemigos con el detalle de un jefe** | Por niveles: modelo propio con esqueleto para jefes e icónicas, unas 100-150 bases detalladas compartidas para el resto y SketchUp para criaturas-objeto y armas; antes, un piloto de esqueleto con el Aka-oni | DECISIÓN 15 (`BESTIARIO_UNIVERSAL.md` §8.2) |
| **Rangos de cada criatura** | Tres: base, alfa (la variante fuerte) y silenciada | DECISIÓN 14 |
| **Regla de respeto cultural** | Los dioses y seres sagrados de religiones vivas no son enemigos (50 entradas) | Salvo que la vetes |
| **Qué hace cada lugar** | Aldea: diálogos y encargos · templo: puzzles de entorno · dojo: técnicas con ritmo · ruinas: exploración y jefe · planicie: viaje y dados | Al construir cada lugar |
| **Bestiario dentro del juego** | Fichas con ilustración y leyenda real al vencer a cada criatura | Al planificar el vertical slice |
| **Modelo de capítulos** | Primer capítulo gratis como demo y el resto de pago, o cada capítulo de pago | Con datos del vertical slice |
| **Dados de la planicie** | Chō-han (par o impar con dos dados) | Al empezar la planicie en 3D |
| **Nombre** | «RONIN» ya lo usan otros juegos: buscar nombre o subtítulo propio | Antes de abrir una página de tienda |
| **Camino al «2D lo más pulido»** | En pausa: con el pixel art (20E) los personajes ya son 2D. Se retoma si se quiere más detalle en los sprites (repaso a mano o mejores modelos para hornear) | DECISIÓN 19 (`PLAN_PRODUCCION.md` §16) |
| **El mundo con los personajes en pixel art** | Texturas de pixel art en los decorados (como Octopath), con la niebla y el desenfoque de la 0.9. Un mundo como el de Ethra pide otro renderizador y mucho arte | DECISIÓN 21 (`PLAN_PRODUCCION.md` §18) |

---

## Lo que bloquea avanzar

1. **Tu prueba del APK 0.9 en el móvil**, ahora con los personajes en pixel art:
   - los FPS (abajo a la derecha; meta: 30 o más);
   - si el iai (mantener y soltar al «!») y el corte de luna se entienden;
   - qué animación prefieres, anime o suave (botón en la pausa);
   - **Shiro y las monedas**, y si los precios del jizō y del sastre (pausa → «Sastre») se sienten
     justos;
   - **la galería de criaturas** (pausa → «Galería de criaturas»): los FPS con los modelos detallados
     (página 2), con 7 y con 24 criaturas a la vez (páginas 5 y 7), y si las siluetas por familia te
     convencen.
2. **DECISIONES 11 a 15 y 21** (`HISTORIA.md` §8, `BESTIARIO_UNIVERSAL.md` y `PLAN_PRODUCCION.md` §18).
   - La 15 es cómo dar a todos los enemigos el detalle que pediste (con el pixel art, las criaturas
     también se hornean en sprites).
   - La 21, cómo es el mundo ahora que los personajes son pixel art.
   - Las 16, 17, 18 y 20 ya están decididas y en el juego; la 19 queda en pausa.
3. **Imágenes del bestiario en Colab:** el cuaderno está listo (`colab/`), falta ejecutarlo con la GPU T4.

## Próximo paso

Vertical slice «Una noche en Hoshiyama», base del primer capítulo:

- combate pulido;
- los yōkai del capítulo 1 (kappa, oni, onibi y el oni gigante de jefe);
- salida a la planicie con un encuentro de dados;
- una aldea mínima.

Cuánto detalle cabe (luces, sombras, número de enemigos) depende de los FPS de tu móvil.
