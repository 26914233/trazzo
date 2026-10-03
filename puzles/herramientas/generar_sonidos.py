#!/usr/bin/env python3
"""Sonidos de los prototipos de puzles, sintetizados por código (WAV mono de 16 bits, 44,1 kHz).

Comunes: roce de madera y de metal (en bucle), clics, golpes secos, bisagra, recoger, encajar,
pista, paso resuelto, papel y pasos.
Caja viva: noche (bucle), ojo que se abre, gruñido, suspiro, espíritu y el final (koto).
Relojero: tic-tac (bucle), cuerda, campanada, mecanismo, cajón y el final (caja de música).
Reliquia: zumbido (bucle), despertar, pulso, luz que fluye, cristal, despliegue y el final.
Farero: lluvia y viento (bucles), trueno, candado, libro, llave, trampilla, cerilla y el final.
Salas (0.2): traba seca de «así no», viaje de la cámara, puerta corredera, puerta con bisagra, fuego
de chimenea y péndulo (bucles) y el ambiente del gabinete del menú (bucle).

Uso:  python3 puzles/herramientas/generar_sonidos.py [grupo ...]   (sin grupos: todos)
      grupos: comunes, caja_viva, relojero, reliquia, farero, salas
"""

import sys

import os

import numpy as np
from scipy import signal
from scipy.io import wavfile

AQUI = os.path.dirname(os.path.abspath(__file__))
DESTINO = os.path.join(AQUI, "..", "godot", "recursos", "sonidos")
FM = 44100
azar = np.random.default_rng(2026)


# --- Piezas básicas ----------------------------------------------------------------------------

def muestras(segundos):
    return int(segundos * FM)


def tiempo(segundos):
    return np.arange(muestras(segundos)) / FM


def blanco(segundos):
    return azar.uniform(-1, 1, muestras(segundos))


def banda(x, bajo, alto, orden=3):
    sos = signal.butter(orden, [bajo, min(alto, FM / 2 - 100)], btype="band", fs=FM, output="sos")
    return signal.sosfilt(sos, x)


def paso_bajo(x, corte, orden=3):
    return signal.sosfilt(signal.butter(orden, corte, btype="low", fs=FM, output="sos"), x)


def paso_alto(x, corte, orden=3):
    return signal.sosfilt(signal.butter(orden, corte, btype="high", fs=FM, output="sos"), x)


def envolvente(n, ataque, caida, forma=1.0):
    t = np.arange(n) / FM
    subida = np.clip(t / max(ataque, 1e-4), 0, 1)
    bajada = np.exp(-np.maximum(t - ataque, 0) / max(caida, 1e-4)) ** forma
    return subida * bajada


def resonancia(x, frecuencia, q=30):
    b, a = signal.iirpeak(frecuencia, q, fs=FM)
    return signal.lfilter(b, a, x)


def campana(frecuencia, segundos, parciales=((1, 1.0), (2.76, 0.5), (5.4, 0.25), (8.93, 0.12)), caida=1.0):
    t = tiempo(segundos)
    x = np.zeros_like(t)
    for relacion, amplitud in parciales:
        x += amplitud * np.sin(2 * np.pi * frecuencia * relacion * t) * np.exp(-t * (1.5 + relacion) / caida)
    return x * envolvente(len(t), 0.002, segundos)


def karplus(frecuencia, segundos, brillo=0.5):
    """Cuerda pulsada (koto, caja de música): Karplus-Strong."""
    n = muestras(segundos)
    periodo = int(FM / frecuencia)
    linea = azar.uniform(-1, 1, periodo)
    salida = np.zeros(n)
    for i in range(n):
        j = i % periodo
        salida[i] = linea[j]
        siguiente = linea[(j + 1) % periodo]
        linea[j] = 0.996 * (brillo * linea[j] + (1 - brillo) * siguiente)
    return salida


def colocar(destino, x, inicio, ganancia=1.0):
    i = muestras(inicio)
    fin = min(len(destino), i + len(x))
    destino[i:fin] += x[:fin - i] * ganancia
    return destino


