# Roadmap de La caja viva (05-10-2026)

**Qué es:** el camino desde el prototipo de hoy (APK 0.3, dos niveles) hasta un juego que se pueda lanzar, con el orden
de trabajo, lo que entra en cada fase y las decisiones que tiene que tomar el usuario. Sale de la auditoría
(`07_auditoria_caja_viva.md`), la gramática (`05_gramatica_y_sistemas.md`), la investigación del género
(`01`-`04` y `06`) y el método del usuario (`../METODO_CAJA_VIVA.md`).

**Marcas:** [Hecho] comprobado · [Estimación] · [Supuesto] · [Opinión]. Las fechas son orientativas: dependen sobre
todo de lo que se tarde en dar con buenos puzles y de las pruebas con jugadores.

---

## 1. Dónde estamos [Hecho]

- **Fase:** prototipo jugable. Dos niveles (El cuerno y La caja de dentro), unos 10-15 minutos.
- **Lo que ya es bueno:** la regla del ojo («no deja tocar mientras te ve»), esconderle cosas al ojo, la resistencia
  creativa, el estilo pintado del boceto, la cara como puzle grande y, desde la 0.3, el tacto con peso y un
  vocabulario de sonido fijo. Desde la 0.4, tres señales sin texto: el ojo mira de reojo el frente abierto, la tablilla
  que toca se afloja cuando el ojo no la ve y la caja también oye (la tetera lo distrae).
- **Dónde está frente a The Room** [Interpretación, `the_room_interaccion_y_camara.md` b.4]: entre The Room y Two. Un
  objeto central en una sala que participa, con vistas fijas.
- **Lo que más falta:** contenido (horas, no minutos), variedad de familias de puzle, información cruzada larga,
  menos texto y una historia contada (el marco, DECISIÓN 25, sigue abierto).

## 2. Las fases

| Fase | Qué es | Qué tiene que estar | Cómo se sabe que está | Cuándo [Estimación] |
|---|---|---|---|---|
| **Prototipo** (hoy) | Validar la regla del ojo y el tacto | Niveles 1 y 2, gestos, sonido, APK | El usuario lo juega en su móvil [Hecho] | Hecho (0.1-0.3) |
| **Corte vertical** | Una porción con la calidad final | Nivel 3 completo, el marco de la historia, pistas en 4 escalones, música, ajustes de sonido y vibración, arte a 2K en lo que se ve de cerca | 3-5 personas lo terminan sin la última pista en casi todos los pasos y quieren seguir (§5) | 2-4 semanas |
| **Alfa** | Todo el juego jugable | Todos los niveles y el final con arte provisional donde falte | Se puede jugar de principio a fin; la prueba automática lo recorre | +1-2 meses |
| **Beta** | Juego completo y pulido | Arte final, sonido final, español e inglés, rendimiento medido en móviles modestos | La prueba cerrada de Google Play (12 personas, 14 días) sin bloqueos | +1 mes |
| **Lanzamiento** | Google Play | Ficha de la tienda, tráiler, capturas, precio | Publicado | — |
| **Después** | Más cajas | Las otras líneas (el relojero, la reliquia y el farero) como entregas nuevas (DECISIÓN 24) | Ventas y reseñas | — |

## 3. Qué entra (MVP, Must, Should y Nice)

**MVP, para validar con jugadores** (el corte vertical):
- los niveles 1, 2 y 3, y un final corto que use las tres piezas de la cara;
- la regla del ojo enseñada, ampliada y dada la vuelta (`05` §5, escalones 1-5);
- el tacto y el sonido de la 0.3 en todas las piezas nuevas;
- pistas (DECISIÓN 26) y guardado.

**Must Have, para lanzar:**
- **contenido:** 5-6 niveles y el final, con unas 2-3 horas de juego [Supuesto]. Como referencia, The Room Three dura
  de 5 a 7 horas y Old Sins unas 5 [Hecho, `the_room_interaccion_y_camara.md` b.1]; la duración del primer The Room no
  consta en nuestras fuentes. En las reseñas, «demasiado fácil» y «corto» pesan más que «demasiado difícil» [Hecho,
  `jugadores_y_principios.md` §1.8];
