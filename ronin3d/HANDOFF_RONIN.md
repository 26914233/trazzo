# RONIN — Traspaso del proyecto (handoff)

**Última actualización:** 1 de octubre de 2026 · sesión de Claude Code en la nube
**Leer entero antes de seguir.** Copia en Google Drive: `Respaldos Claude/ronin/01-Diseno/`.
**Forma de trabajar:** las instrucciones del usuario (equipo multidisciplinario de videojuegos:
Game Director, diseño, producción, marketing, negocio…) están en `CLAUDE.md`, en la raíz del
repositorio. Síguelas: fases, MVP/Must/Should/Nice, formato DECISIÓN y hablar como socio.

---

## 1. Objetivo

Convertir **RONIN** (samurái Akira) en un juego real, divertido y viable. Tras comparar cinco
versiones, el usuario eligió **Godot 4.7 + cel-shading** y, como alcance, **un núcleo con
variaciones y lanzamiento por capítulos** (opción C; los dos, 27-09-2026). El **1-10-2026** amplió
el mundo: un Japón invadido por yōkai, combate de **iaidō** (precisión), Takeda como **shōgun** y
Genzo **pactando con el gran yōkai** (decisiones 2-7 de `ronin3d/PROPUESTA_MUNDO_YOKAI.md`). Ahora
toca llegar al **vertical slice** «Una noche en Hoshiyama» (`ronin3d/PLAN_PRODUCCION.md`, §5), que
pulido será el primer capítulo (castillo + planicie + aldea).

## 2. Hecho

- **Prototipo 2D** `samurai.py` (Pygame): capítulo 1 + salida a la planicie. Se reconstruyó
  porque no existía en el repo.
- **Comparativa** de motores y estéticas (Godot HD-2D/pixel/cel, Three.js, Ursina) con FPS y
  memoria medidos: `ronin3d/COMPARATIVA.md`, página privada
  https://claude.ai/artifact/6urV5FCikt9CWAUV35gBCu y versión Three.js jugable
  https://claude.ai/artifact/9QHgv2eQPDdww4HGcbYJaL. Incluye otros motores y cómo sacar APK de
  los que no lo traen (§7).
- **Decisión:** Godot 4.7 (Compatibility) + cel-shading; textos de intro y cierre sin cambios.
- **Godot solo con cel-shading** (`ronin3d/godot/`): HD-2D y pixel art 3D retirados (quedan en
  el commit `8ec4b1b`). Patio más legible de noche.
- **Controles:** teclado/ratón, **mando** y **pantalla táctil** (joystick, Atacar, Iai, Luna,
  Saltar, pausa, arrastrar para la cámara, tocar para seguir). `--tactil` los muestra en el PC.
- **Combate de precisión (0.2, ya sustituido):** parar al «!» y contraatacar. **Sensación:**
  pausa de impacto, cámara lenta en la parada, sacudida, chispas, estela de la espada y 7 sonidos
  generados (`sonidos/generar_sonidos.py`).
- **Exportación** preparada: `export_presets.cfg` con Android (APK arm64) y Windows; icono
  provisional; compresión ETC2/ASTC activada.
- **Prueba automática: 15 de 15** (flujo, HUD, cámara, espada, muros, portón, pausa, toques,
  joystick, mando, parada a tiempo, contraataque, parada a destiempo). ~11-13 FPS en la nube con
  render por software.
- **Plan de producción** `ronin3d/PLAN_PRODUCCION.md`: pitch, diagnóstico (alcance, nombre,
  combate), pilares, bucles, vertical slice, validación, riesgos, negocio y decisiones.
- **`CLAUDE.md`** con las instrucciones del usuario para todas las sesiones de Claude Code.
- **DECISIÓN 1 cerrada:** opción C (núcleo + variaciones, lanzamiento por capítulos).
- **APK de prueba 0.2** generado en la nube y guardado en Drive (`ronin/ronin-0.2-prueba.apk`,
  26,9 MB, SHA-256 `fecb802a…57439d60`, MD5 comprobado en Drive). Es *release*, arm64,
  Android 7.0+, sin permisos. Para el móvil se añadieron: FPS junto a la versión, «Atrás» pausa (y
  en pausa sale), pausa automática al pasar a segundo plano y ayuda táctil con letra más grande.
  La prueba automática pasa 15/15 en el editor y en una exportación *release* para Linux. Cómo
  se genera: `ronin3d/godot/LEEME.md`, sección «Exportar».
- **Clave de firma de prueba** guardada con permiso del usuario (27-09-2026) en Drive
  `ronin/03-Godot/firma-prueba/` (con un LEEME): las versiones siguientes se instalan encima de
  la 0.2 sin desinstalarla.

