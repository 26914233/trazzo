"""Animales de estilo étnico: la cabeza partida en segmentos que siguen la anatomía
(frente, mejillas, hocico, mechones, plumas), cada uno con doble contorno y su
propio patrón (puntos, lágrimas, escamas, rayas, anillos...).

Todo es vectorial (shapely): cada segmento se recorta por los que tiene delante,
se dibuja su borde y una línea interior paralela, y dentro se recorta un patrón.

Un animal es una lista de segmentos (de atrás hacia delante) y unos detalles
(ojos, nariz). Caja de 0..1000 y hacia abajo; de frente se escribe la mitad
izquierda y se refleja.
"""
import math

import numpy as np
from shapely import affinity
from shapely.geometry import LineString, MultiLineString, MultiPolygon, Point, Polygon
from shapely.ops import unary_union

from laminas import LADO, LINEA, Lienzo, polar

ANCHO = 1000
FINO = LINEA * 0.55
MEDIO = LINEA * 0.8
FUERTE = LINEA * 1.15


# --------------------------------------------------------------------- geometría

def poli(pts):
    p = Polygon(pts)
    return p if p.is_valid else p.buffer(0)


def espejo_geom(g, eje=500):
    return affinity.scale(g, xfact=-1, yfact=1, origin=(eje, 0))


def bezier2(p0, p1, p2, n=20):
    return [((1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0],
             (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1]) for t in (k / n for k in range(n + 1))]


def bezier3(p0, p1, p2, p3, n=24):
    return [((1 - t) ** 3 * p0[0] + 3 * (1 - t) ** 2 * t * p1[0] + 3 * (1 - t) * t * t * p2[0] + t ** 3 * p3[0],
             (1 - t) ** 3 * p0[1] + 3 * (1 - t) ** 2 * t * p1[1] + 3 * (1 - t) * t * t * p2[1] + t ** 3 * p3[1])
            for t in (k / n for k in range(n + 1))]


def mechon(base, ang, largo, ancho, curva=0.0, n=26, caida=0.0):
    """Mechón (o pluma) con forma de llama: espina en S, ancho que crece y
    termina en punta. `caida` lo dobla hacia abajo (gravedad)."""
    c1 = polar(base, largo * 0.35, ang - curva)
    medio = polar(base, largo * 0.65, ang + curva * 0.5)
    fin = polar(base, largo, ang + curva * 1.4)
    fin = (fin[0], fin[1] + caida * largo)
    c2 = (medio[0], medio[1] + caida * largo * 0.4)
    espina = bezier3(base, c1, c2, fin, n)
    izq, der = [], []
    for i, p in enumerate(espina):
        t = i / n
        a = espina[max(i - 1, 0)]
        b = espina[min(i + 1, n)]
        normal = math.atan2(b[1] - a[1], b[0] - a[0]) + math.pi / 2
        if t < 0.3:
            f = 0.35 + 0.65 * math.sin(t / 0.3 * math.pi / 2)
        elif t < 0.6:
            f = 1.0
        else:
            f = max(0.0, math.cos((t - 0.6) / 0.4 * math.pi / 2)) ** 1.1
        w = ancho / 2 * f
        izq.append(polar(p, w, normal))
        der.append(polar(p, -w, normal))
    return poli(izq + der[::-1]), LineString(espina)


def ovalo(c, rx, ry, rot=0.0, n=60):
    ca, sa = math.cos(rot), math.sin(rot)
    return poli([(c[0] + rx * math.cos(t) * ca - ry * math.sin(t) * sa, c[1] + rx * math.cos(t) * sa + ry * math.sin(t) * ca)
                 for t in (2 * math.pi * i / n for i in range(n))])


def almendra(c, ancho, alto, inclinacion=0.0, n=40):
    pts = []
    for i in range(n):
        t = 2 * math.pi * i / n
        x = math.cos(t) * ancho
        y = math.sin(t) * alto * (1 - 0.35 * math.cos(t))
        pts.append((c[0] + x, c[1] + y + x * inclinacion))
    return poli(pts)


# --------------------------------------------------------------------- dibujar

def trazar(lz, g, grosor=FINO, relleno=False, negro=False):
    if g is None or g.is_empty:
        return
    if isinstance(g, (MultiPolygon, MultiLineString)) or g.geom_type == "GeometryCollection":
        for h in g.geoms:
            trazar(lz, h, grosor, relleno, negro)
    elif g.geom_type == "Polygon":
        lz.forma(list(g.exterior.coords)[:-1], grosor, relleno, negro)
        for hueco in g.interiors:
            lz.forma(list(hueco.coords)[:-1], grosor, False)
    elif g.geom_type in ("LineString", "LinearRing"):
        lz.trazo(list(g.coords), grosor)


# --------------------------------------------------------------------- patrones

def _rejilla_hex(caja, paso):
    x0, y0, x1, y1 = caja
    fila = 0
    y = y0
    while y < y1 + paso:
        x = x0 + (paso / 2 if fila % 2 else 0)
        while x < x1 + paso:
            yield x, y
            x += paso
        y += paso * 0.866
        fila += 1


