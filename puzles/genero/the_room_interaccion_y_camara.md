# The Room: interacción, cámara y tipos de puzle

Base de datos de la serie The Room (Fireproof Games) para diseñar **La caja viva**. Cubre The Room (2012), The Room
Two (2013), The Room Three (2015) y The Room: Old Sins (2018). Fecha: 05-10-2026.

**Archivos de esta entrega (en `puzles/genero/`):**
- `the_room_puzles.csv`: **265 puzles**, uno por fila (56 de The Room, 60 de Two, 87 de Three y 62 de Old Sins).
- `the_room_mecanicas.csv`: **70 mecánicas** agrupadas, de R-001 a R-070.
- Este documento: a) interacción y cámara por juego · b) cómo evoluciona la serie · c) todos los tipos de puzle ·
  d) los 10 principios más transferibles a La caja viva.

**Marcas** (las del contexto común):
- **[Hecho]**: lo dice una fuente. La sigla lleva a su enlace en la lista del final.
- **[Opinión]**: lo dice un crítico o un jugador, con su enlace.
- **[Interpretación]**: conclusión nuestra.
- **(vídeo)**: descripción automática (vidIQ) de una partida grabada. Se usa solo si no choca con las guías; si choca,
  manda la guía.

---

## 0. Método, límites y cómo leer las tablas

**De dónde sale** [Hecho]:
- La reconstrucción puzle a puzle ya estaba hecha, con fuentes, en `../referencia/the_room_1_y_2.md` y
  `../referencia/the_room_3_y_old_sins.md`. El análisis de diseño está en `../ANALISIS_THE_ROOM.md`, y el método
  de Fireproof, en `../referencia/como_se_hizo_the_room.md`.
- Esta vez se cubrieron dos huecos:
  - **Old Sins** (galería japonesa, taller de pintura, cocina, sala marítima, jardín y desván): con las guías de
    AppUnwrapper que guardó la investigación anterior (copias de archive.org). Por ejemplo, la galería japonesa
    pasa de tres líneas a una secuencia completa de gestos (OS-G1 a OS-G3) [Hecho, AU].
  - **El feedback** de algunos puzles de The Room y los sistemas de Old Sins (cámara, errores, inventario): con las
    descripciones automáticas de los vídeos de partida que el usuario envió el 02-10-2026 [Hecho, vídeo].
- Archive.org no se dejó abrir desde el contenedor el 05-10-2026, así que no se hizo más búsqueda web.

**Límites:**
- No se jugó: se trabajó con guías, reseñas y descripciones de vídeo.
- En **105 de los 265 puzles** ninguna fuente describe el feedback; la tabla dice «no consta». Las guías cuentan
  qué hacer, no qué se oye.
- Los tiempos de las pistas no constan en ninguna fuente [Hecho, anexos].

**Cómo leer `the_room_puzles.csv`:**
- **ID:** R1 = The Room · R2 = Two · R3 = Three · OS = Old Sins, más el código del anexo. Por ejemplo, R1-1.4 es el
  puzle 4 del capítulo 1 de The Room; R2-S.6, el puzle 6 del barco de Two.
  - Las letras a, b y c separan puzles que el anexo contaba juntos (R1-2.9a y R1-2.9b).
  - R3-F.E, R3-F.R y R3-F.L son los finales alternativos de Three; R3-CF1 a R3-CF9, su posjuego.
- **Columnas de hechos:** Interacción, Información que recibe, Reglas, Feedback y Recompensa.
  - Salen de los anexos. Entre paréntesis va la sigla de la fuente cuando solo la da una guía o cuando hay
    discrepancia.
  - «no consta» = ninguna fuente lo dice.
- **Columnas de interpretación:** Cámara (si la fuente no la describe, se pone la vista habitual de la serie), Qué
  debe descubrir, Variable que manipula, Qué lo hace difícil, Qué lo hace satisfactorio, Dificultad, Habilidad
  requerida y Cómo podría adaptarse.
  - **Dificultad:** 1 = tutorial · 2 = fácil · 3 = media · 4 = alta · 5 = muy alta. Ningún puzle de la serie llega
    a 5 en nuestra lectura: solo el posjuego y las reglas sin explicar llegan a 4.
- **Tipo:** una o dos categorías del contexto común. Se añadió LABERINTO, porque los recorridos se repiten mucho.
- **Cómo podría adaptarse:** empieza por A-H, como pide el contexto.
  - Ninguna propuesta usa lente u ocular, portales, sustancia irisada, miniaturas, ni rituales de varillas o
    máquinas de puertas.
  - Cuando una idea roza la referencia, lo dice: «riesgo medio».

**`the_room_mecanicas.csv`** agrupa los puzles en 70 mecánicas distintas. Cada fila cita los IDs de sus ejemplos.

---

## a) Interacción y cámara, juego a juego

**Los doce verbos** [Interpretación: definiciones para este documento]:

| Verbo | Qué cuenta aquí |
|---|---|
| Tocar | pulsar una pieza o un punto (toque simple; el doble toque es zoom) |
| Arrastrar | llevar un objeto del inventario al mundo, o mover una pieza suelta por la pantalla |
| Deslizar | mover una pieza por su carril: corredera, cajón, panel o tablilla |
| Rotar | dar vueltas a la vista o a un objeto entero (la caja, el objeto que se examina) |
| Mantener pulsado | dejar el dedo hasta que algo se carga o se abre |
| Girar | hacer girar una pieza sobre su eje con un gesto circular: llave, dial, manivela o anillo |
| Hacer zoom | acercarse (doble toque) o alejarse (pellizco) |
| Inspeccionar | examinar un objeto del inventario a pantalla completa y manipularlo |
| Combinar | juntar dos objetos en el inventario, o montar piezas en el mundo |
| Introducir objetos | poner un objeto en su hueco, soporte o ranura |
| Retirar objetos | sacar, coger, desatornillar o quitar piezas del mundo |
| Activar mecanismos | botones, interruptores, palancas, dar cuerda, disparar |

Los ejemplos de las tablas son IDs del CSV, donde está cada fuente. Lo que no aparece en ninguna guía se marca
«no consta».

### a.1 The Room (2012): una caja

[Hecho] Una caja sobre un pedestal, en una sala a oscuras; solo la caja está iluminada (MG). Cuatro capítulos y un
epílogo. Cada capítulo es una capa: al abrir la última cerradura aparece otra caja, más pequeña y más compleja (WP,
TA).

**Interacción**

| Verbo | Ejemplos | Notas |
|---|---|---|
| Tocar | pulsar la placa FIRE (R1-1.3); tocar huellas (R1-4.2); botones del relé (R1-3.9) | |
| Arrastrar | la llave a la cerradura (R1-1.2); la llave inglesa al perno (R1-1.5); tres espejos (R1-3.10); marcos de símbolos (R1-E.4) | [Hecho] Usar un objeto es arrastrarlo al mundo (DT) |
| Deslizar | sacar la carta del sobre (R1-1.1); el tramo rayado (R1-1.4); paneles que tapan cerraduras (R1-1.6); correderas con números (R1-2.11b); la tapa del tubo (R1-2.16) | |
| Rotar | la vista alrededor de la caja (R1-1.1); la caja deprisa en el relé (R1-3.9); el amuleto para leer sus caras (R1-4.5) | |
| Mantener pulsado | no consta | |
| Girar | la llave (R1-1.2); el extremo de la llave (R1-1.4); anillos (R1-1.6); el dial alternando el sentido (R1-2.11a); rodillos de letras (R1-2.7); manivelas (R1-2.13, R1-4.2) | [Hecho] «circling clockwise» para los diales (TA, sobre Two) |
| Hacer zoom | doble toque para acercar y pellizco para alejar (R1-1.1, R1-1.2) | [Hecho] MG. [Opinión] Un estudiante esperaba alejarse con doble toque (MoM) |
| Inspeccionar | libro de discos (R1-2.2); tubo (R1-2.16); cajita de la bola (R1-3.2); cajita que se vuelve llave (R1-3.8b); orbe (R1-E.3) | [Hecho] El primer objeto que se modifica en el inventario es la llave de R1-1.4 (anexo) |
| Combinar | en el inventario, no consta; en el mundo: zoótropo (R1-2.5), tren de engranajes (R1-2.15), globo de cuatro piezas (R1-3.8a a R1-3.11) | [Hecho] La lente se monta sola en el ocular (R1-1.5) |
| Introducir objetos | estrella en la aguja (R1-2.10); gema en la esfera (R1-2.18); cristal en la base (R1-3.7a); foto en el visor (R1-3.4); daga en la ranura (R1-4.3) | Huecos con la forma de la pieza |
| Retirar objetos | la carta (R1-1.1); cuatro tornillos (R1-2.14); la estrella de su puerta (R1-2.10) | [Hecho] El destornillador vuelve al inventario tras cada tornillo (MM) |
| Activar mecanismos | interruptor que saca el zoótropo (R1-2.3); dar cuerda (R1-2.5); dos botones a la vez (R1-3.7b); teclado de estrellas (R1-3.11); piano (R1-E.6) | |
| Otros gestos | inclinar el iPad (R1-2.9a, R1-4.1); dos dedos a la vez (R1-3.7b, R1-E.6) | [Hecho] En PC se rehicieron todos los puzles de inclinar (GH) |

**Cámara**

