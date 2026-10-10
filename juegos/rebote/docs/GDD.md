# GDD — Rebotazz (nombre de trabajo) · romper ladrillos

## Concepto
El clásico: una paleta abajo que mueves con el dedo, una bola que rebota y ladrillos arriba
que se rompen. Que no caiga la bola. Referencia del dueño: «Estrella de Brick Breaker».
Se copia la función del género (método replica, `RECON.md`), no su arte ni sus niveles.

## Lo que lo diferencia (de las reseñas de la competencia)
- **Gratis, con anuncios que no castigan** (147 de 253 quejas son por anuncios): nada en
  los 10 primeros niveles, nunca tras perder, como mucho 1 cada 3 niveles ganados.
  Sin vidas de pago ni esperas: perder nunca bloquea.
- **Nunca se atasca:** si la bola entra en un bucle sin tocar ladrillos, se corrige sola.
- **Sonido y vibración que se apagan de verdad.**
- **Curva de dificultad que reta desde pronto** (quejas de «se juega solo»).

## Controles
- Arrastrar en cualquier punto de la mitad de abajo mueve la paleta (sigue al dedo en
  horizontal, con el dedo por debajo de la paleta para no taparla).
- Tocar para lanzar la bola (y para soltarla si está pegada con el imán).
- El láser dispara solo mientras dura.

## Reglas
- 3 vidas por nivel. Perderlas todas: reintentar el nivel (sin castigo ni esperas).
- Nivel superado al romper todos los ladrillos rompibles.
- Estrellas: 3 sin perder vidas, 2 perdiendo una, 1 al superarlo.
- Puntos por ladrillo, multiplicador de combo mientras la bola no toca la paleta.

## Ladrillos
| Tipo | Golpes | Notas |
|---|---|---|
| Normal | 1 | 6 colores |
| Duro | 2–3 | se agrieta en cada golpe |
| Metal | ∞ | indestructible, no cuenta para terminar |
| Explosivo | 1 | rompe los 8 vecinos |
| Sorpresa | 1 | siempre suelta un potenciador |

## Potenciadores (cápsulas que caen; se recogen con la paleta)
Paleta ancha · Multibola (×3) · Láser · Imán · Bola lenta · Bola de fuego (atraviesa) ·
Vida extra. Negativo opcional en mundos avanzados: Paleta corta.

## Física (propia, determinista)
- Bola circular contra rectángulos; subpasos para que nunca atraviese un ladrillo aunque vaya
  rápida (desplazamiento por subpaso ≤ medio radio).
- Ángulo de salida según el punto de la paleta: centro = recto, bordes = ±60°.
- Velocidad mínima vertical para que no quede casi horizontal; empujón suave si pasan
  10 s sin tocar ladrillos (anti-atasco).
- La velocidad sube poco a poco dentro del nivel y de un mundo a otro (`balance-check`).

## Contenido
6 mundos × 20 niveles = 120, con fondo propio: Espacio, Océano, Bosque, Desierto, Volcán,
Cristal. Niveles hechos con un generador (`herramientas/niveles.py`): dibujos de píxeles
hechos de ladrillos (corazón, nave, flor, pez…) más patrones (pirámide, ajedrez, diamante,
túneles de metal). Cada 10 niveles, uno especial (ladrillos que se mueven o casi todo metal).

## Modos
Aventura (mundos y estrellas) · Infinito (filas que bajan; récord) · Desafío del día (nivel
generado con la fecha, igual para todos).

## Estilo visual (ui-ux-pro-max: «claymorphism» de juego casual)
Fondo espacial oscuro con estrellas y nebulosa (#0B1026 → #1E1B4B). Ladrillos «chunky» con
brillo y bisel, colores caramelo; rosa #EC4899, violeta #8B5CF6 y dorado de recompensa
#F59E0B. Tipografía Fredoka (ya incluida, OFL). Paleta en forma de cápsula, propia (no la de
la referencia). Partículas al romper, pequeño temblor en las explosiones (`motion-design`).

## Técnica
Godot 4.7, GL Compatibility, vertical 1080×1920, mismo molde que Palabrario y Lienzo Zen
(estilo, sonido, guardado atómico, pruebas sin pantalla y capturas). Dibujo de ladrillos con
`_draw` y texturas generadas en código. Sonidos sintetizados (licencia propia).

## Negocio
Decidido por el dueño (10-oct-2026): **gratis con anuncios**, personalización (paletas,
bolas, estelas) y microtransacciones (gemas y quitar anuncios). Detalle, reglas y precios
en `MONETIZACION.md`; integración real en `INTEGRACION_ANDROID.md`.
