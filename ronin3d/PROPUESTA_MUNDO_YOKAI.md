# RONIN — Propuesta: un Japón plagado de yōkai

**Fecha:** 1 de octubre de 2026 · **Estado:** propuesta del usuario analizada y **decisiones 2 a 7
cerradas el mismo día** (resumen justo abajo). **Relación con el plan:** amplía
`PLAN_PRODUCCION.md` (alcance C: núcleo + variaciones, lanzamiento por capítulos). **Siguen:**
`HISTORIA.md` (sinopsis, DECISIONES 8 y 9) y `BESTIARIO.md` (DECISIÓN 10).

Etiquetas: **[Hecho]** comprobado · **[Estimación]** cálculo con incertidumbre · **[Opinión]**
criterio del equipo.

## Decidido el 1-10-2026

| Decisión | Resultado | Qué se hizo |
| --- | --- | --- |
| 2 · Combate | **B, precisión**, con el iaidō como forma visible | En el prototipo 0.3: iaidō (mantener y soltar al «!») y corte de luna |
| 3 · Historia | **B**: Genzo pactó con el gran yōkai creyendo proteger Japón. Y **Takeda pasa a ser el shōgun** | Sinopsis para aprobar en `HISTORIA.md`; los textos del juego aún no cambian |
| 4 · Bestiario | **B** (yōkai japoneses y sus variantes) **y además más criaturas**, con las de otras tierras y **Bahamut como el dragón** | `BESTIARIO.md` |
| 5 · Escenas | **B**: ilustración 2D con tinta (pixel art solo para los recuerdos de Akira) | Herramienta encontrada: Higgsfield (0,15 créditos por imagen); conceptos en `arte/conceptos/` |
| 6 · Animación | **C**, estilo anime limitado, a probar | Probado en el prototipo: 12 poses por segundo; **T** (o el botón de la pausa en el móvil) cambia a la suave para comparar. VRoid no se puede probar desde la nube: es un programa de escritorio para tu PC |
| 7 · Farmeo automático | **C**: nada automático; la caza se juega | — |

---

## 1. Lo que propones, en una línea cada cosa

1. Japón en la época en que leyendas, yōkai, fantasmas y mitos están más activos.
2. Minijuegos de caza de monstruos y farmeo automático; peleas de uno contra varios.
3. Escenas de historia en pixel art.
4. Monstruos gigantes, veloces y poderosos; cada tipo distinto.
5. Historia: quien mató al señor era seguidor de uno de los monstruos más poderosos y malvados,
   que quiere poner todo Japón bajo los monstruos.
6. Cambiar entre dos planos: el de los humanos y el más allá de los monstruos.
7. Un bestiario enorme (sirena, duende, kappa, hombre lobo, vampiro, gyojin, kaijū, slime, lobos,
   gárgola, hombre lagarto, doppelgänger, oni, ogros, hobgoblin, dragones, fénix, tigres y leones
   legendarios, hadas, elfos, elfos oscuros, Bahamut, titanes, Leviatán, Fenrir, ifrit, asura,
   golems, robots de una civilización antigua olvidada, la luna).
8. Imágenes 2D completas de los personajes principales.
9. Estatuas en la planicie para rezar: guardar partida y mejorar estadísticas.
10. Poderes vistosos y cortes de espada, con estilo **iaidō** (desenvaine rápido y preciso, como
    Vergil en *Devil May Cry*).
11. Cambiar el estilo de animación.
12. Cambiar ropa y armadura, y configurar la estética del personaje al empezar.

## 2. Diagnóstico como socio

**Lo mejor de la propuesta [Opinión]:** el mundo yōkai resuelve el mayor problema de
diferenciación que vimos en el plan (el samurái «realista» está muy ocupado: *Ghost of Yōtei*,
*Rise of the Ronin*). Un ronin con iaidō en un Japón invadido por yōkai, con un plano espiritual,
se explica en una frase y se ve en un vídeo de 10 segundos. Y el **iaidō encaja exactamente con el
combate de precisión** que ya está en el prototipo: parar justo al «!» y cortar *es* un iaidō.

