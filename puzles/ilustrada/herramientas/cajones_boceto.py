#!/usr/bin/env python3
"""Los cajones del costado de la caja, medidos sobre el boceto con los cajones cerrados.

- Aplana el costado derecho de la caja (el plano x = 0,11 m) con la cámara del boceto (camara.json).
- Afina el borde de cada cajón buscando la junta oscura de laca entre cajones.
- Escribe pagina/capas/cajones.json: cada cajón en metros (ejes de Blender: x derecha, y hacia el fondo,
  z arriba; la cara del costado está en x = 0,11), su contorno en el boceto y la pieza del modelo de Blender
  que le corresponde (técnica C).

Uso:  python3 puzles/ilustrada/herramientas/cajones_boceto.py
"""
import json
import os

import numpy as np
from PIL import Image
from scipy import ndimage

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.normpath(os.path.join(AQUI, '..'))
CAPAS = os.path.join(RAIZ, 'pagina', 'capas')
ESCALA = 2000                       # píxeles del costado aplanado por metro
X_CARA = 0.11
BORDE = 0.0025                      # el marco de cada frente, por fuera de la marquetería (m)

# Cada cajón, a ojo sobre el costado aplanado (u: de delante a atrás, v: de arriba abajo, en px a 2000 px/m),
# con la pieza del modelo de Blender (CajonDerecho_N) que ocupa el mismo sitio
CAJONES = [
    ('c1', (40, 37, 172, 102), 7),
    ('c2', (207, 37, 402, 102), 8),
    ('c3', (37, 127, 285, 210), 5),
    ('c4', (307, 125, 402, 207), 6),
    ('c5', (40, 222, 152, 310), 2),
    ('c6', (175, 225, 285, 310), 3),
    ('c7', (307, 222, 407, 310), 4),
    ('c8', (37, 325, 215, 415), 0),
    ('c9', (245, 325, 410, 415), 1),
]


def camara():
    cam = json.load(open(os.path.join(CAPAS, 'camara.json')))
    R = np.array(cam['mundo_a_camara']); C = np.array(cam['posicion']); f = cam['focal_px']

    def proyectar(P):
        c = (np.asarray(P, np.float64) - C) @ R.T
        return 688 + f * c[..., 0] / c[..., 2], 384 + f * c[..., 1] / c[..., 2]
    return cam, proyectar


def afinar(lum, u0, v0, u1, v1, margen=9):
    """Mueve cada borde hasta la junta oscura más cercana (el paso de laca negra a madera)."""
    def mejor(perfil, centro, signo):
        lo, hi = max(1, centro - margen), min(len(perfil) - 2, centro + margen)
        grad = np.gradient(perfil)
        trozo = grad[lo:hi + 1] * signo
        return lo + int(np.argmax(trozo))
    banda_v = slice(int(v0 + (v1 - v0) * 0.2), int(v1 - (v1 - v0) * 0.2))
    banda_u = slice(int(u0 + (u1 - u0) * 0.2), int(u1 - (u1 - u0) * 0.2))
    columnas = lum[banda_v].mean(0)
    filas = lum[:, banda_u].mean(1)
    return (mejor(columnas, int(u0), +1), mejor(filas, int(v0), +1),
            mejor(columnas, int(u1), -1), mejor(filas, int(v1), -1))


def principal():
    cam, proyectar = camara()
    alto = 0.21 * cam['alto_caja']
    z_arriba, z_abajo = 0.034 + alto, 0.034
    ys = np.arange(int(0.22 * ESCALA)) / ESCALA - 0.11
    zs = z_arriba - np.arange(int(alto * ESCALA)) / ESCALA
    Y, Z = np.meshgrid(ys, zs)
    u, v = proyectar(np.stack([np.full_like(Y, X_CARA), Y, Z], -1))
    imagen = np.asarray(Image.open(os.path.join(RAIZ, 'fuentes', 'sala_cajones_cerrados.jpg')).convert('L'), np.float64)
    lum = ndimage.map_coordinates(imagen, [v, u], order=1)
    lum = ndimage.gaussian_filter(lum, 1.0)
    cajones = []
    for nombre, (u0, v0, u1, v1), pieza in CAJONES:
        a, b, c, d = afinar(lum, u0, v0, u1, v1)
        y0, y1 = -0.11 + a / ESCALA - BORDE, -0.11 + c / ESCALA + BORDE
        z1, z0 = z_arriba - b / ESCALA + BORDE, z_arriba - d / ESCALA - BORDE
        esquinas = [(X_CARA, y0, z1), (X_CARA, y1, z1), (X_CARA, y1, z0), (X_CARA, y0, z0)]
        poligono = [[round(float(p), 1) for p in proyectar(e)] for e in esquinas]
        cajones.append({'id': nombre, 'y': [round(y0, 4), round(y1, 4)], 'z': [round(z0, 4), round(z1, 4)],
                        'poligono': poligono, 'pieza': f'CajonDerecho_{pieza}'})
        print(f'  {nombre}: y {y0:+.3f}..{y1:+.3f}  z {z0:.3f}..{z1:.3f}  (antes {u0},{v0},{u1},{v1} → {a},{b},{c},{d})')
    datos = {'x': X_CARA, 'fondo': 0.085, 'sale': 0.055, 'cajones': cajones,
             'nota': 'Metros, ejes de Blender (x derecha, y hacia el fondo, z arriba). La cara del costado está en x = 0,11; '
                     'cada cajón sale por +x. «poligono»: sus esquinas en el boceto (arriba-delante, arriba-atrás, '
                     'abajo-atrás, abajo-delante).'}
    with open(os.path.join(CAPAS, 'cajones.json'), 'w', encoding='utf-8') as f:
        json.dump(datos, f, ensure_ascii=False, indent=1)
    print('cajones.json escrito:', len(cajones), 'cajones')


if __name__ == '__main__':
    principal()
