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
| **Iai** (mantener y soltar al «!») | **K** | **LB** | Botón «Iai» |
| **Corte de luna** (barra llena) | **L** | **Y** | Botón «Luna» |
| Animación anime / suave | T | Select | En la pausa, tocar «Animación» |
| Galería de criaturas (prueba) | G en la pausa | — | En la pausa, tocar «Galería de criaturas» |
| Sastre: ver el siguiente aspecto / comprarlo | V / B en la pausa | — | En la pausa, tocar «Sastre · …» / «Comprar…» |
| Rezar al jizō (estando cerca) | ENTER | B | Tocar el aviso |
| Girar la cámara | Q / E, botón derecho + arrastrar | Stick derecho | Arrastrar el dedo |
| Zoom | Rueda, + / − | Cruceta arriba / abajo | — |
| Inclinar la cámara | R / F | Stick derecho | Arrastrar el dedo |
| Continuar en los textos | ENTER | A | Tocar la pantalla |
| Pausa | ESC (Q en pausa: salir) | Start | Botón «II» o «Atrás» (en pausa, «Atrás» sale) |

Los controles táctiles aparecen solos en pantallas táctiles. Para probarlos en el PC:
`godot --path ronin3d/godot -- --tactil` (el ratón hace de dedo). En el móvil el juego se pausa
solo si pasa a segundo plano (una llamada, cambiar de aplicación). Abajo a la derecha, junto a la
versión, salen los **FPS** (imágenes por segundo) para las pruebas.

## El combate (precisión con iaidō, decidido el 1-10-2026)

- Los soldados avisan con **«!»** y el golpe de madera del teatro (hyoshigi) antes de la
  estocada.
- **Iaidō:** mantén **K** y Akira se pone en postura, con la mano en la empuñadura y girado hacia
  el soldado más cercano. **Suéltalo justo cuando van a golpear:** el desenvaine desvía la lanza y
  derriba al soldado de un solo corte. Se ve con pausa de impacto, cámara lenta, un cuadro de
  tinta invertida y la pose final (zanshin).
- Soltar a destiempo solo corta el aire: la ventana es de 0,3 s y hay que esperar 0,6 s para
  repetir. Así no se puede abusar de él.
- **Barra de espíritu** (bajo la vida): el iai perfecto da media barra y cada golpe de espada,
  una décima. Llena, brilla en dorado con «LUNA».
- **Corte de luna (L):** el tiempo se congela, la pantalla se vuelve tinta, aparecen las líneas
  de corte una tras otra y caen todos los enemigos a menos de 7 m. Si no hay nadie cerca, avisa y
  no gasta la barra.
- **Animación:** por defecto es **estilo anime limitado**: las poses cambian 12 veces por segundo,
  como en el anime, y los cambios de pose, golpes y caídas se ven al instante. **T** cambia a la
  animación suave (cada imagen) para comparar.
- Cada golpe tiene **pausa de impacto**, sacudida de cámara, chispas, estela de la espada y
  sonido. Los sonidos se generan con `sonidos/generar_sonidos.py` (sin librerías externas).

Los números están en `scripts/datos.gd`, en la sección Akira: `VENTANA_PARADA`,
`ENFRIAMIENTO_PARADA`, `ESPIRITU_POR_IAI`, `RADIO_CORTE_LUNA`, `PASO_ANIME`… Se ajustan después
de probar.

## Akira, Shiro y las monedas (nuevo en la 0.6)

- **Akira, el joven endurecido** (elegido el 02-10-2026):
  - cicatriz en diagonal por la cara, mirada dura, cinta roja deshilachada, ropa remendada y vendas;
  - **tres skins**: curtido (unos 30), veterano (unos 40) y Akira mujer;
  - se cambian en la pausa (**V** o tocando «Akira: …») y el juego recuerda la elegida (`user://ajustes.cfg`);
  - datos de cada aspecto en `scripts/apariencias_akira.gd`.
- **Shiro**, su perro blanco:
  - le sigue, se sienta cuando Akira se para y se agacha detrás si hay soldados alerta;
  - en calma, olfatea, ladra, escarba y desentierra monedas, y trae las que se quedan atrás;
  - no pelea y nadie le ataca. Reglas y números en `../DISENO_3D.md` y `scripts/datos.gd`.
