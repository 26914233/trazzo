# Checklist de lanzamiento — Palabrario 1.0.0 (Google Play, app de pago + pistas opcionales)

Adaptado de la skill `launch-checklist` a un juego móvil de un jugador, sin servidor y
sin anuncios. Única compra dentro: paquetes de pistas con Google Play Billing.
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

La auditoría completa (`security-audit-juegos`) se hizo sobre el modelo anterior, con
anuncios y compras. Al pasar a app de pago desapareció casi toda esa superficie:

| Hallazgo anterior | Estado ahora |
|---|---|
| SEC-001 (alto): derechos de pago en un guardado reconstruible | **Ya no aplica**: el guardado no contiene nada que valga dinero |
| SEC-003, 005, 007, 012: compras, catálogo, bonus, premiados | **Ya no aplican**: no hay compras ni anuncios |
| SEC-011: versión de plugins sin fijar | **Ya no aplica**: no hay plugins |
| SEC-002: reloj del móvil | Sigue corregido (la fecha del juego no retrocede); ahora solo afecta a la racha y a la sopa del día |
| SEC-004, 006, 009, 010 | Siguen corregidos y con prueba |
| SEC-008: APK de prueba debuggable | Sigue documentado: no repartirlo |
| Nuevo: piratería del APK de pago | Riesgo aceptado propuesto (sin servidor no hay protección fuerte); revisar *App integrity* en Play Console |

**No se ha vuelto a pasar la skill completa** tras el cambio. Con una superficie tan
pequeña, basta con un `security-audit-juegos quick` antes de subir.

## 5. Orden para subir

1. Perfil de pagos y ficha de la app creada **como app de pago**.
2. Clave de release y Play App Signing (`docs/PUBLICAR.md`).
3. AAB de release → pista de **prueba interna**; probar en un móvil (§5 de `PUBLICAR.md`).
4. Data safety, IARC, público objetivo, ficha, capturas, precio.
5. Prueba cerrada con testers el tiempo que exija Google para cuentas personales nuevas
   (requisito actual de 12 testers durante 14 días; confirmarlo en la consola).
6. Producción con despliegue escalonado.