def bucle(x, fundido=0.25):
    """Funde el final con el principio para que el bucle no tenga corte."""
    n = muestras(fundido)
    rampa = np.linspace(0, 1, n)
    cuerpo = x[:-n].copy()
    cuerpo[:n] = cuerpo[:n] * rampa + x[-n:] * (1 - rampa)
    return cuerpo


def guardar(nombre, x, pico=0.8):
    x = np.asarray(x, dtype=np.float64)
    maximo = np.max(np.abs(x)) or 1.0
    x = x / maximo * pico
    os.makedirs(DESTINO, exist_ok=True)
    wavfile.write(os.path.join(DESTINO, nombre + ".wav"), FM, (x * 32767).astype(np.int16))
    print(f"   {nombre}: {len(x) / FM:.2f} s")


# --- Comunes -----------------------------------------------------------------------------------

def comunes():
    # Roce de madera: ruido marrón en banda, con «granos» irregulares
    x = blanco(1.6)
    grano = np.abs(paso_bajo(blanco(1.6), 30)) * 6
    roce = banda(x, 250, 2400) * (0.6 + grano)
    roce += banda(blanco(1.6), 1800, 5000) * 0.15
    guardar("deslizar_madera", bucle(roce, 0.3), 0.6)

    x = banda(blanco(1.4), 1500, 7000) * (0.7 + np.abs(paso_bajo(blanco(1.4), 20)) * 4)
    x += resonancia(blanco(1.4), 3200, 60) * 0.05
    guardar("deslizar_metal", bucle(x, 0.3), 0.5)

    golpe = blanco(0.09) * envolvente(muestras(0.09), 0.0005, 0.008)
    x = resonancia(golpe, 1250, 25) * 0.7 + resonancia(golpe, 2600, 30) * 0.5 + golpe * 0.15
    guardar("clic_madera", x, 0.7)

    golpe = blanco(0.2) * envolvente(muestras(0.2), 0.0003, 0.004)
    x = resonancia(golpe, 3100, 80) + resonancia(golpe, 4700, 90) * 0.7 + resonancia(golpe, 6300, 90) * 0.4
    guardar("clic_metal", x, 0.6)

    t = tiempo(0.22)
    tono = np.sin(2 * np.pi * (140 - 60 * t / 0.22) * t) * envolvente(len(t), 0.001, 0.05)
    x = tono + paso_bajo(blanco(0.22), 900) * envolvente(len(t), 0.0005, 0.02) * 0.8
    guardar("tope_madera", x, 0.75)

    x = np.zeros(muestras(0.32))
    colocar(x, tono, 0.0)
    for k, inicio in enumerate((0.05, 0.09, 0.12, 0.16)):
        traqueteo = resonancia(blanco(0.05) * envolvente(muestras(0.05), 0.0005, 0.006), 1700 + k * 260, 20)
        colocar(x, traqueteo, inicio, 0.5)
    guardar("bloqueo", x, 0.75)

    # Bisagra: chirrido con frecuencia que tiembla
    t = tiempo(0.9)
    frecuencia = 210 + 40 * np.sin(2 * np.pi * 1.7 * t) + 25 * paso_bajo(blanco(0.9), 8) * 20
    fase = np.cumsum(frecuencia) / FM
    diente = 2 * (fase % 1) - 1
    friccion = np.abs(paso_bajo(blanco(0.9), 40)) * 8
    x = banda(diente * (0.4 + friccion), 400, 3500) * envolvente(len(t), 0.05, 0.6)
    guardar("bisagra", x, 0.5)

    t = tiempo(0.45)
    soplo = banda(blanco(0.45), 600, 4000) * np.sin(np.pi * t / 0.45) ** 2
    x = soplo * 0.6 + campana(1320, 0.45, caida=0.4) * 0.35
    guardar("recoger", x, 0.6)

    x = np.zeros(muestras(0.5))
    colocar(x, tono, 0.0, 0.8)
    colocar(x, resonancia(blanco(0.08) * envolvente(muestras(0.08), 0.0005, 0.006), 2200, 25), 0.06, 0.8)
    colocar(x, campana(660, 0.4, caida=0.3) * 0.3, 0.06)
    guardar("encajar", x, 0.75)

    x = resonancia(blanco(0.06) * envolvente(muestras(0.06), 0.0005, 0.004), 1800, 20)
    guardar("toque", x, 0.35)

    x = campana(784, 0.9, caida=0.6) * 0.5 + campana(1175, 0.9, caida=0.5) * 0.3
    guardar("pista", x, 0.45)

    # Paso resuelto: dos notas de una escala pentatónica, suaves
    x = np.zeros(muestras(1.6))
    colocar(x, campana(587, 1.4, caida=0.9), 0.0)
    colocar(x, campana(880, 1.2, caida=0.8), 0.12, 0.8)
    guardar("paso", x, 0.55)

    t = tiempo(0.45)
    x = banda(blanco(0.45), 1500, 9000) * np.abs(paso_bajo(blanco(0.45), 25)) * 6 * np.sin(np.pi * t / 0.45)
    guardar("papel", x, 0.4)

    x = np.zeros(muestras(0.8))
    for inicio in (0.0, 0.38):
        pisada = paso_bajo(blanco(0.12), 500) * envolvente(muestras(0.12), 0.003, 0.03)
        crujido = banda(blanco(0.1), 900, 2500) * envolvente(muestras(0.1), 0.01, 0.03) * 0.3
        colocar(x, pisada + crujido[:len(pisada)] if len(crujido) >= len(pisada) else pisada, inicio)
    guardar("pasos", x, 0.5)


