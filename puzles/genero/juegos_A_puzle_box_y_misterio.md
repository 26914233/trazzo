# Bloque A · Puzzle box, escape room y misterio: 15 juegos desmontados

*Investigación para La caja viva · 04-10-2026 · contexto común en `00_contexto_para_investigar.md`*

## Cómo leer este documento

- **Qué hay.** Una ficha «DESMONTAR» por juego (Riven y su remake de 2024 comparten ficha) y, al final,
  **«Lo mejor del bloque»**: las 12 mecánicas o principios más útiles para La caja viva. La base de datos de
  mecánicas está en `juegos_A_mecanicas.csv` (86 filas, de A-001 a A-086).
- **Marcas.** **[Hecho, n]** = lo dice la fuente n de la lista que cierra esa ficha. **[Opinión, n]** = lo dice
  un crítico, un diseñador opinando o los jugadores (fuente n). **[Interpretación]** = conclusión nuestra. Las
  propuestas para La caja viva son siempre [Interpretación]: **nada de esto está aprobado**; son material para
  proponer al usuario con el formato DECISIÓN.
- **Citas.** Cortas y en su idioma original, con traducción entre corchetes. La entrevista a Lucas Pope está en
  japonés: se resume con nuestras palabras, sin comillas.
- **Puzles.** Cada «mejor puzle» se desmonta en ocho campos: información que recibe el jugador · qué debe
  descubrir · qué variable manipula · reglas · qué lo hace difícil · qué lo hace satisfactorio · feedback ·
  recompensa. Los campos que describen el puzle son [Hecho] de las fuentes que lleva su título; «lo difícil» y
  «lo satisfactorio» son [Interpretación] salvo que se cite a alguien.
- **Límites.** Las charlas de la GDC (Myst, Gorogoa, Outer Wilds, Keep Talking) están en vídeo o tras
  suscripción: se usan sus resúmenes oficiales y entrevistas, no su contenido completo. Varias guías y reseñas
  bloquean la lectura automática; cuando un dato sale solo de una guía, se dice. Lo que no se pudo confirmar se
  marca como «sin confirmar».
- **Originalidad.** Cada ficha acaba con su riesgo de parecido. Lo prohibido hoy (lente u ocular, portales,
  sustancia irisada, miniaturas y «entrar en lo pequeño», rituales de varillas o máquinas de puertas) aparece en
  varios de estos juegos: se estudia, pero nunca se propone tal cual.

**Índice:** 1 Myst · 2 Riven (1997 y 2024) · 3 The House of Da Vinci · 4 The House of Da Vinci 2 · 5 The House
of Da Vinci 3 · 6 Machinika Museum · 7 Boxes: Lost Fragments · 8 Escape Simulator · 9 Blue Prince · 10 Tunic ·
11 Return of the Obra Dinn · 12 Outer Wilds · 13 Gorogoa · 14 Keep Talking and Nobody Explodes · 15 The Witness ·
Lo mejor del bloque · Descartes y avisos.

---

## 1. Myst (1993)

**Género y año.** Aventura de exploración y puzles en primera persona. Cyan (Rand y Robyn Miller), publicada
por Broderbund el 24-09-1993 para Mac; Windows en 1994 [Hecho, 1]. Se hizo con HyperCard y unas 2.500 imágenes
prerrenderizadas [Hecho, 1]. Fue el juego de PC más vendido hasta 2002 (más de 6,3 millones de copias hasta
2000) [Hecho, 1]. En 2021 salió un remake en 3D con aleatorización opcional de los puzles [Hecho, 6].

**Core loop (el ciclo que se repite)** [Interpretación]: recorrer un lugar → encontrar una nota o una máquina
que no se entiende → relacionarla con algo visto en otra parte → accionar → se abre el viaje a otra «Era» (otro
mundo) → volver con una página que completa la historia.

**Interacción (verbos)** [Hecho, 1]: hacer clic para pasar de una vista fija a otra (con fundido), pulsar,
girar, tirar de palancas, leer, coger una sola página cada vez. No hay enemigos, ni muerte, ni límite de tiempo.

**Mecánicas** [Hecho, 1 y 3]:
- Inventario de una página: solo se lleva una; si se suelta, vuelve a su sitio.
- Datos repartidos por la isla (notas, vistas, diarios) que se usan lejos de donde se encuentran.
- Máquinas de la isla: una torre que gira sobre un mapa, un reloj, un generador, un planetario y un barquito en
  una fuente.
- El sonido como dato (Era Selenítica).
- Varios finales, según a qué personaje creas.

**Los mejores puzles**

1. **Los interruptores marcadores** [3].
   - Información: una nota pide meter en un panel el número de interruptores marcadores de la isla.
   - Descubrir: cuántos hay. Están repartidos por todo el mapa.
   - Variable: un número.
   - Reglas: solo el número exacto muestra el mensaje.
   - Lo difícil: casi nada. Es el tutorial disfrazado.
   - Lo satisfactorio: para contarlos hay que recorrer la isla entera; al acabar, el jugador ya conoce el mapa
     sin que nadie se lo haya explicado.
   - Feedback: se reproduce un mensaje grabado.
   - Recompensa: el primer tramo de la historia y un mapa mental de la isla.

2. **El generador de 59 voltios** [3].
   - Información: hace falta una tensión exacta (59 voltios) para dar energía a la nave.
   - Descubrir: qué combinación de botones suma justo eso.
   - Variable: los botones encendidos (cada uno suma una cantidad).
   - Reglas: si te pasas, salta un fusible y hay que ir a rearmarlo.
   - Lo difícil: el castigo por pasarse convierte una suma en un plan.
   - Lo satisfactorio: la aguja que sube y se para justo en la cifra.
   - Feedback: la aguja del voltímetro; el fusible que salta.
   - Recompensa: el acceso a la nave que lleva a la Era Selenítica.

3. **El sonido como mapa (Era Selenítica)** [4, 2].
   - Información: cinco micrófonos junto a cinco fuentes de sonido (agua que gotea, una grieta de fuego, un
     reloj, cristales y un túnel de viento) [4].
   - Descubrir: hacia dónde orientar cada antena de una torre; luego, el orden de los cinco sonidos; por último,
     en un vagón que recorre un laberinto, qué sonido indica cada dirección.
   - Variable: la orientación de las antenas; unos deslizadores que ordenan sonidos; el giro en cada cruce.
   - Reglas: la flecha de la antena parpadea cuando estás cerca y el sonido se oye más limpio cuando apuntas bien
     [4]. Un botón Σ reproduce los cinco sonidos en el orden que abre una puerta [4]. En el laberinto, cada parada
     emite el sonido de la dirección buena; las mezclas indican diagonales y el silencio, un callejón [4].
   - Lo difícil: distinguir sonidos parecidos. [Opinión, 2] Según Rand Miller, a muchos jugadores les parece el
     peor puzle porque las pistas sonoras eran demasiado sutiles.
   - Lo satisfactorio: [Opinión, 2] Miller lo defiende: «The maze is actually laid out along with the sounds, so
     that it elegantly reveals itself» [el laberinto está trazado con los sonidos y se revela solo].
   - Feedback: «más caliente, más frío» (la flecha que parpadea, el sonido que se aclara); el vagón avanza.
   - Recompensa: la página de la Era y el libro de vuelta.

4. **Fechas, estrellas y un barquito** [3].
   - Información: tres fechas; un planetario; un libro de constelaciones; botones junto a una fuente con un barco
     de juguete.
   - Descubrir: qué constelación sale con cada fecha y qué botón le corresponde.
   - Variable: las fechas del planetario; los botones de la fuente.
   - Reglas: la combinación correcta hace subir los barcos (según la guía, el de juguete y el hundido de verdad,
     que guarda el libro de la Era Stoneship).
   - Lo difícil: traducir entre tres sitios distintos.
   - Lo satisfactorio: lo pequeño (el barquito) responde a lo grande: una maqueta que manda.
   - Feedback: cambia la cúpula estrellada; los barcos suben.
   - Recompensa: la Era Stoneship.

**Cámara** [Hecho, 1]: vistas fijas en primera persona con fundidos; una opción («Zip») salta a lugares ya
vistos.

**Feedback, animación y sonido** [Interpretación]: con imágenes fijas, el sonido hace casi todo el feedback
(máquinas que zumban, agua, viento). Por eso Myst puede usar el sonido como información y como «más caliente, más
frío». [Opinión, 1] GameSpot lo resumió como «an immersive experience that draws you in».

**Narrativa** [Hecho, 1]: dos hermanos encerrados en un libro rojo y uno azul; cada página que les llevas aclara
su mensaje; hay varios finales. [Interpretación] La historia es la recompensa de los puzles: más páginas, más
mensaje.

**Dificultad y aprendizaje.** [Hecho, 5] Robyn Miller explicó en la GDC de 2013 que lo hicieron para gente que
no juega: «most people don't like puzzles». [Hecho, 1] Los puzles se pensaron para resolverse observando y con
sentido común, no por ensayo y error. [Opinión, 2] El criterio de Rand Miller: si al ver la solución el jugador
se culpa a sí mismo y no a los diseñadores, el puzle está bien hecho. [Interpretación] El primer puzle (contar
interruptores) es un recorrido guiado sin texto.

**Lo que valoran** [Opinión]: «quite simply, the best Macintosh CD-ROM game», según Computer Gaming World [1]. En
el remake de 2021, los jugadores de Steam valoran la aleatorización para rejugar [7, resumen automático de
reseñas].

**Lo que critican** [Opinión]: Next Generation lo llamó «gaming's bleakest hour» por sus gráficos fijos y su
ensayo y error [1]; otras revistas criticaron puzles oscuros [1]. En 2021: puzles que piden ensayo y error o
ayuda externa, y un cuaderno de notas incómodo de consultar [7].

**Para La caja viva** [Interpretación]:
- **Un primer puzle que es un recorrido (C).** En un nivel nuevo, contar algo repartido por los cuatro costados
  (polillas de laca, clavos de bronce) obliga a girar la caja entera y da la cifra de un candado. El ojo no deja
  tocar, pero sí mirar: contar es la tarea perfecta mientras te vigila.
- **«Más caliente, más frío» (A).** Cuando el jugador acerca una pieza a su posición buena, la caja responde un
  poco (la respiración se calma, el humo se endereza) antes del acierto completo, como la antena de la Era
  Selenítica.
- **El sonido como dato, con vibración (E).** La caja respira por rendijas con sonidos distintos; repetir su
  orden abre algo. Con vibración del móvil para quien juega sin sonido.
- **Datos aleatorios (A).** Como el remake de 2021: el mismo razonamiento, cifras distintas en cada partida (ver
  «Lo mejor del bloque», 8).

**Riesgo de parecido.** Libros de enlace = portales: **alto, no usar**. La «maqueta que manda» (el barquito):
**medio-alto** por la regla de no usar miniaturas; ver la versión con sombras en «Lo mejor del bloque», 12.
Contar objetos, sumar sin pasarse y sonidos en orden: **bajo** (son del género).

