# Cuatro cajas: prototipos de juegos de puzles tipo The Room

Cuatro líneas de juego sobre un mismo núcleo, para descubrir con pruebas reales cuál merece
convertirse en juego. Se decidió el 02-10-2026 (DECISIÓN 22, en `PLAN.md`). RONIN queda en pausa en
la versión 0.9 mientras tanto.

## Documentos

- **Plan, decisiones y cómo se valida:** `PLAN.md`.
- **Análisis de The Room** (cómo está diseñada la serie, puzle a puzle y por principios):
  `ANALISIS_THE_ROOM.md`.
  - Anexos con la reconstrucción completa y sus fuentes: `referencia/the_room_1_y_2.md` y
    `referencia/the_room_3_y_old_sins.md`.
- **Biblia de diseño** (el sistema propio: concepto, reglas, plantillas, progresión, pistas, sonido,
  arte, arquitectura, fichas para programar, banco de puzles y control de originalidad):
  `BIBLIA_DISENO.md`.
- **Bocetos de las cuatro cajas** (03-10-2026), antes de construir: `bocetos/`. Su `LEEME.md` tiene
  la lectura de cada uno, el control de originalidad y si se pueden construir con esa calidad; los
  prompts, en `bocetos/PROMPTS.md`. Las DECISIONES 27 y 28 están en `PLAN.md` §6.
- **La caja viva ilustrada** (03-10-2026): el boceto de la A+C, animado por capas y jugable en el móvil.
  - Responde a «no se parece nada al boceto» tras la prueba de Blender.
  - Su técnica es la DECISIÓN 29 (abierta), en `PLAN.md` §7.
  - Método y comandos: `ilustrada/LEEME.md`.

## Carpetas

- **Proyecto de Godot 4.7** (renderizador Compatibility, Android): `godot/`.
- **Herramientas:** `herramientas/`.
  - Texturas, sonidos e iconos hechos por código, sin créditos de imágenes.
  - `hojas_bocetos.py`: junta los bocetos en hojas para revisarlos en el móvil.
- **Bocetos:** `bocetos/`.
- **Prueba ilustrada:** `ilustrada/`.
  - Las ilustraciones fuente.
  - `preparar_capas.py`.
  - La página jugable (`pagina/`).
  - Su prueba automática (`prueba/`).
- **Arte de origen:** `arte/` (de momento, la cara de la caja viva: el mapa de alturas de Gemini y lo que
  saca de él `herramientas/blender/preparar_cara.py`).
- **Modelos de Blender:** se hacen por código con `herramientas/blender/` y salen en `godot/modelos/`.
  Mientras la caja nueva no entre en el juego, `modelos/caja_viva/` queda fuera del APK (filtro de
  exportación).
- **Capturas:**
  - `capturas/gabinete.jpg`: el menú;
  - `capturas/entradas.jpg`: la cámara entrando en cada sala;
  - `capturas/cuatro_prototipos.jpg`: las cuatro cajas en juego;
  - `capturas/toques_y_examen.jpg`: el doble toque y el examen de objetos;
  - `capturas/resistencia.jpg`: cómo se resiste cada caja (0.3).

  Las PNG que deja la prueba automática no se suben a git.

## Qué hay en la 0.2.1 (03-10-2026)

**El gabinete:**
- un cuarto de coleccionista en 3D con los cuatro juegos en pedestales;
- la portada lleva a los juegos;
- cada juego tiene sus cajas: una jugable y dos selladas;
- desde las cajas se vuelve a elegir otro juego.

**Cuatro líneas, una caja jugable en cada una:**

| Juego | La idea en una frase | Su regla | Pasos | Sala |
| --- | --- | --- | --- | --- |
| **La caja viva** | Cajas secretas japonesas de cien años que han cobrado vida y no quieren que las abras. | La mirada: mientras el ojo te ve, no se deja tocar | 8 | Washitsu de noche |
| **La caja del relojero** | Un relojero desapareció en 1891. Sus cajas solo se abren a las horas que importan. | La hora: cuerda, horas de una carta y un billete, el engranaje que falta | 7 | Taller victoriano con chimenea y reloj de pie |
| **La reliquia** | Un artefacto de otro mundo. Guía su luz y escucha lo que despierta. | La luz: anillos con surcos que la desvían; el cristal cambia el camino | 7 | Santuario circular |
| **El cuarto del farero** | La tormenta arrecia y el farero no está. Enciende el faro. | El punto de vista: la habitación es la caja | 9 | La torre del faro |

Cada caja dura unos 5-15 minutos **[Estimación, sin probar aún con jugadores]**.

**Lo nuevo de la 0.2, pedido por el usuario tras probar la 0.1:**
- el menú vistoso, con juegos y cajas, del que se puede volver para elegir otro tipo de caja;
- cada caja en su sala, con una **entrada de cámara** que cruza la puerta y llega hasta la caja (se
  puede saltar);
