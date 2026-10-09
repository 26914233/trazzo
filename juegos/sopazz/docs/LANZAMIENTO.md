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

Auditoría completa (6 categorías) hecha por el agente `security-engineer` siguiendo la
skill, con verificación propia: forjó un guardado válido, analizó el APK y probó las
fechas. **Resultado: 0 críticos, 1 alto, 2 medios, 9 bajos, 4 por validar.** Cada
corrección lleva prueba en `tests/pruebas.gd`.

| ID | Sev. | Hallazgo | Estado |
|---|---|---|---|
| SEC-001 | ALTO | La clave del guardado se puede reconstruir desde el cliente y ahí viven los derechos de pago | **Mitigado en parte.** "Quitar anuncios" y los temas comprados se sincronizan con Play en cada arranque (Play manda). **Queda abierto:** el saldo de fichas es local; forjarlo exige root y extraer la sal. Arreglo completo = servidor de compras. **Decisión del dueño: aceptar el riesgo o hacer servidor.** |
| SEC-002 | MEDIO | Cambiar la fecha del móvil regalaba fichas, pistas y premiados | ✅ Corregido: la fecha del juego nunca retrocede |
| SEC-003 | MEDIO | Compras sin verificar; reembolsos no se retiraban | **Mitigado en parte:** los permanentes reembolsados desaparecen al sincronizar. Sin verificación de firma ni servidor; un billing falso con root sigue pudiendo dar fichas |
| SEC-004 | BAJO | Guardado fusionado sin validar tipos ni rangos | ✅ Corregido |
| SEC-005 | BAJO | `conceder()` sin lista blanca | ✅ Corregido |
| SEC-006 | BAJO | Guardado rechazado se perdía | ✅ Corregido: se aparta en `.rechazado` |
| SEC-007 | BAJO | Borrar datos devuelve el bonus de 300 fichas de "quitar anuncios" | Riesgo aceptado propuesto (impacto bajo, no se acumula) |
| SEC-008 | BAJO | El APK de prueba es debuggable y con clave de depuración | Documentado: no repartirlo; a Play solo va el AAB de release |
| SEC-009 | BAJO | Los logs decían por qué se rechazaba el guardado | ✅ Corregido en release |
| SEC-010 | BAJO | Temas poco validados; palabras en BBCode sin escapar | ✅ Corregido |
| SEC-011 | BAJO | Plugins sin versión fijada | Documentado en `INTEGRACION_ANDROID.md` |
| SEC-012 | BAJO | Recompensa de premiados solo en cliente | Riesgo aceptado propuesto (valor bajo; SSV necesita servidor) |
| NV-01 | — | Consentimiento: si UMP falla se piden anuncios igual; edad fija | needs_validation: probar en móvil con geografía EEA |
| NV-02 | — | URL de privacidad | La página ya existe en el repo; falta comprobarla publicada |
| NV-03 | — | Flags del AAB de release | AAB de release construido y firmado; `debuggable` sin comprobar (no hay bundletool aquí) |
| NV-04 | — | CVE de plugins | Sin plugins instalados no se puede contrastar |

**Recomendación de la skill:** con SEC-001 abierto, *FIX BEFORE SHIPPING*, salvo que el
dueño acepte por escrito el riesgo del saldo de fichas local (juego de un jugador, sin
ranking ni multijugador). El informe completo está pendiente de que el dueño apruebe
guardarlo en `production/security/security-audit-2026-10-09-full.md`.

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