| Vista | Cómo funciona | Ejemplos |
|---|---|---|
| Vista general | cámara en órbita alrededor de la caja, sobre fondo oscuro [Hecho, MG]; cada capítulo empieza con un barrido que enseña lo nuevo [Hecho, vídeo] | R1-1.1 |
| Vista cercana | el doble toque viaja en unos 0,5 s a un encuadre cerrado sobre el mecanismo [Hecho, vídeo] | todas las cerraduras |
| Zoom | doble toque y pellizco [Hecho, MG]; en la versión del vídeo, también un botón de volver en el borde [Hecho, vídeo] | R1-1.2 |
| Rotación | deslizar en el vacío; la cámara tiene inercia [Hecho, Barry Meade en `como_se_hizo_the_room.md` §4] | R1-3.9, donde hay que girar a tiempo |
| Cambio de perspectiva | primer puzle de perspectiva: hay que mover la cámara para leer [Hecho, WP]; anamorfosis con el ocular | R1-2.3, R1-2.9b, R1-2.17, R1-3.8a, R1-4.3, R1-E.5b, R1-E.8b |
| Transición entre espacios | no hay otros espacios: la caja es el mundo. Al cerrar un capítulo, la caja interior sustituye a la anterior [Hecho, WP]. Dentro, la cámara viaja sola a la consecuencia | R1-1.2 (al joyero), R1-2.13 (se aleja), R1-2.15 (salta al reloj), R1-4.2 (a la consola) |
| Vistas internas | mirar a través de un objeto: un visor, un telescopio, una película | R1-3.4, R1-3.11, R1-2.5 |
| Vistas de mecanismos | lo invisible, con el ocular: un rayo, unas agujas, la cara trasera de un panel | R1-3.10, R1-2.18, R1-E.7 |
| El ocular | oscurece los bordes y estrecha la vista: «no es para usarlo siempre» [Hecho, Pratt] | de R1-1.6 en adelante |

### a.2 The Room Two (2013): una sala con puestos

[Hecho] Seis salas. Cada una tiene varios puestos y el jugador se mueve libremente entre ellos (WP) con pellizcos y
deslizamientos (PGr). Cada sala termina con el mismo ritual: con el ocular, unas varillas forman el símbolo del Null
y se abre la puerta (WP, IGN).

**Interacción**

| Verbo | Ejemplos | Notas |
|---|---|---|
| Tocar | casillas del mapa y el botón del barco (R2-S.6); el cristal antes del ritual (R2-C.7); una huella con el ocular (R2-C.2) | |
| Arrastrar | la lámpara: doble toque para agarrarla y moverla por la sala (R2-C.6); objetos al mundo, como el ancla (R2-S.9) | [Hecho] PG |
| Deslizar | tres piezas con un disco (R2-C.1); cañones (R2-S.2); media gema por su raíl (R2-S.3); la placa a tres topes (R2-T.4); bloques (R2-D.6); correderas (R2-L.5) | |
| Rotar | mirar hacia arriba (R2-T.1); pasar de puesto en puesto; el cronómetro que se da la vuelta (R2-S.10) | |
| Mantener pulsado | no consta | |
| Girar | dos anillos (R2-S.1); tres ruedas (R2-S.4); el timón (R2-S.6, R2-S.7); dos asas a la vez (R2-T.7); el dial de KHAN sin soltar el dedo (R2-D.10); la manivela del bote (R2-X.1); la rueda del cargador, deprisa (R2-L.3) | |
| Hacer zoom | como en el primero: el tutorial «basically follows that of the first game» [Hecho, TA] | |
| Inspeccionar | medallón (R2-C.5); cilindro del asa (R2-S.4); pesas que se transforman (R2-S.8); campana (R2-D.9) | |
| Combinar | la única combinación explícita en el inventario: lente y ocular (R2-C.2) [Hecho, MM]; en el mundo: la ballesta (R2-T.2 a R2-T.5), la cámara de fotos (R2-D.1, R2-D.5), la maqueta (R2-S.7, R2-S.9) y el cargador (R2-L.3, R2-L.7) | |
| Introducir objetos | el ancla (R2-S.9); la calavera en los pinchos (R2-T.17); muñeco y pedernal en el cuenco (R2-T.13); un objeto en el molde del cofre (R2-T.15); cartas en la caja de tarot (R2-D.7) | |
| Retirar objetos | la manivela del tablón (R2-X.1); la barra del techo (R2-T.1); la esfera atornillada (R2-L.1); el fusible (R2-L.7) | |
| Activar mecanismos | el gatillo de la ballesta (R2-T.5); ocho interruptores (R2-D.8); la máquina de escribir (R2-D.7); el flash (R2-D.5); el martillo con rueda y palanca (R2-T.8) | |
| Otros gestos | dos dedos para separar piezas (R2-C.5), girar dos asas (R2-T.7) o abrir una plaquita (R2-D.3) [Hecho, PG]; frotar arena y pedernal (R2-T.9, R2-T.13); apuntar (R2-T.5, R2-T.14) | [Hecho] La ficha de la App Store habla de jugar «with one digit», pero hay gestos de dos dedos (anexo de The Room 1 y 2, §4) |

**Cámara**

| Vista | Cómo funciona | Ejemplos |
|---|---|---|
| Vista general | la sala con sus puestos; la cripta enseña a moverse entre zonas, «new for the sequel» [Hecho, PG] | R2-C.1 a R2-C.7 |
| Vista cercana | doble toque, como en el primero | todas |
| Zoom | el pellizco vuelve del detalle al puesto y del puesto a la sala | |
| Rotación | dentro de cada puesto; a veces hay que mirar arriba | R2-T.1 |
| Cambio de perspectiva | el ritual de las varillas en cada sala; la puerta del castillo; el barco distorsionado | R2-C.7, R2-T.10, R2-S.12, R2-L.12 |
| Transición entre espacios | entre puestos, la cámara viaja sola donde pasa algo [Hecho, WK, MM]; otras veces solo suena un desbloqueo en otro rincón [Hecho, TA]; zonas que aparecen al iluminarse; dos versiones de la caja de la mesa (madera y oro) por un espejo; entre salas, una puerta; un interludio en un bote | R2-S.3, R2-T.13, R2-T.9 a R2-T.12, R2-X.1 |
| Vistas internas | la mira de la ballesta; el punto de vista de un espejo; un visor; una foto | R2-T.5, R2-T.14, R2-L.4, R2-L.6, R2-L.8, R2-D.5 |
| Vistas de mecanismos | ventanitas por las que, con el ocular, se ven cerraduras ocultas | R2-S.5 |

### a.3 The Room Three (2015): un centro con zonas y miniaturas

[Hecho] Cinco capítulos en una isla (Grey Holm). Un centro (la sala del altar, con una fuente de cinco ranuras) abre
una zona por capítulo; cada zona da una pirámide y, al cogerla, el jugador vuelve al centro a la fuerza (FW, SX, AU).
Hay cuatro finales y un posjuego sin pistas (ST, FW).

**Interacción**

| Verbo | Ejemplos | Notas |
|---|---|---|
| Tocar | una puerta para cruzarla: no hay movimiento libre [Hecho, TA]; la baldosa PYRE (R3-2.2); estrellas de la pared (R3-5.6) | |
| Arrastrar | la pirámide al triángulo blanco (R3-1.6); dos imanes (R3-2.7) | |
| Deslizar | piezas hasta unir un contorno (R3-1.1); barras del panel (R3-1.8a); el pergamino del descifrador (R3-5.7); el deslizador al ritmo del automático (R3-4.2) | |
| Rotar | la torre dentro del cuadro (R3-3.8); un globo siguiendo una luz (R3-5.15); un cubo con gemas (R3-4.13) | |
| Mantener pulsado | mantener dos puntos con dos dedos para ver símbolos (R3-2.5); sujetar un deslizador mientras se levanta el pestillo (R3-2.1) | |
| Girar | diales de las adivinanzas (R3-1.3); ruedas de la cerradura por parejas (R3-1.5); manivelas de las torres (R3-3.4, R3-3.6); diales del molde (R3-4.8); la rueda del barómetro (R3-2.14) | |
| Hacer zoom | doble toque y pellizco, más el **superzoom**: doble toque sobre partículas o cristales para entrar en algo pequeño [Hecho, AU, FW] | R3-1.5 es el primero |
| Inspeccionar | la caja ornamentada, primer objeto que se manipula en el inventario (R3-1.4); la esfera (R3-2.2); la bellota (R3-2.15); el estuche (R3-4.3); el disco que se vuelve engranaje (R3-4.10); el orbe (R3-5.10) | |
| Combinar | en el inventario, no consta [Hecho, anexo]; en el mundo: la lente que se acopla sola (R3-1.4), la gema en el cuenco (R3-2.16), las cinco pirámides en la llave del Artesano (R3-F.1) | |
| Introducir objetos | pirámides en la fuente (R3-1.6); piezas en la maqueta (R3-2.9, R3-2.10); la barra en el molde (R3-4.8); el libro en el atril (R3-5.1); el reloj de sol en el III (R3-5.10) | |
| Retirar objetos | la lente rota (R3-5.3); el componente del osciloscopio de otra sala (R3-5.2); los ladrillos (R3-CF9) | |
| Activar mecanismos | palanca, trípode y osciloscopio de la máquina de puertas (R3-1.8b); el fuelle de la forja (R3-4.8); campanas (R3-3.7, R3-3.12); el botón de las vías de la bailarina (R3-3.10) | |
| Otros gestos | trazar símbolos (R3-2.5, R3-5.15); dos manos (R3-2.1, R3-3.3, R3-5.17); balancear un péndulo (R3-CF2) | |

**Cámara**

| Vista | Cómo funciona | Ejemplos |
|---|---|---|
| Vista general | el centro, y en cada zona la vista se centra en la pieza principal de la sala [Hecho, TA] | R3-1.6, R3-2.1 |
| Vista cercana | doble toque | todas |
| Zoom | pellizco hacia atrás y superzoom hacia dentro | R3-1.5 |
| Rotación | alrededor de objetos grandes | la caja dorada (R3-3.3), el planetario (R3-5.11) |
| Cambio de perspectiva | un medio arco que casa con el arco roto de la pared; tres trozos de llave | R3-3.1, R3-CF8 |
| Transición entre espacios | tocar puertas [Hecho, TA]; la máquina de puertas abre un portal a la zona de cada capítulo [Hecho, AU, PG]; vuelta forzada al centro [Hecho, FW]; la sala sube un piso; un ascensor; bajar al estudio a por una pieza | R3-1.8a, R3-1.8b, R3-2.9, R3-5.1, R3-5.2 |
| Vistas internas | superzoom dentro de una cerradura, de miniaturas, de una miniatura dentro de otra y de una réplica de la sala; una mirilla; un telescopio; un laberinto en primera persona | R3-1.5, R3-2.4, R3-2.11, R3-5.12, R3-1.2, R3-5.7, R3-5.16 |
| Vistas de mecanismos | los pernos de la cerradura vistos por dentro; una casa en 3D que solo se ve con el ocular; alternar entre la llave por fuera y el pestillo por dentro | R3-1.5, R3-4.12, R3-CF9 |

