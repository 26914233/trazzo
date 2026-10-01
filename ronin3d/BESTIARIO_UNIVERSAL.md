# RONIN — Bestiario universal: cómo meter cientos de monstruos sin romper el juego

**Fecha:** 1 de octubre de 2026 · **Estado:** análisis y propuesta; las decisiones 11 (en `HISTORIA.md`), 12, 13 y 14
son tuyas. Aplica tu decisión **10B** (las criaturas de otras tierras llegan a partir del capítulo 3), tu idea
de que cada monstruo tenga una **variante más fuerte** y tu pedido de **añadir demonios y ángeles**.

Etiquetas: **[Hecho]** comprobado · **[Estimación]** cálculo con incertidumbre · **[Supuesto]** algo que
damos por bueno sin comprobar · **[Hipótesis]** hay que validarlo · **[Opinión]** criterio del equipo.

---

## 1. Qué me pasaste y qué encontré

Dos archivos: `Bestiario_Universal_500.xlsx` (IDs 1-498) y `Bestiario_Universal_501-1000_Detallado.xlsx`
(IDs 501-1000). Son un **buen índice de nombres**, pero todavía no un bestiario: lo que traen y lo que
no, medido sobre los archivos:

| Hallazgo | Detalle |
| --- | --- |
| Faltan datos | El archivo A tiene **498 filas** (no 500; faltan los ids 499 y 500) y solo cuatro campos con información propia: nombre, cultura, región y categoría. El resto de columnas dicen «Pendiente de investigación» en las 498 filas |
| «Detallado» es una frase | El archivo B trae **una frase** por criatura (de 39 a 140 caracteres). Las otras 11 columnas (apariencia, comportamiento, hábitat, debilidades…) tienen **el mismo texto genérico en las 500 filas** |
| La categoría de A no sirve | Se repite en **ciclo de 10** (Gigante, Marina, Bestia, Entidad, Voladora, Espíritu, No-muerto, Híbrido, Demonio, Monstruo) sin mirar la criatura: la Medusa figura como «marina», Cerbero como «no-muerto» y la Esfinge como «demonio». La de B es mejor, pero también falla (Karakasa-kozo y Nobusuma figuran como «acuáticas») |
| Culturas mal puestas | Tiamat figura en Francia; Quetzalcóatl, en África; Anansi, en Corea; Oni, en China; Simurgh, en Egipto; Fenrir, en Roma |
| Duplicados | **98 nombres idénticos** en los dos archivos y **69 grupos** que son la misma criatura con otro nombre («Cerbero» y «Cerbero grecorromano», «Mantícora» ×4, «Gallu»/«Gallû», ortografías…). De 998 filas quedan **808 criaturas distintas** |
| Relleno | Entradas que el propio catálogo avisa que son «categoría», «nombre comparativo» o «requiere verificación» (*Water spirit of the Zambezi*, *Raven spirit*, *Sisiutl africano*, *Kikimora Pacifica*…), y otras que **no son criaturas**: *Kermes* es un insecto tintóreo, *Ras al-hanout spirit* parte de una mezcla de especias, *Babr-e Bayan* es la armadura de un héroe, *Pekapeka* es un murciélago real |

**Lo que hice:** clasifiqué cada criatura canónica una por una, por lo que es (no por las columnas
erróneas ni por reglas automáticas), en 13 campos: cultura real, familia de cuerpo, tamaño, rol de combate,
elemento, bioma, cómo se modela, sensibilidad cultural, descripción visual en inglés para las imágenes y una
nota de mecánica. Lo hicieron agentes de Claude en paralelo, una tanda de unas 80 criaturas cada uno, con la rúbrica de
`bestiario/RUBRICA_CLASIFICACION.md`; **yo revisé muestras y pasé comprobaciones automáticas** (formato,
reskins con base, palabras de riesgo en los prompts, familia frente a descripción), pero **no leí las 939
una por una**: espera algún error de detalle (por eso quedan 77 marcadas «Dudosa»). Y añadí **132
criaturas** que no estaban (ver §5).

**Cifras tras la limpieza** *(salen de `bestiario/informe_calidad.md`)*:

| | Criaturas |
| --- | ---: |
| Criaturas del catálogo (tras fusionar) | 808 |
| Criaturas añadidas por mí | 132 |
| **Total en el bestiario** (808 + 132, menos 1 fundida) | **939** |
| Con identidad propia (`criatura`) | 699 |
| Genéricas / relleno (`generica`) | 149 |
| Dioses y seres divinos (`deidad`) | 81 |
| No son criaturas (`no_criatura`) | 10 |
| **Utilizables como enemigos** (criatura o genérica, sensibilidad 0-1) | **825** |

