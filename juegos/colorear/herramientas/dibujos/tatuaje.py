"""Animales al estilo de los diseños de tatuaje, convertidos en lámina.

Cada animal es una silueta (una o varias partes cerradas) y unos detalles
(ojos, nariz, líneas). Sobre esa base hay dos estilos:

  geometrico   la silueta partida en facetas (triangulación simétrica) dentro
               de un marco de geometría sagrada
  ornamental   la silueta partida en franjas onduladas, cada una con su patrón
               (escamas, puntos, rayas...), con un halo de pétalos detrás

Coordenadas en una caja de 0..1000, y hacia abajo. Los animales de frente se
escriben por su mitad izquierda y se reflejan con `simetrico`.
"""
import math

import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage
from scipy.spatial import Delaunay

from dibujos import camino, espejo, simetrico
from laminas import LADO, LINEA, SS, Lienzo, petalo, polar


# --------------------------------------------------------------------- utilidades

def cinta_pts(pts, ancho, final=None):
    final = ancho if final is None else final
    izq, der = [], []
    for i in range(len(pts)):
        a = pts[max(i - 1, 0)]
        b = pts[min(i + 1, len(pts) - 1)]
        ang = math.atan2(b[1] - a[1], b[0] - a[0]) + math.pi / 2
        w = (ancho + (final - ancho) * i / max(len(pts) - 1, 1)) / 2
        izq.append(polar(pts[i], w, ang))
        der.append(polar(pts[i], -w, ang))
    return izq + der[::-1]


def ovalo(c, rx, ry, rot=0.0, n=48):
    ca, sa = math.cos(rot), math.sin(rot)
    return [(c[0] + rx * math.cos(t) * ca - ry * math.sin(t) * sa, c[1] + rx * math.cos(t) * sa + ry * math.sin(t) * ca)
            for t in (2 * math.pi * i / n for i in range(n))]


