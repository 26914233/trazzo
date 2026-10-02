#!/usr/bin/env python3
"""Texturas de los prototipos de puzles, hechas por código (sin créditos de imágenes).

Todas se repiten sin costura. Junto a cada textura con relieve sale su mapa de normales
(<nombre>_n.png, convención de OpenGL, la de Godot).

  - Maderas: oscura (nogal), clara (boj), caoba, tablones del suelo.
  - Mosaicos yosegi (marquetería de Hakone): asanoha, kikko, uroko, ichimatsu y yabane.
  - Metales y otros: latón, metal ajeno con paneles hexagonales, piedra, cuero, papel, glifos.
  - Símbolos (luna, llama, ola, monte), ofuda, esfera del reloj, carta del relojero.

Uso:  python3 puzles/herramientas/generar_texturas.py [nombre ...]   (sin nombres: todas)
"""

import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

AQUI = os.path.dirname(os.path.abspath(__file__))
DESTINO = os.path.join(AQUI, "..", "godot", "recursos", "texturas")
FUENTES = "/usr/share/fonts/truetype"
T = 1024


# --- Ruido periódico ---------------------------------------------------------------------------

def ruido(ancho, alto, celdas_x, celdas_y, semilla):
    """Ruido de valor suave que se repite exactamente en ancho x alto."""
    azar = np.random.default_rng(semilla)
    rejilla = azar.random((celdas_y, celdas_x))
    x = np.arange(ancho) * celdas_x / ancho
    y = np.arange(alto) * celdas_y / alto
    x0 = np.floor(x).astype(int)
    y0 = np.floor(y).astype(int)
    fx = x - x0
    fy = y - y0
    fx = fx * fx * (3 - 2 * fx)
    fy = fy * fy * (3 - 2 * fy)
    x1 = (x0 + 1) % celdas_x
    y1 = (y0 + 1) % celdas_y
    a = rejilla[np.ix_(y0, x0)]
    b = rejilla[np.ix_(y0, x1)]
    c = rejilla[np.ix_(y1, x0)]
    d = rejilla[np.ix_(y1, x1)]
    fx = fx[None, :]
    fy = fy[:, None]
    return (a * (1 - fx) + b * fx) * (1 - fy) + (c * (1 - fx) + d * fx) * fy


def fbm(ancho, alto, celdas_x, celdas_y, semilla, octavas=4):
    total = np.zeros((alto, ancho))
    peso = 1.0
    suma = 0.0
    for o in range(octavas):
        total += ruido(ancho, alto, celdas_x * 2 ** o, celdas_y * 2 ** o, semilla + o * 17) * peso
        suma += peso
        peso *= 0.5
    return total / suma


def mezcla(a, b, t):
    a = np.asarray(a, dtype=np.float64)
    b = np.asarray(b, dtype=np.float64)
    return a + (b - a) * t[..., None]


def hexa(color):
    color = color.lstrip("#")
    return np.array([int(color[i:i + 2], 16) for i in (0, 2, 4)], dtype=np.float64)


# --- Madera ------------------------------------------------------------------------------------

def madera(claro, oscuro, semilla, anillos=9, torsion=1.2, fibra=0.35, tam=T, vertical=False):
    """Veta de madera: anillos ondulados + fibras finas. Devuelve (color RGB 0-255, altura 0-1)."""
    ondas = fbm(tam, tam, 3, 2, semilla, 4)
    y = np.arange(tam)[:, None] / tam
    fase = y * anillos + (ondas - 0.5) * torsion
    anillo = 0.5 + 0.5 * np.sin(fase * 2 * np.pi)
    anillo = anillo ** 2.2
    fibras = ruido(tam, tam, 6, 220, semilla + 3) * 0.6 + ruido(tam, tam, 12, 400, semilla + 5) * 0.4
    manchas = fbm(tam, tam, 4, 4, semilla + 9, 3)
    t = np.clip(anillo * 0.55 + (fibras - 0.5) * fibra + (manchas - 0.5) * 0.35 + 0.22, 0, 1)
    color = mezcla(hexa(claro), hexa(oscuro), t)
    altura = 1 - t * 0.6 - fibras * 0.4
    if vertical:
        color = np.transpose(color, (1, 0, 2))
        altura = altura.T
    return color, altura


