# La caja viva en APK (03-10-2026)

**Qué pidió el usuario:** «¿Puedes pasarlo a APK con la misma calidad que hiciste en el enlace?».

**Qué es:** la misma página de la página privada (la técnica B, con Three.js), metida en una app de Android de una
sola pantalla (un WebView).
- Todo va dentro del APK: la ilustración, los sonidos, Three.js r170 y las fuentes. Se juega **sin conexión**.
- La partida guardada (el paso de nivel) se queda en el móvil, como en el navegador.
- A pantalla completa, en horizontal y en vertical (respeta el bloqueo de rotación).
- El botón «atrás» cierra lo que esté abierto (la nota, examinar) o vuelve a la sala; si ya no hay nada que
  cerrar, la app pasa a segundo plano sin perder la partida en curso. Al salir, el sonido se para.

| | |
|---|---|
| Paquete | `com.thunderdarkness.cajaviva` (otro distinto del de «Cuatro cajas»: no lo pisa) |
| Nombre | «La caja viva», con la cara de la caja como icono |
| Android | 7.0 o más (SDK mínimo 24; objetivo 34; compilado con la plataforma 35) |
| Versión 0.1 | código 1, 5,3 MB, `caja-viva-0.1-prueba.apk` |
| Firma | clave de prueba propia («La caja viva prueba»); ver abajo |

## Cómo se construye

```
# una vez por contenedor: la plataforma de Android 35 (64 MB, autorizada el 03-10-2026; SHA-1 en el repositorio
# de Google: 0bb560a90a7a2cbd0dd8348224d518b638fe7949) en /root/android-sdk/platforms/android-35
# y la clave de prueba en /root/.local/share/caja_viva/firma (de Drive; ver «La firma»)

python3 puzles/ilustrada/apk/herramientas/icono_apk.py        # el icono (solo si cambia)
python3 puzles/ilustrada/apk/construir_apk.py --version 0.1 --codigo 1
```

El guion (`construir_apk.py`):
1. Arma la web en `construccion/assets/web/`:
   - copia la página (`../pagina`: los `.js`, `capas/` y `sonidos/`; los modelos de la técnica C no van);
   - envuelve su `index.html` como lo hace la página privada al publicarla;
   - cambia Three.js y las fuentes de internet por las del APK.

   Three.js (MIT) y las fuentes de Fontsource (OFL, solo los trozos que usa el juego: latín y los sellos 箱 角 目 声)
   se bajan de jsDelivr la primera vez a `.cache/` y se comprueban con SHA-256. Sus licencias van dentro del APK.
2. Compila con el SDK, sin Gradle: `aapt2` (recursos y manifiesto), `javac` y `d8` (el código), `zipalign` y
   `apksigner` (firma v2 y v3).
3. Deja `salida/caja-viva-<versión>-prueba.apk` y enseña la firma, el manifiesto y su SHA-256.

`construccion/`, `salida/` y `.cache/` no van a git; el APK va a Drive.

## Cómo está hecho

- `java/com/thunderdarkness/cajaviva/ActividadCaja.java`: la pantalla. Sirve los archivos de `assets/web/` desde
  `https://appassets.androidplatform.net/web/`. Así los módulos de JavaScript, los `fetch` y `localStorage`
  funcionan como en la web. Nada sale a la red.
- `pagina/juego.js` deja dos ganchos para la app: `window.__atras()` (el botón «atrás») y `window.__pausa(sí/no)`
  (el sonido al salir y al volver). En la web no hacen nada.
- `res/`: el tema (sin barra, fondo `#0c0907` desde el primer instante, sin destello blanco), el nombre y el icono
  adaptable (`herramientas/icono_apk.py`, la cara de la caja sacada de la ilustración).
- El objetivo es el SDK 34 para no entrar en el «borde a borde» forzado de Android 15: la pantalla no se mete bajo
  la cámara frontal. Para Google Play habrá que subirlo a 35 y respetar esos márgenes.

## Cómo se prueba

En el contenedor no hay un Android donde instalarlo. Se comprueba esto:
- el APK: la firma (`apksigner verify`), el manifiesto (`aapt2 dump badging` y `xmltree`) y las clases (`dexdump`);
- la web que lleva dentro, con las mismas pruebas automáticas del juego, **sin internet**:

```
python3 -m http.server 8766 -d puzles/ilustrada/apk/construccion/assets/web &
CAJA_VIVA_URL=http://localhost:8766/index.html SIN_RED=1 node puzles/ilustrada/prueba/jugar.mjs B horizontal <capturas>
CAJA_VIVA_URL=http://localhost:8766/index.html SIN_RED=1 node puzles/ilustrada/prueba/jugar_nivel2.mjs vertical <capturas>
```

Con `SIN_RED=1`, cualquier petición fuera de `localhost` falla. Además, la prueba comprueba que nada sale de la
página y que las fuentes del juego cargan.

## La firma

- La clave de prueba de RONIN no se usa aquí: su contraseña quedó bloqueada por seguridad. Por eso La caja viva tiene
  su propia clave: `caja-viva-prueba.keystore` (PKCS12, alias `cajaviva`), creada con `herramientas/crear_firma.py`.
  Su contraseña es aleatoria, está en `clave.txt`, junto al almacén, y nunca se muestra.
- **Dónde está:** en el contenedor, en `/root/.local/share/caja_viva/firma/`. Su copia, con permiso del usuario
  (03-10-2026), está en Drive › `Respaldos Claude/puzles/firma-prueba/`. **Nunca en GitHub**, que es público.
- **En un contenedor nuevo:** baja esa copia a la misma carpeta, no crees otra. Con una clave distinta, el APK nuevo
  no se instala encima del anterior: habría que desinstalar, y se perdería la partida guardada.

## Entrega

- Drive: `caja-viva-<versión>-prueba.apk` en la raíz de `Respaldos Claude/puzles/`. Sigue la regla de Curtzz: la
  versión anterior pasa a «Versiones anteriores (puzles)».
- Chat: el APK en un `.zip` (en trozos de 10 MB si pasa de ese tamaño), que se abre con ZArchiver.
- Al subir de versión: `--version` y `--codigo` (el código siempre crece), y el nombre del archivo cambia con la
  versión, para que no se mezclen partes de dos versiones.
