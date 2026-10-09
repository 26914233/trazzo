"""Fachadas en alzado, como en un plano de construcción.

Cada fachada se genera por partes (zócalo, muros, cornisas, ventanas, puerta,
balcones, tejado) con el algoritmo del pintor: el muro se dibuja con su aparejo
completo y las ventanas lo tapan después. Alrededor van cotas con medidas y un
cajetín, como en un plano real.

Tipos: colonial, victoriana, clasica (más en la lista TIPOS).
"""
import math
import os

from PIL import ImageFont

from laminas import LADO, LINEA, SS, Lienzo, polar

ANCHO = 1000   # se dibuja en una caja de 1000 y el lienzo escala a LADO

FINO = LINEA * 0.6
MEDIO = LINEA * 0.85
FUERTE = LINEA * 1.3
_FUENTE = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), "arte", "fuentes", "DMSans-Medium.ttf")


def rect(lz, x0, y0, x1, y1, g=MEDIO, relleno=True):
    lz.forma([(x0, y0), (x1, y0), (x1, y1), (x0, y1)], g, relleno)


def arco_pts(cx, cy, r, n=24, desde=math.pi, hasta=2 * math.pi):
    return [polar((cx, cy), r, desde + (hasta - desde) * k / n) for k in range(n + 1)]


# --------------------------------------------------------------------- aparejos

def ladrillo(lz, x0, y0, x1, y1, alto=18, largo=46):
    rect(lz, x0, y0, x1, y1, FUERTE)
    y, fila = y1, 0
    while y > y0 + 1:
        lz.trazo([(x0, y), (x1, y)], FINO)
        x = x0 + (largo / 2 if fila % 2 else largo)
        while x < x1 - 2:
            lz.trazo([(x, max(y - alto, y0)), (x, y)], FINO)
            x += largo
        y -= alto
        fila += 1


def sillar(lz, x0, y0, x1, y1, alto=44, largo=90):
    ladrillo(lz, x0, y0, x1, y1, alto, largo)


def tablas(lz, x0, y0, x1, y1, alto=16):
    rect(lz, x0, y0, x1, y1, FUERTE)
    y = y0 + alto
    while y < y1:
        lz.trazo([(x0, y), (x1, y)], FINO)
        y += alto


def tejas(lz, poly, x0, y0, x1, y1, r=16):
    """Tejado de escamas recortado al polígono (se pinta el polígono encima con
    relleno solo en el contorno: las escamas quedan dentro gracias al orden)."""
    lz.forma(poly, FUERTE)
    fila = 0
    y = y1
    while y > y0:
        x = x0 + (r if fila % 2 else 0)
        while x < x1:
            if _dentro_poly(poly, (x, y)):
                lz.trazo(arco_pts(x, y - r, r, 10, 0, math.pi), FINO)
            x += 2 * r
        y -= r * 1.2
        fila += 1
    lz.forma(poly, FUERTE, relleno=False)


def _dentro_poly(poly, p):
    x, y = p
    dentro = False
    for (ax, ay), (bx, by) in zip(poly, poly[1:] + poly[:1]):
        if (ay > y) != (by > y) and x < (bx - ax) * (y - ay) / (by - ay + 1e-9) + ax:
            dentro = not dentro
    return dentro


def cornisa(lz, x0, x1, y, alto=26, denticulos=True):
    rect(lz, x0 - 14, y - alto, x1 + 14, y, MEDIO)
    rect(lz, x0 - 22, y - alto - 10, x1 + 22, y - alto, MEDIO)
    if denticulos:
        x = x0 - 4
        while x < x1 - 4:
            rect(lz, x, y, x + 10, y + 10, FINO)
            x += 20


# --------------------------------------------------------------------- piezas

