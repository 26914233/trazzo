# Auditoría de La caja viva (APK 0.2, 04-10-2026)

**Qué se audita:** la página y el APK 0.2 (`puzles/ilustrada/`), con los niveles 1 y 2. Se leyó el código, se
jugaron los dos niveles con la prueba automática (34 de 34 y 28 de 28) y se revisaron sus capturas.

**Marcas:** ✅ bien · 🟡 a medias · ❌ falta · [Hecho] comprobado en el código o en las pruebas ·
[Estimación] · [Opinión].

---

## 1. Lo que hay hoy (inventario) [Hecho]

| Parte | Estado |
|---|---|
| **Técnica** | La pintura del boceto (1376 × 768) proyectada sobre una caja, una mesa y una sala 3D sencillas; Three.js r170 en un WebView. Respaldo 2D (técnica A) para móviles sin WebGL, solo con el nivel 1 |
| **Código** | `juego.js` (unas 3300 líneas: estado, niveles, ojo, efectos, gestos, sonido, interfaz y técnica A), `tecnica_3d.js` (unas 1200: cámara, proyección, caja hija, toques 3D), `escena3d.js` y `caja_hija.js`. Unas 5400 líneas en total |
| **Vistas** | Sala, caja, costado de los cajones, incensario, cara, subida y caja pequeña en la mano. De cerca, la cámara se queda quieta; el pellizco es una lupa con margen por vista |
| **Gestos** | Tocar (avisa) · tirar y empujar cajones · girar la llave en círculo · levantar la tapa · tirar de la trampilla · deslizar tablillas · girar la caja grande y la pequeña · pellizcar · arrastrar objetos del inventario · examinar (girar la tapa de la cajita) |
| **Nivel 1 · El cuerno** | Unos 9 pasos: cajones (2 con cerradura) → llave vigilada → la lámpara distrae al ojo → la nota → la llave en el león, girarla → levantar la tapa → el cuerno de las brasas → la frente → la caja despierta |
| **Nivel 2 · La caja de dentro** | Unos 12 pasos: trampilla → girar la caja pequeña → 5 tablillas en orden, escondiendo cada una del ojo → cajoncito → cajita (tapa a saltos hasta la marca) → el ojo de piedra de luna en la cuenca |
| **Meta** | La cara de la caja es el puzle grande: cada nivel le devuelve una pieza (cuerno, ojo y, en propuesta, voz). Tarjeta con sellos al acabar cada nivel; partida guardada al terminar nivel |
| **Sonido** | 28 sonidos generados por código; 25 se usan. Ambiente de noche y fuego en bucle. Sin música |
| **Vibración** | 28 llamadas a vibrar, en golpes, bloqueos y logros |
| **Texto** | 84 mensajes distintos: avisos de gesto, resistencias, descubrimientos y pistas |
| **Pistas** | Botón «?»: en el nivel 2, una escalera de 2 o 3 pistas por paso; en el nivel 1, mensajes según el estado. (La DECISIÓN 26 sigue abierta) |
| **Pruebas** | Automáticas con gestos de verdad: nivel 1, 34 de 34 en la B y en la A; nivel 2, 28 de 28; sin red, 36 de 36 y 30 de 30 |
| **Duración** | Nivel 1, unos 3-4 minutos; nivel 2, unos 5-8 **[Estimación]**. Total de hoy: unos 10-15 minutos |

---

## 2. La lista de comprobación del punto 35

| Pregunta | Estado | Por qué | Qué haría falta |
|---|---|---|---|
| ¿La interacción es satisfactoria? | 🟡 | Desde la 0.2 todo es un gesto y los cajones tienen muelle, rebote y golpe. Pero la llave, la tapa y las tablillas siguen al dedo sin peso ni resistencia, y la caja pequeña no tiene inercia al soltarla | Peso, resistencia inicial que cede, inercia y topes con sonido en cada pieza (como los cajones) |
| ¿Los puzles son variados? | 🟡 | Usamos 6 de las 12 familias de la biblia: Atención, Manipular, Observar, Montar, Memoria espacial y Bolsillo. No hay ninguno de deducir, de luz, de sonido, de perspectiva visual ni de tiempo | El nivel 3 y el final deben traer Deducir, Punto de vista, Transformación y Guiar |
| ¿Las soluciones son lógicas? | ✅ | La nota dice dónde está el cuerno; la flecha de cada tablilla dice cuál sigue; la marca de la cajita dice dónde parar | — |
| ¿Hay momentos de descubrimiento? | ✅ | La caja despierta; la caja pequeña sale de la trampilla; el ojo nuevo mira a otra parte | Falta un momento «la caja era parte de algo mayor» (punto 27) |
| ¿Hay puzles conectados? | 🟡 | La nota lleva al incensario (información cruzada); en la espalda hay sembrados un hueco de ficha de shōgi y un cajón largo con otra cerradura, que aún no se usan | Cosechar lo sembrado en el nivel 3; más información que se encuentra en un sitio y se usa en otro, mucho después |
| ¿Hay mecánicas combinadas? | ✅ | Nivel 2: orden de tablillas + esconderlas del ojo + girar la caja en la mano | — |
| ¿La cámara ayuda? | ✅ | Vistas fijas de cerca, pellizco, transiciones suaves; en horizontal, los textos van a un lado | La cámara aún no forma parte de ningún puzle (punto 13) |
| ¿Las animaciones explican los mecanismos? | 🟡 | Se ve qué se mueve (cajón, tablilla, tapa). Lo que no se ve es POR QUÉ se abre algo: la cerradura del león hace clic y la tapa queda suelta sin que se vea el pestillo; la trampilla se abre sola | Cadenas de causa → efecto visibles: un pestillo que se retira, un engranaje que gira, una vista interior en los desbloqueos grandes (punto 14) |
| ¿Los sonidos refuerzan las acciones? | 🟡 | Hay sonido en cada acción, pero el mismo sonido sirve para cosas distintas: `clic_madera` es a la vez aviso, tope y logro | Un vocabulario fijo: roce = movimiento, clac = posición correcta, mecanismo = algo se mueve dentro, grave = gran desbloqueo, silencio = tensión (punto 16) |
| ¿La progresión funciona? | ✅ | Cada nivel devuelve una pieza a la cara; tarjeta, sellos y guardado | Que el nivel final use todo lo aprendido (punto 19) |
| ¿La dificultad aumenta? | ✅ | Nivel 1: una regla (el ojo). Nivel 2: la regla ampliada (esconder) y combinada con el orden | Medirlo con jugadores (`PLAN.md` §3) |
| ¿El jugador sabe qué puede hacer? | 🟡 | Depende mucho del texto (84 mensajes). Las piezas que se pueden tocar no se distinguen siempre de las que no | Señales sin texto: brillo leve, holgura (la pieza asoma), sonido y vibración propios (punto 17) |
| ¿Sabe cuándo consiguió algo? | ✅ | Sonido, vibración, mensaje y, al final de nivel, tarjeta | Un sonido grave y una animación de revelación más larga en los logros grandes (punto 27) |
| ¿Hay puntos muertos? | ✅ | No se conoce ninguno: todo se puede repetir y nada se pierde | Cuidarlo en los niveles nuevos (la prueba automática los recorre) |
| ¿Hay bugs? | 🟡 | Conocidos y menores: (1) en la vista de la caja, el incensario queda junto al botón «Girar» y el móvil puede llevar el toque al botón; (2) bajo el incensario se ve el borde recto de su sombra pintada al acercarse | (1) mover «Girar» o el encuadre; (2) recortar la sombra con la silueta |
| ¿El rendimiento móvil es aceptable? | 🟡 | El APK pesa 5,3 MB; en el contenedor, sin tarjeta gráfica, va a 3-11 cuadros por segundo, que no dice nada del móvil. No se ha medido en un Android de verdad | Medir en el móvil del usuario (un contador de cuadros oculto) |

