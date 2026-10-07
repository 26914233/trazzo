#!/usr/bin/env python3
"""Las capas del nivel 4 («El oro»), sacadas del boceto (fuentes/sala.jpg), sin imágenes nuevas.

La mejilla derecha de la cara tiene un hueco (un pedazo saltado) y, debajo, una grieta. En el nivel 4 se junta el
pedazo con tres esquirlas y se cura con laca y oro (kintsugi). Esto prepara:

- `mejilla.webp`: la mejilla sin el hueco. Se rellena resolviendo la ecuación de Laplace dentro del hueco (los colores
  del borde se extienden suaves hacia dentro) y se le añade la veta de la madera de su izquierda (solo el detalle fino),
  para que no quede lisa. El juego la pinta encima del boceto cuando el pedazo está puesto y dibuja el oro por encima.
- `nivel4.json`: las formas, en píxeles del boceto:
  - `contorno`: el hueco; `esquirlas`: las tres piezas que lo llenan; `juntas`: las dos juntas entre ellas;
    `grieta`: la grieta de debajo, que también se dora;
  - `olas`: las tres olas de oro de la peana que suenan (cada una, una nota);
  - `cajon_zocalo`: el cajón de la peana (entre las olas de los lados);
  - `lampara`: dónde se apoya la esquirla en la lámpara y dónde cae su sombra en la pared.

Uso:  python3 puzles/ilustrada/herramientas/nivel4_capas.py
"""
import json
import os

import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.normpath(os.path.join(AQUI, '..'))
FUENTES = os.path.join(RAIZ, 'fuentes')
CAPAS = os.path.join(RAIZ, 'pagina', 'capas')
ANCHO, ALTO = 1376, 768

# El hueco de la mejilla, medido sobre el boceto (por fuera de su línea de tinta), en el sentido de las agujas del reloj
# desde la punta de la izquierda
CONTORNO = [(918, 436.5), (921.5, 429.8), (928, 428.2), (934, 428.8), (940, 429.4), (946, 426.8), (952, 424), (957, 422.4),
            (961, 423.4), (964.8, 427), (966.2, 433), (965, 440), (963.6, 447), (960.6, 452.6), (955, 455.8), (949, 456),
            (944, 455), (939, 452.6), (933, 450.6), (928, 449.2), (922.5, 445.6)]
# las dos juntas entre las esquirlas: la primera baja por el medio; la segunda sale de ella hacia la derecha
JUNTA1 = [CONTORNO[5], (945, 434), (947, 441), (945.5, 447), CONTORNO[16]]
JUNTA2 = [(947, 441), (952, 439.5), (958, 441), CONTORNO[11]]
# las tres esquirlas: la de la izquierda (A), la de arriba a la derecha (B) y la de abajo a la derecha (C)
ESQUIRLAS = [
    CONTORNO[0:6] + [(945, 434), (947, 441), (945.5, 447)] + CONTORNO[16:21],
    CONTORNO[5:12] + [(958, 441), (952, 439.5), (947, 441), (945, 434)],
    [(947, 441), (952, 439.5), (958, 441)] + CONTORNO[11:17] + [(945.5, 447)],
]
# la grieta que baja del hueco hasta el mosaico
GRIETA = [(946, 455), (945.4, 463), (944.4, 471), (943.6, 478)]
# las tres olas de oro de la peana que suenan: de izquierda a derecha, grave, media y aguda
OLAS = [{'x': 737, 'y': 597, 'r': 13}, {'x': 829, 'y': 613, 'r': 14}, {'x': 917, 'y': 630, 'r': 13}]
# el cajón de la peana: su frente en el boceto (arriba a la izquierda y abajo a la derecha)
CAJON_ZOCALO = [772, 590, 886, 628]
# la lámpara: dónde está la esquirla (encima del marco) y dónde cae su sombra (la pared de arriba)
LAMPARA = {'esquirla': (604, 217), 'sombra': (600, 150)}


def poligono(puntos, sobre=4, ancho=ANCHO, alto=ALTO, dx=0, dy=0):
    m = Image.new('L', (ancho * sobre, alto * sobre), 0)
    ImageDraw.Draw(m).polygon([((x - dx) * sobre, (y - dy) * sobre) for x, y in puntos], fill=255)
    return np.asarray(m.resize((ancho, alto), Image.LANCZOS)).astype(np.float32) / 255.0


