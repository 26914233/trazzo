# Checklist de lanzamiento — Sopazz 1.0.0 (Google Play)

Adaptado de la skill `launch-checklist` a un juego móvil, un jugador, sin servidor.
Leyenda: ✅ verificado aquí · 🟡 hecho pero sin probar en dispositivo · ⬜ pendiente del
dueño · ➖ no aplica.

## 1. Código y build

| | Punto | Evidencia |
|---|---|---|
| ✅ | Pruebas en verde | `godot --headless --path juegos/sopazz res://tests/pruebas.tscn` → 107/107 |
| ✅ | Las 5 pantallas cargan sin errores de motor | Prueba con `Logger` dentro de la suite |
| ✅ | APK de prueba exporta y firma | `aapt2`/`apksigner`: firma v2+v3, target SDK 36, arm64 + armv7 |
| ✅ | AAB para Play compila con Gradle | Construido con el template de Godot 4.7; ver nota de firma abajo |
| ✅ | AAB de release firmado con `GODOT_ANDROID_KEYSTORE_RELEASE_*` | 52,4 MB, `jarsigner -verify`: jar verified (probado con una clave desechable; el de depuración sale sin firmar, es normal) |
| ✅ | Sin pruebas ni docs dentro del paquete | Filtro de exportación comprobado en el APK y el AAB |
| ⬜ | Versión etiquetada en git | `git tag sopazz-v1.0.0` al subir |
| ⬜ | Rendimiento en un móvil barato (objetivo 60 fps, carga < 3 s) | No hay dispositivo aquí. El generador de niveles se optimizó para gama baja |
| ✅ | Sin claves ni secretos en el repo | `.gitignore` excluye keystores, AAB y APK; claves de release por variables de entorno |
| ➖ | Crash reporting | No integrado a propósito (cambiaría el Data safety). Play Console ya da ANR y crashes |

## 2. Monetización

| | Punto | Evidencia |
|---|---|---|
| ✅ | Reglas del intersticial (no en partida, no en onboarding, 90 s, 1 de cada 3, no tras abandonar) | Pruebas |
| ✅ | Entrega solo tras confirmación de Play; pendientes, recuperación y restauración | Pruebas con Billing falso |
| ✅ | Depuración siempre con anuncios de prueba | Prueba `ids_anuncios()` |
| 🟡 | AdMob real + consentimiento UMP | Escrito contra la doc del plugin; probar en móvil (`INTEGRACION_ANDROID.md` §6) |
| ⬜ | Instalar plugins de AdMob y Billing | `INTEGRACION_ANDROID.md` §2 |
| ⬜ | Crear unidades de anuncio reales y ponerlas en `sopazz/admob/*` | §3 |
| ⬜ | Crear los productos in-app con los IDs exactos | §4 |

## 3. Contenido

| | Punto | Evidencia |
|---|---|---|
| ✅ | 12 temas, 4 dificultades, niveles infinitos | 1.200 sopas generadas en pruebas sin palabras perdidas |
| ✅ | Partida completa de principio a fin | Prueba sobre la escena real |
| ✅ | Guardado y carga; archivo manipulado rechazado | Pruebas |
| ✅ | Accesibilidad básica: tamaño de letra, no solo color, juego completo sin sonido | Capturas en `docs/capturas/` |
| ⬜ | Revisión ortográfica de las 400+ palabras por un humano | Generadas y normalizadas por script |
| ⬜ | Gráfico destacado 1024×500 | Pendiente (`banner-design`) |
| ⬜ | Tutorial / primera vez | Hoy la primera partida es Fácil y el menú lo explica en una línea; validar con 3 personas reales (`playtest-report`) |
| ➖ | Localización | Solo español en la v1 |

## 4. Tienda y legal

| | Punto | Evidencia |
|---|---|---|
| ✅ | Textos de la ficha dentro de límites | `python3 docs/comprobar_ficha.py` |
| ✅ | Capturas reales 1080×1920 | `docs/capturas/` |
| ✅ | Política de privacidad escrita y enlazada desde Ajustes | `sopazz-privacidad.html` en la raíz del repo web |
| ⬜ | Comprobar que la URL de privacidad responde tras publicar la web | `https://26914233.github.io/trazzo/sopazz-privacidad.html` (supuesta) |
| ✅ | Borrador de Data safety coherente con el código y el SDK | `docs/PLAY_DATA_SAFETY.md` |
| ⬜ | Cuestionario de clasificación IARC y público objetivo 13+ | `docs/FICHA_PLAY.md` |
| ⬜ | Confirmar nombre del paquete `com.thunderdarkness.sopazz` | Es permanente una vez subido |
| ✅ | Sin música ni arte de terceros | Sonidos sintetizados por script, icono propio |

## 5. Seguridad (`security-audit-juegos`)

Auditoría en curso; el informe se añadirá aquí.

## 6. Orden para subir

1. Decidir nombre y paquete definitivos (no se pueden cambiar después).
2. Instalar plugins, poner IDs reales, crear productos (`INTEGRACION_ANDROID.md`).
3. Crear la clave de release y activar Play App Signing.
4. Exportar el AAB de release y subirlo a **prueba interna**.
5. Pasar la lista de prueba en móvil (`INTEGRACION_ANDROID.md` §6).
6. Rellenar Data safety, IARC, público objetivo y ficha.
7. Prueba cerrada con 12+ testers durante 14 días si la cuenta de desarrollador es
   personal y nueva (requisito actual de Google para cuentas personales; confirmarlo
   en la consola del dueño).
8. Producción con despliegue escalonado (20 % → 100 %).
