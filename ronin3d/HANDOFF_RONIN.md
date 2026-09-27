# RONIN — Traspaso del proyecto (handoff)

**Última actualización:** 27 de septiembre de 2026 · sesión de Claude Code en la nube
**Leer entero antes de seguir.** Copia en Google Drive: `Respaldos Claude/ronin/01-Diseno/`.

---

## 1. Objetivo

Hacer **RONIN**, un juego de samuráis con la historia de Akira, primero como prototipo 2D
(hecho) y ahora **rehecho en 3D con estética 2D y cámara que gira alrededor**. Se probaron
**tres estéticas** en Godot (HD-2D, pixel art 3D, cel-shading) y la misma escena en **Three.js**
(navegador) y **Ursina** (Python) para comparar motores. **El usuario decide estética y motor**
después de ver la comparativa; hasta entonces no se sigue construyendo.

## 2. Hecho

- **Prototipo 2D** (`samurai.py`, Pygame, un solo archivo): intro, capítulo 1 en el castillo,
  cierre y salida a **la planicie** (mapa abierto con castillo, aldea, templo, dojo, ruinas,
  río, minimapa y mapa con M). `samurai.py` **no existía en el repo**: se reconstruyó desde la
  descripción del usuario.
- **Especificación común 3D** `ronin3d/DISENO_3D.md` y **sprites/texturas pixel art**
  compartidos en `ronin3d/recursos/` (`generar_recursos.py`).
- **Godot 4.7.2** (`ronin3d/godot/`, renderizador Compatibility): capítulo 1 completo con las
  **tres estéticas** que se cambian con las teclas 1/2/3. Prueba automática **9 de 9** en las
  tres. FPS en la nube (OpenGL por software, 1280 × 720): HD-2D 9,5 · Pixel 17,6 · Cel 12,3.
  Memoria en la prueba: unos 415-458 MB (con render por software).
- **Three.js r170** (`ronin3d/threejs/ronin3d.html`, un solo HTML jugable, también en el móvil
  con controles táctiles): HD-2D, prueba **47 de 47**. 6,3 FPS en las mismas condiciones;
  728 MB contando todo el navegador.
- **Ursina 7.0** (`ronin3d/ursina/ronin3d_ursina.py`, un solo archivo, opción `--ligero`):
  HD-2D, prueba **34 de 34**. 20,1 FPS; 276 MB.
- **Comparativa** `ronin3d/COMPARATIVA.md` + página con las capturas lado a lado + hojas
  `capturas/comparativa_esteticas.jpg` y `capturas/comparativa_motores.jpg`.
- **Recomendación dada:** motor **Godot** (único de los tres que llega a Android, como Trazzo;
  tiene editor) y estética **HD-2D** (la más parecida a 2D; alternativa: pixel art 3D si se
  quiere girar la cámara sin cambios bruscos de vista y lo más ligero).
- **Respaldo en Google Drive** `Respaldos Claude/ronin/` (índice, ZIP de la rama, documentos,
  capturas y archivos de cada motor) y handoff en Vertiso Memory (ámbito `ronin-juego`).

## 3. En curso / pendiente del usuario

1. **Elegir estética:** HD-2D, pixel art 3D o cel-shading (o una mezcla).
2. **Confirmar motor:** Godot (recomendado), Three.js o Ursina.
3. Revisar los **textos provisionales** de la intro y el cierre (escritos solo con la
   historia base; suponen que los soldados obedecen a Genzo y que Akira sale ya ronin).
4. Si tiene el `samurai.py` original, subirlo.

## 4. Siguiente

1. Con la estética y el motor elegidos: pulir el capítulo 1 en 3D (combate, sonido,
   animaciones, más vistas de sprite si es HD-2D).
2. Salida del castillo a **la planicie en 3D** (mundo abierto con los cinco lugares).
3. Módulos por lugar: aldea (rol: diálogos, misiones, tienda, descanso), templo (puzzles),
   dojo (ritmo/reflejos para aprender técnicas), ruinas (exploración y combate), planicie
   (viaje y encuentros al azar con dados; propuesta: chō-han).
