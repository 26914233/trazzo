#!/usr/bin/env python3
"""Genera las láminas para colorear.

Cada lámina sale en tres archivos dentro de datos/laminas/<categoria>/:
  <id>_lineas.png    líneas negras con alfa (lo que se ve encima del color)
  <id>_regiones.png  id de zona por píxel: R + G*256 (lo que se toca y se rellena)
  <id>_mini.png      miniatura de las líneas para las listas
y un índice en datos/laminas/indice.json.

Las figuras se pintan de atrás hacia delante con relleno blanco y contorno negro
(algoritmo del pintor): lo de delante tapa a lo de atrás sin calcular intersecciones.
Se dibuja a 4x y se reduce para que las líneas salgan suaves.

Uso:  python3 herramientas/laminas.py            (todas)
      python3 herramientas/laminas.py --solo mandalas --cuantas 3 --salida /tmp/x
Necesita Pillow, numpy y scipy (solo en el ordenador de desarrollo).
"""
import argparse
import json
import math
import os
import sys
import zlib

import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage
from scipy.spatial import Voronoi

LADO = 1280          # tamaño final de la lámina
SS = 4               # superposición para suavizar
MINI = 320
LINEA = 5.0          # grosor normal de línea en píxeles finales
AREA_MINIMA = 160    # zonas más pequeñas se suman a la vecina (no se podrían tocar)
UMBRAL_LINEA = 110   # alfa a partir del cual un píxel es línea en el mapa de zonas
MAX_ZONAS = 4095     # la paleta del juego es una textura de 64x64

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


# --------------------------------------------------------------------- lienzo

class Lienzo:
    """Lienzo en coordenadas finales (0..LADO); dibuja a SS veces."""

    def __init__(self):
        self.img = Image.new("L", (LADO * SS, LADO * SS), 255)
        self.d = ImageDraw.Draw(self.img)
        self.escala = 1.0     # para dibujar en otra caja (p. ej. 0..1000)

    def _p(self, pts):
        k = SS * self.escala
        return [(x * k, y * k) for x, y in pts]

    def forma(self, pts, grosor=LINEA, relleno=True, negro=False):
        """Polígono cerrado: tapa lo de debajo (o se rellena de negro) y dibuja su borde."""
        q = self._p(pts)
        if negro:
            self.d.polygon(q, fill=0)
        elif relleno:
            self.d.polygon(q, fill=255)
        self.d.line(q + [q[0]], fill=0, width=max(1, int(grosor * SS)), joint="curve")
        self._puntas(q[:1], grosor)

    def trazo(self, pts, grosor=LINEA):
        """Línea abierta con puntas redondas."""
        q = self._p(pts)
        self.d.line(q, fill=0, width=max(1, int(grosor * SS)), joint="curve")
        self._puntas([q[0], q[-1]], grosor)

    def _puntas(self, q, grosor):
        r = grosor * SS / 2
        for x, y in q:
            self.d.ellipse((x - r, y - r, x + r, y + r), fill=0)

    def circulo(self, c, r, grosor=LINEA, relleno=True, negro=False):
        self.forma(circulo(c, r), grosor, relleno, negro)


def circulo(c, r, n=None):
    n = n or max(24, int(r * 0.9))
    return [(c[0] + r * math.cos(2 * math.pi * i / n), c[1] + r * math.sin(2 * math.pi * i / n)) for i in range(n)]


def polar(c, r, a):
    return (c[0] + r * math.cos(a), c[1] + r * math.sin(a))


def petalo(c, r1, r2, a, ancho, punta=0.0, n=24):
    """Pétalo entre los radios r1 y r2 centrado en el ángulo a.
    ancho: semiancho angular en la base; punta 0 = redondo, 1 = afilado."""
    lado_izq, lado_der = [], []
    for i in range(n + 1):
        t = i / n
        r = r1 + (r2 - r1) * t
        # perfil: abre y cierra; con punta, cierra en pico
        perfil = math.sin(math.pi * t) ** (0.6 + punta) if t < 1 else 0.0
        if t < 0.5:
            perfil = max(perfil, 0.35 * (1 - t * 2) * (1 - punta))
        da = ancho * perfil * (r1 + (r2 - r1) * 0.5) / max(r, 1)
        lado_izq.append(polar(c, r, a - da))
        lado_der.append(polar(c, r, a + da))
    return lado_izq + lado_der[::-1]