# --- Caja viva ---------------------------------------------------------------------------------

def caja_viva():
    # Noche: grillos (trinos a 4,4 kHz que van y vienen) y un viento suave
    n = muestras(8.0)
    t = np.arange(n) / FM
    noche = paso_bajo(blanco(8.0), 400) * 0.25 * (0.6 + 0.4 * np.sin(2 * np.pi * 0.11 * t))
    for k in range(3):
        frecuencia = 4200 + k * 380
        ritmo = 0.5 + 0.5 * np.sign(np.sin(2 * np.pi * (16 + k * 3) * t))
        frases = (np.sin(2 * np.pi * (0.35 + k * 0.13) * t + k) > 0.2).astype(float)
        frases = paso_bajo(frases, 30)
        noche += np.sin(2 * np.pi * frecuencia * t) * ritmo * frases * (0.05 - k * 0.012)
    guardar("noche", bucle(noche, 0.5), 0.35)

    # Ojo que se abre: crujido de madera grave
    t = tiempo(0.7)
    frecuencia = 95 + 30 * np.sin(2 * np.pi * 3.1 * t)
    fase = np.cumsum(frecuencia) / FM
    x = banda((2 * (fase % 1) - 1) * (0.5 + np.abs(paso_bajo(blanco(0.7), 30)) * 5), 120, 1800)
    guardar("ojo_abre", x * envolvente(len(t), 0.04, 0.4), 0.55)

    # Gruñido: ruido grave con temblor
    t = tiempo(0.9)
    x = paso_bajo(blanco(0.9), 320, 4) * (0.6 + 0.4 * np.sin(2 * np.pi * 13 * t))
    x += np.sin(2 * np.pi * (70 + 8 * np.sin(2 * np.pi * 5 * t)) * t) * 0.4
    guardar("grunido", x * envolvente(len(t), 0.05, 0.45), 0.75)

    t = tiempo(1.8)
    x = banda(blanco(1.8), 300, 2600) * np.sin(np.pi * t / 1.8) ** 1.5 * (1 - t / 1.8 * 0.5)
    guardar("suspiro", x, 0.45)

    t = tiempo(2.8)
    brillo = sum(np.sin(2 * np.pi * (1200 + 900 * t / 2.8 + k * 310) * t + k) * (0.2 / (k + 1)) for k in range(5))
    x = (banda(blanco(2.8), 800, 6000) * 0.4 + brillo) * np.sin(np.pi * t / 2.8) ** 2
    guardar("espiritu", x, 0.5)

    # Final: arpegio de koto en la escala miyako-bushi (re, mi bemol, sol, la, si bemol)
    notas = [293.7, 311.1, 392.0, 440.0, 466.2, 587.3, 622.3, 784.0]
    x = np.zeros(muestras(5.0))
    for k, nota in enumerate([0, 2, 3, 4, 5, 7, 6, 5]):
        colocar(x, karplus(notas[nota], 2.6, 0.6), 0.18 * k, 0.8 - k * 0.04)
    colocar(x, campana(1174.7, 3.0, caida=1.8) * 0.3, 1.5)
    guardar("final_caja_viva", x, 0.7)


