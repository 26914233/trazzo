# Hoja de ruta: familia de juegos (Godot 4.7 → Google Play)

Orden acordado: uno completo primero y después los demás sobre el mismo molde.

| # | Juego | Estado | Esfuerzo estimado* |
|---|---|---|---|
| 1 | **Palabrario** — sopa de letras | **Casi terminado, en espera**: 545 sopas, app de pago + paquetes de pistas, auditado, APK y AAB exportados. Se sube cuando la cuenta de Play esté lista (`palabrario/docs/LANZAMIENTO.md`) | — |
| 2 | **Lienzo Zen** — colorear (749 láminas), dos formas de pintar | **En curso** | Medio |
| 3 | **Rebotazz** — romper ladrillos (tipo «Brick Breaker») | **En curso**: núcleo jugable, 120 niveles en 6 mundos, 7 potenciadores; falta modo infinito, desafío diario, logros y ficha (`rebote/docs/GDD.md`) | Bajo-medio |
| 4 | **Zona Zero** — supervivencia zombi 2D | Diseño abajo, alcance recortado | Alto |

\* Relativo entre ellos, no en horas: depende de cuánto arte nuevo haga falta.

## Modelo de negocio común

Decisión del dueño: **apps de pago de 4,99 US$, todo incluido, sin anuncios ni compras
dentro** (Palabrario y Lienzo Zen). Ver `palabrario/docs/MONETIZACION.md`. El código de
anuncios y compras que se escribió y probó para Palabrario está en el historial de git
(hasta el commit `e0ed81a`) si algún juego necesitara un modelo gratis.

**Revisado el 2026-10-10 tras el análisis de competencia** (`ANALISIS_COMPETENCIA.md`): el
dueño mantiene **app de pago a 4,99 US$** para Palabrario y Lienzo Zen, sin anuncios, aun
sabiendo que 32 de 33 competidores son gratis y que en Play no hay prueba para apps de pago.

## Lo que se reutiliza de Palabrario (el molde)

Se copia y se adapta, sin convertirlo en un framework hasta que haya un segundo
juego que lo use de verdad:

- `autoload/progreso.gd` — guardado firmado con HMAC y escritura atómica.
- `scripts/estilo.gd` — diseños intercambiables (Cielo, Papel, Noche), botones,
  tarjetas, diálogos, avisos y zona segura.
- `tests/pruebas.tscn` (patrón, con contraste y carga de pantallas), `tests/capturas.tscn`.
- `herramientas/construir_temas.py` — patrón de contenido en texto validado → JSON.
- `export_presets.cfg` (sin permisos de red), `.gitignore`, `docs/PUBLICAR.md`,
  `PLAY_DATA_SAFETY.md` ("no recoge datos").

## Mejoras hechas tras el análisis de competencia (octubre 2026)

Método replica (copiar la función, no el código ni el arte): matriz en
`replica/features.csv`, paridad en `replica/parity.md` (89/100).

- **Palabrario:** logros, sopa al azar, comodín de racha, estadísticas, palabras extra,
  contrarreloj opcional, diseño de alto contraste, mapa de viaje con medallas y eventos
  de temporada.
- **Lienzo Zen:** buscar zona sin pintar, celebración al terminar, guardar imagen,
  lámina del día con racha, ocultar terminadas, Mis colores, música ambiental, ajustes y
  misterio de la semana.

## Para actualizaciones futuras (decisión del dueño: después del lanzamiento)

No bloquean la primera versión; se suben como actualizaciones.

| Juego | Qué | Qué hace falta |
|---|---|---|
| Lienzo Zen | Compartir la imagen y ponerla de fondo de pantalla | Plugin de Android (intent de compartir y WallpaperManager) |
| Lienzo Zen | Repetición en vídeo (time-lapse) de la obra | Guardar el orden de pintado y codificar vídeo en el teléfono (plugin) |
| Lienzo Zen | Láminas de eventos (Navidad, Halloween…) | Generarlas en Colab con el mismo flujo de las láminas, junto a la tanda de criaturas |
| Lienzo Zen | Modo «por números» opcional en una selección | Numerar zonas por lámina; solo si los datos de uso lo piden |
| Palabrario | Clasificación de la sopa del día y logros en la nube | Google Play Games (cuenta de desarrollador activa) |
| Palabrario | Copia del progreso en la nube | Google Play Games (Saved Games) |
| Palabrario | Compartir el resultado de la sopa del día | Intent de compartir de Android (plugin) |
| Los dos | Validar en teléfono que la imagen guardada salga en la galería | Prueba en dispositivo; si no aparece, plugin de MediaStore |

---

## 2. Lienzo Zen — dibujo, colorear y mandalas

