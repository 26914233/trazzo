#!/usr/bin/env python3
"""Efectos de sonido de Rebotazz, sintetizados aqui (licencia propia, sin muestras).

Uso: python3 herramientas/sonidos.py   -> arte/sonidos/*.wav
"""
import os
import wave

import numpy as np

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SR = 22050


def env(n, ataque=0.005, caida=6.0):
    t = np.arange(n) / SR
    e = np.exp(-t * caida)
    a = int(ataque * SR)
    if a:
        e[:a] *= np.linspace(0, 1, a)
    return e


def tono(f, dur, forma="seno", caida=6.0, barrido=0.0):
    n = int(dur * SR)
    t = np.arange(n) / SR
    fr = f * (1 + barrido * t / dur)
    fase = 2 * np.pi * np.cumsum(fr) / SR
    if forma == "seno":
        o = np.sin(fase)
    elif forma == "cuadrada":
        o = np.sign(np.sin(fase)) * 0.5
    else:
        o = 2 * (fase / (2 * np.pi) % 1) - 1
    return o * env(n, caida=caida)


def ruido(dur, caida=10.0, corte=0.3, semilla=1):
    n = int(dur * SR)
    r = np.random.default_rng(semilla).standard_normal(n)
    y = np.zeros(n)
    for i in range(1, n):            # paso bajo simple
        y[i] = y[i - 1] + corte * (r[i] - y[i - 1])
    return y * env(n, caida=caida)


def mezclar(*partes):
    """Suma sonidos de distinta duracion (rellena con silencio)."""
    n = max(len(p) for p in partes)
    out = np.zeros(n)
    for p in partes:
        out[:len(p)] += p
    return out


def guardar(nombre, x, vol=0.6):
    x = x / max(1e-9, np.max(np.abs(x))) * vol
    ruta = os.path.join(RAIZ, "arte", "sonidos", nombre + ".wav")
    with wave.open(ruta, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((x * 32767).astype("<i2").tobytes())


def main():
    os.makedirs(os.path.join(RAIZ, "arte", "sonidos"), exist_ok=True)
    guardar("paleta", mezclar(tono(330, 0.09, "seno", 30), 0.4 * tono(660, 0.09, "seno", 40)), 0.45)
    guardar("pared", tono(520, 0.05, "seno", 50), 0.25)
    guardar("rompe", mezclar(tono(880, 0.12, "cuadrada", 28, barrido=0.4) * 0.7, ruido(0.08, 40, 0.5) * 0.5), 0.5)
    guardar("agrieta", mezclar(tono(420, 0.1, "cuadrada", 35), ruido(0.06, 50, 0.6) * 0.4), 0.4)
    guardar("metal", mezclar(tono(1400, 0.25, "seno", 14), 0.5 * tono(2130, 0.25, "seno", 18)), 0.35)
    guardar("explota", mezclar(ruido(0.45, 7, 0.15, 3), 0.4 * tono(90, 0.4, "seno", 8, barrido=-0.5)), 0.7)
    guardar("laser", tono(1600, 0.1, "sierra", 25, barrido=-0.6), 0.25)
    notas = [523, 659, 784, 1047]
    guardar("potenciador", np.concatenate([tono(f, 0.07, "cuadrada", 20) for f in notas]), 0.4)
    guardar("pierde", np.concatenate([tono(f, 0.12, "cuadrada", 10) for f in [392, 330, 262, 196]]), 0.45)
    fanfarria = np.concatenate([tono(f, d, "cuadrada", 6) for f, d in [(523, 0.1), (659, 0.1), (784, 0.1), (1047, 0.35)]])
    guardar("gana", fanfarria, 0.5)
    guardar("clic", tono(700, 0.03, "seno", 80), 0.3)
    print("sonidos listos")


if __name__ == "__main__":
    main()
