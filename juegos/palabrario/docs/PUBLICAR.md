# Publicar Palabrario en Google Play

Lo que hay que hacer en la máquina del dueño. El juego no usa plugins (ni anuncios ni
compras), así que el camino es corto.

## 0. Qué está verificado aquí

| Pieza | Estado |
|---|---|
| Juego, contenido (545 sopas × 4 dificultades), guardado | Pruebas headless en verde |
| Pantallas en los 3 diseños sin errores de motor | Probado |
| APK de prueba | Exportado y firmado; `aapt2` confirma paquete, target SDK y permisos |
| AAB de release firmado | Construido con Gradle (53 MB, 44 temas y 7 fuentes dentro) y firmado con una clave de prueba por variables de entorno; repetir con la clave real |
| En un móvil real | **Sin probar** (no hay dispositivo en el entorno de desarrollo) |

## 1. Herramientas

1. **Godot 4.7 stable** y sus plantillas de exportación
   (*Editor → Manage Export Templates → Download and Install*).
2. **JDK 17 o superior** y **Android SDK**. Rutas en
   *Editor → Editor Settings → Export → Android*.
3. *Project → Install Android Build Template…* (el AAB se genera con Gradle).

## 2. Cuenta de Play

- Una app de pago necesita un **perfil de pagos** (cuenta de comerciante) vinculado a
  Play Console.
- Recuerda: una app de pago se puede pasar a gratis, pero **una gratis no se puede pasar
  a de pago**. Créala de pago desde el principio.
- El nombre de paquete `com.thunderdarkness.palabrario` es **permanente** una vez subido.

## 3. Clave de firma (nunca en el repo)

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

## 4. Antes de cada subida

```bash
python3 juegos/palabrario/herramientas/construir_temas.py      # contenido válido
godot --headless --path juegos/palabrario res://tests/pruebas.tscn   # pruebas en verde
python3 juegos/palabrario/docs/comprobar_ficha.py               # textos de la ficha
```

Subir `version/code` en `export_presets.cfg` en cada versión nueva.

## 5. Prueba en un móvil

- [ ] Instalar el APK de prueba (`Android APK (prueba)`) y jugar una sopa de cada dificultad.
- [ ] Botón atrás de Android en cada pantalla.
- [ ] Cambiar de diseño en Ajustes y volver a jugar.
- [ ] Cerrar la app en mitad de una partida y volver: el progreso sigue.
- [ ] Modo avión: todo funciona.
- [ ] Un móvil barato: el tablero de 14×14 se ve y responde bien.

> El APK de prueba es **debuggable** y va firmado con la clave de depuración: sirve para
> tus pruebas, **no lo repartas**. A testers y a Play va solo el AAB de release.

## 6. Contenido nuevo

Añadir o corregir sopas: editar `datos/fuente/NN-tema.txt` (una línea por sopa, 12
palabras), ejecutar `herramientas/construir_temas.py` y pasar las pruebas. El script
avisa de palabras repetidas, demasiado largas o con letras raras.
