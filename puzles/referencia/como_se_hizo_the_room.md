# Cómo se hizo The Room (fuentes públicas, 03-10-2026)

**Qué pidió el usuario:** «¿Puedes buscar el código fuente y cómo están creados los juegos de The Room?».

**Marcas:** [Hecho] lo dice una fuente (al final, con su enlace) · [Deducción] conclusión a partir de los hechos ·
[Opinión] valoración nuestra.

Complementa a `../ANALISIS_THE_ROOM.md`, que estudia el diseño a partir de partidas grabadas y guías. Aquí está lo
que contaron sus autores: con qué lo hicieron, cuánta gente, cuánto costó y cómo trabajan.

---

## 1. El código fuente: no es público

- **[Hecho]** Fireproof Games no ha publicado el código de ningún The Room. Es un juego comercial cerrado y no hay
  versión de código abierto (búsqueda del 03-10-2026).
- Lo que circula por ahí sería código sacado de la aplicación (descompilado). Eso infringe sus derechos y su
  licencia: **no se usa**.
- **[Opinión]** Tampoco nos haría falta:
  - lo valioso de The Room no está en el código, sino en el diseño y el pulido, y eso se ve jugando y está estudiado
    en `ANALISIS_THE_ROOM.md`;
  - su código es C# para Unity, y La caja viva va en JavaScript con Three.js.
- **Lo legítimo para aprender:**
  - las entrevistas y artículos de abajo;
  - la charla de la GDC Europe 2014 (solo para socios de la GDC Vault);
  - juegos de aficionados del mismo estilo publicados en itch.io (por ejemplo, «Box Puzzle Game», hecho en Unity).

## 2. Quién, con qué y cuánto

| | |
|---|---|
| **Estudio** | Fireproof Games (Guildford, Reino Unido). Lo fundaron a finales de 2008 seis artistas que venían de Criterion Games (Burnout). Durante cuatro años hicieron arte por encargo (LittleBigPlanet, Killzone, Forza, DJ Hero…) y ahorraron para hacer su propio juego **[Hecho]** |
| **Motor** | **Unity**, en los tres juegos principales. Lo eligieron por barato: «la combinación de Unity y el móvil permitió que una empresa como la nuestra hiciera un videojuego» (Barry Meade) **[Hecho]** |
| **Equipo de The Room (2012)** | En la práctica, dos personas fijas: Rob Dodd (el único programador) y Mark Hamilton (diseño y arte). Más de la mitad del juego lo hicieron ellos dos; el resto del estudio seguía con encargos y echaba una mano **[Hecho]** |
| **Tiempo** | Unos ocho meses (de febrero a septiembre de 2012). A las seis semanas ya era jugable y se lo enseñaron a Apple **[Hecho]** |
| **Coste** | Las fuentes no coinciden: menos de 80.000 £ («básicamente, los sueldos de seis meses»), 100.000 £ ahorradas o 160.000 £ en total, según la fuente **[Hecho]** |
| **Lanzamiento** | iPad, septiembre de 2012. Apple lo destacó y en una semana recuperaron lo invertido. Sin presupuesto de marketing: boca a boca **[Hecho]** |
| **Resultados** | 1,4 millones de copias en iPad en marzo de 2013. En octubre de 2016, 11,5 millones de la serie entera **[Hecho]** |
| **Después** | The Room Two (2013), Three (2015), Old Sins (2018) y la versión de realidad virtual A Dark Matter (2020). La versión de PC del primero la hicieron ocho personas en seis o siete meses, rehaciendo los puzles de inclinar el aparato **[Hecho]** |

## 3. Cómo diseñan

1. **Primero el gesto, después el juego.** Hamilton: «la idea salió de pensar qué movimientos y manipulaciones
   iban mejor con la pantalla táctil, y luego ver qué juego podíamos hacer con eso». No querían «una versión
   recortada de un juego de consola, con medio desarrollo dedicado a meter un mando en la pantalla» **[Hecho]**.
