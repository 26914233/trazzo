# Monetización y economía — Sopazz

Modelo: **gratis con anuncios + compras**. El juego se puede terminar sin pagar y sin
ver un anuncio; lo que se vende es comodidad (pistas), tranquilidad (quitar anuncios)
y contenido (temas).

## 1. Las tres fuentes de ingreso, por orden de peso esperado

1. **Anuncio premiado (rewarded)** — el motor real en este género. El jugador *elige*
   verlo para conseguir una pista. Es el que mejor paga y el que no molesta.
2. **Quitar anuncios** — compra única de los jugadores que ya engancharon. Pocos, pero
   el ticket más alto por usuario.
3. **Intersticial** — el relleno. Paga poco y, mal puesto, mata la retención y hace que
   Google Play te mire con lupa. Reglas estrictas abajo.

El banner queda **fuera de la partida**. Un banner junto a un tablero táctil provoca
toques accidentales, y los toques accidentales son invalidaciones de AdMob.

## 2. Fichas (moneda del juego)

### Entradas (faucets)
| Acción | Fichas |
|---|---|
| Completar nivel (1 estrella) | 10 |
| Completar nivel (3 estrellas) | 20 |
| Primer nivel de un tema nuevo | 25 |
| Nivel del día | doble de lo normal |
| Racha diaria (día 1→7) | 10, 15, 20, 25, 30, 40, 60 |
| Anuncio premiado (opción fichas) | 30 |

### Salidas (sinks)
| Gasto | Fichas |
|---|---|
| Pista | 25 |
| Revelar una palabra entera | 60 |
| Desbloquear un tema de pago | 300 |

Un jugador normal saca unas 45 fichas por sesión de 3 niveles y gasta 25–50 si usa
pistas: la economía está calibrada para que **las pistas se noten** sin bloquear a
nadie. Las 3 pistas gratis del principio existen para que el jugador aprenda que la
pista es útil antes de que se le pida algo por ella.

## 3. Anuncio premiado

- **Dónde:** botón de pista cuando no hay pistas gratis ni fichas suficientes; y
  "duplicar recompensa" en la pantalla de victoria.
- **Siempre voluntario y siempre con el premio dicho antes de verlo.**
- Si el anuncio no carga (muy común con conexión mala), se avisa y **se da la pista
  igual una vez al día**. Un jugador que no puede seguir por un anuncio roto es un
  jugador que desinstala.
- Tope: 20 premiados al día, para que no se convierta en una granja.

## 4. Intersticial: reglas duras

No se muestra:
- durante una partida, nunca;
- en los **tres primeros niveles** de un jugador nuevo;
- después de abandonar un nivel (castigar al que se frustra es perderlo);
- si han pasado menos de **90 segundos** desde el anterior;
- si el jugador compró "quitar anuncios".

Se muestra: al volver al menú tras completar un nivel, como máximo **1 de cada 3**
niveles completados.

## 5. Precios (COP/USD, revisables por el dueño)

| Producto | Tipo | Precio sugerido |
|---|---|---|
| Quitar anuncios (+300 fichas de regalo) | no consumible | 2,99 US$ |
| 500 fichas | consumible | 0,99 US$ |
| 1.500 fichas | consumible | 2,49 US$ |
| 4.000 fichas (mejor valor) | consumible | 4,99 US$ |
| 10.000 fichas | consumible | 9,99 US$ |
| Un paquete de temas | no consumible | 1,99 US$ |
| Todos los temas | no consumible | 7,99 US$ |

Coherencia con la web de Curtzz: ahí los paquetes web llevan **25 % extra** sobre los
del juego. Si se quiere repetir esa jugada con Sopazz, los códigos canjeables se
venderían en la misma tienda web que ya existe (`tienda.html`), reutilizando el flujo.

## 6. Expectativa honesta de ingresos

Con público hispanohablante, los eCPM reales están en torno a 2–6 US$ en premiado y
1–3 US$ en intersticial. Con 1.000 jugadores activos al día, eso son **del orden de
10–30 US$ al día** entre anuncios y compras, y solo si la retención D1 pasa del 30 %.
No hay cifras mágicas: la palanca que mueve de verdad el dinero es la retención, no la
cantidad de anuncios. Cualquier número más optimista que esto es humo.

## 7. Métricas mínimas a instrumentar

- Retención D1 / D7 (objetivo: 35 % / 12 %)
- Niveles por sesión (objetivo: 3) y duración de sesión (objetivo: 8 min)
- Tasa de uso de pista por nivel, y % de pistas pagadas con anuncio vs fichas
- Embudo de la tienda: visitas → selección de paquete → compra
- Nivel donde más se abandona (si es el mismo siempre, el generador lo está haciendo
  demasiado difícil)

No se recoge nada personal: ni correo, ni contactos, ni ubicación. Lo que se declare en
el formulario de **Data safety** de Play tiene que coincidir exactamente con esto.
