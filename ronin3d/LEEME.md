# RONIN — Índice del proyecto

Juego de samuráis en un Japón invadido por yōkai. Akira, guardia del shōgun Takeda, queda como
ronin tras la traición del general Genzo, que pactó con el gran yōkai creyendo proteger Japón.
Busca justicia por fuera y recuperar su honor por dentro. Empieza y termina en el castillo de
Hoshiyama.

**Estado:** prototipo 0.3 del capítulo 1 en **Godot 4.7 con cel-shading**, jugable con teclado,
mando y pantalla táctil.

- **Combate:** iaidō. Se mantiene y se suelta justo al aviso; con la barra llena hay un corte de
  luna.
- **Animación:** estilo anime limitado, que se puede cambiar a la suave para comparar.
- **APK de prueba para Android:** `ronin-0.3-prueba.apk`, en la carpeta de Drive.
- **Decidido:** núcleo + variaciones y lanzamiento por capítulos (opción C), y combate de
  precisión con iaidō.
- **Siguiente hito:** **vertical slice**, base del primer capítulo (ver `PLAN_PRODUCCION.md`).

**Última actualización:** 1 de octubre de 2026

---

## Cómo está organizado

```
ronin/                         (Google Drive: Respaldos Claude › ronin)
├── LEEME.md                   Este índice
├── ronin-0.3-prueba.apk       APK de prueba para instalar en el móvil (Android 7.0 o superior)
├── RONIN_rama_completa.zip    Todo el código y las capturas (copia de la rama de GitHub)
├── 01-Diseno/                 Traspaso, plan, propuesta yōkai, historia, bestiario, especificación…
├── 02-Prototipo-2D/           samurai.py (Pygame, un solo archivo)
├── 03-Godot/                  Versión Godot: LEEME, pruebas, huellas SHA-256, capturas y
│                              firma-prueba/ (clave de los APK de prueba; privada)
├── 04-Otros-motores/          Three.js y Ursina (solo como referencia)
├── 05-Arte/conceptos-2d/      Conceptos 2D en PNG a tamaño completo (Higgsfield)
└── Versiones anteriores (RONIN)/  APK anteriores (0.2) y capturas retiradas
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
├── HISTORIA.md                Sinopsis nueva y textos propuestos (por aprobar: DECISIONES 8 y 9)
├── BESTIARIO.md               Criaturas por capítulos, fichas del capítulo 1 y Bahamut (DECISIÓN 10)
├── DISENO_3D.md               Especificación del patio y de las reglas de combate
├── COMPARATIVA.md             Cómo se eligieron motor y estética (y otros motores y APK)
├── godot/                     El juego (principal)
├── arte/conceptos/            Conceptos 2D de personajes y criaturas (JPG)
├── capturas/                  Capturas: actual/ = versión de hoy (con GIF); el resto, de la comparativa
├── herramientas/              hacer_gifs.py (GIF a partir de los fotogramas de la prueba)
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
| **Bestiario** | Yōkai japoneses con variantes, más criaturas, las de otras tierras y **Bahamut como dragón** (1-10-2026) |
| **Escenas de historia** | Ilustración 2D con tinta; pixel art solo para los recuerdos de Akira (1-10-2026) |
| **Animación** | Estilo anime limitado, en prueba (1-10-2026) |
| **Farmeo automático** | No: la caza se juega (1-10-2026) |
| **Textos de intro y cierre** | Siguen como estaban hasta que apruebes la sinopsis (DECISIÓN 8) |
| **Reglas** | Todo en español, nombres de variables en español |

## Propuestas abiertas (no son decisiones)

| Tema | Propuesta | Cuándo se cierra |
| --- | --- | --- |
| **Sinopsis y textos nuevos** | `HISTORIA.md`: kekkai, dos planos, el pacto y cuatro capítulos | DECISIÓN 8 |
| **El gran yōkai** | Tamamo-no-Mae (recomendada), Shuten-dōji o uno inventado | DECISIÓN 9 |
| **Criaturas de otras tierras** | Llegan a partir del capítulo 3, con Bahamut | DECISIÓN 10 de `BESTIARIO.md` |
| **Qué hace cada lugar** | Aldea: diálogos y encargos · templo: puzzles de entorno · dojo: técnicas con ritmo · ruinas: exploración y jefe · planicie: viaje y dados | Al construir cada lugar |
| **Bestiario dentro del juego** | Fichas con ilustración y leyenda real al vencer a cada criatura | Al planificar el vertical slice |
| **Modelo de capítulos** | Primer capítulo gratis como demo y el resto de pago, o cada capítulo de pago | Con datos del vertical slice |
| **Dados de la planicie** | Chō-han (par o impar con dos dados) | Al empezar la planicie en 3D |
| **Nombre** | «RONIN» ya lo usan otros juegos: buscar nombre o subtítulo propio | Antes de abrir una página de tienda |

---

## Lo que bloquea avanzar

1. **Tu prueba del APK 0.3 en el móvil:**
   - los FPS (abajo a la derecha; meta: 30 o más);
   - si el iai (mantener y soltar al «!») y el corte de luna se entienden;
   - qué animación prefieres, anime o suave (botón en la pausa).
2. **DECISIONES 8 y 9** de `HISTORIA.md` y **DECISIÓN 10** de `BESTIARIO.md`.

## Próximo paso

Vertical slice «Una noche en Hoshiyama», base del primer capítulo:

- combate pulido;
- los yōkai del capítulo 1 (kappa, oni, onibi y el oni gigante de jefe);
- salida a la planicie con un encuentro de dados;
- una aldea mínima.

Cuánto detalle cabe (luces, sombras, número de enemigos) depende de los FPS de tu móvil.