- la caja ocupa menos pantalla y se acerca o se aleja con los dedos;
- **doble toque como en The Room:** la cámara viaja con suavidad al mecanismo tocado;
- letra más grande e iconos dibujados;
- **lo que no se puede mover ya no tiembla:** se queda quieto, suena trabado, vibra un poco y destella
  en cálido;
- la parte de atrás del escritorio del relojero se ve (placa de latón y luz propia);
- la ranura de la ficha de la caja viva pasa a la cara de atrás.

**Lo que corrige la 0.2.1:**
- el primer aviso de cada caja salía en un marco gigante que tapaba la pantalla;
- la puerta del taller tapaba la mitad de la entrada;
- el engranaje se veía negro y el cristal, blanco, al examinarlos.

**La 0.3, en el repositorio (todavía sin APK):**
- **La caja viva profunda:**
  - tiene 19 pasos: la cara incompleta, el incensario de la mesa, el rollo de la pared y el altar del
    final;
  - su aspecto se rehace según la DECISIÓN 27 (`bocetos/` y `PLAN.md` §6).
- **La resistencia creativa**, que pidió el usuario: lo bloqueado ni se mueve ni se marca, y el objeto
  se resiste a su manera (`BIBLIA_DISENO.md` §3.4). Hoja con cuatro momentos de cada caja:
  `capturas/resistencia.jpg`.

## Cómo se juega

- **Un dedo en el vacío:** girar alrededor del objeto (en el farero, mirar alrededor).
- **Doble toque:** acercarse al mecanismo o al punto tocado.
- **Pellizco:** acercar o alejar hacia los dedos. En el PC, la rueda del ratón.
- **Botón de centrar** (arriba a la derecha): volver a la vista general.
- **Un dedo sobre una pieza:**
  - arrastrarla: paneles, cajones, diales, manivela, anillos, tapas;
  - con un toque, la pieza avanza a su siguiente posición o se abre.
- **Lo que está bloqueado ni se mueve ni se marca:** suena «trabado» y el objeto se resiste a su manera:
  la caja viva contiene el aliento, el minutero dice que no, la luz de la reliquia se retira y la
  tormenta responde en el faro. Si insistes, va a más. La primera vez, una línea de texto explica por
  qué.
- **Objetos:**
  - se tocan para guardarlos en la columna de la izquierda;
  - se elige uno y se toca donde se quiere usar;
  - la **lupa** lo enseña en 3D (girar con un dedo, pellizcar para acercar).
- **Pista (?):** tres niveles por paso, de vaga a explícita. La tercera hace brillar la pieza.
- **Atrás:** pide confirmación (se pierde lo avanzado) y vuelve a las cajas de ese juego.
- **Al terminar**, una pantalla muestra **el tiempo, las pistas usadas y los intentos bloqueados**,
  y el gabinete guarda el mejor tiempo. Son los datos que se piden a los probadores.

## Estructura de `godot/`

- **`principal.gd`:** gabinete ↔ caja, con fundido. Argumentos:
  - `--prueba`;
  - `--caja=<id>`: abre una caja directamente;
  - `--juego=<id>`: abre el gabinete en las cajas de ese juego.
- **`catalogo.gd`:** los cuatro juegos y sus cajas (título, frase, color, guion); `VERSION`.
- **`gabinete.gd`:** el menú en 3D, con vitrinas que usan los propios guiones de las cajas.
- **Núcleo común:**
  - `mesa.gd`: monta la partida y reparte los toques entre la cámara y las piezas (doble toque,
    pellizco, arrastre). También lleva las pistas, el inventario con iconos, el examen, las
    métricas y el final;
  - `camara_puzle.gd`: órbita con inercia, zonas, viajes suaves, entrada por la sala y puntos de
    vista;
  - `hud.gd`: botones, pistas, progreso, inventario en columna, avisos, notas, examen, salida y
    resumen final;
  - `sonido.gd` y `estilo.gd`, este con letras, iconos y botones;
  - `piezas/`: deslizante, giratoria, bisagra, pulsador, recogible, ranura, nota y punto de vista.
    Cuando están bloqueadas, ni se mueven ni se marcan: suenan y avisan a su caja;
  - `puzle.gd`: la base de cada caja (pasos, pistas, zonas, entrada, vitrina, la resistencia de cada
    objeto con `resistir()` y lo que necesita la prueba);
  - `efectos.gd`: humo, polvo y motas de luz de un instante, para la resistencia;
  - `geometria.gd`, `materiales.gd`, `escena.gd` y `arquitectura.gd`: mallas, materiales, montaje de
    escenas y salas (paredes con huecos, puertas, ventanas, libros, relojes), todo por código.
- **`salas/`:** `washitsu.gd`, `taller.gd` y `santuario.gd`. La torre del farero está en su propio
  guion.