def bezier(p0, p1, p2, p3, n=30):
    pts = []
    for i in range(n + 1):
        t = i / n
        u = 1 - t
        pts.append((u ** 3 * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t ** 3 * p3[0],
                    u ** 3 * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t ** 3 * p3[1]))
    return pts


# --------------------------------------------------------------------- mandalas

def mandala(rng, lz, i):
    c = (LADO / 2, LADO / 2)
    k = int(rng.choice([8, 10, 12, 12, 16, 16, 20, 24]))
    paso = 2 * math.pi / k
    r_max = LADO * 0.47
    # anillos de dentro hacia fuera; se dibujan de fuera hacia dentro (pintor)
    # el primer anillo deja ~30 px por sector para que el centro no sea una mancha
    radios = [max(LADO * 0.06, 30 * k / (2 * math.pi))]
    while radios[-1] < r_max * 0.92:
        radios.append(min(r_max, radios[-1] + LADO * rng.uniform(0.045, 0.085)))
    radios[-1] = r_max
    capas = []
    for i in range(1, len(radios)):
        r1, r2 = radios[i - 1], radios[i]
        motivos = ["petalos", "petalos", "afilados", "festones", "puntos", "dobles", "rombos", "aro"]
        if r1 * 2 * math.pi / (2 * k) < 30:      # sin sitio para el doble de divisiones
            motivos = ["petalos", "afilados", "rombos", "puntos"]
        capas.append((r1, r2, rng.choice(motivos)))
    giro = 0.0
    for r1, r2, motivo in reversed(capas):
        giro = paso / 2 if rng.random() < 0.5 else 0.0
        lz.circulo(c, r2, LINEA)
        if motivo in ("petalos", "afilados"):
            punta = 0.9 if motivo == "afilados" else 0.0
            for j in range(k):
                a = j * paso + giro
                lz.forma(petalo(c, r1 * 0.98, r2 * 1.04, a, paso * 0.48, punta))
                if r2 - r1 > LADO * 0.06:
                    lz.forma(petalo(c, r1 * 0.98, r1 + (r2 - r1) * 0.62, a, paso * 0.22, punta), LINEA * 0.8)
        elif motivo == "dobles":
            for j in range(k * 2):
                a = j * paso / 2 + giro
                alto = r2 if j % 2 == 0 else r1 + (r2 - r1) * 0.7
                lz.forma(petalo(c, r1 * 0.98, alto, a, paso * 0.3, 0.5))
        elif motivo == "festones":
            n = k * 2
            for j in range(n):
                a = j * 2 * math.pi / n + giro
                rr = min((r2 - r1) * 0.55, r2 * math.sin(math.pi / n) * 1.05)
                lz.circulo(polar(c, r2 - rr * 0.9, a), rr, LINEA * 0.9)
            lz.circulo(c, r1 + (r2 - r1) * 0.25, LINEA * 0.8)
        elif motivo == "puntos":
            n = k * int(rng.choice([1, 2]))
            rm = (r1 + r2) / 2
            rr = min((r2 - r1) * 0.32, rm * math.sin(math.pi / n) * 0.75)
            for j in range(n):
                lz.circulo(polar(c, rm, j * 2 * math.pi / n + giro), rr, LINEA * 0.9)
        elif motivo == "rombos":
            for j in range(k):
                a = j * paso + giro
                rm = (r1 + r2) / 2
                lz.forma([polar(c, r1 * 1.02, a), polar(c, rm, a - paso * 0.45), polar(c, r2 * 0.98, a), polar(c, rm, a + paso * 0.45)])
        else:  # aro con radios
            lz.circulo(c, (r1 + r2) / 2, LINEA * 0.8)
            for j in range(k * 2):
                a = j * paso / 2 + giro
                lz.trazo([polar(c, r1, a), polar(c, r2, a)], LINEA * 0.8)
    lz.circulo(c, radios[0], LINEA)
    lz.circulo(c, radios[0] * 0.45, LINEA * 0.8)


