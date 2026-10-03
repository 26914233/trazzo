# Cuatro cajas: plan

Juego de puzles tipo The Room. Hoy son **cuatro prototipos** para elegir, con datos de jugadores, cuál
se convierte en el primer juego que se lanza.
- **Índice y comandos:** `LEEME.md`.
- **Análisis de la referencia:** `ANALISIS_THE_ROOM.md`.
- **Sistema de diseño propio:** `BIBLIA_DISENO.md`.

Marcas: **[Hecho]** comprobado con fuente, **[Estimación]**, **[Supuesto]**, **[Hipótesis]** u
**[Opinión]**.

## 1. Por qué un juego de puzles primero

- **RONIN con el nivel de Octopath u Ethra es trabajo de un equipo durante mucho tiempo [Opinión].**
  Un juego de puzles de objetos se puede terminar y lanzar con nuestros medios.
- **The Room** [Hecho]:
  - lo hicieron 2 personas fijas con ayuda puntual, en 6-8 meses;
  - costó menos de 80.000 libras (otra fuente dice 160.000);
  - recuperaron la inversión en su primera semana;
  - la serie pasó los 11,5 millones de copias en 2016.

  Fuentes: [cómo se hizo The Room](https://www.pocketgamer.biz/thinking-outside-the-box-the-making-of-the-room/)
  y [The Room en Wikipedia](https://en.wikipedia.org/wiki/The_Room_(video_game)).
- **Rusty Lake** [Hecho]:
  - tiene 4 empleados fijos y usa juegos cortos gratis como puerta a los de pago;
  - suma más de 75 millones de descargas;
  - el 60 % de sus ventas viene de Steam y el 35 % del móvil.

  Fuente: [GameDiscoverCo](https://newsletter.gamediscover.co/p/how-rusty-lakes-immersive-puzzle).
- **Escape Simulator** pasó los 2 millones de copias en PC en poco más de dos años [Hecho;
  [fuente](https://filmneweurope.com/news/croatia-news/item/125389-croatia-s-pine-studio-sells-two-million-copies-of-escape-simulator-game)].
- **Encaja con nuestros límites [Opinión]:**
  - un objeto visto de cerca, sin personajes que animar ni mundo grande;
  - pensado para el dedo;
  - funciona en el renderizador Compatibility, como RONIN.
- **Riesgos:**
  - 2026 no es 2012. The Room despegó porque Apple lo destacó [Hecho, lo dicen sus creadores] y hoy
    hay muchos clones: sin identidad propia, se pierde [Opinión].
  - El corazón es el diseño de puzles, y se juega una sola vez: el modelo pide pago único o una
    primera caja gratis [Opinión].

### DECISIÓN 22 — Qué lanzamos primero · **DECIDIDA el 02-10-2026**

- **OPCIONES:**
  - A) seguir con RONIN;
  - B) tipo The Room con otra idea;
  - C) tipo The Room con cajas japonesas vivas;
  - D) terminar Trazzo primero.
- **ELECCIÓN DEL USUARIO:** «algo ambicioso»: la **C y la B en paralelo**, y para la B, **las tres**
  ideas propuestas: misterio clásico, reliquia de otro mundo y habitación de escape.
- **CÓMO SE HIZO:** cuatro prototipos pequeños sobre **un mismo núcleo**, para que se puedan comparar
  y no cuesten cuatro veces más. En paralelo van los prototipos, no cuatro producciones: tras la
  prueba se elige uno (DECISIÓN 23).
- **RONIN** queda en pausa en la 0.9, a salvo en el repositorio y en Drive.

## 2. Los prototipos (versión 0.1, 02-10-2026)

Los cuatro comparten:
- controles táctiles;
- pistas en tres niveles;
- inventario;
- sonido y vibración;
- un resumen final con tiempo, pistas e intentos bloqueados.

Arte y sonido están hechos por código **[Hecho]**: sin créditos de imágenes y sin descargas. Duración
de cada uno: 5-15 minutos **[Estimación]**.

1. **La caja viva:** *himitsu-bako* de Hakone convertida en *tsukumogami*.
   - [Hecho] Las *himitsu-bako* son cajas secretas de Hakone con unos 200 años de historia. Se abren
     con una secuencia de 4 a más de 60 movimientos y van decoradas con mosaico *yosegi-zaiku*
     ([fuente](https://www.theculturetrip.com/asia/japan/articles/a-brief-history-of-japanese-puzzle-boxes)).
   - **Mecánica propia:** el ojo. Mientras te ve, la caja no deja tocar sus paneles: hay que girarla
     y trabajar por su punto ciego. Al final se duerme con una ficha de shōgi.
   - **Pasos:**
     1. costado derecho;
     2. tapa, primer tramo;
     3. costado izquierdo (sin que te vea);
     4. tapa, segundo tramo;
     5. coger la ficha;
     6. ficha en la base (se duerme);
     7. disco en la ola;
     8. abrir la cara delantera.
   - Usa el estilo de RONIN (laca, rojo bermellón, yōkai) **sin tocar su historia**.
2. **La caja del relojero** (misterio clásico, Londres 1891).
   - **Mecánica propia:** el reloj es la llave. Hay que darle cuerda y poner las horas que cuentan una
     carta y un billete de tren; además, le falta un engranaje a la maquinaria.
   - **Pasos:**
     1. cuerda;
     2. las 3:00 (suelta el cajón);
     3. abrir el cajón;
     4. coger el engranaje;
     5. ponerlo en la maquinaria de atrás;
     6. las 9:45 (suelta la tapa);
     7. abrir la tapa.
3. **La reliquia** (de otro mundo).
   - **Mecánica propia:** luz que se guía. Tres anillos con dos surcos cada uno que la desvían de forma
     distinta. Hay 8 combinaciones y cada una lleva a un glifo diferente. Con el cristal la luz cambia
     de color y hay que rehacer el camino.
   - **Pasos:**
     1. despertar el núcleo;
     2. luz en el primer anillo;
     3. luz en el glifo de abajo;
     4. coger el cristal;
     5. ponerlo en el núcleo;
     6. luz en el glifo de arriba a la derecha;
     7. tocar el núcleo (se despliega y muestra un mapa de estrellas).
4. **El cuarto del farero** (habitación de escape, 1903).
   - **Mecánica propia:** se recorre por puntos de vista, con pistas cruzadas entre muebles.
   - **Pasos:**
     1. el diario;
     2. la placa (1887);
     3. candado de cuatro ruedas;
     4. el cajón;
     5. las cerillas;
     6. el libro entre FRESNEL y STEVENSON;
     7. la llave;
     8. la trampilla;
     9. encender la lámpara del faro.

**Prueba automática [Hecho]:** 64 de 64 comprobaciones correctas. Resuelve los cuatro con las mismas
piezas que usa el jugador y comprueba:
- los bloqueos (el ojo, el cajón antes de la hora);
- las pistas y los iconos del inventario;
- un arrastre real con eventos de toque.

### 2.1 Versión 0.2 y 0.2.1 (03-10-2026)

Lo que pidió el usuario tras probar la 0.1, todo hecho **[Hecho]**:
- un menú vistoso: el **gabinete**, con los cuatro juegos y sus cajas (una jugable y dos selladas);
- cada caja en **su sala**, con una entrada de cámara que llega hasta ella;
- la caja más pequeña en pantalla, con acercar y alejar;
- el **doble toque** que viaja con suavidad, como en The Room;
- letra más grande;
- lo bloqueado **no se mueve**: suena, vibra y destella;
- la parte de atrás del relojero, iluminada.

La 0.2.1 corrige tres fallos de la primera 0.2:
- el marco gigante del primer aviso;
- la puerta del taller, que tapaba la entrada;
- el latón negro y el cristal blanco en el examen.

**Prueba automática:** 95 de 95. **APK:** 49,9 MB (detalles en `LEEME.md`).

Además, con los cuatro vídeos de partidas que envió el usuario se hizo:
- el **análisis de The Room** (`ANALISIS_THE_ROOM.md`);
- la **biblia de diseño** (`BIBLIA_DISENO.md`).

La biblia compara la 0.2.1 con la referencia (anexo A). Su conclusión **[Opinión]**:
- funcionan la respuesta del objeto, la cámara y la identidad de la caja viva;
- falta profundidad: más pasos, más capas y un «¡ajá!» por caja.

**Lo que aún no hay [Hecho]:**
- guardado a mitad de partida;
- música;
- textos en inglés;
- pistas de 4 niveles (DECISIÓN 26);
- prueba en un móvil de verdad (el rendimiento en el teléfono está por medir).

### 2.2 La resistencia creativa (03-10-2026) [Hecho]

El usuario, tras probar la 0.2.1: «La resistencia hay que hacerla creativa». No quería que lo
bloqueado se marcara en rojo ni que se moviera; el sonido sí le gustaba.

- **Lo que cambia:** la pieza bloqueada ya ni se mueve ni se marca; siguen el sonido «trabado» y la
  vibración corta.
- **Quién reacciona:** el objeto entero, cada uno a su manera (`BIBLIA_DISENO.md` §3.4):
  - la caja viva contiene el aliento: humo por la junta, deja de respirar y el ojo mira tu mano;
  - el minutero del relojero se menea como un dedo que dice que no;
  - la luz de la reliquia se retira al núcleo (si duerme, el núcleo late una vez, como en sueños);
  - en el farero responde la tormenta: una racha que agacha la llama del quinqué.
- **Si insistes**, la reacción va a más.
- **Prueba automática:** 116 de 116, con la caja viva profunda.

## 3. Cómo se valida (lo que pide la DECISIÓN 23)

1. **Tú primero:** instala `puzles-0.2.1-prueba.apk` y juega los cuatro sin pistas al principio.
2. **Después, 3 a 5 personas** que no los conozcan, cada una en un orden distinto. Para cada
   prototipo, que digan:
   - el tiempo y las pistas que muestra la pantalla final;
   - **¿cuántas ganas tienes de jugar otra caja como esta?** (de 1 a 5);
   - **¿qué te frustró?** (una frase);
   - **¿pagarías por un juego de tres o cuatro cajas así?** (no, hasta 2 €, hasta 5 €).
3. **Qué significa cada dato:**
   - **Completado sin la tercera pista:** el puzle se entiende. Si casi todos la necesitan en el mismo
     paso, ese paso está mal diseñado.
   - **Tiempo:** si alguien tarda menos de 3 minutos, es demasiado fácil; más de 20 minutos atascado,
     frustra [Supuesto].
   - **Ganas de jugar otra (1-5):** la métrica principal. Es lo más parecido a la retención que se
     puede medir con un prototipo.
   - **Disposición a pagar:** orienta el modelo de negocio. Es una señal débil: la gente dice que
     pagaría más de lo que paga [Opinión].
4. **Las 12 personas de Google Play:** si la cuenta de desarrollador es personal y se creó después
   del 13-11-2023, hay que hacer una prueba cerrada con 12 personas durante 14 días seguidos antes de
   publicar [Hecho; [Google](https://support.google.com/googleplay/android-developer/answer/14151465)].
   Esas 12 personas pueden ser, más adelante, los probadores del juego elegido.

### DECISIÓN 23 — Cuál de los cuatro se convierte en juego · **CERRADA el 03-10-2026: la caja viva**

**Lo que eligió el usuario** (03-10-2026, noche, después de elegir la B): «vamos a concentrarnos en mejorar uno
primero, que va a ser el juego de la caja del ojo, y los demás se pueden hacer en otras entregas en el futuro».
Se eligió antes de la prueba con jugadores, que sigue sirviendo para medir los niveles (§8). Lo que se escribió
antes de elegir sigue aquí abajo como registro.


- **OPCIONES:**
  - la caja viva;
  - el relojero;
  - la reliquia;
  - el farero;
  - una mezcla, por ejemplo una colección de cajas de varios estilos.
- **CÓMO SE ELIGE:**
  - la media más alta de «ganas de jugar otra»;
  - que casi todos terminen sin la tercera pista;
  - si hay empate, la identidad más clara frente a The Room.
- **RECOMENDACIÓN PREVIA [Opinión]:** la **caja viva**.
  - Es la que más se diferencia: el ojo es una mecánica que no tiene The Room.
  - Aprovecha el mundo y el estilo de RONIN.
  - Cada caja puede ser un yōkai distinto: escala a una colección.

  Pero manda la prueba.
- **Lo que añade el análisis [Opinión]** (`BIBLIA_DISENO.md`, anexos A y B):
  - la caja viva es la más propia;
  - el farero, la más débil: es una habitación de escape clásica y comparte tema con el faro de The
    Room Three;
  - el relojero y la reliquia quedan en medio, y cada uno tiene un detalle que cambiar para no
    rozar la referencia: la hora escrita y el mapa de estrellas.
- **SIGUIENTE PASO:** probar el APK y apuntar los datos.

## 4. Del prototipo al lanzamiento (para el elegido)

- **MVP** (ya existe): una caja de 5 a 15 minutos con controles, pistas e inventario.
- **Must Have** (para lanzar):
  - 3 o 4 cajas, más o menos una hora de juego;
  - guardado;
  - español e inglés;
  - música;
  - ajustes de sonido y vibración;
  - una primera caja gratis.
- **Should Have:** la mecánica propia llevada más lejos (por ejemplo, cajas con ojos distintos) y un
  hilo de historia entre cajas.
- **Nice to Have:** logros, más idiomas y versión de Steam.
- **Fases:** prototipo (hecho) → corte vertical (una caja pulida) → alfa (todas las cajas) → beta
  (la prueba cerrada de Google Play) → lanzamiento.
- **Cómo se diseñan las cajas 2-4:** con la plantilla, el generador y la ficha para programar de
  `BIBLIA_DISENO.md` (§8, §5 y §19). La biblia trae un ejemplo completo: la caja viva 2, «Los
  gemelos».
- **Modelo [Hipótesis]:** primera caja gratis y el resto con **un solo pago**, sin anuncios ni monedas.
  Rusty Lake combina juegos gratis y de pago [Hecho]. Lo confirmarán los datos de la prueba.
- **Costes [Hecho]:**
  - Google Play cobra 25 USD una sola vez y un 15 % del primer millón de dólares al año;
  - Steam cobra 100 USD por juego y los devuelve al pasar los 1.000 USD de ventas
    ([fuente](https://partner.steamgames.com/doc/gettingstarted/appfee)).

  El resto es tiempo. Llegar del prototipo a 3-4 cajas lleva 1-3 meses a nuestro ritmo
  **[Estimación; depende sobre todo de lo que tardemos en dar con buenos puzles]**.
- **Cuenta de Google Play [Hecho, según `ronin3d/PLAN_PRODUCCION.md`]:** existe (la de Trazzo) y el
  27-09 estaba pendiente de la verificación de identidad.

## 5. Decisiones abiertas que propone la biblia (03-10-2026)

El detalle de cada una, con el formato DECISIÓN, está al final de `BIBLIA_DISENO.md`.
La 24 se cerró el 03-10-2026 (abajo); la 25 y la 26 siguen abiertas.

- **DECISIÓN 24, cómo se organiza el juego. CERRADA el 03-10-2026: una línea, la de la caja viva.** Las
  otras cajas (el relojero, la reliquia y el farero) quedan para entregas futuras. Es la A, con una diferencia:
  la línea no son cuatro cajas sueltas, sino niveles de la misma caja, cada uno con su caja dentro (§8).
  - Opciones que había: A) una línea de 4 cajas; B) 4 líneas de 2 cajas; C) una línea completa más la caja 1
    de las otras tres como muestras.
  - Se recomendaba la **C**; el usuario prefirió concentrarse en una.
- **DECISIÓN 25, el marco de la historia.**
  - Opciones: A) sin marco; B) un coleccionista desaparecido (se parece a la referencia); C) heredas
    el gabinete de tu abuela (o abuelo).
  - Recomendación: **C**.
- **DECISIÓN 26, las pistas.**
  - Opciones: A) 3 niveles a petición, como ahora; B) 4 niveles más un aviso suave tras 3 minutos
    sin avanzar; C) automáticas.
  - Recomendación: **B**.

