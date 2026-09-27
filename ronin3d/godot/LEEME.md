# RONIN 3D — versión Godot 4.7 (cel-shading)

Capítulo 1 (el patio del castillo de Hoshiyama, de noche) en 3D con **cel-shading**: luz en
bandas planas, brillo en los bordes y contorno negro. Es la versión principal del juego
(decisión del 27-09-2026). Renderizador **Compatibility** (OpenGL 3.3 / OpenGL ES 3.0): el más
ligero, para PC modestos y Android.

## Cómo abrirlo

1. Abre **Godot 4.7** (el mismo que usas para Trazzo).
2. Gestor de proyectos → **Importar** → elige `ronin3d/godot/project.godot`.
3. Pulsa **Ejecutar** (F5). La primera vez Godot importa los recursos (unos segundos).

## Controles

| Acción | Teclado y ratón | Mando | Pantalla táctil |
| --- | --- | --- | --- |
| Moverse | W A S D / flechas | Stick izquierdo | Joystick (mitad izquierda) |
| Correr | SHIFT | RB | Joystick hasta el borde |
| Saltar | ESPACIO | A | Botón «Saltar» |
| Atacar | J / clic izquierdo | X | Botón «Atacar» |
| **Parar** | **K** | **LB** | Botón «Parar» |
| Girar la cámara | Q / E, botón derecho + arrastrar | Stick derecho | Arrastrar el dedo |
| Zoom | Rueda, + / − | Cruceta arriba / abajo | — |
| Inclinar la cámara | R / F | Stick derecho | Arrastrar el dedo |
| Continuar en los textos | ENTER | A | Tocar la pantalla |
| Pausa | ESC (Q en pausa: salir) | Start | Botón «II» o «Atrás» (en pausa, «Atrás» sale) |

Los controles táctiles aparecen solos en pantallas táctiles. Para probarlos en el PC:
`godot --path ronin3d/godot -- --tactil` (el ratón hace de dedo). En el móvil el juego se pausa
solo si pasa a segundo plano (una llamada, cambiar de aplicación). Abajo a la derecha, junto a la
versión, salen los **FPS** (imágenes por segundo) para las pruebas.

## El combate (prototipo de precisión)

- Los soldados avisan con **«!»** y el golpe de madera del teatro (hyoshigi) antes de la
  estocada.
- **Parar (K) justo cuando van a golpear** desvía la lanza: chispas, un instante a cámara lenta y
  el soldado queda **sin guardia** 1,6 s. El siguiente corte lo derriba de un golpe.
- Parar a destiempo no sirve (la ventana es de 0,3 s) y hay que esperar 0,6 s para repetir.
- Al parar, Akira se gira solo hacia el soldado más cercano.
- Cada golpe tiene **pausa de impacto**, sacudida de cámara, chispas, estela de la espada y
  sonido. Los sonidos se generan con `sonidos/generar_sonidos.py` (sin librerías externas).

Los números están en `scripts/datos.gd` (sección Akira: `VENTANA_PARADA`, `ENFRIAMIENTO_PARADA`…)
para ajustarlos después de probar.

## Exportar

- **APK de prueba (ya hecho):** `ronin-0.2-prueba.apk` (26,9 MB) está en Google Drive, en
  `Respaldos Claude/ronin/`. Para instalarlo, ábrelo desde el móvil y acepta «instalar apps de
  origen desconocido» si Android lo pide. Pide Android 7.0 o superior y un móvil de 64 bits.
  SHA-256 `fecb802ad42221d863e2bbc4b9c0b3044f5eff865fc56be739cb6ef957439d60`.
- **Desde tu PC:** Proyecto → Exportar → **Android** → Exportar proyecto (como con Curtzz). El
  APK sale en `ronin3d/godot/exportaciones/` (esa carpeta no se sube a git). Hace falta lo mismo
  que para Curtzz: plantillas de exportación de Godot 4.7.2 y el SDK de Android configurado.
  Paquete provisional: `com.thunderdarkness.ronin` (se puede cambiar antes de publicar).
