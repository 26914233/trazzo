"""Hoja de muestra de dibujos: python3 -m dibujos.prueba <salida.png> [modulo ...]"""
import importlib
import sys

import numpy as np
from PIL import Image

from dibujos import PATRONES, con_patron, sencilla
from laminas import MINI, Lienzo, procesar

salida = sys.argv[1]
modulos = sys.argv[2:] or ["animales", "frutas", "objetos", "formas"]
minis = []
for nombre in modulos:
    m = importlib.import_module("dibujos." + nombre)
    for i, (sid, _n, sitio, f) in enumerate(m.SUJETOS):
        rng = np.random.default_rng(i)
        for variante in ("sencilla", "patron"):
            lz = Lienzo()
            if variante == "sencilla":
                sencilla(rng, lz, f, sitio)
            else:
                con_patron(rng, lz, f, PATRONES[i % len(PATRONES)])
            _l, _r, mini, k = procesar(lz)
            minis.append(mini)
            print(sid, variante, k, file=sys.stderr)
cols = 6
filas = (len(minis) + cols - 1) // cols
hoja = Image.new("L", (cols * (MINI + 8), filas * (MINI + 8)), 120)
for i, m in enumerate(minis):
    hoja.paste(m, ((i % cols) * (MINI + 8), (i // cols) * (MINI + 8)))
hoja.save(salida)
