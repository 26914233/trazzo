# -*- coding: utf-8 -*-
"""
Genera los sprites y texturas pixel art que comparten todas las versiones 3D de RONIN.

    python generar_recursos.py            -> escribe los PNG en esta carpeta
    python generar_recursos.py --muestra  -> además, una hoja ampliada para revisarlos

Hojas de personaje (ver DISENO_3D.md, sección 9):
    akira.png    cuadros de 48 x 48, rejilla 5 columnas x 3 filas
    soldado.png  cuadros de 64 x 48, rejilla 5 columnas x 3 filas
    Filas: 0 frente, 1 espalda, 2 lado (mirando a la derecha).
    Columnas Akira:   quieto, paso A, paso B, espada alzada, tajo.
    Columnas soldado: quieto, paso A, paso B, preparando, estocada.

Todo se dibuja a tamaño real, sin suavizado, y se le pone un contorno oscuro de 1 px.
"""

import math
import os
import random
import sys

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
import pygame  # noqa: E402

CARPETA = os.path.dirname(os.path.abspath(__file__))

# --- Paleta (DISENO_3D.md, sección 10) --------------------------------------
CONTORNO = (14, 11, 20)
PIEL = (228, 190, 152)
PIEL_SOMBRA = (196, 150, 118)
PELO = (20, 18, 24)
PELO_BRILLO = (58, 54, 74)
KIMONO = (52, 66, 118)
KIMONO_CLARO = (74, 92, 150)
KIMONO_OSCURO = (34, 44, 84)
HAKAMA = (34, 36, 58)
HAKAMA_CLARO = (52, 56, 84)
HAKAMA_OSCURO = (22, 23, 38)
OBI = (160, 46, 42)
OBI_OSCURO = (112, 30, 30)
HACHIMAKI = (238, 238, 242)
HACHIMAKI_SOMBRA = (186, 188, 204)
TABI = (222, 222, 226)
ZORI = (70, 52, 40)
ACERO = (224, 232, 246)
ACERO_SOMBRA = (150, 160, 184)
TSUKA = (206, 194, 164)
TSUKA_OSCURO = (120, 100, 80)
TSUBA = (196, 156, 72)
SAYA = (70, 26, 30)

ARMADURA = (126, 42, 36)
ARMADURA_CLARA = (168, 72, 58)
ARMADURA_OSCURA = (84, 26, 24)
SOMBRERO = (92, 74, 50)
SOMBRERO_CLARO = (130, 108, 74)
SOMBRERO_OSCURO = (60, 46, 30)
PANTALON = (58, 56, 66)
PANTALON_OSCURO = (38, 36, 46)
ESPINILLERA = (44, 42, 50)
MADERA_LANZA = (122, 88, 54)
MADERA_LANZA_OSCURA = (86, 60, 36)

TRANSPARENTE = (0, 0, 0, 0)


# =============================================================================
# Utilidades de dibujo pixel a pixel
# =============================================================================

def lienzo(ancho, alto):
    superficie = pygame.Surface((ancho, alto), pygame.SRCALPHA)
    superficie.fill(TRANSPARENTE)
    return superficie


def rect(sup, color, x, y, ancho, alto):
    pygame.draw.rect(sup, color, (int(x), int(y), int(ancho), int(alto)))


def punto(sup, color, x, y):
    if 0 <= x < sup.get_width() and 0 <= y < sup.get_height():
        sup.set_at((int(x), int(y)), color)


def linea(sup, color, x0, y0, x1, y1, grosor=1):
    """Línea de Bresenham (sin suavizado); grosor extiende en horizontal."""
    x0, y0, x1, y1 = int(round(x0)), int(round(y0)), int(round(x1)), int(round(y1))
    dx, dy = abs(x1 - x0), -abs(y1 - y0)
    sx, sy = (1 if x0 < x1 else -1), (1 if y0 < y1 else -1)
    error = dx + dy
    while True:
        for k in range(grosor):
            punto(sup, color, x0 + k, y0)
        if x0 == x1 and y0 == y1:
            break
        e2 = 2 * error
        if e2 >= dy:
            error += dy
            x0 += sx
        if e2 <= dx:
            error += dx
            y0 += sy


def poligono(sup, color, puntos):
    pygame.draw.polygon(sup, color, [(int(x), int(y)) for x, y in puntos])


def elipse(sup, color, x, y, ancho, alto):
    pygame.draw.ellipse(sup, color, (int(x), int(y), int(ancho), int(alto)))


