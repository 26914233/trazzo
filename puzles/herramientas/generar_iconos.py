#!/usr/bin/env python3
"""Iconos de la interfaz (blancos sobre transparente, 160 x 160): se dibujan a 4 veces el tamaño y se
reducen para que los bordes queden suaves. El color lo pone el juego al usarlos.

Uso:  python3 puzles/herramientas/generar_iconos.py
"""

import math
import os

from PIL import Image, ImageDraw, ImageFont

AQUI = os.path.dirname(os.path.abspath(__file__))
DESTINO = os.path.join(AQUI, "..", "godot", "recursos", "iconos")
TAM = 160
ESCALA = 4
G = TAM * ESCALA
BLANCO = (255, 255, 255, 255)


def lienzo():
    imagen = Image.new("RGBA", (G, G), (0, 0, 0, 0))
    return imagen, ImageDraw.Draw(imagen)


def guardar(nombre, imagen):
    os.makedirs(DESTINO, exist_ok=True)
    imagen.resize((TAM, TAM), Image.LANCZOS).save(os.path.join(DESTINO, nombre + ".png"))
    print("  ", nombre)


def trazo(d, puntos, grosor):
    """Línea gruesa con extremos y uniones redondeados."""
    puntos = [(x * G, y * G) for x, y in puntos]
    d.line(puntos, fill=BLANCO, width=int(grosor * G), joint="curve")
    r = grosor * G / 2
    for x, y in (puntos[0], puntos[-1]):
        d.ellipse([x - r, y - r, x + r, y + r], fill=BLANCO)


def volver():
    imagen, d = lienzo()
    trazo(d, [(0.6, 0.24), (0.36, 0.5), (0.6, 0.76)], 0.11)
    guardar("volver", imagen)


def siguiente():
    imagen, d = lienzo()
    trazo(d, [(0.4, 0.24), (0.64, 0.5), (0.4, 0.76)], 0.11)
    guardar("siguiente", imagen)


def pista():
    imagen, d = lienzo()
    ruta = "/usr/share/fonts/truetype/liberation/LiberationSerif-Bold.ttf"
    prueba = ImageFont.truetype(ruta, 100)
    caja = d.textbbox((0, 0), "?", font=prueba)
    fuente = ImageFont.truetype(ruta, int(100 * G * 0.74 / (caja[3] - caja[1])))
    caja = d.textbbox((0, 0), "?", font=fuente)
    ancho = caja[2] - caja[0]
    alto = caja[3] - caja[1]
    d.text(((G - ancho) / 2 - caja[0], (G - alto) / 2 - caja[1]), "?", font=fuente, fill=BLANCO)
    guardar("pista", imagen)


def centrar():
    imagen, d = lienzo()
    a, b, l = 0.2, 0.8, 0.2
    for x, y, dx, dy in ((a, a, 1, 1), (b, a, -1, 1), (a, b, 1, -1), (b, b, -1, -1)):
        trazo(d, [(x + dx * l, y), (x, y), (x, y + dy * l)], 0.085)
    r = 0.07 * G
    d.ellipse([G / 2 - r, G / 2 - r, G / 2 + r, G / 2 + r], fill=BLANCO)
    guardar("centrar", imagen)


def lupa():
    imagen, d = lienzo()
    cx, cy, r, g = 0.42 * G, 0.42 * G, 0.22 * G, 0.085 * G
    d.ellipse([cx - r - g / 2, cy - r - g / 2, cx + r + g / 2, cy + r + g / 2], outline=BLANCO, width=int(g))
    trazo(d, [(0.59, 0.59), (0.8, 0.8)], 0.12)
    guardar("lupa", imagen)


def cerrar():
    imagen, d = lienzo()
    trazo(d, [(0.28, 0.28), (0.72, 0.72)], 0.11)
    trazo(d, [(0.72, 0.28), (0.28, 0.72)], 0.11)
    guardar("cerrar", imagen)


def candado():
    imagen, d = lienzo()
    g = 0.085 * G
    d.rounded_rectangle([0.24 * G, 0.44 * G, 0.76 * G, 0.84 * G], radius=0.07 * G, fill=BLANCO)
    d.arc([0.32 * G, 0.16 * G, 0.68 * G, 0.6 * G], 180, 360, fill=BLANCO, width=int(g))
    d.line([(0.32 * G + g / 2, 0.38 * G), (0.32 * G + g / 2, 0.46 * G)], fill=BLANCO, width=int(g))
    d.line([(0.68 * G - g / 2, 0.38 * G), (0.68 * G - g / 2, 0.46 * G)], fill=BLANCO, width=int(g))
    r = 0.05 * G
    d.ellipse([G / 2 - r, 0.6 * G - r, G / 2 + r, 0.6 * G + r], fill=(0, 0, 0, 0))
    d.rectangle([G / 2 - r * 0.45, 0.6 * G, G / 2 + r * 0.45, 0.72 * G], fill=(0, 0, 0, 0))
    guardar("candado", imagen)


def jugar():
    imagen, d = lienzo()
    d.polygon([(0.34 * G, 0.22 * G), (0.34 * G, 0.78 * G), (0.8 * G, 0.5 * G)], fill=BLANCO)
    guardar("jugar", imagen)


def repetir():
    imagen, d = lienzo()
    g = 0.09 * G
    d.arc([0.22 * G, 0.22 * G, 0.78 * G, 0.78 * G], 300, 240, fill=BLANCO, width=int(g))
    angulo = math.radians(300)
    x = 0.5 + 0.28 * math.cos(angulo)
    y = 0.5 + 0.28 * math.sin(angulo)
    d.polygon([((x + 0.13) * G, (y - 0.02) * G), ((x - 0.05) * G, (y - 0.13) * G), ((x - 0.02) * G, (y + 0.09) * G)], fill=BLANCO)
    guardar("repetir", imagen)


if __name__ == "__main__":
    for funcion in (volver, siguiente, pista, centrar, lupa, cerrar, candado, jugar, repetir):
        funcion()
