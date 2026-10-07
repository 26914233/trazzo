#!/usr/bin/env python3
"""Los sonidos de los niveles 3 y final de La caja viva, a 22 kHz (pagina/sonidos/).

- campanilla: la campanilla de bronce con su badajo (un toque claro que se apaga despacio);
- campanilla_muda: la campanilla sin badajo, al moverla (un roce de bronce sordo);
- tin: el badajo cae en la taza de té (un tintineo pequeño y un chapoteo);
- vertido: el té cae de la tetera a la taza (un chorro corto);
- tarareo: la caja responde, con la boca cerrada (una nota grave con aire de voz);
- canto: la caja canta con su voz (la campanilla y una melodía lenta);
- latido: el corazón de la caja (dos golpes graves de madera);
- anillo: un anillo de latón que gira una muesca (un clic metálico grave).

Usa las piezas de síntesis de puzles/herramientas/generar_sonidos.py.

Uso:  python3 puzles/ilustrada/herramientas/sonidos_nivel3.py
"""
import os
import sys

import numpy as np

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(AQUI, '..', '..', 'herramientas'))
sys.path.insert(0, AQUI)
import generar_sonidos as gs  # noqa: E402
from sonidos_vocabulario import guardar_22k, golpecito  # noqa: E402


def campanilla():
    dur = 2.6
    x = np.zeros(gs.muestras(dur))
    gs.colocar(x, gs.campana(1318, 2.5, parciales=((1, 1.0), (2.41, 0.42), (3.9, 0.22), (5.6, 0.12), (7.7, 0.05)), caida=1.6), 0.0, 1.0)
    gs.colocar(x, gs.campana(1324, 2.4, caida=1.4) * 0.35, 0.0)      # el batido de dos parciales casi iguales
    gs.colocar(x, golpecito(5200, q=40, caida=0.004), 0.0, 0.35)     # el badajo contra el borde
    return x


def campanilla_muda():
    x = np.zeros(gs.muestras(0.5))
    roce = gs.banda(gs.blanco(0.3), 600, 2400) * gs.envolvente(gs.muestras(0.3), 0.01, 0.08)
    gs.colocar(x, roce, 0.0, 0.5)
    gs.colocar(x, gs.resonancia(gs.blanco(0.2) * gs.envolvente(gs.muestras(0.2), 0.001, 0.02), 1318, 60), 0.02, 0.25)
    return x


def tin():
    x = np.zeros(gs.muestras(0.9))
    gs.colocar(x, gs.campana(2840, 0.6, caida=0.35) * 0.5, 0.0)
    gs.colocar(x, golpecito(3600, q=30, caida=0.003), 0.0, 0.6)
    gota = gs.paso_bajo(gs.blanco(0.25), 1800) * gs.envolvente(gs.muestras(0.25), 0.002, 0.06)
    t = gs.tiempo(0.25)
    burbuja = np.sin(2 * np.pi * (600 + 900 * t / 0.25) * t) * gs.envolvente(len(t), 0.002, 0.04)
    gs.colocar(x, gota * 0.5 + burbuja * 0.3, 0.05, 0.8)
    return x


def vertido():
    dur = 1.6
    x = gs.banda(gs.blanco(dur), 500, 4200)
    t = gs.tiempo(dur)
    x *= 0.55 + 0.45 * np.abs(gs.paso_bajo(gs.blanco(dur), 9)) * 6
    x *= np.minimum(1, t / 0.12) * np.minimum(1, (dur - t) / 0.3)
    return x


def tarareo():
    dur = 1.8
    t = gs.tiempo(dur)
    f = 98 * (1 + 0.012 * np.sin(2 * np.pi * 4.6 * t))              # vibrato lento
    fase = 2 * np.pi * np.cumsum(f) / gs.FM
    voz = sum(np.sin(fase * k) / k ** 1.3 for k in range(1, 9))
    voz = gs.resonancia(voz, 520, 4) * 0.6 + gs.resonancia(voz, 860, 5) * 0.3 + voz * 0.15   # formantes de una «m»
    return voz * gs.envolvente(len(t), 0.25, 0.7)


def canto():
    dur = 7.0
    x = np.zeros(gs.muestras(dur))
    notas = [(0.0, 147), (1.0, 165), (2.0, 196), (3.2, 220), (4.4, 196), (5.4, 147)]   # re mi sol la sol re
    for inicio, f in notas:
        largo = 1.4
        t = gs.tiempo(largo)
        fase = 2 * np.pi * np.cumsum(f * (1 + 0.01 * np.sin(2 * np.pi * 5 * t))) / gs.FM
        voz = sum(np.sin(fase * k) / k ** 1.4 for k in range(1, 8))
        voz = gs.resonancia(voz, 640, 4) * 0.6 + voz * 0.2
        gs.colocar(x, voz * gs.envolvente(len(t), 0.2, 0.45), inicio, 0.6)
    for inicio in (0.0, 2.0, 4.4):
        gs.colocar(x, campanilla() * 0.45, inicio)
    return x


def latido():
    x = np.zeros(gs.muestras(1.0))
    for inicio, g in ((0.0, 1.0), (0.24, 0.7)):
        t = gs.tiempo(0.3)
        golpe = np.sin(2 * np.pi * (62 - 18 * t / 0.3) * t) * gs.envolvente(len(t), 0.003, 0.09)
        madera = gs.resonancia(gs.paso_bajo(gs.blanco(0.2), 900) * gs.envolvente(gs.muestras(0.2), 0.001, 0.03), 180, 10)
        gs.colocar(x, golpe, inicio, g)
        gs.colocar(x, madera, inicio, g * 0.5)
    return x


def anillo():
    x = np.zeros(gs.muestras(0.35))
    gs.colocar(x, golpecito(1900, q=26, caida=0.006), 0.0, 0.9)
    gs.colocar(x, gs.resonancia(gs.blanco(0.25) * gs.envolvente(gs.muestras(0.25), 0.0005, 0.04), 760, 50), 0.0, 0.5)
    return x


def principal():
    print('Sonidos de los niveles 3 y final (22 kHz):')
    guardar_22k('campanilla', campanilla(), 0.7)
    guardar_22k('campanilla_muda', campanilla_muda(), 0.5)
    guardar_22k('tin', tin(), 0.6)
    guardar_22k('vertido', vertido(), 0.45)
    guardar_22k('tarareo', tarareo(), 0.6)
    guardar_22k('canto', canto(), 0.75)
    guardar_22k('latido', latido(), 0.8)
    guardar_22k('anillo', anillo(), 0.6)


if __name__ == '__main__':
    principal()
