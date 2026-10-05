# La investigación del género y el banco de diseño de La caja viva

Lo que salió del encargo del usuario del 04-10-2026 (el método entero está en `../METODO_CAJA_VIVA.md`): investigar el
género, sacar los principios y convertirlos en un banco de ideas para La caja viva. **Principios sí; expresiones
concretas (assets, textos, escenarios, soluciones exactas) no.**

**Marcas** que usan todos los documentos: [Hecho] (sale de una fuente, que se cita) · [Interpretación] ·
[Opinión] · [Estimación] · [Supuesto].

## Para empezar

1. `00_contexto_para_investigar.md`: qué es el juego y las reglas de originalidad que siguen todos los demás (es el
   contexto con el que se investigó, el 04-10-2026: los niveles 3 y final aún eran propuestas).
2. `07_auditoria_caja_viva.md`: qué tenía el juego frente a lo investigado.
3. `08_ROADMAP.md`: el camino hasta un juego que se pueda lanzar, el orden de trabajo y la DECISIÓN 30.

## La investigación

| Archivo | Qué es |
|---|---|
| `the_room_interaccion_y_camara.md` | The Room 1-4 (también Old Sins): interacción y cámara de cada entrega, cómo evoluciona la serie, todos los tipos de puzle y los 10 principios más transferibles |
| `the_room_puzles.csv` | 265 puzles de la serie, uno por fila (qué se descubre, qué se manipula, feedback, dificultad…) |
| `the_room_mecanicas.csv` | 70 mecánicas de la serie, agrupadas (R-001 a R-070) |
| `juegos_A_puzle_box_y_misterio.md` y `juegos_A_mecanicas.csv` | Bloque A: 15 juegos de caja, escape room y misterio |
| `juegos_B_logica_perspectiva_fisica.md` y `juegos_B_mecanicas.csv` | Bloque B: lógica, perspectiva, física y puzle ambiental |
| `juegos_C_grandes_con_puzles.md` y `juegos_C_mecanicas.csv` | Bloque C: juegos grandes, solo por sus puzles, su interacción y su feedback |
| `jugadores_y_principios.md` | Qué valoran y qué odian los jugadores (25.613 reseñas de Steam y 8.682 de la App Store) y qué dicen los diseñadores |
| `catalogo_mecanicas.csv` | Las 330 mecánicas de todo lo anterior en una sola tabla (`../herramientas/unir_mecanicas.py`) |

## La síntesis y el banco de diseño

| Archivo | Qué es |
|---|---|
| `04_matriz_competitiva.md` | La matriz del método (§25): mejor mecánica, mejor puzle, cámara, narrativa, audio, animación, atmósfera y debilidad de cada juego, en qué puede superarlo La caja viva y sus bazas para diferenciarse (§26) |
| `05_gramatica_y_sistemas.md` | La gramática interna (OBJETO puede ROTAR…), los sistemas del juego (S1 la mirada, S2 los cajones…), la curva de dificultad y las políticas de diseño |
| `banco_mecanicas.csv` | 100 mecánicas (M-001 a M-100) |
| `banco_combinaciones.csv` | 50 combinaciones de mecánicas (C-001 a C-050) |
| `banco_puzles.csv` | 100 ideas de puzle (P-001 a P-100), con la plantilla del método (idea, mecánica base, referencia, qué funciona y qué no, transformación, variable nueva, implementación, dificultad y reutilización) |
| `banco_multietapa.csv` | 30 puzles de varias etapas (E-001 a E-030) |
| `banco_tematicos.csv` | 100 puzles temáticos: 20 de perspectiva, 20 de sonido (siempre con su señal visual), 20 de luz, 20 de objetos multifunción y 20 que conectan áreas |

Todos los bancos se puntúan con los nueve criterios del método (§22), de 1 a 5: originalidad, diversión, claridad,
dificultad, implementación, reutilización, relación con la historia, impacto visual e impacto emocional. El total
es su suma (máximo 45). Cada fila dice además el riesgo de parecido con otros juegos y en qué nivel encajaría.
Los CSV usan «;» como separador (se abren con una hoja de cálculo eligiendo ese separador).

## Lo que ya está en el juego (APK 0.5, 05-10-2026)

Lo investigado que ya se juega, por si quieres opinar de cada cosa: la regla del ojo y sus distracciones (luz y
sonido), los cajones que se tiran, la llave que se gira en círculo, la tapa que se levanta, la caja dentro de la caja
y sus tablillas en orden (Hakone), el puzle de bolsillo, el vistazo del ojo como pista sin texto, la luz fría que
revela tinta (la mirada dirigida, en versión propia), el péndulo del rollo, la pieza de dos caras que se corona, el
cajón que suelta un pestillo, la tetera que se vuelca (líquido), combinar objetos en la bandeja, el ritmo de la
respiración, los anillos concéntricos que se alinean con tres señales distintas (vista, luz y oído) y la llave que
viene de un nivel anterior. Detalle de cada nivel en `../ilustrada/NIVELES.md`.
