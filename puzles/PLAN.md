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

### DECISIÓN 23 — Cuál de los cuatro se convierte en juego · **pendiente de la prueba**

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
**Ninguna está tomada.**

- **DECISIÓN 24, cómo se organiza el juego.**
  - Opciones: A) una línea de 4 cajas; B) 4 líneas de 2 cajas; C) una línea completa más la caja 1
    de las otras tres como muestras.
  - Recomendación: **C**.
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

### DECISIÓN 27 — El diseño de la caja viva · **abierta**

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

### DECISIÓN 28 — Cómo se fabrican las piezas para llegar a los bocetos · **abierta**

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
