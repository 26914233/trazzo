#!/usr/bin/env python3
"""Reduce las hojas de sprites a una paleta de pocos colores (128 por defecto). En pixel art apenas se
nota, limpia el ruido que dejó el JPEG de Gemini y la hoja pesa mucho menos en el APK.

Uso:  python3 ronin3d/herramientas/reducir_paleta.py [--colores N] <id> [<id> ...]   (p. ej. kappa_hoja)
"""
import os
import sys

import numpy as np
from PIL import Image

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SPRITES = os.path.join(RAIZ, "godot", "recursos", "sprites")


def reducir(ident: str, colores: int) -> None:
    ruta = os.path.join(SPRITES, ident + ".png")
    antes = os.path.getsize(ruta)
    imagen = Image.open(ruta).convert("RGBA")
    alfa = np.array(imagen.getchannel("A"))
    # La paleta sale solo de los píxeles visibles; el fondo transparente es un índice aparte.
    rgb = imagen.convert("RGB").quantize(colors=colores - 1, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    indices = np.array(rgb, dtype=np.uint8) + 1
    indices[alfa < 128] = 0
    paleta = [0, 0, 0] + rgb.getpalette()[: (colores - 1) * 3]
    salida = Image.fromarray(indices, "P")
    salida.putpalette(paleta)
    salida.info["transparency"] = 0
    salida.save(ruta, optimize=True, transparency=0)
    print(f"{ident}: {antes // 1024} KB → {os.path.getsize(ruta) // 1024} KB")


def main() -> None:
    argumentos = sys.argv[1:]
    colores = 128
    if argumentos[:1] == ["--colores"]:
        colores = int(argumentos[1])
        argumentos = argumentos[2:]
    if not argumentos:
        sys.exit(__doc__)
    for ident in argumentos:
        reducir(ident, colores)


if __name__ == "__main__":
    main()
