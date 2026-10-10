#!/usr/bin/env python3
"""Datos de cada zona para el botón "buscar zona sin pintar".

Por cada lámina escribe <id>_zonas.bin junto a sus PNG: por zona (1..k), cuatro
uint16 little-endian: x, y del punto más interior de la zona (el más lejano a su
borde, así cae dentro aunque la zona sea cóncava) y ancho, alto de su caja.
El juego lo usa para llevar la cámara a la zona y elegir el zoom.

Uso: python3 herramientas/zonas.py            (todas las láminas del índice)
     python3 herramientas/zonas.py mandalas   (solo esa categoría)
"""
import json
import os
import sys
from multiprocessing import Pool

import numpy as np
from PIL import Image
from scipy import ndimage

from laminas import RAIZ

DESTINO = os.path.join(RAIZ, "datos", "laminas")


def datos_zonas(etiquetas, k):
    """Array (k, 4) uint16: x, y interiores y ancho, alto de la caja de cada zona."""
    borde = np.zeros(etiquetas.shape, dtype=bool)
    borde[:-1, :] |= etiquetas[:-1, :] != etiquetas[1:, :]
    borde[1:, :] |= etiquetas[1:, :] != etiquetas[:-1, :]
    borde[:, :-1] |= etiquetas[:, :-1] != etiquetas[:, 1:]
    borde[:, 1:] |= etiquetas[:, 1:] != etiquetas[:, :-1]
    borde[0, :] = borde[-1, :] = borde[:, 0] = borde[:, -1] = True   # el marco también es borde
    distancia = ndimage.distance_transform_edt(~borde)
    ids = np.arange(1, k + 1)
    puntos = ndimage.maximum_position(distancia, etiquetas, ids)
    cajas = ndimage.find_objects(etiquetas, max_label=k)
    out = np.zeros((k, 4), dtype=np.uint16)
    for i, (p, c) in enumerate(zip(puntos, cajas)):
        if c is None:          # id sin píxeles: no debería pasar
            continue
        out[i] = (p[1], p[0], c[1].stop - c[1].start, c[0].stop - c[0].start)
    return out


def guardar(ruta_regiones, k):
    rgb = np.asarray(Image.open(ruta_regiones).convert("RGB"), dtype=np.int32)
    etiquetas = rgb[..., 0] + rgb[..., 1] * 256
    datos = datos_zonas(etiquetas, k)
    ruta = ruta_regiones.replace("_regiones.png", "_zonas.bin")
    with open(ruta, "wb") as f:
        f.write(datos.astype("<u2").tobytes())
    return ruta


def _trabajo(t):
    cat, lid, k = t
    return guardar(os.path.join(DESTINO, cat, lid + "_regiones.png"), k)


def main():
    solo = sys.argv[1] if len(sys.argv) > 1 else ""
    indice = json.load(open(os.path.join(DESTINO, "indice.json"), encoding="utf-8"))
    trabajos = [(c["id"], l["id"], l["zonas"]) for c in indice["categorias"]
                if not solo or c["id"] == solo for l in c["laminas"]]
    with Pool() as pool:
        for i, _ in enumerate(pool.imap_unordered(_trabajo, trabajos, chunksize=4), 1):
            if i % 100 == 0:
                print(i, "/", len(trabajos), file=sys.stderr)
    print("zonas de", len(trabajos), "láminas", file=sys.stderr)


if __name__ == "__main__":
    main()
