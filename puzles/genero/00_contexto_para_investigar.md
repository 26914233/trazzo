# Contexto común para la investigación del género (La caja viva, 04-10-2026)

## Qué es La caja viva (el juego que diseñamos)
- Juego de puzles táctil para móvil Android, **siempre en horizontal**, del género *puzzle box* (como The Room).
- Una *himitsu-bako* japonesa que es un *tsukumogami*: una caja secreta viva, con una cara tallada que respira, mira
  y **no deja tocar nada mientras te ve** (la regla central: «no deja tocar mientras te ve»). Sala japonesa de noche
  (shoji, lámpara *andon*, incensario con un león, tetera), tono tétrico y misterioso, sin sustos ni gore.
- **Técnica (decidida):** la ilustración pintada del boceto proyectada sobre una caja, una mesa y una sala 3D
  sencillas (Three.js r170 dentro de un WebView). Lo 3D «de verdad» (con texturas pintadas) es posible en objetos
  pequeños: la caja hija del nivel 2 es un cubo 3D con tablillas que corren. El arte nuevo se pinta con IA
  (Gemini) con el mismo encuadre o de frente. El móvil del usuario es modesto.
- **Gestos que ya existen (APK 0.2):** tocar (avisa), tirar/empujar cajones por su línea (con muelle), girar una
  llave en círculo, levantar una tapa hacia arriba, deslizar tablillas por su línea, girar la caja (arrastrar),
  pellizcar para acercar/alejar (lupa), arrastrar objetos del inventario a donde se usan, examinar un objeto
  (puzle de bolsillo: girar su tapa). Cámara: vistas fijas (sala, caja, costado de cajones, incensario, cara, caja
  pequeña en la mano); de cerca la cámara se queda quieta.
- **Nivel 1 · El cuerno (hecho):** cajones del costado (dos con cerradura); la llave en un cajón no se deja coger
  mientras el ojo mira → la lámpara distrae al ojo; la nota «Me falta un cuerno. Lo guarda el león que respira
  humo»; la llave abre el incensario (león); el cuerno de las brasas va al hueco de la frente; la caja despierta.
  En la espalda de la caja hay sembrados un hueco con forma de ficha de shōgi y un cajón largo con otra cerradura.
- **Nivel 2 · La caja de dentro (hecho):** de la trampilla sale una caja pequeña; cinco tablillas corren en orden
  (la flecha de marquetería que destapa cada una dice cuál sigue); la cara de la caja pequeña que ve el ojo grande
  no se mueve: hay que girarla en la mano para escondérsela. Dentro, un cajoncito con una cajita roja (puzle de
  bolsillo: su tapa gira a saltos hasta que su marca coincide con la del borde) con un ojo de piedra de luna que va a
  la cuenca vacía de la cara grande.
- **Propuestas sin aprobar:** nivel 3 «La caja del revés» (la caja se da la vuelta; la llave sirve otra vez en el
  cajón largo; ficha de shōgi; la caja se despliega como un biombo de cuatro hojas con un pequeño santuario de tres
  secciones; el ojo nuevo alumbra tinta invisible: ahora quieres que mire) y el final «El corazón» (tres anillos
  con cuerno, ojo y voz). La cara de la caja es el puzle grande: cada nivel le devuelve una pieza.

## Reglas de originalidad (obligatorias)
- **Principios sí, expresiones concretas no.** Se estudian mecánicas, estructuras, patrones, tutoriales, curvas de
  dificultad. No se copian assets, textos, personajes, escenarios, soluciones exactas ni secuencias idénticas.
- Prohibido hoy (control de originalidad del proyecto): **lente u ocular** que revela una capa oculta, **portales**,
  **sustancia irisada**, **miniaturas y «entrar en lo pequeño»** (The Room Three), rituales de varillas o máquinas
  de puertas. (El usuario pide estudiar la escala y los micro-mundos: estúdialos igual y propón versiones propias,
  marcando el riesgo de parecido.)

## Cómo escribir
- **Todo en español.** Frases cortas y claras; nada de jerga sin explicar.
- Marca cada afirmación: **[Hecho]** (lo dice una fuente: pon el enlace), **[Opinión]** (de críticos o jugadores:
  pon el enlace) o **[Interpretación]** (conclusión nuestra). No inventes datos ni citas; si no lo encuentras,
  dilo.
- Citas literales cortas (una frase como mucho); el resto, con tus palabras.
- Varias fuentes por juego cuando se pueda (reseñas, entrevistas, GDC, análisis de diseño, guías, comunidades).

## Columnas de la base de datos de mecánicas (CSV, separado por punto y coma, UTF-8)
`ID;Juego;Mecánica;Tipo;Dificultad;Habilidad requerida;Feedback;Cómo podría adaptarse`
- **ID:** prefijo de tu bloque + número (p. ej. A-001).
- **Tipo:** una o dos de estas categorías: ROTACIÓN, DESLIZAMIENTO, COMBINACIÓN, SECUENCIA, SIMETRÍA, PATRONES,
  ENGRANAJES, PALANCAS, RUEDAS, DIALES, LLAVES, CERRADURAS, SÍMBOLOS, LUCES, SONIDOS, PESO, FÍSICA, PERSPECTIVA,
  ESCALA, REFLEJOS, SOMBRAS, TIEMPO, MEMORIA, OBSERVACIÓN, ORDEN, CONEXIONES, TRANSFORMACIÓN, CONSTRUCCIÓN,
  DESMONTAJE, RECONSTRUCCIÓN, COMBINACIÓN DE OBJETOS, INFORMACIÓN CRUZADA, MULTIZONA, MULTIOBJETO (y otra si hace
  falta).
- **Dificultad:** 1 a 5.
- **Cómo podría adaptarse:** empieza por una letra y sigue con una frase concreta para La caja viva:
  A = el principio tal cual · B = modificado · C = combinado con otra · D = invertido · E = con una variable nueva ·
  F = en otro contexto · G = unido a la narrativa · H = convertido en una mecánica nueva.
- No pongas punto y coma dentro de los campos (usa comas).

## Ficha «DESMONTAR» por juego (en el .md)
Para cada juego: género y año · core loop · interacción (verbos) · mecánicas · los 2-4 mejores puzles (para cada
uno: qué información recibe el jugador, qué debe descubrir, qué variable manipula, qué reglas hay, qué lo hace
difícil, qué lo hace satisfactorio, qué feedback da, qué recompensa) · cámara · feedback, animación y sonido ·
narrativa · dificultad y aprendizaje (cómo enseña) · lo que los jugadores valoran y lo que critican (con fuente) ·
principios que podemos adaptar a La caja viva y cómo · riesgo de parecido. Sé concreto y útil para un diseñador:
mejor tres ideas transferibles buenas que diez vagas.