4. Exportar a Android (APK) como ya se hizo con Trazzo.

## 5. Dónde está todo

| Qué | Dónde |
| --- | --- |
| Código | GitHub `26914233/trazzo`, rama `claude/ronin-pygame-setup-szn3rn` (repo público) |
| Índice del proyecto | `ronin3d/LEEME.md` (mismo formato que el de Trazzo) |
| Prototipo 2D | `samurai.py` · `pip install pygame` · `python samurai.py` (`--planicie` empieza en el mapa) |
| Versiones 3D | `ronin3d/godot/` (principal), `ronin3d/threejs/`, `ronin3d/ursina/`; cada una con su `LEEME.md` |
| Comparativa | `ronin3d/COMPARATIVA.md` · página privada https://claude.ai/artifact/6urV5FCikt9CWAUV35gBCu |
| Jugar en el navegador | página privada https://claude.ai/artifact/9QHgv2eQPDdww4HGcbYJaL (versión Three.js) |
| Capturas | `ronin3d/capturas/` (`godot_<estética>_*.png`, `threejs_*.png`, `ursina_*.png`) |
| Respaldo | Google Drive `Respaldos Claude/ronin/` (01-Diseno, 02-Prototipo-2D, 03-Godot, 04-Otros-motores) |
| Memoria | Vertiso Memory, handoff con ámbito `ronin-juego` |

**Cómo pasar esto a un proyecto de Claude:** en claude.ai, abre el proyecto de RONIN y añade
a sus archivos este documento (está en Google Drive, `Respaldos Claude/ronin/01-Diseno/`; si el
proyecto no deja elegirlo desde Drive, descárgalo y súbelo) y, si quieres, `COMPARATIVA.md` y
`LEEME.md`. Para retomar en un chat nuevo, basta con decir: «Lee HANDOFF_RONIN.md y sigue con
RONIN; mi elección es: estética …, motor …». Si el chat tiene Vertiso Memory, el traspaso
también está allí (ámbito `ronin-juego`).

## 6. Riesgos y reglas

- **Historia base (no cambiar sin consultar):** Akira, guardia del señor Takeda; tras la
  traición queda como ronin; busca justicia por fuera y recuperar su honor por dentro.
  Villano: el general Genzo, mano derecha de Takeda, lo asesinó creyéndolo demasiado blando;
  no se ve como villano y parte del pueblo lo apoya. Estructura circular: empieza y termina en
  el castillo de Hoshiyama (mismo escenario).
- **Mapa y géneros:** castillo (acción con espada), aldea (rol), templo (puzzles), dojo
  (ritmo/reflejos), ruinas (exploración y combate), planicie (viaje + dados).
- **Reglas de trabajo:** todo en español, **nombres de variables en español**, no cambiar
  la historia sin consultar; el usuario marca la dirección.
- **PC del usuario modesto** (Windows, 0,5-1 GB de RAM libre): Godot con el renderizador
  *Compatibility*. Una cosa pesada a la vez. Los FPS y la memoria medidos en la nube son con
  render por software; con tarjeta gráfica real cambian.
- **Respaldos en Google Drive, nunca en OneDrive.** Textos con el conector de Google Drive;
  binarios (ZIP, capturas) con Composio `GOOGLESUPER_UPLOAD_FROM_URL` desde las URL «raw» de
  GitHub; para reescribir un texto ya subido sin cambiar su enlace, `GOOGLESUPER_EDIT_FILE`.
- Verificar checksums de las descargas grandes. **No publicar en redes.** Las páginas de
  claude.ai son privadas; si se quieren compartir, lo decide el usuario.
- Notas técnicas de Godot: los scripts usan `preload()` en vez de `class_name`; la prueba se
  lanza con `godot --path ronin3d/godot --fixed-fps 30 -- --prueba --estilo=hd2d|pixel|cel`
  (en Linux sin pantalla, con `xvfb-run`). Con Compatibility, cada luz que toca un objeto lo
  vuelve a dibujar: el suelo y los muros van en trozos de 8 m.