### a.4 The Room: Old Sins (2018): una casa de muñecas

[Hecho] El centro es una casa de muñecas en un desván. Cada habitación es un nivel: se entra rompiendo un sello con
el ocular y se sale pellizcando (GZ, LW). Al coger el artefacto de una habitación, unos tentáculos la cierran para
siempre (LW, FW, WP). Hay hasta tres habitaciones abiertas a la vez, más el exterior (AU, WP).

**Interacción**

| Verbo | Ejemplos | Notas |
|---|---|---|
| Tocar | doble toque al sello para entrar (OS-T4); campanas en orden (OS-E5a); símbolos laterales que eligen el destino de una figura (OS-D2) | |
| Arrastrar | piezas del inventario a la casa (OS-E1); un trozo de mapa al globo (OS-E11a); los huevos a su sitio (OS-J4) | |
| Deslizar | piezas de la moneda hasta formar un molinete (OS-V2); deslizadores (OS-J3); las piezas amarillas del pasillo ilusorio (OS-T4); correderas del armario (OS-M2) | |
| Rotar | la vista alrededor de la casa (OS-C2); el taller entero, que gira en la casa (OS-A1, OS-A2) | |
| Mantener pulsado | el símbolo central del sello hasta que todos brillan (OS-V3); abrir cada artefacto (OS-E1) | [Hecho] AU, LW |
| Girar | el destornillador con un gesto circular (OS-T1) [Hecho, GZ]; la moneda de la verja (OS-T2); el ciervo 180° (OS-V3); la válvula (OS-K2); discos acoplados (OS-K3); la rueda de los dragones (OS-G1) | |
| Hacer zoom | entrar por el sello con doble toque y salir pellizcando; superzoom dentro de objetos (OS-E7, OS-E9, OS-C4, OS-J2) | [Opinión] Al principio salía sin querer de habitaciones en las que quería quedarse (GaG) |
| Inspeccionar | el ocular se abre en el inventario (OS-T3); la moneda que es molinete (OS-V2); cada artefacto (OS-E1); la botella (OS-E8); la plancha (OS-E11c); el colgante (OS-C8); la cápsula (OS-M4); la cigarra (OS-G1) | [Interpretación] Es el juego que más objetos transforma en el inventario |
| Combinar | en el inventario, no consta en las guías [Hecho, anexo]; la descripción del vídeo dice que se puede arrastrar un segundo objeto sobre el que se examina, sin dar ningún caso [Hecho, vídeo; dato dudoso]; en el mundo, la escultura que crece con base, tejado y aguja (OS-J2, OS-G2, OS-G3) | |
| Introducir objetos | piezas en la casa: farola, pozo, chimenea, veleta, tejado, escalera, aguja y vidriera [Hecho, AU, LW]; el ojo en el pulpo (OS-M3); la talla en la frente de una cara (OS-J5); los huevos (OS-J4) | |
| Retirar objetos | el artefacto, que cierra la habitación (OS-V5); el tapón de la botella (OS-E8); la olla del montaplatos (OS-C3) | |
| Activar mecanismos | botones por parejas (OS-V5); palancas y llaves del vapor (OS-E14); el arpón (OS-M5); la radio (OS-C5); el timón del submarino (OS-C7) | |
| Otros gestos | trazar con el dedo (OS-A3, OS-A4); frotar un cristal sucio (OS-C3); dos dedos (OS-T1, OS-V5, OS-M3, OS-G2); alternar con y sin ocular (OS-G1) | |

**Cámara**

| Vista | Cómo funciona | Ejemplos |
|---|---|---|
| Vista general | órbita de 360° alrededor de la casa, con la inclinación vertical limitada [Hecho, vídeo]; tras poner la farola, la cámara da una vuelta completa a la casa, que ya es una pista [Hecho, LW] | OS-E1 |
| Vista cercana | encuadres cerrados de cerraduras y objetos, con el fondo desenfocado [Hecho, vídeo] | todas |
| Zoom | doble toque para entrar en una habitación y pellizco para salir: el pellizco sube un nivel (detalle, habitación, casa) [Hecho, AU, GZ, vídeo] | OS-T4 |
| Rotación | la casa entera; dentro de cada habitación, la cámara se mueve entre sus puestos [Hecho, vídeo] | |
| Cambio de perspectiva | un pasillo de perspectiva forzada; un código por los ojos de buey; unos viales que se miran en ángulo | OS-T4, OS-E9, OS-E10 |
| Transición entre espacios | entrar a tamaño real en una habitación de la casa [Hecho, GZ, LW]; hasta tres habitaciones abiertas; expulsión al coger el artefacto o el colgante [Hecho, AU, LW]; objetos que viajan (montaplatos) y escenas que enseñan el agua subiendo | OS-C3, OS-C7, OS-E13 |
| Vistas internas | superzoom dentro de objetos; rayos X; visiones del pasado; cuadros que se trazan; una casa dentro de la casa | OS-E7, OS-C4, OS-E12, OS-C1, OS-A3, OS-D1 |
| Vistas de mecanismos | rayos X del modelo anatómico; dos cuadros-ventana para mover los dragones con el ocular y morder sin él | OS-E12, OS-G1 |

### a.5 Los verbos de un vistazo

| Verbo | The Room | Two | Three | Old Sins |
|---|---|---|---|---|
| Tocar | sí (R1-1.3) | sí (R2-S.6) | sí (R3-2.2) | sí (OS-E5a) |
| Arrastrar | sí (R1-1.2) | sí (R2-C.6) | sí (R3-1.6) | sí (OS-E1) |
| Deslizar | sí (R1-1.4) | sí (R2-S.3) | sí (R3-1.1) | sí (OS-V2) |
| Rotar | sí (R1-4.5) | sí (R2-T.1) | sí (R3-3.8) | sí (OS-A2) |
| Mantener pulsado | no consta | no consta | sí, con dos dedos (R3-2.5) | sí (OS-V3) |
| Girar | sí (R1-2.11a) | sí (R2-D.10) | sí (R3-1.5) | sí (OS-K3) |
| Hacer zoom | doble toque y pellizco | lo mismo, entre puestos | más el superzoom | más entrar en habitaciones |
| Inspeccionar | sí (R1-2.2) | sí (R2-C.5) | sí (R3-1.4) | sí, mucho (OS-V2) |
| Combinar en el inventario | no consta | una vez (R2-C.2) | no consta | no consta (el vídeo lo insinúa) |
| Combinar en el mundo | sí (R1-2.5) | sí (R2-T.2) | sí (R3-F.1) | sí (OS-J2) |
| Introducir objetos | sí (R1-2.10) | sí (R2-S.9) | sí (R3-1.6) | sí, en la casa (OS-E1) |
| Retirar objetos | sí (R1-2.14) | sí (R2-L.7) | sí (R3-5.2) | sí (OS-E8) |
| Activar mecanismos | sí (R1-3.7b) | sí (R2-D.8) | sí (R3-1.8b) | sí (OS-E14) |
| Inclinar el aparato | sí, solo en iPad (R1-2.9a) | no consta | no consta | no consta |
| Trazar con el dedo | no consta | no consta | sí (R3-2.5) | sí (OS-A3) |
| Frotar | no consta | sí (R2-T.9) | no consta | sí (OS-C3) |
| Dos dedos o dos manos | sí (R1-3.7b) | sí (R2-T.7) | sí (R3-2.1) | sí (OS-G2) |

[Interpretación] Los verbos básicos no cambian en seis años: tocar, deslizar, girar, arrastrar y examinar. Lo que
crece es dónde se usan y unos pocos gestos de lujo (trazar, mantener, dos manos). Inclinar el aparato no vuelve a
aparecer en las guías después del primero.

---

## b) Cómo evoluciona la serie: de la caja a la habitación, al mundo y a la casa de muñecas

### b.1 La tabla

