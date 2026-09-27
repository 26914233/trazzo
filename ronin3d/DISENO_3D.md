# RONIN 3D — Especificación común de la versión 3D

Documento que siguen **todas** las versiones 3D (Godot, Three.js, Ursina) para que la
comparación entre motores y estéticas sea justa: mismo patio, mismas medidas, mismos
personajes, mismos controles y los mismos sprites y texturas (`recursos/`).

La historia no cambia: es la del prototipo 2D (`samurai.py`). Los textos son los mismos.

---

## 1. Qué es esta versión

**Capítulo 1 en 3D:** el patio del castillo de Hoshiyama, de noche. Akira debe cruzar
el patio y llegar al portón del este. Seis soldados con lanza patrullan. La cámara gira
alrededor de Akira y se acerca o aleja.

Flujo: introducción (texto) → patio → tocar el portón → texto de cierre.
Si la vida llega a 0: «Akira ha caído» → reintentar.

## 2. Unidades y ejes

Metros. **Y hacia arriba**, **X hacia el este**, **Z hacia el sur** (norte = −Z).
El suelo del patio está en y = 0.

## 3. El patio (medidas exactas)

| Elemento | Centro (x, y, z) | Tamaño (x × y × z) | Notas |
| --- | --- | --- | --- |
| Suelo del patio | (0, 0, 0) | 48 × — × 32 | Losas de piedra (`losa.png`) |
| Terreno exterior | (0, −0.01, 0) | 200 × — × 200 | Tierra oscura, fuera de los muros |
| Muro norte | (0, 2, −16.5) | 50 × 4 × 1 | Base 1,2 m de piedra + yeso blanco encima |
| Muro sur | (0, 2, 16.5) | 50 × 4 × 1 | Igual |
| Muro oeste | (−24.5, 2, 0) | 1 × 4 × 32 | Igual |
| Muro este (tramo norte) | (24.5, 2, −9.5) | 1 × 4 × 13 | Deja un hueco de 6 m para el portón |
| Muro este (tramo sur) | (24.5, 2, 9.5) | 1 × 4 × 13 | Igual |
| Tejadillo de los muros | encima de cada muro | ancho 1,6, alto 0,4 | `tejas.png` |
| Portón (hojas) | (24.6, 2.2, 0) | 0,3 × 4,4 × 6 | `porton.png`; macizo (no se atraviesa) |
| Postes del portón | (24.5, 2.5, ±3.5) | 1 × 5 × 1 | Madera oscura |
| Dintel y tejado del portón | (24.5, 5.3, 0) | 1,4 × 0,6 × 8,5 | Tejado de tejas por encima |
| Pasarela de madera | (−3, 0.6, −12) | 10 × 1,2 × 4 | Se sube saltando o por el escalón |
| Escalón de la pasarela | (−3, 0.3, −9.5) | 2 × 0,6 × 1 | Madera |
| Muro bajo | (−8, 0.6, 4) | 0,8 × 1,2 × 6 | Piedra; se salta |
| Bloque de piedra A | (6, 0.4, −6) | 2 × 0,8 × 2 | |
| Bloque de piedra B | (8.2, 0.8, −6) | 2 × 1,6 × 2 | |
| Linternas de piedra | (±12, 0, ±8) | cilindro r 0,4, alto 1,6 | Cuatro; luz tenue dentro |
| Pozo | (0, 0, 8) | cilindro r 1,0, alto 0,9 | Con tejadillo sobre dos postes |
| Cajas | (16, 0.5, 12), (17.2, 0.5, 12.4), (16.6, 1.5, 12.2) | 1 × 1 × 1 | La tercera va encima |
| Barriles | (−18, 0.5, −12), (−18.9, 0.5, −11.3) | cilindro r 0,45, alto 1 | |

**Torreón (tenshu), fuera del patio, al norte**, centrado en (0, 0, −32):
base de piedra 18 × 6 × 18; piso 1: 13 × 4,5 × 13 (y de 6 a 10,5) con tejado de
17 de ancho y 2,5 de alto; piso 2: 10 × 4 × 10 (y de 11 a 15) con tejado de 13 × 2,2;
piso 3: 7 × 3,5 × 7 (y de 15,5 a 19) con tejado de 10 × 3 y remate dorado.
Ventanas iluminadas en cada piso. Se ve por encima del muro norte.

