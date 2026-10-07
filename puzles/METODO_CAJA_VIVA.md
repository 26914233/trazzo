# Método de La caja viva: el encargo del usuario (04-10-2026)

El usuario lo envió el 04-10-2026 como guía de trabajo para todo el juego. Va tal cual, con sus palabras. Lo
que se hizo con él está en `genero/` (investigación, bases de datos, banco de ideas, auditoría y roadmap).
Los comandos del final (INVESTIGAR, DESMONTAR, COMBINAR, PUZZLES, ANIMACIONES y SIGUIENTE) valen para las
próximas sesiones: `CLAUDE.md` los resume.

---

OBJETIVO PRINCIPAL

Quiero crear un juego propio que pertenezca claramente al mismo tipo de experiencia:

PUZZLE BOX
+
EXPLORACIÓN
+
MANIPULACIÓN 3D
+
MISTERIO
+
MECANISMOS
+
DESCUBRIMIENTO
+
NARRATIVA AMBIENTAL
+
PUZZLES ENCADENADOS.

The Room será una de las referencias PRINCIPALES, pero no la única.
Debes estudiar profundamente el género y utilizar las mejores ideas de diferentes juegos para construir una experiencia propia.

# 1. INVESTIGACIÓN PROFUNDA DEL GÉNERO

Investiga videojuegos de:

PUZZLE BOX
ESCAPE ROOM
PUZZLE ADVENTURE
ENVIRONMENTAL PUZZLE
LOGICAL PUZZLE
PHYSICS PUZZLE
MECHANICAL PUZZLE
MYSTERY PUZZLE
EXPLORATION PUZZLE.

Como mínimo analizar:

THE ROOM
THE ROOM TWO
THE ROOM THREE
THE ROOM: OLD SINS

Y estudiar también, cuando sea útil:

Myst
Riven
The House of Da Vinci
The House of Da Vinci 2
The House of Da Vinci 3
Machinika Museum
Boxes: Lost Fragments
Escape Simulator
The Witness
The Witcher 3
Portal
Portal 2
The Talos Principle
The Talos Principle 2
Baba Is You
Q.U.B.E.
Antichamber
Superliminal
Viewfinder
Gorogoa
Return of the Obra Dinn
Outer Wilds
Keep Talking and Nobody Explodes
Monument Valley
Inside
Limbo
The baldur Gate 3
Expedition 33
Litke nightmare
Tetris
Astro bot
It take two
God of war
Dragón age inquisición
GTA 5
The legend of Zelda tears of the kindon, breath of the wild, echos of wisdom, ocarina of time
Mario Odyssey
Blue Prince
Riven
Tunic
Senue saga
Stellar blade
Wukong

Puedes copiar elementos de todos.

La finalidad es descubrir:

¿QUÉ MECÁNICAS FUNCIONAN?

¿POR QUÉ FUNCIONAN?

¿EN QUÉ CONTEXTO FUNCIONAN?

¿CÓMO PUEDEN TRANSFORMARSE?

# 2. ESTUDIO ESPECÍFICO DE THE ROOM

Analiza individualmente:

THE ROOM
THE ROOM TWO
THE ROOM THREE
THE ROOM: OLD SINS

Para cada juego estudiar:

## INTERACCIÓN

- tocar;
- arrastrar;
- deslizar;
- rotar;
- mantener pulsado;
- girar;
- hacer zoom;
- inspeccionar;
- combinar;
- introducir objetos;
- retirar objetos;
- activar mecanismos.

CÁMARA

- vista general;
- vista cercana;
- zoom;
- rotación;
- cambio de perspectiva;
- transición entre espacios;
- vistas internas;
- vistas de mecanismos.

PUZZLES

Identificar TODOS los tipos de puzzle que aparezcan.

No limitarse a decir:

"Hay puzzles de combinación."

Describir:

- qué información recibe el jugador;
- qué debe descubrir;
- qué variable manipula;
- qué reglas existen;
- qué hace que sea difícil;
- qué hace que la solución resulte satisfactoria;
- qué feedback recibe;
- qué recompensa obtiene.

# 3. CATÁLOGO DE MECÁNICAS

Construir una DATABASE:

| ID | Juego | Mecánica | Tipo | Dificultad | Habilidad requerida | Feedback | Cómo podría adaptarse |
|----|------|----------|------|------------|---------------------|----------|------------------------|

Ejemplos de categorías:

