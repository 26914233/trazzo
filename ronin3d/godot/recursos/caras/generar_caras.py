#!/usr/bin/env python3
"""Dibuja las caras de los personajes de RONIN: ojos, cejas, nariz, boca y barba de pocos días.

Es la técnica de los juegos de anime en 3D: la cabeza es una forma sencilla y los rasgos van
pintados en una imagen 2D que el shader (shaders/toon_cara.gdshader) proyecta desde delante.
Así los ojos se ven como un dibujo y no como cajitas.

Cada imagen cubre el recuadro de la cara en el espacio de la cabeza (en metros):
x de -0,12 a 0,12 e y de -0,13 a 0,11; vista de frente, el lado izquierdo de la imagen es el
lado derecho del personaje. El canal alfa dice dónde hay rasgo; el resto es piel.

Uso:  python3 generar_caras.py     (escribe cara_<id>.png junto a este archivo)
Si cambian las imágenes, Godot las vuelve a importar solo (o con «godot --headless --import»).
"""

import math
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

TAMANO = 256                 # píxeles de la imagen final
SUPER = 4                    # se dibuja a 4 veces el tamaño y se reduce: trazos suaves
X0, Y1 = -0.12, 0.11         # esquina de arriba a la izquierda del recuadro (metros)
LADO = 0.24                  # ancho y alto del recuadro (metros)

TINTA = (22, 17, 24)
BLANCO_OJO = (246, 241, 230)
IRIS = (44, 30, 30)
PUPILA = (10, 8, 10)
BRILLO = (255, 255, 252)

CARAS = {
    # Akira joven endurecido: ojos rasgados y duros, cejas en ceño, boca recta.
    "joven": {"piel": (220, 180, 142), "pelo": (20, 18, 24), "ojo": 1.0, "abierto": 1.0,
              "ceja": 1.0, "edad": 0, "pestanas": False, "barba": "", "boca": 1.0},
    # Curtido (unos 30): párpados más caídos, cejas gruesas y barba de pocos días.
    "curtido": {"piel": (201, 160, 122), "pelo": (26, 22, 20), "ojo": 1.0, "abierto": 0.82,
                "ceja": 1.25, "edad": 1, "pestanas": False, "barba": "de_dias", "boca": 1.1},
    # Veterano (unos 40): cejas grises, patas de gallo, surcos junto a la boca y bigote.
    "veterano": {"piel": (196, 156, 120), "pelo": (96, 96, 106), "ojo": 0.95, "abierto": 0.78,
                 "ceja": 1.3, "edad": 2, "pestanas": False, "barba": "corta", "boca": 1.1},
    # Akira mujer: ojos algo mayores con pestañas y rabillo, cejas finas, boca pequeña.
    "mujer": {"piel": (226, 188, 152), "pelo": (20, 18, 24), "ojo": 1.08, "abierto": 1.08,
              "ceja": 0.75, "edad": 0, "pestanas": True, "barba": "", "boca": 0.8},
}


def a_pixel(punto):
    """De metros (espacio de la cabeza) a píxeles de la imagen grande."""
    x, y = punto
    escala = TAMANO * SUPER / LADO
    return ((x - X0) * escala, (Y1 - y) * escala)


def bezier(p0, p1, p2, pasos=24):
    """Curva cuadrática de p0 a p2 con el punto de control p1."""
    puntos = []
    for i in range(pasos + 1):
        t = i / pasos
        a, b, c = (1 - t) ** 2, 2 * (1 - t) * t, t * t
        puntos.append((a * p0[0] + b * p1[0] + c * p2[0], a * p0[1] + b * p1[1] + c * p2[1]))
    return puntos


