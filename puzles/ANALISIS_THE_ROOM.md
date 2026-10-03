# The Room: cómo está diseñado

Análisis de la serie The Room (Fireproof Games) para aprender sus principios y usarlos en un juego
propio. No es un resumen ni una guía: es una descomposición del diseño. La parte propia está en
`BIBLIA_DISENO.md`.

**La pregunta central:** ¿cómo consigue el juego que el jugador observe, experimente, descubra,
resuelva y quiera continuar?

**Marcas:**
- **[Hecho]**: lo dicen las guías, las reseñas o los vídeos (las siglas de las fuentes están en los
  anexos).
- **[Vídeo]**: descripción automática de un vídeo.
- **[Deducción]**: conclusión a partir de los hechos.
- **[Hipótesis]**: idea de diseño que habría que comprobar.
- **[Opinión]**: valoración del equipo.

---

## 0. Material y método

**Los cuatro vídeos que envió el usuario** son partidas completas, sin comentarios:

| Juego | Año | Vídeo | Duración | Cómo se analizó |
|---|---|---|---|---|
| The Room | 2012 | https://youtu.be/_N9YeVhc3hI | 52 min | vidIQ lo vio entero y lo describió puzle a puzle, más las guías escritas |
| The Room Two | 2013 | https://youtu.be/oS3dOwB_D44 | 58 min | Guías escritas (los créditos de vidIQ solo alcanzaban para dos vídeos) |
| The Room Three | 2015 | https://youtu.be/7BH2PwFRie0 | 2 h 48 min | Guías escritas |
| The Room: Old Sins | 2018 | https://youtu.be/4paowtxhQLY | 1 h 34 min | vidIQ lo vio entero, más las guías escritas |

**Guías y reseñas:**
- **Guías paso a paso:** PocketGamer, Walkthrough King, Mystery Manor, AppUnwrapper, LevelWinner,
  Gamezebo y la wiki de Fandom.
- **Reseñas:** TouchArcade, IGN, Eurogamer, God is a Geek y TheSixthAxis, más una entrevista y dos
  análisis de estudiantes.

Si una descripción de vídeo y una guía no coinciden, manda la guía.

**Anexos con la reconstrucción completa, puzle a puzle y con fuentes:**
- `referencia/the_room_1_y_2.md`;
- `referencia/the_room_3_y_old_sins.md`.

Este documento usa sus códigos: «1.4» es el puzle 4 del capítulo 1 de The Room; «S.6», el puzle 6
del barco de The Room Two.

**Límites:**
- No se jugó: se analizaron grabaciones y textos.
- Los tiempos de espera de las pistas no constan en ninguna fuente.
- Los sonidos solo se conocen por las reseñas y las descripciones.

---

## 1. La respuesta corta: el bucle que engancha

```
MIRAR ──► TOCAR ──► ALGO CEDE ──► APARECE ALGO ──► USARLO ──► EL OBJETO CAMBIA
  ▲                                                                   │
  └──────────────────── una capa más adentro ◄─────────────────────────┘
```

**Ocho pilares** [Deducción, salvo que se indique otra cosa]:

1. **Un solo objeto muy denso en la oscuridad.**
   - [Hecho] Solo la caja está iluminada.
   - Todo lo que importa está en ella. No hay ruido alrededor, así que cualquier detalle puede ser
     una pista.
2. **Tacto.**
   - Cada gesto imita una acción física: deslizar, girar, tirar o empujar.
   - [Hecho] Las piezas tienen peso: Fireproof metió un motor de física para eso.
   - Una llave que gira da «a satisfying thunk» [Hecho, TouchArcade].
3. **Capas.**
   - Cajas dentro de cajas, objetos que esconden objetos y un ocular que revela otra capa del mundo.
   - Siempre hay «un poco más adentro».
4. **Información repartida.**
   - La pista está en el propio objeto, a veces lejos de la cerradura. Por ejemplo, un símbolo
     grabado en una pata que resuelve un dial de la tapa.
   - Recordar «esto lo he visto» es parte del placer.
5. **Bucle corto de recompensa.**
   - Casi cada acción produce un cambio visible en segundos.
   - Los ratos largos sin nada que hacer son raros.
6. **Un misterio que tira.**
   - Notas de un desconocido, una sustancia extraña y un personaje que observa.
   - La curiosidad va más allá del puzle.
7. **Rituales que se repiten y crecen.**
   - [Hecho] En The Room Two, cada sala termina con el mismo puzle de alinear varillas.
   - [Hecho] En The Room Three, la máquina de puertas vuelve en cada capítulo, cada vez más
     complicada.
   - Reconocer el ritual da sensación de dominio.
8. **Cada entrega añade una sola capa de estructura:**
   1. una caja;
   2. una sala con varios puestos;
   3. un centro con zonas y miniaturas;
   4. una casa de muñecas con habitaciones conectadas.

   Los verbos básicos no cambian.

---

## 2. El juego como sistema: qué hace el jugador

| Verbo | Qué toca o hace | Ejemplos | Qué información recibe |
|---|---|---|---|
| Mirar | Girar alrededor y acercarse con doble toque | Toda la serie | Forma del objeto, huecos, símbolos, desgaste |
| Mover | Deslizar paneles, tirar de cajones, girar diales | Panel rayado (1.4), cajones (D.3) | Si cede o no; topes y clics |
| Abrir | Tapas, puertas y compartimentos | Puerta de la caja fuerte (1.6) | Un espacio nuevo y su contenido |
| Coger | Tocar un objeto para guardarlo | Llave (1.1), engranaje | Un recurso con forma, que sugiere dónde va |
| Examinar | Girarlo a pantalla completa y manipularlo | Libro con discos (2.2), medallón (C.5) | Partes ocultas; el objeto se transforma |
| Usar | Arrastrar el objeto al mundo | Llave en la cerradura, gema en el cuenco | Encaja o no |
| Configurar | Ajustar una llave o un molde antes de usarlo | Llave de extremo giratorio (1.4), molde de la forja (Three 4.8) | El contorno de la cerradura es la pista |
| Activar | Palancas, interruptores, manivelas | Manivela de la caja de engranajes (2.13) | Una máquina que se pone en marcha |
| Revelar | El ocular o lente | Tinta invisible (1.6), huellas (2.1), cifras por perspectiva (2.3) | Una capa oculta: texto, trayectorias, huellas |
| Encogerse | «Superzoom» dentro de objetos | Cerradura por dentro (Three 1.5), miniaturas | Un mundo dentro del objeto |
| Leer | Notas y cartas | Acertijo FIRE (1.3), rumbos del mapa (S.6) | Historia y, a veces, la clave |
| Combinar en el mundo | Montar máquinas por piezas | Zoótropo (2.5), ballesta (T.2-T.5) | Una herramienta nueva |

**Información visible y oculta** [Deducción]:
- **Visible pero sin sentido aún:** símbolos, números romanos, desgaste, siluetas de huecos.
- **Oculta en el espacio:** detrás de paneles, dentro de objetos, en la base, al fondo de un cajón.
- **Oculta en otra capa:** la que muestra el ocular.
- **Oculta en el punto de vista:** cifras que solo se leen desde un ángulo.
- **Oculta en el tiempo:** un reloj que marca una hora, un ritmo, una secuencia que se repite.

---

## 3. Cómo crece el formato de una entrega a otra

| Juego | Unidad de nivel | Cómo se pasa de nivel | Novedad estructural |
|---|---|---|---|
| The Room | Una caja con capas (4 capítulos y un epílogo) | Al abrir la última cerradura sale otra caja más pequeña y compleja [Hecho] | La caja anidada |
| The Room Two | Una sala con varios puestos (6 salas) | El Null de cada sala, visto con el ocular, abre la puerta siguiente [Hecho] | Moverse entre puestos de una sala |
| The Room Three | Un centro (la mansión) con una zona por capítulo | Cada zona da una pirámide; con cinco se llega al final; hay 4 finales [Hecho] | El centro, las miniaturas (superzoom) y los finales |
| Old Sins | Una casa de muñecas: cada habitación es un nivel | El artefacto de una habitación se convierte en una pieza que se pone en la casa y abre otra [Hecho] | Habitaciones conectadas que se pasan recursos (agua, vapor) |

