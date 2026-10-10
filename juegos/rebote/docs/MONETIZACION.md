# Monetización de Rebotazz

Decisión del dueño (10-oct-2026): **gratis con anuncios**, más **personalización y
microtransacciones**. Principio sacado de las reseñas del género (docs/RECON.md):
todo se gana jugando, ningún nivel se cierra tras un pago y lo que se compra no
hace falta para terminar el juego.

## Qué se vende

| Producto (ID en Play) | Tipo | Precio de referencia | Qué da |
|---|---|---|---|
| `sin_anuncios` | permanente (se reconoce) | 2,99 US$ | Sin intersticiales, «Seguir» gratis al perder. Los premiados siguen, voluntarios |
| `gemas_500` | consumible | 0,99 US$ | 500 gemas |
| `gemas_1500` | consumible | 2,49 US$ | 1.500 gemas |
| `gemas_4000` | consumible | 4,99 US$ | 4.000 gemas (marcado «mejor precio») |

La tienda muestra el **precio local que devuelve Play** (`formatted_price`). Si aún
no llegó, muestra el de referencia con «≈».

## Gemas

| Fuente | Cantidad |
|---|---|
| Superar un nivel | 5 |
| Cada estrella nueva (mejor marca del nivel) | +5 |
| Anuncio con premio en la tienda | 25, máximo 10 al día |
| Doblar las gemas de un nivel (anuncio) | ×2 de lo ganado en ese nivel |

Superar los 20 niveles de un mundo con 2 estrellas da unas 300 gemas.

| Gasto | Precio |
|---|---|
| Paleta ancha al empezar (desde el nivel 4) | 30 |
| Multibola al empezar | 45 |
| Vida extra al empezar | 60 |
| Seguir tras perder (una vez por intento) | 50 (o un anuncio, o gratis con `sin_anuncios`) |
| Paletas | 150–450 |
| Bolas | 100–350 |
| Estelas | 150–400 |

Los potenciadores comprados se activan al primer lanzamiento (no se gasta su tiempo
mientras la bola espera). Las pruebas fijan dos límites de balance: la paleta más
cara cuesta como mucho 2 mundos de gemas, y ningún potenciador más de 4 niveles.

## Anuncios a pantalla completa (intersticiales): reglas

En `scripts/reglas_anuncios.gd`, con pruebas:

- Nunca en los **10 primeros niveles superados**.
- Nunca **tras perder** ni al **abandonar** un nivel.
- Solo al salir de un nivel **ganado**, como mucho **1 cada 3 niveles** y con
  **3 minutos** de separación.
- Nunca con `sin_anuncios`.

## Seguridad del progreso

Las gemas valen dinero, así que `user://progreso.save` va firmado (HMAC-SHA256).
Un archivo editado se aparta como `.rechazado-<ms>` y se empieza de cero. La compra
`sin_anuncios` se vuelve a pedir a Play al abrir (fuente de verdad: si Play ya no la
tiene, por reembolso, se retira). Límite aceptado: la sal está en el binario; con
root se podría firmar un archivo falso. No hay ranking ni comercio entre jugadores,
así que el daño se queda en ese jugador.

## Qué está verificado y qué no

- Verificado con pruebas headless (`tests/pruebas.tscn`, 164 comprobaciones): economía,
  firma, reglas de anuncios, compras simuladas, flujo de Billing con un cliente falso
  que imita el plugin oficial (consumir, reconocer, pendientes, cancelaciones,
  restaurar, reembolso), precio local, y los flujos tocando botones (tienda,
  personalizar, potenciadores, seguir, doblar).
- **Sin verificar en un móvil**: AdMob, consentimiento UMP y cobro real con Play.
  Ver `INTEGRACION_ANDROID.md`.