def trazo(dibujo, puntos, grosores, color):
    """Pincelada: sigue los puntos y su grosor (metros) va de grosores[0] a grosores[-1],
    pasando por los del medio si los hay. Las puntas finas le dan aire de tinta."""
    n = len(puntos)
    izquierda, derecha = [], []
    for i, (x, y) in enumerate(puntos):
        t = i / (n - 1)
        posicion = t * (len(grosores) - 1)
        k = min(int(posicion), len(grosores) - 2)
        grosor = grosores[k] + (grosores[k + 1] - grosores[k]) * (posicion - k)
        anterior = puntos[max(i - 1, 0)]
        siguiente = puntos[min(i + 1, n - 1)]
        dx, dy = siguiente[0] - anterior[0], siguiente[1] - anterior[1]
        largo = math.hypot(dx, dy) or 1.0
        nx, ny = -dy / largo, dx / largo
        izquierda.append((x + nx * grosor / 2, y + ny * grosor / 2))
        derecha.append((x - nx * grosor / 2, y - ny * grosor / 2))
    contorno = izquierda + derecha[::-1]
    dibujo.polygon([a_pixel(p) for p in contorno], fill=color)


def circulo(dibujo, centro, radio, color, radio_y=None):
    x, y = a_pixel(centro)
    escala = TAMANO * SUPER / LADO
    rx, ry = radio * escala, (radio_y or radio) * escala
    dibujo.ellipse((x - rx, y - ry, x + rx, y + ry), fill=color)


def capa():
    return Image.new("RGBA", (TAMANO * SUPER, TAMANO * SUPER), (0, 0, 0, 0))


def oscurecer(color, cantidad):
    return tuple(int(c * (1 - cantidad)) for c in color[:3])


