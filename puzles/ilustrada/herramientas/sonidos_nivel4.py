#!/usr/bin/env python3
"""Los sonidos del nivel 4 de La caja viva («El oro»), a 22 kHz (pagina/sonidos/).

- crac: la mejilla se resiente al cantar y suelta una esquirla (un chasquido seco de madera y un crujido);
- pincel: el pincel con laca repasa una junta (un roce suave de pelo sobre madera);
- oro: el polvo de oro cae sobre la laca (un brillo de campanitas muy pequeñas sobre un soplo).

Las notas de las olas de la peana y la frase que canta la caja salen de la campanilla y el tarareo del nivel 3, con
otro tono (juego.js).

Usa las piezas de síntesis de puzles/herramientas/generar_sonidos.py.

Uso:  python3 puzles/ilustrada/herramientas/sonidos_nivel4.py
"""
import os
import sys

import numpy as np

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(AQUI, '..', '..', 'herramientas'))
sys.path.insert(0, AQUI)
import generar_sonidos as gs  # noqa: E402
from sonidos_vocabulario import guardar_22k, golpecito  # noqa: E402

rng = np.random.default_rng(44)


def crac():
    x = np.zeros(gs.muestras(0.9))
    # el chasquido: dos golpes muy secos, casi juntos, con cuerpo de madera
    for inicio, g in ((0.0, 1.0), (0.018, 0.6)):
        gs.colocar(x, golpecito(2300, q=14, caida=0.004), inicio, g)
        gs.colocar(x, gs.resonancia(gs.blanco(0.08) * gs.envolvente(gs.muestras(0.08), 0.0005, 0.012), 420, 8), inicio, g * 0.8)
    # el crujido de después: chasquidos pequeños que se apagan
    for i in range(14):
        inicio = 0.05 + 0.32 * (i / 14) ** 0.8 + rng.uniform(0, 0.02)
        gs.colocar(x, golpecito(rng.uniform(1500, 3200), q=rng.uniform(10, 20), caida=0.002), inicio, 0.35 * (1 - i / 16))
    return x


def pincel():
    dur = 0.55
    t = gs.tiempo(dur)
    roce = gs.banda(gs.blanco(dur), 1400, 6200) * (0.6 + 0.4 * np.sin(2 * np.pi * 9 * t) ** 2)
    return roce * gs.envolvente(len(t), 0.12, 0.25) * 0.5


def oro():
    dur = 1.4
    x = np.zeros(gs.muestras(dur))
    soplo = gs.banda(gs.blanco(dur), 3000, 9000) * gs.envolvente(gs.muestras(dur), 0.05, 0.6)
    gs.colocar(x, soplo, 0.0, 0.18)
    for _ in range(26):
        f = rng.uniform(3200, 7600)
        inicio = rng.uniform(0, 0.9)
        gs.colocar(x, gs.campana(f, 0.35, parciales=((1, 1.0), (2.1, 0.3)), caida=0.15), inicio, rng.uniform(0.08, 0.22))
    return x


def principal():
    print('Sonidos del nivel 4 (22 kHz):')
    guardar_22k('crac', crac(), 0.8)
    guardar_22k('pincel', pincel(), 0.45)
    guardar_22k('oro', oro(), 0.55)


if __name__ == '__main__':
    principal()
