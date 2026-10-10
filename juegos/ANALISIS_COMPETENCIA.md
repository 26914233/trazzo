# Análisis de competencia: Palabrario y Lienzo Zen

Fecha de la investigación: 10 de octubre de 2026. Tienda de referencia: Google Play EE. UU. (`gl=US`), salvo que se indique otra.

## 0. Método, fuentes y límites (léelo primero)

**Qué se revisó**
- **33 apps de Google Play**: 16 sopas de letras (Grupo A) y 17 de colorear (Grupo B). De cada una se tomaron descargas, nota, número de valoraciones, si declara anuncios, el rango de precios de compras integradas, la fecha de la última actualización y el texto de la descripción. Fuente: la ficha `https://play.google.com/store/apps/details?id=<paquete>`, enlazada en cada fila.
- **Quejas en Google Play**: para cada app se clasificaron por palabras clave hasta 240 reseñas de 1, 2 y 3 estrellas por app (entre 7 y 240 según la app), ordenadas por "más relevantes" (en inglés/EE. UU. y en español/México). Los porcentajes que aparecen en las fichas dicen **qué parte de esas reseñas negativas menciona cada tema**, no qué parte de todas las reseñas. Es una clasificación automática y aproximada.
- **Reseñas textuales para el método replica-entrepreneur**: se tomaron del RSS oficial de reseñas de Apple, de 12 competidores grandes (5 + 7) y en las tiendas de EE. UU., México y España, junto con 3 comentarios de Hacker News. El archivo `juegos/replica/reviews.csv` contiene el texto exacto de cada una con su URL, y el ranking está en `juegos/replica/feedback.md`. El tamaño real de la muestra aparece en la sección 6.

**Aviso de cumplimiento (importante).** Los metadatos y las reseñas de Google Play se obtuvieron con la librería `google-play-scraper`, porque `WebFetch` devolvía la ficha truncada. Más tarde, el coordinador indicó que no se usen librerías de scraping contra Google Play, y la skill replica-entrepreneur dice lo mismo. A partir de ese momento ya no se usó. **Ninguna reseña de Google Play está en `reviews.csv`**, que solo contiene datos del RSS oficial de Apple y de la API de HN. Las cifras públicas de las fichas (descargas, nota, anuncios, rango de compras integradas y descripción) y las estadísticas de quejas de Play de las secciones 1–3 vienen de esa extracción anterior. Si el dueño prefiere no usarlas, se pueden borrar o volver a verificar a mano en cada ficha, que está enlazada.

**Límites**
- Google Play no publica el precio de las suscripciones. Cuando se da uno, viene de la descripción o de una reseña que lo cita, y se indica cuál. Los precios cambian según el país y la fecha.
- "Descargas" es el tramo público de Play (por ejemplo "10,000,000+").
- Reddit devolvió 403 a las peticiones sin autenticar, así que no hay hilos de Reddit.
- Si un dato no apareció, pone **"no encontrado"**.
- Lake y Pigment, citados en el encargo, **no tienen ficha en Google Play EE. UU.** (los paquetes `com.pixite.pigment` y `com.lakecoloring.lake` dan "no encontrado"). Solo se incluyen sus reseñas de iOS, como referencia del modelo de suscripción.

---

## 1. Grupo A: sopas de letras y búsqueda de palabras (16 apps)

Abreviaturas: **IAP** = compras integradas (el rango es el que muestra Play "por artículo"). "Quejas Play" = porcentaje de la muestra de reseñas de 1–3★ que menciona cada tema.

