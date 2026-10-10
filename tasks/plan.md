# Plan: Palabrario (sopa de letras) y familia de juegos

## Estado (2026-10-09)

**Palabrario** (antes "Sopazz") está jugable, con contenido completo y listo para el
tramo final de publicación:

- 545 sopas en 44 temas (6.540 palabras), cuatro dificultades, sopa del día, racha.
- Diseño **Cielo** (elegido por el dueño); Papel y Noche elegibles en Ajustes.
- **App de pago de 4,99 US$**, sin anuncios ni compras dentro (decisión del dueño).
- 96 comprobaciones headless en verde; APK y AAB de release exportados y verificados.

Detalle de lo pendiente en `juegos/palabrario/docs/LANZAMIENTO.md`.

## Decisiones de arquitectura (vigentes)

- **Godot 4.7, `gl_compatibility`, vertical 1080×1920.** Llega a móviles baratos.
- **Lógica pura separada de las escenas** (generador, economía, reglas): se prueba en headless.
- **Contenido en texto** (`datos/fuente/*.txt`) validado por script y convertido a JSON.
- **Diseños como datos** (`Estilo.VARIANTES`): paleta, fuentes, radios y sombras.
- **Guardado firmado** con escritura atómica, esquema validado y copia del archivo rechazado.
- **Sin red**: el APK solo pide `VIBRATE`; el formulario de datos de Play queda en "no recoge datos".

## Historial de decisiones del dueño

1. Android / Google Play, Godot 4, un juego completo primero.
2. Sopa de letras con más de 500 sopas por temas y subtemas.
3. Pago único de ~5 US$ → **app de pago** (no gratis con desbloqueo).
4. Diseño **Cielo**.
5. Nombre **Palabrario** (Sopazz no encajaba con el tipo de juego).

## Siguiente

1. Revisión humana de las palabras, prueba en un móvil y subida a prueba interna.
2. Lienzo Zen (dibujo, colorear, mandalas) con el mismo modelo de pago — `juegos/HOJA_DE_RUTA.md`.

## Preguntas abiertas para el dueño

- ¿Se quitan los diseños Papel y Noche de Ajustes o se dejan como opción?
- ¿Cuenta de desarrollador de Play ya creada y con perfil de pagos?
- ¿Quién revisa las 6.540 palabras antes de publicar?