def contornear(sup, color=CONTORNO):
    """Añade 1 px de contorno oscuro alrededor de todo lo opaco (estilo pixel art)."""
    ancho, alto = sup.get_size()
    opaco = [[sup.get_at((x, y)).a > 0 for x in range(ancho)] for y in range(alto)]
    for y in range(alto):
        for x in range(ancho):
            if opaco[y][x]:
                continue
            for vx, vy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + vx, y + vy
                if 0 <= nx < ancho and 0 <= ny < alto and opaco[ny][nx]:
                    sup.set_at((x, y), color)
                    break
    return sup


# =============================================================================
# Akira (cuadros de 48 x 48, centro x = 24, pies en y = 47)
# =============================================================================

def _akira_piernas_frente(s, cx, paso):
    """Hakama y pies vistos de frente o de espaldas. paso: -1, 0 o 1."""
    poligono(s, HAKAMA, [(cx - 7, 33), (cx + 6, 33), (cx + 9, 45), (cx - 10, 45)])
    rect(s, HAKAMA_OSCURO, cx - 1, 37, 1, 9)              # separación de piernas
    for x in (cx - 5, cx + 3):                            # pliegues
        linea(s, HAKAMA_CLARO, x, 35, x - (1 if x < cx else -1), 44)
    rect(s, HAKAMA_OSCURO, cx + 5, 34, 2, 11)             # sombra lateral
    alto_izq = 1 if paso == 1 else 0
    alto_der = 1 if paso == -1 else 0
    rect(s, TABI, cx - 8, 45 - alto_izq, 5, 2)
    rect(s, TABI, cx + 2, 45 - alto_der, 5, 2)
    rect(s, ZORI, cx - 8, 47 - alto_izq, 5, 1)
    rect(s, ZORI, cx + 2, 47 - alto_der, 5, 1)


def _akira_torso_frente(s, cx, balanceo, espalda=False):
    # mangas (detrás del torso)
    rect(s, KIMONO_OSCURO, cx - 10, 21 + balanceo, 4, 9)
    rect(s, KIMONO_OSCURO, cx + 6, 21 - balanceo, 4, 9)
    rect(s, PIEL, cx - 10, 30 + balanceo, 3, 2)
    rect(s, PIEL, cx + 7, 30 - balanceo, 3, 2)
    # torso
    rect(s, KIMONO, cx - 7, 20, 14, 12)
    rect(s, KIMONO_CLARO, cx - 7, 20, 3, 11)              # luz a la izquierda
    rect(s, KIMONO_OSCURO, cx + 5, 20, 2, 12)             # sombra a la derecha
    if not espalda:
        poligono(s, PIEL, [(cx - 2, 20), (cx + 2, 20), (cx, 24)])
        linea(s, HACHIMAKI, cx - 3, 20, cx, 26)
        linea(s, HACHIMAKI, cx + 3, 20, cx, 26)
    # obi
    rect(s, OBI, cx - 7, 30, 14, 3)
    rect(s, OBI_OSCURO, cx - 7, 32, 14, 1)
    if espalda:
        rect(s, OBI, cx - 3, 29, 6, 5)                    # nudo del obi
        rect(s, OBI_OSCURO, cx - 1, 30, 2, 3)


def _akira_cabeza_frente(s, cx, ondeo):
    rect(s, PIEL, cx - 2, 18, 4, 3)                       # cuello
    elipse(s, PIEL, cx - 6, 7, 12, 12)
    elipse(s, PELO, cx - 6, 5, 12, 8)                     # flequillo y parte alta
    rect(s, PELO, cx - 6, 9, 2, 5)                        # patillas
    rect(s, PELO, cx + 4, 9, 2, 5)
    rect(s, PELO_BRILLO, cx - 3, 6, 3, 1)
    elipse(s, PELO, cx - 2, 2, 5, 5)                      # moño
    rect(s, OBI, cx - 1, 6, 3, 1)
    rect(s, HACHIMAKI, cx - 6, 10, 12, 2)                 # hachimaki
    linea(s, HACHIMAKI, cx + 6, 10, cx + 10, 12 + ondeo)
    linea(s, HACHIMAKI_SOMBRA, cx + 6, 11, cx + 9, 15 + ondeo)
    rect(s, CONTORNO, cx - 3, 14, 1, 2)                   # ojos
    rect(s, CONTORNO, cx + 2, 14, 1, 2)
    rect(s, PIEL_SOMBRA, cx - 1, 17, 2, 1)


