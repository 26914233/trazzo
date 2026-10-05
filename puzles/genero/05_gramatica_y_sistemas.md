# La gramática de puzles y los sistemas de La caja viva (04-10-2026)

**Para qué sirve:** que el juego tenga profundidad sin inventar una mecánica nueva en cada puzle (punto 20 del
encargo). Unas pocas **piezas**, **verbos**, **estados** y **leyes** de la caja se combinan con unas **reglas de
producción** y salen cientos de puzles distintos que se sienten del mismo mundo.

Todo lo de aquí es **[Propuesta]**, salvo lo marcado como **[Hecho]** (ya está en el juego). Respeta el control de
originalidad de la biblia (anexo B): principios sí, expresiones concretas de otros juegos no.

---

## 1. El vocabulario

### 1.1 Sustantivos: qué hay en el mundo

| Grupo | Elementos |
|---|---|
| **La caja** | La caja grande (viva) · cajas anidadas (la caja hija [Hecho], otras) · su cara (ojo viejo, ojo nuevo, boca, frente) |
| **Piezas** | Cajones [Hecho] · tablillas [Hecho] · tapas [Hecho] · pestillos · ruedas · anillos · celosías · hojas de biombo · bisagras · fichas |
| **Cierres** | Cerraduras de llave [Hecho] · cierres por orden [Hecho] · cierres por mirada [Hecho] · cierres por marca (alinear) [Hecho en la cajita] · cierres por ritmo · cierres por luz |
| **Llaves y objetos** | La llave de bambú [Hecho] · el cuerno [Hecho] · el ojo de piedra de luna [Hecho] · la cajita roja [Hecho] · la ficha de shōgi [sembrada] · la campanilla · el espejo de mano · varillas de incienso |
| **Información** | Notas [Hecho] · flechas de marquetería [Hecho] · marcas doradas [Hecho] · emblemas *kamon* · los doce animales · kanji tallados · sellos de tinta · siluetas · sombras · sonidos |
| **La sala** | Lámpara *andon* [Hecho] · shoji y viento [Hecho] · incensario y su humo [Hecho] · tetera y tazas [Hecho] · rollo colgado [Hecho] · luna tras el shoji |
| **Fuerzas** | Luz (lámpara, brasas, luna, la mirada del ojo nuevo) · sombra · humo (muestra corrientes de aire) · peso · respiración de la caja · sonido |

### 1.2 Verbos: qué hace el jugador (gestos)

| Verbo | Gesto | Estado |
|---|---|---|
| **Tocar** | Un toque: avisa, la pieza asoma | [Hecho] |
| **Tirar / empujar** | Arrastrar por la línea de la pieza | [Hecho] |
| **Girar** | Dedo en círculo (llave, rueda, anillo, tapa) | [Hecho] |
| **Deslizar** | Arrastrar por un carril | [Hecho] |
| **Levantar** | Arrastrar hacia arriba | [Hecho] |
| **Volcar / girar en la mano** | Arrastrar fuera de las piezas | [Hecho] |
| **Acercar / alejar** | Pellizcar | [Hecho] |
| **Introducir / retirar** | Arrastrar un objeto del inventario a su sitio, o sacarlo | [Hecho] el introducir |
| **Examinar** | Tocar dos veces un objeto de la bandeja: se gira en la mano | [Hecho] |
| **Mantener** | Dejar el dedo quieto sobre algo (sostener una pieza mientras otra corre, tapar una luz) | [Propuesta] |
| **Dos dedos** | Sostener con uno y mover con otro (abrir dos cierres a la vez) | [Propuesta] |
| **Soplar** | Deslizar rápido sobre el humo o una llama | [Propuesta] (sin micrófono) |

### 1.3 Estados: cómo puede estar cada cosa

- **Posición:** cerrado · suelto · abierto · en su sitio (encajado).
- **Bloqueo:** libre · bloqueado por un mecanismo · por el orden · por la mirada · por la luz · por el ritmo.
- **Mirada:** visto o no visto por cada ojo.
- **Luz:** a oscuras · iluminado · en sombra · a contraluz.
- **La caja:** dormida · despierta · respirando · conteniendo el aliento · transformada (dada la vuelta, desplegada).
- **Conocimiento del jugador:** lo que ya sabe (lo que ha visto y entendido), aunque la caja no haya cambiado.

### 1.4 Las leyes de la caja (las reglas fijas del mundo)