def normales(altura, fuerza=2.0):
    """Mapa de normales (OpenGL: verde hacia arriba) a partir de una altura que se repite."""
    dx = (np.roll(altura, -1, axis=1) - np.roll(altura, 1, axis=1)) * fuerza
    dy = (np.roll(altura, -1, axis=0) - np.roll(altura, 1, axis=0)) * fuerza
    n = np.dstack([-dx, dy, np.ones_like(altura)])
    n /= np.linalg.norm(n, axis=2, keepdims=True)
    return ((n * 0.5 + 0.5) * 255).astype(np.uint8)


def guardar(nombre, color, altura=None, fuerza=2.0):
    os.makedirs(DESTINO, exist_ok=True)
    if isinstance(color, Image.Image):
        imagen = color
    else:
        imagen = Image.fromarray(np.clip(color, 0, 255).astype(np.uint8))
    imagen.save(os.path.join(DESTINO, nombre + ".png"), optimize=True)
    if altura is not None:
        Image.fromarray(normales(altura, fuerza)).save(os.path.join(DESTINO, nombre + "_n.png"), optimize=True)
    print("  ", nombre, imagen.size)


MADERAS = {
    # nombre: (claro, oscuro, semilla, anillos, torsión)
    "nogal": ("6b4a32", "2a1810", 11, 8, 1.4),
    "boj": ("e2c48c", "b08a52", 21, 12, 0.9),
    "cerezo": ("b0603a", "6a2a16", 31, 10, 1.1),
    "ebano": ("3a3230", "141010", 41, 14, 0.8),
    "arce": ("efe0c0", "c8b088", 51, 11, 1.0),
    "hinoki": ("e8cfa0", "c39a62", 61, 16, 0.7),
    "caoba": ("8a3a22", "3e140a", 71, 9, 1.3),
}


def tex_maderas():
    for nombre, salida in (("nogal", "madera_oscura"), ("boj", "madera_clara"), ("caoba", "caoba")):
        claro, oscuro, semilla, anillos, torsion = MADERAS[nombre]
        color, altura = madera(claro, oscuro, semilla, anillos, torsion)
        guardar(salida, color, altura, 1.6)


def tex_tablones():
    """Tablones del suelo: cuatro tablas por textura, cada una con su tono y sus juntas."""
    claro, oscuro, semilla, anillos, torsion = ("8a6a48", "3a2818", 81, 7, 1.5)
    color, altura = madera(claro, oscuro, semilla, anillos, torsion)
    filas = 4
    alto = T // filas
    tonos = [1.0, 0.86, 1.08, 0.93]
    for f in range(filas):
        tramo = slice(f * alto, (f + 1) * alto)
        color[tramo] *= tonos[f]
        desplaza = (f * 311) % T
        color[tramo] = np.roll(color[tramo], desplaza, axis=1)
        altura[tramo] = np.roll(altura[tramo], desplaza, axis=1)
        color[f * alto:f * alto + 3] *= 0.35
        altura[f * alto:f * alto + 3] -= 0.8
        junta = (f * 517 + 200) % T
        color[tramo, junta:junta + 3] *= 0.4
        altura[tramo, junta:junta + 3] -= 0.6
    guardar("tablones", color, altura, 2.5)


# --- Mosaicos yosegi ---------------------------------------------------------------------------

def paleta_yosegi():
    paleta = {}
    for nombre in ("nogal", "boj", "cerezo", "ebano", "arce", "hinoki"):
        claro, oscuro, semilla, anillos, torsion = MADERAS[nombre]
        for direccion in (False, True):
            color, altura = madera(claro, oscuro, semilla + (7 if direccion else 0), anillos * 2, torsion,
                                   vertical=direccion)
            paleta[(nombre, direccion)] = (color, altura)
    return paleta


def componer(indices, piezas, paleta, juntas):
    """indices: mapa (T, T) con el número de pieza; piezas: lista de (madera, vertical)."""
    color = np.zeros((T, T, 3))
    altura = np.zeros((T, T))
    for numero, (nombre, vertical) in enumerate(piezas):
        mascara = indices == numero
        if not mascara.any():
            continue
        c, h = paleta[(nombre, vertical)]
        color[mascara] = c[mascara]
        altura[mascara] = h[mascara] * 0.3 + 0.7
    junta = np.array(juntas) > 0
    color[junta] = color[junta] * 0.25 + np.array([30, 18, 10]) * 0.75
    altura[junta] -= 0.7
    return color, altura


