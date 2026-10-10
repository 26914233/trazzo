# Bloque B · Lógica, perspectiva, física y puzle ambiental

**Juegos desmontados para La caja viva** · 05-10-2026 · investigación del género, bloque B.

Catorce juegos, y dentro de sus fichas *Monument Valley 2* y *Little Nightmares II*: *Portal*, *Portal 2*,
*The Talos Principle*, *The Talos Principle 2*, *Baba Is You*, *Q.U.B.E.*, *Antichamber*, *Superliminal*,
*Viewfinder*, *Monument Valley*, *Tetris*, *Inside*, *Limbo* y *Little Nightmares*.

**Qué hay aquí**
- Una ficha «DESMONTAR» por juego, con sus fuentes enlazadas al final de cada ficha.
- Al final, **«Lo mejor del bloque»**: las 12 ideas que más le sirven a La caja viva, con su letra (A-H) y su
  riesgo de parecido.
- La base de datos de mecánicas está en `juegos_B_mecanicas.csv` (96 filas, de B-001 a B-096).

**Marcas**
- **[Hecho, fuente]**: lo dice esa fuente; su enlace está en «Fuentes», al final de la ficha.
- **[Opinión, fuente]**: valoración de un crítico, un jugador o un autor.
- **[Interpretación]**: conclusión nuestra. Todas las propuestas para La caja viva lo son.
- Las citas literales van en inglés, entre comillas latinas y cortas. Lo demás está contado con nuestras palabras.

**Método y límites**
- Se buscaron primero fuentes primarias: los **comentarios de los desarrolladores** que vienen dentro de *Portal* y
  *Portal 2* (transcritos en Portal Wiki), postmortems, charlas de GDC resumidas por la prensa y entrevistas.
