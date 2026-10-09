# Formulario Data safety y declaraciones de Play Console — Sopazz

Respuestas para *Play Console → App content*. Están contrastadas con el código
(`autoload/progreso.gd`, `autoload/monetizacion.gd`, `scripts/proveedores/`) y con la
divulgación oficial del SDK de Google Mobile Ads (vía la doc del plugin de Poing
Studios, *Google Play data disclosure*). Si se añade cualquier SDK nuevo (analítica,
crash reporting, mediación), **hay que revisar esto antes de subir**.

El responsable de las respuestas es el dueño de la cuenta: esto es un borrador
razonado, no asesoría legal.

## Data safety

**¿La app recoge o comparte datos de usuario?** Sí (los recoge el SDK de anuncios).
**¿Todos los datos se cifran en tránsito?** Sí (TLS, según Google).
**¿Pueden los usuarios pedir que se borren sus datos?** El juego no guarda datos en
servidores propios; el progreso es local y se borra al desinstalar. Para los datos de
anuncios, remitir a los controles de Google (ID de publicidad en Ajustes de Android).

| Tipo de dato (Play) | Recogido | Compartido | Motivo | Opcional |
|---|---|---|---|---|
| Ubicación → Ubicación aproximada (derivada de la IP) | Sí | Sí | Publicidad, Prevención de fraude, Analítica | No |
| Actividad en apps → Interacciones con la app | Sí | Sí | Publicidad, Analítica | No |
| Información y rendimiento de apps → Diagnósticos | Sí | Sí | Analítica | No |
| ID de dispositivo u otros IDs → ID de publicidad / App set ID | Sí | Sí | Publicidad, Prevención de fraude, Analítica | No* |
| Historial de compras | No** | No | — | — |
| Información personal (nombre, correo…) | No | No | — | — |

\* El usuario puede restablecer o eliminar el ID de publicidad en Android.
\** Las compras las procesa Google Play; el juego solo recibe la confirmación para
entregar el producto y no la guarda fuera del dispositivo. No hay servidor propio.

## Otras declaraciones

| Sección | Respuesta |
|---|---|
| Anuncios | **Sí, la app contiene anuncios** |
| ID de publicidad | **Sí**, se usa para publicidad (lo añade el SDK de Google Mobile Ads con el permiso `com.google.android.gms.permission.AD_ID`) |
| Acceso a la app | Sin restricciones (no hay login) |
| Público objetivo | 13+ (ver `FICHA_PLAY.md`) |
| Apps de noticias / sanidad / gobierno | No |
| Política de privacidad | `https://26914233.github.io/trazzo/sopazz-privacidad.html` — **verificar que la URL responde tras publicar la web** (en el repo es `sopazz-privacidad.html`) |

## Permisos del APK (verificados con `aapt2 dump badging`)

`INTERNET`, `ACCESS_NETWORK_STATE`, `VIBRATE`. Con los plugins instalados, el SDK de
anuncios y Billing añaden los suyos (`AD_ID`, `BILLING`); revisar el manifiesto final
del AAB antes de enviar.