[Deducción] La serie no cambió los verbos: amplió el espacio donde se usan. Es un buen modelo de
producción: un núcleo estable y, en cada entrega, una sola idea estructural nueva.

---

## 4. Fichas de nivel

### 4.1 The Room · Capítulo 1: la caja fuerte (el tutorial)

1. **Objetivo:** abrir la caja fuerte.
2. **Estado inicial:** una caja fuerte sobre un pedestal, a oscuras; un sobre encima [Hecho].
3. **Espacio:**
   - un solo objeto con tapa, patas, laterales y puerta;
   - cámara orbital;
   - solo la caja está iluminada.
4. **Descubrimiento:** el sobre (1.1). Es lo único que destaca sobre la tapa.
5. **Secuencia:** carta y llave (1.1) → joyero (1.2) → placa FIRE (1.3) → panel rayado y llave
   configurable (1.4) → perno y llave inglesa (1.5) → lente y anillos con el ocular (1.6).
6. **Puzles:**
   - 6 pasos;
   - un acertijo (1.3);
   - una pieza que delata su desgaste (1.4);
   - una llave configurable, el primer objeto que se modifica en el inventario (1.4);
   - una herramienta (1.5);
   - el primer uso del ocular (1.6).
7. **Dependencias:**
   ```
   1.1 carta ─► llave ─► 1.2 joyero ─► ocular sin lente + acertijo
                                         │
                       1.3 FIRE (acertijo) ─► llave configurable
                                         │
                       1.4 panel rayado ─► llave inglesa ─► 1.5 perno ─► lente
                                                                          │
                                         1.6 anillos (con el ocular) ─► la puerta
   ```
8. **Feedback:**
   - la cámara viaja sola al joyero [Hecho];
   - la placa cae [Hecho];
   - la lente se monta sola en el ocular [Hecho];
   - la puerta se abre «poco después» [Hecho].
9. **Dificultad: fácil.**
   - Cada paso tiene una sola salida.
   - El acertijo apunta a una palabra escrita en la caja.
   - Solo exige leer y mirar bien.
   - Enseña a sospechar del desgaste y a reutilizar una llave.
10. **Recompensa:** la caja interior. Es el primer «¡dentro hay otra!», que promete todo el juego.

### 4.2 The Room · Capítulo 2: la caja de los tres sellos

1. **Objetivo:** romper tres sellos: el zoótropo, la minicaja fuerte y el reloj [Hecho].
2. **Estado inicial:** una caja hexagonal con patas, aguja, paneles y cerraduras.
3. **Espacio:**
   - la caja tiene caras con funciones distintas: teclado, aguja, patas, cajón y reloj;
   - aparecen partes nuevas a medida que se abre.
4. **Descubrimiento:** huellas que solo ve el ocular y que señalan un escondite (2.1).
5. **Secuencia:** 18 pasos en tres bloques [Hecho].
   - Sello 1: libro (2.1-2.2) + cifras por perspectiva (2.3) + patas (2.4) → zoótropo (2.5) →
     calavera (2.6) → candado TRIAL (2.7).
   - Sello 2: cuatro símbolos (2.8) + bolas (2.9) → estrella (2.10) → dial (2.11) → llave
     transformable (2.12).
   - Sello 3: cuatro diales (2.13) → ruedas (2.14) → tren de engranajes (2.15) → tubo (2.16) →
     panel (2.17) → reloj a las 6:05 (2.18).
6. **Puzles:**
   - perspectiva;
   - objetos del inventario con puzle propio (el libro y el tubo);
   - una máquina montada por piezas (el zoótropo);
   - pistas repartidas por la caja (los cuatro símbolos);
   - un dial de caja fuerte, engranajes y un código al dorso de una foto.
7. **Dependencias:** tres objetivos intermedios (los sellos) bajo uno final. Dentro de cada sello,
   cadenas con dos o tres ramas que se juntan. Es el patrón «árbol que converge».
8. **Feedback:**
   - la película del zoótropo, con susurros [Hecho, TouchArcade];
   - la cámara gira sola y se abre el sello [Hecho];
   - la cámara se aleja sola y se ve subir la parte de arriba (2.13) [Hecho];
   - la vista salta al reloj (2.15) [Hecho].
9. **Dificultad: media-alta.** Es el capítulo más largo de The Room.
   - Exige memoria espacial: dónde estaba cada símbolo.
   - Exige mover la cámara para leer (perspectiva).
   - Exige relacionar un objeto (la foto) con un mecanismo (el reloj) separados por varios pasos.
10. **Recompensa:** cada sello abre una parte visible de la caja, así que el progreso se ve. Al
    final, la caja siguiente.

### 4.3 The Room Two · Capítulo 2: el barco

1. **Objetivo:** salir de la bodega. El Null y las varillas abren la puerta [Hecho].
2. **Estado inicial:** la bodega de un barco con varios puestos: maqueta de galeón, cofre, poste,
   mesa con balanza y caja-cronómetro [Hecho].
3. **Espacio:**
   - se va de un puesto a otro con pellizcos y deslizamientos;
   - algunos puestos aparecen al iluminarse [Hecho].
4. **Descubrimiento:** una carta que menciona el palo, la cofa y los cañones (S.1). La nota apunta a
   partes concretas del espacio.
5. **Secuencia:** cofa → cañones → media gema → cofre → cuatro cerraduras ocultas → mapa → maqueta →
   balanza → ancla → cronómetro → las 2:50 → barco distorsionado (S.1-S.12).
6. **Puzles:**
   - cerraduras que solo se ven por ventanitas con el ocular (S.5);
   - un mapa que se recorre con instrucciones de cartas (S.6);
   - pesas que se transforman en el inventario (S.8);
   - una maqueta que se completa por piezas (S.7, S.9).
7. **Dependencias:** casi lineales (S.1 → … → S.12), pero repartidas por cinco puestos.
   - La dificultad está en recordar qué puesto pide qué.
   - [Hecho, TouchArcade] «which table was it on?».
8. **Feedback:**
   - la media gema ilumina el cofre y la cámara viaja allí [Hecho];
   - el barco se mueve por el mapa;
   - un destello despeja la niebla;
   - giran engranajes [Hecho].
9. **Dificultad: media.** Los puzles por separado no son difíciles. La carga está en la navegación
   y en el inventario: piezas para puestos lejanos.
10. **Recompensa:** la cámara lleva de un puesto a otro, así que la sala «se va encendiendo». Al
    final, la puerta siguiente.

### 4.4 The Room Three · Capítulo 2: el faro

1. **Objetivo:** la pirámide 2 [Hecho].
2. **Estado inicial:** una maqueta de madera de la isla en el centro de la sala; una carta junto a la
   ventana [Hecho].
3. **Espacio:**
   - la sala real, con su maqueta;
   - las miniaturas de la maqueta (molino, torre, observatorio, faro), en las que se entra con
     superzoom;
   - la sala sube un piso como un ascensor [Hecho].
4. **Descubrimiento:** un cajón que pide dos manos: mantener un deslizador y levantar el pestillo
   (2.1).
5. **Secuencia:** 42 pasos en la guía de AppUnwrapper [Hecho], con dos ramas que se juntan en la
   gema y la linterna:
   - la de la esfera, el búho, la barca, la rata, la llave, el maniquí y el piso del faro;
   - la del casco, el remache, la bellota, el saltamontes, el puntero, el grifo y el frasco.
