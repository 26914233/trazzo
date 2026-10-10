#!/usr/bin/env python3
"""Hoja de revisión de una o varias hojas de sprites del juego: cada animación en una fila, con su
nombre y el número de cada cuadro, sobre gris, para ver de un vistazo si el recorte salió bien.

Uso:  python3 ronin3d/herramientas/vista_hoja.py <salida.png> <id> [<id> ...]   (p. ej. kappa_hoja)
"""
import json
import os
import sys

from PIL import Image, ImageDraw

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ALTO_FILA = 96


def vista(ident: str) -> Image.Image:
    base = os.path.join(RAIZ, "godot", "recursos", "sprites", ident)
    hoja = Image.open(base + ".png")
    datos = json.load(open(base + ".json", encoding="utf-8"))
    ancho, alto = datos["tam"]
    escala = ALTO_FILA / alto
    celda = (max(1, int(ancho * escala)), ALTO_FILA)
    animaciones = datos["animaciones"]
    mayor = max(a["cuadros"] for a in animaciones.values())
    lienzo = Image.new("RGB", (90 + celda[0] * mayor, 18 + ALTO_FILA * len(animaciones)), (90, 90, 96))
    dibujo = ImageDraw.Draw(lienzo)
    dibujo.text((4, 2), f"{ident}  celda {ancho}x{alto}  alto_px {datos['alto_px']}", fill=(255, 255, 0))
    for fila, (nombre, anim) in enumerate(animaciones.items()):
        y = 18 + fila * ALTO_FILA
        dibujo.text((4, y + 4), nombre, fill=(255, 255, 255))
        for k in range(anim["cuadros"]):
            n = anim["inicio"] + k
            caja = ((n % datos["columnas"]) * ancho, (n // datos["columnas"]) * alto)
            cuadro = hoja.crop((caja[0], caja[1], caja[0] + ancho, caja[1] + alto)).resize(celda, Image.NEAREST)
            x = 90 + k * celda[0]
            lienzo.paste(cuadro, (x, y), cuadro)
            dibujo.rectangle((x, y, x + celda[0] - 1, y + ALTO_FILA - 1), outline=(60, 60, 64))
            dibujo.text((x + 2, y + 2), str(k), fill=(255, 220, 120))
    return lienzo


def main() -> None:
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    vistas = [vista(i) for i in sys.argv[2:]]
    lienzo = Image.new("RGB", (max(v.width for v in vistas), sum(v.height for v in vistas)), (40, 40, 40))
    y = 0
    for v in vistas:
        lienzo.paste(v, (0, y))
        y += v.height
    lienzo.save(sys.argv[1])


if __name__ == "__main__":
    main()
