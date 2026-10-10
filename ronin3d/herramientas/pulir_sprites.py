#!/usr/bin/env python3
"""Pule las hojas de sprites que hornea godot/scripts/hornear_sprites.gd y las deja en el juego.

Lo que hace a cada hoja (herramientas/sprites_crudos/<id>.png):
  1. La transparencia, en todo o nada (el pixel art no tiene bordes a medias).
  2. Aclara un poco los tonos oscuros: de noche, la ropa casi negra se perdía.
  3. Reduce los colores a una paleta corta (corte por la mediana), igual para todos los cuadros.
  4. Pone un contorno oscuro de un píxel alrededor de la silueta, del tono del borde.
Escribe godot/recursos/sprites/<id>.png y copia la descripción (<id>.json).

Uso:  python3 ronin3d/herramientas/pulir_sprites.py [id ...]     (sin id: todas las hojas)
"""

import json
import os
import shutil
import sys

import numpy as np
from PIL import Image

AQUI = os.path.dirname(os.path.abspath(__file__))
CRUDOS = os.path.join(AQUI, "sprites_crudos")
DESTINO = os.path.join(AQUI, "..", "godot", "recursos", "sprites")
COLORES = 40                       # colores por hoja (sin contar la transparencia y el contorno)
GAMMA = 0.82                       # < 1 aclara los oscuros
TINTA = np.array([18, 14, 24], dtype=np.float32)   # el contorno tira hacia este negro azulado


def pulir(identificador):
    crudo = np.array(Image.open(os.path.join(CRUDOS, identificador + ".png")).convert("RGBA"))
    opaco = crudo[..., 3] >= 128
    color = crudo[..., :3].astype(np.float32) / 255.0
    color = np.power(color, GAMMA) * 255.0

    # Paleta: corte por la mediana con los píxeles opacos de toda la hoja
    muestras = color[opaco].astype(np.uint8).reshape(1, -1, 3)
    paleta = Image.fromarray(muestras, "RGB").quantize(colors=COLORES, method=Image.Quantize.MEDIANCUT)
    plano = Image.fromarray(color.clip(0, 255).astype(np.uint8), "RGB")
    reducido = np.array(plano.quantize(palette=paleta, dither=Image.Dither.NONE).convert("RGB"))

    salida = np.zeros_like(crudo)
    salida[opaco, :3] = reducido[opaco]
    salida[opaco, 3] = 255

    # Contorno: los píxeles transparentes que tocan la silueta (arriba, abajo o a los lados)
    vecino = np.zeros_like(opaco)
    tono = np.zeros(color.shape, dtype=np.float32)
    cuenta = np.zeros(opaco.shape, dtype=np.float32)
    for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        desplazado = np.roll(opaco, (dy, dx), axis=(0, 1))
        color_desplazado = np.roll(reducido.astype(np.float32), (dy, dx), axis=(0, 1))
        vecino |= desplazado
        tono += color_desplazado * desplazado[..., None]
        cuenta += desplazado
    borde = vecino & ~opaco
    medio = tono[borde] / np.maximum(cuenta[borde], 1.0)[:, None]
    salida[borde, :3] = (medio * 0.3 + TINTA * 0.7).clip(0, 255).astype(np.uint8)
    salida[borde, 3] = 255

    os.makedirs(DESTINO, exist_ok=True)
    Image.fromarray(salida, "RGBA").save(os.path.join(DESTINO, identificador + ".png"), optimize=True)
    shutil.copyfile(os.path.join(CRUDOS, identificador + ".json"), os.path.join(DESTINO, identificador + ".json"))
    colores = len(np.unique(salida[salida[..., 3] > 0][:, :3], axis=0))
    print(f"{identificador}: {salida.shape[1]}×{salida.shape[0]} px, {colores} colores con el contorno")


def main():
    ids = sys.argv[1:] or sorted(n[:-4] for n in os.listdir(CRUDOS) if n.endswith(".png"))
    for identificador in ids:
        pulir(identificador)


if __name__ == "__main__":
    main()