Dicho claro: tu catálogo tiene **808 criaturas distintas, no 1.000** (una, el *Oni*, es el mismo oni
rojo que yo añadí como *Aka-oni*, así que se fundieron: el total es 939); con las añadidas, 825
son utilizables como enemigos. Con la variante fuerte de cada una salen **1.650** enemigos y con la silenciada,
**2.475**, pero esos dos números cuentan variantes, no criaturas. **La cifra honesta para decir en público es
«825 criaturas, cada una con su variante fuerte»**; llamar «2.475 monstruos» a lo mismo con otro color sería inflar.

---

## 2. ¿Es la cantidad de monstruos un buen gancho?

Tu idea: *que lo que diferencie y atraiga del juego sea la cantidad de monstruos que se pueden pelear.*
Te lo analizo como socio, no te lo apruebo por defecto.

**A favor [Opinión]**

1. **Se explica en una frase:** *«Un ronin, un solo corte y cientos de monstruos de todas las
   mitologías: cada uno se vence de otra manera.»* Pasa la prueba de la frase del CLAUDE.md (si no se puede explicar en una frase, hay que mejorar el concepto).
2. **Genera contenido barato y repetible.** Cada criatura trae una leyenda real: una publicación
   («el monstruo de hoy»), una ficha del bestiario y un encargo de caza. Con 825 criaturas hay
   material para años, sin publicar nada sin tu permiso.
3. **Encaja con el lanzamiento por capítulos:** cada oleada de criaturas es una actualización.
4. **Los rangos multiplican sin multiplicar el arte** (§4).

**En contra / riesgos**

1. **«Ancho pero poco profundo».** La gente recuerda 10 o 20 criaturas, no 800. Lo que se recuerda es la
   *sensación al derrotarlas*. Si 700 se sienten como la misma con otro color, la cantidad deja de ser
   un gancho y pasa a ser un defecto.
2. **El cuello de botella no es el modelo, es el comportamiento.** Cada criatura necesita 2-4 ataques
   con un aviso legible (§3.3) y su equilibrio. Eso no se multiplica con un script.
3. **Rendimiento en móvil.** No sabemos todavía los FPS en tu teléfono (el APK 0.2 y el 0.3 están sin
   probar). Cada criatura hecha con piezas cuesta unas 20,5 piezas (cada una con su contorno:
   el doble de llamadas de dibujo). Con 8 criaturas a la vez ya son unas 330 llamadas.
4. **Competencia directa:** *Nioh* y *Nioh 2* ya mezclan samuráis y yōkai **[Hecho]**; *Pokémon* es el
   rey de coleccionar; *Monster Hunter*, de pocos monstruos con mucha profundidad; *Shin Megami Tensei*,
   de cientos de demonios con negociación y fusión. Nuestro hueco **[Hipótesis]**: **precisión de iaidō +
   mitologías de todo el mundo dentro de un Japón de leyendas**. No conozco un juego que junte las tres cosas,
   pero no he hecho un estudio de mercado: antes de construir el mensaje hay que verificarlo.
5. **Promesa y entrega.** Anunciar «mil» y lanzar con 12 rompe la confianza. Hay que prometer lo que se
   entrega en cada oleada.
6. **Sensibilidad cultural:** 50 entradas son dioses o seres sagrados de religiones vivas, y
   270 piden cuidado (§6).

**Qué lo hace viable:** que la cantidad salga de un **sistema** (familias + piezas + rangos + patrones de
ataque), no de modelar a mano. §3 explica cómo.

### DECISIÓN 12 — Cuál es el gancho
- **OPCIONES:**
  - A) **La cantidad es el gancho principal:** «el juego de los mil monstruos».
  - B) **Precisión + cantidad:** «duelos de iaidō contra el bestiario más grande»; la cantidad apoya, el
    combate de precisión es lo que se juega.
  - C) **La historia es el gancho** (Genzo, Tamamo-no-Mae) y el bestiario es un extra.
- **VENTAJAS:** A es el titular más fácil y viral. B conserva lo que ya funciona (el duelo) y da a cada
  criatura una razón para ser distinta (un aviso, una forma de pararla). C es lo más seguro de producir.
