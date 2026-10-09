"""Dibujos (animales, frutas, objetos, formas) y sus variantes de lámina.

Un dibujo es una función que recibe una Pluma y la usa en una caja de 0..1000
(y hacia abajo). La Pluma solo graba las figuras; luego se reproducen en el
lienzo a la escala y posición que pida cada variante:

  sencilla  el dibujo con un fondo según su sitio (tierra, agua, aire)
  patron    el interior del dibujo relleno de un patrón (vitral, escamas...),
            al estilo de los libros de colorear para adultos

Reglas para escribir dibujos:
  - se pintan de atrás hacia delante: lo último tapa a lo anterior
  - forma(..., solido=True) para ojos y detalles que el patrón no debe cruzar
  - forma(..., negro=True) para pupilas y narices rellenas de negro
"""
import math

import numpy as np
from PIL import Image, ImageDraw

from laminas import LADO, LINEA, SS, Lienzo, bezier, celdas, circulo, encoger, polar


class Pluma:
    def __init__(self):
        self.figuras = []   # (tipo, puntos, grosor, relleno, solido, negro)

    def forma(self, pts, g=1.0, relleno=True, solido=False, negro=False):
        self.figuras.append(("forma", list(pts), g, relleno, solido or negro, negro))

    def trazo(self, pts, g=1.0):
        self.figuras.append(("trazo", list(pts), g, False, False, False))

    def circulo(self, c, r, **kw):
        self.forma(circulo(c, r, max(24, int(r * 0.5))), **kw)

    def elipse(self, c, rx, ry, rot=0.0, **kw):
        n = max(28, int(max(rx, ry) * 0.5))
        ca, sa = math.cos(rot), math.sin(rot)
        pts = []
        for i in range(n):
            t = 2 * math.pi * i / n
            x, y = rx * math.cos(t), ry * math.sin(t)
            pts.append((c[0] + x * ca - y * sa, c[1] + x * sa + y * ca))
        self.forma(pts, **kw)

    def cinta(self, pts, ancho, final=None, **kw):
        """Tira con grosor a lo largo de una línea (colas, tallos, patas)."""
        final = ancho if final is None else final
        izq, der = [], []
        for i in range(len(pts)):
            a = pts[max(i - 1, 0)]
            b = pts[min(i + 1, len(pts) - 1)]
            ang = math.atan2(b[1] - a[1], b[0] - a[0]) + math.pi / 2
            w = (ancho + (final - ancho) * i / max(len(pts) - 1, 1)) / 2
            izq.append(polar(pts[i], w, ang))
            der.append(polar(pts[i], -w, ang))
        self.forma(izq + der[::-1], **kw)

    def poligono(self, c, r, lados, giro=0.0, **kw):
        self.forma([polar(c, r, giro + 2 * math.pi * i / lados) for i in range(lados)], **kw)

    def ojo(self, c, r, mirada=(0.0, 0.15)):
        self.circulo(c, r, solido=True)
        p = (c[0] + mirada[0] * r, c[1] + mirada[1] * r)
        self.circulo(p, r * 0.55, negro=True)
        self.circulo((p[0] - r * 0.2, p[1] - r * 0.22), r * 0.16, solido=True, g=0.4)

    def ojo_feliz(self, c, r):
        """Ojo cerrado sonriente: un arco."""
        self.trazo([polar(c, r, math.pi + math.pi * k / 12) for k in range(13)], 1.1)

    def sonrisa(self, c, ancho, alto=None):
        alto = alto if alto is not None else ancho * 0.45
        self.trazo(bezier((c[0] - ancho, c[1]), (c[0] - ancho * 0.5, c[1] + alto), (c[0] + ancho * 0.5, c[1] + alto), (c[0] + ancho, c[1])), 1.0)


def camino(*p, n=24):
    """Curva cúbica por tramos: p0, c1, c2, p1, c1, c2, p2..."""
    if (len(p) - 1) % 3:
        raise ValueError("camino necesita 1 + 3k puntos, tiene %d" % len(p))
    pts = [p[0]]
    for i in range(0, len(p) - 1, 3):
        pts += bezier(p[i], p[i + 1], p[i + 2], p[i + 3], n)[1:]
    return pts


def espejo(pts, eje=500):
    return [(2 * eje - x, y) for x, y in pts]


def simetrico(mitad, eje=500):
    """Contorno simétrico a partir de su mitad izquierda (de arriba abajo)."""
    return mitad + espejo(mitad, eje)[::-1]


