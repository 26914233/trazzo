"""Prepara un concepto 2D para pasarlo a 3D: quita el fondo (relleno desde los bordes con
tolerancia de color), recorta, centra y guarda tres archivos:
  <salida>.png         con transparencia
  <salida>_plano.png   sobre gris claro (200, 200, 200): es lo que se manda a SAM 3D, que con
                       transparencia falló
  <salida>_vista.jpg   sobre verde, para revisar a simple vista que no se comió nada

Uso: python3 recortar_concepto.py <concepto.png> <salida.png> [tolerancia=38]
Funciona con fondos lisos (pergamino, color plano). Las manchas de tinta que tocan al personaje
no se quitan: para 3D conviene pedir conceptos limpios (de frente, brazos algo separados, fondo
liso y sin salpicaduras).
"""
import sys
from collections import deque

import numpy as np
from PIL import Image, ImageFilter


def recortar(entrada, salida, tolerancia=38, lado_max=1024):
    im = Image.open(entrada).convert("RGB")
    im.thumbnail((lado_max, lado_max))
    a = np.asarray(im).astype(np.int32)
    h, w, _ = a.shape
    fondo = np.median(np.concatenate([a[0], a[-1], a[:, 0], a[:, -1]]), axis=0)
    es_fondo = np.abs(a - fondo).sum(axis=2) < tolerancia * 3
    visto = np.zeros((h, w), bool)
    cola = deque()
    for y in range(h):
        for x in (0, w - 1):
            if es_fondo[y, x] and not visto[y, x]:
                visto[y, x] = True
                cola.append((y, x))
    for x in range(w):
        for y in (0, h - 1):
            if es_fondo[y, x] and not visto[y, x]:
                visto[y, x] = True
                cola.append((y, x))
    while cola:
        y, x = cola.popleft()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < h and 0 <= nx < w and not visto[ny, nx] and es_fondo[ny, nx]:
                visto[ny, nx] = True
                cola.append((ny, nx))
    alfa = Image.fromarray(np.where(visto, 0, 255).astype(np.uint8))
    alfa = alfa.filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(0.8))
    rgba = im.copy()
    rgba.putalpha(alfa)
    rgba = rgba.crop(rgba.getbbox())
    lado = int(max(rgba.size) * 1.1)
    lienzo = Image.new("RGBA", (lado, lado), (0, 0, 0, 0))
    lienzo.paste(rgba, ((lado - rgba.size[0]) // 2, (lado - rgba.size[1]) // 2))
    lienzo.save(salida)
    for sufijo, color in (("_plano.png", (200, 200, 200)), ("_vista.jpg", (40, 160, 60))):
        fondo_liso = Image.new("RGB", lienzo.size, color)
        fondo_liso.paste(lienzo, mask=lienzo.split()[3])
        fondo_liso.save(salida.replace(".png", sufijo), quality=85)
    print(salida, lienzo.size)


if __name__ == "__main__":
    recortar(sys.argv[1], sys.argv[2], int(sys.argv[3]) if len(sys.argv) > 3 else 38)
