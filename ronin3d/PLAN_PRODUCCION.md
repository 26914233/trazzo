# RONIN — Plan de producción

**Fecha:** 27 de septiembre de 2026 (actualizado el 1 de octubre de 2026) · **Fase actual:**
prototipo 0.4 (capítulo 1 jugable en Godot 4.7, cel-shading, iaidō, animación estilo anime y galería de criaturas) ·
**Alcance:** núcleo + variaciones y lanzamiento por capítulos (decidido: opción C) · **Combate:**
precisión con iaidō (decidido: opción B) · **Siguiente hito:** vertical slice, base del primer
capítulo.

Cada afirmación va marcada cuando no es obvia: **[Hecho]** comprobado, **[Estimación]** cálculo
con incertidumbre, **[Supuesto]** algo que damos por bueno sin comprobar, **[Hipótesis]** algo que
hay que validar, **[Opinión]** criterio del equipo.

---

## 1. El juego en una frase

Tres formas de contarlo, para elegir o combinar:

| | Frase | Qué vende |
| --- | --- | --- |
| A | *Un ronin persigue al general que mató a su señor… y descubre que medio pueblo le da la razón al general.* | La historia: un villano con razones |
| B | *Duelos samurái de precisión en un Japón de tinta: lee al rival, espera el momento, un solo corte.* | El combate |
| C | *Una noche, seis lugares, seis maneras de jugar: espada, palabra, ingenio y ritmo.* | La variedad |

**Recomendación [Opinión]:** A como gancho de historia y B como gancho de juego. C describe
bien el diseño actual, pero también es su mayor riesgo (ver §3).

## 2. Diagnóstico honesto

- **¿Es divertido?** Aún no lo sabemos. El combate funciona (tajo en cono, estocada con aviso
  «!»), pero hoy se gana acercándose y pulsando J dos veces: no hay nada que dominar
  **[Opinión, por las pruebas]**. Es lo primero que hay que resolver.
- **¿Es diferente?** El tema samurái está muy ocupado: *Ghost of Yōtei* (PS5, octubre de 2025;
  más de 3,3 millones de copias vendidas hasta noviembre de 2025), *Rise of the Ronin* (PS5 2024, PC marzo de 2025),
  *Trek to Yomi* (2022) **[Hecho]**. Lo que nos puede diferenciar: el villano que no se cree
  villano, la estructura circular y una estética de grabado en tinta con cel-shading
  **[Opinión]**. Desde el 1-10-2026 se suma lo que más nos separa de esos juegos: un Japón
  invadido por yōkai y el combate de iaidō (ver `PROPUESTA_MUNDO_YOKAI.md`) **[Opinión]**.
- **El nombre:** «RONIN» ya lo usan un juego de 2015 publicado por Devolver Digital y *Rise of
  the Ronin* **[Hecho]**. Es difícil de encontrar en tiendas y buscadores. No urge, pero hay que
  tener nombre propio (o subtítulo fuerte) antes de abrir una página de tienda **[Opinión]**.
- **¿Es viable?** Con el diseño actual, no a corto plazo: seis lugares con seis géneros
  distintos son, en la práctica, seis juegos pequeños **[Estimación]**. Ver §3.
- **¿Quién lo jugaría?** Jugadores de acción-aventura indie que buscan una historia corta
  (4-6 h) con una estética marcada, en PC y Android **[Hipótesis]**.
- **¿Por qué volverían?** Hoy, solo por la historia. Propuestas: técnicas nuevas que cambian
  cómo peleas (dojo) y decisiones de honor/justicia que se notan al volver a Hoshiyama
  **[Opinión; lo segundo toca la historia, se decide contigo]**.
- **¿Cómo ganaría dinero?** Juego de pago con demo gratis del capítulo 1 **[Hipótesis]**. El
  free-to-play encaja mal con una aventura narrativa corta **[Opinión]**.

## 3. Alcance: el riesgo principal

Cada género del mapa (acción, rol, puzzles, ritmo, exploración, dados) necesita sus propios
sistemas, contenido y pruebas. Para una persona con ayuda de Claude y un PC modesto, eso es
demasiado para una primera versión **[Estimación]**.

**Propuesta:** un único núcleo (duelo + exploración con los mismos controles) y que cada lugar
sea una **variación** de ese núcleo, no un género nuevo:

