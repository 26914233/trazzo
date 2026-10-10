#!/usr/bin/env python3
"""Calcula la cámara desde la que está pintado el boceto de la caja viva.

Las esquinas de la caja se midieron a mano sobre ampliaciones de `fuentes/sala.jpg`. La caja tiene las
medidas del modelo de Blender (`herramientas/blender/caja_viva_ac.py`): 0,22 × 0,22 × 0,21 m sobre un
zócalo de 0,034 m. Ejes de Blender: X a la derecha, Y hacia el fondo, Z arriba; el frente mira a −Y.

Escribe `pagina/capas/camara.json` (posición, giro, campo de visión y error en píxeles).

    python3 puzles/ilustrada/herramientas/camara_boceto.py
"""
import json
import os

import numpy as np
from scipy.optimize import least_squares

AQUI = os.path.dirname(os.path.abspath(__file__))
SALIDA = os.path.join(AQUI, '..', 'pagina', 'capas', 'camara.json')
ANCHO, ALTO = 1376, 768
X, Y, Z0, Z1 = 0.11, 0.11, 0.034, 0.244

# esquina del cuerpo de la caja -> píxel del boceto
PUNTOS = [
    ((-X, -Y, Z1), (690, 209)),    # delante, izquierda, arriba
    ((X, -Y, Z1), (1008, 228)),    # delante, derecha, arriba
    ((X, Y, Z1), (1147, 187)),     # detrás, derecha, arriba
    ((-X, Y, Z1), (862, 170)),     # detrás, izquierda, arriba
    ((-X, -Y, Z0), (696, 547)),    # delante, izquierda, abajo
    ((X, -Y, Z0), (1018, 597)),    # delante, derecha, abajo
]


def rotacion(guinada, cabeceo, alabeo):
    """Matriz mundo -> cámara. La cámara mira por +Z (x a la derecha, y hacia abajo)."""
    cg, sg = np.cos(guinada), np.sin(guinada)
    cc, sc = np.cos(cabeceo), np.sin(cabeceo)
    ca, sa = np.cos(alabeo), np.sin(alabeo)
    # base de la cámara en el mundo: adelante, derecha y arriba
    adelante = np.array([sg * cc, cg * cc, -sc])           # guiñada 0 = mirando a +Y; cabeceo > 0 = hacia abajo
    derecha = np.array([cg, -sg, 0.0])
    arriba = np.cross(derecha, adelante)
    # alabeo alrededor de «adelante»
    derecha, arriba = derecha * ca + arriba * sa, -derecha * sa + arriba * ca
    return np.stack([derecha, -arriba, adelante])


def proyectar(p, parametros, alto_caja=1.0):
    cx, cy, cz, guinada, cabeceo, alabeo, focal = parametros
    R = rotacion(guinada, cabeceo, alabeo)
    q = np.array(p, float).copy()
    q[2] = Z0 + (q[2] - Z0) * alto_caja if q[2] > Z0 else q[2]
    c = R @ (q - np.array([cx, cy, cz]))
    return np.array([ANCHO / 2 + focal * c[0] / c[2], ALTO / 2 + focal * c[1] / c[2]])


def residuos(v, con_alto):
    parametros, alto_caja = (v[:7], v[7]) if con_alto else (v, 1.0)
    return np.concatenate([proyectar(p, parametros, alto_caja) - np.array(px) for p, px in PUNTOS])


def principal():
    inicio = [0.45, -0.75, 0.5, np.radians(-30), np.radians(25), 0.0, 1400.0]
    sol = least_squares(residuos, inicio, args=(False,))
    sol_alto = least_squares(residuos, list(sol.x) + [1.0], args=(True,))
    for nombre, s, con in (('caja de Blender', sol, False), ('alto libre', sol_alto, True)):
        err = np.sqrt((s.fun.reshape(-1, 2) ** 2).sum(1))
        print(f'{nombre}: error medio {err.mean():.1f} px, máximo {err.max():.1f} px')
    elegida, con = (sol_alto, True) if np.sqrt((sol_alto.fun ** 2).mean()) < 0.8 * np.sqrt((sol.fun ** 2).mean()) else (sol, False)
    v = elegida.x
    cx, cy, cz, guinada, cabeceo, alabeo, focal = v[:7]
    alto_caja = float(v[7]) if con else 1.0
    fov_vertical = float(np.degrees(2 * np.arctan(ALTO / 2 / focal)))
    R = rotacion(guinada, cabeceo, alabeo)
    datos = {
        'posicion': [float(cx), float(cy), float(cz)],
        'guinada_grados': float(np.degrees(guinada)), 'cabeceo_grados': float(np.degrees(cabeceo)),
        'alabeo_grados': float(np.degrees(alabeo)), 'focal_px': float(focal), 'fov_vertical_grados': fov_vertical,
        'alto_caja': alto_caja,
        'mundo_a_camara': R.tolist(),
        'error_px': [float(e) for e in np.sqrt((elegida.fun.reshape(-1, 2) ** 2).sum(1))],
        'imagen': [ANCHO, ALTO],
        'nota': 'Ejes de Blender (Z arriba). La cámara mira por +Z de su base (x derecha, y abajo).',
    }
    os.makedirs(os.path.dirname(SALIDA), exist_ok=True)
    with open(SALIDA, 'w', encoding='utf-8') as f:
        json.dump(datos, f, ensure_ascii=False, indent=1)
    print(json.dumps({k: v for k, v in datos.items() if k != 'mundo_a_camara'}, ensure_ascii=False, indent=1))
    # dónde caen las esquinas del zócalo (0,256 m de lado), para comparar con el boceto
    for nombre, p in [('zócalo delante izq. abajo', (-0.128, -0.128, 0.0)), ('zócalo delante der. abajo', (0.128, -0.128, 0.0)),
                      ('zócalo detrás der. abajo', (0.128, 0.128, 0.0)), ('zócalo delante izq. arriba', (-0.128, -0.128, 0.034))]:
        print(nombre, proyectar(p, v[:7], alto_caja).round(1))


if __name__ == '__main__':
    principal()