- **RIESGOS:** A obliga a cumplir con cientos de criaturas y deja el combate en segundo plano. B exige
  que cada criatura enseñe algo distinto. C desaprovecha tu idea.
- **COSTE:** A, el más alto (promesa grande). B, medio. C, el más bajo.
- **RECOMENDACIÓN:** **B.** La cantidad atrae; la precisión es lo que hace que cada monstruo valga la
  pena. Y se puede decir con honestidad: *«más de 825 criaturas, con la variante fuerte de
  cada una»* cuando sea verdad, oleada a oleada.
- **SIGUIENTE PASO:** medir cuánto tarda hacer una criatura nueva con el sistema (§7): si pasa de
  4 horas por criatura, el gancho de la cantidad no se sostiene y habría que replantearlo.

### 2.1 Lo que enseñan los datos sobre la variedad

Sobre las 825 utilizables **[Hecho, sale de `bestiario/informe_calidad.md`]**:

- **Cuerpos:** 41 % bípedos, 20 % cuadrúpedos, 11 % flotantes, 11 % alados, 8 % serpentinos, 6 % acuáticos y
  solo 1 % artrópodos. El catálogo está sesgado hacia lo humanoide: **la variedad que se sentirá no puede
  salir del cuerpo, tiene que salir del patrón de ataque** (§3.3).
- **Elementos:** sombra 20 %, agua 17 %, fuego 12 %… y solo 2 % de rayo y 2 % de sangre. Conviene repartir
  mejor los elementos al diseñar cada oleada.
- **Tamaños:** 48 % medianas, 29 % grandes, 16 % pequeñas y 7 % gigantes (54): hay material para jefes
  de sobra.
- **Roles:** entre 7 % y 17 % cada uno; ninguno domina, que es lo que se buscaba.
- **Por cultura:** Grimorios e infierno (80) y Japón (73) son las más grandes; Báltica y uralica solo tiene 2.
  Si quieres que alguna tradición pese más, es el momento de pedir más criaturas de ella.

### 2.2 Lo que dejé marcado para que lo revises

No son errores a corregir sino **decisiones mías que puedes cambiar** (están en la columna `nota`):

| Qué | Cuántas | Qué hice |
| --- | ---: | --- |
| Identidad dudosa (la nota empieza por «Dudosa:»): relleno del catálogo, nombres comparativos o posibles inventos | 77 | Las traté como `generica` o con hipótesis explícita en la nota (p. ej. *Akakor guardian* viene de un bulo moderno; *Thunderbird himalayo* es una invención, el Thunderbird es norteamericano) |
| Cultura corregida respecto a tu catálogo (sus etiquetas de cultura fallaban mucho, §1) | — | Gerión y Tritones a Grecia, Mantícora a Persia, Quetzalcóatl a Mesoamérica, Anansi a África occidental, Uldra a la tradición sami, Camarupa a la India… |
| No son seres: objetos, insectos, personas reales o expresiones | 10 | Fuera del juego: *Kermes* (insecto tintóreo), *Pekapeka* (murciélago), *Babr-e Bayan* (armadura), *Jenny Haniver* (objeto), *Dersu spirit* (cazador real)… |
| Fusionadas | 1 | *Oni* = *Aka-oni* |
| Dioses y seres sagrados de religiones vivas (sensibilidad 2) | 50 | No son enemigos (§6). Revisa sobre todo los guardianes chinos (Qinglong, Baihu, Zhuque, Xuanwu), que dejé en nivel 1, y los de nivel 1 de tradiciones indígenas vivas, que son muchos |
| Casi duplicados que dejé separados a propósito | pocos | *Old Shuck*, *Padfoot* y *Church Grim* son reskins de *Black Shuck*; si prefieres no repetir, se funden |

---

## 3. Cómo se construyen cientos de criaturas

### 3.1 Tres formas de construir una criatura

| Forma | Qué es | Cuántas | Coste por criatura [Hipótesis] |
| --- | --- | ---: | --- |
| **Variante** | Una familia de cuerpo + piezas + paleta | 595 (72 %) | 1-2 horas una vez hecho el sistema |
| **Reskin** | El cuerpo de otra criatura con otra paleta y accesorios (Cadejo blanco/negro, perros negros británicos…) | 128 (16 %) | 15-30 minutos |
| **Propia** | Modelo hecho a medida: anatomía que no sale de una familia (Blemmyes, Ouroboros, hidras) o jefes icónicos (Bahamut, Tiamat, Jörmungandr) | 102 (12 %) | 1-3 días |

