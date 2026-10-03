# Bocetos de las cuatro cajas (03-10-2026)

**Por qué hay bocetos.** El usuario vio la caja viva profunda y dijo que la idea le gusta, pero que
el diseño está flojo. Pidió bocetos de todo antes de construir nada más, para ver si puede llegar a la
calidad y al esmero de los entornos de The Room. Nada de esto está construido todavía: son la
propuesta que se aprueba o se cambia antes de programar.

- **Cómo se hicieron:** Gemini (`gemini-3.1-flash-image`), con la clave del usuario. Los prompts están
  en `PROMPTS.md`.
  - **Coste:** unos 0,045 USD por imagen; 11 imágenes, unos 0,50 USD **[Estimación]**. El precio sale
    de calculadoras de terceros. Si la clave está en el nivel gratuito, no cuesta.
- **Hojas para el móvil:** `python3 puzles/herramientas/hojas_bocetos.py <carpeta>`. Junta los bocetos
  en columna, con títulos, viñetas numeradas y notas. Las hojas no se suben a git; están en Drive.

## Qué hay

| Archivo | Qué es |
|---|---|
| `caja_viva_a.jpg` | **Caja viva A:** mosaico *yosegi*, máscara de paulownia incompleta y washitsu cálido |
| `caja_viva_b.jpg` | **Caja viva B:** laca negra con oro (*maki-e*), un oni y cajones rojos en el costado |
| `caja_viva_c.jpg` | **Caja viva C:** cómoda *tansu* de cajones; los cajones forman la cara |
| `caja_viva_piezas.jpg` | Las piezas que se llevan de un sitio a otro: ojo dormido, boca con colmillos, cuerno, llave de bambú, ficha de shōgi, incensario, cuatro placas y la tapa del león |
| `caja_viva_a_secuencia.jpg` | Cómo se abre la A, en cuatro viñetas |
| `relojero.jpg` y `relojero_secuencia.jpg` | **El reloj sin corazón:** caja de caoba en el taller de 1891 y cómo se abre |
| `reliquia.jpg` y `reliquia_secuencia.jpg` | **El corazón de cuatro pétalos:** la flor de piedra en el santuario y cómo se abre |
| `farero.jpg` y `farero_secuencia.jpg` | **La lámpara de señales:** el cuarto del farero en la tormenta de 1903 y cómo se resuelve |
| `caja_viva_ac.jpg` y `caja_viva_ac_detras.jpg` | **La elegida (DECISIÓN 27): la A con los cajones de la C**, de frente y por detrás. Son la referencia del modelo de Blender |

## Lectura de cada boceto [Opinión]

**Caja viva A** (la base recomendada):
- **Lo bueno:**
  - es la artesanía real de las cajas secretas de Hakone;
  - la cara incompleta se entiende sola: un ojo, una cuenca vacía, el cuerno que falta y las grietas;
  - la sala es cálida y no distrae;
  - cumple el vocabulario de materiales de la biblia (§14.2).
- **Lo que falta:** que se vea qué se mueve. Las piezas móviles irían en laca bermellón, como manda la
  biblia y como los cajones de la B.

**Caja viva B:**
- **Lo bueno:** es la más viva y amenazante, y la que mejor funciona en una miniatura de tienda o de
  vídeo. Los cajones rojos del costado ya son los satélites.
- **El riesgo:** se parece a un cofre con cara de oni y menos a una caja secreta.

**Caja viva C:** tiene muchísimo que explorar, pero la cara se pierde y cuesta ver que está viva.

**Secuencia de la A:**
- enseña cómo se expande la caja y cómo se lleva cada pieza de un sitio a otro;
- termina con el clímax: la cabeza se levanta y aparece el altar.
- La llave salió de estilo europeo; será de bambú.

**Relojero:**
- Es la secuencia más redonda:
  - la tapa partida;
  - el medallón que gira;
  - el reloj de bolsillo y el de la chimenea como satélites;
  - el pájaro autómata que canta al final, que es una tradición real de la época.
- La sala tiene color propio, como pedía la biblia: papel verde y fuego.
- En el primer boceto la ventanita ya tiene volante; en la secuencia está vacía, que es lo correcto.

**Reliquia:**
- **Error del primer boceto:** los huecos (triángulo, cuadrado, círculo y rombo) recuerdan a los
  botones de PlayStation. Venían del prompt; en la secuencia ya son una luna, un ojo, una ola y una
  semilla.
- **Lo bueno:** los cuatro nichos de la pared (un disco, unas losas, una pila de agua y un brasero)
  reparten el puzle por la sala.
- **El riesgo:** es la línea con la identidad más genérica; se parece a muchas reliquias de fantasía.

**Farero:**
- La habitación es la caja: el baúl, la librería, el barómetro, la trampilla y el diario son los
  satélites de la lámpara.
- Revisar con el anexo B de la biblia:
  - la línea no puede acabar en «encender la lámpara»; esta es la caja 1, no la última;
  - el barco en la botella es decorado, nunca una miniatura en la que se entra.

## Control de originalidad (anexo B de la biblia)

| Elemento | ¿Roza la referencia? | Qué hacer |
|---|---|---|
| La cara incompleta de la caja viva | Bajo: en Old Sins se arregla una máscara de madera copiando una de metal | Lo nuestro es buscar las piezas por la sala; nunca copiar otra máscara |
| El pájaro autómata del relojero | Bajo: en la referencia hay un pájaro de verdad en una jaula que grazna | Mantener: las cajas de pájaro cantor son un objeto real del siglo XIX |
| Los huecos con formas de la reliquia | No (pero recordaban a PlayStation) | Usar los símbolos propios: luna, ojo, ola y semilla |
| La caja 2 del farero, «Sombras» (girar objetos hasta formar una silueta) | **Medio:** The Room Three tiene gemas que se giran hasta que su sombra forma un pájaro | Añadir la fila a la biblia y cambiar la mecánica al diseñar esa caja |

## Si se puede construir con esta calidad [Opinión técnica]

- **Lo que sale bien por código** (como ahora en Godot):
  - salas, luz y ambiente;
  - cajas con paneles, cajones, laca, *yosegi* y esquinas de metal;
  - esferas, engranajes, anillos, el baúl y la librería.
- **Lo que sale con más trabajo, también por código:**
  - piezas torneadas: incensario, tetera, quinqué, bisel del reloj y lámpara de señales;
  - aristas biseladas que atrapen la luz. Es lo que más distingue a un objeto «caro» de uno hecho con
    cajas.
- **Lo que no sale bien por código:** las piezas orgánicas, que son pocas por caja:
  - la cara tallada;
  - el león de la tapa;
  - el pájaro;
  - la filigrana.

Por eso se propone la **DECISIÓN 28** (`PLAN.md` §5): cómo se fabrican esas piezas. Antes de rehacer
una caja entera, se haría una **prueba de calidad**: el frente de la caja elegida con su mesa y su
incensario, junto al boceto.
