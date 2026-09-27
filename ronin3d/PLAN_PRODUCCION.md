# RONIN — Plan de producción

**Fecha:** 27 de septiembre de 2026 · **Fase actual:** prototipo (capítulo 1 jugable en Godot 4.7,
cel-shading) · **Siguiente hito:** vertical slice.

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
  **[Opinión]**.
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
- **Largo plazo:** honor y justicia se acumulan y cambian cómo es la vuelta a Hoshiyama.

## 5. Vertical slice (siguiente hito)

**«Una noche en Hoshiyama»:** 15-20 minutos que prueban el núcleo y el tono.

| Prioridad | Contenido |
| --- | --- |
| **MVP** | Duelo con sensación: tajo, parada con buen momento, esquiva, aviso del rival, impacto (pausa, sacudida, sonido) |
| **MVP** | Castillo pulido: soldados + un rival distinto (arquero o capitán como mini-jefe) |
| **MVP** | Salida a la planicie en 3D, camino a la aldea y un encuentro con dados |
| **MVP** | Aldea mínima: 2-3 diálogos, descansar para curarse, un encargo corto |
| **MVP** | Menú, guardado básico, teclado, mando y controles táctiles; efectos de sonido y un tema musical |
| Must Have (Alpha) | Templo (2-3 puzzles), dojo (1 técnica), ruinas, Genzo como jefe, final en Hoshiyama |
| Should Have | Más tipos de enemigo, tienda, más encuentros de dados, accesibilidad (remapeo, subtítulos, dificultad) |
| Nice to Have | Finales alternativos, modo de duelos, coleccionables, logros |

**Fases:** Concepto (hecho) → Prototipo (hecho: capítulo 1) → **Vertical slice** → Alpha (todos
los lugares jugables) → Beta (contenido completo y pulido) → Release → Post-launch. Calcular
fechas ahora sería inventar: se estimarán al cerrar el vertical slice.

## 6. Cómo validamos

| Qué | Cómo | Qué decide |
| --- | --- | --- |
| Rendimiento en móvil | APK en tu teléfono: FPS estables (meta ≥ 30) | Si Android es plataforma de lanzamiento y cuánto detalle cabe |
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

## 8. Negocio (supuestos, no certezas)

- **Coste hoy:** tu tiempo y la suscripción de Claude; Godot es gratis **[Hecho]**.
- **Comisiones:** Google Play cobra un 15 % del primer millón de dólares al año; Steam, un 30 %
  **[Hecho]**. Tu cuenta de Google Play Console ya existe, pendiente de la verificación de
  identidad (la del proyecto Trazzo) **[Hecho, según el índice de Trazzo]**.
- **Modelo:** de pago con demo gratis **[Hipótesis]**. Las proyecciones de ingresos (escenarios
  pesimista, base y optimista) se harán al tener el vertical slice y datos de las pruebas; hacerlas
  ahora sería inventar.

## 9. Decisiones que necesito de ti

### DECISIÓN 1 — Alcance del juego

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

### DECISIÓN 2 — Estilo de combate

- **OPCIONES:** A) acción: muchos enemigos y combos; B) precisión: pocos rivales, cada uno
  peligroso; parar en el momento justo abre un contraataque.
- **VENTAJAS:** A es fácil de entender y vistosa. B encaja con el samurái y con el pilar 1,
  diferencia el juego y necesita menos enemigos y animaciones.
- **RIESGOS:** A necesita mucho contenido y se parece a muchos juegos. B puede frustrar si el
  momento de parar no se lee bien (el aviso «!» ya ayuda).
- **COSTE:** A, alto en animaciones y enemigos; B, bajo en contenido y medio en ajuste fino.
- **RECOMENDACIÓN:** **B**. Hago un prototipo de parada para que lo pruebes antes de decidir.
- **SIGUIENTE PASO:** probarlo en el capítulo 1 y ajustar la ventana de parada.

## 10. Lo que ya está en marcha

1. Proyecto Godot solo con cel-shading (HD-2D y pixel art 3D quedan en el historial de git).
2. Exportación a Android preparada, para probar el APK en tu móvil.
3. Sensación de combate: pausa de impacto, sacudida de cámara, estela de la espada y sonidos.
