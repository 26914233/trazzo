# Publicar Palabrario en Google Play

Lo que hay que hacer en la máquina del dueño. El único plugin es el de Google Play
Billing, para los paquetes de pistas.

## 0. Qué está verificado aquí

| Pieza | Estado |
|---|---|
| Juego, contenido (545 sopas × 4 dificultades), guardado | Pruebas headless en verde |
| Pantallas en los 3 diseños sin errores de motor | Probado |
| APK de prueba | Exportado y firmado; `aapt2` confirma paquete, target SDK y permisos |
| AAB de release firmado | Construido con Gradle (53 MB, 44 temas y 7 fuentes dentro) y firmado con una clave de prueba por variables de entorno; repetir con la clave real |
| Cobro de pistas (`scripts/proveedores/pagos_play.gd`) | Probado con un `BillingClient` falso que imita la API documentada del plugin |
| Antipiratería propia (`autoload/integridad.gd`) | La decisión está probada; la llamada a Android **no**, porque no hay dispositivo |
| En un móvil real | **Sin probar** (no hay dispositivo en el entorno de desarrollo) |

## 1. Herramientas

1. **Godot 4.7 stable** y sus plantillas de exportación
   (*Editor → Manage Export Templates → Download and Install*).
2. **JDK 17 o superior** y **Android SDK**. Rutas en
   *Editor → Editor Settings → Export → Android*.
3. *Project → Install Android Build Template…* (el AAB se genera con Gradle).

## 2. Plugin de pagos (solo para las pistas)

- `godot-sdk-integrations/godot-google-play-billing`: instalar **una release concreta**
  (no la rama master) en `addons/`, activarlo en *Project Settings → Plugins* y anotar
  aquí la versión: _por rellenar_.
- Docs: https://godot-sdk-integrations.github.io/godot-google-play-billing/
- Con el plugin presente, `autoload/tienda.gd` usa el cobro real. Sin él, en una build de
  release la compra **falla** (nunca regala pistas).

Productos en *Play Console → Monetize → In-app products*, todos **consumibles** y con
estos IDs exactos: `pistas_10` (0,99 US$), `pistas_30` (1,99 US$), `pistas_100` (4,99 US$).

## 3. Cuenta de Play

- Una app de pago necesita un **perfil de pagos** (cuenta de comerciante) vinculado a
  Play Console.
- Recuerda: una app de pago se puede pasar a gratis, pero **una gratis no se puede pasar
  a de pago**. Créala de pago desde el principio.
- El nombre de paquete `com.thunderdarkness.palabrario` es **permanente** una vez subido.

## 4. Protección antipiratería

1. **Principal — protección automática de Play.** En Play Console, sección de
   integridad de la app (*App integrity*), activar la protección automática (el nombre
   exacto del menú puede variar). Google añade al subir el AAB una
   comprobación de que la app viene de Play y, si no, manda al usuario a la ficha para
   comprarla. Requisitos (los cumple Palabrario): Play App Signing, publicar en AAB, API
   mínima 24. La parte "antimanipulación" está reservada a socios grandes; no cuenta.
2. **Segunda capa — `autoload/integridad.gd`.** Pregunta a Android quién instaló la app.
   Si no fue Play, muestra una pantalla para reinstalar desde Play (gratis para quien la
   compró). Ante cualquier duda deja jugar. Se apaga con
   `palabrario/integridad/exigir_play=false` en `project.godot` si con la protección
   automática basta.

Ninguna de las dos detiene a quien modifique el juego a conciencia; frenan el caso común:
pasarse el APK.

## 5. Clave de firma (nunca en el repo)

```bash
keytool -genkeypair -v -keystore ~/claves/palabrario-release.keystore \
  -alias palabrario -keyalg RSA -keysize 2048 -validity 10000
```

El `.gitignore` ya excluye `*.keystore`, `*.jks`, `*.aab` y `*.apk`. Para exportar:

```bash
export GODOT_ANDROID_KEYSTORE_RELEASE_PATH=~/claves/palabrario-release.keystore
export GODOT_ANDROID_KEYSTORE_RELEASE_USER=palabrario
export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD='…'
godot --headless --path juegos/palabrario --export-release "Android Play (AAB)" build/palabrario.aab
```

Activar **Play App Signing** al subir el primer AAB.

## 6. Antes de cada subida

```bash
python3 juegos/palabrario/herramientas/construir_temas.py      # contenido válido
godot --headless --path juegos/palabrario res://tests/pruebas.tscn   # pruebas en verde
python3 juegos/palabrario/docs/comprobar_ficha.py               # textos de la ficha
```

Subir `version/code` en `export_presets.cfg` en cada versión nueva.

## 7. Prueba en un móvil

- [ ] Instalar el APK de prueba (`Android APK (prueba)`) y jugar una sopa de cada dificultad.
- [ ] **Antipiratería, desde la pista de prueba interna de Play:** el juego abre normal.
      Si sale la pantalla "Esta copia no se instaló desde Google Play", apagar
      `exigir_play` y avisar: la llamada a Android no responde como se espera.
- [ ] **Antipiratería, release instalado con `adb install`:** debe salir esa pantalla.
- [ ] **Antipiratería, release con `adb install -i com.android.vending`** (Android 11+):
      también debe salir esa pantalla (NV-01). Si no sale, no es grave: avisar y seguir.
- [ ] **Reloj adelantado:** poner la fecha un año por delante, abrir, volver a la fecha
      real y abrir: la sopa del día vuelve a la de hoy y no hay pistas gratis extra.
- [ ] **Pistas:** gastar las 3 gratis; comprar un paquete con una cuenta de *License
      testing* (sin cobro real); cerrar la app a mitad de una compra y volver: las pistas
      llegan; pago "lento" de prueba: no llegan hasta que se aprueba.
- [ ] Botón atrás de Android en cada pantalla.
- [ ] Cambiar de diseño en Ajustes y volver a jugar.
- [ ] Cerrar la app en mitad de una partida y volver: el progreso sigue.
- [ ] Modo avión: todo funciona.
- [ ] Un móvil barato: el tablero de 14×14 se ve y responde bien.

> El APK de prueba es **debuggable** y va firmado con la clave de depuración: sirve para
> tus pruebas, **no lo repartas**. A testers y a Play va solo el AAB de release.

## 8. Contenido nuevo

Añadir o corregir sopas: editar `datos/fuente/NN-tema.txt` (una línea por sopa, 12
palabras), ejecutar `herramientas/construir_temas.py` y pasar las pruebas. El script
avisa de palabras repetidas, demasiado largas o con letras raras.

## 9. Gráficos de la ficha

Todo en `docs/tienda/`: icono 512, tres opciones de gráfico destacado (1024×500) y seis
capturas con titular (1080×1920). Se hacen en HTML y se exportan con
`node docs/tienda/exportar.js`. El icono adaptativo de Android (frente, fondo y monocromo)
está en `arte/icono_android/` y ya va enlazado en `export_presets.cfg`.