**El 1-10-2026:**

- **Propuesta del mundo yōkai** analizada (`PROPUESTA_MUNDO_YOKAI.md`) y **decisiones 2 a 7
  cerradas**:
  - 2: precisión con iaidō.
  - 3: pacto de Genzo con el gran yōkai, y Takeda pasa a ser shōgun.
  - 4: yōkai con variantes, más criaturas, las de otras tierras y Bahamut como dragón.
  - 5: escenas en ilustración 2D.
  - 6: animación estilo anime limitado, a probar.
  - 7: sin farmeo automático.
- **Iaidō** (sustituye a la parada): mantener K / LB / «Iai» y soltar justo al «!». El iai
  perfecto desvía la lanza y derriba de un corte, con pausa, cámara lenta y un cuadro de tinta
  invertida. A destiempo no para nada; hay que esperar 0,6 s para repetir.
- **Corte de luna:** L / Y / «Luna» con la barra de espíritu llena (se llena con iai y golpes).
  El tiempo se congela, la pantalla se vuelve tinta, aparecen las líneas de corte y caen los
  enemigos a menos de 7 m. Sin enemigos cerca no gasta la barra.
- **Animación limitada estilo anime:** poses a 12 por segundo. **T** (teclado), Select (mando) o
  el botón de la pausa (móvil) cambia a la suave para comparar.
- **Prueba automática: 16 de 16.** GIF del iai y del corte de luna en `capturas/actual/`, hechos
  con `herramientas/hacer_gifs.py`.
- **Conceptos 2D** con Higgsfield en `arte/conceptos/` (y los PNG originales en Drive):
  - personajes: Akira, Genzo, Takeda y el gran yōkai;
  - criaturas: Bahamut, kappa, oni y onibi.
  - El oni gigante salió en negro tres veces (filtro de Higgsfield) y se dejó.
  - Cada imagen cuesta 0,15 créditos; quedan 5,7.
- **`HISTORIA.md`:** sinopsis para aprobar, con los textos nuevos de intro y cierre propuestos
  (no aplicados). DECISIONES 8 (aprobarla) y 9 (quién es el gran yōkai; recomendada
  Tamamo-no-Mae).
- **`BESTIARIO.md`:** familias para que sea viable, fichas del capítulo 1 (kappa, oni, onibi y
  oni gigante), más de 50 criaturas por capítulos, Bahamut y DECISIÓN 10 (las criaturas de
  otras tierras llegan en el capítulo 3; recomendada).
- **APK de prueba 0.3** (`ronin/ronin-0.3-prueba.apk`, 26,9 MB, SHA-256 `bfff4cb6…1f0cedc7`).
  Está firmado con la misma clave, así que se instala encima de la 0.2, que pasó a
  «Versiones anteriores (RONIN)».

**El 1-10-2026 (segunda parte):**

- **Cerradas las decisiones 8A, 9A y 10B:** sinopsis aprobada tal cual (`HISTORIA.md`), el gran yōkai
  es Tamamo-no-Mae y las criaturas de otras tierras llegan desde el capítulo 3. Los **textos del
  capítulo 1** de `datos.gd` ya cuentan la historia nueva (prueba automática que los comprueba).
- **Nueva entidad del Silencio** (nombre de trabajo *Shijima*): algo nacido de la oscuridad más callada,
  donde ni los yōkai quieren entrar, que rompe el equilibrio. Ficha, avisos de diseño y concepto 2D en
  `HISTORIA.md` §8 (`arte/conceptos/shijima.jpg`). **DECISIÓN 11 abierta** (recomendada B: gancho final y
  rango «silenciado»).
- **Catálogo de monstruos** (tus dos Excel, 998 filas): limpiado y clasificado a mano, criatura por
  criatura, con la rúbrica de `bestiario/RUBRICA_CLASIFICACION.md`. Resultado: **808 criaturas distintas**
  (no 1.000) + **132 añadidas** (17 huestes celestiales, 72 demonios del *Goetia* y 8 comunes, 35 yōkai y
  aliados japoneses) = **939**, de ellas **825 utilizables como enemigos**. Datos en `bestiario/`
  (`catalogo_limpio.csv/json`, `prompts_colab.csv`, `informe_calidad.md`); la fuente de verdad es
  `bestiario/clasificacion/` + `herramientas/bestiario/criaturas_extra.py`, y todo se regenera con
  `python3 ronin3d/herramientas/bestiario/unir_clasificacion.py ronin3d/bestiario/clasificacion ronin3d`.
  Tus Excel originales están en Drive › `ronin/06-Bestiario/fuentes/` (no en GitHub).