# --------------------------------------------------------------------- vitrales

def puntos_relajados(rng, n, caja, pasos=3, dentro=None):
    x0, y0, x1, y1 = caja
    pts = rng.uniform([x0, y0], [x1, y1], size=(n * 3, 2))
    if dentro:
        pts = np.array([p for p in pts if dentro(p)])[:n]
    else:
        pts = pts[:n]
    for _ in range(pasos):
        regiones = celdas(pts, caja)
        pts = np.array([np.mean(r, axis=0) if len(r) else p for p, r in zip(pts, regiones)])
    return pts


def celdas(pts, caja):
    """Celdas de Voronoi recortadas a la caja (con puntos espejo en los bordes)."""
    x0, y0, x1, y1 = caja
    espejo = [pts,
              np.c_[2 * x0 - pts[:, 0], pts[:, 1]], np.c_[2 * x1 - pts[:, 0], pts[:, 1]],
              np.c_[pts[:, 0], 2 * y0 - pts[:, 1]], np.c_[pts[:, 0], 2 * y1 - pts[:, 1]]]
    v = Voronoi(np.vstack(espejo))
    salida = []
    for i in range(len(pts)):
        reg = v.regions[v.point_region[i]]
        if -1 in reg or not reg:
            salida.append(np.zeros((0, 2)))
            continue
        poly = v.vertices[reg]
        poly[:, 0] = poly[:, 0].clip(x0, x1)
        poly[:, 1] = poly[:, 1].clip(y0, y1)
        salida.append(poly)
    return salida


def encoger(poly, f):
    c = poly.mean(axis=0)
    return c + (poly - c) * f


def vitral(rng, lz, i):
    m = LADO * 0.04
    forma = rng.choice(["cuadro", "roseton", "arco"])
    caja = (m, m, LADO - m, LADO - m)
    c = np.array([LADO / 2, LADO / 2])
    R = LADO / 2 - m
    if forma == "roseton":
        dentro = lambda p: np.hypot(*(p - c)) < R * 0.97
    elif forma == "arco":
        dentro = lambda p: (p[1] > LADO * 0.42 and m < p[0] < LADO - m) or np.hypot(p[0] - LADO / 2, p[1] - LADO * 0.42) < R
    else:
        dentro = None
    n = int(rng.integers(45, 110))
    pts = puntos_relajados(rng, n, caja, dentro=dentro)
    grueso = LINEA * 1.6
    for poly in celdas(pts, caja):
        if len(poly) < 3:
            continue
        lz.forma([tuple(p) for p in poly], grueso)
        if rng.random() < 0.35:
            lz.forma([tuple(p) for p in encoger(poly, 0.55)], LINEA)
    # recorte de la silueta: lo de fuera se tapa con un marco
    if forma != "cuadro":
        mascara = Image.new("L", lz.img.size, 0)
        dm = ImageDraw.Draw(mascara)
        if forma == "roseton":
            dm.ellipse([(c[0] - R) * SS, (c[1] - R) * SS, (c[0] + R) * SS, (c[1] + R) * SS], fill=255)
        else:
            cy = LADO * 0.42
            dm.ellipse([(c[0] - R) * SS, (cy - R) * SS, (c[0] + R) * SS, (cy + R) * SS], fill=255)
            dm.rectangle([m * SS, cy * SS, (LADO - m) * SS, (LADO - m) * SS], fill=255)
        blanco = Image.new("L", lz.img.size, 255)
        lz.img = Image.composite(lz.img, blanco, mascara)
        lz.d = ImageDraw.Draw(lz.img)
        if forma == "roseton":
            lz.circulo(tuple(c), R, grueso, relleno=False)
            lz.circulo(tuple(c), R * 0.16, grueso)
        else:
            cy = LADO * 0.42
            arco = [polar((c[0], cy), R, math.pi + math.pi * i / 60) for i in range(61)]
            lz.forma(arco + [(LADO - m, LADO - m), (m, LADO - m)], grueso, relleno=False)
    else:
        lz.forma([(m, m), (LADO - m, m), (LADO - m, LADO - m), (m, LADO - m)], grueso, relleno=False)