def p_puntos(zona, rng):
    paso = rng.uniform(22, 32)
    r = paso * rng.uniform(0.22, 0.32)
    return [Point(q).buffer(r, 12) for q in _rejilla_hex(zona.bounds, paso) if zona.contains(Point(q).buffer(r + 2))]


def p_rayas(zona, rng, ang=None):
    paso = rng.uniform(13, 20)
    ang = rng.uniform(0, math.pi) if ang is None else ang
    x0, y0, x1, y1 = zona.bounds
    c = ((x0 + x1) / 2, (y0 + y1) / 2)
    L = math.hypot(x1 - x0, y1 - y0)
    lineas = []
    d = -L / 2
    while d < L / 2:
        p = polar(c, d, ang + math.pi / 2)
        lineas.append(LineString([polar(p, -L, ang), polar(p, L, ang)]).intersection(zona))
        d += paso
    return lineas


def p_anillos(zona, rng):
    paso = rng.uniform(10, 15)
    salida = []
    z = zona.buffer(-paso)
    while not z.is_empty and z.area > 120:
        salida.append(z.boundary)
        z = z.buffer(-paso)
    return salida


def p_anillos_puntos(zona, rng):
    """Una línea paralela al borde y una fila de puntos dentro; el resto vacío."""
    salida = []
    z1 = zona.buffer(-10)
    if z1.is_empty:
        return salida
    salida.append(z1.boundary)
    z2 = zona.buffer(-24)
    if z2.is_empty or z2.length < 30:
        return salida
    r = 5.5
    for borde in (getattr(z2, "geoms", [z2])):
        largo = borde.exterior.length
        n = int(largo // 22)
        for k in range(n):
            q = borde.exterior.interpolate(k * largo / max(n, 1))
            salida.append(q.buffer(r, 10))
    z3 = zona.buffer(-38)
    if not z3.is_empty:
        salida.append(z3.boundary)
    return salida


def p_escamas(zona, rng):
    r = rng.uniform(13, 19)
    x0, y0, x1, y1 = zona.bounds
    piezas = []
    fila = 0
    y = y1 + r
    while y > y0 - 2 * r:
        x = x0 - 2 * r + (r if fila % 2 else 0)
        while x < x1 + 2 * r:
            piezas.append(LineString([polar((x, y), r, math.pi * k / 12) for k in range(13)]).intersection(zona))
            x += 2 * r
        y -= r * 0.8
        fila += 1
    return piezas


def p_lagrimas(zona, rng):
    paso = rng.uniform(30, 42)
    ang = rng.uniform(0, math.pi)
    salida = []
    for q in _rejilla_hex(zona.bounds, paso):
        g = affinity.rotate(poli(_lagrima_pts(paso * 0.34)), ang, origin=(0, 0), use_radians=True)
        g = affinity.translate(g, q[0], q[1])
        if zona.contains(g.buffer(2)):
            salida.append(g)
    return salida


def _lagrima_pts(r, n=20):
    pts = []
    for i in range(n):
        t = 2 * math.pi * i / n
        pts.append((r * math.cos(t), r * math.sin(t) * (1 - math.cos(t)) * 0.6))
    return pts


def p_zigzag(zona, rng):
    paso = rng.uniform(16, 24)
    x0, y0, x1, y1 = zona.bounds
    salida = []
    y = y0
    while y < y1 + paso:
        pts = [(x, y + (paso * 0.55 if int(round((x - x0) / paso)) % 2 else 0)) for x in np.arange(x0 - paso, x1 + 2 * paso, paso)]
        salida.append(LineString(pts).intersection(zona))
        y += paso
    return salida


def p_rombos(zona, rng):
    a = rng.uniform(0, math.pi / 2)
    return p_rayas(zona, rng, a) + p_rayas(zona, rng, a + math.pi / 2)


def p_circulos(zona, rng):
    paso = rng.uniform(26, 36)
    salida = []
    for q in _rejilla_hex(zona.bounds, paso):
        c = Point(q)
        if zona.contains(c.buffer(paso * 0.45)):
            salida.append(c.buffer(paso * 0.42, 14).boundary)
            salida.append(c.buffer(paso * 0.16, 10))
    return salida


def p_vacio(zona, rng):
    return []


PATRONES = {
    "puntos": p_puntos, "rayas": p_rayas, "anillos": p_anillos, "anillos_puntos": p_anillos_puntos,
    "escamas": p_escamas, "lagrimas": p_lagrimas, "zigzag": p_zigzag, "rombos": p_rombos,
    "circulos": p_circulos, "vacio": p_vacio,
}


# --------------------------------------------------------------------- composición

def _perpendiculares(espina, zona, paso, largo=200):
    salida = []
    L = espina.length
    k = paso
    while k < L - paso * 0.5:
        a = espina.interpolate(k - 1)
        b = espina.interpolate(k + 1)
        ang = math.atan2(b.y - a.y, b.x - a.x) + math.pi / 2
        q = (espina.interpolate(k).x, espina.interpolate(k).y)
        salida.append(LineString([polar(q, -largo, ang), polar(q, largo, ang)]).intersection(zona))
        k += paso
    return salida


def deco_puntos(vis, espina, rng):
    esp = espina.intersection(vis.buffer(-12))
    salida = [esp]
    n = int(espina.length // 26)
    for j in range(1, n):
        q = espina.interpolate(j * espina.length / n)
        if vis.buffer(-14).contains(q):
            salida.append(("negro", q.buffer(4.5, 8)))
    return salida


def deco_bandas(vis, espina, rng):
    """Rayas de lado a lado del mechón, en grupos (como franjas de piel)."""
    zona = vis.buffer(-10)
    salida = []
    grupo = int(rng.integers(2, 4))
    lineas = _perpendiculares(espina, zona, 15)
    for j, l in enumerate(lineas):
        if (j // grupo) % 2 == 0:
            salida.append(l)
    return salida


def deco_chevrones(vis, espina, rng):
    zona = vis.buffer(-10)
    salida = []
    L = espina.length
    k = 30.0
    while k < L - 20:
        a = espina.interpolate(k - 1)
        b = espina.interpolate(k + 1)
        ang = math.atan2(b.y - a.y, b.x - a.x)
        q = (espina.interpolate(k).x, espina.interpolate(k).y)
        v = [polar(q, 60, ang + math.pi * 0.78), q, polar(q, 60, ang - math.pi * 0.78)]
        salida.append(LineString(v).intersection(zona))
        k += 24
    return salida


def deco_linea_y_triangulos(vis, espina, rng):
    zona = vis.buffer(-10)
    salida = [espina.intersection(zona)]
    L = espina.length
    k = 24.0
    while k < L - 30:
        a = espina.interpolate(k - 1)
        b = espina.interpolate(k + 1)
        ang = math.atan2(b.y - a.y, b.x - a.x)
        q = (espina.interpolate(k).x, espina.interpolate(k).y)
        for lado in (-1, 1):
            t = poli([polar(q, 6, ang + lado * math.pi / 2), polar(q, 22, ang + lado * math.pi / 2), polar(polar(q, 14, ang + lado * math.pi / 2), 10, ang)])
            if zona.contains(t):
                salida.append(t)
        k += 26
    return salida


DECOS = [deco_puntos, deco_bandas, deco_chevrones, deco_linea_y_triangulos]


class Segmento:
    def __init__(self, geom, patron=None, espina=None, doble=True, deco=None):
        self.geom = geom
        self.patron = patron       # nombre de PATRONES o None (al azar)
        self.espina = espina       # línea central (mechones/plumas)
        self.doble = doble
        self.deco = deco           # índice en DECOS para mechones (None: al azar)


def simetricos(segmentos, eje=500):
    """Añade el reflejo de cada segmento (con el mismo patrón)."""
    salida = []
    for s in segmentos:
        salida.append(s)
        salida.append(Segmento(espejo_geom(s.geom, eje), s.patron, espejo_geom(s.espina, eje) if s.espina is not None else None, s.doble, s.deco))
    return salida


def componer(lz, rng, segmentos, detalles, caja):
    """Dibuja los segmentos (de atrás hacia delante) encajados en `caja`."""
    todo = unary_union([s.geom for s in segmentos])
    x0, y0, x1, y1 = todo.bounds
    cx0, cy0, cx1, cy1 = caja
    k = min((cx1 - cx0) / (x1 - x0), (cy1 - cy0) / (y1 - y0))
    ox = (cx0 + cx1) / 2 - (x0 + x1) / 2 * k
    oy = (cy0 + cy1) / 2 - (y0 + y1) / 2 * k

    def T(g):
        return affinity.translate(affinity.scale(g, k, k, origin=(0, 0)), ox, oy)

    segs = [Segmento(T(s.geom), s.patron, T(s.espina) if s.espina is not None else None, s.doble, s.deco) for s in segmentos]
    dets = [(t, T(g)) for t, g in detalles]
    # patrones asignados por pares simétricos: mismo índice de azar para el reflejo
    elegidos = {}
    nombres = [n for n in PATRONES if n != "vacio"]
    delante = None
    visibles = []
    for s in reversed(segs):
        vis = s.geom if delante is None else s.geom.difference(delante)
        delante = s.geom if delante is None else delante.union(s.geom)
        visibles.append((s, vis))
    visibles.reverse()
    ocupado_detalles = unary_union([g for _, g in dets]) if dets else None
    for i, (s, vis) in enumerate(visibles):
        if vis.is_empty or vis.area < 40:
            continue
        trazar(lz, vis, FUERTE if i == 0 else MEDIO)
        interior = vis
        if s.doble:
            borde = vis.buffer(-9)
            if not borde.is_empty:
                trazar(lz, borde, FINO)
                interior = borde.buffer(-5)
        if ocupado_detalles is not None:
            interior = interior.difference(ocupado_detalles.buffer(8))
        if s.espina is not None:
            d = s.deco if s.deco is not None else int(rng.integers(len(DECOS)))
            for g in DECOS[d](vis, s.espina, rng):
                if isinstance(g, tuple):
                    trazar(lz, g[1], FINO, negro=True)
                else:
                    trazar(lz, g, FINO)
            continue
        if interior.is_empty or interior.area < 400:
            continue
        clave = round(s.geom.centroid.y, 0), round(abs(s.geom.centroid.x - (cx0 + cx1) / 2), 0), round(s.geom.area, -2)
        if s.patron:
            nombre = s.patron
        else:
            if clave not in elegidos:
                elegidos[clave] = nombres[int(rng.integers(len(nombres)))]
            nombre = elegidos[clave]
        semilla = abs(hash(clave)) % (2 ** 31)
        for g in PATRONES[nombre](interior, np.random.default_rng(semilla)):
            trazar(lz, g, FINO)
    for t, g in dets:
        if t == "negro":
            trazar(lz, g, MEDIO, negro=True)
        elif t == "blanco":
            trazar(lz, g, MEDIO, relleno=True)
        elif t == "linea":
            trazar(lz, g, MEDIO)


def anillo_segmentado(geom, ancho, cortes, centro, desde=0.0, hasta=2 * math.pi):
    """Corta el borde (anillo de `ancho`) de una forma en trozos radiales."""
    anillo = geom.difference(geom.buffer(-ancho))
    trozos = []
    for j in range(cortes):
        a0 = desde + (hasta - desde) * j / cortes
        a1 = desde + (hasta - desde) * (j + 1) / cortes
        cuña = poli([centro] + [polar(centro, 2000, a0 + (a1 - a0) * k / 8) for k in range(9)])
        t = anillo.intersection(cuña)
        if not t.is_empty and t.area > 200:
            trozos.append(t if t.geom_type == "Polygon" else max(getattr(t, "geoms", [t]), key=lambda g: g.area))
    return trozos


def camino_pts(*p, n=20):
    pts = [p[0]]
    for i in range(0, len(p) - 1, 3):
        pts += bezier3(p[i], p[i + 1], p[i + 2], p[i + 3], n)[1:]
    return pts


def simetrica(mitad, eje=500):
    """Polígono simétrico a partir de su contorno izquierdo (de arriba abajo, en el eje)."""
    return poli(mitad + [(2 * eje - x, y) for x, y in mitad[::-1]])


def ojo(c, ancho, alto, inclinacion=0.12, lado=1):
    """Ojo étnico: párpado exterior, almendra, iris con anillo, pupila y brillo."""
    x = c[0]
    det = []
    det.append(("blanco", almendra((x, c[1] - 4), ancho * 1.35, alto * 1.55, inclinacion * lado)))
    det.append(("blanco", almendra(c, ancho, alto, inclinacion * lado)))
    det.append(("blanco", Point(c).buffer(alto * 0.85, 24)))
    det.append(("negro", Point(c).buffer(alto * 0.45, 20)))
    det.append(("blanco", Point((c[0] - alto * 0.2, c[1] - alto * 0.22)).buffer(alto * 0.14, 10)))
    return det


# --------------------------------------------------------------------- animales

def leon(rng):
    segs = []
    centro = (500, 470)
    # melena: capas de mechones en S, de atrás (largos) hacia delante (cortos);
    # los de los lados y de abajo caen con la gravedad
    capas = [(12, 300, 330, 112, 0.42), (11, 272, 270, 104, 0.38), (10, 252, 205, 92, 0.34)]
    for c, (n, r0, largo, ancho, curva) in enumerate(capas):
        for j in range(n):
            a = math.pi * 0.42 + math.pi * 1.1 * (j + 0.5 + 0.5 * (c % 2)) / n
            if a > math.pi * 1.5:
                continue
            base = polar(centro, r0 * (1.0 + 0.1 * math.sin(a)), a)
            lado = math.cos(a)                       # -1 a la izquierda
            caida = 0.25 * max(0.0, math.sin(a)) + 0.12 * abs(lado)
            sentido = 1 if j % 2 else -1
            g, esp = mechon(base, a, largo * (1.0 + 0.15 * max(0, math.sin(a))), ancho, curva * sentido, caida=caida)
            segs.append(Segmento(g, espina=esp))
    melena = simetricos(segs)
    cara = simetrica(camino_pts((500, 225), (420, 225), (330, 250), (295, 330), (262, 410), (255, 520), (285, 620),
                                (320, 710), (420, 790), (500, 800)))
    orejas = simetricos([Segmento(ovalo((330, 250), 66, 60), "anillos")])
    borde = anillo_segmentado(cara, 46, 22, (500, 520))
    fondo_cara = Segmento(cara.buffer(-46), "vacio", doble=False)
    frente = simetrica(camino_pts((500, 270), (450, 275), (420, 300), (430, 340), (440, 370), (470, 390), (500, 400)))
    frente_lados = simetricos([Segmento(poli(camino_pts((440, 280), (380, 280), (320, 320), (310, 370), (360, 365), (400, 360), (430, 345)) + [(440, 280)]), "rayas")])
    puente = simetrica(camino_pts((500, 400), (470, 400), (455, 430), (452, 480), (450, 520), (440, 545), (430, 565)) + [(500, 565)])
    mejillas = simetricos([
        Segmento(poli(camino_pts((300, 430), (350, 470), (420, 470), (440, 520), (445, 570), (420, 600), (380, 620)) + [(300, 600)])),
        Segmento(poli(camino_pts((300, 600), (350, 630), (390, 630), (410, 610), (400, 680), (370, 720), (340, 720)) + [(300, 680)]), "lagrimas"),
    ])
    hocico = simetricos([Segmento(ovalo((450, 640), 62, 50, -0.15), "puntos")])
    nariz = simetrica(camino_pts((500, 560), (460, 560), (425, 562), (430, 585), (440, 605), (470, 622), (500, 628)))
    barbilla = simetrica(camino_pts((500, 685), (460, 690), (430, 700), (435, 730), (445, 760), (475, 780), (500, 785)))
    cuerpo = (orejas + [Segmento(cara, "vacio")] + [Segmento(t) for t in borde] + [fondo_cara, Segmento(frente, "anillos_puntos")]
              + frente_lados + [Segmento(puente, "zigzag")] + mejillas + [Segmento(barbilla, "escamas")] + hocico + [Segmento(nariz, "rayas")])
    det = []
    for lado, x in ((1, 395), (-1, 605)):
        det += ojo((x, 440), 48, 22, 0.12, lado)
    det.append(("negro", simetrica(camino_pts((500, 568), (475, 568), (462, 572), (470, 585), (478, 595), (490, 600), (500, 602)))))
    det.append(("linea", LineString([(500, 628), (500, 665)])))
    det.append(("linea", LineString(bezier2((500, 665), (470, 688), (438, 676)))))
    det.append(("linea", LineString(bezier2((500, 665), (530, 688), (562, 676)))))
    return melena + cuerpo, det


def _cinta(pts, ancho, final):
    izq, der = [], []
    n = len(pts) - 1
    for i, p in enumerate(pts):
        a = pts[max(i - 1, 0)]
        b = pts[min(i + 1, n)]
        ang = math.atan2(b[1] - a[1], b[0] - a[0]) + math.pi / 2
        w = (ancho + (final - ancho) * i / max(n, 1)) / 2
        izq.append(polar(p, w, ang))
        der.append(polar(p, -w, ang))
    return poli(izq + der[::-1])


def cabeza(rng, P):
    """Cabeza de mamífero de frente a partir de parámetros (ver ANIMALES)."""
    yt, ye, yn, yb = P["yt"], P["ye"], P["yn"], P["yb"]
    wt, wc, wj, wm = P["wt"], P["wc"], P["wj"], P["wm"]
    ex, ew = P.get("ex", 0.42 * wc), P.get("ew", 46)
    wn = P.get("wn", wm * 0.75)
    ym = yn + (yb - yn) * 0.35
    detras, segs, det = [], [], []
    mitad = camino_pts((500, yt), (500 - wt * 0.6, yt), (500 - wt, yt + 20), (500 - wt * 1.05, yt + (ye - yt) * 0.7),
                       (500 - wc * 1.02, ye + 20), (500 - wc, ye + (yn - ye) * 0.6), (500 - wj, yn + 20),
                       (500 - wj * 0.9, yn + (yb - yn) * 0.6), (500 - wm * 0.8, yb), (500, yb))
    cara = simetrica(mitad)
    # ---- detrás de la cara: cuernos, orejas, pelo
    cuernos = P.get("cuernos")
    if cuernos == "astas":
        viga = camino_pts((500 - wt * 0.45, yt + 15), (500 - wt * 0.9, yt - 60), (500 - wt * 1.5, yt - 140), (500 - wt * 1.45, yt - 330))
        piezas = [Segmento(_cinta(viga, 44, 16), espina=LineString(viga))]
        for t, largo, ang in ((7, 140, -1.3), (12, 170, -1.6), (17, 120, -1.95)):
            base = viga[t]
            medio = polar(base, largo * 0.5, ang - 0.3)
            punta = polar(medio, largo * 0.5, ang)
            esp = bezier2(base, medio, punta, 12)
            piezas.insert(0, Segmento(_cinta(esp, 30, 10), espina=LineString(esp)))
        detras += simetricos(piezas)
    elif cuernos == "espiral":
        c = (500 - wt * 0.95, yt + 70)
        esp = [polar(c, 150 * (1 - 0.68 * k / 40), -math.pi * 0.55 - 1.75 * math.pi * k / 40) for k in range(41)]
        detras += simetricos([Segmento(_cinta(esp, 110, 30), espina=LineString(esp), deco=1)])
    elif cuernos == "toro":
        esp = camino_pts((500 - wt * 0.7, yt + 30), (500 - wt * 1.3, yt + 20), (500 - wt * 1.75, yt - 20), (500 - wt * 1.7, yt - 150))
        detras += simetricos([Segmento(_cinta(esp, 80, 14), espina=LineString(esp), deco=1)])
    pelo = P.get("pelo")
    if pelo == "collar":
        lado = []
        for capa, (n, largo, ancho) in enumerate(((7, 190, 86), (6, 150, 74))):
            for j in range(n):
                f = (j + 0.5 * (capa % 2)) / n
                y = ye + (yb - ye) * (0.05 + 0.9 * f)
                x = 500 - (wc + (wj - wc) * f) * 0.92
                ang = math.pi * (0.95 - 0.35 * f)
                g, e = mechon((x, y), ang, largo, ancho, 0.3 * (1 if j % 2 else -1), caida=0.15)
                lado.append(Segmento(g, espina=e))
        detras += simetricos(lado)
    orejas = P.get("orejas", "punta")
    tam = P.get("oreja", 120)
    if orejas == "punta":
        ext = camino_pts((500 - wt * 0.35, yt + 25), (500 - wt * 0.5, yt - tam * 0.5), (500 - wt * 0.75, yt - tam * 0.9), (500 - wt * 0.92, yt - tam),
                         (500 - wt * 1.05, yt - tam * 0.6), (500 - wt * 1.1, yt), (500 - wt * 1.02, yt + 70))
        inte = camino_pts((500 - wt * 0.5, yt + 25), (500 - wt * 0.6, yt - tam * 0.35), (500 - wt * 0.78, yt - tam * 0.7), (500 - wt * 0.88, yt - tam * 0.78),
                          (500 - wt * 0.95, yt - tam * 0.45), (500 - wt * 0.98, yt), (500 - wt * 0.95, yt + 50))
        detras += simetricos([Segmento(poli(ext)), Segmento(poli(inte), "rayas")])
    elif orejas == "redonda":
        c = (500 - wt * 0.88, yt + 10)
        detras += simetricos([Segmento(ovalo(c, tam, tam * 0.92)), Segmento(ovalo((c[0] + 8, c[1] + 10), tam * 0.6, tam * 0.55), "anillos")])
    elif orejas == "larga":
        c = (500 - wt * 0.45, yt - tam * 0.9)
        detras += simetricos([Segmento(ovalo(c, tam * 0.33, tam, 0.12)), Segmento(ovalo((c[0], c[1] + 10), tam * 0.17, tam * 0.78, 0.12), "puntos")])
    elif orejas == "lado":
        c = (500 - wt * 1.15, yt + 60)
        detras += simetricos([Segmento(ovalo(c, tam, tam * 0.36, 0.25)), Segmento(ovalo(c, tam * 0.65, tam * 0.18, 0.25), "rayas")])
    elif orejas == "elefante":
        c = (500 - wc * 1.25, ye + 30)
        detras += simetricos([Segmento(ovalo(c, tam * 0.8, tam, -0.1)), Segmento(ovalo((c[0] + 15, c[1]), tam * 0.6, tam * 0.78, -0.1))])
    if pelo == "melena":
        melena = []
        for c, (n, r0, largo, ancho, curva) in enumerate([(12, 300, 330, 112, 0.42), (11, 272, 270, 104, 0.38), (10, 252, 205, 92, 0.34)]):
            for j in range(n):
                a = math.pi * 0.42 + math.pi * 1.1 * (j + 0.5 + 0.5 * (c % 2)) / n
                if a > math.pi * 1.5:
                    continue
                base = polar((500, (yt + yb) / 2), r0 * (1.0 + 0.1 * math.sin(a)), a)
                caida = 0.25 * max(0.0, math.sin(a)) + 0.12 * abs(math.cos(a))
                g, e = mechon(base, a, largo * (1.0 + 0.15 * max(0, math.sin(a))), ancho, curva * (1 if j % 2 else -1), caida=caida)
                melena.append(Segmento(g, espina=e))
        detras = simetricos(melena) + detras
    # ---- cara
    segs.append(Segmento(cara, "vacio"))
    segs += [Segmento(t) for t in anillo_segmentado(cara, 42, P.get("cortes", 22), (500, (ye + yn) / 2))]
    segs.append(Segmento(cara.buffer(-42), "vacio", doble=False))
    frente = simetrica(camino_pts((500, yt + 45), (500 - wt * 0.3, yt + 48), (500 - wt * 0.32, ye - 90), (500 - wt * 0.2, ye - 50),
                                  (500 - wt * 0.12, ye - 30), (500 - wt * 0.05, ye - 15), (500, ye - 8)))
    lados = poli(camino_pts((500 - wt * 0.36, yt + 50), (500 - wt * 0.6, yt + 52), (500 - wt * 0.8, yt + 70), (500 - wt * 0.82, ye - 100),
                            (500 - wt * 0.7, ye - 80), (500 - wt * 0.45, ye - 85), (500 - wt * 0.3, ye - 75)) + [(500 - wt * 0.3, yt + 50)])
    segs += [Segmento(frente, P.get("p_frente", "anillos_puntos"))] + simetricos([Segmento(lados)])
    mejilla = poli([(500 - wc * 0.95, ye + ew * 0.7), (500 - ex * 0.45, ye + ew * 0.7), (500 - wn * 1.1, yn), (500 - wm * 1.3, ym + 40), (500 - wj * 0.95, yn + 40)])
    segs += simetricos([Segmento(mejilla.intersection(cara.buffer(-42)))])
    hocico_l = ovalo((500 - wm * 0.55, ym), wm * 0.62, (yb - yn) * 0.28, -0.12)
    segs += simetricos([Segmento(hocico_l.buffer(55).intersection(mejilla.union(hocico_l)).intersection(cara.buffer(-42)), "lagrimas")])
    for tipo, extra in P.get("manchas", []):
        if tipo == "parche":
            segs += simetricos([Segmento(ovalo((500 - ex, ye + 10), ew * 1.9, ew * 1.35, 0.5), extra)])
        elif tipo == "antifaz":
            segs.append(Segmento(simetrica(camino_pts((500, ye - 40), (500 - ex * 0.6, ye - 70), (500 - ex * 1.6, ye - 60), (500 - wc * 1.0, ye + 10),
                                                       (500 - ex * 1.4, ye + 70), (500 - ex * 0.6, ye + 50), (500, ye + 30))), extra))
        elif tipo == "rayas":
            for k, (x, y, l, a) in enumerate(((0.72, 0.15, 90, 0.2), (0.85, 0.45, 110, -0.1), (0.8, 0.7, 90, -0.4))):
                base = (500 - wc * x, yt + (yb - yt) * y)
                g, _e = mechon(base, math.pi * 0.0 + a, l, 34, 0.2)
                segs += simetricos([Segmento(g.intersection(cara.buffer(-42)), "vacio")])
        elif tipo == "mascara":
            segs.append(Segmento(simetrica(camino_pts((500, ye - 60), (500 - ex * 0.5, ye - 110), (500 - ex * 1.8, ye - 100), (500 - ex * 1.6, ye + 10),
                                                       (500 - ex * 1.5, ye + 90), (500 - wm * 1.3, yb - 20), (500, yb - 10))), extra))
    puente = simetrica(camino_pts((500, ye - 8), (500 - wn * 0.5, ye - 4), (500 - wn * 0.6, ye + 30), (500 - wn * 0.6, (ye + yn) / 2),
                                  (500 - wn * 0.65, yn - 30), (500 - wn * 0.8, yn - 10), (500 - wn * 0.9, yn)) + [(500, yn)])
    segs.append(Segmento(puente, "zigzag"))
    cejas = poli(camino_pts((500 - ex - ew * 1.3, ye - ew * 0.2), (500 - ex - ew * 0.8, ye - ew * 1.3), (500 - ex + ew * 0.6, ye - ew * 1.4),
                            (500 - ex + ew * 1.25, ye - ew * 0.5), (500 - ex + ew * 0.5, ye - ew * 0.9), (500 - ex - ew * 0.6, ye - ew * 0.9), (500 - ex - ew * 1.3, ye - ew * 0.2)))
    segs += simetricos([Segmento(cejas, "rayas")])
    segs += simetricos([Segmento(hocico_l, "puntos")])
    barbilla = simetrica(camino_pts((500, yb - (yb - yn) * 0.32), (500 - wm * 0.4, yb - (yb - yn) * 0.3), (500 - wm * 0.55, yb - 40), (500 - wm * 0.45, yb - 22),
                                    (500 - wm * 0.35, yb - 12), (500 - wm * 0.2, yb - 8), (500, yb - 6)))
    segs.append(Segmento(barbilla, "escamas"))
    nariz_alto = P.get("nariz_alto", 70)
    nariz = simetrica(camino_pts((500, yn - 5), (500 - wn * 0.6, yn - 5), (500 - wn * 1.05, yn - 2), (500 - wn, yn + nariz_alto * 0.4),
                                 (500 - wn * 0.8, yn + nariz_alto * 0.8), (500 - wn * 0.3, yn + nariz_alto), (500, yn + nariz_alto)))
    segs.append(Segmento(nariz, "rayas"))
    for lado in (1, -1):
        det += ojo((500 - lado * ex, ye), ew, ew * 0.47, 0.12, lado)
    det.append(("negro", simetrica(camino_pts((500, yn + 6), (500 - wn * 0.45, yn + 6), (500 - wn * 0.65, yn + 10), (500 - wn * 0.55, yn + nariz_alto * 0.4),
                                              (500 - wn * 0.4, yn + nariz_alto * 0.6), (500 - wn * 0.15, yn + nariz_alto * 0.7), (500, yn + nariz_alto * 0.72)))))
    yb2 = yn + nariz_alto
    det.append(("linea", LineString([(500, yb2), (500, yb2 + 34)])))
    det.append(("linea", LineString(bezier2((500, yb2 + 34), (500 - wm * 0.4, yb2 + 60), (500 - wm * 0.8, yb2 + 45)))))
    det.append(("linea", LineString(bezier2((500, yb2 + 34), (500 + wm * 0.4, yb2 + 60), (500 + wm * 0.8, yb2 + 45)))))
    if P.get("trompa"):
        esp = camino_pts((500, yn - 60), (500, yn + 120), (470, yb + 160), (560, yb + 230))
        segs.append(Segmento(_cinta(esp, wm * 1.4, wm * 0.7), espina=LineString(esp), deco=1))
    return detras + segs, det


def _cabeza(**P):
    return lambda rng: cabeza(rng, P)


BASE = dict(yt=260, ye=440, yn=600, yb=790, wt=210, wc=250, wj=200, wm=95)

ANIMALES = [
    ("leon", "León", _cabeza(**{**BASE, "pelo": "melena", "orejas": "redonda", "oreja": 62, "yt": 240, "wt": 220, "wc": 245, "wj": 215})),
    ("tigre", "Tigre", _cabeza(**{**BASE, "pelo": "collar", "orejas": "redonda", "oreja": 70, "manchas": [("rayas", None)]})),
    ("lobo", "Lobo", _cabeza(**{**BASE, "pelo": "collar", "orejas": "punta", "oreja": 170, "wc": 230, "wj": 150, "wm": 70, "yb": 840, "yn": 650})),
    ("zorro", "Zorro", _cabeza(**{**BASE, "orejas": "punta", "oreja": 190, "wc": 260, "wj": 130, "wm": 55, "yb": 830, "yn": 660, "ew": 40, "manchas": [("mascara", "vacio")]})),
    ("gato", "Gato", _cabeza(**{**BASE, "orejas": "punta", "oreja": 150, "wj": 190, "wm": 80, "ew": 52})),
    ("oso", "Oso", _cabeza(**{**BASE, "orejas": "redonda", "oreja": 70, "wt": 230, "wc": 265, "wj": 230, "wm": 110, "ew": 38})),
    ("panda", "Panda", _cabeza(**{**BASE, "orejas": "redonda", "oreja": 80, "wt": 235, "wc": 270, "wj": 235, "wm": 100, "ew": 38, "manchas": [("parche", "rayas")]})),
    ("koala", "Koala", _cabeza(**{**BASE, "orejas": "redonda", "oreja": 125, "wt": 240, "wc": 265, "wj": 220, "wm": 80, "wn": 70, "nariz_alto": 120, "ew": 36})),
    ("mono", "Mono", _cabeza(**{**BASE, "orejas": "lado", "oreja": 90, "wt": 200, "wm": 120, "ew": 44, "manchas": [("mascara", "vacio")]})),
    ("mapache", "Mapache", _cabeza(**{**BASE, "orejas": "punta", "oreja": 120, "wj": 160, "wm": 70, "manchas": [("antifaz", "rayas")]})),
    ("conejo", "Conejo", _cabeza(**{**BASE, "orejas": "larga", "oreja": 260, "yt": 380, "ye": 540, "yn": 680, "yb": 840, "wt": 190, "wc": 230, "wj": 190, "wm": 80, "wn": 40, "nariz_alto": 40, "ew": 44})),
    ("ciervo", "Ciervo", _cabeza(**{**BASE, "cuernos": "astas", "orejas": "lado", "oreja": 110, "yt": 400, "ye": 560, "yn": 800, "yb": 920, "wt": 170, "wc": 190, "wj": 120, "wm": 80, "ew": 40})),
    ("carnero", "Carnero", _cabeza(**{**BASE, "cuernos": "espiral", "orejas": "lado", "oreja": 80, "yt": 300, "ye": 470, "yn": 720, "yb": 860, "wt": 160, "wc": 175, "wj": 130, "wm": 85, "ew": 38})),
    ("toro", "Toro", _cabeza(**{**BASE, "cuernos": "toro", "orejas": "lado", "oreja": 90, "yt": 330, "ye": 480, "yn": 700, "yb": 860, "wt": 200, "wc": 215, "wj": 170, "wm": 125, "wn": 100, "ew": 40})),
    ("elefante", "Elefante", _cabeza(**{**BASE, "orejas": "elefante", "oreja": 230, "yt": 230, "ye": 430, "yn": 560, "yb": 700, "wt": 190, "wc": 200, "wj": 150, "wm": 70, "wn": 50, "ew": 34, "trompa": True})),
]


def lamina(rng, lz, i):
    _id, _n, f = ANIMALES[i % len(ANIMALES)]
    segs, det = f(rng)
    lz.escala = LADO / ANCHO
    componer(lz, rng, segs, det, (40, 40, 960, 960))
    lz.escala = 1.0
