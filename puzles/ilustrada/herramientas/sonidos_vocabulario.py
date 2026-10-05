#!/usr/bin/env python3
"""Los sonidos del vocabulario de La caja viva (genero/05_gramatica_y_sistemas.md, §7), a 22 kHz.

Cada sonido significa siempre lo mismo en todo el juego:
- holgura: la pieza asoma, se puede mover (dos o tres clics flojos y rápidos);
- clac: posición correcta, encajó (golpe doble de madera dura con un tic de metal);
- pestillo: un pestillo de latón que corre dentro de un mecanismo y se detiene;
- desbloqueo: gran desbloqueo (golpe grave y largo, con la madera que resuena y una nota baja).

Usa las piezas de síntesis de puzles/herramientas/generar_sonidos.py y escribe en pagina/sonidos/.

Uso:  python3 puzles/ilustrada/herramientas/sonidos_vocabulario.py
"""
import os
import sys
import wave

import numpy as np
from scipy import signal

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(AQUI, '..', '..', 'herramientas'))
import generar_sonidos as gs  # noqa: E402  (las piezas: blanco, banda, resonancia, envolvente, campana…)

DESTINO = os.path.join(AQUI, '..', 'pagina', 'sonidos')


def guardar_22k(nombre, x, pico=0.8):
    x = np.asarray(x, dtype=np.float64)
    x = x / (np.max(np.abs(x)) or 1.0) * pico
    x = signal.resample_poly(x, 1, 2)                 # 44,1 → 22,05 kHz, como el resto de la página
    ruta = os.path.join(DESTINO, nombre + '.wav')
    with wave.open(ruta, 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(gs.FM // 2)
        w.writeframes(np.clip(x * 32767, -32768, 32767).astype(np.int16).tobytes())
    print(f'  {nombre}.wav  {len(x) / (gs.FM / 2):.2f} s  {os.path.getsize(ruta) // 1024} KB')


def golpecito(frecuencia, dur=0.05, q=22, caida=0.005):
    g = gs.blanco(dur) * gs.envolvente(gs.muestras(dur), 0.0004, caida)
    return gs.resonancia(g, frecuencia, q)


def holgura():
    x = np.zeros(gs.muestras(0.2))
    for inicio, f, gan in ((0.0, 1500, 0.9), (0.055, 1720, 0.6), (0.1, 1600, 0.35)):
        gs.colocar(x, golpecito(f, q=18), inicio, gan)
    return x


def clac():
    x = np.zeros(gs.muestras(0.32))
    t = gs.tiempo(0.18)
    cuerpo = np.sin(2 * np.pi * (190 - 70 * t / 0.18) * t) * gs.envolvente(len(t), 0.001, 0.035)
    gs.colocar(x, cuerpo, 0.0, 0.7)
    gs.colocar(x, golpecito(1350, q=26, caida=0.006), 0.0, 0.9)
    gs.colocar(x, golpecito(2400, q=30, caida=0.005), 0.045, 1.0)          # el segundo golpe: encajó
    metal = gs.blanco(0.12) * gs.envolvente(gs.muestras(0.12), 0.0003, 0.01)
    gs.colocar(x, gs.resonancia(metal, 4300, 90) * 0.5 + gs.resonancia(metal, 6100, 90) * 0.3, 0.047, 0.6)
    return x


def pestillo():
    dur = 0.42
    x = np.zeros(gs.muestras(dur))
    t = gs.tiempo(0.28)
    roce = gs.banda(gs.blanco(0.28), 1800, 7000) * (0.5 + np.abs(gs.paso_bajo(gs.blanco(0.28), 30)) * 5)
    roce *= np.sin(np.pi * t / 0.28) ** 1.5
    gs.colocar(x, roce + gs.resonancia(gs.blanco(0.28), 3600, 70) * 0.06, 0.0, 0.5)
    tope = gs.blanco(0.15) * gs.envolvente(gs.muestras(0.15), 0.0003, 0.006)
    gs.colocar(x, gs.resonancia(tope, 3100, 70) + gs.resonancia(tope, 5200, 80) * 0.6, 0.27, 0.9)
    return x


def desbloqueo():
    dur = 2.0
    x = np.zeros(gs.muestras(dur))
    t = gs.tiempo(1.4)
    bajo = np.sin(2 * np.pi * (68 - 22 * t / 1.4) * t) * gs.envolvente(len(t), 0.004, 0.45)
    gs.colocar(x, bajo, 0.0, 1.0)
    madera = gs.paso_bajo(gs.blanco(0.6), 700) * gs.envolvente(gs.muestras(0.6), 0.002, 0.08)
    gs.colocar(x, gs.resonancia(madera, 160, 12) * 2 + madera * 0.4, 0.0, 0.8)
    retumbe = gs.paso_bajo(gs.blanco(1.6), 120) * gs.envolvente(gs.muestras(1.6), 0.05, 0.5)
    gs.colocar(x, retumbe, 0.05, 0.9)
    gs.colocar(x, gs.campana(147, 1.8, caida=1.3) * 0.35, 0.08)             # re grave, muy suave
    gs.colocar(x, gs.campana(220, 1.5, caida=1.0) * 0.2, 0.12)
    return x


def principal():
    os.makedirs(DESTINO, exist_ok=True)
    print('Sonidos del vocabulario (22 kHz):')
    guardar_22k('holgura', holgura(), 0.55)
    guardar_22k('clac', clac(), 0.8)
    guardar_22k('pestillo', pestillo(), 0.6)
    guardar_22k('desbloqueo', desbloqueo(), 0.85)


if __name__ == '__main__':
    principal()