- **Análisis `BESTIARIO_UNIVERSAL.md`:** qué traía el catálogo, si la cantidad es un buen gancho, las tres
  formas de modelar (propia 12 %, variante 72 %, reskin 16 %), la variante más fuerte (rangos), ángeles y
  demonios, regla de respeto cultural, olas de contenido y trabajo estimado (≈ 4.200 h). **Decisiones
  12, 13 y 14 abiertas.**
- **Sistema modular de criaturas** `godot/scripts/criatura_modular.gd` y **galería** `galeria.gd` (pausa →
  botón o **G**; `--galeria`). Las 929 criaturas construibles se construyen en 0,5 s, 20,5 piezas de
  media.
- **Cuaderno de Colab** `colab/bestiario_imagenes.ipynb` (+ receta `INSTRUCCIONES_COLAB_BESTIARIO.md`)
  para dibujar las imágenes 2D con SDXL: el flujo está probado sin GPU, **la carga y difusión en una T4
  no**. Las imágenes aún no están hechas.
- **Prueba automática: 21 de 21.** **APK 0.4** (`ronin/ronin-0.4-prueba.apk`, 26,9 MB, SHA-256
  `3e4d82c2…f4ec4633`, misma firma que la 0.2 y la 0.3).

## 3. En curso / pendiente del usuario

1. **Probar el APK 0.4 en el móvil** y contar:
   - los FPS (meta ≥ 30);
   - si el iai (mantener y soltar) y el corte de luna se entienden;
   - qué animación prefiere, anime o suave;
   - **la galería de criaturas** (pausa → botón): FPS en la página 3 (7 criaturas) y en la 5 (24).
2. **DECISIONES 11, 12, 13 y 14** (`HISTORIA.md` §8 y `BESTIARIO_UNIVERSAL.md`) y la regla de respeto
   cultural (se aplica salvo veto).
3. **Imágenes del bestiario en Colab:** ejecutar el cuaderno con la GPU T4 (o la sesión que maneja Colab).
4. Si tiene el `samurai.py` original, subirlo.

## 4. Siguiente

1. Vertical slice (§5 del plan), base del primer capítulo:
   - ajustar el iai con lo que diga el usuario;
   - los yōkai del capítulo 1 (kappa, oni, onibi y el oni gigante de jefe; fichas en
     `BESTIARIO.md`);
   - salida a la planicie con un encuentro de dados;
   - aldea mínima;
   - menú y guardado (en estatuas jizō);
   - música.
   El detalle (luces, sombras, enemigos) se ajusta a los FPS que dé su móvil.
2. Medir 10 criaturas reales con el sistema (patrones de ataque, equilibrio y tiempo por criatura): es
   la prueba que valida o tumba el gancho de la cantidad (`BESTIARIO_UNIVERSAL.md` §10).
3. Personajes con esqueleto para la animación estilo anime (DECISIÓN 6). Probar VRoid Studio en
   su PC; desde la nube no se puede, porque es un programa de escritorio.
4. Buscar nombre o subtítulo propio antes de cualquier página de tienda.

## 5. Dónde está todo

| Qué | Dónde |
| --- | --- |
| Código | GitHub `26914233/trazzo`, rama `claude/ronin-pygame-setup-szn3rn` (repo público) |
| Instrucciones para Claude | `CLAUDE.md` (raíz) |
| Índice del proyecto | `ronin3d/LEEME.md` |
| El juego | `ronin3d/godot/` (LEEME con controles, combate, exportación y prueba) |
| Plan | `ronin3d/PLAN_PRODUCCION.md` |
| Mundo yōkai (decisiones 2-7) | `ronin3d/PROPUESTA_MUNDO_YOKAI.md` |
| Sinopsis (aprobada) y el Silencio | `ronin3d/HISTORIA.md` |
| Bestiario por capítulos | `ronin3d/BESTIARIO.md` |
| Bestiario universal (análisis y decisiones 12-14) | `ronin3d/BESTIARIO_UNIVERSAL.md` · datos en `ronin3d/bestiario/` · Drive `ronin/06-Bestiario/` |
| Colab (imágenes del bestiario) | `ronin3d/colab/` · Drive `ronin/06-Bestiario/` y la carpeta de Colab del usuario |
| Conceptos 2D | `ronin3d/arte/conceptos/` (JPG) · Drive `ronin/05-Arte/conceptos-2d/` (PNG originales) |
| Comparativa | `ronin3d/COMPARATIVA.md` · página privada https://claude.ai/artifact/6urV5FCikt9CWAUV35gBCu |
| Capturas de hoy | `ronin3d/capturas/actual/` |
| Clave de firma de prueba | Drive `Respaldos Claude/ronin/03-Godot/firma-prueba/` (privada; nunca en GitHub) |
| APK de prueba | Drive `Respaldos Claude/ronin/ronin-0.4-prueba.apk` (como con Curtzz: el nuevo va en la raíz con el nombre `ronin-<versión>-prueba.apk` y el anterior pasa a la carpeta «Versiones anteriores (RONIN)», dentro de `ronin/`) |
| Respaldo | Google Drive `Respaldos Claude/ronin/` (01-Diseno, 02-Prototipo-2D, 03-Godot, 04-Otros-motores, 05-Arte, 06-Bestiario, Versiones anteriores (RONIN)) |
| Memoria | Vertiso Memory, handoff con ámbito `ronin-juego` |