6. **Puzles:**
   - miniaturas con animales mecánicos (serpiente, búho, rata, saltamontes);
   - un maniquí recursivo: una sala igual dentro de la maqueta, con otra maqueta dentro (2.11);
   - imanes que empujan rombos (2.7);
   - una «máquina de escribir» con regla de doble entrada sin explicar (2.3).
7. **Dependencias:** árbol de dos ramas largas que convergen. Al final, una cadena corta y vistosa
   (gema → lámpara → jaula → pirámide).
8. **Feedback:**
   - suben estructuras de la maqueta;
   - la sala entera sube un piso;
   - al salir de la recursión, los maniquíes de cada nivel se completan [Hecho].
9. **Dificultad: alta.** Es el capítulo con más pasos.
   - Hay que recordar en qué miniatura está cada cosa.
   - La regla de la máquina de escribir no se explica: se descubre probando.
10. **Recompensa:** el asombro de escala (entrar en lo pequeño) y la pirámide, que rellena el
    contador de progreso del centro.

### 4.5 Old Sins · Vestíbulo y capítulo del estudio

1. **Objetivo:** el artefacto de cada habitación. Con todos, romper el sello del desván [Hecho].
2. **Estado inicial:** una casa de muñecas en el desván, con huecos visibles en el exterior: blasón,
   pedestales, farola, balcón, pozo, chimenea… [Hecho].
3. **Espacio:**
   - el exterior de la casa (el centro);
   - hasta tres habitaciones abiertas a la vez, más el exterior [Hecho].
   - Se entra rompiendo un sello con el ocular y un doble toque; se sale pellizcando [Hecho].
4. **Descubrimiento:**
   - en el vestíbulo, una caja con un dial que da una moneda;
   - en el inventario, la moneda se transforma en molinete (V2).
5. **Secuencia del estudio:** 61 pasos en AppUnwrapper [Hecho]. Su núcleo:
   - escritorio → pozo → cocina → campanas → tintero;
   - cajones → bomba → foto → tren → chimenea → sala de curiosidades → globo → … → vapor → artefacto.
6. **Puzles:**
   - el primer superzoom dentro de un objeto;
   - cerrojos que dependen de la posición final de varios cajones (E7);
   - un código que solo se lee desde un ángulo (25BF);
   - recursos que viajan entre habitaciones (agua, fuego y vapor).
7. **Dependencias:** red entre tres habitaciones.
   - El estudio necesita la cocina y la sala de curiosidades.
   - Al terminar, el estudio se cierra para siempre [Hecho].
8. **Feedback:**
   - la casa se ilumina y la cámara le da una vuelta de 360° [Hecho];
   - una escena muestra cómo sube el agua al estudio [Hecho];
   - el estudio «explota» y se cierra con tentáculos negros [Hecho].
9. **Dificultad: alta por la red, no por los puzles.** Las reseñas dicen que los puzles sueltos son
   los más fáciles de la saga [Hecho]. La dificultad está en el cruce de habitaciones y en recordar
   qué recurso va adónde.
10. **Recompensa:** ver cambiar la casa por fuera con cada pieza (progreso físico y visible) y cerrar
    una habitación con un final dramático.

### 4.6 El resto de capítulos, en breve

| Capítulo | Objetivo | Novedad | Cómo acaba |
|---|---|---|---|
| The Room · 3 | Caja de luz y globo | Dirigir un haz con cristal y espejos; un relé contrarreloj; un globo de 4 piezas como contador | Una palanca expande la parte de arriba |
| The Room · 4 | El planetario | Una consola dice qué figura formar; un código que se lee desde varias caras | Una puerta de luz |
| The Room · Epílogo | Sala de engranajes | Piano de memoria; llave de tres posiciones; laberinto giratorio | Un portal; el ocular se rompe |
| Two · Cripta | Tutorial de sala | Dos mesas; ocular que se repara; lámpara a oscuras | El ritual de las varillas |
| Two · Templo | Salir | Ballesta que se monta y apunta; espejo que alterna la caja entre madera y oro | El ritual |
| Two · Sesión de espiritismo | Salir | Cámara de fotos como herramienta; bucle máquina de escribir ↔ tarot | El cadáver y el Null |
| Two · Travesía | Llegar a tierra | Un interludio de una sola acción | El laboratorio |
| Two · Laboratorio | Salir | Láseres apuntados desde cada espejo; un cargador que falla adrede; el ocular mejorado | El final |
| Three · Proposición | Llegar a la mansión | Superzoom; la fuente del centro; la máquina de puertas | El portal al faro |
| Three · Torre del reloj | La medianoche | Varias plantas; ritmo y destreza; un cuervo que actúa | La campana grande |
| Three · Taller | Fabricar llaves | Forjar con un molde ajustable y volver a fundir | La pirámide 4 |
| Three · Observatorio | Los planetas | Una miniatura de una sala real: lo que se rompe dentro se rompe fuera | La pirámide 5 |
| Old Sins · Curiosidades | El artefacto | Una visión del pasado cambia la sala; una radio que se oye desde otra sala | La lámpara del vestíbulo cambia de sitio |
| Old Sins · Jardín | El artefacto | Dibujos que dicen dónde está algo en otra sala | El pozo |
| Old Sins · Galería japonesa | El artefacto | Alternar con y sin ocular para manejar dos capas | La columna |
| Old Sins · Taller de pintura | El artefacto | Trazar símbolos con el dedo; girar la casa para copiar un cuadro | El cuadro se quema |

---

## 5. Mapas de dependencias y papel de cada elemento

### 5.1 Los patrones que se repiten [Deducción]

1. **Cadena con desvíos cortos.** A → B → C, y a veces dos tareas en paralelo que se juntan.
   Ejemplo: The Room, capítulo 1. Sirve para enseñar.
2. **Árbol que converge.** Varios objetivos intermedios bajo una cerradura final.
   - Ejemplo: los tres sellos del capítulo 2.
   - Da elección (hay más de un hilo abierto) y una meta clara (los sellos que faltan).
3. **Puestos de una sala.** La cadena se reparte por el espacio.
   - Ejemplo: el barco.
   - El reto pasa a ser «dónde va esto».
4. **Ramas largas paralelas.** Dos hilos de muchos pasos que se encuentran al final.
   - Ejemplo: el faro.
   - Si uno se atasca, puede avanzar en el otro.
5. **Red entre espacios.** Recursos que viajan.
   - Ejemplo: el agua, el fuego y el vapor de Old Sins.
   - El reto es la causalidad a distancia.
6. **Ritual final.** El mismo tipo de puzle cierra cada nivel.
   - Ejemplos: las varillas de Two; la máquina de puertas de Three.
   - Da un respiro de dominio y marca el final.

### 5.2 Papeles de los elementos (con ejemplos)

| Papel | Qué es | Ejemplos |
|---|---|---|
| Bloqueador | Lo que impide avanzar | La puerta de la caja fuerte (1.6), cada sello (2.7, 2.12, 2.18), la niebla del mapa (S.6) |
| Llave | Lo que quita un bloqueador | Llaves físicas, el disco del sello 2, la gema en el cuenco |
| Pista | La información que dice cómo usar la llave | El acertijo FIRE, la foto «REV. 6:05», los rumbos, «PYRE» |
| Herramienta | Un objeto que se usa varias veces | La llave inglesa, el destornillador (vuelve tras cada tornillo), el ocular, la llave configurable |
| Mecanismo | Lo que transforma una acción en un cambio | Dial de caja fuerte, zoótropo, tren de engranajes, forja |
| Recompensa | Lo que se recibe | Objetos, información, un espacio nuevo, una escena |
| Objetivo intermedio | Lo que marca el progreso | Los sellos, las piezas del globo, las campanas, las pirámides |
| Objetivo final | Lo que cierra el nivel | La caja interior, la puerta de luz, el artefacto |