Esto responde a tu idea: **modelo propio para las de descripción más rara; las demás se adaptan a
una base**. La clasificación de cada una está en `bestiario/catalogo_limpio.csv`, columna `modelado`.

### 3.2 El sistema: familias, piezas y paleta (probado)

`godot/scripts/criatura_modular.gd` construye una criatura a partir de una **receta**: familia de cuerpo
(7: bípedo, cuadrúpedo, serpentino, alado, acuático, flotante, artrópodo), tamaño (S, M, L, XL),
elemento (10, que da la paleta), rol, partes (cuernos, melena, espinas, máscara, armadura, caparazón,
alas, llamas, aureola, brazos extra, cabeza extra, plato, pico, garrote) y rango. La misma semilla da la
misma criatura. Se anima por código (patas, alas, colas, tentáculos), a 12 poses por segundo como Akira.

**Lo que probé [Hecho]:**
- **Las 929 criaturas del catálogo se construyen sin error** (prueba automática nueva: 1.163
  construcciones, contando el alfa y el silenciado de 1 de cada 8, en 479 ms en la nube), con **20,5
  piezas de media y 42 como máximo** por criatura. La media está dentro del presupuesto de 24;
  el máximo, no: lo que pase de 24 habrá que aligerarlo (o fusionar sus piezas) antes de ponerlo en pantalla
  con otras siete.
- La galería (`--galeria`, o G en la pausa del juego) las muestra: capturas en
  `capturas/actual/bestiario_NN.png`.
- Resultado visual **[Opinión]**: las familias dan siluetas reconocibles y consistentes (un lobo es un
  lobo, una serpiente es una serpiente), pero **parecen juguetes**. Sirve para las variantes, no para
  las criaturas icónicas: el «Bahamut» hecho solo con piezas de familia es un pájaro de palitos
  (página 4 de la galería). Por eso existe la forma «propia».

### 3.3 Patrones de ataque: dónde está la variedad real

Una criatura = cuerpo de familia + **2-4 patrones** según su rol + **1 patrón de firma**. Biblioteca
inicial de 14 patrones, cada uno con su aviso y su respuesta:

| Patrón | Respuesta del jugador |
| --- | --- |
| Embestida en línea | Esquivar de lado |
| Zarpazo corto | Iai a tiempo |
| Golpe cargado (aviso rojo) | No se puede parar: esquivar |
| Salto con caída (la sombra marca el punto) | Apartarse |
| Agarre | Parar o romper |
| Proyectil | **Cortarlo con el iai** (novedad del iaidō) |
| Aliento o cono | Rodear |
| Onda por el suelo | Saltar |
| Invocar enjambre | Corte de luna |
| Curar o proteger a otro | Matar primero al curandero |
| Ilusión o copia | Leer cuál es la real |
| Emboscada | Atender a la señal (sonido o brillo) |
| Maldición | Limpiar con un iai perfecto |
| Barrido amplio de cola | Agacharse o saltar |

Los roles (veloz, poderoso, enjambre, gigante, engaño, distancia, emboscador, apoyo) eligen qué patrones
le tocan; la criatura de firma decide qué la hace única. Eso es lo que hay que **diseñar y equilibrar
criatura a criatura**, y es donde se va el tiempo.

### 3.4 Presupuesto de rendimiento

Hasta conocer los FPS de tu móvil: **como máximo 24 piezas por criatura y 8 criaturas a la vez en
pantalla** [Supuesto]. Si hace falta más, el siguiente paso es fusionar las piezas fijas de cada
criatura en una sola malla (de ~40 llamadas de dibujo a ~6). La galería muestra los FPS: es la
prueba que necesito que hagas en el móvil (pausa → «Galería de criaturas»).

---

## 4. La variante más fuerte (rangos)

| Rango | Nombre | Qué cambia | Coste de arte |
| --- | --- | --- | --- |
| 1 | **Base** | La criatura de la ficha | — |
| 2 | **Alfa** (la variante más fuerte) | Un 20 % más grande, paleta más oscura y saturada, aura del color de su elemento, más cuernos o placas, vida ×1,8, daño ×1,4, aviso un 15 % más corto, **un ataque de firma más** | Casi cero: parámetros de paleta y de tamaño |
| 3 | **Silenciada** | Blanca y gris con ojos huecos, **sin sonido de aviso** (hay que parar mirando), apaga el sonido a su alrededor, vida ×3, daño ×2 | Un shader y una regla de audio. Solo tras el capítulo 4 (DECISIÓN 11) |