| Lugar | Hoy (diseño) | Propuesta como variación |
| --- | --- | --- |
| Castillo | Acción con espada | El núcleo: duelos contra soldados |
| Planicie | Viaje + dados | Viaje; los dados deciden el encuentro (duelo, mercader, evento) |
| Aldea | Rol | Centro: diálogos, descanso, tienda pequeña, 1-2 encargos |
| Dojo | Ritmo y reflejos | Aprender técnicas con retos de ritmo **usando la espada** |
| Templo | Puzzles | Puzzles de entorno con moverse, saltar y cortar |
| Ruinas | Exploración y combate | El núcleo con más exploración y un jefe |

**Decidido el 27-09-2026 (DECISIÓN 1, opción C):** este núcleo con variaciones y lanzamiento por
capítulos. El primer capítulo es castillo + planicie + aldea: el vertical slice de §5, pulido. Lo
que hace cada lugar (la tercera columna) sigue siendo una propuesta y se cierra al construirlo.

## 4. Pilares y bucles

**Pilares [propuesta]:** cada mecánica tiene que servir a uno.

1. **Duelo de precisión:** leer al rival y cortar en el momento justo.
2. **Honor y justicia:** lo que haces pesa por dentro (honor) y por fuera (justicia).
3. **Grabado en tinta que se mueve:** cel-shading, contorno, noche, faroles y luna.

**Bucles:**

- **Principal (segundos):** ver al rival → leer su aviso → parar o esquivar → cortar →
  recompensa (avanzar, abrir camino).
- **Secundario (sesión):** viajar por la planicie → encuentro con dados → llegar a un lugar →
  su reto → técnica u objeto nuevo → siguiente lugar.
- **Exploración con Shiro (desde la 0.6):** explorar → Shiro olfatea y desentierra monedas (y trae
  las que dejas atrás) → gastarlas (para qué, DECISIÓN 16). Solo mientras se juega (DECISIÓN 7 C).
- **Largo plazo:** honor y justicia se acumulan y cambian cómo es la vuelta a Hoshiyama.

## 5. Vertical slice (siguiente hito)

**«Una noche en Hoshiyama»:** 15-20 minutos que prueban el núcleo y el tono. Con la opción C,
pulido, es la base del primer capítulo que se lanza.

| Prioridad | Contenido |
| --- | --- |
| **MVP** | Duelo con sensación: tajo, iaidō (mantener y soltar al aviso), corte de luna, esquiva, aviso del rival, impacto (pausa, sacudida, tinta, sonido) |
| **MVP** | Castillo pulido: soldados de Genzo y los yōkai del capítulo 1 (kappa, oni, onibi), con el oni gigante como jefe en el portón (`BESTIARIO.md`) |
| **MVP** | Salida a la planicie en 3D, camino a la aldea y un encuentro con dados |
| **MVP** | Aldea mínima: 2-3 diálogos, descansar para curarse, un encargo corto |
| **MVP** | Menú, guardado básico (en las estatuas jizō de la planicie, idea tuya), teclado, mando y controles táctiles; efectos de sonido y un tema musical |
| Must Have (Alpha) | Templo (2-3 puzzles), dojo (1 técnica), ruinas, Genzo como jefe, final en Hoshiyama |
| Should Have | Más tipos de enemigo, bestiario dentro del juego, tienda, más encuentros de dados, accesibilidad (remapeo, subtítulos, dificultad) |
| Nice to Have | Finales alternativos, modo de duelos, coleccionables, logros |

**Fases:** Concepto (hecho) → Prototipo (hecho: capítulo 1) → **Vertical slice** → Alpha (todos
los lugares jugables) → Beta (contenido completo y pulido) → Release → Post-launch. Calcular
fechas ahora sería inventar: se estimarán al cerrar el vertical slice.

## 6. Cómo validamos

| Qué | Cómo | Qué decide |
| --- | --- | --- |
| Rendimiento en móvil | APK en tu teléfono: FPS estables (meta ≥ 30; salen abajo a la derecha, junto a la versión) | Si Android es plataforma de lanzamiento y cuánto detalle cabe |
| Completion rate del capítulo | % de 5-10 personas que llegan al portón (meta ≥ 70 %) | Si la dificultad y el onboarding funcionan |
| Muertes y dónde | Contarlas por jugador | Qué rival o tramo ajustar |
| Intención de seguir | «¿Jugarías el siguiente capítulo?» (meta ≥ 60 % sí) | Si el núcleo engancha lo bastante para seguir construyendo |
| Duración de la sesión | Minutos jugados sin parar | Si el ritmo de la noche funciona |

Retención D1/D7, conversión o wishlists solo tendrán sentido con una demo pública; no se mide
nada público sin tu permiso.

## 7. Riesgos

