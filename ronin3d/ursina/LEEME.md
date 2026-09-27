# RONIN 3D · versión Ursina (estética HD-2D)

Capítulo 1 de RONIN en 3D hecho con **Ursina** (motor 3D de Python sobre Panda3D): el
patio del castillo de Hoshiyama de noche, con Akira y los seis soldados como sprites pixel
art de pie, iluminados por la luna y las antorchas. Sigue la especificación común
`../DISENO_3D.md`, usa los sprites y texturas de `../recursos/` sin modificarlos y los
textos de `samurai.py` sin cambios.

Todo el juego está en un solo archivo: **`ronin3d_ursina.py`**.

## Instalar y ejecutar

Hace falta **Python 3.10 o posterior** (lo exige Ursina 7) y una tarjeta gráfica con
**OpenGL 3.0** o superior (cualquier PC de los últimos diez años).

```
pip install ursina
python ronin3d_ursina.py
```

En Windows, si no encuentra `pip` o `python`: `py -m pip install ursina` y
`py ronin3d_ursina.py`. Se puede lanzar desde cualquier carpeta: los recursos se buscan en
`../recursos/` respecto al propio script, así que hay que mantener la estructura de
carpetas de `ronin3d/`.

| Orden | Qué hace |
| --- | --- |
| `python ronin3d_ursina.py` | Juego normal, ventana de 1280 × 720 (F11: pantalla completa). |
| `python ronin3d_ursina.py --ligero` | Sin sombras reales de la luna ni posproceso (desenfoque de maqueta, resplandor, viñeta). Para un PC muy justo. |
| `python ronin3d_ursina.py --prueba` | Prueba automática: juega sola, comprueba y guarda capturas (ver más abajo). |

Consumo: unos 285 MB de memoria como máximo medidos en Linux con el render por software
(que también ocupa memoria del proceso); con una tarjeta gráfica real debería ser menos.

## Controles

| Tecla | Acción |
| --- | --- |
| W A S D / flechas | Moverse (relativo a la cámara) |
| SHIFT | Correr |
| ESPACIO | Saltar |
| J / clic izquierdo | Atacar con la espada |
| Q / E | Girar la cámara (Q: la vista gira a la izquierda; E: a la derecha) |
| Botón derecho + arrastrar | Girar (horizontal) e inclinar (vertical) la cámara |
| Rueda del ratón, + / − | Zoom (7 a 18 m) |
| R / F | Inclinar la cámara: R la sube, F la baja (de 60° a −5°; abajo se ven el torreón y la luna) |
| ENTER | Continuar en los textos (la primera pulsación muestra el texto entero) |
| ESC | Pausa (en pausa, Q sale del juego) |

## Qué está hecho

- **Flujo completo**: introducción con título, subtítulo y los textos de `samurai.py`
  letra a letra → patio → tocar el portón → «Fin del capítulo 1» con el texto de cierre.
  Con la vida a 0, Akira cae y aparece «Akira ha caído» con `TEXTO_DERROTA`; ENTER
  reintenta. Fundidos a negro de 0,45 s entre escenas, como en el prototipo 2D.
- **Presentación**: durante la intro, plano fijo desde (6, 3, 12) mirando a (0, 9, −20)
  con un leve vaivén (patio norte, torreón y luna); al pulsar ENTER la cámara pasa en 1 s a
  la órbita sobre Akira.
- **Patio con las medidas exactas** de la especificación: muros con base de piedra de
  1,2 m, yeso encima, bandas de madera y tejadillo de tejas; portón macizo con postes,
  dintel y tejado; pasarela con escalón; muro bajo; bloques A y B; cuatro linternas de
  piedra con luz tenue dentro; pozo con tejadillo sobre dos postes; tres cajas (una encima)
  y dos barriles; terreno exterior; **torreón** de tres pisos con ventanas iluminadas y
  remate dorado; ocho **antorchas** con luz cálida #ffae5c de 9 m de alcance que parpadea y
  llama animada con `fuego.png`; cielo en degradado con estrellas, **luna** grande con
  `luna.png` en la dirección normalizar(−0,3, 0,32, −0,9) y halo; montes lejanos; niebla
  nocturna suave.