# --- Relojero ----------------------------------------------------------------------------------

def relojero():
    x = np.zeros(muestras(2.0))
    for inicio, frecuencia in ((0.0, 3300), (1.0, 2600)):
        golpe = blanco(0.06) * envolvente(muestras(0.06), 0.0003, 0.003)
        colocar(x, resonancia(golpe, frecuencia, 40) + resonancia(golpe, frecuencia * 1.6, 50) * 0.5, inicio)
    guardar("tictac", x, 0.4)

    golpe = blanco(0.05) * envolvente(muestras(0.05), 0.0003, 0.003)
    guardar("cuerda", resonancia(golpe, 2900, 30) + resonancia(golpe, 5100, 40) * 0.5, 0.5)

    guardar("campanada", campana(392, 3.0, ((1, 1.0), (2.0, 0.6), (2.92, 0.4), (4.16, 0.25), (5.43, 0.15)), 1.6), 0.6)

    x = np.zeros(muestras(1.4))
    for k in range(10):
        golpe = blanco(0.03) * envolvente(muestras(0.03), 0.0003, 0.003)
        colocar(x, resonancia(golpe, 2400 + (k % 3) * 400, 30), 0.05 * k, 0.4)
    t = tiempo(0.25)
    colocar(x, np.sin(2 * np.pi * (180 - 80 * t / 0.25) * t) * envolvente(len(t), 0.001, 0.06), 0.6)
    colocar(x, resonancia(blanco(0.1) * envolvente(muestras(0.1), 0.0005, 0.01), 3000, 40), 0.62, 0.6)
    guardar("mecanismo", x, 0.7)

    t = tiempo(0.6)
    x = banda(blanco(0.6), 300, 2000) * (0.5 + np.abs(paso_bajo(blanco(0.6), 25)) * 5) * envolvente(len(t), 0.02, 0.25)
    t2 = tiempo(0.2)
    colocar(x, np.sin(2 * np.pi * 120 * t2) * envolvente(len(t2), 0.001, 0.04), 0.4)
    guardar("cajon", x, 0.6)

    # Final: caja de música (cuerdas pulsadas muy brillantes) con una melodía menor
    notas = [659.3, 784.0, 880.0, 987.8, 1046.5, 1174.7, 1318.5]
    melodia = [(0, 0.0), (2, 0.35), (4, 0.7), (3, 1.05), (2, 1.4), (1, 1.75), (2, 2.1), (0, 2.6), (4, 2.95), (6, 3.3)]
    x = np.zeros(muestras(5.5))
    for nota, inicio in melodia:
        colocar(x, campana(notas[nota], 1.6, ((1, 1.0), (3.0, 0.3), (5.2, 0.12)), 0.6), inicio, 0.7)
    guardar("final_relojero", x, 0.6)


# --- Reliquia ----------------------------------------------------------------------------------