| Riesgo | Nivel [Opinión] | Mitigación |
| --- | --- | --- |
| Alcance (seis géneros) | Alto | Variaciones del núcleo y lanzamiento por capítulos |
| Combate poco profundo | Alto | Parada con buen momento, lectura del rival y pocos enemigos pero distintos |
| Controles táctiles de combate 3D con cámara | Alto (Android) | Probar el APK pronto; fijar objetivo; cámara automática opcional |
| Personajes 3D hechos con piezas | Medio | Kit de piezas con un estilo coherente; valorar Blender más adelante |
| Rendimiento en PC modesto y móvil | Medio | Renderizador Compatibility; medir en el APK |
| Nombre poco distintivo | Medio | Nombre o subtítulo propio antes de la página de tienda |
| Sonido y música | Medio | Efectos generados; música con licencia libre o encargada |
| Detalle de jefe en cientos de enemigos (2-10-2026) | Alto | Por niveles: modelo propio para jefes, bases compartidas para el resto; vigilar peso del APK y FPS (DECISIÓN 15) |
| Monedas sin nada que comprar (2-10-2026) | Medio | Una moneda que no sirve para nada no motiva: darles uso pronto y pequeño (DECISIÓN 16) |
| El compañero y la economía crecen más que el núcleo | Medio | Shiro no pelea; la economía, mínima. El duelo sigue siendo lo primero |

## 8. Negocio (supuestos, no certezas)

- **Coste hoy:** tu tiempo y la suscripción de Claude; Godot es gratis **[Hecho]**.
- **Comisiones:** Google Play cobra un 15 % del primer millón de dólares al año; Steam, un 30 %
  **[Hecho]**. Tu cuenta de Google Play Console ya existe, pendiente de la verificación de
  identidad (la del proyecto Trazzo) **[Hecho, según el índice de Trazzo]**.
- **Modelo:** de pago con demo gratis **[Hipótesis]**. Con capítulos hay dos caminos: el primero
  gratis como demo y el resto de pago, o cada capítulo de pago **[Hipótesis; se decide con datos
  del vertical slice]**. Las proyecciones de ingresos (escenarios pesimista, base y optimista) se
  harán al tener el vertical slice y datos de las pruebas; hacerlas ahora sería inventar.

## 9. Decisiones que necesito de ti

### DECISIÓN 1 — Alcance del juego · **DECIDIDA el 27-09-2026: C**

- **OPCIONES:** A) seis lugares con seis géneros completos, como está; B) un núcleo (duelo +
  exploración) y cada lugar como variación con los mismos controles (§3); C) B y además lanzar
  por capítulos (primero castillo + planicie + aldea).
- **VENTAJAS:** A es la visión original completa. B reduce mucho sistemas, pruebas y arte, y
  hace que todo el juego mejore cuando mejora el núcleo. C además permite salir antes, medir y
  financiar el resto.
- **RIESGOS:** A puede no terminarse nunca. B puede sentirse repetitivo si las variaciones son
  pobres. C exige que el primer capítulo se sostenga solo.
- **COSTE:** A, varias veces el trabajo de B **[Estimación]**; C, igual que B, repartido.
- **RECOMENDACIÓN:** **C**. Es la manera más barata de saber si RONIN engancha.
- **SIGUIENTE PASO:** construir el vertical slice de §5.

### DECISIÓN 2 — Estilo de combate · **DECIDIDA el 1-10-2026: B, con el iaidō como forma**

- **OPCIONES:** A) acción: muchos enemigos y combos; B) precisión: pocos rivales, cada uno
  peligroso; parar en el momento justo abre un contraataque.
- **VENTAJAS:** A es fácil de entender y vistosa. B encaja con el samurái y con el pilar 1,
  diferencia el juego y necesita menos enemigos y animaciones.
- **RIESGOS:** A necesita mucho contenido y se parece a muchos juegos. B puede frustrar si el
  momento de parar no se lee bien (el aviso «!» ya ayuda).
- **COSTE:** A, alto en animaciones y enemigos; B, bajo en contenido y medio en ajuste fino.
- **RECOMENDACIÓN:** **B**. El prototipo ya está en el capítulo 1 para que lo pruebes antes de
  decidir: **K** (teclado), **LB** (mando) o el botón **Parar** (móvil) justo al «!».
- **SIGUIENTE PASO:** probarlo y ajustar la ventana de parada (0,3 s) y el castigo por fallar.
- **Cómo quedó (0.3):** la parada pasó a ser el iaidō. Se mantiene **K**, **LB** o el botón
  **Iai** y se suelta justo al «!»: el desenvaine desvía la lanza y derriba al soldado de un
  corte. Soltar a destiempo no para nada y hay que esperar 0,6 s para volver a intentarlo.