# --------------------------------------------------------------------- reproducir

def _caja_de(figuras):
    xs = [x for f in figuras for x, _ in f[1]]
    ys = [y for f in figuras for _, y in f[1]]
    return min(xs), min(ys), max(xs), max(ys)


def _transformacion(figuras, caja):
    x0, y0, x1, y1 = _caja_de(figuras)
    cx0, cy0, cx1, cy1 = caja
    k = min((cx1 - cx0) / (x1 - x0), (cy1 - cy0) / (y1 - y0))
    ox = cx0 + ((cx1 - cx0) - (x1 - x0) * k) / 2 - x0 * k
    oy = cy0 + ((cy1 - cy0) - (y1 - y0) * k) / 2 - y0 * k
    return k, ox, oy


def reproducir(pluma, lz, caja, abajo=False):
    """Pinta el dibujo encajado en `caja` (abajo=True lo apoya en el borde inferior)."""
    k, ox, oy = _transformacion(pluma.figuras, caja)
    if abajo:
        oy += caja[3] - (_caja_de(pluma.figuras)[3] * k + oy)
    grosor = min(1.0, max(0.75, k * 1.1))
    for tipo, pts, g, relleno, _solido, negro in pluma.figuras:
        q = [(x * k + ox, y * k + oy) for x, y in pts]
        if tipo == "forma":
            lz.forma(q, LINEA * g * grosor, relleno, negro)
        else:
            lz.trazo(q, LINEA * g * grosor)
    return k, ox, oy


def mascaras(pluma, transf):
    """(silueta, sólidos) a 4x: dónde va el patrón y dónde no."""
    k, ox, oy = transf
    sil = Image.new("L", (LADO * SS, LADO * SS), 0)
    sol = Image.new("L", (LADO * SS, LADO * SS), 0)
    ds, dd = ImageDraw.Draw(sil), ImageDraw.Draw(sol)
    for tipo, pts, g, relleno, solido, _negro in pluma.figuras:
        q = [((x * k + ox) * SS, (y * k + oy) * SS) for x, y in pts]
        if tipo == "forma" and relleno:
            ds.polygon(q, fill=255)
            (dd.polygon(q, fill=255) if solido else dd.polygon(q, fill=0))
    return np.asarray(sil) > 0, np.asarray(sol) > 0


# --------------------------------------------------------------------- fondos

def nube(lz, c, w):
    pts = []
    bultos = [(-0.55, 0.05, 0.32), (-0.25, -0.18, 0.4), (0.15, -0.25, 0.45), (0.5, -0.02, 0.33)]
    contorno = []
    for i in range(72):
        a = 2 * math.pi * i / 72
        p = (math.cos(a) * w * 0.75, math.sin(a) * w * 0.3)
        for bx, by, br in bultos:
            q = (bx * w + math.cos(a) * br * w, by * w + math.sin(a) * br * w)
            if math.hypot(q[0], q[1] * 1.6) > math.hypot(p[0], p[1] * 1.6):
                p = q
        contorno.append((c[0] + p[0], c[1] + p[1]))
    lz.forma(contorno)


def sol(lz, c, r):
    for j in range(12):
        a = 2 * math.pi * j / 12
        lz.forma([polar(c, r * 1.2, a - 0.13), polar(c, r * 1.75, a), polar(c, r * 1.2, a + 0.13)], LINEA * 0.9)
    lz.circulo(c, r)


