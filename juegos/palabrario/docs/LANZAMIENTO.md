# Checklist de lanzamiento — Palabrario 1.0.0 (Google Play, app de pago + pistas opcionales)

Adaptado de la skill `launch-checklist` a un juego móvil de un jugador, sin servidor y
sin anuncios. Única compra dentro: paquetes de pistas con Google Play Billing.
> **Estado (2026-10-09): casi terminado, en espera.** La cuenta de desarrollador de
> Google Play está en trámite. Cuando esté lista, el dueño sube el juego siguiendo la
> sección 5. Mientras tanto no se toca, salvo bugs.

Leyenda: ✅ verificado aquí · 🟡 hecho pero sin probar en dispositivo · ⬜ pendiente del
dueño · ➖ no aplica.

## 1. Código y build

| | Punto | Evidencia |
|---|---|---|
| ✅ | Pruebas en verde | `godot --headless --path juegos/palabrario res://tests/pruebas.tscn` → 123/123 |
| ✅ | Las 545 sopas se completan en las 4 dificultades | 2.180 combinaciones generadas en la batería de pruebas |
| ✅ | Las 6 pantallas cargan sin errores en los 3 diseños | Prueba con `Logger` |
| ✅ | APK de prueba exporta y firma | `aapt2`: `com.thunderdarkness.palabrario`, target SDK 36, arm64 + armv7, **solo permiso VIBRATE** (el plugin de pagos añadirá el suyo al compilar con Gradle) |
| ✅ | AAB de release compila con Gradle y se firma por variables de entorno | Probado con una clave desechable |
| ⬜ | Exportar el AAB con la clave real | `docs/PUBLICAR.md` §3 |
| ⬜ | Rendimiento en un móvil barato (tablero 14×14) | No hay dispositivo aquí |
| ✅ | Sin claves ni secretos en el repo | `.gitignore` excluye keystores, AAB y APK |
| ➖ | Crash reporting | No integrado a propósito (Data safety "no recoge datos"); Play Console da ANR y crashes |

## 2. Contenido

| | Punto | Evidencia |
|---|---|---|
| ✅ | 545 sopas en 44 temas, 12 palabras cada una | `herramientas/construir_temas.py` valida longitud, repetidas y letras |
| ✅ | Ñ correcta en la cuadrícula | Prueba `normalizar` |
| ✅ | Revisión de las 6.540 palabras | Corrector ortográfico en español (sin erratas) y revisión de palabras vulgares en algún país (cambiadas: chucha, concha, pico, bichos) |
| ⬜ | Una lectura humana final | Recomendable: alguien que lea los 44 archivos de `datos/fuente/` con calma |
| ✅ | Accesibilidad: 4 tamaños de letra, contraste medido, modo oscuro | Pruebas de contraste en los 3 diseños |
| ⬜ | Probar con 3 personas reales (`playtest-report`) | Sobre todo la primera partida |
| ➖ | Localización | Solo español en la v1 |

## 3. Tienda y legal

| | Punto | Evidencia |
|---|---|---|
| ✅ | Ficha dentro de límites | `python3 docs/comprobar_ficha.py` |
| ✅ | Capturas reales 1080×1920 en diseño Cielo | `docs/capturas/` |
| ✅ | Gráfico destacado 1024×500 | `docs/tienda/destacado-*.png` (3 opciones) |
| ✅ | Capturas con titular para la ficha | `docs/tienda/captura-1..6-*.png` |
| ✅ | Icono 512 y adaptativo de Android | `docs/tienda/icono-512.png`, `arte/icono_android/`; verificado dentro del APK |
| ✅ | Política de privacidad acorde a lo que hace la app | `palabrario-privacidad.html` (raíz del repo web) |
| ⬜ | Comprobar que la URL de privacidad responde una vez publicada | `https://26914233.github.io/trazzo/palabrario-privacidad.html` (supuesta) |
| ✅ | Data safety: no recoge datos | `docs/PLAY_DATA_SAFETY.md`, contrastado con los permisos del APK |
| ⬜ | Perfil de pagos en Play Console (obligatorio para apps de pago) | `docs/PUBLICAR.md` §2 |
| ⬜ | Precio 4,99 US$ y precios locales | `docs/MONETIZACION.md` |
| ⬜ | Instalar el plugin de Play Billing y crear `pistas_10/30/100` | `docs/PUBLICAR.md` §2 |
| ⬜ | Activar la protección automática de integridad en Play Console | `docs/PUBLICAR.md` §4 |
| ⬜ | Cuestionario IARC y público objetivo | `docs/FICHA_PLAY.md` |
| ✅ | Fuentes con licencia libre y créditos | `arte/fuentes/OFL.txt`, `CREDITOS.txt` |
| ✅ | Sonidos propios (sintetizados) | `arte/sonidos/` |

