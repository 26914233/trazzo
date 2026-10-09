# Formulario Data safety y declaraciones de Play Console — Palabrario

Respuestas para *Play Console → App content*, contrastadas con el código: el juego no
tiene SDK de anuncios, analítica, informes de errores ni servidor, y el APK no pide
permiso de internet (`aapt2 dump badging`: solo `VIBRATE`). Si algún día se añade un
SDK, **hay que revisar esto antes de subir**.

Borrador razonado; el responsable de las respuestas es el dueño de la cuenta.

## Data safety

| Pregunta | Respuesta |
|---|---|
| ¿La app recoge o comparte datos de usuario? | **No** |
| Datos cifrados en tránsito | No aplica (no transmite datos) |
| Eliminación de datos | El progreso es local; se borra al desinstalar |

## Otras declaraciones

| Sección | Respuesta |
|---|---|
| Anuncios | **No, la app no contiene anuncios** |
| ID de publicidad | **No** se usa |
| Compras dentro de la app | No (app de pago) |
| Acceso a la app | Sin restricciones (no hay login) |
| Público objetivo | 13+ (ver `FICHA_PLAY.md`) |
| Política de privacidad | `https://26914233.github.io/trazzo/palabrario-privacidad.html` — **comprobar que responde tras publicar la web** (en el repo: `palabrario-privacidad.html`) |