def reliquia():
    t = tiempo(4.0)
    x = sum(np.sin(2 * np.pi * f * t) * a for f, a in ((55.0, 0.5), (55.4, 0.4), (110.2, 0.25), (165.0, 0.12)))
    x *= 0.8 + 0.2 * np.sin(2 * np.pi * 0.25 * t)
    x += banda(blanco(4.0), 200, 900) * 0.05
    guardar("zumbido", bucle(x, 0.5), 0.45)

    t = tiempo(2.4)
    barrido = np.sin(2 * np.pi * np.cumsum(80 + 600 * (t / 2.4) ** 2) / FM)
    x = barrido * np.sin(np.pi * t / 2.4) * 0.6 + banda(blanco(2.4), 2000, 8000) * (t / 2.4) ** 2 * 0.3
    guardar("despertar", x, 0.6)

    t = tiempo(0.7)
    x = np.sin(2 * np.pi * (220 - 120 * t / 0.7) * t) * envolvente(len(t), 0.005, 0.2)
    x += banda(blanco(0.7), 400, 3000) * envolvente(len(t), 0.002, 0.08) * 0.3
    guardar("pulso", x, 0.6)

    t = tiempo(1.2)
    x = sum(np.sin(2 * np.pi * (600 + 1400 * t / 1.2) * (1 + k * 0.5) * t) * (0.3 / (k + 1)) for k in range(4))
    guardar("luz_fluye", x * np.sin(np.pi * t / 1.2) ** 2, 0.45)

    guardar("cristal", campana(1760, 1.6, ((1, 1.0), (2.32, 0.5), (4.25, 0.3), (6.63, 0.2)), 1.2), 0.5)

    t = tiempo(2.6)
    motor = np.sin(2 * np.pi * np.cumsum(140 + 60 * np.sin(np.pi * t / 2.6)) / FM)
    x = banda(motor, 100, 2000) * 0.4 + banda(blanco(2.6), 300, 3000) * np.sin(np.pi * t / 2.6) * 0.4
    guardar("despliegue", x * np.sin(np.pi * t / 2.6), 0.6)

    t = tiempo(5.0)
    acorde = sum(np.sin(2 * np.pi * f * t) * a for f, a in ((220, 0.4), (277.2, 0.3), (329.6, 0.3), (440, 0.2), (659.3, 0.1)))
    x = acorde * np.minimum(t / 1.5, 1) * np.exp(-np.maximum(t - 2.5, 0) / 1.2)
    x += banda(blanco(5.0), 3000, 9000) * 0.05 * np.sin(np.pi * t / 5.0)
    guardar("final_reliquia", x, 0.6)


# --- Farero ------------------------------------------------------------------------------------

