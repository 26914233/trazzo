# Jugadores y principios de diseño: investigación transversal para La caja viva

**Fecha:** 05-10-2026. **Para qué:** saber qué valoran y qué odian los jugadores del género, qué dicen los
diseñadores sobre los buenos puzles, y convertirlo en reglas concretas para La caja viva.

**Marcas** (las del contexto común, `00_contexto_para_investigar.md`):
- **[Hecho]**: lo dice una fuente (con enlace) o sale de nuestra muestra de reseñas (método en el §0).
- **[Opinión]**: lo dice un jugador o un crítico (con enlace).
- **[Interpretación]**: conclusión nuestra. Las **propuestas** son interpretación y las decide el usuario.

Las citas van en su idioma original, literales y cortas; detrás, con una flecha (→), lo que dicen en español.

---

## 0. Método, muestra y límites

**Reseñas de Steam** [Hecho, muestra propia]:
- 24 juegos del género y vecinos: The Room 1-3, Old Sins y la versión de realidad virtual; The House of Da
  Vinci 1-3; Escape Simulator 1-2; Myst (2021) y Riven (2024); The Witness; Tiny Room Stories; Cube Escape
  Collection, Rusty Lake Paradise y The Past Within; Escape Academy; Doors: Paradox; The Talos Principle; Gorogoa;
  Machinarium; Samorost 3, y Monument Valley.
- **25.613 reseñas en inglés:** 20.828 positivas y 4.785 negativas. Se bajaron con la API pública de reseñas de
  Steam (las más útiles y las más recientes). Las negativas se sobremuestrearon a propósito.
- Por eso los porcentajes se comparan **dentro** de cada grupo (positivas con positivas, negativas con negativas).

**Reseñas de la App Store** (EE. UU.) [Hecho, muestra propia]:
- 16 apps (las de arriba que existen en iOS, más Boxes: Lost Fragments y Faraway).
- 8.682 reseñas: 7.243 de 4-5 estrellas, 892 de 1-2 y 547 de 3. Se bajaron del canal RSS público de Apple.
- La App Store no da enlace a cada reseña: se cita la app, el autor y la fecha.

**Cómo se contó:**
- Se buscaron palabras clave en inglés: por ejemplo, «frustrat», «tedious», «pixel hunt» o «clunky».
- Se comprobó a mano una muestra de frases de cada tema. Ejemplo: «too hard» en las reseñas positivas casi
  siempre es «not too hard» (el 66 % de las 406 frases).
- Un recuento así **mide de qué se habla, no cuánta gente lo piensa**. Sirve para ver patrones, no para dar cifras
  del mercado.

**Fuentes de diseño:**
- Se leyeron en su original siempre que se pudo: las entrevistas, el comentario de desarrolladores de Portal y
  Portal 2, los ensayos de Ron Gilbert y Graham Nelson, la guía de hápticos de Android y Apple, y los artículos de
  Nicholson.
- Cuando el original ya no existe o estaba bloqueado, se usó Wikipedia como índice y se marca **«vía Wikipedia»**.

**Límites (importantes):**
- El buscador web de la sesión estaba agotado. No se usaron otros buscadores para no saltarse ese límite: se
  leyeron páginas concretas y las que enlazan sus artículos.
- **Reddit, YouTube y archive.org bloquean** las peticiones desde este contenedor. No hay citas de Reddit.
- **Los vídeos de Game Maker's Toolkit (Mark Brown) no se pudieron leer.** La transcripción por vidIQ cuesta 5
  créditos por vídeo, y quedan 48 que no se renuevan: no se gastaron sin permiso del usuario. La lista de vídeos
  pendientes está en el §8.
- Las charlas de la GDC Vault son vídeo (la de The Room, además, solo para socios): no se pudieron ver. La de Myst
  se cita a través de Wikipedia.
- **Bart Bonte:** solo se encontró lo que dice él mismo en sus fichas de tienda, más reseñas de sus juegos.
- **Jesse Schell** («The Art of Game Design») y **Scott Kim**: no se encontraron textos accesibles. No se citan.

---

## 1. Jugadores: qué les satisface, frustra, confunde, recuerdan y les cansa

### 1.1 Hallazgos con números

**Tabla 1. Temas en las reseñas de Steam** [Hecho, muestra propia; % de reseñas que mencionan el tema]

| Tema (palabras buscadas) | En positivas | En negativas | Veces más en negativas |
|---|---|---|---|
| Poco intuitivo («unintuitive», «counterintuitive») | 0,1 % | 1,4 % | **10** |
| Repetitivo o tedioso | 1,4 % | 9,4 % | **6,9** |
| Pixel hunting (buscar el píxel que responde) | 0,2 % | 1,2 % | **6,1** |
| Prueba y error, fuerza bruta, «tocar todo» | 0,6 % | 3,5 % | **6,1** |
| Cámara | 0,5 % | 2,4 % | 5,0 |
| Fallos técnicos | 2,0 % | 9,1 % | 4,6 |
| Volver atrás (*backtracking*) | 0,3 % | 1,4 % | 4,6 |
| Controles («control», «clunky», «awkward») | 2,1 % | 9,0 % | 4,3 |
| Ilógico u oscuro («obtuse», «makes no sense») | 1,2 % | 4,6 % | 3,9 |
| Frustración | 3,0 % | 9,5 % | 3,1 |
| Demasiado fácil | 1,4 % | 4,1 % | 2,9 |
| Confuso | 1,0 % | 2,2 % | 2,2 |
| Pistas | 4,8 % | 7,2 % | 1,5 |
| Satisfactorio | 3,3 % | 3,0 % | 0,9 |
| Atmósfera | 4,6 % | 3,2 % | 0,7 |
| Inquietante, terror | 3,4 % | 2,0 % | 0,6 |
| Memorable | 0,6 % | 0,4 % | 0,6 |
| «Demasiado difícil» (casi siempre «no demasiado difícil») | 2,4 % | 1,5 % | 0,6 |

**Tabla 2. Qué pesa en las reseñas negativas de cada serie** [Hecho, muestra propia; % de las reseñas negativas
del grupo]

| Grupo (negativas) | Frustración | Repetitivo | Pistas | Ilógico | Controles | Cámara | Fallos | Fácil |
|---|---|---|---|---|---|---|---|---|
| The Room, las 5 (1.207) | 10 | 9 | 10 | 4 | 9 | 4 | 9 | 5 |
| House of Da Vinci 1-3 (435) | 20 | 11 | 18 | 8 | **31** | 9 | 8 | 2 |
| Escape Simulator 1-2 (607) | 5 | 2 | 5 | 1 | 7 | 0 | **16** | 2 |
| Myst y Riven, remakes (277) | 14 | 10 | 6 | 8 | 11 | 3 | **17** | 4 |
| The Witness (258) | 14 | **16** | 7 | 2 | 3 | 1 | 3 | 2 |
| Rusty Lake: Cube, Paradise, Past Within (389) | 4 | 9 | 1 | 6 | 2 | 0 | 4 | 7 |

**Tabla 3. App Store** [Hecho, muestra propia; % de reseñas que lo mencionan]

| Tema | 4-5 estrellas | 1-2 estrellas |
|---|---|---|
| Precio, pago o anuncios | 13,8 % | **28,9 %** |
| Fallos, cierres, congelado | 3,5 % | **17,0 %** |
| Frustración | 4,2 % | 9,8 % |
| Pistas | 9,3 % | 9,2 % |
| Pantalla pequeña, «tiny» | 0,8 % | 1,6 % |
| Controles, zoom, arrastrar, girar | 2,5 % | 7,8 % |
| Historia o final | 16,0 % | 6,2 % |
| Atmósfera, inquietante | 4,7 % | 0,7 % |
| Vibración o hápticos | 0,0 % | 0,1 % (1 reseña) |

### 1.2 Lo satisfactorio: el objeto que pesa y la idea que encaja

