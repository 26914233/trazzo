# Recon — juego de romper ladrillos (método replica)

Clean-room: se copia la **función y el flujo** del género, no el código, el arte, los nombres
ni los textos de ninguna app. Referencia del dueño: «Estrella de Brick Breaker» (paleta,
bola metálica, ladrillos brillantes, fondo espacial).

## Fuentes (públicas)
- Búsqueda pública de iTunes y RSS de reseñas del App Store (EE. UU.), 2 páginas por app,
  a ritmo humano: Huge Bricks, Classic BrickBreaker, Many Bricks Breaker, Simple Brick
  Breaker, Brick Breaker: Legend Balls, Bricks Breaker Quest. Las reseñas en bruto no se
  suben al repo (material de investigación).
- Fichas públicas encontradas en la web: Bricks Breaker - Pro (101+ niveles, ladrillos que
  dan vida o misiles) y un Breakout de itch.io (9 potenciadores, buenos y malos).
- Google Play no se lee con herramientas automáticas (regla del método).

## Qué odian (253 reseñas de 1–3★; recuento por palabras clave, aproximado)
| Tema | Reseñas | Ejemplo (resumido) |
|---|---|---|
| Anuncios | 147 | «anuncios cada dos niveles», «borrada a los 15 minutos por los anuncios» |
| Pago, vidas, monedas | 45 | «¿por qué pago Arcade para ver anuncios?» |
| Fallos y cierres | 22 | «se cierra al terminar cada nivel», «se congela en el 24 y vuelve al 21» |
| Sonido que no se apaga | 7 | «el botón de silencio no funciona» |
| Demasiado fácil / se juega solo | varios | «demasiado fácil durante 200 niveles» |
| Atascos | varios | «me quedé bloqueado en un nivel» (bola en bucle) |

## Pantallas del género
S01 menú · S02 mapa de mundos/niveles · S03 partida · S04 pausa · S05 nivel superado
(estrellas) · S06 sin vidas (reintentar) · S07 ajustes · S08 modo infinito · S09 desafío diario.

## Bucle principal
Elegir nivel → lanzar la bola con un toque → mover la paleta con el dedo → romper todos los
ladrillos rompibles (potenciadores al caer) → estrellas → siguiente nivel.

## Lo que no se copia
Arte, nombres, sonidos y niveles concretos de otras apps; su modelo de anuncios y vidas de
pago; el editor de niveles (fuera de la primera versión).

## Tamaño
M: física propia y determinista, ~120 niveles hechos con un generador + plantillas de
dibujos, 7 potenciadores, 3 modos. Lo difícil: el *feel* (rebote, partículas, sonido), evitar
que la bola atraviese ladrillos a alta velocidad y la curva de dificultad.
