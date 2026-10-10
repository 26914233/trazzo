# Recon map: EthrA (Windows; Switch 2 anunciado) → RONIN (Android, horizontal)

Hecho con la skill `replica-recon` (Replica, MIT) adaptada a un juego: las «pantallas» son el HUD
y los menús, y los «flujos», los bucles de juego.

- **Alcance (slice):** el núcleo de combate y exploración. Incluye cámara, movimiento, armas y
  combos, defensa, sensación de impacto, enemigos, jefe, HUD y guardado. Se deja fuera lo que es de
  EthrA: el compañero mago Veil, el oficio (forja, cocina, pesca, granja, casa), el cooperativo en
  línea y su mundo.
- **Para:** RONIN, el juego propio del usuario (Godot 4.7, horizontal desde la 0.13, móvil), con su historia y su
  bestiario. Se copian funciones y ritmo, nunca arte, nombres, textos ni código.
- **Fecha:** 2026-10-10

## Fuentes

| # | fuente | URL | notas |
| --- | --- | --- | --- |
| 1 | ficha de Steam (app 2177510) | https://store.steampowered.com/app/2177510/EthrA/ | Género, estilo "3D pixel-art", Bob y Veil, armas, recomienda mando. Sin fecha; solo prueba abierta |
| 2 | ficha de Steam (app 4986460) | https://store.steampowered.com/app/4986460 | Misma descripción |
| 3 | video de gameplay (unos 85 min) | https://www.youtube.com/watch?v=4BOxYjCXZWM | Analizado con `vidiq_video_watch`; YouTube bloquea la descarga desde la nube. Los minutos citados salen de ese análisis |
| 4 | noticia de Switch 2 | https://nintendoeverything.com/ethra-secures-future-release-on-nintendo-switch-2/ | Financiado en Kickstarter; Switch 2 en el futuro |
| 5 | presskit (devuego.es) | https://www.devuego.es/presskit/ethra | Error 503 al leerlo: **sin verificar** |

No hay cuenta del usuario en EthrA (es una prueba abierta de PC), ni API pública, ni código: no se
usa nada de eso.

## Bucle principal

Explorar un mundo 3D con personajes en pixel art, encontrar enemigos y pelear con combos por arma,
esquiva y parada perfecta, con mucho impacto en cada golpe; vencer jefes y mejorar el equipo.

## Pantallas (HUD y menús)

| ID | pantalla | cómo se llega | propósito | componentes clave | estados vistos |
| --- | --- | --- | --- | --- | --- |
| S01 | Mundo con HUD | jugando | moverse y pelear | retrato, vida, maná, aguante, ranura rápida, brújula | explorando, en combate, con buff (cuadraditos amarillos) |
| S02 | Combate con objetivo fijado | botón de fijar | pelear contra uno | retícula roja, barra de vida del objetivo, números de daño | fijado, cambio de objetivo (02:22) |
| S03 | Rueda de órdenes de Veil | L1/R1 | hechizos y órdenes del compañero | menú radial en cámara lenta | abierta (03:24) |
| S04 | Ficha del personaje | menú | atributos | FUE, INT, CON, RES, MEN, ataques y defensas, postura, elementos | lleno (26:30, 62:23) |
| S05 | Forja y oficio | estación | crear equipo y consumibles | lista de recetas y materiales | abierta (28:30, 46:33) |
| S06 | Objetos rápidos | cruceta | curarse en combate | ranuras con número (pociones, pan, vendas) | con objetos (15:30) |
| S07 | Diálogo con desenfoque | hablar con NPC | historia y misiones | caja de texto, fondo desenfocado | abierto (25:20) |
| S08 | Guardado (buzón) | interactuar | guardar | — | (25:12) |
| S09 | Jefe | zona del cementerio | examen de combate | barra del jefe, esbirros | combate (79:24-83:22) |
| S10 | Muerte o derrota | — | — | — | **no visto** en el análisis |

## Flujos