Los jefes no tienen rangos: son únicos. Los números son **[Hipótesis]** que se ajustan jugando. La
galería enseña los tres rangos de cuatro criaturas (página 2).

### DECISIÓN 14 — Cuántos rangos
- **OPCIONES:** A) dos (base y alfa); B) tres (base, alfa y silenciada); C) tres más modificadores
  aleatorios (elite, veloz, blindada…).
- **VENTAJAS:** A es lo que pediste, sin más. B enlaza con el Silencio de la historia y da fin de
  juego. C da variedad casi infinita.
- **RIESGOS:** A queda corto para rejugar. B depende de que apruebes la DECISIÓN 11. C hace el
  equilibrio mucho más difícil.
- **COSTE:** A, mínimo. B, bajo. C, medio (más pruebas).
- **RECOMENDACIÓN:** **B**, y C solo después del lanzamiento si hace falta.
- **SIGUIENTE PASO:** poner los multiplicadores en `datos.gd` y probarlos con el oni.

---

## 5. Ángeles y demonios (lo que añadí)

| Grupo | Criaturas | De dónde sale | Sensibilidad |
| --- | ---: | --- | --- |
| **Huestes celestiales** | 17 | Los nueve coros de la tradición cristiana (serafín, querubín, trono, dominación, virtud, potestad, principado, arcángel, ángel) y variantes (caídos de ceniza, hielo y sombra, centinela de luz, coro de ecos…). **Sin arcángeles con nombre** | 1: son figuras de religiones vivas |
| **Infierno** | 80 | Los **72 del *Ars Goetia*** (grimorio del siglo XVII, dominio público; el rango del grimorio —rey, príncipe, duque, marqués, conde, presidente, caballero— sirve de escala de fuerza) y 8 demonios comunes (diablillo, verdugo, condenado, gárgola…) | 0 |
| **Yōkai que faltaban** | 27 | Onibi, hitodama, kodama, karasu-tengu, Sōjōbō, tsuchigumo, nue, kasha, raijū, Yamata no Orochi, gaki, okuri-inu, Daidarabotchi, hannya, **la familia de los oni por colores**, gozu y mezu, ushi-oni, rasetsu, Ibaraki-dōji, hashihime, el oni gigante del portón y Tamamo-no-Mae | 0 (gozu, mezu y rasetsu: 1) |
| **Aliados y guardianes** | 8 | Niō, los cuatro reyes celestiales, Fudō Myōō, tennin | 2: **no son enemigos**, sirven de PNJ en el templo y el dojo |

Los diseños son originales (nada copiado de otros juegos). Los nombres del *Goetia* son de dominio
público, aunque otros juegos los usan. Encajan con tu idea de «criaturas de otras tierras» (10B):
en el capítulo 4 aparecen 3-5 como élites y el resto llega tras el lanzamiento.

**Una idea de historia [propuesta]:** los ángeles y los demonios no son aliados de nadie. Los
ángeles quieren «corregir» un mundo roto con justicia sin piedad; los demonios, aprovecharlo. El
Silencio los amenaza a todos. Eso refuerza el tema del equilibrio que pediste.

---

## 6. Regla de respeto cultural [propuesta]

El catálogo mezcla folclore con seres sagrados de religiones vivas. En una tienda de aplicaciones y en
las reseñas eso puede ser un problema. Propongo una regla **que puedes vetar**:

| Nivel | Qué es | Cuántas | Qué hacemos |
| --- | --- | ---: | --- |
| 0 | Folclore europeo, mitologías antiguas extinguidas, yōkai, críptidos modernos | 619 | Libres como enemigos |
| 1 | Seres que algunas comunidades vivas consideran reales (wendigo, jinn, Mami Wata, taniwha), dioses de culturas indígenas actuales, figuras con riesgo de caricatura, ángeles | 270 | Enemigos, con diseño respetuoso y sin burla |
| 2 | Dioses y seres sagrados de religiones vivas, y seres ancestrales sagrados (Serpiente Arcoíris, Hine-nui-te-pō…) | 50 | **No enemigos**: PNJ, lore o jefes con contexto, o fuera |

