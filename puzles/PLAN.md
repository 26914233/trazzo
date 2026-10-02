# Cuatro cajas: plan

Juego de puzles tipo The Room. Hoy son **cuatro prototipos** para elegir, con datos de jugadores, cuál
se convierte en el primer juego que se lanza. Índice y comandos en `LEEME.md`.

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

**Lo que aún no hay [Hecho]:**
- guardado a mitad de partida;
- música;
- textos en inglés;
- prueba en un móvil de verdad (el rendimiento en el teléfono está por medir).

## 3. Cómo se valida (lo que pide la DECISIÓN 23)

1. **Tú primero:** instala `puzles-0.1-prueba.apk` y juega los cuatro sin pistas al principio.
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