def dibujar_poligonos(poligonos, escala=4):
    """Dibuja polígonos (lista de (puntos, número)) con repetición en los bordes. Devuelve
    (índices, juntas) a tamaño T."""
    grande = T * escala
    lienzo = Image.new("I", (grande, grande), 0)
    lineas = Image.new("L", (grande, grande), 0)
    d = ImageDraw.Draw(lienzo)
    dl = ImageDraw.Draw(lineas)
    for puntos, numero in poligonos:
        for ox in (-T, 0, T):
            for oy in (-T, 0, T):
                p = [((x + ox) * escala, (y + oy) * escala) for x, y in puntos]
                d.polygon(p, fill=int(numero))
                dl.line(p + [p[0]], fill=255, width=int(2.2 * escala))
    indices = np.array(lienzo.resize((T, T), Image.NEAREST))
    juntas = np.array(lineas.resize((T, T), Image.BILINEAR)) > 100
    return indices, juntas


def tex_asanoha(paleta):
    """Hoja de cáñamo: rejilla de triángulos y cada uno partido en tres desde su centro."""
    columnas, filas = 5, 6
    s = T / columnas
    h = T / filas
    poligonos = []
    for fila in range(-1, filas + 1):
        desplaza = (fila % 2) * s / 2
        for col in range(-1, columnas + 2):
            x0 = col * s + desplaza
            y0 = fila * h
            arriba = [(x0, y0 + h), (x0 + s, y0 + h), (x0 + s / 2, y0)]
            abajo = [(x0 + s / 2, y0), (x0 + s * 1.5, y0), (x0 + s, y0 + h)]
            for tri, base in ((arriba, 0), (abajo, 3)):
                cx = sum(p[0] for p in tri) / 3
                cy = sum(p[1] for p in tri) / 3
                for k in range(3):
                    poligonos.append(([tri[k], tri[(k + 1) % 3], (cx, cy)], 1 + base + k))
    indices, juntas = dibujar_poligonos(poligonos)
    piezas = [("ebano", False), ("boj", False), ("nogal", True), ("cerezo", False),
              ("cerezo", True), ("boj", True), ("ebano", True)]
    color, altura = componer(indices, piezas, paleta, juntas)
    guardar("yosegi_asanoha", color, altura, 3.0)


def tex_kikko(paleta):
    """Caparazón de tortuga: hexágonos con un hexágono dentro y un punto en el centro."""
    radio = T / 12            # 8 columnas de 1,5 radios = T
    paso_y = T / 7            # 7 filas (casi √3 radios: se aplasta un 1 %)
    k = paso_y / (math.sqrt(3) * radio)
    poligonos = []
    for col in range(-1, 10):
        for fila in range(-1, 9):
            cx = col * 1.5 * radio
            cy = fila * paso_y + (col % 2) * paso_y / 2
            for escala_h, numero in ((1.0, 1), (0.62, 2), (0.22, 3)):
                puntos = [(cx + radio * escala_h * math.cos(math.pi / 3 * j),
                           cy + radio * escala_h * math.sin(math.pi / 3 * j) * k) for j in range(6)]
                poligonos.append((puntos, numero))
    indices, juntas = dibujar_poligonos(poligonos)
    piezas = [("ebano", False), ("nogal", False), ("boj", True), ("cerezo", True)]
    color, altura = componer(indices, piezas, paleta, juntas)
    guardar("yosegi_kikko", color, altura, 3.0)


def tex_uroko(paleta):
    """Escamas: triángulos alternos claros y oscuros."""
    columnas, filas = 6, 6
    s = T / columnas
    h = T / filas
    poligonos = []
    for fila in range(-1, filas + 1):
        for col in range(-1, columnas + 2):
            x0 = col * s
            y0 = fila * h
            poligonos.append(([(x0, y0 + h), (x0 + s, y0 + h), (x0 + s / 2, y0)], 1))
            poligonos.append(([(x0 + s / 2, y0), (x0 + s * 1.5, y0), (x0 + s, y0 + h)], 2))
    indices, juntas = dibujar_poligonos(poligonos)
    piezas = [("ebano", False), ("arce", False), ("nogal", True)]
    color, altura = componer(indices, piezas, paleta, juntas)
    guardar("yosegi_uroko", color, altura, 3.0)