### 5.3 Mapa del capítulo 2 de The Room, por papeles

```
PISTAS:   huellas(ocular)   cifras(perspectiva)   pata brillante   foto 6:05   cuatro símbolos
            │                    │                    │              │              │
LLAVES:   libro ──► llave de cuerda   interruptor     mecha+óptica   gema          llave en cruz
            └─────────────┬──────────────┘                │            │              │
MECANISMO:            ZOÓTROPO ──► palabra TRIAL           │          RELOJ        estrella, dial
                          │                               │            │              │
BLOQUEADOR:        SELLO 1 (TRIAL) ─────────────────► SELLO 2 ────► SELLO 3 (6:05)
                                                                      │
OBJETIVO FINAL:                                            la caja siguiente
```

---

## 6. Taxonomía de puzles

| Categoría | Qué pide | Ejemplos | Notas |
|---|---|---|---|
| **Código** | Encontrar letras o números y marcarlos | TRIAL, SIGIL, SESWN, ROSE, 25BF, KHAN, 1795 | El más repetido. Funciona cuando el código está escondido de forma ingeniosa, no cuando es «otro código» |
| **Revelado oculto** | Ver lo que no se ve a simple vista | Tinta invisible, huellas, agujas del reloj, rayo invisible | Es el corazón del ocular |
| **Perspectiva (anamorfosis)** | Mover la cámara hasta que algo encaje | Cifras del cubo (2.3), símbolo hexagonal, varillas, arco del templo | Convierte la cámara en herramienta |
| **Símbolos repartidos** | Encontrar símbolos por el objeto y reproducirlos | Cuatro símbolos (2.8), árbol de blasones (Three 1.7) | Premia la memoria espacial |
| **Llave configurable** | Ajustar una llave o un molde a la cerradura | Extremo giratorio (1.4), tres brazos (D.2), molde de la forja | La cerradura dibuja la solución |
| **Objeto-contenedor** | Un puzle de bolsillo en el inventario | Libro (2.2), tubo (2.16), orbe (E.3), medallón (C.5), bellota | Da ritmo entre puzles grandes |
| **Montaje** | Juntar piezas en una máquina | Zoótropo, tren de engranajes, ballesta, cargador, tren de juguete | La máquina terminada recompensa en sí misma |
| **Secuencia mecánica** | Un orden de giros o pulsaciones | Dial de caja fuerte (2.11), KHAN alternando sentido | La pista suele ser física (topes, clics) |
| **Luz y trayectorias** | Llevar un haz o una bola por un camino | Cristal y reflectores (3.7), espejos (3.10), láseres del laboratorio | Visible y satisfactorio: el haz «llega» |
| **Laberinto y recorrido** | Mover algo por un camino con reglas | Bola en el alambre (3.2), laberintos giratorios (E.9), persecución (T.6) | A veces se siente de relleno |
| **Tiempo y destreza** | Actuar a tiempo | Relé contrarreloj (3.9), bailarina (Three 3.10), osciloscopio | Arriesgado en el móvil; se usa poco |
| **Memoria y sonido** | Repetir o reconocer | Piano tipo Simón (E.6), campanas en orden (E5), radio | Los sonidos como pista se usan poco |
| **Escala (miniatura)** | Entrar en lo pequeño | Cerradura por dentro, maquetas, recursión del maniquí | La mayor novedad de Three |
| **Causalidad a distancia** | Lo que haces aquí cambia allí | Vapor y agua entre habitaciones; la miniatura que rompe la sala real | La mayor novedad de Old Sins |
| **Transformación del espacio** | El lugar cambia de estado | Espejo que alterna madera y oro (T.9); la sala que sube; tentáculos que cierran una habitación | Produce asombro |
| **Acertijo verbal** | Interpretar un texto | FIRE (1.3), los cilindros-adivinanza (Three 1.3) | Corto y claro: la respuesta está en el objeto |
| **Regla conocida** | Reutilizar una regla del mundo real | El caballo de ajedrez (Three 3.9), la cadena alimentaria (M4), las fases de la luna | Rápido de entender si la regla es universal |
| **Copia o espejo** | Reproducir lo que se ve | Copiar el panel vecino (E2), las máscaras, el cuadro | Bueno para enseñar un mecanismo |
| **Dos manos** | Dos acciones a la vez | Cajón de dos manos (Three 2.1), botones por parejas (V5) | Muy táctil; cuidado con la accesibilidad |
| **Inclinación del dispositivo** | Mover el teléfono | Bolas (2.9), correderas (4.1) | Se rehízo en PC [Hecho]: no es portátil |

**Categorías que aparecen al analizar** [Deducción]:
- **Puzle-indicador:** una consola o maqueta dice qué hay que formar (la daga del planetario, 4.3).
  El puzle explica su propio objetivo.
- **Estado compartido:** el resultado depende de la posición final de varias piezas, como los
  cajones-combinación (D.3) o los cerrojos «comecocos» (E7).
- **Ventana:** el mecanismo está dentro y solo se ve por una abertura (S.5).
- **Herramienta que falla adrede:** el cargador se rompe y hay que repararlo (L.7). Rompe la
  expectativa.
- **Puzle de cámara:** mirar desde un ángulo concreto, a través de una ventana o desde el punto de
  vista de un espejo (L.4).
- **Bucle de información:** palabra → mensaje → cartas → palabra (D.7). El resultado de un puzle es
  la entrada del siguiente.

---

## 7. Curva de dificultad

### 7.1 Pasos por capítulo [Hecho; cuenta de las guías, orientativa]

| Juego | Pasos por capítulo |
|---|---|
| The Room | 6 → 18 → 11 → 6 → 9 (epílogo) |
| The Room Three | 17 → 42 → 38 → 44 → 46 → 11 (final) |
| Old Sins | 12 → 61 → 25 → 12 → 14 → 21 → 12 → 9 → 11 |

### 7.2 Qué sube con la dificultad [Deducción]

- **Distancia entre pista y cerradura:**
  - en el tutorial, la pista está al lado;
  - luego, en otra cara;
  - luego, en otro puesto;
  - luego, en otra habitación.
- **Hilos abiertos a la vez:**
  - The Room, casi siempre uno o dos;
  - Two, varios puestos;
  - Old Sins, hasta tres habitaciones.
- **Capas:** primero se ve todo; luego hace falta el ocular; luego, el ocular y un ángulo; luego,
  alternar con y sin ocular (la galería japonesa).
- **Memoria:** qué símbolo vi, en qué puesto va cada objeto, qué recurso llega adónde.
- **Reglas sin explicar:** la máquina de escribir de Three (2.3) hay que descubrirla probando.

Lo que **no** sube mucho: la precisión de los dedos y el tiempo. Los puzles de destreza son pocos y
las reseñas los critican cuando aparecen.

### 7.3 Picos y valles [Deducción]

- The Room tiene el pico en el capítulo 2; el 4 es corto y espectacular. Es una curva de «gran
  nudo y final brillante».
- Old Sins pone el pico al principio (el estudio, con 61 pasos y tres habitaciones abiertas) y luego
  baja. Las reseñas lo notan: los puzles sueltos son fáciles y la dificultad está en la red.
- Three crece casi siempre y termina con un final corto de rituales.

### 7.4 Enseñar → practicar → combinar → dominar

**El ocular (The Room):**
- Enseñar (1.6): la lente se consigue y se usa en el paso siguiente, en un puzle sencillo.
- Practicar (2.1): unas huellas.
- Combinar (2.3 y 2.5): el ocular y la perspectiva para leer cifras; el ocular y una máquina para
  leer una palabra.
- Dominar (4.6): recomponer un dibujo repartido en cuatro niveles girando la caja.