## 10. Hecho el 27-09-2026

1. Proyecto Godot solo con cel-shading (HD-2D y pixel art 3D quedan en el historial de git) y
   un patio más legible de noche.
2. Controles de mando y táctiles, y exportación a Android y Windows preparada: el APK se saca
   desde tu PC como con Trazzo.
3. Sensación de combate: pausa de impacto, cámara lenta en la parada, sacudida de cámara,
   chispas, estela de la espada y siete sonidos.
4. Prototipo de parada y contraataque (DECISIÓN 2), con prueba automática: 15 de 15.
5. DECISIÓN 1 cerrada: opción C (núcleo + variaciones y lanzamiento por capítulos).
6. **APK de prueba** generado en la nube y guardado en Google Drive (`ronin-0.2-prueba.apk`):
   muestra los FPS, «Atrás» pausa en vez de cerrar y la ayuda táctil tiene letra más grande.

## 11. Hecho el 1-10-2026

1. **Decisiones 2 a 7** de `PROPUESTA_MUNDO_YOKAI.md` cerradas (ver allí). La 2 cierra también la
   DECISIÓN 2 de este plan: precisión con iaidō.
2. **Iaidō** en el prototipo: mantener y soltar al «!». El iai perfecto derriba de un corte con
   pausa de impacto, cámara lenta y un cuadro de tinta invertida.
3. **Corte de luna:** con la barra de espíritu llena (se llena con iai y golpes), el tiempo se
   congela, la pantalla se vuelve tinta, aparecen las líneas de corte y caen los enemigos cercanos.
4. **Animación limitada estilo anime** (12 poses por segundo) con la opción de volver a la suave:
   **T** en el PC, o el botón de la pausa en el móvil.
5. Prueba automática: **16 de 16**.
6. **Conceptos 2D** con Higgsfield (Akira, Genzo, Takeda, el gran yōkai, Bahamut, kappa, oni y
   onibi) en `arte/conceptos/`.
7. **`HISTORIA.md`** (sinopsis para aprobar: DECISIONES 8 y 9) y **`BESTIARIO.md`** (más de 50
   criaturas por capítulos, fichas del capítulo 1 y DECISIÓN 10).

## 12. Hecho el 1-10-2026 (segunda parte)

1. **Cerradas las decisiones 8A, 9A y 10B:** sinopsis aprobada tal cual (`HISTORIA.md`), el gran yōkai es
   Tamamo-no-Mae y las criaturas de otras tierras llegan desde el capítulo 3. Los **textos del capítulo
   1** ya cuentan la historia nueva (shōgun Takeda, yōkai, luna roja); prueba automática nueva que los
   comprueba.
2. **Catálogo de monstruos:** los dos Excel que pasaste (998 filas) se limpiaron y se clasificaron
   criatura por criatura: **808 distintas** (no 1.000), más **132 añadidas** (ángeles, los 72 demonios del
   *Goetia*, yōkai que faltaban y aliados) = **939**, de las que **825 son utilizables como enemigos**.
   Datos en `bestiario/`, análisis y decisiones 12-14 en `BESTIARIO_UNIVERSAL.md`.
3. **Variante más fuerte de cada criatura** (alfa) y una tercera, la **silenciada**, ligada al Silencio
   (`HISTORIA.md` §8, DECISIÓN 11): 825 criaturas; 1.650 enemigos con el alfa y 2.475 con los tres rangos (cuentan variantes, no criaturas distintas).
4. **Sistema modular de criaturas** (`godot/scripts/criatura_modular.gd`): 7 familias de cuerpo, 4
   tamaños, 11 elementos y piezas. Las 929 criaturas se construyen (20,5 piezas de media). Se ven en la
   **galería** del juego (pausa → botón, o **G**).
5. **Entidad nueva del Silencio** (Shijima) propuesta con concepto 2D y avisos de diseño.
6. **Cuaderno de Colab** para dibujar las 2D del bestiario (`colab/`): probado sin GPU, **sin probar en
   una T4**.
7. **Prueba automática: 21 de 21** (antes 16). **APK 0.4** (`ronin-0.4-prueba.apk`).

### Decisiones pendientes de esta ronda

| # | Decisión | Dónde | Recomendación |
| --- | --- | --- | --- |
| 11 | Qué papel tiene el Silencio | `HISTORIA.md` §8 | B: gancho final y rango silenciado |
| 12 | El gancho del juego (cantidad frente a precisión) | `BESTIARIO_UNIVERSAL.md` §2 | B: precisión + cantidad |
| 13 | Cómo se modelan las icónicas | `BESTIARIO_UNIVERSAL.md` §8 | C: híbrido, con prueba de 10 |
| 14 | Cuántos rangos | `BESTIARIO_UNIVERSAL.md` §4 | B: base, alfa y silenciada |
| — | Regla de respeto cultural | `BESTIARIO_UNIVERSAL.md` §6 | Aplicarla salvo veto |