def tex_ichimatsu(paleta):
    """Damero de dos maderas, con la veta cruzada en casillas alternas."""
    n = 8
    s = T / n
    poligonos = []
    for i in range(n):
        for j in range(n):
            poligonos.append(([(i * s, j * s), ((i + 1) * s, j * s), ((i + 1) * s, (j + 1) * s), (i * s, (j + 1) * s)],
                              1 + (i + j) % 2))
    indices, juntas = dibujar_poligonos(poligonos)
    piezas = [("ebano", False), ("hinoki", False), ("nogal", True)]
    color, altura = componer(indices, piezas, paleta, juntas)
    guardar("yosegi_ichimatsu", color, altura, 3.0)


def tex_yabane(paleta):
    """Plumas de flecha: columnas de paralelogramos que se inclinan a un lado y al otro."""
    columnas = 8
    w = T / columnas
    alto = T / 8
    poligonos = []
    for col in range(-1, columnas + 1):
        sube = col % 2 == 0
        for fila in range(-2, 10):
            y0 = fila * alto
            inclina = alto * 0.5 if sube else -alto * 0.5
            puntos = [(col * w, y0), ((col + 1) * w, y0 + inclina), ((col + 1) * w, y0 + inclina + alto),
                      (col * w, y0 + alto)]
            poligonos.append((puntos, 1 + (fila % 2) + 2 * (col % 2)))
    indices, juntas = dibujar_poligonos(poligonos)
    piezas = [("ebano", False), ("boj", True), ("cerezo", True), ("arce", True), ("nogal", True)]
    color, altura = componer(indices, piezas, paleta, juntas)
    guardar("yosegi_yabane", color, altura, 3.0)


def tex_yosegi():
    paleta = paleta_yosegi()
    tex_asanoha(paleta)
    tex_kikko(paleta)
    tex_uroko(paleta)
    tex_ichimatsu(paleta)
    tex_yabane(paleta)


# --- Metales, piedra, cuero, papel --------------------------------------------------------------

def tex_laton():
    tam = 512
    base = hexa("c9a160")
    cepillado = ruido(tam, tam, 4, 300, 101) * 0.6 + ruido(tam, tam, 8, 600, 103) * 0.4
    patina = fbm(tam, tam, 5, 5, 107, 4)
    t = np.clip((cepillado - 0.5) * 0.35 + (patina - 0.5) * 0.9, -1, 1)
    color = base[None, None, :] * (1 + t[..., None] * 0.35)
    imagen = Image.fromarray(np.clip(color, 0, 255).astype(np.uint8))
    d = ImageDraw.Draw(imagen)
    azar = np.random.default_rng(109)
    for _ in range(90):
        x, y = azar.random(2) * tam
        largo = azar.random() * 60 + 10
        angulo = azar.random() * math.pi
        d.line([(x, y), (x + math.cos(angulo) * largo, y + math.sin(angulo) * largo)], fill=(235, 205, 150), width=1)
    altura = cepillado * 0.4 + patina * 0.6
    guardar("laton", imagen, altura, 1.0)


def tex_metal_ajeno():
    """Metal oscuro de la reliquia: paneles hexagonales con surcos finos."""
    radio = T / 12
    paso_y = T / 7
    k = paso_y / (math.sqrt(3) * radio)
    escala = 2
    lienzo = Image.new("L", (T * escala, T * escala), 0)
    d = ImageDraw.Draw(lienzo)
    for col in range(-1, 10):
        for fila in range(-1, 9):
            cx = col * 1.5 * radio
            cy = fila * paso_y + (col % 2) * paso_y / 2
            puntos = [(cx + radio * math.cos(math.pi / 3 * j), cy + radio * math.sin(math.pi / 3 * j) * k)
                      for j in range(6)]
            for ox in (-T, 0, T):
                for oy in (-T, 0, T):
                    p = [((x + ox) * escala, (y + oy) * escala) for x, y in puntos]
                    d.line(p + [p[0]], fill=255, width=3 * escala)
    surcos = np.array(lienzo.resize((T, T), Image.BILINEAR)) / 255.0
    manchas = fbm(T, T, 6, 6, 201, 4)
    rayas = ruido(T, T, 3, 180, 203)
    t = np.clip(manchas * 0.6 + rayas * 0.2, 0, 1)
    color = mezcla(hexa("1c2230"), hexa("3a4456"), t)
    color *= (1 - surcos[..., None] * 0.6)
    altura = 1 - surcos * 0.8 + manchas * 0.1
    guardar("metal_ajeno", color, altura, 3.0)