| | The Room (2012) | Two (2013) | Three (2015) | Old Sins (2018) |
|---|---|---|---|---|
| **Unidad de nivel** | una caja con capas [Hecho, TA] | una sala con varios puestos [Hecho, WP] | un centro con una zona por capítulo [Hecho, FW] | una casa de muñecas: cada habitación es un nivel [Hecho, AU, LW] |
| **Cómo se pasa** | al abrir la última cerradura sale otra caja, más pequeña y compleja [Hecho, WP] | el Null de cada sala, con el ocular y las varillas, abre la puerta [Hecho, WP] | cada zona da una pirámide; con cinco, el final; cuatro finales [Hecho, ST, FW] | el artefacto de cada habitación se abre en una pieza que, puesta en la casa, abre otra [Hecho, AU, LW] |
| **Qué se ve a la vez** | las caras de un objeto | de 1 a 9 puestos según la sala [Hecho, anexo] | el centro o una zona; las zonas no se vuelven a visitar [Hecho, AU] | hasta tres habitaciones y el exterior [Hecho, AU, WP] |
| **Navegación** | orbitar la caja | pellizcos y deslizamientos entre puestos [Hecho, PGr] | tocar puertas, sin movimiento libre [Hecho, TA] | sello y doble toque para entrar, pellizco para salir [Hecho, GZ, LW] |
| **Cámara nueva** | órbita, doble toque y viaje a la consecuencia | viajes entre puestos y zonas que se encienden | superzoom: entrar en lo pequeño | entrar a tamaño real en un objeto pequeño (la casa) |
| **El ocular** | llega sin lente y se completa (R1-1.2, R1-1.5) | roto, se repara (R2-C.2) y luego se mejora (R2-L.10) | añade el superzoom (R3-1.4) | rompe sellos y localiza; menos para pistas [Opinión, AU, GaG] |
| **Gestos nuevos** | inclinar (iPad) y dos dedos | separar con dos dedos, frotar, apuntar | trazar, mantener con dos dedos, ritmo | mantener pulsado, alternar capas, trazar |
| **Forma de las dependencias** | cadena y árbol que converge (tres sellos) [Interpretación, análisis del proyecto] | cadena repartida por los puestos | dos ramas largas que convergen | red entre habitaciones con recursos que viajan |
| **Pasos por capítulo** | 6, 18, 11, 6 y 9 [Hecho, cuenta de las guías] | no hay cuenta comparable | 17, 42, 38, 44, 46 y 11 [Hecho, AU] | 12, 61, 25, 12, 14, 21, 12, 9 y 11 [Hecho, AU] |
| **Dónde está la dificultad** | en cada puzle y en la memoria espacial | en la navegación y el inventario: «which table was it on?» [Opinión, TA] | en encontrar «el hilo» entre muchas piezas [Opinión, TA] | en la red; los puzles sueltos son los más fáciles de la saga [Opinión, AU, GaG] |
| **Pistas** | un «?» cuando el juego cree que estás atascado; vagas [Hecho, MG, TA] | por tiempo, de muy vagas a explícitas; se pueden desactivar [Hecho, TA, IGN] | por niveles; ninguna en el posjuego [Hecho, AU, FW] | escalan hasta decir qué hacer [Hecho, TA]; sin el sonido de antes [Hecho, GaG] |
| **Duración** | no consta en las fuentes del proyecto | no consta | de 5 a 7 horas [Hecho, SX] | unas 5 horas [Hecho, AU] |

### b.2 Lo que cambia y lo que no [Interpretación]

1. **Los verbos se quedan; el espacio crece.** Tocar, deslizar, girar, arrastrar y examinar son los mismos en 2012
   y en 2018 (tabla a.5). Cada entrega añade una sola idea estructural: la caja anidada, los puestos, el centro con
   miniaturas, la casa con habitaciones conectadas. El análisis del proyecto ya lo había visto (§3).
2. **El espacio crece hacia fuera y luego hacia dentro.** The Room y Two crecen hacia fuera: de un objeto a una
   sala. Three y Old Sins crecen hacia dentro: se entra en lo pequeño. Old Sins junta las dos cosas: la casa de
   muñecas es a la vez un objeto que se gira (como la caja de 2012) y un mundo de habitaciones (como Two).
3. **La cámara pasa de herramienta de mirar a herramienta de moverse.** En 2012 el ángulo es la solución (R1-2.3).
   En Two, la cámara es el modo de ir de un puesto a otro. En Three y Old Sins, el zoom es la puerta a otra escala.
4. **El ocular pasa de pista a llave.** Al principio revela pistas (huellas, tinta, rayos). En Three sirve para
   entrar en lo pequeño, y en Old Sins rompe sellos y abre habitaciones. Las reseñas notan que se usa menos para
   encontrar pistas [Opinión, AU, GaG].
5. **La dificultad se traslada del puzle a la red.** The Room tiene su pico en un capítulo largo (18 pasos). Old
   Sins pone 61 pasos en el estudio, con tres habitaciones abiertas, y puzles sueltos más sencillos. Los críticos lo
   notan [Opinión, AU, GaG].
6. **Los rituales se vuelven estructura.** El símbolo hexagonal de 2012 vuelve una y otra vez (R1-2.9b, R1-2.17,
   R1-3.8a, R1-4.3). En Two es el cierre de cada sala, y en Three, la máquina de puertas de cada capítulo, cada vez
   más compleja (R3-1.8a, R3-3.2, R3-4.2, R3-5.2).
7. **La pérdida da peso.** Old Sins cierra para siempre cada habitación terminada [Hecho, LW, FW]: la progresión se
   ve y se siente, pero el jugador ya no puede volver a mirar.

### b.3 Lo que la crítica señaló (para no repetirlo)

- **Pistas tardías o demasiado vagas** en el primero [Opinión: un usuario de la App Store las llama «intentionally
  vague», recogido en el anexo; MoM].
- **Notas sin registro y pistas falsas** («sheer number of red herrings») en Two [Opinión, IGN].
- **«Which table was it on?»:** objetos que van a puestos lejanos [Opinión, TA].
- **El mismo final en cada sala** en Two («all of them end with roughly the same puzzle») [Opinión, IGN]; el
  proyector que se repite en los finales de Three [Opinión, AU].
- **El laberinto en primera persona** de Three, que a TouchArcade le pareció inútil [Opinión, TA].
- **Puzles «de relleno»** en Old Sins [Opinión, AU].
- **Salir sin querer** de una habitación al pellizcar [Opinión, GaG].
- **Inclinar el aparato** no funcionaba en PC y se rehízo [Hecho, GH].

### b.4 Qué significa para La caja viva [Interpretación]

- **Dónde está hoy La caja viva:** entre The Room y Two. Es un objeto central (la caja) en una sala que participa
  (la lámpara, el incensario, el shoji), con vistas fijas: sala, caja, costado, incensario, cara y caja en la mano.
- **Hacia dónde crecer:** hacia dentro del cuerpo de la caja (caja hija, cajita roja, ojo) y hacia su forma (el
  biombo del nivel 3). No hacia más habitaciones.
  - Una red de salas multiplicaría el arte pintado (cada vista nueva cuesta imágenes de Gemini) y traería los
    problemas de Two y Old Sins: perderse entre puestos y salir sin querer.
- **El centro ya existe:** la cara de la caja hace el papel del exterior de la casa de Old Sins o de la fuente de
  Three. Cada pieza (cuerno, ojo y voz) cambia el centro a la vista.
  - Diferencia que hay que cuidar: son partes del cuerpo de la caja, que vuelven a ella; no piezas de una maqueta.
- **Una idea estructural por nivel**, como la serie:
  - nivel 1: la sala participa;
  - nivel 2: el objeto en la mano;
  - nivel 3: la caja cambia de forma;
  - final: todo junto.

---

## c) Todos los tipos de puzle

Son 33 tipos. Cada uno lleva los ocho campos pedidos y de 1 a 3 ejemplos.
- **Los campos** son [Interpretación]: generalizan los casos.
- **Los ejemplos y su feedback** son [Hecho]: la fuente está en la fila del CSV.
- Entre corchetes, las categorías del contexto común que le corresponden.

### c.1 Código escondido y candado [CERRADURAS, INFORMACIÓN CRUZADA]
- **Información:** un candado o teclado (letras, números o direcciones) y, en otro sitio, el código escondido: en una película, una vela, una carta leída con el ocular o tras unos ojos de buey.
- **Qué descubrir:** dónde está el código y que es el de ese candado.
- **Variable:** rodillos, teclas o un puntero.
- **Reglas:** la secuencia exacta; a veces falta una pieza del propio candado (la L de TRIAL).
- **Difícil:** encontrar el código, no marcarlo; la distancia entre la pista y el candado.
- **Satisfactorio:** el «esto lo he visto»; el código escondido con ingenio.
- **Feedback:** la cámara gira sola y se abre el sello (R1-2.7); las letras aparecen bajo el ojo (R2-C.4).
- **Recompensa:** un sello o un cajón con objetos.
- **Ejemplos:** R1-2.7 (TRIAL), R2-C.4 (SESWN), OS-E9 (25BF).

### c.2 Acertijo con la respuesta en el objeto [INFORMACIÓN CRUZADA, OBSERVACIÓN]
- **Información:** un texto con una adivinanza y un objeto con varias opciones escritas o representadas.
- **Qué descubrir:** la respuesta, y que ya estaba en el objeto.
- **Variable:** qué opción se elige (una placa, un dial).
- **Reglas:** una sola correcta; en Three, hasta «nada» es una respuesta (la ventana vacía).
- **Difícil:** el salto del texto al objeto y el pensamiento lateral.
- **Satisfactorio:** la respuesta estaba a la vista todo el rato.
- **Feedback:** se abre un hueco (R1-1.3) o una ranura (R3-1.3).
- **Recompensa:** una llave, una carta.
- **Ejemplos:** R1-1.3 (FIRE), R3-1.3 (los cilindros-adivinanza).

### c.3 Revelar una capa oculta [OBSERVACIÓN, TRANSFORMACIÓN]
- **Información:** un objeto que parece normal y una herramienta (el ocular) que cambia lo que se ve.
- **Qué descubrir:** que hay algo más, dónde, y que hay que volver a mirar lo ya visto.
- **Variable:** dónde se mira con la herramienta puesta.
- **Reglas:** lo oculto solo existe con la herramienta. Cinco familias: textos, huellas, figuras que encajan desde un ángulo, mecanismos invisibles e imágenes que cambian (anexo de The Room 1 y 2, §3.1).
- **Difícil:** acordarse de usarla y saber dónde.
- **Satisfactorio:** cada objeto da más información sin añadir objetos.
- **Feedback:** bordes oscuros y vista estrecha al ponérsela (Pratt); lo oculto brilla.
- **Recompensa:** sobre todo información.
- **Ejemplos:** R1-1.6 (tinta invisible), R1-2.1 (huellas), R2-S.5 (cerraduras vistas por ventanitas).

### c.4 Perspectiva y anamorfosis [PERSPECTIVA, SÍMBOLOS]
- **Información:** fragmentos sueltos y, a veces, la figura que hay que formar, en una nota.
- **Qué descubrir:** que el ángulo de la cámara es la solución.
- **Variable:** el punto de vista, a veces junto con piezas que se mueven.
- **Reglas:** la figura solo encaja desde un sitio.
- **Difícil:** pensar en la cámara como herramienta; ángulos raros (desde abajo, R1-3.8a).
- **Satisfactorio:** la figura aparece de golpe.
- **Feedback:** un destello; la placa se vuelve blanca y desaparece (R1-2.9b).
- **Recompensa:** una cerradura, un cajón, una puerta.
- **Ejemplos:** R1-2.3 (las cifras del cubo), R3-3.1 (medio arco que casa con la pared), OS-T4 (el pasillo ilusorio).

