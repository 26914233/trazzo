"""Muestra de animales étnicos: python3 -m dibujos.prueba_etnico <salida.png> [semillas]"""
import sys
import time

import numpy as np
from PIL import Image

from dibujos.etnico import ANIMALES, lamina
from laminas import LADO, Lienzo, procesar

salida = sys.argv[1]
n = int(sys.argv[2]) if len(sys.argv) > 2 else 1
imgs = []
for i in range(len(ANIMALES)):
    for sem in range(n):
        t = time.time()
        lz = Lienzo()
        lamina(np.random.default_rng(sem), lz, i)
        lin, _r, _m, k = procesar(lz)
        fondo = Image.new("L", (LADO, LADO), 255)
        fondo.paste(Image.new("L", (LADO, LADO), 0), mask=lin.split()[1])
        imgs.append(fondo)
        print(ANIMALES[i][0], sem, k, "zonas", "%.1fs" % (time.time() - t), file=sys.stderr)
W = 1000 if len(imgs) == 1 else 640
cols = min(len(imgs), 4)
hoja = Image.new("L", (cols * (W + 10), ((len(imgs) + cols - 1) // cols) * (W + 10)), 120)
for i, im in enumerate(imgs):
    hoja.paste(im.resize((W, W), Image.LANCZOS), ((i % cols) * (W + 10), (i // cols) * (W + 10)))
hoja.save(salida)