def remuestrear(pts, paso, cerrado=True):
    q = pts + [pts[0]] if cerrado else pts
    salida = []
    for a, b in zip(q, q[1:]):
        d = math.hypot(b[0] - a[0], b[1] - a[1])
        n = max(1, int(d // paso))
        salida += [(a[0] + (b[0] - a[0]) * k / n, a[1] + (b[1] - a[1]) * k / n) for k in range(n)]
    return salida


class Animal:
    def __init__(self, partes, detalles):
        self.partes = partes          # polígonos cerrados que forman la silueta
        self.detalles = detalles      # (tipo, puntos): ojo, negro, blanco, borde, linea


class Encaje:
    """Lleva la caja 0..1000 del animal a una zona de la lámina."""

    def __init__(self, animal, caja):
        xs = [x for p in animal.partes for x, _ in p]
        ys = [y for p in animal.partes for _, y in p]
        x0, y0, x1, y1 = min(xs), min(ys), max(xs), max(ys)
        cx0, cy0, cx1, cy1 = caja
        self.k = min((cx1 - cx0) / (x1 - x0), (cy1 - cy0) / (y1 - y0))
        self.ox = (cx0 + cx1) / 2 - (x0 + x1) / 2 * self.k
        self.oy = (cy0 + cy1) / 2 - (y0 + y1) / 2 * self.k
        self.eje = 500 * self.k + self.ox

    def __call__(self, pts):
        return [(x * self.k + self.ox, y * self.k + self.oy) for x, y in pts]


def _mascara(polis, solo_relleno=True):
    m = Image.new("L", (LADO * SS, LADO * SS), 0)
    d = ImageDraw.Draw(m)
    for q in polis:
        d.polygon([(x * SS, y * SS) for x, y in q], fill=255)
    return np.asarray(m) > 0


def _componer(lz, trama, dentro):
    base = np.asarray(lz.img)
    t = np.asarray(trama.img)
    lz.img = Image.fromarray(np.where(dentro, np.minimum(base, t), base).astype(np.uint8), "L")
    lz.d = ImageDraw.Draw(lz.img)


def _dentro(m, x, y):
    i, j = int(y * SS), int(x * SS)
    return 0 <= i < m.shape[0] and 0 <= j < m.shape[1] and m[i, j]


def _pintar_base(lz, animal, enc):
    for q in animal.partes:
        lz.forma(enc(q), LINEA * 1.3)


def _pintar_detalles(lz, animal, enc):
    for tipo, pts in animal.detalles:
        q = enc(pts)
        if tipo == "ojo":
            lz.forma(q, LINEA)
            cx = sum(x for x, _ in q) / len(q)
            cy = sum(y for _, y in q) / len(q)
            r = (max(y for _, y in q) - min(y for _, y in q)) * 0.36
            lz.circulo((cx, cy), r, LINEA, relleno=False)
            lz.forma([polar((cx, cy), r * 0.55, 2 * math.pi * i / 24) for i in range(24)], LINEA * 0.5, negro=True)
        elif tipo == "negro":
            lz.forma(q, LINEA, negro=True)
        elif tipo == "blanco":
            lz.forma(q, LINEA)
        elif tipo == "borde":
            lz.forma(q, LINEA, relleno=False)
        else:
            lz.trazo(q, LINEA * 0.9)


def _solidos(animal, enc):
    return _mascara([enc(p) for t, p in animal.detalles if t in ("ojo", "negro", "blanco")])


# --------------------------------------------------------------------- estilos

def facetas(lz, rng, animal, enc, silueta, separacion=72):
    """Triangulación simétrica de la silueta (estilo low-poly)."""
    eje = enc.eje
    pts = []
    for q in animal.partes:
        pts += remuestrear(enc(q), separacion * 0.85)
    for t, q in animal.detalles:
        if t in ("ojo", "negro", "blanco", "borde"):
            pts += remuestrear(enc(q), separacion * 0.7)
    # sin puntos casi pegados: dejarían triángulos finísimos
    limpios = []
    for q in pts:
        if all((q[0] - a) ** 2 + (q[1] - b) ** 2 > (separacion * 0.35) ** 2 for a, b in limpios):
            limpios.append(q)
    pts = limpios
    ys, xs = np.nonzero(silueta[::SS * 4, ::SS * 4])
    x0, x1 = xs.min() * 4, xs.max() * 4
    y0, y1 = ys.min() * 4, ys.max() * 4
    interior = []
    for _ in range(6000):
        x, y = rng.uniform(x0, eje), rng.uniform(y0, y1)
        if not _dentro(silueta, x, y):
            continue
        if all((x - a) ** 2 + (y - b) ** 2 > separacion ** 2 for a, b in interior + pts):
            interior.append((x, y))
    pts += interior + [(2 * eje - x, y) for x, y in interior]
    tri = Delaunay(np.array(pts))
    trama = Lienzo()
    for s in tri.simplices:
        v = tri.points[s]
        c = v.mean(axis=0)
        if _dentro(silueta, c[0], c[1]):
            trama.forma([tuple(p) for p in v], LINEA * 0.75, relleno=False)
    return trama


PATRONES_FRANJA = ["escamas", "puntos", "rayas", "zigzag", "circulos", "rombos", "ondas"]


def _patron_franja(lz, rng, tipo, caja):
    x0, y0, x1, y1 = caja
    if tipo == "escamas":
        r = rng.uniform(20, 30)
        y, fila = y1 + r, 0
        while y > y0 - 2 * r:
            x = x0 - 2 * r + (r if fila % 2 else 0)
            while x < x1 + 2 * r:
                lz.forma([polar((x, y), r, math.pi * k / 12) for k in range(13)] + [(x - r, y - r * 1.5), (x + r, y - r * 1.5)], LINEA * 0.6)
                x += 2 * r
            y -= r * 0.75
            fila += 1
    elif tipo == "puntos":
        r = rng.uniform(13, 19)
        paso = r * 3
        fila = 0
        y = y0
        while y < y1 + paso:
            x = x0 + (paso / 2 if fila % 2 else 0)
            while x < x1 + paso:
                lz.circulo((x, y), r, LINEA * 0.6)
                x += paso
            y += paso * 0.87
            fila += 1
    elif tipo == "rayas":
        paso = rng.uniform(22, 32)
        d = x0 - (y1 - y0)
        while d < x1:
            lz.trazo([(d, y1), (d + (y1 - y0), y0)], LINEA * 0.6)
            d += paso
    elif tipo == "zigzag":
        paso = rng.uniform(30, 40)
        y = y0
        while y < y1 + paso:
            lz.trazo([(x, y + (paso * 0.45 if int((x - x0) / paso) % 2 else 0)) for x in np.arange(x0 - paso, x1 + paso, paso)], LINEA * 0.6)
            y += paso
    elif tipo == "circulos":
        c = ((x0 + x1) / 2, (y0 + y1) / 2)
        paso = rng.uniform(22, 30)
        r = paso
        while r < max(x1 - x0, y1 - y0):
            lz.circulo(c, r, LINEA * 0.6, relleno=False)
            r += paso
    elif tipo == "rombos":
        paso = rng.uniform(40, 56)
        for i in range(-60, 60):
            b = i * paso
            lz.trazo([(x0, y0 + b), (x1, y0 + b + (x1 - x0))], LINEA * 0.6)
            lz.trazo([(x0, y0 + b + (x1 - x0)), (x1, y0 + b)], LINEA * 0.6)
    else:
        paso = rng.uniform(24, 32)
        y = y0
        while y < y1 + paso:
            lz.trazo([(x, y + paso * 0.3 * math.sin(x / 25.0)) for x in np.arange(x0 - 10, x1 + 20, 10)], LINEA * 0.6)
            y += paso


def franjas(lz, rng, silueta, solidos, eje):
    """Parte la silueta en franjas onduladas simétricas, cada una con su patrón."""
    ys, xs = np.nonzero(silueta[::SS * 4, ::SS * 4])
    x0, x1 = xs.min() * 4, xs.max() * 4
    y0, y1 = ys.min() * 4, ys.max() * 4
    n = int(rng.integers(5, 8))
    cortes = np.linspace(y0, y1, n + 1)[1:-1]
    amp = (y1 - y0) / n * 0.35
    fase = rng.uniform(0, 3)
    curvas = []
    for i, c in enumerate(cortes):
        # simétrica respecto al eje: depende de |x - eje|
        curvas.append([(x, c + amp * math.cos(abs(x - eje) / 70.0 + fase + i)) for x in np.arange(x0 - 20, x1 + 30, 10)])
    tipos = list(rng.permutation(PATRONES_FRANJA))
    libre = ndimage.binary_erosion(silueta, iterations=int(LINEA * SS)) & ~ndimage.binary_dilation(solidos, iterations=int(LINEA * SS))
    bordes = [[(x0 - 20, y0 - 20), (x1 + 30, y0 - 20)]] + curvas + [[(x0 - 20, y1 + 20), (x1 + 30, y1 + 20)]]
    for i in range(len(bordes) - 1):
        franja = bordes[i] + bordes[i + 1][::-1]
        m = _mascara([franja]) & libre
        trama = Lienzo()
        _patron_franja(trama, rng, tipos[i % len(tipos)], (x0, y0 - amp, x1, y1 + amp))
        _componer(lz, trama, m)
    trama = Lienzo()
    for c in curvas:
        trama.trazo(c, LINEA * 1.0)
    _componer(lz, trama, ndimage.binary_erosion(silueta, iterations=2) & ~solidos)


# --------------------------------------------------------------------- fondos

def marco_sagrado(lz, rng):
    c = (LADO / 2, LADO / 2)
    R = LADO * 0.47
    lz.circulo(c, R, LINEA * 1.2, relleno=False)
    lz.circulo(c, R * 0.93, LINEA * 0.9, relleno=False)
    giro = rng.choice([0.0, math.pi])
    for g in (giro, giro + math.pi):
        lz.forma([polar(c, R * 0.93, g - math.pi / 2 + k * 2 * math.pi / 3) for k in range(3)], LINEA * 0.9, relleno=False)
    lz.circulo(c, R * 0.465, LINEA * 0.8, relleno=False)
    for k in range(6):
        q = polar(c, R * 0.93, giro - math.pi / 2 + k * math.pi / 3)
        lz.circulo(q, LADO * 0.025, LINEA * 0.8)
    for k in range(36):
        if k % 6:
            lz.circulo(polar(c, R * 0.965, 2 * math.pi * k / 36), LADO * 0.006, LINEA * 0.4, negro=True)


def halo(lz, rng):
    c = (LADO / 2, LADO / 2)
    n = int(rng.choice([16, 20, 24]))
    paso = 2 * math.pi / n
    for j in range(n):
        lz.forma(petalo(c, LADO * 0.3, LADO * 0.48, j * paso + paso / 2, paso * 0.48, 0.8), LINEA * 0.9)
    for j in range(n):
        lz.forma(petalo(c, LADO * 0.28, LADO * 0.42, j * paso, paso * 0.45, 0.3), LINEA * 0.9)
    lz.circulo(c, LADO * 0.33, LINEA)


# --------------------------------------------------------------------- láminas

def geometrico(rng, lz, animal):
    marco_sagrado(lz, rng)
    enc = Encaje(animal, (LADO * 0.13, LADO * 0.12, LADO * 0.87, LADO * 0.88))
    _pintar_base(lz, animal, enc)
    silueta = _mascara([enc(q) for q in animal.partes])
    trama = facetas(lz, rng, animal, enc, silueta)
    dentro = ndimage.binary_erosion(silueta, iterations=int(LINEA * SS * 0.8)) & ~_solidos(animal, enc)
    _componer(lz, trama, dentro)
    _pintar_detalles(lz, animal, enc)


def ornamental(rng, lz, animal):
    halo(lz, rng)
    enc = Encaje(animal, (LADO * 0.1, LADO * 0.08, LADO * 0.9, LADO * 0.92))
    _pintar_base(lz, animal, enc)
    silueta = _mascara([enc(q) for q in animal.partes])
    franjas(lz, rng, silueta, _solidos(animal, enc), enc.eje)
    _pintar_detalles(lz, animal, enc)
    m = LINEA * 1.5
    lz.forma([(m, m), (LADO - m, m), (LADO - m, LADO - m), (m, LADO - m)], LINEA * 2, relleno=False)


# --------------------------------------------------------------------- animales

def _ojo_almendra(c, ancho, alto, inclinacion=0.15):
    x, y = c
    return [(x - ancho, y + ancho * inclinacion), (x - ancho * 0.4, y - alto), (x + ancho * 0.5, y - alto * 0.8),
            (x + ancho, y), (x + ancho * 0.4, y + alto * 0.8), (x - ancho * 0.5, y + alto * 0.7)]


def _par(tipo, pts):
    return [(tipo, pts), (tipo, espejo(pts)[::-1])]


def lobo():
    cara = simetrico([(500, 300), (440, 285), (400, 250), (350, 150), (320, 60), (290, 150), (265, 250), (250, 320), (215, 345),
                      (235, 372), (165, 420), (215, 442), (145, 500), (210, 518), (155, 590), (225, 598), (190, 670), (265, 676),
                      (245, 745), (320, 752), (330, 822), (390, 832), (420, 890), (470, 905), (500, 912)])
    det = []
    det += _par("blanco", [(322, 120), (288, 262), (392, 262)])
    det += _par("ojo", _ojo_almendra((395, 465), 62, 26))
    det += _par("linea", [(310, 420), (380, 405), (440, 418), (470, 440)])
    det += _par("linea", [(455, 485), (462, 580), (470, 690)])
    det += _par("linea", [(500, 330), (480, 380), (470, 420)])
    det.append(("negro", [(440, 700), (560, 700), (545, 748), (500, 770), (455, 748)]))
    det.append(("linea", [(500, 770), (500, 808)]))
    det += _par("linea", camino((500, 808), (480, 830), (450, 838), (420, 828)))
    return Animal([cara], det)


def leon():
    melena = []
    n = 40
    for i in range(n):
        a = -math.pi / 2 + 2 * math.pi * i / n
        r = 470 if i % 2 == 0 else 385
        melena.append(polar((500, 480), r, a + (0.03 if i % 2 == 0 else 0)))
    cara = simetrico([(500, 255), (420, 262), (360, 255), (300, 300), (262, 360), (250, 440), (265, 530), (300, 610),
                      (345, 685), (400, 745), (450, 775), (500, 785)])
    det = []
    det += _par("ojo", _ojo_almendra((405, 450), 55, 24))
    det += _par("linea", [(330, 405), (400, 392), (455, 410)])
    det += _par("linea", [(458, 470), (462, 520), (455, 560)])
    det.append(("negro", [(445, 560), (555, 560), (535, 602), (500, 618), (465, 602)]))
    det += _par("borde", ovalo((462, 650), 46, 34))
    det.append(("linea", [(500, 618), (500, 660)]))
    det += _par("linea", camino((415, 720), (440, 745), (470, 752), (500, 750)))
    return Animal([melena, cara], det)


def buho():
    cuerpo = simetrico([(500, 250), (430, 240), (360, 190), (300, 80), (288, 200), (250, 280), (205, 400), (188, 520),
                        (200, 650), (240, 760), (300, 850), (380, 910), (450, 935), (500, 940)])
    det = []
    det += _par("borde", ovalo((395, 395), 125, 125))
    det += _par("borde", ovalo((395, 395), 88, 88))
    det += _par("ojo", ovalo((395, 395), 52, 52))
    det.append(("negro", [(468, 478), (532, 478), (500, 570)]))
    det += _par("borde", [(232, 470), (300, 535), (345, 660), (335, 800), (305, 865), (245, 765), (208, 610)])
    det += _par("linea", camino((240, 560), (280, 600), (310, 650), (322, 720)))
    for fila, y in enumerate((640, 700, 760, 820)):
        anchura = 130 - fila * 15
        for j in range(-2, 3):
            x = 500 + j * anchura / 2.2
            det.append(("linea", [(x - 22, y), (x, y + 22), (x + 22, y)]))
    return Animal([cuerpo], det)


def ciervo():
    cabeza = simetrico([(500, 330), (440, 332), (395, 322), (350, 300), (250, 268), (165, 300), (235, 352), (330, 382),
                        (348, 452), (368, 562), (398, 682), (428, 782), (460, 852), (500, 872)])
    cuerno = camino((430, 322), (340, 270), (250, 200), (255, 40))
    partes = [cabeza]
    for lado in (1, -1):
        def m(q):
            return q if lado == 1 else espejo(q)
        partes.insert(1, m(cinta_pts(cuerno, 40, 16)))
        for t, largo, ang in ((7, 120, -1.35), (13, 150, -1.6), (19, 110, -1.95)):
            base = cuerno[t]
            medio = polar(base, largo * 0.5, ang - 0.25)
            punta = polar(medio, largo * 0.5, ang)
            partes.insert(1, m(cinta_pts([base, medio, punta], 28, 10)))
    det = []
    det += _par("blanco", ovalo((255, 315), 62, 22, rot=0.2))
    det += _par("ojo", _ojo_almendra((402, 480), 48, 22, 0.25))
    det += _par("linea", [(455, 500), (462, 620), (470, 760)])
    det.append(("negro", ovalo((500, 800), 55, 38)))
    det.append(("linea", [(500, 838), (500, 860)]))
    return Animal(partes, det)


ANIMALES = [
    ("lobo", "Lobo", lobo),
    ("leon", "León", leon),
    ("buho", "Búho", buho),
    ("ciervo", "Ciervo", ciervo),
]