## 6. Bocetos antes de construir (03-10-2026)

El usuario vio la caja viva profunda: le gusta la idea, pero no el diseño. Pidió bocetos de todo
antes de seguir, para ver si se puede llegar al esmero de los entornos de The Room. Están en
`bocetos/` (lectura de cada uno, prompts y coste en `bocetos/LEEME.md`).

- **Por línea:** el objeto en su sala y una secuencia de cuatro viñetas que enseña cómo se abre.
- **La caja viva:** además, tres diseños y una hoja con las piezas que se llevan de un sitio a otro.

La mecánica profunda de la caja viva ya funciona: 19 pasos, la cara incompleta, el incensario y el
altar. Pasa su prueba (43 de 43). Se conserva; lo que cambia es el aspecto.

### DECISIÓN 27 — El diseño de la caja viva · **CERRADA el 03-10-2026: la A con los cajones de la C**

El usuario: «empecemos con la A con la C, que deje explorar bastante». También le gustaron la B y la
C: se guardan para otras cajas de la línea **[Propuesta: se decide al diseñar cada una]**.

Lo que se propuso:

- **OPCIONES:**
  - A) mosaico *yosegi* y máscara de paulownia;
  - B) laca negra con oro y un oni;
  - C) cómoda *tansu* de cajones;
  - D) la A con las piezas que se mueven en laca bermellón, como los cajones de la B.
