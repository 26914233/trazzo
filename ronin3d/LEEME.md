# RONIN — Índice del proyecto

Juego de samuráis en un Japón invadido por yōkai. Akira, guardia del shōgun Takeda, queda como
ronin tras la traición del general Genzo, que pactó con el gran yōkai creyendo proteger Japón.
Busca justicia por fuera y recuperar su honor por dentro. Empieza y termina en el castillo de
Hoshiyama.

**Estado:** prototipo 0.5 del capítulo 1 en **Godot 4.7 con cel-shading**, jugable con teclado,
mando y pantalla táctil. Incluye una **galería de criaturas** (pausa → botón, o tecla G) para ver el sistema
que permitiría construir cientos de monstruos. Desde la 0.5 trae los **tres primeros enemigos con modelo
detallado** (Aka-oni, kappa y Chōchin-obake, página 1 de la galería).

- **Combate:** iaidō. Se mantiene y se suelta justo al aviso; con la barra llena hay un corte de
  luna.
- **Animación:** estilo anime limitado, que se puede cambiar a la suave para comparar.
- **APK de prueba para Android:** `ronin-0.5-prueba.apk`, en la carpeta de Drive.
- **Bestiario universal:** 939 criaturas (tu catálogo limpio + ángeles, demonios y yōkai que faltaban), cada
  una con su variante fuerte; ver `BESTIARIO_UNIVERSAL.md`.
- **Decidido:** núcleo + variaciones y lanzamiento por capítulos (opción C), y combate de
  precisión con iaidō.
- **Siguiente hito:** **vertical slice**, base del primer capítulo (ver `PLAN_PRODUCCION.md`).

**Última actualización:** 2 de octubre de 2026

---

## Cómo está organizado

```
ronin/                         (Google Drive: Respaldos Claude › ronin)
├── LEEME.md                   Este índice
├── ronin-0.5-prueba.apk       APK de prueba para instalar en el móvil (Android 7.0 o superior)
├── RONIN_rama_completa.zip    Todo el código y las capturas (copia de la rama de GitHub)
├── 01-Diseno/                 Traspaso, plan, propuesta yōkai, historia, bestiario, especificación…
├── 06-Bestiario/              Catálogo limpio (CSV/JSON), prompts_colab.csv, cuaderno de Colab, imágenes
│                              (cuando se hagan) y tus dos Excel originales en fuentes/
├── 02-Prototipo-2D/           samurai.py (Pygame, un solo archivo)
├── 03-Godot/                  Versión Godot: LEEME, pruebas, huellas SHA-256, capturas y
│                              firma-prueba/ (clave de los APK de prueba; privada)
├── 04-Otros-motores/          Three.js y Ursina (solo como referencia)
├── 05-Arte/conceptos-2d/      Conceptos 2D en PNG a tamaño completo (Higgsfield), al estilo del Bahamut;
│                              las fichas anteriores (para 3D) en fichas/
├── 05-Arte/modelos3d/         Modelos 3D de enemigos (GLB, el .skp de SketchUp) y sus retratos
└── Versiones anteriores (RONIN)/  APK anteriores (0.2, 0.3 y 0.4) y capturas retiradas
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

---

## Lo que bloquea avanzar

1. **Tu prueba del APK 0.5 en el móvil:**
   - los FPS (abajo a la derecha; meta: 30 o más);
   - si el iai (mantener y soltar al «!») y el corte de luna se entienden;
   - qué animación prefieres, anime o suave (botón en la pausa);
   - **la galería de criaturas** (pausa → «Galería de criaturas»): los FPS con los modelos detallados
     (página 1), con 8 y con 24 criaturas a la vez (páginas 4 y 6), y si las siluetas por familia te
     convencen.
2. **DECISIONES 11, 12, 13, 14 y 15** (`HISTORIA.md` §8 y `BESTIARIO_UNIVERSAL.md`). La 15 es cómo dar a
   todos los enemigos el detalle que pediste.
3. **Imágenes del bestiario en Colab:** el cuaderno está listo (`colab/`), falta ejecutarlo con la GPU T4.

## Próximo paso

Vertical slice «Una noche en Hoshiyama», base del primer capítulo:

- combate pulido;
- los yōkai del capítulo 1 (kappa, oni, onibi y el oni gigante de jefe);
- salida a la planicie con un encuentro de dados;
- una aldea mínima.

Cuánto detalle cabe (luces, sombras, número de enemigos) depende de los FPS de tu móvil.
