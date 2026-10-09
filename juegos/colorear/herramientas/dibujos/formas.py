"""Formas: corazones, estrellas, lunas... Caja 0..1000, y hacia abajo."""
import math


def corazon_pts(c=(500, 520), k=26.0):
    pts = []
    for i in range(120):
        t = 2 * math.pi * i / 120
        x = 16 * math.sin(t) ** 3
        y = 13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t)
        pts.append((c[0] + x * k, c[1] - y * k))
    return pts


def corazon(p):
    p.forma(corazon_pts())
    p.forma(corazon_pts(k=17.0))
    p.forma(corazon_pts(k=8.0))


SUJETOS = [
    ("corazon", "Corazón", "nada", corazon),
]