def rellenar_laplace(rgb, dentro, vueltas=4000):
    """Rellena los píxeles de «dentro» con la solución de Laplace (Jacobi), con el resto como borde fijo."""
    r = rgb.copy()
    # empieza con el color medio del borde para converger antes
    borde = ndimage.binary_dilation(dentro, iterations=1) & ~dentro
    r[dentro] = rgb[borde].mean(axis=0)
    for _ in range(vueltas):
        vecinos = (np.roll(r, 1, 0) + np.roll(r, -1, 0) + np.roll(r, 1, 1) + np.roll(r, -1, 1)) / 4
        r[dentro] = vecinos[dentro]
    return r


def main():
    os.makedirs(CAPAS, exist_ok=True)
    sala = np.asarray(Image.open(os.path.join(FUENTES, 'sala.jpg')).convert('RGB'), np.float32)
    # la zona que cambia: el hueco con margen
    xs, ys = [p[0] for p in CONTORNO], [p[1] for p in CONTORNO]
    x0, y0, x1, y1 = int(min(xs)) - 7, int(min(ys)) - 7, int(max(xs)) + 8, int(max(ys)) + 8
    w, h = x1 - x0, y1 - y0
    zona = sala[y0:y1, x0:x1].copy()
    mascara = poligono(CONTORNO, ancho=w, alto=h, dx=x0, dy=y0)
    # la línea de tinta del hueco queda por fuera del contorno: se cubre ensanchándolo un poco
    dentro = ndimage.binary_dilation(mascara > 0.35, iterations=2)
    relleno = rellenar_laplace(zona, dentro)
    # la veta: el detalle fino de la madera de la izquierda (a la misma altura, la veta es vertical)
    fuente = sala[y0:y1, x0 - 48:x1 - 48]
    detalle = fuente - ndimage.gaussian_filter(fuente, sigma=(1.6, 1.6, 0))
    # y una veta sintética muy suave, vertical, para que no se repita la de al lado
    rng = np.random.default_rng(4)
    veta = ndimage.gaussian_filter1d(rng.normal(0, 1, w), 0.7)
    # unas pocas líneas de veta más oscuras, como las de la cara
    for x in rng.choice(np.arange(4, w - 4), 4, replace=False):
        veta[x] -= rng.uniform(1.5, 3)
    veta = ndimage.gaussian_filter(np.tile(veta[:, None], (1, h)).T, (2.5, 0.4))
    veta = np.repeat(veta[..., None], 3, axis=2) * 4.5 * np.array([1, 0.85, 0.7])
    relleno = relleno + (detalle * 0.95 + veta) * dentro[..., None]
    # el borde, fundido
    alfa = ndimage.gaussian_filter(dentro.astype(np.float32), 0.9)
    alfa = np.maximum(alfa, mascara)
    rgba = np.dstack([np.clip(relleno, 0, 255), np.clip(alfa, 0, 1) * 255]).astype(np.uint8)
    Image.fromarray(rgba, 'RGBA').save(os.path.join(CAPAS, 'mejilla.webp'), 'WEBP', quality=92, method=6)
    print(f'  mejilla.webp  {w}×{h} en ({x0}, {y0})')
    # para revisarla: la cara con la mejilla curada (sin el oro), a 4 aumentos
    prueba = sala.copy()
    prueba[y0:y1, x0:x1] = zona * (1 - alfa[..., None]) + relleno * alfa[..., None]
    recorte = Image.fromarray(np.clip(prueba[y0 - 20:y1 + 20, x0 - 30:x1 + 20], 0, 255).astype(np.uint8))
    recorte = recorte.resize((recorte.width * 6, recorte.height * 6), Image.LANCZOS)
    recorte.save(os.path.join(os.environ.get('REVISION', '/tmp'), 'mejilla_revision.png'))

    datos = {
        'mejilla': {'x': x0, 'y': y0, 'w': w, 'h': h},
        'contorno': CONTORNO, 'esquirlas': ESQUIRLAS, 'juntas': [JUNTA1, JUNTA2], 'grieta': GRIETA,
        'olas': OLAS, 'cajon_zocalo': CAJON_ZOCALO, 'lampara': LAMPARA,
    }
    with open(os.path.join(CAPAS, 'nivel4.json'), 'w', encoding='utf-8') as f:
        json.dump(datos, f, ensure_ascii=False, indent=1)
    print('  nivel4.json')


if __name__ == '__main__':
    main()
