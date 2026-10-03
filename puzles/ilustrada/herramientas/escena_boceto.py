#!/usr/bin/env python3
"""Reconstruye la sala del boceto en 3D, en lo justo para que la cámara se pueda mover.

A partir de la cámara de `camara_boceto.py` y de las planchas sin caja (`sala_mesa_vacia.jpg`) y sin mesa
(`sala_vacia.jpg`), calcula:
- la altura del tablero (donde apoya la peana de la caja en el boceto);
- el círculo del tablero, ajustado al borde del fondo de la mesa (lo que cambia entre las dos planchas);
- el suelo y las dos paredes, por las juntas del tatami con la pared;
- dónde están el incensario, la tetera y las tazas, y su radio.

Escribe `pagina/capas/escena.json` (ejes de Blender, metros).

    python3 puzles/ilustrada/herramientas/escena_boceto.py
"""
import json
import math
import os

import numpy as np
from PIL import Image
from scipy import ndimage
from scipy.optimize import brentq, least_squares

AQUI = os.path.dirname(os.path.abspath(__file__))
FUENTES = os.path.join(AQUI, '..', 'fuentes')
CAPAS = os.path.join(AQUI, '..', 'pagina', 'capas')
ALTO_MESA = 0.33          # del suelo al tablero [Supuesto: mesa baja japonesa]


def cargar_camara():
    d = json.load(open(os.path.join(CAPAS, 'camara.json')))
    R = np.array(d['mundo_a_camara'])
    C = np.array(d['posicion'])
    f = d['focal_px']
    W, H = d['imagen']
    return d, R, C, f, W, H


def proyectar(p, R, C, f, W, H):
    c = R @ (np.asarray(p, float) - C)
    return np.array([W / 2 + f * c[0] / c[2], H / 2 + f * c[1] / c[2]])


def rayo(px, R, C, f, W, H):
    """Dirección en el mundo del rayo que pasa por el píxel."""
    d = np.array([(px[0] - W / 2) / f, (px[1] - H / 2) / f, 1.0])
    d = R.T @ d
    return d / np.linalg.norm(d)


def con_plano_z(px, z, R, C, f, W, H):
    d = rayo(px, R, C, f, W, H)
    t = (z - C[2]) / d[2]
    return C + t * d