**El riesgo:** juntas, las 12 ideas son 4 o 5 juegos (cazador de monstruos, idle de farmeo, RPG de
equipo, juego de plataformas entre planos, JRPG con bestiario gigante). Con una persona, Claude y un
PC modesto, intentar todo a la vez es la forma más segura de no terminar nada **[Estimación]**.
La solución no es decir que no: es **meter cada idea donde sirve al núcleo** y repartirla por
capítulos, como acordamos con la opción C.

## 3. Reparto por capítulos

| Idea | Capítulo 1 (vertical slice) | Más adelante | Por qué |
| --- | --- | --- | --- |
| Mundo yōkai | **Sí**: el castillo cae porque los yōkai atacan Hoshiyama esa noche | — | Da identidad desde el minuto 1 y no cuesta sistemas nuevos |
| Iaidō y poderes vistosos | **Sí**: la parada pasa a ser el desenvaine; 1 técnica especial (corte a distancia con barra de espíritu) | Más técnicas en el dojo | Es el núcleo; todo lo demás se apoya en él |
| Tipos de enemigo (gigante, veloz, poderoso, enjambre) | **3-4 yōkai**: kappa (veloz), oni (poderoso), onibi (enjambre), un oni gigante como jefe | Kaijū y jefes de fases | Cada tipo enseña algo distinto del iaidō |
| Uno contra varios | **Sí**, grupos de 3-6 | Hordas mayores según los FPS del móvil | El rendimiento en Android manda |
| Estatuas para rezar (jizō) | **Sí**: guardar, recuperar vida y subir 1 estadística con lo cazado | Más mejoras | Barato y da el bucle de «volver más fuerte» |
| Caza de monstruos | **1 encargo** en la aldea (tablón de cazadores) | Tablón con encargos y recompensas | Reutiliza el combate; no es un minijuego aparte |
| Cambio de planos | Un **adelanto**: una zona donde se ve el otro plano un instante | Mecánica completa en el capítulo 2 | Es la idea con más potencial y la más cara; merece su propio capítulo |
| Historia con el gran yōkai | **Sí**, si eliges la opción B de la DECISIÓN 3 | — | Cambia la historia base: la decides tú |
| Escenas de historia 2D | **Sí**, 4-6 ilustraciones fijas con texto | Más escenas | Ver DECISIÓN 5 (pixel o ilustración) |
| Ropa, armadura y apariencia | 2-3 colores de kimono y 1 armadura visible | Creador al inicio y armario completo | Cada prenda multiplica modelos y animaciones |
| Estilo de animación | Elegirlo ahora (DECISIÓN 6) | — | Todo el arte depende de esto |
| Bestiario completo | — | Repartido por capítulos (5-8 yōkai por capítulo) | Ver DECISIÓN 4 |
| Farmeo automático | **No** | Quizá «expediciones» | Ver DECISIÓN 7 |

## 4. El bestiario: cómo meter tu lista sin perder la identidad

Mezclar vampiros, elfos y Bahamut con kappa y oni puede convertir el juego en «otro RPG genérico».
Casi todo lo que pediste **tiene un equivalente japonés** que mantiene el sabor y sigue siendo lo
que querías **[Opinión]**:

| Pediste | Equivalente japonés | Rol en combate |
| --- | --- | --- |
| Sirena / gyojin | Ningyo, gyojin del mar | Veloz en el agua, ataque desde abajo |
| Duende / hadas / elfos | Kodama, zashiki-warashi, tennin | Enjambre o aliados |
| Elfos oscuros | Kitsune y tanuki que cambian de forma | Engaño, ilusiones |
| Doppelgänger | Noppera-bō o kitsune que imita a un humano | Duelo espejo; perfecto para la intriga de Genzo |
| Hombre lobo / lobos / Fenrir | Okuri-inu (lobos que siguen al viajero), Ōkami gigante | Veloz, manada |
| Vampiro | Kyūketsuki / nure-onna | Poderoso, drena vida |
| Kappa | Kappa (ya es japonés) | Veloz, agarre |
| Slime | Nuppeppō, betobeto | Enjambre que se divide |
| Gárgola / golem | Komainu de piedra que despiertan, guardianes de piedra | Gigante lento con puntos débiles |
| Hombre lagarto | Servidores de Ryūjin (rey dragón del mar) | Soldado |
| Oni / ogros / hobgoblin y variantes | Oni rojos, azules, ōni gigantes | Poderoso; la gran familia de enemigos |
| Dragones | Ryū, Yamata no Orochi (8 cabezas) | Jefe gigante |
| Fénix | Hō-ō | Jefe aéreo o aliado |
| Tigres y leones legendarios | Byakko (tigre blanco), shishi | Veloz y poderoso |
| Titanes | Daidarabotchi (gigante que hizo montañas) | Kaijū |
| Kaijū / Leviatán | Umibōzu, isonade | Jefe del mar |
| Ifrit | Kasha (carro de fuego que roba cadáveres) | Poderoso de fuego |
| Asura | Ashura (ya está en el budismo japonés) | Jefe de varios brazos |
| Robots de civilización antigua | **Dogū y haniwa que despiertan**: autómatas de una era olvidada | Sorpresa de mitad de juego |
| La luna | **Tsukuyomi**, el dios de la luna, como amenaza final o aliado ambiguo | Jefe o giro de historia |
| Bahamut | Sin equivalente directo; el nombre se asocia mucho a *Final Fantasy* | ~~Mejor un dragón propio~~ **Decidido: Bahamut es el dragón**, con diseño propio (`BESTIARIO.md` §6) |