- **Estética HD-2D**: texturas pixel art con filtro *nearest* y repetidas **por metro**
  (las UV de cada cara se calculan en metros, que equivale a `texture_scale` = tamaño en
  metros: nada se estira); luz por píxel de la luna (azulada, baja, **con sombras
  reales**), las 8 antorchas y las 4 linternas; niebla; resplandor (halos y posproceso);
  **desenfoque de maqueta** arriba y abajo; viñeta.
- **Sprites**: Akira (48 × 48 px) y soldados (64 × 48 px) a 0,04 m/px, como *billboard*
  **vertical** (solo giran en Y: `rotation_y` se calcula cada cuadro desde la cámara; no se
  inclinan), iluminados por las luces con transparencia recortada; vista
  frente/espalda/lado con la regla de la especificación (volteo en el lado izquierdo);
  pasos cada 0,15 s (0,1 s corriendo) y ataque en dos mitades, recortando la hoja con
  `texture_offset` / `texture_scale`; `sombra.png` bajo los pies; `tajo.png` delante de
  Akira durante el corte; «!» rojo pixel art sobre el soldado que va a atacar.
- **Akira**: empieza en (−20, 0, 0) mirando al este; 5 m/s (8 con SHIFT) relativo a la
  cámara; salto de 7,5 m/s con gravedad 22 m/s² (sube 1,28 m: llega a la pasarela y a los
  bloques); colisiones programadas a mano (cajas alineadas y cilindros, con subpasos de
  1/60 s) contra muros, portón y obstáculos; 5 de vida, 1 s invulnerable parpadeando y
  retroceso de 6 m/s durante 0,25 s sin control; ataque de 0,3 s que corta de 0,05 a 0,2 s,
  alcance 1,6 m en un cono de 100°, enfriamiento 0,4 s, cada soldado una vez por ataque.
- **Soldados (6)**, con los recorridos A–B de la tabla: 2 de vida; patrullan a 2 m/s; ven
  a 9 m en un cono de 120° o a 3 m en cualquier dirección; persiguen a 3,5 m/s sin
  alejarse más de 8 m de su recorrido; a 1,8 m: aviso «!» 0,5 s → estocada 0,2 s (alcance
  2,1 m, ancho 0,8 m) → recuperación 0,6 s; golpeados: aturdidos 0,4 s con retroceso de
  5 m/s; derrotados: caen y desaparecen (tramado) en 1,2 s; si pierden de vista a Akira
  2 s, vuelven a patrullar.
- **Cámara** exactamente con la fórmula de la especificación: distancia 12 m, inclinación
  38°, giro −60° y **campo de visión vertical de 38°** por defecto; Q/E a 90°/s; botón
  derecho + arrastrar; rueda y + / − entre 7 y 18 m; R/F entre −5° y 60°; punto mirado a
  1,0 m sobre los pies con inclinación ≥ 30°, subiendo hasta 2,2 m a −5°; sigue a Akira
  con suavizado.
- **HUD** (con `Text` de Ursina): «AKIRA» y 5 rombos rojos arriba a la izquierda,
  «Soldados derrotados: n/6» arriba a la derecha, ayuda de controles los primeros 10 s,
  pausa con ESC y «Ursina · HD-2D» en la esquina inferior derecha.

### Cómo está hecho (detalles técnicos)

- **Ejes**: la especificación usa Z hacia el sur; Ursina es de mano izquierda con Z hacia
  delante. En el juego el mundo es X este, Y arriba, Z norte, y `convertir()` invierte Z.
  Todas las medidas están escritas tal cual en la especificación.
- **Sombreador propio** (GLSL 1.30): el `lit_with_shadows_shader` de Ursina solo admite una
  luz y no tiene niebla ni recorte de transparencia, así que el juego usa uno propio que lee
  las luces de Ursina (`PointLight`, `DirectionalLight`, `AmbientLight`) a través de
  `p3d_LightSource` de Panda3D. La luna se liga aparte como estructura para leer su mapa de
  sombras (2048 × 2048, ajustado al patio y al torreón). Los sprites usan luz envolvente y
  un poco más de luz ambiente para leerse bien en las zonas de sombra.
- **Geometría**: el escenario se construye con mallas propias (una por textura) para que
  haya pocas llamadas de dibujo.
- **Corte de la muralla** (no está en la especificación): con la cámara por defecto, Akira
  empieza a 4 m del muro oeste y la cámara queda al otro lado, con el tejadillo tapando
  media pantalla. Cuando la cámara está fuera de la muralla y un tramo tapa a Akira, ese
  tramo se «corta» a la altura de su base de piedra (1,2 m) con una transición rápida, y
  además se abre un hueco tramado alrededor de Akira. Dentro del patio no cambia nada.