- **variedad:** al menos 8 de las 12 familias de la biblia, con luz, sonido, deducir y transformarse;
- **información cruzada:** cada nivel siembra una marca y cosecha otra de antes (`05` §7);
- **la caja se transforma** al menos una vez por nivel, con su animación de revelación;
- **ajustes:** sonido, vibración aparte (hoy el silencio no la apaga), tamaño de letra y menos movimiento;
- **arte a 2K** donde la cámara se acerca; **música** discreta;
- **español e inglés.**

**Should Have:**
- varias soluciones en algunos puzles (cada camino usa la regla de otra forma, `05` §7);
- la sala que se abre como una caja (DECISIÓN 30, si se elige la B);
- un contador de cuadros oculto para medir el rendimiento en móviles de verdad.

**Nice to Have:** logros, más idiomas, una versión de Steam y las otras líneas de cajas.

## 4. El orden de trabajo (lo siguiente)

Por impacto, como pide el método (prioridades del punto 34):

1. **[Hecho, 0.3]** Tacto con peso, vocabulario de sonido, causa → efecto en la cerradura del león y menos texto.
   **[Hecho, 0.4]** Señales sin texto: el vistazo del ojo, la holgura de la tablilla y la caja que oye.
2. **Nivel 3, «La caja del revés»** (`../ilustrada/NIVELES.md` §6): la mayor falta es contenido y variedad. Trae luz
   (el ojo nuevo alumbra), transformación (la caja se da la vuelta y se despliega) y cosecha las dos semillas de la
   espalda (el hueco de la ficha y el cajón largo). **Necesita arte** (6-10 imágenes con Gemini, unos 0,05 USD cada
   una [Estimación]): se pide permiso antes de generarlo.
3. **Pistas en 4 escalones y un aviso suave** (DECISIÓN 26, recomendada la B).
4. **El marco de la historia** (DECISIÓN 25, recomendada la C).
5. **Prueba con 3-5 jugadores** (§5) antes de seguir con más niveles.
6. **Música y ajustes** (sonido, vibración, letra).
7. **Arte a 2K** de lo que se ve de cerca.
8. **Niveles 4-6 y el final**, con la DECISIÓN 30 resuelta.

## 5. Cómo se valida cada paso

| Métrica | Qué es | Qué decisión ayuda a tomar |
|---|---|---|
| **Tasa de finalización por nivel** | Cuántos terminan cada nivel | Si cae en un nivel, ese nivel frena (dificultad o claridad) |
| **Tiempo por paso** | Cuánto se tarda en cada paso | Menos de 1 minuto: obvio; más de 10 atascado: falta una señal |
| **Pistas por paso** | Cuántas pistas se piden y en qué escalón | Si casi todos piden la última en el mismo paso, el paso está mal diseñado |
| **Abandonos** | Dónde se deja de jugar | Puntos muertos o frustración |
| **«¿Quieres jugar el siguiente nivel?» (1-5)** | La pregunta al final de cada nivel | La métrica principal mientras no haya tienda: lo más parecido a la retención |
| **Disposición a pagar** | No / hasta 2 € / hasta 5 € | Orienta el precio. Señal débil: la gente dice que pagaría más de lo que paga [Opinión] |

Después del lanzamiento: reseñas, finalización del juego entero y ventas por país. En un juego de pago único de
puzles, la finalización y las reseñas importan más que la retención D1/D7/D30 de un juego gratuito [Opinión].

## 6. Riesgos

