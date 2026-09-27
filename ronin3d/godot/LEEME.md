# RONIN 3D — versión Godot 4.7

Capítulo 1 (el patio del castillo de Hoshiyama, de noche) en 3D con **tres estéticas**
que se cambian en caliente con las teclas **1, 2 y 3**:

| Tecla | Estética | Cómo se ve |
| --- | --- | --- |
| 1 | **HD-2D** | Sprites pixel art (siempre de cara a la cámara) en un escenario 3D con texturas pixel art, luz de antorchas, niebla, brillo y efecto maqueta. |
| 2 | **Pixel art 3D** | Personajes y escenario 3D dibujados a un tercio de resolución, sin suavizar y con tramado de colores. |
| 3 | **Cel-shading** | Los mismos modelos 3D con sombreado por bandas, brillo de borde y contorno negro. |

Al cambiar de estética se conserva dónde está Akira y cómo mira la cámara, para comparar
el mismo plano.

## Cómo abrirlo

1. Abre **Godot 4.7** (el mismo que usas para Trazzo).
2. Gestor de proyectos → **Importar** → elige `ronin3d/godot/project.godot`.
3. Pulsa **Ejecutar** (F5). La primera vez Godot importa las texturas (unos segundos).

Usa el renderizador **Compatibility** (OpenGL 3.3): el más ligero, pensado para PC
modestos, Android y web.

## Controles

| Tecla | Acción |
| --- | --- |
| W A S D / flechas | Moverse (relativo a la cámara) |
| SHIFT | Correr |
| ESPACIO | Saltar |
| J / clic izquierdo | Atacar con la espada |
| Q / E, botón derecho + arrastrar | Girar la cámara |
| Rueda, + / − | Zoom |
| R / F | Inclinar la cámara (al bajarla se ven el torreón y la luna) |
| 1 / 2 / 3 | Cambiar de estética |
| ENTER | Continuar en los textos |
| ESC | Pausa (Q en pausa: salir) |

## Qué hay

- Intro con los textos de la historia sobre un plano del castillo (torreón, luna,
  estrellas), y transición suave a la cámara de juego.
- Patio con las medidas de `../DISENO_3D.md`: muros, portón, torreón, pasarela, muro
  bajo, bloques, linternas, pozo, cajas, barriles y 8 antorchas con luz que parpadea.
- Akira: correr, saltar (llega a la pasarela), ataque en cono con la espada, 5 de vida,
  retroceso e invulnerabilidad tras un golpe.
- 6 soldados con lanza: patrullan, te ven en un cono, persiguen sin alejarse de su puesto,
  avisan con «!» y lanzan una estocada que alcanza más que la espada.
- Cámara orbital que no atraviesa muros. HUD con vida, soldados derrotados y ayuda.
- Portón → texto de cierre. Vida 0 → «Akira ha caído» → reintentar.

## Estructura

```
godot/
├── project.godot          Proyecto (Compatibility, 1280 × 720)
├── principal.tscn         Escena raíz
├── recursos/              Sprites y texturas pixel art (copia de ../recursos)
├── shaders/               cielo, toon (cel), contorno, maqueta (HD-2D), pixelado
└── scripts/
    ├── principal.gd       Flujo intro → juego → cierre, teclas, pausa, cambio de estética
    ├── juego.gd           Monta el capítulo y resuelve los golpes de espada
    ├── estilos.gd         Lo que cambia entre estéticas (materiales, luz, efectos)
    ├── constructor_mundo.gd  El patio del castillo
    ├── akira.gd           Control de Akira
    ├── soldado.gd         IA de los soldados
    ├── camara_orbital.gd  Cámara que gira y esquiva muros
    ├── visual_sprite.gd   Personajes HD-2D (sprites)
    ├── visual_modelo.gd   Personajes 3D (pixel art 3D y cel-shading)
    ├── hud.gd             Interfaz
    ├── datos.gd           Medidas, reglas del combate, textos y colores
    └── prueba.gd          Prueba automática
```

## Prueba automática

Juega sola 18 segundos: pasa la intro, camina, mira que el HUD quepa en pantalla, gira la
cámara, pelea con un soldado, choca con un muro, encuadra el torreón, llega al portón y
cambia de estética. Comprueba 9 cosas, mide los FPS mientras Akira camina y guarda capturas
en `../capturas/godot_<estética>_*.png`.

```
godot --path ronin3d/godot --fixed-fps 30 -- --prueba --estilo=hd2d
godot --path ronin3d/godot --fixed-fps 30 -- --prueba --estilo=pixel
godot --path ronin3d/godot --fixed-fps 30 -- --prueba --estilo=cel
```

Resultado en la nube (Godot 4.7.2, OpenGL por software, sin tarjeta gráfica): **9 de 9** en
las tres estéticas. FPS al caminar por el patio a 1280 × 720: HD-2D 9,5 · Pixel art 3D 17,6 ·
Cel-shading 12,3 (con una tarjeta gráfica real van mucho más rápido). Comparativa con los otros
motores en `../COMPARATIVA.md`.

## Pendiente

Sonido, animaciones más ricas, la salida a la planicie en 3D y los módulos de cada lugar.
Para exportar a Android: Proyecto → Exportar, igual que con Trazzo.
