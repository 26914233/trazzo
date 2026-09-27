# RONIN — Traspaso del proyecto (handoff)

**Última actualización:** 27 de septiembre de 2026 · sesión de Claude Code en la nube
**Leer entero antes de seguir.** Copia en Drive: `Respaldos Claude/ronin/01-Diseno/`.

---

## 1. Objetivo

Hacer **RONIN**, un juego de samuráis con la historia de Akira, primero como prototipo 2D
(hecho) y ahora **rehecho en 3D con estética 2D y cámara que gira alrededor**, con
**Godot 4.7** como motor principal (el mismo del prototipo de Trazzo). Se prueban **tres
estéticas** en Godot (HD-2D, pixel art 3D, cel-shading) y, para comparar motores, la
misma escena en **Three.js** (navegador) y **Ursina** (Python). El usuario decide la
dirección después de ver las versiones.

## 2. Hecho

- **Prototipo 2D completo** (`samurai.py`, Pygame, un solo archivo): intro, Capítulo 1 en
  el castillo (plataformas, espada con J, 6 soldados con lanza que avisan «!», 5 de vida,
  puerta final), cierre, y salida a **la planicie** (mapa abierto 3200 × 2400 con castillo,
  aldea, templo, dojo, ruinas, río con puentes, minimapa y mapa con M). Probado con bots y
  capturas. `samurai.py` **no existía en el repo**: se reconstruyó desde la descripción del
  usuario; si aparece el original, se porta la planicie encima.
- **Decisión de motor:** Godot 4.7 principal, tres estéticas; comparar con Three.js y
  Ursina. Godot 4.7.2 instalado en la nube (SHA-512 verificado) y renderizando con
  OpenGL por software para sacar capturas.
- **Especificación común 3D:** `ronin3d/DISENO_3D.md` (medidas del patio, personajes,
  cámara, controles, HUD, estéticas, paleta).
- **Sprites y texturas pixel art compartidos:** `ronin3d/recursos/` generados por
  `generar_recursos.py` (Akira y soldado en 3 vistas × 5 poses; losas, muro, yeso,
  madera, tejas, portón, fuego, sombra, luna, tajo).
- **Drive:** carpeta `Respaldos Claude/ronin/` con `01-Diseno`, `02-Prototipo-2D`,
  `03-Godot`, `04-Otros-motores`.

## 3. En curso / pendiente del usuario

- **En curso (nube):** proyecto Godot con las tres estéticas; versiones Three.js y Ursina.
  Cuando terminen: capturas en `ronin3d/capturas/` y comparativa.
- **Pendiente del usuario:**
  1. Ver las versiones y **elegir estética** (HD-2D, pixel art 3D o cel-shading).
  2. **Confirmar motor** (Godot, salvo que otro convenza más).
  3. Revisar los **textos provisionales** de la intro y el cierre (escritos solo con la
     historia base; suponen que los soldados obedecen a Genzo y que Akira sale ya ronin).
  4. Si tiene el `samurai.py` original, subirlo.

## 4. Siguiente

1. Terminar y probar las tres estéticas en Godot; comparar con Three.js y Ursina.
2. Con la estética elegida: pulir el Capítulo 1 en 3D (combate, sonido, animaciones).
3. Salida del castillo a **la planicie en 3D** (mundo abierto con los cinco lugares).
4. Módulos por lugar: aldea (rol: diálogos, misiones, tienda, descanso), templo
   (puzzles), dojo (ritmo/reflejos para aprender técnicas), ruinas (exploración y
   combate), planicie (viaje y encuentros al azar con dados; propuesta: chō-han).
5. Exportar a Android (APK) como ya se hizo con Trazzo.

## 5. Dónde está todo

| Qué | Dónde |
| --- | --- |
| Código | GitHub `26914233/trazzo`, rama `claude/ronin-pygame-setup-szn3rn` (repo público) |
| Prototipo 2D | `samurai.py` (raíz del repo) · `pip install pygame` · `python samurai.py` (`--planicie` empieza en el mapa) |
| Versión 3D | `ronin3d/` → `godot/`, `threejs/`, `ursina/`, `recursos/`, `capturas/` |
| Especificación 3D | `ronin3d/DISENO_3D.md` |
| Respaldo en Drive | `Respaldos Claude/ronin/` (01-Diseno, 02-Prototipo-2D, 03-Godot, 04-Otros-motores) |
| Memoria | Vertiso Memory, handoff con ámbito `ronin-juego` |

## 6. Riesgos y reglas

- **Historia base (no cambiar sin consultar):** Akira, guardia del señor Takeda; tras la
  traición queda como ronin; busca justicia por fuera y recuperar su honor por dentro.
  Villano: el general Genzo, mano derecha de Takeda, lo asesinó creyéndolo demasiado
  blando; no se ve como villano y parte del pueblo lo apoya. Estructura circular: empieza
  y termina en el castillo de Hoshiyama (mismo escenario).
- **Mapa y géneros:** castillo (acción con espada), aldea (rol), templo (puzzles), dojo
  (ritmo/reflejos), ruinas (exploración y combate), planicie (viaje + dados).
- **Reglas de trabajo:** todo en español, **nombres de variables en español**, no cambiar
  la historia sin consultar; el usuario marca la dirección.
- **PC del usuario modesto** (Windows, 0,5-1 GB de RAM libre): Godot con el renderizador
  *Compatibility* (ligero, sirve para Android). Una cosa pesada a la vez.
- Verificar checksums de las descargas grandes. **No publicar en redes.**
- En Drive solo se suben textos (el conector sube el archivo dentro de la llamada); los
  binarios y el proyecto completo se bajan de GitHub (Code → Download ZIP de la rama).