| Riesgo | Qué puede pasar | Qué hacemos |
|---|---|---|
| **Contenido corto** | 10-15 minutos no se pueden vender | Niveles con la gramática y los sistemas (`05`): muchos puzles con pocas piezas |
| **Coste del arte por nivel** | Cada nivel pide 6-10 imágenes y retoques | Reutilizar la sala; repintados con el mismo encuadre; la caja pequeña en 3D con texturas pintadas |
| **Parecido con The Room** | Reseñas que lo llamen copia | El control de originalidad (anexo B de la biblia) y la DECISIÓN 30 |
| **Parecido con Old Sins en lo que ya existe** | Old Sins pone una talla en la frente de una cara (OS-J5) y ojos de piedra en una cuenca (OS-M3, OS-J3) [Hecho, `the_room_puzles.csv`]; nuestro cuerno y nuestro ojo de piedra de luna se parecen | Que la vuelta de cada pieza sea propia: la pieza vuelve a un cuerpo vivo, que la recibe y reacciona (respira, abre el ojo), no se encaja en una maqueta. No repetir la acción «encajar en la cara» en más niveles. Riesgo medio |
| **Precedente de la regla del ojo** | Boxes: Lost Fragments tiene un puzle de «luz roja, luz verde» [Hecho, `juegos_A_puzle_box_y_misterio.md`] | Nuestra regla es de todo el juego y crece (esconder, oír, alumbrar); allí es un puzle suelto. Riesgo medio-bajo |
| **Cierres y fallos en el móvil** | El 17 % de las reseñas de 1-2 estrellas de la App Store habla de cierres y fallos [Hecho, `jugadores_y_principios.md` tabla 3] | Prueba automática antes de cada APK y medir memoria en el móvil del usuario |
| **Monetización mal vista** | El 28,9 % de las de 1-2 estrellas habla de precio, pagos o anuncios [Hecho, ídem] | Nunca pistas de pago ni anuncios (ya es regla de la biblia) |
| **Rendimiento** | Móviles modestos a pocos cuadros por segundo | Medir en el móvil del usuario; la técnica A de respaldo |
| **Constancia del estilo** | Imágenes de IA que no casan | La receta de los bocetos y un solo encuadre por vista |
| **Visibilidad** | Sin escaparate de la tienda, nadie lo encuentra | Página de la tienda pronto, vídeos cortos del ojo (es el gancho) y una primera parte gratis [Hipótesis] |

## 7. Decisiones para el usuario

- **25, el marco de la historia** (abierta; recomendada la C: heredas el gabinete de tu abuela o abuelo).
- **26, las pistas** (abierta; recomendada la B: 4 escalones y un aviso suave a los 3 minutos sin avanzar).
- **30, la escala y los micro-mundos en versión propia** (nueva; abajo).

### DECISIÓN 30 — La escala y los micro-mundos, en versión propia

- **DECISIÓN:** el método pide estudiar la escala y los micro-mundos y «crear una versión propia» (punto 12). La biblia
  prohíbe hoy las miniaturas y «entrar en lo pequeño», que es la expresión más reconocible de The Room Three.
- **OPCIONES:**
  - **A) Solo cajas anidadas**, como hoy: la caja pequeña sale de la grande y lo que guarda vuelve a ella.
  - **B) «Lo grande era una caja»:** la escala al revés. En vez de entrar en algo pequeño, descubres que algo grande
    es una caja secreta: el tatami se levanta como una tablilla, el shoji corre en orden como los paneles de una
    *himitsu-bako*, la hornacina (*tokonoma*) es un cajón. La sala entera es la caja más grande.
  - **C) «La caja ve en pequeño»:** dentro de una caja hay la sala en miniatura, pero no se entra: lo que mueves en la
    pequeña se mueve en la grande, y al revés (información cruzada entre las dos escalas).
  - **D) Miniaturas como en la referencia.**
- **VENTAJAS:**
  - A: ya existe y es barata.
  - B: es la más propia y da el momento «la caja era parte de algo mayor» que pide la auditoría (punto 27); además, la
    sala ya está pintada y vive.
  - C: un puzle de escala nuevo, con mucha información cruzada.
  - D: un efecto probado.
- **RIESGOS:**
  - A: se queda corta para un juego entero.
  - B: hace falta arte de la sala transformada (varias imágenes) y cuidar que la cámara lo enseñe bien.
  - C: parecido medio con la referencia (una sala en pequeño).
  - D: parecido alto; va contra el control de originalidad.
- **COSTE [Estimación]:**
  - A: nada.
  - B: 8-12 imágenes y una o dos semanas de código.
  - C: un modelo pequeño de la sala y una semana.
  - D: no se valora.
- **RECOMENDACIÓN [Opinión]:** **B** para el final, con A en los niveles de en medio. C se puede probar en un nivel
  tardío si la B gusta. La investigación de The Room aconseja crecer «hacia dentro del cuerpo de la caja» y no hacia más
  habitaciones [Interpretación, `the_room_interaccion_y_camara.md` b.4]: la B no añade salas, transforma la que ya hay.
- **SIGUIENTE PASO:** si elige la B, diseñar con la plantilla de la biblia el nivel en que la sala se abre (el 5 o
  el final) y pedir permiso para su arte.