ROTACIÓN · DESLIZAMIENTO · COMBINACIÓN · SECUENCIA · SIMETRÍA · PATRONES · ENGRANAJES · PALANCAS · RUEDAS ·
DIALES · LLAVES · CERRADURAS · SÍMBOLOS · LUCES · SONIDOS · PESO · FÍSICA · PERSPECTIVA · ESCALA · REFLEJOS ·
SOMBRAS · TIEMPO · MEMORIA · OBSERVACIÓN · ORDEN · CONEXIONES · TRANSFORMACIÓN · CONSTRUCCIÓN · DESMONTAJE ·
RECONSTRUCCIÓN · COMBINACIÓN DE OBJETOS · INFORMACIÓN CRUZADA · PUZZLES MULTIZONA · PUZZLES MULTIOBJETO.

Una mecánica encontrada en otro juego puede:

A. utilizarse como referencia directa del principio;
B. modificarse;
C. combinarse con otra;
D. invertirse;
E. introducir una nueva variable;
F. cambiar de contexto;
G. combinarse con narrativa;
H. convertirse en una mecánica completamente nueva.

Ejemplo conceptual: MECÁNICA A + MECÁNICA B = NUEVO PUZZLE.

No quiero una colección de puzzles aislados. Quiero SISTEMAS QUE PUEDAN GENERAR PUZZLES.

# 5. COMBINAR MECÁNICAS

Busca combinaciones interesantes.

Ejemplo: ROTACIÓN + LUZ + SÍMBOLOS + SOMBRA puede convertirse en un puzzle donde: el jugador rota una pieza, la
luz cambia, la sombra proyecta un símbolo, ese símbolo proporciona información para otro mecanismo.

Otro ejemplo: PESO + ENGRANAJES + ORDEN puede convertirse en un mecanismo donde colocar pesos en determinadas
posiciones modifica una transmisión mecánica.

Crear nuevos puzzles utilizando principios conocidos.

# 6. MECÁNICAS DE DIFERENTES JUEGOS

Busca oportunidades para combinar: The Room + Portal + The Witness + Talos Principle + Myst + Superliminal +
Gorogoa + Baba Is You y demás.

Ejemplo: The Room: manipulación física. The Witness: aprender reglas mediante observación. Portal: relación
espacial. Superliminal: perspectiva/escala. Gorogoa: composición visual. Talos: introducción progresiva de reglas.

Resultado: UNA MECÁNICA NUEVA.

# 7. SISTEMA DE "IDEAS DE PUZZLES"

Cuando encuentres una mecánica interesante: NO la implementes inmediatamente. Primero crear:

## IDEA
## MECÁNICA BASE
## REFERENCIA DE DISEÑO
## QUÉ FUNCIONA
## QUÉ NO FUNCIONA
## TRANSFORMACIÓN
## NUEVA VARIABLE
## IMPLEMENTACIÓN
## DIFICULTAD
## POSIBLE REUTILIZACIÓN.

# 8. PUZZLES CON MÚLTIPLES SOLUCIONES

Investiga juegos que permitan diferentes soluciones. Analiza cuándo es beneficioso.

Diseñar algunos puzzles donde SOLUCIÓN A, SOLUCIÓN B, SOLUCIÓN C puedan conducir al mismo resultado.

Pero solamente cuando: tenga sentido; no destruya la dificultad; no genere bugs; sea posible implementarlo de
forma estable. La existencia de varias soluciones debe ser intencional.

# 9. PUZZLES CON INFORMACIÓN CRUZADA

Una mecánica importante de LA CAJA VIVA debe ser: INFORMACIÓN EN UN LUGAR ↓ UTILIZADA EN OTRO.

Ejemplo: El jugador descubre un patrón en una caja. Pero ese patrón no abre esa caja. Después descubre otro
mecanismo donde ese patrón tiene significado.

Esto genera: "AHORA ENTIENDO PARA QUÉ SERVÍA ESO."

Priorizar este tipo de conexiones.

# 10. PUZZLES QUE SE TRANSFORMAN

Una caja puede cambiar durante el juego.

ESTADO 1 Caja cerrada. ↓ ESTADO 2 Primer mecanismo desbloqueado. ↓ ESTADO 3 Se despliega una nueva sección. ↓
ESTADO 4 Aparece un mecanismo interno. ↓ ESTADO 5 El jugador descubre otra perspectiva. ↓ ESTADO 6 La caja se
transforma nuevamente.