def fondo(lz, rng, sitio):
    if sitio == "tierra":
        sol(lz, (LADO * 0.84, LADO * 0.14), LADO * 0.06)
        nube(lz, (LADO * 0.2, LADO * 0.15), LADO * 0.13)
        nube(lz, (LADO * 0.56, LADO * 0.09), LADO * 0.09)
        y = LADO * 0.86
        lz.forma([(-10, y)] + [(x, y + 18 * math.sin(x / 140.0 + rng.uniform(0, 1))) for x in range(0, LADO + 20, 20)] + [(LADO + 10, y), (LADO + 10, LADO + 10), (-10, LADO + 10)])
        for _ in range(7):
            x, yy = rng.uniform(40, LADO - 40), rng.uniform(LADO * 0.9, LADO * 0.97)
            for d in (-1, 0, 1):
                lz.trazo([(x + d * 10, yy), (x + d * 22, yy - 26 - 8 * (d == 0))], LINEA * 0.7)
    elif sitio == "agua":
        for _ in range(9):
            c = (rng.uniform(50, LADO - 50), rng.uniform(50, LADO * 0.8))
            r = rng.uniform(12, 34)
            lz.circulo(c, r, LINEA * 0.8)
            lz.trazo([polar(c, r * 0.6, math.pi * (1.1 + 0.3 * k / 6)) for k in range(7)], LINEA * 0.6)
        for j in range(5):
            x = LADO * (0.08 + 0.21 * j) + rng.uniform(-30, 30)
            alto = rng.uniform(LADO * 0.18, LADO * 0.32)
            izq = [(x - 18 + 26 * math.sin(t / 3.0), LADO - t * alto / 12) for t in range(13)]
            der = [(x + 18 + 26 * math.sin(t / 3.0), LADO - t * alto / 12) for t in range(13)]
            lz.forma(izq + der[::-1], LINEA * 0.8)
        lz.forma([(-10, LADO * 0.93)] + [(x, LADO * 0.93 + 10 * math.sin(x / 90.0)) for x in range(0, LADO + 20, 20)] + [(LADO + 10, LADO + 10), (-10, LADO + 10)])
    elif sitio == "aire":
        sol(lz, (LADO * 0.18, LADO * 0.16), LADO * 0.06)
        for c, w in [((LADO * 0.72, LADO * 0.14), 0.15), ((LADO * 0.18, LADO * 0.8), 0.12), ((LADO * 0.8, LADO * 0.85), 0.14)]:
            nube(lz, c, LADO * w)
    else:
        decorado(lz, rng)


def estrella_pts(c, r, puntas=5, interior=0.45, giro=-math.pi / 2):
    return [polar(c, r if i % 2 == 0 else r * interior, giro + math.pi * i / puntas) for i in range(puntas * 2)]


def decorado(lz, rng):
    """Fondo para dibujos sin sitio: rayos, confeti de formas o anillos."""
    c = (LADO / 2, LADO / 2)
    tipo = int(rng.integers(3))
    if tipo == 0:
        n = int(rng.choice([16, 20, 24]))
        for j in range(n):
            a = 2 * math.pi * j / n
            lz.trazo([polar(c, LADO * 0.1, a), polar(c, LADO, a)], LINEA * 0.9)
    elif tipo == 1:
        puestos = []
        for _ in range(400):
            if len(puestos) > 26:
                break
            q = (rng.uniform(60, LADO - 60), rng.uniform(60, LADO - 60))
            if math.hypot(q[0] - c[0], q[1] - c[1]) < LADO * 0.3:
                continue
            if all(math.hypot(q[0] - o[0], q[1] - o[1]) > 110 for o in puestos):
                puestos.append(q)
                r = rng.uniform(22, 38)
                f = int(rng.integers(3))
                if f == 0:
                    lz.forma(estrella_pts(q, r, 5, 0.45, rng.uniform(0, 6)), LINEA * 0.8)
                elif f == 1:
                    lz.circulo(q, r * 0.8, LINEA * 0.8)
                else:
                    lz.forma([polar(q, r, rng.uniform(0, 1) + k * math.pi / 2) for k in range(4)], LINEA * 0.8)
    else:
        r = LADO * 0.47
        while r > LADO * 0.2:
            lz.circulo(c, r, LINEA * 0.9, relleno=False)
            r -= LADO * 0.06
    m = LINEA * 1.5
    lz.forma([(m, m), (LADO - m, m), (LADO - m, LADO - m), (m, LADO - m)], LINEA * 2, relleno=False)


# --------------------------------------------------------------------- patrones

def patron_vitral(lz, rng, caja, silueta):
    x0, y0, x1, y1 = caja
    area = max(1.0, silueta.sum() / SS ** 2)
    n = int(np.clip(area / 9000, 18, 90))
    pts = rng.uniform([x0, y0], [x1, y1], size=(n * 4, 2))
    dentro = [p for p in pts if silueta[min(int(p[1] * SS), LADO * SS - 1), min(int(p[0] * SS), LADO * SS - 1)]]
    pts = np.array(dentro[:n]) if len(dentro) >= 4 else pts[:n]
    for poly in celdas(pts, (x0 - 5, y0 - 5, x1 + 5, y1 + 5)):
        if len(poly) >= 3:
            lz.forma([tuple(p) for p in poly], LINEA * 0.8, relleno=False)