def tex_piedra():
    """Sillares de piedra para la pared del faro: 8 hiladas de 4 bloques, a matajunta."""
    filas, por_fila = 8, 4
    alto = T // filas
    ancho = T // por_fila
    yy, xx = np.mgrid[0:T, 0:T]
    fila = yy // alto
    desplaza = (fila % 2) * (ancho // 2) + (fila * 37) % 23
    xb = (xx + desplaza) % T
    bloque = xb // ancho
    dx = np.minimum(xb % ancho, ancho - 1 - xb % ancho)
    dy = np.minimum(yy % alto, alto - 1 - yy % alto)
    borde = np.minimum(dx, dy)
    numero = fila * por_fila + bloque
    tono = 0.8 + ((numero * 7919) % 17) / 17 * 0.32
    grano = fbm(T, T, 16, 16, 301, 5)
    manchas = fbm(T, T, 4, 4, 303, 3)
    color = mezcla(hexa("625e56"), hexa("a29c8e"), np.clip(grano * 0.7 + manchas * 0.3, 0, 1)) * tono[..., None]
    relieve = np.clip(borde / 12.0, 0, 1) ** 0.5
    altura = relieve * 0.8 + grano * 0.2
    junta = borde < 3
    color[junta] = hexa("2e2a26")
    altura[junta] = 0.0
    guardar("piedra", color, altura, 4.0)


def tex_cuero():
    tam = 512
    poros = ruido(tam, tam, 90, 90, 401) * 0.5 + ruido(tam, tam, 180, 180, 403) * 0.5
    manchas = fbm(tam, tam, 4, 4, 405, 4)
    t = np.clip(manchas * 0.7 + poros * 0.3, 0, 1)
    color = mezcla(hexa("1f3a2a"), hexa("3c6448"), t)
    guardar("cuero_verde", color, poros * 0.5 + manchas * 0.5, 1.5)


def papel_base(tam_x, tam_y, semilla, claro="efe4c8", oscuro="c8b48a"):
    fibras = ruido(tam_x, tam_y, 60, 200, semilla) * 0.5 + ruido(tam_x, tam_y, 200, 60, semilla + 1) * 0.5
    manchas = fbm(tam_x, tam_y, 3, 4, semilla + 2, 4)
    borde_x = np.minimum(np.arange(tam_x), tam_x - 1 - np.arange(tam_x)) / tam_x
    borde_y = np.minimum(np.arange(tam_y), tam_y - 1 - np.arange(tam_y)) / tam_y
    oscurecer = np.clip(1 - np.minimum(borde_x[None, :], borde_y[:, None]) * 8, 0, 1) ** 2
    t = np.clip(manchas * 0.6 + fibras * 0.2 + oscurecer * 0.5, 0, 1)
    return mezcla(hexa(claro), hexa(oscuro), t)


def tex_papel():
    guardar("papel", papel_base(512, 512, 501))


# --- Símbolos, ofuda, glifos ----------------------------------------------------------------------

def simbolo(nombre, dibujo):
    tam = 512
    imagen = Image.new("L", (tam, tam), 0)
    d = ImageDraw.Draw(imagen)
    dibujo(d, tam)
    imagen = imagen.resize((256, 256), Image.LANCZOS)
    rgba = Image.merge("RGBA", (Image.new("L", imagen.size, 255),) * 3 + (imagen,))
    guardar("simbolo_" + nombre, rgba)


def banda(d, puntos, grosor):
    """Trazo grueso y limpio: un polígono a lo largo de la curva (sin uniones con picos)."""
    izquierda, derecha = [], []
    for k, (x, y) in enumerate(puntos):
        x0, y0 = puntos[max(0, k - 1)]
        x1, y1 = puntos[min(len(puntos) - 1, k + 1)]
        dx, dy = x1 - x0, y1 - y0
        largo = math.hypot(dx, dy) or 1.0
        nx, ny = -dy / largo * grosor / 2, dx / largo * grosor / 2
        izquierda.append((x + nx, y + ny))
        derecha.append((x - nx, y - ny))
    d.polygon(izquierda + derecha[::-1], fill=255)
    for x, y in (puntos[0], puntos[-1]):
        d.ellipse([x - grosor / 2, y - grosor / 2, x + grosor / 2, y + grosor / 2], fill=255)


def tex_simbolos():
    def luna(d, t):
        d.ellipse([t * 0.14, t * 0.14, t * 0.86, t * 0.86], fill=255)
        d.ellipse([t * 0.32, t * 0.06, t * 0.98, t * 0.72], fill=0)

    def llama(d, t):
        # bulbo redondo abajo y punta arriba, con una curva en S; lengua interior hueca
        def silueta(cx, cy, radio, alto, curva):
            derecha = [(cx + radio * math.sin(v * math.pi / 2) ** 1.4 - curva * radio * math.sin(v * math.pi),
                        cy - alto + v * alto) for v in (k / 24 for k in range(25))]
            abajo = [(cx + radio * math.cos(a), cy + radio * math.sin(a)) for a in (k / 24 * math.pi for k in range(1, 24))]
            izquierda = [(cx - radio * math.sin(v * math.pi / 2) ** 1.4 - curva * 0.6 * radio * math.sin(v * math.pi),
                          cy - alto + v * alto) for v in (k / 24 for k in range(24, -1, -1))]
            return derecha + abajo + izquierda
        d.polygon(silueta(t * 0.5, t * 0.64, t * 0.22, t * 0.54, 0.35), fill=255)
        d.polygon(silueta(t * 0.5, t * 0.72, t * 0.08, t * 0.22, 0.3), fill=0)

    def ola(d, t):
        for fila in range(3):
            y = t * (0.3 + fila * 0.2)
            puntos = [(t * (0.12 + 0.76 * k / 80), y + math.sin(k / 80 * 2 * math.pi * 1.5 + 0.6) * t * 0.055)
                      for k in range(81)]
            banda(d, puntos, t * 0.07)

    def monte(d, t):
        d.polygon([(t * 0.06, t * 0.82), (t * 0.4, t * 0.2), (t * 0.74, t * 0.82)], fill=255)
        d.polygon([(t * 0.46, t * 0.82), (t * 0.7, t * 0.4), (t * 0.94, t * 0.82)], fill=255)

    for nombre, dibujo in (("luna", luna), ("llama", llama), ("ola", ola), ("monte", monte)):
        simbolo(nombre, dibujo)


def pincelada(d, azar, x, y, largo, angulo, grosor, color):
    puntos = []
    for k in range(12):
        t = k / 11
        puntos.append((x + math.cos(angulo) * largo * t + math.sin(t * 3) * grosor * 0.3,
                       y + math.sin(angulo) * largo * t))
    for k in range(len(puntos) - 1):
        ancho = int(grosor * (1 - abs(k / len(puntos) - 0.35)) + 1)
        d.line([puntos[k], puntos[k + 1]], fill=color, width=max(1, ancho))


def tex_ofuda():
    """Ofuda (talismán de papel): «百年封印» (sello de cien años) en vertical y un sello rojo."""
    ancho, alto = 256, 768
    color = papel_base(ancho, alto, 601, "f4eedc", "d8ccae")
    imagen = Image.fromarray(np.clip(color, 0, 255).astype(np.uint8))
    d = ImageDraw.Draw(imagen)
    d.rectangle([10, 10, ancho - 11, alto - 11], outline=(170, 30, 24), width=5)
    tinta = Image.new("L", (ancho, alto), 0)
    dt = ImageDraw.Draw(tinta)
    letra = fuente("fonts-japanese-gothic.ttf", 118)
    for k, caracter in enumerate("百年封印"):
        caja = dt.textbbox((0, 0), caracter, font=letra)
        dt.text((ancho / 2 - (caja[2] - caja[0]) / 2 - caja[0], 50 + k * 128), caracter, fill=255, font=letra)
    tinta = tinta.filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.GaussianBlur(1.2))
    grumos = (ruido(ancho, alto, 40, 120, 605) * 255).astype(np.uint8)
    tinta = Image.fromarray((np.array(tinta) * (0.75 + grumos / 1020)).astype(np.uint8))
    imagen.paste(Image.new("RGB", (ancho, alto), (20, 14, 12)), (0, 0), tinta)
    # sello rojo en negativo: el carácter «霊» (espíritu) en blanco dentro del cuadrado
    d.rectangle([ancho / 2 - 44, alto - 200, ancho / 2 + 44, alto - 112], fill=(186, 36, 28))
    d.rectangle([ancho / 2 - 38, alto - 194, ancho / 2 + 38, alto - 118], outline=(240, 222, 200), width=3)
    sello = fuente("fonts-japanese-gothic.ttf", 64)
    caja = d.textbbox((0, 0), "霊", font=sello)
    d.text((ancho / 2 - (caja[2] - caja[0]) / 2 - caja[0], alto - 156 - (caja[3] - caja[1]) / 2 - caja[1]), "霊",
           fill=(244, 230, 210), font=sello)
    guardar("ofuda", imagen)