1. **Lo que el ojo ve no se mueve.** [Hecho] La ley central. Se enseña en el nivel 1 y se va doblando.
2. **Las piezas corren en orden, y cada una enseña la siguiente.** [Hecho, nivel 2]
3. **La luz revela lo que la caja esconde.** [Propuesta] Marcas en tinta que solo se ven con cierta luz: la luna,
   las brasas o la mirada del ojo nuevo. Nunca una lente que se pone el jugador.
4. **La caja respira.** [Propuesta] Algunas piezas solo ceden cuando la caja exhala. Es ritmo lento, nunca reflejos:
   el ciclo dura varios segundos y se ve y se oye.
5. **Lo que se hace aquí cambia algo allí.** [Propuesta] Una pieza de la caja mueve otra de la sala, o al revés
   (información cruzada y mecanismos multizona).
6. **Cada parte vuelve a su cuerpo.** [Hecho] Lo que se recupera (cuerno, ojo, voz) vuelve a la cara: es el
   meta-puzle.
7. **Todo objeto sirve dos veces.** [Propuesta] Ningún objeto tiene una sola función obvia (punto 11).

---

## 2. Las reglas de producción (cómo se encadena un puzle)

Cada flecha es una regla que se puede usar en cualquier puzle. Un puzle es un camino por estas reglas.

```
GESTO        → mueve una PIEZA
PIEZA        → cambia de POSICIÓN
POSICIÓN     → libera un MECANISMO            (pestillo, engranaje, peso)
MECANISMO    → revela un OBJETO o una MARCA
OBJETO       → se usa como LLAVE              (introducir)
OBJETO       → se examina y se TRANSFORMA     (puzle de bolsillo)
OBJETO       → sirve de HERRAMIENTA           (refleja, alumbra, pesa, suena)
MARCA        → da INFORMACIÓN
INFORMACIÓN  → resuelve otro MECANISMO        (a menudo en otra zona o en otro nivel)
LUZ          → cae sobre una PIEZA → proyecta una SOMBRA o revela una MARCA
MIRADA       → bloquea una PIEZA → el jugador DESVÍA la mirada (distraer, esconder, señuelo) → la PIEZA queda libre
MIRADA (ojo nuevo) → ALUMBRA → revela una MARCA          (la ley 3 a través de la ley 1, invertida)
RESPIRACIÓN  → abre una ventana de TIEMPO → una PIEZA cede
SONIDO       → marca un RITMO o una DISTANCIA → la caja RESPONDE
```

**Ejemplo con lo que ya hay (nivel 1) [Hecho]:** TIRAR un cajón → revela la LLAVE → la MIRADA la bloquea → TOCAR la
lámpara desvía la mirada → coger la llave → INFORMACIÓN de la nota («el león que respira humo») → INTRODUCIR la
llave en el león → GIRAR → el MECANISMO suelta la tapa → LEVANTAR → revela el CUERNO → vuelve a su CUERPO.

---

## 3. Los sistemas que generan puzles

Cada sistema es un módulo con parámetros. Variando los parámetros salen puzles nuevos sin código nuevo.