**Riesgo nuevo [Opinión]:** la cantidad de criaturas es un buen gancho de marketing, pero el cuello de
botella no es el modelo sino el comportamiento y el equilibrio de cada una (más de un tercio de las horas
estimadas). Por eso la recomendación es medir 10 criaturas reales antes de prometer cifras.

## 13. Hecho el 2-10-2026

1. **Tres enemigos con modelo detallado en el juego** (`godot/modelos/criaturas/`), con el mismo
   cel-shading, contorno y rangos que el resto:
   - **Aka-oni y kappa:** imagen → 3D con SAM 3D en Higgsfield, 1 crédito cada uno.
   - **Chōchin-obake:** modelada por código en Trimble SketchUp y pasada a GLB.
2. **Conectores revisados:**
   - Higgsfield: SAM 3D, Tripo, Hunyuan y Meshy, con sus costes medidos sin gastar.
   - Tripo y Meshy directos: precios verificados.
   - Visor de Three.js y Trimble SketchUp, probados.
   - Lo que vale cada uno: `BESTIARIO_UNIVERSAL.md` §8.1.
3. **DECISIÓN 15:** cómo llevar a todos los enemigos al nivel de detalle que pediste (§8.2). La
   recomendación es por niveles, con un piloto de esqueleto antes de pagar nada.
4. **Prueba automática: 22 de 22.** **APK 0.5** (`ronin-0.5-prueba.apk`, 30,4 MB). Cada modelo de IA
   pesa unos 1,2 MB en el APK; el de SketchUp, 0,1 MB.

| # | Decisión | Dónde | Recomendación |
| --- | --- | --- | --- |
| 15 | Cómo dar a todos los enemigos el detalle que pediste | `BESTIARIO_UNIVERSAL.md` §8.2 | D: por niveles, tras un piloto de esqueleto |


## 14. Hecho el 2-10-2026 (tarde): Akira endurecido, skins, Shiro y monedas

Lo que pediste: Akira con más aire de samurái (más rudo, con una cicatriz en la cara), un compañero
que camine con él y recoja monedas de vez en cuando, y probar estilos de dibujo.

1. **Akira, el joven endurecido** (lo elegiste tú), en el juego: cicatriz en diagonal, mirada dura,
   cinta roja deshilachada, ropa remendada y vendas. **Tres skins**: curtido (unos 30), veterano (unos
   40, con canas, barba y sombrero de paja a la espalda) y Akira mujer. Se cambian en la pausa (V o
   el botón) y el juego recuerda la elegida.
2. **Shiro**, el perro (opción recomendada que elegiste):
   - Sigue a Akira y se sienta cuando se para.
   - Se queda atrás, agachado, si hay soldados alerta. No pelea y nadie le ataca.
   - En calma, cada 22-40 s olfatea, ladra, escarba y desentierra 3-6 monedas. El primer hallazgo
     llega a los 9 s, para que se descubra solo.
   - Trae las monedas que se quedan atrás.
3. **Monedas «mon»** (cobre con agujero cuadrado, del periodo Edo):
   - Los soldados sueltan 2-4.
   - Akira las recoge al pasar y el contador del HUD suena más agudo en racha.
   - Se conservan al reintentar, pero todavía no hay partida guardada.
4. **Arreglado un fallo de antes:** en la pausa los soldados seguían moviéndose (el juego no se
   paraba de verdad). Ahora la pausa lo detiene todo.
5. **Prueba de estilos de dibujo** (`arte/conceptos/estilos/`) y concepto de Shiro. Higgsfield
   rechaza una persona con un perro en la misma imagen: se hacen por separado.
6. **Prueba automática: 28 de 28** (antes 22).

### DECISIÓN 16 — Para qué sirven las monedas · **DECIDIDA el 2-10-2026: A + C**
- **OPCIONES:**
  - A) **Estatuas jizō:** rezar y mejorar un poco a Akira (vida o espíritu). Ya estaba en el plan.
  - B) **Tienda de la aldea:** vendas para curarse o amuletos.
  - C) **El sastre de la aldea:** las skins se compran con monedas del juego.
  - D) **Skins de pago** con dinero real (DLC de aspecto).
