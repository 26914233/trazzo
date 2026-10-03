#!/usr/bin/env python3
"""El icono del APK de La caja viva, sacado de la ilustración (la cara de la caja: el cuerno, el ojo y la cuenca).

- Icono adaptable (Android 8 y más): una capa de fondo a sangre con la cara, 108 dp (432 px en xxxhdpi). El lanzador
  enseña los 72 dp del centro con su máscara (círculo, gota…), así que la cara va centrada en ese tercio interior.
- Icono clásico (Android 7): cuadrados con las esquinas redondeadas, de 48 a 192 px.

Uso:  python3 puzles/ilustrada/apk/herramientas/icono_apk.py
"""
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

AQUI = os.path.dirname(os.path.abspath(__file__))
APK = os.path.normpath(os.path.join(AQUI, '..'))
FUENTE = os.path.normpath(os.path.join(APK, '..', 'fuentes', 'sala.jpg'))
RES = os.path.join(APK, 'res')

# La parte visible (los 72 dp del centro) es la cara de cerca; el resto, lo que la rodea
CENTRO, VISIBLE = (850, 382), 262            # píxeles del boceto
LADO_TOTAL = VISIBLE * 108 / 72


def cara(lado):
    im = Image.open(FUENTE).convert('RGB')
    m = LADO_TOTAL / 2
    x, y = CENTRO
    recorte = im.crop((round(x - m), round(y - m), round(x + m), round(y + m)))
    recorte = recorte.resize((lado, lado), Image.LANCZOS)
    # viñeta suave: los bordes, en la penumbra de la sala
    yy, xx = np.mgrid[0:lado, 0:lado] / (lado - 1) * 2 - 1
    r = np.sqrt(xx ** 2 + yy ** 2)
    oscuro = np.clip((r - 0.55) / 0.6, 0, 1) ** 1.4 * 0.55
    a = np.asarray(recorte, np.float32) * (1 - oscuro[..., None]) + np.array([12, 9, 7]) * oscuro[..., None]
    return Image.fromarray(np.clip(a, 0, 255).astype(np.uint8)).filter(ImageFilter.UnsharpMask(1.2, 60, 2))


def guardar(imagen, carpeta, nombre):
    ruta = os.path.join(RES, carpeta)
    os.makedirs(ruta, exist_ok=True)
    imagen.save(os.path.join(ruta, nombre), optimize=True)
    print(f'  {carpeta}/{nombre}  {imagen.size[0]} px')


def principal():
    # adaptable: el fondo a sangre (la máscara la pone el lanzador)
    guardar(cara(432), 'mipmap-xxxhdpi', 'icono_fondo.png')
    # clásico: solo la parte visible, con esquinas redondeadas
    for carpeta, lado in (('mipmap-mdpi', 48), ('mipmap-hdpi', 72), ('mipmap-xhdpi', 96), ('mipmap-xxhdpi', 144), ('mipmap-xxxhdpi', 192)):
        grande = cara(lado * 4 * 108 // 72)
        m = (grande.size[0] - lado * 4) // 2
        grande = grande.crop((m, m, m + lado * 4, m + lado * 4))
        mascara = Image.new('L', grande.size, 0)
        ImageDraw.Draw(mascara).rounded_rectangle((0, 0, grande.size[0] - 1, grande.size[1] - 1), radius=grande.size[0] * 0.18, fill=255)
        icono = Image.new('RGBA', grande.size, (0, 0, 0, 0))
        icono.paste(grande, (0, 0), mascara)
        guardar(icono.resize((lado, lado), Image.LANCZOS), carpeta, 'icono.png')


if __name__ == '__main__':
    principal()