- **Monedas «mon»:** las sueltan los soldados y las desentierra Shiro. Akira las recoge al pasar y el
  contador sale bajo la vida.
- **Arreglo:** la pausa ahora para el juego de verdad (antes los soldados seguían moviéndose).

### En qué se gastan las monedas (nuevo en la 0.7, DECISIÓN 16 A + C)

- **Estatua jizō** (junto al muro oeste, cerca del inicio):
  - al acercarse sale un aviso con el precio;
  - rezar (ENTER, B en el mando o tocar el aviso) da +1 de vida máxima y cura del todo;
  - cuesta 40 mon la primera vez y 80 la segunda.
- **Sastre** (en la pausa mientras no exista la aldea):
  - las skins empiezan bloqueadas: curtido 30, mujer 40 y veterano 60;
  - V enseña la siguiente y B la compra;
  - lo que no se compra no se queda puesto.
- **La partida se guarda** (`user://partida.cfg`): monedas, skins compradas y bendiciones. Se guarda
  sola poco después de cada cambio, al salir y al pasar a segundo plano. Los precios, en
  `scripts/partida.gd`.
- **Textos (DECISIÓN 17A):** la intro cuenta la cicatriz y que Shiro, el perro del shōgun, huye con
  Akira; el cierre, que cruza la puerta con Shiro.

## Personajes en pixel art (nuevo en la 0.9, DECISIÓN 20E)

Akira (con sus 4 skins), los soldados y Shiro son **sprites de píxeles** dentro del mundo 3D, como en
la referencia que eligió el usuario.
- **Cómo se hacen:** se hornean desde los modelos de piezas, con todas sus poses y desde 8 direcciones:
  1. `godot --path ronin3d/godot --script res://scripts/hornear_sprites.gd [id …]` dibuja cada pose
     con una cámara ortográfica a 26 píxeles por metro. Deja las hojas en crudo en
     `../herramientas/sprites_crudos/`, que no va a git.
  2. `python3 ronin3d/herramientas/pulir_sprites.py` deja la transparencia en todo o nada, aclara los
     oscuros, reduce la paleta a 40 colores y pone un contorno de 1 px. Las hojas finales y su
     descripción van a `recursos/sprites/`.
  3. Si Godot las importa de nuevo, en sus `.import` va `detect_3d/compress_to=0` (sin compresión de
     vídeo) y `mipmaps/generate=false`.
- **En el juego:** `scripts/visual_sprite.gd` con `shaders/sprite_pixel.gdshader`.
  - Cada personaje es un cartel que siempre mira a la cámara.
  - La fila de la hoja la decide desde dónde lo ve la cámara (8 direcciones) y el cuadro, la pose, a 12
    por segundo.
  - Recibe la luz de las antorchas y de la luna.
  - Las estelas del corte, el «!» y la moneda de Shiro siguen en 3D.
- `-- --modelos3d` enseña los modelos de piezas de antes (los que se hornean).
- **El mundo:** sin la línea negra del cel-shading, y con un desenfoque de profundidad al estilo HD-2D
  (`shaders/profundidad.gdshader`, por la altura en pantalla, porque Compatibility no tiene profundidad
  de campo).

## Cabezas y caras dibujadas (nuevo en la 0.8)

Para que los personajes se parezcan más a un dibujo de anime y la cabeza no se vea como una bola:

- **Pelo en mechones** (conos unidos en una sola malla): puntas, flequillo, patillas a los lados de la
  cara, moño o coleta según la skin. La barba del veterano también va en mechones.
- **Cara dibujada:** ojos, cejas, nariz y boca son una imagen 2D (`recursos/caras/cara_<skin>.png`) que
  `shaders/toon_cara.gdshader` proyecta sobre la cabeza y el mentón, como en los juegos de anime en 3D.
  - Las imágenes las dibuja `recursos/caras/generar_caras.py` (Python con PIL): `python3
    recursos/caras/generar_caras.py`.
  - También se pueden redibujar a mano: es un PNG de 256 × 256 con transparencia. Cubre de -0,12 a
    0,12 m en horizontal y de -0,13 a 0,11 m en vertical, vista de frente.