def _akira_cabeza_espalda(s, cx, ondeo):
    rect(s, PIEL, cx - 2, 18, 4, 3)
    elipse(s, PELO, cx - 6, 6, 12, 13)
    rect(s, PELO_BRILLO, cx - 3, 8, 4, 1)
    elipse(s, PELO, cx - 2, 2, 5, 5)
    rect(s, OBI, cx - 1, 6, 3, 1)
    rect(s, HACHIMAKI, cx - 6, 10, 12, 2)
    rect(s, HACHIMAKI, cx + 1, 10, 2, 3)                  # nudo, algo a un lado
    linea(s, HACHIMAKI, cx + 2, 12, cx + 4 + ondeo, 19)   # las dos cintas cuelgan juntas
    linea(s, HACHIMAKI_SOMBRA, cx + 3, 12, cx + 6 + ondeo, 18)


def _akira_frente(pose, espalda=False):
    s = lienzo(48, 48)
    cx = 24
    paso = {1: 1, 2: -1}.get(pose, 0)
    rebote = 1 if pose in (1, 2) else 0
    ondeo = {0: 0, 1: 1, 2: -1, 3: 1, 4: 2}[pose]
    if espalda:
        linea(s, SAYA, cx - 7, 31, cx - 14, 37, 2)       # vaina asomando por detrás
    _akira_piernas_frente(s, cx, paso)
    cuerpo = lienzo(48, 48)
    balanceo = paso if pose in (1, 2) else 0
    _akira_torso_frente(cuerpo, cx, balanceo, espalda)
    if espalda:
        _akira_cabeza_espalda(cuerpo, cx, ondeo)
    else:
        _akira_cabeza_frente(cuerpo, cx, ondeo)
        if pose in (0, 1, 2):                            # empuñadura a la cadera
            linea(cuerpo, TSUKA, cx + 7, 31, cx + 11, 27, 2)
            punto(cuerpo, TSUBA, cx + 7, 31)
    if pose == 3:                                        # espada alzada
        rect(cuerpo, KIMONO_OSCURO, cx + 5, 12, 4, 10)
        rect(cuerpo, PIEL, cx + 6, 10, 3, 3)
        linea(cuerpo, TSUKA, cx + 7, 12, cx + 9, 8, 2)
        linea(cuerpo, ACERO, cx + 9, 8, cx + 17, 0, 2)
        linea(cuerpo, ACERO_SOMBRA, cx + 10, 9, cx + 17, 2)
    elif pose == 4:                                      # tajo hacia abajo
        rect(cuerpo, KIMONO_OSCURO, cx - 6, 24, 10, 4)
        rect(cuerpo, PIEL, cx - 8, 25, 3, 3)
        linea(cuerpo, TSUKA, cx - 7, 27, cx - 10, 29, 2)
        linea(cuerpo, ACERO, cx - 10, 29, cx - 21, 38, 2)
        linea(cuerpo, ACERO_SOMBRA, cx - 11, 31, cx - 21, 39)
    s.blit(cuerpo, (0, rebote))
    return contornear(s)


