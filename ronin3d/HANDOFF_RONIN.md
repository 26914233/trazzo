# RONIN — Traspaso del proyecto (handoff)

**Última actualización:** 27 de septiembre de 2026 · sesión de Claude Code en la nube
**Leer entero antes de seguir.** Copia en Google Drive: `Respaldos Claude/ronin/01-Diseno/`.
**Forma de trabajar:** las instrucciones del usuario (equipo multidisciplinario de videojuegos:
Game Director, diseño, producción, marketing, negocio…) están en `CLAUDE.md`, en la raíz del
repositorio. Síguelas: fases, MVP/Must/Should/Nice, formato DECISIÓN y hablar como socio.

---

## 1. Objetivo

Convertir **RONIN** (samurái Akira, historia fija) en un juego real, divertido y viable. Tras
comparar cinco versiones, el usuario eligió **Godot 4.7 + cel-shading** y, como alcance, **un
núcleo con variaciones y lanzamiento por capítulos** (opción C; los dos, 27-09-2026). Ahora toca
llegar al **vertical slice** «Una noche en Hoshiyama» (`ronin3d/PLAN_PRODUCCION.md`, §5), que
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
- **Controles:** teclado/ratón, **mando** y **pantalla táctil** (joystick, Atacar, Parar,
  Saltar, pausa, arrastrar para la cámara, tocar para seguir). `--tactil` los muestra en el PC.
- **Combate de precisión (prototipo):** K / LB / botón «Parar» justo al aviso «!» desvía la
  estocada, el soldado queda sin guardia 1,6 s y el contraataque lo derriba de un golpe; a
  destiempo no sirve. **Sensación:** pausa de impacto, cámara lenta en la parada, sacudida,
  chispas, estela de la espada y 7 sonidos generados (`sonidos/generar_sonidos.py`).
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

## 3. En curso / pendiente del usuario

1. **Probar el APK en el móvil** y contar: FPS (meta ≥ 30), si los controles táctiles se
   entienden y qué tal se siente la parada.
2. **DECISIÓN 2 — Combate:** recomendación B (precisión), después de probarla.
3. **Clave de firma de prueba:** la de la 0.2 solo existe en la sesión de la nube que la creó
   (no se subió a ningún sitio). Si la siguiente versión sale de otra sesión o de su PC, hay que
   desinstalar la 0.2 antes. Si quiere que se instalen encima, que decida dónde guardar una
   clave fija (por ejemplo, exportar siempre desde su PC, como con Curtzz).
4. Si tiene el `samurai.py` original, subirlo.

## 4. Siguiente

1. Vertical slice (§5 del plan), base del primer capítulo: ajustar la parada con lo que diga
   el usuario, un rival distinto (arquero o capitán), salida a la planicie con un encuentro de
   dados, aldea mínima, menú y guardado, música. El detalle (luces, sombras, soldados) se ajusta
   a los FPS que dé su móvil.
2. Mejorar personajes (siguen hechos de piezas simples) y la estela/efectos tras verlos en el
   móvil.
3. Buscar nombre o subtítulo propio antes de cualquier página de tienda.

## 5. Dónde está todo

| Qué | Dónde |
| --- | --- |
| Código | GitHub `26914233/trazzo`, rama `claude/ronin-pygame-setup-szn3rn` (repo público) |
| Instrucciones para Claude | `CLAUDE.md` (raíz) |
| Índice del proyecto | `ronin3d/LEEME.md` |
| El juego | `ronin3d/godot/` (LEEME con controles, combate, exportación y prueba) |
| Plan | `ronin3d/PLAN_PRODUCCION.md` |
| Comparativa | `ronin3d/COMPARATIVA.md` · página privada https://claude.ai/artifact/6urV5FCikt9CWAUV35gBCu |
| Capturas de hoy | `ronin3d/capturas/actual/` |
| APK de prueba | Drive `Respaldos Claude/ronin/ronin-0.2-prueba.apk` (como con Curtzz: el nuevo va en la raíz con el nombre `ronin-<versión>-prueba.apk` y el anterior pasa a «Versiones anteriores (RONIN)») |
| Respaldo | Google Drive `Respaldos Claude/ronin/` (01-Diseno, 02-Prototipo-2D, 03-Godot, 04-Otros-motores) |
| Memoria | Vertiso Memory, handoff con ámbito `ronin-juego` |

**Cómo pasar esto a un proyecto de Claude:** en claude.ai, abre el proyecto de RONIN y añade a
sus archivos este documento (está en Google Drive, `Respaldos Claude/ronin/01-Diseno/`; si el
proyecto no deja elegirlo desde Drive, descárgalo y súbelo), junto con `PLAN_PRODUCCION.md`.
Para retomar en un chat nuevo: «Lee HANDOFF_RONIN.md y CLAUDE.md y sigue con RONIN; mis
decisiones son: …». Si el chat tiene Vertiso Memory, el traspaso también está allí (ámbito
`ronin-juego`).

## 6. Riesgos y reglas

- **Historia base (no cambiar sin consultar):** Akira, guardia del señor Takeda; tras la
  traición queda como ronin; busca justicia por fuera y recuperar su honor por dentro.
  Villano: el general Genzo, mano derecha de Takeda, lo asesinó creyéndolo demasiado blando;
  no se ve como villano y parte del pueblo lo apoya. Empieza y termina en el castillo de
  Hoshiyama.
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
  desde la sesión y `GOOGLESUPER_UPLOAD_FROM_URL`; después se comprueba el MD5 en Drive. Las
  claves de firma no salen de la sesión.
- **Pedir permiso para descargas grandes** y verificar sumas de comprobación. **No publicar en
  redes.** Las páginas de claude.ai son privadas; compartirlas lo decide el usuario.
- Notas técnicas de Godot: los scripts usan `preload()` en vez de `class_name`; la prueba se
  lanza con `godot --path ronin3d/godot --fixed-fps 30 -- --prueba` (en Linux sin pantalla, con
  `xvfb-run -a`). Con Compatibility, cada luz que toca un objeto lo vuelve a dibujar: el suelo y
  los muros van en trozos de 8 m.
