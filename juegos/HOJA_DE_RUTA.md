# Hoja de ruta: familia de juegos (Godot 4.7 → Google Play)

Orden acordado: uno completo primero y después los demás sobre el mismo molde.

| # | Juego | Estado | Esfuerzo estimado* |
|---|---|---|---|
| 1 | **Palabrario** — sopa de letras (antes "Palabrario") | 545 sopas, app de pago, APK y AAB exportados. Falta lo de `palabrario/docs/LANZAMIENTO.md` | — |
| 2 | **Pintazz** (nombre de trabajo) — dibujo libre, colorear y mandalas | Diseño abajo | Medio |
| 3 | **Rebotazz** — plataforma, bola y bloques | Diseño abajo | Bajo-medio |
| 4 | **Zona Zero** — supervivencia zombi 2D | Diseño abajo, alcance recortado | Alto |

\* Relativo entre ellos, no en horas: depende de cuánto arte nuevo haga falta.

## Modelo de negocio común

Decisión del dueño: **apps de pago de 4,99 US$, todo incluido, sin anuncios ni compras
dentro** (Palabrario y Pintazz). Ver `palabrario/docs/MONETIZACION.md`. El código de
anuncios y compras que se escribió y probó para Palabrario está en el historial de git
(hasta el commit `e0ed81a`) si algún juego necesitara un modelo gratis.

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

---

## 2. Pintazz — dibujo, colorear y mandalas

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
**Nombre:** "Pintazz" es de trabajo; buscarle uno a la altura de Palabrario.

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

**Monetización (por decidir; el dueño solo fijó el pago único para Palabrario y Pintazz):** vidas extra con premiado al perder (*continuar*), power-ups de
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

1. Cerrar Palabrario: revisión humana de las palabras, prueba en un móvil y subida a
   prueba interna (`palabrario/docs/LANZAMIENTO.md`).
2. Siguiente: **Pintazz**, con el mismo modelo de pago. Es el de más potencial comercial,
   pero necesita arte (láminas para colorear y mandalas).