- **Cinta a medida:** pegada a la frente y por encima del pelo, con el nudo y las puntas detrás.
- **Soldados:** protector de cuello (shikoro), máscara (menpō) y la sombra del sombrero sobre los ojos.
- **Línea de grosor casi constante** (`shaders/contorno.gdshader`): entre 1,3 y 3,5 píxeles a 720p,
  como el trazo de un dibujo. Los límites son `minimo_px` y `maximo_px`.
- Para revisarlos de cerca: `godot --path ronin3d/godot --script res://scripts/retrato.gd -- akira`
  (las cuatro skins, un soldado y Shiro; deja las imágenes en `../capturas/actual/`).

## Prueba de estilos de render (sin cambios en el juego)

`godot --path ronin3d/godot --script res://scripts/estilos_render.gd` dibuja los mismos personajes en
seis estilos: cel-shading, manga de tinta, sumi-e, ukiyo-e, pixel art 3D y 3D realista.
- Hace tres vistas de cada estilo: en fila, la cara y un combate en el patio con la cámara del juego.
- También mide cuánto tarda cada uno en dibujar el patio.
- Las imágenes van a `../capturas/estilos_render/`, y `python3 ronin3d/herramientas/hoja_estilos.py`
  monta la hoja `../capturas/comparativa_estilos_personajes.jpg`.
- Los filtros son shaders de pantalla en `shaders/estilos/`. Se aplican al SubViewportContainer que
  dibuja el mundo; el pixel art lo dibuja además a ¼ de resolución.
- Es la base de la DECISIÓN 20 (`../PLAN_PRODUCCION.md` §17).

## Galería de criaturas (nueva en la 0.4)

Sirve para ver y medir el sistema que construye criaturas con piezas (`../BESTIARIO_UNIVERSAL.md`):

- **Cómo se abre:** en el juego, pausa → **Galería de criaturas** (tocando el botón en el móvil, o tecla **G**).
  Desde la línea de comandos: `godot --path ronin3d/godot -- --galeria` (con `--capturas` guarda una imagen
  por página en `../capturas/actual/` y sale).
- **Cómo se usa:** ← → o tocar el tercio izquierdo/derecho de la pantalla cambia de página; **ESC** o tocar
  arriba a la derecha vuelve a la pausa. Arriba salen los **FPS**, las criaturas y las piezas de la página.
- **Qué enseña (10 páginas):**
  1. **Akira y Shiro (nueva en la 0.6):** el joven endurecido, sus tres skins y Shiro.
  2. **Modelos detallados (0.5):** Chōchin-obake (SketchUp), kappa y Aka-oni (SAM 3D), cada uno junto a
     su versión de piezas y con sus tres rangos.
  3. Las 4 criaturas del capítulo 1 hechas a mano.
  4. Los tres rangos (base, alfa, silenciada).
  5. Las 7 familias de cuerpo.
  6. Criaturas icónicas hechas solo con piezas (para ver por qué necesitan modelo propio).
  7. Del catálogo, una **prueba de carga con 24 criaturas medianas**.
  8. a 10. Muestras de pequeñas, grandes y gigantes.
- **Lo que hay que mirar en el móvil:** que vayan a **30 FPS o más** la página 2 (modelos detallados),
  la 5 (7 criaturas) y la 7 (24 criaturas). Es la medida que decide el presupuesto de piezas y de
  triángulos. (En la 0.5 eran las páginas 1, 4 y 6.)

## Exportar

- **APK de prueba (ya hecho):** `ronin-0.9-prueba.apk` está en Google Drive, en
  `Respaldos Claude/ronin/` (tamaño y SHA-256 en `../HANDOFF_RONIN.md`). Para instalarlo, ábrelo desde
  el móvil y acepta «instalar apps de origen desconocido» si Android lo pide. Pide Android 7.0 o
  superior y un móvil de 64 bits. Se instala encima de las anteriores (misma firma); están en
  «Versiones anteriores (RONIN)».
  - Trae a Akira endurecido, a Shiro, las monedas, el jizō, el sastre (skins bloqueadas) y la
    partida guardada. La 0.8 añadió las cabezas nuevas y la 0.9, los personajes en pixel art.
  - **Peso de cada modelo dentro del APK:** Aka-oni 1,2 MB (malla 0,5 + textura 0,7), kappa 2,2 MB
    y Chōchin-obake 0,1 MB (SketchUp: colores planos).
