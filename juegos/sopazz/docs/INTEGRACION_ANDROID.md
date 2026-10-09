# Integración Android: AdMob, Google Play Billing y exportación

Qué hay que hacer en la máquina del dueño para pasar del juego que funciona con el
*stub* al AAB que cobra de verdad. El código ya está escrito y probado contra la API
documentada de cada plugin; lo que queda aquí es instalación, configuración y prueba
en un móvil real.

## 0. Qué está verificado y qué no

| Pieza | Estado |
|---|---|
| Juego, guardado, economía, reglas de anuncios | Probado: `tests/pruebas.tscn` en Godot 4.7 headless |
| Flujo de cobro (`scripts/proveedores/pagos_play.gd`) | Probado con un `BillingClient` falso que imita la API documentada del plugin |
| Flujo de AdMob (`scripts/proveedores/anuncios_admob.gd`) | Escrito según la documentación del plugin; **sin probar en dispositivo** |
| Consentimiento UMP | Escrito según la doc "stable" del plugin; **sin probar en dispositivo**. Ojo: el README de GitHub del plugin nombra la API distinto (`ConsentInformation.request_consent_info_update`) que la web de docs (`UserMessagingPlatform.consent_information.update`); se siguió la web. Confirmar con la versión instalada. |
| Exportación | Ver `docs/LANZAMIENTO.md` |

Si con los plugins instalados algo no cuadra (nombre de clase, de señal, de
propiedad), el arreglo queda dentro de esos dos archivos de `scripts/proveedores/`.
El resto del juego no se toca.

## 1. Herramientas

1. **Godot 4.7 stable** y sus plantillas de exportación
   (*Editor → Manage Export Templates → Download and Install*).
2. **JDK 17 o superior** y **Android SDK** (platform-tools, build-tools y una
   plataforma reciente). Rutas en *Editor → Editor Settings → Export → Android*.
3. *Project → Install Android Build Template…* (los dos plugins necesitan Gradle build).

## 2. Plugins

### AdMob — Poing Studios
- Instalar desde el Godot Asset Store (busca "AdMob", autor Poing Studios) o desde las
  releases de `poingstudios/godot-admob-plugin`. Requiere Godot 4.5+.
- Activar en *Project Settings → Plugins*.
- Poner el **App ID de AdMob** (el `ca-app-pub-…~…`, distinto de las unidades de
  anuncio) donde indica la guía *Global Settings* del plugin.
- Docs: https://poingstudios.github.io/godot-admob-plugin/stable/

### Google Play Billing — oficial de Godot
- `godot-sdk-integrations/godot-google-play-billing`, rama master (Godot 4.2+).
- Descomprimir en `addons/`, activar en *Project Settings → Plugins*.
- Docs: https://godot-sdk-integrations.github.io/godot-google-play-billing/

Al detectar las clases `MobileAds` y `BillingClient` en Android, `autoload/monetizacion.gd`
cambia solo del stub a los proveedores reales. No hay que tocar código.

## 3. Unidades de anuncio reales

- Crear en AdMob una unidad **intersticial** y una **bonificada (rewarded)**.
- En *Project Settings* (con *Advanced Settings* activado) añadir:
  - `sopazz/admob/intersticial` = `ca-app-pub-XXXX/YYYY`
  - `sopazz/admob/premiado` = `ca-app-pub-XXXX/ZZZZ`
- Las builds de **depuración siempre usan las unidades de prueba** de Google, aunque
  estén puestas las reales: tocar anuncios reales propios puede suspender la cuenta.
- Una build de release que se quede con las de prueba avisa en el log.

## 4. Productos en Play Console

*Monetize → Products → In-app products*. Todos son de tipo **in-app**; los IDs deben
ser exactamente estos:

| ID | Tipo en el código | Precio sugerido |
|---|---|---|
| `sin_anuncios` | permanente (se reconoce) | 2,99 US$ |
| `fichas_500` | consumible | 0,99 US$ |
| `fichas_1500` | consumible | 2,49 US$ |
| `fichas_4000` | consumible | 4,99 US$ |
| `fichas_10000` | consumible | 9,99 US$ |
| `todos_los_temas` | permanente | 7,99 US$ |
| `tema_paises`, `tema_cine`, `tema_ciencia`, `tema_mitologia`, `tema_musica`, `tema_oficios` | permanente | 1,99 US$ |

Un tema nuevo de pago (`datos/temas/<id>.json` con `"gratis": false`) necesita su
producto `tema_<id>` en la consola; el código lo incluye solo en la consulta.

## 5. Firma (nunca en el repo)

```bash
keytool -genkeypair -v -keystore ~/claves/sopazz-release.keystore \
  -alias sopazz -keyalg RSA -keysize 2048 -validity 10000
```

Guardar la clave y su contraseña fuera del repo (el `.gitignore` ya excluye
`*.keystore`, `*.jks`, `*.aab`, `*.apk`). Para exportar, pasarlas por variables de
entorno en vez de escribirlas en `export_presets.cfg`:

```bash
export GODOT_ANDROID_KEYSTORE_RELEASE_PATH=~/claves/sopazz-release.keystore
export GODOT_ANDROID_KEYSTORE_RELEASE_USER=sopazz
export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD='…'
godot --headless --path juegos/sopazz --export-release "Android" build/sopazz.aab
```

Activar **Play App Signing** al subir el primer AAB: si se pierde esta clave, Google
sigue pudiendo firmar las actualizaciones.

## 6. Prueba en un móvil antes de enviar a revisión

- [ ] Instalar desde una pista de **prueba interna** de Play (Billing solo funciona
      con builds subidas a Play).
- [ ] Añadir la cuenta de prueba en *Settings → License testing*: compras sin cobro real.
- [ ] Premiado: ver uno entero → pista concedida; cerrarlo a mitad → sin pista.
- [ ] Intersticial: no sale en los 3 primeros niveles; luego 1 de cada 3, con 90 s
      de separación; nunca al abandonar un nivel.
- [ ] Modo avión: la pista cae a la de cortesía, nada se queda colgado.
- [ ] Comprar fichas, quitar anuncios y un tema. Reinstalar y pulsar *Restaurar
      compras*: vuelven los permanentes, no se duplican las 300 fichas.
- [ ] Compra pendiente con la tarjeta de prueba "lenta": no se entrega hasta que se aprueba.
- [ ] Consentimiento: con `debug_geography = EEA` sale el formulario UMP.
- [ ] Botón atrás de Android en cada pantalla.
