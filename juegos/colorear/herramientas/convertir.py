#!/usr/bin/env python3
"""Convierte un dibujo de líneas (PNG) en lámina pintable.

Pensado para ilustraciones de líneas finas: las engrosa un poco para que las
zonas queden cerradas, y deja la línea suave. Escribe los mismos tres archivos
que laminas.py (<id>_lineas.png, <id>_regiones.png, <id>_mini.png).

Uso: python3 herramientas/convertir.py entrada.png salida_sin_extension [--grosor 2]
"""
import argparse
import sys

import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage

from laminas import LADO, procesar_tinta


def solo_lineas(g, contraste=35, mancha=40):
    """Quita sombreados y fondos grises: se queda con lo que es claramente más
    oscuro que su entorno (las líneas) y borra motas sueltas."""
    a = np.asarray(g, dtype=np.float32)
    entorno = ndimage.uniform_filter(a, 15)
    linea = (entorno - a > contraste) | (a < 60) & (entorno - a > contraste * 0.5)
    etiquetas, n = ndimage.label(linea, structure=np.ones((3, 3)))
    if n:
        tam = ndimage.sum_labels(np.ones_like(etiquetas), etiquetas, index=np.arange(n + 1))
        linea &= (tam >= mancha)[etiquetas]
    return Image.fromarray(np.where(linea, 0, 255).astype(np.uint8))


def tinta_de(img, grosor=2, umbral=150, limpiar=False):
    g = img.convert("L")
    if limpiar:
        g = solo_lineas(g)
    # recorta márgenes blancos y centra en un cuadrado
    caja = Image.eval(g, lambda v: 255 - v).getbbox()
    if caja:
        g = g.crop(caja)
    lado = int(max(g.size) * 1.08)
    lienzo = Image.new("L", (lado, lado), 255)
    lienzo.paste(g, ((lado - g.size[0]) // 2, (lado - g.size[1]) // 2))
    g = lienzo.resize((LADO, LADO), Image.LANCZOS)
    a = 255 - np.asarray(g, dtype=np.int32)
    linea = a > (255 - umbral)
    if grosor:
        linea = ndimage.binary_dilation(linea, iterations=grosor)
    # línea suave: máscara engrosada con un poco de desenfoque
    suave = Image.fromarray((linea * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.8))
    return np.maximum(np.asarray(suave, dtype=np.int32), a)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("entrada")
    ap.add_argument("salida")
    ap.add_argument("--grosor", type=int, default=1)
    ap.add_argument("--limpiar", action="store_true", help="quitar sombreado y fondos grises")
    args = ap.parse_args()
    lin, reg, mini, k = procesar_tinta(tinta_de(Image.open(args.entrada), args.grosor, limpiar=args.limpiar))
    lin.save(args.salida + "_lineas.png", optimize=True)
    reg.save(args.salida + "_regiones.png", optimize=True)
    mini.save(args.salida + "_mini.png", optimize=True)
    print(k, "zonas", file=sys.stderr)


if __name__ == "__main__":
    main()
