#!/usr/bin/env python3
"""Filtra y ordena las imágenes generadas en Colab antes de revisarlas a ojo.

Para cada imagen mide:
  gris     fracción de píxeles grises (sombras): debe ser baja
  tinta    fracción de línea: ni vacía ni emborronada
  zonas    zonas pintables tras convertirla (convertir.py)
  borde    tinta pegada al borde (dibujo cortado)
Descarta lo que se sale de los límites y deja el resto ordenado, con hojas de
contacto numeradas para elegir.

Uso: python3 herramientas/seleccionar.py carpeta_imagenes salida/
"""
import csv
import os
import sys

import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage

from convertir import tinta_de
from laminas import procesar_tinta

LIMITES = {"tinta_min": 0.05, "tinta_max": 0.17, "zonas_min": 80, "zonas_max": 900}


def medir(ruta):
    """Mide la lámina tal como quedará: con la limpieza de sombreados aplicada."""
    img = Image.open(ruta).convert("L")
    tinta = tinta_de(img, 0, limpiar=True)
    lin, _r, mini, zonas = procesar_tinta(tinta)
    a = np.asarray(lin)[..., 1]
    return {"tinta": float((a > 128).mean()), "zonas": zonas, "mini": mini}


def valida(m):
    return LIMITES["tinta_min"] <= m["tinta"] <= LIMITES["tinta_max"] and LIMITES["zonas_min"] <= m["zonas"] <= LIMITES["zonas_max"]


def _medir_seguro(ruta):
    try:
        m = medir(ruta)
    except Exception as e:  # imagen rota: se informa y se sigue
        print("no se pudo medir", ruta, e, file=sys.stderr)
        return None
    m["ruta"] = ruta
    m["valida"] = valida(m)
    return m


def main():
    from multiprocessing import Pool
    origen, salida = sys.argv[1], sys.argv[2]
    os.makedirs(os.path.join(salida, "minis"), exist_ok=True)
    rutas = sorted(os.path.join(r, f) for r, _d, fs in os.walk(origen) for f in fs if f.lower().endswith(".png"))
    with Pool() as pool:
        filas = [m for m in pool.imap_unordered(_medir_seguro, rutas, chunksize=4) if m]
    for m in filas:
        m["mini"].save(os.path.join(salida, "minis", os.path.basename(m["ruta"])))
        del m["mini"]
    filas.sort(key=lambda m: (not m["valida"], os.path.basename(m["ruta"])))
    with open(os.path.join(salida, "medidas.csv"), "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=["ruta", "valida", "tinta", "zonas"])
        w.writeheader()
        w.writerows(filas)
    buenas = [m for m in filas if m["valida"]]
    print(len(filas), "medidas,", len(buenas), "pasan los filtros", file=sys.stderr)
    # hojas de contacto 6x5 numeradas, con la lámina ya limpia (lo que verá quien pinta)
    for h in range(0, len(buenas), 30):
        hoja = Image.new("L", (6 * 330, 5 * 350), 255)
        d = ImageDraw.Draw(hoja)
        for k, m in enumerate(buenas[h:h + 30]):
            x, y = (k % 6) * 330, (k // 6) * 350
            hoja.paste(Image.open(os.path.join(salida, "minis", os.path.basename(m["ruta"]))).resize((320, 320)), (x + 5, y + 5))
            d.text((x + 8, y + 328), "%d %s" % (h + k, os.path.basename(m["ruta"])[:44]), fill=0)
        hoja.save(os.path.join(salida, "hoja_%03d.png" % (h // 30)))


if __name__ == "__main__":
    main()