def _akira_lado(pose):
    """Akira de perfil mirando a la derecha."""
    s = lienzo(48, 48)
    cx = 22
    rebote = 1 if pose in (1, 2) else 0
    ondeo = {0: 0, 1: 1, 2: -1, 3: 2, 4: 1}[pose]
    # vaina detrás (hacia la izquierda)
    if pose in (0, 1, 2):
        linea(s, SAYA, cx + 2, 32 + rebote, cx - 13, 36 + rebote, 2)
    # piernas
    if pose == 1:
        poligono(s, HAKAMA_OSCURO, [(cx - 4, 33), (cx + 2, 33), (cx - 4, 45), (cx - 11, 45)])
        poligono(s, HAKAMA, [(cx - 3, 33), (cx + 4, 33), (cx + 11, 45), (cx + 3, 45)])
        rect(s, TABI, cx - 12, 45, 5, 2); rect(s, ZORI, cx - 12, 47, 5, 1)
        rect(s, TABI, cx + 6, 45, 6, 2); rect(s, ZORI, cx + 6, 47, 6, 1)
    elif pose == 2:
        poligono(s, HAKAMA_OSCURO, [(cx - 2, 33), (cx + 4, 33), (cx + 6, 45), (cx, 45)])
        poligono(s, HAKAMA, [(cx - 5, 33), (cx + 2, 33), (cx + 1, 45), (cx - 6, 45)])
        rect(s, TABI, cx + 1, 45, 6, 2); rect(s, ZORI, cx + 1, 47, 6, 1)
        rect(s, TABI, cx - 7, 45, 5, 2); rect(s, ZORI, cx - 7, 47, 5, 1)
    else:
        abierto = 3 if pose == 4 else 0
        poligono(s, HAKAMA_OSCURO, [(cx - 4, 33), (cx + 2, 33), (cx - 2 - abierto, 45), (cx - 9 - abierto, 45)])
        poligono(s, HAKAMA, [(cx - 3, 33), (cx + 5, 33), (cx + 8 + abierto, 45), (cx - 2 + abierto, 45)])
        rect(s, TABI, cx - 10 - abierto, 45, 5, 2); rect(s, ZORI, cx - 10 - abierto, 47, 5, 1)
        rect(s, TABI, cx + 3 + abierto, 45, 6, 2); rect(s, ZORI, cx + 3 + abierto, 47, 6, 1)
    cuerpo = lienzo(48, 48)
    inclinacion = 1 if pose == 4 else 0
    tx = cx + inclinacion
    # torso de perfil
    rect(cuerpo, KIMONO, tx - 5, 20, 10, 12)
    rect(cuerpo, KIMONO_CLARO, tx + 2, 20, 3, 11)
    rect(cuerpo, KIMONO_OSCURO, tx - 5, 20, 2, 12)
    linea(cuerpo, HACHIMAKI, tx + 2, 20, tx + 4, 25)
    rect(cuerpo, OBI, tx - 5, 30, 10, 3)
    rect(cuerpo, OBI, tx - 7, 30, 3, 4)                   # nudo detrás
    # cabeza de perfil
    hx = tx + 1
    rect(cuerpo, PIEL, hx - 1, 18, 4, 3)
    elipse(cuerpo, PIEL, hx - 5, 7, 11, 12)
    rect(cuerpo, PIEL, hx + 5, 13, 1, 2)                  # nariz
    elipse(cuerpo, PELO, hx - 6, 5, 9, 12)                # pelo hacia atrás
    rect(cuerpo, PELO, hx - 2, 5, 6, 4)
    rect(cuerpo, PELO_BRILLO, hx - 3, 6, 3, 1)
    elipse(cuerpo, PELO, hx - 5, 2, 5, 5)                 # moño
    rect(cuerpo, OBI, hx - 4, 6, 3, 1)
    rect(cuerpo, CONTORNO, hx + 3, 13, 1, 2)              # ojo
    rect(cuerpo, HACHIMAKI, hx - 5, 10, 11, 2)
    linea(cuerpo, HACHIMAKI, hx - 5, 10, hx - 12, 8 + ondeo)
    linea(cuerpo, HACHIMAKI_SOMBRA, hx - 5, 11, hx - 11, 13 + ondeo)
    # brazo y espada
    if pose == 3:
        rect(cuerpo, KIMONO_OSCURO, tx - 2, 12, 5, 10)
        rect(cuerpo, PIEL, tx - 1, 10, 3, 3)
        linea(cuerpo, TSUKA, tx, 10, tx - 2, 6, 2)
        linea(cuerpo, ACERO, tx - 2, 6, tx - 13, 0, 2)
        linea(cuerpo, ACERO_SOMBRA, tx - 3, 8, tx - 13, 2)
    elif pose == 4:
        rect(cuerpo, KIMONO_OSCURO, tx + 1, 22, 9, 4)
        rect(cuerpo, PIEL, tx + 9, 22, 3, 3)
        linea(cuerpo, TSUKA, tx + 11, 23, tx + 14, 24, 2)
        linea(cuerpo, ACERO, tx + 14, 24, tx + 25, 30, 2)
        linea(cuerpo, ACERO_SOMBRA, tx + 14, 25, tx + 25, 31)
    else:
        balanceo = {1: 1, 2: -1}.get(pose, 0)
        rect(cuerpo, KIMONO_OSCURO, tx - 1 + balanceo, 21, 4, 9)
        rect(cuerpo, PIEL, tx + balanceo, 29, 3, 2)
        linea(cuerpo, TSUKA, tx + 3, 31, tx + 9, 28, 2)
        punto(cuerpo, TSUBA, tx + 3, 31)
    s.blit(cuerpo, (0, rebote))
    return contornear(s)


def hoja_akira():
    hoja = lienzo(48 * 5, 48 * 3)
    for pose in range(5):
        hoja.blit(_akira_frente(pose), (pose * 48, 0))
        hoja.blit(_akira_frente(pose, espalda=True), (pose * 48, 48))
        hoja.blit(_akira_lado(pose), (pose * 48, 96))
    return hoja


# =============================================================================
# Soldado (cuadros de 64 x 48, centro x = 32, pies en y = 47)
# =============================================================================