Lo que no tiene equivalente (vampiro europeo, elfo, Bahamut) puede entrar **como algo que llega
desde el otro plano**: «criaturas de otras tierras» que el gran yōkai invoca. Así el extraño
tiene una razón y no rompe el mundo.

## 5. Los cuatro tipos de enemigo

| Tipo | Qué enseña del iaidō | Ejemplo capítulo 1 |
| --- | --- | --- |
| **Veloz** | Leer el aviso: ataca rápido y desde ángulos; solo se vence parando a tiempo | Kappa |
| **Poderoso** | Paciencia: golpes que no se pueden parar y hay que esquivar; aturdido, recibe el corte final | Oni |
| **Enjambre** | Control: muchos débiles; el corte especial a distancia los barre | Onibi (fuegos fatuos) |
| **Gigante** | Puntos débiles: brazos y piernas que se cortan por partes; ataques muy avisados | Oni gigante (jefe) |

## 6. El estilo iaidō (respuesta a «como Vergil»)

- **Inspirarse sí, copiar no:** nada de nombres como «Judgement Cut» ni el abrigo azul.
- **Mecánica:** Akira lleva la espada envainada. Mantener «Parar» = postura de iaidō; soltar justo
  al aviso = desenvaine que para y corta a la vez (lo que ya hace el prototipo, con más ceremonia).
- **Corte especial («Tsuki no kiri», nombre provisional):** con la barra de espíritu llena, varios
  cortes que aparecen un instante después en el aire, en un área. Sirve contra enjambres.
- **Cómo se ve:** congelar la imagen 0,1 s, la pantalla se vuelve tinta blanca y negra, aparecen
  las líneas de corte, vuelve el color y los enemigos caen. Encaja con el cel-shading y con la
  «pausa de impacto» que ya está programada.

## 7. Estilos de animación posibles (tu pregunta)

Hoy los personajes son piezas sueltas que se mueven por código: barato, pero rígido. Las opciones:

| Estilo | Cómo se ve | Coste | Encaje |
| --- | --- | --- | --- |
| A) Piezas por código (actual) | Rígido, tipo juguete | Ninguno | Solo prototipo |
| B) Esqueleto 3D con animación suave | Como la mayoría de juegos 3D | Modelos con esqueleto (Blender o VRoid) y animaciones (Mixamo, gratis) | Bueno, genérico |
| C) **Animación limitada estilo anime** | Poses clave sostenidas a 12 imágenes por segundo, borrones de movimiento, cuadros de impacto (*Guilty Gear Xrd*, *Hi-Fi Rush*) | Lo mismo que B más ajuste de poses | **El mejor con cel-shading e iaidō** |
| D) Sprites 2D en mundo 3D (HD-2D) | Ya lo probamos | Medio | Descartado al elegir cel-shading |
| E) 2D dibujado a mano | Precioso | Muy caro: cada movimiento dibujado | No viable hoy |

**VRoid Studio** (gratis) crea personajes anime con esqueleto listo y apariencia editable
(pelo, ojos, ropa), y Godot los carga con un complemento libre. Serviría también para el creador
de personaje del inicio **[Opinión; hay que probar que corra en tu PC]**.