- **En la nube (así se hizo la 0.2):**
  1. Plantillas `Godot_v4.7.2-stable_export_templates.tpz` (1.281 MB, SHA-512 comprobado con el
     `SHA512-SUMS.txt` del release). Solo hacen falta `android_release.apk`, `android_debug.apk` y
     `version.txt`, en `~/.local/share/godot/export_templates/4.7.2.stable/`.
  2. De Android bastan `platform-tools` r37.0.1 y `build-tools` 35.0.1 (71 MB, SHA-1 comprobado
     con el manifiesto `repository2-3.xml` de Google), sin Android Studio ni `cmdline-tools`.
     En la configuración del editor, `export/android/android_sdk_path` apunta a esa carpeta.
  3. Exportación *release* (más rápida que la de depuración), firmada con una clave de prueba que
     se pasa con `GODOT_ANDROID_KEYSTORE_RELEASE_PATH`, `_USER` y `_PASSWORD` (ninguna clave va al
     repositorio):
     `godot --headless --path ronin3d/godot --export-release Android exportaciones/ronin-<versión>-prueba.apk`
  4. Comprobación con `apksigner verify --print-certs` y `aapt2 dump badging`, y la prueba
     automática sobre una exportación *release* para Linux (mismos datos que el APK).
- **Firma:** Android solo instala una versión encima de otra si las dos llevan la misma firma. La
  clave de prueba de la 0.2 (`CN=RONIN prueba`) se creó en la sesión de la nube y no se guardó
  fuera de ella: si la siguiente versión se exporta en otra sesión o en tu PC, hay que desinstalar
  la 0.2 antes de instalarla (todavía no hay partidas guardadas que perder).
- **Windows:** mismo menú → **Windows** → `exportaciones/ronin3d.exe`.

## Qué hay

- Intro con los textos de la historia sobre un plano del castillo y transición a la cámara de
  juego.
- Patio con las medidas de `../DISENO_3D.md`: muros, portón, torreón, pasarela, muro bajo,
  bloques, linternas, pozo, cajas, barriles y 8 antorchas con luz que parpadea.
- Akira: correr, saltar, atacar, parar; 5 de vida, retroceso e invulnerabilidad tras un golpe.
- 6 soldados con lanza: patrullan, te ven en un cono, persiguen sin alejarse de su puesto,
  avisan y atacan; si les paras, quedan sin guardia.
- Cámara orbital que no atraviesa muros y se sacude con los golpes. HUD con vida, soldados
  derrotados, ayuda (distinta en el móvil) y versión.
- Portón → texto de cierre. Vida 0 → «Akira ha caído» → reintentar. Pausa.

## Estructura

```
godot/
├── project.godot          Proyecto (Compatibility, 1280 × 720, icono)
├── export_presets.cfg     Exportación a Android (APK) y Windows
├── principal.tscn         Escena raíz
├── icono.png              Icono provisional
├── recursos/sombra.png    Sombra bajo los personajes
├── sonidos/               Efectos de sonido (.wav) y su generador
├── shaders/               cielo, toon (cel-shading) y contorno
└── scripts/
    ├── principal.gd       Controles, flujo intro → juego → cierre, pausa
    ├── juego.gd           Monta el capítulo y resuelve los golpes
    ├── aspecto.gd         Materiales cel-shading y ambiente de la noche
    ├── constructor_mundo.gd  El patio del castillo
    ├── akira.gd           Control de Akira (ataque y parada)
    ├── soldado.gd         IA de los soldados
    ├── camara_orbital.gd  Cámara que gira, esquiva muros y se sacude
    ├── efectos.gd         Pausa de impacto, cámara lenta, chispas y sonidos
    ├── controles_tactiles.gd  Joystick y botones para el móvil
    ├── visual_modelo.gd   Personajes hechos con piezas 3D
    ├── hud.gd             Interfaz
    ├── datos.gd           Medidas, reglas del combate, textos y colores
    └── prueba.gd          Prueba automática
```

## Prueba automática

Juega sola unos 26 segundos y comprueba 15 cosas: intro, caminar, HUD dentro de la pantalla,
cámara, espada, muros, portón, pausa, toques en la pantalla, joystick táctil, stick del mando,
parada a tiempo, contraataque y parada a destiempo. Mide los FPS y guarda capturas en
`../capturas/actual/`.

```
godot --path ronin3d/godot --fixed-fps 30 -- --prueba
```

Resultado en la nube (Godot 4.7.2, OpenGL por software, sin tarjeta gráfica): **15 de 15**, en el
editor y en la versión exportada (*release*); unos 11-13 FPS al caminar por el patio a 1280 × 720
(con tarjeta gráfica real va mucho más rápido).
