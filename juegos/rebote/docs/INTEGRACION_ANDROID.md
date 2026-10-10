# Integración Android: AdMob, Google Play Billing y exportación

Qué falta en la máquina del dueño para pasar del APK de prueba (anuncios simulados,
compras desactivadas) al AAB que muestra anuncios y cobra de verdad. El código es el
mismo que el de Sopazz, ya revisado; cambia la configuración.

## 0. Qué está verificado y qué no

| Pieza | Estado |
|---|---|
| Juego, guardado firmado, economía, reglas de anuncios | Probado: `tests/pruebas.tscn` en Godot 4.7 headless |
| Cobro (`scripts/proveedores/pagos_play.gd`) | Probado con un `BillingClient` falso. Señales y claves (`product_ids`, `purchase_token`, `is_acknowledged`, `token`, `formatted_price`) contrastadas con el código fuente del plugin oficial (`Utils.kt`, `GodotGooglePlayBilling.kt`) |
| AdMob (`scripts/proveedores/anuncios_admob.gd`) | Escrito según la doc del plugin de Poing Studios; **sin probar en un móvil** |
| Consentimiento UMP | Igual: **sin probar en un móvil**. Confirmar los nombres con la versión instalada |

Si con los plugins instalados algo no cuadra, el arreglo queda dentro de
`scripts/proveedores/`. El resto del juego no se toca.

## 1. Herramientas

1. Godot 4.7 stable y sus plantillas de exportación.
2. JDK 17+ y Android SDK (rutas en *Editor Settings → Export → Android*).
3. *Project → Install Android Build Template…* (los plugins necesitan Gradle).
   El preset **«Android Play (AAB)»** ya tiene Gradle activado.

## 2. Plugins

- **AdMob (Poing Studios)**, Godot 4.5+. Activar en *Project Settings → Plugins* y
  poner el **App ID** (`ca-app-pub-…~…`) donde dice su guía *Global Settings*.
  Docs: https://poingstudios.github.io/godot-admob-plugin/stable/
- **Google Play Billing (oficial)**, `godot-sdk-integrations/godot-google-play-billing`.
  Descomprimir en `addons/` y activar.
  Docs: https://godot-sdk-integrations.github.io/godot-google-play-billing/

Al detectar `MobileAds` y `BillingClient` en Android, `autoload/monetizacion.gd`
cambia solo a los proveedores reales.

## 3. Unidades de anuncio reales (nunca en el repo)

- En AdMob: una unidad **intersticial** y una **bonificada**.
- En *Project Settings* (Advanced) añadir, solo en la copia local para exportar:
  - `rebotazz/admob/intersticial`
  - `rebotazz/admob/premiado`
- Las builds de **depuración siempre usan las unidades de prueba** de Google.

## 4. Productos en Play Console

*Monetize → Products → In-app products*, todos **in-app**, con estos IDs exactos:
`sin_anuncios` (no consumible), `gemas_500`, `gemas_1500`, `gemas_4000`
(consumibles). Precios de referencia en `MONETIZACION.md`.

## 5. Firma y exportación

```bash
export GODOT_ANDROID_KEYSTORE_RELEASE_PATH=~/claves/rebotazz-release.keystore
export GODOT_ANDROID_KEYSTORE_RELEASE_USER=rebotazz
export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD='…'
godot --headless --path juegos/rebote --export-release "Android Play (AAB)" build/rebotazz.aab
```

La clave nunca va al repo. Activar **Play App Signing** al subir el primer AAB.

## 6. Prueba en un móvil antes de enviar a revisión

- [ ] Instalar desde una pista de **prueba interna** (Billing solo funciona así).
- [ ] Cuenta en *License testing*: compras sin cobro real.
- [ ] Tienda: los precios salen en la moneda local (sin «≈»).
- [ ] Premiado: verlo entero da 25 gemas; cerrarlo a mitad no da nada; tope 10/día.
- [ ] Intersticial: nada en los 10 primeros niveles; luego como mucho 1 cada 3
      niveles ganados y 3 min; nunca tras perder ni al salir con pausa.
- [ ] Perder: «Seguir (anuncio)» y «Seguir por 50 gemas»; solo una vez por intento.
- [ ] Comprar gemas y quitar anuncios; reinstalar y *Restaurar compras*: vuelve
      quitar anuncios, las gemas no se duplican.
- [ ] Compra pendiente (tarjeta de prueba «lenta»): llega sola al aprobarse.
- [ ] Modo avión: nada se queda colgado (los anuncios tienen tiempo límite).
- [ ] UMP: con geografía de depuración EEA sale el formulario de consentimiento.
- [ ] **Pendiente de código**: Google pide un punto de entrada para cambiar el
      consentimiento (formulario de opciones de privacidad de UMP) en Ajustes. No se
      añadió porque el nombre del método en el plugin no está confirmado; añadirlo
      en `anuncios_admob.gd` + botón en Ajustes al instalar el plugin.