def ojo(imagen, centro, s, d):
    """Un ojo. s = 1 para el del lado +x (el izquierdo del personaje), -1 para el otro;
    el rabillo (la esquina de fuera) está hacia s."""
    cx, cy = centro
    tam = d["ojo"]
    ancho = 0.046 * tam
    abierto = d["abierto"]
    interior = (cx - s * ancho * 0.47, cy - 0.003 * tam)
    exterior = (cx + s * ancho * 0.53, cy + 0.007 * tam)      # rabillo hacia arriba: mirada dura
    control_arriba = (cx + s * ancho * 0.05, cy + 0.017 * tam * abierto)
    control_abajo = (cx + s * ancho * 0.1, cy - 0.01 * tam * abierto)
    arriba = bezier(interior, control_arriba, exterior)
    abajo = bezier(interior, control_abajo, exterior)

    # Blanco del ojo, y el iris recortado por él
    blanco = capa()
    ImageDraw.Draw(blanco).polygon([a_pixel(p) for p in arriba + abajo[::-1]], fill=BLANCO_OJO + (255,))
    iris = capa()
    dibujo_iris = ImageDraw.Draw(iris)
    centro_iris = (cx - s * 0.0015, cy + 0.002 * tam)
    circulo(dibujo_iris, centro_iris, 0.0095 * tam, IRIS + (255,), 0.0102 * tam)
    circulo(dibujo_iris, centro_iris, 0.0045 * tam, PUPILA + (255,))
    circulo(dibujo_iris, (centro_iris[0] - 0.003, centro_iris[1] + 0.0035), 0.0022 * tam, BRILLO + (255,))
    mascara = blanco.getchannel("A")
    iris.putalpha(Image.fromarray(np.minimum(np.array(iris.getchannel("A")), np.array(mascara))))
    blanco.alpha_composite(iris)
    imagen.alpha_composite(blanco)

    lineas = capa()
    dibujo = ImageDraw.Draw(lineas)
    # Párpado de arriba: el trazo grueso que hace la mirada, más fino en el lagrimal
    alargado = arriba + [(exterior[0] + s * 0.004 * tam, exterior[1] + 0.0015 * tam)]
    trazo(dibujo, alargado, [0.0022, 0.0042, 0.0048, 0.0016], TINTA + (255,))
    if d["pestanas"]:
        # rabillo y dos pestañas hacia fuera
        trazo(dibujo, [exterior, (exterior[0] + s * 0.009, exterior[1] + 0.006)], [0.004, 0.0008], TINTA + (255,))
        for t, largo in ((0.75, 0.006), (0.88, 0.007)):
            base = arriba[int(t * (len(arriba) - 1))]
            trazo(dibujo, [base, (base[0] + s * largo * 0.6, base[1] + largo)], [0.0022, 0.0005], TINTA + (255,))
    # Párpado de abajo: solo la mitad de fuera, fino
    trazo(dibujo, abajo[len(abajo) // 2:], [0.0006, 0.0016, 0.0008], TINTA + (230,))
    if d["edad"] >= 1:
        # pliegue del párpado (cansancio)
        pliegue = bezier((cx - s * ancho * 0.25, cy + 0.0125 * tam), (cx + s * ancho * 0.1, cy + 0.02 * tam),
                         (cx + s * ancho * 0.48, cy + 0.0135 * tam), 12)
        trazo(dibujo, pliegue, [0.0004, 0.0012, 0.0004], oscurecer(d["piel"], 0.45) + (200,))
    if d["edad"] >= 2:
        # patas de gallo
        for giro in (-0.35, 0.15):
            inicio = (exterior[0] + s * 0.004, exterior[1] - 0.002)
            fin = (inicio[0] + s * 0.009 * math.cos(giro), inicio[1] + 0.009 * math.sin(giro))
            trazo(dibujo, [inicio, fin], [0.0012, 0.0003], oscurecer(d["piel"], 0.45) + (210,))
    imagen.alpha_composite(lineas)

    # Ceja en ceño: la punta de dentro más baja y gruesa
    ceja = capa()
    grosor = 0.0085 * d["ceja"]
    curva = bezier((cx - s * 0.025, cy + 0.0115), (cx + s * 0.002, cy + 0.0245), (cx + s * 0.032, cy + 0.0245), 16)
    trazo(ImageDraw.Draw(ceja), curva, [grosor, grosor * 0.85, grosor * 0.3], oscurecer(d["pelo"], 0.1) + (255,))
    imagen.alpha_composite(ceja)


def barba_de_dias(imagen, d):
    """Sombra de barba en la mandíbula y la barbilla, con un punteado encima."""
    tono = tuple(int(p * 0.62 + q * 0.38) for p, q in zip(d["piel"], (70, 76, 96)))
    mancha = capa()
    dibujo = ImageDraw.Draw(mancha)
    # mandíbula: una media luna que deja libre la mejilla alta
    circulo(dibujo, (0.0, -0.118), 0.118, tono + (125,), 0.064)
    circulo(dibujo, (0.0, -0.062), 0.072, (0, 0, 0, 0), 0.02)          # el labio de arriba, más claro
    mancha = mancha.filter(ImageFilter.GaussianBlur(radius=SUPER * 3))
    imagen.alpha_composite(mancha)
    puntos = capa()
    dibujo = ImageDraw.Draw(puntos)
    azar = np.random.default_rng(7)
    for _ in range(200):
        x = azar.uniform(-0.11, 0.11)
        y = azar.uniform(-0.18, -0.07)
        if (x / 0.11) ** 2 + ((y + 0.118) / 0.062) ** 2 > 1.0 or abs(x) < 0.03 and y > -0.085:
            continue
        circulo(dibujo, (x, y), 0.0011, oscurecer(tono, 0.35) + (200,))
    imagen.alpha_composite(puntos)


def bigote(imagen, d):
    """Bigote corto del veterano, del color del pelo (la barba es de mechones 3D)."""
    capa_bigote = capa()
    dibujo = ImageDraw.Draw(capa_bigote)
    color = d["pelo"] + (255,)
    for s in (-1, 1):
        curva = bezier((s * 0.002, -0.064), (s * 0.02, -0.062), (s * 0.034, -0.084), 12)
        trazo(dibujo, curva, [0.007, 0.0065, 0.0015], color)
    imagen.alpha_composite(capa_bigote)


def cara(d):
    imagen = capa()
    if d["barba"] == "de_dias":
        barba_de_dias(imagen, d)
    for s in (-1, 1):
        ojo(imagen, (s * 0.052, -0.008), s, d)
    rasgos = capa()
    dibujo = ImageDraw.Draw(rasgos)
    sombra = oscurecer(d["piel"], 0.42)
    # Nariz: una línea en el lado de la sombra y la punta
    trazo(dibujo, bezier((0.004, -0.022), (0.0, -0.036), (-0.004, -0.047), 10), [0.0005, 0.0016, 0.002], sombra + (190,))
    trazo(dibujo, [(-0.004, -0.0475), (0.003, -0.049), (0.007, -0.047)], [0.002, 0.0016, 0.0006], sombra + (210,))
    if d["edad"] >= 2:
        # surcos de la nariz a la boca
        for s in (-1, 1):
            trazo(dibujo, bezier((s * 0.02, -0.05), (s * 0.034, -0.066), (s * 0.033, -0.088), 10),
                  [0.0004, 0.0014, 0.0003], sombra + (170,))
    imagen.alpha_composite(rasgos)
    if d["barba"] == "corta":
        bigote(imagen, d)
    # Boca: una línea recta con las comisuras algo hacia abajo
    boca = capa()
    ancho = 0.015 * d["boca"]
    color_boca = oscurecer(d["piel"], 0.55)
    trazo(ImageDraw.Draw(boca), bezier((-ancho, -0.081), (0.0, -0.0785), (ancho, -0.0815), 12),
          [0.0006, 0.0019, 0.0006], color_boca + (235,))
    if d["pestanas"]:
        # labio de abajo, apenas insinuado
        trazo(ImageDraw.Draw(boca), bezier((-0.006, -0.0865), (0.0, -0.088), (0.006, -0.0865), 8),
              [0.0003, 0.0011, 0.0003], (178, 92, 86, 150))
    imagen.alpha_composite(boca)
    return imagen


def cara_soldado():
    """Soldado de Genzo: la sombra del sombrero le tapa los ojos y solo se ven dos rendijas
    claras, como a los enemigos del anime. La boca la tapa la máscara (menpō)."""
    imagen = capa()
    sombra = capa()
    dibujo = ImageDraw.Draw(sombra)
    dibujo.rectangle((*a_pixel((-0.2, 0.06)), *a_pixel((0.2, -0.02))), fill=(34, 20, 24, 240))
    sombra = sombra.filter(ImageFilter.GaussianBlur(radius=SUPER * 2))
    imagen.alpha_composite(sombra)
    ojos = capa()
    dibujo = ImageDraw.Draw(ojos)
    for s in (-1, 1):
        interior = (s * 0.02, -0.007)
        exterior = (s * 0.074, 0.009)
        arriba = bezier(interior, (s * 0.046, 0.006), exterior, 12)
        abajo = bezier(interior, (s * 0.05, -0.012), exterior, 12)
        dibujo.polygon([a_pixel(p) for p in arriba + abajo[::-1]], fill=(240, 228, 200, 255))
        circulo(dibujo, (s * 0.04, -0.0015), 0.0052, PUPILA + (255,), 0.006)
        trazo(dibujo, arriba + [(exterior[0] + s * 0.004, exterior[1] + 0.002)], [0.002, 0.0035, 0.001], TINTA + (255,))
    imagen.alpha_composite(ojos)
    return imagen


def reducir(imagen):
    """Reduce la imagen grande con el alfa premultiplicado (si no, los bordes salen negros)."""
    datos = np.asarray(imagen).astype(np.float32) / 255.0
    alfa = datos[..., 3:4]
    premultiplicado = np.concatenate([datos[..., :3] * alfa, alfa], axis=-1)
    canales = []
    for i in range(4):
        canal = Image.fromarray(premultiplicado[..., i], mode="F")
        canales.append(np.asarray(canal.resize((TAMANO, TAMANO), Image.BOX)))
    resultado = np.stack(canales, axis=-1)
    alfa = resultado[..., 3:4]
    color = np.where(alfa > 1e-4, resultado[..., :3] / np.maximum(alfa, 1e-4), 0.0)
    final = np.concatenate([np.clip(color, 0, 1), np.clip(alfa, 0, 1)], axis=-1)
    return Image.fromarray((final * 255.0 + 0.5).astype(np.uint8), mode="RGBA")


def main():
    carpeta = os.path.dirname(os.path.abspath(__file__))
    for nombre, datos in CARAS.items():
        reducir(cara(datos)).save(os.path.join(carpeta, f"cara_{nombre}.png"))
    reducir(cara_soldado()).save(os.path.join(carpeta, "cara_soldado.png"))
    print("Caras escritas en", carpeta)


if __name__ == "__main__":
    main()