def _soldado_piernas_frente(s, cx, paso):
    alto_izq = 1 if paso == 1 else 0
    alto_der = 1 if paso == -1 else 0
    rect(s, PANTALON, cx - 6, 34, 5, 11 - alto_izq)
    rect(s, PANTALON, cx + 1, 34, 5, 11 - alto_der)
    rect(s, ESPINILLERA, cx - 6, 39 - alto_izq, 5, 5)
    rect(s, ESPINILLERA, cx + 1, 39 - alto_der, 5, 5)
    rect(s, PANTALON_OSCURO, cx + 4, 34, 2, 10)
    rect(s, ZORI, cx - 7, 46 - alto_izq, 6, 2)
    rect(s, ZORI, cx + 1, 46 - alto_der, 6, 2)


def _soldado_torso_frente(s, cx, espalda=False):
    poligono(s, ARMADURA_OSCURA, [(cx - 8, 30), (cx + 7, 30), (cx + 9, 35), (cx - 10, 35)])
    for x in (cx - 4, cx, cx + 4):
        linea(s, CONTORNO, x, 31, x + (0 if x == cx else (1 if x > cx else -1)), 34)
    rect(s, ARMADURA, cx - 7, 19, 14, 12)
    for y in (22, 25, 28):
        rect(s, ARMADURA_CLARA, cx - 7, y, 14, 1)
    rect(s, ARMADURA_OSCURA, cx + 5, 19, 2, 12)
    if not espalda:
        rect(s, SOMBRERO_OSCURO, cx - 7, 29, 14, 2)       # cinturón
    for x in (cx - 11, cx + 7):                           # hombreras (sode)
        rect(s, ARMADURA, x, 19, 4, 7)
        rect(s, ARMADURA_CLARA, x, 21, 4, 1)
        rect(s, ARMADURA_CLARA, x, 24, 4, 1)
    rect(s, PANTALON, cx - 10, 26, 3, 4)                  # brazos
    rect(s, PANTALON, cx + 7, 26, 3, 4)
    rect(s, PIEL, cx - 10, 29, 3, 2)
    rect(s, PIEL, cx + 7, 29, 3, 2)


def _soldado_cabeza(s, cx, espalda=False):
    rect(s, PIEL_SOMBRA, cx - 2, 17, 4, 3)
    elipse(s, PIEL, cx - 5, 9, 10, 10)
    if espalda:
        elipse(s, PELO, cx - 5, 9, 10, 9)
    else:
        rect(s, PIEL_SOMBRA, cx - 5, 12, 10, 2)          # sombra del ala
        rect(s, CONTORNO, cx - 3, 14, 2, 1)
        rect(s, CONTORNO, cx + 1, 14, 2, 1)
    # jingasa
    poligono(s, SOMBRERO, [(cx - 12, 12), (cx + 11, 12), (cx, 4)])
    poligono(s, SOMBRERO_CLARO, [(cx - 12, 12), (cx - 1, 12), (cx, 4)])
    rect(s, SOMBRERO_OSCURO, cx - 12, 12, 24, 1)
    punto(s, SOMBRERO_OSCURO, cx, 4)


def _soldado_frente(pose, espalda=False):
    s = lienzo(64, 48)
    cx = 32
    paso = {1: 1, 2: -1}.get(pose, 0)
    rebote = 1 if pose in (1, 2) else 0
    lado_lanza = -1 if espalda else 1
    lx = cx + 12 * lado_lanza
    if pose in (0, 1, 2):
        rect(s, MADERA_LANZA, lx, 5, 2, 42)
        rect(s, MADERA_LANZA_OSCURA, lx + 1, 5, 1, 42)
        poligono(s, ACERO, [(lx - 1, 5), (lx + 2, 5), (lx + 1, 0), (lx, 0)])
    _soldado_piernas_frente(s, cx, paso)
    cuerpo = lienzo(64, 48)
    _soldado_torso_frente(cuerpo, cx, espalda)
    _soldado_cabeza(cuerpo, cx, espalda)
    if pose == 3:       # preparando: lanza cruzada, punta hacia arriba-izquierda
        linea(cuerpo, MADERA_LANZA, cx + 14, 36, cx - 12, 14, 2)
        poligono(cuerpo, ACERO, [(cx - 12, 14), (cx - 15, 10), (cx - 11, 12)])
    elif pose == 4:     # estocada: la punta viene hacia la cámara
        linea(cuerpo, MADERA_LANZA, cx + 2, 30, cx - 1, 22, 2)
        poligono(cuerpo, ACERO, [(cx - 4, 22), (cx + 3, 22), (cx, 16)])
        rect(cuerpo, PIEL, cx - 3, 26, 6, 3)
    s.blit(cuerpo, (0, rebote))
    return contornear(s)