- No se pudieron ver vídeos completos (charlas de GDC, vídeos de Game Maker's Toolkit). Se usan sus
  descripciones oficiales o resúmenes publicados, y se dice cuando es así.
- Varias wikis de fans estaban cerradas. Los detalles de niveles salen de guías publicadas (Gamezebo, Gamepressure,
  Gamer Walkthroughs) y de reseñas. No se copian soluciones: solo lo necesario para entender el principio.
- La dificultad (1-5) del CSV es estimación nuestra.

**Cómo encaja con lo que ya hay**
- [Interpretación] La regla de La caja viva («no deja tocar mientras te ve») mezcla dos familias de este bloque:
  el **sigilo a la vista** (*Inside*, *Little Nightmares*) y la **regla que se puede invertir** (*Baba Is You*,
  *Little Nightmares II*). Por eso esos juegos pesan más en las conclusiones.
- Todo pasa por el control de originalidad (`../BIBLIA_DISENO.md`, anexo B): nada de portales, lentes u
  oculares, sustancia irisada ni «entrar en lo pequeño».

## Índice

| # | Juego | Año | Lo que más nos enseña |
|---|---|---|---|
| 1 | [Portal](#1-portal-valve-2007) | 2007 | Enseñar una regla sin que se pueda esquivar, y medirlo todo con pruebas |
| 2 | [Portal 2](#2-portal-2-valve-2011) | 2011 | Salas «de lista» y de combinación; feedback inmediato; sembrar la idea antes |
| 3 | [The Talos Principle](#3-the-talos-principle-croteam-2014) | 2014 | Pocas piezas con muchos usos; no linealidad contra el atasco |
| 4 | [The Talos Principle 2](#4-the-talos-principle-2-croteam-2023) | 2023 | Una zona, una mecánica; saltar un puzle con algo ganado explorando |
| 5 | [Baba Is You](#5-baba-is-you-hempuli-2019) | 2019 | La regla es un objeto que se ve y se cambia; diseñar hacia atrás |
| 6 | [Q.U.B.E.](#6-qube-toxic-games-2011) | 2011 | Un color, un verbo; y un aviso sobre copiar la estética |
| 7 | [Antichamber](#7-antichamber-alexander-bruce-2013) | 2013 | La confianza del jugador también se diseña |
| 8 | [Superliminal](#8-superliminal-pillow-castle-2019) | 2019 | Perspectiva y escala como reglas del mundo |
| 9 | [Viewfinder](#9-viewfinder-sad-owl-studios-2023) | 2023 | Una mecánica abierta necesita límites; rebobinar sin castigo |
| 10 | [Monument Valley (y 2)](#10-monument-valley-ustwo-games-2014-y-monument-valley-2-2017) | 2014 / 2017 | Una idea nueva por nivel; acciones «ruidosas» en pantalla táctil |
| 11 | [Tetris](#11-tetris-alexéi-pázhitnov-1984-1985) | 1984-1985 | La tarea incompleta engancha; pensar girando; azar justo |
| 12 | [Inside](#12-inside-playdead-2016) | 2016 | Sigilo a la vista y un ritmo que se oye |
| 13 | [Limbo](#13-limbo-playdead-2010) | 2010 | La solución correcta debe ser fácil de ejecutar |
| 14 | [Little Nightmares (y II)](#14-little-nightmares-tarsier-studios-2017-y-little-nightmares-ii-2021) | 2017 / 2021 | El vigilante visible; distraerlo; la amenaza como herramienta |
| — | [Lo mejor del bloque](#lo-mejor-del-bloque-12-principios-para-la-caja-viva) | | Las 12 ideas más transferibles |

**Cómo se leen las tablas de puzles:** las filas «Qué lo hace difícil» y «Qué lo hace satisfactorio» son
[Interpretación] salvo que lleven otra marca. La fuente de cada puzle está en su última fila.

---

## 1. Portal (Valve, 2007)

**En una frase:** un arma que abre dos agujeros enlazados en las paredes convierte cada sala en un problema de
espacio. [Interpretación]

- **Género y año.** Puzle en primera persona con física, de 2007 [Hecho, Eurogamer P2]. Nació de *Narbacular
  Drop*, un proyecto de estudiantes [Hecho, Comentario 00].
- **Core loop.** Entrar en una sala de pruebas → leer la sala (salida, botones, paredes válidas) → colocar dos
  portales → mover tu cuerpo o un objeto → abrir la salida → ascensor. El campo que borra portales y el ascensor
  marcan sin dudas el final de cada sala [Hecho, Comentario 03].
- **Verbos.** Disparar el portal azul o el naranja, andar, saltar, caer, coger, soltar y pulsar.
- **Mecánicas.** Portales enlazados que conservan la velocidad (el «lanzamiento»), cubo sobre botón, superficies
  que no aceptan portal, bolas de energía que se redirigen, campos que borran portales y objetos, plataformas que
  se mueven y torretas [Hecho, Comentario].

### Los mejores puzles

| | **A. El primer portal** (sala 00) | **B. El lanzamiento** (salas 10-15) | **C. El cubo de compañía** (sala 17) |
|---|---|---|---|
| **Qué ve el jugador** | Una sala muy reconocible, con una radio que suena, y un portal ya abierto | Un bloque de hormigón que sobresale encima de un foso con suelo de damero | Un cubo con corazones en una sala con bolas de energía |
| **Qué debe descubrir** | Que el portal es un agujero dentro del mismo sitio, no la puerta a otro mundo | Que al caer en un portal sales por el otro con la misma velocidad | Que el cubo es un escudo; después, que hay que meterlo en el incinerador |
| **Qué manipula** | Su posición | La altura de la caída y el sitio del portal de salida | El cubo: llevarlo con él |
| **Reglas** | Lo que entra por un portal sale por el otro | La velocidad se conserva | El cubo para la bola; el incinerador destruye |
| **Qué lo hace difícil** | La idea es nueva: en *Narbacular Drop* la gente creía que el portal llevaba a otra dimensión [Hecho, Comentario 00] | «Portal momentum ended up being the hardest concept to convey» [Hecho, Comentario 10] | Muchos probadores leían la sala como «esquivar la bola» y abandonaban el cubo [Hecho, Comentario 17] |
| **Qué lo hace satisfactorio** | Verse a uno mismo a través del portal: así lo entendían mucho antes [Hecho, Comentario 00] | Salir disparado: la física se siente en el cuerpo | El apego: «playtesters went from routinely abandoning the box to never wanting it to leave their side» [Hecho, Comentario 17] |
| **Feedback** | Tu propia figura; la radio suena igual a los dos lados | El vuelo y el aterrizaje; la señal del bloque se repite varias veces | La voz que habla del cubo sin parar; la escena de despedida |
| **Recompensa** | Entender el mundo | Llegar lejos. Después, la señal desaparece: «we take the training wheels off» [Hecho, Comentario 15] | La escena enseña a usar el incinerador, que hace falta en el final [Hecho, Comentario 17] |
| **Fuente** | [Hecho, Comentario 00] | [Hecho, Comentario 10, 12 y 15] | [Hecho, Comentario 17] |

### Cámara
- Primera persona.
- [Hecho, Comentario 14] La luz guía la vista: una luz cálida sobre el cubo, contra la luz fría de la sala, y
  sombras que apuntan hacia él.
- [Hecho, Comentario 09] Los objetos redondos son los que importan; los angulosos son fondo.
- [Hecho, Comentario, Huida 2] «without some serious prompting, players will rarely look up»: usaron una escalera
  que se rompe al tocarla, y en la sala 10 pusieron las superficies del portal de salida en pistones que empiezan a
  la vista.

### Feedback, animación y sonido
- [Hecho, Comentario 02] Una «pausa obligatoria» con partículas y un ruido fuerte para que se vea qué crea los
  portales.
- [Hecho, Comentario 11] Un tictac mientras la puerta está abierta dice «actúa ahora».
- [Hecho, Comentario 01] Un portal que se cierra nunca te mata: te empuja fuera. El jugador debe sentirse seguro.
- [Hecho, Comentario, Huida 3] Quitaron la voz de los lanzacohetes: la señal sonora tenía que ser «distinct,
  uncluttered».
- [Hecho, Comentario 05] Quitaron el desorden de los escenarios: los objetos de más estorbaban el aprendizaje.
- [Hecho, Comentario, Huida 4] Unas pasarelas decorativas atraían tanto a los probadores que las hicieron
  necesarias para avanzar.

### Narrativa
- [Hecho, Comentario, Huida 1] Una voz artificial (GLaDOS) comenta las pruebas: primero, monótona; después, cada vez
  más emotiva.
- [Hecho, Comentario 16] Hay historia escondida en el entorno, como la guarida de alguien atrapado.
- [Hecho, Comentario 13] Las salas limpias contrastan con lo que hay detrás del decorado, y eso da sensación de avance.

### Dificultad y aprendizaje
- [Hecho, Comentario 00] «Portal is effectively an extended player training exercise»: presenta herramientas y las
  va apilando. Primero cubo y botón; luego, portales.
- [Hecho, Comentario 01] La sala 01 está hecha para que ir a tientas «will virtually always lead to a dead end»: hay
  que cruzar al menos cinco portales en orden. Así se igualó la curva de aprendizaje.
- [Hecho, Comentario 04] Al principio hay una sola solución: pusieron un cristal para impedir un atajo que se
  saltaba la lección. Más tarde, las salas se abren.
- [Hecho, Comentario 08 y 15] Si una sala traía demasiadas cosas nuevas, se partía: «Overwhelmed players tend not to
  digest new information».
- [Hecho, Comentario 10] En el lanzamiento, la voz explica los elementos, algo que evitaron en el resto del juego.
- [Hecho, Comentario 12] Tras un concepto grande se olvida lo anterior: una sala vuelve a enseñar el lanzamiento.
- [Hecho, Comentario 14] Si un atajo cuesta más que la solución, lo dejaron («solución ninja»).
- [Hecho, Comentario, Huida 2] El cansancio aparecía si no se cortaban los puzles lentos con tareas simples con
  algo de prisa.
- [Hecho, GMTK] Probaron con jugadores desde la primera semana y casi cada semana, mirando en silencio.

### Lo que valoran y lo que critican
- [Opinión, Eurogamer P2] Su claridad y su economía: una idea desarrollada «exactly as far as it needed to go and no
  further».
- [Opinión, Destructoid] La duración: las primeras 13 o 14 salas se pasan en menos de una hora.

### Principios para La caja viva
1. **Un paso que no se puede pasar sin entender (A).** Como la sala 01: en el nivel 1, coger la llave solo debe ser
   posible con el ojo distraído. Hay que comprobar con la prueba automática, tocando al azar, que no sale por
   casualidad (por ejemplo, durante la animación del ojo). [Interpretación]
2. **Una señal que se repite y después se retira (B).** Como el bloque del lanzamiento: un motivo propio (la muesca
   para la uña = esto corre) que aparece con ayuda en los niveles 1 y 2, y sin ayuda en el 3. [Interpretación]
3. **Si un adorno parece importante, o se apaga o se vuelve importante (A).** Como las pasarelas. La decoración viva
   (polillas, tetera, ondas del té) debe reaccionar de forma claramente ambiental. Si en las pruebas alguien
   insiste en un adorno, se convierte en paso o se le quita el brillo. [Interpretación]

### Riesgo de parecido
Bajo si se usan solo los principios. Los portales están prohibidos (anexo B). La voz burlona tampoco: nuestra caja
no habla con voz. [Interpretación]

### Fuentes
- **Comentario:** [Valve, comentario de desarrolladores de *Portal*, transcrito en Portal Wiki](https://theportalwiki.com/wiki/Portal_developer_commentary)
- **GMTK:** [Mark Brown, «Valve's Secret Weapon», Game Maker's Toolkit](https://gmtk.substack.com/p/valves-secret-weapon)
- **Destructoid:** [Aaron Linde, reseña de *Portal* (9/10)](https://www.destructoid.com/destructoid-review-portal/)
- **Eurogamer P2:** [Oli Welsh, reseña de *Portal 2* (2011), que empieza valorando *Portal*](https://www.eurogamer.net/portal-2-review)

---

## 2. Portal 2 (Valve, 2011)

**En una frase:** *Portal* con más piezas (láseres, puentes de luz, embudos, geles) y una campaña cooperativa.
[Interpretación]

- **Género y año.** Puzle en primera persona de 2011, con campaña individual y cooperativa para dos [Hecho,
  Wikipedia P2; Eurogamer].
- **Core loop.** El de *Portal*, con elementos que viajan a través de los portales (láser, puente de luz, embudo) y
  geles que cambian las superficies [Hecho, Wikipedia P2]. Entre salas hay «experiencias» sin puzle para descansar
  [Hecho, Wikipedia P2].
- **Verbos.** Disparar portales; coger, llevar y entregar objetos; redirigir un láser con un cubo-prisma; pintar
  con gel; saltar en placas de lanzamiento. En cooperativo, señalar, iniciar una cuenta atrás y hacer gestos
  [Hecho, Wikipedia P2].
- **Mecánicas.** Láser y cubo de redirección; puente de luz sólida; embudo de excursión, que lleva o trae; placa de
  lanzamiento; gel de repulsión (rebote), de propulsión (velocidad) y de conversión (cualquier superficie admite
  portal); el agua limpia el gel [Hecho, Wikipedia P2]. Además, se pueden pintar objetos para cambiar cómo se
  mueven [Hecho, Comentario P2].

### Los mejores puzles

| | **A. La rejilla que borra portales** («Fizzler Intro») | **B. El embudo y la escena que enseña antes** («Repulsion Polarity») | **C. La doble colisión** (cooperativo) |
|---|---|---|---|
| **Qué ve el jugador** | Una rejilla luminosa y, encima, un cristal con un solo agujero a la altura de los ojos | Un embudo de excursión que parece el camino | Una sala simétrica |
| **Qué debe descubrir** | Que hay que disparar un portal por el agujero, por encima de la rejilla | Que la solución no es el embudo, sino la pistola: portal en el suelo, salida en la pared | Que los dos robots, lanzados a la vez, pueden chocar en el aire |
| **Qué manipula** | Dónde y desde qué lado dispara | Los portales | El momento y la trayectoria de los dos |
| **Reglas** | La rejilla borra portales y destruye los objetos que la cruzan; el jugador pasa | Lo que entra por un portal sale por el otro | Física compartida por dos jugadores |
| **Qué lo hace difícil** | La primera versión (dos rejillas, tres zonas) casi nadie la resolvía [Hecho, Comentario P2] | Los probadores se obsesionaban con el elemento nuevo y olvidaban que tenían la pistola [Hecho, Comentario P2] | «one of Portal’s trickiest logical leaps»: la gente perdía la paciencia [Hecho, Comentario P2] |
| **Qué lo hace satisfactorio** | La versión final deja disparar desde los dos lados [Hecho, Comentario P2] | Reconocer una idea que ya usaste | Casi todos lo citaban como su momento favorito del cooperativo [Hecho, Comentario P2] |
| **Feedback** | Rediseñaron la rejilla porque nadie la notaba: brillos de agua de piscina (no amenaza), destellos al chocar un portal y un remolino que crece cuando un objeto se acerca [Hecho, Comentario P2] | Justo antes, una destrucción del escenario obliga a cruzar un hueco así; la sala presenta «the exact same scenario, but in a different context» [Hecho, Comentario P2] | La luz, la simetría y las marcas de la sala dibujan la trayectoria [Hecho, Comentario P2] |
| **Recompensa** | La salida y una regla bien entendida | Avanzar | El «¡ajá!» es del jugador: una sala que enseñaba la colisión «almost completely robbed the appeal», y la quitaron; en su lugar «sembraron» trozos de la idea cuatro salas antes [Hecho, Comentario P2] |
| **Fuente** | [Hecho, Comentario P2] | [Hecho, Comentario P2] | [Hecho, Comentario P2] |

### Cámara
- Primera persona. La parte central del juego pasa en espacios enormes con pocas paredes válidas, para obligar a
  cruzar de forma creativa [Hecho, Wikipedia P2].

### Feedback, animación y sonido
- [Hecho, Wikipedia P2] Cambiaron las bolas de energía por láseres porque el láser da feedback inmediato.
- [Hecho, Comentario P2] El sonido del gel azul: la primera versión (pelota, arpa) era demasiado de broma; la final,
  una barra de metal que rebota como un trampolín.
- [Hecho, Comentario P2] El Aperture viejo y el nuevo suenan distinto: metal y madera que se pudren frente a lo
  inestable.
- [Hecho, Comentario P2] La luna: con el retraso realista de 1,4 segundos, la gente se giraba creyendo que no había
  pasado nada; cambiaron la solución.

### Narrativa
- [Hecho, Comentario P2] GLaDOS era más cruel al principio; las pruebas mostraron que cansaba y la suavizaron.
- [Hecho, Comentario P2] Para el combate final enseñan a romper tuberías de gel un nivel antes, sin prisa.
- [Hecho, Comentario P2] Sorpresa: cuando el jugador ya domina las placas de lanzamiento, Wheatley lo lanza de lado.

### Dificultad y aprendizaje
- [Hecho, Wikipedia P2] No querían hacerlo más difícil: querían que el jugador se sintiera listo.
- [Hecho, Wikipedia P2; Game Informer] Dos tipos de sala: «de lista» (*checklisting*: probar un concepto nuevo sin
  riesgo) y de combinación (pensar de lado).
- [Hecho, Comentario P2] El «¡ajá!» es frágil: si es fácil, te lo roban; «If it's too hard then players feel stupid
  instead of smart».
- [Hecho, Comentario P2] En cooperativo probaron un centro con salas a elegir y lo quitaron: sin un orden no podían
  garantizar lo aprendido.
- [Hecho, Comentario P2] Un tramo del embudo es «a prueba de fallos»: si disparas el portal equivocado, el juego
  mueve el otro para salvarte.
- [Hecho, Comentario P2] Tras muchas salas complejas, un viaje largo por un embudo sirve de descanso.

### Lo que valoran y lo que critican
- [Opinión, Eurogamer] 10/10: comedia excelente; pero más hablador que el primero y con ideas que no funcionan
  igual de bien.
- [Opinión, Gamecritics] Sparky Clarkson: «I felt much more like I was trying to guess the designer's solution than
  coming up with my own». Con una sola herramienta, el primero era más creativo.

### Principios para La caja viva
1. **Feedback continuo que crece al acercarse (B).** Como el remolino de la rejilla: el ojo entorna el párpado según
   se acerca el dedo a lo prohibido, antes de contener el aliento. [Interpretación]
2. **Enseñar la idea fuera del puzle, justo antes (B).** En el nivel 2, la caja hija podría girar sola al subir, y el
   ojo grande perdería de vista una de sus caras: el jugador ya habría visto la idea. En el nivel 3 propuesto, el
   ojo mira una polilla y la deja quieta en el aire antes de que haga falta usar su mirada. [Interpretación]
3. **Una sola herramienta (A).** Valve renunció a una pistola de pintura para no enseñar otra herramienta [Hecho,
   Comentario P2]. La caja viva mantiene el dedo como única herramienta: nada de lupas, linternas ni pistolas.
   [Interpretación]

### Riesgo de parecido
Bajo. No se usan geles, puentes de luz ni embudos tal cual. [Interpretación]

### Fuentes
- **Comentario P2:** [Valve, comentario de desarrolladores de *Portal 2*, transcrito en Portal Wiki](https://theportalwiki.com/wiki/Portal_2_developer_commentary)
- **Wikipedia P2:** [*Portal 2*, Wikipedia (diseño y modo cooperativo)](https://en.wikipedia.org/wiki/Portal_2)
- **Game Informer:** [«Thinking With Portals: Making A Test Chamber» (2010)](https://gameinformer.com/b/features/archive/2010/03/17/thinking-with-portals-making-a-test-chamber)
- **Eurogamer:** [Oli Welsh, reseña de *Portal 2* (10/10)](https://www.eurogamer.net/portal-2-review)
- **Gamecritics:** [Sparky Clarkson, «A Few Thoughts on Portal 2»](https://gamecritics.com/sparky-clarkson/a-few-thoughts-on-portal-2/)

---

## 3. The Talos Principle (Croteam, 2014)

**En una frase:** más de 120 puzles en recintos cerrados, resueltos con muy pocas piezas, dentro de una historia
filosófica. [Hecho, Wikipedia]

- **Género y año.** Puzle en primera persona (o tercera), del 11-12-2014 [Hecho, Wikipedia]. Nació mientras
  Croteam probaba objetos interactivos para *Serious Sam 4*, a partir del «inhibidor» [Hecho, PC Gamer GDC].
- **Core loop.** Entrar en un recinto → conseguir su sigilo (una pieza con forma de tetrominó) → con varios
  sigilos, resolver un puzle de encaje que abre puertas o da herramientas nuevas [Hecho, Wikipedia]. Si te matan
  (drones, torretas), vuelves al principio de ese puzle [Hecho, Wikipedia].
- **Verbos.** Coger y dejar, apuntar un aparato, apilar, grabar y reproducir, encajar piezas.
- **Mecánicas.** Inhibidores (apagan campos de fuerza, drones y torretas), conectores que llevan rayos de luz a
  interruptores, hexaedros (subir, bloquear), ventiladores (lanzar), grabadora (una copia de ti repite lo
  grabado), estrellas (soluciones únicas) y mensajeros (una pista de un solo uso por puzle) [Hecho, Wikipedia].

### Los mejores puzles

No se encontraron análisis de salas concretas; se describen tres **tipos** de puzle a partir de Wikipedia y de las
reseñas.

| | **A. La grabadora** | **B. Las estrellas** | **C. Las cerraduras de tetrominós** |
|---|---|---|---|
| **Qué ve el jugador** | Un interruptor que hay que mantener y un aparato de grabación | Una estrella a la vista, aparentemente fuera de alcance | Una plantilla y las piezas ganadas |
| **Qué debe descubrir** | Que la copia grabada puede sostener el interruptor mientras él hace otra cosa | Una solución distinta de la del puzle [Hecho, Wikipedia], que pide pensar «even more abstract» [Opinión, PCWorld] | Cómo encajan las piezas |
| **Qué manipula** | Lo que hace durante la grabación, y cuándo | Los objetos del puzle, usados de otra forma | El giro y el sitio de cada pieza |
| **Reglas** | La copia repite tus actos y se puede interactuar con ella [Hecho, Wikipedia] | Las mismas del puzle | Teselado: no pueden sobrar huecos |
| **Qué lo hace difícil** | Pensar en dos líneas de tiempo a la vez | Para el reseñista, «They're hard» [Opinión, PCWorld] | Poco: es un trámite |
| **Qué lo hace satisfactorio** | Colaborar con uno mismo | Saberse más listo que el puzle | Al principio, cerrar el ciclo de recompensa |
| **Feedback** | La copia repite tus gestos | La estrella al alcance | Las piezas encajan y la puerta se abre |
| **Recompensa** | El sigilo | Puzles extra [Hecho, Wikipedia] | Puertas y herramientas nuevas; Andrew Plotkin cuenta unas 111 cerraduras y las ve como relleno repetido [Opinión, Plotkin] |
| **Fuente** | [Hecho, Wikipedia] | [Hecho, Wikipedia; Opinión, PCWorld] | [Hecho, Wikipedia; Opinión, Plotkin] |

### Cámara
- Primera persona (o tercera) [Hecho, Wikipedia]. Cada puzle es un espacio cerrado, como una sala de pruebas de
  *Portal* al aire libre [Opinión, Eurogamer].

### Feedback, animación y sonido
- [Opinión, Eurogamer] Las piezas van «colour-coded and clear of clutter» (con código de color y sin desorden).
- [Opinión, Eurogamer] Las herramientas están en el propio escenario, no en un inventario: siempre sabes qué
  necesitas y cuántas tienes.

### Narrativa
- [Hecho, Wikipedia] Una voz divina (Elohim), terminales con un programa que discute de filosofía y mensajes de
  otros robots.
- [Hecho, Wikipedia] Los guionistas, Tom Jubert y Jonas Kyratzes, llegaron con el 80 % de los puzles ya hechos.

### Dificultad y aprendizaje
- [Opinión, Eurogamer] No hay tutorial: «like a child with a set of building blocks you learn through play».
- [Hecho, PC Gamer GDC] Cada miembro del equipo diseñaba puzles; los demás los probaban y los puntuaban por diversión
  y dificultad.
- [Hecho, PC Gamer GDC] Como en las pruebas la gente se atascaba, el juego pasó a ser no lineal: siempre hay varios
  puzles a mano. Las pruebas externas quitaron puzles redundantes y acortaron una zona.
- [Hecho, Wikipedia] Un bot jugaba cada versión entera (de 30 a 60 minutos) y avisaba de callejones sin salida;
  Croteam calcula unas 15.000 horas de pruebas con él.
- [Opinión, PCWorld] Atascarse veinte minutos, irse a otro puzle y volver con la idea es parte de la gracia.

### Lo que valoran y lo que critican
- [Opinión, PCWorld] «There are very few puzzle mechanics in The Talos Principle—maybe six objects overall», pero
  siempre aparecen usos nuevos.
- [Opinión, PCWorld] Al final, algunos puzles parecen trámite; perder obliga a empezar el puzle de nuevo.
- [Opinión, Plotkin] Demasiado largo; el reto final, con tiempo y sin guardado intermedio, obliga a repetir lo ya
  resuelto.
- [Hecho, Wikipedia] Metacritic 85 (PC) y 88 (PS4).

### Principios para La caja viva
1. **Pocas piezas, muchos usos (A).** La llave del nivel 1 que vuelve en el nivel 3 ya lo hace. Que la lámpara y el
   espejo tengan también al menos dos usos en la línea. [Interpretación]
2. **Herramientas a la vista (A).** Todo lo que sirve en un nivel se ve en la escena antes de usarlo; el inventario
   solo guarda lo ya cogido. [Interpretación]
3. **Varias tareas abiertas a la vez (B).** Dos ramas abiertas por nivel cuando se pueda (el nivel 3 propuesto ya va
   así), para que un atasco no pare el juego. [Interpretación]
4. **Un bot que juega cada versión (A).** Ya existe `ilustrada/prueba/jugar.mjs`; se le puede añadir un modo que
   toque al azar para buscar atajos, como el bot de Croteam. [Interpretación]

### Riesgo de parecido
Bajo. Si algún día hay un puzle de encajar piezas, nada de tetrominós: formas de marquetería *yosegi*.
[Interpretación]

### Fuentes
- **Wikipedia:** [*The Talos Principle*, Wikipedia (juego y desarrollo)](https://en.wikipedia.org/wiki/The_Talos_Principle)
- **PC Gamer GDC:** [Wes Fenlon, «The Talos Principle started as Serious Sam 4», resumen del postmortem de GDC 2015 «Reactive Game Development»](https://www.pcgamer.com/the-talos-principle-started-as-serious-sam-4/)
- **Eurogamer:** [Stace Harman, reseña de *The Talos Principle*](https://www.eurogamer.net/the-talos-principle-review)
- **PCWorld:** [Hayden Dingman, «The Talos Principle review: The best puzzler since Portal»](https://www.pcworld.com/article/436743)
- **Plotkin:** [Andrew Plotkin, «The Talos Principle: design ruminations»](https://blog.zarfhome.com/2014/12/the-talos-principle-design-ruminations)

---

## 4. The Talos Principle 2 (Croteam, 2023)

**En una frase:** la secuela ordena la variedad: cada zona presenta una mecánica, la enseña en orden y la combina.
[Interpretación]

- **Género y año.** Puzle en primera persona, del 2-11-2023, hecho con Unreal Engine 5 [Hecho, Wikipedia T2].
- **Core loop.** Doce zonas. En cada una, ocho puzles obligatorios (llegar a un botón encerrado), dos opcionales más
  difíciles y secretos; al terminar, un puzle de piezas tipo *Tetris* tiende un puente hacia el centro de la zona
  [Hecho, Wikipedia T2; PC Gamer T2].
- **Verbos.** Coger y colocar, apuntar rayos, cambiar de cuerpo, teletransportarse, abrir agujeros en paredes.
- **Mecánicas nuevas.** Conversores RGB (rayo azul y rojo dan verde), inversores de rayo, acumuladores (fuentes de
  rayo portátiles), taladros que abren agujeros temporales en paredes especiales, cuerpos alternativos entre los
  que se salta si están a la vista, teletransportadores y rayos antigravedad [Hecho, Wikipedia T2; PC Gamer T2].
  Desaparecen las minas y las torretas [Hecho, PC Gamer T2].

### Los mejores puzles

No se encontraron análisis de salas concretas; se describen tres tipos de puzle a partir de la reseña de PC Gamer:

| | **A. El conversor** | **B. Los cuerpos alternativos** | **C. El taladro** |
|---|---|---|---|
| **Qué ve el jugador** | Emisores de dos colores y un receptor de un tercero | Otro cuerpo, inactivo, al otro lado de una barrera | Una pared especial entre un objeto y su destino |
| **Qué debe descubrir** | Que hay que mezclar los rayos | Que puede saltar al otro cuerpo para estar en dos sitios | Que el agujero dura poco y hay que preparar lo que pasará por él |
| **Qué manipula** | Qué rayos entran al conversor | Desde dónde ve el otro cuerpo | El momento y lo que cruza |
| **Reglas** | Azul y rojo dan verde [Hecho, PC Gamer T2] | Solo se salta si hay línea de visión [Hecho, PC Gamer T2] | Agujero temporal en paredes especiales, por el que pasan objetos o rayos [Hecho, PC Gamer T2] |
| **Qué lo hace difícil** | Pensar en colores además de en caminos | Pensar desde dos posiciones a la vez | Ordenar los pasos antes de abrir |
| **Qué lo hace satisfactorio** | La mezcla correcta enciende algo lejos | Estar en dos sitios a la vez | El paso justo a tiempo |
| **Feedback** | El color del rayo cambia | La cámara salta al otro cuerpo | El agujero se abre y se cierra a la vista |
| **Recompensa** | El botón del puzle | Ídem | Ídem |
| **Fuente** | [Hecho, PC Gamer T2] | [Hecho, PC Gamer T2] | [Hecho, PC Gamer T2] |

### Cámara, feedback y narrativa
- Primera persona; zonas abiertas que se recorren libremente y puzles construidos dentro del paisaje [Opinión,
  PC Gamer T2].
- Rayos con código de color que deben llegar a receptores del mismo color [Hecho, PC Gamer T2].
- Una civilización de robots con la que se habla; la narración pesa casi tanto como los puzles [Opinión, PC Gamer T2].

### Dificultad y aprendizaje
- [Opinión, PC Gamer T2] Cada aparato se presenta poco a poco y bien enseñado si se hacen los puzles en su orden
  numerado; luego se combina. Casi cada pareja de aparatos tiene una sinergia interesante.
- [Hecho, eXputer] Croteam buscó una progresión en la que los nuevos aprendan y los veteranos no se aburran.
  Probadores humanos jugaban a diario y encontraban soluciones no previstas.
- [Hecho, TechRadar] Fuego de Prometeo: sirve para saltar un puzle demasiado difícil; se recupera si luego lo
  resuelves, y está escondido por el mapa. Croteam: «I think this title is more accessible» y «We wanted to give
  players more choice to play the game they wanted to play».
- [Opinión, Steam] Varios jugadores lo ven más fácil que el primero: sin minas (dificultad de ejecución) y con
  clones en lugar de grabadora (sin cálculo de tiempos).

### Lo que valoran y lo que critican
- [Opinión, PC Gamer T2] 89/100. Su única queja: el puzle de piezas de los puentes mejora las cerraduras del primero
  pero sigue siendo «still not that interesting».
- [Hecho, Wikipedia T2] Metacritic entre 85 y 90 según la plataforma.

### Principios para La caja viva
1. **Una zona, una idea, en orden (A).** Cada nivel trae una idea estructural nueva (ya está en
   `ilustrada/NIVELES.md`); la tarjeta de nivel puede nombrarla. [Interpretación]
2. **Saltar un paso con algo ganado explorando (G).** «Ofrendas» escondidas en la sala (un dulce, una moneda) que,
   dejadas ante la caja, la convencen de enseñar el paso siguiente; se recuperan al resolverlo. Encaja con un
   *tsukumogami*. Para cuatro niveles quizá basta con las pistas: es opcional. [Interpretación]
3. **Quitar la dificultad de ejecución (A).** Ningún paso pide precisión ni rapidez de dedo: la dificultad está en
   entender. [Interpretación]

### Riesgo de parecido
Bajo. [Interpretación]

### Fuentes
- **Wikipedia T2:** [*The Talos Principle 2*, Wikipedia](https://en.wikipedia.org/wiki/The_Talos_Principle_2)
- **PC Gamer T2:** [Dominic Tarason, reseña de *The Talos Principle 2* (89/100)](https://www.pcgamer.com/the-talos-principle-2-review/)
- **TechRadar:** [«The Talos Principle 2 makes puzzle-solving easier with skippable levels»](https://www.techradar.com/gaming/consoles-pc/the-talos-principle-2-makes-puzzle-solving-easier-with-skippable-levels)
- **eXputer:** [Entrevista a Croteam sobre *The Talos Principle 2*](https://exputer.com/interviews/the-talos-principle-2-interview/)
- **Steam:** [Hilo de jugadores «Talos Principle 2 Review»](https://steamcommunity.com/app/835960/discussions/0/4136060714895132274)

---

## 5. Baba Is You (Hempuli, 2019)

**En una frase:** las reglas del nivel están escritas con bloques de palabras que se empujan, y cambiar una frase
cambia el mundo. [Hecho, Wikipedia]

- **Género y año.** Puzle por turnos de empujar bloques, del 13-03-2019, de Arvi Teikari (Hempuli) [Hecho,
  Wikipedia]. Nació en la Nordic Game Jam de 2017 con el tema «Not There» [Hecho, Wikipedia; MCV].
- **Core loop.** Leer las reglas escritas en el nivel → empujar palabras para cambiar o romper reglas → llegar a lo
  que «ES GANAR», o hacer que algo lo sea [Hecho, Wikipedia; PC Gamer].
- **Verbos.** Moverse (y así empujar), deshacer y reiniciar [Hecho, PC Gamer].
- **Mecánicas.** Tres o más palabras alineadas forman una regla (sustantivo + ES + propiedad: TÚ, EMPUJAR, PARAR,
  GANAR); operadores Y, NO y TIENE [Hecho, Wikipedia; PC Gamer].

### Los mejores puzles

| | **A. La sala amurallada** (de los primeros niveles) | **B. TIENE para cruzar un río** | **C. El nivel nacido de un atajo** |
|---|---|---|---|
| **Qué ve el jugador** | Baba encerrado en una sala con MURO ES PARAR; las palabras de BANDERA ES GANAR, sin alinear [Hecho, PC Gamer] | La palabra TIENE (un objeto contiene a otro) y un río | Un nivel parecido a uno ya resuelto |
| **Qué debe descubrir** | Que separar una palabra rompe la regla: el muro deja de parar | Que un objeto puede llevar otro dentro | Que el atajo de antes está cerrado y queda otra idea |
| **Qué manipula** | La posición de las palabras | Las frases con TIENE | Las palabras |
| **Reglas** | Tres palabras en línea forman una regla activa | TIENE: un objeto contiene a otro [Hecho, PC Gamer] | Las mismas, con una pieza menos |
| **Qué lo hace difícil** | Nada: enseña | Pensar en contenidos, no en posiciones | Desaprender la solución fácil |
| **Qué lo hace satisfactorio** | Hay al menos tres salidas: BANDERA ES GANAR, MURO ES GANAR y BABA ES GANAR [Hecho, PC Gamer] | Para la reseñista fue «a low-key moment of real joy» [Opinión, PC Gamer] | Ver la idea de otro jugador convertida en puzle |
| **Feedback** | El mundo cambia al instante | La fuente no lo detalla (no se describe la solución) | La solución vieja ya no cabe |
| **Recompensa** | Entender el sistema | Avanzar en el mapa | Un nivel con una idea limpia |
| **Fuente** | [Hecho, PC Gamer] | [Opinión, PC Gamer] (sin detallar la solución) | Un probador encontró una solución que Teikari no quería en el nivel original: «But I liked it so much that I wanted to dedicate a new level to that solution alone» [Hecho, MCV] |

### Cámara, feedback y sonido
- Pantalla fija con todo el nivel a la vista; estética simple que funciona mejor en los niveles sencillos [Opinión,
  PC Gamer].
- Se puede deshacer paso a paso o reiniciar; también ver la lista de reglas activas en la pausa [Hecho, PC Gamer].

### Narrativa
- Casi ninguna: el mapa de mundos es el hilo [Interpretación].

### Dificultad y aprendizaje
- [Hecho, Road to the IGF] Teikari parte de «cool or amusing combinations/interactions between the words» y diseña
  hacia atrás el nivel que obliga a usarlas.
- [Hecho, Road to the IGF] «it's extremely easy to be blind to certain types of unintended solutions»: los
  probadores fueron clave.
- [Hecho, MCV] Las prioridades entre reglas son complicadas por dentro, y los niveles están hechos para que el
  jugador no tenga que entenderlas.
- [Hecho, MCV] Trabajando solo, perdió la noción de la dificultad y ajustó para hacerlo más accesible.
- [Opinión, GMTK vía notas] Sin tutorial: los niveles sencillos enseñan cada palabra y las mecánicas llegan poco a
  poco (resumen público del vídeo; no se pudo ver el original).

### Lo que valoran y lo que critican
- [Opinión, PC Gamer] 90/100. Enseña a leer los niveles: «commands jammed into a corner can't be moved so they act
  as basic truths for the scene». Curva irregular al principio; con muchas reglas a la vez cuesta seguirlas.
- [Opinión, Game Informer, citado en Wikipedia] La suma de variables lo vuelve «exhausting and unsatisfying» al final.
- [Opinión, GameSpot, citado en Wikipedia] Los últimos puzles resultan exasperantemente oscuros.
- [Hecho, Wikipedia] Premio a la excelencia en diseño del IGF de 2018.

### Principios para La caja viva
1. **La regla es un objeto (H).** Para el final «El corazón»: la regla de la caja tallada en tres pictogramas de
   marquetería (ojo · mira · mano) que giran en su sitio; cambiar uno cambia a quién vigila o qué detiene. Coste de
   diseño alto: solo para el final. [Interpretación]
2. **Diseñar hacia atrás desde un truco (A).** Cada paso nace de un truco (esconder una cara al ojo girando la caja)
   y se le añaden límites hasta que sea la única salida. Es como se hizo el nivel 2. [Interpretación]
3. **Verdades fijas a la vista (A).** Unas pocas cosas nunca se mueven y se nota (laca negra): acotan lo que hay que
   probar. [Interpretación]
4. **Los atajos bonitos se vuelven pasos (B).** Apuntar en las pruebas las soluciones no previstas; si una gusta, se
   hace paso o secreto y se cierra donde estorba. [Interpretación]

### Riesgo de parecido
Medio si se hacen fichas con palabras que se empujan. Bajo con pictogramas tallados que giran en su sitio.
[Interpretación]

### Fuentes
- **Wikipedia:** [*Baba Is You*, Wikipedia](https://en.wikipedia.org/wiki/Baba_Is_You)
- **Road to the IGF:** [Game Developer, «Road to the IGF: Hempuli Oy's Baba Is You»](https://www.gamedeveloper.com/business/road-to-the-igf-hempuli-oy-s-i-baba-is-you-i-)
- **MCV:** [«When we made... Baba Is You»](https://mcvuk.com/development-news/when-we-made-baba-is-you/)
- **PC Gamer:** [Philippa Warr, reseña de *Baba Is You* (90/100)](https://www.pcgamer.com/baba-is-you-review/)
- **GDC 2020:** [Arvi Teikari, «Understanding the rules of Baba Is You» (vídeo; solo se leyó la descripción)](https://www.gamedeveloper.com/design/video-understanding-the-rules-of-i-baba-is-you-i-)
- **GMTK vía notas:** [Notas públicas sobre diseño de puzles con resúmenes de vídeos de GMTK](https://notes.hamatti.org/Gaming/Puzzle-game-design)

---

## 6. Q.U.B.E. (Toxic Games, 2011)

**En una frase:** salas blancas con bloques de colores; cada color hace siempre lo mismo. [Hecho, Wikipedia]

- **Género y año.** Puzle en primera persona, del 17-12-2011 (Windows); un *Director's Cut* de 2014 añadió una
  historia escrita por Rob Yescombe [Hecho, Wikipedia]. Empezó como proyecto de estudiantes en la Universidad de
  Newport [Hecho, Wikipedia].
- **Core loop.** Entrar en una sala → activar bloques de colores con unos guantes → construir el camino a la salida
  [Hecho, Wikipedia].
- **Verbos.** Apuntar y activar (sacar o meter) un bloque, saltar; más tarde, mover imanes y guiar bolas [Hecho,
  Wikipedia; Eurogamer].
- **Mecánicas.** Rojo: se extiende o se retrae. Amarillo (de tres en tres): escalera. Azul: trampolín. Morado: gira
  una sección de pared. Verde: da una esfera o un cubo. Después, luz y magnetismo [Hecho, Wikipedia].

### Los mejores puzles

| | **A. Los tres amarillos** | **B. La bola por la pendiente** | **C. La sala a oscuras** (lección negativa) |
|---|---|---|---|
| **Qué ve el jugador** | Tres bloques amarillos juntos | Una bola, una pendiente, bloques y un agujero | Oscuridad: solo brillan los bloques |
| **Qué debe descubrir** | Que cada bloque sale a una altura según dónde golpee | Cómo desviar la bola, «cogerla» con un bloque y llevarla al agujero [Hecho, Eurogamer] | La forma de la sala sin verla |
| **Qué manipula** | El bloque que golpea | Bloques en marcha, con la bola rodando | Los bloques que brillan |
| **Reglas** | Las alturas dependen del punto de golpe [Hecho, Eurogamer] | Física de la bola | Las de siempre, sin luz |
| **Qué lo hace difícil** | Prever tres alturas a la vez | Hacer varias cosas a la vez con prisa [Opinión, Eurogamer] | No ver |
| **Qué lo hace satisfactorio** | La escalera justa | Soluciones elegantes tras mucho trastear [Opinión, Eurogamer] | Poco: «a boring stretch of trial-and-error» [Opinión, Eurogamer] |
| **Feedback** | Los bloques salen con su color y su sonido | La bola rueda; su física «ayuda» de forma rara [Opinión, Eurogamer] | Solo lo que brilla |
| **Recompensa** | Subir | El agujero | Salir |
| **Fuente** | [Hecho, Eurogamer] | [Hecho, Eurogamer] | [Hecho, Eurogamer] |

### Cámara, feedback y narrativa
- Primera persona, salas blancas con baldosas grandes y elementos de colores [Hecho, Eurogamer].
- [Opinión, Cubed3] Tutoriales silenciosos eficaces: sin texto, se aprende probando.
- [Opinión, Eurogamer] El control se siente a distancia: apuntar con la mano y que el bloque se mueva, con poco
  feedback físico.
- [Opinión, Joystiq] Casi sin historia: más un patio de juegos que una experiencia.

### Dificultad y aprendizaje
- [Opinión, Joystiq] Empieza sencillo, para aprender los controles, y sube poco a poco.
- [Opinión, Cubed3] A mitad de juego repite puzles con modificadores baratos (oscuridad, posiciones cambiadas);
  después, un salto brusco con los imanes.

### Lo que valoran y lo que critican
- [Opinión, Joystiq] «a delightful on-screen Rubik's Cube».
- [Opinión, Cubed3] 6/10: «It's not the Portal rip-off it's often accused of being, but it is ultimately faceless».
- [Opinión, Eurogamer] 6/10: la estética imita tanto a *Portal* que la comparación lo hunde: «QUBE hasn't learned
  from Valve's game but copied it».
- [Hecho, Wikipedia] Metacritic entre 68 y 76.

### Principios para La caja viva
1. **Un material, un verbo (A).** En toda la caja, el bambú siempre se desliza, la laca roja siempre gira y el bronce
   siempre suena. [Interpretación]
2. **Contacto, no mando a distancia (B).** El dedo arrastra la pieza 1:1, y la pieza tiene muelle y peso. Si se
   ayuda al encajar, que se lea como encaje, nunca como trampa. [Interpretación]
3. **No subir la dificultad con modificadores baratos (A).** Ni apagar la luz para el jugador, ni repetir un puzle
   cambiando posiciones: variar con ideas. [Interpretación]
4. **Lección de originalidad (A).** Para la crítica, la estética prestada pesó más que las mecánicas propias. Es un
   argumento más a favor del anexo B. [Interpretación]

### Riesgo de parecido
Bajo. [Interpretación]

### Fuentes
- **Wikipedia:** [*Q.U.B.E.*, Wikipedia](https://en.wikipedia.org/wiki/Q.U.B.E.)
- **Joystiq:** [Jessica Conditt, reseña de *Q.U.B.E.* (Joystiq, en Engadget)](https://www.engadget.com/2012-01-13-q-u-b-e-review.html)
- **Cubed3:** [Jordan Hurst, reseña de *Q.U.B.E.* (6/10)](https://www.cubed3.com/games/reviews/pc/qube)
- **Eurogamer:** [Rich Stanton, reseña de *QUBE* (6/10)](https://www.eurogamer.net/qube-review)

---

## 7. Antichamber (Alexander Bruce, 2013)

**En una frase:** un laberinto de espacios imposibles que cambia según cómo lo recorres. [Hecho, Wikipedia]

- **Género y año.** Puzle en primera persona, del 31-01-2013, hecho casi solo por Alexander Bruce [Hecho,
  Wikipedia; Eurogamer].
- **Core loop.** Salir de la sala negra del principio → recorrer un laberinto que cambia → resolver una sala → leer
  un cartel con un dibujo y una frase → volver por el mapa a otra sala [Hecho, Wikipedia].
- **Verbos.** Andar, mirar, saltar, y coger y colocar cubos con un «arma» que gana poderes por colores [Hecho,
  Wikipedia].
- **Mecánicas.** Espacios que cambian al pasar ciertos puntos o según hacia dónde miras; láseres que abren puertas
  si se tapan o se destapan; armas de cubos (coger y colocar, hacer crecer, dirigir, llenar); zonas que borran los
  cubos; un mapa para volver a cualquier sala, que reinicia esa sala; un reloj de 90 minutos [Hecho, Wikipedia].
  Para Bruce, romper las expectativas del espacio y rehacerlas «is essentially the core mechanic of the game»
  [Hecho, Wikipedia].

### Los mejores puzles

| | **A. Las dos escaleras** | **B. La ventana** | **C. Láseres y cubos** |
|---|---|---|---|
| **Qué ve el jugador** | Una escalera azul que sube y una roja que baja; las dos vuelven al mismo sitio [Hecho, Game Informer] | Una ventana a la que se puede pegar la cara | Haces de láser y puertas |
| **Qué debe descubrir** | Que recorrer el camino hacia atrás abre una zona nueva [Hecho, Game Informer] | Que mirar de cerca puede cambiar dónde estás [Hecho, Eurogamer] | Qué haces hay que tapar y cuáles destapar |
| **Qué manipula** | La dirección en que anda | Su posición frente al cristal | Cubos |
| **Reglas** | El espacio responde a cómo se recorre | El espacio responde a la mirada | Muchas puertas piden varios haces en el estado justo [Hecho, Wikipedia] |
| **Qué lo hace difícil** | Romper la intuición del espacio | Que nada lo anuncia | Gestionar cubos escasos |
| **Qué lo hace satisfactorio** | Descubrir que el juego «escucha» cómo te mueves | La sorpresa | El orden correcto |
| **Feedback** | Aparece una zona nueva | Estás en otro sitio | La puerta se abre |
| **Recompensa** | El cartel con su frase | Una ruta nueva | Avanzar y ganar poderes del arma |
| **Fuente** | [Hecho, Game Informer] | [Hecho, Eurogamer] | [Hecho, Wikipedia] |

### Cámara
- Primera persona; arte esquemático blanco con colores fuertes [Opinión, Eurogamer].

### Feedback, animación y sonido
- [Hecho, Game Developer audio] Sonido de naturaleza (lluvia, pájaros, olas) para dejar espacio a pensar. El
  diseñador de sonido, Robin Arnott: «We're now trying to avoid anything remotely antagonistic in the sound design».

### Narrativa
- Tras la mayoría de los puzles hay un cartel con un dibujo que, al activarlo, da una pista sobre el puzle resuelto
  [Hecho, Wikipedia].

### Dificultad y aprendizaje
- [Hecho, Joystiq] Cuando los probadores se perdían, Bruce no copió soluciones de otros juegos (mapas, flechas):
  usó el propio espacio imposible para llevar las ideas de un sitio a otro.
- [Opinión, Eurogamer] La mayoría de puzles «appear impossible at first and obvious after you've solved them».

### Lo que valoran y lo que critican
- [Opinión, Game Informer] 9/10: Bruce sería «the M.C. Escher of game development».
- [Opinión, Eurogamer] 6/10. Su inconsistencia lo hace poco fiable: «a puzzle game you can't trust is seldom that
  much fun». No saber si estás atascado, engañado o sin la herramienta necesaria «is the wrong kind of frustration».
  El mapa resta misterio y los carteles suenan condescendientes.
- [Opinión, Gamecritics] 7,5: carteles presumidos y a veces contradictorios; a mitad de juego cambia lo extraño por
  puzles de cubos más corrientes.
- [Hecho, Wikipedia] Metacritic 82.

### Principios para La caja viva
1. **La confianza también se diseña (B).** El jugador debe distinguir «te ve», «falta algo» y «así no» (ver «Lo
   mejor del bloque», 6). La inversión del nivel 3 se anuncia con una escena clara: la regla del ojo nunca cambia
   a escondidas. [Interpretación]
2. **Lo que el vigilante no ve, cambia (D).** Un segundo objeto vivo de la sala (por ejemplo, el animal pintado en el
   rollo) solo se mueve cuando el ojo no lo mira; el jugador usa la mirada de la caja para controlarlo.
   [Interpretación]
3. **Sonido que deja pensar (A).** La sala suena tranquila (grillos, viento, el agua de la tetera); lo inquietante se
   reserva para la caja. [Interpretación]
4. **Sin moralejas (A).** La nota de la caja nunca explica lo que acabas de hacer: pide lo siguiente con su voz.
   [Interpretación]

### Riesgo de parecido
Bajo: no usamos geometría imposible ni carteles. La idea 2 roza el tópico de «solo se mueve si no lo miras»
(riesgo bajo-medio). [Interpretación]

### Fuentes
- **Wikipedia:** [*Antichamber*, Wikipedia](https://en.wikipedia.org/wiki/Antichamber)
- **Game Informer:** [Jeff Marchiafava, «Antichamber Review: A Lesson In Originality» (9/10)](https://www.gameinformer.com/games/antichamber/b/pc/archive/2013/01/31/antichamber-review-a-lesson-in-originality.aspx)
- **Eurogamer:** [Oli Welsh, reseña de *Antichamber* (6/10)](https://www.eurogamer.net/antichamber-review)
- **Gamecritics:** [Sparky Clarkson, «The Space is a Lie» (7,5)](https://gamecritics.com/sparky-clarkson/antichamber-review/)
- **Game Developer audio:** [«Navigating an Antichamber of sound and mysteries» (entrevista sobre el sonido)](https://www.gamedeveloper.com/audio/interview-navigating-an-em-antichamber-em-of-sound-and-mysteries)
- **Joystiq:** [«On The Fringe, Part One: Alexander Bruce's Antichamber»](https://www.engadget.com/2012-05-02-on-the-fringe-part-one-alexander-bruces-antichamber.html)
- **GDC Vault:** [Alexander Bruce, «Antichamber: An Overnight Success, Seven Years in the Making» (GDC 2014; solo se leyó la descripción)](https://gdcvault.com/play/1020071/Antichamber-An-Overnight-Success-Seven)

---

## 8. Superliminal (Pillow Castle, 2019)

**En una frase:** lo que ves es lo que hay: un objeto pequeño cerca de los ojos es enorme al soltarlo lejos.
[Hecho, Wikipedia]

- **Género y año.** Puzle en primera persona de ilusiones ópticas: PC en noviembre de 2019, consolas en 2020 y
  móviles en julio de 2024 [Hecho, Wikipedia]. Nació en 2013 como proyecto de Albert Shih en Carnegie Mellon
  («Museum of Simulation Technology») [Hecho, Wikipedia].
- **Core loop.** Entrar en una sala de un sueño → descubrir la ilusión que la gobierna → usarla para abrir la salida
  [Interpretación, a partir de las reseñas].
- **Verbos.** Coger, soltar, mirar desde un sitio y andar.
- **Mecánicas.**
  - Perspectiva forzada: al soltarlo, el objeto mantiene el tamaño que aparentaba; mirar abajo lo encoge y mirar
    arriba lo agranda [Hecho, Wikipedia].
  - Trampantojos: formas pintadas que, desde el ángulo justo, se vuelven objetos que se pueden coger [Hecho,
    Wikipedia; TheSixthAxis].
  - Objetos que se duplican al cogerlos, puertas que son geometría estirada y suelos que desaparecen [Hecho,
    TheSixthAxis].

### Los mejores puzles

| | **A. Del queso a la rampa** | **B. El trampantojo** | **C. La casa del horizonte** |
|---|---|---|---|
| **Qué ve el jugador** | Un objeto pequeño (una cuña de queso) y un sitio al que no llega | Formas pintadas en las paredes | Una casa lejana, en el horizonte |
| **Qué debe descubrir** | Que acercar el objeto a los ojos y soltarlo lejos lo agranda hasta hacer una rampa | El punto exacto desde el que las formas pintadas se vuelven un objeto | Que se puede coger, dejar en una mesa y entrar por su puerta [Hecho, TheSixthAxis] |
| **Qué manipula** | Distancia y ángulo de la mirada al soltar | Su posición | Escala y sitio de la casa |
| **Reglas** | Se conserva el tamaño aparente | Alineado, lo pintado es real | Se conserva el tamaño aparente |
| **Qué lo hace difícil** | Va contra la intuición física | Encontrar el punto | Imaginar el cambio de escala |
| **Qué lo hace satisfactorio** | La magia de cambiar la escala | La figura que se completa | Entrar en lo que era pequeño |
| **Feedback** | El objeto cambia de tamaño al soltarlo | La figura «se vuelve» objeto | La casa a tu medida |
| **Recompensa** | Subir | Un objeto que hacía falta | El paso siguiente |
| **Fuente** | [Hecho, Game Informer] | [Hecho, Wikipedia] | [Hecho, TheSixthAxis; Game Informer] |

### Cámara, feedback y narrativa
- Primera persona; el placer es la sorpresa: «Every time I tried one thing and something else happened I'd swear
  aloud in surprise and grin to myself like an idiot» [Opinión, TheSixthAxis].
- Una terapia de sueños con mensajes de humor de un doctor [Hecho, Game Informer].
- Influencias: *Portal* y *Antichamber*, y películas como *Paprika* u *Origen* [Hecho, Game*Spark].

### Dificultad y aprendizaje
- [Opinión, TheSixthAxis] Las mecánicas no duran demasiado y cambian sutilmente: siempre hay algo nuevo.

### Lo que valoran y lo que critican
- [Opinión, Game Informer] 7,5: salió de un pasillo en bucle tocando objetos sin entender por qué; se sintió «stuck
  in an obtuse situation that left me scratching my head».
- [Opinión, TheSixthAxis] 8/10: corto (hay trofeos por acabarlo en una hora y en media) y poco rejugable.
- [Hecho, Wikipedia] Metacritic entre 74 y 80; se elogia la mecánica y se critican la duración y la historia.

### Principios para La caja viva
1. **Desde un sitio no se entiende; desde otro encaja (B).** Las vistas fijas lo abaratan: un dibujo de marquetería
   repartido entre la caja, la mesa y el shoji que solo se completa visto desde la cara. [Interpretación]
2. **La escala con luz, no con objetos (H).** Acercar o alejar la lámpara agranda o encoge en el shoji la sombra de un
   objeto pequeño; la caja reacciona a la sombra como si fuera real. [Interpretación]
3. **Explicar por qué funcionó (B).** Si un paso pide repetir algo, la caja enseña que lo cuenta (un clic más grave,
   una vuelta del humo). [Interpretación]

### Riesgo de parecido
- **Alto** si se encoge algo y se entra en ello: es «entrar en lo pequeño», prohibido.
- **Medio** con la anamorfosis (Superliminal; y las cifras que solo se leen desde un ángulo en The Room).
- **Bajo-medio** con la sombra en el shoji. [Interpretación]

### Fuentes
- **Wikipedia:** [*Superliminal*, Wikipedia](https://en.wikipedia.org/wiki/Superliminal)
- **Game Informer:** [Ben Reeves, «Superliminal Review: A Matter Of Perspective» (7,5)](https://gameinformer.com/review/superliminal/superliminal-review-a-matter-of-perspective)
- **TheSixthAxis:** [Gareth Chadwick, reseña de *Superliminal* (8/10)](https://www.thesixthaxis.com/2020/08/10/superliminal-review-ps4-xbox-switch/)
- **Game\*Spark:** [Entrevista a Pillow Castle (en japonés)](https://www.gamespark.jp/article/2020/11/15/103865.html)

---

## 9. Viewfinder (Sad Owl Studios, 2023)

**En una frase:** una foto colocada en el mundo sustituye lo que hay por lo que muestra. [Hecho, Wikipedia]

- **Género y año.** Puzle en primera persona, del 18-07-2023 (PS5 y PC) [Hecho, Wikipedia]. Matt Stark empezó con un
  vídeo en redes sociales en noviembre de 2019, el «efecto Polaroid» [Hecho, Wikipedia]. Ganó el BAFTA de 2024 a
  juego británico y a nueva propiedad intelectual [Hecho, Wikipedia].
- **Core loop.** Llegar a una zona → colocar fotos (u otras imágenes 2D) para cambiar el espacio → dar energía al
  teletransportador, a veces con baterías → salir [Hecho, Wikipedia].
- **Verbos.** Colocar y girar una foto, hacer fotos (más tarde, con una cámara instantánea), copiar y rebobinar
  [Hecho, Wikipedia; Nintendo Life].
- **Mecánicas.** Fotos que sustituyen el mundo, cámara propia, copias, miradores, rebobinado sin castigo, cámaras
  fijas y superficies que no se pueden sustituir [Hecho, Nintendo Life; Push Square].

### Los mejores puzles

| | **A. La foto-puente** | **B. La cámara con límites** | **C. Las baterías** |
|---|---|---|---|
| **Qué ve el jugador** | Una foto y un hueco sin camino | Una cámara fija o una superficie que no admite fotos | Un teletransportador apagado |
| **Qué debe descubrir** | Dónde y con qué giro poner la foto para crear el camino | Qué foto se puede hacer desde donde le dejan | Cómo llevar la energía hasta él |
| **Qué manipula** | Posición y giro de la imagen | El encuadre | Fotos y baterías |
| **Reglas** | Lo que muestra la foto pasa a existir | Límites puestos sobre una mecánica libre [Hecho, Push Square] | El teletransportador necesita energía [Hecho, Wikipedia] |
| **Qué lo hace difícil** | Imaginar el resultado en 3D | El límite | El orden de los pasos |
| **Qué lo hace satisfactorio** | Ver el mundo cortarse y rehacerse | Encontrar la foto justa | Cerrar el circuito |
| **Feedback** | El mundo cambia al instante; si no gusta, se rebobina | La foto no se coloca donde no debe | El teletransportador se enciende |
| **Recompensa** | El paso | Ídem | La salida |
| **Fuente** | [Hecho, Wikipedia] | [Hecho, Push Square] | [Hecho, Wikipedia] |

### Cámara, feedback y sonido
- Primera persona [Hecho, Wikipedia].
- [Hecho, Nintendo Life] El rebobinado deshace al instante y sin castigo lo que no funcionó.
- [Opinión, Nintendo Life] Mezcla bocetos a mano, entornos poligonales y acuarela; la música, de jazz y
  sintetizadores, sostiene el ambiente.

### Narrativa
- [Hecho, Wikipedia] Una simulación creada para recuperar la vida vegetal de la Tierra; un gato de Cheshire artificial,
  Cait, acompaña al jugador; al salir, se lleva una plántula como señal de esperanza.
- [Opinión, Push Square] Una historia que se olvida pronto.

### Dificultad y aprendizaje
- [Opinión, Push Square] La dificultad sube añadiendo límites a la mecánica (cámaras fijas, superficies que no se
  pueden sustituir), no mecánicas nuevas.
- [Opinión, Nintendo Life] Los puzles de varias fases invitan a rebobinar a menudo, y el avance es fluido.

### Diseño
- [Hecho, Wikipedia] Tomaron de *Portal* la forma de presentar las mecánicas poco a poco, y no querían que el efecto
  se quedara en un truco.
- [Hecho, Develop] Charla de Matt Stark sobre cómo hacer un juego entero de una sola mecánica: analizar sus fuerzas
  y sus límites y construir sistemas de apoyo.
- [Hecho, 80.lv] Lecciones: no apegarse a las ideas, priorizar sin piedad y saber explicar cada decisión. El cuello
  de botella técnico fue cortar mallas en un solo fotograma.
- [Hecho, PCGamesN] Influencias: *Portal*, *The Talos Principle* y *The Witness*.

### Lo que valoran y lo que critican
- [Opinión, Nintendo Life] 8/10: nunca obtuso; el rebobinado mantiene el ritmo; corto (unas cuatro horas). Los
  cambios de espacio no marean: «it all comes surprisingly naturally».
- [Opinión, Push Square] 7/10: estructura algo deslavazada, con «the concept not quite fulfilling its potential».
- [Hecho, Wikipedia] Metacritic entre 81 y 84; se elogia la mecánica y se critica lo corto.

### Principios para La caja viva
1. **A cada mecánica libre, un límite que obligue a pensar (A).** Ya pasa en el nivel 2 (girar la caja hija, pero la
   cara que mira el ojo no se mueve). Aplicarlo a cada mecánica nueva. [Interpretación]
2. **Experimentar sin coste (A).** Todo gesto se deshace (empujar lo que se tiró, girar al revés) y nada se pierde.
   [Interpretación]
3. **Lo pintado cobra vida (G).** Con nuestra técnica (pintura proyectada), el rollo puede ser otro *tsukumogami*: lo
   pintado en él se mueve cuando la caja no mira. Nunca fotos ni cámaras: es un ser vivo, no un cambio de geometría.
   [Interpretación]

### Riesgo de parecido
Medio si hubiera fotos o imágenes que transforman el espacio. Bajo con los principios. [Interpretación]

### Fuentes
- **Wikipedia:** [*Viewfinder*, Wikipedia](https://en.wikipedia.org/wiki/Viewfinder_(video_game))
- **80.lv:** [«Postmortem: Developing Viewfinder»](https://80.lv/articles/postmortem-developing-viewfinder-a-surreal-perception-bending-puzzle-game/)
- **PCGamesN:** [«Viewfinder draws inspiration from Portal to blend puzzles with story»](https://www.pcgamesn.com/viewfinder/portal-inspiration)
- **Develop:** [Matt Stark, «Viewfinding: From Mechanic to Game» (descripción de la charla)](https://developconference.com/north/speakers/matt-stark)
- **Nintendo Life:** [Ken Talbot, reseña de *Viewfinder* (8/10)](https://www.nintendolife.com/reviews/switch-eshop/viewfinder)
- **Push Square:** [Stephen Tailby, reseña de *Viewfinder* (7/10)](https://pushsquare.com/reviews/ps5/viewfinder)

---

## 10. Monument Valley (ustwo games, 2014) y Monument Valley 2 (2017)

**En una frase:** guías a una princesa por edificios imposibles que, girados, se conectan desde tu punto de vista.
[Hecho, Wikipedia MV]

- **Género y año.** Puzle táctil de geometría imposible en vista isométrica; iOS, 3-04-2014 [Hecho, Wikipedia MV].
  Diez niveles, cada uno con una mecánica central distinta [Hecho, Wikipedia MV]. Equipo de ocho personas [Hecho,
  Game Developer MV]; 55 semanas de desarrollo y 852.000 dólares [Hecho, TechCrunch].
- **Core loop.** Tocar adónde debe ir Ida → girar manivelas y deslizar piezas para que el camino exista desde tu
  punto de vista → llegar a la salida [Hecho, Wikipedia MV; Gamezebo].
- **Verbos.** Tocar un destino, girar una manivela, deslizar una pieza y pisar botones, con Ida o con otros
  [Hecho, Gamezebo].
- **Mecánicas.** Caminos que se unen cuando se alinean en la vista; manivelas (la parte que se mueve es un poco más
  clara); círculos salientes que indican que la pieza se desliza en esa dirección; gente cuervo que patrulla, cierra
  el paso y pisa botones; el Tótem, compañero que se desliza y pisa botones; paredes que pasan a ser suelo [Hecho,
  Gamezebo; Wikipedia MV].

### Los mejores puzles

| | **A. El jardín** (capítulo II) | **B. La Caja** (capítulo VIII) | **C. El Tótem** (capítulo VI) |
|---|---|---|---|
| **Qué ve el jugador** | Dos botones y una manivela | Una caja con cuatro partes móviles, marcadas con círculos | El Tótem, un pilar con círculos a los dos lados que se desliza en cualquier dirección [Hecho, Gamezebo] |
| **Qué debe descubrir** | Que el puzle es «all about perspective»: el camino aparece al alinear piezas [Hecho, Gamezebo] | Que hay que probar cada parte; Ida enciende tres luces y la cuarta (morada) solo la puede encender un cuervo [Hecho, Gamezebo] | Que hay que «conocerlo», moverlo y llevar arriba a Ida y al Tótem; el Tótem también pisa botones [Hecho, Gamezebo] |
| **Qué manipula** | La manivela (tres veces) [Hecho, Gamezebo] | Las cuatro partes de la caja | El Tótem y el camino |
| **Reglas** | Lo que se ve unido está unido | Cuatro luces abren la caja | Los botones con puntos se apagan al bajarse [Hecho, Gamezebo] |
| **Qué lo hace difícil** | Ver en 2D lo que es 3D | Coordinar a Ida y al cuervo | Mover a dos |
| **Qué lo hace satisfactorio** | El «imposible» que funciona | La caja se abre y aparece una zona nueva [Hecho, Gamezebo] | Un compañero que no habla |
| **Feedback** | Ida camina por la unión imposible | Las luces se encienden y la caja se despliega | El Tótem acompaña |
| **Recompensa** | La salida | La zona nueva | Subir |
| **Fuente** | [Hecho, Gamezebo] | [Hecho, Gamezebo] | [Hecho, Gamezebo] |

### Cámara
- Isométrica y fija; cada nivel es un «mundo pequeño» entero en pantalla. Ken Wong: decidir que «every screen is
  going to be a work of art that you can hang on a wall» les obligó a inventar puzles distintos [Hecho, Game
  Developer MV].
- Para Dan Gray, cada pantalla debía funcionar a la vez como puzle, como arquitectura y como composición gráfica
  [Hecho, PocketGamer.biz].
- Se diseñó en vertical; pasarlo a horizontal fue difícil [Hecho, Wikipedia MV].

### Feedback, animación y sonido
- [Hecho, Wikipedia MV] El color indica dónde se puede tocar.
- [Hecho, Joystiq MV] En las pruebas, cada persona tocaba la pantalla de forma distinta y casi todos miraban fijamente
  a la protagonista; por eso «important environment actions needed to be visually loud».
- [Hecho, Gamezebo] La gente cuervo no hace daño, pero cierra el paso: si Ida choca con uno, se retrocede y se
  espera a que siga su ronda.

### Narrativa
- Un viaje simbólico casi sin texto. La princesa es silenciosa y no tiene cara para que cada jugador interprete lo
  que pasa [Hecho, Webby MV2].

### Dificultad y aprendizaje
- [Hecho, Wikipedia MV] Pensado para que casi todos lo terminen: beta con más de 1.000 probadores y una media de 90
  minutos.
- [Hecho, PocketGamer.biz] Ante dos opciones elegían «whichever option felt more elegant», aunque bajara la
  dificultad o hubiera que quitar un puzle. Probaron con gente del estudio que no juega.
- [Hecho, Game Developer MV] Ken Wong: «We only added a level if we had something new to say».
- [Hecho, TechCrunch] Aun así, solo el 50 % de los que empezaron lo terminó.

### Lo que valoran y lo que critican
- [Hecho, Wikipedia MV] Metacritic 89 y Apple Design Award de 2014; la crítica señala lo corto.
- [Hecho, TouchArcade] La expansión de pago trajo reseñas de una estrella (una decía haberlo acabado en una hora); ustwo respondió:
  «This makes us sad».

### Monument Valley 2 (2017)
- [Hecho, Wikipedia MV2] Ro y su hija: al principio la hija la sigue sola; en los últimos niveles se separan y se
  manejan por separado. Las escenas de separación usan estructuras grises y brutalistas.
- [Hecho, Webby MV2] Querían contar una historia de madres, poco tratada en los juegos.
- [Hecho, MobileSyrup] Dan Gray: una madre que es además creadora de ese mundo.
- [Interpretación] La mecánica cuenta la historia: la dependencia y la independencia se juegan, no se explican.

### Principios para La caja viva
1. **Una idea nueva por nivel (A).** Confirma `ilustrada/NIVELES.md` (cada nivel trae una idea estructural). Y quitar
   lo que no aporte, aunque baje la dificultad. [Interpretación]
2. **Acciones «ruidosas» porque el jugador mira al personaje (B).** En La caja viva el jugador mira al ojo: todo lo que
   pase lejos (el león, la trampilla) necesita luz, sonido o un giro de cámara. Y zonas táctiles generosas: cada uno
   toca distinto. [Interpretación]
3. **Una gramática de asas (A).** Allí, círculos y manivelas; en la caja, muesca, borla y anillo (ver «Lo mejor del
   bloque», 5). [Interpretación]
4. **Madre e hija (G).** La caja hija del nivel 2 como hija de la caja grande: la grande respira más tranquila cuando
   la tiene cerca, y por eso la vigila. La regla del nivel 2 se explica con una emoción. [Interpretación]

### Riesgo de parecido
- **Bajo-medio** para el nivel 3: «La Caja» de Monument Valley es una caja que se abre por partes. Nuestro biombo se
  abre por su regla (la mirada), sin luces en las esquinas y sin nadie caminando dentro.
- **Bajo** para el resto: no usamos geometría imposible. [Interpretación]

### Fuentes
- **Wikipedia MV:** [*Monument Valley*, Wikipedia](https://en.wikipedia.org/wiki/Monument_Valley_(video_game))
- **Game Developer MV:** [Entrevista a Ken Wong, «Designing the surprise mobile game hit Monument Valley» (2014)](https://www.gamedeveloper.com/design/designing-the-surprise-mobile-game-hit-i-monument-valley-i-)
- **Joystiq MV:** [Resumen de la charla de Ken Wong (Joystiq, en Engadget, 2014)](https://www.engadget.com/2014-08-11-monument-valley-recouped-costs-in-one-week.html)
- **PocketGamer.biz:** [«Stairway to heaven: the making of Monument Valley»](https://www.pocketgamer.biz/stairway-to-heaven-the-making-of-monument-valley/)
- **TechCrunch:** [Costes, ventas y finalización (2015)](https://techcrunch.com/2015/01/15/monument-valley-team-reveals-the-cost-and-reward-of-making-a-hit-ios-game/)
- **Gamezebo:** [Guía de *Monument Valley* por capítulos](https://www.gamezebo.com/walkthroughs/monument-valley-walkthrough/)
- **TouchArcade:** [«I Love Your Game, I Give It One Star»](https://toucharcade.com/2015/05/21/i-love-your-game-i-give-it-one-star-the-crazy-world-of-app-store-reviews/)
- **GDC Vault:** [Ken Wong, «Designing Monument Valley: Less Game, More Experience» (solo se leyó la descripción)](https://www.gdcvault.com/play/1021380/Designing-Monument-Valley-Less)
- **Wikipedia MV2:** [*Monument Valley 2*, Wikipedia](https://en.wikipedia.org/wiki/Monument_Valley_2)
- **Webby MV2:** [Preguntas y respuestas con ustwo games sobre *Monument Valley II*](https://www.webbyawards.com/qa-ustwo-games-creators-monument-valley-ii/)
- **MobileSyrup:** [Anuncio de *Monument Valley 2* (2017)](https://mobilesyrup.com/2017/06/05/monument-valley-2/)

---

## 11. Tetris (Alexéi Pázhitnov, 1984-1985)

**En una frase:** piezas que caen y una fila que, completa, desaparece y deja seguir jugando. [Hecho, Wikipedia
Tetris]

- **Género y año.** Puzle de encaje en tiempo real, hecho a mediados de los años 80 en el Centro de Computación
  Dorodnitsyn para el ordenador Elektronika 60 [Hecho, Wikipedia Tetris]. Es el juego más vendido de la historia:
  520 millones de copias a diciembre de 2024 [Hecho, Wikipedia Tetris].
- **Core loop.** Cae una pieza → girarla y moverla → encajarla → si una fila se completa, desaparece → cae otra, cada
  vez más rápido [Hecho, Wikipedia Tetris].
- **Verbos.** Mover, girar, dejar caer y, en las versiones modernas, guardar una pieza [Hecho, Tetris Wiki].
- **Mecánicas.** Siete piezas de cuatro cuadros, filas que se borran, velocidad que sube, vista previa de las
  siguientes, pieza fantasma, reserva, medio segundo de gracia al tocar fondo y generador «de bolsa de siete»
  [Hecho, Tetris Wiki; Wikipedia Tetris].

### Por qué es así
- [Hecho, Wikipedia Tetris; Museum of Play] Nació de los pentominós. Con doce formas de cinco cuadros, «the game
  would be needlessly complicated», así que bajó a siete piezas de cuatro. La gravedad lo convirtió en un juego en
  tiempo real.
- [Hecho, Gamereactor] Pázhitnov cuenta tres «¡ajá!»: lograr imágenes en pantalla, el giro inmediato al pulsar, y
  borrar las filas: «if I take it away, I can continue to play the game. That was the main 'aha' for the game».

### Los mejores momentos de puzle

| | **A. La fila** | **B. El pozo para la pieza larga** | **C. El giro en T** |
|---|---|---|---|
| **Qué ve el jugador** | La pila, el hueco, la pieza actual y las siguientes | Un pozo de una casilla de ancho | Un hueco con forma de T tapado por arriba |
| **Qué debe descubrir** | Dónde encaja la pieza | Si merece la pena esperar a la pieza larga para borrar cuatro filas | Que la T, girada en el último momento, entra donde «no cabe» |
| **Qué manipula** | Giro y posición | El riesgo: cuánto esperar | Giro en el sitio |
| **Reglas** | Fila completa, fila borrada | La bolsa de siete limita la espera: como mucho 12 piezas entre dos piezas largas [Hecho, Tetris Wiki] | Las versiones modernas detectan este giro y lo premian [Hecho, Tetris Wiki] |
| **Qué lo hace difícil** | La velocidad | La pila crece mientras esperas | La precisión y saber que existe |
| **Qué lo hace satisfactorio** | El orden que vuelve | Cuatro filas de golpe | El truco experto |
| **Feedback** | La fila desaparece y la pila baja | Ídem, a lo grande | Aviso y puntos extra |
| **Recompensa** | Seguir jugando [Hecho, Gamereactor] | Más puntos | Más puntos |
| **Fuente** | [Hecho, Wikipedia Tetris] | [Hecho, Tetris Wiki] | [Hecho, Tetris Wiki] |

### Cámara, feedback y ayudas
- Pantalla fija: el pozo entero siempre a la vista. [Interpretación]
- [Hecho, Tetris Wiki] Las versiones modernas añadieron ayudas que hacen el juego justo: vista previa de hasta seis
  piezas, pieza fantasma (una silueta que muestra dónde caerá), reserva, y medio segundo de gracia al tocar fondo,
  que se reinicia si mueves la pieza.
- [Hecho, Tetris Wiki] La bolsa de siete reparte las siete piezas en orden aleatorio, una de cada, para evitar
  sequías largas de una pieza.

### Por qué engancha
- [Opinión, Stafford] El efecto Zeigarnik: las tareas incompletas se recuerdan; «Tetris holds our attention by
  continually creating unfinished tasks». A eso se suma el placer de ordenar.
- [Hecho, Kirsh y Maglio] Los jugadores giran la pieza en pantalla para pensar, en lugar de girarla en la cabeza: es
  más rápido y más fiable («acción epistémica»).
- [Hecho, Wikipedia efecto Tetris] El «efecto Tetris»: se siguen viendo piezas al cerrar los ojos; incluso personas
  con amnesia soñaban con piezas que caen (Stickgold, 2000).

### Narrativa
- Ninguna: el juego es el puzle. [Interpretación]

### Dificultad y aprendizaje
- [Hecho, Wikipedia Tetris] La dificultad es la velocidad, que sube a medida que se borran filas; las reglas no
  cambian nunca.
- [Interpretación] Se entiende en segundos y no necesita tutorial: la curva está en las manos, no en las reglas.

### Lo que valoran y lo que critican
- [Opinión, Museum of Play] Ejemplo de buen diseño: simplificar y buscar ideas fuera de los videojuegos.

### Principios para La caja viva
1. **Una tarea incompleta siempre a la vista (G).** La cara con sus huecos; sembrar la cerradura del nivel siguiente
   antes de su llave (el hueco de la ficha de shōgi ya lo hace). [Interpretación]
2. **Pensar girando (A).** Girar la caja hija y la cajita roja sin coste ni espera, con respuesta inmediata, como el
   giro que enganchó a Pázhitnov. [Interpretación]
3. **La silueta del encaje (B).** Al acercar un objeto del inventario a su sitio aparece su silueta encajada (como la
   pieza fantasma), con un margen de gracia al soltar. [Interpretación]
4. **Azar justo (B).** Si el ojo tiene algo de azar (cuándo se distrae solo), que tenga un máximo, como la bolsa de
   siete: la oportunidad llega siempre en pocos segundos. [Interpretación]

### Riesgo de parecido
Ninguno: son principios abstractos. [Interpretación]

### Fuentes
- **Wikipedia Tetris:** [*Tetris*, Wikipedia](https://en.wikipedia.org/wiki/Tetris)
- **Gamereactor:** [«Tetris creator reveals the three 'aha' moments that changed gaming»](https://www.gamereactor.eu/tetris-creator-reveals-the-three-aha-moments-that-changed-gaming-1645373/)
- **Museum of Play:** [«Russian-born Tetris illustrates good design»](https://www.museumofplay.org/blog/russian-born-tetris-illustrates-good-design/)
- **Stafford:** [Tom Stafford, «The psychology of Tetris» (columna de BBC Future, en su blog)](https://www.goodreads.com/author_blog_posts/3206042-bbc-future-column-the-psychology-of-tetris)
- **Kirsh y Maglio:** [David Kirsh y Paul Maglio, «On Distinguishing Epistemic from Pragmatic Action», *Cognitive Science*, 1994](https://doi.org/10.1207/s15516709cog1804_1)
- **Tetris Wiki:** [«Random Generator»](https://tetris.wiki/Random_Generator) y [«Tetris Guideline»](https://tetris.wiki/Tetris_Guideline)
- **Wikipedia efecto Tetris:** [«Tetris effect», Wikipedia](https://en.wikipedia.org/wiki/Tetris_effect)

---

## 12. Inside (Playdead, 2016)

**En una frase:** un niño cruza un mundo hostil resolviendo puzles de física, sigilo y control de cuerpos, sin una
palabra. [Hecho, Wikipedia Inside]

- **Género y año.** Plataformas y puzles en 2,5D, del 29-06-2016, dirigido por Arnt Jensen [Hecho, Wikipedia Inside].
- **Core loop.** Avanzar hacia la derecha → leer la amenaza (perros, focos, vigilantes) → resolver con física,
  sigilo o control de cuerpos → seguir [Hecho, Wikipedia Inside; Eurogamer Inside].
- **Verbos.** Correr, saltar, agarrar, empujar y tirar, nadar, y conectarse a un casco de control [Hecho, GamesRadar;
  PopMatters].
- **Mecánicas.** Casco de control mental (cuerpos sin voluntad repiten tus movimientos), focos y robots que barren
  la zona, ondas cíclicas, agua y secretos que abren un final alternativo [Hecho, Wikipedia Inside; PopMatters;
  Gamepressure].

### Los mejores puzles

| | **A. La fila vigilada** (fábrica) | **B. La onda expansiva** (puente) | **C. El casco de control** (ciudad y fábrica) |
|---|---|---|---|
| **Qué ve el jugador** | Una fila de personas sin voluntad que avanza; un dron llega y lo ilumina | Explosiones lejanas que barren un puente | Un casco conectado y cuerpos inertes |
| **Qué debe descubrir** | Que hay que comportarse como ellos: andar, pararse, saltar y girarse a la vez [Hecho, Gamepressure] | Que el ciclo avisa: sonido y destello, silencio, onda [Hecho, Gamepressure] | Que sus movimientos los hacen ellos; con dos cuerpos, que van en sentidos opuestos [Hecho, Gamepressure] |
| **Qué manipula** | Su ritmo | Cuándo se mueve y tras qué se cubre (incluidas coberturas móviles) | Sus propios pasos, que mueven a otros |
| **Reglas** | La fila anda nueve pasos y se para unos segundos [Hecho, Gamepressure] | Unos cuatro segundos de calma entre ondas [Hecho, Gamepressure] | Los cuerpos repiten lo que haces [Hecho, PopMatters] |
| **Qué lo hace difícil** | La sincronía bajo la mirada | Los tiempos | Pensar por dos a la vez |
| **Qué lo hace satisfactorio** | Esconderse a plena vista | Dominar un ritmo | Mandar sobre otros cuerpos |
| **Feedback** | Si te desacompasas, la luz del dron parpadea antes del castigo [Hecho, Gamepressure] | Sonido, destello y silencio antes de cada onda | Los cuerpos imitan al instante |
| **Recompensa** | Pasar (acaba en una persecución) | Cruzar el puente | Dos placas pulsadas a la vez |
| **Fuente** | [Hecho, Gamepressure] | [Hecho, Gamepressure] | [Hecho, Gamepressure; PopMatters] |

### Cámara
- Lateral en 2,5D, con un mundo vivo al fondo que también importa [Opinión, Eurogamer Inside].

### Feedback, animación y sonido
- [Hecho, GDC 2016] Martin Stig Andersen, «A Game That Listens»: el sonido marca el ritmo y el juego se adapta a él,
  para que la tensión y la calma no se corten.
- [Hecho, Wikipedia Inside] Grabaron parte del sonido a través de un cráneo humano.
- [Opinión, GamesRadar] Sin diálogo y con poca música: máquinas, madera que cruje y la respiración agitada del niño.

### Narrativa
- Sin palabras; para la crítica, el puzle y la trama son lo mismo [Opinión, Eurogamer Inside].

### Dificultad y aprendizaje
- [Opinión, Eurogamer Inside] «This isn't a hard game», pero sus mejores puzles hacen reír al entender. El truco es
  «make it clear which elements belong inside a puzzle and which are extraneous»: las piezas clave están cerca.
- [Opinión, Eurogamer Inside] Para Playdead, el sigilo incluye «behaving in certain ways when you're entirely
  visible», a menudo con ritmo.
- [Opinión, GamesRadar] Menos trampas de ensayo y error que *Limbo*; mucha variedad, pero sin un gran «¡eureka!»
  final que lo junte todo.

### Lo que valoran y lo que critican
- Lo de arriba. [Hecho, Wikipedia Inside] Metacritic entre 91 y 93.

### Principios para La caja viva
1. **Sigilo a la vista (E).** Mientras el ojo mira, algo se puede mover solo si se hace «como espera la caja»: al
   ritmo de su respiración, al espirar. Si te desacompasas, el párpado se entorna (aviso) antes de la resistencia.
   [Interpretación]
2. **Aviso, silencio y consecuencia (A).** La caja anuncia su despertar: inspira (sonido), contiene (silencio) y abre
   el ojo. [Interpretación]
3. **Que se vea qué es pieza (A).** Ver «Lo mejor del bloque», 7. [Interpretación]

### Riesgo de parecido
Bajo; nada de distopía ni de cuerpos. [Interpretación]

### Fuentes
- **Wikipedia Inside:** [*Inside*, Wikipedia](https://en.wikipedia.org/wiki/Inside_(video_game))
- **Eurogamer Inside:** [Christian Donlan, reseña de *Inside*](https://www.eurogamer.net/inside-review)
- **GamesRadar:** [Lucas Sullivan, reseña de *Inside*](https://www.gamesradar.com/inside-review/)
- **GDC 2016:** [Martin Stig Andersen, «A Game That Listens» (descripción de la charla)](https://www.gamedeveloper.com/audio/video-designing-the-audio-for-i-inside-i-a-game-that-listens)
- **Gamepressure:** guía de [la fábrica](https://www.gamepressure.com/inside/factory/zf9051), [el puente](https://www.gamepressure.com/inside/range-bridge/z29054) y [la ciudad](https://www.gamepressure.com/inside/city/ze9050)
- **PopMatters:** [«Inside embodies the horrors of collectivism»](https://www.popmatters.com/inside-embodies-the-horrors-of-collectivism-2495424103.html)

---

## 13. Limbo (Playdead, 2010)

**En una frase:** un niño, dos botones y un bosque lleno de trampas: se aprende muriendo. [Hecho, Game Developer
Limbo]

- **Género y año.** Plataformas y puzles en 2D, del 21-07-2010 (Xbox Live Arcade). Dirección de Arnt Jensen, diseño
  de puzles de Jeppe Carlsen y sonido de Martin Stig Andersen; unas ocho personas en el núcleo del equipo [Hecho,
  Wikipedia Limbo].
- **Core loop.** Avanzar → morir en una trampa → entender → pasar: «ensayo y muerte» [Hecho, Wikipedia Limbo].
- **Verbos.** Moverse, saltar y agarrar: solo dos botones y nunca un texto de tutorial [Hecho, Game Developer Limbo].
- **Mecánicas.** Trampas, cajas, palancas, gravedad que cambia, babosas que controlan la mente y una araña gigante
  [Hecho, Wikipedia Limbo; Eurogamer Limbo].

### Los mejores puzles

| | **A. Aprender a agarrar** | **B. La araña y la trampa** | **C. El interruptor al pasar** (patrón) |
|---|---|---|---|
| **Qué ve el jugador** | Una cornisa demasiado alta y un bote para arrastrar | Una araña gigante que cierra el paso | Un interruptor en el camino |
| **Qué debe descubrir** | Que se puede arrastrar el bote; nadie lo pensaba porque acababan de viajar en él [Hecho, Game Developer Limbo] | Que la araña tira una trampa de oso que hace falta para seguir [Hecho, Game Developer Limbo] | Qué hace el interruptor |
| **Qué manipula** | Objetos que se arrastran | La posición frente a la araña | Nada: lo pulsa al correr |
| **Reglas** | Agarrar y tirar | La trampa cae fuera de la pantalla | Pisar es activar |
| **Qué lo hace difícil** | Que no hay tutorial | La «slight frustration on not knowing what to do» que buscaban [Hecho, Game Developer Limbo] | Nada: enseña |
| **Qué lo hace satisfactorio** | Descubrirlo solo | Volver el peligro contra sí mismo | Ver la consecuencia |
| **Feedback** | Crearon una escena que deja al niño junto a un objeto arrastrable; cerca de él, el niño adelanta los brazos [Hecho, Game Developer Limbo] | Se oye caer la trampa; con la trampa en la misma pantalla, la gente miraba la trampa y no la araña, así que la llevaron a otra [Hecho, Game Developer Limbo] | El efecto llega solo |
| **Recompensa** | Subir | Seguir | Entender el elemento antes de necesitarlo [Hecho, Game Developer Limbo] |
| **Fuente** | [Hecho, Game Developer Limbo] | [Hecho, Game Developer Limbo] | [Hecho, Game Developer Limbo] |

### Diseño según Jeppe Carlsen
- [Hecho, Game Developer Limbo] «You could call it a learning-by-dying game». Pero morir no penaliza, y las muertes
  deben enseñar algo y ser vistosas: «It's important that you also treat him nicely».
- [Hecho, Game Developer Limbo] Primero ser el peor enemigo del jugador y diseñar el puzle más retorcido; después,
  su mejor amigo, y darle las pistas justas. Empezar difícil y recortar.
- [Hecho, Game Developer Limbo] «It's very important that the correct solution is fairly easy to execute». Si la
  idea buena falla un par de veces, el jugador la descarta: «It takes the player a long time to go back to an idea
  that he had previously discarded as not being possible».
- [Hecho, Game Developer Limbo] Los caminos equivocados deben verse claramente equivocados: si uno malo se acerca a
  funcionar, el jugador se aferra a él.
- [Hecho, Game Developer Limbo] No hay pistas ni menús. Carlsen admite que quedarse atascado así es «not really a
  fortunate situation» para el jugador.

### Cámara, arte y sonido
- Blanco y negro con grano de película, sin texto ni interfaz [Hecho, Wikipedia Limbo; Eurogamer Limbo].
- Sonido sin fuente visible (acusmático), más ambiente que música [Hecho, Wikipedia Limbo].

### Narrativa
- Ambigua: un niño en un bosque y una ciudad; el final es deliberadamente vago [Hecho, Wikipedia Limbo].

### Lo que valoran y lo que critican
- [Opinión, Eurogamer Limbo] 9/10: límites rigurosos (sin color, sin diálogo, poca música) bien aprovechados;
  capacidades mínimas que se vuelven hazañas.
- [Opinión, bit-tech] Las trampas del final solo se resuelven por ensayo y error: «there's no way to proceed without
  dying a few times».
- [Hecho, Wikipedia Limbo] Metacritic entre 88 y 90; se discutió su duración frente a su precio.

### Principios para La caja viva
1. **La solución correcta, fácil de ejecutar (A).** En táctil, el gesto bueno debe funcionar la primera vez que se
   hace más o menos bien: márgenes amplios de dirección y recorrido. [Interpretación]
2. **Lo equivocado, claramente equivocado (B).** La resistencia de la caja distingue «no por ahora» de «así no» (ver
   «Lo mejor del bloque», 6). [Interpretación]
3. **Mover la pista para mover la atención (A).** Si algo roba la atención, se aleja o se calla; el sonido une lo que
   pasa fuera de la vista. [Interpretación]
4. **Fallar sí, morir no (D).** Sin muerte ni vuelta atrás: el fallo enseña con la reacción de la caja.
   [Interpretación]

### Riesgo de parecido
Bajo; nada de muertes ni de sangre. [Interpretación]

### Fuentes
- **Wikipedia Limbo:** [*Limbo*, Wikipedia](https://en.wikipedia.org/wiki/Limbo_(video_game))
- **Game Developer Limbo:** [Brandon Sheffield, «GDC Europe: Limbo's Carlsen On Making Players Your Worst Enemy And Your Best Friend»](https://www.gamedeveloper.com/game-platforms/gdc-europe-i-limbo-i-s-carlsen-on-making-players-your-worst-enemy-and-your-best-friend)
- **Eurogamer Limbo:** [John Teti, reseña de *Limbo* (9/10)](https://www.eurogamer.net/limbo-review)
- **bit-tech:** [Alex Watson, reseña de *Limbo*](https://bit-tech.net/reviews/gaming/xbox/limbo-xbla-review/2/)

---

## 14. Little Nightmares (Tarsier Studios, 2017) y Little Nightmares II (2021)

**En una frase:** una niña diminuta cruza un barco de adultos enormes escondiéndose, distrayéndolos y trepando por
sus muebles. [Hecho, Wikipedia LN; Eurogamer LN]

- **Género y año.** Plataformas y puzles con «escondite» en 2,5D, del 28-04-2017 [Hecho, Wikipedia LN]. Tarsier lo
  describe como un juego de escondite más que de sigilo [Hecho, Eurogamer LN].
- **Core loop.** Entrar en una sala → observar al adulto que la ocupa → esconderse, distraerlo o huir → resolver el
  paso: tirar, trepar o encender [Hecho, Wikipedia LN; Eurogamer LN].
- **Verbos.** Correr, agacharse, esconderse, trepar, tirar y arrastrar, lanzar y encender el mechero [Hecho,
  Wikipedia LN; Eurogamer LN].
- **Mecánicas.** La escala (todo es enorme), escondites, adultos con rutinas, un conserje ciego de brazos largos que
  caza por el oído y un mechero que enciende lámparas que son puntos de control [Hecho, PC Gamer LN; Eurogamer LN].

### Los mejores puzles

| | **A. El conserje ciego** | **B. Los cajones como escalera** | **C. Los maniquíes** (*Little Nightmares II*) |
|---|---|---|---|
| **Qué ve el jugador** | Un adulto de brazos larguísimos y suelos que crujen | Un archivador gigante | Maniquíes quietos en un hospital y una linterna |
| **Qué debe descubrir** | Que no ve: oye; y que un objeto lanzado lo manda a otra parte [Hecho, PC Gamer LN] | Que abriendo cajones a distintas alturas se sube [Hecho, IGN] | Que solo se mueven a oscuras y la luz los congela; y que a veces conviene apartar la luz para que uno se levante [Hecho, Gamer Walkthroughs] |
| **Qué manipula** | El ruido: por dónde pisa y qué lanza | Qué cajones abre | Hacia dónde apunta la luz |
| **Reglas** | Responde solo a los sonidos que haces al pisar superficies que crujen [Hecho, PC Gamer LN] | Un cajón abierto es un peldaño | Luz = quieto; oscuridad = se mueve |
| **Qué lo hace difícil** | La tensión y el recorrido | Ver un mueble como escalera | Repartir la luz entre varios |
| **Qué lo hace satisfactorio** | Burlarlo con un sonido | El cambio de escala: un mueble es una montaña | Usar la amenaza a tu favor |
| **Feedback** | Se va hacia el ruido; sus brazos tantean hacia el escondite [Hecho, PC Gamer LN; IGN] | Los cajones salen y forman peldaños | Se paran en seco en la luz |
| **Recompensa** | Pasar sin ser vista | Subir | Abrir el paso |
| **Fuente** | [Hecho, PC Gamer LN] | [Hecho, IGN] | [Hecho, Gamer Walkthroughs] |

### Cámara
- Como una casa de muñecas sin la pared de delante; los escenarios son algo más grandes que el campo de visión, y la
  cámara va con un ligero retraso y se mece con el barco, como un ojo que flota [Opinión, IGN].

### Feedback, animación y sonido
- [Hecho, Eurogamer LN] Los ojos de Six se van hacia los objetos útiles del puzle: «her eyes darting to puzzle props».
- [Hecho, Eurogamer LN] La respiración ronca y los pasos de los adultos se oyen antes de verlos.
- [Hecho, Eurogamer LN] Arrancar una llave enorme de su clavo balanceándose; encender lámparas con el mechero.

### Narrativa
- Sin palabras: las rutinas domésticas de los adultos cuentan el mundo [Opinión, Eurogamer LN; IGN].

### Dificultad y aprendizaje
- [Hecho, GamingBolt] Puzles bastante directos; lo difícil fue equilibrar las plataformas rápidas con el sigilo
  lento. Entre 4 y 6 horas.
- [Opinión, IGN] Sabes dónde están los depredadores; lo que inquieta es otra cosa: «you’re more worried about them
  knowing where you are».

### Little Nightmares II (2021)
- [Hecho, Wikipedia LN2] Mono y Six, una compañera que maneja el juego; se la puede llamar y darle la mano.
- [Opinión, PC Gamer LN2] Six ayuda en los puzles y da pistas generales si te atascas. Los puzles ocurren en
  espacios pequeños, así que «you always know the solution is here somewhere». Un puzle de ajedrez pide encontrar
  los remates de las piezas. El combate, con armas demasiado grandes, es lento y frustrante.

### Lo que valoran y lo que critican
- [Opinión, IGN] 8,8: el miedo de esperar a que te encuentren; pero la 2,5D vuelve irritantes algunos saltos, hay
  muertes de ensayo y error y los puntos de control son irregulares.
- [Opinión, PC Gamer LN] 78: a veces te descubren de forma «arbitrary», y las búsquedas de los adultos parecen de
  guion.
- [Opinión, Eurogamer LN] Cuesta distinguir el primer plano del fondo, y uno se cae sin querer.
- [Hecho, Wikipedia LN; Wikipedia LN2] Metacritic entre 78 y 83 (el primero) y entre 79 y 83 (el segundo).

### Principios para La caja viva
1. **El vigilante a la vista; importa si te ha visto (B).** El ojo de la caja siempre se ve; la tensión es si te
   nota. Su detección nunca debe parecer arbitraria (ver «Lo mejor del bloque», 1). [Interpretación]
2. **Distraerlo con otro sentido (E).** Además de la lámpara (luz), un ruido (la tapa de la tetera, una campanilla
   de viento) hace que mire allí unos segundos. [Interpretación]
3. **La amenaza como herramienta (D).** Como apartar la linterna para que el maniquí se levante: en el nivel 3 se
   dirige la mirada del ojo a propósito, porque lo que mira se queda quieto. [Interpretación]
4. **Cajones como escalera (F).** Abrir los cajones del costado a distintas alturas forma una escalera por la que baja
   rodando una pieza desde arriba. [Interpretación]
5. **Los ojos que delatan (G).** Como los de Six, el ojo de la caja mira de reojo lo importante cuando te atascas.
   [Interpretación]

### Riesgo de parecido
Bajo-medio con los maniquíes (el tópico de «se congelan si los miras»): nuestra mirada es la de un objeto vivo y
sujeta cosas, no congela enemigos. El tono se queda en tétrico, sin sustos ni sangre. [Interpretación]

### Fuentes
- **Wikipedia LN:** [*Little Nightmares*, Wikipedia](https://en.wikipedia.org/wiki/Little_Nightmares)
- **PC Gamer LN:** [Samuel Roberts, reseña de *Little Nightmares* (78/100)](https://www.pcgamer.com/little-nightmares-review/)
- **IGN:** [Joe Skrebels, reseña de *Little Nightmares* (8,8)](https://www.ign.com/articles/2017/04/27/little-nightmares-review)
- **Eurogamer LN:** [Edwin Evans-Thirlwell, reseña de *Little Nightmares*](https://www.eurogamer.net/little-nightmares-review)
- **GamingBolt:** [«Little Nightmares Interview: Into The Maw»](https://gamingbolt.com/little-nightmares-interview-into-the-maw)
- **Wikipedia LN2:** [*Little Nightmares II*, Wikipedia](https://en.wikipedia.org/wiki/Little_Nightmares_II)
- **PC Gamer LN2:** [Stacey Henley, reseña de *Little Nightmares 2* (76/100)](https://www.pcgamer.com/little-nightmares-2-review/)
- **Gamer Walkthroughs:** [*Little Nightmares 2*, capítulo 3: el hospital](https://gamerwalkthroughs.com/little-nightmares-2/chapter-3-hospital/)

---

## Lo mejor del bloque: 12 principios para La caja viva

Todo lo de esta sección es **[Interpretación]**: conclusiones nuestras sobre los hechos y opiniones de las fichas,
que llevan sus fuentes. Son propuestas: el usuario decide cuáles entran (y cómo afectan al nivel 3 y al final, que
siguen en propuesta).

### Resumen

| # | Principio | De dónde sale | Letra | Riesgo de parecido |
|---|---|---|---|---|
| 1 | El vigilante legible, con aviso antes de reaccionar | Inside, Little Nightmares, Portal | B | Bajo |
| 2 | Distraer al vigilante con otro sentido | Little Nightmares (y II) | E | Bajo |
| 3 | La mirada como herramienta: lo que estorbaba, sirve | Little Nightmares II, Baba Is You, Portal, Antichamber | D | Bajo-medio |
| 4 | Aprender sin poder saltarse la idea | Portal, Portal 2, Limbo | A | Ninguno |
| 5 | Un vocabulario visual propio que se repite y luego se retira | Portal, Monument Valley, Q.U.B.E. | B | Bajo |
| 6 | La confianza: lo bueno es fácil de ejecutar y cada error se distingue | Limbo, Antichamber, Superliminal | B | Ninguno |
| 7 | Todo lo necesario, a mano; lo que no es pieza no lo parece | Inside, Little Nightmares II, Talos, Portal | A | Ninguno |
| 8 | La caja se delata: la pista sale del propio vigilante | Little Nightmares (y II), Talos (y 2), Portal | G | Bajo |
| 9 | Pensar con las manos: acciones baratas, reversibles e inmediatas | Tetris, Viewfinder, Baba Is You, Portal 2 | A | Ninguno |
| 10 | Un ritmo que se oye: aviso, silencio y consecuencia | Inside, Portal | E | Bajo |
| 11 | Una tarea incompleta siempre a la vista | Tetris, Monument Valley, Talos | G | Ninguno |
| 12 | Perspectiva y escala propias: la sombra a escala y la vista desde la cara | Superliminal, Monument Valley, Antichamber, Little Nightmares | H | Bajo-medio / medio |

### 1. El vigilante legible, con aviso antes de reaccionar
- **De dónde sale.** En *Inside*, la luz del dron parpadea antes de castigar a quien se desacompasa. En *Little
  Nightmares*, sabes dónde está el depredador y lo que preocupa es que te vea. En *Portal*, el láser de la torreta
  marca hacia dónde mira.
- **Por qué funciona.** El miedo útil es el de ser visto, no el de no entender las reglas. Cuando la detección parece
  «arbitrary» (crítica de PC Gamer a *Little Nightmares*), se rompe la confianza.
- **Cuándo usarlo.** En todo paso en que el ojo bloquea; es el corazón de nuestra regla.
- **Cómo transformarlo (B).** Tres estados del ojo que se leen de un vistazo:
  - **duerme**: el párpado caído;
  - **vigila**: abierto, con un brillo tenue sobre lo que mira (nuestra versión del láser de la torreta);
  - **te ha visto**: la pupila clavada en la mano y el aliento contenido (la resistencia que ya existe).
  - Entre «vigila» y «te ha visto», un aviso de un segundo: el párpado se entorna. Nunca se salta de dormir a resistir
    sin aviso.
- **Riesgo de parecido.** Bajo: el aviso graduado es un recurso común del sigilo; la expresión (un párpado tallado
  que se entorna) es nuestra.

### 2. Distraer al vigilante con otro sentido
- **De dónde sale.** El conserje ciego de *Little Nightmares* oye: un objeto lanzado lo manda a otra parte. Los
  maniquíes de *Little Nightmares II* se rigen por la luz.
- **Por qué funciona.** Da al jugador una herramienta activa contra la amenaza. Cada sentido es una regla nueva sin
  necesidad de una mecánica nueva.
- **Cuándo usarlo.** Cuando la lámpara ya esté aprendida (después del nivel 1).
- **Cómo transformarlo (E: variable nueva, el oído).** Golpear la tapa de la tetera o tocar una campanilla de viento
  junto al shoji hace que el ojo mire hacia allí unos tres segundos; la lámpara distrae mientras se mueve. Dos
  distracciones de duración distinta permiten puzles de orden (primero el ruido, luego la luz). La campanilla
  (la «voz») del nivel 3 propuesto puede ser este sonido.
- **Riesgo de parecido.** Bajo: distraer con ruido es del género; aquí quien oye es una caja.

### 3. La mirada como herramienta: lo que estorbaba, sirve
- **De dónde sale.** En *Little Nightmares II* hay que apartar la linterna a propósito para que un maniquí se
  levante. En *Baba Is You*, romper MURO ES PARAR abre el camino. En *Portal*, tras escapar, una sala vieja se
  resuelve «mal» a propósito. En *Antichamber*, andar hacia atrás abre la salida.
- **Por qué funciona.** Pasar de obstáculo a herramienta es el «¡ajá!» más fuerte de todo el bloque. Coincide con
  el patrón de la biblia (§7.1: presentar, ampliar, invertir, combinar).
- **Cuándo usarlo.** En el nivel 3, después de que la regla se haya presentado (nivel 1) y ampliado (nivel 2).
- **Cómo transformarlo (D: invertido).** El nivel 2 enseña que lo que mira el ojo no se mueve. En el nivel 3 se usa
  a favor: un disco con muelle que gira solo, o un cajón que se cierra solo, se queda quieto si el ojo lo mira. Con
  la lámpara o el espejo de mano se le hace mirar justo eso mientras se trabaja en otra cosa. Conviene enseñarlo
  antes en una escena sin presión (el ojo mira una polilla y la deja quieta en el aire), como hace *Portal 2*.
- **Riesgo de parecido.** Bajo-medio: los maniquíes de *Little Nightmares II* (y el tópico de «se congela si lo
  miras»). Diferencia: aquí la mirada es la del objeto vivo y sujeta cosas; no detiene enemigos.

### 4. Aprender sin poder saltarse la idea
- **De dónde sale.** La sala 01 de *Portal* está hecha para que ir a tientas lleve a un callejón sin salida; en la
  04, un cristal impide el atajo. *Portal 2* alterna salas «de lista» (probar sin riesgo) y de combinación. En
  *Limbo*, una escena deja al niño junto a un objeto que se arrastra hasta que lo entiende.
- **Por qué funciona.** Si alguien pasa un paso sin entenderlo, el siguiente, que se apoya en él, se vuelve
  injusto. Valve dice que así igualó la curva de aprendizaje.
- **Cuándo usarlo.** En cada regla nueva.
- **Cómo transformarlo (A).** Tres tiempos por regla: un momento sin riesgo en que se ve funcionar; un paso que solo
  se resuelve entendiéndola; una combinación. A la prueba automática (`ilustrada/prueba/`) se le puede añadir un
  modo que toque al azar durante unos minutos para comprobar que nada se abre por casualidad.
- **Riesgo de parecido.** Ninguno.

### 5. Un vocabulario visual propio que se repite y luego se retira
- **De dónde sale.** En *Portal*, un bloque que sobresale sobre un suelo de damero significa «lánzate», hasta que
  se quita. En *Monument Valley*, los círculos indican que una pieza se desliza y en qué dirección, y la parte que
  gira es algo más clara. En *Q.U.B.E.*, cada color hace siempre lo mismo.
- **Por qué funciona.** El jugador aprende a leer el objeto y la exploración pasa a ser deducción.
- **Cuándo usarlo.** Desde el nivel 1, en todas las piezas que se mueven.
- **Cómo transformarlo (B).** Una gramática de marquetería japonesa: muesca para la uña = deslizar; borla o cordón =
  tirar; anillo dorado = girar; madera algo más clara = se mueve; laca negra = nunca se mueve. Con apoyo en los
  niveles 1 y 2; en el 3, alguna pieza sin señal, como premio a la confianza ganada.
- **Riesgo de parecido.** Bajo: las expresiones son propias.

### 6. La confianza: lo bueno es fácil de ejecutar y cada error se distingue
- **De dónde sale.** Jeppe Carlsen (*Limbo*): si la idea buena falla un par de veces, el jugador la descarta y tarda
  mucho en volver a ella; y los caminos equivocados deben verse equivocados. Eurogamer sobre *Antichamber*: no saber
  si estás atascado, engañado o sin la herramienta es «the wrong kind of frustration». *Superliminal*: un pasillo
  que se abre sin que se entienda por qué.
- **Por qué funciona.** El jugador solo experimenta si confía en lo que el juego le responde.
- **Cuándo usarlo.** Siempre; sobre todo en táctil, donde un gesto «casi bueno» es fácil.
- **Cómo transformarlo (B).** Tres respuestas distintas y fijas:
  - **«te ve»**: la caja contiene el aliento y mira la mano;
  - **«falta algo»**: la cerradura suena hueca y el hueco brilla un instante;
  - **«así no»**: la pieza asoma en su dirección buena.
  - Y gestos con márgenes amplios: dirección aproximada y recorrido corto bastan.
- **Riesgo de parecido.** Ninguno.

### 7. Todo lo necesario, a mano; lo que no es pieza no lo parece
- **De dónde sale.** En *Inside*, está claro qué pertenece al puzle y las piezas clave están cerca. En *Little
  Nightmares II*, los puzles son pequeños: «you always know the solution is here somewhere». En *The Talos
  Principle*, las herramientas están en el escenario. En *Portal*, quitaron el desorden, y unas pasarelas
  decorativas que atraían a todos se volvieron necesarias.
- **Por qué funciona.** Se experimenta más cuando se confía en que las piezas están cerca.
- **Cuándo usarlo.** Al cerrar cada nivel, y al añadir decoración viva.
- **Cómo transformarlo (A).** Cada nivel declara su «mesa de trabajo»: la caja y dos o tres objetos de la sala. La
  decoración viva responde al dedo de forma ambiental (ondas, polvo, polillas), pero nunca asoma ni hace clic. Si en
  las pruebas alguien insiste en un adorno, o se vuelve paso o se le quita el brillo.
- **Riesgo de parecido.** Ninguno.

### 8. La caja se delata: la pista sale del propio vigilante
- **De dónde sale.** En *Little Nightmares*, los ojos de Six van a los objetos útiles, y en el II Six da pistas. En
  *The Talos Principle*, los mensajeros dan una pista de un solo uso; en el 2, se puede saltar un puzle con algo
  hallado explorando. En *Portal*, la voz solo explica el concepto más difícil.
- **Por qué funciona.** Una pista que sale del mundo no rompe el clima. Y aquí el antagonista es un ser vivo: puede
  tener nervios.
- **Cuándo usarlo.** Tras un rato sin avanzar.
- **Cómo transformarlo (G: unido a la narrativa).** A los tres minutos sin progreso (el «aviso suave» de la
  DECISIÓN 26, cuya opción recomendada es la B), el ojo mira de reojo, nervioso, hacia lo que protege. Si el atasco
  sigue, entran las pistas escritas de la biblia (§6). Opcional: ofrendas escondidas en la sala para pedirle un paso
  a la caja (versión *tsukumogami* del fuego de Prometeo).
- **Riesgo de parecido.** Bajo.

### 9. Pensar con las manos: acciones baratas, reversibles e inmediatas
- **De dónde sale.** En *Tetris*, se gira la pieza en pantalla para pensar (Kirsh y Maglio). *Viewfinder* rebobina y
  *Baba Is You* deshace sin castigo. *Portal 2* cambió las bolas de energía por láseres porque dan feedback
  inmediato.
- **Por qué funciona.** Probar en el mundo es más rápido y fiable que imaginar.
- **Cuándo usarlo.** En todas las piezas que se manipulan.
- **Cómo transformarlo (A).** Girar la caja hija y la cajita roja sin coste ni espera; nada se pierde ni se rompe;
  ninguna animación bloquea el siguiente gesto; la pieza sigue al dedo 1:1, con muelle.
- **Riesgo de parecido.** Ninguno.

### 10. Un ritmo que se oye: aviso, silencio y consecuencia
- **De dónde sale.** La onda de *Inside*: sonido y destello, silencio, onda. La fila de *Inside*, al compás. El tictac
  de *Portal* cuando la puerta está abierta.
- **Por qué funciona.** El ritmo convierte la amenaza en algo que se aprende, no en azar.
- **Cuándo usarlo.** En uno o dos pasos de la línea, nunca como prueba de reflejos.
- **Cómo transformarlo (E: variable nueva, el aliento).** La respiración de la caja deja de ser solo ambiente:
  inspira (sonido), contiene (silencio), espira. En un paso del nivel 3 o del final, algo solo cede al espirar (la
  junta se afloja y deja salir humo). Siempre con su señal visual (el humo) y sin fallo duro: si no sale, se espera
  al siguiente aliento.
- **Riesgo de parecido.** Bajo.

### 11. Una tarea incompleta siempre a la vista
- **De dónde sale.** El efecto Zeigarnik en *Tetris* (según Tom Stafford). En *Monument Valley*, cada nivel trae algo
  nuevo. En *The Talos Principle*, las puertas que piden sigilos se ven antes de tenerlos.
- **Por qué funciona.** Lo inacabado se queda en la memoria y llama a volver.
- **Cuándo usarlo.** Entre niveles y dentro de cada uno.
- **Cómo transformarlo (G).** La cara con sus huecos (cuerno, cuenca, labios) siempre a la vista; cada nivel siembra
  la cerradura del siguiente antes de su llave (el hueco de la ficha de shōgi ya lo hace); la tarjeta de nivel
  enseña lo que falta.
- **Riesgo de parecido.** Ninguno.

### 12. Perspectiva y escala propias: la sombra a escala y la vista desde la cara
- **De dónde sale.** En *Superliminal*, el tamaño aparente se vuelve real y los trampantojos se completan desde un
  punto. En *Monument Valley*, los caminos se unen al alinearse. En *Antichamber*, el espacio responde a la mirada.
  En *Little Nightmares*, la escala de un niño convierte los muebles en montañas.
- **Por qué funciona.** «Desde aquí no se entiende y desde allí encaja» da el «¡ajá!» más visual del género, y las
  vistas fijas de La caja viva lo hacen barato.
- **Cuándo usarlo.** Una vez por línea, como sorpresa.
- **Cómo transformarlo (H: mecánica nueva).** Dos versiones, de menos a más riesgo:
  - **La sombra a escala.** Acercar o alejar la lámpara *andon* agranda o encoge en el shoji la sombra de un objeto
    pequeño (el cuerno, la ficha). Cuando la sombra coincide con una silueta pintada en el papel, el ojo reacciona a
    la sombra como si fuera real: se asusta y mira, o cree ver lo que busca. Une la escala con la regla del ojo.
  - **Desde la cara.** Un dibujo de marquetería repartido entre la caja, la mesa y el shoji que solo se completa
    visto desde donde está la cara (por ejemplo, con el espejo de mano del nivel 3). Completo, dice el orden de las
    puertecitas.
- **Riesgo de parecido.** Bajo-medio en la sombra; **medio** en la vista desde la cara (anamorfosis de
  *Superliminal* y cifras que solo se leen desde un ángulo en The Room). Prohibido: encoger algo y entrar en ello,
  lentes, y fotos que cambian el espacio.

### También merecen la pena (no entran en los doce)
- **Respiro escenificado** entre pasos densos (*Portal 2*: el viaje por el embudo). La subida de la caja hija ya lo
  es; uno por nivel.
- **La regla tallada como objeto** (*Baba Is You*) para el final «El corazón»: pictogramas que giran en su sitio.
  Riesgo medio y coste alto.
- **Cajones como escalera** (*Little Nightmares*) para un paso del costado.
- **Madre e hija** (*Monument Valley 2*): la caja hija como hija de la caja grande.
- **Sorpresa tras el dominio** (*Portal 2*): la llave conocida que, en el nivel 3, hace que la caja dé la vuelta sola.

### Errores que este bloque enseña a evitar
- Castigar con ensayo y error o con muertes instantáneas (*Limbo*, *Little Nightmares*).
- Subir la dificultad con modificadores baratos: oscuridad, puzles repetidos con piezas cambiadas de sitio
  (*Q.U.B.E.*).
- Cerraduras repetidas como relleno (los tetrominós de *The Talos Principle*, según Andrew Plotkin).
- Moralejas después de resolver (los carteles de *Antichamber*).
- Cambiar las reglas sin avisar: el jugador deja de confiar (*Antichamber*).
- Física que «ayuda» y se nota (*Q.U.B.E.*).
- Pasos que funcionan sin que se entienda por qué (*Superliminal*).
- Copiar la estética de la referencia (*Q.U.B.E.* frente a *Portal*).
- Contenido de pago que se percibe como un recorte del juego (las reseñas de una estrella de *Monument Valley*).

### Avisos para las propuestas actuales
- **Nivel 3, el biombo:** parecido bajo-medio con «La Caja» de *Monument Valley* (una caja que se abre por partes).
  Mantener la apertura por la regla de la mirada, sin luces en las esquinas y sin nadie caminando dentro.
- **Nivel 3, la mirada que sujeta (principio 3):** parecido bajo-medio con los maniquíes de *Little Nightmares II*.
  Mantener que sea la caja la que mira y que lo mirado sean objetos.
- **Nivel 3, la tinta invisible:** no sale de este bloque, pero roza el ocular de The Room (anexo B). Sería más
  seguro que la luz del ojo descubra por dónde pasa (un rastro, un orden) y no una capa entera de información.