**Fuentes de la ficha:** 1. [Wikipedia: Myst](https://en.wikipedia.org/wiki/Myst) · 2. [AV Club: Rand Miller
sobre su puzle favorito](https://avclub.com/Myst-creator-rand-miller-on-his-favorite-puzzle-that-ev-1798251819) ·
3. [Myst Journey: guía de Myst](https://mystjourney.com/myst/walkthrough/) · 4. [Thonky: guía de la Era
Selenítica](https://www.thonky.com/myst-walkthrough/selenitic-age) · 5. [Game Developer: postmortem de Myst en
la GDC 2013](https://www.gamedeveloper.com/design/video-the-i-myst-i-classic-postmortem-from-gdc-2013) · 6.
[Road to VR: remake con aleatorización
opcional](https://www.roadtovr.com/myst-remake-vr-oculus-quest-release-date-facebook-2020-trailer/) · 7.
[VaporLens: resumen automático de reseñas de Steam de Myst (2021)](https://vaporlens.app/app/1255560/myst.md)

---

## 2. Riven (1997) y su remake (2024)

**Género y año.** Aventura de exploración y puzles en primera persona, secuela de Myst. Cyan, 1997; codirigida por
Robyn Miller y Richard Vander Wende, con Rand Miller de productor; el juego de ordenador más vendido de 1997 (1,5
millones en un año) [Hecho, 1]. El remake de 2024 es 3D en tiempo real (Unreal Engine 5), con realidad virtual y
personajes en CGI en lugar de actores filmados; algunos puzles tienen soluciones aleatorias y otros se rehicieron
para que sean más fáciles para quien llega nuevo; nota media de 86 en Metacritic [Hecho, 1]. Trae puzles,
lugares y lore nuevos [Hecho, 2].

**Core loop** [Interpretación]: explorar cinco islas → entender cómo funcionan las máquinas de Gehn (el
villano) y la cultura de los rivenses → traducir símbolos y números → usar ese saber en dos grandes puzles. [Hecho,
3] Riven tiene dos puzles principales repartidos por las cinco islas, en vez de barreras en fila.

**Interacción (verbos)** [Hecho, 1]: clic para moverse entre vistas (1997) o caminar libre (2024); arrastrar
palancas e interruptores; el cursor cambia según la acción posible (girar, arrastrar, coger).

**Mecánicas** [Hecho, 1, 3, 5, 6, 7]:
- Un sistema de números que se aprende con un juguete (los números D'ni van en base 25 [9]).
- Colores y símbolos propios de cada isla, aprendidos en un sitio y usados en otro.
- Ojos de madera que suenan como animales, junto a formas naturales que, vistas desde un ángulo, parecen esos
  animales.
- Cúpulas que giran y se detienen pulsando en el momento justo: hay que parar cuando el símbolo de la isla (una
  raya horizontal en Survey Island) pasa por donde debería estar el estroboscopio [7].
- Una rejilla que es un plano de la isla.
- Transportes y salas giratorias (una sala de cinco puertas) [5].

**Los mejores puzles**

1. **El juguete de la escuela** [4, 6].
   - Información: en la escuela del pueblo hay un juguete de madera. [Hecho, 6] Al girar un anillo aparece un
     símbolo en la base y un muñequito situado sobre la boca de un pez enorme baja unas muescas.
   - Descubrir: que los símbolos son números y cuánto vale cada uno, del 1 al 10 [4].
   - Variable: ninguna; es una lección.
   - Reglas: cada símbolo hace bajar al muñequito tantas muescas como vale.
   - Lo difícil: darse cuenta de que es un sistema, apuntarlo y extenderlo (la base 25); se usa mucho más tarde.
   - Lo satisfactorio: el juguete es lección y pista narrativa a la vez. [Opinión, 6] El autor del Let's Play lo
     relaciona con la horca del lago, donde se baja a los presos hasta los monstruos del agua. Enseña un número y
     una crueldad.
   - Feedback: el muñequito baja; ruido de madera.
   - Recompensa: poder leer las cifras de Gehn, que el final exige.

2. **Los ojos de madera** [8, 5].
   - Información: ojos de madera repartidos por la isla; al girarlos enseñan un símbolo y emiten el sonido de un
     animal (un zumbido de escarabajo, la llamada de una ballena con colmillos) [8]. Cerca, una forma natural
     parece ese animal: el agua de un caño dibuja un escarabajo; unas rocas, la ballena [8].
   - Descubrir: que cada ojo es a la vez un animal y un número, y en qué orden van.
   - Variable: el orden de cinco piedras de un mecanismo.
   - Reglas: en el original, la combinación es pez, escarabajo, rana, *sunner* y *wahrk* [5].
   - Lo difícil: hay que unir tres canales (sonido, forma vista desde un ángulo y número) entre lugares lejanos.
   - Lo satisfactorio: descubrir que el paisaje era una pista desde el principio.
   - Feedback: el sonido del animal al girar el ojo.
   - Recompensa: la combinación de piedras que deja avanzar. [Hecho, 5] En el remake esta parte cambia y da
     pistas más crípticas (tótems y símbolos).

3. **La rejilla de las canicas** [5, 7, 10].
   - Información: en la sala de mapas, la forma de cada isla; en la sala espía de Gehn, un botón por isla que
     enciende una luz de color propio («These colors will be relevant later», avisa la guía) [7]; cinco canicas
     de colores.
   - Descubrir: dónde está la cúpula de cada isla y qué color le toca.
   - Variable: la casilla de cada canica en una rejilla de 5 × 5.
   - Reglas: la rejilla es un plano; cada canica va donde está su cúpula en el mapa [5].
   - Lo difícil: pasar de un mapa en relieve a una cuadrícula abstracta y cruzarlo con colores vistos en otra
     isla.
   - Lo satisfactorio: el instante de entender que la rejilla «es» la isla.
   - Feedback: la máquina se pone en marcha.
   - Recompensa: un paso grande hacia el final.
   - Crítica de diseño [Opinión, 10]: Andrew Plotkin (diseñador de aventuras) analiza cómo se cargan las
     canicas, en las dos versiones: pulsas, hay luces y un ruido, y la canica viaja sola por tubos que no se ven.
     El jugador no ve el efecto («you didn't see the marble leave town») y no entiende qué ha hecho. Defiende que
     resolver un puzle debe dar mejor perspectiva sobre la historia y que el jugador debe sentir cómo funciona la
     máquina.

**Cámara** [Hecho, 1]: en 1997, vistas fijas prerrenderizadas; en 2024, movimiento libre.

**Feedback, animación y sonido.** [Hecho, 2] Hannah Gamiel (Cyan), medio en broma: «Our games should have been
called Follow the Pipes 1 and Follow the Pipes 2» [nuestros juegos deberían llamarse «Sigue las tuberías 1 y 2»].
[Interpretación] Las tuberías y los cables a la vista son el feedback de Cyan: se ve qué conecta con qué. Donde
no se ve (las canicas), falla. [Opinión, 11] El remake destaca por su sonido posicional y su ambiente.

**Narrativa** [Hecho, 3]: los puzles salen del gobierno de Gehn; muchas máquinas son aparatos con los que
mantiene su poder. [Interpretación] Cada puzle explica una relación de poder: el juguete enseña a contar y a
temer.

**Dificultad y aprendizaje.** [Hecho, 11] El remake no tiene pistas: si fallas, nada te dice dónde te
equivocaste. [Opinión, 3] Al rejugarlo, sorprende cuántas pistas había por todas partes. [Hecho, 11] El remake
acorta algunos trayectos (ya no hay que cambiar la ruta del submarino una y otra vez) y añade un segundo sistema
de numeración.

**Lo que valoran** [Opinión]: arte y coherencia («Art [...] is what Riven approaches», Salon) [1]; en el remake,
puzles en capas que obligan a conectar islas [11].

**Lo que critican** [Opinión]: demasiado parecido a Myst (Computer Gaming World) y anticuado frente a los juegos
3D (Edge) [1]; puzles demasiado difíciles [1]. Del remake: personajes con efecto de «valle inquietante» y una
herramienta de capturas torpe [11].

**Para La caja viva** [Interpretación]:
- **Un juguete que enseña el sistema (G).** Un *okiagari-koboshi* (el tentempié japonés que siempre se levanta)
  que se balancea tantas veces como marca una muesca tallada enseña las «marcas» de la caja, que luego abren la
  espalda. Como en Riven, el juguete puede insinuar algo inquietante del pasado de la caja, sin gore.
- **El color de cada parte, aprendido en un sitio (C).** Cada costado tiene su color de laca; un objeto de la
  sala (los hilos de un amuleto *omamori*) enseña el orden de colores que pide el cajón largo.
- **Seguir las tuberías (A).** Todo efecto lejano debe verse viajar: una cuerda en una ranura, una veta de laca
  que se ilumina, una línea de humo («Lo mejor del bloque», 2).
- **La rejilla es un plano (C).** El tablero de shōgi de la sala como plano de la caja: poner fichas en las
  casillas de los cajones abiertos enciende el hueco trasero.

**Riesgo de parecido.** Ojos de madera que giran y suenan: **medio-alto** para nosotros, porque nuestro ojo es
único y vivo; no usar «ojos-ficha». Rejilla-plano y juguete que enseña números: **bajo** si no copiamos el pez,
la horca ni los números D'ni. Libros de enlace: **alto (portal), no usar**.

**Fuentes de la ficha:** 1. [Wikipedia: Riven](https://en.wikipedia.org/wiki/Riven) · 2. [Game Informer:
rehacer Riven](https://gameinformer.com/feature/2024/04/01/riven-feature-remaking-a-masterpiece) · 3. [Hardcore
Gaming 101: Riven](https://www.hardcoregaming101.net/riven/) · 4. [Riumplus: Riven
Elementary](https://www.riumplus.com/riven-elementary/) · 5. [Myst Journey: pistas de
Riven](https://mystjourney.com/riven/hints/) · 6. [Let's Play Archive: Riven, parte
7](https://lparchive.org/Riven/Update%2007) · 7. [Into Indie Games: guía de Survey Island
(2024)](https://intoindiegames.com/walkthroughs/riven-2024-walkthrough-survey-island/) · 8. [Let's Play Archive:
Riven, parte 6](https://lparchive.org/Riven/Update%2006) · 9. [Let's Play Archive: Riven, parte
15](https://lparchive.org/Riven/Update%2015) · 10. [Andrew Plotkin: «One Riven puzzle
considered»](https://blog.zarfhome.com/2024/07/one-riven-puzzle-considered) · 11. [Adventure Game Hotspot:
reseña del remake](https://adventuregamehotspot.com/review/2301/riven-remake)

---
## 3. The House of Da Vinci (2017)

**Género y año.** Puzzle box y escape room en primera persona, al estilo de The Room. Blue Brain Games (estudio
indie eslovaco), 2017; Android, iOS, Windows y macOS [Hecho, 1]. Eres el aprendiz de Leonardo y buscas a tu
maestro desaparecido en su casa de Florencia [Hecho, 1]. Cada capítulo es una habitación: hay que resolver todo
en una para pasar a la siguiente; al acabar, se pueden revisitar y ver los planos de los inventos en un patio
[Hecho, 3].

**Core loop** [Interpretación]: entrar en una sala → acercarse a cada mueble → encontrar piezas y pistas →
combinarlas en el inventario → abrir mecanismos (a veces mirando con una lente mágica) → se abre la sala
siguiente.

**Interacción (verbos)** [Hecho, 3]: doble clic para acercarse; arrastrar para girar la vista; arrastrar objetos
desde una cinta de inventario a la izquierda; examinar; combinar los objetos marcados con «+»; deslizar en el
borde derecho para activar las lentes. [Opinión, 4] En móvil los controles responden bien, pero son demasiado
sensibles cuando hay mucho zoom.

**Mecánicas** [Hecho, 2, 3, 6]:
- Dos lentes en un guante: *Oculi Infinitum* (ver dentro de un mecanismo «como rayos X» y mover lo oculto;
  descubrir códigos o qué ladrillo pulsar) y *Oculi Tempus* (ver escenas del pasado, tras completar un dibujo).
- Inventario con objetos que se montan y se transforman en otros.
- Luz y prismas; discos giratorios; un mapa de conquista; un armario de varias fases.

**Los mejores puzles**

1. **El haz de luz de la biblioteca** [6].
   - Información: la lente descubre una fuente de luz escondida en la base de una lámpara; hay prismas que giran.
   - Descubrir: el recorrido del haz por la sala.
   - Variable: el ángulo de cada prisma, en un orden.
   - Reglas: el haz rebota en los prismas; solo un recorrido llega a la estantería.
   - Lo difícil: pensar en la sala entera, no en un objeto.
   - Lo satisfactorio: ver el haz cruzar la sala; la consecuencia ocurre lejos.
   - Feedback: el haz visible; la estantería iluminada.
   - Recompensa: el objeto que guarda la estantería.

2. **El armario de los sólidos** [6].
   - Información: un armario alto con huecos de formas; sólidos repartidos (tetraedro, cubo, esfera, dodecaedro,
     octaedro).
   - Descubrir: qué sólido va en cada hueco; después, los puzles de discos que aparecen debajo.
   - Variable: la forma; el giro de los discos.
   - Reglas: cada forma entra solo en su hueco y abre un compartimento.
   - Lo difícil: poco en las formas; el reto está en los discos.
   - Lo satisfactorio: el mueble se abre por capas, como una caja dentro de otra.
   - Feedback: un compartimento nuevo que se abre.
   - Recompensa: el compartimento siguiente.

3. **El dibujo del pasado (*Oculi Tempus*)** [6, 2].
   - Información: una escena del pasado; deslizadores de una línea temporal; discos con trozos de un dibujo (el
     Hombre de Vitruvio).
   - Descubrir: cómo es el dibujo completo.
   - Variable: el giro de los discos.
   - Reglas: alinear los discos recompone el dibujo.
   - Lo difícil: [Opinión, 2] el dibujo previo para activar la lente resulta «finicky and boring» [quisquilloso
     y aburrido] y no queda claro cuándo usarla.
   - Lo satisfactorio: ver el pasado da sentido al mecanismo.
   - Feedback: el dibujo se completa.
   - Recompensa: el paso siguiente.

**Cámara** [Hecho, 3]: primera persona con puntos de zoom; la vista se gira arrastrando.

**Feedback, animación y sonido** [Opinión, 3]: «Animations can be short, or cinematically and impressively much
longer»; el sonido acompaña sin agobiar.

**Narrativa.** [Hecho, 1] Cartas de Leonardo y de sus enemigos. [Opinión, 2] Escritas con letra ornamentada
difícil de leer; es «highly likely that you'll grow bored».

**Dificultad y aprendizaje.** [Hecho, 2, 3, 5] Pistas por fases (de vagas a concretas) que se recargan con el
tiempo; si te atascas, suena una campanilla y aparece una pista arriba a la izquierda, sin penalización.
[Opinión, 5] La dificultad sube «exponencialmente» a partir de la tercera sala.

**Lo que valoran** [Opinión]: «a well-made, detailed, and complex puzzler» [4]; la historia real integrada (los
inventos de Leonardo) [5].

**Lo que critican** [Opinión]: que es «essentially The Room in a different package» [4]; interacciones
imprecisas («tetchy») [2]; interfaz «fiddly» [3]; textos difíciles de leer [2].

**Para La caja viva** [Interpretación]:
- **La capa oculta la revela la caja, no una lente (D).** Ya está decidido en `ilustrada/NIVELES.md` §9: en el
  nivel 3, la mirada de la caja alumbra tinta invisible. Este juego confirma por qué: la lente es la expresión
  central del género y aquí se repite tal cual.
- **El armario por capas, con piezas de juegos (B).** La espalda de la caja pide piezas de juegos japoneses en
  huecos con su forma (la ficha de shōgi ya está sembrada; podrían seguir una piedra de go y un dado); cada una
  abre un cajoncito con un puzle pequeño.
- **Recuerdos en el humo, no visiones con lente (G).** Al recuperar una parte de su cara, la caja «recuerda»: el
  humo del incensario dibuja el gesto que hacía el artesano y el jugador lo repite.
- **Aprender de sus críticas (A).** Zonas táctiles generosas, nada de letra ornamentada en los textos útiles y
  ningún control hipersensible con zoom.

**Riesgo de parecido.** Las lentes (*Oculi*): **alto, prohibido**. Ver el pasado: **medio** (solo como memoria de
la caja, sin aparato). Armario de formas y prismas: **bajo** (son del género).

**Fuentes de la ficha:** 1. [Wikipedia: The House of Da Vinci](https://en.wikipedia.org/wiki/The_House_of_Da_Vinci)
· 2. [TheXboxHub: reseña](https://www.thexboxhub.com/the-house-of-da-vinci-review/) · 3. [GameBoomers:
reseña](https://gameboomers.com/reviews/Hh/HouseofDaVinci/HouseofDaVinci.htm) · 4. [Pocket Gamer:
reseña](https://www.pocketgamer.com/articles/074520/the-house-of-da-vinci-review-a-mystery-worth-being-solved/) ·
5. [The Escape Roomer: reseña](https://theescaperoomer.com/2021/02/26/the-house-of-da-vinci/) · 6. [Walkthrough
King: guía](https://walkthroughking.com/text/houseofdavinci.aspx)

---

## 4. The House of Da Vinci 2 (2019-2020)

**Género y año.** El mismo género y estudio. iOS en 2019; Android y Steam en 2020 [Hecho, 1]. Escape room en
primera persona por lugares del Renacimiento, con mecanismos de relojería, palancas y poleas [Hecho, 2].

**Core loop** [Interpretación]: el de la primera entrega, con un giro: cada sala existe en dos tiempos y la
solución puede estar «en el otro».

**Interacción (verbos).** [Hecho, 2] Buscar lo que se puede «pressed, slid, opened, or pulled» [pulsar,
deslizar, abrir o tirar], examinar y combinar. [Hecho, 3] El *Oculus Perpetua* abre un portal morado y,
manteniendo el dedo encima, te lleva al pasado. [Opinión, 2] La pantalla táctil es la forma más intuitiva de
jugarlo.

**Mecánicas** [Hecho, 2]: «Some areas must be affected in the past before you can progress in the present» [hay
zonas que hay que cambiar en el pasado para avanzar en el presente]; otros puzles piden usar el aparato para ver
cómo funcionan por dentro.

**Los mejores puzles**

1. **La cúpula de dibujos** [4].
   - Información: una cúpula de secciones con trozos de un dibujo; en el centro, un aparato esférico.
   - Descubrir: la posición de cada sección.
   - Variable: el giro de cada sección.
   - Reglas: cuando el dibujo encaja, se puede coger el aparato.
   - Lo difícil: poco; es el tutorial del objeto clave.
   - Lo satisfactorio: el objeto que vas a usar todo el juego se gana con un gesto.
   - Feedback: encaje y apertura.
   - Recompensa: el *Oculus Perpetua*.

2. **La palanca del puente y las gárgolas** [4].
   - Información: en el presente, unas gárgolas echan agua; en el pasado, una palanca del puente se puede mover.
   - Descubrir: que la causa está en el otro tiempo.
   - Variable: la posición de la palanca en el pasado.
   - Reglas: lo que cambias en el pasado sigue cambiado en el presente.
   - Lo difícil: acordarse de que existe el otro tiempo. [Opinión, 3] La reseñista admite que a veces olvidaba
     usar el aparato.
   - Lo satisfactorio: volver y ver la consecuencia.
   - Feedback: las gárgolas dejan de echar agua.
   - Recompensa: el paso queda libre.

**Cámara** [Interpretación]: la de la serie (primera persona con puntos de zoom).

**Feedback, animación y sonido** [Hecho, 3]: el salto al pasado es un remolino rosa y morado.

**Narrativa** [Opinión, 2]: un argumento «enjoyably ludicrous» [disparatado y disfrutable].

**Dificultad y aprendizaje.** [Hecho, 3] Pistas que van de vagas a útiles, con un tiempo de espera entre una y
otra. [Opinión, 3] Los textos se leen mejor que en la primera entrega.

**Lo que valoran** [Opinión, 2]: «some fabulously complex mechanisms» y el sentido histórico.

**Lo que critican** [Opinión, 2]: las piezas de girar ruedas son incómodas; el ratón es torpe; el precio en PC
frente al móvil.

**Para La caja viva** [Interpretación]:
- **Dos estados del mismo lugar (B).** Sin viajar en el tiempo: lámpara encendida o apagada, caja dormida o
  despierta. Lo que mueves en un estado queda movido en el otro, y cada estado deja ver o tocar cosas distintas
  («Lo mejor del bloque», 7).
- **Que el juego recuerde el modo especial (A).** Como los jugadores olvidan el «otro estado», la propia caja lo
  sugiere (la lámpara parpadea cuando lo que buscas solo se ve a oscuras).
- **El objeto clave se gana con un gesto (A).** Como la cúpula: la primera pieza importante de un nivel llega
  con un gesto pequeño y claro.

**Riesgo de parecido.** Portal y viaje temporal: **alto, prohibido**. Dos estados de la criatura o de la luz:
**bajo**. Ruedas que alinean un dibujo: **bajo**.

**Fuentes de la ficha:** 1. [Wikipedia: The House of Da Vinci (secuelas)](https://en.wikipedia.org/wiki/The_House_of_Da_Vinci)
· 2. [TheSixthAxis: reseña](https://www.thesixthaxis.com/2020/06/11/house-of-da-vinci-2-review-pc-ios/) · 3.
[Ladies Gamers: reseña de Switch](https://ladiesgamers.com/the-house-of-da-vinci-2-review-switch/) · 4. [AppUnwrapper:
guía del capítulo 1](https://www.appunwrapper.com/2019/12/04/the-house-of-da-vinci-2-walkthrough-guide/) (texto
visto en el buscador; la página bloquea la lectura automática)

---

## 5. The House of Da Vinci 3 (2022)

**Género y año.** El mismo género y estudio. Móviles en 2022 [Hecho, 1]; PC el 22-12-2022 [Hecho, 2].
Protagonista: Giacomo [Hecho, 4]. Personajes con voz y escenas cinemáticas [Hecho, 2]. En Steam, 89 % de reseñas
positivas de 1.310 (consulta del 04-10-2026) [Hecho, 2].

**Core loop** [Interpretación]: el de la serie; el aparato abre portales a otras épocas y lugares, y lo que
cambias en el pasado cambia el presente.

**Interacción (verbos)** [Hecho, 3, 4]: el cursor cambia sobre lo que se puede tocar; el *Oculus Perpetua* deja
ver el interior de cerraduras y mecanismos y viajar entre el año 966 y 1508.

**Mecánicas** [Hecho, 2, 3]: cambiar el pasado para cambiar el presente; ver dentro de los mecanismos; reparar y
montar herramientas.

**Los mejores puzles**

1. **El pozo y las ratas** [3].
   - Información: en el presente, una plaga de ratas cierra un paso; en el pasado, hay un pozo abierto.
   - Descubrir: que las ratas salen del pozo.
   - Variable: sellar o no el pozo en el pasado.
   - Reglas: la causa en el pasado decide el presente.
   - Lo difícil: relacionar dos épocas separadas por siglos.
   - Lo satisfactorio: una causa pequeña con un efecto grande y lógico.
   - Feedback: el presente aparece cambiado.
   - Recompensa: el paso despejado.

2. **Reconstruir el aparato** [3].
   - Información: piezas rotas del *Oculus Perpetua*.
   - Descubrir: cómo encajan.
   - Variable: la posición de las piezas.
   - Reglas: montaje por formas.
   - Lo difícil: poco; es el tutorial.
   - Lo satisfactorio: arreglar tu herramienta crea apego por ella.
   - Feedback: el aparato funciona.
   - Recompensa: la herramienta de todo el juego.

3. **El carril doblado y la ganzúa de engranajes** [3].
   - Información: un carril torcido y un banco con segmentos giratorios; cerraduras con engranajes que se ven
     por dentro con el aparato.
   - Descubrir: cómo enderezar el carril y cómo alinear las ranuras.
   - Variable: el giro de segmentos y engranajes.
   - Reglas: los segmentos corrigen la curva; las ranuras alineadas abren.
   - Lo difícil: la precisión.
   - Lo satisfactorio: arreglar algo con las manos.
   - Feedback: el carril queda recto; la cerradura cede.
   - Recompensa: avanzar.

**Cámara** [Hecho, 2]: primera persona.

**Feedback, animación y sonido.** [Hecho, 4] El cursor cambia sobre lo interactivo. [Opinión, 5] Se valoran la
música y el sonido, sutiles.

**Narrativa.** [Hecho, 2] Personajes con voz y cinemáticas. [Opinión, 5] Muchos jugadores critican escenas largas
que no se pueden saltar.

**Dificultad y aprendizaje.** [Hecho, 3] Las notas de Giacomo sirven de pista. [Opinión, 5] Se valora el sistema
de pistas por fases.

**Lo que valoran** [Opinión, 5]: puzles mecánicos ingeniosos, la historia, el arte y las pistas.

**Lo que critican** [Opinión, 5]: peor que las entregas anteriores; escenas que no se saltan; zonas de toque
inconsistentes y *pixel hunting* (buscar a ciegas el punto exacto que se puede tocar); fallos técnicos; ritmo
repetitivo.

**Para La caja viva** [Interpretación]:
- **La caja recuerda, no viaja (D).** Al recuperar el ojo, la sala «recuerda» cómo estaba (el incensario con tres
  varillas en un orden); devolverla a ese orden abre algo. Causa en el pasado, sin portal.
- **Reparar la primera herramienta (B).** El primer contacto con la sala puede ser recomponer la lámpara *andon*
  (papel, vela, marco): enseña gestos y crea apego antes de tocar la caja.
- **Lo que no hay que repetir (A).** Escenas cortas y que se puedan saltar; zonas táctiles generosas; nada de
  buscar píxeles.

**Riesgo de parecido.** Portales: **alto, prohibido**. «Otra perspectiva» con un aparato (una lente): **alto**.
Reparar herramientas: **bajo**.

**Fuentes de la ficha:** 1. [Wikipedia: The House of Da Vinci (secuelas)](https://en.wikipedia.org/wiki/The_House_of_Da_Vinci)
· 2. [Steam: The House of Da Vinci 3](https://store.steampowered.com/app/1603640/The_House_of_Da_Vinci_3/) · 3.
[LevelWinner: guía](https://www.levelwinner.com/?p=78223) · 4. [TapTap: reseña de
jugador](https://www.taptap.io/es/post/3898872) · 5. [VaporLens: resumen automático de reseñas de
Steam](https://vaporlens.app/app/1603640/the_house_of_da_vinci_3)

---

## 6. Machinika Museum (2021)

**Género y año.** Puzzle box de ciencia ficción. Littlefield Studio; editado por Dear Villagers [Hecho, 1] (en
otras fichas figura Plug In Digital [Hecho, 2]). PC el 23-03-2021 [Hecho, 1]; iOS y Android el 20-04-2021 [Hecho,
2]. De 2 a 4 horas; 91 % de reseñas positivas en Steam de 1.184 [Hecho, 1]. Sus autores citan Myst y The Room
como inspiración [Hecho, 2]. Eres técnico de un museo del futuro y estudias y reparas artefactos alienígenas
[Hecho, 2].

**Core loop** [Interpretación]: llega un artefacto → girarlo y estudiar cada cara → encontrar interruptores
ocultos → usar las herramientas (impresora, endoscopio, destornillador) → hacerlo funcionar → una pieza de la
historia.

**Interacción (verbos)** [Hecho, 3, 4]: girar el artefacto, tocar, deslizar, cortar una cinta con tijeras,
teclear códigos, meter baterías y piezas, usar herramientas.

**Mecánicas** [Hecho, 3, 6]:
- Impresora 3D que duplica cualquier pieza encontrada.
- Endoscopio: una cámara que se mete por grietas para ver el interior.
- Destornillador que cambia de forma para encajar en cada tornillo.
- Símbolos que se traducen de una cara a otra.

**Los mejores puzles**

1. **El tutorial de la impresora** [4].
   - Información: un sobre con una carta que trae un número de serie (1078); unas tijeras; una impresora apagada.
   - Descubrir: que la carta trae el código y que la máquina necesita batería y tinta.
   - Variable: el código y las piezas.
   - Reglas: una secuencia de puesta en marcha (cortar la cinta, teclear, batería, cartucho).
   - Lo difícil: nada; enseña gestos con un objeto corriente.
   - Lo satisfactorio: se siente manual y creíble.
   - Feedback: la impresora se enciende.
   - Recompensa: la herramienta que se usará todo el juego.

2. **La llave doble** (capítulo 2) [3].
   - Información: dos cerraduras y una sola llave rara.
   - Descubrir: que hace falta otra igual y que la impresora puede copiarla.
   - Variable: cuántas llaves hay.
   - Reglas: las dos cerraduras deben girar a la vez.
   - Lo difícil: pensar en la herramienta como solución.
   - Lo satisfactorio: el «ajá» de usar la impresora para algo que no parecía suyo.
   - Feedback: el cierre cede.
   - Recompensa: la cara siguiente del artefacto.

3. **El teclado visto por dentro** (capítulo 3) [3].
   - Información: un teclado roto; el endoscopio.
   - Descubrir: qué teclas tienen por dentro símbolos rojos.
   - Variable: las teclas pulsadas.
   - Reglas: repetir fuera el patrón que se ve dentro.
   - Lo difícil: relacionar dentro y fuera.
   - Lo satisfactorio: encontrar información escondida en las tripas de la máquina.
   - Feedback: el teclado acepta.
   - Recompensa: el mecanismo siguiente.

4. **Los tres anillos** (capítulo 5) [3]: los símbolos vistos en los costados y detrás de una gema roja se ponen
   en tres anillos giratorios (un semicírculo, un círculo abierto y un círculo con una raya). Información cruzada
   dentro de un mismo objeto.

**Cámara** [Interpretación]: centrada en el objeto, que se gira; vistas propias para cada herramienta.

**Feedback, animación y sonido** [Opinión, 5]: «neat little touches that are pretty delightful» [detalles
pequeños que encantan].

**Narrativa** [Hecho, 5]: poco a poco se descubre «the truth about what is going on» a través de los artefactos,
con un giro alienígena.

**Dificultad y aprendizaje.** [Opinión, 5] Los puzles «aren't always the most challenging». [Hecho, 4] El primer
capítulo enseña los gestos con la impresora.

**Lo que valoran** [Opinión]: cajas «cleverly-designed» [5]; la mezcla de gráficos realistas, puzles táctiles y
herramientas nuevas [6].

**Lo que critican** [Opinión, 5]: controles «finicky»; algunas soluciones «a bit out there» [rebuscadas]; corto;
fallos de lanzamiento (ya corregidos).

**Para La caja viva** [Interpretación]:
- **La caja copia lo que mira (H).** Versión viva de la impresora: si el ojo mira el cuerno un rato, en la frente
  crece un cuerno gemelo de laca; dos cuernos para dos cerraduras. La regla del ojo se vuelve herramienta.
- **Escuchar dentro en vez de mirar dentro (D).** Al girar la caja pequeña, una bolita rueda dentro; por el
  sonido (y la vibración) se sabe qué tablilla está libre. Evita la cámara que se mete dentro.
- **Enseñar gestos con un objeto corriente (A).** La tetera y la lámpara enseñan tirar, girar y levantar antes de
  tocar la caja.

**Riesgo de parecido.** Endoscopio (ver dentro, entrar en lo pequeño): **medio-alto**. Destornillador ajustable,
parecido a la llave configurable de The Room (biblia, 19.7): **medio**. Copiar piezas con una máquina: **bajo** si
lo hace la caja con su mirada.

**Fuentes de la ficha:** 1. [Steam: Machinika Museum](https://store.steampowered.com/app/1507190/Machinika_Museum/)
· 2. [iPhoneSoft: presentación](https://iphonesoft.fr/2021/03/24/machinika-museum-littlefield-studio-futur-the-room-mobile)
· 3. [Walkthrough King: guía](https://www.walkthroughking.com/text/machinikamuseum.aspx) · 4. [AppUnwrapper:
guía](https://www.appunwrapper.com/2021/03/26/machinika-museum-walkthrough-guide/) (texto visto en el buscador; la
página bloquea la lectura automática) · 5. [TouchArcade: reseña](https://toucharcade.com/?p=279904) · 6.
[AppUnwrapper: reseña](https://www.appunwrapper.com/2021/04/19/machinika-museum-ios-review/) (texto visto en el
buscador)

---

## 7. Boxes: Lost Fragments (2024)

**Género y año.** Puzzle box en primera persona. Big Loop Studios; editado por Snapbreak; en Steam desde el
01-02-2024; 91 % de reseñas positivas de 1.757 [Hecho, 1]. Un ladrón entra en una mansión llena de cajas-puzle; lo
que empieza como un robo rápido se vuelve una lucha por salir [Hecho, 1]. Cinco capítulos de cuatro cajas (20) y
puzles de la mansión entre medias [Hecho, 2]. Unos 30 meses de desarrollo; la progresión en torre (subir de
planta) se añadió en los últimos tres meses, y el final original se cambió por las opiniones de los jugadores
[Hecho, 3].

**Core loop** [Interpretación]: entrar en una sala → una caja sobre la mesa → girarla y probarlo todo → una
cadena de interruptores abre capas → sale un fragmento o una llave → otra caja → la mansión sube un piso.

**Interacción (verbos)** [Hecho, 4, 5]: arrastrar palancas, girar engranajes con el movimiento, levantar
pestillos, girar diales y llaves; no hay indicadores de qué se puede tocar. [Opinión, 6] En tableta, el control
táctil es fluido e intuitivo.

**Mecánicas** [Hecho, 2, 4, 5, 7]: cadenas de dependencias («one switch activates another section of the box,
which in turn leads to another» [7]); bloques que se deslizan; luz; emparejar símbolos; reflejos; plataformas en
2,5D; una variante de «luz roja, luz verde»; un proyector que se monta con fragmentos; una maqueta de castillo; un
carro diminuto en un templo griego.

**Los mejores puzles**

1. **Luz roja, luz verde** [5, 2].
   - Información: una luz que cambia de color; una figura de piedra en un carril.
   - Descubrir: que solo se puede mover con verde.
   - Variable: cuándo mueves la figura.
   - Reglas: deslizarla por el carril mientras la luz está verde [5]. [Hecho, 2] Otra reseña lo describe como
     una variante del juego infantil «Grandma's Footsteps».
   - Lo difícil: la paciencia y el ritmo.
   - Lo satisfactorio: la tensión de avanzar a escondidas.
   - Feedback: el color de la luz.
   - Recompensa: la figura llega y algo se abre.
   - [Interpretación] Es el precedente más cercano del género a nuestra regla («no deja tocar mientras te ve»).
     Ellos la usan en un puzle; nosotros, en todo el juego y con un ser vivo.

2. **La primera caja** [8, 7].
   - Información: una caja con un deslizador verde en un costado.
   - Descubrir: la cadena: el deslizador abre un compartimento con dos diales; girarlos destapa otro deslizador;
     la caja se despliega y muestra otro panel; dentro hay una llave para un candado del otro lado [8, según una
     guía].
   - Variable: deslizadores y diales.
   - Reglas: cada paso habilita el siguiente.
   - Lo difícil: encontrar lo oculto. [Opinión, 7] A veces hay que tocar «just about everywhere», incluso por
     debajo.
   - Lo satisfactorio: la caja crece y cambia de forma.
   - Feedback: [Opinión, 4] «Each lock that audibly disengages, every switch that snicks into place, every gear
     that begins to whir» [cada cierre que suena al soltarse, cada interruptor que encaja, cada engranaje que
     empieza a zumbar].
   - Recompensa: la llave y, al final, el fragmento.

3. **El carro del templo griego** [4, 5].
   - Información: una caja de tema griego.
   - Descubrir: cómo poner en marcha el recorrido.
   - Variable: el disparo de una ballesta diminuta.
   - Reglas: [Hecho, 4] «the camera guides you into a tiny horse-drawn chariot and circles a Greek temple»; desde
     allí se dispara al minotauro [5].
   - Lo difícil: poco; es un premio de espectáculo.
   - Lo satisfactorio: el cambio de escala.
   - Feedback: la animación.
   - Recompensa: avanzar en la caja.
   - [Interpretación] Es «entrar en lo pequeño»: un ejemplo de lo que no haremos.

**Cámara** [Hecho, 4]: primera persona alrededor de la caja; a veces entra en una escena diminuta.

**Feedback, animación y sonido.** [Opinión, 2] Efectos «phenomenally satisfying». [Opinión, 4] Poca música, para
que se oigan los mecanismos. [Hecho, 3] Los autores querían que el sonido creara atmósfera e inmersión junto a
animaciones y efectos pulidos.

**Narrativa.** [Opinión, 4] Muy poca. [Hecho, 5] Fragmentos de la historia de Aurora, un ser artificial que se
pregunta quién es.

**Dificultad y aprendizaje.** [Hecho, 3] «Striking the right balance between difficulty and flow was one of our
primary goals»: buscaban algo «enjoyably puzzling», no «brain-meltingly hard». [Hecho, 5, 7] Una máscara señala el
próximo puzle u objeto, sin penalización, y se puede saltar un puzle.

**Lo que valoran** [Opinión]: diseños de cajas muy creativos [4]; el tacto: «you have to actually flip latches,
rotate dials, and turn keys» [5]; nunca se hace repetitivo [5].

**Lo que critican** [Opinión]: demasiado parecido a The Room [7, 2]; algunos puzles se resuelven en un suspiro
[4]; no se puede reiniciar un puzle suelto, solo el nivel, y un puzle puede quedar sin solución [5]; a veces no
se distingue qué es interactivo [6]; deslizamientos que «aciertan o fallan» [6]; final abrupto [2].

**Para La caja viva** [Interpretación]:
- **Nuestra regla, en su versión infantil y japonesa (A/G).** *Daruma-san ga koronda* («el daruma se ha caído»)
  es el «luz roja, luz verde» japonés: quien la liga canta la frase de espaldas y, al girarse, quien se mueve
  pierde [Hecho, 9]. La caja puede «cantar» su frase con el ojo cerrado: mientras dura, se puede tocar («Lo mejor
  del bloque», 1).
- **Nunca sin solución (A).** Cada mecanismo vuelve a su estado inicial con un gesto propio (empujar el cajón
  hasta el fondo), y la prueba automática comprueba que nada quede bloqueado.
- **Un sonido para cada pieza (B).** Lo más elogiado del juego: cada cierre, muelle o diente con su sonido y una
  vibración corta.

**Riesgo de parecido.** «Luz roja, luz verde»: **medio-bajo** (es un juego infantil; su expresión es una figura
en un carril con un semáforo; la nuestra, una caja que canta y mira). Entrar en el templo diminuto: **alto,
prohibido**. Cajas por capas: **bajo** (género).

**Fuentes de la ficha:** 1. [Steam: Boxes: Lost Fragments](https://store.steampowered.com/app/2019810/Boxes_Lost_Fragments/)
· 2. [JumpDashRoll: reseña](https://jumpdashroll.com/article/boxes-lost-fragments-review) · 3. [Xbox Wire:
cómo se hizo](https://news.xbox.com/en-us/2025/11/06/an-inside-scoop-of-boxes-lost-fragments-development/) · 4.
[Adventure Game Hotspot: reseña](https://adventuregamehotspot.com/review/1315/boxes-lost-fragments) · 5.
[Gameluster: reseña](https://gameluster.com/boxes-lost-fragments-review-the-best-kind-of-unboxing/) · 6. [Room
Escape Artist: reseña coral](https://roomescapeartist.com/2024/11/18/boxes-lost-fragments-hivemind-review/) · 7.
[GameSpew: reseña](https://www.gamespew.com/2024/02/boxes-lost-fragments-review/) · 8. [Pro Game Guides:
guía](https://progameguides.com/boxes-lost-fragments/boxes-lost-fragments-walkthrough/) (texto visto en el
buscador; la página bloquea la lectura automática) · 9. [Wikipedia: Statues
(game)](https://en.wikipedia.org/wiki/Statues_(game))

---
## 8. Escape Simulator (2021)

**Género y año.** Simulador de salas de escape en primera persona, en solitario o en cooperativo en línea. Pine
Studio, 19-10-2021 [Hecho, 1]. Trae 28 salas en packs temáticos (Egipto, espacio, mansión, oficina…) y miles de
salas de la comunidad hechas con su editor; sus puzles los diseñaron operadores de salas de escape reales [Hecho,
1].

**Core loop** [Interpretación]: entrar en una sala → registrarlo todo → coger, girar, abrir y combinar →
descifrar candados y códigos → salir; en cooperativo, repartirse el trabajo.

**Interacción (verbos)** [Hecho, 1]: coger y examinar cualquier objeto, mover muebles, romper jarrones y
candados, combinar.

**Mecánicas** [Hecho, 1, 2, 4]: física para casi todo (la pregunta de partida fue «What if everything can be
picked up?» [¿y si todo se pudiera coger?] [2]); inventario; combinaciones; haces de luz; matemáticas; pesos;
cifrados; editor de salas.

**Los mejores puzles**

1. **La balanza** (*Chamber of Dead*, Egipto) [4].
   - Información: esferas de colores de peso desconocido; bolas negras numeradas; una balanza; diales sobre
     jeroglíficos.
   - Descubrir: cuánto pesa cada esfera.
   - Variable: qué se pone en cada plato.
   - Reglas: la balanza compara; los diales piden los pesos.
   - Lo difícil: planear las comparaciones.
   - Lo satisfactorio: una deducción física que se nota en la mano.
   - Feedback: la balanza se inclina.
   - Recompensa: el aparato se abre y suelta piezas.

2. **Las vasijas orientadas** (*The Library*, mansión Edgewood) [4].
   - Información: cuatro vasijas celestes alrededor de la chimenea; la posición de unos planetas en un puzle
     anterior.
   - Descubrir: hacia qué punto cardinal debe mirar cada vasija.
   - Variable: la orientación de cada vasija.
   - Reglas: copiar la disposición de los planetas.
   - Lo difícil: relacionar dos puzles distintos.
   - Lo satisfactorio: lo resuelto antes vuelve a servir.
   - Feedback: un encaje.
   - Recompensa: el paso siguiente.

3. **El laboratorio** (*The Lab*, espacio) [4]: combinar elementos químicos en orden (hidróxido de sodio con
   aluminio; luego el resultado con nitrógeno y helio) en un fabricador para crear los objetos necesarios. Una
   receta como puzle.

**Cámara** [Interpretación]: primera persona libre; los objetos se examinan en la mano.

**Feedback, animación y sonido** [Interpretación]: la física es el feedback: los objetos caen, ruedan y suenan;
no hace falta avisar de qué se puede tocar, porque casi todo se puede.

**Narrativa** [Interpretación]: temática (cada pack es un mundo), casi sin historia.

**Dificultad y aprendizaje.** [Hecho, 3] Cada pack tiene cinco salas de dificultad creciente. [Opinión, 3] Una
reseña echaba de menos pistas: es «very easy to get stuck». [Hecho, 5] Otra reseña describe un botón de ayuda que
da una pequeña pista sobre en qué fijarse. [Hecho, 3] El inventario distingue los objetos útiles; el resto se
puede tirar.

**Lo que valoran** [Opinión]: el cooperativo, «the chaos and excitement when you and your friends come at the same
puzzles with wildly different ideas» [5]; puzles conectados entre sí [5]; el editor de salas [3].

**Lo que critican** [Opinión]: salas pequeñas y un inventario pesado de gestionar [5]; quedarse atascado sin
ayuda [3].

**Para La caja viva** [Interpretación]:
- **Premiar la curiosidad sin multiplicar lo útil (B).** Unos pocos objetos de la sala reaccionan a todo (la
  tetera, el rollo, las polillas) aunque no sean del puzle. Ya hay «decoración viva»; la regla sería: todo lo que
  parece tocable responde algo, aunque sea poco.
- **Reparar en vez de romper (D).** Aquí se rompen jarrones; una caja viva no se rompe: una pieza agrietada se
  repara con *kintsugi* (laca con oro en las grietas) y entonces suelta lo que guarda. Encaja con el respeto al
  objeto que tiene alma.
- **La bandeja del té como balanza (B).** Una deducción por peso: comparar el ojo de piedra de luna con monedas
  *mon* antiguas da una cifra.
- **Más adelante, un taller (F).** Fuera del MVP: un «taller del artesano» para montar cajas con piezas conocidas
  y compartirlas, como el editor de salas.

**Riesgo de parecido.** **Bajo**: son mecánicas genéricas de las salas de escape.

**Fuentes de la ficha:** 1. [Steam: Escape Simulator](https://store.steampowered.com/app/1435790/Escape_Simulator/)
· 2. [The Escape Roomer: entrevista a Tomislav (Pine Studio)](https://theescaperoomer.com/pine-studio-tomislav-interview/)
· 3. [The Escape Roomer: reseña](https://theescaperoomer.com/escape-simulator-review/) · 4. [Walkthrough King:
guía](https://walkthroughking.com/text/escapesimulator.aspx) · 5. [KeenGamer:
reseña](https://www.keengamer.com/articles/reviews/pc-reviews/escape-simulator-review-theres-no-escape-from-the-fun-pc/)

---

## 9. Blue Prince (2025)

**Género y año.** Puzles y misterio con estructura *roguelite* (cada partida empieza de cero, pero algo se
conserva). Dogubomb, es decir, Tonda Ros en solitario, con unos ocho años de trabajo; 2025 [Hecho, 1]. Metacritic
92 en PC; premios D.I.C.E. a juego independiente y a diseño [Hecho, 1].

**Core loop** [Hecho, 1]: cada día empiezas en el vestíbulo de una mansión de 9 × 5 casillas; al abrir una puerta
eliges uno de tres planos de habitación al azar; tienes 50 pasos, llaves, gemas y monedas; el objetivo es llegar
a la habitación 46. Si no llegas, la casa se reordena al día siguiente, pero conservas lo aprendido y algunas
mejoras.

**Interacción (verbos)** [Hecho, 1, 2]: elegir planos, abrir puertas, leer, coger y usar objetos, accionar palancas,
abrir cajas fuertes. [Opinión, 2] Tomar notas (fuera del juego) es casi obligatorio.

**Mecánicas** [Hecho, 1, 2, 3, 4]:
- Elegir habitaciones (*drafting*: escoger una carta entre varias) y gestionar recursos.
- El saber como progreso: lo aprendido sirve aunque la casa cambie.
- Puzles de una habitación y puzles que cruzan muchas.
- Notas que dicen verdad y notas que mienten.
- Palancas repartidas que abren puertas; alguna no se reinicia de un día a otro.

**Los mejores puzles**

1. **El juego del salón** (*Parlor*) [3].
   - Información: tres cajas (azul, blanca y negra) con frases escritas; una llave de cuerda de un solo uso; tres
     reglas fijas: al menos una caja dice solo verdades, al menos una dice solo mentiras y solo una tiene premio.
   - Descubrir: qué caja tiene las gemas.
   - Variable: la caja que abres (un solo intento).
   - Reglas: las tres de arriba.
   - Lo difícil: es lógica pura y crece: con los días aparecen cajas sin frase, frases que hablan de sí mismas y
     hasta tres frases por caja.
   - Lo satisfactorio: [Hecho, 3] se resuelve solo deduciendo, sin ensayo y error: la certeza antes de abrir.
   - Feedback: la caja se abre, con gemas o vacía.
   - Recompensa: gemas (un recurso); a las 40 resueltas, un trofeo.

2. **Las tres palancas de la antecámara** [4].
   - Información: la antecámara, meta del día, tiene tres puertas selladas; hay notas sobre ella repartidas por
     la casa.
   - Descubrir: dónde están las tres palancas: en el jardín secreto (alineando una veleta hacia el oeste; esa no
     se reinicia al día siguiente), en el invernadero (hay que reparar su base con una palanca rota; solo vale
     ese día) y en el gran salón (tras unas puertas laterales cerradas).
   - Variable: qué palancas se activan y en qué día.
   - Reglas: cada palanca abre su puerta.
   - Lo difícil: reunir piezas repartidas por una casa que cambia y recordar cuál persiste.
   - Lo satisfactorio: [Hecho, 4] al tirar de una palanca, una escena breve enseña cómo se abre su puerta: ves la
     consecuencia lejana.
   - Feedback: la escena de la puerta.
   - Recompensa: el camino a la habitación 46.

3. **Las notas que mienten** [4].
   - Información: notas de colores repartidas por la casa.
   - Descubrir: que las rojas mienten (una nota roja afirma, en falso, que la antecámara ya está abierta).
   - Variable: a qué notas creer.
   - Reglas: el color decide si la nota dice verdad.
   - Lo difícil: desconfiar de un texto del propio juego.
   - Lo satisfactorio: releer todo con la regla nueva.
   - Feedback: ninguno inmediato: la casa no cambia; cambia tu lectura.
   - Recompensa: dejar de perder días en pistas falsas.

**Cámara** [Interpretación]: primera persona dentro de la casa, más una vista de plano al elegir habitaciones.

**Feedback, animación y sonido** [Hecho, 4]: escenas cortas que enseñan consecuencias lejanas (las puertas de la
antecámara).

**Narrativa.** [Hecho, 1] Una herencia: la mansión será tuya si llegas a la habitación 46. [Opinión, 5] Ros: «This
is ultimately a game about people making assumptions» [es un juego sobre gente que da cosas por supuestas], y que
descubre con el tiempo que se equivocaba.

**Dificultad y aprendizaje.** [Hecho, 6] Ros vio más de 2.000 horas de partidas grabadas de probadores: dónde se
paraban, por dónde iban solos y dónde sufrían. [Hecho, 5] No hay callejones sin salida: si te atascas, empiezas
otro día. [Opinión, 2] Tomar notas es vital, porque los puzles grandes citan detalles de varias habitaciones.

**Lo que valoran** [Opinión, 1]: «the pleasure of finding hidden aspects to things you thought you understood in
full» [el placer de descubrir lados ocultos de lo que creías entender del todo]; [Opinión, 2] te hace sentir
listo.

**Lo que critican** [Opinión, 2]: el azar frustra cuando falta justo la herramienta o la habitación necesaria.

**Para La caja viva** [Interpretación]:
- **La caja miente con un tic (H).** Un tsukumogami es un objeto travieso. Que mienta con una regla aprendible
  convierte la lectura en deducción y le da carácter: cuando señala un cajón falso, el humo se riza; cuando dice
  verdad, sube recto. Primero se enseña el tic con un caso seguro; luego se usa para elegir («Lo mejor del
  bloque», 11).
- **Sellos que se quedan y enseñan su efecto (B).** Cada sello que vuelve a la cara (cuerno, ojo, voz) muestra en
  una escena corta qué anillo de El corazón ha soltado, y no se pierde nunca.
- **Saber es avanzar (A).** Lo aprendido en un nivel (las marcas, las reglas del ojo) abre atajos en los
  siguientes. Y la prueba con jugadores se graba y se mira, como hizo Ros.

**Riesgo de parecido.** El formato del salón (tres cajas con frases escritas y reglas fijas): **alto si se
copia**; sin texto, con el tic de la caja: **bajo**. La lupa que revela pistas escondidas (en la casa hay pistas
que se leen aumentadas [4]): **alto (lente), prohibido**. Elegir habitaciones: no aplica a una caja.

**Fuentes de la ficha:** 1. [Wikipedia: Blue Prince](https://en.wikipedia.org/wiki/Blue_Prince) · 2. [Game
Informer: reseña](https://gameinformer.com/review/blue-prince/mystery-mastery) · 3. [Blue Prince Wiki: Parlor
Game](https://blueprince.wiki.gg/wiki/Parlor_Game) · 4. [Blue Prince Wiki:
Antechamber](https://blueprince.wiki.gg/wiki/Antechamber) · 5. [Inverse: entrevista a Tonda
Ros](https://www.inverse.com/gaming/blue-prince-interview-tonda-ros-no-dlc-maze-christopher-manson-intotheabyss-white-raven)
· 6. [Unity: por qué Dogubomb vio 2.000 horas de partidas](https://unity.com/blog/blue-prince-why-dogubomb-watched-2000-hours-gameplay)

---

## 10. Tunic (2022)

**Género y año.** Acción y aventura isométrica con un zorro, llena de secretos. Andrew Shouldice empezó solo en
febrero de 2015 (entonces se llamaba *Secret Legend*); editado por Finji; salió el 16-03-2022 [Hecho, 1].

**Core loop** [Interpretación]: explorar y luchar → encontrar una página del manual → la página enseña una
mecánica o insinúa un secreto → volver a mirar lo ya visto → abrir secretos.

**Interacción (verbos)** [Hecho, 1, 4]: moverse, luchar, recoger páginas, leer el manual (dibujos, mapas y notas
a mano), hacer ofrendas, introducir secuencias de direcciones.

**Mecánicas** [Hecho, 1, 3, 4]:
- Un manual de instrucciones que se encuentra por páginas, desordenado, escrito en gran parte en una lengua
  inventada.
- Las páginas enseñan con dibujos; por ejemplo, que en un altar se pueden ofrecer objetos, algo que el mundo no
  indica [1].
- Secuencias de direcciones que abren secretos (la «cruz sagrada»).
- Un meta-puzle (un puzle hecho de otros puzles) que usa el manual entero: el camino dorado [3, 4].

**Los mejores puzles**

1. **La página que enseña lo que el mundo calla** [1, 2].
   - Información: un dibujo del zorro haciendo una ofrenda en un altar.
   - Descubrir: que el altar acepta ofrendas.
   - Variable: ofrecer o no.
   - Reglas: el altar mejora al zorro a cambio de ofrendas.
   - Lo difícil: el mundo no da ninguna señal.
   - Lo satisfactorio: [Hecho, 2] para Shouldice, «getting to study a mysterious page feels like
     mystery-solving» [estudiar una página misteriosa ya es resolver un misterio].
   - Feedback: el altar responde.
   - Recompensa: mejoras.

2. **El camino dorado** [3, 4].
   - Información: en la página 49, una cuadrícula de números; cada número remite a otra página donde hay un trozo
     de un camino dorado.
   - Descubrir: que el manual entero es el puzle y cómo se unen los trozos.
   - Variable: una secuencia larga de direcciones (arriba, abajo, izquierda y derecha).
   - Reglas: el camino unido se traduce a direcciones y se introduce ante la puerta de la montaña [4].
   - Lo difícil: necesita casi todas las páginas y juntar todo lo visto.
   - Lo satisfactorio: [Opinión, 3] un descubrimiento «electrifying and intimidating»; lo hace disfrutable que el
     juego «slowly builds up a visual language» [construye poco a poco un lenguaje visual].
   - Feedback: un destello morado y la puerta se abre despacio [4].
   - Recompensa: el camino al final verdadero.

**Cámara** [Interpretación]: isométrica y fija; parte de los secretos vive en lo que esa cámara enseña mal.

**Feedback, animación y sonido** [Interpretación]: el feedback de un secreto es el propio hallazgo: una puerta que
se abre, una página nueva. No se encontró un análisis específico de su sonido.

**Narrativa.** [Hecho, 5] El equipo quería que el jugador se sintiera «a stranger in a strange land» [un
forastero en tierra extraña]; por eso la lengua inventada. [Interpretación] La historia y las reglas llegan por
el manual.

**Dificultad y aprendizaje.** [Hecho, 2] La idea nace de los manuales de NES que Shouldice hojeaba de niño sin
entenderlos. [Hecho, 6] En la GDC de 2023 propuso pensar los secretos como «cabos sueltos» y defendió que tener
muchos misterios abiertos también es un placer, no solo resolverlos. [Hecho, 5] El equipo calibró cuánto abrir
cada camino: si dejas la puerta demasiado abierta, mucha gente se mete por donde no toca. [Hecho, 5] También
hicieron «contenido para nadie»: detalles que quizá nadie vea.

**Lo que valoran** [Opinión, 1]: GameSpot llamó a los puzles del manual «utterly fantastic».

**Lo que critican** [Opinión, 1]: puzles oscuros y difíciles que dejan atascados a algunos jugadores, sobre todo
al final.

**Para La caja viva** [Interpretación]:
- **El cuaderno del artesano (G).** Hojas con dibujos en tinta, sin texto, que aparecen en cajones y enseñan
  gestos y reglas de la caja (cómo se tira de un cajón con cerradura, qué acepta el incensario). Encaja con el
  estilo de tinta del juego.
- **El trazo de un kanji como código (H).** Versión táctil de la cruz sagrada: el orden de trazos del kanji 目
  («ojo»), dibujado con números en el cuaderno, se traza con el dedo sobre la laca para abrir el cajón largo («Lo
  mejor del bloque», 10).
- **Un final hecho de trozos (C).** Cada nivel deja en el cuaderno un trozo de trazo; juntos forman el gesto que
  abre El corazón.
- **Secretos para nadie (A).** Micro-secretos opcionales (un haiku que solo se lee con la lámpara cerca) que dan un
  sello de curiosidad en el marcador.

**Riesgo de parecido.** Manual del propio juego, cruz de direcciones y caminos dorados: **medio** si se copia el
formato. Un cuaderno de artesano con trazos de kanji: **bajo**.

**Fuentes de la ficha:** 1. [Wikipedia: Tunic](https://en.wikipedia.org/wiki/Tunic_(video_game)) · 2. [Game
Developer: Road to the IGF (Tunic)](https://www.gamedeveloper.com/road-to-igf-2023/how-tunic-weaves-wondrous-unknowable-worlds-inspired-by-inscrutable-nes-manuals)
· 3. [AV Club: el camino dorado](https://www.avclub.com/tunic-golden-path-explained-boss-rush) · 4. [GGRecon:
la puerta de la montaña](https://www.ggrecon.com/guides/tunic-mountain-door/) · 5. [Game Developer: diseñar
contenido para nadie](https://www.gamedeveloper.com/design/designing-content-for-no-one-an-interview-with-the-team-behind-tunic)
· 6. [GDC: sesión sobre los secretos de Tunic](https://gdconf.com/news/unlock-secrets-tunic-gdc-2023-design-session)

---

## 11. Return of the Obra Dinn (2018)

**Género y año.** Juego de deducción en primera persona. Lucas Pope, en solitario; 18-10-2018; gráficos de 1 bit
(blanco y negro con tramas) [Hecho, 1]. Unos cuatro años y medio de trabajo [Hecho, 3]. Gran premio Seumas McNally
y mejor dirección de arte en The Game Awards 2018 [Hecho, 1].

**Core loop** [Hecho, 1, 2]: encontrar un cadáver → el reloj *Memento Mortem* enseña el instante de su muerte
(primero solo sonido y diálogo; luego la escena congelada en 3D) → recorrer la escena para identificar a la gente
→ anotar en el cuaderno quién es, cómo murió y quién lo mató → la escena lleva a otros cadáveres.

**Interacción (verbos)** [Hecho, 1, 2]: caminar, mirar, usar el reloj, consultar el cuaderno (lista de
tripulantes con cargo y nacionalidad, dibujos de todos, mapa del barco), elegir nombres y causas.

**Mecánicas** [Hecho, 1, 2, 3]:
- 60 personas que identificar.
- Validación por lotes: los destinos se confirman de tres en tres (los seis últimos, de dos en dos) para
  desanimar las conjeturas [1].
- La causa de la muerte admite respuestas aproximadas; lo exigente es la identidad [3].
- Pistas débiles que hay que cruzar: acento, ropa, litera, posición en un dibujo, con quién va [2].

**Los mejores puzles**

1. **Identificar a un marinero cualquiera** [2, 3].
   - Información: una escena congelada; voces con acento; la lista de tripulantes; el dibujo de grupo.
   - Descubrir: el nombre de alguien sin ningún rasgo único.
   - Variable: el nombre elegido.
   - Reglas: solo cuenta cuando sale bien un lote de tres.
   - Lo difícil: [Hecho, 3] Pope reconoce que los marineros corrientes le quedaron demasiado difíciles: las
     pistas son pocas y se pasan por alto con facilidad.
   - Lo satisfactorio: deducir con pistas pequeñas y sentir que lo has visto tú.
   - Feedback: la confirmación por lotes.
   - Recompensa: el destino queda impreso y ya no se puede cambiar.

2. **La regla de tres** [1, 3, 4].
   - Información: el cuaderno con tus conjeturas escritas a mano.
   - Descubrir: cuáles son correctas.
   - Variable: el conjunto de respuestas.
   - Reglas: cuando tres destinos están bien, el juego te saca de la acción y los imprime [4]; lo que no se
     confirma tiene algo mal.
   - Lo difícil: [Hecho, 3] Pope eligió los lotes para que adivinar costara más que resolver; un amigo le sugirió
     tres en vez de dos.
   - Lo satisfactorio: la confirmación llega como un premio a ritmo regular.
   - Feedback: el sello impreso.
   - Recompensa: avances fijos. [Opinión, 4] Aun así, se puede descartar por eliminación, y eso no es una
     deducción de verdad.

**Cámara** [Hecho, 1]: primera persona; se camina dentro de momentos congelados.

**Feedback, animación y sonido** [Hecho, 2]: el sonido llega antes que la imagen: pantalla negra, diálogo y luego
el instante. [Interpretación] El sonido plantea la pregunta y la imagen da las pistas.

**Narrativa** [Hecho, 2]: el cuaderno ordena el desastre por capítulos; reconstruir el viaje es la historia.

**Dificultad y aprendizaje.** [Hecho, 3] Pope quería que al jugador le atrajera la propia lista, sin que el
juego le obligara. [Opinión, 2] Al final, el barco se llena de puntos de muerte que no dicen a qué capítulo
pertenecen, y el estilo gráfico a veces esconde detalles necesarios.

**Lo que valoran** [Opinión, 1]: Polygon lo llamó «the work of an intense and creative intelligence».

**Lo que critican** [Opinión]: identidades comunes demasiado difíciles (lo dice el propio Pope) [3]; la
eliminación permite atajos [4]; la navegación del final [2].

**Para La caja viva** [Interpretación]:
- **Confirmar por lotes y grabar lo acertado (B).** En El corazón, la caja solo confirma cuando los tres anillos
  están bien a la vez, y lo acertado queda grabado en su cara para siempre («Lo mejor del bloque», 8).
- **El recuerdo congelado, primero sonido (F).** Al devolverle el ojo, la caja enseña un recuerdo quieto en tinta
  (una lámina), precedido solo de sonido; en él están las pistas del nivel siguiente.
- **Aceptar lo aproximado cuando la exactitud no es el reto (A).** Si una pieza está casi en su sitio y lo
  importante era la idea, la caja la acepta.

**Riesgo de parecido.** Reloj que enseña muertes, barco y cuaderno de seguros: no se usan. Un recuerdo congelado
de la caja: **bajo**.

**Fuentes de la ficha:** 1. [Wikipedia: Return of the Obra Dinn](https://en.wikipedia.org/wiki/Return_of_the_Obra_Dinn)
· 2. [Hardcore Gaming 101: Return of the Obra Dinn](https://www.hardcoregaming101.net/return-of-the-obra-dinn/) ·
3. [Automaton: entrevista a Lucas Pope, en japonés](https://automaton-media.com/articles/interviewsjp/20190719-97599/2/)
· 4. [Film Stories: la regla de tres de Obra Dinn](https://filmstories.co.uk/?p=83249)

---

## 12. Outer Wilds (2019)

**Género y año.** Exploración y misterio en un pequeño sistema solar, en primera persona. Mobius Digital, editado
por Annapurna Interactive; 2019 [Hecho, 1]. Nació en 2012 como tesis de máster de Alex Beachum en la USC; ganó en
el IGF de 2015 el premio a la excelencia en diseño y el gran premio Seumas McNally; BAFTA a mejor juego [Hecho,
1].

**Core loop** [Hecho, 1]: el sol estalla cada 22 minutos y todo vuelve a empezar; no se conservan objetos ni
mejoras, solo lo que sabes, que guarda el diario de la nave.

**Interacción (verbos)** [Hecho, 1]: pilotar una nave con física realista, caminar, usar la mochila propulsora,
traducir textos nomai (una civilización desaparecida), escuchar señales con un radiotelescopio, lanzar una sonda
con cámara.

**Mecánicas** [Hecho, 1, 3, 4]:
- Un bucle de 22 minutos con sucesos a horas fijas (la arena pasa de un planeta gemelo al otro; otro planeta se
  desmorona hacia su agujero negro).
- El saber como única progresión.
- Un diario de la nave con un «modo rumor» que enlaza pistas.
- Reglas de observación «cuántica»: una luna que cambia de órbita cuando nadie la mira.
- Peces abisales que reaccionan al ruido.

**Los mejores puzles**

1. **Las reglas de la observación** [3, 1].
   - Información: textos y pruebas, en varios planetas, sobre objetos «cuánticos» que cambian de sitio cuando
     nadie los mira.
   - Descubrir: tres reglas aprendidas en sitios distintos: mirar una imagen del objeto cuenta como mirarlo
     («observing an image of a quantum object and observing the object itself are the same thing»); a oscuras,
     si lo tocas, viajas con él; y dónde está el santuario de la luna [3].
   - Variable: mirar o no mirar, la foto de la sonda, la luz.
   - Reglas: lo no observado se mueve; la foto lo fija; la oscuridad te une a él.
   - Lo difícil: va contra la intuición y hay que combinar reglas de tres sitios.
   - Lo satisfactorio: una regla aprendida en un planeta resuelve otro.
   - Feedback: el objeto se queda o desaparece; el paisaje cambia.
   - Recompensa: llegar al lugar más escondido de la luna.

2. **Los peces abisales** [1, 4].
   - Información: en un planeta lleno de zarzas viven peces gigantes y agresivos. [Hecho, 4] En otro
     planeta, junto a un fósil, un texto cuenta que los niños nomai jugaban a un juego: uno hacía de pez con los
     ojos vendados y los demás tenían que cruzar a hurtadillas; la venda se añadió «because real anglerfish are blind»
     [porque los peces reales son ciegos].
   - Descubrir: que los peces cazan por el ruido, no por la vista.
   - Variable: encender o no los motores.
   - Reglas: el ruido atrae a los peces [1]; deslizarse en silencio no.
   - Lo difícil: fiarse de un dato aprendido en un juego de niños, con un pez gigante delante.
   - Lo satisfactorio: sobrevivir solo por saber.
   - Feedback: los peces se giran hacia ti si haces ruido.
   - Recompensa: llegar a los restos nomai del interior.

**Cámara** [Hecho, 1]: primera persona libre.

**Feedback, animación y sonido** [Interpretación]: el mundo es el feedback (la arena que sube, el planeta que se
cae); el diario marca dónde queda algo por descubrir.

**Narrativa.** [Hecho, 2] Beachum explica que el único fin de explorar es responder preguntas sobre el mundo, y
que los personajes hablan de lugares lejanos a los que luego puedes ir. [Hecho, 2] El bucle existe sobre todo
para poder crear sistemas grandes que cambian con el tiempo.

**Dificultad y aprendizaje.** [Hecho, 5] Mobius quería quitar el deambular sin rumbo: que se vea adónde lleva un
camino, mejor con imágenes que con carteles, y dar pistas de dirección sin destripar lo que hay. [Hecho, 6, 7] Sus
autores dieron en la GDC de 2020 una charla sobre el diseño guiado por la curiosidad y otra sobre su «diseño de
niveles en 4D» (el espacio que cambia con el tiempo).

**Lo que valoran** [Opinión, 1]: la exploración y el misterio.

**Lo que critican** [Opinión, 1]: al final, hay jugadores que se atascan sin una dirección clara.

**Para La caja viva** [Interpretación]:
- **Una regla de mirar con subreglas (E/D).** Nuestra regla ya es de este tipo; puede crecer nivel a nivel con
  una excepción nueva cada vez: «la caja también oye» (un cajón que chirría la despierta: hay que tirar despacio);
  «a oscuras no ve, pero tú tampoco»; «una mirada pintada cuenta» (un ojo pintado en papel, puesto frente a ella,
  le devuelve la mirada y la deja quieta, embobada) («Lo mejor del bloque», 6).
- **Un juego infantil que guarda la regla (G).** Como el juego de los niños nomai: la canción de *daruma-san ga
  koronda* en el fondo de un cajón enseña que la caja no ve mientras canta («Lo mejor del bloque», 1).
- **Un diario que marca lo pendiente (B).** La cara-marcador brilla un poco en las partes de la caja que aún
  guardan algo, sin decir qué.

**Riesgo de parecido.** Física cuántica, fotos que fijan objetos y lunas que se mueven: **medio** si se copia la
expresión. Una regla de un ser vivo (mirar, oír, la oscuridad): **bajo**.

**Fuentes de la ficha:** 1. [Wikipedia: Outer Wilds](https://en.wikipedia.org/wiki/Outer_Wilds) · 2. [Game
Developer: Road to the IGF (Alex Beachum)](https://www.gamedeveloper.com/design/road-to-the-igf-alex-beachum-s-i-outer-wilds-i-)
· 3. [TheGamer: guía de las reglas cuánticas](https://www.thegamer.com/guide-how-to-get-best-ending-outer-wilds-part-2/)
· 4. [Steamah: entradas del diario de la nave](https://steamah.com/outer-wilds-all-ship-log-entries-guide-archaeologist-achievement/)
· 5. [Mobius Digital: «The intentionality of wandering»](https://www.mobiusdigitalgames.com/news/the-intentionality-of-wandering)
· 6. [GDC: diseño guiado por la curiosidad en Outer Wilds](https://gdconf.com/article/attend-gdc-and-learn-how-outer-wilds-nailed-curiosity-driven-game-design/)
· 7. [GDC: el diseño de niveles en 4D de Outer Wilds](https://gdconf.com/news/see-4d-level-design-outer-wilds-deconstructed-gdc-2020)

---
## 13. Gorogoa (2017)

**Género y año.** Puzle ilustrado a mano y sin texto. Jason Roberts (Buried Signal), editado por Annapurna; casi
seis años de trabajo (2011-2017) [Hecho, 1]; salió el 14-12-2017 [Hecho, 7]. Música de Joel Corelitz, que cambia
según el panel que miras [Hecho, 1]. Dura de 2 a 3 horas; BAFTA a mejor juego debut [Hecho, 1].

**Core loop** [Hecho, 1]: cuatro ilustraciones en una cuadrícula de 2 × 2 → acercarse o alejarse dentro de ellas
→ mover paneles y levantar capas (lo que tiene un hueco, como una ventana, se separa y se pone encima de otro
panel) → cuando dos escenas encajan, cobran vida → el niño protagonista avanza hacia una de las cinco frutas.

**Interacción (verbos)** [Hecho, 1, 3]: hacer zoom, desplazar, arrastrar un panel, levantar una capa, ponerla
encima de otra, tocar.

**Mecánicas** [Hecho, 1, 3, 5]: alinear bordes y formas entre paneles; escenas dentro de escenas (escala); capas;
escenas con tiempo (alinear unas vías antes de que pase el tren [5]).

**Los mejores puzles**

1. **El niño por la escalera** [6, 3].
   - Información: un panel con el niño; otro con una escalera; un tejado.
   - Descubrir: que un panel puesto sobre otro une sus espacios.
   - Variable: qué panel va sobre cuál y qué capa se quita.
   - Reglas: el panel del niño sobre el de la escalera le hace cruzar una puerta; quitar la capa del tejado le
     deja subir; poner encima el callejón del tejado le lleva a la puerta verde [6].
   - Lo difícil: pensar en capas, no en fotos.
   - Lo satisfactorio: [Hecho, 3] Roberts lo explica así: el jugador imagina que las escenas podrían unirse y
     «the border between them dissolves» [el borde entre ellas se disuelve].
   - Feedback: el borde se borra y el niño anda.
   - Recompensa: avanzar por la ciudad.

2. **La segunda fruta** [6].
   - Información: una estatua con un cuenco; un dibujo verde en un edificio en llamas; la silueta de una manzana;
     un ojo verde.
   - Descubrir: qué formas «riman» entre escenas.
   - Variable: zoom, capa y posición de los paneles.
   - Reglas: al quitar una capa del cuenco aparece un muro; al acercarse al dibujo verde, se vuelve rojo; la
     silueta de la manzana puesta sobre el ojo hace caer la fruta en el cuenco.
   - Lo difícil: ver una rima visual entre escalas distintas.
   - Lo satisfactorio: dos dibujos sin relación resultan ser el mismo.
   - Feedback: la animación de la fruta.
   - Recompensa: la fruta.

**Cámara** [Hecho, 1]: no hay cámara libre: el zoom dentro de cada panel hace de cámara.

**Feedback, animación y sonido** [Hecho, 1]: cada conexión buena dispara una animación corta; la música sigue al
panel que miras.

**Narrativa.** [Hecho, 2] Roberts: «a story suspended inside a puzzle» [una historia suspendida dentro de un
puzle] y «Everything has a dual nature» [todo tiene doble naturaleza]. [Hecho, 3] «The needs of the story and the
needs of the puzzle design push against each other» [lo que pide la historia y lo que pide el puzle se empujan];
tiró capítulos enteros cuando el equilibrio fallaba. [Hecho, 4] Su charla de la GDC 2018 se titula «Gorogoa: The
Design of a Cosmic Acrostic».

**Dificultad y aprendizaje** [Hecho, 1, 5]: sin texto; se aprende tocando: el primer gesto es alejarse de un
panel y descubrir un paisaje mayor.

**Lo que valoran** [Opinión, 1]: Ars Technica lo llamó el juego dibujado a mano más bonito jamás hecho.

**Lo que critican** [Opinión, 1]: que es corto.

**Para La caja viva** [Interpretación]:
- **Rimas visuales entre la caja y la sala (F).** Girar la caja pequeña hasta que una veta de su marquetería
  continúe la del tablero de la mesa; al encajar, la línea corre como un hilo de luz.
- **Cada paso es una escena (G).** Cada paso resuelto enseña un instante de la vida de la caja con sus dueños,
  pintado en el mismo estilo de tinta: la historia llega sin texto.
- **El zoom como descubrimiento (B, con cuidado).** Pellizcar sobre el rollo colgado revela que su paisaje
  esconde un detalle de la caja (un cajón abierto que la caja real tiene cerrado). Se mira, nunca se entra.

**Riesgo de parecido.** Paneles que se unen y capas que se levantan: **alto** si se copia (es su firma). La puerta
a un jardín que se abre quitando una capa (lo más parecido a un portal): **alto, no usar**. El pellizco ya existe
en el juego; usarlo para descubrir detalles: **bajo-medio**.

**Fuentes de la ficha:** 1. [Wikipedia: Gorogoa](https://en.wikipedia.org/wiki/Gorogoa) · 2. [Thumbsticks: cómo
se hizo Gorogoa](https://www.thumbsticks.com/jason-roberts-making-of-gorogoa/) · 3. [Inverse: entrevista a
Jason Roberts](https://inverse.com/article/28053-gorogoa-developer-jason-roberts-interview) · 4. [GDC Vault:
«Gorogoa: The Design of a Cosmic Acrostic»](https://gdcvault.com/play/1025448/-Gorogoa-The-Design-of) · 5.
[Mechanics of Magic: Critical Play](https://mechanicsofmagic.com/2024/05/14/critical-play-puzzles-124/) · 6.
[TheGamer: puzles del capítulo 2](https://www.thegamer.com/gorogoa-chapter-two-puzzle-solution/) · 7. [GamesBeat:
fecha de salida](https://gamesbeat.com/gorogoas-hand-drawn-puzzles-debut-on-december-14-after-5-years-of-crafting/)

---

## 14. Keep Talking and Nobody Explodes (2015)

**Género y año.** Puzle cooperativo de comunicación. Steel Crate Games (Allen Pestaluky, Ben Kane y Brian
Fetter); nació en la Global Game Jam de 2014: hacían una montaña rusa en realidad virtual, vieron que los
espectadores se quedaban fuera y buscaron una experiencia compartida [Hecho, 1]. Salió en 2015 [Hecho, 1].

**Core loop** [Hecho, 1]: una persona (el artificiero) ve la bomba y no el manual; las demás (los expertos) leen
el manual y no ven la bomba → el artificiero describe un módulo → los expertos buscan la regla → el artificiero
actúa → acierto, o un fallo que acelera el reloj → el siguiente módulo, antes de que se acabe el tiempo.

**Interacción (verbos)** [Hecho, 1, 2]: describir, preguntar, leer, cortar cables, pulsar, mantener y soltar.

**Mecánicas** [Hecho, 1, 2]:
- Información asimétrica: cada bando tiene media información.
- Módulos independientes, en cualquier orden; módulos «necesitados» que hay que atender cada cierto tiempo y que
  nunca se desactivan del todo.
- Reloj y fallos (los fallos aceleran el reloj).
- Reglas que dependen de detalles del exterior de la bomba (número de serie, pilas, indicadores).
- Bombas generadas al azar.

**Los mejores puzles** [2]

1. **Los cables** [2].
   - Información: el artificiero ve de tres a seis cables de colores y el número de serie.
   - Descubrir: qué cable cortar.
   - Variable: el cable.
   - Reglas: dependen de cuántos cables hay, de sus colores y de si la última cifra del número de serie es par o
     impar.
   - Lo difícil: describir bien y leer bien bajo presión.
   - Lo satisfactorio: la cooperación exacta.
   - Feedback: el módulo se apaga o suma un fallo.
   - Recompensa: un módulo menos.

2. **El botón** [2].
   - Información: el color y el texto del botón; las pilas; los indicadores; una tira de color que se enciende al
     mantenerlo pulsado.
   - Descubrir: si hay que pulsar y soltar o mantener, y cuándo soltar.
   - Variable: el momento de soltar.
   - Reglas: siete reglas en orden; si se mantiene, se suelta cuando el reloj muestra un 4 (tira azul), un 1
     (blanca) o un 5 (amarilla).
   - Lo difícil: la regla depende de algo que solo aparece al actuar (la tira).
   - Lo satisfactorio: el instante exacto de soltar.
   - Feedback: la tira de color; el módulo desactivado.
   - Recompensa: un módulo menos.

3. **El teclado de símbolos** [2].
   - Información: cuatro símbolos raros en el teclado; en el manual, columnas de símbolos.
   - Descubrir: la columna que contiene los cuatro.
   - Variable: el orden de pulsación.
   - Reglas: pulsar en el orden en que aparecen en esa columna, de arriba abajo.
   - Lo difícil: describir con palabras símbolos que no tienen nombre.
   - Lo satisfactorio: inventar entre los jugadores un vocabulario propio para los símbolos.
   - Feedback: acierto o fallo.
   - Recompensa: un módulo menos.

**Cámara** [Interpretación]: el artificiero gira la bomba para ver sus caras y sus bordes, como una caja.

**Feedback, animación y sonido.** [Hecho, 1] Fallos y un reloj que se acelera. [Hecho, 2] El manual tiene humor
negro: «One small oversight and it could all be over!» [¡un pequeño descuido y se acabó todo!].

**Narrativa** [Interpretación]: ninguna; la historia la crean los jugadores al hablar.

**Dificultad y aprendizaje.** [Hecho, 3] Para Ben Kane, la clave es fomentar una comunicación interesante y
divertida; no hace falta poner trampas a propósito, porque describir algo que el otro no ve ya es difícil.
[Hecho, 4] Su charla de la GDC trató cómo afinaron los puzles para provocar tensión, errores, risas y
compañerismo, con los juegos de mesa como inspiración.

**Lo que valoran** [Opinión, 1]: Destructoid (9/10) lo recomienda siempre que tengas amigos dispuestos.

**Lo que critican** [Interpretación]: la misma frase de Destructoid apunta a su límite: sin compañía no se juega.

**Para La caja viva** [Interpretación]:
- **Reglas que dependen del entorno (C).** Un detalle de la sala (cuántas varillas de incienso arden, la fase de
  la luna tras el shoji) cambia qué cajón es el bueno, y cambia de una partida a otra.
- **Soltar en el momento justo (B).** Mantener la trampilla y soltarla en el punto más alto de la respiración de
  la caja.
- **Un modo de sofá, más adelante (F).** Fuera del MVP: uno sostiene el móvil y otro lee en otra pantalla el
  cuaderno del artesano. Puede dar vídeos de parejas jugando (marketing), pero es trabajo extra.

**Riesgo de parecido.** **Bajo**: bombas, cables y manuales no se parecen a una caja viva.

**Fuentes de la ficha:** 1. [Wikipedia: Keep Talking and Nobody Explodes](https://en.wikipedia.org/wiki/Keep_Talking_and_Nobody_Explodes)
· 2. [Bomb Defusal Manual (manual oficial)](https://bombmanual.com/web) · 3. [Voices of VR: Ben Kane sobre el
diseño](https://voicesofvr.com/?p=927) · 4. [GDC Vault: «Designing Asymmetric Gameplay For Keep Talking and Nobody
Explodes»](https://gdcvault.com/play/1023113/Designing-Asymmetric-Gameplay-For-Keep)

---

## 15. The Witness (2016)

**Género y año.** Puzles en primera persona en una isla. Thekla (Jonathan Blow); 26-01-2016; unos 650 puzles y
siete años de desarrollo [Hecho, 1].

**Core loop** [Hecho, 1]: encontrar paneles donde se traza una línea desde un círculo hasta una salida → deducir
la regla de un símbolo con casos fáciles → aplicarla a casos difíciles → abrir zonas → descubrir que el propio
paisaje esconde los mismos trazos.

**Interacción (verbos)** [Hecho, 1]: caminar, mirar, trazar una línea en un panel, buscar el punto de vista.

**Mecánicas** [Hecho, 1, 3, 4, 5]:
- Reglas de trazado que se enseñan con filas de paneles, sin texto.
- Pistas del entorno: ramas, sombras, reflejos y brillos del sol, sonido (el canto de pájaros en la selva).
- Trazos del paisaje que solo se completan desde un punto exacto.
- Algunas zonas tienen dos caminos al mismo objetivo [5].

**Los mejores puzles**

1. **El huerto** [3, 8].
   - Información: paneles con forma de ramas que se abren en varias puntas; manzanos al lado [8].
   - Descubrir: que en cada árbol real cuelga una sola manzana, en una rama concreta [3].
   - Variable: el camino trazado.
   - Reglas: el camino del panel es la rama del árbol que tiene la manzana.
   - Lo difícil: levantar la vista del panel.
   - Lo satisfactorio: el mundo y el puzle hablan el mismo idioma.
   - Feedback: el panel se acepta.
   - Recompensa: el siguiente panel y, sobre todo, aprender que el entorno da pistas.

2. **Sombras y brillos** [4, 1].
   - Información: paneles de un bosque con sombras de ramas encima; en el desierto, paneles cuyo trazo solo se ve
     con el reflejo del sol [4].
   - Descubrir: que la sombra o el brillo marcan el camino.
   - Variable: tu posición y tu punto de vista.
   - Reglas: lo que importa está en la luz, no en el panel.
   - Lo difícil: la pista no está en el objeto que tocas.
   - Lo satisfactorio: entender que la luz es parte del puzle.
   - Feedback: el trazo aceptado.
   - Recompensa: avanzar.

3. **Los trazos del paisaje** [1, 6].
   - Información: líneas del entorno (un camino, una roca, una rama) que, desde un punto, forman un trazo de panel.
   - Descubrir: dónde ponerse.
   - Variable: el punto de vista.
   - Reglas: si se ve el trazo completo, se puede trazar.
   - Lo difícil: nadie te dice que existen.
   - Lo satisfactorio: [Opinión, 6] «This game was an epiphany generator» [este juego era una máquina de
     revelaciones].
   - Feedback: el trazo se marca en el paisaje.
   - Recompensa: la revelación misma.

**Cámara** [Hecho, 1]: primera persona libre; el punto de vista es parte del puzle.

**Feedback, animación y sonido** [Opinión, 6]: pocos efectos y ninguna recompensa llamativa al resolver; el
zumbido de los paneles acaba cansando.

**Narrativa** [Hecho, 2]: para Blow, los puzles no son el fin: son una forma de comunicar ideas.

**Dificultad y aprendizaje.** [Hecho, 1] Blow quería comunicarse sin palabras: explicar de más mataría la
revelación y la alegría de descubrir. [Hecho, 5] «When making adventure games, your puzzles should have a point»
[en una aventura, los puzles deben tener un sentido]. [Opinión, 7] Algunas secuencias que enseñan se alargan
demasiado repitiendo la misma lección.

**Lo que valoran** [Opinión, 1]: IGN le dio un 10 y lo llamó obra maestra; muchos críticos destacan los momentos
de revelación.

**Lo que critican** [Opinión]: Wired lo vio «hard, but empty» y avisó de que muchos abandonarán [1]; USgamer
criticó que, al fallar, no se entiende qué está mal [1]; mareo por el campo de visión [1]; accesibilidad: una zona
entera depende de distinguir colores y otra del sonido [7]; algunos paneles se apagan al fallar y obligan a rehacer
el anterior [7]; no hay pistas [6].

**Para La caja viva** [Interpretación]:
- **Tres casos pequeños antes de cada regla nueva (A).** Antes de una cerradura nueva, tres versiones mínimas en
  la bandeja enseñan su regla, sin texto.
- **La sala dibuja la pista (F).** La rama de bambú con una hoja distinta, cuya sombra cae en el shoji, dice qué
  ranura de la tapa es la buena («Lo mejor del bloque», 4).
- **Accesible desde el diseño (E).** Ninguna información solo por color ni solo por sonido: siempre también forma,
  posición o vibración.
- **Un error nunca deshace lo logrado (D).** Al revés que sus paneles que se apagan: la caja solo se resiste a su
  manera.

**Riesgo de parecido.** Paneles de líneas: no se usan. Pistas de sombra y de punto de vista: **medio-bajo** (The
Room también tiene cifras que solo se leen desde un ángulo; biblia, 19.11). Como mucho, una alineación por vista
fija.

**Fuentes de la ficha:** 1. [Wikipedia: The Witness](https://en.wikipedia.org/wiki/The_Witness_(2016_video_game))
· 2. [Game Developer: «Bearing Witness»](https://www.gamedeveloper.com/business/bearing-i-witness-i-) · 3.
[GamesBeat: guía de The Witness](https://gamesbeat.com/the-witness-walkthrough/) (texto visto en el buscador) ·
4. [GameRevolution: todos los tipos de puzle](https://www.gamerevolution.com/?p=12219) (texto visto en el
buscador) · 5. [Engadget: The Witness y la intuición](https://www.engadget.com/2014-06-12-the-witness-and-the-joy-of-intuition.html)
· 6. [Room Escape Artist: reseña](https://roomescapeartist.com/2018/05/18/the-witness-review/) · 7. [GameCritics:
reseña](https://gamecritics.com/sparky-clarkson/the-witness-review/) · 8. [Fletcher Studio: el diseño de los
entornos](https://fletcher.studio/blog/2017/5/26/the-witness-designing-video-game-environments)

---

## Lo mejor del bloque: 12 principios para La caja viva

Todo lo de esta sección es **[Interpretación]** (salvo lo marcado), apoyado en los [Hecho] de las fichas, que se
citan por número de ficha. Ninguna propuesta está aprobada: son candidatas para la biblia y para presentar al
usuario con el formato DECISIÓN. Letras: A tal cual · B modificado · C combinado · D invertido · E variable nueva ·
F otro contexto · G unido a la narrativa · H mecánica nueva.

| # | Principio | Sale de | Letra | Riesgo de parecido |
|---|---|---|---|---|
| 1 | La regla se aprende con un juego del propio mundo | Riven, Outer Wilds, Boxes | G | Medio-bajo |
| 2 | «Sigue las tuberías»: la consecuencia se ve viajar | Riven (Cyan), Blue Prince, Boxes | A/B | Bajo |
| 3 | Una clave de lectura que se aprende en un sitio y se usa en otro | Riven, Myst, Machinika, Tunic | C | Bajo |
| 4 | El mundo dibuja la solución | The Witness, Riven, Gorogoa | F | Medio-bajo |
| 5 | Cada pieza tiene doble naturaleza | Gorogoa, Da Vinci, Riven | G/H | Bajo |
| 6 | Mirar cambia las cosas: una regla que crece con subreglas | Outer Wilds, Boxes | E/D | Medio-bajo |
| 7 | Dos estados del mismo lugar, sin viajar | Da Vinci 2 y 3 | B | Bajo (sin portales) |
| 8 | Contra el ensayo y error: lotes, datos al azar y logros fijos | Obra Dinn, Myst 2021, Riven | B | Bajo |
| 9 | Pistas que viven en el mundo y escalan | Da Vinci, Boxes, Escape Simulator | G | Bajo |
| 10 | Un trazo como código | Tunic, Gorogoa | H | Bajo |
| 11 | Una fuente que miente con una regla que se aprende | Blue Prince | H | Medio-bajo |
| 12 | La escala sin entrar en lo pequeño | Gorogoa, Boxes, Machinika, Myst | B/F | Bajo-medio |

### 1. La regla se aprende con un juego del propio mundo
- **Sale de.** El juguete de la escuela de Riven enseña los números y, de paso, la crueldad de Gehn (ficha 2). En
  Outer Wilds, un juego de niños con los ojos vendados guarda el dato que salva la vida ante los peces (ficha
  12). Boxes tiene un puzle de «luz roja, luz verde» (ficha 7).
- **Por qué funciona.** El jugador aprende la regla en un sitio seguro, sin texto y sin castigo; un juego infantil
  se reconoce y se recuerda; y además cuenta algo del mundo.
- **En qué contexto.** Antes del primer uso «serio» de una regla, o para presentar la regla central a quien no
  la ha entendido.
- **Cómo transformarlo (G).** *Daruma-san ga koronda* es la versión japonesa de «luz roja, luz verde» [Hecho:
  [Wikipedia, Statues (game)](https://en.wikipedia.org/wiki/Statues_(game))]. La caja canta la frase (o suena
  dentro de ella) con el ojo cerrado: mientras dura, se puede tocar; al terminar, abre el ojo. El jugador lo
  entiende sin texto. Un dibujo de niños jugando en el cuaderno o en el fondo de un cajón lo confirma. Variable
  nueva para un nivel posterior (E): el ritmo de la canción como reloj, más rápido cuanto más despierta está la
  caja.
- **Riesgo de parecido.** Medio-bajo: Boxes lo usa como un puzle con una figura en un carril y un semáforo; aquí es
  la regla del juego y la canta un ser vivo. **Aviso de tono:** la serie *El juego del calamar* (2021) convirtió
  este juego en una prueba mortal con una muñeca gigante [Hecho: misma fuente]. Muchos jugadores lo asociarán
  [Interpretación]: nada de muñeca gigante, castigos ni «eliminados»; mantenerlo juguetón y tétrico, no violento.

### 2. «Sigue las tuberías»: la consecuencia se ve viajar
- **Sale de.** Cyan bromea con que sus juegos deberían llamarse «Follow the Pipes» (ficha 2). Andrew Plotkin
  critica la carga de canicas de Riven porque el efecto no se ve y el jugador no entiende qué ha hecho (ficha 2).
  En Blue Prince, cada palanca enseña con una escena corta la puerta que abre (ficha 9). En Boxes, lo más elogiado
  es que cada pieza suena al soltarse (ficha 7).
- **Por qué funciona.** El jugador construye un modelo de causa y efecto; el placer viene de entender, no del
  «ding». Si el efecto es invisible, el acierto parece suerte.
- **En qué contexto.** Siempre que el efecto ocurre fuera de la vista: en el otro costado, dentro de la caja o en
  la sala.
- **Cómo transformarlo (A/B).** Cada mecanismo tiene un enlace visible: un cordón que corre por una ranura, una
  veta de laca que se ilumina, una línea de humo, una grieta que avanza. La cámara sigue el enlace solo si el
  efecto está lejos. Cada enlace lleva su sonido y una vibración corta.
- **Riesgo de parecido.** Bajo: es un principio general (The Room también lleva la cámara a la consecuencia;
  biblia, 19.9). Evitar tuberías metálicas o estética steampunk: nuestro enlace es de laca, papel, cuerda y humo.

### 3. Una clave de lectura que se aprende en un sitio y se usa en otro
- **Sale de.** Los números de Riven (aprendidos con el juguete) y los colores de cada isla (aprendidos en la sala
  espía) que luego resuelven la rejilla (ficha 2); contar interruptores y traducir fechas en Myst (ficha 1); los
  símbolos de los costados que se ponen en tres anillos en Machinika (ficha 6); los números del manual de Tunic
  que remiten a otras páginas (ficha 10).
- **Por qué funciona.** Crea información cruzada: el jugador siente que entiende un sistema, no que sigue
  instrucciones, y mirar otra vez algo viejo cobra sentido.
- **En qué contexto.** Entre niveles (memoria entre niveles) o entre la caja y la sala.
- **Cómo transformarlo (C).** «Las marcas de la caja»: un sistema propio de muescas (por ejemplo, como las cuentas
  de un ábaco *soroban*) que se aprende con el juguete del principio 1 y se lee en el cajón largo y en El corazón.
  Que el sistema aparezca en tres sitios a la vez (una talla, una hoja del cuaderno, una sombra) para que nadie se
  quede fuera por no haber visto uno.
- **Riesgo de parecido.** Bajo, si no se usan números D'ni, fechas que se convierten en estrellas ni colores por
  isla.

### 4. El mundo dibuja la solución
- **Sale de.** El huerto de The Witness (la rama con la manzana es el camino) y sus sombras y brillos (ficha 15);
  las formas de animales que el paisaje de Riven dibuja desde un ángulo (ficha 2); las rimas visuales de Gorogoa
  (ficha 13).
- **Por qué funciona.** Obliga a levantar la vista de la caja; une objeto y sala; y el «ajá» es doble: la pista y
  la coherencia del mundo.
- **En qué contexto.** Nuestra sala ya tiene elementos vivos (las sombras del bambú que mueve el viento, el humo,
  la lámpara, el té): sirven de pistas sin añadir objetos. Con cámaras fijas, una pista de este tipo por vista,
  como mucho.
- **Cómo transformarlo (F).** Cuando el ojo duerme, el viento para y la sombra del bambú se queda quieta un
  instante señalando la ranura buena; o la columna de humo del incensario se dobla hacia el cajón correcto.
- **Riesgo de parecido.** Medio-bajo: The Witness usa sombras de árboles sobre paneles y The Room, cifras que solo
  se leen desde un ángulo. Evitar paneles de líneas y cifras escondidas en ángulos.

### 5. Cada pieza tiene doble naturaleza
- **Sale de.** Roberts: «Everything has a dual nature» y «a story suspended inside a puzzle» (ficha 13). Los
  objetos que se montan y cambian de función en The House of Da Vinci (ficha 3). El juguete-horca de Riven (ficha
  2). El juego infantil que es un dato científico en Outer Wilds (ficha 12).
- **Por qué funciona.** Cada objeto trabaja dos veces (ahorra producción) y la historia llega sin texto.
- **En qué contexto.** Objetos del inventario y de la sala.
- **Cómo transformarlo (G/H).** El cuerno es parte de la cara y también una flauta: soplarlo (mantener pulsado)
  atrae la mirada hacia el sonido. La nota es nota y también plantilla: sus agujeros, puestos sobre la
  marquetería, dejan ver solo unas piezas. Y cada paso resuelto enseña un instante de la vida de la caja con sus
  dueños.
- **Riesgo de parecido.** Bajo.

### 6. Mirar cambia las cosas: una regla que crece con subreglas
- **Sale de.** Las reglas de observación de Outer Wilds: lo no mirado se mueve, una imagen cuenta como mirada, a
  oscuras viajas con el objeto; y los peces que oyen en vez de ver (ficha 12). La luz roja de Boxes (ficha 7).
- **Por qué funciona.** Una sola regla simple que gana excepciones da profundidad sin sistemas nuevos; cada
  excepción es un «ajá» y se aprende en un sitio distinto.
- **En qué contexto.** Nuestra regla central («no deja tocar mientras te ve») ya es de este tipo; le falta crecer
  de nivel en nivel.
- **Cómo transformarlo (E/D).** Una subregla por nivel, enseñada antes de exigirla:
  - «La caja también oye»: un cajón que chirría la despierta, así que hay que tirar despacio (E).
  - «A oscuras no ve, pero tú tampoco»: apagar la lámpara deja tocar, pero esconde las marcas (E).
  - «Una mirada pintada cuenta»: un ojo pintado en un papel, puesto frente a ella, le devuelve la mirada y la deja
    quieta, embobada, como en un duelo de miradas (D).
  - Invertida, ya propuesta para el nivel 3: ahora quieres que mire (D).
  - Y varias soluciones válidas para lo mismo: distraerla con la lámpara, esconder la mano tras la caja pequeña o
    esperar a su parpadeo.
- **Riesgo de parecido.** Medio-bajo: nada de física cuántica, fotos que fijan objetos ni cosas que se
  teletransportan; la regla es de un ser vivo. El señuelo que se mueve (biblia, anexo C.1) y el espejo (caja viva
  2) ya existen: no repetirlos con otro nombre.

### 7. Dos estados del mismo lugar, sin viajar
- **Sale de.** El pasado y el presente de The House of Da Vinci 2 y 3: una palanca en el pasado corta el agua de
  las gárgolas; sellar un pozo evita la plaga de ratas (fichas 4 y 5). El mundo que cambia con el bucle en Outer
  Wilds (ficha 12).
- **Por qué funciona.** Duplica el espacio sin pintar mucho arte nuevo y obliga a pensar en causas y efectos
  diferidos.
- **En qué contexto.** Cuando la sala ya es conocida (nivel 3 o final).
- **Cómo transformarlo (B).** Estados de la sala y de la criatura: lámpara encendida o apagada, caja dormida o
  despierta. Lo que se mueve en uno queda movido en el otro; cada estado deja ver o tocar cosas distintas. Como los
  jugadores olvidan el «otro estado» (ficha 4), la caja lo sugiere cuando hace falta.
- **Riesgo de parecido.** Bajo con estados de luz y de la criatura. Alto si hay viaje en el tiempo o portales
  (prohibidos).

### 8. Contra el ensayo y error: lotes, datos al azar y logros fijos
- **Sale de.** La regla de tres de Obra Dinn, pensada para que adivinar cueste más que resolver (ficha 11); las
  cifras al azar del remake de Myst y del de Riven (fichas 1 y 2); las críticas a Boxes (un puzle que queda sin
  solución, ficha 7) y a The Witness (paneles que se apagan al fallar, ficha 15).
- **Por qué funciona.** Protege el «ajá» (no se puede forzar), deja sin valor las guías de internet y nunca quita
  lo ya logrado.
- **En qué contexto.** Combinaciones, órdenes y cerraduras finales (las tablillas, El corazón).
- **Cómo transformarlo (B).** El corazón solo confirma cuando los tres anillos están bien a la vez, y lo acertado
  se graba en la cara para siempre. Las cifras y los órdenes cambian en cada partida. Ningún mecanismo puede quedar
  sin solución: cada uno vuelve a su estado inicial con un gesto propio, y la prueba automática lo comprueba.
- **Riesgo de parecido.** Bajo.

### 9. Pistas que viven en el mundo y escalan
- **Sale de.** The House of Da Vinci: pistas por tiempo, de vagas a concretas, con una campanilla y recarga (ficha
  3). Boxes: una máscara que señala lo siguiente y la opción de saltar un puzle (ficha 7). Escape Simulator: un
  botón de ayuda (ficha 8). En Riven, Obra Dinn y The Witness no hay pistas, y se critica quedarse atascado
  (fichas 2, 11 y 15).
- **Por qué funciona.** En el móvil se abandona al atascarse; una pista dentro del mundo no rompe la atmósfera.
- **En qué contexto.** La biblia ya propone cuatro niveles de pista (§6.2, DECISIÓN 26).
- **Cómo transformarlo (G).** La pista es la propia caja: 1) el ojo mira de reojo hacia lo útil; 2) el humo se
  inclina hacia allí; 3) la hoja del cuaderno que lo explica se ilumina; 4) si se pide, la caja hace el paso ella
  sola con su animación (saltar). Nunca un dedo flotante ni un círculo brillante.
- **Riesgo de parecido.** Bajo: la máscara de Boxes es un objeto aparte; aquí es el carácter de la caja.

### 10. Un trazo como código
- **Sale de.** La cruz sagrada y el camino dorado de Tunic, donde un camino dibujado se convierte en una secuencia
  de direcciones (ficha 10); las formas que riman en Gorogoa (ficha 13).
- **Por qué funciona.** Convierte una imagen en un gesto; aprovecha la pantalla táctil; y se entiende de golpe
  cuando se ve.
- **En qué contexto.** Cerraduras sin llave (el cajón largo, El corazón).
- **Cómo transformarlo (H).** El orden de trazos de un kanji (目 «ojo», 角 «cuerno», 声 «voz»: los tres sellos del
  marcador) se traza con el dedo sobre la laca. El orden se aprende en el cuaderno del artesano, con los trazos
  numerados. La variable es el orden y la dirección de cada trazo.
- **Riesgo de parecido.** Bajo: nada de cruces de direcciones ni caminos dorados. Habrá que comprobar con
  jugadores no japoneses que el dibujo numerado basta.

### 11. Una fuente que miente con una regla que se aprende
- **Sale de.** Las notas rojas de Blue Prince, que mienten, y su juego del salón, con cajas que dicen verdad o
  mentira bajo reglas fijas (ficha 9). Para Tonda Ros, su juego trata de suposiciones que resultan equivocadas
  (ficha 9).
- **Por qué funciona.** Un tsukumogami es travieso: que mienta con una regla convierte la lectura en deducción y
  le da carácter.
- **En qué contexto.** Mitad de la línea, cuando el jugador ya confía en la caja.
- **Cómo transformarlo (H).** La caja tiene un tic cuando miente (el humo se riza, el ojo parpadea dos veces). Se
  enseña con un caso seguro; después, la caja «señala» cajones y hay que elegir según su tic.
- **Riesgo de parecido.** Medio si se copia el formato (tres cajas con frases escritas y reglas fijas); sin texto y
  con un tic: bajo.

### 12. La escala sin entrar en lo pequeño
- **Sale de.** El zoom dentro de cuadros y las capas de Gorogoa (ficha 13); el paseo en un carro diminuto y la
  maqueta de castillo de Boxes (ficha 7); el endoscopio de Machinika (ficha 6); el barquito de Myst que sube con el
  barco real (ficha 1); la rejilla-plano de Riven (ficha 2).
- **Por qué funciona.** Cambiar de escala asombra, y hace que lo pequeño importe en lo grande.
- **En qué contexto.** El usuario pide estudiarlo, pero The Room Three convirtió «entrar en lo pequeño» en su
  firma, y está prohibido.
- **Cómo transformarlo (B/F).**
  - La sombra como escala: la lámpara proyecta en el shoji la silueta de una pieza pequeña (el cuerno, la cajita
    roja); al acercar o alejar la lámpara, la sombra crece hasta encajar con un dibujo del shoji.
  - El reflejo como escala: la superficie del té refleja la cara de la caja en pequeño y del revés; lo que solo se
    lee en el reflejo se usa en la caja.
  - La caja pequeña como espejo de la grande (lo que haces en una pasa en la otra, como el barquito de Myst): es la
    más potente, pero roza las miniaturas.
- **Riesgo de parecido.** Sombra y reflejo: bajo-medio (los puzles de sombras son del género; The Witness también
  los usa). La caja espejo: medio-alto. Nunca la cámara dentro de una maqueta ni una lente.

---

## Descartes y avisos

- **Lentes y oculares que revelan capas** (*Oculi* de The House of Da Vinci, el aparato de Da Vinci 3, la lupa de
  Blue Prince): prohibidos. Lo oculto lo revela la mirada de la caja (ya decidido para el nivel 3).
- **Portales y viajes** (libros de Myst y Riven, portales de Da Vinci 2 y 3, la puerta-jardín de Gorogoa):
  prohibidos. Los «dos estados» del principio 7 los sustituyen.
- **Entrar en lo pequeño** (el carro de Boxes, el endoscopio de Machinika): prohibido. Ver el principio 12.
- **Ojos de madera que giran y suenan** (Riven): no usar, para que el único ojo del juego sea el de la caja.
- **Tres cajas con frases escritas** (Blue Prince): no copiar el formato; usar el tic de la caja (principio 11).
- **Lo que critican los jugadores y no hay que repetir:** escenas largas que no se saltan y zonas táctiles
  pequeñas (Da Vinci 3); puzles que quedan sin solución (Boxes); paneles que deshacen lo logrado al fallar (The
  Witness); información solo por color o solo por sonido (The Witness); textos con letra difícil (Da Vinci).
- **Alcance (scope creep):** el editor de cajas (Escape Simulator) y el modo de sofá (Keep Talking) son ideas de
  después del lanzamiento, no del MVP.