## 8. Escenas de historia y personajes 2D

- **Imágenes de los personajes:** Gemini no tiene cuota de imágenes en el plan gratuito de tu
  clave y PixAI rechazó la petición **[Hecho]**. **Resuelto el mismo día con Higgsfield** (modelo
  Z Image, 0,15 créditos por imagen, con tu cuenta): los conceptos están en `arte/conceptos/` y
  en Drive.
- **Pixel art o ilustración:** el juego ya tiene 3D cel-shading. Sumar pixel art y además
  ilustraciones 2D anime son tres estilos a la vez. Propuesta: escenas en **ilustración 2D con
  tinta** (como los conceptos), y el **pixel art solo para los recuerdos de Akira**, como homenaje
  al prototipo `samurai.py`: así cada estilo tiene una razón.

## 9. Ropa, armadura y apariencia

- La historia es de **Akira**, así que el creador al inicio cambia **cómo se ve Akira** (pelo,
  cicatriz, colores del kimono, empuñadura), no quién es.
- Cada prenda nueva necesita modelarse y ajustarse a todas las animaciones: es caro. Capítulo 1:
  2-3 colores y 1 armadura visible; armario completo después.
- **Negocio [Hipótesis]:** la apariencia es la vía de monetización menos agresiva en un juego de
  pago (trajes extra), sin tocar el combate. Se decide más adelante.

## 10. Prompts listos para los conceptos 2D

Estilo común: «Full-body 2D character concept art, anime cel-shaded illustration with bold black
ink outlines and flat color bands, plain light parchment background, sumi-e ink splatter accents,
feudal Japan dark fantasy, whole figure visible, no text, no watermark».

- **Akira:** ronin de unos 28 años, coleta alta negra con cinta blanca, kimono y hakama azul marino
  con cordón rojo, piezas de cuero en hombro y antebrazos, katana en vaina negra a la izquierda,
  mano en la empuñadura en postura de iaidō, cicatriz en la mejilla.
- **Genzo:** general de unos 55 años, alto, barba corta canosa, mirada dura y triste, armadura
  o-yoroi carmesí y negra con oro, kabuto con cuernos bajo el brazo, nodachi a la espalda, capa
  negra rota; aura púrpura y un talismán con máscara de oni en el cinturón (el pacto).
- **Señor Takeda:** daimyō de unos 65 años, rostro amable y cansado, moño blanco, kamishimo índigo
  y plata con un emblema de luna creciente sobre una montaña, abanico cerrado, wakizashi.
- **El gran yōkai:** señor demonio colosal, mezcla de kitsune de nueve colas y oni, máscara de
  porcelana, ojos carmesí, corona de fragmentos de torii, kimono real negro y oro, colas de fuego
  fatuo violeta, luna llena detrás.

## 11. Decisiones que necesito de ti

### DECISIÓN 2 (pendiente del plan) — Estilo de combate · **DECIDIDA: B**
Pediste iaidō con precisión en los cortes. **Entiendo que eso la cierra en B (precisión)**, con el
iaidō como forma visible. Confírmalo, idealmente después de probar la parada en el APK.

### DECISIÓN 3 — Historia: el gran yōkai y Genzo · **DECIDIDA: B, y Takeda es el shōgun**
- **OPCIONES:** A) Genzo es seguidor fiel del gran yōkai y lo mató por él (villano claro);
  B) Genzo hizo un **pacto** con el gran yōkai creyendo que era la única forma de proteger Japón
  (Takeda era «demasiado blando» con los yōkai), y el yōkai lo usa; desde el pacto los ataques
  bajaron en sus tierras y por eso parte del pueblo lo apoya; C) el asesino es otro seguidor del
  yōkai y Genzo queda aparte.
- **VENTAJAS:** A es simple y épico. B mantiene todo lo que ya tenía la historia (Genzo no se ve
  como villano, el pueblo dividido, justicia y honor) y suma la amenaza mayor. C da un villano
  nuevo.
- **RIESGOS:** A pierde los matices que hacen distinta la historia. B exige escribir bien el
  pacto. C cambia más la historia base y deja a Genzo sin papel claro.