2. **Prototipos rápidos, y se queda el que divierte.** Tenían tres meses para probar ideas. Hicieron dos:
   - «Tiny Planets», como Angry Birds Space;
   - «Puzzle Box», un juguete para manipular objetos 3D con los dedos, inspirado en las cajas secretas chinas.

   Eligieron el segundo y nunca hicieron el tercero **[Hecho]**.
3. **Sin documento de diseño: se inventa jugando.** «Nos inventábamos el juego cada día al llegar a trabajar».
   «¿Cómo vas a saber en papel qué se siente con una idea en el juego?» **[Hecho]**.
4. **Muchas ideas, se construyen enseguida y se tira lo que no vale.** Hamilton y el cofundador Chris Cannon
   apuntan ideas de cajas y puzles y las van descartando. Las que quedan se construyen enseguida y se juegan; si
   funcionan, se iteran. No les importa tirar trabajo si el resto del estudio dice que no es bueno **[Hecho]**.
5. **Pruebas con todo el mundo.** Todo el estudio jugaba durante el desarrollo y se lo llevaba a casa para que lo
   probaran sus familias. Si un puzle atascaba, volvían a él **[Hecho]**.
6. **La jugabilidad manda.** «La jugabilidad da forma a todo lo demás: la interfaz, el sonido, las mecánicas».
   La historia es «sabor», contada con objetos y notas **[Hecho]**.
7. **Atascarse un poco gusta.** «A la gente le gustan los baches; disfruta averiguando cosas». «Atascarse y
   desatascarse uno mismo es la satisfacción que buscan». No simplifican los puzles cuando alguien se atasca **[Hecho]**.
8. **Pistas gratis.** No cobran por ellas: «si cobras las pistas, te pueden acusar de hacer puzles difíciles a
   propósito» **[Hecho]**.
9. **Pequeño y pulido.** «Hicimos el juego lo más pequeño posible, para poder pulir lo que teníamos». Lo pulieron
   mucho en el aspecto y el tacto **[Hecho]**.

## 4. Cómo está hecho por dentro

**Lo que han contado [Hecho]:**
- **Física en todo lo que se mueve.** Metieron un motor de física para que cada pieza tuviera peso: «modelamos la
  física de cada interruptor, palanca, cerradura y cierre». Con eso, tocar la pantalla responde como un objeto de
  verdad, y eso quitaba «una barrera de entrada enorme».
- **El tacto llevó meses.** Hamilton: «tardamos un par de meses de prueba y error en que los controles funcionaran
  como ahora». El programador rehízo muchas veces los gestos y la física.
- **La sensación de realidad.** Meade la explica así:
  - física en los pomos;
  - peso al manipular los objetos;
  - inercia en el movimiento de la cámara;
  - respuesta táctil.
- **El arte es lo que luce, no la complejidad.** Texturas muy detalladas y paisajes sonoros complejos, pero «nuestras
  mallas no son más complejas que las de otros: llevamos años aprendiendo a decidir bien el arte». Los tres juegos
  iban en un iPhone 4S.
- **Ahorros que acabaron siendo el estilo:**
  - un juego corto;
  - solo para algunos sistemas;
  - **oscuro y en penumbra**.

  Las tres cosas fueron recortes de presupuesto y acabaron dando su atmósfera.
- **Llevar la mirada.** «¡Haced cosas que brillen!»: trabajaron mucho en guiar los ojos del jugador.

**Lo que no han contado** (no hay charlas técnicas públicas sobre el sombreado ni la iluminación). Por lo que se ve,
y como es lo habitual en Unity para móviles de 2012 **[Deducción]**:
- luz horneada en texturas y mapas de relieve (*normal maps*) para el detalle;
- pocos objetos y luces en tiempo real;
- una cámara que orbita el objeto y salta a puntos de interés;
- la física de Unity (PhysX) con articulaciones y límites para bisagras, correderas y diales.

## 5. Qué nos sirve para La caja viva