**La llave configurable:**
- 1.4: un extremo giratorio.
- 2.12: dos piezas y el contorno dibujado por el ocular.
- 3.10: seis paletones.
- E.5: tres posiciones, cada una abre algo distinto.

**El ritual de las varillas (Two):**
- Se aprende en la cripta.
- Se repite en cada sala con más dificultad.
- En el laboratorio son dos colores y dos correderas.

**La máquina de puertas (Three):**
1. Las mismas cuatro estaciones.
2. Luego, un panel más complejo.
3. Luego, un objetivo que se mueve.
4. Luego, sin los signos + y −.
5. Por último, un osciloscopio roto que obliga a bajar al estudio a por una pieza.

**El superzoom (Three):**
1. Se enseña dentro de una cerradura (1.5).
2. Luego, en miniaturas.
3. Luego, en una miniatura dentro de otra.
4. Por último, en una miniatura que rompe la sala real (5.12).

El principio: **cada mecánica aparece primero sola y fácil, y vuelve después en combinación o con
una vuelta de tuerca.** No se introduce una mecánica a la vez que se exige dominarla.

---

## 8. El tutorial: enseñar sin explicar

### 8.1 Los primeros minutos de The Room [Hecho, salvo deducción]

| Momento | Qué hace el jugador | Qué aprende |
|---|---|---|
| 1 | Desliza para girar la vista hasta la tapa | La cámara se mueve con un dedo |
| 2 | Doble toque al sobre; desliza para sacar la carta | Acercarse; los gestos imitan la acción |
| 3 | La llave pasa al inventario | Los objetos se guardan a la izquierda |
| 4 | La cámara viaja sola hasta el joyero | El juego enseña adónde mirar |
| 5 | Gira la tapa, arrastra la llave y la gira | Usar un objeto es llevarlo y girarlo |
| 6 | Aparece el ocular sin lente | Hay herramientas incompletas: una meta |
| 7 | Pellizca para alejarse | Volver a la vista general |
| 8 | Resuelve FIRE sin ayuda | El texto apunta a la caja |
| 9 | Ve un tramo rayado y lo desliza | El desgaste delata lo que se mueve |
| 10 | Usa la lente en el paso siguiente | El ocular revela una capa |

### 8.2 Técnicas [Deducción]

- **Un gesto nuevo por objeto nuevo.** Cada objeto introduce su gesto; no se explican todos al
  principio [Hecho, análisis de estudiantes].
- **La cámara guía.** Tras un logro, la cámara viaja al siguiente punto de interés: dice «mira
  aquí» sin texto.
- **Una herramienta rota como objetivo.** El ocular sin lente crea una meta antes de enseñar para
  qué sirve.
- **Reutilización inmediata.** La llave de 1.4 se vuelve a usar en 1.6: así el jugador aprende que
  los objetos pueden durar.
- **Avisos mínimos.** Solo al encontrar algo importante [Hecho].

### 8.3 Lo que falla, según las críticas

- Tras el tutorial, algunos no sabían por dónde empezar [Hecho, estudiantes].
- El juego da por hecho que se examinará la superficie de cerca, pero no lo enseña.
- Hay quien esperaba alejarse con doble toque en lugar de con pellizco.
- Las pistas llegan tarde.

---

## 9. Diseño de interacción

