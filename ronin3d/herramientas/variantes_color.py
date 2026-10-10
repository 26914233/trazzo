#!/usr/bin/env python3
"""Variantes de color de una hoja de sprites del juego, girando el tono (como el oni azul de la ficha
del oni, BESTIARIO.md §3): copia <origen>.png/.json de godot/recursos/sprites/ como <destino>, con el
tono de cada píxel girado «giro» grados y la saturación y el brillo multiplicados.

Uso:  python3 ronin3d/herramientas/variantes_color.py <origen> <destino> <giro> [saturación] [brillo]
      p. ej.  ... oni_jefe oni_azul_hoja 200
"""
import json
import os
import sys

import numpy as np
from PIL import Image

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SPRITES = os.path.join(RAIZ, "godot", "recursos", "sprites")


def main() -> None:
    if len(sys.argv) < 4:
        sys.exit(__doc__)
    origen, destino, giro = sys.argv[1], sys.argv[2], float(sys.argv[3])
    saturacion = float(sys.argv[4]) if len(sys.argv) > 4 else 1.0
    brillo = float(sys.argv[5]) if len(sys.argv) > 5 else 1.0
    imagen = Image.open(os.path.join(SPRITES, origen + ".png")).convert("RGBA")
    alfa = imagen.getchannel("A")
    hsv = np.array(imagen.convert("RGB").convert("HSV")).astype(float)
    hsv[..., 0] = (hsv[..., 0] + giro / 360.0 * 255.0) % 256.0
    hsv[..., 1] = np.clip(hsv[..., 1] * saturacion, 0, 255)
    hsv[..., 2] = np.clip(hsv[..., 2] * brillo, 0, 255)
    nueva = Image.fromarray(hsv.astype(np.uint8), "HSV").convert("RGB")
    nueva.putalpha(alfa)
    nueva.save(os.path.join(SPRITES, destino + ".png"))
    with open(os.path.join(SPRITES, origen + ".json"), encoding="utf-8") as archivo:
        datos = json.load(archivo)
    datos["id"] = destino
    with open(os.path.join(SPRITES, destino + ".json"), "w", encoding="utf-8") as archivo:
        json.dump(datos, archivo, ensure_ascii=False, indent=1)
    print(f"{destino}: {origen} con el tono girado {giro:.0f}°")


if __name__ == "__main__":
    main()