---

## 3. Lo que hay que conservar (fortalezas) [Opinión]

1. **El ojo que no deja tocar mientras te ve.** Es una regla de atención que no tiene The Room: el objeto vigila.
   Es nuestra firma y genera puzles (distraer, esconder, más adelante dirigir).
2. **Esconderle cosas al ojo (nivel 2).** Es una mecánica de perspectiva propia: lo que importa no es lo que ves
   tú, sino lo que ve la caja.
3. **La resistencia creativa.** Lo bloqueado no se marca en rojo: la caja contiene el aliento, el ojo mira tu mano.
4. **El estilo pintado del boceto.** Tétrico y propio, y barato de ampliar con repintados.
5. **La cara como puzle grande.** Es un meta-puzle claro y emocional: le devuelves el cuerpo a la caja.
6. **La base técnica de la 0.2:** gestos con su línea, lupa, cámara fija de cerca y pruebas automáticas con gestos
   de verdad.

## 4. Las debilidades, por orden de impacto (prioridades del punto 34)

1. **Contenido corto.** Hoy son 10-15 minutos. The Room dura unas 2-3 horas **[Estimación; se contrasta en la
   investigación]**. Lo que más falta es contenido de calidad, no más sistemas.
2. **Pocas familias de puzle.** Faltan deducir, luz, sonido, perspectiva visual y tiempo. El nivel 3 debe traer al
   menos dos familias nuevas.
3. **Información cruzada escasa.** Solo una conexión larga (la nota → el incensario). El usuario quiere que sea la
   firma («ahora entiendo para qué servía eso»).
4. **Dependencia del texto.** 84 mensajes. Los avisos de gesto y de lugar deberían pasar a señales visuales,
   sonoras y hápticas, y el texto quedarse para la historia y las pistas pedidas.
5. **Animación que no explica.** Los desbloqueos grandes no enseñan su mecanismo.
6. **Tacto desigual.** Los cajones ya tienen peso; la llave, la tapa, las tablillas y el giro de la caja, no.
7. **Audio sin vocabulario fijo** y sin música.
8. **Historia apenas contada.** Una nota. El marco (DECISIÓN 25) sigue abierto.
9. **Técnica:** `juego.js` mezcla todo en un archivo de unas 3300 líneas. No conviene rehacerlo; conviene que los
   niveles nuevos vayan en su propio módulo.
10. **Resolución:** la pintura de 1376 × 768 se ve blanda al acercar; está pendiente subirla a 2K.

## 5. Lo primero que se arreglaría

| # | Mejora | Por qué primero | Coste [Estimación] |
|---|---|---|---|
| 1 | **Tacto con peso en todas las piezas** (resistencia inicial, inercia, topes con su sonido) | Es lo que define el género («la satisfacción de manipular objetos de The Room») y ya hay base | Bajo: código, sin arte |
| 2 | **Vocabulario de sonido y vibración** | Hace legible todo lo demás y reduce texto | Bajo: código y algún sonido nuevo |
| 3 | **Señales sin texto** (holgura, brillo leve tras un rato sin avanzar) | Menos texto, más descubrimiento | Bajo |
| 4 | **Causa → efecto visible** en los desbloqueos grandes (pestillo del león, trampilla) | Punto 14: el jugador entiende cómo funciona la caja | Medio: animación y algo de arte |
| 5 | **Nivel 3 con información cruzada, perspectiva y transformación** | Contenido y variedad, cosechando lo sembrado | Alto: diseño, arte (6-10 imágenes) y código |