- **VENTAJAS:**
  - A: la más propia y auténtica (las cajas secretas de Hakone); la cara incompleta se entiende sola;
    cumple la biblia (§14.2); casi todo sale por código;
  - B: la más viva y la mejor miniatura para la tienda y los vídeos;
  - C: la que más cosas tiene para explorar;
  - D: la identidad de la A con la señal de «esto se mueve» de la B.
- **RIESGOS:**
  - A: puede parecer demasiado tranquila;
  - B: parece un cofre con cara de oni más que una caja secreta;
  - C: la cara se pierde y cuesta ver que está viva;
  - D: cuidar que el rojo no le quite protagonismo a la cara.
- **COSTE:** parecido en las cuatro. En todas, la pieza difícil es la cara tallada (DECISIÓN 28).
- **RECOMENDACIÓN [Opinión]:** la **D**.
- **SIGUIENTE PASO:** la prueba de calidad de la DECISIÓN 28 con el diseño elegido.

### DECISIÓN 28 — Cómo se fabrican las piezas para llegar a los bocetos · **CERRADA el 03-10-2026: Blender**

El usuario quiere llegar a la calidad de The Room, cree que con Blender se puede y autorizó la
descarga. Se usa **Blender 4.5.14 LTS** (378 MB, SHA-256 comprobada), en el contenedor de Claude y
no en el PC, manejado por código. Las texturas pintadas con IA se suman donde hagan falta. La IA 3D o
un artista, solo si la prueba de calidad dice que lo orgánico no llega, y con su permiso.