# --------------------------------------------------------------------- flores

def flor(lz, rng, c, r, tipo=None):
    tipo = tipo or rng.choice(["margarita", "dalia", "tulipan", "estrella"])
    if tipo == "tulipan":
        a = -math.pi / 2
        for desv in (-0.55, 0.55, 0.0):
            lz.forma(petalo((c[0], c[1] + r * 0.55), 0, r * 1.25, a + desv * 0.5, 0.5, 0.6))
        return
    n = int(rng.integers(6, 14)) if tipo != "estrella" else 5
    capas = 2 if tipo == "dalia" else 1
    for capa in range(capas, 0, -1):
        rr = r * (0.75 + 0.25 * capa / capas)
        for j in range(n):
            a = 2 * math.pi * j / n + (math.pi / n if capa % 2 == 0 else 0)
            punta = 0.9 if tipo == "estrella" else (0.4 if tipo == "dalia" else 0.0)
            lz.forma(petalo(c, r * 0.18, rr, a, math.pi / n * 0.95, punta))
    lz.circulo(c, r * 0.3)
    if r > 60:
        lz.circulo(c, r * 0.14, LINEA * 0.8)


def hoja(lz, base, ang, largo, ancho):
    p = polar(base, largo, ang)
    n = (math.cos(ang + math.pi / 2), math.sin(ang + math.pi / 2))
    m1 = polar(base, largo * 0.45, ang)
    izq = bezier(base, (m1[0] + n[0] * ancho, m1[1] + n[1] * ancho), (p[0] + n[0] * ancho * 0.3, p[1] + n[1] * ancho * 0.3), p, 20)
    der = bezier(p, (p[0] - n[0] * ancho * 0.3, p[1] - n[1] * ancho * 0.3), (m1[0] - n[0] * ancho, m1[1] - n[1] * ancho), base, 20)
    lz.forma(izq + der[1:])
    lz.trazo([polar(base, largo * 0.1, ang), polar(base, largo * 0.8, ang)], LINEA * 0.7)


def tallo(lz, pts, ancho):
    """Tallo con grosor (zona coloreable) en vez de una sola línea."""
    izq, der = [], []
    for i in range(len(pts)):
        p0 = pts[max(i - 1, 0)]
        p1 = pts[min(i + 1, len(pts) - 1)]
        ang = math.atan2(p1[1] - p0[1], p1[0] - p0[0]) + math.pi / 2
        w = ancho * (1.0 - 0.35 * i / len(pts))
        izq.append(polar(pts[i], w / 2, ang))
        der.append(polar(pts[i], -w / 2, ang))
    lz.forma(izq + der[::-1], LINEA * 0.9)


