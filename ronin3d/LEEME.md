# RONIN — Índice del proyecto

Juego de samuráis: Akira, guardia del señor Takeda, queda como ronin tras la traición del
general Genzo. Busca justicia por fuera y recuperar su honor por dentro. Empieza y termina en
el castillo de Hoshiyama.

**Estado:** prototipo 2D completo (capítulo 1 y salida a la planicie) · capítulo 1 rehecho en
3D con estética 2D y cámara que gira: en Godot con tres estéticas y, para comparar motores, en
Three.js y Ursina.
**Última actualización:** 27 de septiembre de 2026

---

## Cómo está organizado

```
ronin/                         (Drive: Respaldos Claude › ronin)
├── LEEME.md                   Este índice
├── RONIN_rama_completa.zip    Todo el código y las capturas (copia de la rama de GitHub)
├── 01-Diseno/                 Traspaso, especificación 3D y comparativa de motores y estéticas
├── 02-Prototipo-2D/           samurai.py (Pygame, un solo archivo)
├── 03-Godot/                  Versión Godot 4.7: LEEME y capturas de las tres estéticas
└── 04-Otros-motores/          Three.js (se juega en el navegador) y Ursina (Python)
```

En GitHub (`26914233/trazzo`, rama `claude/ronin-pygame-setup-szn3rn`):

```
samurai.py                     Prototipo 2D
ronin3d/
├── LEEME.md                   Este índice
├── HANDOFF_RONIN.md           Traspaso para seguir en otra sesión
├── DISENO_3D.md               Especificación común de las versiones 3D
├── COMPARATIVA.md             Motores y estéticas: resultados y recomendación
├── recursos/                  Sprites y texturas pixel art (generar_recursos.py)
├── capturas/                  Capturas de las pruebas automáticas
├── godot/                     Proyecto Godot (principal)
├── threejs/                   Versión web (ronin3d.html)
└── ursina/                    Versión Python (ronin3d_ursina.py)
```

---

## Decisiones ya cerradas

| Tema | Decisión |
| --- | --- |
| **Historia** | La de siempre (Akira, Takeda, Genzo, estructura circular en Hoshiyama). No se cambia sin consultar |
| **Mapa** | Castillo, aldea, templo, dojo, ruinas y la planicie que los une |
| **Géneros** | Castillo: acción con espada · aldea: rol · templo: puzzles · dojo: ritmo y reflejos · ruinas: exploración y combate · planicie: viaje y encuentros al azar con dados |
| **Dirección** | 3D con estética 2D y cámara que gira alrededor |
| **Reglas** | Todo en español, nombres de variables en español |

## Propuestas abiertas (no son decisiones)

| Tema | Propuesta | Cuándo se cierra |
| --- | --- | --- |
| **Estética** | HD-2D (recomendada) · Pixel art 3D · Cel-shading | Al ver la comparativa |
| **Motor** | Godot (recomendado) · Three.js · Ursina | Al ver la comparativa |
| **Textos de intro y cierre** | Provisionales, escritos solo con la historia base | Antes de pulir el capítulo 1 |
| **Dados de la planicie** | Chō-han (par o impar con dos dados) | Al empezar la planicie en 3D |

---

## Lo que bloquea avanzar

1. **Elegir estética** (ver `COMPARATIVA.md` o la página de comparación).
2. **Confirmar motor.**

## Próximo paso

Con la estética elegida: pulir el capítulo 1 en 3D (combate, sonido, animaciones) y construir
la salida del castillo a la planicie en 3D. Después, un módulo por lugar.
