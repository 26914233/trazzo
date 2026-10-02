# Modelos detallados de criaturas (prueba piloto)

Son los primeros enemigos con modelo propio en lugar de piezas. Salieron de la prueba del
02-10-2026, cuando el usuario pidió que todos los enemigos tuvieran el detalle de un arte de jefe
que envió. Dos se hicieron con IA a partir de su concepto (SAM 3D) y uno por código con el
conector de Trimble SketchUp. Cómo se llevaría eso a todo el bestiario es la **DECISIÓN 15**
(`../../../BESTIARIO_UNIVERSAL.md`, §8.2).

| Archivo | Criatura (id) | Triángulos | Textura | Tamaño | MD5 |
|---|---|---|---|---|---|
| `aka_oni.glb` | Aka-oni (2315) | 13 686 (14 024 con el garrote) | 1024 × 1024 | 1 637 692 bytes | `433ea78bcb4537a15862edecd21940e8` |
| `kappa.glb` | Kappa (353) | 41 327 (41 471 con el agua) | 1024 × 1024 | 2 033 392 bytes | `8e34d6bf3d452c6e4c9db39749f44031` |
| `chochin_obake.glb` | Chōchin-obake (680) | 2 588 | paleta de 64 × 8 | 281 020 bytes | `cf9af007335fd6c2ffa745928f48051a` |

Al importarlos, Godot saca la textura a `aka_oni_0.png`, `kappa_0.png` y `chochin_obake_0.png` (comprimidas en VRAM) y
crea LOD automáticos. En el juego los carga `scripts/modelo_criatura.gd`, con el mismo
cel-shading, el mismo contorno y los mismos tres rangos que las criaturas de piezas.

## Cómo se hicieron

1. **Concepto 2D:** `oni.png` y `kappa.png` de Drive › `ronin/05-Arte/conceptos-2d/fichas/` (las fichas sin fondo; desde el 02-10 los conceptos principales son escenas), hechos con
   Higgsfield (`z_image`).
2. **Recorte:** `herramientas/modelos3d/recortar_concepto.py` quita el fondo y pone la figura sobre
   gris claro (`*_plano.png`). Con transparencia, SAM 3D falló (el crédito se devolvió).
3. **Imagen → 3D:** SAM 3D (Meta) en Higgsfield, modelo `sam_3_3d`. Cuesta **1 crédito** por
   modelo y tarda 1-2 minutos. Ajustes: `detection_threshold` 0.3, semilla 7. Indicaciones:
   - oni: «red oni demon holding an iron club»
   - kappa: «green kappa creature with a turtle shell and a water dish on its head»
4. **Retoques:**
   - **El oni salió sin garrote.** Lleva un kanabō hecho por código en el puño levantado
     (`_garrote`), en una sola malla. Así el arma se puede cambiar o animar aparte.
   - **El plato del kappa salió hueco y casi negro.** `herramientas/modelos3d/pintar_plato_kappa.py`
     lo pinta de acero en la textura y la guarda dentro del GLB sin tocar la malla. La salida
     original de SAM 3D era `98cd55dfb7fe5cf255ac102abe6ecb56` (2 072 480 bytes). El agua va
     aparte (`_agua`): un disco claro con reflejos que laten.

## Chōchin-obake: hecha con SketchUp (por código, sin IA)

- **Cómo:** el conector de Trimble SketchUp ejecuta Python dentro de SketchUp en la nube. El
  modelo se construye pieza a pieza: farol con costillas, aros de laca, asa, el ojo enorme, la boca
  abierta como una mandíbula que brilla por dentro, la lengua, la pierna y el geta. Código:
  `herramientas/modelos3d/sketchup_chochin_obake.py`.
- **Del .skp al juego:** Godot no abre `.skp`. Así que se sacan los triángulos de cada pieza desde
  el propio SketchUp, y `herramientas/modelos3d/sketchup_a_glb.py` los convierte en GLB:
  - pasa de pulgadas a metros y de Z arriba a Y arriba;
  - calcula normales suaves por ángulo;
  - mete los colores en una paleta, de modo que todo es una malla y una sola llamada de dibujo.
- **El original:** `chochin_obake.skp` está en Drive (`ronin/05-Arte/modelos3d/`). Se guardó 1 vez
  de las 30 que permite el plan gratis.
- **Límites:**
  - Las costillas del papel no se ven en el juego (en SketchUp son líneas de arista).
  - Sirve para criaturas-objeto y piezas duras: farolillos, paraguas, armas, armaduras, escenarios.
    Para cuerpos orgánicos (un oni, un kappa) no vale.

## Lo que falta (honesto)

- **Sin esqueleto.** Respiran y se balancean por código. Atacar, caminar o caer necesita rigging:
  Tripo o Meshy lo hacen por familia de cuerpo (ver DECISIÓN 15).
- **El kappa pesa demasiado para un enemigo pequeño** (41 000 triángulos). Los LOD lo alivian de
  lejos, pero le conviene una retopología a unos 10 000 antes de usarlo en serio.
- **Hay costuras finas** en el plato repintado (líneas oscuras de la textura vecina). Solo se notan
  muy de cerca.
- **Conceptos para 3D:** los dos conceptos llevan manchas de tinta y poses de acción. Para 3D
  conviene pedirlos de frente, con los brazos algo separados, fondo liso y sin salpicaduras.

## Licencias (comprobado el 02-10-2026)

- **SAM 3D: licencia SAM de Meta.** Permite el uso comercial. Prohíbe usos militares o sujetos
  a controles de comercio, y la ingeniería inversa del propio modelo. No reclama lo que se genera.
  Fuente: `github.com/facebookresearch/sam-3d-objects` (LICENSE).
- **Higgsfield** no reclama la propiedad de lo que se sube ni de lo que sale, y no ata el uso
  comercial al plan. Fuente: su centro de ayuda, «Who owns my generations», modificado el
  12-09-2026.
  - **Ojo:** puede usar lo generado para entrenar sus modelos. Si no se quiere, hay que borrarlo
    de Higgsfield después de descargarlo.