**Antorchas** (poste de 2,6 m; fuego a 2,8 m; luz puntual cálida #ffae5c, alcance
9 m, parpadeo): (−12, −14.5), (8, −14.5), (−8, 14.5), (8, 14.5), (−23, −6), (−23, 6),
(22.5, −4.5), (22.5, 4.5)  (coordenadas x, z).

**Cielo y luz:** noche azul oscura con estrellas. Luna grande en la dirección
normalizar(−0.35, 0.5, −0.8) (detrás del torreón). Luz de luna direccional azulada
#9fb4ff (intensidad baja) con sombras. Luz ambiente #1a1f3a. Niebla nocturna suave.

## 4. Personajes

### Akira
- Empieza en (−20, 0, 0) mirando al este.
- Cápsula: alto 1,7, radio 0,35.
- Velocidad 5 m/s; con SHIFT 8 m/s. Movimiento **relativo a la cámara**.
- Salto 7,5 m/s con gravedad 22 m/s² (sube ~1,28 m: alcanza la pasarela).
- 5 puntos de vida. Tras un golpe: 1 s invulnerable (parpadea) y retroceso de 6 m/s
  durante 0,25 s sin control.
- Ataque (J o clic izquierdo): dura 0,3 s; corta entre 0,05 y 0,2 s; alcance 1,6 m en un
  cono de 100° al frente; enfriamiento 0,4 s. Cada ataque golpea a cada soldado una vez.

### Soldados (6)
- 2 puntos de vida. Patrullan de A a B a 2 m/s.
- Ven a Akira a 9 m en un cono de 120° al frente, o a 3 m en cualquier dirección.
- Persiguen a 3,5 m/s, sin alejarse más de 8 m de su recorrido de patrulla.
- A 1,8 m: **aviso «!» 0,5 s** → estocada 0,2 s (alcance 2,1 m, ancho 0,8 m) →
  recuperación 0,6 s. La lanza alcanza más que la espada (2,1 m frente a 1,6 m): hay que
  acercarse durante el aviso y golpear, o apartarse/saltar.
- Golpeado: aturdido 0,4 s con retroceso de 5 m/s. Derrotado: cae y desaparece en 1,2 s.
- Si pierden de vista a Akira 2 s, vuelven a patrullar.

| Soldado | Punto A (x, y, z) | Punto B (x, y, z) |
| --- | --- | --- |
| 1 | (−14, 0, −4) | (−14, 0, 6) |
| 2 | (−7, 1.2, −12) | (1, 1.2, −12) — sobre la pasarela |
| 3 | (−2, 0, 4) | (6, 0, 10) |
| 4 | (10, 0, −12) | (16, 0, −4) |
| 5 | (8, 0, 2) | (16, 0, 8) |
| 6 | (19, 0, −2) | (19, 0, 2) — guarda el portón |

## 5. Cámara

Órbita alrededor de Akira (sigue su posición con suavizado).
- Posición = objetivo + (sen(giro)·cos(incl)·d, sen(incl)·d, cos(giro)·cos(incl)·d).
- Por defecto: distancia d = 12 m, inclinación 38°, giro −60°, campo de visión 38°.
- **Q / E** giran (90°/s). **Botón derecho + arrastrar** gira e inclina.
- **Rueda del ratón o + / −**: zoom entre 7 y 18 m. **R / F**: inclinación entre 20° y 60°.

## 6. Controles (todas las versiones)

| Tecla | Acción |
| --- | --- |
| W A S D / flechas | Moverse (relativo a la cámara) |
| SHIFT | Correr |
| ESPACIO | Saltar |
| J / clic izquierdo | Atacar con la espada |
| Q / E, botón derecho | Girar la cámara |
| Rueda, + / − | Zoom |
| R / F | Inclinar la cámara |
| ENTER | Continuar en los textos |
| ESC | Pausa (Q en pausa: salir) |
| 1 / 2 / 3 | Cambiar de estética (solo Godot) |

## 7. HUD

- Arriba a la izquierda: «AKIRA» y 5 rombos rojos (vida).
- Arriba a la derecha: «Soldados derrotados: n/6».
- Abajo: ayuda de controles durante los primeros 10 s.
- «!» rojo sobre el soldado que va a atacar.
- Esquina inferior derecha: nombre del motor y la estética (para comparar capturas).

## 8. Estéticas