def patron_escamas(lz, rng, caja, silueta):
    r = rng.uniform(34, 52)
    y = LADO + r
    fila = 0
    while y > -2 * r:
        x = -r * 2 + (r if fila % 2 else 0)
        while x < LADO + 2 * r:
            lz.forma([polar((x, y), r, math.pi * k / 16) for k in range(17)] + [(x - r, y - r * 1.5), (x + r, y - r * 1.5)], LINEA * 0.7)
            x += 2 * r
        y -= r * 0.7
        fila += 1


def patron_ondas(lz, rng, caja, silueta):
    paso = rng.uniform(38, 56)
    amp = paso * 0.35
    fase = rng.uniform(0, 6)
    y = -paso
    while y < LADO + paso:
        lz.trazo([(x, y + amp * math.sin(x / 45.0 + fase + y / 90.0)) for x in range(-20, LADO + 40, 16)], LINEA * 0.7)
        y += paso


def patron_rombos(lz, rng, caja, silueta):
    paso = rng.uniform(70, 100)
    for i in range(-LADO // 40, LADO // 40):
        b = i * paso
        lz.trazo([(0, b), (LADO, b + LADO)], LINEA * 0.7)
        lz.trazo([(0, b + LADO), (LADO, b)], LINEA * 0.7)


def patron_circulos(lz, rng, caja, silueta):
    x0, y0, x1, y1 = caja
    c = ((x0 + x1) / 2 + rng.uniform(-60, 60), (y0 + y1) / 2 + rng.uniform(-60, 60))
    paso = rng.uniform(34, 50)
    r = paso
    while r < LADO:
        lz.circulo(c, r, LINEA * 0.7, relleno=False)
        r += paso
    for j in range(16):
        a = 2 * math.pi * j / 16
        lz.trazo([polar(c, paso, a), polar(c, LADO, a)], LINEA * 0.7)


def patron_hexagonos(lz, rng, caja, silueta):
    r = rng.uniform(40, 60)
    h = r * math.sqrt(3)
    fila = 0
    y = -h
    while y < LADO + h:
        x = -r * 2 + (1.5 * r if fila % 2 else 0)
        while x < LADO + 2 * r:
            lz.forma([polar((x, y), r, k * math.pi / 3) for k in range(6)], LINEA * 0.7, relleno=False)
            x += 3 * r
        y += h / 2
        fila += 1


PATRONES = [patron_vitral, patron_escamas, patron_ondas, patron_rombos, patron_circulos, patron_hexagonos]


# --------------------------------------------------------------------- variantes

CAJA = (LADO * 0.1, LADO * 0.12, LADO * 0.9, LADO * 0.86)


def sencilla(rng, lz, dibujo, sitio):
    fondo(lz, rng, sitio)
    p = Pluma()
    dibujo(p)
    caja = (LADO * 0.12, LADO * 0.18, LADO * 0.88, LADO * 0.92) if sitio == "tierra" else CAJA
    reproducir(p, lz, caja, abajo=(sitio == "tierra"))


def con_patron(rng, lz, dibujo, patron):
    """El dibujo grande con el patrón dentro de su silueta."""
    p = Pluma()
    dibujo(p)
    caja = (LADO * 0.06, LADO * 0.06, LADO * 0.94, LADO * 0.94)
    transf = reproducir(p, lz, caja)
    silueta, solidos = mascaras(p, transf)
    k, ox, oy = transf
    x0, y0, x1, y1 = _caja_de(p.figuras)
    caja_real = (x0 * k + ox, y0 * k + oy, x1 * k + ox, y1 * k + oy)
    pat = Lienzo()
    patron(pat, rng, caja_real, silueta)
    # el patrón solo dentro de la silueta (encogida un poco) y fuera de los sólidos
    from scipy import ndimage
    dentro = ndimage.binary_erosion(silueta, iterations=int(LINEA * SS)) & ~ndimage.binary_dilation(solidos, iterations=int(LINEA * SS))
    base = np.asarray(lz.img)
    trama = np.asarray(pat.img)
    lz.img = Image.fromarray(np.where(dentro, np.minimum(base, trama), base).astype(np.uint8), "L")
    lz.d = ImageDraw.Draw(lz.img)
    m = LINEA * 1.5
    lz.forma([(m, m), (LADO - m, m), (LADO - m, LADO - m), (m, LADO - m)], LINEA * 2, relleno=False)