El jugador debe sentir que: NO ESTÁ ABRIENDO UNA CAJA. ESTÁ DESCUBRIENDO CÓMO FUNCIONA.

# 11. OBJETOS MULTIFUNCIÓN

Diseñar objetos que puedan tener más de una utilidad.

Ejemplo: OBJETO A. Primero: sirve como llave. Después: se transforma. Después: sirve como herramienta. Después:
revela información.

Evitar que cada objeto tenga una única función obvia.

# 12. ESCALA Y MICRO-MUNDOS

Investigar cómo utilizar: miniaturas; mecanismos internos; objetos dentro de objetos; mundos pequeños; vistas
ampliadas; cambios de escala.

Analizar especialmente las ideas de mundos en miniatura y exploración de diferentes escalas utilizadas por juegos
del género.

Crear una versión propia para LA CAJA VIVA.

# 13. PERSPECTIVA COMO MECÁNICA

La cámara no debe ser únicamente visual. Debe poder formar parte del puzzle.

Investigar: ángulos; perspectiva; paralaje; sombras; reflejos; profundidad; escala; composición; líneas
visuales.

Diseñar puzzles donde: desde una posición NO se entiende nada. pero desde otra: TODO ENCAJA.

# 14. ANIMACIÓN COMO PARTE DEL PUZZLE

La animación también debe utilizarse para embellecer.

Debe comunicar: causa; efecto; progreso; desbloqueo; transformación; peso; energía; dirección; estado.

Cada mecanismo importante debe responder visualmente.

Ejemplo: PLAYER gira rueda ↓ engranajes comienzan a moverse ↓ una pieza se desplaza ↓ un mecanismo se
desbloquea ↓ otra parte de la caja se abre.

El jugador debe poder ENTENDER la relación causa → efecto viendo la animación.

# 15. ANIMACIÓN FÍSICA

Analizar el movimiento realista de: engranajes; ruedas; pistones; palancas; bisagras; cajones; puertas;
mecanismos; cadenas; resortes; piezas metálicas; piezas de madera.

Evitar: movimientos instantáneos; objetos flotando; piezas atravesándose; falta de inercia; pivotes incorrectos.

Añadir: aceleración; desaceleración; pequeñas vibraciones; resistencia; rebote controlado; sonidos
sincronizados.

# 16. AUDIO COMO MECÁNICA

Investigar cómo el sonido puede ayudar al jugador.

Ejemplo: CLICK = interacción. CLACK = posición correcta. SONIDO MECÁNICO = mecanismo activo. SONIDO GRAVE = gran
desbloqueo. SILENCIO = posible tensión.

Diseñar audio funcional, no solamente música ambiental.

# 17. PUZZLES SENSORIALES

Explorar: VISUAL, AUDIO, VIBRACIÓN, LUZ, MOVIMIENTO, SONIDO.

No depender siempre de texto.

# 18. SISTEMA DE APRENDIZAJE

Cada nueva mecánica debe introducirse: 1. Mostrar. 2. Permitir experimentar. 3. Enseñar regla. 4. Combinar.
5. Variar. 6. Dominar. 7. Sorprender.

Introducir una mecánica compleja con preparación.

# 19. CURVA DE DIFICULTAD

Crear: NIVEL 1 aprendizaje. NIVEL 2 aplicación. NIVEL 3 combinación. NIVEL 4 variación. NIVEL 5 dominio.
NIVEL 6 combinación avanzada. NIVEL FINAL síntesis de conocimientos.

# 20. SISTEMA DE PUZZLE GRAMMAR

Crear una gramática interna del juego. Por ejemplo:

OBJETO puede ROTAR. ROTACIÓN puede CAMBIAR POSICIÓN. POSICIÓN puede ACTIVAR MECANISMO. MECANISMO puede REVELAR
OBJETO. OBJETO puede PROPORCIONAR INFORMACIÓN. INFORMACIÓN puede RESOLVER OTRO MECANISMO.

Así el juego genera profundidad sin necesitar una mecánica completamente nueva en cada puzzle.

# 21. BASE DE DATOS DE PUZZLES

Crear una biblioteca con mínimo: 100 ideas de mecánicas. 100 ideas de puzzles. 50 combinaciones de mecánicas.
30 puzzles de múltiples etapas. 20 puzzles que utilicen perspectiva. 20 puzzles que utilicen sonido. 20 puzzles
que utilicen iluminación. 20 puzzles que utilicen objetos multifunción. 20 puzzles que conecten diferentes áreas.

