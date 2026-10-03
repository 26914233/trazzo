#!/usr/bin/env python3
"""Las capas del nivel 2 («La caja de dentro»), sacadas de sus ilustraciones de Gemini (fuentes/nivel2/ y
fuentes/sala_dos_ojos.jpg).

- La caja hija: tres caras pintadas de frente (asanoha, kikko y el frente con el párpado tallado), a 512 px.
- La cajita de laca roja vista desde arriba, recortada en su círculo (su tapa gira en el puzle de bolsillo).
- El ojo nuevo, el de piedra de luna, para animarlo como el viejo:
  - `ojo2.webp`: la cuenca con el ojo puesto y el iris borrado (se rellena fila a fila entre sus lados);
  - `iris2.webp`: el iris suelto;
  - su almendra (el hueco entre los párpados) y su iris van en `nivel2.json`.

Uso:  python3 puzles/ilustrada/herramientas/nivel2_capas.py
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

# El ojo nuevo, medido sobre sala_dos_ojos.jpg (píxeles del boceto): arriba de izquierda a derecha y abajo de vuelta
ALMENDRA2 = [(876, 390.5), (880, 382), (885, 377), (890, 373.8), (900, 370), (910, 368.8), (920, 369.4), (930, 371.9),
             (940, 376.9), (947.5, 382.5), (944, 387.5), (940, 391), (930, 394.4), (920, 396), (910, 396.9), (900, 396.5),
             (890, 395), (884, 393.5), (879, 392)]
IRIS2 = (911.9, 382.5, 14.4)
ZONA_OJO2 = (864, 352, 958, 404)          # lo que cambia en la cara: la cuenca entera con sus párpados


def poligono(puntos, sobre=4):
    m = Image.new('L', (ANCHO * sobre, ALTO * sobre), 0)
    ImageDraw.Draw(m).polygon([(x * sobre, y * sobre) for x, y in puntos], fill=255)
    return np.asarray(m.resize((ANCHO, ALTO), Image.LANCZOS)).astype(np.float32) / 255.0


def webp(nombre, rgb, alfa=None, calidad=88):
    rgb = np.clip(rgb, 0, 255).astype(np.uint8)
    imagen = Image.fromarray(rgb, 'RGB') if alfa is None else Image.fromarray(
        np.dstack([rgb, (np.clip(alfa, 0, 1) * 255).astype(np.uint8)]), 'RGBA')
    imagen.save(os.path.join(CAPAS, nombre + '.webp'), 'WEBP', quality=calidad, method=6)
    print(f'  {nombre}.webp  {imagen.size[0]}×{imagen.size[1]}')


def caras_hija():
    for nombre in ('asanoha', 'kikko', 'frente_ojo'):
        im = Image.open(os.path.join(FUENTES, 'nivel2', f'cara_{nombre}.jpg')).convert('RGB').resize((512, 512), Image.LANCZOS)
        webp('hija_' + nombre.replace('_ojo', ''), np.asarray(im, np.float32), calidad=86)


def cajita():
    im = np.asarray(Image.open(os.path.join(FUENTES, 'nivel2', 'cajita.jpg')).convert('RGB'), np.float32)
    # el círculo de laca: lo que no es el fondo oscuro
    roja = (im[..., 0] > 90) & (im[..., 0] > im[..., 2] * 1.4)
    roja = ndimage.binary_fill_holes(ndimage.binary_closing(roja, iterations=4))
    ys, xs = np.nonzero(roja)
    cx, cy = xs.mean(), ys.mean()
    r = np.sqrt(roja.sum() / np.pi)
    lado = int(np.ceil(r * 1.02))
    x0, y0 = int(round(cx - lado)), int(round(cy - lado))
    recorte = im[y0:y0 + 2 * lado, x0:x0 + 2 * lado]
    yy, xx = np.mgrid[0:2 * lado, 0:2 * lado]
    alfa = np.clip(r + 0.5 - np.hypot(xx - (cx - x0), yy - (cy - y0)), 0, 1)
    rgb = np.asarray(Image.fromarray(recorte.astype(np.uint8)).resize((512, 512), Image.LANCZOS), np.float32)
    a = np.asarray(Image.fromarray((alfa * 255).astype(np.uint8)).resize((512, 512), Image.LANCZOS), np.float32) / 255
    webp('cajita', rgb, a, calidad=90)
    return {'radio': round(float(r / lado * 256), 1)}


def ojo_nuevo():
    base = np.asarray(Image.open(os.path.join(FUENTES, 'sala.jpg')).convert('RGB'), np.float32)
    dos = np.asarray(Image.open(os.path.join(FUENTES, 'sala_dos_ojos.jpg')).convert('RGB'), np.float32)
    # Gemini oscurece un poco: se iguala por canal con lo que no cambia alrededor del ojo
    x0, y0, x1, y1 = ZONA_OJO2
    alrededor = np.zeros((ALTO, ANCHO), bool); alrededor[y0 - 40:y1 + 40, x0 - 60:x1 + 60] = True
    alrededor[y0:y1, x0:x1] = False
    for k in range(3):
        a, b = np.polyfit(dos[..., k][alrededor], base[..., k][alrededor], 1)
        dos[..., k] = dos[..., k] * a + b
    almendra = poligono(ALMENDRA2)
    cx, cy, r = IRIS2
    # el ojo sin iris: cada fila del disco del iris se rellena con el blanco que hay a sus lados (solo píxeles
    # claros, para no arrastrar la tinta de los párpados) y después se suaviza en vertical
    ojo = dos.copy()
    yy, xx = np.mgrid[0:ALTO, 0:ANCHO]
    hueco = (np.hypot(xx - cx, yy - cy) <= r + 2.6) & (almendra > 0.45)
    luz = dos.mean(2)
    filas = {}
    for y in range(int(cy - r - 4), int(cy + r + 5)):
        xs = np.nonzero(hueco[y])[0]
        if not len(xs):
            continue
        izq = [x for x in range(xs.min() - 7, xs.min()) if almendra[y, x] > 0.6 and luz[y, x] > 150]
        der = [x for x in range(xs.max() + 1, xs.max() + 8) if almendra[y, x] > 0.6 and luz[y, x] > 150]
        if izq and der:
            filas[y] = (dos[y, izq].mean(0), dos[y, der].mean(0), xs.min(), xs.max())
    validas = sorted(filas)
    for y in range(int(cy - r - 4), int(cy + r + 5)):
        xs = np.nonzero(hueco[y])[0]
        if not len(xs) or not validas:
            continue
        a, b, x0f, x1f = filas[min(validas, key=lambda v: abs(v - y))]
        for x in xs:
            t = np.clip((x - x0f) / max(1, x1f - x0f), 0, 1)
            ojo[y, x] = a * (1 - t) + b * t
    suavizado = ndimage.gaussian_filter(ojo, (1.6, 1.0, 0))
    ojo[hueco] = suavizado[hueco]
    ruido = ndimage.gaussian_filter(np.random.default_rng(11).normal(0, 1, (ALTO, ANCHO)), 0.7)
    ojo += (ruido / ruido.std() * 3.0)[..., None] * (almendra[..., None] > 0.5)
    # lo que se pega sobre la cuenca vacía: la cuenca entera, con un borde suave
    zona = np.zeros((ALTO, ANCHO), np.float32)
    yy, xx = np.mgrid[0:ALTO, 0:ANCHO]
    zona[((xx - (x0 + x1) / 2) / ((x1 - x0) / 2)) ** 2 + ((yy - (y0 + y1) / 2) / ((y1 - y0) / 2)) ** 2 <= 1] = 1
    zona = np.clip(ndimage.gaussian_filter(zona, 2.0) * 1.15, 0, 1)
    caja = (x0 - 4, y0 - 4, x1 + 4, y1 + 4)
    webp('ojo2', ojo[caja[1]:caja[3], caja[0]:caja[2]], zona[caja[1]:caja[3], caja[0]:caja[2]], calidad=94)
    # el iris suelto, con su borde
    lado = int(np.ceil(r)) + 2
    sub = dos[int(cy) - lado - 1:int(cy) + lado + 3, int(cx) - lado - 1:int(cx) + lado + 3]
    desplazado = ndimage.shift(sub, (-(cy - int(cy)), -(cx - int(cx)), 0), order=1)
    iris = desplazado[1:2 * lado + 2, 1:2 * lado + 2]
    yy, xx = np.mgrid[-lado:lado + 1, -lado:lado + 1]
    alfa = np.clip(r + 0.5 - np.hypot(xx, yy), 0, 1)
    webp('iris2', iris, alfa, calidad=96)
    return {'almendra2': ALMENDRA2, 'iris2': {'x': cx - lado, 'y': cy - lado, 'w': 2 * lado + 1, 'h': 2 * lado + 1, 'cx': cx, 'cy': cy, 'r': r},
            'ojo2': {'x': caja[0], 'y': caja[1], 'w': caja[2] - caja[0], 'h': caja[3] - caja[1]}}


def principal():
    caras_hija()
    datos = {'cajita': cajita()}
    datos.update(ojo_nuevo())
    with open(os.path.join(CAPAS, 'nivel2.json'), 'w', encoding='utf-8') as f:
        json.dump(datos, f, ensure_ascii=False, indent=1)
    print('nivel2.json escrito')


if __name__ == '__main__':
    principal()
