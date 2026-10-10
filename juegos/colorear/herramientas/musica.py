#!/usr/bin/env python3
"""Música ambiental de Lienzo Zen, sintetizada aquí (licencia propia, sin muestras).

Pad suave de cuatro acordes, campanitas pentatónicas escasas y un viento muy bajo.
El bucle es continuo: la cola del final se suma al principio.

Uso: python3 herramientas/musica.py   -> arte/sonidos/ambiente.ogg (necesita ffmpeg)
"""
import os
import subprocess
import tempfile
import wave

import numpy as np
from scipy import signal

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SR = 32000
ACORDE_S = 8.0
# re mayor: Dmaj9, Bm7, Gmaj7, A(add9); notas MIDI
ACORDES = [[50, 57, 61, 64, 66], [47, 54, 57, 62, 66], [43, 50, 54, 59, 62], [45, 52, 57, 59, 64]]
PENTA = [74, 76, 78, 81, 83, 86, 88]       # re mayor pentatónica, aguda
VUELTAS = 2


def hz(m):
    return 440.0 * 2 ** ((m - 69) / 12)


def envolvente(n, ataque, caida):
    e = np.ones(n)
    a, c = int(ataque * SR), int(caida * SR)
    e[:a] = np.sin(np.linspace(0, np.pi / 2, a)) ** 2
    e[-c:] *= np.cos(np.linspace(0, np.pi / 2, c)) ** 2
    return e


def main():
    rng = np.random.default_rng(7)
    total_s = ACORDE_S * len(ACORDES) * VUELTAS
    cola_s = 4.0
    n = int((total_s + cola_s) * SR)
    mezcla = np.zeros((n, 2))
    # pad: cada acorde dura 8 s + 4 s de cola que se solapa con el siguiente
    largo = int((ACORDE_S + cola_s) * SR)
    t = np.arange(largo) / SR
    env = envolvente(largo, 2.5, 4.0)
    for k in range(len(ACORDES) * VUELTAS):
        ini = int(k * ACORDE_S * SR)
        for j, m in enumerate(ACORDES[k % len(ACORDES)]):
            f = hz(m) * (1 + rng.uniform(-0.0015, 0.0015))
            onda = np.sin(2 * np.pi * f * t) + 0.18 * np.sin(4 * np.pi * f * t + 0.3)
            onda *= 1 + 0.08 * np.sin(2 * np.pi * 0.17 * t + j)      # vibrato de volumen lento
            pan = 0.3 + 0.4 * (j / 4)
            v = onda * env * (0.11 if j == 0 else 0.07)
            mezcla[ini:ini + largo, 0] += v * (1 - pan)
            mezcla[ini:ini + largo, 1] += v * pan
    # campanitas: una cada ~3 s, decaimiento largo
    tc = np.arange(int(3.5 * SR)) / SR
    pos = 1.0
    while pos < total_s - 1:
        f = hz(rng.choice(PENTA))
        nota = (np.sin(2 * np.pi * f * tc) + 0.3 * np.sin(2 * np.pi * 2.01 * f * tc)) * np.exp(-tc * 1.6)
        nota *= envolvente(len(tc), 0.01, 0.5) * 0.05
        ini = int(pos * SR)
        pan = rng.uniform(0.2, 0.8)
        mezcla[ini:ini + len(tc), 0] += nota * (1 - pan)
        mezcla[ini:ini + len(tc), 1] += nota * pan
        pos += rng.uniform(2.0, 4.5)
    # viento: ruido rosa suave filtrado
    ruido = rng.standard_normal((n, 2))
    b, a = signal.butter(2, 500 / (SR / 2))
    viento = signal.lfilter(b, a, ruido, axis=0)
    viento *= (0.5 + 0.5 * np.sin(2 * np.pi * np.arange(n) / SR / 11.0))[:, None]
    mezcla += viento * 0.012
    # bucle continuo: la cola vuelve al principio
    fin = int(total_s * SR)
    bucle = mezcla[:fin].copy()
    bucle[: n - fin] += mezcla[fin:]
    bucle *= 0.45 / np.max(np.abs(bucle))
    pcm = (bucle * 32767).astype("<i2")
    salida = os.path.join(RAIZ, "arte", "sonidos", "ambiente.ogg")
    with tempfile.TemporaryDirectory() as tmp:
        ruta_wav = os.path.join(tmp, "a.wav")
        with wave.open(ruta_wav, "wb") as w:
            w.setnchannels(2)
            w.setsampwidth(2)
            w.setframerate(SR)
            w.writeframes(pcm.tobytes())
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", ruta_wav, "-c:a", "libvorbis", "-q:a", "2", salida], check=True)
    print(salida, os.path.getsize(salida), "bytes,", total_s, "s")


if __name__ == "__main__":
    main()