**Qué es:** tres modos en una app tranquila: *Colorear* (dibujos con zonas que se
rellenan con un toque), *Mandalas* (simetría radial: lo que trazas se repite en 6–16
sectores) y *Lienzo libre* (pinceles, goma, deshacer).

**Por qué funciona en Play:** "colorear para adultos" y "mandalas" son búsquedas con
mucho volumen y público que paga por contenido sin interrupciones.

**Núcleo técnico:**
- Relleno por zonas: cada dibujo es una imagen de líneas + un mapa de regiones
  precalculado (flood fill offline), así colorear es instantáneo en móviles baratos.
- Mandalas: un solo trazo que se dibuja N veces rotado (y espejado opcional).
- Deshacer con historial de trazos, no de imágenes (memoria).
- Guardar y compartir la obra como PNG (Android share intent).

**Monetización:** app de pago de 4,99 US$ con todos los dibujos, mandalas, paletas y
pinceles incluidos; sin anuncios ni compras (mismo modelo que Palabrario).

**Riesgo principal:** el contenido. Cada dibujo es arte. Hace falta un flujo para
producir láminas (vectoriales propias o generadas y retocadas) con licencia clara.
**Ojo con Familias:** colorear atrae a niños. Sin anuncios ni datos es mucho más fácil
cumplir la política de Familias de Play, pero hay que revisarla si se apunta a menores.
**Nombre:** "Lienzo Zen" es de trabajo; buscarle uno a la altura de Palabrario.

---

## 3. Rebotazz — plataforma, bola y bloques

**Qué es:** el clásico de romper bloques: una plataforma abajo que mueves con el dedo,
una bola que rebota, bloques arriba que se rompen. Que no caiga la bola.

**Diferencial propuesto:** niveles con forma (dibujos de píxeles hechos de bloques),
power-ups clásicos (bola múltiple, plataforma ancha, imán, láser) y un modo infinito
con bloques que bajan.

**Núcleo técnico:**
- Física propia y simple (reflexión AABB/círculo), no el motor de física: rebotes
  deterministas y sin "túneles" a alta velocidad (subpasos por frame).
- Ángulo de salida según dónde golpea la bola en la plataforma: es lo que da control.
- Niveles en JSON (rejilla de caracteres), editor mínimo para hacerlos rápido.

**Monetización (por decidir; el dueño solo fijó el pago único para Palabrario y Lienzo Zen):** vidas extra con premiado al perder (*continuar*), power-ups de
inicio con fichas, paquetes de niveles, quitar anuncios. Aquí sí hay derrota: el
intersticial va tras 2–3 partidas y el "continuar con anuncio" es el premiado estrella.

**Riesgo principal:** es un género saturado; vive del *feel* (rebote, sonido, partículas).
Usar `motion-design` para el juice y `balance-check` para la curva de velocidad.

---

## 4. Zona Zero — supervivencia zombi 2D (alcance recortado)

**Lo que NO es:** un Project Zomboid. Zomboid es un simulador isométrico enorme con
años de desarrollo y equipo. Copiar ese alcance no se termina nunca.

**Lo que sí es:** un roguelike de supervivencia top-down por partidas de 15–25 min:
mapa pequeño generado, buscar comida/agua/armas en casas, fabricar lo básico,
atrincherarse de noche ante hordas, sobrevivir N días. Muerte permanente; lo que se
desbloquea entre partidas son personajes y ventajas.

**Núcleo técnico (por orden de riesgo):**
1. IA de zombis barata en masa: campo de flujo (flow field) hacia el jugador/ruido en
   vez de A* por zombi; LOD de IA para los lejanos.
2. Ruido y visión: correr/disparar atrae, la oscuridad limita lo que ves.
3. Inventario por peso, necesidades (hambre, sed, sueño, heridas) y crafteo corto.
4. Ciclo día/noche y oleadas; generación de mapas por plantillas de manzanas.

**Monetización (por decidir):** premium-lite: personajes y modos con fichas, premiado para revivir
una vez por partida, sin pay-to-win. Considerar también versión de pago única.

**Riesgo principal:** alcance y rendimiento en móviles baratos. Empezar con un
prototipo (`prototype`) que pruebe solo 1–2 (zombis en masa + ruido) antes de nada más,
y escribir su GDD con `design-system` y `map-systems` antes de producir.

---

## Siguiente paso recomendado

1. Palabrario: en espera de la cuenta de Play; luego prueba en un móvil y subida a
   prueba interna (`palabrario/docs/LANZAMIENTO.md`).
2. En curso: **Lienzo Zen**, con el mismo modelo de pago: falta la tanda de criaturas de
   Colab, los gráficos de la ficha, la auditoría de seguridad y la prueba en un teléfono.
3. Las mejoras de la tabla «Para actualizaciones futuras», después del lanzamiento.