Lo que se propuso:

- **OPCIONES:**
  - A) todo por código, como ahora;
  - B) código más texturas pintadas con IA (Gemini) y relieves sacados de ellas;
  - C) además, Blender en la nube (en el contenedor de Claude, no en el PC), también por código;
  - D) además, IA de imagen a 3D para las pocas piezas orgánicas: la cara, el león y el pájaro;
  - E) un artista 3D por encargo.
- **VENTAJAS:**
  - A: gratis y fácil de cambiar;
  - B: el mayor salto por el menor coste (*maki-e*, pinturas, papel pintado, relieves);
  - C: aristas biseladas que atrapan la luz, piezas torneadas y relieves de verdad;
  - D: lo único que da caras y animales creíbles sin un artista;
  - E: la mejor calidad y la más coherente.
- **RIESGOS:**
  - A: su techo ya se vio: lo orgánico sale hecho de bloques;
  - B: de muy cerca, lo pintado se ve plano;
  - C: es una descarga grande (unos 350 MB **[Estimación]**): necesita permiso y comprobar la suma;
  - D: necesita créditos (Higgsfield: 1 por modelo y quedan unos 0,01) y limpiar las mallas;
  - E: es lo más caro; habría que pedir presupuestos.
- **COSTE:**
  - A y C: 0 USD;
  - B: unos 0,045 USD por imagen **[Estimación]**;
  - D: según los créditos, y comprarlos lo decide el usuario;
  - E: según presupuesto.