| # | Sistema | Parámetros | Puzles que genera | Estado |
|---|---|---|---|---|
| S1 | **La mirada** | Qué vigila; qué la distrae; cuánto dura; modo (vigila · sigue lo último que se movió · alumbra · dos ojos que ven distinto) | Distraer, esconder, señuelo, linterna, coordinar dos ojos | [Hecho] vigila y esconder |
| S2 | **Piezas en orden** | Secuencia; quién enseña la siguiente (flecha, símbolo, sonido); qué la bloquea | Cajas de Hakone, cerraduras de varios pasos | [Hecho] |
| S3 | **Llaves que sirven dos veces** | Dónde se usa primero y dónde después; cómo cambia | La llave abre dos cosas; una pieza que es llave y luego herramienta | [Propuesta] |
| S4 | **Luz y sombra** | Fuente (lámpara, luna, brasas, ojo); qué la tapa; dónde cae | Sombras que forman símbolos, marcas que solo se ven con una luz | [Propuesta] |
| S5 | **Marcas sin números** | Familia de signos (*kamon*, doce animales, cinco elementos, kanji); dónde está la clave y dónde se usa | Códigos sin cifras, información cruzada entre zonas y niveles | [Hecho] flechas y marcas; [Propuesta] el resto |
| S6 | **La respiración** | Duración del ciclo; qué cede al exhalar; qué la altera (miedo, calma) | Puzles de ritmo lento, sostener y soltar a tiempo | [Propuesta] |
| S7 | **Cajas anidadas (escala)** | Qué caja sale de cuál; qué vuelve a la grande | Una caja dentro de otra; lo de dentro es parte del cuerpo de fuera | [Hecho] la caja hija |
| S8 | **La caja se transforma** | Estados de forma (cerrada, dada la vuelta, desplegada en biombo, abierta por dentro) | Revelaciones, espacios nuevos, otra perspectiva | [Propuesta] |
| S9 | **La sala viva** | Qué objeto de la sala reacciona y cómo (viento, humo, lámpara, té) | Información del entorno: el humo se inclina hacia una rendija escondida; las ondas del té delatan un golpe | [Hecho] decoración; [Propuesta] como información |
| S10 | **Sonido y voz** | Fuente (campanilla, la caja, una pieza); qué significa | Ritmos, «frío o caliente» al acercar una pieza, voces que responden | [Propuesta] |
| S11 | **Peso y equilibrio** | Dónde se pone qué; qué inclina | Contrapesos dentro de la caja, una balanza de ofrendas | [Propuesta] |
| S12 | **Perspectiva (lo que ve quién)** | Desde dónde mira la cámara y desde dónde mira el ojo | Alinear formas para ver un símbolo, esconder cosas al ojo | [Hecho] esconder; [Propuesta] alinear |

---

## 4. Cómo nace una mecánica nueva (la regla de combinación, punto 28)

```
MECÁNICA EXISTENTE + CONTEXTO NUEVO + REGLA NUEVA + PRESENTACIÓN NUEVA = MECÁNICA PROPIA
```

| Mecánica existente | Contexto nuevo | Regla nueva | Presentación nueva | Resultado |
|---|---|---|---|---|
| Distraer a un guardia (sigilo) | Una caja que vigila tus manos | Lo que el ojo ve no se mueve | Un ojo tallado que respira | La ley 1 [Hecho] |
| Alinear formas para ver un símbolo (perspectiva) | Lo que ve la caja, no lo que ves tú | El símbolo se forma desde el ojo | Sombras del shoji sobre la cara | «Lo que ve el ojo»: mueve la sala hasta que el ojo vea el símbolo |
| Revelar con luz (tinta invisible) | La mirada del ojo nuevo | Quieres que mire, al revés que antes | El ojo de piedra de luna alumbra en frío | La ley 3 invertida |
| Ritmo (puzles musicales) | Una caja que respira | Cede al exhalar | Pecho de madera que sube y baja, humo que entra y sale | La ley 4 |
| Llave y cerradura | La llave cambia al usarla | Sirve dos veces | La llave de bambú se astilla y deja ver un kanji | Objetos multifunción (S3) |

---

## 5. Cómo se enseña cada sistema (punto 18)

Cada sistema sube por estos siete escalones, repartidos entre niveles. Ejemplo con **la mirada (S1)**:

| Escalón | Qué es | La mirada |
|---|---|---|
| 1. Mostrar | Se ve la regla antes de usarla | El ojo sigue tu dedo nada más empezar [Hecho] |
| 2. Experimentar | Probar sin castigo | La llave resiste mientras te mira; la caja contiene el aliento [Hecho] |
| 3. Enseñar la regla | Que se entienda | La lámpara tiembla sola y el ojo la mira: «la llama la distrae» [Hecho] |
| 4. Combinar | Con otra regla | Esconder la tablilla del ojo + el orden de las tablillas [Hecho, nivel 2] |
| 5. Variar | La misma regla, al revés o con otra variable | Nivel 3: ahora quieres que mire (el ojo nuevo alumbra) |
| 6. Dominar | Usarla sin ayuda en algo largo | Nivel 4: dos ojos, cada uno ve una cosa; hay que coordinarlos |
| 7. Sorprender | Que la regla haga algo inesperado | Final: el ojo, que siempre te bloqueó, te ayuda a abrir el corazón |

## 6. La curva de dificultad del juego (punto 19)