def jarron(lz, rng, top, bot):
    cx = LADO / 2
    tipo = rng.choice(["redondo", "alto", "copa"])
    w = LADO * (0.17 if tipo != "alto" else 0.12)
    if tipo == "redondo":
        izq = bezier((cx - w * 0.5, top), (cx - w * 1.7, top + 120), (cx - w * 1.3, bot - 40), (cx - w * 0.75, bot), 30)
    elif tipo == "alto":
        izq = bezier((cx - w * 0.8, top), (cx - w * 0.6, top + 90), (cx - w * 1.2, bot - 120), (cx - w * 0.9, bot), 30)
    else:
        izq = bezier((cx - w * 1.4, top), (cx - w * 1.3, top + 150), (cx - w * 0.3, bot - 150), (cx - w * 0.5, bot), 30)
    der = [(2 * cx - x, y) for x, y in izq[::-1]]
    lz.forma(izq + der)
    ancho_boca = abs(izq[0][0] - cx) + 18
    lz.forma([(cx - ancho_boca, top - 22), (cx + ancho_boca, top - 22), (cx + ancho_boca - 8, top + 14), (cx - ancho_boca + 8, top + 14)])
    # bandas decorativas: más zonas que colorear
    for f in [[0.35], [0.3, 0.6], [0.45, 0.62]][int(rng.integers(3))]:
        y = top + (bot - top) * f
        i = min(range(len(izq)), key=lambda k: abs(izq[k][1] - y))
        x = izq[i][0]
        borde = [(x + 4, y), (2 * cx - x - 4, y)]
        lz.trazo(borde, LINEA * 0.9)
        if rng.random() < 0.6:
            n = max(4, int((2 * cx - 2 * x) // 46))
            paso = (2 * cx - 2 * x) / n
            zz = [(x + paso * (j + 0.5), y + (26 if j % 2 else 4)) for j in range(n)]
            lz.trazo([(x + 6, y + 4)] + zz + [(2 * cx - x - 6, y + 4)], LINEA * 0.8)


def ramo(rng, lz):
    n = int(rng.integers(3, 6))
    con_jarron = rng.random() < 0.65
    cuello = (LADO / 2, LADO * 0.64) if con_jarron else (LADO / 2, LADO * 0.97)
    flores = []
    for _ in range(400):
        if len(flores) == n:
            break
        r = rng.uniform(LADO * 0.11, LADO * 0.17)
        c = (rng.uniform(LADO * 0.2, LADO * 0.8), rng.uniform(LADO * 0.15, LADO * (0.45 if con_jarron else 0.6)))
        if all(math.hypot(c[0] - f[0][0], c[1] - f[0][1]) > (r + f[1]) * 0.85 for f in flores):
            flores.append((c, r))
    for c, r in flores:
        medio = ((c[0] + cuello[0]) / 2 + rng.uniform(-80, 80), (c[1] + cuello[1]) / 2)
        pts = bezier(cuello, medio, medio, c, 30)
        for k in (len(pts) // 3, 2 * len(pts) // 3):
            ang = math.atan2(pts[k + 1][1] - pts[k][1], pts[k + 1][0] - pts[k][0])
            lado = 1 if (k + int(c[0])) % 2 else -1
            hoja(lz, pts[k], ang + math.pi + lado * 1.1, LADO * rng.uniform(0.1, 0.14), LADO * 0.045)
        tallo(lz, pts, 18)
    for c, r in sorted(flores, key=lambda f: f[0][1]):
        flor(lz, rng, c, r)
    if con_jarron:
        jarron(lz, rng, LADO * 0.62, LADO * 0.97)


def flor_grande(rng, lz):
    c = (LADO / 2, LADO / 2)
    # hojas al fondo
    nh = int(rng.integers(5, 8))
    for j in range(nh):
        a = 2 * math.pi * j / nh + rng.uniform(-0.15, 0.15)
        hoja(lz, polar(c, LADO * 0.1, a), a, LADO * 0.37, LADO * 0.07)
    capas = int(rng.integers(3, 5))
    n = int(rng.integers(8, 15))
    for i in range(capas, 0, -1):
        rr = LADO * 0.36 * (0.35 + 0.65 * i / capas)
        for j in range(n):
            a = 2 * math.pi * j / n + (math.pi / n) * (i % 2)
            lz.forma(petalo(c, rr * 0.25, rr, a, math.pi / n * 0.95, rng.choice([0.0, 0.5, 0.9])))
    lz.circulo(c, LADO * 0.07)
    for j in range(8):
        lz.circulo(polar(c, LADO * 0.045, 2 * math.pi * j / 8), LADO * 0.012, LINEA * 0.7)


def flores(rng, lz, i):
    (ramo if rng.random() < 0.6 else flor_grande)(rng, lz)


# --------------------------------------------------------------------- geometría

def flor_de_la_vida(rng, lz):
    c = (LADO / 2, LADO / 2)
    r = LADO * rng.choice([0.075, 0.09, 0.11])
    anillos = int((LADO * 0.44) // r)
    centros = set()
    for q in range(-anillos, anillos + 1):
        for s in range(-anillos, anillos + 1):
            x = c[0] + r * (q + s / 2)
            y = c[1] + r * s * math.sqrt(3) / 2
            if math.hypot(x - c[0], y - c[1]) <= r * (anillos - 1) + 1:
                centros.add((round(x, 3), round(y, 3)))
    for p in centros:
        lz.circulo(p, r, LINEA * 0.9, relleno=False)
    R = r * anillos
    lz.circulo(c, R, LINEA * 1.2, relleno=False)
    # tapa lo que queda fuera del círculo mayor
    mascara = Image.new("L", lz.img.size, 0)
    ImageDraw.Draw(mascara).ellipse([(c[0] - R) * SS, (c[1] - R) * SS, (c[0] + R) * SS, (c[1] + R) * SS], fill=255)
    lz.img = Image.composite(lz.img, Image.new("L", lz.img.size, 255), mascara)
    lz.d = ImageDraw.Draw(lz.img)
    lz.circulo(c, R, LINEA * 1.2, relleno=False)


def truchet(rng, lz):
    n = int(rng.choice([6, 8, 10]))
    t = LADO / n
    for i in range(n):
        for j in range(n):
            x, y = i * t, j * t
            if rng.random() < 0.5:
                arcos = [((x, y), 0), ((x + t, y + t), math.pi)]
            else:
                arcos = [((x + t, y), math.pi / 2), ((x, y + t), -math.pi / 2)]
            for (cx, cy), a0 in arcos:
                for f in (1 / 3, 2 / 3):
                    pts = [polar((cx, cy), t * f, a0 + math.pi / 2 * k / 16) for k in range(17)]
                    lz.trazo(pts, LINEA * 0.9)
    marco(lz)


def espiral_cuadrados(rng, lz):
    c = (LADO / 2, LADO / 2)
    lados = int(rng.choice([3, 4, 5, 6, 8]))
    lado = LADO * 0.46
    giro = rng.uniform(0.07, 0.15) * rng.choice([-1, 1])
    a = rng.uniform(0, math.pi)
    for i in range(40):
        pts = [polar(c, lado, a + 2 * math.pi * k / lados - math.pi / 2) for k in range(lados)]
        lz.forma(pts, LINEA * 0.9, relleno=False)
        lado *= math.cos(math.pi / lados) / math.cos(math.pi / lados - abs(giro))
        a += giro
        if lado < LADO * 0.09:
            break


def estrellas_islamicas(rng, lz):
    n = int(rng.choice([3, 4]))
    t = LADO / n
    for i in range(n + 1):
        lz.trazo([(i * t, 0), (i * t, LADO)], LINEA * 0.8)
        lz.trazo([(0, i * t), (LADO, i * t)], LINEA * 0.8)
    for i in range(n):
        for j in range(n):
            c = (i * t + t / 2, j * t + t / 2)
            # estrella de 8 puntas = dos cuadrados girados, con octógono y rosa dentro
            for a0 in (0, math.pi / 4):
                lz.forma([polar(c, t * 0.46, a0 + k * math.pi / 2) for k in range(4)], LINEA, relleno=False)
            lz.forma([polar(c, t * 0.3, math.pi / 8 + k * math.pi / 4) for k in range(8)], LINEA * 0.9)
            for k in range(8):
                lz.forma(petalo(c, t * 0.05, t * 0.27, k * math.pi / 4, math.pi / 8 * 0.9, 0.8), LINEA * 0.8)
            lz.circulo(c, t * 0.06, LINEA * 0.8)
    marco(lz)


def escamas(rng, lz):
    """Escamas: semicírculos hacia abajo; se pinta de abajo arriba y cada fila
    tapa la parte alta de la de debajo, como tejas."""
    r = LADO / rng.choice([7, 9, 11])
    doble = rng.random() < 0.6
    fila = 0
    y = LADO + r
    while y > -2 * r:
        x = -r * 2 + (r if fila % 2 else 0)
        while x < LADO + 2 * r:
            abajo = [polar((x, y), r, math.pi * k / 24) for k in range(25)]
            lz.forma(abajo + [(x - r, y - r * 1.5), (x + r, y - r * 1.5)], LINEA * 0.9)
            if doble:
                lz.trazo([polar((x, y), r * 0.6, math.pi * k / 24) for k in range(25)], LINEA * 0.8)
            x += 2 * r
        y -= r * 0.7
        fila += 1
    marco(lz)


def hexagonos(rng, lz):
    r = LADO / rng.choice([7, 9, 11])
    h = r * math.sqrt(3)
    fila = 0
    y = -h
    while y < LADO + h:
        x = -r * 2 + (1.5 * r if fila % 2 else 0)
        while x < LADO + 2 * r:
            c = (x, y)
            lz.forma([polar(c, r, k * math.pi / 3) for k in range(6)], LINEA)
            estilo = (fila + int(x // (3 * r))) % 3
            if estilo == 0:
                lz.forma([polar(c, r * 0.55, k * math.pi / 3 + math.pi / 6) for k in range(6)], LINEA * 0.8)
            elif estilo == 1:
                for a0 in (0, math.pi / 3):
                    lz.forma([polar(c, r * 0.62, a0 + k * 2 * math.pi / 3 + math.pi / 6) for k in range(3)], LINEA * 0.8, relleno=False)
            else:
                lz.circulo(c, r * 0.5, LINEA * 0.8)
            x += 3 * r
        y += h / 2
        fila += 1
    marco(lz)


def ondas(rng, lz):
    centros = [(rng.uniform(0.15, 0.85) * LADO, rng.uniform(0.15, 0.85) * LADO) for _ in range(int(rng.integers(2, 4)))]
    paso = LADO * rng.uniform(0.1, 0.14)
    for c in centros:
        r = paso
        while r < LADO * 1.2:
            lz.circulo(c, r, LINEA * 0.9, relleno=False)
            r += paso
    marco(lz)


def marco(lz):
    m = LINEA * 1.5
    lz.forma([(m, m), (LADO - m, m), (LADO - m, LADO - m), (m, LADO - m)], LINEA * 2, relleno=False)


def geometria(rng, lz, i):
    GEOMETRIAS[i % len(GEOMETRIAS)](rng, lz)


GEOMETRIAS = [flor_de_la_vida, truchet, espiral_cuadrados, estrellas_islamicas, escamas, hexagonos, ondas]


# --------------------------------------------------------------------- salida

def fachadas(rng, lz, i):
    from dibujos.arquitectura import fachada   # import aquí: dibujos importa este módulo
    fachada(rng, lz, i)


CATEGORIAS = [
    ("mandalas", "Mandalas", mandala, 60),
    ("vitrales", "Vitrales", vitral, 30),
    ("flores", "Flores", flores, 30),
    ("geometria", "Geometría", geometria, 28),
    ("fachadas", "Fachadas", fachadas, 3),
]


def procesar(lz):
    """Devuelve (lineas LA, regiones RGB, mini, nº de zonas)."""
    fino = lz.img.resize((LADO, LADO), Image.LANCZOS)
    return procesar_tinta(255 - np.asarray(fino, dtype=np.int32))


def procesar_tinta(tinta):
    """Igual que procesar() a partir de la tinta (0 papel, 255 línea) a LADO x LADO."""
    linea = tinta >= UMBRAL_LINEA
    etiquetas, n = ndimage.label(~linea)                     # 4-conexas
    tam = ndimage.sum_labels(np.ones_like(etiquetas), etiquetas, index=np.arange(n + 1))
    chicas = (tam < AREA_MINIMA)
    chicas[0] = True
    if chicas.any():
        # se suman a la zona vecina (más abajo): se colorean junto con ella
        etiquetas = np.where(chicas[etiquetas], 0, etiquetas)
    # renumerar 1..k
    vivos = np.unique(etiquetas[etiquetas > 0])
    mapa = np.zeros(n + 1, dtype=np.int32)
    mapa[vivos] = np.arange(1, len(vivos) + 1)
    etiquetas = mapa[etiquetas]
    k = len(vivos)
    if k > MAX_ZONAS:
        raise ValueError("demasiadas zonas: %d" % k)
    # los píxeles de línea toman la zona más cercana: el color llega bajo la línea
    _, (iy, ix) = ndimage.distance_transform_edt(etiquetas == 0, return_indices=True)
    etiquetas = etiquetas[iy, ix]
    reg = np.zeros((LADO, LADO, 3), dtype=np.uint8)
    reg[..., 0] = etiquetas & 255
    reg[..., 1] = etiquetas >> 8
    lineas = np.zeros((LADO, LADO, 2), dtype=np.uint8)     # gris + alfa: negro con alfa
    # 4 niveles de alfa: se ve igual y ocupa una quinta parte (las láminas van en el APK)
    lineas[..., 1] = (np.round(tinta.clip(0, 255) / 85.0) * 85).astype(np.uint8)
    lin_img = Image.fromarray(lineas, "LA")
    mini = Image.fromarray((255 - tinta.clip(0, 255)).astype(np.uint8), "L").resize((MINI, MINI), Image.LANCZOS)
    return lin_img, Image.fromarray(reg, "RGB"), mini, k


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--salida", default=os.path.join(RAIZ, "datos", "laminas"))
    ap.add_argument("--solo", default="")
    ap.add_argument("--cuantas", type=int, default=0)
    args = ap.parse_args()
    # Se conserva el resto del índice (otras categorías e ilustraciones importadas):
    # solo se reemplazan las láminas hechas por código de lo que se regenera.
    ruta_indice = os.path.join(args.salida, "indice.json")
    indice = {"version": 1, "lado": LADO, "categorias": []}
    if os.path.exists(ruta_indice):
        indice = json.load(open(ruta_indice, encoding="utf-8"))
    por_id = {c["id"]: c for c in indice["categorias"]}
    for cid, nombre, gen, cuantas in CATEGORIAS:
        if args.solo and cid != args.solo:
            continue
        cuantas = args.cuantas or cuantas
        os.makedirs(os.path.join(args.salida, cid), exist_ok=True)
        cat = por_id.get(cid)
        if cat is None:
            cat = {"id": cid, "nombre": nombre, "laminas": []}
            indice["categorias"].append(cat)
        cat["laminas"] = [l for l in cat["laminas"] if "_i" in l["id"]]   # deja las ilustradas
        for i in range(cuantas):
            lid = "%s_%03d" % (cid, i + 1)
            rng = np.random.default_rng(zlib.crc32(lid.encode()))
            lz = Lienzo()
            gen(rng, lz, i)
            lineas, reg, mini, k = procesar(lz)
            base = os.path.join(args.salida, cid, lid)
            lineas.save(base + "_lineas.png", optimize=True)
            reg.save(base + "_regiones.png", optimize=True)
            import zonas                       # aquí: zonas.py importa este módulo
            zonas.guardar(base + "_regiones.png", k)
            mini.save(base + "_mini.png", optimize=True)
            cat["laminas"].append({"id": lid, "zonas": k})
            print("%s: %d zonas" % (lid, k), file=sys.stderr)
    with open(ruta_indice, "w", encoding="utf-8") as f:
        json.dump(indice, f, ensure_ascii=False, indent=1)


if __name__ == "__main__":
    main()
