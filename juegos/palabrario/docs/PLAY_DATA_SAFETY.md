# Formulario Data safety y declaraciones de Play Console — Palabrario

Respuestas para *Play Console → App content*, contrastadas con el código: el juego no
tiene SDK de anuncios, analítica, informes de errores ni servidor. La única pieza externa
es Google Play Billing, para los paquetes de pistas: la compra la procesa Google Play y
el juego solo recibe la confirmación dentro del móvil, sin enviarla a ningún sitio. Si
algún día se añade un SDK, **hay que revisar esto antes de subir**.

Borrador razonado; el responsable de las respuestas es el dueño de la cuenta.

## Data safety

| Pregunta | Respuesta |
|---|---|
| ¿La app recoge o comparte datos de usuario? | **No** (ver nota sobre compras) |
| Datos cifrados en tránsito | No aplica (no transmite datos) |
| Eliminación de datos | El progreso es local; se borra al desinstalar |

## Otras declaraciones

| Sección | Respuesta |
|---|---|
| Anuncios | **No, la app no contiene anuncios** |
| ID de publicidad | **No** se usa |
| Compras dentro de la app | **Sí**: paquetes de pistas con Google Play Billing |
| Acceso a la app | Sin restricciones (no hay login) |
| Público objetivo | 13+ (ver `FICHA_PLAY.md`) |
| Política de privacidad | `https://26914233.github.io/trazzo/palabrario-privacidad.html` — **comprobar que responde tras publicar la web** (en el repo: `palabrario-privacidad.html`) |

## Nota sobre las compras

En Data safety, "recoger" significa transmitir datos fuera del dispositivo. Palabrario
recibe la confirmación de compra de Google Play dentro del móvil y no la envía a ningún
servidor propio, así que no hay "historial de compras" recogido por el desarrollador.
Algunos proveedores de pagos (RevenueCat, Adapty) sí piden declararlo, pero porque ellos
guardan las compras en sus servidores. **Confirmar con la ayuda oficial de Google al
rellenar el formulario**; ante la duda, declarar "Historial de compras: recogido, para
funcionalidad de la app, no compartido" es la opción conservadora.
