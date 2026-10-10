#!/usr/bin/env python3
"""Icono de Rebotazz (dibujado aqui): ladrillos, bola y paleta sobre fondo espacial."""
import os

from PIL import Image, ImageDraw, ImageFilter

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
COLORES = ["#FF4D6D", "#FF9F1C", "#FFD60A", "#3DDC97", "#3A86FF", "#9B5DE5"]


def dibujo(lado, con_fondo=True, mono=False):
    s = lado / 512
    im = Image.new("RGBA", (lado, lado), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    if con_fondo:
        for y in range(lado):
            t = y / lado
            c = (int(11 + 19 * t), int(16 + 11 * t), int(38 + 37 * t), 255)
            d.line([(0, y), (lado, y)], fill=c)
    blanco = (255, 255, 255, 255)
    # ladrillos: 3 filas
    for f in range(3):
        for c in range(4 - (f == 1)):
            x = 70 + c * 96 + (48 if f == 1 else 0)
            y = 80 + f * 54
            col = blanco if mono else COLORES[(f * 2 + c) % 6]
            d.rounded_rectangle([x * s, y * s, (x + 86) * s, (y + 42) * s], radius=10 * s, fill=col)
            if not mono:
                d.rounded_rectangle([(x + 8) * s, (y + 6) * s, (x + 78) * s, (y + 14) * s], radius=4 * s, fill=(255, 255, 255, 110))
    # bola
    bx, by, br = 300, 300, 34
    d.ellipse([(bx - br) * s, (by - br) * s, (bx + br) * s, (by + br) * s], fill=blanco if mono else (201, 210, 227, 255))
    if not mono:
        d.ellipse([(bx - 16) * s, (by - 22) * s, (bx + 2) * s, (by - 4) * s], fill=(255, 255, 255, 230))
    # paleta
    px, py = 256, 410
    d.rounded_rectangle([(px - 120) * s, py * s, (px + 120) * s, (py + 40) * s], radius=20 * s, fill=blanco if mono else (34, 211, 238, 255))
    if not mono:
        for lado_x in (px - 112, px + 80):
            d.rounded_rectangle([lado_x * s, (py + 5) * s, (lado_x + 32) * s, (py + 35) * s], radius=14 * s, fill=(236, 72, 153, 255))
    return im


def main():
    destino = os.path.join(RAIZ, "arte")
    dibujo(512).convert("RGB").save(os.path.join(destino, "icono.png"))
    dibujo(192).save(os.path.join(destino, "icono_android", "principal_192.png"))
    # adaptativo: el primer plano debe caber en el circulo central (66 %)
    frente = Image.new("RGBA", (432, 432), (0, 0, 0, 0))
    frente.alpha_composite(dibujo(300, con_fondo=False), (66, 66))
    frente.save(os.path.join(destino, "icono_android", "frente_432.png"))
    Image.new("RGB", (432, 432), (15, 21, 52)).save(os.path.join(destino, "icono_android", "fondo_432.png"))
    mono = Image.new("RGBA", (432, 432), (0, 0, 0, 0))
    mono.alpha_composite(dibujo(300, con_fondo=False, mono=True), (66, 66))
    mono.save(os.path.join(destino, "icono_android", "monocromo_432.png"))
    print("iconos listos")


if __name__ == "__main__":
    main()