def _soldado_lado(pose):
    s = lienzo(64, 48)
    cx = 28
    rebote = 1 if pose in (1, 2) else 0
    inclinacion = {3: -2, 4: 2}.get(pose, 0)
    # lanza vertical (quieto y caminando) detrás del brazo
    if pose in (0, 1, 2):
        rect(s, MADERA_LANZA, cx + 7, 5, 2, 42)
        rect(s, MADERA_LANZA_OSCURA, cx + 8, 5, 1, 42)
        poligono(s, ACERO, [(cx + 6, 5), (cx + 9, 5), (cx + 8, 0), (cx + 7, 0)])
    # piernas
    if pose == 1:
        rect(s, PANTALON_OSCURO, cx - 6, 34, 4, 11); rect(s, ZORI, cx - 8, 45, 6, 2)
        rect(s, PANTALON, cx + 1, 34, 4, 11); rect(s, ZORI, cx + 1, 45, 7, 2)
    elif pose == 2:
        rect(s, PANTALON_OSCURO, cx, 34, 4, 11); rect(s, ZORI, cx, 45, 6, 2)
        rect(s, PANTALON, cx - 4, 34, 4, 11); rect(s, ZORI, cx - 5, 45, 6, 2)
    else:
        abierto = 3 if pose == 4 else (1 if pose == 3 else 0)
        rect(s, PANTALON_OSCURO, cx - 4 - abierto, 34, 4, 11); rect(s, ZORI, cx - 5 - abierto, 45, 6, 2)
        rect(s, PANTALON, cx + abierto, 34, 4, 11); rect(s, ZORI, cx + abierto, 45, 7, 2)
    rect(s, ESPINILLERA, cx - 4, 39, 8, 5)
    cuerpo = lienzo(64, 48)
    tx = cx + inclinacion
    poligono(cuerpo, ARMADURA_OSCURA, [(tx - 6, 30), (tx + 5, 30), (tx + 6, 35), (tx - 8, 35)])
    rect(cuerpo, ARMADURA, tx - 5, 19, 10, 12)
    for y in (22, 25, 28):
        rect(cuerpo, ARMADURA_CLARA, tx - 5, y, 10, 1)
    rect(cuerpo, ARMADURA_OSCURA, tx - 5, 19, 2, 12)
    rect(cuerpo, ARMADURA, tx - 3, 19, 5, 7)              # hombrera
    rect(cuerpo, ARMADURA_CLARA, tx - 3, 22, 5, 1)
    # cabeza de perfil con jingasa
    hx = tx + 1
    rect(cuerpo, PIEL_SOMBRA, hx - 1, 17, 4, 3)
    elipse(cuerpo, PIEL, hx - 4, 9, 9, 10)
    elipse(cuerpo, PELO, hx - 5, 9, 6, 9)
    rect(cuerpo, CONTORNO, hx + 2, 14, 2, 1)
    poligono(cuerpo, SOMBRERO, [(hx - 12, 12), (hx + 11, 12), (hx - 1, 4)])
    poligono(cuerpo, SOMBRERO_CLARO, [(hx - 1, 4), (hx + 11, 12), (hx + 3, 12)])
    rect(cuerpo, SOMBRERO_OSCURO, hx - 12, 12, 24, 1)
    # brazos y lanza
    y_lanza = 26
    if pose == 3:
        linea(cuerpo, MADERA_LANZA, tx - 30, y_lanza, tx + 8, y_lanza, 1)
        linea(cuerpo, MADERA_LANZA_OSCURA, tx - 30, y_lanza + 1, tx + 8, y_lanza + 1, 1)
        poligono(cuerpo, ACERO, [(tx + 8, y_lanza - 2), (tx + 8, y_lanza + 3), (tx + 14, y_lanza)])
        rect(cuerpo, PANTALON, tx - 4, 23, 6, 3)
        rect(cuerpo, PIEL, tx - 5, y_lanza - 1, 3, 3)
    elif pose == 4:
        linea(cuerpo, MADERA_LANZA, tx - 14, y_lanza, tx + 26, y_lanza, 1)
        linea(cuerpo, MADERA_LANZA_OSCURA, tx - 14, y_lanza + 1, tx + 26, y_lanza + 1, 1)
        poligono(cuerpo, ACERO, [(tx + 26, y_lanza - 2), (tx + 26, y_lanza + 3), (tx + 33, y_lanza)])
        rect(cuerpo, PANTALON, tx, 23, 9, 3)
        rect(cuerpo, PIEL, tx + 8, y_lanza - 1, 3, 3)
    else:
        balanceo = {1: 1, 2: -1}.get(pose, 0)
        rect(cuerpo, PANTALON, tx + 1 + balanceo, 23, 4, 5)
        rect(cuerpo, PIEL, tx + 5, 26, 3, 3)
    s.blit(cuerpo, (0, rebote))
    return contornear(s)


