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

LIMITES = {"gris": 0.01, "tinta_min": 0.03, "tinta_max": 0.32, "zonas_min": 40, "zonas_max": 1500, "borde": 0.02}


def medir(ruta):
    img = Image.open(ruta).convert("L")
    a = np.asarray(img.resize((1024, 1024)), dtype=np.int32)
    # gris lejos de las líneas = sombra (el suavizado del borde de una línea no cuenta)
    cerca = ndimage.binary_dilation(a < 110, iterations=3)
    gris = float(((a > 60) & (a < 215) & ~cerca).mean())
    tinta = float((a <= 128).mean())
    marco = np.concatenate([a[:6].ravel(), a[-6:].ravel(), a[:, :6].ravel(), a[:, -6:].ravel()])
    borde = float((marco <= 128).mean())
    _l, _r, _m, zonas = procesar_tinta(tinta_de(img, 1))
    return {"gris": gris, "tinta": tinta, "borde": borde, "zonas": zonas}


def valida(m):
    return (m["gris"] <= LIMITES["gris"] and LIMITES["tinta_min"] <= m["tinta"] <= LIMITES["tinta_max"]
            and LIMITES["zonas_min"] <= m["zonas"] <= LIMITES["zonas_max"] and m["borde"] <= LIMITES["borde"])


def main():
    origen, salida = sys.argv[1], sys.argv[2]
    os.makedirs(salida, exist_ok=True)
    filas = []
    for raiz, _d, archivos in os.walk(origen):
        for f in sorted(archivos):
            if f.lower().endswith(".png"):
                ruta = os.path.join(raiz, f)
                try:
                    m = medir(ruta)
                except Exception as e:  # imagen rota: se informa y se sigue
                    print("no se pudo medir", ruta, e, file=sys.stderr)
                    continue
                m["ruta"] = ruta
                m["valida"] = valida(m)
                filas.append(m)
    filas.sort(key=lambda m: (not m["valida"], m["gris"]))
    with open(os.path.join(salida, "medidas.csv"), "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=["ruta", "valida", "gris", "tinta", "borde", "zonas"])
        w.writeheader()
        w.writerows(filas)
    buenas = [m for m in filas if m["valida"]]
    print(len(filas), "medidas,", len(buenas), "pasan los filtros", file=sys.stderr)
    # hojas de contacto de 6x5 numeradas
    for h in range(0, len(buenas), 30):
        hoja = Image.new("L", (6 * 330, 5 * 350), 255)
        d = ImageDraw.Draw(hoja)
        for k, m in enumerate(buenas[h:h + 30]):
            x, y = (k % 6) * 330, (k // 6) * 350
            hoja.paste(Image.open(m["ruta"]).convert("L").resize((320, 320)), (x + 5, y + 5))
            d.text((x + 8, y + 328), "%d %s" % (h + k, os.path.basename(m["ruta"])[:40]), fill=0)
        hoja.save(os.path.join(salida, "hoja_%03d.png" % (h // 30)))


if __name__ == "__main__":
    main()