def farero():
    n = muestras(6.0)
    lluvia = banda(blanco(6.0), 800, 9000) * 0.3
    gotas = np.zeros(n)
    for _ in range(900):
        i = azar.integers(0, n - 2000)
        gotas[i:i + 600] += resonancia(azar.uniform(-1, 1, 600) * np.exp(-np.arange(600) / 80), azar.uniform(2500, 6000), 15) * azar.uniform(0.2, 1)
    guardar("lluvia", bucle(lluvia + gotas * 0.4, 0.5), 0.5)

    t = tiempo(6.0)
    viento = banda(blanco(6.0), 200, 1200) * (0.5 + 0.5 * np.sin(2 * np.pi * 0.17 * t) ** 2)
    silbido = np.sin(2 * np.pi * np.cumsum(500 + 150 * np.sin(2 * np.pi * 0.23 * t)) / FM) * 0.05
    guardar("viento", bucle(viento + silbido * (0.5 + 0.5 * np.sin(2 * np.pi * 0.31 * t)), 0.5), 0.45)

    t = tiempo(4.5)
    trueno = paso_bajo(blanco(4.5), 180, 4) * np.exp(-t / 1.4) * (1 + 0.6 * paso_bajo(blanco(4.5), 3) * 30)
    trueno += banda(blanco(4.5), 300, 2000) * np.exp(-t / 0.15) * 0.6
    guardar("trueno", trueno, 0.9)

    t = tiempo(0.45)
    x = resonancia(blanco(0.45) * envolvente(len(t), 0.0005, 0.01), 2300, 25)
    colocar(x, np.sin(2 * np.pi * 300 * tiempo(0.15)) * envolvente(muestras(0.15), 0.001, 0.03), 0.05, 0.4)
    guardar("candado_abre", x, 0.7)

    t = tiempo(0.6)
    x = banda(blanco(0.6), 500, 3000) * envolvente(len(t), 0.02, 0.15) * 0.5
    colocar(x, paso_bajo(blanco(0.15), 300) * envolvente(muestras(0.15), 0.002, 0.04), 0.35)
    guardar("libro", x, 0.6)

    x = np.zeros(muestras(0.6))
    for k in range(3):
        golpe = blanco(0.05) * envolvente(muestras(0.05), 0.0003, 0.004)
        colocar(x, resonancia(golpe, 2600 + k * 500, 35), 0.08 + k * 0.12, 0.7)
    guardar("llave", x, 0.6)

    t = tiempo(1.4)
    frecuencia = 150 + 30 * np.sin(2 * np.pi * 2.3 * t)
    x = banda((2 * ((np.cumsum(frecuencia) / FM) % 1) - 1) * (0.5 + np.abs(paso_bajo(blanco(1.4), 30)) * 5), 150, 2500)
    x *= envolvente(len(t), 0.05, 0.6)
    colocar(x, paso_bajo(blanco(0.3), 250) * envolvente(muestras(0.3), 0.002, 0.08) * 2, 1.0)
    guardar("trampilla", x, 0.75)

    t = tiempo(1.2)
    x = banda(blanco(1.2), 2000, 9000) * envolvente(len(t), 0.002, 0.08) * 1.2
    x += banda(blanco(1.2), 200, 1500) * np.clip(t - 0.1, 0, 1) * np.exp(-t / 0.6) * 1.5
    guardar("cerilla", x, 0.6)

    t = tiempo(5.0)
    sirena = sum(np.sin(2 * np.pi * f * t) * a for f, a in ((98, 0.6), (196, 0.3), (294, 0.15)))
    x = sirena * np.minimum(t / 0.4, 1) * np.exp(-np.maximum(t - 2.2, 0) / 0.9)
    x += sum(np.sin(2 * np.pi * f * t) * 0.08 for f in (392, 493.9, 587.3)) * np.minimum(t / 2.5, 1) * np.exp(-np.maximum(t - 3.5, 0))
    guardar("final_farero", x, 0.7)


# --- Salas y menú (0.2) ------------------------------------------------------------------------