def ventana(lz, rng, cx, y0, ancho, alto, estilo):
    x0, x1, y1 = cx - ancho / 2, cx + ancho / 2, y0 + alto
    if estilo.get("contraventanas"):
        for lado in (-1, 1):
            sx0 = cx + lado * ancho / 2
            sx1 = sx0 + lado * ancho * 0.48
            a, b = min(sx0, sx1), max(sx0, sx1)
            rect(lz, a, y0, b, y1, MEDIO)
            y = y0 + 12
            while y < y1 - 6:
                lz.trazo([(a + 6, y), (b - 6, y)], FINO)
                y += 12
    rect(lz, x0 - 10, y0 - 10, x1 + 10, y1 + 6, MEDIO)                        # marco
    if estilo.get("arco"):
        lz.forma(arco_pts(cx, y0, ancho / 2 + 10) + [(x1 + 10, y0), (x0 - 10, y0)], MEDIO)
        lz.forma(arco_pts(cx, y0, ancho / 2), FINO)
        for k in range(1, 4):
            lz.trazo([(cx, y0), polar((cx, y0), ancho / 2, math.pi + math.pi * k / 4)], FINO)
    rect(lz, x0, y0, x1, y1, MEDIO)                                            # vidrio
    cols, filas = estilo.get("panos", (2, 3))
    for k in range(1, cols):
        x = x0 + (x1 - x0) * k / cols
        lz.trazo([(x, y0), (x, y1)], FINO)
    for k in range(1, filas):
        y = y0 + (y1 - y0) * k / filas
        lz.trazo([(x0, y), (x1, y)], FINO)
    rect(lz, x0 - 18, y1 + 6, x1 + 18, y1 + 18, MEDIO)                        # alféizar
    dintel = estilo.get("dintel")
    if dintel == "fronton":
        lz.forma([(x0 - 22, y0 - 12), (x1 + 22, y0 - 12), (cx, y0 - 12 - ancho * 0.32)], MEDIO)
        lz.forma([(x0 - 6, y0 - 18), (x1 + 6, y0 - 18), (cx, y0 - 18 - ancho * 0.22)], FINO)
    elif dintel == "recto":
        rect(lz, x0 - 20, y0 - 30, x1 + 20, y0 - 12, MEDIO)
        lz.forma([(cx - 12, y0 - 30), (cx + 12, y0 - 30), (cx + 8, y0 - 12), (cx - 8, y0 - 12)], FINO)
    if estilo.get("jardinera"):
        rect(lz, x0 - 8, y1 + 18, x1 + 8, y1 + 40, MEDIO)
        n = max(3, int(ancho // 22))
        for k in range(n):
            px = x0 + (x1 - x0) * (k + 0.5) / n
            lz.circulo((px, y1 + 12), 11, FINO)
            lz.circulo((px, y1 + 12), 4, FINO * 0.8)


def puerta(lz, cx, y_suelo, ancho, alto, arco=True, faroles=True):
    x0, x1 = cx - ancho / 2, cx + ancho / 2
    y0 = y_suelo - alto
    for k in range(3):                                                         # escalones
        rect(lz, x0 - 40 - k * 18, y_suelo + k * 14, x1 + 40 + k * 18, y_suelo + (k + 1) * 14, MEDIO)
    rect(lz, x0 - 24, y0 - 20, x1 + 24, y_suelo, MEDIO)                       # jambas
    if arco:
        lz.forma(arco_pts(cx, y0, ancho / 2 + 24) + [(x1 + 24, y0), (x0 - 24, y0)], MEDIO)
        lz.forma(arco_pts(cx, y0, ancho / 2) + [(x1, y0), (x0, y0)], MEDIO)
        for k in range(1, 6):
            lz.trazo([(cx, y0), polar((cx, y0), ancho / 2, math.pi + math.pi * k / 6)], FINO)
        lz.circulo((cx, y0), ancho * 0.1, FINO)
        rect(lz, cx - 14, y0 - ancho / 2 - 28, cx + 14, y0 - ancho / 2 + 4, FINO)    # clave
    rect(lz, x0, y0, x1, y_suelo, MEDIO)
    lz.trazo([(cx, y0), (cx, y_suelo)], MEDIO)
    for lado in (0, 1):
        a = x0 + lado * ancho / 2
        for f in range(3):
            fy0 = y0 + 16 + f * (alto - 32) / 3
            fy1 = fy0 + (alto - 32) / 3 - 14
            rect(lz, a + 14, fy0, a + ancho / 2 - 14, fy1, FINO)
    for lado in (-1, 1):
        lz.circulo((cx + lado * 16, y0 + alto * 0.55), 6, FINO)
        if not faroles:
            continue
        # faroles a los lados
        fx = cx + lado * (ancho / 2 + 70)
        fy = y0 + 20
        lz.trazo([(fx, fy - 30), (fx, fy - 10)], FINO)
        lz.forma([(fx - 18, fy - 10), (fx + 18, fy - 10), (fx + 12, fy + 40), (fx - 12, fy + 40)], MEDIO)
        lz.forma([(fx - 24, fy - 10), (fx + 24, fy - 10), (fx, fy - 30)], FINO)


def balaustrada(lz, x0, x1, y_base, alto=70):
    rect(lz, x0 - 12, y_base, x1 + 12, y_base + 16, MEDIO)                    # losa
    rect(lz, x0 - 6, y_base - alto, x1 + 6, y_base - alto + 12, MEDIO)        # pasamanos
    n = max(3, int((x1 - x0) // 26))
    for k in range(n):
        bx = x0 + (x1 - x0) * (k + 0.5) / n
        perfil = [(bx - 5, y_base), (bx - 9, y_base - alto * 0.25), (bx - 4, y_base - alto * 0.55), (bx - 6, y_base - alto + 12),
                  (bx + 6, y_base - alto + 12), (bx + 4, y_base - alto * 0.55), (bx + 9, y_base - alto * 0.25), (bx + 5, y_base)]
        lz.forma(perfil, FINO)
    for lado in (x0, x1):
        rect(lz, lado - 10, y_base - alto, lado + 10, y_base, MEDIO)


def chimenea(lz, x, y_tejado, alto=120):
    ladrillo(lz, x - 34, y_tejado - alto, x + 34, y_tejado + 30, 14, 34)
    rect(lz, x - 44, y_tejado - alto - 18, x + 44, y_tejado - alto, MEDIO)


def pilastra(lz, x, y0, y1, ancho=30):
    rect(lz, x - ancho / 2, y0, x + ancho / 2, y1, MEDIO)
    lz.trazo([(x - ancho / 4, y0 + 20), (x - ancho / 4, y1 - 20)], FINO)
    lz.trazo([(x + ancho / 4, y0 + 20), (x + ancho / 4, y1 - 20)], FINO)
    rect(lz, x - ancho / 2 - 8, y0 - 16, x + ancho / 2 + 8, y0, MEDIO)
    rect(lz, x - ancho / 2 - 8, y1, x + ancho / 2 + 8, y1 + 16, MEDIO)


# --------------------------------------------------------------------- plano

def _texto(lz, texto, x, y, tam=20, centro=True):
    k = SS * lz.escala
    f = ImageFont.truetype(_FUENTE, int(tam * k))
    ancho = lz.d.textlength(texto, font=f) / k
    xx = x - ancho / 2 if centro else x
    lz.d.rectangle([(xx - 4) * k, (y - tam * 0.7) * k, (xx + ancho + 4) * k, (y + tam * 0.6) * k], fill=255)
    lz.d.text((xx * k, (y - tam * 0.65) * k), texto, font=f, fill=0)


def cota(lz, a, b, desplaz, texto, horizontal=True):
    """Línea de cota con marcas a 45° y la medida en el centro."""
    if horizontal:
        y = desplaz
        lz.trazo([(a, y), (b, y)], FINO)
        for x in (a, b):
            lz.trazo([(x, y - 16), (x, y + 16)], FINO)
            lz.trazo([(x - 8, y + 8), (x + 8, y - 8)], MEDIO)
        _texto(lz, texto, (a + b) / 2, y - 2, 18)
    else:
        x = desplaz
        lz.trazo([(x, a), (x, b)], FINO)
        for y in (a, b):
            lz.trazo([(x - 16, y), (x + 16, y)], FINO)
            lz.trazo([(x - 8, y + 8), (x + 8, y - 8)], MEDIO)
        _texto(lz, texto, x, (a + b) / 2, 18)


def cajetin(lz, titulo, escala):
    x0, y0, x1, y1 = ANCHO * 0.56, ANCHO - 92, ANCHO - 26, ANCHO - 26
    rect(lz, x0, y0, x1, y1, MEDIO)
    lz.trazo([(x0, (y0 + y1) / 2), (x1, (y0 + y1) / 2)], FINO)
    lz.trazo([(x1 - 120, (y0 + y1) / 2), (x1 - 120, y1)], FINO)
    _texto(lz, titulo, (x0 + x1) / 2, y0 + 17, 19)
    _texto(lz, "ALZADO PRINCIPAL", (x0 + x1 - 120) / 2, y1 - 16, 16)
    _texto(lz, escala, x1 - 60, y1 - 16, 16)


def suelo(lz, y):
    lz.trazo([(30, y), (ANCHO - 30, y)], FUERTE)
    x = 40
    while x < ANCHO - 40:
        lz.trazo([(x, y), (x - 18, y + 18)], FINO)
        x += 26


# --------------------------------------------------------------------- tipos

def colonial(rng, lz):
    """Casa colonial de dos plantas con balcón corrido de madera y tejado de teja."""
    x0, x1 = 150, 850
    y_suelo = 820
    h1, h2 = 250, 230
    y1 = y_suelo - h1
    y2 = y1 - h2
    tejado = [(x0 - 50, y2), (x1 + 50, y2), (x1 - 20, y2 - 110), (x0 + 20, y2 - 110)]
    tejas(lz, tejado, x0 - 50, y2 - 110, x1 + 50, y2, 15)
    rect(lz, x0 - 60, y2 - 4, x1 + 60, y2 + 14, MEDIO)                        # alero
    x = x0 - 50
    while x < x1 + 50:
        lz.forma([(x, y2 + 14), (x + 16, y2 + 14), (x + 8, y2 + 34)], FINO)   # canecillos
        x += 40
    tablas(lz, x0, y2 + 14, x1, y1, 22) if rng.random() < 0.3 else sillar(lz, x0, y2 + 14, x1, y1, 30, 70)
    sillar(lz, x0, y1, x1, y_suelo, 40, 84)
    rect(lz, x0 - 10, y_suelo - 60, x1 + 10, y_suelo, MEDIO)                  # zócalo
    for k in range(int((x1 - x0) // 60)):
        rect(lz, x0 + k * 60 + 6, y_suelo - 52, x0 + k * 60 + 54, y_suelo - 8, FINO)
    n = int(rng.choice([3, 4]))
    xs = [x0 + (x1 - x0) * (k + 0.5) / n for k in range(n)]
    estilo2 = {"panos": (2, 4), "contraventanas": True, "dintel": "recto"}
    for x in xs:
        ventana(lz, rng, x, y2 + 70, 74, 120, estilo2)
    balaustrada(lz, x0 + 20, x1 - 20, y1 - 6, 80)
    for k in range(5):                                                         # pies derechos del balcón
        px = x0 + 20 + (x1 - x0 - 40) * k / 4
        rect(lz, px - 8, y2 + 30, px + 8, y1 - 86, FINO)
    cx = (x0 + x1) / 2
    for x in (x0 + 90, x0 + 210, x1 - 210, x1 - 90):
        ventana(lz, rng, x, y1 + 70, 76, 120, {"panos": (2, 3), "arco": True, "jardinera": True})
    puerta(lz, cx, y_suelo, 130, 190, arco=True, faroles=False)
    return x0, x1, y2 - 110, y_suelo


def victoriana(rng, lz):
    """Casa victoriana: torreón con cubierta cónica, mirador y tablas."""
    x0, x1 = 230, 820
    y_suelo = 830
    h = 200
    y1, y2 = y_suelo - h, y_suelo - 2 * h
    cumbre = y2 - 200
    tejas(lz, [(x0 - 40, y2), (x1 + 40, y2), ((x0 + x1) / 2 + 60, cumbre)], x0 - 40, cumbre, x1 + 40, y2, 14)
    chimenea(lz, x1 - 110, y2 - 70, 110)
    tablas(lz, x0, y2, x1, y_suelo, 18)
    cornisa(lz, x0, x1, y1, 20)
    cornisa(lz, x0, x1, y2 + 6, 18)
    # torreón a la izquierda
    tx0, tx1 = 110, 300
    tejas(lz, [(tx0 - 20, y2 - 40), (tx1 + 20, y2 - 40), ((tx0 + tx1) / 2, y2 - 330)], tx0 - 20, y2 - 330, tx1 + 20, y2 - 40, 12)
    lz.trazo([((tx0 + tx1) / 2, y2 - 330), ((tx0 + tx1) / 2, y2 - 380)], MEDIO)
    lz.circulo(((tx0 + tx1) / 2, y2 - 386), 10, FINO)
    sillar(lz, tx0, y2 - 40, tx1, y_suelo, 30, 64)
    for yy in (y1, y2 - 30):
        cornisa(lz, tx0, tx1, yy, 18, False)
    for yy in (y2 + 30, y1 + 40):
        ventana(lz, rng, (tx0 + tx1) / 2, yy, 80, 130, {"panos": (2, 3), "arco": True})
    # mirador (bay window) en la planta baja
    mx0, mx1 = 560, 780
    rect(lz, mx0 - 20, y1 + 20, mx1 + 20, y1 + 40, MEDIO)
    for k in range(3):
        a = mx0 + (mx1 - mx0) * k / 3
        ventana(lz, rng, a + (mx1 - mx0) / 6, y1 + 70, (mx1 - mx0) / 3 - 26, 120, {"panos": (1, 3)})
    rect(lz, mx0 - 10, y_suelo - 50, mx1 + 10, y_suelo, MEDIO)
    for x in (430, 680):
        ventana(lz, rng, x, y2 + 40, 84, 120, {"panos": (2, 3), "dintel": "fronton", "contraventanas": x == 430})
    puerta(lz, 410, y_suelo, 110, 170, arco=False, faroles=False)
    balaustrada(lz, 330, 500, y1 + 4, 50)
    return tx0, x1, y2 - 396, y_suelo


def clasica(rng, lz):
    """Edificio clásico: frontón, columnas, ventanas con frontón y balcones."""
    x0, x1 = 140, 860
    y_suelo = 840
    y_base = y_suelo - 70
    y_cornisa = 260
    fronton = [(x0 - 30, y_cornisa - 30), (x1 + 30, y_cornisa - 30), ((x0 + x1) / 2, y_cornisa - 210)]
    lz.forma(fronton, FUERTE)
    lz.forma([(x0 + 40, y_cornisa - 46), (x1 - 40, y_cornisa - 46), ((x0 + x1) / 2, y_cornisa - 180)], MEDIO)
    lz.circulo(((x0 + x1) / 2, y_cornisa - 100), 40, MEDIO)
    for k in range(8):
        lz.trazo([((x0 + x1) / 2, y_cornisa - 100), polar(((x0 + x1) / 2, y_cornisa - 100), 40, 2 * math.pi * k / 8)], FINO)
    sillar(lz, x0, y_cornisa, x1, y_base, 36, 80)
    cornisa(lz, x0, x1, y_cornisa, 30)
    rect(lz, x0 - 20, y_base, x1 + 20, y_suelo, MEDIO)
    for k in range(int((x1 - x0) // 72)):
        rect(lz, x0 + k * 72 + 6, y_base + 10, x0 + k * 72 + 64, y_suelo - 10, FINO)
    cols = [x0 + 20, x0 + 190, x1 - 190, x1 - 20]
    for x in cols:
        pilastra(lz, x, y_cornisa + 24, y_base, 40)
    cx = (x0 + x1) / 2
    for x in (x0 + 105, cx - 90, cx + 90, x1 - 105):
        ventana(lz, rng, x, y_cornisa + 80, 70, 150, {"panos": (2, 3), "dintel": "fronton"})
    for x in (x0 + 105, x1 - 105):
        ventana(lz, rng, x, y_cornisa + 330, 70, 150, {"panos": (2, 4), "dintel": "recto"})
    balaustrada(lz, cx - 150, cx + 150, y_cornisa + 250, 54)
    puerta(lz, cx, y_base + 10, 120, 170, arco=True)
    return x0, x1, y_cornisa - 210, y_suelo


TIPOS = [("colonial", "Casa colonial", colonial), ("victoriana", "Casa victoriana", victoriana), ("clasica", "Edificio clásico", clasica)]


def fachada(rng, lz, i):
    _id, titulo, f = TIPOS[i % len(TIPOS)]
    lz.escala = LADO / ANCHO
    x0, x1, ytop, y_suelo = f(rng, lz)
    suelo(lz, y_suelo + 44)
    escala = 0.02 * rng.uniform(0.9, 1.15)
    cota(lz, x0, x1, y_suelo + 86, "%.2f m" % ((x1 - x0) * escala))
    cota(lz, ytop, y_suelo, 50, "%.2f m" % ((y_suelo - ytop) * escala), horizontal=False)
    cajetin(lz, titulo.upper(), "E 1:50")
    m = 8
    lz.forma([(m, m), (ANCHO - m, m), (ANCHO - m, ANCHO - m), (m, ANCHO - m)], LINEA * 2, relleno=False)
    lz.escala = 1.0