- **Desde tu PC:** Proyecto → Exportar → **Android** → Exportar proyecto (como con Curtzz). El
  APK sale en `ronin3d/godot/exportaciones/` (esa carpeta no se sube a git). Hace falta lo mismo
  que para Curtzz: plantillas de exportación de Godot 4.7.2 y el SDK de Android configurado.
  Paquete provisional: `com.thunderdarkness.ronin` (se puede cambiar antes de publicar).
- **En la nube (así se hicieron de la 0.2 a la 0.9):**
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
- **Firma:** Android solo instala una versión encima de otra si las dos llevan la misma firma.
  Todas las versiones de prueba se firman con `ronin-prueba.keystore` (`CN=RONIN prueba`), la
  clave de la 0.2, guardada con permiso del usuario en Drive › `ronin/03-Godot/firma-prueba/`
  junto con un LEEME (alias, contraseña y cómo usarla en el PC o en la nube). Nunca va al
  repositorio, que es público. No es la clave para Google Play.
- **Windows:** mismo menú → **Windows** → `exportaciones/ronin3d.exe`.

## Qué hay

- Intro con los textos de la historia sobre un plano del castillo y transición a la cámara de
  juego.
- Patio con las medidas de `../DISENO_3D.md`: muros, portón, torreón, pasarela, muro bajo,
  bloques, linternas, pozo, cajas, barriles y 8 antorchas con luz que parpadea.
- Akira: correr, saltar, atacar, iai y corte de luna; 5 de vida, barra de espíritu, retroceso e
  invulnerabilidad tras un golpe. Cuatro aspectos (el joven endurecido y tres skins).
- Shiro, el perro: le sigue, escarba y desentierra monedas, y trae las que se quedan atrás.
- Monedas: las sueltan los soldados y las desentierra Shiro; contador en el HUD. Se gastan en el jizō
  (+1 de vida) y en el sastre (skins), y se guardan entre partidas.
- 6 soldados con lanza: patrullan, te ven en un cono, persiguen sin alejarse de su puesto,
  avisan y atacan.