def tex_glifos():
    """Tira de 8 glifos de la reliquia (blanco sobre negro: se usa como emisión)."""
    tam = 128
    imagen = Image.new("L", (tam * 8, tam), 0)
    d = ImageDraw.Draw(imagen)
    azar = np.random.default_rng(701)
    for g in range(8):
        x0 = g * tam
        d.ellipse([x0 + 14, 14, x0 + tam - 14, tam - 14], outline=255, width=5)
        for _ in range(3):
            a = azar.uniform(0, 2 * math.pi)
            b = a + azar.uniform(1.2, 3.0)
            r1, r2 = azar.uniform(10, 26), azar.uniform(28, 46)
            d.line([(x0 + tam / 2 + math.cos(a) * r1, tam / 2 + math.sin(a) * r1),
                    (x0 + tam / 2 + math.cos(b) * r2, tam / 2 + math.sin(b) * r2)], fill=255, width=6)
        d.ellipse([x0 + tam / 2 - 8, tam / 2 - 8, x0 + tam / 2 + 8, tam / 2 + 8], fill=255)
    imagen = imagen.filter(ImageFilter.GaussianBlur(0.8))
    guardar("glifos", Image.merge("RGB", (imagen,) * 3))


def fuente(nombre, tamano):
    return ImageFont.truetype(os.path.join(FUENTES, nombre), tamano)