**Cómo pasar esto a un proyecto de Claude:** en claude.ai, abre el proyecto de RONIN y añade a
sus archivos este documento (está en Google Drive, `Respaldos Claude/ronin/01-Diseno/`; si el
proyecto no deja elegirlo desde Drive, descárgalo y súbelo), junto con `PLAN_PRODUCCION.md`.
Para retomar en un chat nuevo: «Lee HANDOFF_RONIN.md y CLAUDE.md y sigue con RONIN; mis
decisiones son: …». Si el chat tiene Vertiso Memory, el traspaso también está allí (ámbito
`ronin-juego`).

## 6. Riesgos y reglas

- **Historia base (no cambiar sin consultar):**
  - Akira, guardia de Takeda, que **desde el 1-10-2026 es el shōgun**. Tras la traición queda
    como ronin; busca justicia por fuera y recuperar su honor por dentro.
  - Villano: el general Genzo, mano derecha de Takeda. Lo asesinó creyéndolo demasiado blando,
    tras **pactar con el gran yōkai** creyendo proteger Japón. No se ve como villano y parte del
    pueblo lo apoya.
  - Empieza y termina en el castillo de Hoshiyama.
  - La sinopsis completa (`HISTORIA.md`) quedó **aprobada el 1-10-2026** (8A, y el gran yōkai es
    Tamamo-no-Mae, 9A); los textos del capítulo 1 ya la cuentan. Lo único abierto es la capa del Silencio
    (DECISIÓN 11).
- **Riesgos del plan:** alcance (seis géneros), combate poco profundo, controles táctiles para
  combate 3D, personajes hechos de piezas, rendimiento en móvil, nombre poco distintivo.
- **Reglas de trabajo:** todo en español, nombres de variables en español; el usuario marca la
  dirección (decisiones con el formato DECISIÓN).
- **PC del usuario modesto** (Windows, 0,5-1 GB de RAM libre): una cosa pesada a la vez.
- **Respaldos en Google Drive, nunca en OneDrive.** Textos con el conector de Google Drive;
  binarios (ZIP, capturas, sonidos) con Composio `GOOGLESUPER_UPLOAD_FROM_URL` desde las URL
  «raw» de GitHub; para reescribir un texto ya subido sin cambiar su enlace,
  `GOOGLESUPER_EDIT_FILE`. El APK (que no va a GitHub, que es público) se subió con una URL de
  subida temporal del workbench de Composio (la misma que usa `upload_local_file`), `curl -X PUT`
  desde la sesión y `GOOGLESUPER_UPLOAD_FROM_URL`; después se comprueba el MD5 en Drive. La
  clave de firma de prueba solo está en Drive (`03-Godot/firma-prueba`, guardada con permiso del
  usuario); nunca en GitHub.
- **Pedir permiso para descargas grandes** y verificar sumas de comprobación. **No publicar en
  redes.** Las páginas de claude.ai son privadas; compartirlas lo decide el usuario.
- **Imágenes:** Higgsfield por Composio, con `HIGGSFIELD_MCP_GENERATE_IMAGE_BATCH` y luego
  `HIGGSFIELD_MCP_JOBS_WAIT`.
  - Modelo `z_image` a 0,15 créditos por imagen; la cuenta es «basic».
  - El estilo común de los prompts está en `PROPUESTA_MUNDO_YOKAI.md` §10.
  - Nunca comprar créditos ni planes, ni usar el modo ilimitado, sin que el usuario lo pida.
  - Si una imagen sale negra, la cobran igual: cambiar el prompt antes de repetir.
- Notas técnicas de Godot: los scripts usan `preload()` en vez de `class_name`; la prueba se
  lanza con `godot --path ronin3d/godot --fixed-fps 30 -- --prueba` (en Linux sin pantalla, con
  `xvfb-run -a`). Con Compatibility, cada luz que toca un objeto lo vuelve a dibujar: el suelo y
  los muros van en trozos de 8 m.