### c.5 Ritual de cierre que se repite [PERSPECTIVA, CONEXIONES]
- **Información:** el mismo mecanismo al final de cada sala o capítulo.
- **Qué descubrir:** la variación de esta vez.
- **Variable:** el ángulo (las varillas de Two) o las barras, la palanca y la onda (la máquina de puertas de Three).
- **Reglas:** las del tutorial, cada vez más exigentes: más piezas, un objetivo que se mueve, sin signos y, por último, una pieza rota.
- **Difícil:** la vuelta de tuerca, no la regla.
- **Satisfactorio:** sentirse experto.
- **Feedback:** la puerta se abre; el tono sube cuanto más se parecen las ondas (R3-1.8b).
- **Recompensa:** el paso al nivel siguiente.
- **Ejemplos:** R2-C.7 (varillas de la cripta), R3-1.8b (la primera máquina), R3-5.2 (la máquina rota).
- **Nota:** sus expresiones están prohibidas en La caja viva (control de originalidad).

### c.6 Símbolos repartidos [SÍMBOLOS, INFORMACIÓN CRUZADA]
- **Información:** un mecanismo con varias posiciones y símbolos esparcidos por el objeto o la sala.
- **Qué descubrir:** qué símbolo va en cada posición. A veces lo dicen unas marcas: tres rayas indican la esquina (R1-2.8).
- **Variable:** la orientación o la elección de cada pieza.
- **Reglas:** una correspondencia de uno a uno.
- **Difícil:** la memoria espacial; ir y volver.
- **Satisfactorio:** conectar varias cosas vistas antes.
- **Feedback:** casi siempre no consta; un rayo sale hacia la puerta (R2-L.11).
- **Recompensa:** una llave, una moneda, el final.
- **Ejemplos:** R1-2.8, R1-E.4, R2-L.11.

### c.7 Llaves que se configuran, se fabrican o tienen varias posiciones [LLAVES, TRANSFORMACIÓN]
- **Información:** una cerradura con un contorno (a veces dibujado por el ocular) y una llave con partes móviles, o un molde.
- **Qué descubrir:** que la llave se cambia antes de usarla, y cómo.
- **Variable:** la forma de la llave (extremo, brazos, dientes, diales del molde) o su posición dentro de la cerradura.
- **Reglas:** solo entra con el perfil exacto; cada posición abre algo distinto (R1-E.5a).
- **Difícil:** pasar una forma de una vista a otra.
- **Satisfactorio:** ninguna llave es solo una llave; fabricarse la propia.
- **Feedback:** «The key doesn't fit like this» con un golpe y sin movimiento (vídeo); en la forja, la cámara sube y enseña el fuego (R3-4.8).
- **Recompensa:** lo que abre, y una llave que puede volver a usarse.
- **Ejemplos:** R1-1.4, R1-E.5a, R3-4.8.

### c.8 Puzle de bolsillo [TRANSFORMACIÓN, DESMONTAJE]
- **Información:** un objeto del inventario que parece decorado.
- **Qué descubrir:** que sus adornos son mandos.
- **Variable:** discos, tapas o piezas que se separan.
- **Reglas:** la secuencia de su mecanismo (en R1-2.2, discos a 180° y a 90°).
- **Difícil:** pensar en manipular lo que ya se ha guardado.
- **Satisfactorio:** un respiro entre puzles grandes; el objeto guarda otro.
- **Feedback:** el objeto se despliega (R1-E.3, vídeo).
- **Recompensa:** una llave, una nota o una herramienta.
- **Ejemplos:** R1-2.2, R2-C.5, OS-M4.

### c.9 Transformar un objeto en otro [TRANSFORMACIÓN, LLAVES]
- **Información:** un objeto que no encaja en ningún sitio.
- **Qué descubrir:** que cambia de función: la cajita es una llave, la campana un engranaje, la caja una escalera.
- **Variable:** giros y despliegues en el inventario.
- **Reglas:** el objeto final tiene la silueta de algún hueco del mundo.
- **Difícil:** imaginar la forma futura.
- **Satisfactorio:** el objeto «era» otra cosa.
- **Feedback:** en la mayoría no consta.
- **Recompensa:** la herramienta que faltaba.
- **Ejemplos:** R1-3.8b, R2-D.9, OS-M1.

### c.10 Montaje de una máquina [CONSTRUCCIÓN, COMBINACIÓN DE OBJETOS]
- **Información:** una máquina incompleta con huecos con forma y piezas repartidas en otros puzles.
- **Qué descubrir:** qué falta y dónde va.
- **Variable:** las piezas, el orden y a veces un ajuste (el enfoque de la cámara de fotos).
- **Reglas:** la máquina solo funciona completa.
- **Difícil:** reunir piezas de varios sitios.
- **Satisfactorio:** la máquina cobra vida.
- **Feedback:** la película del zoótropo con susurros (R1-2.5); el escritorio que se abre de golpe (R2-D.1).
- **Recompensa:** información (una palabra) o acceso.
- **Ejemplos:** R1-2.5, R2-D.1, OS-E9.

### c.11 Secuencia mecánica: diales y topes [DIALES, SECUENCIA]
- **Información:** un dial o una corredera sin número escrito; solo topes y clics.
- **Qué descubrir:** la secuencia de sentidos y paradas.
- **Variable:** el sentido y la cantidad de giro o de recorrido.
- **Reglas:** cada tramo suelta un pestillo, y los sueltos dejan de contar.
- **Difícil:** la pista es física; sin atenderla, hay que probar.
- **Satisfactorio:** sentir el mecanismo, como un ladrón de cajas fuertes.
- **Feedback:** el pestillo suelto deja de contar (R1-2.11a).
- **Recompensa:** una minicaja fuerte abierta, una ficha.
- **Ejemplos:** R1-2.11a, R1-3.3, R2-T.4.

### c.12 Anillos y discos que se alinean [ROTACIÓN, PATRONES]
- **Información:** anillos concéntricos o discos con un dibujo partido; a veces un centro fijo de referencia.
- **Qué descubrir:** la posición de cada uno y, si están acoplados, el orden.
- **Variable:** el giro de cada anillo.
- **Reglas:** completar el dibujo; en los acoplados, girar uno arrastra a otros (OS-K3).
- **Difícil:** el acoplamiento.
- **Satisfactorio:** el dibujo se completa.
- **Feedback:** la puerta hace clic y se abre (R1-1.6); una placa se aparta (R2-C.3).
- **Recompensa:** una puerta o una pieza.
- **Ejemplos:** R1-1.6, R2-C.3, OS-K3.

### c.13 Estado compartido [ORDEN, MULTIOBJETO]
- **Información:** varias piezas (cajones) y una pista numérica o de posición.
- **Qué descubrir:** que la posición final de cada pieza es un dígito de la combinación.
- **Variable:** cuánto se abre cada cajón.
- **Reglas:** todas a la vez en su sitio; en Old Sins, cada cajón gira cierres de otros.
- **Difícil:** ver el conjunto; las piezas se afectan entre sí.
- **Satisfactorio:** todo encaja de golpe.
- **Feedback:** los cajones se unen en uno (R2-D.3).
- **Recompensa:** una bombilla, un mango.
- **Ejemplos:** R2-D.3, OS-E7.

### c.14 Luz y trayectorias [REFLEJOS, LUCES]
- **Información:** una fuente de luz, espejos o reflectores y un blanco, a veces invisible sin el ocular.
- **Qué descubrir:** el camino del haz.
- **Variable:** la posición u orientación de cada espejo; a veces el punto de vista desde el espejo (R2-L.4).
- **Reglas:** la luz rebota y tiene que llegar al blanco.
- **Difícil:** ver la trayectoria entera; varios rebotes.
- **Satisfactorio:** el haz «llega» y algo se enciende.
- **Feedback:** sube una esfera y proyecta constelaciones (R1-3.10); la vista se pone roja (R2-L.4).
- **Recompensa:** una pieza o una puerta.
- **Ejemplos:** R1-3.10, R2-L.4, R3-4.1.

### c.15 Sombras y siluetas [SOMBRAS, PATRONES]
- **Información:** piezas que proyectan sombra y una silueta objetivo.
- **Qué descubrir:** la orientación que forma la silueta.
- **Variable:** el giro de las piezas o de los espejos.
- **Reglas:** la sombra debe coincidir con la figura.
- **Difícil:** pensar en la sombra y no en la pieza.
- **Satisfactorio:** la figura aparece.
- **Feedback:** la cámara lleva a un botón (R3-4.12).
- **Recompensa:** una llave, una cerradura.
- **Ejemplos:** R3-3.11, R3-4.12.

### c.16 Laberintos, recorridos y persecuciones [LABERINTO, ROTACIÓN]
- **Información:** una pieza, unos caminos y una meta; a veces un perseguidor.
- **Qué descubrir:** el orden de giros o de movimientos.
- **Variable:** el giro de la plataforma o de los anillos, dos ejes, o la posición de la ficha.
- **Reglas:** solo se pasa por caminos abiertos; las esferas no deben apagarse (R1-E.2); el perseguidor siempre va hacia ti (R2-T.6).
- **Difícil:** planificar; el control indirecto.
- **Satisfactorio:** la pieza llega; engañar al perseguidor.
- **Feedback:** las esferas se vuelven azules o verdes (R1-E.2); un cajón salta (R1-3.2, vídeo).
- **Recompensa:** una llave, un orbe.
- **Ejemplos:** R1-3.2, R1-E.9, R2-T.6. El laberinto en primera persona (R3-5.16) fue criticado [Opinión, TA].

