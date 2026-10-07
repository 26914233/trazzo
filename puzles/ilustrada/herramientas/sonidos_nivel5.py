#!/usr/bin/env python3
"""Los sonidos de los niveles 5 («La cómoda») y 6 («La noche») de La caja viva, a 22 kHz (pagina/sonidos/).

Nivel 5:
- toc: un golpe con el nudillo en madera maciza (seco, corto);
- toc_hueco: el mismo golpe en un panel hueco (más grave y largo, con eco de caja) y algo suelto que tintinea dentro;
- clinc: un pasador de metal que se suelta y cae por dentro (un ping y unos rebotes);
- ronquido: la caja dormida (un aire lento y grave, que se repite);
- seda: el cordón de seda que corre o se aprieta (un roce fino).

Nivel 6:
- azufre: la punta de azufre de la tsukegi prende (un siseo que estalla en llama);
- soplo: el viento apaga una llama pequeña (un soplo corto);
- mecha: la mecha de la lámpara prende (un «fuf» suave y un chisporroteo).

Usa las piezas de síntesis de puzles/herramientas/generar_sonidos.py.

Uso:  python3 puzles/ilustrada/herramientas/sonidos_nivel5.py
"""
import os
import sys

import numpy as np

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(AQUI, '..', '..', 'herramientas'))
sys.path.insert(0, AQUI)
import generar_sonidos as gs  # noqa: E402
from sonidos_vocabulario import guardar_22k, golpecito  # noqa: E402

rng = np.random.default_rng(55)


def toc():
    x = np.zeros(gs.muestras(0.35))
    gs.colocar(x, golpecito(1800, q=10, caida=0.003), 0.0, 0.6)
    cuerpo = gs.resonancia(gs.blanco(0.1) * gs.envolvente(gs.muestras(0.1), 0.0005, 0.02), 260, 6)
    gs.colocar(x, cuerpo, 0.0, 1.0)
    return x


def toc_hueco():
    x = np.zeros(gs.muestras(1.3))
    gs.colocar(x, golpecito(1300, q=8, caida=0.004), 0.0, 0.5)
    # la caja suena: dos resonancias graves que duran
    golpe = gs.blanco(0.5) * gs.envolvente(gs.muestras(0.5), 0.0005, 0.03)
    gs.colocar(x, gs.resonancia(golpe, 160, 22), 0.0, 0.9)
    gs.colocar(x, gs.resonancia(golpe, 340, 18), 0.0, 0.45)
    # algo suelto dentro: tres o cuatro golpecitos de metal, cada vez más flojos
    t = 0.12
    for i in range(4):
        gs.colocar(x, gs.campana(rng.uniform(2600, 3400), 0.18, parciales=((1, 1.0), (2.7, 0.3)), caida=0.05), t, 0.22 * (0.7 ** i))
        t += rng.uniform(0.07, 0.12) * (0.8 ** i)
    return x


def clinc():
    x = np.zeros(gs.muestras(1.1))
    gs.colocar(x, gs.campana(3100, 0.6, parciales=((1, 1.0), (2.4, 0.4), (5.1, 0.15)), caida=0.25), 0.0, 0.7)
    t, g = 0.16, 0.45
    for _ in range(5):
        gs.colocar(x, gs.campana(rng.uniform(2800, 3300), 0.2, parciales=((1, 1.0), (2.4, 0.3)), caida=0.06), t, g)
        t += 0.09 * (g / 0.45) + 0.02
        g *= 0.55
    gs.colocar(x, golpecito(900, q=8, caida=0.004), t, 0.25)          # y se queda quieto, con un toque de madera
    return x


def ronquido():
    dur = 2.6
    t = gs.tiempo(dur)
    # tomar aire (más agudo) y soltarlo (más grave), con un poco de vibración al tomarlo
    forma = np.clip(np.sin(np.pi * t / dur * 2), 0, None) ** 1.5
    vibra = 1 + 0.5 * np.sin(2 * np.pi * 32 * t) * (t < dur / 2)
    aire = gs.banda(gs.blanco(dur), 120, 900) * forma * vibra
    soltar = gs.banda(gs.blanco(dur), 90, 500) * np.clip(-np.sin(np.pi * t / dur * 2), 0, None) ** 2
    return (aire * 0.7 + soltar * 0.5) * gs.envolvente(len(t), 0.05, 0.1)


def seda():
    dur = 0.6
    t = gs.tiempo(dur)
    roce = gs.banda(gs.blanco(dur), 2200, 7000) * (0.5 + 0.5 * np.sin(2 * np.pi * 14 * t) ** 2)
    return roce * gs.envolvente(len(t), 0.08, 0.3) * 0.45


def azufre():
    dur = 1.6
    x = np.zeros(gs.muestras(dur))
    siseo = gs.banda(gs.blanco(0.35), 2500, 9000) * gs.envolvente(gs.muestras(0.35), 0.01, 0.1)
    gs.colocar(x, siseo, 0.0, 0.5)
    llama = gs.banda(gs.blanco(1.3), 150, 1800) * gs.envolvente(gs.muestras(1.3), 0.02, 0.9)
    gs.colocar(x, llama, 0.12, 0.9)
    for _ in range(10):
        gs.colocar(x, golpecito(rng.uniform(2500, 5000), q=12, caida=0.002), rng.uniform(0.1, 0.9), rng.uniform(0.08, 0.2))
    return x


def soplo():
    dur = 0.5
    t = gs.tiempo(dur)
    aire = gs.banda(gs.blanco(dur), 300, 2500) * np.sin(np.pi * np.clip(t / dur, 0, 1)) ** 2
    return aire * 0.8


def mecha():
    dur = 1.5
    x = np.zeros(gs.muestras(dur))
    fuf = gs.paso_bajo(gs.blanco(0.4), 600) * gs.envolvente(gs.muestras(0.4), 0.03, 0.3)
    gs.colocar(x, fuf, 0.0, 1.0)
    llama = gs.banda(gs.blanco(1.2), 200, 1500) * gs.envolvente(gs.muestras(1.2), 0.1, 0.7)
    gs.colocar(x, llama, 0.1, 0.35)
    for _ in range(7):
        gs.colocar(x, golpecito(rng.uniform(2000, 4500), q=12, caida=0.002), rng.uniform(0.15, 1.2), rng.uniform(0.06, 0.15))
    return x


def principal():
    print('Sonidos de los niveles 5 y 6 (22 kHz):')
    guardar_22k('toc', toc(), 0.75)
    guardar_22k('toc_hueco', toc_hueco(), 0.8)
    guardar_22k('clinc', clinc(), 0.6)
    guardar_22k('ronquido', ronquido(), 0.35)
    guardar_22k('seda', seda(), 0.45)
    guardar_22k('azufre', azufre(), 0.7)
    guardar_22k('soplo', soplo(), 0.6)
    guardar_22k('mecha', mecha(), 0.7)


if __name__ == '__main__':
    principal()