- **RECOMENDACIÓN [Opinión]:** empezar por la **B** con una prueba de calidad: el frente de la caja
  elegida con su mesa y su incensario, junto al boceto. Si la cara no llega, sumar la C o la D solo
  para las piezas orgánicas.
- **SIGUIENTE PASO:** la prueba de calidad. Con el resultado, se rehace la caja entera y después las
  otras tres.

### Prueba de calidad (03-10-2026) [Hecho]

La caja viva A+C, hecha en Blender por código y vista en el motor del juego, junto a sus bocetos:
`capturas/calidad_frente.jpg`, `calidad_detras.jpg` y `calidad_cara.jpg`.

- **Cómo se hizo:**
  - la caja, con aristas biseladas, paneles de mosaico, cajones con anilla, interiores de laca
    bermellón, herrajes dorados, zócalo con olas, la borla, el incensario con su león y el juego de té;
  - la cara: Gemini dibujó un mapa de alturas de la máscara; `preparar_cara.py` lo convierte en relieve y
    en la textura de paulownia, y Blender lo talla de verdad (sube 1,4 cm y los agujeros se hunden).
- **Lo que ya llega [Opinión]:**
  - el objeto se lee como el boceto;
  - la cara tiene volumen y da inquietud;
  - la madera, la laca y los cajones abiertos dan ganas de tocar.
- **Lo que aún separa de The Room [Opinión]:**
  - la luz de la habitación: dura y sin oclusión ambiental (se puede hornear en Blender);
  - el desgaste y los matices de los materiales;
  - los herrajes, planos, sin grabado;
  - el león, demasiado simple;
  - el peso: 9 MB la caja, que hay que bajar antes del APK.
- **Conclusión [Opinión]:** Blender es la vía correcta. De momento no hace falta IA 3D ni un artista; quizá
  para figuras como el león, más adelante.

**El usuario, al verla (03-10-2026):** «no se parece nada al boceto». Le gustó la imagen del boceto, con
ese toque tétrico y misterioso, y pidió que el juego tenga ese estilo animado y sea interactivo. Lo que
más le falla al jugar es la calidad de imagen y el tipo de animación. Por eso se abre la DECISIÓN 29.

## 7. El juego con el aspecto del boceto (03-10-2026)

**Prueba jugable [Hecho]:** `ilustrada/`, publicada como página privada en
https://claude.ai/artifact/7fC2cECS62soiVNBa2kMG3 (solo la puede abrir el usuario).

- **Qué es:** la ilustración del boceto (la A+C de frente), animada por capas y jugable en el móvil.
- **Lo que se mueve:**
  - el ojo sigue el dedo, parpadea, se entorna y mira la lámpara cuando la llama tiembla;
  - la caja respira;
  - el humo sube en cintas con el borde a tinta, como en la ilustración;
  - la luz de la lámpara tiembla y hay motas de polvo en el aire.
- **El recorrido:**
  1. coger la llave del cajón (no te deja mientras el ojo te mira: hay que distraerlo con la lámpara);
  2. abrir el incensario, cuyo león levanta la tapa y la deja en la mesa;
  3. sacar el cuerno de las brasas y ponerlo en la frente;
  4. el despertar: ojos rojos, humo por las juntas y la trampilla que se abre con luz dorada.
