"""Muestra de fachadas: python3 -m dibujos.prueba_arq <salida.png> [n]"""
import sys

import numpy as np
from PIL import Image

from dibujos.arquitectura import fachada
from laminas import LADO, Lienzo, procesar

salida = sys.argv[1]
n = int(sys.argv[2]) if len(sys.argv) > 2 else 3
imgs = []
for i in range(n):
    lz = Lienzo()
    fachada(np.random.default_rng(i), lz, i)
    lin, _r, _m, k = procesar(lz)
    fondo = Image.new("L", (LADO, LADO), 255)
    fondo.paste(Image.new("L", (LADO, LADO), 0), mask=lin.split()[1])
    imgs.append(fondo.resize((860, 860), Image.LANCZOS))
    print(i, k, file=sys.stderr)
hoja = Image.new("L", (n * 870, 860), 120)
for i, im in enumerate(imgs):
    hoja.paste(im, (i * 870, 0))
hoja.save(salida)