| Nivel | Papel | Sistema estrella | Sistemas que vuelven |
|---|---|---|---|
| 1 · El cuerno [Hecho] | Aprendizaje | S1 la mirada (distraer) | S2 cajones |
| 2 · La caja de dentro [Hecho] | Aplicación | S7 anidar + S1 esconder | S2 orden |
| 3 · La voz [Hecho, 0.5] | Combinación | S4 luz + S1 alumbrar (invertida: va al revés del dedo) + S6 respiración (el ritmo) | S2 el cajón largo, S5 la ficha y las tintas, S9 la sala (rollo, tetera, tatami) |
| 4 | Variación | S8 transformarse (la caja que se despliega, propuesta antigua del 3) | S1, S4 |
| 5 | Dominio | S9 la sala viva + S5 marcas cruzadas | Todos |
| 6 | Combinación avanzada | S10 sonido + S11 peso | Todos |
| Final · El corazón [Hecho, 0.5] | Síntesis | Los tres anillos: cuerno (el ojo viejo señala), ojo (el nuevo alumbra) y voz (la campanilla avisa); la caja hija es la llave | Todos |

## 7. Políticas de diseño

**Información cruzada (punto 9), la firma del juego:**
- Cada nivel siembra al menos **una marca que no se usa en ese nivel** y cosecha al menos una de un nivel anterior.
- La cosecha debe tardar: lo mejor es que el jugador haya olvidado la marca hasta que la ve tener sentido.
- La información viaja sin números: signos, siluetas, sonidos, posiciones.
- Ya hay dos semillas [Hecho]: el hueco con forma de ficha de shōgi y el cajón largo con otra cerradura.

**Varias soluciones (punto 8):** solo cuando cada camino use la regla de otra forma, no cuando sea un atajo.
Ejemplo propio: para distraer al ojo vale la lámpara, una ráfaga del shoji o un señuelo que se mueve; la caja
reacciona distinto a cada uno, pero el resultado es el mismo. Se comprueba cada camino en la prueba automática.

**La caja que se transforma (punto 10):** cada nivel cambia la forma de la caja al menos una vez, y la animación
de ese cambio dura lo suficiente para verlo como un vídeo (3-6 segundos, con la cámara apartándose para que se
vea entero).

**Objetos multifunción (punto 11):** ningún objeto se usa una sola vez. Si un objeto solo sirve para una cosa, se
le busca una segunda función o se quita.

**Escala propia (punto 12):** en vez de entrar en miniaturas (prohibido por el control de originalidad), la escala
es **anidar cajas** (la pequeña sale de la grande y vuelve a ella) y, al revés, **descubrir que algo grande era
una caja** (por ejemplo, que la sala misma se abre como una caja secreta). Ver la DECISIÓN 30.

**Perspectiva (punto 13):** la nuestra es **lo que ve quién**: el ojo de la caja mira desde su sitio, y lo que
importa es lo que él ve. Los puzles de alinear formas se resuelven desde el punto de vista del ojo, no desde el
del jugador.

**Animación que explica (punto 14):** cada desbloqueo grande enseña su mecanismo: el gesto → la pieza → el pestillo
o el engranaje → lo que se abre. Si no se ve la causa, no se puede aprender la regla.

**Sonido funcional (punto 16):** un vocabulario fijo, que se respeta en todo el juego. **[Hecho en la 0.3]**: está en
`VOCABULARIO` y `sentir()` de `ilustrada/pagina/juego.js`, con cuatro sonidos nuevos
(`ilustrada/herramientas/sonidos_vocabulario.py`).

| Evento | Sonido | Significa |
|---|---|---|
| toque | Toque suave | Has tocado algo que responde |
| holgura | Dos o tres clics flojos | La pieza asoma: se puede mover |
| roce | Roce de madera | Algo se está moviendo |
| tope | Golpe seco | La pieza llegó al final (cerrada o abierta del todo) |
| **clac** | Doble golpe de madera dura con un tic de metal | Posición correcta: encajó |
| pestillo | Latón que corre y se detiene | Algo corre dentro (un cierre que se retira) |
| muesca | Clic metálico | Un paso del mecanismo (la llave al girar; más adelante, ruedas y anillos) |
| mecanismo | Engranajes | Algo se mueve dentro de la caja |
| desbloqueo | Grave y largo | Gran desbloqueo |
| trabado | «Trabado» | No se puede, ahora |
| (silencio) | El ambiente baja unos 11 dB | Tensión: la caja contiene el aliento |

La vibración sigue el mismo vocabulario (corta para la holgura, doble para el clac, larga para el gran desbloqueo).