- **VENTAJAS:**
  - A da progresión y una razón para explorar.
  - B da decisiones de gasto.
  - C da un sumidero que no toca el equilibrio del combate.
  - D da ingresos.
- **RIESGOS:**
  - A: si los números suben mucho, el combate de precisión pierde tensión.
  - B: añade un sistema (inventario).
  - C: las skins tienen que valer el precio.
  - D: en un juego de pago, cobrar aparte por el aspecto del protagonista se recibe mal si llega con el
    lanzamiento [Opinión]. Y las monedas nunca deben venderse por dinero: rompería la DECISIÓN 7 C.
- **COSTE:**
  - A: bajo.
  - B: medio.
  - C: bajo (las tres skins ya existen).
  - D: medio (la tienda de la plataforma y más arte).
- **RECOMENDACIÓN:** **A + C.** Las monedas se ganan jugando y se gastan en dos sitios: las estatuas
  (pocas mejoras y pequeñas) y el sastre (las skins). D, solo como contenido después del lanzamiento
  y nunca para monedas.
- **SIGUIENTE PASO:** una estatua jizō y un sastre en la aldea del vertical slice, con 2 o 3 precios,
  para medir cuántas monedas junta un jugador en una partida.

### DECISIÓN 17 — De dónde vienen Shiro y la cicatriz · **DECIDIDA el 2-10-2026: A**
En `HISTORIA.md` §9: Shiro era el perro del shōgun y la cicatriz se la hizo Genzo la noche de la
traición. Contado en la intro y el cierre (§5 de la historia).

### DECISIÓN 18 — Estilo de las ilustraciones 2D · **DECIDIDA el 2-10-2026: A** (tinta para la historia y los personajes; el bestiario sigue en color)
- **OPCIONES** (`arte/conceptos/estilos/`):
  - A) Manga de tinta (blanco y negro con rojo de acento).
  - B) Realista pintado.
  - C) Anime de los 90.
  - D) Ukiyo-e.
  - E) Seguir con el estilo del Bahamut (anime en color con tinta), que es el de las 8 imágenes de
    esta mañana.
- **VENTAJAS:**
  - A: la más ruda; casa con el pilar «grabado en tinta que se mueve» y con el cel-shading; un solo
    color de acento es fácil de mantener coherente.
  - B: la más espectacular.
  - C: cercana.
  - D: la más distinta y de dominio público.
  - E: ya hecha y te gustó.
- **RIESGOS:**
  - A: en blanco y negro luce menos en miniaturas; el arte de tienda puede ir en color.
  - B: comparación directa con Ghost of Tsushima; promete más de lo que da un juego cel-shading.
  - C: genérica; recuerda a series concretas.
  - D: caras poco expresivas para escenas de emoción.
  - E: pediste un cambio.
- **COSTE:** 0,15 créditos por imagen en Higgsfield. Rehacer las 8 de esta mañana costaría 1,20
  créditos y quedan 0,01: haría falta comprar créditos (decides tú) o usar Colab, gratis con la T4. El
  cuaderno acepta cualquier bloque de estilo.
- **RECOMENDACIÓN [Opinión]:** **A para la historia y los personajes**, y el color (E) para las fichas
  de criaturas del bestiario, que comparten el trazo negro. D queda como opción para títulos de
  capítulo o el tráiler.
- **SIGUIENTE PASO:** cuando elijas, poner ese bloque de estilo en el cuaderno de Colab y rehacer allí
  a Genzo, a Takeda y la escena de la traición.

| # | Decisión | Dónde | Decidido (2-10-2026) |
| --- | --- | --- | --- |
| 16 | Para qué sirven las monedas | §14 | **A + C:** estatuas jizō y sastre (skins bloqueadas hasta comprarlas) |
| 17 | De dónde vienen Shiro y la cicatriz | `HISTORIA.md` §9 | **A:** el perro del shōgun; la cicatriz, de Genzo (en la intro y el cierre) |
| 18 | Estilo de las ilustraciones 2D | §14 | **A:** tinta para la historia y los personajes; el bestiario sigue en color |

## 15. Hecho el 2-10-2026 (noche): versión 0.7 con las decisiones 16, 17 y 18

1. **17A en el juego:** la intro cuenta que la espada de Genzo le cruzó la cara a Akira y que solo
   Shiro, el perro del shōgun, va con él; el cierre, que cruza la puerta con Shiro a su lado.
2. **16A, estatua jizō** en el patio (junto al muro oeste, cerca del inicio):
   - Al acercarse sale un aviso con el precio. Se reza con ENTER, con B en el mando o tocando el
     aviso.
   - Rezar da +1 de vida máxima y cura del todo. Cuesta 40 mon la primera vez y 80 la segunda;
     no hay más.
   - Es el primer sumidero de monedas; más adelante será también donde se guarda la partida.