El cuaderno de Colab no dibuja las de nivel 2 por defecto. **[Opinión, no es asesoría legal]**: es
más barato evitar la polémica ahora que rediseñar después.

---

## 7. Olas de contenido y capacidad

Cantidades **utilizables como enemigos** por ola, según el catálogo clasificado. La ola sale de la cultura de cada
criatura (columna `ola` del CSV) y es una **base [propuesta]**: unas pocas se mueven a mano para coincidir con
`BESTIARIO.md` §8 (los hobgoblins van en el 3, el ifrit en el 4; las sirenas, Fenrir, el Leviatán y el fénix, tras
el lanzamiento). Cumple tu decisión 10B: **nada que no sea japonés aparece antes del capítulo 3**.

| Ola | Cuándo | Criaturas | Contenido |
| --- | --- | ---: | --- |
| 1 | Capítulo 1 (las 4 de la ficha) | 4 | Kappa, Aka-oni, onibi y el oni gigante del portón |
| 2 | Capítulo 2: el resto de Japón | 69 | Tengu, kitsune, jorōgumo, Yamata no Orochi, Tamamo-no-Mae… |
| 3 | Capítulo 3, cuando despierta Bahamut: el continente y Oriente Próximo | 249 | China, Corea, sudeste asiático, Tíbet, India, Asia central, Mesopotamia, Egipto, Persia, árabe, hebrea |
| 4 | Capítulo 4: Europa | 231 | Grecia, Roma, nórdica, celta, británica, eslava, germánica, francesa e ibérica |
| 5 | Tras el lanzamiento: África, América, Oceanía y lo moderno | 175 | África, las dos Américas, Oceanía, críptidos |
| 6 | Tras el lanzamiento: huestes celestiales e infierno | 97 | Ángeles y los 72 demonios del *Goetia* |

**Lo que propongo prometer [propuesta]:** capítulo 1 con **12 criaturas (24 enemigos con su alfa)**: las
4 de la ficha a mano más 8 variantes. Después, una oleada por capítulo y actualizaciones gratuitas.

**Cuánto trabajo es [Estimación; supuestos: tú y yo, jornada completa, el sistema ya hecho]:**

| Tarea | Cantidad | Horas por unidad | Horas |
| --- | ---: | ---: | ---: |
| Variantes | 595 | 1,5 | 892 |
| Reskins | 128 | 0,4 | 51 |
| Propias | 102 | 16 | 1.632 |
| Comportamiento, equilibrio y pruebas (2-4 patrones y uno de firma, §3.3) | 825 | 2 | 1.650 |
| **Total** | | | **4.226 h ≈ 26 meses a jornada completa (≈ 2,2 años)** |

Es decir: **el catálogo entero es un proyecto de años, no de meses**, y más de un tercio de las horas
no son de arte sino de comportamiento y equilibrio (la fila que más cambia según lo que midamos). La regla
es una oleada por vez y el primer paso es medir el tiempo real de las 10 primeras criaturas (todas estas
horas son **[Hipótesis]**; lo único medido es que construir una criatura con el sistema tarda menos de un
milisegundo).

---

## 8. Cómo se hace el modelo de las «propias»

### DECISIÓN 13 — Cómo se modelan las criaturas icónicas
- **OPCIONES:**
  - A) **Todo con piezas de código:** gratis, ligero, se anima fácil; las icónicas quedan de juguete.
  - B) **Imagen → 3D con IA:** dibujar la criatura en Colab y convertirla en malla 3D con un modelo
    libre (**TripoSR**, licencia MIT **[Hecho]**, unos 6 GB de VRAM, entra en una T4), reducir los
    polígonos y pintarla con el shader toon. Una malla = una sola llamada de dibujo.
  - C) **Híbrido:** piezas para variantes y reskins (88 %) y B (o a mano) para las
    102 propias; antes, una **prueba con 10 criaturas**.
- **VENTAJAS:** A es lo más barato. B da identidad propia a cada icónica en minutos y cabe en el
  presupuesto de dibujo. C usa cada herramienta donde rinde.
- **RIESGOS:** A decepciona en los jefes. B da mallas **sin esqueleto** (se animan con balanceos, no
  con patas que andan), con geometría sucia y estilo distinto al de los conceptos; hay que revisar la
  licencia de cada modelo de imagen de origen. C exige mantener dos sistemas.