def hoja_soldado():
    hoja = lienzo(64 * 5, 48 * 3)
    for pose in range(5):
        hoja.blit(_soldado_frente(pose), (pose * 64, 0))
        hoja.blit(_soldado_frente(pose, espalda=True), (pose * 64, 48))
        hoja.blit(_soldado_lado(pose), (pose * 64, 96))
    return hoja


# =============================================================================
# Texturas repetibles (32 x 32 salvo que se indique)
# =============================================================================

def variar(color, azar, cantidad):
    delta = azar.randint(-cantidad, cantidad)
    return tuple(max(0, min(255, c + delta)) for c in color)


def textura_losa(azar):
    s = pygame.Surface((32, 32))
    s.fill((60, 60, 68))                                  # junta
    for bx in (0, 16):
        for by in (0, 16):
            base = variar((132, 132, 140), azar, 10)
            rect(s, base, bx + 1, by + 1, 15, 15)
            rect(s, variar(base, azar, 4), bx + 1, by + 1, 15, 1)
            rect(s, tuple(min(255, c + 16) for c in base), bx + 1, by + 1, 15, 1)
            rect(s, tuple(max(0, c - 18) for c in base), bx + 1, by + 15, 15, 1)
            for _ in range(5):                            # motas
                punto(s, variar(base, azar, 18), bx + azar.randint(2, 14), by + azar.randint(2, 14))
    linea(s, (84, 84, 94), 5, 20, 9, 24)                  # grieta
    punto(s, (92, 120, 76), 17, 14)                       # musgo
    punto(s, (92, 120, 76), 18, 15)
    return s


def textura_muro_piedra(azar):
    s = pygame.Surface((32, 32))
    s.fill((52, 52, 60))
    for fila in range(4):
        y = fila * 8
        desfase = 8 if fila % 2 else 0
        for columna in range(-1, 3):
            x = columna * 16 + desfase
            base = variar((118, 116, 122), azar, 12)
            rect(s, base, x + 1, y + 1, 15, 7)
            rect(s, tuple(min(255, c + 18) for c in base), x + 1, y + 1, 15, 1)
            rect(s, tuple(max(0, c - 20) for c in base), x + 1, y + 7, 15, 1)
    return s


def textura_yeso(azar):
    s = pygame.Surface((32, 32))
    s.fill((222, 218, 206))
    for _ in range(40):
        punto(s, variar((222, 218, 206), azar, 10), azar.randint(0, 31), azar.randint(0, 31))
    for _ in range(4):
        punto(s, (196, 190, 176), azar.randint(0, 31), azar.randint(0, 31))
    return s


def textura_madera(azar):
    s = pygame.Surface((32, 32))
    for tabla in range(4):
        x = tabla * 8
        base = variar((122, 84, 50), azar, 10)
        rect(s, base, x, 0, 8, 32)
        rect(s, tuple(max(0, c - 34) for c in base), x, 0, 1, 32)
        for _ in range(4):                                # vetas
            vx = x + azar.randint(2, 6)
            vy = azar.randint(0, 24)
            linea(s, tuple(max(0, c - 16) for c in base), vx, vy, vx, vy + azar.randint(4, 8))
        if azar.random() < 0.6:                           # nudo
            punto(s, tuple(max(0, c - 40) for c in base), x + 4, azar.randint(4, 28))
    return s


def textura_tejas(azar):
    s = pygame.Surface((32, 32))
    s.fill((40, 44, 58))
    for fila in range(4):
        y = fila * 8
        for columna in range(4):
            x = columna * 8
            base = variar((78, 84, 104), azar, 6)
            elipse(s, base, x, y - 2, 8, 10)
            rect(s, tuple(min(255, c + 30) for c in base), x + 2, y, 2, 5)
            rect(s, (32, 34, 46), x + 7, y, 1, 8)
        rect(s, (30, 32, 42), 0, y + 7, 32, 1)
    return s