### c.17 Deslizantes, intercambios y saltos de fichas [DESLIZAMIENTO, ORDEN]
- **Información:** un tablero con bloques o fichas y una configuración meta.
- **Qué descubrir:** la secuencia de movimientos.
- **Variable:** la posición de cada pieza.
- **Reglas:** las clásicas: deslizar sin levantar, saltar por encima de otra.
- **Difícil:** planificar varios movimientos.
- **Satisfactorio:** una solución limpia.
- **Feedback:** en la mayoría no consta; hay un botón de reinicio (R3-4.4).
- **Recompensa:** piezas, una palanca.
- **Ejemplos:** R1-E.8a, R2-D.6, R3-4.4.

### c.18 Tiempo y destreza [TIEMPO]
- **Información:** algo que se mueve: una aguja que baja, ruedas que giran, una bailarina, un automático.
- **Qué descubrir:** el momento o el ritmo.
- **Variable:** cuándo se pulsa o se mueve.
- **Reglas:** hay que actuar a tiempo; si no, se reinicia.
- **Difícil:** los dedos, más que la cabeza.
- **Satisfactorio:** ganar la carrera.
- **Feedback:** la aguja baja y, si se llega tarde, se reinicia (R1-3.9).
- **Recompensa:** piezas.
- **Ejemplos:** R1-3.9, R3-3.10, R3-4.2.
- **Nota:** [Interpretación del análisis del proyecto] son pocos y las reseñas los critican cuando aparecen.

### c.19 El tiempo como clave: la hora y el tiempo real [TIEMPO, INFORMACIÓN CRUZADA]
- **Información:** un reloj, a veces con las agujas ocultas, y una hora escrita en otro sitio; o el reloj real del aparato.
- **Qué descubrir:** la hora y dónde se pone.
- **Variable:** las agujas.
- **Reglas:** la hora exacta (las 6:05; las 2:50 con la aguja casi en las 3); en el posjuego de Three, la hora real.
- **Difícil:** relacionar un objeto lejano; esperar a una hora real, sin pistas.
- **Satisfactorio:** la foto o la carta cobran sentido.
- **Feedback:** se abren el sello y la caja (R1-2.18); suena la campana grande (R3-3.14).
- **Recompensa:** un sello, una pirámide, un cristal.
- **Ejemplos:** R1-2.18, R2-S.11, R3-CF1.

### c.20 Memoria y sonido [SONIDOS, MEMORIA]
- **Información:** melodías, campanas, una radio o una onda.
- **Qué descubrir:** la secuencia o la sintonía.
- **Variable:** teclas, campanas o diales.
- **Reglas:** repetir lo que suena, o igualar una señal; a veces dos notas a la vez.
- **Difícil:** la memoria auditiva; en Old Sins, la radio está en otra habitación.
- **Satisfactorio:** la música, la voz que se aclara.
- **Feedback:** el piano toca (R1-E.6); el tono sube cuanto más se parecen las ondas (R3-1.8b); la voz se oye clara y la luz se pone verde (OS-C6).
- **Recompensa:** manivelas, unas coordenadas.
- **Ejemplos:** R1-E.6, OS-E5a, OS-C6.

### c.21 Regla conocida del mundo [ORDEN, SECUENCIA]
- **Información:** piezas de un sistema conocido: ajedrez, cadena alimentaria, crecimiento de una planta, fases de la luna o sumas.
- **Qué descubrir:** qué regla se aplica.
- **Variable:** posiciones u orden.
- **Reglas:** las del mundo real.
- **Difícil:** poco, si se reconoce la regla.
- **Satisfactorio:** rapidez: ya lo sabías.
- **Feedback:** el fondo se abre y salen dos patas (OS-M4).
- **Recompensa:** piezas.
- **Ejemplos:** R3-3.9a, OS-M4, OS-E3.

### c.22 Regla oculta que se descubre probando [PATRONES, FÍSICA]
- **Información:** un mecanismo con mandos y resultados visibles, sin explicación.
- **Qué descubrir:** la regla: una cuadrícula de doble entrada, unos imanes que empujan o atraen.
- **Variable:** los mandos.
- **Reglas:** no se explican; se deducen de lo que pasa.
- **Difícil:** es lo más difícil de la serie fuera del posjuego.
- **Satisfactorio:** el ajá de entender el sistema.
- **Feedback:** cada letra se enciende (R3-2.3); se abre un cerrojo (R3-2.7).
- **Recompensa:** piezas.
- **Ejemplos:** R3-2.3, R3-2.7.

### c.23 Copia, simetría e inversión [SIMETRÍA, PATRONES]
- **Información:** un modelo: el panel vecino, una máscara, un cuadro, la otra asta.
- **Qué descubrir:** que hay que copiarlo, a veces en espejo o invertido.
- **Variable:** piezas, compases o segmentos.
- **Reglas:** igualar el modelo; en OS-E4, un brazo invierte las piezas al pasar al otro lado.
- **Difícil:** el espejo y la inversión.
- **Satisfactorio:** se aprende el mecanismo copiando.
- **Feedback:** el cuadro brilla (OS-A2).
- **Recompensa:** acceso.
- **Ejemplos:** OS-E2, OS-E4, R3-2.15.

### c.24 Puzle-indicador: la meta a la vista [PATRONES, INFORMACIÓN CRUZADA]
- **Información:** una consola, un cuadro o un diagrama que muestra el resultado.
- **Qué descubrir:** cómo reproducirlo.
- **Variable:** los mandos del puzle.
- **Reglas:** igualar lo que se ve.
- **Difícil:** poco; el reto es la manipulación.
- **Satisfactorio:** el puzle explica su objetivo.
- **Feedback:** un destello (R1-4.3).
- **Recompensa:** una daga, una puerta.
- **Ejemplos:** R1-4.3, OS-C4, OS-A2.

### c.25 Información encadenada: instrucciones, mapas y bucles [INFORMACIÓN CRUZADA, SECUENCIA]
- **Información:** notas con rumbos, dibujos que muestran otra sala, o dos máquinas que se responden.
- **Qué descubrir:** que un texto o un dibujo es un recorrido, o que la salida de una máquina es la entrada de otra.
- **Variable:** el recorrido, el sitio o la palabra.
- **Reglas:** seguir en orden; cada paso da la entrada del siguiente.
- **Difícil:** varios pasos y bloqueos por medio (la niebla de R2-S.6).
- **Satisfactorio:** conversar con el mundo.
- **Feedback:** el barco se mueve y un destello despeja la niebla (R2-S.6); la sala tiembla (R2-D.7).
- **Recompensa:** el mascarón, unos mensajes, el huevo siguiente.
- **Ejemplos:** R2-S.6, R2-D.7, OS-J4.

### c.26 Dos manos [PALANCAS, DESLIZAMIENTO]
- **Información:** dos mandos que deben moverse a la vez, o uno que se cierra si no se sujeta.
- **Qué descubrir:** que hacen falta dos dedos.
- **Variable:** dos acciones simultáneas.
- **Reglas:** un mando solo no hace nada; si se suelta, se cierra.
- **Difícil:** la coordinación; la accesibilidad.
- **Satisfactorio:** muy táctil.
- **Feedback:** un botón solo no hace nada (OS-V5).
- **Recompensa:** un engranaje, un artefacto.
- **Ejemplos:** R3-2.1, OS-V5, OS-G2.

### c.27 Física con el cuerpo: inclinar, apuntar y golpear [FÍSICA, PESO]
- **Información:** bolas, correderas, una mira o un brazo con peso.
- **Qué descubrir:** que el propio aparato, o una herramienta, es el mando.
- **Variable:** la inclinación, la puntería o la altura del golpe.
- **Reglas:** las de la física: la bola rueda, el virote vuela, el peso cae.
- **Difícil:** la destreza; en PC, inclinar no funcionaba [Hecho, GH].
- **Satisfactorio:** usar el cuerpo.
- **Feedback:** las bolas se encienden (R1-2.9a); si acierta, gira un muro (R2-T.5); grietas (R2-T.8).
- **Recompensa:** piezas y zonas nuevas.
- **Ejemplos:** R1-2.9a, R2-T.5, R2-T.8.

### c.28 Entrar en lo pequeño: escala y recursión [ESCALA]
- **Información:** un objeto pequeño con partículas o cristales que piden entrar.
- **Qué descubrir:** que dentro hay un mundo con sus puzles, y que puede repetirse dentro.
- **Variable:** el nivel de escala y los mandos de dentro.
- **Reglas:** lo de dentro cambia lo de fuera.
- **Difícil:** orientarse entre niveles.
- **Satisfactorio:** el asombro de escala.
- **Feedback:** un suave timbre donde se puede entrar (FW); al salir de la recursión, los maniquíes de cada nivel se completan (R3-2.11).
- **Recompensa:** piezas para el mundo de fuera.
- **Ejemplos:** R3-1.5, R3-2.11, OS-D1.
- **Nota:** prohibido en La caja viva; la versión propia está en el principio 10.

### c.29 Causalidad a distancia [MULTIZONA, TRANSFORMACIÓN]
- **Información:** dos espacios conectados: una maqueta y una sala, o dos habitaciones.
- **Qué descubrir:** que lo que se hace aquí cambia allí.
- **Variable:** la acción en el primer espacio.
- **Reglas:** el agua, el vapor, el sonido o la escala llevan el cambio.
- **Difícil:** construir el mapa mental; recordar qué recurso va adónde.
- **Satisfactorio:** entender el sistema entero.
- **Feedback:** el suelo se rompe también en la sala real (R3-5.12); una escena enseña el agua subiendo (OS-E13).
- **Recompensa:** caminos nuevos.
- **Ejemplos:** R3-5.12, OS-E8, OS-C6.

### c.30 Transformación del espacio [TRANSFORMACIÓN, MULTIZONA]
- **Información:** un espacio que puede cambiar de estado.
- **Qué descubrir:** qué lo cambia y que el otro estado guarda otras cosas.
- **Variable:** el estado: madera u oro, un piso u otro, presente o pasado.
- **Reglas:** lo de un estado sirve en el otro.
- **Difícil:** pensar en volver atrás.
- **Satisfactorio:** el asombro; dos espacios con un solo objeto.
- **Feedback:** un destello y la maqueta convertida en castillo dorado (R2-T.9); la sala que sube un piso (R3-2.9); una visión del pasado (OS-C1).
- **Recompensa:** zonas nuevas.
- **Ejemplos:** R2-T.9, R3-2.9, OS-C1.