### HD-2D (la de comparación entre motores)
- Personajes: **sprites pixel art** de `recursos/akira.png` y `recursos/soldado.png`,
  dibujados como *billboard* vertical (siempre de cara a la cámara pero de pie), filtro
  *nearest* (píxel nítido), **iluminados** por la luna y las antorchas.
- Escenario: geometría 3D simple con las **texturas pixel art** de `recursos/`
  (filtro nearest, repetidas por metro).
- Luz de antorchas cálida contra luna fría, niebla suave, *bloom* si el motor lo tiene,
  y si es viable un desenfoque arriba y abajo (efecto maqueta / *tilt-shift*).
- Sombra de personajes: `recursos/sombra.png` en el suelo bajo los pies.

### Pixel art 3D (solo Godot)
Personajes y escenario hechos con modelos 3D sencillos (cajas, cilindros, esferas,
conos) con colores planos. Todo se dibuja a baja resolución (unos 400 × 225) y se
escala sin suavizado: parece pixel art pero la cámara gira libre.

### Cel-shading (solo Godot)
Los mismos modelos 3D con sombreado por bandas (2-3 tonos), brillo de borde y
contorno negro, a resolución completa: aspecto de dibujo animado.

## 9. Sprites y texturas compartidos (`recursos/`)

Generados por `recursos/generar_recursos.py` (Python + pygame). Si se cambian, se
vuelven a generar y todas las versiones los usan.

**Hojas de personaje** en una rejilla de **5 columnas × 3 filas**:
`akira.png` con cuadros de **48 × 48 px** (hoja de 240 × 144) y `soldado.png` con cuadros
de **64 × 48 px** (hoja de 320 × 144; más ancho para que quepa la lanza). Los pies están
en la fila de abajo (y = 47), centrados en x = 24 (Akira) y x = 32 (soldado).

| Fila | Vista |
| --- | --- |
| 0 | Frente (mira hacia la cámara) |
| 1 | Espalda |
| 2 | Lado, mirando a la derecha (para la izquierda se voltea) |

| Columna | Akira | Soldado |
| --- | --- | --- |
| 0 | Quieto | Quieto |
| 1 | Paso A | Paso A |
| 2 | Paso B | Paso B |
| 3 | Ataque: espada alzada | Preparando: lanza atrás |
| 4 | Ataque: tajo | Estocada: lanza extendida |

- Escala en el mundo: **0,04 m por píxel** (48 px = 1,92 m de alto; Akira mide ~1,8 m).
- Efecto del tajo: `tajo.png` (48 × 48, mirando a la derecha) delante de Akira durante
  el corte.
- Vista según el ángulo: sea f la dirección a la que mira el personaje y v la dirección
  del personaje a la cámara (ambas en el plano XZ). Si f·v > 0,707 → frente; si
  f·v < −0,707 → espalda; si no, lado (voltear si f apunta a la izquierda de la pantalla,
  es decir, f · derecha_cámara < 0).
- Caminar alterna paso A / paso B cada 0,15 s (0,1 s corriendo). Atacar: primera mitad
  columna 3, segunda mitad columna 4.

**Texturas** (repetibles): `losa.png`, `muro_piedra.png`, `yeso.png`, `madera.png`,
`tejas.png` (32 × 32); `porton.png` (64 × 64); `fuego.png` (4 cuadros de 16 × 24 en
fila, 64 × 24); `sombra.png` (32 × 16); `luna.png` (64 × 64); `tajo.png` (48 × 48).

## 10. Paleta

| Uso | Color |
| --- | --- |
| Kimono de Akira | #344276 |
| Hakama | #22243a |
| Obi | #a02e2a |
| Hachimaki (cinta) | #eeeef2 |
| Piel | #e4be98 |
| Pelo | #141218 |
| Armadura de soldado | #7e2a24 |
| Sombrero (jingasa) | #5c4a32 |
| Luz de antorcha | #ffae5c |
| Luz de luna | #9fb4ff |
| Cielo (arriba → horizonte) | #06081a → #2a244c |

## 11. Textos

Los mismos que `samurai.py` (`TEXTO_INTRO`, `TEXTO_CIERRE`, `TEXTO_DERROTA`).
Título: «RONIN» · subtítulo «Capítulo 1 · El castillo de Hoshiyama».

## 12. Reglas de trabajo

- Todo en español, **nombres de variables en español**.
- No cambiar la historia sin consultar.
- Cada versión incluye una **prueba automática** que la ejecuta sin ventana, simula
  teclas y guarda capturas en `capturas/`.