- **COSTE:** A, ninguno. B, bajo en dinero (Colab gratis) y medio en tiempo de limpieza. C, la suma.
- **RECOMENDACIÓN:** **C**, con la prueba de 10 como paso previo: si 7 de las 10 mallas te parecen
  al menos «aceptables» (3 de 5), adoptamos B para las propias.
- **SIGUIENTE PASO:** cuando decidas, escribo la receta de Colab C14 (imagen → malla) para las 10 de la
  prueba: Bahamut, Jorōgumo, Yamata no Orochi, Nue, Gashadokuro, Kraken, Tiamat, Quimera, Ouroboros y
  Tamamo-no-Mae.

---

## 9. Imágenes en Colab

- **Cuaderno:** `colab/bestiario_imagenes.ipynb` (para abrirlo tú) y **receta C13** (las C1-C12 ya están en tu carpeta de Colab) en
  `colab/INSTRUCCIONES_COLAB_BESTIARIO.md` (para la sesión que maneja Colab con colab-mcp, en el mismo
  formato que la de Heredera del Hielo). Ambas leen `06-Bestiario/prompts_colab.csv` de tu Drive.
- **Modelo:** SDXL base 1.0 (licencia CreativeML Open RAIL++-M, uso comercial permitido con
  restricciones de uso responsable **[Hecho]**). Opción experimental: Z-Image-Turbo (Apache 2.0 **[Hecho]**, el
  mismo modelo de los conceptos que hice con Higgsfield), que pide GPU de 16 GB o más y **no he probado en T4**.
- **Espacio:** a tu Drive le quedan unos **6,8 GB libres** **[Hecho, medido hoy]**. Las imágenes se guardan en JPG
  (unos 250 KB cada una [Estimación]): las 929 criaturas ocuparían unos 230 MB (el doble con la variante fuerte); las 50 de sensibilidad 2 no se dibujan por defecto.
- **Tiempo:** unos 20 s por imagen en una T4 **[Estimación]**; en tandas de 50. Google no publica el cupo de GPU gratis
  y cambia con la demanda; en foros se habla de unas 15-30 horas a la semana, pero **no lo he verificado
  [Supuesto]**. Las 929 imágenes del rango 1 serían unas 5-6 horas de GPU repartidas en varios días.
- **Estado:** las imágenes **todavía no están hechas**. Hace falta que ejecutes el cuaderno o que lo haga la sesión
  que maneja Colab (tú eliges la GPU T4 y aceptas los permisos). Antes, `prompts_colab.csv` debe estar en
  `Respaldos Claude/ronin/06-Bestiario/` de tu Drive (ya está subido).
- **Qué está probado:** el flujo completo en modo simulado (rutas, reanudación, JPG, hojas de
  contacto). **No está probada la carga ni la difusión de SDXL en una T4.** Si falla, la receta dice que
  se copie el error y se avise.
- **Higgsfield** queda para los conceptos importantes (quedan unos 5,4 créditos, unas 36 imágenes de Z Image).

---

## 10. Cómo validamos

| Prueba | Cómo | Pasa si | Decide |
| --- | --- | --- | --- |
| Velocidad de producción | Hacer 10 criaturas nuevas con el sistema y cronometrar | ≤ 4 h por criatura | Si el gancho de la cantidad se sostiene (DECISIÓN 12) |
| Rendimiento en móvil | Pausa → «Galería de criaturas» en tu teléfono, páginas 3 (7 criaturas) y 5 (24 criaturas) | ≥ 30 FPS con 8 criaturas y ≥ 20 con 24 | El presupuesto de piezas (§3.4) |
| Variedad percibida | Enseñar 10 criaturas a 5-10 personas | Recuerdan ≥ 6 y dicen que ≥ 7 se sienten distintas de vencer | Si la cantidad es un gancho o un defecto |
| Look de las propias | 10 mallas de la prueba de la DECISIÓN 13 | ≥ 7 de 10 puntúan ≥ 3 de 5 | Cómo se modelan las icónicas |

---

## 11. Resumen de decisiones

| # | Decisión | Recomendación |
| --- | --- | --- |
| 11 | El papel del Silencio (`HISTORIA.md` §8) | B: gancho final y rango silenciado |
| 12 | El gancho del juego | B: precisión + cantidad |
| 13 | Cómo se modelan las icónicas | C: híbrido, tras la prueba de 10 |
| 14 | Cuántos rangos | B: base, alfa y silenciada |
| — | Regla de respeto cultural (§6) | Aplicarla, salvo que la vetes |