### c.31 Gestos de dibujo: trazar y frotar [SÍMBOLOS, OBSERVACIÓN]
- **Información:** un símbolo que seguir, o una superficie sucia.
- **Qué descubrir:** el gesto.
- **Variable:** el trazo.
- **Reglas:** seguir el símbolo, a veces de un solo trazo; frotar descubre.
- **Difícil:** poco; algo de precisión.
- **Satisfactorio:** dibujar con el dedo.
- **Feedback:** una capa del cuadro se quema (OS-A3); la luz deja de parpadear (R3-5.15).
- **Recompensa:** una llave, una escena.
- **Ejemplos:** R3-2.5, OS-A3, R2-T.9.

### c.32 Circuitos [CONEXIONES, LUCES]
- **Información:** piezas con polos o vetas, y luces apagadas.
- **Qué descubrir:** cómo cerrar el circuito.
- **Variable:** la posición o el giro de las piezas.
- **Reglas:** unir + con −, o unir las piezas de dos en dos.
- **Difícil:** varias caras a la vez.
- **Satisfactorio:** las luces se encienden.
- **Feedback:** luces y un ventilador que gira (OS-G3).
- **Recompensa:** el artefacto, energía.
- **Ejemplos:** R3-1.8a, OS-G3, OS-T1.

### c.33 Reparar [RECONSTRUCCIÓN, DESMONTAJE]
- **Información:** una herramienta o una máquina que falla, a veces después de haber funcionado.
- **Qué descubrir:** qué falta y de dónde sacarlo, a veces de otra sala.
- **Variable:** la pieza que se cambia.
- **Reglas:** reparar en orden.
- **Difícil:** rompe lo que se esperaba; hay que buscar lejos.
- **Satisfactorio:** devolver la vida a un mecanismo.
- **Feedback:** el cargador se rompe (R2-L.7); el reloj se endereza y anda (R2-S.10).
- **Recompensa:** la máquina en marcha.
- **Ejemplos:** R2-L.7, R2-S.10, R3-5.2.

---

## d) Los 10 principios más transferibles a La caja viva

Cada principio dice de dónde sale, una propuesta concreta y su riesgo de parecido con la referencia.
- **La regla del proyecto:** principios sí, expresiones no.
- **Prohibido:** lente u ocular, portales, sustancia irisada, miniaturas y «entrar en lo pequeño», y rituales de
  varillas o máquinas de puertas.
- **Las propuestas son [Interpretación]** y ninguna está aprobada: las decide el usuario (formato DECISIÓN).

### d.1 La consecuencia siempre se ve
- **De dónde sale** [Hecho]: cuando el cambio pasa fuera de la vista, la cámara viaja a él o suena desde allí
  (R1-1.2, R1-2.13, R2-S.3, OS-E1; fuentes MM, WK, TA y LW).
- **Por qué funciona** [Interpretación]: el jugador entiende la causa y sabe adónde ir después, sin leer nada.
- **Propuesta:**
  - al correr una tablilla de la caja hija, la cámara gira lo justo para enseñar la flecha de marquetería que ha
    quedado al aire;
  - al poner el cuerno, la cámara se aleja hasta la cara entera, y entonces la caja respira;
  - si algo cambia en la sala (la trampilla que da luz), un viaje corto, de menos de 0,8 s (biblia §10.2), y vuelta.
- **Riesgo de parecido: bajo.** Es una convención de feedback, no una expresión de la serie.

### d.2 Tacto: el gesto imita la acción, la pieza pesa y el error no castiga
- **De dónde sale** [Hecho]:
  - Fireproof metió un motor de física para que cada pieza tuviera peso (WP; `como_se_hizo_the_room.md` §4);
  - las llaves giran con «a satisfying thunk» (TA);
  - lo bloqueado no se mueve, suena seco y sale una línea corta: «It won't budge», «The key doesn't fit like this»
    (vídeo);
  - en la forja, si la llave sale mal, se vuelve a fundir (R3-4.8).
- **Propuesta:**
  - la llave de bambú resiste un poco al empezar a girar y cede de golpe con un «toc» de madera;
  - las tablillas corren con roce de madera y hacen clic al llegar al tope;
  - lo bloqueado ya no se mueve y la caja contiene el aliento (hecho, biblia §3.4): mantenerlo;
  - una vibración corta en Android al encajar algo, y nada de castigos al fallar.
- **Riesgo de parecido: bajo.** El principio es del género; nuestra resistencia (el aliento, la mirada) es propia.

### d.3 La pista vive en el objeto y se aleja cuando sube la dificultad
- **De dónde sale** [Hecho]: FIRE está escrito en una pata (R1-1.3); los símbolos llevan tres rayas que dicen su
  esquina (R1-2.8); la hora sale de una foto encontrada varios pasos antes (R1-2.18); un dibujo de otra habitación
  dice dónde va el huevo (OS-J4).
- **Por qué funciona** [Interpretación del análisis del proyecto, §7.2]: la distancia entre la pista y la cerradura
  crece: al lado, en otra cara, en otro puesto y en otra habitación.
- **Propuesta:**
  - nivel 1: la nota está en el cajón de al lado (hecho);
  - nivel 2: la flecha está debajo de la tablilla que acabas de mover (hecho);
  - nivel 3: el orden de las puertecitas del santuario está grabado en la espalda de la caja hija, otra pieza y de
    otro nivel;
  - final: algo visto en el nivel 1 (el vuelo de las polillas, una frase de la nota) es la clave de un anillo.
- **Riesgo de parecido: bajo.**

### d.4 Ninguna llave es solo una llave
- **De dónde sale** [Hecho]: la llave configurable (R1-1.4, R1-2.12), la de tres posiciones (R1-E.5a), la de tres
  brazos (R2-D.2), la cajita que se vuelve llave (R1-3.8b), la campana que se vuelve llave o engranaje (R2-D.9,
  OS-M6) y los puzles de bolsillo (R1-2.2).
- **Propuesta:**
  - la llave de bambú abre el león en el nivel 1 y el cajón largo en el 3, y el perfil de sus dientes es además la
    pista de una cerradura de ruedas;
  - la ficha de shōgi se «promociona»: dada la vuelta, como en el shōgi real, enseña otro carácter y encaja en otro
    hueco;
  - un puzle de bolsillo por nivel: la cajita roja en el 2 (hecha) y un inro (cajita de pisos que cuelga de un
    cordón) en el 3.
- **Riesgo de parecido: bajo.** Ojo: la campana que se transforma ya está en Two y en Old Sins, así que la campanilla
  de la voz no debería convertirse en herramienta (eso sería riesgo medio).

### d.5 Una capa oculta que obliga a volver a mirar, sin lente
- **De dónde sale** [Hecho]: el ocular revela cinco familias de cosas (anexo de The Room 1 y 2, §3.1).
  - [Opinión] «The eyepiece isn't a clue system… it's integral to the puzzle design» (TA).
  - [Opinión] «If you're stuck your eyeglass will reveal a way to continue» (PGr).
