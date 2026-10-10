# EthrA como referencia del combate de RONIN

Fuentes (10-10-2026):
- **Ficha de Steam** (app 2177510): <https://store.steampowered.com/app/2177510/EthrA/>
- **Video de gameplay**: <https://www.youtube.com/watch?v=4BOxYjCXZWM>. YouTube bloqueó la
  descarga desde la nube, así que lo analizó la herramienta `vidiq_video_watch` (vidIQ). Los
  minutos que se citan abajo salen de ese análisis. Lo marcado como **observado** está en el
  video. Lo que dice **inferido** es nuestro, no de EthrA.

Se copian **mecánicas y ritmo**, no recursos. El arte, los sonidos, los nombres y el código son de
RONIN. La historia y el bestiario de RONIN no cambian.

## 1. Lo que es EthrA (verificado en Steam)

| Dato | Valor |
|---|---|
| Estudio | StoneLab Games |
| Género | RPG de acción en mundo abierto, tercera persona, "3D pixel-art" |
| Plataformas | Windows y, en el futuro, Switch 2. **No hay versión para móvil** |
| Controles | Recomienda mando; no tiene controles táctiles |
| Personajes | Bob (cuerpo a cuerpo) y Veil (magia; va a su espalda o recibe órdenes) |
| Armas | Espada, escudo, lanza, mandoble y arco; dagas dobles planeadas |

## 2. Mecánicas observadas y cómo pasan a RONIN

| Mecánica en EthrA | Evidencia | Confianza | En RONIN |
|---|---|---|---|
| Espada: cadena de 3 cortes (horizontal, revés, estocada o corte bajo) | 02:38-03:03, 10:38 | Alta | **Katana**: 4 cortes de iai (nukitsuke, kesa-giri, gyaku-kesa, karatake-wari) |
| Mantener ataque: carga y corte giratorio de 360° | 02:59 | Alta | Mantener «Atacar» 0,55 s: **iai de luna creciente** (360°) |
| Ataque a la carrera | 02:46 | Media | Pendiente |
| Lanza: estocadas rápidas, largas y estrechas | 21:28, 36:00 | Media | **Yari**: 3 estocadas, 2,6 m, cono de 40° |
| Mandoble: barridos lentos (~20-25 cuadros de preparación), anchos, rompen postura | 39:20-39:35, 49:22 | Media (cuadros estimados) | **Nodachi**: 0,36 s de preparación, cono de 200°, rompe la postura en 2 golpes |
| Esquiva: paso corto con el objetivo fijado y voltereta sin fijar; gasta aguante | 04:47-04:59 | Alta | **Esquiva** de 0,32 s, invulnerable entre 0,03 y 0,24 s, 25 de aguante; cancela la recuperación |
| Bloqueo y parada perfecta (destello amarillo, aturde, permite contraatacar) | 05:04-06:01, 81:08 | Alta | Ya existía el **iaidō**; ahora, tras un iai perfecto, atacar sigue la cadena desde el 2.º corte |
| Congelación de 2-5 cuadros al golpear, más fuerte con el mandoble | 10:41, 39:35 | Media | Pausa por corte: 0,05-0,16 s, x1,25 si se rompe la postura, x1,4 si mata |
| Sacudida pequeña en golpes fuertes | 39:35, 44:03 | Media | Sacudida por corte: 0,22-0,8 |
| Chispas y estela del arma | 02:38 | Alta | Chispas y estela, que ya existían |
| Silueta blanca del enemigo al recibir daño | 10:41 | Alta | Ya existía (`destello`) |
| Números de daño | 10:41, 49:25 | Alta | **Números flotantes** |
| Retroceso; el último golpe de la cadena lanza lejos | 10:41, 39:35 | Alta | Empuje por corte, dividido por el peso del enemigo |
| Muerte: estallido de polvo de píxeles | 12:10, 39:36 | Alta | **Polvo de píxeles** |
| Fijado de objetivo con retícula y barra de vida | 02:18-02:29 | Alta | Por ahora, giro automático al rival más cercano (pensado para el móvil). Retícula pendiente |
| Barra de aguante (naranja) | 44:33 | Alta | **Barra de aguante** en el HUD |
| Personajes sprite pixel art en 8 direcciones dentro de un mundo 3D | 01:00 | Alta | Ya existía (DECISIÓN 20E) |
| Animación de 6-10 cuadros por segundo, sin cuadros de arrastre ni estirar y aplastar | — | Media | Anime limitado a 12 cuadros por segundo (ya existía) |
| Cámara elevada a 25-35°, a unos 4-6 m, gira con el stick derecho | 01:30, 14:26 | Media | Cámara orbital (ya existía) |
| Jefe esqueleto con mandoble: golpe vertical, estocada y barrido, con esbirros | 79:24-83:22 | Media | Pendiente: jefe del bestiario |
| HUD: retrato, vida, maná y aguante arriba a la izquierda; brújula arriba | 01:30, 10:35 | Alta | Vida, espíritu, aguante y arma arriba a la izquierda |
| Puntos de guardado en buzones | 25:12 | Media | No aplica (RONIN guarda solo) |

## 3. Tiempos de los cortes (`godot/scripts/armas.gd`)

Segundos: preparación / corte / recuperación.

| Arma | Corte | Tiempos | Daño | Postura | Alcance | Cono |
|---|---|---|---|---|---|---|
| Katana | Nukitsuke | 0,05 / 0,12 / 0,18 | 1 | 0,25 | 1,7 | 110° |
| Katana | Kesa-giri | 0,06 / 0,12 / 0,18 | 1 | 0,25 | 1,7 | 110° |
| Katana | Gyaku-kesa | 0,06 / 0,12 / 0,20 | 1 | 0,25 | 1,7 | 110° |
| Katana | Karatake-wari | 0,12 / 0,14 / 0,36 | 1 | 0,45 | 1,9 | 90° |
| Katana | Cargado: luna creciente | 0,08 / 0,18 / 0,45 | 2 | 0,8 | 2,4 | 360° |
| Yari | Tsuki, Ni-dan, Sandan | 0,06-0,12 / 0,10-0,14 / 0,20-0,34 | 1 | 0,2-0,35 | 2,6-2,9 | 40-50° |
| Yari | Cargado: estocada del cometa | 0,10 / 0,22 / 0,45 | 2 | 0,6 | 4,0 | 45° |
| Nodachi | Yoko-nagi, Gyaku-nagi | 0,34-0,36 / 0,16 / 0,42-0,55 | 2 | 0,55-0,75 | 2,3 | 200° |
| Nodachi | Cargado: tenchi-giri | 0,30 / 0,20 / 0,65 | 3 | 1,2 | 2,8 | 360° |

**Reglas de la cadena:**
- La pulsación se guarda 0,25 s y solo encadena durante la recuperación del corte anterior.
- La esquiva puede cancelar un corte desde la mitad de su fase de corte.
- Tras un iai perfecto, atacar en los 0,6 s siguientes sigue desde el 2.º corte.
- Con la postura rota, el enemigo queda vendido 1,2 s y el siguiente golpe lo remata.

## 4. Lo que falta por verificar o hacer

- Medir los cuadros exactos con el video en local: ahora son estimaciones del análisis de vidIQ.
- Animaciones propias de cada corte y arma. Por ahora la cadena alterna los cuadros de «ataque» y
  de «desenvaine» del sprite: hay que hornear poses nuevas.
- Jefe con fases y enemigos del bestiario en combate.
- Retícula del objetivo fijado.
- Juego en vertical.