Significa que todos pueden entrar al juego.

Es un banco de diseño.

# 22. FILTRADO

Después de generar ideas: Puntuar cada una: ORIGINALIDAD, DIVERSIÓN, CLARIDAD, DIFICULTAD, IMPLEMENTACIÓN,
REUTILIZACIÓN, RELACIÓN CON HISTORIA, IMPACTO VISUAL, IMPACTO EMOCIONAL.

# 23. INVESTIGACIÓN CONTINUA

Cuando exista un problema de diseño: INVESTIGA. No improvises siempre.

Buscar: análisis de diseño; entrevistas de desarrolladores; documentación; GDC; postmortems; análisis de
jugadores; walkthroughs; gameplay; reseñas; comunidades; documentación técnica.

Pero diferenciar: HECHO, OPINIÓN, INTERPRETACIÓN.

# 24. INVESTIGACIÓN DE JUGADORES

Analizar qué jugadores consideran: satisfactorio; frustrante; intuitivo; confuso; memorable; repetitivo.

Usar esta información para mejorar el diseño.

# 25. COMPARACIÓN CON COMPETIDORES

Crear: MATRIZ COMPETITIVA

| Juego | Mejor mecánica | Mejor puzzle | Cámara | Narrativa | Audio | Animación | Atmósfera | Debilidad |

Después: ¿En qué puede LA CAJA VIVA superar a cada uno?

# 26. DIFERENCIACIÓN

Con que llegue al nivel que pueda ser reconocido o hasta superarlo.

Puede ser: una estructura narrativa diferente; puzzles conectados; objetos multifunción; transformación de
cajas; perspectiva; mecánicas de escala; investigación; sistemas de pistas; múltiples soluciones; narrativa
ambiental; combinación de varios tipos de puzzle.

Investigar primero.

# 27. SISTEMA DE "WOW MOMENT"

Diseñar momentos memorables.

Ejemplo: El jugador cree que terminó una caja. ↓ La caja comienza a transformarse. ↓ Se revela un espacio oculto.
↓ Ese espacio contiene otra estructura. ↓ El jugador descubre que la caja era solamente una parte de algo mucho
mayor.

Crear momentos propios. Y que tengan animaciones de revelación como si fuera un vídeo.

# 28. REGLA DE COMBINACIÓN

Una nueva mecánica puede provenir de: MECÁNICA EXISTENTE + NUEVO CONTEXTO + NUEVA REGLA + NUEVA PRESENTACIÓN.

Esto puede producir una mecánica original aunque sus componentes individuales sean conocidos.

Usar como referencia para usar: assets; modelos; texturas; sonidos; música; personajes; textos; logos;
escenarios; soluciones exactas; secuencias idénticas.

SÍ estudiar: principios; categorías; estructuras; patrones; mecánicas generales; sistemas de interacción;
métodos de tutorialización; curvas de dificultad; estructuras de progresión.

# 30. OBJETIVO DE CALIDAD

Quiero que cuando un jugador diga: "Esto me recuerda a The Room", eso sea una BUENA SEÑAL.

# 31. DESARROLLO REAL

Después de la investigación: Quiero que la investigación se convierta en: sistemas; mecánicas; puzzles; niveles;
animaciones; cámaras; objetos; interacciones; audio; progresión.

# 32. LOOP PRINCIPAL

INVESTIGAR ↓ ANALIZAR ↓ EXTRAER PRINCIPIO ↓ COMPARAR CON OTRAS MECÁNICAS ↓ COMBINAR ↓ CREAR VARIACIONES ↓ FILTRAR
↓ DISEÑAR ↓ IMPLEMENTAR ↓ ANIMAR ↓ AÑADIR AUDIO ↓ PROBAR ↓ OBSERVAR FRUSTRACIÓN ↓ CORREGIR ↓ VOLVER A PROBAR ↓
PULIR.

# 33. CUANDO ENCUENTRES UNA BUENA MECÁNICA

No preguntes inmediatamente si debe entrar.

Evalúa: ¿Mejora el juego? ¿Es coherente con el mundo? ¿Es suficientemente clara? ¿Puede combinarse con otras?
¿Puede producir más puzzles? ¿Puede escalar en dificultad? ¿Tiene buen feedback? ¿Es viable técnicamente? ¿Es
memorable?