| Acción | Respuesta | Feedback | Consecuencia |
|---|---|---|---|
| Deslizar en el vacío | La cámara gira alrededor | Movimiento suave con inercia | Se ve otra cara |
| Doble toque en un punto | La cámara viaja a ese detalle en ~0,5 s [Vídeo] | Encuadre cerrado sobre el mecanismo | Se pueden tocar piezas pequeñas |
| Pellizcar hacia fuera | Vuelve al nivel anterior (detalle → caja → sala) [Hecho] | Transición suave hacia atrás | Orientación recuperada |
| Arrastrar una pieza en línea | Se desliza por su carril | Roce, tope y clic | Abre o desbloquea |
| Arrastrar en círculo | Gira un dial o una manivela | Clic en cada tope | Cambia un valor (hora, letra, código) |
| Tocar un botón o una placa | Se hunde | Clic | Activa algo |
| Tocar algo bloqueado | No se mueve | Un golpe metálico sordo y un texto corto («It won't budge») [Vídeo] | El jugador sabe que hace falta otra cosa |
| Tocar un objeto suelto | Va al inventario | Animación hacia el borde | Nuevo recurso |
| Tocar un objeto del inventario | Se ve a pantalla completa | Se puede girar | Se descubren partes ocultas |
| Manipular el objeto examinado | Se transforma | Animación y clic | Cambia de función (la llave se configura) |
| Arrastrar un objeto al mundo | Encaja o se rechaza | Encaje con sonido, o «doesn't fit like this» [Vídeo] | Desbloqueo |
| Ponerse el ocular | Capa revelada | Bordes oscuros, aberración de color y campo de visión más estrecho [Hecho] | Información oculta |
| Dos dedos a la vez | Dos piezas a la vez | Lo mismo que con uno | Puzles de coordinación |
| Mantener pulsado | Una carga o un sello | Brillo que crece | Abre el artefacto (Old Sins) |
| Trazar con el dedo | Dibuja un símbolo | Línea brillante | Quema una capa (Old Sins) |

[Deducción] La regla general: **el gesto imita la acción física y la respuesta se parece a la de un
objeto real.** Por eso apenas hace falta texto.

---

## 10. Feedback

- **Visual:**
  - piezas que se mueven con peso;
  - compartimentos que se abren y dejan ver su contenido;
  - destellos al completar un símbolo [Hecho];
  - luces que se encienden;
  - cambios de estado del espacio (la sala sube, los tentáculos cierran una habitación).
- **Cámara:** cuando la consecuencia está fuera de la vista, la cámara viaja a ella o suena desde
  allí [Hecho]. **La consecuencia siempre se ve.** Es quizá la regla de feedback más importante de la
  serie [Deducción].
- **Sonido:**
  - golpes, clics y engranajes;
  - el desbloqueo;
  - susurros en momentos de misterio;
  - un tono que sube cuanto más te acercas a la solución (el osciloscopio de Three) [Hecho].
- **Error:** el objeto **no se mueve**, suena seco y aparece un texto breve [Vídeo, Hecho]. No hay
  castigo. Es justo lo que pidió el usuario para Cuatro cajas.
- **Háptico:** una vibración leve en Android, según un análisis [Hecho; poco documentado].
- **Texto:** mínimo. Avisos de una línea cuando falta algo («Something is missing», «va en la casa»)
  [Hecho].

---

## 11. Cámara y presentación

### 11.1 Reglas que se observan

- **Vista general:** el objeto a media pantalla, con aire alrededor y fondo oscuro.
- **Puntos de acercamiento:** el doble toque lleva a encuadres definidos de antemano.
- **Jerarquía:** sala → objeto → detalle. El pellizco sube un nivel [Hecho, Old Sins].
- **Movimientos automáticos:**
  - al empezar un capítulo, un barrido que presenta el espacio [Vídeo];
  - tras un logro, el viaje hasta la consecuencia [Hecho].
- **Límites:** la cámara no atraviesa el objeto ni se mete en ángulos inútiles.
- **El ocular cierra el encuadre:** bordes oscuros, como diciendo «esto no es para usarlo siempre»
  [Hecho].

### 11.2 Cómo dirige la atención sin decir dónde mirar [Deducción, salvo cita]

1. **Luz:** solo lo importante está iluminado [Hecho].
2. **Brillo de los metales:** el latón refleja la luz al girar la cámara y señala diales y pestillos
   [Vídeo].
3. **Movimiento:** algo que se mueve o vibra atrae la vista.
4. **Sonido localizado:** un desbloqueo suena donde ocurre.
5. **Viaje de la cámara** tras cada logro.
6. **Siluetas:** el hueco tiene la forma de la pieza que falta.
7. **Desgaste:** rayas o brillo de uso delatan lo que se mueve (1.4).
8. **Color de excepción:** una pata «un poco más brillante que las demás» (2.4) [Hecho].
9. **Superficie irisada** = «usa el ocular»; **partículas flotando** = «entra aquí» [Hecho].
10. **Una consola o maqueta que muestra la meta** (la constelación de la daga).

---

## 12. Objetos: cómo dicen «úsame»

- **Vocabulario de materiales** [Deducción]:
  - **madera oscura mate**: estructura, no se mueve;
  - **latón y acero**: mecanismo, se mueve;
  - **cristal o irisado**: capa oculta;
  - **papel**: información.
- **Formas que piden un gesto:** asas (tirar), diales con muescas (girar), botones abombados
  (pulsar), ranuras con silueta (encajar).
- **Estado legible:** abierto o cerrado, encendido o apagado, encajado o vacío. Siempre se ve.
- **Papel de cada objeto:**
  - herramientas reutilizables (llave inglesa, destornillador, ocular);
  - llaves de un solo uso;
  - pistas (fotos, cartas);
  - contenedores (libro, tubo, bellota).
- **Riesgos de confusión** [Hecho, reseñas]:
  - notas con «red herrings» (pistas falsas) que no llevan a nada;
  - objetos para puestos lejanos («which table was it on?»);
  - en Old Sins, un inventario lleno de cosas «aparentemente aleatorias».

---

## 13. Mecanismos: descomposición

### 13.1 El zoótropo (The Room, 2.5)

```
Zoótropo
├── Entrada: mecha, rueda de chispa, óptica (desplegada en el inventario) y llave de cuerda
├── Estado inicial: apagado, sin piezas, trampilla cerrada
├── Acción del jugador: colocar cada pieza en su hueco; dar cuerda girando la llave
├── Movimiento: el tambor gira y la llama se enciende
├── Feedback: una película animada con susurros [Hecho]
├── Cambio de estado: la película muestra unas palabras, que solo el ocular deja leer
├── Condición de éxito: las piezas colocadas, la cuerda dada y el ocular puesto
└── Resultado: la palabra TRIAL (información) y una placa que se abre (acceso)
```

Está compuesto por otros mecanismos: tres huecos-ranura, una manivela de cuerda, una animación y la
capa del ocular.

### 13.2 El dial de caja fuerte (The Room, 2.11)

```
Dial
├── Entrada: el anillo de latón, que se encaja en el dial
├── Estado inicial: seis pestillos cerrados
├── Acción: girar alternando el sentido
├── Movimiento: cada pestillo libre se recoge
├── Feedback: clics; el pestillo libre deja de contar [Hecho]
├── Cambio de estado: pestillos libres / cerrados
├── Condición: todos libres
└── Resultado: la minicaja fuerte se abre y da la llave de dos niveles
```

### 13.3 La forja (Three, 4.8)

```
Forja
├── Entrada: yesca, pedernal y barra de metal
├── Estado inicial: fragua apagada, molde con tres diales
├── Acción: encender; copiar el perfil de la cerradura en los diales; bombear el fuelle
├── Movimiento: el fuego, el indicador que sube al rojo, la llave que cae al agua
├── Feedback: la cámara sube y enseña el fuego [Hecho]
├── Cambio de estado: barra → llave con el perfil elegido
├── Condición: el perfil coincide con la cerradura
└── Resultado: una llave; si sale mal, se vuelve a fundir (el error no castiga)
```

[Deducción] **Los mecanismos grandes son combinaciones de pocos mecanismos simples**: ranuras,
diales, deslizadores, manivelas, botones y capas reveladas. Eso es lo que permite fabricar mucho
contenido con un equipo pequeño.

---

## 14. Psicología del puzle (hipótesis de diseño)

Esto no es ciencia: es lo que el diseño parece buscar en cada momento.

| Momento | Lo que probablemente piensa el jugador | Lo que hace el juego |
|---|---|---|
| Llegada | «¿Qué es esto? Quiero tocarlo» | Un objeto bello, iluminado, en silencio |
| Exploración | «A ver qué se mueve» | Responde a casi todo; lo que no se mueve, suena seco |
| Primer descubrimiento | «¡Algo ha cedido!» | Sonido, animación y algo nuevo a la vista |
| Confusión | «No sé qué más hacer» | Detalles que destacan (luz, desgaste, siluetas) |
| Hipótesis | «Este símbolo lo vi en la pata…» | Las pistas repetidas permiten conectar |
| Experimentación | «Pruebo a girar esto» | El error no castiga: se puede probar mil veces |
| Frustración | «Llevo diez minutos atascado» | Una pista vaga que se puede pedir |
| Comprensión | «¡Ah, era eso!» | La regla se ve de golpe (el ajá) |
| Solución | «Lo hice yo» | El mecanismo se abre con peso y sonido |
| Recompensa | «Hay más dentro» | Una capa nueva: la curiosidad empieza otra vez |

[Hipótesis] La sensación de «lo hice yo» se protege con pistas vagas al principio: una pista que
dice la solución quita el mérito.

---

## 15. Momentos «¡ajá!»

Cada uno, con la misma estructura: qué tenía el jugador → qué no entendía → qué descubre → qué
conexión hace → qué acción → qué recompensa.

1. **El acertijo que está en la caja** (The Room, 1.3).
   - Tenía: un acertijo en una nota.
   - No entendía: qué hacer con la respuesta.
   - Descubre: la palabra FIRE en una pata.
   - Conexión: la respuesta es una palabra escrita.
   - Acción: pulsar la placa.
   - Recompensa: una llave.
2. **El desgaste delata** (1.4).
   - Tenía: una tira de remaches.
   - No entendía: cuál se mueve.
   - Descubre: rayas junto a un tramo.
   - Conexión: el uso deja marcas.
   - Acción: deslizarlo.
   - Recompensa: una cerradura.
3. **Las cifras que solo existen desde un ángulo** (2.3).
   - Tenía: fragmentos brillantes.
   - No entendía: qué número formaban.
   - Descubre: al mover la cámara, los fragmentos encajan.
   - Conexión: la cámara es una herramienta.
   - Acción: leer las cuatro cifras.
   - Recompensa: el código.
4. **La foto con una hora al dorso** (2.16 → 2.18).
   - Tenía: una foto.
   - No entendía: para qué.
   - Descubre: «REV. 6:05» y un reloj sin agujas visibles.
   - Conexión: la foto es la hora del reloj.
   - Acción: ponerla con el ocular.
   - Recompensa: el sello 3.
5. **El espejo que cambia la caja** (Two, T.9).
   - Tenía: un espejo roto.
   - No entendía: qué hacía.
   - Descubre: la caja tiene una versión de oro.
   - Conexión: hay dos estados del mismo objeto.
   - Acción: alternarlos.
   - Recompensa: dos espacios con un solo objeto.
6. **El ritual reconocido** (Two, cada sala).
   - Tenía: la experiencia de la cripta.
   - Descubre: «esto ya lo sé hacer».
   - Conexión: el mundo tiene reglas estables.
   - Recompensa: sentirse experto.
7. **El caballo de ajedrez** (Three, 3.9).
   - Tenía: un tablero con torres.
   - No entendía: cómo capturarlas.
   - Conexión: el caballo salta en L.
   - Recompensa: rapidez, porque la regla ya la sabía.
8. **Lo de dentro rompe lo de fuera** (Three, 5.12).
   - Tenía: una miniatura de la sala.
   - Descubre: lo que rompe dentro se rompe fuera.
   - Conexión: la escala es causal.
   - Recompensa: asombro y un camino nuevo.
9. **La radio de otra habitación** (Old Sins, C5-C6).
   - Tenía: una radio con ruido.
   - Descubre: la voz se aclara al ajustar el corazón en otra sala.
   - Conexión: las salas están conectadas.
   - Recompensa: coordenadas.
10. **Los dibujos-mapa** (Old Sins, J4).
    - Tenía: un huevo.
    - Descubre: un dibujo que muestra un estante de otra sala.
    - Conexión: los dibujos son mapas.
    - Recompensa: el siguiente huevo.

**El principio común** [Deducción]: el ajá aparece cuando el jugador **cambia de modelo mental**:
- lo escrito es un objeto;
- la cámara es una herramienta;
- el tiempo es una llave;
- el objeto tiene dos estados;
- la escala es causal;
- el sonido viaja.

Para crear ajás propios no hay que copiar el contenido: hay que encontrar **otros cambios de modelo
mental** que encajen con nuestras cajas. Ejemplos en `BIBLIA_DISENO.md`, §7.2 (la sorpresa de cada
caja) y anexo C.

---

## 16. Pistas, interfaz, sonido y arte en la referencia

- **Pistas:**
  - The Room: un icono «?» que aparece cuando el juego decide que estás atascado; las pistas son
    vagas y nunca dan la solución [Hecho].
  - Two: las pistas se desbloquean con el tiempo, de muy vagas a explícitas, y se pueden desactivar
    [Hecho].
  - Old Sins: escalan hasta decir qué hacer.
  - En el posjuego de Three no hay pistas [Hecho].
  - Los tiempos exactos no constan.
- **Interfaz:**
  - inventario en columna a la izquierda;
  - ocular a la derecha;
  - menú y pistas arriba [Hecho, Vídeo];
  - examinar a pantalla completa;
  - usar arrastrando el objeto al mundo.
  - Two no tiene registro para releer las notas, y la crítica lo señala [Hecho].
- **Sonido:** ambientes graves, mecanismos con cuerpo, susurros y silencios. Cada desbloqueo se oye
  aunque esté lejos [Hecho, reseñas].
- **Arte:** madera oscura, latón, cuero y papel envejecido; sombras profundas y una luz cálida; un
  elemento sobrenatural irisado. Los materiales cuentan qué se mueve.
- **Producción** [Hecho, `PLAN.md`]: The Room lo hicieron 2 personas fijas en 6-8 meses. Los
  sistemas (ocular, rituales, máquina de puertas) se reutilizan y crecen de una entrega a otra.

## 17. Lo que no funciona tan bien (críticas recogidas)

- Pistas demasiado vagas o tardías en el primer juego.
- Notas sin registro para releerlas, y pistas falsas en ellas.
- «¿En qué mesa iba esto?» cuando hay muchos puestos.
- Repetición: el proyector del final de Three; puzles «de relleno» en Old Sins.
- El laberinto en primera persona de Three, que a TouchArcade le pareció inútil.
- Gestos de inclinar el dispositivo que no funcionan en PC (se rehicieron).
- Salir sin querer de una habitación al pellizcar (Old Sins, God is a Geek).

## 18. Principios extraídos (para la biblia)

1. Un objeto denso, bien iluminado, en un entorno que no distrae.
2. Cada gesto imita la acción física; cada pieza responde como un objeto real.
3. El error no castiga: no se mueve, suena seco y, como mucho, una línea de texto.
4. La consecuencia de cada acción siempre se ve (la cámara viaja o el sonido la sitúa).
5. Capas: siempre hay algo más adentro.
6. La pista está en el mundo y, a ser posible, en el propio objeto.
7. Una mecánica nueva se presenta sola y fácil; luego se combina; luego se retuerce.
8. Rituales que vuelven y crecen: dan dominio.
9. Los materiales y la luz dicen qué se puede tocar.
10. Un hilo de misterio que tira más allá del puzle.
11. Cada nivel añade como mucho una idea estructural nueva.
12. La dificultad sube por la distancia entre pista y cerradura, las capas, los hilos abiertos y la
    memoria; no por la precisión de los dedos.
13. Los ajás nacen de cambiar el modelo mental, no de esconder más.
14. Las pistas escalan con el tiempo y respetan el mérito del jugador.
15. Los objetos del inventario también son puzles, pequeños y de bolsillo.
16. Los mecanismos grandes se construyen con piezas simples reutilizables.

---

## 19. Los elementos clave, en el formato del consejo

Cada elemento con los siete campos que pidió el usuario. El último campo enlaza con la parte propia
(`BIBLIA_DISENO.md`).

### 19.1 El ocular (la lente)
- **Elemento:** una lente que se pone delante de la vista.
- **Qué hace:** muestra lo que no se ve a simple vista: tinta invisible, huellas, cifras, rayos.
- **Cómo funciona:**
  - se consigue roto en el tutorial y se completa al poco (1.6);
  - al ponérselo, el encuadre se cierra con bordes oscuros [Hecho].
- **Por qué funciona:**
  - multiplica la información de cada objeto sin añadir objetos;
  - el jugador vuelve a mirar lo ya visto: «¿y con la lente?».
- **Principio:** una herramienta que revela una capa oculta del mundo.
- **Qué podemos aprender:** una sola herramienta bien enseñada vale para todo el juego.
- **Cómo aplicarlo de forma original:** **sin lente.** Nuestra capa oculta sale de la regla de cada
  línea:
  - lo que mira el ojo;
  - lo que pasa a cierta hora;
  - lo que alumbra o tapa la luz;
  - lo que se ve desde un sitio.

  Ver `BIBLIA_DISENO.md` §3.2 y el anexo B.

### 19.2 El doble toque hacia un detalle
- **Elemento:** el acercamiento a puntos fijados de antemano.
- **Qué hace:** lleva la cámara a un encuadre cerrado sobre un mecanismo.
- **Cómo funciona:** con un doble toque, la cámara viaja unos 0,5 s hasta ese punto [Vídeo]; con un
  pellizco hacia fuera, se vuelve atrás.
- **Por qué funciona:**
  - en el móvil, las piezas pequeñas no se pueden tocar desde lejos;
  - el viaje mantiene la orientación.
- **Principio:** una jerarquía de vistas (sala → objeto → detalle) con transiciones suaves.
- **Qué podemos aprender:** la cámara es parte de la interfaz, no un adorno.
- **Cómo aplicarlo de forma original:**
  - ya lo hicimos a nuestra manera: zonas por caja, viaje en arco con aceleración suave, pellizco
    hacia el dedo y botón de centrar [Hecho, 0.2];
  - ver `BIBLIA_DISENO.md` §10.

### 19.3 «No se mueve»
- **Elemento:** la respuesta a una acción que aún no es posible.
- **Qué hace:** la pieza no se mueve, suena seca y, a veces, sale un texto breve.
- **Cómo funciona:** golpe sordo y una línea como «It won't budge» [Vídeo].
- **Por qué funciona:**
  - el jugador sabe que esa pieza importa y que le falta algo;
  - no hay castigo, así que se atreve a probar.
- **Principio:** el error informa y no castiga.
- **Qué podemos aprender:** probar tiene que salir gratis.
- **Cómo aplicarlo de forma original:**
  - nuestro destello cálido, la vibración corta y, en la caja viva, el ojo que se entorna y se
    enfada [Hecho, 0.2];
  - el usuario lo pidió así.

### 19.4 La caja dentro de la caja
- **Elemento:** al abrir la última cerradura aparece otra caja, más pequeña y compleja.
- **Qué hace:** convierte el final de un nivel en el principio del siguiente.
- **Cómo funciona:** el epílogo de cada capítulo de The Room es una caja interior [Hecho].
- **Por qué funciona:** la recompensa es la promesa de más: «dentro hay otra».
- **Principio:** capas; la recompensa abre curiosidad nueva.
- **Qué podemos aprender:** cada final debe dejar una pregunta.
- **Cómo aplicarlo de forma original:**
  - cada caja deja un objeto-recuerdo que se usa en la caja 4;
  - y una nota que abre la caja siguiente del gabinete.

  No anidamos cajas. Ver `BIBLIA_DISENO.md` §2.3 y §16.

### 19.5 La pista escrita en el propio objeto
- **Elemento:** un acertijo cuya respuesta está grabada en la caja (FIRE en una pata, 1.3).
- **Qué hace:** obliga a mirar el objeto entero.
- **Cómo funciona:** la nota da una adivinanza; la respuesta es una palabra que ya estaba a la vista.
- **Por qué funciona:** el «¡ah, estaba aquí!» premia la observación, no el saber de fuera.
- **Principio:** la información está en el mundo del juego.
- **Qué podemos aprender:** el jugador nunca debe necesitar buscar fuera.
- **Cómo aplicarlo de forma original:**
  - regla 8 de la biblia;
  - en la caja viva 2, el dibujo de la tapa es la pista del mosaico: no es una palabra, es una
    imagen que se copia.

### 19.6 El desgaste que delata
- **Elemento:** rayas junto al tramo de una tira que se puede deslizar (1.4).
- **Qué hace:** señala qué se mueve sin decirlo.
- **Cómo funciona:** el uso deja marcas; el jugador las nota y prueba.
- **Por qué funciona:** usa una regla del mundo real (lo que se usa, se gasta).
- **Principio:** el arte da pistas de interacción.
- **Qué podemos aprender:** el desgaste es lenguaje.
- **Cómo aplicarlo de forma original:**
  - «desgaste honesto»: solo donde una mano tocaría;
  - el brillo de «recién libre» cuando una pieza se suelta;
  - ver `BIBLIA_DISENO.md` §14.2.

### 19.7 La llave configurable
- **Elemento:** una llave cuyo extremo se ajusta antes de usarla (1.4, 2.12, 3.10).
- **Qué hace:** convierte una llave en un pequeño puzle.
- **Cómo funciona:** el contorno de la cerradura dibuja la forma que hay que dar a la llave.
- **Por qué funciona:** rompe la expectativa de «llave = abrir» y vuelve con más complejidad.
- **Principio:** ninguna llave es solo una llave.
- **Qué podemos aprender:** los objetos de un solo uso aburren.
- **Cómo aplicarlo de forma original:**
  - el espejo de la caja viva 2 no abre: desvía una mirada;
  - la llave de dos paletones del relojero 3 se guarda para la caja 4;
  - ver `BIBLIA_DISENO.md` §7.3, regla 2.

### 19.8 El ritual que vuelve
- **Elemento:** el mismo tipo de puzle al final de cada sala (las varillas de Two) o de cada capítulo
  (la máquina de puertas de Three).
- **Qué hace:** cierra el nivel con algo conocido, cada vez más difícil.
- **Cómo funciona:** se aprende una vez y se repite con variaciones.
- **Por qué funciona:** reconocerlo da sensación de dominio.
- **Principio:** la repetición con variación crea maestría.
- **Qué podemos aprender:** un elemento estable entre niveles ayuda a sentirse experto.
- **Cómo aplicarlo de forma original:**
  - nuestro ritual es la regla de la línea, que crece en cuatro fases (presentar, ampliar, invertir,
    combinar);
  - no copiamos las varillas ni la máquina;
  - ver `BIBLIA_DISENO.md` §7.1.

### 19.9 La cámara que viaja a la consecuencia
- **Elemento:** tras un logro, la cámara va sola a lo que cambió.
- **Qué hace:** enseña el resultado aunque esté en otra cara o en otro puesto.
- **Cómo funciona:** viaje automático o un sonido desde el lugar [Hecho].
- **Por qué funciona:**
  - el jugador entiende la causa y el efecto;
  - además, sabe adónde ir después.
- **Principio:** la consecuencia siempre se ve.
- **Qué podemos aprender:** es quizá la regla de feedback más importante.
- **Cómo aplicarlo de forma original:** una función común, `mostrar_consecuencia(nodo)`, con viajes de
  menos de 0,8 s y un destello del color de la línea. Ver `BIBLIA_DISENO.md` §10.2.

### 19.10 El objeto del inventario que es un puzle
- **Elemento:** un libro, un tubo o un medallón que se manipula a pantalla completa (2.2, 2.16).
- **Qué hace:** da un respiro entre puzles grandes y esconde la siguiente pieza.
- **Cómo funciona:** al examinarlo se gira y se toca; una parte se abre o se transforma.
- **Por qué funciona:** el inventario deja de ser una lista y se vuelve otro espacio que explorar.
- **Principio:** puzles de bolsillo.
- **Qué podemos aprender:** examinar tiene que valer la pena alguna vez, pero no siempre.
- **Cómo aplicarlo de forma original:**
  - uno o dos por caja;
  - por ejemplo, el abanico (anexo C.10 de la biblia).

### 19.11 Las cifras que solo se leen desde un ángulo
- **Elemento:** fragmentos que forman un número solo desde un punto de vista (2.3).
- **Qué hace:** obliga a mover la cámara para leer.
- **Cómo funciona:** anamorfosis: piezas sueltas que se alinean desde un ángulo.
- **Por qué funciona:** convierte la cámara en herramienta; es un cambio de modelo mental.
- **Principio:** el punto de vista es información.
- **Qué podemos aprender:** el espacio puede esconder datos sin taparlos.
- **Cómo aplicarlo de forma original:**
  - las sombras proyectadas del farero: la silueta se forma con la luz del quinqué, no con la
    cámara;
  - ver anexo C.8 de la biblia.

### 19.12 La miniatura (el «superzoom»)
- **Elemento:** entrar en un objeto pequeño y encontrar un mundo dentro (The Room Three).
- **Qué hace:** cambia la escala del juego.
- **Cómo funciona:** un doble toque «encoge» al jugador dentro de la maqueta.
- **Por qué funciona:** asombro; un espacio enorme dentro de uno pequeño.
- **Principio:** la escala como capa.
- **Qué podemos aprender:** una sola idea estructural nueva por entrega basta para renovar.
- **Cómo aplicarlo de forma original:** **no se usa.** Es la expresión más reconocible de esa entrega
  (anexo B de la biblia). Nuestra idea estructural es la regla que crece por línea.

### 19.13 Las pistas que escalan
- **Elemento:** ayudas que van de vagas a explícitas.
- **Qué hace:** evita el abandono sin quitar todo el mérito.
- **Cómo funciona:** en Two se desbloquean con el tiempo y se pueden desactivar [Hecho]; en The
  Room llegaban tarde, según la crítica.
- **Por qué funciona:** cada jugador recibe la ayuda que necesita, cuando la pide.
- **Principio:** proteger el «lo hice yo».
- **Qué podemos aprender:** la última pista no debe resolver por el jugador.
- **Cómo aplicarlo de forma original:**
  - cuatro niveles, el último con el gesto dibujado que hace el propio jugador;
  - el botón late tras 3 minutos sin avanzar;
  - ver `BIBLIA_DISENO.md` §6 y la DECISIÓN 26.

### 19.14 La red entre habitaciones
- **Elemento:** recursos que viajan de una sala a otra (agua, fuego, vapor en Old Sins).
- **Qué hace:** pide pensar en causa y efecto a distancia.
- **Cómo funciona:** lo que haces en una habitación cambia otra; la casa de muñecas lo enseña desde
  fuera.
- **Por qué funciona:** el jugador construye un mapa mental del sistema.
- **Principio:** causa a distancia.
- **Qué podemos aprender:** la dificultad puede estar en la red y no en los puzles sueltos (a veces,
  demasiado).
- **Cómo aplicarlo de forma original:**
  - en pequeño: atrasar el reloj borra la carta del escritorio (anexo C.4 de la biblia);
  - sin casas de muñecas ni recursos que viajan.