def textura_porton(azar):
    s = pygame.Surface((64, 64))
    for tabla in range(8):
        x = tabla * 8
        base = variar((116, 76, 44), azar, 8)
        rect(s, base, x, 0, 8, 64)
        rect(s, tuple(max(0, c - 36) for c in base), x, 0, 1, 64)
        for _ in range(5):
            vx, vy = x + azar.randint(2, 6), azar.randint(0, 56)
            linea(s, tuple(max(0, c - 14) for c in base), vx, vy, vx, vy + azar.randint(4, 9))
    for y in (12, 46):                                     # bandas de hierro
        rect(s, (58, 58, 66), 0, y, 64, 6)
        rect(s, (88, 88, 98), 0, y, 64, 1)
        for x in range(4, 64, 8):
            rect(s, (150, 150, 162), x, y + 2, 2, 2)
    rect(s, (40, 26, 16), 31, 0, 2, 64)                    # unión de las dos hojas
    return s


def textura_fuego():
    s = lienzo(64, 24)
    formas = [(0, 0), (1, -1), (-1, 1), (1, 1)]
    for cuadro, (vaiven, estira) in enumerate(formas):
        base_x = cuadro * 16
        cx = base_x + 8
        for alto, ancho, color in ((20 + estira, 6, (226, 74, 24)), (15 + estira, 4, (255, 152, 40)),
                                   (9, 2, (255, 234, 150))):
            poligono(s, color, [(cx - ancho, 23), (cx + ancho, 23), (cx + ancho - 1, 23 - alto // 2),
                                (cx + vaiven, 23 - alto), (cx - ancho + 1, 23 - alto // 2)])
        punto(s, (255, 250, 220), cx, 21)
    return s


def textura_sombra():
    s = lienzo(32, 16)
    for y in range(16):
        for x in range(32):
            d = ((x - 15.5) / 16) ** 2 + ((y - 7.5) / 8) ** 2
            if d < 1:
                s.set_at((x, y), (0, 0, 0, int(140 * (1 - d) ** 0.8)))
    return s


def textura_luna():
    s = lienzo(64, 64)
    pygame.draw.circle(s, (248, 240, 210), (32, 32), 30)
    for dx, dy, r in ((-9, -7, 6), (8, 5, 8), (-4, 12, 4), (12, -11, 4), (-14, 6, 3)):
        pygame.draw.circle(s, (226, 216, 186), (32 + dx, 32 + dy), r)
    return s


def textura_tajo():
    """Estela del tajo de la espada (mirando a la derecha)."""
    s = lienzo(48, 48)
    for radio, alfa in ((22, 230), (20, 170), (18, 110), (16, 60)):
        for grados in range(-70, 75, 2):
            a = math.radians(grados)
            x = 16 + math.cos(a) * radio
            y = 24 + math.sin(a) * radio
            punto(s, (230, 240, 255, alfa), round(x), round(y))
            punto(s, (230, 240, 255, alfa), round(x), round(y) + 1)
    return s


# =============================================================================
# Principal
# =============================================================================

def generar():
    pygame.init()
    azar = random.Random(7)
    archivos = {
        "akira.png": hoja_akira(),
        "soldado.png": hoja_soldado(),
        "losa.png": textura_losa(azar),
        "muro_piedra.png": textura_muro_piedra(azar),
        "yeso.png": textura_yeso(azar),
        "madera.png": textura_madera(azar),
        "tejas.png": textura_tejas(azar),
        "porton.png": textura_porton(azar),
        "fuego.png": textura_fuego(),
        "sombra.png": textura_sombra(),
        "luna.png": textura_luna(),
        "tajo.png": textura_tajo(),
    }
    for nombre, superficie in archivos.items():
        pygame.image.save(superficie, os.path.join(CARPETA, nombre))
    return archivos


def hoja_de_muestra(archivos, ruta):
    """Todo ampliado x4 sobre fondo nocturno, para revisarlo a ojo."""
    escala = 4
    fondo = pygame.Surface((1400, 1500))
    fondo.fill((34, 32, 52))
    x, y, alto_fila = 10, 10, 0
    for nombre, sup in archivos.items():
        grande = pygame.transform.scale(sup, (sup.get_width() * escala, sup.get_height() * escala))
        if x + grande.get_width() > 1390:
            x, y = 10, y + alto_fila + 10
            alto_fila = 0
        fondo.blit(grande, (x, y))
        x += grande.get_width() + 10
        alto_fila = max(alto_fila, grande.get_height())
    pygame.image.save(fondo, ruta)


if __name__ == "__main__":
    generados = generar()
    print("Generados:", ", ".join(generados))
    if "--muestra" in sys.argv:
        destino = os.path.join(CARPETA, "..", "capturas", "muestra_recursos.png")
        hoja_de_muestra(generados, destino)
        print("Muestra:", os.path.abspath(destino))