```
F01 Pelear contra un grupo
    S01 -> S02 (fijar) -> cadena de 3 cortes -> esquivar el contraataque -> S02 (siguiente)
    edge: enemigo con escudo que bloquea (49:26), esqueletos casi inmunes al físico (32:27)

F02 Parada perfecta y contraataque
    S02 -> bloquear justo antes del impacto -> destello amarillo -> el rival queda aturdido -> remate
    edge: bloquear tarde gasta postura y aguante (05:08)

F03 Cambiar de arma a mitad de combate
    S01 -> cambiar juego de armas -> otra cadena (espada / lanza / mandoble)
    edge: el mandoble es lento: hay que buscar el hueco (39:20)

F04 Jefe
    S09 -> leer los avisos (golpe vertical, estocada, barrido) -> esbirros -> magia o kiting -> victoria
    edge: esbirros que reaparecen (80:15)

F05 Guardar y mejorar
    S08 guardar -> S05 forjar con minerales -> S04 ver los atributos
```

Toques del camino feliz de F01 en RONIN: fijar es automático, así que bastan **3 toques** a
«Atacar». En EthrA son 1 de fijar más 3 de ataque.

## Componentes

| componente | variantes | estados | dónde |
| --- | --- | --- | --- |
| Barra de vida | jugador, objetivo, jefe | llena, bajando (la parte reciente en claro), vacía | S01, S02, S09 |
| Barra de aguante | jugador | llena, gastada, recargando | S01 |
| Retícula | objetivo fijado | fijado, cambiando | S02 |
| Número de daño | normal, crítico | sube y se desvanece | S02 |
| Destello de parada | perfecto | instante | S02 |
| Aviso de ataque enemigo | (en EthrA, por la animación) | anticipación | S02, S09 |
| Menú radial | órdenes, hechizos | abierto en cámara lenta | S03 |
| Ranura de objeto | con cantidad | vacía, llena | S06 |

## Modelo de datos inferido

```
Arma       nombre, tipo (espada|lanza|mandoble|arco|dagas), cadena[corte], cargado, a_la_carrera
           evidencia: 02:38-03:03, 21:28, 39:20; confianza: alta (los tiempos, estimados)
Corte      anticipacion, activo, recuperacion, danio, postura, alcance, cono, pausa, sacudida
           evidencia: análisis cuadro a cuadro aproximado; confianza: media
Enemigo    tipo, vida, postura, peso, ataques[aviso, activo, recuperacion, parable], resistencias
           evidencia: limos, setas, bandidos con escudo, esqueletos; confianza: media
Jefe       fases, ataques, esbirros
           evidencia: 79:24-83:22; confianza: media
Personaje  vida, mana, aguante, atributos (FUE, INT, CON, RES, MEN), postura, elementos
           evidencia: S04; confianza: alta
Partida    guardada en buzones
           evidencia: 25:12; confianza: media
```

En RONIN esto ya existe como datos en `godot/scripts/armas.gd` y `enemigos.gd`, y como la partida
guardada en `partida.gd`.

## Matriz de funciones

En `replica/features.csv`, con la columna `clone` puesta según lo que ya hace RONIN 0.12. La
puntúa `replica-diff` (`parity.py`).

## Lo que no se copia (filas `skip`)

- **Veil, el compañero mago**, y su rueda de órdenes: es la identidad de EthrA. RONIN tiene a Shiro,
  que no pelea, por decisión del usuario.
- **Oficios** (forja, cocina, pesca, granja, casa): fuera del alcance del capítulo 1, y RONIN tiene
  la regla de «sin farmeo automático».
- **Cooperativo en línea**: servidor y red; no está en el plan de RONIN.
- **Arte, sonido, nombres, mundo y textos** de EthrA: son suyos.
- **Atributos de RPG** (FUE, INT...): RONIN es de precisión con iaidō, no de números (decisión del
  01-10-2026). Se propondría como DECISIÓN si se quisiera.

## Tamaño

10 pantallas, 5 flujos y 6 entidades. Lo difícil:
1. **La sensación de impacto**: tiempos, pausa y reacciones. Necesita probar en el móvil.
2. **Animaciones por corte y por arma** en pixel art: se hornean desde los modelos.
3. **El jefe legible** con avisos claros en la pantalla pequeña de un móvil.

Para el núcleo de combate el tamaño es **M** (unas semanas). Ya está casi todo en la 0.12; lo que
falta está en `replica/parity.md`.