## 4. Seguridad

Re-auditoría con `security-audit-juegos` tras añadir los paquetes de pistas (juego de un
jugador, sin red: el APK solo pide `VIBRATE`). Estado de cada hallazgo:

| Hallazgo | Estado |
|---|---|
| SEC-001 (alto): con root y la sal sacada del binario se puede forjar el guardado e inflar el saldo de pistas | **Riesgo aceptado.** Un jugador, sin ranking ni intercambio; el máximo que se gana es lo que vale un paquete. Mitigado: firma HMAC por dispositivo, esquema validado, saldo acotado a 100 000 y racha a 3650 |
| SEC-002 (medio): adelantar el reloj da 3 pistas gratis por día adelantado | **Riesgo aceptado.** Sin servidor no hay hora fiable. Atrasar el reloj sigue sin devolver nada (con prueba). Quien lo hace queda con la sopa del día por delante hasta 30 días |
| SEC-003: textos que decían «sin compras» | **Corregido**: política, Data safety, ficha y la pantalla de copia no válida (ya no promete conservar las pistas al reinstalar) |
| SEC-004: en el APK de depuración la compra se simulaba gratis | **Corregido**: solo se simula al ejecutar desde el editor (`OS.has_feature("editor")`). El APK de prueba sigue siendo debuggable: no repartirlo |
| SEC-005: PCK sin cifrar | **Aceptado**: cifrarlo solo sube el listón (la clave va en el binario) y exige compilar plantillas propias. Se revisará si hay piratería real |
| SEC-006: una fecha futura (reloj mal puesto) congelaba lo diario | **Corregido**: fechas con formato validado; si la fecha guardada va más de 30 días por delante del reloj se vuelve a la real, sin regalar pistas |
| SEC-007: guardado rechazado = progreso y pistas perdidos en silencio | **Corregido en parte**: se avisa al jugador en el menú y cada archivo rechazado se guarda aparte con la hora. Sigue sin arreglo: un restablecimiento de fábrica cambia el ID del dispositivo y las pistas compradas no se recuperan (son consumibles locales, sin cuenta) |
| NV-01: `adb install -i com.android.vending` engañaría al antipiratería | **Corregido sin validar en móvil**: en Android 11+ si quien inició la instalación es la shell de adb, cuenta como copia. Probar en un dispositivo antes de subir (`docs/PUBLICAR.md`) |
| NV-02: las compras no se verifican con la firma de Play ni con servidor | **Aceptado**: hay lista blanca del catálogo y deduplicación por token; verificar en servidor cuesta más que lo que protege |

Si el juego añade funciones online (rankings, intercambio), SEC-001 pasa a crítico y hay que
llevar el saldo a un servidor.

## 5. Orden para subir

1. Perfil de pagos y ficha de la app creada **como app de pago**.
2. Clave de release y Play App Signing (`docs/PUBLICAR.md`).
3. AAB de release → pista de **prueba interna**; probar en un móvil (§5 de `PUBLICAR.md`).
4. Data safety, IARC, público objetivo, ficha, capturas, precio.
5. Prueba cerrada con testers el tiempo que exija Google para cuentas personales nuevas
   (requisito actual de 12 testers durante 14 días; confirmarlo en la consola).
6. Producción con despliegue escalonado.