def principal():
    datos, R, C, f, W, H = cargar_camara()
    cam = (R, C, f, W, H)
    alto_caja = datos['alto_caja']

    # 1. La peana pintada es más grande que la del modelo: se ajusta a sus esquinas (centro, medio lado en X
    #    y en Y, y la altura de su base). Arriba acaba donde empieza el cuerpo de la caja (z = 0,034).
    esquinas_peana = [((-1, -1, 0), (662, 617)), ((1, -1, 0), (1019, 687)), ((1, 1, 0), (1172, 575)),
                      ((-1, -1, 1), (662, 560)), ((1, -1, 1), (1019, 608)), ((1, 1, 1), (1173, 517))]

    def residuo_peana(p):
        ox, oy, mx, my, zb = p
        res = []
        for (sx, sy, arriba), px in esquinas_peana:
            q = (ox + sx * mx, oy + sy * my, 0.034 if arriba else zb)
            res.extend(proyectar(q, *cam) - np.array(px))
        return np.array(res)

    peana = least_squares(residuo_peana, [0.0, 0.0, 0.13, 0.13, -0.01]).x
    err_peana = float(np.sqrt((residuo_peana(peana).reshape(-1, 2) ** 2).sum(1)).mean())
    z_tablero = float(peana[4])

    # 2. Círculo del tablero: lo que cambia entre la plancha con mesa y la sin mesa; su borde de arriba
    #    es el borde del fondo del tablero
    m = np.asarray(Image.open(os.path.join(FUENTES, 'sala_mesa_vacia.jpg')).convert('RGB')).astype(float)
    v = np.asarray(Image.open(os.path.join(FUENTES, 'sala_vacia.jpg')).convert('RGB')).astype(float)
    mesa = ndimage.gaussian_filter(np.abs(m - v).mean(2), 2) > 18
    mesa = ndimage.binary_fill_holes(ndimage.binary_opening(mesa, iterations=3))
    etiquetas, n = ndimage.label(mesa)
    mesa = etiquetas == (np.argmax(ndimage.sum(mesa, etiquetas, range(1, n + 1))) + 1)
    borde = []
    for x in range(440, 1370, 15):
        filas = np.where(mesa[:, x])[0]
        if len(filas):
            borde.append((x, filas.min()))
    borde = np.array(borde, float)

    def residuo(p):
        cx, cy, r = p
        res = []
        for x, y in borde:
            # punto del círculo que cae en esa columna, por el lado del fondo
            angulos = np.linspace(0, 2 * np.pi, 720, endpoint=False)
            pts = np.stack([cx + r * np.cos(angulos), cy + r * np.sin(angulos), np.full(720, z_tablero)], 1)
            pr = np.array([proyectar(q, *cam) for q in pts])
            cerca = np.abs(pr[:, 0] - x) < 3
            if not cerca.any():
                res.append(50.0)
                continue
            res.append(pr[cerca, 1].min() - y)
        return np.array(res)

    ajuste = least_squares(residuo, [0.05, 0.05, 0.45], bounds=([-0.5, -0.5, 0.2], [0.6, 0.8, 0.9]))
    cx, cy, r = ajuste.x
    err_mesa = float(np.abs(ajuste.fun).mean())

    # 3. Suelo y paredes: la esquina del fondo, detrás de la lámpara, y las juntas del tatami con la pared
    z_suelo = z_tablero - ALTO_MESA
    esquina = con_plano_z((668, 395), z_suelo, *cam)
    ventana = con_plano_z((1376, 470), z_suelo, *cam)
    tokonoma = con_plano_z((190, 485), z_suelo, *cam)

    def pared(a, b):
        d = (b - a)[:2] / np.linalg.norm((b - a)[:2])
        normal = np.array([-d[1], d[0], 0.0])
        if normal @ (C - a) < 0:
            normal = -normal
        return {'punto': a.tolist(), 'normal': normal.tolist()}

    # 4. Lo que hay en la mesa: base (el punto más bajo de cada cosa, sin su reflejo) y ancho
    s = np.asarray(Image.open(os.path.join(FUENTES, 'sala.jpg')).convert('RGB')).astype(float)
    objetos = {}
    for nombre, caja, base_y in [('incensario', (505, 430, 648, 612), 604), ('tetera', (1203, 474, 1376, 628), 622),
                                 ('taza_1', (1145, 594, 1236, 676), 668), ('taza_2', (1240, 610, 1330, 695), 688)]:
        x0, y0, x1, y1 = caja
        dif = ndimage.gaussian_filter(np.abs(s - m).mean(2), 1.5)[y0:y1, x0:x1] > 20
        xs = np.where(dif.any(0))[0]
        izq, der = x0 + xs.min(), x0 + xs.max()
        centro_px = ((izq + der) / 2.0, base_y)
        base = con_plano_z(centro_px, z_tablero, *cam)
        a = con_plano_z((izq, base_y), z_tablero, *cam)
        b = con_plano_z((der, base_y), z_tablero, *cam)
        radio = float(np.linalg.norm(a[:2] - b[:2]) / 2.0)
        arriba = brentq(lambda z: proyectar((base[0], base[1], z), *cam)[1] - y0, z_tablero, z_tablero + 0.6)
        objetos[nombre] = {'base': base.tolist(), 'radio': radio, 'alto': float(arriba - z_tablero),
                           'recorte': [int(x0), int(y0), int(x1), int(y1)]}

    # 5. Profundidad por fila de la imagen (para el paralaje de la técnica A): la sala (paredes y suelo) y el
    #    tablero, cada 16 filas, en la columna del centro de la caja
    def profundidad(q):
        return float((R @ (np.asarray(q, float) - C))[2])

    paso = 16
    prof_sala, prof_mesa = [], []
    for y in range(0, H + 1, paso):
        d = rayo((927, y), *cam)
        suelo = None
        if d[2] < -1e-6:
            q = C + (z_suelo - C[2]) / d[2] * d
            suelo = profundidad(q)
        d_pared = profundidad(C + d * ((esquina[1] - C[1]) / d[1])) if d[1] > 1e-6 else 3.6
        prof_sala.append(min(suelo, d_pared, 3.6) if suelo is not None else min(d_pared, 3.6))
        if d[2] < -1e-6:
            q = C + (z_tablero - C[2]) / d[2] * d
            prof_mesa.append(profundidad(q))
        else:
            prof_mesa.append(3.6)

    escena = {
        'z_tablero': float(z_tablero), 'alto_caja': alto_caja,
        'profundidad': {'paso_filas': paso, 'sala': prof_sala, 'mesa': prof_mesa, 'caja': profundidad((0, 0, 0.14)),
                        'incensario': profundidad(objetos['incensario']['base']), 'te': profundidad(objetos['tetera']['base'])},
        'peana': {'centro': [float(peana[0]), float(peana[1])], 'medio_x': float(peana[2]), 'medio_y': float(peana[3]),
                  'z_abajo': float(peana[4]), 'z_arriba': 0.034, 'error_px': err_peana},
        # el tablero un 4 % más grande: así su silueta cubre la mesa pintada (el borde que sobra es suelo de la plancha)
        'mesa': {'centro': [float(cx), float(cy)], 'radio': float(r) * 1.04, 'grueso': 0.034, 'error_px': err_mesa},
        'z_suelo': float(z_suelo),
        'paredes': [pared(esquina, ventana), pared(esquina, tokonoma)],
        'esquina': esquina.tolist(),
        'objetos': objetos,
        'nota': 'Ejes de Blender (Z arriba), metros. La peana de la caja va de z_tablero a 0.034.',
    }
    with open(os.path.join(CAPAS, 'escena.json'), 'w', encoding='utf-8') as fsal:
        json.dump(escena, fsal, ensure_ascii=False, indent=1)
    print(json.dumps(escena, ensure_ascii=False, indent=1))


if __name__ == '__main__':
    principal()