- **La resistencia creativa sigue:** sin marcas ni movimiento; la caja contiene el aliento, echa humo por
  la junta, el ojo mira la mano y, si se insiste, gruñe.
- **Cómo se hizo** (detalle en `ilustrada/LEEME.md`):
  - cuatro retoques de Gemini con el mismo encuadre (incensario abierto y vacío, cajón sin llave, caja
    despierta), unos 0,18 USD **[Estimación]**;
  - `preparar_capas.py` recorta las piezas y los parches de cada estado;
  - la página dibuja todo en un lienzo, a unos 40 cuadros por segundo en el Chromium de pruebas, y pesa
    unos 2 MB con los sonidos.

### Las tres técnicas, jugables (03-10-2026, noche) [Hecho]

El usuario pidió hacer las tres opciones, con movimiento y animación de cámara: «me gustó mucho este tipo
de animación… sería lo distinto a The Room… se puede llenar de detalles». Están en la misma página privada,
con el mismo recorrido; se elige la técnica en la portada y se cambia jugando (botones A, B y C de arriba).

- **Lo común:**
  - la cámara del boceto, calculada a partir de las esquinas de la caja (error de unos 4,5 px);
  - una sala sencilla en 3D: el suelo, dos paredes, la mesa redonda, la peana y los objetos;
  - tres retoques nuevos de Gemini con el mismo encuadre: la caja de espaldas, la mesa sin nada y la sala
    sin mesa. Unos 0,14 USD **[Estimación]**;
  - las «planchas»: la pintura original y, solo detrás de cada objeto, lo que Gemini pintó. Quieta, la
    escena es el boceto exacto; al moverse, detrás de cada cosa hay algo pintado.
- **A · Ilustración por capas:**
  - cada franja de la sala y de la mesa se desplaza según su profundidad al arrastrar el dedo;
  - la caja gira como en un teatro de papel: se estrecha, se da la vuelta y aparece su espalda pintada;
  - pellizcar acerca; 53 cuadros por segundo en el Chromium de pruebas, sin tarjeta gráfica.
- **B · Pintura sobre 3D** (Three.js):
  - la pintura se proyecta desde la cámara del boceto sobre la caja, la mesa y la sala;
  - la caja gira de verdad con el dedo: el frente y el costado derecho salen del boceto de frente, y la
    espalda y el costado izquierdo, del de espaldas;
  - la cámara se acerca a cada vista y da vueltas alrededor con el dedo (hasta unos 20°);
  - el ojo animado, el humo, la luz y la tapa siguen siendo los de la técnica A, anclados en 3D.
- **C · 3D con acuarela** (Three.js):
  - el modelo de Blender de la caja y de lo que hay en la mesa, aligerado de 9 a 2,2 MB;
  - tinta (contorno) y acuarela (bandas de luz, papel, manchas de pigmento y borde oscurecido);
  - el ojo se mueve y parpadea pintado en la cara del modelo;
  - lo mecánico es 3D: la tapa con el león vuela a la mesa, hay brasas, el cuerno se pone y la trampilla
    se abre con luz;
  - la sala sigue pintada. Es la que más deja mover la cámara (hasta unos 55°).
- **Prueba automática:** juega la partida entera con toques de móvil en cada técnica, gira la caja y
  cambia de técnica a mitad. Da 18 de 18 en A y 20 de 20 en B y C, en horizontal y en vertical.

**Lo que se aprendió al hacerlas [Opinión]:**
- **A** es la que más se parece al boceto, porque lo es, pero la caja no gira de verdad: al girar se
  estrecha como un cartón.
- **B** se ve igual que el boceto mientras no se mueve y gira de verdad, que es lo que el usuario pedía:
  - hasta unos 20-30° convence;
  - más allá se estira (los cajones abiertos) y, fuera de lo pintado, la sala se oscurece.
- **C** se mueve libre, pero parece un dibujo animado 3D y no el boceto. Además, cada objeto necesita un
  modelo bueno: el incensario de la prueba de Blender es tosco y se nota.

### DECISIÓN 29 — Cómo se hace el juego con el aspecto de los bocetos · **cerrada: B (03-10-2026)**

- **DECISIÓN:** con qué técnica se construye el juego para que se vea y se mueva como el boceto.
- **OPCIONES:** A) ilustración por capas; B) pintura sobre 3D; C) 3D con acuarela. Las tres se pueden jugar
  en la página privada.
- **VENTAJAS:**
  - A:
    - es el boceto mismo;
    - pesa poco (unos 3 MB con los sonidos);
    - funciona en cualquier móvil, sin 3D.
  - B:
    - el aspecto del boceto con giro real de la caja y cámara que se mueve;
    - más cerca de la sensación de The Room sin perder el estilo.
  - C: cámara libre y puzles mecánicos en 3D.
