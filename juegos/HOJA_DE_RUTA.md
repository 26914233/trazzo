# Hoja de ruta: familia de juegos (Godot 4.7 → Google Play)

Orden acordado: uno completo primero y después los demás sobre el mismo molde.

| # | Juego | Estado | Esfuerzo estimado* |
|---|---|---|---|
| 1 | **Sopazz** — sopa de letras | Jugable, monetizado, APK exportado. Falta lo de `sopazz/docs/LANZAMIENTO.md` | — |
| 2 | **Pintazz** — dibujo libre, colorear y mandalas | Diseño abajo | Medio |
| 3 | **Rebotazz** — plataforma, bola y bloques | Diseño abajo | Bajo-medio |
| 4 | **Zona Zero** — supervivencia zombi 2D | Diseño abajo, alcance recortado | Alto |

\* Relativo entre ellos, no en horas: depende de cuánto arte nuevo haga falta.

## Lo que se reutiliza de Sopazz (el molde)

Se copia y se adapta, sin convertirlo en un framework hasta que haya un segundo
juego que lo use de verdad:

- `autoload/progreso.gd` — guardado firmado con HMAC y escritura atómica.
- `autoload/monetizacion.gd` + `scripts/proveedores/` — AdMob y Play Billing con stub,
  timeout, entrega solo tras confirmación de Play, IDs de prueba en depuración.
- `scripts/reglas_anuncios.gd` — reglas del intersticial (cambiar los números por juego).
- `scripts/estilo.gd` — botones, diálogos, avisos, zona segura; cambiar la paleta.
- `tests/pruebas.tscn` (patrón), `tests/capturas.tscn`, `tests/falso_billing.gd`.
- `export_presets.cfg`, `.gitignore`, `docs/INTEGRACION_ANDROID.md`, `PLAY_DATA_SAFETY.md`.

---

## 2. Pintazz — dibujo, colorear y mandalas

**Qué es:** tres modos en una app tranquila: *Colorear* (dibujos con zonas que se
rellenan con un toque), *Mandalas* (simetría radial: lo que trazas se repite en 6–16
sectores) y *Lienzo libre* (pinceles, goma, deshacer).

**Por qué funciona en Play:** "colorear para adultos" y "mandalas" son búsquedas con
mucho volumen y público que paga por contenido. Sesiones largas = muchos premiados.

**Núcleo técnico:**
- Relleno por zonas: cada dibujo es una imagen de líneas + un mapa de regiones
  precalculado (flood fill offline), así colorear es instantáneo en móviles baratos.
- Mandalas: un solo trazo que se dibuja N veces rotado (y espejado opcional).
- Deshacer con historial de trazos, no de imágenes (memoria).
- Guardar y compartir la obra como PNG (Android share intent).

**Monetización:** dibujos gratis cada día + paquetes temáticos de pago; paletas y
pinceles premium; premiado para desbloquear un dibujo del día; "quitar anuncios".
Intersticial solo al terminar o salir de una obra, nunca mientras se pinta.

**Riesgo principal:** el contenido. Cada dibujo es arte. Hace falta un flujo para
producir láminas (vectoriales propias o generadas y retocadas) con licencia clara.
**Ojo con Familias:** colorear atrae a niños; si se apunta a menores de 13 cambian las
reglas de anuncios (ver `sopazz/docs/FICHA_PLAY.md`).

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

**Monetización:** vidas extra con premiado al perder (*continuar*), power-ups de
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

**Monetización:** premium-lite: personajes y modos con fichas, premiado para revivir
una vez por partida, sin pay-to-win. Considerar también versión de pago única.

**Riesgo principal:** alcance y rendimiento en móviles baratos. Empezar con un
prototipo (`prototype`) que pruebe solo 1–2 (zombis en masa + ruido) antes de nada más,
y escribir su GDD con `design-system` y `map-systems` antes de producir.

---

## Siguiente paso recomendado

1. Cerrar Sopazz: instalar plugins, probar en un móvil y subir a prueba interna
   (`sopazz/docs/LANZAMIENTO.md`).
2. Con datos reales de retención de Sopazz, elegir el segundo: **Rebotazz** es el más
   barato de producir; **Pintazz** el de más potencial comercial pero necesita arte.
