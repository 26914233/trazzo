# RONIN — Índice del proyecto

Juego de samuráis: Akira, guardia del señor Takeda, queda como ronin tras la traición del
general Genzo. Busca justicia por fuera y recuperar su honor por dentro. Empieza y termina en
el castillo de Hoshiyama.

**Estado:** prototipo del capítulo 1 en **Godot 4.7 con cel-shading**, jugable con teclado,
mando y pantalla táctil, con combate de precisión en prueba (parar justo al aviso y
contraatacar). Siguiente hito: **vertical slice** (ver `PLAN_PRODUCCION.md`).
**Última actualización:** 27 de septiembre de 2026

---

## Cómo está organizado

```
ronin/                         (Google Drive: Respaldos Claude › ronin)
├── LEEME.md                   Este índice
├── RONIN_rama_completa.zip    Todo el código y las capturas (copia de la rama de GitHub)
├── 01-Diseno/                 Traspaso, plan de producción, especificación y comparativa
├── 02-Prototipo-2D/           samurai.py (Pygame, un solo archivo)
├── 03-Godot/                  Versión Godot: LEEME, pruebas y capturas
└── 04-Otros-motores/          Three.js y Ursina (solo como referencia)
```

En GitHub (`26914233/trazzo`, rama `claude/ronin-pygame-setup-szn3rn`):

```
CLAUDE.md                      Instrucciones de trabajo para Claude (equipo de videojuegos)
samurai.py                     Prototipo 2D
ronin3d/
├── LEEME.md                   Este índice
├── HANDOFF_RONIN.md           Traspaso para seguir en otra sesión
├── PLAN_PRODUCCION.md         Visión, alcance, vertical slice, riesgos y decisiones
├── DISENO_3D.md               Especificación del patio y de las reglas de combate
├── COMPARATIVA.md             Cómo se eligieron motor y estética (y otros motores y APK)
├── godot/                     El juego (principal)
├── capturas/                  Capturas: actual/ = versión de hoy; el resto, de la comparativa
├── recursos/                  Sprites y texturas pixel art de la comparativa
├── threejs/                   Versión web de la comparativa (referencia)
└── ursina/                    Versión Python de la comparativa (referencia)
```

---

## Decisiones ya cerradas

| Tema | Decisión |
| --- | --- |
| **Historia** | La de siempre (Akira, Takeda, Genzo, estructura circular en Hoshiyama). No se cambia sin consultar |
| **Mapa** | Castillo, aldea, templo, dojo, ruinas y la planicie que los une |
| **Dirección** | 3D con cámara que gira alrededor |
| **Motor** | Godot 4.7 con el renderizador Compatibility (27-09-2026) |
| **Estética** | Cel-shading (27-09-2026) |
| **Textos de intro y cierre** | Se quedan como están por ahora; se pueden cambiar más adelante |
| **Reglas** | Todo en español, nombres de variables en español |

## Propuestas abiertas (no son decisiones)

| Tema | Propuesta | Cuándo se cierra |
| --- | --- | --- |
| **Alcance** | Un núcleo (duelo + exploración) y cada lugar como variación; lanzar por capítulos | Ahora (DECISIÓN 1 del plan) |
| **Estilo de combate** | Precisión: parar al aviso y contraatacar (prototipo ya jugable) | Tras probarlo (DECISIÓN 2 del plan) |
| **Géneros por lugar** | Aldea: rol · templo: puzzles · dojo: ritmo · ruinas: exploración · planicie: viaje y dados | Con la DECISIÓN 1 |
| **Dados de la planicie** | Chō-han (par o impar con dos dados) | Al empezar la planicie en 3D |
| **Nombre** | «RONIN» ya lo usan otros juegos: buscar nombre o subtítulo propio | Antes de abrir una página de tienda |

---

## Lo que bloquea avanzar

1. **DECISIÓN 1 (alcance)** y **DECISIÓN 2 (estilo de combate)** de `PLAN_PRODUCCION.md`.
2. **Probar el APK en tu móvil** (exportar desde Godot en tu PC, como con Trazzo).

## Próximo paso

Vertical slice «Una noche en Hoshiyama»: combate pulido, un rival distinto, salida a la
planicie con un encuentro de dados y una aldea mínima.