- **RIESGOS:**
  - A: la caja no gira de verdad. Cada ángulo nuevo es otra ilustración.
  - B:
    - para girar del todo sin estirarse, cada caja pide sus costados pintados, no solo el frente y la espalda;
    - las cosas que sobresalen necesitan su propio volumen (los cajones abiertos ya lo tienen);
    - necesita WebGL, aunque cualquier móvil de los últimos años lo tiene.
  - C:
    - se aleja del boceto, que es justo lo que no gustó;
    - cada objeto necesita un modelo bueno y retocado;
    - es el camino más caro.
- **COSTE:**
  - A: unas 30-50 imágenes por caja, de 1,5 a 2,5 USD **[Estimación]**.
  - B:
    - lo mismo que A más 2-4 vistas pintadas de cada objeto que gira (frente, espalda y costados) y su
      geometría sencilla;
    - el motor ya está hecho (`tecnica_3d.js`).
  - C: modelar y retocar cada objeto. En tiempo, el más caro.
- **RECOMENDACIÓN [Opinión]:** la **B**, con lo mejor de la A dentro.
  - Ya lleva el ojo, el humo y la luz de la A, y da el movimiento de cámara y el giro que se pidieron.
  - La A se queda como reserva para móviles sin 3D.
  - La C solo si se prefiere explorar libremente aunque se pierda el aspecto del boceto.
  - Cambia la recomendación anterior (la A), porque ahora se ha visto la B funcionando.
- **ELEGIDA: la B.** El usuario la jugó en el móvil y mandó dos capturas de la B con el costado de los cajones
  marcado: «Solo [hay que] mejorar estos detalles porque del otro lado lo hace bien, vamos con [que] todo el
  juego sea de esa manera». Lo marcado era lo que se estiraba al girar la caja; ya está arreglado (abajo).
  - La página entra directa en la B. La A queda solo de respaldo para móviles sin WebGL.
  - La C se retira: su código sigue en `ilustrada/pagina/tecnica_3d.js` como referencia, sin mantener, y sus
    modelos no se publican.
- **SIGUIENTE PASO:**
  1. subir la resolución del frente a 2K;
  2. llevar los 19 pasos de la caja viva a la B;
  3. el APK: **hecho el 03-10-2026**. El usuario pidió «pasarlo a APK con la misma calidad que el enlace»: la
     página va empaquetada tal cual en un WebView, sin conexión, con una clave de prueba propia
     (`ilustrada/apk/LEEME.md`).

### Cajones, inventario y decoración viva en la B (03-10-2026, noche) [Hecho]

El usuario pidió: «Los cajones que están al lado sería bueno que se mantengan cerrados, que se puedan abrir,
que tengan su animación de abrirse, que todo tenga su animación, el apartado del inventario crea uno mejor,
también sería bueno que algunos objetos se muevan aunque sean decoraciones que se relacionen con el ambiente
o el toque». Después eligió la B y marcó el costado que se estiraba.

- **Los costados nítidos al girar:**
  - los dos costados y la tapa se aplanaron desde los bocetos y Gemini los repintó de frente, sin mover nada
    (comprobado: desplazamiento 0, 0);
  - la B mezcla esa pintura con la proyección según el ángulo: desde la cámara del boceto se ve el boceto
    exacto; al girar la caja o mover la cámara, la pintura de frente, nítida;
  - coste: tres retoques más el de los cajones cerrados, unos 0,18 USD **[Estimación]**.
- **Los cajones:** los nueve del costado empiezan cerrados (un retoque de Gemini del boceto con ellos
  cerrados).
  - Se abren deslizándose, con un rebote; tienen hueco oscuro, sombra y paredes de laca roja.
  - Al tocar uno, la cámara se acerca al costado.
  - Dos tienen cerradura y resisten sin moverse, como todo lo bloqueado.
  - La llave está en el de abajo y la nota en el de al lado; los demás guardan pistas de ambiente (ceniza,
    hilos de seda, un papel quemado). Al despertar, todos traquetean.
- **El inventario:**
  - una bandeja lacada con cuatro huecos y esquinas de latón, con un brillo al llegar cada objeto;
  - su nombre al tocarlo; tocarlo otra vez, o mantenerlo pulsado, lo examina en grande;
  - la nota se guarda para releerla;
  - en horizontal va a la izquierda, para no tapar la tetera, las tazas ni los cajones.
- **La decoración viva:**
  - el viento sopla a ráfagas (o al tocar el shoji): mece las sombras del bambú en el papel, el rollo colgado,
    la llama y el humo;
  - tres polillas rondan la lámpara y se posan en el papel; la llama, el viento o el dedo las espantan;
  - la tapa de la tetera tiembla con el vapor;
  - el té hace ondas cuando algo golpea la mesa (la caja, un cajón que se cierra, el despertar);
  - el dedo aparta el polvo y el humo.
- **Arreglos de paso:** la tetera y las tazas ya no arrastran un rectángulo de mesa al mover la cámara (se
  recortan con su forma) y llevan su sombra de contacto.