### A1. Word Search Explorer (en español "Sopa de Letras Español") — PlaySimple Games
- Descargas: 100M+. Nota: 4,91 (1.257.257 valoraciones). Gratis, con anuncios e IAP de 0,99 a 49,99 US$. [Ficha](https://play.google.com/store/apps/details?id=in.playsimple.wordsearch)
- Mecánica: deslizar el dedo sobre la cuadrícula para encontrar palabras de un tema común. Se progresa por "destinos" con paisajes, hay "múltiples pistas", juego sin conexión y sincronización con Facebook (descripción).
- Contenido: "hundreds of word puzzles" (descripción). No da cifra exacta de categorías: no encontrado.
- Retención: viaje por destinos y pistas (descripción). Las reseñas mencionan puzles diarios con citas, una racha del reto diario y eventos con tiempo limitado de unas 3 horas ([ficha/reseñas](https://play.google.com/store/apps/details?id=in.playsimple.wordsearch)).
- Quejas Play (n=240): anuncios 63 %, anuncios largos o tras cada nivel 20 %, pago 12 %, repetitivo 8 %. La reseña más votada (1.919 votos) dice: "a full 30sec of adds every level, and you can't skip it". Otras reseñas citan que quitar los anuncios cuesta 5,99 US$ y que las monedas para pistas se agotan.

### A2. Word Search – Word Puzzle Game ("Word Search Journey") — Bluetile
- Descargas: 100M+. Nota: 4,80 (779.909). Gratis, con anuncios e IAP de 0,99 a 19,99 US$. [Ficha](https://play.google.com/store/apps/details?id=com.playvalve.wsjourney)
- Mecánica: **4 niveles de dificultad (Easy, Medium, Hard, Pro)**, igual que Palabrario. Palabras en cualquier dirección, juego sin wifi y temas de destinos del mundo más categorías clásicas (descripción).
- Contenido: cifra no encontrada.
- Retención: viaje por destinos. Las reseñas mencionan el "RETO DEL DÍA" con temporizador y eventos temáticos con tiempo.
- Quejas Play (n=240): anuncios 44 %, repetitivo 17 % ("the categories and words are the same over and over", 3.336 votos). Una reseña en español con 3.041 votos pide que el reto del día tenga tres niveles de dificultad porque la barra de tiempo "pasa muy rápido".

### A3. Wordscapes Search — PeopleFun
- Descargas: 10M+. Nota: 4,70 (233.290). Gratis, con anuncios e IAP de 0,99 a 99,99 US$. [Ficha](https://play.google.com/store/apps/details?id=com.peoplefun.wordsearch)
- Mecánica: unir letras con fondos de naturaleza, potenciadores (boosters) y puntos extra por palabras adicionales (descripción).
- Contenido: "1000's of puzzle board levels" (descripción).
- Retención: según las reseñas, hay eventos de "resaltadores" dos días por semana, trofeos y una racha diaria (una reseña se queja de que se reinició dos veces).
- Quejas Play (n=163): anuncios 39 %, fallos 16 %, pago 11 %. Varias reseñas dicen que quitar los anuncios cuesta 10 US$ y que es "too much… Maybe $5 at most". También se quejan de que es demasiado fácil para un adulto.

### A4. Word Search Quest – Puzzles ("Sopas de Letras Español") — Blackout Lab
- Descargas: 100M+. Nota: 4,76 (1.016.301). Gratis, con anuncios e IAP de 0,99 a 22,99 US$. [Ficha](https://play.google.com/store/apps/details?id=com.blackout.word)
- Mecánica: un modo "Quest" con miles de niveles de dificultad creciente y un **modo Relax de cuadrículas infinitas** con dificultad elegible. Sin temporizador, con monedas como recompensa (descripción).
- Contenido: 23 temas desbloqueables y 10 idiomas con más de 3.000 palabras por idioma (descripción).
- Retención: recompensas y monedas, y desbloqueo de temas.
- Quejas Play (n=240): anuncios 60 %, repetitivo o fácil 15 %. Hay reseñas que **piden una opción de pago único para quitar los anuncios** ("make it a one time purchase", "pay a one time fee for no ads") y otras que se quejan de que el juego obliga a dejar una reseña.

### A5. Words of Wonders: Search — Fugo Games
- Descargas: 10M+. Nota: 4,93 (179.788). Gratis, con anuncios e IAP de 0,99 a 49,99 US$. [Ficha](https://play.google.com/store/apps/details?id=com.fugo.wowsearch)
- Mecánica: viaje por ciudades y las siete maravillas, con pistas animadas y juego sin conexión (descripción).
- Contenido: cifra no encontrada. Una reseña habla de más de 4.000 niveles.
- Retención: viaje y monumentos. Las reseñas mencionan un puzle diario y piden logros, porque "doesn't have achievements".
- Quejas Play (n=240): anuncios 41 %. En español: "anuncio de 30 segundos que no se puede saltar… después de cada partida" (637 votos). Varias reseñas dicen que quitar los anuncios es una **suscripción semanal** ("4 bucks a week"; "paid $9.99 to remove ads").

### A6. Word Search — Italic Games
- Descargas: 10M+. Nota: 4,76 (465.859). Gratis, con anuncios. No declara IAP. [Ficha](https://play.google.com/store/apps/details?id=com.mobilegame.wordsearch)
- Mecánica: modos Tiempo y Clásico, pistas, juego sin wifi y **retos diarios con recompensas** (descripción).
- Contenido: "100+ different categories" (descripción).
- Dato útil: varias reseñas dicen que la app está en **Google Play Pass**, donde se juega sin anuncios ("With the Play Pass, there's no ads").
- Quejas Play (n=227): anuncios 23 %, repetitivo 11 %, faltas de ortografía y palabras raras, y que es demasiado fácil.

### A7. Infinite Word Search Puzzles — Random Logic Games
- Descargas: 10M+. Nota: 4,68 (80.524). Gratis, con anuncios e IAP de 0,99 a 49,99 US$. [Ficha](https://play.google.com/store/apps/details?id=com.randomlogicgames.wordsearch)
- Mecánica: modos Progresión, Infinito y **Multijugador en tiempo real** con clasificaciones, retos diarios y diseños desbloqueables (descripción).
- Contenido: "hundreds of categories" (descripción).
- Quejas Play (n=240): anuncios 61 %, pago 12 %, fallos 11 %. Una reseña cuenta que antes había un pago único y que ahora hay "a weekly fee of $8".

### A8. Sopa de Letras en Español — Senior Games (Tellmewow)
- Descargas: 5M+. Nota: 4,64 (101.159). Gratis, con anuncios e IAP de 0,89 a 39,99 US$. [Ficha](https://play.google.com/store/apps/details?id=com.tellmewow.senior.word.search)
- Mecánica: **4 dificultades por tamaño de cuadrícula (7×7 a 10×10)**, palabras también al revés y una interfaz pensada para mayores (descripción).
- Contenido: "miles" de sopas, más de 50 categorías y 8 idiomas, entre ellos el español (descripción).
- Retención: no encontrada en la descripción.
- Quejas Play (n=240): anuncios 35 %, repetitivo 10 %.

### A9. Sopa de letras — Reto diario (Word Search) — AsgardSoft
- Descargas: 10M+. Nota: 4,67 (108.943). Gratis, con anuncios e IAP de **1,99 a 4,99 US$**. [Ficha](https://play.google.com/store/apps/details?id=com.asgardsoft.words)
- Mecánica: 8 niveles de dificultad, sopas generadas automáticamente sin fin y modo con temporizador, cuenta atrás o relajado (descripción).
- Contenido: infinito por generación, 13 idiomas y categorías temáticas (descripción).
- Retención: **"Puzzle of the Day" igual para todos los jugadores del mundo**, logros y clasificaciones de Google Play Games, y temas y colores personalizables (descripción).
- Modelo: "unlock premium for ad-free gameplay and unlimited hints" (descripción), con IAP de 1,99–4,99. Es el competidor cuyo modelo **más se parece a un pago único**.
- Quejas Play (n=225): anuncios solo 13 %, el más bajo del grupo entre las apps grandes.

### A10. ¡Sopa de Letras! (Word Search!) — Mindful Daily Puzzles
- Descargas: 10M+. Nota: 4,91 (249.013). Gratis, con anuncios. No declara IAP. [Ficha](https://play.google.com/store/apps/details?id=com.word.search.find.puzzle)
- Mecánica: deslizar, potenciadores y juego sin conexión (descripción). Las reseñas mencionan un reto diario con "gotas de agua" coleccionables.
- Contenido: "myriad of words spanning various categories" (descripción). Cifra no encontrada.
- Quejas Play (n=225): anuncios 38 %. Una reseña de 2026 dice: "where is the ad-free one time payment option for ZERO interruptions". En español: "después de cada nivel tenés que ver un anuncio".

### A11. Sopa de Letras: Español (Word Search Games: Word Find) — RV AppStudios
- Descargas: 1M+. Nota: 4,17 (8.364). Gratis, con anuncios e IAP de 0,99 a 49,99 US$. [Ficha](https://play.google.com/store/apps/details?id=com.rvappstudios.word.search.puzzle.game)
- Mecánica: modos Clásico, Arcade, "Up Words" (palabras en movimiento) y Multijugador. **Tamaño de letra ajustable y modo noche**, torneos, y fuentes y fondos personalizables (descripción).
- Contenido: "10000+ words" (descripción).
- Quejas Play (n=199): pocas por anuncios (8 %). Hay quejas por pocas palabras por sopa y por la mano tutorial que se queda colgada.

### A12. Bible Word Search — Hustle Run
- Descargas: 1M+. Nota: 4,80 (29.705). Gratis, con anuncios e IAP de 0,99 a 49,99 US$. [Ficha](https://play.google.com/store/apps/details?id=com.econogames.bible.wordsearch.gp)
- Mecánica: sopas temáticas bíblicas más una trivia de más de 10.000 preguntas (descripción).
- Contenido: "over 6,000 handcrafted levels" (descripción).
- Retención: **"Verse of the Day"** y un "date tracker" (registro de días), que es una forma de racha (descripción).
- Quejas Play (n=142): anuncios 59 % ("commercials are no less than 1 minute… between each and every puzzle"), "same 100 words over and over" y que no hay progresión de dificultad.

### A13. Sopa de letras en español (Word Search – Puzzle Game) — Onni Lab
- Descargas: 1M+. Nota: 4,63 (8.018). Gratis, con anuncios. No declara IAP. [Ficha](https://play.google.com/store/apps/details?id=com.milimimili.pc)
- Mecánica: sin límite de tiempo, pistas, imágenes de fondo relajantes y juego sin conexión (descripción).
- Contenido: no encontrado.
- Quejas Play (n=107): anuncios 25 %. Varias quejas por **anuncios con sonido que no se pueden silenciar**.

### A14. Vita Word Search for Seniors — Vita Studio
- Descargas: 100K+. Nota: 4,63 (9.481). Gratis, con anuncios e IAP de 0,99 a 19,99 US$. [Ficha](https://play.google.com/store/apps/details?id=com.vitastudio.wordsearch)
- Mecánica: **letras grandes**, interfaz pensada para mayores, dificultad graduada, pistas, juego sin conexión y teléfono o tableta (descripción).
- Quejas Play (n=60): anuncios 31 % (uno grande y ruidoso que no se podía cerrar de noche) y progreso que se reinicia.

### A15. Word Search Games PRO — LittleBigPlay (app de pago)
- Descargas: **10K+**. Nota: 4,48 (**136** valoraciones). **De pago, 1,99 US$**, sin anuncios ni IAP. [Ficha](https://play.google.com/store/apps/details?id=air.com.littlebigplay.games.premium.wordsearchgames)
- Mecánica: modos Skill (contrarreloj con clasificación), Relax, Endless y un **editor de sopas propias**. 21 idiomas y personalización de fondos, fuentes y tamaños (descripción).
- Quejas Play (n=7, muestra mínima): "Mediocre... especially for a paid app", "No difficulty levels".
- Por qué está aquí: es la referencia directa del modelo de pago en esta categoría. Hay otros dos casos de pago en Play con cifras parecidas: "Words Search – Premium" (A.V.A, 1,99 US$, 10K+, [ficha](https://play.google.com/store/apps/details?id=com.ANOOGAMES.WordsSearchPremium)) y "Word Search Daily PRO" (LittleBigPlay, 2,49 US$, 5K+, [ficha](https://play.google.com/store/apps/details?id=air.com.littlebigplay.games.wordsearchdailypro)), ambos vistos en los resultados de búsqueda de Play.

### A16. Word Search Nature — Appgeneration
- Descargas: 1M+. Nota: 4,59 (10.055). Gratis, con anuncios e IAP de 0,99 a 22,99 US$. [Ficha](https://play.google.com/store/apps/details?id=word.search.games.free)
- Mecánica: palabras extra ocultas que suman puntos, un **"cerebro animado"** que muestra la puntuación global, estadísticas y modos desbloqueables (descripción).
- Contenido: "thousands of levels" (descripción).
- Quejas Play (n=103): el deslizamiento deja de responder y anuncios 15 %.

---

## 2. Grupo B: colorear para adultos, mandalas y colorear por números (17 apps)

### B1. Happy Color® – Color by Number — X-FLOW
- Descargas: 100M+. Nota: 4,56 (3.900.459). Gratis, con anuncios e IAP de **1,99 a 7,99 US$**. [Ficha](https://play.google.com/store/apps/details?id=com.pixel.art.coloring.color.number)
- Mecánica: **colorear por números** tocando (descripción) y un buscador de imágenes.
- Contenido: "over 40,000 FREE" láminas de naturaleza, animales y mandalas, contenido de Disney, Marvel y Star Wars, y más de 100 artistas (descripción). Todo gratis.
- Retención: eventos benéficos ("You color, we donate"), según la descripción. Las reseñas mencionan imágenes diarias, **imágenes misterio**, **logros que dan imágenes extra**, "coloring animations" satisfactorias y pistas mediante una **bombilla** que se desbloquea con anuncios.
- Modelo: según una reseña, un pago para quitar anuncios ("remove ads"). Una reseña de otra app (Candy Mobile) cuenta que Happy Color y Zen Color ofrecían "remove ads and get unlimited hints for a one off payment". El precio exacto no se encontró.
- Quejas Play (n=240): **anuncios 82 %** ("anuncio al entrar una imagen, anuncio al salir"), **arte hecho con IA** (860 votos: "the ai art is atrocious… I wish there was a way to hide the ai art") y la bombilla de pista que sigue saliendo después de pagar.

### B2. Recolor – Art Coloring Pages — Recolor (Sumoing)
- Descargas: 10M+. Nota: **3,54** (85.835). Gratis, con anuncios e IAP de 1,99 a 108,71 US$. **Suscripción con prueba gratis de 7 días** (descripción). [Ficha](https://play.google.com/store/apps/details?id=com.sumoing.recolor)
- Mecánica: **colorear libre** (eliges el color), con degradados y "live colors", más de 70 paletas y paletas propias, más de 100 efectos y filtros, e importar fotos propias (descripción).
- Contenido: más de 5.000 láminas: mandalas, fantasía, interiores, retratos, animales, flores y otras (descripción).
- Retención: **3 láminas gratis al día** (10:00, 13:00 y 18:00), eventos y colecciones semanales, y comunidad para compartir (descripción).
- Precio de la suscripción: 14,99–15 US$/mes según reseñas ("I have to pay $15 a month").
- Quejas Play (n=240): **pago o suscripción 72 %** y contenido bloqueado 17 % ("Nearly every picture is locked behind a pay wall").

### B3. Colorfy: Coloring Book Games — Wildlife Studios
- Descargas: 50M+. Nota: **3,76** (872.103). Gratis, con anuncios e IAP de 0,99 a 99,99 US$. [Ficha](https://play.google.com/store/apps/details?id=com.fungamesforfree.colorfy)
- Mecánica: libro de colorear con libre elección de color (lo confirman las reseñas).
- Contenido: mandalas, animales, patrones y flores (descripción). Cifra no encontrada.
- Precio: reseñas con miles de votos citan **7,99 US$/semana** (9.320 votos), 9,99/semana o 2,99/semana según la fecha.
- Quejas Play (n=240): **pago 68 %** ("almost everything is behind a premium subscription wall", 11.369 votos).

### B4. Zen Color – Color By Number — Oakever Games
- Descargas: 5M+. Nota: 4,55 (23.631). Gratis, con anuncios. IAP: **un único precio de 9,99 US$** (Play). [Ficha](https://play.google.com/store/apps/details?id=com.oakever.zencolor)
- Mecánica: colorear por números, efectos "color pop" al rellenar y retrato o apaisado (descripción).
- Contenido: paisajes, animales, escenas acogedoras, mascotas, mandalas y geometría, con imágenes de festividades (descripción). Cifra no encontrada.
- Retención: **sonidos temáticos mientras se colorea**, **modo oscuro**, **insignias de logros**, secciones misterio, "surprises… each time you complete" (descripción) y reto diario (reseña).
- Quejas Play (n=197): anuncios 71 %, pago 20 %. En 2026 hay reseñas que cuentan que la app desapareció de Play y que **se perdieron compras y obras**. Otras se quejan de zonas diminutas en gris muy claro ("can't see them without a magnifying glass").

### B5. Tap Color Pro: Color By Number — Tap Color Studio
- Descargas: 50M+. Nota: 4,55 (219.918). Gratis, con anuncios e IAP de 0,99 a 49,99 US$. [Ficha](https://play.google.com/store/apps/details?id=coloring.color.number.happy.paint.art.drawing.puzzle)
- Mecánica: colorear por números, con **imágenes animadas** a diario (descripción).
- Contenido: más de 20.000 láminas en más de 30 categorías: animadas, animales, flores, mandalas, naturaleza, lugares, festivales, interiores… (descripción).
- Precio: suscripción semanal, mensual o anual, de unos 50 US$/año (hasta unos 230 US$/año pagando por semanas), según reseñas.
- Quejas Play (n=240): anuncios 59 %, fallos 11 %, zonas diminutas 6 %, pérdida de **rachas** ("lose my streaks after over 150 days") y logros, y unas 50 notificaciones al día.

### B6. Color by Number: Coloring Games — Wildlife Studios
- Descargas: 100M+. Nota: 4,60 (513.556). La ficha **no marca "Contiene anuncios"**, pero el 79 % de las reseñas negativas se queja de anuncios. IAP de 7,99 a 99,99 US$. [Ficha](https://play.google.com/store/apps/details?id=com.tfgco.apps.coloring.free.color.by.number)
- Mecánica: pixel art por números, importar fotos, comunidad y herramientas de pintura (descripción).
- Precio: reseñas de 2026 citan 9,99 US$/semana o unos 100 US$/año.
- Quejas Play (n=240): anuncios 79 % (anuncios que pausan la música del usuario) y que quitaron los cubos de pintura como recompensa.

### B7. Mandala Coloring Pages — Coloring Games
- Descargas: 50M+. Nota: 4,44 (348.520). Gratis, con anuncios e IAP de 1,99 a 36,99 US$. [Ficha](https://play.google.com/store/apps/details?id=com.color.mandala)
- Mecánica: **rellenar zonas tocando, con color libre**, botón de deshacer y guardar y cargar. Según las reseñas tiene degradados, efectos 3D y patrones. Recomienda usar lápiz óptico para zonas pequeñas (descripción).
- Contenido: "400+ Mandalas" (descripción).
- Quejas Play (n=240): fallos 12 % y **no guarda el progreso** ("80% done… majority… gone", 597 votos).

### B8. Coloring Book for Adults — ColorTime & PuzzleTime
- Descargas: 5M+. Nota: 4,38 (40.640). Gratis, con anuncios e IAP de 3,49 a 37,99 US$. [Ficha](https://play.google.com/store/apps/details?id=com.colortime.coloringbook)
- Mecánica: tocar para rellenar, más pinceles y lápices, pegatinas y pellizcar para hacer zoom (descripción).
- Contenido: más de 500 láminas de mandalas, flores, corazones y cuadros famosos (Vermeer, van Gogh), con **actualización quincenal** y una opción "Mystery" (descripción).
- Quejas Play (n=235): obras que aparecen en blanco al reabrirlas, zoom insuficiente para zonas pequeñas, se borró una página de 40 minutos y "pay $4 to remove the ads".

### B9. Coloring Book: Color by Number — Candy Mobile
- Descargas: 50M+. Nota: 4,54 (229.554). Gratis, con anuncios. No declara IAP. [Ficha](https://play.google.com/store/apps/details?id=com.iceors.colorbook.release)
- Mecánica: colorear por números con cuadros famosos (Mona Lisa, La noche estrellada), "surprise in the end" y compartir en redes (descripción). Las reseñas destacan el **"watch a replay of your picture"**.
- Quejas Play (n=240): anuncios 35 %, fallos 10 %. Si los anuncios no cargan **no se puede colorear el 60 % de los dibujos** (4.855 votos). Varias reseñas piden **un pago único para quitar los anuncios** ("Please give us the option").

### B10. InColor™ : Coloring & Drawing — Eyewind
- Descargas: 50M+. Nota: 4,43 (128.378). Gratis, con anuncios e IAP de 0,99 a 99,99 US$. **Suscripción semanal, mensual o anual, con 3 días de prueba en algunas** (descripción). [Ficha](https://play.google.com/store/apps/details?id=com.inapp.incolor)
- Mecánica: generador de láminas con IA, pinceles realistas y degradados, dibujo libre y foto convertida en boceto (descripción).
- Retención: comunidad global y retos temáticos semanales (descripción).
- Precio: según reseñas, "$3 wk / $8 mo / $40 yr" (2020) y unos 12 US$/mes (2021).
- Quejas Play (n=240): pago 43 %, contenido bloqueado 11 % y que no guarda el trabajo.

### B11. Classic Adult Coloring Book — Abovegames
- Descargas: 500K+. Nota: 4,48 (8.048). Gratis, con anuncios e IAP de 0,99 a 29,99 US$. [Ficha](https://play.google.com/store/apps/details?id=com.infokombinat.coloringvectorclassic)
- Mecánica: **rellenar zonas con color libre** (una reseña lo llama "only a bucket tool"). Es lo más parecido a Lienzo Zen. Tiene degradados y gran variedad de colores y tonos (descripción y reseñas).
- Contenido: aves, ornamentos, animales, mandalas, fantasía y personas, por categorías (descripción). Cifra no encontrada.
- Retención: **música agradable**, un **contador de láminas terminadas**, la obra como foto de perfil y descarga como fondo de pantalla (descripción).
- Quejas Play (n=140): las láminas premium "You can't BUY them, you RENT them" (por suscripción), faltan marrones para la piel y anuncios.

### B12. Coloring pages: Mandala for me — mobiray
- Descargas: 5M+. Nota: 4,04 (57.478). Gratis, con anuncios e IAP de 1,49 a 2,49 US$. [Ficha](https://play.google.com/store/apps/details?id=com.twodtwob.coloring.adult)
- Mecánica: color libre y juego sin wifi (descripción).
- Contenido: mandalas, anime y unicornios (descripción). Cifra no encontrada.
- Quejas Play (n=240): dibujos de pago (14 %) y poca novedad ("90% of the images are the same ones from yrs ago").

### B13. Coloring Mandalas — Quarzo Apps
- Descargas: 1M+. Nota: 4,16 (1.662). Gratis, con anuncios. IAP: **un único precio de 4,49 US$**. [Ficha](https://play.google.com/store/apps/details?id=com.quarzo.paintmandalas)
- Mecánica: colores personalizables, deshacer, **autoguardado**, compartir, **modo oscuro**, retrato y apaisado, y todo disponible sin conexión (descripción).
- Retención: **"Page of the day"** (descripción).
- Quejas Play (n=97): muy pocas por anuncios (2 %). Hay quejas por diseños básicos, porque el deshacer no funciona y porque no se puede guardar la imagen en la galería.
- Por qué es útil: el modelo y las funciones son casi los de Lienzo Zen, con mucho menos contenido.

### B14. ColorMe – Coloring Book — Dot to Dot
- Descargas: 10M+. Nota: 4,43 (170.305). Gratis, con anuncios e IAP de 0,99 a 49,99 US$. [Ficha](https://play.google.com/store/apps/details?id=com.adult.coloring.book.pages)
- Mecánica: color libre, que la app vende con "TRUE CREATIVE FREEDOM (NO 'COLOR BY NUMBER')". Modos lápiz y acuarela, más de 200 colores y paletas propias (descripción).
- Contenido: más de 500 láminas, "updated daily" (descripción).
- Quejas Play (n=240): anuncios 55 % ("long video ads about every 60 seconds"). Quitar los anuncios cuesta 19,99 US$ ("I'd love an option to just pay for ad free that isn't $20").

### B15. Colorscapes® – Color by Number — Playflux
- Descargas: 50M+. Nota: 4,73 (410.271). Gratis, con anuncios e IAP de 4,99 a 69,99 US$. [Ficha](https://play.google.com/store/apps/details?id=com.artlife.coloringbook)
- Mecánica: colorear por números con una mano y "tips and tricks at every step" (descripción).
- Contenido: más de 2.500 obras, nuevas cada día (descripción).
- Precio: VIP de "$7 a week, $13 a month and $70 per year" (reseña de 2023).
- Quejas Play (n=240): anuncios 54 %, pistas 12 % (una **notificación de pista que suena y vibra tras 10 s de inactividad**) y zonas difíciles de localizar ("siempre quedan lugares difíciles de localizar", 899 votos). También piden pintar como con un lápiz: "como si tu dedo fuera un lápiz".

### B16. Crayola Adult Coloring — Red Games Co.
- Descargas: 50K+. Nota: 3,71 (133). Gratis. La ficha no marca anuncios, pero una reseña los menciona. IAP de 0,99 a 159,99 US$. [Ficha](https://play.google.com/store/apps/details?id=com.crayolallc.coloring.adult)
- Mecánica: rotuladores, pasteles, lápices, ceras y acuarela, 147 colores oficiales Crayola y efectos animados (descripción).
- Contenido: "hundreds" de láminas, con más cada mes (descripción).
- Quejas Play (n=28, muestra pequeña): suscripción ("$50 yearly"), contenido bloqueado y fallos.

### B17. Pixel Art – Color by Number — Easybrain
- Descargas: 100M+. Nota: 4,63 (2.596.261). Gratis, con anuncios e IAP de 5,49 a 46,99 US$. [Ficha](https://play.google.com/store/apps/details?id=com.europosit.pixelcoloring)
- Mecánica: pixel art por números, **potenciadores ("Color Splash", "Magic Wand")**, cámara para pixelar fotos y objetos 3D (descripción).
- Contenido: más de 40.000 imágenes, nuevas cada día (descripción).
- Retención: **eventos de temporada** con colecciones, un meta-juego **"Flower Garden"** con recompensas y **time-lapse para compartir** (descripción).
- Precio: 14,99 US$/mes o unos 47–60 US$/año según reseñas.
- Quejas Play (n=240): **anuncios 83 %** ("Before, during, AND after each pic") y pago 25 %.

**Referencias solo de iOS (no están en Play EE. UU.)**: Lake: Coloring Book for Adults (Apple id 1183717726) y Adult Coloring Book – Pigment (Pixite, id 1062006344). Sus reseñas están en `replica/reviews.csv`. Según [búsqueda web](https://apps.apple.com/app/id1183717726), Lake cobra 2,99 US$/semana, 9,99/mes o 59,99/año en el App Store. Para Pigment, AlternativeTo cita unos 11 US$/mes ([alternativeto](https://alternativeto.net/software/pigment-coloring-book/about)). Ninguno de los dos precios se verificó en la tienda.

---

## 3. Tablas resumen

### Grupo A (sopas de letras)

| App | Estudio | Descargas | Nota (valoraciones) | Precio | Anuncios | IAP | Actualizada | Quejas Play (muestra 1–3★) | Fuente |
|---|---|---|---|---|---|---|---|---|---|
| Word Search Explorer | PlaySimple Games | 100M+ | 4,91 (1.257.257) | Gratis | Sí | 0,99–49,99 | 2026-09-28 | n=240: anuncios 63 %, pago 12 %, repetitivo 8 %, fallos 5 % | [ficha](https://play.google.com/store/apps/details?id=in.playsimple.wordsearch) |
| Word Search (Journey) | Bluetile | 100M+ | 4,80 (779.909) | Gratis | Sí | 0,99–19,99 | 2026-09-30 | n=240: anuncios 44 %, pago 5 %, repetitivo 17 %, fallos 7 % | [ficha](https://play.google.com/store/apps/details?id=com.playvalve.wsjourney) |
| Wordscapes Search | PeopleFun | 10M+ | 4,70 (233.290) | Gratis | Sí | 0,99–99,99 | 2026-09-25 | n=163: anuncios 39 %, pago 11 %, repetitivo 4 %, fallos 16 % | [ficha](https://play.google.com/store/apps/details?id=com.peoplefun.wordsearch) |
| Word Search Quest | Blackout Lab | 100M+ | 4,76 (1.016.301) | Gratis | Sí | 0,99–22,99 | 2026-09-28 | n=240: anuncios 60 %, pago 7 %, repetitivo 15 %, fallos 2 % | [ficha](https://play.google.com/store/apps/details?id=com.blackout.word) |
| Words of Wonders: Search | Fugo Games | 10M+ | 4,93 (179.788) | Gratis | Sí | 0,99–49,99 | 2026-10-02 | n=240: anuncios 41 %, pago 8 %, repetitivo 5 %, fallos 5 % | [ficha](https://play.google.com/store/apps/details?id=com.fugo.wowsearch) |
| Word Search | Italic Games | 10M+ | 4,76 (465.859) | Gratis | Sí | no declara | 2026-10-08 | n=227: anuncios 23 %, pago 0 %, repetitivo 11 %, fallos 4 % | [ficha](https://play.google.com/store/apps/details?id=com.mobilegame.wordsearch) |
| Infinite Word Search | Random Logic Games | 10M+ | 4,68 (80.524) | Gratis | Sí | 0,99–49,99 | 2026-10-05 | n=240: anuncios 61 %, pago 12 %, repetitivo 8 %, fallos 11 % | [ficha](https://play.google.com/store/apps/details?id=com.randomlogicgames.wordsearch) |
| Sopa de Letras en Español | Senior Games | 5M+ | 4,64 (101.159) | Gratis | Sí | 0,89–39,99 | 2026-08-24 | n=240: anuncios 35 %, pago 3 %, repetitivo 10 %, fallos 5 % | [ficha](https://play.google.com/store/apps/details?id=com.tellmewow.senior.word.search) |
| Sopa de letras — Reto diario | AsgardSoft | 10M+ | 4,67 (108.943) | Gratis | Sí | 1,99–4,99 | 2026-08-24 | n=225: anuncios 13 %, pago 1 %, repetitivo 9 %, fallos 2 % | [ficha](https://play.google.com/store/apps/details?id=com.asgardsoft.words) |
| ¡Sopa de Letras! | Mindful Daily Puzzles | 10M+ | 4,91 (249.013) | Gratis | Sí | no declara | 2026-01-05 | n=225: anuncios 38 %, pago 0 %, repetitivo 3 %, fallos 0 % | [ficha](https://play.google.com/store/apps/details?id=com.word.search.find.puzzle) |
| Sopa de Letras: Español | RV AppStudios | 1M+ | 4,17 (8.364) | Gratis | Sí | 0,99–49,99 | 2026-09-22 | n=199: anuncios 8 %, pago 0 %, repetitivo 3 %, fallos 3 % | [ficha](https://play.google.com/store/apps/details?id=com.rvappstudios.word.search.puzzle.game) |
| Bible Word Search | Hustle Run | 1M+ | 4,80 (29.705) | Gratis | Sí | 0,99–49,99 | 2026-06-03 | n=142: anuncios 59 %, pago 4 %, repetitivo 5 %, fallos 2 % | [ficha](https://play.google.com/store/apps/details?id=com.econogames.bible.wordsearch.gp) |
| Sopa de letras en español | Onni Lab | 1M+ | 4,63 (8.018) | Gratis | Sí | no declara | 2026-03-27 | n=107: anuncios 25 %, pago 1 %, repetitivo 5 %, fallos 1 % | [ficha](https://play.google.com/store/apps/details?id=com.milimimili.pc) |
| Vita Word Search for Seniors | Vita Studio | 100K+ | 4,63 (9.481) | Gratis | Sí | 0,99–19,99 | 2026-08-18 | n=60: anuncios 31 %, pago 1 %, repetitivo 3 %, fallos 3 % | [ficha](https://play.google.com/store/apps/details?id=com.vitastudio.wordsearch) |
| **Word Search Games PRO** | LittleBigPlay | **10K+** | 4,48 (136) | **1,99 US$** | No | no | 2026-09-19 | n=7 (insuficiente) | [ficha](https://play.google.com/store/apps/details?id=air.com.littlebigplay.games.premium.wordsearchgames) |
| Word Search Nature | Appgeneration | 1M+ | 4,59 (10.055) | Gratis | Sí | 0,99–22,99 | 2026-09-29 | n=103: anuncios 15 %, pago 0 %, repetitivo 4 %, fallos 2 % | [ficha](https://play.google.com/store/apps/details?id=word.search.games.free) |

### Grupo B (colorear)

| App | Estudio | Descargas | Nota (valoraciones) | Precio | Anuncios | IAP | Actualizada | Quejas Play (muestra 1–3★) | Fuente |
|---|---|---|---|---|---|---|---|---|---|
| Happy Color | X-FLOW | 100M+ | 4,56 (3.900.459) | Gratis | Sí | 1,99–7,99 | 2026-10-08 | n=240: anuncios 82 %, pago 10 %, fallos 2 % | [ficha](https://play.google.com/store/apps/details?id=com.pixel.art.coloring.color.number) |
| Recolor | Recolor | 10M+ | 3,54 (85.835) | Gratis + suscripción | Sí | 1,99–108,71 | 2025-12-19 | n=240: anuncios 27 %, **pago 72 %**, fallos 6 % | [ficha](https://play.google.com/store/apps/details?id=com.sumoing.recolor) |
| Colorfy | Wildlife Studios | 50M+ | 3,76 (872.103) | Gratis + suscripción | Sí | 0,99–99,99 | 2026-09-22 | n=240: anuncios 15 %, **pago 68 %**, fallos 2 % | [ficha](https://play.google.com/store/apps/details?id=com.fungamesforfree.colorfy) |
| Zen Color | Oakever Games | 5M+ | 4,55 (23.631) | Gratis | Sí | 9,99 | 2026-09-25 | n=197: anuncios 71 %, pago 20 %, fallos 5 % | [ficha](https://play.google.com/store/apps/details?id=com.oakever.zencolor) |
| Tap Color Pro | Tap Color Studio | 50M+ | 4,55 (219.918) | Gratis + suscripción | Sí | 0,99–49,99 | 2026-09-23 | n=240: anuncios 59 %, pago 13 %, fallos 11 % | [ficha](https://play.google.com/store/apps/details?id=coloring.color.number.happy.paint.art.drawing.puzzle) |
| Color by Number | Wildlife Studios | 100M+ | 4,60 (513.556) | Gratis + suscripción | No (según ficha) | 7,99–99,99 | 2026-10-06 | n=240: anuncios 79 %, pago 8 %, fallos 3 % | [ficha](https://play.google.com/store/apps/details?id=com.tfgco.apps.coloring.free.color.by.number) |
| Mandala Coloring Pages | Coloring Games | 50M+ | 4,44 (348.520) | Gratis | Sí | 1,99–36,99 | 2025-10-22 | n=240: anuncios 17 %, pago 5 %, fallos 12 % | [ficha](https://play.google.com/store/apps/details?id=com.color.mandala) |
| Coloring Book for Adults | ColorTime | 5M+ | 4,38 (40.640) | Gratis | Sí | 3,49–37,99 | 2025-10-30 | n=235: anuncios 24 %, pago 6 %, fallos 6 % | [ficha](https://play.google.com/store/apps/details?id=com.colortime.coloringbook) |
| Coloring Book: Color by Number | Candy Mobile | 50M+ | 4,54 (229.554) | Gratis | Sí | no declara | 2026-09-22 | n=240: anuncios 35 %, pago 5 %, fallos 10 % | [ficha](https://play.google.com/store/apps/details?id=com.iceors.colorbook.release) |
| InColor | Eyewind | 50M+ | 4,43 (128.378) | Gratis + suscripción | Sí | 0,99–99,99 | 2026-05-21 | n=240: anuncios 31 %, pago 43 %, fallos 6 % | [ficha](https://play.google.com/store/apps/details?id=com.inapp.incolor) |
| Classic Adult Coloring Book | Abovegames | 500K+ | 4,48 (8.048) | Gratis + suscripción | Sí | 0,99–29,99 | 2026-08-24 | n=140: anuncios 13 %, pago 9 %, fallos 7 % | [ficha](https://play.google.com/store/apps/details?id=com.infokombinat.coloringvectorclassic) |
| Mandala for me | mobiray | 5M+ | 4,04 (57.478) | Gratis | Sí | 1,49–2,49 | 2026-04-26 | n=240: anuncios 23 %, pago 14 %, fallos 4 % | [ficha](https://play.google.com/store/apps/details?id=com.twodtwob.coloring.adult) |
| Coloring Mandalas | Quarzo Apps | 1M+ | 4,16 (1.662) | Gratis | Sí | 4,49 | 2026-08-04 | n=97: anuncios 2 %, pago 3 %, fallos 4 % | [ficha](https://play.google.com/store/apps/details?id=com.quarzo.paintmandalas) |
| ColorMe | Dot to Dot | 10M+ | 4,43 (170.305) | Gratis | Sí | 0,99–49,99 | 2026-08-30 | n=240: anuncios 55 %, pago 17 %, fallos 6 % | [ficha](https://play.google.com/store/apps/details?id=com.adult.coloring.book.pages) |
| Colorscapes | Playflux | 50M+ | 4,73 (410.271) | Gratis + VIP | Sí | 4,99–69,99 | 2026-06-02 | n=240: anuncios 54 %, pago 10 %, fallos 10 % | [ficha](https://play.google.com/store/apps/details?id=com.artlife.coloringbook) |
| Crayola Adult Coloring | Red Games Co. | 50K+ | 3,71 (133) | Gratis + suscripción | No (según ficha) | 0,99–159,99 | 2026-09-17 | n=28: pago 21 %, fallos 21 % | [ficha](https://play.google.com/store/apps/details?id=com.crayolallc.coloring.adult) |
| Pixel Art | Easybrain | 100M+ | 4,63 (2.596.261) | Gratis + suscripción | Sí | 5,49–46,99 | 2026-09-07 | n=240: anuncios 83 %, pago 25 %, fallos 7 % | [ficha](https://play.google.com/store/apps/details?id=com.europosit.pixelcoloring) |

"Gratis + suscripción" se marca solo cuando la descripción o las reseñas lo confirman.

---

## 4. Lo que hacen casi todos y a nuestros juegos les falta

Se ordena por impacto (lo que más pesa en retención y reseñas) y esfuerzo (S = días, M = 1–2 semanas, L = más).

### Palabrario

Ya tiene: sopa del día, racha, pistas, 4 dificultades, 44 temas, 3 diseños y no tiene anuncios. Estas cuatro cosas coinciden con lo mejor del mercado y **la ausencia de anuncios es la queja nº 1 de la competencia** (secciones 1 y 6).

| # | Qué falta | Quién lo hace | Impacto | Esfuerzo |
|---|---|---|---|---|
| 1 | **Mapa o viaje de progresión** (avanzar por destinos o colecciones que se desbloquean) en vez de una lista de temas | Explorer, Bluetile, Words of Wonders, Wordscapes Search | Alto: es la columna vertebral de los 4 mayores | M |
| 2 | **Logros y clasificación** (Google Play Games: logros y tabla de la sopa del día) | AsgardSoft, Infinite WS, Zen Color; WoW: reseñas lo piden | Alto | S–M |
| 3 | **Palabras extra o bonus** (palabras ocultas fuera de la lista que dan pistas o puntos) | Wordscapes Search, Explorer, Appgeneration | Medio-alto: añade reto sin hacer nuevas sopas | S |
| 4 | **Modo infinito o relax** con sopas generadas por tema y dificultad | Word Search Quest, AsgardSoft, Infinite WS | Alto contra la queja "repetitivo" (5–17 %) | M |
| 5 | **Eventos temporales** (fin de semana temático, Navidad) | Explorer, Bluetile, Wordscapes Search | Medio | M |
| 6 | **Accesibilidad**: tamaño de letra, alto contraste, modo noche | RV AppStudios, Vita, Senior Games | Medio-alto (público mayor) | S |
| 7 | **Modo contrarreloj opcional** junto al relajado | Italic, AsgardSoft, LittleBigPlay | Medio | S |
| 8 | **Guardado en la nube o restaurar compras** al cambiar de móvil | Explorer, Appgeneration (Facebook) | Medio: Zen Color recibió reseñas de 1★ por perder compras | M |
| 9 | Recordatorio de racha **opcional** y respetuoso | Casi todos (y se quejan del abuso) | Medio | S |

### Lienzo Zen

Ya tiene: 749 láminas, toque o arrastre, zoom, deshacer, 8 paletas, Mis obras y no tiene anuncios.

| # | Qué falta | Quién lo hace | Impacto | Esfuerzo |
|---|---|---|---|---|
| 1 | **Ayuda para encontrar zonas sin pintar** (resaltar o "ir a la siguiente zona vacía") | Happy Color (bombilla), Pixel Art (potenciadores), Colorscapes (pistas); las quejas de zonas diminutas llegan al 6 % | Alto | S–M |
| 2 | **Animación de lámina terminada y repetición en time-lapse para compartir** | Happy Color, Pixel Art, Candy Mobile, Zen Color ("color pop") | Alto: es la recompensa emocional | M |
| 3 | **Lámina del día** y racha | Recolor, Quarzo, ColorTime, Pixel Art, Zen Color | Alto | S |
| 4 | **Exportar a la galería y fondo de pantalla** (si no lo tiene) | Abovegames, Quarzo (se quejan de que no lo tiene), casi todos comparten | Alto (y marketing gratis) | S |
| 5 | **Música o sonidos ambientales opcionales** | Zen Color, Abovegames | Medio | S |
| 6 | **Selector libre de color, paleta propia y degradados** | Recolor, ColorMe, Abovegames, Mandala Coloring Pages | Medio-alto: es lo que valoran los que huyen del "por números" | M |
| 7 | **Logros o colecciones** (completar una categoría da una lámina o paleta) | Happy Color, Zen Color, Pixel Art | Medio | S–M |
| 8 | **Modo "por números" opcional** | Happy Color, Pixel Art, Zen Color, Tap Color, Colorscapes, Candy (el formato dominante por descargas) | Alto en mercado, alto en esfuerzo: hay que numerar 749 láminas | L |
| 9 | **Láminas misterio o eventos** | Happy Color, Zen Color, ColorTime | Medio | M |
| 10 | Modo oscuro o tema nocturno | Zen Color, Quarzo | Bajo-medio | S |

---

## 5. Riesgo del modelo "pago único de 4,99 US$ sin anuncios"

**Lo que dicen los datos**
1. **El mercado es abrumadoramente gratuito.** El 96,6 % de las apps de Google Play son gratis y el 3,4 % de pago, según AppBrain (actualizado el 9 de octubre de 2026) ([AppBrain](https://www.appbrain.com/stats/free-and-paid-android-applications)). De las 33 apps revisadas, **32 son gratis**. La única de pago es Word Search Games PRO, que con 1,99 US$ tiene **10K+ descargas y 136 valoraciones**, frente a los 10M–100M+ de las gratuitas ([ficha](https://play.google.com/store/apps/details?id=air.com.littlebigplay.games.premium.wordsearchgames)). Las otras dos sopas de pago encontradas en la búsqueda de Play tienen cifras parecidas: Words Search – Premium (1,99 US$, 10K+) y Word Search Daily PRO (2,49 US$, 5K+).
2. **El usuario odia los anuncios, pero los aguanta porque entró gratis.** Los anuncios son la queja dominante: 63 % en Word Search Explorer, 82 % en Happy Color, 83 % en Pixel Art (sección 3). Aun así, esas apps tienen notas de 4,5–4,9 y cientos de millones de descargas.
3. **Las suscripciones se castigan en la nota.** Las dos apps de colorear con muro de suscripción tienen las peores notas del grupo: Recolor 3,54 (72 % de quejas por pago) y Colorfy 3,76 (68 %). Los usuarios citan precios de 7,99 US$/semana o 15 US$/mes.
4. **Muchos usuarios piden un pago único y lo valoran en unos 5 US$.** Lo piden en Word Search Quest, ¡Sopa de Letras!, Candy Mobile, Tap Color y Colorscapes. Sobre el precio: en Wordscapes Search, "$10 is too much… Maybe $5 at most"; en Words of Wonders, "most games… only ask $3-6"; en ColorMe, "an option to just pay for ad free that isn't $20". El dato también aparece en las reseñas de iOS (sección 6). Zen Color vende un único IAP de 9,99, que las reseñas describen como versión sin anuncios con pistas ilimitadas. Quarzo tiene un único IAP de 4,49, cuya finalidad no se verificó. AsgardSoft vende su premium (sin anuncios y pistas ilimitadas) con IAP de 1,99–4,99.
5. **En Play no hay prueba gratis para apps de pago.** Solo existe el reembolso, que en las primeras 48 h "puede" concederse según el caso, y que se da una sola vez por app ([Google Play Help](https://support.google.com/googleplay/answer/15574908)). Sin prueba, el usuario compra a ciegas, frente a 32 alternativas gratuitas.
6. **Google Play Pass es un canal pensado para apps de pago sin anuncios.** Los suscriptores juegan gratis y el desarrollador cobra un *royalty* según el uso. "All developers can express interest", y para una app de pago basta integrar la licencia de Play ([Play Pass para desarrolladores](https://google.play/business/programs/googleplaypass/)). La misma página dice que Play Pass empezó solo en EE. UU. y no da criterios de admisión. La sopa de Italic Games está en Play Pass, según sus reseñas.

**El riesgo, en una frase:** el producto encaja con lo que piden los usuarios (sin anuncios, pago único, unos 5 US$), pero cobrar **antes** de probar elimina casi todo el embudo de descubrimiento, que en esta categoría funciona por instalaciones gratuitas. Con un pago por adelantado, lo esperable es quedarse en decenas de miles de descargas, como los ejemplos de pago revisados.

**Recomendación (honesta, y la decisión es del dueño)**
- **Opción recomendada: gratis para probar más un único "Desbloquear todo" sin anuncios en ninguna versión.**
  - Palabrario: la sopa del día y la racha gratis siempre, más 3–4 temas completos en todas las dificultades (por ejemplo, unas 40–50 sopas). El resto se desbloquea con un pago único de **3,99–4,99 US$**. Los paquetes de pistas se pueden mantener, pero quien pague el desbloqueo debería recibir más pistas diarias, porque las reseñas castigan "pagué y me siguen vendiendo cosas" (ejemplo de Happy Color, sección 2).
  - Lienzo Zen: la lámina del día gratis más unas 50–80 láminas de varias categorías. Pago único de **3,99–4,99 US$** por las 749 y las 8 paletas.
  - Así se mantiene el mensaje "sin anuncios, pagas una vez", que es el diferenciador frente a la competencia, sin renunciar al tráfico gratuito.
- **Alternativa si se quiere mantener la app de pago:** bajar a 2,99 US$, solicitar la entrada en Play Pass y poner capturas que digan "sin anuncios, sin suscripción" en la primera imagen. Hay que esperar volúmenes pequeños.
- **No recomendado:** suscripción o anuncios. Es exactamente lo que más se odia en las reseñas, y anularía el argumento de venta.
- Antes de decidir conviene probar el precio con experimentos de ficha en Play Console (pruebas A/B de la ficha) y medir la conversión del desbloqueo con la versión gratuita. Ninguna de las cifras de conversión está verificada aquí: no hay datos públicos fiables para esta categoría.

---

## 6. Lo que dicen las reseñas textuales (método replica-entrepreneur)

**Muestra real**
- `replica/reviews.csv` tiene **484 filas**: 481 reseñas de 1 a 4★ del RSS oficial de Apple y 3 comentarios de Hacker News. `reviews.py` usó **482**, porque descartó 2 duplicadas; 479 tienen estrellas.
- Reparto por estrellas de las reseñas de Apple: 188 de 1★, 69 de 2★, 96 de 3★ y 128 de 4★. Fechas entre 2020-04-17 y 2026-10-08 (más un comentario de HN de 2012). 356 de las 484 filas son de 2026, porque el RSS se pidió ordenado por las más nuevas.
- **Sopas (142 reseñas)**: Word Search Quest 45, Words of Wonders: Search 39, Wordscapes Search 23, Word Search Explorer 16, Word Search (Doodle Mobile) 10, Sopa de Letras (Emmanuel Mathis) 8 y 1 de HN.
- **Colorear (340 tras quitar duplicadas)**: Pigment 108, Colorfy 71, Lake 63, Happy Color 47, Colorscapes 26, Zen Color 25 y 2 de HN.
- Para Recolor y Word Search Journey, el RSS devolvió el feed vacío en todos los intentos.
- **Sesgo:** 242 de las 340 reseñas de colorear son de apps con suscripción (Pigment, Colorfy y Lake), lo que infla el tema "precio".
- **"(thin)"** en `feedback.md` significa que el tema solo aparece en una plataforma, el App Store, porque Google Play quedó fuera por la regla de no usar scraping y Reddit dio 403. Es poca diversidad de fuentes, no necesariamente pocas reseñas.
- Archivos: [`replica/feedback.md`](replica/feedback.md) con todo junto, y [`replica/feedback_sopas.md`](replica/feedback_sopas.md) y [`replica/feedback_colorear.md`](replica/feedback_colorear.md) por grupo. Los temas están en `replica/themes.json`, adaptado al español y a juegos.

### 6.1 Lo que odian (quejas sobre lo que hacen las apps)

| # | Tema | Reseñas (sopas / colorear) | Fuentes | Citas |
|---|---|---|---|---|
| 1 | Precio, suscripción y muros de pago | 118 (8 / 110) | 2 | "Having to pay $7.00 a week." ([Pigment, App Store EE. UU.](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1062006344/sortBy=mostRecent/json)); "TODO SE TIENE QUE PAGAR." ([Pigment, App Store España](https://itunes.apple.com/es/rss/customerreviews/page=1/id=1062006344/sortBy=mostRecent/json)) |
| 2 | Anuncios en exceso | 116 (**58 = 41 % de las sopas** / 58) | 2 | "De tantos anuncios te desconcentras" ([Word Search Explorer, MX](https://itunes.apple.com/mx/rss/customerreviews/page=1/id=1602508478/sortBy=mostRecent/json)); "Estoy cansada de tanta publicidad." ([Happy Color, ES](https://itunes.apple.com/es/rss/customerreviews/page=1/id=1407852246/sortBy=mostRecent/json)) |
| 3 | Fallos y cierres | 27 (9 / 18) | 1 (thin) | "This App crashes, closes, way too often" ([Word Search Doodle, EE. UU.](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1533569824/sortBy=mostRecent/json)) |
| 4 | Casi todo bloqueado, poco gratis | 20 (1 / 19) | 2 | "You only get like 2 free pages to color and they’re not good." ([Pigment, EE. UU., p. 2](https://itunes.apple.com/us/rss/customerreviews/page=2/id=1062006344/sortBy=mostRecent/json)) |
| 5 | Anuncio forzado tras cada nivel | 19 (10 / 9) | 1 (thin) | "I am faced with an ad after every single puzzle." ([Wordscapes Search, EE. UU.](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1420294918/sortBy=mostRecent/json)) |
| 6 | Demasiado fácil o repetitivo | 17 (7 / 10) | 1 (thin) | "The game repeats the same 5 categories with the same words over and over again." ([Word Search Quest, EE. UU., p. 2](https://itunes.apple.com/us/rss/customerreviews/page=2/id=1479305181/sortBy=mostRecent/json)) |
| 7 | Errores de ortografía y palabras inventadas (sopas en español) | 13 (13 / 0) | 1 (thin) | "Está llena de plabras que no existen, de palabras en inglés y de erratas" ([Words of Wonders: Search, ES](https://itunes.apple.com/es/rss/customerreviews/page=1/id=1483222663/sortBy=mostRecent/json)); "Casi todas las dizque pal ras se las inventaron porque no existen!!!chafa" ([Sopa de Letras, MX](https://itunes.apple.com/mx/rss/customerreviews/page=1/id=1024928081/sortBy=mostRecent/json)) |
| 8 | Cobros y renovaciones no deseadas | 10 (1 / 9), media de 1,1★ | 1 (thin) | "Hice la prueba de una semana, se me realizó la renovación sin ningún tipo de autorización previa" ([Colorfy, ES](https://itunes.apple.com/es/rss/customerreviews/page=1/id=1009442510/sortBy=mostRecent/json)) |
| 9 | Una actualización lo empeoró | 10 | 1 (thin) | "Desde la última actualización se me bloquea o se cierra." ([Words of Wonders: Search, ES](https://itunes.apple.com/es/rss/customerreviews/page=1/id=1483222663/sortBy=mostRecent/json)). Leída a mano, fuera del recuento: "porque quitaron el buscar palabras a contra tiempo!!!!!! … Mas de dos años de reto matutino lo echaron a perder" ([WoW: Search, MX](https://itunes.apple.com/mx/rss/customerreviews/page=1/id=1483222663/sortBy=mostRecent/json)) |
| 10 | Pistas y monedas | 9 | 1 (thin) | "Why isn’t there a use for the coins? … they are basically worthless." ([Wordscapes Search, EE. UU.](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1420294918/sortBy=mostRecent/json)) |

Temas pequeños (thin, pocas reseñas): obras perdidas (5), batería (4), zonas difíciles de ver (4: "It’s like hide n seek especially for a senior", [Zen Color, EE. UU.](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1557392270/sortBy=mostRecent/json)), arte con IA (3) y sonido o notificaciones (1). En la muestra de Google Play estos temas pesan más (sección 1–2: zonas diminutas hasta 6 %, arte IA en Happy Color, sonido de anuncios).

### 6.2 Lo que falta (piden por su nombre)

| # | Petición | Reseñas | Fuentes | Citas |
|---|---|---|---|---|
| 1 | Libertad creativa: elegir el color, pinceles, **colorear con el dedo y no solo tocar** | 28 (colorear) | 2 | "me gustaría que… en vez de tocar y que se coloree que nosotros lo coloreemos" ([Pigment, ES](https://itunes.apple.com/es/rss/customerreviews/page=1/id=1062006344/sortBy=mostRecent/json)); "You only have like 9 drawings you can do and you only have one paint brush." ([Lake, EE. UU., p. 2](https://itunes.apple.com/us/rss/customerreviews/page=2/id=1183717726/sortBy=mostRecent/json)) |
| 2 | Contenido diario, rachas y eventos (y que funcionen) | 12 | 2 | "as of August 8,2026, I can no longer open the daily pictures to paint anymore!" ([Pigment, EE. UU., p. 2](https://itunes.apple.com/us/rss/customerreviews/page=2/id=1062006344/sortBy=mostRecent/json)) |
| 3 | Guardar, exportar o poner de fondo de pantalla | 7 | 2 | "No puedo guardar la y magen para poner la de fondo de pantalla" ([Colorscapes, MX](https://itunes.apple.com/mx/rss/customerreviews/page=1/id=1502948858/sortBy=mostRecent/json)) |
| 4 | Más contenido gratis | 6 (y unas 15 en la lista literal) | 1 (thin) | "Deberían haber más cosas gratis." ([Pigment, ES](https://itunes.apple.com/es/rss/customerreviews/page=1/id=1062006344/sortBy=mostRecent/json)) |
| 5 | Quitar anuncios con **pago único** | 5 + 3 | 1 (thin) | "Removing ads should be a one-time purchase." ([Wordscapes Search, EE. UU.](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1420294918/sortBy=mostRecent/json)); "Just wish I could purchase one time, rather than subscribe every year." ([Pigment, EE. UU.](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1062006344/sortBy=mostRecent/json)) |
| 6 | Jugar sin conexión | 5 | 1 (thin) | "So much for no adds and no WiFi" ([Zen Color, EE. UU.](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1557392270/sortBy=mostRecent/json)) |
| 7 | Ocultar láminas que no gustan o las ya terminadas (leído a mano) | 3 | 1 (thin) | "There are ones I wish I could hide since I’ll never color them." ([Lake, EE. UU.](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1183717726/sortBy=mostRecent/json)) |
| 8 | Contrarreloj opcional o más dificultad (sopas) | 2 + 2 a mano | 1 (thin) | "me gustaría que tuviera un tiempo limite para hacerlo" ([Word Search Explorer, MX](https://itunes.apple.com/mx/rss/customerreviews/page=1/id=1602508478/sortBy=mostRecent/json)) |

### 6.3 Lo que nadie resuelve (huecos para posicionarse)

1. **Un juego completo sin anuncios ni suscripción, pagando una vez.** Ninguna de las apps grandes lo ofrece como propuesta principal. Las excepciones son pequeñas o parciales: Word Search Games PRO (de pago, 10K+ descargas); AsgardSoft y Zen Color, que tienen un premium o versión sin anuncios dentro de una app gratuita con anuncios; y "quitar anuncios", a 5,99 en Explorer y renovable cada 30 días en Wordscapes Search. Las quejas son fuertes (116 por anuncios y 118 por precio), pero las peticiones explícitas de pago único son pocas en iOS (8) y algo más frecuentes en Play (sección 5). Este es el hueco de Palabrario y de Lienzo Zen.
2. **Una sopa de letras nativa en español con palabras revisadas.** Las 13 quejas de ortografía, palabras inventadas o en inglés vienen de apps traducidas (Words of Wonders en España y Sopa de Letras en México). También hay una queja de "está en inglés todo, no hay servicio técnico" ([Colorfy, ES](https://itunes.apple.com/es/rss/customerreviews/page=1/id=1009442510/sortBy=mostRecent/json)). Es thin (una sola fuente), pero encaja con el producto.
3. **Colorear con el dedo y con todo incluido.** Los que buscan libertad creativa (28 reseñas) tienen que ir a apps de suscripción (Pigment, Lake, Recolor o Colorfy) o a apps llenas de anuncios (ColorMe). El modo Pincel de Lienzo Zen responde a esa petición literal.
4. Pista menor (thin): el contenido diario **sin polémicas**. Hay quejas por láminas del día inapropiadas en Zen Color y Pigment ([Zen Color, EE. UU.](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1557392270/sortBy=mostRecent/json)). Conviene curar la sopa y la lámina del día.

### 6.4 Ángulo de posicionamiento (skill, paso 5)

- **A (recomendado para Palabrario).** Para quien juega sopas de letras en español y está harto de anuncios tras cada sopa y de palabras inventadas, Palabrario ofrece 545 sopas revisadas en español, sin un solo anuncio y pagando una vez. *Evidencia: anuncios en 58 de las 142 reseñas de sopas (41 %), anuncio forzado 10, errores de palabras 13; en Play, anuncios entre el 13 y el 63 % de las reseñas negativas.*
- **B (recomendado para Lienzo Zen).** Para quien quiere colorear tranquilo sin que cada lámina bonita esté detrás de una suscripción semanal, Lienzo Zen trae 749 láminas y 8 paletas, sin anuncios y con un solo pago, pintando con el dedo o tocando. *Evidencia: precio o suscripción en 110 de las 340 reseñas de colorear (32 %), contenido bloqueado 19, libertad creativa 28; en Play, Recolor tiene 72 % de quejas por pago y Colorfy 68 %.*
- **C (alternativa, thin).** Pensado para mayores: letra grande, alto contraste y ayuda para encontrar lo que falta. *Evidencia: pocas reseñas en iOS (2 de accesibilidad y 1 de "hide n seek" para mayores), aunque hay apps enteras para este público en Play (Vita, Senior Games).*

No uses el nombre de los competidores en la ficha ni en anuncios. Las citas de esta sección son material de investigación, no testimonios.

Nota: la skill propone además `replica/fixes.md` y filas en `features.csv`. No se crearon porque el encargo pedía integrarlo en este informe; el plan de mejoras está en las secciones 7 y 8.

---

## 7. 10 mejoras para Palabrario (en orden)

Orden por impacto según la evidencia y por lo barato que es hacerlo. Talla: S = días, M = 1–2 semanas, L = más.

1. **Entrada gratis más desbloqueo único (lo decide el dueño).** La sopa del día y la racha gratis siempre, más 3–4 temas completos; el resto con un pago único de 3,99–4,99 US$ y sin anuncios nunca. Quien haya pagado no debería ver ofertas de pistas durante la partida. *M. Evidencia: sección 5 y 6.3-1.*
2. **Revisión lingüística de las 545 sopas**: ortografía, tildes, nada de anglicismos y cada palabra dentro de su tema. Conviene decirlo en la ficha ("palabras revisadas por hablantes nativos"). *S–M. Evidencia: 13 reseñas de iOS sobre palabras inventadas o erratas; en Play, Italic Games recibe quejas de faltas de ortografía.*
3. **Mapa o colecciones de progreso**: los 44 temas como "rutas" que se desbloquean y dan recompensas (diseños visuales extra, insignias). *M. Evidencia: es la estructura de Explorer, Bluetile, Words of Wonders y Wordscapes Search.*
4. **Logros y tabla de la sopa del día con Google Play Games.** *S–M. Evidencia: AsgardSoft e Infinite Word Search; una reseña de WoW pide logros.*
5. **Palabras extra ocultas que dan pistas o puntos.** Añade reto y reduce la necesidad de paquetes de pistas. *S. Evidencia: Wordscapes Search, Explorer y Appgeneration.*
6. **Modo relax o infinito**: sopas generadas al azar por tema y dificultad, para combatir el "siempre las mismas". *M. Evidencia: repetitivo en el 5–17 % de las quejas de Play (Bluetile 17 %, Word Search Quest 15 %); 7 reseñas de iOS.*
7. **Accesibilidad**: tamaño de letra ajustable, alto contraste y un resaltado distinguible para daltónicos. *S. Evidencia: RV AppStudios, Vita y Senior Games lo venden como función.*
8. **Contrarreloj opcional y estadísticas** (mejor tiempo por dificultad, sopas por tema). *S. Evidencia: "me gustaría que tuviera un tiempo limite" (Explorer, MX); la queja por quitar el contrarreloj en Words of Wonders.*
9. **Racha a prueba de fallos**: que no se pierda al actualizar y un "comodín" semanal para no romperla. *S. Evidencia: rachas reiniciadas en Wordscapes Search y Explorer; Tap Color perdió una racha de 150 días.*
10. **Copia del progreso en la nube y compartir el resultado de la sopa del día** con un texto corto, sin cuenta. *M. Evidencia: Zen Color recibió reseñas de 1★ por perder compras y obras; el comentario de HN sobre el éxito de un juego "Free. No ads… share functionality… common daily word" ([HN](https://news.ycombinator.com/item?id=30155227)).*

## 8. 10 mejoras para Lienzo Zen (en orden)

1. **Entrada gratis más desbloqueo único (lo decide el dueño).** La lámina del día y 50–80 láminas gratis; las 749 y las 8 paletas con un pago único de 3,99–4,99 US$, sin anuncios. *M. Evidencia: sección 5; precio o suscripción en 110 reseñas de colorear.*
2. **Botón "buscar zona sin pintar"**: lleva la cámara a la siguiente zona vacía y la hace parpadear, gratis e ilimitado. Así se convierte en ventaja lo que otros venden con anuncios. *S–M. Evidencia: zonas diminutas en el 3–6 % de las quejas de Play; "siempre quedan lugares difíciles de localizar" (Colorscapes, 899 votos); "hide n seek especially for a senior" (Zen Color).*
3. **Autoguardado continuo y copia de seguridad de Mis obras.** *S–M. Evidencia: Mandala Coloring Pages (597 votos, "does not save progress"), ColorTime (obras en blanco), Colorfy ES ("se me borran") y Zen Color (obras perdidas).*
4. **Animación al terminar y repetición en time-lapse** exportable como vídeo corto. *M. Evidencia: Happy Color ("coloring animations are satisfying"), Pixel Art (time-lapse para compartir), Candy Mobile ("watch a replay").*
5. **Exportar en PNG a la galería, como fondo de pantalla y compartir.** *S. Evidencia: 7 reseñas de iOS; la queja de Quarzo por no poder guardar en la galería; Abovegames lo ofrece como fondo de pantalla.*
6. **Lámina del día y racha suave**, con contenido revisado. *S. Evidencia: Recolor, Quarzo, ColorTime, Zen Color y Pixel Art; las quejas por láminas del día inapropiadas.*
7. **Color libre**: selector de color, cuentagotas y paleta propia, sin bloqueos. El modo Pincel conviene destacarlo en la ficha ("pinta con tu dedo"). *M. Evidencia: libertad creativa en 28 reseñas; "en vez de tocar y que se coloree que nosotros lo coloreemos" (Pigment, ES).*
8. **Música ambiental y sonidos opcionales**, que se apaguen de verdad. *S. Evidencia: Zen Color y Abovegames los venden; en Play hay quejas por sonidos que no se pueden apagar.*
9. **Colecciones y logros por categoría**, más filtros para ocultar láminas terminadas o que no interesan. *S–M. Evidencia: Happy Color (logros con láminas extra), Zen Color (insignias); "I wish I could hide" (Lake) y "hide your colored pictures" (Colorscapes).*
10. **Modo "por números" opcional en una selección de láminas**, solo si los datos de uso lo justifican. *L. Evidencia: es el formato de las apps con más descargas (Happy Color, Pixel Art, Color by Number, Tap Color y Colorscapes), pero cuesta numerar 749 láminas y el público de color libre lo rechaza ("Tired of 'color by number' apps", ColorMe).*

Nota: si alguna lámina se generó con IA, conviene revisarla a mano. En Play, una reseña de Happy Color con 860 votos castiga el arte de IA defectuoso y pide poder ocultarlo.

---

## Fuentes generales
- AppBrain, apps gratis y de pago en Google Play: https://www.appbrain.com/stats/free-and-paid-android-applications
- Google Play Pass para desarrolladores: https://google.play/business/programs/googleplaypass/
- Política de reembolsos de Google Play: https://support.google.com/googleplay/answer/15574908
- Lake en el App Store: https://apps.apple.com/app/id1183717726. Pigment en AlternativeTo: https://alternativeto.net/software/pigment-coloring-book/about
- RSS de reseñas de Apple, con el formato `https://itunes.apple.com/{país}/rss/customerreviews/page={n}/id={id}/sortBy=mostRecent/json`. Cada URL concreta está en `replica/reviews.csv`.
- Hacker News: https://news.ycombinator.com/item?id=45367994, https://news.ycombinator.com/item?id=4111700 y https://news.ycombinator.com/item?id=30155227
- Fichas de Google Play: enlazadas en cada fila de las secciones 1–3.