- Capa de tinta (`shaders/tinta.gdshader`): cuadros de impacto y líneas del corte de luna.
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
├── recursos/caras/        Caras dibujadas de cada personaje (PNG) y su generador
├── recursos/sprites/      Hojas de sprites pixel art (PNG) y su descripción (JSON)
├── datos/bestiario.json   Las criaturas del catálogo (lo genera ronin3d/herramientas/bestiario/unir_clasificacion.py)
├── sonidos/               Efectos de sonido (.wav) y su generador
├── shaders/               cielo, toon (cel-shading), toon_cara (caras dibujadas), toon_textura (modelos detallados), contorno y tinta
│   ├── sprite_pixel        Los personajes en pixel art (cartel que mira a la cámara)
│   ├── profundidad         Desenfoque de profundidad al estilo HD-2D
│   └── estilos/           Filtros de la prueba de estilos: tinta_manga, sumie, ukiyoe, pixel y cara_realista
├── modelos/criaturas/     Modelos detallados (GLB) y su LEEME: cómo se hicieron, sumas y licencias
└── scripts/
    ├── principal.gd       Controles, flujo intro → juego → cierre, pausa
    ├── juego.gd           Monta el capítulo y resuelve los golpes
    ├── aspecto.gd         Materiales cel-shading y ambiente de la noche
    ├── constructor_mundo.gd  El patio del castillo
    ├── akira.gd           Control de Akira (ataque, iai, espíritu y corte de luna)
    ├── soldado.gd         IA de los soldados
    ├── camara_orbital.gd  Cámara que gira, esquiva muros y se sacude
    ├── efectos.gd         Pausa de impacto, cámara lenta, chispas, sonidos y corte de luna
    ├── tinta.gd           Capa de tinta: cuadros de impacto y líneas de corte
    ├── controles_tactiles.gd  Joystick y botones para el móvil
    ├── visual_sprite.gd   Personajes en pixel art: dirección y cuadro de su hoja según la pose
    ├── hornear_sprites.gd Hornea las hojas de sprites desde los modelos de piezas
    ├── visual_modelo.gd   Personajes hechos con piezas 3D y sus poses (de ellos salen los sprites)
    ├── apariencias_akira.gd  Los cuatro aspectos de Akira (el joven endurecido y tres skins)
    ├── shiro.gd           El perro de Akira: seguirle, escarbar y traer monedas
    ├── visual_shiro.gd    Shiro hecho con piezas y sus poses
    ├── monedas.gd         Monedas «mon»: saltan, giran, se recogen; su malla con agujero cuadrado
    ├── partida.gd         Lo que se guarda (monedas, skins compradas, bendiciones) y los precios
    ├── jizo.gd            La estatua jizō del patio
    ├── hud.gd             Interfaz
    ├── criatura_modular.gd  Construye una criatura a partir de una receta (familia, tamaño, elemento, rol, rango)
    ├── modelo_criatura.gd   La misma interfaz con un modelo detallado (GLB): cel-shading, rangos, garrote, agua
    ├── retrato.gd         Retratos de cerca (--script res://scripts/retrato.gd -- <id | akira>)
    ├── estilos_render.gd  Prueba de estilos de render (--script res://scripts/estilos_render.gd)
    ├── extraer_lod.gd     Saca un LOD de un modelo importado a un archivo (visor 3D del chat)
    ├── galeria.gd         Galería de criaturas: páginas, FPS y capturas
    ├── datos.gd           Medidas, reglas del combate, textos y colores
    └── prueba.gd          Prueba automática
```

## Prueba automática

Juega sola unos 43 segundos y comprueba 32 cosas (con una partida nueva en memoria: no toca la
guardada):

- los textos del capítulo 1 (shōgun Takeda, yōkai, luna roja), intro, caminar, HUD dentro de la pantalla y cámara;
- espada, defensa del soldado, muros y portón;
- que la pausa para el juego de verdad, toques en la pantalla, joystick táctil y stick del mando;
- iai perfecto, iai a destiempo y corte de luna;
- animación anime (12 poses por segundo) frente a la suave;
- la galería de criaturas: se abre desde la pausa, reparte páginas y al cerrarla el juego sigue entero;
- el catálogo del bestiario (`datos/bestiario.json`): se carga con todos sus datos válidos y **todas sus
  criaturas se construyen** dentro del presupuesto de piezas;
- los modelos detallados: se cargan con textura y cel-shading, y el Aka-oni mide lo que debe en sus tres
  rangos (sin contar el garrote, que va levantado);
- los cuatro aspectos de Akira (todos con la cicatriz, distintos entre sí, y se cambian en la pausa);
- los sprites pixel art: las 6 hojas con todas sus poses, y la dirección cambia al girar la cámara;
- Shiro: sigue a Akira, desentierra monedas y trae las que se quedan atrás; los soldados sueltan
  monedas y Akira las recoge (el HUD las cuenta);
- el sastre (skins bloqueadas que se compran), el jizō (+1 de vida por monedas) y el guardado de la
  partida.

Mide los FPS y guarda capturas en `../capturas/actual/`.

```
godot --path ronin3d/godot --fixed-fps 30 -- --prueba
```

Con `RONIN_FOTOGRAMAS=<carpeta>` guarda además los fotogramas del iai y del corte de luna, y
`python3 ronin3d/herramientas/hacer_gifs.py <carpeta> ronin3d/capturas/actual` los convierte en GIF.

Resultado en la nube (Godot 4.7.2, OpenGL por software, sin tarjeta gráfica): **31 de 31** en la
0.8 y en la 0.7, 32 de 32 en la 0.9 (28 de 28 en la 0.6), y unos 10-13 FPS al caminar por el patio a 1280 × 720. Las 929 criaturas del
catálogo se construyen en medio segundo (20,5 piezas de media por criatura, 42 como máximo). Con tarjeta gráfica real va mucho
más rápido. La 0.2 pasó también la prueba en una exportación *release* para Linux.