Si responde positivamente a la mayoría: IMPLEMENTACIÓN.

# 34. PRIORIDAD

Siempre priorizar: 1. Jugabilidad. 2. Calidad de puzzles. 3. Progresión. 4. Interacción. 5. Animaciones.
6. Cámara. 7. Feedback. 8. Audio. 9. Visuales. 10. Detalles.

Un puzzle excelente con gráficos buenos vale más que un escenario espectacular con puzzles malos.

# 35. AUDITORÍA FINAL

Antes de declarar terminado: ¿La interacción es satisfactoria? ¿Los puzzles son variados? ¿Las soluciones son
lógicas? ¿Hay momentos de descubrimiento? ¿Hay puzzles conectados? ¿Hay mecánicas combinadas? ¿La cámara ayuda?
¿Las animaciones explican los mecanismos? ¿Los sonidos refuerzan las acciones? ¿La progresión funciona? ¿La
dificultad aumenta? ¿El jugador sabe qué puede hacer? ¿El jugador sabe cuándo consiguió algo? ¿Existen puntos
muertos? ¿Hay bugs? ¿El rendimiento móvil es aceptable?

# 36. COMANDO "INVESTIGAR"

Cuando escriba: INVESTIGAR [TEMA], investiga profundamente ese tema. No te limites a una fuente. Compara varias
fuentes.

Entrega: hallazgos; principios; ejemplos; posibles aplicaciones; riesgos; propuesta para LA CAJA VIVA.

# 37. COMANDO "DESMONTAR"

Cuando escriba: DESMONTAR [JUEGO], analiza ese juego como diseñador. Inspírate en el contenido.

Descompón: core loop; interacción; mecánicas; puzzles; progresión; cámara; feedback; animaciones; audio;
narrativa; dificultad; recompensas.

Después identifica qué principios pueden adaptarse.

# 38. COMANDO "COMBINAR"

Cuando escriba: COMBINAR, selecciona varias mecánicas investigadas y crea: combinaciones; variaciones; puzzles;
sistemas; posibles niveles. Incluso combinaciones arbitrarias que tengan sentido y lógica.

# 39. COMANDO "PUZZLES"

Cuando escriba: PUZZLES, generar y revisar puzzles. Puedes utilizar estructuras. Buscar variedad.

# 40. COMANDO "ANIMACIONES"

Cuando escriba: ANIMACIONES, auditar cada mecanismo. Crear: OBJETO → TRIGGER → ANIMACIÓN → SONIDO → FEEDBACK →
CAMBIO DE ESTADO.

# 41. COMANDO "SIGUIENTE"

Cuando escriba: SIGUIENTE, selecciona automáticamente la tarea de mayor impacto. No preguntes qué hacer si existe
una siguiente acción evidente.

# 42. RESULTADO FINAL

LA CAJA VIVA debe convertirse en: un puzzle adventure 3D táctil, con una fuerte influencia de varios géneros, con
la satisfacción de manipular objetos de The Room, la lógica progresiva de grandes juegos ganadores del GOTY y muy
valorados por la comunidad, la exploración de juegos de misterio, la utilización inteligente de perspectiva, la
combinación de mecánicas, la transformación de objetos, la investigación, la narrativa ambiental, y una identidad
"más cajas".

Crear: UN SISTEMA DE PUZZLES. UN MUNDO. UNA EXPERIENCIA.

# PRIMERA TAREA

Antes de modificar el proyecto:

1. Investiga profundamente The Room 1.
2. Investiga The Room Two.
3. Investiga The Room Three.
4. Investiga The Room: Old Sins.
5. Construye una base de datos de sus mecánicas y tipos de puzzle.
6. Investiga al menos los 25 juegos adicionales de puzzle y de otros géneros.
7. Construye una matriz comparativa.
8. Identifica las mejores mecánicas.
9. Identifica cuáles pueden combinarse.
10. Propón 30 o más mecánicas potenciales para LA CAJA VIVA.
11. Propón 50 o más conceptos de puzzles.
13. Determina cuáles son técnicamente viables para el proyecto actual.
14. Después audita el proyecto existente.
15. Finalmente crea el ROADMAP de desarrollo.

NO empieces eliminando ni reconstruyendo sistemas existentes.

Primero comprende el proyecto.

Después desarrolla. Y creas el APK para probar.