| The Room | La caja viva hoy | Propuesta |
|---|---|---|
| Primero el gesto, después el puzle | Desde la 0.2, gestos: tirar, girar, levantar, deslizar | Diseñar cada puzle nuevo empezando por su gesto (biblia §8), no por su solución |
| Física y peso en cada pieza | Muelles en los cajones (rebote y golpe) | Dar peso también a la llave, la tapa y las tablillas (que se resistan un poco al principio y cedan) |
| Inercia en la cámara | Transiciones suaves, sin inercia al soltar | Un poco de inercia al girar la caja pequeña y la grande |
| «Haced cosas que brillen» | Destellos y la luz de la trampilla | Un brillo leve y raro en la pieza que toca, si el jugador lleva tiempo sin avanzar (encaja con la DECISIÓN 26, pistas) |
| Pruebas con familias, desde el principio | Pruebas automáticas; aún sin jugadores | Hacer ya la prueba con jugadores de `PLAN.md` §3: 3-5 personas de la familia, apuntando dónde se atascan y cuánto tardan |
| Pequeño y muy pulido | Dos niveles | Pulir el 1 y el 2 antes del 3 (gestos, sonido, encuadres) |
| Penumbra como estilo y como ahorro | Sala nocturna del boceto | Mantenerla: es barata y da miedo |

**[Opinión]** Lo más importante que confirma esta búsqueda es su método: prototipo jugable en semanas, probar con
gente de verdad e iterar el tacto durante meses. Es justo el punto en el que está La caja viva. El siguiente paso de
más valor no es otro nivel: es ver jugar a tres personas el APK 0.2.

## 6. Fuentes

- Pocket Gamer.biz, «Thinking outside the box: the making of The Room»: https://www.pocketgamer.biz/thinking-outside-the-box-the-making-of-the-room/
- Pocket Gamer.biz, «From Puzzle Box to The Room: how Fireproof found its feet on mobile»: https://www.pocketgamer.biz/from-puzzle-box-to-the-room-how-fireproof-found-its-feet-on-mobile/
- Pocket Gamer.biz, «Develop 2013: Barry Meade talks The Room»: https://www.pocketgamer.biz/develop-2013-barry-meade-talks-the-room-the-game-with-no-great-plan-but-a-lot-of-success/
- MCV/Develop, «The Develop post-mortem: The Room Three»: https://mcvuk.com/development-news/the-develop-post-mortem-the-room-three/
- GDC Vault, «Making The Room: How We Got There and What We've Learned» (Barry Meade, GDC Europe 2014; solo socios): https://gdcvault.com/play/1020901/Making-The-Room-How-We
- TheSixthAxis, «Talking The Room with Fireproof's Mark Hamilton» (2013): https://www.thesixthaxis.com/2013/04/26/talking-the-room-with-fireproofs-mark-hamilton/
- Gamer Horizon, entrevista a Barry Meade (2014): https://gamerhorizon.com/2014/08/19/room-interview-fireproof-studios-barry-meade/
- Pocket Gamer, «Fireproof's Barry Meade: we're not done with The Room universe yet»: https://www.pocketgamer.com/the-room-2/fireproofs-barry-meade-were-not-done-with-the-room-universe-yet/
- PlayStation Blog, «How Fireproof Games brought puzzle sensation The Room to PS VR» (2020): https://blog.playstation.com/2020/03/23/how-fireproof-games-brought-puzzle-sensation-the-room-to-ps-vr/
- Room Escape Artist, «REPOD: Barry Meade, creating The Room» (2021): https://roomescapeartist.com/2021/03/30/repod-barry-meade-creating-room/
- Guildford Games, «In The Room with Mark Hamilton and Barry Meade»: https://guildford.games/news/in-the-room-with-mark-hamilton-and-barry-meade-of-fireproof-studios
- Wikipedia, «The Room (video game)» (cifras de ventas y coste, que citan a The Guardian y Gamasutra): https://en.wikipedia.org/wiki/The_Room_(video_game)
- itch.io, «Box Puzzle Game» (un juego de aficionado del mismo estilo, en Unity): https://maximebastien.itch.io/box-puzzle-game