- **`prototipos/`:** `caja_viva.gd`, `relojero.gd`, `reliquia.gd` y `farero.gd`.
- **`shaders/`:** cielo, resalte de ayuda, surcos de luz, tormenta y niebla de Londres.
- **`recursos/`:**
  - texturas, sonidos e iconos;
  - fuentes: Liberation Serif, con licencia OFL (`recursos/fuentes/LICENCIA_OFL.txt`).

## Comandos

```bash
# Prueba automática: el gabinete y las cuatro cajas (entrada, bloqueo, doble toque, avisos,
# pistas, un arrastre real, examen y final)
xvfb-run -a godot --path puzles/godot --rendering-driver opengl3 -- --prueba        # 116 comprobaciones
xvfb-run -a godot --path puzles/godot --rendering-driver opengl3 -- --prueba --solo=farero

# Revisar que todos los guiones compilan, sin abrir el juego
godot --headless --path puzles/godot --script res://scripts/comprobar_guiones.gd

# Revisión visual: fotos de una caja desde sus zonas y en los pasos que se elijan (no va en el APK)
xvfb-run -a godot --path puzles/godot --rendering-driver opengl3 --fixed-fps 30 \
  --script res://scripts/vistas.gd -- --ver=caja_viva --zonas=cara,incensario --pasos=ojo --salida=/ruta/
# ...o un clip, cuadro a cuadro, de cómo se resiste a tres toques (en el farero, --resistencia=escritorio)
xvfb-run -a godot --path puzles/godot --rendering-driver opengl3 --fixed-fps 30 \
  --script res://scripts/vistas.gd -- --ver=relojero --resistencia --salida=/ruta/

# Hojas de bocetos para el móvil
python3 puzles/herramientas/hojas_bocetos.py <carpeta de salida>

# Modelos de Blender (4.5.14 LTS, en /root/herramientas/): la caja viva A+C y lo de su mesa
python3 puzles/herramientas/blender/preparar_cara.py
/root/herramientas/blender-4.5.14-linux-x64/blender -b -P puzles/herramientas/blender/caja_viva_ac.py \
  -- [--vista /ruta/vista.png]
godot --headless --path puzles/godot --import
# Prueba de calidad: la caja de Blender en su washitsu, con la luz del juego (no va en el APK)
xvfb-run -a godot --path puzles/godot --rendering-driver opengl3 --fixed-fps 30 \
  --script res://scripts/prueba_calidad.gd -- --salida=/ruta/

# Volver a generar texturas, sonidos e iconos
python3 puzles/herramientas/generar_texturas.py [nombre ...]
python3 puzles/herramientas/generar_sonidos.py [grupo ...]
python3 puzles/herramientas/generar_iconos.py
```

- **Tras generar texturas nuevas hay que reimportar** con
  `godot --headless --path puzles/godot --import`. En sus `.import`:
  - `compress/mode=2`, `mipmaps/generate=true` y `detect_3d/compress_to=0`;
  - en las `_n` (relieve) y en la esfera del reloj, `process/size_limit=512`, que le quita peso al
    APK.
- **Tras añadir un guion con `class_name`** también hay que reimportar: si no, Godot no lo encuentra
  («not declared»).
- **El símbolo del ofuda** («百年封印», sello de cien años) se dibuja con la fuente IPAGothic del
  sistema solo para crear la imagen. La fuente no va dentro del juego.

## Exportar el APK

Igual que RONIN (`ronin3d/godot/LEEME.md`, sección «Exportar»): plantillas de Godot 4.7.2, SDK de
Android y la clave de prueba con las variables `GODOT_ANDROID_KEYSTORE_RELEASE_*`.

```bash
godot --headless --path puzles/godot --export-release Android exportaciones/puzles-<versión>-prueba.apk
```

**La versión 0.2.1 [Hecho, comprobado con apksigner y aapt2]:**

| Dato | Valor |
| --- | --- |
| Peso | 49,9 MB |
| Paquete | `com.thunderdarkness.puzles`, nombre «Cuatro cajas»; versión 0.2.1 (código 3) |
| Android | 64 bits; pide permiso de vibración |
| Firma | Clave de prueba de RONIN (`CN=RONIN prueba`): se instala encima de la 0.1 |
| SHA-256 | `901ba26cff9ba445b7163f0646565b5da62422b54c043ed84a157306a7e66a54` |

Está en Google Drive, en `Respaldos Claude/puzles/`. La 0.1 está en «Versiones anteriores
(puzles)». Al usuario se le manda también en partes de 10 MB (`.zip.001…`), que se juntan abriendo la
primera con ZArchiver.

**Versiones:**
- **0.1** (02-10-2026): los cuatro prototipos, 43,9 MB.
- **0.2** (03-10-2026): el gabinete, las salas y la cámara. Se sustituyó el mismo día por la 0.2.1,
  que corrige tres fallos.