3. **16C, el sastre:** las skins empiezan bloqueadas (lo elegiste así para el APK de prueba).
   - Precios: curtido 30, mujer 40 y veterano 60.
   - **Mientras no exista la aldea, el sastre está en la pausa:** V enseña el siguiente aspecto, B
     (o el botón) lo compra. Lo que no se compra no se queda puesto al salir.
   - En la galería se siguen viendo todas, con su precio.
4. **Partida guardada** (`user://partida.cfg`): monedas, skins compradas y bendiciones. Se guarda
   sola poco después de cada cambio, al salir y al mandar el juego a segundo plano. Hasta ahora las
   monedas se perdían al cerrar el juego.
5. **18A:** el concepto oficial de Akira es el de tinta (`arte/conceptos/akira.jpg`). Genzo y Takeda
   se rehacen en tinta cuando haya créditos (quedan 0,01) o con Colab.
6. **Prueba automática: 31 de 31.** Se añaden el sastre, el jizō y el guardado.

**Supuestos que hay que medir [Supuesto]:**
- Una partida al patio da unas 15-40 monedas: 6 soldados × 2-4, más 3-6 por cada hallazgo de
  Shiro (1-3 por partida, según el tiempo en calma).
- Con esos números, la primera skin (30) llega en 1-2 partidas y las dos bendiciones (120 en total),
  en unas 4-8.

Si en el móvil se siente lento o regalado, se ajustan los precios en `godot/scripts/partida.gd`.

## 16. Hecho el 2-10-2026 (noche): versión 0.8, cabezas que ya no son bolas

1. **Pelo en mechones:** cada mechón es un cono, y todos se unen en una sola malla (una sola llamada
   de dibujo, que el móvil agradece).
   - Joven: puntas revueltas, flequillo sobre la cinta y patillas que tapan las mejillas.
   - Curtido y veterano: moño de ronin hacia delante, puntas en la nuca y patillas hasta la
     mandíbula. El veterano, con entradas: sin flequillo.
   - Akira mujer: flequillo recto, patillas hasta la barbilla y coleta alta.
2. **Cara dibujada:** los ojos, las cejas, la nariz y la boca son una imagen 2D que se proyecta
   sobre la cabeza, la técnica de los juegos de anime en 3D. Cada skin tiene la suya:
   - el curtido, con barba de pocos días;
   - el veterano, con patas de gallo, surcos y bigote;
   - Akira mujer, con pestañas.
   Las imágenes salen de `godot/recursos/caras/generar_caras.py` y se pueden redibujar a mano.
3. **Forma de la cabeza:** mentón en punta, cuello, la cabeza algo más estrecha y la piel con luz
   plana, para que la sombra no parta la cara en dos.
4. **Cinta (hachimaki) a medida:** va pegada a la frente y por encima del pelo, con el nudo y las
   puntas detrás. Antes era un aro que flotaba como un halo oscuro.
5. **Barba del veterano en mechones.** Antes era una bola gris que parecía un bozal.
6. **Soldados:** protector de cuello (shikoro) y máscara (menpō). Además, la sombra del sombrero les
   tapa los ojos y solo se ven dos rendijas claras.
7. **Línea de dibujo de grosor casi constante** en todo el juego: entre 1,3 y 3,5 píxeles a 720p.
   - De cerca ya no es un borrón y de lejos no desaparece.
   - **[Hecho]** No cuesta rendimiento: 44 ms por cuadro frente a 43 ms antes, con 24 personajes en
     el emulador de la nube (6 medidas alternas; la diferencia está dentro del ruido).
8. **Arreglado:** en la galería se pisaban los nombres de las skins.
9. **Prueba automática: 31 de 31.** FPS al caminar por el patio: entre 11,7 y 12,4 en dos pasadas
   (antes 11,9), en el mismo emulador. Es decir, lo mismo.

Antes y después: `capturas/comparativa_cabezas.jpg`.

### Hasta dónde llegan las piezas [Opinión]
- **Lo que sí se puede** (la vía de hoy):
  - siluetas con identidad (pelo, sombreros, armas);
  - caras dibujadas, y expresiones cambiando la imagen: dolor, concentración, ojos cerrados (aún sin
    hacer);
  - línea de dibujo y luz en bandas;
  - animación limitada a 12 poses por segundo.
