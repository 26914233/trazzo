"""Muestra de animales tatuaje: python3 -m dibujos.prueba_tatuaje <salida.png>"""
import sys

import numpy as np
from PIL import Image

from dibujos.tatuaje import ANIMALES, geometrico, ornamental
from laminas import LADO, Lienzo, procesar

salida = sys.argv[1]
imgs = []
for i, (aid, _n, f) in enumerate(ANIMALES):
    for estilo in (geometrico, ornamental):
        rng = np.random.default_rng(i * 7 + 1)
        lz = Lienzo()
        estilo(rng, lz, f())
        lin, _r, _m, k = procesar(lz)
        fondo = Image.new("L", (LADO, LADO), 255)
        fondo.paste(Image.new("L", (LADO, LADO), 0), mask=lin.split()[1])
        imgs.append(fondo.resize((640, 640), Image.LANCZOS))
        print(aid, estilo.__name__, k, file=sys.stderr)
hoja = Image.new("L", (4 * 650, 2 * 650), 120)
for i, im in enumerate(imgs):
    hoja.paste(im, ((i % 4) * 650, (i // 4) * 650))
hoja.save(salida)