def salas():
    # Traba: golpe sordo de madera y el pestillo que choca dos veces (sin que nada se mueva)
    t = tiempo(0.34)
    golpe = np.sin(2 * np.pi * (115 - 50 * t / 0.34) * t) * envolvente(len(t), 0.001, 0.035)
    golpe += paso_bajo(blanco(0.34), 700) * envolvente(len(t), 0.0005, 0.015) * 0.7
    x = np.zeros(muestras(0.34))
    colocar(x, golpe, 0.0)
    for k, inicio in enumerate((0.012, 0.075)):
        pestillo = blanco(0.06) * envolvente(muestras(0.06), 0.0003, 0.005)
        sonido = resonancia(pestillo, 2350 + k * 420, 70) + resonancia(pestillo, 3900 + k * 300, 80) * 0.6
        colocar(x, sonido, inicio, 0.55 - k * 0.2)
    guardar("trabado", x, 0.75)

    # Viaje de la cámara: un soplo suave que sube
    t = tiempo(0.6)
    soplo = blanco(0.6)
    centro = 500 + 1400 * (t / 0.6)
    salida = np.zeros_like(soplo)
    for i in range(0, len(soplo), 2048):
        tramo = soplo[i:i + 2048]
        c = float(centro[min(i, len(centro) - 1)])
        salida[i:i + len(tramo)] = banda(tramo, c * 0.6, c * 1.6)
    x = salida * np.sin(np.pi * t / 0.6) ** 2
    guardar("acercar", x, 0.35)

    # Puerta corredera (fusuma): madera que roza el carril y un toque al llegar
    t = tiempo(1.1)
    grano = np.abs(paso_bajo(blanco(1.1), 35)) * 6
    x = banda(blanco(1.1), 300, 2600) * (0.5 + grano) * np.sin(np.pi * np.clip(t / 0.95, 0, 1)) ** 0.7
    toque = np.sin(2 * np.pi * 150 * tiempo(0.15)) * envolvente(muestras(0.15), 0.001, 0.03)
    colocar(x, toque, 0.92, 0.9)
    guardar("corredera", x, 0.55)

    # Puerta con bisagra: el pestillo y un chirrido largo y grave
    t = tiempo(1.6)
    frecuencia = 150 + 35 * np.sin(2 * np.pi * 1.1 * t) + paso_bajo(blanco(1.6), 6) * 400
    fase = np.cumsum(frecuencia) / FM
    diente = 2 * (fase % 1) - 1
    friccion = np.abs(paso_bajo(blanco(1.6), 30)) * 7
    x = banda(diente * (0.3 + friccion), 250, 2600) * envolvente(len(t), 0.15, 1.0)
    pestillo = resonancia(blanco(0.08) * envolvente(muestras(0.08), 0.0005, 0.006), 1900, 25)
    colocar(x, pestillo, 0.0, 1.2)
    guardar("puerta", x, 0.55)

    # Fuego de chimenea (bucle): rumor grave y chasquidos sueltos
    n = muestras(7.0)
    rumor = paso_bajo(blanco(7.0), 180) * 1.2 + banda(blanco(7.0), 300, 1200) * 0.12
    for _ in range(140):
        inicio = azar.uniform(0, 6.8)
        fuerza = azar.uniform(0.05, 0.6) ** 2
        chasquido = banda(blanco(0.03) * envolvente(muestras(0.03), 0.0003, 0.004), 1200, 7000)
        colocar(rumor, chasquido, inicio, fuerza * 3)
    guardar("fuego", bucle(rumor, 0.5), 0.5)

    # Péndulo de un reloj de pie (bucle de dos segundos): tac grave y tic
    x = np.zeros(muestras(2.0))
    for inicio, frecuencia in ((0.0, 900), (1.0, 1250)):
        golpe = blanco(0.12) * envolvente(muestras(0.12), 0.0005, 0.01)
        sonido = resonancia(golpe, frecuencia, 30) + resonancia(golpe, frecuencia * 2.3, 40) * 0.4
        colocar(x, sonido, inicio)
    guardar("pendulo", x, 0.5)

    # Ambiente del gabinete (bucle de 24 s): un acorde grave que respira y notas de caja de música
    duracion = 24.0
    t = tiempo(duracion)
    lento = 0.65 + 0.35 * np.sin(2 * np.pi * t / duracion)
    acorde = np.zeros_like(t)
    for frecuencia, amplitud in ((110.0, 0.5), (164.8, 0.32), (220.0, 0.22), (277.2, 0.1)):
        acorde += np.sin(2 * np.pi * frecuencia * t + np.sin(2 * np.pi * 0.07 * t) * 0.6) * amplitud
    acorde = paso_bajo(acorde, 900) * lento
    sala = paso_bajo(blanco(duracion), 220) * 0.05
    x = acorde * 0.5 + sala
    escala = (440.0, 493.9, 554.4, 659.3, 740.0, 880.0)
    momentos = (1.0, 2.6, 4.1, 7.5, 8.4, 11.0, 13.8, 15.1, 17.9, 19.6, 21.2)
    for k, inicio in enumerate(momentos):
        nota = escala[(k * 3 + 1) % len(escala)] * (0.5 if k % 4 == 3 else 1.0)
        colocar(x, karplus(nota, 2.6, 0.62) * envolvente(muestras(2.6), 0.002, 1.2) * 0.22, inicio)
    guardar("gabinete", bucle(x, 1.5), 0.55)


def main():
    grupos = {g.__name__: g for g in (comunes, caja_viva, relojero, reliquia, farero, salas)}
    for nombre in sys.argv[1:] or list(grupos):
        print(nombre)
        grupos[nombre]()


if __name__ == "__main__":
    main()