def tex_esfera_reloj():
    """Esfera de esmalte con números romanos, envejecida."""
    tam = 1024
    color = papel_base(tam, tam, 801, "f3ead6", "cfc0a0")
    imagen = Image.fromarray(np.clip(color, 0, 255).astype(np.uint8))
    d = ImageDraw.Draw(imagen)
    c = tam / 2
    d.ellipse([12, 12, tam - 12, tam - 12], outline=(60, 44, 30), width=10)
    d.ellipse([60, 60, tam - 60, tam - 60], outline=(60, 44, 30), width=3)
    for k in range(60):
        a = k / 60 * 2 * math.pi
        largo = 34 if k % 5 == 0 else 16
        r = c - 64
        d.line([(c + math.sin(a) * r, c - math.cos(a) * r), (c + math.sin(a) * (r - largo), c - math.cos(a) * (r - largo))],
               fill=(40, 28, 20), width=6 if k % 5 == 0 else 3)
    letra = fuente("liberation/LiberationSerif-Bold.ttf", 96)
    romanos = ["XII", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI"]
    for k, texto in enumerate(romanos):
        a = k / 12 * 2 * math.pi
        r = c - 190
        x = c + math.sin(a) * r
        y = c - math.cos(a) * r
        caja = d.textbbox((0, 0), texto, font=letra)
        d.text((x - (caja[2] - caja[0]) / 2, y - (caja[3] - caja[1]) / 2 - caja[1]), texto, fill=(36, 24, 16), font=letra)
    pequena = fuente("liberation/LiberationSerif-Italic.ttf", 38)
    for texto, y in (("E. Whitcombe", c - 150), ("Londres · 1889", c + 110)):
        caja = d.textbbox((0, 0), texto, font=pequena)
        d.text((c - (caja[2] - caja[0]) / 2, y), texto, fill=(70, 50, 34), font=pequena)
    mascara = Image.new("L", (tam, tam), 0)
    ImageDraw.Draw(mascara).ellipse([8, 8, tam - 8, tam - 8], fill=255)
    imagen.putalpha(mascara)
    guardar("esfera_reloj", imagen)


def tex_carta():
    """Carta manuscrita (renglones de tinta ilegibles a lo lejos) y billete de tren."""
    ancho, alto = 512, 704
    imagen = Image.fromarray(np.clip(papel_base(ancho, alto, 901, "f1e6cc", "cdb98f"), 0, 255).astype(np.uint8))
    d = ImageDraw.Draw(imagen)
    letra = fuente("liberation/LiberationSerif-Italic.ttf", 30)
    lineas = ["Querido Arthur:", "", "Si esta caja ha llegado", "a tus manos, es que no", "he vuelto. No la fuerces:",
              "dale cuerda y escucha.", "", "Te escribo a las tres", "en punto, la hora a la", "que todo empezó.", "",
              "            E. Whitcombe"]
    for k, linea in enumerate(lineas):
        d.text((48, 50 + k * 50), linea, fill=(40, 30, 50), font=letra)
    guardar("carta", imagen)
    ancho, alto = 512, 256
    imagen = Image.fromarray(np.clip(papel_base(ancho, alto, 903, "e9dcb8", "c2a878"), 0, 255).astype(np.uint8))
    d = ImageDraw.Draw(imagen)
    d.rectangle([10, 10, ancho - 11, alto - 11], outline=(120, 60, 40), width=4)
    negrita = fuente("liberation/LiberationSerif-Bold.ttf", 34)
    normal = fuente("liberation/LiberationSerif-Regular.ttf", 28)
    d.text((32, 24), "GREAT NORTHERN RAILWAY", fill=(110, 40, 30), font=negrita)
    d.text((32, 80), "Londres  →  Whitby", fill=(40, 30, 30), font=normal)
    d.text((32, 124), "Salida: 9:45", fill=(40, 30, 30), font=negrita)
    d.text((32, 176), "12 nov. 1891 · 3.ª clase", fill=(60, 50, 40), font=normal)
    guardar("billete", imagen)


def tex_diario():
    """Diario del farero abierto: dos páginas con renglones manuscritos."""
    ancho, alto = 1024, 640
    imagen = Image.fromarray(np.clip(papel_base(ancho, alto, 1001, "efe3c4", "c9b386"), 0, 255).astype(np.uint8))
    d = ImageDraw.Draw(imagen)
    d.line([(ancho / 2, 0), (ancho / 2, alto)], fill=(150, 120, 80), width=6)
    letra = fuente("liberation/LiberationSerif-Italic.ttf", 30)
    izquierda = ["12 de noviembre de 1903", "Viento del noroeste. Mar", "gruesa. Lámpara encendida", "a las cinco y media.", "",
                 "13 de noviembre", "Segundo día de tormenta.", "Queda poco aceite."]
    derecha = ["14 de noviembre", "El barco del correo llega", "esta noche. El candado:", "el año en que se encendió", "este faro.",
               "La llave, donde guardo a", "los grandes: entre Fresnel", "y Stevenson."]
    for k, linea in enumerate(izquierda):
        d.text((50, 50 + k * 64), linea, fill=(38, 30, 46), font=letra)
    for k, linea in enumerate(derecha):
        d.text((ancho / 2 + 40, 50 + k * 64), linea, fill=(38, 30, 46), font=letra)
    guardar("diario", imagen)


TODAS = {
    "maderas": tex_maderas,
    "tablones": tex_tablones,
    "yosegi": tex_yosegi,
    "laton": tex_laton,
    "metal_ajeno": tex_metal_ajeno,
    "piedra": tex_piedra,
    "cuero": tex_cuero,
    "papel": tex_papel,
    "simbolos": tex_simbolos,
    "ofuda": tex_ofuda,
    "glifos": tex_glifos,
    "esfera_reloj": tex_esfera_reloj,
    "carta": tex_carta,
    "diario": tex_diario,
}


def main():
    nombres = sys.argv[1:] or list(TODAS)
    for nombre in nombres:
        print(nombre)
        TODAS[nombre]()


if __name__ == "__main__":
    main()