- **Prueba automática:** 23 de 23 en la B y en la A, en horizontal y en vertical.

## 8. Los niveles de la caja viva (03-10-2026, noche)

**Qué pidió el usuario:** «empieza a hacer los niveles… crea varios niveles buenos y complejos como en The Room
1, 2 y 3, que toman muchas ideas: puntos de vista diferentes, cambio de una caja grande a pequeña, cambio total
de la caja, el tipo de vistas, diferentes secciones, un puzle más grande en donde tienes que pasar niveles para
entrar al nivel final».

**El plan** está en `ilustrada/NIVELES.md`:
- La idea en una frase: **la caja no te deja tocar mientras te mira; devuélvele la cara (el cuerno, el ojo y la
  voz) y te abrirá su corazón.**
- Cuatro niveles: 1 · El cuerno, 2 · La caja de dentro, 3 · La caja del revés y el final, El corazón.
- La cara es el puzle grande: cada nivel le devuelve una pieza y el final solo se abre con las tres.

**Hecho [en la página privada]:**
- **El paso de nivel:**
  - al terminar cada nivel sale una tarjeta con la cara como marcador: tres sellos (角 cuerno, 目 ojo y 声 voz)
    que se estampan en bermellón según se recuperan;
  - la partida se guarda al terminar cada nivel (en el navegador) y la portada ofrece seguir en el siguiente.
- **Nivel 1 · El cuerno:** el recorrido de siempre, que ahora termina en su tarjeta.
- **Nivel 2 · La caja de dentro** (solo en la B):
  1. la caja se calma y su trampilla sigue dando luz;
  2. tirando de ella hacia arriba, sube de dentro una caja pequeña (yosegi, con un párpado tallado), flota y baja a
     la mesa;
  3. la cámara se acerca: la caja pequeña delante y el ojo grande encima, vigilándola;
  4. arrastrar la gira en la mano; al soltarla se asienta con una cara hacia cada lado;
  5. sus cinco tablillas corren en orden, deslizándolas con el dedo, y la flecha de marquetería que destapa cada
     una dice cuál sigue;
  6. **la regla, ampliada:** la cara que ve el ojo grande no se mueve, y la lámpara ya no lo distrae; hay que
     girar la caja pequeña para esconderle cada tablilla (la de arriba, de entrada, la está mirando);
  7. la quinta es la tapa de atrás; detrás, un cajoncito con una cajita de laca roja;
  8. la cajita es un puzle de bolsillo: su tapa gira a saltos y se suelta cuando su marca dorada toca la del
     borde; dentro hay un ojo de piedra de luna, que aparta la vista de tu dedo;
  9. el ojo va a la cuenca vacía: la caja cierra el ojo viejo y abre los dos; el nuevo es claro y mira hacia
     otro lado.
- **Pistas del nivel 2:** de vagas a claras, una escalera por paso.
- **Prueba automática:** `prueba/jugar_nivel2.mjs` juega el nivel 2 con toques y arrastres de verdad, y
  `prueba/jugar.mjs` sigue jugando el nivel 1.

**El APK (03-10-2026) [Hecho]:** `caja-viva-0.1-prueba.apk` (5,3 MB), la misma página en una app de Android sin
conexión: paquete `com.thunderdarkness.cajaviva`, Android 7 o más. Detalle en `ilustrada/apk/LEEME.md`.

**Gestos y horizontal (03-10-2026, noche) [Hecho, APK 0.2]:** el usuario probó la 0.1 y pidió: «el juego tiene que
ser horizontal cuando entre […] permite que pellizque para acercar o alejar […] cuando se acerque se mantenga para
que pueda interactuar, que quede fijo en esa parte […] que jale el cajón, no solo tocar».
- El juego es horizontal (la app siempre; la página pide girar el móvil). Los encuadres de cerca se ajustaron.
- De cerca, la cámara se queda quieta; se vuelve con «Sala», atrás o pellizcando.
- Pellizcar acerca o aleja alrededor de los dedos; alejarse del todo vuelve a la vista de antes.
- Las acciones son gestos: los cajones se tiran y se empujan (con muelle, rebote y golpe), la llave se gira en
  círculo, la tapa se levanta hacia arriba, la caja pequeña se saca tirando de la trampilla, las tablillas se
  deslizan y el cajoncito se tira. Un toque solo avisa y hace asomar la pieza.
- Detalle en `ilustrada/LEEME.md` («Gestos y horizontal»). Es la `caja-viva-0.2-prueba.apk`.

**Siguiente:**
- Nivel 3 · La caja del revés y el nivel final, en las próximas entregas (diseño en `NIVELES.md` §6 y §7).
- Medir los niveles con jugadores, como dice el §3: el tiempo, las pistas y las ganas de seguir.

