# Data safety y declaraciones de Play Console — Rebotazz

Borrador razonado (no asesoría legal), contrastado con el código
(`autoload/progreso.gd`, `autoload/monetizacion.gd`, `scripts/proveedores/`) y con la
divulgación del SDK de Google Mobile Ads. Si se añade otro SDK (analítica, errores,
mediación), revisar antes de subir.

## Data safety

- ¿Recoge o comparte datos? **Sí** (los recoge el SDK de anuncios).
- ¿Cifrados en tránsito? **Sí** (según Google).
- ¿Borrado a petición? No hay servidor propio; el progreso es local y se borra al
  desinstalar. Datos de anuncios: controles de Google.

| Tipo de dato (Play) | Recogido | Compartido | Motivo | Opcional |
|---|---|---|---|---|
| Ubicación aproximada (por la IP) | Sí | Sí | Publicidad, prevención de fraude, analítica | No |
| Interacciones con la app | Sí | Sí | Publicidad, analítica | No |
| Diagnósticos | Sí | Sí | Analítica | No |
| ID de publicidad / App set ID | Sí | Sí | Publicidad, prevención de fraude, analítica | No* |
| Historial de compras | No** | No | — | — |
| Información personal | No | No | — | — |

\* Se puede restablecer o eliminar en Android. \** Las compras las procesa Google Play.

## Otras declaraciones

| Sección | Respuesta |
|---|---|
| Anuncios | **Sí, contiene anuncios** |
| ID de publicidad | **Sí**, para publicidad (permiso `AD_ID` del SDK) |
| Acceso | Sin restricciones (no hay login) |
| Público objetivo | **13+** (con anuncios personalizados no se apunta a menores) |
| Compras en la app | Sí (gemas y quitar anuncios) |
| Política de privacidad | `https://26914233.github.io/trazzo/rebotazz-privacidad.html` (en el repo, `rebotazz-privacidad.html`). **Verificar que la URL responde tras publicar la web** |

## Permisos

APK de prueba: `INTERNET`, `ACCESS_NETWORK_STATE`, `VIBRATE`. Con los plugins, el
AAB añade `AD_ID` y `BILLING`: revisar el manifiesto final antes de enviar.
