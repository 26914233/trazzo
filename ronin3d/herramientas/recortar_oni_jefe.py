#!/usr/bin/env python3
"""Recorta las animaciones del oni de la hoja de estilo del usuario (arte/conceptos/oni_jefe_hoja.webp,
10-10-2026) y las monta en una hoja de sprites para el jefe: godot/recursos/sprites/oni_jefe.png y .json.

Cada cuadro se recorta de su panel, el fondo azul oscuro se quita con un relleno desde los bordes (así
los tonos oscuros de dentro del personaje no se pierden) y todos se alinean por los pies: la fila de
abajo y el centro de las piernas caen en el mismo píxel de cada celda.

Uso:  python3 ronin3d/herramientas/recortar_oni_jefe.py
"""
import json
import os
from collections import deque

import numpy as np
from PIL import Image

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HOJA = os.path.join(RAIZ, "arte", "conceptos", "oni_jefe_hoja.webp")
SALIDA = os.path.join(RAIZ, "godot", "recursos", "sprites", "oni_jefe")
FONDO = np.array([12, 15, 23])
TOLERANCIA_FONDO = 38          # suma de diferencias RGB que aún cuenta como fondo
CELDA = (240, 140)             # ancho y alto de cada cuadro en la hoja
PIES = (110, 132)              # dónde caen los pies dentro de la celda (x del centro, y de la base)

# (nombre, fila y0-y1, [x0-x1 de cada cuadro], cuadros por segundo; 0 = según el progreso)
ANIMACIONES = [
    ("reposo", (550, 672), [(47, 109), (133, 189), (212, 273), (300, 358), (385, 442)], 6.0),
    ("caminar", (550, 672), [(512, 569), (594, 657), (676, 732), (754, 810), (832, 888), (910, 978)], 9.0),
    ("ataque", (705, 835), [(38, 125), (143, 250), (252, 393), (397, 588)], 0.0),
    ("area", (705, 835), [(635, 736), (743, 956), (966, 1082), (1095, 1209)], 0.0),
    ("golpe", (875, 982), [(52, 158), (165, 248), (265, 351), (358, 419), (438, 512)], 0.0),
    ("muerte", (875, 982), [(642, 703), (724, 838), (858, 963), (980, 1075), (1100, 1206)], 0.0),
]


def quitar_fondo(rgb: np.ndarray) -> np.ndarray:
    """Alfa 0 en el fondo conectado con los bordes del recorte."""
    alto, ancho, _ = rgb.shape
    parecido = np.abs(rgb.astype(int) - FONDO).sum(2) <= TOLERANCIA_FONDO
    fondo = np.zeros((alto, ancho), bool)
    cola = deque()
    for x in range(ancho):
        for y in (0, alto - 1):
            if parecido[y, x]:
                cola.append((y, x))
    for y in range(alto):
        for x in (0, ancho - 1):
            if parecido[y, x]:
                cola.append((y, x))
    while cola:
        y, x = cola.popleft()
        if fondo[y, x]:
            continue
        fondo[y, x] = True
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < alto and 0 <= nx < ancho and parecido[ny, nx] and not fondo[ny, nx]:
                cola.append((ny, nx))
    alfa = np.where(fondo, 0, 255).astype(np.uint8)
    return np.dstack([rgb, alfa])


def recortar(imagen: np.ndarray, fila, columnas) -> Image.Image:
    y0, y1 = fila
    x0, x1 = columnas
    rgba = quitar_fondo(imagen[y0:y1, x0 - 4:x1 + 4])
    solido = rgba[:, :, 3] > 0
    filas = np.where(solido.any(1))[0]
    base = filas.max()
    # Centro de las piernas: el cuarto de abajo del cuerpo, sin el arma ni los efectos.
    abajo = solido[max(0, base - (base - filas.min()) // 4):base + 1]
    xs = np.where(abajo.any(0))[0]
    centro = int(np.median(np.where(abajo)[1])) if xs.size else rgba.shape[1] // 2
    celda = np.zeros((CELDA[1], CELDA[0], 4), np.uint8)
    dx = PIES[0] - centro
    dy = PIES[1] - base
    for y in range(rgba.shape[0]):
        ty = y + dy
        if not 0 <= ty < CELDA[1]:
            continue
        for x in range(rgba.shape[1]):
            tx = x + dx
            if 0 <= tx < CELDA[0] and rgba[y, x, 3]:
                celda[ty, tx] = rgba[y, x]
    return Image.fromarray(celda, "RGBA")


def main() -> None:
    imagen = np.array(Image.open(HOJA).convert("RGB"))
    cuadros = []
    # alto_px: lo que mide el oni en reposo (sin el pelo que sobresale), para darle su altura.
    descripcion = {"id": "oni_jefe", "tam": list(CELDA), "pies": list(PIES), "alto_px": 105, "animaciones": {}}
    for nombre, fila, columnas, fps in ANIMACIONES:
        descripcion["animaciones"][nombre] = {"inicio": len(cuadros), "cuadros": len(columnas), "fps": fps}
        for x0x1 in columnas:
            cuadros.append(recortar(imagen, fila, x0x1))
    columnas_hoja = 8
    filas_hoja = (len(cuadros) + columnas_hoja - 1) // columnas_hoja
    hoja = Image.new("RGBA", (CELDA[0] * columnas_hoja, CELDA[1] * filas_hoja), (0, 0, 0, 0))
    for i, cuadro in enumerate(cuadros):
        hoja.paste(cuadro, ((i % columnas_hoja) * CELDA[0], (i // columnas_hoja) * CELDA[1]))
    descripcion["columnas"] = columnas_hoja
    hoja.save(SALIDA + ".png")
    with open(SALIDA + ".json", "w", encoding="utf-8") as archivo:
        json.dump(descripcion, archivo, ensure_ascii=False, indent=1)
    print(f"oni_jefe: {len(cuadros)} cuadros, hoja de {hoja.size[0]}×{hoja.size[1]} px")


if __name__ == "__main__":
    main()