- [Opinión] «Every slide of a bolt, every click of a dial, opening of a hatch, and insertion of a key feels
  weighted and purposeful.» → cada cerrojo, dial y llave pesa y tiene un propósito.
  ([reseña de The Room](https://steamcommunity.com/profiles/76561199356031988/recommended/288160/))
- [Opinión] «This game understands that 70% of the fun of escape rooms isn't solving puzzles, it's the tactile joy
  of turning a key in a lock and feeling it pop open.» → buena parte de la diversión es el gusto táctil de girar una
  llave y notar que cede.
  ([reseña de Escape Simulator](https://steamcommunity.com/profiles/76561198097602712/recommended/1435790/))
- [Opinión] «You turn keys with a satisfying thunk, slide drawers out and feel their weight, crank dials around and
  watch pieces turn in response.» → la llave hace «zonk», el cajón pesa y el dial mueve piezas que se ven.
  ([Nissa Campbell, TouchArcade, 2012](https://toucharcade.com/2012/09/26/the-room-for-ipad-review/))
- [Opinión] «I loved the satisfaction of completing a puzzle and seeing the wonderful contraptions come to life.»
  → la recompensa es ver el artilugio cobrar vida.
  ([reseña de The House of Da Vinci 2](https://steamcommunity.com/profiles/76561198017076824/recommended/1259840/))
- [Opinión] «If you enjoy figuring things out on your own though, it's incredibly satisfying.» → el placer está en
  averiguarlo uno solo. ([reseña de The Witness](https://steamcommunity.com/profiles/76561199121411524/recommended/210970/))
- [Opinión] «But oh, that intense satisfaction when your brain goes “click”!» → el «clic» mental.
  (ButMadNNW, 25-01-2018, [The Room: Old Sins en la App Store](https://apps.apple.com/us/app/id1286676015))

**Lo que se ve en las citas** [Interpretación]: la satisfacción tiene **dos fuentes** que los jugadores nombran
por separado: la **física** (peso, sonido y respuesta del mecanismo) y la **mental** (entender). Los juegos mejor
valorados parecen dar las dos en cada paso.

### 1.3 Lo frustrante: no saber qué se puede tocar ni si se ha hecho bien

- [Opinión] «I think my biggest frustration was when presented with something with no indication that it was
  movable in a particular direction.» → lo peor: algo que se mueve sin ninguna señal de hacia dónde.
  ([reseña de la serie The Room](https://steamcommunity.com/profiles/76561197990154923/recommended/1361320/))
- [Opinión] «Eventually I'd give up, ask for a hint, and be told to do something that I'm sure I've already tried
  before, but now the game will actually let me do it.» → la pista dice lo que ya probó, pero antes el juego no le
  dejaba. ([reseña de The House of Da Vinci 3](https://steamcommunity.com/profiles/76561197969417125/recommended/1603640/))
- [Opinión] «Frequently frustrated by thinking I had tried a key or to move something only to find that I hadn't
  double clicked enough times to fully zoom in.» → creía haber probado la llave, pero no estaba lo bastante cerca.
  ([reseña de The House of Da Vinci 2](https://steamcommunity.com/profiles/76561198173907410/recommended/1259840/))
- [Opinión] «I spent more time randomly clicking or moving the camera around hoping to find a hidden button or panel
  than actually solving things in a satisfying way.» → más tiempo buscando botones escondidos que resolviendo.
  ([reseña de The House of Da Vinci](https://steamcommunity.com/profiles/76561198339039799/recommended/522470/))
- [Opinión] «Don't take control away from the player, it feels bad and frustrating especially if you're in the
  middle of solving a puzzle.» → no quitar el control a mitad de un puzle.
  ([reseña de Escape Simulator 2](https://steamcommunity.com/profiles/76561198024959255/recommended/2879840/))
- [Opinión] «Some puzzle solution keys are not intuitive or consistent with the other puzzles in the same sequence
  of puzzles.» → una solución que rompe la regla de su propia serie.
  ([reseña de The Witness](https://steamcommunity.com/profiles/76561198015978998/recommended/210970/))

[Hecho, tabla 2] En The House of Da Vinci, **casi un tercio de las reseñas negativas (31 %) habla de los
controles**. Es la queja más concentrada de toda la muestra. En Escape Simulator y en los remakes de Myst y Riven,
lo que más pesa son los fallos técnicos (16-17 %).

### 1.4 Lo intuitivo y lo confuso: perderse *entre* puzles, no *dentro*

- [Opinión] «Generally not because I was stuck on a puzzle - they're all fairly self-contained and intuitive, which
  is great - but because I was moving between puzzles and there was no obvious link that connected one to the
  next.» → no se atasca dentro de un puzle, sino al pasar de uno a otro.
  ([reseña de Old Sins](https://steamcommunity.com/profiles/76561197990154923/recommended/1361320/))
- [Opinión] «It's rarely clear what you can zoom in on, making it unintuitive to figure out what options you really
  have to solve each puzzle.» → no se sabe dónde se puede acercar.
  ([reseña de Gorogoa](https://steamcommunity.com/profiles/76561198343947871/recommended/557600/))
- [Opinión] «...it's easy to get lost with no idea what to do next, what are clues and to which puzzles they
  belong.» → no sabe qué es pista ni de qué puzle.
  ([reseña de Tiny Room Stories](https://steamcommunity.com/profiles/76561197970326602/recommended/1259640/))
- [Opinión] «...in The Room 3, half of the time you are confronted with strange mechanisms that you have no idea what
  they do.» → mecanismos que no dicen para qué sirven.
  ([reseña de The Room Three](https://steamcommunity.com/profiles/76561198051701050/recommended/456750/))
- [Opinión] «...you either figure it out no thanks to the game or figure it out by accident without even
  understanding the mechanic.» → lo resolvió por accidente, sin entenderlo.
  ([reseña de The Room](https://steamcommunity.com/profiles/76561199234585667/recommended/288160/))

### 1.5 Lo memorable

- [Opinión] «The Room Three was the most memorable puzzle game I played this year.»
  ([reseña de The Room Three](https://steamcommunity.com/profiles/76561198162815522/recommended/456750/))
- [Opinión] «There were a couple of set-piece moments where my jaw hit the floor.» → dos o tres momentos de
  boca abierta. ([reseña de Riven](https://steamcommunity.com/profiles/76561197992080313/recommended/1712350/))
- [Opinión] «Wow, I did not expect to get this many chills playing a puzzle game.» → escalofríos en un juego de
  puzles. ([reseña de Gorogoa](https://steamcommunity.com/profiles/76561198152415480/recommended/557600/))
- [Opinión] «I absolutely LOVED the mechanic of breaking the sigils/glass to enter the rooms, it was both beautiful
  and satisfying...» → romper el sello para entrar fue bello y satisfactorio.
  (OG User Disappointed, 21-07-2018, [Old Sins en la App Store](https://apps.apple.com/us/app/id1286676015))
- [Opinión] «There were some memorable dioramas with explosions, and entertaining outcomes to puzzle solutions, but
  the bar didn't remain high for the whole experience.» → lo memorable son las consecuencias vistosas, y se nota
  cuando bajan. ([reseña de Doors: Paradox](https://steamcommunity.com/profiles/76561198017076824/recommended/1622770/))

[Hecho, tabla 1] «Memorable», «atmósfera» e «inquietante» aparecen más en las positivas que en las negativas, y los
«jump scares» salen poco en las dos (0,4 %). [Interpretación] El tono tétrico **suma**, y nadie echa de menos los
sustos.

### 1.6 Lo repetitivo

- [Opinión] «Many of the puzzles are repetitive and mind numbing.» (120 votos de utilidad)
  ([reseña de Rusty Lake Paradise](https://steamcommunity.com/profiles/76561198074751147/recommended/744190/))
- [Opinión] «Becomes samey and boring when you realize that unlocking stuff will just lead to more stuff to unlock
  and that the hints/solutions are becoming less and less logically connected.» → cansa cuando abrir algo solo
  lleva a más cosas que abrir. ([reseña de Tiny Room Stories](https://steamcommunity.com/profiles/76561197970326602/recommended/1259640/))
- [Opinión] «...some puzzles boil down to mindless repetition after you figure out the trick.» → entendido el
  truco, queda la repetición mecánica. ([reseña de Myst](https://steamcommunity.com/profiles/76561197995637959/recommended/1255560/))
- [Opinión] «The hub features a couple of puzzle types that repeat enough to wear out their welcome, and there's one
  section where you're doing step-by-step navigation of a 3D maze that just felt utterly pointless to me.»
  → tipos de puzle repetidos y un laberinto de relleno.
  ([Shaun Musgrave, TouchArcade, 2015](https://toucharcade.com/2015/11/05/the-room-three-review/))
- [Opinión] «...stick your inventory items into every space you think they might go until it works, syndrome.» → el
  vicio de probar cada objeto en cada hueco.
  ([reseña de The Room VR](https://steamcommunity.com/profiles/76561197983536968/recommended/1104380/))

### 1.7 En el móvil

- [Opinión] «Navigating the fussy, unintuitive controls is much more difficult than any of the actual puzzles.» →
  los controles cuestan más que los puzles. (JustLetMePost73646, 20-05-2020,
  [The House of Da Vinci en la App Store](https://apps.apple.com/us/app/id1062515791))
- [Opinión] «You may have clicked the area multiple times but not hit the exact tiny thing you can't really see.» →
  la diana diminuta. (BigCringeman, 07-02-2022, [Tiny Room Stories](https://apps.apple.com/us/app/id1459520173))
- [Opinión] «Small screen, finger touch not always accurate.» y, en la misma reseña, «the hint/help function should
  know what you have already accomplished» → la pista debería saber lo que ya hiciste. (Songs&Stories, 28-08-2021,
  [The Room Pocket](https://apps.apple.com/us/app/id573156739))
- [Opinión] «There are “hints” but they are very intentionally vague and really useless.» → pistas tan vagas que no
  sirven. (STUMPYMD, 08-07-2018, [The Room Pocket](https://apps.apple.com/us/app/id573156739))
- [Opinión] «I love how the hints help you but don't just tell you the answer.» (SpaceRaccoon2637, 25-08-2023) frente
  a «You have to watch an ad for every single hint...» (Max's Musicbox, 11-12-2022). Las dos son de
  [yellow, de Bart Bonte](https://apps.apple.com/us/app/id1219259689).
- [Opinión] «I know exactly what needs to be done and what the rules are, but I am not physically capable of
  manipulating the fiddly controls within the very narrow tolerance...» → sabe la solución, pero el gesto pide más
  precisión de la que tiene. (Kynard, 04-08-2026, [Faraway](https://apps.apple.com/us/app/id1202839666))
- [Opinión] «...the circle puzzle just vibrated until it randomly locked in place.» → el puzle de anillos parecía
  encajar al azar. (We Are Dust, 08-03-2019, [The Room Pocket](https://apps.apple.com/us/app/id573156739))

### 1.8 Patrones

1. **La satisfacción es doble: física y mental** [Interpretación; §1.2]. Falla el juego que solo da una de las
   dos.
2. **La primera queja es de interacción, no de dificultad** [Hecho, tablas 1-3]. Controles (9 % de las negativas)
   y fallos (9 %) superan de lejos a «demasiado difícil», que apenas aparece como queja (1,5 %).
3. **«Demasiado fácil» y «corto» pesan más que «demasiado difícil»** [Hecho, tabla 1]. Las positivas alaban un reto
   «not too hard». El público quiere atascarse un poco, no mucho.
4. **Lo intolerable es no saber qué es interactivo ni en qué dirección se mueve** [Opinión, §1.3]. Es la familia de
   quejas del pixel hunting.
5. **El juego que no deja hacer lo que el jugador ya intentó** (por zoom, por orden o por estado) se vive como
   injusto [Opinión, §1.3].
6. **Perderse entre puzles duele más que atascarse en uno** [Opinión, §1.4]. El jugador necesita saber cuál es el
   siguiente frente abierto.
7. **Las pistas se valoran si empujan sin resolver** y se odian si son inútiles, insistentes, de pago o con
   anuncios [Opinión, §1.7; Hecho, tabla 3].
8. **Lo repetitivo es «otra cerradura más», «otro laberinto más» o «el mismo truco otra vez»** [Opinión, §1.6].
9. **Lo memorable son las consecuencias espectaculares y los cambios de escala o de forma** [Opinión, §1.5].
10. **En el móvil, los fallos técnicos y el modelo de pago concentran las notas bajas** [Hecho, tabla 3]: el 28,9 %
    de las de 1-2 estrellas habla de precio, pago o anuncios, y el 17 %, de cierres y fallos.

### Principios en limpio

- Cada pieza debe decir **que** se puede tocar y **hacia dónde** se mueve.
- Lo que el jugador intenta con sentido debe funcionar, o explicar por qué no.
- Un frente abierto visible en todo momento.
- Pistas progresivas que empujan, saben lo que ya hiciste y no cuestan dinero.
- Reto moderado y sostenido, sin relleno.

### Ejemplos

- **Bien:** The Room. Los jugadores nombran el peso y el sonido de cada pieza.
- **Bien:** Old Sins. Puzles «self-contained», cada uno cerrado en sí mismo.
- **Mal:** The House of Da Vinci. Controles y zoom que esconden la interacción.
- **Mal:** Tiny Room Stories al final. Demasiadas cosas abiertas sin saber cuál es pista de qué.

### Riesgos para La caja viva

- **La técnica de pintura proyectada** puede esconder qué se mueve, porque todo está pintado igual: el pixel
  hunting de Riven y The Room Three es el aviso [Interpretación].
- **La decoración viva** (polillas, té, humo y polvo) puede leerse como pista. En las salas de escape reales,
  «players will take anything in the room as being important» (los jugadores dan importancia a todo)
  [Hecho, [Nicholson, 2015](http://scottnicholson.com/pubs/erfacwhite.pdf)].
- **El móvil modesto:** los fallos y cierres salen en el 17 % de las notas de 1-2 estrellas [Hecho, tabla 3]. Un
  tirón o un cierre puede costar más que un mal puzle [Interpretación].

### Propuesta para La caja viva

[Interpretación] **Un mapa de quejas con su antídoto**, revisado con cada nivel:

| Queja del género | Antídoto en La caja viva |
|---|---|
| «No sé hacia dónde se mueve» | Cada pieza móvil lleva su señal de dirección en la pintura (§5) y asoma 1-2 mm al tocarla |
| «Ya lo había probado» | Validar el estado y no el orden (§3). El gesto bien dirigido funciona desde cualquier vista en la que la pieza se vea |
| Dianas diminutas | Lo pequeño se toca desde su vista cercana. Ninguna diana por debajo de 48 dp (biblia §4.2) |
| Perderse entre puzles | El ojo de la caja mira de reojo, de vez en cuando, hacia el frente abierto que más teme (pista dentro del mundo; ver §2) |
| Repetición | Ningún gesto ni tipo de cerradura dos veces seguidas. Cada truco del ojo funciona una vez y la caja «aprende» (§3) |
| Pistas de pago o con anuncios | Ya es regla de la biblia (§6.2: nunca se venden pistas). Los datos la respaldan: precio, pago y anuncios son el tema n.º 1 de las notas bajas en el móvil (tabla 3) |
| Cierres en móviles modestos | Prueba automática y prueba de memoria en el móvil del usuario antes de cada APK |

---

## 2. El momento «¡ajá!» y los buenos puzles

### Hallazgos

**El ajá se fabrica: hay que plantar la idea, no darla.**
- [Hecho] En Portal 2 acortaron un puzle añadiendo antes otro que mostraba la idea: «this almost completely robbed
  the appeal from what was once a high moment» → casi le quitó toda la gracia a lo que era un gran momento. Lo
  rehicieron sembrando señales sutiles: «By planting shards of the idea in their heads, we allow players to own that
  exciting dual collision epiphany» → plantar fragmentos de la idea deja que el jugador sea dueño de la
  revelación. ([comentario de desarrolladores de Portal 2](https://theportalwiki.com/wiki/Portal_2_developer_commentary))
- [Hecho] Jonathan Blow sobre los juegos que paran al jugador para asegurarse de que lo vio, o le mueven la cámara:
  «I don't like any of that stuff» → no le gusta nada de eso.
  ([Alex Wiltshire, Rock Paper Shotgun, 19-02-2016](https://www.rockpapershotgun.com/the-witness-tutorial))
- [Hecho] Los Miller (Myst) querían que, al ver la solución, el jugador se culpara a sí mismo y no al juego: «once
  the player finds the solution, if they blame us, then we haven't done a good job» → si culpa al juego, el diseño
  falló (y si se culpa a sí mismo, acertó). Querían puzles que se sintieran parte del mundo, como un cuadro
  eléctrico de casa que se entiende observando
  [Hecho, vía [Wikipedia, «Myst»](https://en.wikipedia.org/wiki/Myst), que cita a The A.V. Club (2016) y la
  [charla de la GDC de 2013](http://www.gdcvault.com/play/1018048/Classic-Game-Postmortem)].

**Un puzle justo da la información antes y se entiende después.**
- [Hecho] Graham Nelson, «Bill of Player's Rights» (enero de 1995):
  - las buenas pistas «should not need explaining after the event» → no deben necesitar explicación después;
  - el derecho n.º 13 es «To be able to understand a problem once it is solved» → entender el problema una vez
    resuelto, porque «many problems are solved by accident or trial and error» (muchos se resuelven por accidente);
  - el n.º 15, «To have a good reason why something is impossible» → una buena razón de por qué algo no se puede.

  ([The Craft of Adventure](https://www.ifarchive.org/if-archive/info/Craft.Of.Adventure.txt))
- [Hecho] Ron Gilbert, «Why Adventure Games Suck» (1989, publicado en 2004):
  - sobre los puzles y sus soluciones: «They don't have to be obvious, just make sense.» → no tienen que ser
    obvios, solo tener sentido;
  - sobre los puzles al revés: «Ideally, the crevice should be found before the rope» → la grieta, antes que la
    cuerda (el problema antes que la herramienta).

  ([Grumpy Gamer](https://grumpygamer.com/why_adventure_games_suck/))
- [Opinión] Sobre Return of the Obra Dinn: «There is enough information to figure everything out without
  guessing—but it's just enough information.» → hay justo la información necesaria para no adivinar.
  ([Chris Kohler, Kotaku, 2019](https://kotaku.com/return-of-the-obra-dinn-the-kotaku-review-1829797772))

**Información cruzada y progresión por conocimiento.**
- [Hecho] Blow: «it may be that in exploring other areas, the player encounters some puzzle that reminds her of
  something she was stuck on and gives her new ideas to try» → al explorar, otro puzle le recuerda aquel en el que
  estaba atascado y le da ideas. Añade que lo construyeron así a propósito, en muchos sitios del juego.
  ([Brenna Hillier, VG247, 28-01-2016](https://www.vg247.com/who-is-the-witness-for-we-asked-jonathan-blow))
- [Hecho] En Outer Wilds no se lleva nada de un bucle a otro, salvo lo que se ha aprendido (el registro de la nave):
  el progreso es solo conocimiento [vía [Wikipedia, «Outer Wilds»](https://en.wikipedia.org/wiki/Outer_Wilds)].
- [Hecho] Tunic reparte su manual en páginas que se encuentran jugando, y por ellas se descubren las reglas y el
  mundo [vía [Wikipedia, «Tunic»](https://en.wikipedia.org/wiki/Tunic_(video_game))].
- [Hecho] Ron Gilbert: «Solving one puzzle should open up 2 or 3 new ones, and then those collapses down (but not
  necessarily at the same rate) to a single solution» → cada puzle resuelto abre 2 o 3, que luego confluyen.
  ([Puzzle Dependency Charts, 2014](https://grumpygamer.com/puzzle_dependency_charts/))

**Enseñar sin texto.**
- [Hecho] Valve, sobre Portal: «Portal is effectively an extended player training exercise.» Cada herramienta se
  presenta sola y luego se combina («layering these tools into increasingly difficult puzzles»). Tres lecciones de
  sus pruebas:
  - «Early versions of Portal let players stumble through the beginning of the game without always understanding
    what was going on, which really compromised teaching new concepts.» → dejar pasar sin entender estropeaba la
    enseñanza;
  - «this puzzle introduced too many new concepts at once» → un puzle con demasiadas ideas nuevas frustró, y
    añadieron dos salas antes;
  - una señal visual repetida («Repeated several times, this cue helps players associate...») enseña sin palabras.

  ([comentario de Portal](https://theportalwiki.com/wiki/Portal_developer_commentary))
- [Hecho] Portal 2 presenta la misma situación dos veces: primero como suceso de la historia y luego como puzle,
  «the exact same scenario, but in a different context» (el mismo escenario en otro contexto).
  ([comentario de Portal 2](https://theportalwiki.com/wiki/Portal_2_developer_commentary))
- [Hecho] Kishōtenketsu, según Koichi Hayashida (Super Mario 3D Land):
  - «First, you have to learn how to use that gameplay mechanic» (aprender);
  - «a slightly more complicated scenario» (desarrollar);
  - «something crazy happens that makes you think about it in a way you weren't expecting» (giro);
  - «demonstrate, finally, what sort of mastery you've gained» (dominio).

  ([Christian Nutt, Gamasutra, 13-04-2012](https://www.gamedeveloper.com/design/the-structure-of-fun-learning-from-i-super-mario-3d-land-i-s-director))
- [Hecho] Escape rooms, la regla de Skolnick que cita Nicholson: «So, first try to find a way to let the player do
  it; your second choice is to show it. And finally, your last resort is to tell it» → primero que lo haga; si no,
  mostrarlo; decirlo, en último lugar.
  ([Nicholson, «Ask Why», 2016](http://scottnicholson.com/pubs/askwhy.pdf))
- [Hecho] Bart Bonte describe así sus juegos de colores: «Each level has its own logic.» Las pistas no se ofrecen
  enseguida: «the light bulb button that will appear after a while» (aparece pasado un rato), con varias por nivel.
  ([ficha de yellow en la App Store](https://apps.apple.com/us/app/id1219259689))

**Confusión no es atasco.**
- [Hecho] En The Witness, lo que más se rehízo de la entrada fue la curva de un cable, porque los jugadores creían
  que salía de la zona. El periodista lo resume: «Players were getting confused – which is a very different issue
  to being stuck.» Blow: «I didn't want them to be confused at all».
  ([Rock Paper Shotgun](https://www.rockpapershotgun.com/the-witness-tutorial))

**Pistas.**
- [Hecho] Mark Hamilton (Fireproof) explica por qué las pistas de The Room son gratis: «If you charge for hints you
  open yourself up to accusations that you have made certain puzzles hard deliberately to get money». También dice:
  «I've got no patience for puzzle games where I keep getting stuck» (no tiene paciencia con los puzles que atascan
  sin parar). ([TheSixthAxis, 26-04-2013](https://www.thesixthaxis.com/2013/04/26/talking-the-room-with-fireproofs-mark-hamilton/))
- [Hecho] En las salas de escape reales: «it is very frustrating for players to be on the cusp of a breakthrough and
  then to have that moment taken away by a poorly-timed hint» (una pista a destiempo roba el descubrimiento). Además,
  muchos jugadores no piden pista aunque puedan, y salen de mal humor.
  ([Nicholson, 2015](http://scottnicholson.com/pubs/erfacwhite.pdf))

### Principios en limpio

1. **El ajá es un cambio de modelo mental con la información ya a la vista** [Interpretación; Myst, Nelson, Obra
   Dinn]. Si la información no estaba, no hay ajá, hay adivinanza.
2. **Plantar, no explicar.** La pista se siembra antes y en otro contexto; el jugador junta las piezas [Hecho:
   Portal 2, Blow].
3. **Enseñar en cuatro tiempos:** presentar a salvo, complicar un poco, dar la vuelta, dejar demostrar [Hecho:
   Hayashida, Valve].
4. **Una idea nueva cada vez;** dos a la vez frustran [Hecho: Portal].
5. **Hacer > mostrar > decir** [Hecho: Skolnick y Nicholson].
6. **El problema antes que la herramienta:** ver la cerradura antes de tener la llave [Hecho: Gilbert].
7. **Varios frentes abiertos:** cada solución abre dos o tres, y otro puzle puede desatascar el primero [Hecho:
   Gilbert, Blow].
8. **La confusión se arregla; el atasco se cuida** [Hecho: The Witness]. Confusión: no entender qué se ve.
   Atasco: saber qué se quiere y no saber cómo.
9. **Lo resuelto se entiende.** Si se resolvió por accidente, la consecuencia lo explica [Hecho: Nelson].
10. **Pistas que empujan y llegan a tiempo:** progresivas, gratis y nunca en mitad del descubrimiento [Hecho:
    Fireproof, Nicholson; Opinión: §1.7].

### Ejemplos

- **Enseñar viéndose a uno mismo:** el primer portal está colocado para que el jugador se vea a sí mismo a través,
  porque así se entendía antes el concepto [Hecho, comentario de Portal].
- **El cable de The Witness:** el panel controla cosas, y hay dos soluciones con efectos distintos. Blow: «That
  doesn't really come into play until way later in the game, but we prompt it right there» (se usa mucho después,
  pero se siembra ahí) [Hecho, Rock Paper Shotgun].
- **El problema que llega antes:** el hueco de ficha de shōgi en la espalda de la caja ya se ve en el nivel 1 y se
  resuelve más tarde (propuesta del nivel 3). Es un «puzle al revés» bien hecho [Interpretación].

### Riesgos

- **Explicar de más mata el ajá** (Portal 2). **Explicar de menos deja pasar sin entender** (Portal) [Hecho].
- **Pistas demasiado vagas** (The Room 1) o **insistentes**: «The game will constantly nag you with hints and tips
  that are so obvious it hurts» → pistas obvias que no paran [Opinión,
  [reseña de The Room](https://steamcommunity.com/profiles/76561198000833859/recommended/288160/)].
- **Romper una regla aprendida** sin señal (§1.3, The Witness) [Opinión].
- **Lógica «de luna»** (moon logic): soluciones que solo tienen sentido para el autor [Interpretación; tabla 1:
  «ilógico» sale 3,9 veces más en las negativas].

### Propuesta para La caja viva

[Interpretación]

1. **La regla de la mirada, en kishōtenketsu a lo largo de los niveles:**

   | Tiempo | Nivel | Qué pasa con la mirada |
   |---|---|---|
   | Presentar | 1 (hecho) | El ojo te frena y la lámpara lo distrae |
   | Desarrollar | 2 (hecho) | Esconder de su mirada la cara de la caja pequeña, girándola en la mano |
   | Giro | 3 (en propuesta) | Ahora quieres que mire: su luz revela tinta |
   | Dominio | Final | Usar su mirada a voluntad, para tapar y para revelar |

   Lo que ya está propuesto para el nivel 3 encaja con el giro: la recomendación es mantenerlo.
2. **Puzles al revés a propósito.** Antes de dar un objeto, que el jugador haya visto su hueco. Ya pasa con la ficha
   de shōgi y con el cajón largo; convertirlo en norma.
3. **Un escalón de pista dentro del mundo, antes de los cuatro de la biblia** (encaja con la DECISIÓN 26, abierta):
   - escalón 0, sin pedirlo: el ojo mira de reojo hacia el frente abierto;
   - escalones 1 a 4: los de la biblia (§6.2), a petición.

   Dos reglas de cuándo:
   - la pista no salta mientras el jugador está manipulando la pieza correcta (se mide: gesto en curso sobre una
     pieza del paso actual);
   - la pista sabe lo que ya se hizo.
4. **Medir la confusión aparte del atasco** en la prueba con jugadores (PLAN.md §3). Se apunta:
   - qué toca el jugador que no es interactivo (confusión: hay que rehacer el objeto);
   - cuánto tarda en un paso cuyo objetivo ya entendió (atasco: está bien si no pasa de lo previsto).

---

## 3. Puzles con varias soluciones

### Hallazgos

**Qué juegos las tienen y cómo.**

| Tipo | Ejemplos [Hecho] | Qué gana el jugador |
|---|---|---|
| **Abiertos con medida de calidad:** cualquier solución que funcione vale, y luego se compara | Zachtronics: SpaceChem y Opus Magnum. «The player can advance with any working solution to each problem», y las tablas comparan ciclos, coste y área [vía [Wikipedia, «Opus Magnum»](https://en.wikipedia.org/wiki/Opus_Magnum)]. Barth quería puzles abiertos, sin «funneling them in a specific direction» [vía [Wikipedia, «SpaceChem»](https://en.wikipedia.org/wiki/SpaceChem)] | Creatividad y orgullo propio |
| **Varias soluciones con efectos distintos, todas pensadas** | The Witness: el panel con dos soluciones, y la primera que se intenta suele ser la mala: «there might be multiple solutions, each with different effects» ([RPS](https://www.rockpapershotgun.com/the-witness-tutorial)) | Descubrir que el mundo responde a sus decisiones |
| **Una solución «oficial» y otras premiadas** | The Talos Principle: las estrellas se consiguen con soluciones «únicas» de algunos puzles [vía [Wikipedia, «The Talos Principle»](https://en.wikipedia.org/wiki/The_Talos_Principle)] | Sentirse listo por salirse del camino |
| **Una idea, varias formas de ejecutarla** | Portal 2: dejaron un solo hueco en el cristal para que disparar desde cualquiera de los dos lados del campo fuera «a valid solution» ([comentario de Portal 2](https://theportalwiki.com/wiki/Portal_2_developer_commentary)) | No castigar la intención correcta |
| **Una sola solución, a propósito** | Portal, al enseñar: «For training purposes, there's generally just one correct solution to these early puzzles» ([comentario de Portal](https://theportalwiki.com/wiki/Portal_developer_commentary)) | Aprender la regla sin atajos |

**Cuándo destruyen el puzle o dan fallos.**
- [Hecho] Portal: los probadores pulsaban el botón con su cuerpo y se saltaban la caja: «that solution, while
  clever, was a failure, so we added the glass barrier to prevent it» → listo, pero un fracaso, porque el puzle
  existía para enseñar caja y botón. Otro atajo (saltar por los raíles) lo corrigieron matando al jugador, y fue
  «too much of an over correction» (una corrección excesiva) que frustraba incluso a los buenos jugadores.
  ([comentario de Portal](https://theportalwiki.com/wiki/Portal_developer_commentary))
- [Hecho] Croteam (The Talos Principle) vio que, aunque un puzle se diseñe con una solución, al construir el
  escenario a su alrededor aparecen «unsolvable situations or unforeseen shortcuts» (situaciones sin salida o atajos
  imprevistos). Por eso hicieron un bot que repetía las soluciones grabadas en cada cambio del escenario: unas 15.000
  horas de prueba automática [vía [Wikipedia](https://en.wikipedia.org/wiki/The_Talos_Principle), que cita a
  VentureBeat (2014)].
- [Opinión] En Talos, los jugadores dudan: «you won't be sure if what you're trying to do is an exploit that is an
  unintended or intended solution» → no sabe si su solución es la buena o una trampa
  ([reseña](https://steamcommunity.com/profiles/76561198111867801/recommended/257510/)). Otro: «I feel like i
  cheesed, because it didn't feel like the right solution» → resolverlo así no se sintió como la solución buena
  ([reseña](https://steamcommunity.com/profiles/76561198956882278/recommended/257510/)). Pero a otros les encanta:
  «I definitely solved some puzzles in some fun ways that were likely not intended» → resolvió algunos de formas
  divertidas, seguramente no previstas ([reseña](https://steamcommunity.com/profiles/76561198095027549/recommended/257510/)).
- [Opinión] En The Witness, varias soluciones válidas en un tablero encadenado: «eventually this causes issues when
  puzzles start stacking their solutions and your 2nd tier of a 4 tier puzzle was 'wrong'» → cuando los puzles se
  encadenan, una solución válida pero «equivocada» bloquea los siguientes.
  ([reseña](https://steamcommunity.com/profiles/76561197993293533/recommended/210970/))
- [Opinión] La física libre rompe puzles: «the broken physics system means any clues not in your inventory could
  fall through the map at any time» → las pistas pueden caerse a través del suelo.
  ([reseña de Escape Simulator](https://steamcommunity.com/profiles/76561198818199744/recommended/1435790/))
- [Opinión] La fuerza bruta se salta la idea: «I finally just brute-forced the final puzzle answer in the last
  room, instead of waiting for the clue» → probó combinaciones en vez de esperar a la pista.
  ([reseña de The Room Two](https://steamcommunity.com/profiles/76561198023784533/recommended/425580/))

**Cómo las hacen estables.**
- [Hecho] **Comprobar por grupos para que adivinar no compense:** Return of the Obra Dinn solo confirma los
  destinos de tres en tres, «to deter guesswork» (para disuadir de adivinar)
  [vía [Wikipedia](https://en.wikipedia.org/wiki/Return_of_the_Obra_Dinn)].
- [Hecho] **Soluciones al azar en cada partida:** el remake de Riven cambia algunas soluciones en cada partida «so
  cheeky players can't just look up the answers» (para que no se puedan buscar).
  ([Susana Polo, Polygon, 2024](https://www.polygon.com/reviews/24185656/riven-review-remake-remaster-pc-steam-vr))
- [Hecho] **Ayudar a la intención:** en Portal 2, si el jugador dispara el portal equivocado en un momento crítico,
  el juego mueve el otro portal para salvarlo: «This effectively makes the section foolproof» (a prueba de errores).
  ([comentario de Portal 2](https://theportalwiki.com/wiki/Portal_2_developer_commentary))
- [Hecho] **Ron Gilbert** pide averiguar qué intenta hacer el jugador: «If it is what the game wants, then help the
  player along and let it happen.» → si lo que intenta es lo que el juego quiere, ayúdale.
  ([Why Adventure Games Suck](https://grumpygamer.com/why_adventure_games_suck/))

### Principios en limpio

1. **Antes de diseñar, decidir el tipo:** una idea con varias ejecuciones, varias ideas todas pensadas, o abierto
   con medida de calidad. Nunca «varias soluciones» por accidente [Interpretación].
2. **Toda solución aceptada debe pasar por la idea del puzle.** Un atajo que se la salta se cierra (Portal), pero
   sin castigar: nada de sobrecorregir [Hecho, Valve].
3. **Comprobar el estado, no la secuencia.** El puzle pregunta «¿está el ojo distraído y la mano en el cajón?», no
   «¿hizo A y luego B?». Así cualquier camino correcto llega, y el mismo estado da siempre el mismo resultado
   [Interpretación; además facilita la prueba automática].
4. **Reconocer cada solución con su propia reacción.** El jugador no debe dudar de si hizo trampa (Talos)
   [Interpretación].
5. **Que razonar sea más rápido que probar a ciegas:** bastantes combinaciones para que probarlas todas no compense,
   o comprobación por grupos (Obra Dinn) [Hecho, Interpretación].
6. **Nada decisivo en física libre:** carriles, topes y estados discretos [Opinión, Escape Simulator;
   Interpretación].
7. **Repetir la prueba automática de cada puzle después de cada cambio de escenario** [Hecho, Croteam], y además
   en órdenes al azar [Interpretación].

### Ejemplos

- **Bien:** Portal 2 acepta disparar desde los dos lados; The Witness enseña pronto que hay soluciones con efectos
  distintos.
- **Mal:** The Witness cuando una solución válida pero no prevista bloquea la siguiente; los atajos de Talos que
  dejan la duda.

### Riesgos

- **Bloqueos sin salida** si dos caminos dejan la caja en un estado que nadie probó.
- **Dobles disparos:** dos soluciones que activan dos veces el mismo desbloqueo.
- **Que la «trampa» abarate el ajá:** si el atajo es más fácil que la idea, el jugador nunca ve la idea.
- **En La caja viva, el giro libre de la caja pequeña:** si se puede esconder la cara «a medias», hace falta un
  umbral claro y visible de cuándo el ojo grande deja de verla [Interpretación].

### Propuesta para La caja viva

[Interpretación]

1. **Distraer al ojo: dos o tres formas pensadas, cada una con su respuesta.**
   - La lámpara (ya existe).
   - Una segunda forma que use algo que ya está en la sala. Por ejemplo, una ráfaga al tocar el shoji que mueve
     las sombras del bambú, si el ojo sigue el movimiento.

   Cada truco funciona **una vez**: la caja «aprende» y no vuelve a caer en el mismo en el nivel siguiente. Es la
   razón dentro del mundo para no repetir el puzle, y le da carácter al tsukumogami.
2. **Validar por estado:** `ojo_distraido && mano_en_pieza`, no «lámpara, luego cajón». Ya funciona así en parte;
   hacerlo norma para todos los pasos.
3. **Puzles de bolsillo resistentes a la fuerza bruta:**
   - la cajita roja (tapa que gira a saltos): que leer la marca sea más rápido que dar vueltas, con más posiciones
     o con dos anillos que solo confirman juntos (el principio de Obra Dinn);
   - nunca castigar el error (biblia §4.2).
4. **Un «mono» en la prueba automática:** gestos al azar durante N minutos sobre cada nivel. Comprueba que nunca
   queda un estado sin salida y que ningún atajo se salta un paso clave. Es la versión barata del bot de Croteam,
   sobre `prueba/jugar.mjs`.
5. **Ayudar a la intención:** si la llave está casi alineada, o el tirón va en la dirección buena pero con poco
   recorrido, la pieza termina el gesto (imán suave). Lo contrario de «ya lo había probado» (§1.3).

---

## 4. El audio como mecánica y como feedback

### Hallazgos

**Lo que hace el sonido en los juegos que se admiran.**
- [Hecho] Barry Meade (Fireproof) sobre el sonido de The Room: «no overt horror-tastic music or SFX, we wanted to
  keep it ambient with nothing spelled out too much for the player» → nada de música de terror evidente: ambiente,
  sin dar todo masticado. Y añade: «we could suggest ideas through small audio or visual cues that would set their
  mind racing» → sugerir con pequeñas señales que disparen la imaginación.
  ([Gamer Horizon, 19-08-2014](https://gamerhorizon.com/2014/08/19/room-interview-fireproof-studios-barry-meade/))
- [Hecho] Jonathan Blow quitó la música de The Witness: «If we slather on a layer of music that is just arbitrarily
  playing, and not really coming from the world, then we're adding a layer of stuff that works against the game.» →
  una música que no sale del mundo es una capa que trabaja en contra del juego.
  ([VG247, 20-11-2015](https://www.vg247.com/the-witness-long-screenshot-trailer-emphasises-music-free-sound-design))
- [Hecho] Inside (Playdead):
  - es «mostly silent» (casi silencioso), con puzles ligados a señales visuales y sonoras a la vez;
  - el pecho del niño se mueve al ritmo del sonido de su respiración, que cambia con la calma o el pánico.

  [Vía [Wikipedia, «Inside»](https://en.wikipedia.org/wiki/Inside_(video_game)), que cita a Develop (2015).]
- [Hecho] Portal, el sonido como guía:
  - un tictac mientras la puerta está abierta indicó que había que actuar en ese tiempo («which solved the
    problem»);
  - «A particle effect and a loud noise help draw their attention» (partículas y un ruido fuerte para llamar la
    atención);
  - quitaron la voz de unas torretas porque se necesitaba «a distinct, uncluttered sound cue» (una señal sonora
    clara y sin ruido alrededor).

  ([comentario de Portal](https://theportalwiki.com/wiki/Portal_developer_commentary))
- [Opinión] La revista Edge sobre Monument Valley: sus «deep rumbles» (retumbos graves) y «clicks» dan la sensación
  de mover «ancient mechanisms» (mecanismos antiguos) [vía [Wikipedia](https://en.wikipedia.org/wiki/Monument_Valley_(video_game))].

**Lo que dicen los jugadores.**
- [Opinión] «The greatest triumph of The Room is the "crunch."» → lo mejor de The Room es el «crujido» de cada
  pieza. ([reseña](https://steamcommunity.com/profiles/76561198399164176/recommended/288160/))
- [Opinión] «...the ambient sounds (a lock clicking open, a mechanism finally giving way) do a great job of pulling
  you into the atmosphere.» → la cerradura que cede y el mecanismo que por fin se rinde meten en la atmósfera.
  ([reseña de The Room](https://steamcommunity.com/profiles/76561198078687083/recommended/288160/))
- [Opinión] En contra, el volumen y la repetición:
  - «yet again I just opened some lock and the game felt like this needed f'ing loud sound effect» → cada cerradura
    con un golpe demasiado fuerte ([reseña de The Room Two](https://steamcommunity.com/profiles/76561198028509553/recommended/425580/));
  - «The initial audio setting is far louder than it has any business being» → el volumen inicial, demasiado alto
    ([reseña de The Room](https://steamcommunity.com/profiles/76561199234585667/recommended/288160/));
  - «the annoying bleeping [...] you'll be hearing it very often» → un pitido que se oye demasiado a menudo
    ([reseña de Talos](https://steamcommunity.com/profiles/76561198063032776/recommended/257510/));
  - «The music is annoying and breaks my concentration» → la música rompe la concentración
    ([reseña de Escape Academy](https://steamcommunity.com/profiles/76561197963670139/recommended/1812090/)).

**Accesibilidad: nunca solo sonido.**
- [Hecho] Guía de accesibilidad de videojuegos: «Ensure no essential information is conveyed by sounds alone».
  - Afecta a la sordera y también a situaciones como jugar con el sonido apagado: «with sound muted to avoid waking
    the baby».
  - La prueba que propone: «ask someone to play through for the first time with the sound muted».

  ([Game Accessibility Guidelines](https://gameaccessibilityguidelines.com/ensure-no-essential-information-is-conveyed-by-sounds-alone/))
- [Opinión] «if you are at all a person with aural disabilities, hard of hearing or outright deaf, don't buy this
  game» → aviso a las personas sordas sobre The Witness, que tiene puzles de sonido
  ([reseña](https://steamcommunity.com/profiles/76561197996633876/recommended/210970/)).
- [Opinión] En Machinarium, «if you're deaf, the game gives you no indication that there's a musical puzzle» → si
  eres sordo, nada te dice que hay un puzle musical
  ([reseña](https://steamcommunity.com/profiles/76561198040833010/recommended/40700/)).
- [Opinión] Lo contrario, en Doors: Paradox: «Would be playable for Deaf and HoH gamers.» → jugable para personas
  sordas o con pérdida auditiva ([reseña](https://steamcommunity.com/profiles/76561198216537667/recommended/1622770/)).

**Hápticos (vibración) en el móvil.**
- [Hecho] Android, principios de hápticos:
  - «less is more»;
  - «Given the choice of buzzy haptics or no haptics for touch feedback, choose no haptics.» → entre zumbido y
    nada, nada;
  - «A good keyclick haptic feedback signal should last between 10 to 20 milliseconds.» → un clic dura de 10 a
    20 ms;
  - recomiendan diseñar a la vez imagen, sonido y vibración. Una vibración desincronizada «can be a bit unsettling»
    (inquieta);
  - la fuerza va según lo importante y lo frecuente del evento: muy suave lo frecuente, más fuerte lo importante;
  - se desaconsejan las vibraciones antiguas de duración fija.

  ([Android Developers](https://developer.android.com/develop/ui/views/haptics/haptics-principles))
- [Hecho] Las piezas de vibración de Android (`VibrationEffect.Composition`) tienen nombre y propósito
  ([referencia](https://developer.android.com/reference/android/os/VibrationEffect.Composition)):

  | Pieza | Desde | Para qué |
  |---|---|---|
  | CLICK | API 30 | «sharp, crisp click» (clic seco y nítido) |
  | TICK | API 30 | toque ligero para repetir durante un gesto |
  | LOW_TICK | API 31 | toque grave y ligero |
  | THUD | API 31 | golpe hacia abajo con rebote |
  | SPIN | API 31 | giro con inercia |
  | QUICK_RISE / SLOW_RISE / QUICK_FALL | API 30 | subidas y caídas |

  `HapticFeedbackConstants` añade CONFIRM y REJECT (API 30), y SEGMENT_TICK (API 34) para pasar por posiciones
  discretas ([referencia](https://developer.android.com/reference/android/view/HapticFeedbackConstants)).
- [Hecho] Apple:
  - pide una relación causa-efecto clara y constante: «build a clear, causal relationship between each haptic and
    the action that causes it»;
  - igualar la intensidad y la nitidez de la vibración con la de la animación;
  - no abusar;
  - hacerla opcional: «Make haptics optional».
  - Y resume: «the best haptic experience is one that people may not be conscious of, but miss when it's turned
    off» → la mejor vibración es la que no se nota, pero se echa de menos al quitarla.

  ([Apple, Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/playing-haptics))
- [Hecho] La vibración web (`navigator.vibrate`), que usa hoy La caja viva, **solo controla la duración, no la
  intensidad** ([MDN](https://developer.mozilla.org/en-US/docs/Web/API/Vibration_API)). En el código actual
  (`pagina/juego.js`) se usan de 6 a 120 ms, y existe la opción `sinVibrar`.
- [Hecho, tabla 3] Solo 1 de las 8.682 reseñas de iOS habla de vibración. Es una reseña de 2 estrellas de The Room
  Pocket, titulada «Glitches» (fallos): el puzle de anillos «vibrated until it randomly locked in place».
  [Interpretación] Nadie alaba la vibración, pero una mal usada se nota.

### Principios en limpio

1. **Vocabulario fijo:** cada sonido significa una sola cosa en todo el juego, igual que cada vibración [Hecho,
   Apple y Android; Interpretación].
2. **El silencio es una herramienta:** casi sin música mientras se piensa; la música, cuando sale del mundo o
   celebra [Hecho: Blow, Meade, Inside].
3. **El sonido sugiere y sitúa:** dice dónde pasó algo y deja imaginar el resto [Hecho: Meade, Portal].
4. **Nunca solo sonido:** todo lo esencial tiene su pareja visual. Prueba con el sonido apagado [Hecho: GAG].
5. **Volumen y repetición con cuidado:** lo frecuente, suave y con pequeñas variaciones; lo fuerte, raro [Opinión,
   jugadores; Hecho, Android].
6. **Vibración nítida y corta, opcional y sincronizada** con el cuadro del impacto [Hecho, Android y Apple].

### Ejemplos

- **El tictac de Portal:** el sonido enseña que hay que actuar «durante» algo.
- **La respiración de Inside:** animación y sonido van atados y cambian con el estado del personaje.
- **The Room:** un ambiente que sugiere sin decir, y el «crujido» de cada pieza que los jugadores recuerdan.

### Riesgos

- **Puzles de sonido que excluyen** (The Witness, Machinarium).
- **Golpes fuertes repetidos** que cansan (The Room Two).
- **Vibraciones largas que zumban:** con `navigator.vibrate` no hay intensidad, y más de unos 20 ms en algo
  frecuente se acerca al zumbido que Android desaconseja.
- **Que el ambiente vivo de la sala tape las señales de la caja.** Las dos cosas compiten por el mismo oído.

### Propuesta para La caja viva

[Interpretación]

**1. Un diccionario sensorial: sonido, vibración e imagen para cada evento.** Amplía la biblia, §12:

| Evento | Sonido | Vibración: Android 11+ (si el móvil la tiene) / respaldo web | Señal visual |
|---|---|---|---|
| Contacto (la pieza responde) | Clic corto de madera | TICK / 10 ms | La pieza asoma 1-2 mm |
| Mecanismo activo (arrastrando) | Roce de madera; un tic por cada diente o tope intermedio | TICK por tramo (como SEGMENT_TICK) / 6-10 ms, muy suave porque es frecuente | La pieza sigue al dedo |
| Encaje, posición correcta («clac») | Clac más grave y con cuerpo | CLICK o CONFIRM / 15-20 ms | Asienta con un rebote pequeño |
| Trabado (no se puede) | Golpe seco y sordo, con variación de tono | REJECT o LOW_TICK / 20 ms | La pieza quieta; la caja contiene el aliento (biblia §3.4) |
| Gran desbloqueo | 0,3-0,6 s de silencio y luego golpe grave más la cadena mecánica | SLOW_RISE y después THUD / 40-60 ms | La consecuencia, a la vista |
| El ojo mira | El ambiente baja; queda la respiración y un murmullo grave | Ninguna | El ojo abierto |
| El ojo se distrae | La respiración se relaja; vuelve el ambiente | Ninguna | El ojo gira |
| Despertar o revelación | El motivo (koto y shakuhachi, biblia §13) sobre el mecanismo | QUICK_RISE y THUD / 80-120 ms | La transformación |

- **Silencio = el ojo mira.** Es la tensión de la regla central hecha sonido, y se percibe sin mirar. Su pareja
  visual es el ojo abierto, siempre visible.
- **La respiración**, sincronizada con la animación de la caja (el principio de Inside). Su ritmo dice el estado:
  calma, alerta o enfado.

**2. Técnica de la vibración.**
- El APK es nativo con WebView: se puede añadir un puente de JavaScript a Java que use `performHapticFeedback`
  (CONFIRM y REJECT) y las piezas de `VibrationEffect.Composition`.
- Antes hay que comprobar si el móvil las admite. Si no, se vuelve a `navigator.vibrate`, recortando los clics a
  10-20 ms.
- Se mantiene `sinVibrar` como opción visible.
- Coste: bajo (un archivo Java y una función de JavaScript). Hay que probarlo en el móvil del usuario.

**3. Un puzle de escucha, nunca solo de escucha.**
- Al dar golpecitos en los cajones, el que tiene hueco suena distinto. Su pareja visual: el papel del forro
  tiembla, o cae un hilo de polvo.
- Es la prueba de concepto de un «verbo escuchar» con alternativa (biblia §4.3).

**4. Una prueba muda** antes de dar un nivel por bueno: alguien que no lo conozca lo juega sin sonido.

---

## 5. Animación que explica y animación física

### Hallazgos

**Qué es el «game feel» y por qué importa aquí.**
- [Hecho] Steve Swink define el pulido así: «Polish -- The interactive impression of physicality created by the
  harmony of animation, sounds, and effects with input-driven motion.» → la impresión de algo físico nace de que
  animación, sonido y efectos vayan a una con el movimiento que hace el jugador.
  - «Any effect that enhances the impression that the game world has its own self consistent physics is fair
    game.» → vale todo efecto que refuerce una física coherente.
  - «The more clues like that you can borrow to inform the player of the physical properties of the objects
    they're interacting with the better.» → cuantas más señales de las propiedades físicas del objeto, mejor.

  ([Gamasutra, 23-11-2007](https://www.gamedeveloper.com/design/game-feel-the-secret-ingredient))
- [Hecho] Los doce principios de la animación de Disney (Thomas y Johnston, «The Illusion of Life», 1981). Los que
  más sirven a un mecanismo:
  - anticipación;
  - «slow in and slow out» (acelerar y frenar);
  - continuidad del movimiento (*follow through*);
  - arcos;
  - el tiempo de cada acción;
  - la puesta en escena: «the presentation of any idea so that it is completely and unmistakably clear» (presentar
    la idea de forma inequívoca).

  ([Wikipedia](https://en.wikipedia.org/wiki/Twelve_basic_principles_of_animation))
- [Hecho] Fireproof tardó meses en el tacto: Rob Dodd rehízo mucho los gestos y la física. Meade dice que la
  pantalla táctil es un idioma que todos los usuarios de móvil hablan: «Used sensibly, it's a gateway to
  understanding – not confusion.» → bien usada, abre la comprensión en vez de confundir.
  ([MCV/Develop, 10-05-2016](https://mcvuk.com/development-news/the-develop-post-mortem-the-room-three/))

**Tiempos y sincronía.**
- [Hecho] Nielsen: 0,1 s «is about the limit for having the user feel that the system is reacting instantaneously»
  (el límite para sentir que responde al instante); 1 s, el límite para no cortar el hilo del pensamiento.
  ([Nielsen Norman Group, 1993](https://www.nngroup.com/articles/response-times-3-important-limits/))
- [Hecho] Sonido e imagen: la norma ITU-R BT.1359 sitúa el umbral en el que se nota el desfase en **45 ms de
  adelanto del sonido y 125 ms de retraso**. El oído tolera mucho peor que el sonido llegue antes.
  ([Wikipedia](https://en.wikipedia.org/wiki/Audio-to-video_synchronization))
- [Hecho] Apple pide igualar «the intensity and sharpness of a haptic with the intensity and sharpness of the
  animation it accompanies» (la intensidad y la nitidez de la vibración, con las de la animación). Android avisa
  de que una vibración desincronizada inquieta (§4).

**Animación que explica: causa → efecto visible.**
- [Hecho] Portal:
  - los probadores no miraban hacia arriba y no veían las salidas; pusieron los portales en pistones que se mueven
    y arrancan donde se ven;
  - en Portal 2, el campo que destruye objetos no se entendía; añadieron destellos al dispararle y un remolino que
    crece cuando un objeto se acerca;
  - un detalle de forma enseña la dirección: «The length is meant to imply a direction, so the player knows the
    intended flight path before they step onto it» (la longitud de la plataforma indica hacia dónde lanza).

  ([Portal](https://theportalwiki.com/wiki/Portal_developer_commentary), [Portal 2](https://theportalwiki.com/wiki/Portal_2_developer_commentary))
- [Hecho] Portal 2, el retraso realista que engaña: un portal en la Luna tardaba lo que tarda la luz (1,4 s), y
  «playtesters would shoot the moon and instantly turn away, thinking nothing had happened» (creían que no había
  pasado nada). Lo cambiaron. ([comentario de Portal 2](https://theportalwiki.com/wiki/Portal_2_developer_commentary))
- [Hecho] En Gorogoa, al conectar dos imágenes, estas se animan solas un momento para enseñar el resultado
  [vía [Wikipedia](https://en.wikipedia.org/wiki/Gorogoa)].

**Lo que critican los jugadores.**
- [Opinión] **Lentitud:**
  - «animations are inexcusably slow» → animaciones lentas sin excusa
    ([reseña de The Witness](https://steamcommunity.com/profiles/76561197962525905/recommended/210970/));
  - «transition animations are excrutiatingly slow seemingly on purpose» → transiciones lentas a propósito
    ([reseña de Riven](https://steamcommunity.com/profiles/76561197993268038/recommended/1712350/));
  - «It is just a waste of time to watch a part of an animated story each time till it completes» → perder el
    tiempo viendo la animación entera cada vez
    ([reseña de Gorogoa](https://steamcommunity.com/profiles/76561198117501009/recommended/557600/)).
- [Opinión] **Mirar en vez de jugar:** «Many "puzzle" elements unfold without your input, and the game is too often
  like watching a cutscene» → demasiadas cosas pasan solas, como en una escena de vídeo
  ([reseña de Monument Valley](https://steamcommunity.com/profiles/76561198025987636/recommended/1927720/)).
- [Opinión] **Torpeza:** «the animations are a bit awkward at times» → animaciones algo torpes
  ([reseña de The House of Da Vinci 2](https://steamcommunity.com/profiles/76561198216537667/recommended/1259840/)).
- [Opinión] **Objetos que atraviesan cosas:** «players and objects can phase through floors and walls» → jugadores y
  objetos atraviesan suelos y paredes
  ([reseña de Escape Simulator](https://steamcommunity.com/profiles/76561197961768818/recommended/1435790/)).
- [Opinión] **Feedback que parece azar:** el puzle de anillos de The Room Pocket «vibrated until it randomly locked
  in place» (§4).

### Principios en limpio

1. **Responder en menos de 100 ms** con movimiento, sonido o vibración [Hecho, Nielsen].
2. **Sincronía:** sonido y vibración en el cuadro del impacto; mejor un poco tarde que antes [Hecho, ITU, Android y
   Apple].
3. **Peso en tres tiempos:** anticipación (resistencia breve), recorrido con aceleración y frenada, y asentamiento
   con un rebote pequeño y amortiguado [Hecho, Disney; Interpretación].
4. **Pivotes y carriles donde el ojo los espera:** la bisagra en el canto; el cajón, por su guía [Interpretación].
5. **Causa → efecto encadenado y a la vista:** cada eslabón, con su pequeño tiempo para que el ojo lo siga
   [Hecho, Portal; Interpretación].
6. **El estado se lee en reposo:** abierto, cerrado, bloqueado o encajado se distinguen sin tocar [Interpretación].
7. **Lo que se repite se acorta**, y nada obliga a mirar sin poder actuar más allá de lo necesario [Opinión,
   jugadores].
8. **Nada flota ni atraviesa nada** [Opinión, jugadores].

### Ejemplos

- **Bien:** The Room. La llave hace «zonk», el cajón pesa y el dial mueve piezas que se ven (TouchArcade).
  Gorogoa enseña el resultado animándolo.
- **Mal:** las transiciones lentas de Riven y The Witness, el retraso «realista» de la Luna en Portal 2 y el puzle
  de anillos que parece encajar al azar.

### Riesgos

- **La pintura proyectada** se estira o se deforma si la pieza gira mucho; ya pasó con el costado de los cajones,
  corregido en la técnica B. Las piezas que se mueven deben moverse en planos que la pintura aguante
  [Interpretación].
- **El peso mal medido** se vuelve lentitud. Las críticas a Riven y a The Witness lo muestran.
- **La cámara fija de cerca** (una decisión del usuario) puede dejar fuera de cuadro la consecuencia de una acción.

### Propuesta para La caja viva

[Interpretación] **Una plantilla de movimiento para cada mecanismo.** Los tiempos son un punto de partida para
probar en el móvil, no datos:

| Fase | Qué se ve | Tiempo orientativo |
|---|---|---|
| Contacto | La pieza responde: asoma o se resiste | Empieza en menos de 100 ms (mejor, 50) |
| Anticipación (piezas pesadas: tapa, cajón largo) | La pieza va un poco por detrás del dedo, como si pesara, pero ya se está moviendo | 60-120 ms de retraso respecto al dedo |
| Recorrido | Sigue al dedo por su carril; al soltar, sigue un poco por inercia y frena | Lo que dure el gesto |
| Tope | Golpe, sonido y vibración en el mismo cuadro; rebote de 1-2 mm, dos oscilaciones como mucho | 80-150 ms |
| Reposo legible | El estado queda claro: un cajón libre sobresale un poco y uno trabado queda a ras | — |

- **Cadenas** (lámpara → el ojo gira → el cajón se suelta):
  - cada eslabón con su sonido, separados por 80-150 ms;
  - si el efecto queda fuera de cuadro (la cámara de cerca no se mueve), una señal en el borde y el sonido desde
    ese lado.
- **La segunda vez, más rápido:** las cadenas y los viajes de cámara repetidos, a 1,5-2 veces la velocidad, y se
  saltan tocando.
- **La respiración de la caja**, atada a su sonido (el principio de Inside), con tres ritmos: calma, alerta y
  enfado. Ya existe la animación; falta atarla al estado y al sonido.
- **Señal de dirección pintada en cada pieza móvil:** veta, desgaste en el canto, una ranura o un tirador
  orientado. Se pinta con Gemini en el mismo encuadre, como el resto del arte.

---

## 6. Momentos «wow» y revelaciones

### Hallazgos

**Cómo los construyen.**
- [Hecho] **Anticipación:** en Portal, la sala antes de conseguir el arma completa da la vuelta a su alrededor para
  que esté «virtually always in sight right up until you grab it» (casi siempre a la vista hasta cogerla).
  ([comentario de Portal](https://theportalwiki.com/wiki/Portal_developer_commentary))
- [Hecho] **Detrás del decorado:** tras la huida de Portal, el jugador ve «the inner workings» (las tripas) del
  centro. Además, resuelve una sala vieja de una forma «incorrecta», lo que transmite que está engañando al
  sistema. ([comentario de Portal](https://theportalwiki.com/wiki/Portal_developer_commentary))
- [Hecho] **Plantado a la vista desde el principio:** en The Witness, uno de los puzles del entorno está en el
  camino del primer panel. Blow lo llama «magician stagecraft misdirection» (distracción de mago): «You're not
  paying attention to it, you're paying attention to the panel.» → miras el panel, no el truco.
  ([Rock Paper Shotgun](https://www.rockpapershotgun.com/the-witness-tutorial))
- [Hecho] El «final verdadero» de The Witness se consigue con un puzle del entorno escondido en uno de los primeros
  puzles de la isla. El crítico David Roberts (GamesRadar+) lo resume así [Opinión]: «the end of your journey
  becomes the beginning» (el final se vuelve el principio)
  [vía [Wikipedia](https://en.wikipedia.org/wiki/The_Witness_(2016_video_game))].
- [Hecho] **El mundo era más grande de lo que creías:** en Fez, el mundo 2D resulta ser una cara de un mundo 3D.
  El juego simula un fallo, se reinicia y entonces deja girar
  [vía [Wikipedia](https://en.wikipedia.org/wiki/Fez_(video_game))].
- [Hecho] **El conocimiento como única llave:** en Outer Wilds, el progreso es lo que sabes (§2).
- [Opinión] **El objeto que se transforma:** en Monument Valley, «a pop-up-book box unfolds into a castle» (una
  caja de libro desplegable se abre en castillo)
  ([reseña](https://steamcommunity.com/profiles/76561198032956796/recommended/1927720/)). En Old Sins, romper el sello
  para entrar a cada sala (§1.5).
- [Opinión] **Escala:** «contraptions within rooms within rooms!» (artilugios dentro de salas dentro de salas)
  ([reseña de The Room Three](https://steamcommunity.com/profiles/76561198049076223/recommended/456750/)). Es la
  expresión prohibida («entrar en lo pequeño»): solo sirve de aviso.
- [Hecho] **La recompensa es algo nuevo que mirar:** Graham Nelson distingue dos premios por resolver: que el juego
  avance y «that the game should offer something new to look at» (que haya algo nuevo que ver).
  ([The Craft of Adventure](https://www.ifarchive.org/if-archive/info/Craft.Of.Adventure.txt))
- [Hecho] **El momento es del jugador:** en Portal 2 prefirieron mantener un salto lógico difícil porque «almost
  everyone insisted that the payoff was by far their favorite moment» (casi todos dijeron que la recompensa era su
  momento favorito). Lo hicieron justo, sin regalarlo (§2).
  ([comentario de Portal 2](https://theportalwiki.com/wiki/Portal_2_developer_commentary))

**Lo que lo estropea.** [Opinión, §5] Quitar el control (Escape Simulator 2), las escenas que pasan solas
(Monument Valley) y las animaciones largas que se repiten (Gorogoa).

### Principios en limpio (los patrones del «wow»)

1. **Plantar y cobrar:** lo que luego asombra estaba a la vista desde el principio [Hecho: The Witness, Portal].
2. **Transformar lo conocido:** el mismo objeto cambia de función o de forma [Opinión: Monument Valley, Old Sins].
3. **Cambiar la escala hacia fuera:** lo que creías el todo era una parte [Hecho: Fez, Portal].
4. **Invertir el papel:** lo que te frenaba ahora te ayuda; lo prohibido se vuelve necesario [Interpretación;
   Portal: resolver «mal» una sala vieja].
5. **Lo desencadena el jugador y dura poco** [Opinión: jugadores; Interpretación].
6. **Anticipar la meta:** enseñar pronto lo que se desea [Hecho: Portal].
7. **Pagar con algo nuevo que mirar,** no con un número [Hecho: Nelson].

### Ejemplos

- Fez (el mundo era 3D), Portal (la huida tras el decorado), The Witness (el entorno era un puzle), Monument Valley
  (la caja que se despliega) y Old Sins (romper el sello para entrar).

### Riesgos

- **Parecido:** «la caja dentro de la caja» y la miniatura son la firma de The Room. Las cajas que se despliegan ya
  existen en Monument Valley.
- **Coste:** un «wow» visual con la pintura proyectada pide arte nuevo (Gemini) por cada estado.
- **Quitar el control** demasiado tiempo convierte el momento en una escena de vídeo.

### Propuesta para La caja viva

[Interpretación] Tres candidatos, para que decida el usuario:

| Candidato | Patrón | Riesgo de parecido | Coste |
|---|---|---|---|
| **A. La mirada invertida** (nivel 3, ya en propuesta): lo que te frenaba (que el ojo te vea) ahora es lo que necesitas | Invertir el papel; plantar y cobrar | Bajo: no hay nada igual en la referencia | Bajo: reutiliza el ojo |
| **B. La sala era la caja:** el último mecanismo hace correr los shoji como paneles de *himitsu-bako*; la sala entera era la capa de fuera | Escala hacia fuera | Medio: The Room también abre salas, pero aquí es crecer hacia fuera, no entrar en lo pequeño | Alto: hay que pintar la sala en varios estados |
| **C. La cara completa canta:** al final, cuerno, ojo y voz vuelven a su sitio y la caja «canta» la melodía que el jugador fue componiendo paso a paso (biblia §13) | Pagar con algo nuevo; el momento del jugador | Bajo | Medio: trabajo de sonido, poco arte |

- **El biombo del nivel 3** (en propuesta) se parece al nivel de la caja desplegable de Monument Valley. Para
  diferenciarlo:
  - cada hoja la despliega el jugador con su gesto;
  - las bisagras alternan como en un biombo de verdad;
  - las hojas continúan la pintura de la sala.

  El pequeño santuario de dentro se manipula, **nunca se «entra» en él**: esa es la línea roja de la miniatura.
- **Regla para todos:** el «wow» lo dispara un gesto del jugador y no le quita el control más de unos segundos. Lo
  que lo hace posible ya estaba a la vista uno o dos niveles antes.

---

## 7. Veinte reglas de diseño para La caja viva

[Interpretación] Son la síntesis de todo lo anterior. Las que tocan decisiones abiertas (pistas, DECISIÓN 26) son
propuesta para el usuario. Entre paréntesis, de dónde salen.

1. **Cada pieza móvil dice hacia dónde se mueve antes de tocarla** (veta, ranura, desgaste o tirador), y lo que no
   se mueve no lo parece. (§1.3, §5; refuerza la biblia §20.18)
2. **Responder en menos de 100 ms, con sonido y vibración en el cuadro del impacto;** el sonido nunca antes que la
   imagen. (Nielsen, ITU, Android; amplía la biblia §20.2)
3. **Lo imposible tiene una razón dentro del mundo:** se resiste la caja, nunca un mensaje genérico. (Nelson; biblia
   §3.4)
4. **La decoración viva reacciona distinto de los mecanismos:** nunca suena ni vibra como algo que se puede usar.
   (Nicholson, §1)
5. **El problema antes que la herramienta:** el jugador ve el hueco o la cerradura antes de tener la pieza.
   (Gilbert, §2)
6. **Cada regla, en cuatro tiempos a lo largo de los niveles:** presentar, desarrollar, giro y dominio; la mirada
   es la primera. (Hayashida, §2)
7. **Hacer > mostrar > decir;** una línea de texto como mucho, y solo la primera vez. (Skolnick, Blow; biblia §20.11)
8. **La confusión se rehace; el atasco se cuida:** si no entienden lo que ven, se rehace el objeto. (The Witness,
   §2)
9. **Siempre dos o tres frentes abiertos y visibles**, salvo en el clímax. (Gilbert, Blow; biblia §20.12)
10. **Pistas que empujan sin resolver:** progresivas, que saben lo que ya hiciste, que nunca saltan en mitad de un
    gesto correcto, y nunca de pago ni con anuncios. (Fireproof, Nicholson, App Store)
11. **Ayudar a la intención:** el gesto casi bueno se completa solo; nunca «ya lo había probado». (Gilbert, Portal 2,
    §1.3)
12. **Comprobar el estado, no la secuencia:** todo camino correcto llega, y el mismo estado da siempre lo mismo.
    (§3)
13. **Toda solución alternativa es pensada y tiene su propia reacción;** los atajos que se saltan la idea se
    cierran sin castigar. (Portal, Talos, §3)
14. **Nada decisivo depende de física libre:** carriles, topes y estados discretos. (Escape Simulator, §3)
15. **Peso en tres tiempos:** anticipación breve, recorrido con frenada y tope con un rebote pequeño. (Swink,
    Disney, §5)
16. **Lo repetido se acorta y se puede saltar;** ninguna animación obliga a mirar sin jugar más de lo necesario.
    (jugadores de Riven, The Witness y Gorogoa, §5)
17. **Un diccionario sensorial fijo:** clic, roce, clac, trabado, grave y silencio, cada uno con su vibración y su
    señal visual; ningún sonido significa dos cosas. (§4)
18. **Nunca solo sonido ni solo color;** vibración nítida (10-20 ms en los clics) y opcional; prueba muda en cada
    nivel. (GAG, Android, Apple; biblia §20.13)
19. **El «wow» se planta antes, lo dispara un gesto y dura poco:** algo nuevo que mirar, no una escena de vídeo.
    (Portal, The Witness, Nelson, §6)
20. **Probar como un estudio pequeño:** un «mono» automático que juega en órdenes al azar, 3-5 personas sin ayuda y
    una prueba sin sonido, antes de dar un nivel por bueno. (Croteam, Valve, Fireproof)

---

## 8. Fuentes

**Diseñadores y estudios (leídas en el original):**
- Ron Gilbert, «Why Adventure Games Suck» (1989, publicado en 2004): https://grumpygamer.com/why_adventure_games_suck/
- Ron Gilbert, «Puzzle Dependency Charts» (2014): https://grumpygamer.com/puzzle_dependency_charts/
- Graham Nelson, «The Craft of Adventure» (1995): https://www.ifarchive.org/if-archive/info/Craft.Of.Adventure.txt
- Valve, comentario de desarrolladores de Portal: https://theportalwiki.com/wiki/Portal_developer_commentary
- Valve, comentario de desarrolladores de Portal 2: https://theportalwiki.com/wiki/Portal_2_developer_commentary
- Koichi Hayashida, entrevista de Christian Nutt (2012): https://www.gamedeveloper.com/design/the-structure-of-fun-learning-from-i-super-mario-3d-land-i-s-director
- Steve Swink, «Game Feel: The Secret Ingredient» (2007): https://www.gamedeveloper.com/design/game-feel-the-secret-ingredient
- Jonathan Blow en VG247 (2016): https://www.vg247.com/who-is-the-witness-for-we-asked-jonathan-blow
- Jonathan Blow, sobre la música (VG247, 2015): https://www.vg247.com/the-witness-long-screenshot-trailer-emphasises-music-free-sound-design
- Alex Wiltshire, «The Witness' Wordless Tutorials» (RPS, 2016): https://www.rockpapershotgun.com/the-witness-tutorial
- Barry Meade en Gamer Horizon (2014): https://gamerhorizon.com/2014/08/19/room-interview-fireproof-studios-barry-meade/
- Mark Hamilton en TheSixthAxis (2013): https://www.thesixthaxis.com/2013/04/26/talking-the-room-with-fireproofs-mark-hamilton/
- «The Develop Post-Mortem: The Room Three» (MCV, 2016): https://mcvuk.com/development-news/the-develop-post-mortem-the-room-three/
- Scott Nicholson, «Ask Why» (2016): http://scottnicholson.com/pubs/askwhy.pdf
- Scott Nicholson, «Peeking Behind the Locked Door» (2015): http://scottnicholson.com/pubs/erfacwhite.pdf
- Bart Bonte, fichas de yellow y What's inside the box? en la App Store: https://apps.apple.com/us/app/id1219259689

**Críticas:**
- TouchArcade, The Room (Nissa Campbell, 2012): https://toucharcade.com/2012/09/26/the-room-for-ipad-review/
- TouchArcade, The Room Three (Shaun Musgrave, 2015): https://toucharcade.com/2015/11/05/the-room-three-review/
- Kotaku, Return of the Obra Dinn (Chris Kohler, 2019): https://kotaku.com/return-of-the-obra-dinn-the-kotaku-review-1829797772
- Polygon, Riven (Susana Polo, 2024): https://www.polygon.com/reviews/24185656/riven-review-remake-remaster-pc-steam-vr

**Guías técnicas y de accesibilidad:**
- Android, principios de hápticos: https://developer.android.com/develop/ui/views/haptics/haptics-principles
- Android, `VibrationEffect.Composition`: https://developer.android.com/reference/android/os/VibrationEffect.Composition
- Android, `HapticFeedbackConstants`: https://developer.android.com/reference/android/view/HapticFeedbackConstants
- Apple, «Playing haptics»: https://developer.apple.com/design/human-interface-guidelines/playing-haptics
- MDN, Vibration API: https://developer.mozilla.org/en-US/docs/Web/API/Vibration_API
- Game Accessibility Guidelines, sonido: https://gameaccessibilityguidelines.com/ensure-no-essential-information-is-conveyed-by-sounds-alone/
- Game Accessibility Guidelines, color: https://gameaccessibilityguidelines.com/ensure-no-essential-information-is-conveyed-by-a-colour-alone/
- Jakob Nielsen, tiempos de respuesta (1993): https://www.nngroup.com/articles/response-times-3-important-limits/

**Vía Wikipedia** (se usaron los artículos y sus referencias cuando el original no se pudo abrir):
- Myst: https://en.wikipedia.org/wiki/Myst
- The Witness: https://en.wikipedia.org/wiki/The_Witness_(2016_video_game)
- The Talos Principle: https://en.wikipedia.org/wiki/The_Talos_Principle
- Return of the Obra Dinn: https://en.wikipedia.org/wiki/Return_of_the_Obra_Dinn
- Outer Wilds: https://en.wikipedia.org/wiki/Outer_Wilds
- Tunic: https://en.wikipedia.org/wiki/Tunic_(video_game)
- Fez: https://en.wikipedia.org/wiki/Fez_(video_game)
- Gorogoa: https://en.wikipedia.org/wiki/Gorogoa
- Monument Valley: https://en.wikipedia.org/wiki/Monument_Valley_(video_game)
- Inside: https://en.wikipedia.org/wiki/Inside_(video_game)
- SpaceChem: https://en.wikipedia.org/wiki/SpaceChem
- Opus Magnum: https://en.wikipedia.org/wiki/Opus_Magnum
- Los doce principios de la animación: https://en.wikipedia.org/wiki/Twelve_basic_principles_of_animation
- Sincronía de sonido e imagen: https://en.wikipedia.org/wiki/Audio-to-video_synchronization

**Jugadores:**
- Steam: cada cita enlaza a su reseña. La muestra se bajó de la API pública
  `https://store.steampowered.com/appreviews/<id>?json=1`.
- App Store: canal RSS público `https://itunes.apple.com/us/rss/customerreviews/id=<id>/json`. Se citan la app, el
  autor y la fecha.

**Pendientes** (no se pudieron leer aquí; títulos comprobados en la lista «Puzzle Game Design» de Game Maker's
Toolkit). Leer sus transcripciones cuesta 5 créditos de vidIQ cada una: solo con permiso del usuario.
- «What Makes a Good Puzzle?»: https://www.youtube.com/watch?v=zsjC6fa_YBg
- «How Jonathan Blow Designs a Puzzle»: https://www.youtube.com/watch?v=2zK8ItePe3Y
- «Puzzle Solving... or Problem Solving?» (sobre varias soluciones): https://www.youtube.com/watch?v=w1_zmx-wU0U
- «Point and Click Puzzle Design»: https://www.youtube.com/watch?v=EDt6XXsRXag
- «How Baba Is You Makes Brain Busting Puzzles»: https://www.youtube.com/watch?v=7zLwa4bztWs
- «How Return of the Obra Dinn Turns You Into a Detective»: https://www.youtube.com/watch?v=V0qxLrFycrc
- Charla «Juice it or lose it» (Martin Jonasson y Petri Purho), enlazada por Wikipedia: https://www.youtube.com/watch?v=Fy0aCDmgnxg