- **COSTE:** igual en las tres; solo textos y escenas.
- **RECOMENDACIÓN:** **B.**
- **SIGUIENTE PASO:** reescribir la sinopsis y los textos de intro y cierre (ahora sí tocaría
  cambiarlos) y enseñártelos antes de meterlos en el juego.
- **Nota:** en la historia, Takeda es un señor feudal (daimyō), no el shōgun. ¿Lo dejamos así o
  quieres que sea el shōgun? Cambia la escala: el shōgun manda en todo Japón.

### DECISIÓN 4 — Bestiario · **DECIDIDA: B, con más criaturas y Bahamut**
- **OPCIONES:** A) tu lista tal cual, mezclando mitos de todo el mundo; B) yōkai japoneses como
  núcleo, con equivalentes japoneses para casi todo (§4) y los extranjeros como «criaturas de otras
  tierras» que llegan desde el otro plano; C) solo yōkai japoneses.
- **VENTAJAS:** A tiene más variedad conocida. B mantiene la identidad y conserva casi toda tu
  lista. C es la identidad más pura.
- **RIESGOS:** A parece un RPG genérico y choca con nombres asociados a otras sagas (Bahamut).
  B exige explicar la llegada de los extranjeros. C pierde ideas que te gustan.
- **COSTE:** igual; lo que cuesta es cada monstruo (modelo, animaciones, comportamiento).
- **RECOMENDACIÓN:** **B.**
- **SIGUIENTE PASO:** fichas de los 4 yōkai del capítulo 1 (kappa, oni, onibi, oni gigante).

### DECISIÓN 5 — Escenas de historia · **DECIDIDA: B**
- **OPCIONES:** A) todas en pixel art; B) ilustración 2D con tinta, y pixel art solo para los
  recuerdos de Akira; C) escenas con los propios modelos 3D.
- **VENTAJAS:** A es barato de hacer. B da a cada estilo una razón y luce mejor. C mantiene un solo
  estilo.
- **RIESGOS:** A choca con el cel-shading. B necesita generar ilustraciones (requiere resolver la
  generación de imágenes). C se ve pobre mientras los personajes sean piezas.
- **COSTE:** A bajo; B medio (0,07 USD por imagen con Gemini más retoque); C bajo ahora, alto
  después.
- **RECOMENDACIÓN:** **B.**
- **SIGUIENTE PASO:** activar la generación de imágenes (facturación de Gemini o arreglar PixAI) y
  hacer los 4 conceptos de la §10.

### DECISIÓN 6 — Estilo de animación · **DECIDIDA: C, en prueba**
- **OPCIONES:** B) esqueleto 3D suave; C) animación limitada estilo anime (§7).
- **VENTAJAS:** B es el estándar. C diferencia el juego y hace lucir el iaidō.
- **RIESGOS:** los dos necesitan modelos con esqueleto (hoy son piezas); C además pide ajustar
  poses a mano.
- **COSTE:** pasar a modelos con esqueleto es el mayor salto técnico del capítulo 1 en las dos.
- **RECOMENDACIÓN:** **C**, probando primero VRoid Studio en tu PC.
- **SIGUIENTE PASO:** un personaje de prueba (Akira) con esqueleto y 3 animaciones (andar, postura
  de iaidō, desenvaine) dentro del prototipo.

### DECISIÓN 7 — Farmeo automático · **DECIDIDA: C**
- **OPCIONES:** A) farmeo automático real (el juego caza solo); B) «expediciones»: contratas
  cazadores que traen materiales mientras juegas; C) nada automático, la caza es jugarla.
- **VENTAJAS:** A atrae a quien juega en el móvil a ratos. B da recursos sin quitar el combate.
  C mantiene el foco en la precisión.
- **RIESGOS:** A es un rasgo de juegos gratuitos con mucha monetización; en un juego de pago
  centrado en la precisión hace que el combate parezca opcional. B añade un sistema más.
  C puede sentirse repetitivo si hay que repetir cazas.
- **COSTE:** A alto (economía y balance), B medio, C ninguno.
- **RECOMENDACIÓN:** **C** ahora; reconsiderar **B** cuando el juego tenga economía.
- **SIGUIENTE PASO:** el encargo de caza del capítulo 1 se diseña para jugarse una vez, no para
  repetirse.