- **Posproceso** en una sola pasada (barato): desenfoque vertical de maqueta, resplandor
  de las zonas brillantes y viñeta.
- **Títulos** con Georgia (fuente de Windows) si existe; si no, otra con serifa del sistema
  o la OpenSans de Ursina. El resto del texto usa OpenSans.

## Prueba automática

```
python ronin3d_ursina.py --prueba
```

En Linux sin pantalla: `xvfb-run -a -s "-screen 0 1280x720x24" python3 ronin3d_ursina.py --prueba`.

La prueba arranca el juego y lo juega sola: **pulsa y suelta las teclas por el mismo camino
que el teclado real** (la entrada de Ursina, `app.input`), avanzando con un paso fijo de
1/30 s para que el resultado no dependa de la velocidad de dibujo. Comprueba (34 puntos):
intro y textos idénticos a `samurai.py`; ENTER; pausa con ESC; giro con Q a 90°/s;
caminar 5 m/s y correr 8 m/s relativos a la cámara; salto de ~1,28 m y vuelta al suelo;
que Akira no atraviesa el muro oeste ni saltando; rueda, + / −, R y F con sus límites y la
altura del punto mirado; subir a la pasarela y a los bloques A y B; que con la cámara baja
se ven el torreón y la luna; combate (la espada hiere y derrota soldados; los soldados
avisan con «!» y lanzan estocadas); que el portón es macizo y tocarlo muestra el texto de
cierre; vuelta a la intro; derrota con «Akira ha caído» y reintento con la vida y los
soldados repuestos. El arrastre con el botón derecho se prueba llamando a su función (en
un servidor sin pantalla no hay ratón real).

Guarda en `../capturas/` (1280 × 720): `ursina_intro.png`, `ursina_patio.png`,
`ursina_camara_girada.png`, `ursina_combate.png`, `ursina_torreon.png` y
`ursina_cierre.png`. Mide los FPS en el patio, imprime un resumen y sale con código 0 si
todo va bien (1 si algo falla).

**Resultado en el contenedor de desarrollo** (sin tarjeta gráfica: Mesa llvmpipe, OpenGL
por software, 4 núcleos compartidos): 34/34 comprobaciones correctas. FPS a 1280 × 720 con
todos los efectos: entre 10 y 31 según la vista y la carga de la máquina; con `--ligero`,
unos 42. Con una tarjeta gráfica real deberían ser muchos más (va sincronizado a 60 Hz).
Versiones: Ursina 7.0.0, Panda3D 1.10.16, Python 3.11.

## Limitaciones, desviaciones y lo que falta

- **Sin sonido** (la especificación no lo pide).
- **Tras el cierre**, ENTER vuelve a la introducción (el pie dice «Pulsa ENTER para volver
  a empezar»): la planicie de `samurai.py` no existe en esta versión 3D.
- La **estocada** va a 0,8–1,0 m sobre los pies del soldado: saltando en el momento justo
  se esquiva (lo pide la especificación). Por eso un soldado no ataca a Akira si este está
  subido más alto (muro bajo, bloque B); la espada tampoco llega a los soldados desde el
  bloque B.
- Los soldados **no saltan ni bajan de su plataforma**: el de la pasarela no la abandona.
- Con la órbita de la especificación, al bajar la cámara a −5° el tejado más alto del
  torreón puede quedar justo en el borde superior de la imagen.
- La luna, baja (19°), proyecta **sombras largas**: la del torreón cruza una franja del
  patio. Es correcto, pero oscurece esa zona.
- La cámara no choca con nada (el corte de la muralla resuelve lo habitual). Muy al norte y
  alejada puede quedar dentro de la base del torreón y ver a través.
- El desenfoque de maqueta es por altura en pantalla, no por profundidad.
- **No se ha probado con una tarjeta gráfica real ni en Windows**, solo con OpenGL por
  software en Linux. Los sombreadores usan GLSL 1.30 para ir en tarjetas antiguas.
- Se usa el modo de desarrollo de Ursina (para tener ventana en lugar de pantalla completa
  forzada) con su interfaz de desarrollo oculta; Ursina escribe algunos mensajes en la
  consola al arrancar.
- Falta, si se quisiera ampliar: mando, menú de opciones, sonido y música.