- **El techo:**
  - el cuerpo son cajas y cilindros, así que la ropa no cae ni hace pliegues;
  - no hay esqueleto: las articulaciones se ven como piezas sueltas y nada se dobla;
  - las manos no tienen dedos, y la cara no tiene volumen de nariz ni pómulos;
  - de cerca nunca parecerá un dibujo a mano. A la distancia de la cámara del juego, en cambio, sí se
    lee como anime.
- **Los juegos que «parecen 2D» en 3D** (Guilty Gear Xrd, Genshin Impact, Hi-Fi Rush) usan otra cosa:
  - modelos de una pieza hechos a mano y con esqueleto;
  - normales retocadas para que la sombra caiga como en un dibujo;
  - caras con expresiones;
  - poses exageradas.
  Eso es modelado de verdad, que es la opción B de abajo.

### DECISIÓN 19 — Camino hacia el «2D lo más pulido» · **pendiente**
- **DECISIÓN:** con qué hacemos los personajes que se ven de cerca (Akira, Shiro, Genzo, Takeda y los
  jefes).
- **OPCIONES:**
  - A) **Seguir con piezas y trucos de anime** (lo de hoy), y añadir expresiones, mangas y hakama con
    caída (formas en trapecio) y manos con forma.
  - B) **Modelos hechos en Blender:**
    - una malla suave por personaje, con esqueleto y pelo en mechones;
    - la cara dibujada de hoy y sombreado anime;
    - los haría yo por código, aquí en la nube, sin usar tu PC.
  - C) **VRoid Studio** en tu PC: personajes anime de calidad con deslizadores. Exporta VRM y Godot
    lo importa con el complemento godot-vrm.
  - D) **Personajes 2D de verdad** (sprites dibujados) en el mundo 3D, al estilo «HD-2D» de Octopath
    Traveler.
  - E) **Modo tinta:** un filtro opcional que pone todo el juego en blanco y negro con tramas, como un
    manga que se mueve. Se puede sumar a cualquiera de las otras.
- **VENTAJAS:**
  - A: gratis, rápida y sin riesgo técnico. A la distancia del juego ya se lee como anime.
  - B: el mayor salto de calidad sin depender de tu PC ni de créditos. Cuerpos que se doblan y ropa
    con forma.
  - C: la mejor calidad por esfuerzo en personajes anime.
  - D: el «2D» más literal, y el más bonito si se dibuja bien.
  - E: identidad muy fuerte y barata. Casa con la 18A y con el pilar «grabado en tinta que se mueve».
- **RIESGOS:**
  - A: el techo de arriba: de cerca seguirá pareciendo hecho de piezas.
  - B: modelar por código tiene un límite, y sin un artista no llegará al nivel de Genshin
    [Opinión]. Además, hay que rehacer la animación: de girar piezas a mover huesos.
  - C: **[Hecho]** según su ficha de Steam, pide 8 GB de RAM como mínimo (16 recomendados) y 10 GB de
    disco. Con 0,5-1 GB libres no es viable hoy en tu PC. Y los personajes de VRoid se parecen entre
    sí [Opinión].
  - D: hay que dibujar cada personaje en 8 direcciones y para cada animación: cientos de dibujos
    [Estimación]. Con IA, el problema es la coherencia entre dibujos, y quedan 0,01 créditos.
  - E: hay que probar la legibilidad en combate (el rojo de acento tiene que marcar a los enemigos y
    los golpes) y el coste en móviles modestos.
- **COSTE** [Estimación]:
  - A: bajo, unas horas por mejora.
  - B: instalar Blender, una descarga grande que necesita tu permiso, y 1-2 sesiones por personaje
    principal.
  - C: gratis, pero necesita un PC con más memoria.
  - D: el más caro: semanas de dibujo o un artista.
  - E: bajo, una sesión para el prototipo.
- **RECOMENDACIÓN [Opinión]:**
  - **A**, que ya está hecha en lo principal.
  - **Un piloto de B solo con Akira**, para decidir con él delante si B se queda en los personajes
    principales. Soldados y criaturas seguirían con piezas: a la distancia del juego ya funcionan.
  - **Un prototipo de E** como opción en la pausa.
  - C, si algún día cambias de PC. D, descartada en esta fase por coste.
- **SIGUIENTE PASO:**
  - Si eliges B: me das permiso para descargar Blender (verifico la suma de comprobación) y hago a
    Akira.
  - Si eliges E: hago el modo tinta como opción en la pausa.

| # | Decisión | Dónde | Estado |
| --- | --- | --- | --- |
| 19 | Camino hacia el «2D lo más pulido» | §16 | **Pendiente.** Recomendado: A + piloto de B con Akira + prototipo de E |