- **Propuesta:**
  - la capa oculta es **la mirada del ojo de piedra de luna**: lo que mira, se alumbra, y hay que dirigirla con el
    andon o con el espejo (ya en el plan del nivel 3);
  - **la luz y el calor de la sala**: el andon rasante descubre marcas de dedos en la laca, y la llama revela una
    escritura invisible en la nota;
  - **un espejo mágico**: [Hecho] existen espejos de bronce que, al reflejar una luz fuerte en una pared, proyectan el
    dibujo de su dorso; en Japón se siguen fabricando
    ([Wikipedia, «Chinese magic mirror»](https://en.wikipedia.org/wiki/Chinese_magic_mirror)). El espejo de mano
    (kagami) del nivel 3 podría proyectar en el shoji la cara completa de la caja.
- **Riesgo de parecido: medio.** La capa oculta es la expresión central de la serie. Para alejarse:
  - nunca un objeto que se pone el jugador;
  - nunca un filtro de pantalla ni una viñeta;
  - nunca superficies irisadas;
  - lo oculto lo revela algo de la sala o de la propia caja.

### d.6 Presentar sola y fácil, luego combinar y luego retorcer
- **De dónde sale** [Hecho, anexos y análisis del proyecto §7.4]: cada mecánica de la serie sigue el mismo arco:
  - el ocular: R1-1.6, luego R1-2.1, luego R1-2.3 y R1-2.5, y por último R1-4.6;
  - la llave configurable: R1-1.4, R1-2.12, R1-3.10 y R1-E.5a;
  - la máquina de puertas: primero normal, luego más compleja, luego con un objetivo que se mueve, luego sin signos y
    por último rota (R3-1.8a a R3-5.2).
- **Propuesta:**
  - la regla de la mirada en cuatro tiempos (ya en el plan de niveles): presentar (nivel 1), ampliar (nivel 2),
    invertir (nivel 3) y combinar (final);
  - dentro de cada nivel, el primer uso de lo nuevo, solo y trivial: en el nivel 3, antes de las tres puertecitas,
    una única marca que el ojo nuevo descubre en cuanto se le pone delante.
- **Riesgo de parecido: bajo,** mientras el ritual de cierre no copie varillas ni máquinas.

### d.7 Los ajás nacen de cambiar el modelo mental
- **De dónde sale** [Interpretación del análisis del proyecto, §15]: cada gran ajá de la serie cambia una idea:
  - lo escrito es un objeto (R1-1.3);
  - la cámara es una herramienta (R1-2.3);
  - el tiempo es una llave (R1-2.18);
  - el objeto tiene dos estados (R2-T.9);
  - la escala es causal (R3-5.12);
  - el sonido viaja (OS-C6).
- **Propuesta: tres cambios propios:**
  - «la caja me ve» pasa a «yo veo lo que ve la caja»: una cámara subjetiva desde su ojo (el principio de R2-L.4,
    ver desde otro objeto);
  - «yo giro la rueda» pasa a «la caja gira la rueda al respirar y yo solo la sujeto»: el dial al revés;
  - «el ojo es un obstáculo» pasa a «el ojo es mi linterna» (nivel 3, ya en el plan).
- **Riesgo de parecido: bajo.**

### d.8 Una sola idea estructural nueva por nivel; los verbos no cambian
- **De dónde sale** [Hecho]: cada entrega añade una estructura nueva (tabla b.1) y conserva los verbos (tabla a.5).
- **Propuesta:**
  - nivel 1: la sala participa;
  - nivel 2: el objeto en la mano;
  - nivel 3: la caja cambia de forma (el biombo);
  - final: todo junto;
  - como mucho, un gesto nuevo por nivel (en el 3, desplegar las hojas del biombo con dos dedos, por ejemplo).
- **Riesgo de parecido: bajo.**

### d.9 Progreso visible y meta a la vista
- **De dónde sale** [Hecho]:
  - el progreso se ve: los tres sellos (R1, capítulo 2), el globo de cuatro piezas (R1-3.8a a R1-3.11), la
    colección de insectos (R2-L.9), las pirámides (R3-1.6) y la casa que cambia por fuera (OS-E1);
  - la meta se ve antes de alcanzarla: la mirilla (R3-1.2), la pirámide visible desde el principio (R3-3.3) y el
    artefacto tras unos barrotes (OS-J3).
- **Propuesta:**
  - la cara como contador (hecho) y la tarjeta con los sellos 角, 目 y 声 (hecha);
  - la campanilla visible tras la celosía desde que se abre el biombo;
  - una rendija del cajón largo que deja ver, un instante, lo que guarda.
- **Riesgo de parecido: bajo-medio.** Old Sins pone una talla en la frente de una cara (OS-J5) y ojos de piedra en
  las cuencas de un pulpo (OS-M3, OS-J3), que recuerdan a nuestro cuerno y a nuestro ojo de piedra de luna. Para
  alejarse:
  - las piezas son partes del cuerpo de la caja, que ella reclama en sus notas;
  - se ven volver a la vida: el cuerno se asienta, el ojo parpadea, la boca se abre;
  - nunca son piezas mecánicas que solo «activan» algo.

### d.10 La escala como asombro, sin entrar en lo pequeño
- **De dónde sale** [Hecho]: la caja dentro de la caja (The Room), el superzoom y la recursión (R3-1.5, R3-2.11) y
  la casa dentro de la casa (OS-D1). Es la mayor novedad de Three (análisis del proyecto, §6).
- **Propuesta (versión propia, como pidió el usuario):**
  - la escala cambia trayendo lo pequeño a la mano, no entrando en ello: la caja hija sale y se gira en la mano, y
    dentro está la cajita roja, y dentro el ojo (hecho en el nivel 2);
  - la escala al revés: en el nivel 3 la caja se despliega como un biombo y la cámara baja a la altura de la mesa,
    de modo que la caja parece enorme;
  - el micro-mundo propio es el santuario de tres secciones del biombo, que se recorre con la cámara sin cambiar de
    escala;
  - un eco entre escalas: lo que se hace en la caja hija lo repite la grande (nunca una maqueta de la sala).
- **Riesgo de parecido:**
  - alto si se entra en lo pequeño (prohibido);
  - medio con el eco y con el santuario, que recuerdan a la causalidad entre escalas de Three;
  - bajo con la caja en la mano.
  - Controles: nada de partículas que piden entrar, nada de doble toque para «encogerse» y nada de réplicas de la
    sala.

---

## Fuentes

Las siglas de las tablas y del texto. Las URL de cada puzle están en los anexos (`../referencia/`).

**Guías**
- **[PG] Pocket Gamer:** [The Room, capítulos 1 y 2](https://www.pocketgamer.com/the-room/how-to-enter-the-room-iphone-ipad-and-android-walkthrough-for-chapters-1-and-2/) · [Two, el templo](https://www.pocketgamer.com/the-room-2/how-to-solve-the-room-2-chapter-3-walkthrough-and-puzzle-guide-for-the-temple/) · [Three, capítulos 1 y 2](https://www.pocketgamer.com/the-room-three/chapter-1-2-walkthrough/) (las demás, en los anexos).
- **[WK] Walkthrough King:** [The Room](https://walkthroughking.com/text/room.aspx) · [The Room Two](https://walkthroughking.com/text/room2.aspx).
- **[MM] Mystery Manor:** [The Room](https://mysterymanor.net/walkthroughs/Room_1/the_room_1_1_english.htm) · [The Room Two](https://mysterymanor.net/walkthroughs/Room_2/the_room_2_english.htm).
- **[DT] dtgre:** [The Room, capítulos 1 y 2](https://www.dtgre.com/2014/02/the-room-2-solution-with-tips-to-all.html).
- **[AU] AppUnwrapper** (leída en web.archive.org): [epílogo de The Room](https://web.archive.org/web/2016/https://www.appunwrapper.com/2013/09/04/the-room-epilogue-walkthrough/) · [Three, capítulo 1](https://www.appunwrapper.com/2015/11/19/the-room-3-three-walkthrough-chapter-1-the-lighthouse/) · [Old Sins](https://www.appunwrapper.com/2018/01/24/the-room-old-sins-walkthrough-guide/) · [galería japonesa](https://www.appunwrapper.com/2018/01/25/the-room-old-sins-japanese-gallery-walkthrough-guide/) · [taller de pintura](https://www.appunwrapper.com/2018/01/25/the-room-old-sins-art-studio-walkthrough-guide/) · [cocina](https://www.appunwrapper.com/2018/01/25/the-room-old-sins-kitchen-walkthrough-guide/) · [sala marítima](https://www.appunwrapper.com/2018/01/25/the-room-old-sins-maritime-room-walkthrough-guide/) · [jardín](https://www.appunwrapper.com/2018/01/25/the-room-old-sins-garden-walkthrough-guide/) · [desván](https://www.appunwrapper.com/2018/01/25/the-room-old-sins-attic-walkthrough-guide/) · reseñas de [Three](https://www.appunwrapper.com/2015/11/11/the-room-three-review/) y de [Old Sins](https://www.appunwrapper.com/2018/01/24/the-room-old-sins-review/).
- **[LW] LevelWinner:** [Old Sins, parte 1](https://www.levelwinner.com/the-room-old-sins-walkthrough-part-1/) · [parte 2](https://www.levelwinner.com/the-room-old-sins-walkthrough-part-2/).
- **[GZ] Gamezebo:** [Old Sins, tutorial y desván](https://www.gamezebo.com/walkthroughs/the-room-old-sins-walkthrough-tutorial-and-attic/).

**Wikis y fichas**
- **[FD] / [FW] Fandom:** [The Room](https://web.archive.org/web/2021/https://theroom.fandom.com/wiki/The_Room) · [The Room Three](https://theroom.fandom.com/wiki/The_Room_Three) · [Old Sins](https://theroom.fandom.com/wiki/The_Room:_Old_Sins).
- **[MG] MobyGames:** [The Room](https://web.archive.org/web/2023/https://www.mobygames.com/game/60395/the-room/).
- **[WP] Wikipedia:** [The Room](https://en.wikipedia.org/wiki/The_Room_(video_game)) · [The Room Two](https://en.wikipedia.org/wiki/The_Room_Two) · [The Room Three](https://en.wikipedia.org/wiki/The_Room_Three) · [Old Sins](https://en.wikipedia.org/wiki/The_Room:_Old_Sins) · [espejo mágico](https://en.wikipedia.org/wiki/Chinese_magic_mirror).
- **[ST] Logros de Steam:** [Three](https://steamcommunity.com/stats/456750/achievements/) · [Old Sins](https://steamcommunity.com/stats/1361320/achievements/).

**Reseñas, entrevistas y análisis**
- **[TA] TouchArcade:** [primer contacto con The Room](https://toucharcade.com/2012/08/06/hands-on-with-the-room/) · [The Room](https://toucharcade.com/2012/09/26/the-room-for-ipad-review/) · [Two](https://toucharcade.com/2014/01/17/the-room-two-review/) · [Three](https://toucharcade.com/2015/11/05/the-room-three-review/) · [Old Sins](https://toucharcade.com/2018/01/24/the-room-old-sins-review/).
- **[IGN]** [The Room Two](https://www.ign.com/articles/2013/12/19/the-room-two-review) · **[EG] Eurogamer** [The Room Two](https://www.eurogamer.net/the-room-2-review).
- **[PGr] Pocket Gamer, reseñas:** [The Room](https://www.pocketgamer.com/the-room/review/) · [The Room Two](https://www.pocketgamer.com/the-room-2/review/).
- **[GaG] God is a Geek:** [Three](https://godisageek.com/reviews/the-room-three-review/) · [Old Sins](https://www.godisageek.com/reviews/the-room-the-old-sins-review).
- **[SX] TheSixthAxis:** [Three](https://www.thesixthaxis.com/2015/11/13/the-room-three-review/).
- **[GH] Gamer Horizon,** entrevista a Barry Meade: [enlace](https://gamerhorizon.com/2014/08/19/room-interview-fireproof-studios-barry-meade/).
- **El método de Fireproof:** `../referencia/como_se_hizo_the_room.md` y sus fuentes, por ejemplo [Pocket Gamer.biz, «Thinking outside the box»](https://www.pocketgamer.biz/thinking-outside-the-box-the-making-of-the-room/).
- **[Pratt]** [Design critique: The Room](https://ixd.prattsi.org/2019/09/design-critique-the-room-android-app) · **[MoM] Mechanics of Magic** [Critical play: The Room](https://mechanicsofmagic.com/2026/05/06/critical-play-the-room/) (análisis de estudiantes: opinión).

**Vídeos de partida** (descripciones automáticas de vidIQ, 03-10-2026): [The Room](https://youtu.be/_N9YeVhc3hI) · [Old Sins](https://youtu.be/4paowtxhQLY).
