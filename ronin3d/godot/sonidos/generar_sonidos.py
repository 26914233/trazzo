# Genera los efectos de sonido del combate (WAV mono, 22050 Hz, 16 bits) con síntesis
# sencilla: ruido filtrado, senos que se apagan y chasquidos. Sin librerías externas.
# Uso: python3 generar_sonidos.py [nombre.wav ...]   (escribe los .wav junto a este archivo;
# sin nombres, todos)
import math
import pathlib
import random
import struct
import sys
import wave

FRECUENCIA = 22050
AQUI = pathlib.Path(__file__).parent


def muestras(segundos):
    return int(segundos * FRECUENCIA)


def ruido(n, semilla):
    azar = random.Random(semilla)
    return [azar.uniform(-1.0, 1.0) for _ in range(n)]


def pasa_banda(senal, centro, q=2.0):
    """Filtro de estado variable. «centro» puede ser un número o una función del índice."""
    bajo = banda = 0.0
    salida = []
    for i, x in enumerate(senal):
        f = centro(i) if callable(centro) else centro
        coef = 2.0 * math.sin(math.pi * min(f, FRECUENCIA * 0.45) / FRECUENCIA)
        alto = x - bajo - banda / q
        banda += coef * alto
        bajo += coef * banda
        salida.append(banda)
    return salida


def pasa_bajo(senal, corte):
    alfa = 1.0 - math.exp(-2.0 * math.pi * corte / FRECUENCIA)
    y = 0.0
    salida = []
    for x in senal:
        y += alfa * (x - y)
        salida.append(y)
    return salida


def resonancias(n, parciales, semilla):
    """Suma de senos que se apagan: [(frecuencia, amplitud, segundos hasta apagarse), ...]."""
    azar = random.Random(semilla)
    fases = [azar.uniform(0, 2 * math.pi) for _ in parciales]
    salida = [0.0] * n
    for (frecuencia, amplitud, caida), fase in zip(parciales, fases):
        for i in range(n):
            t = i / FRECUENCIA
            salida[i] += amplitud * math.exp(-t / caida) * math.sin(2 * math.pi * frecuencia * t + fase)
    return salida


def golpe_sordo(n, frecuencia, caida, bajada=0.4):
    """Seno grave con caída de tono: el «pum» de un impacto."""
    salida = []
    fase = 0.0
    for i in range(n):
        t = i / FRECUENCIA
        f = frecuencia * (1.0 - bajada * min(1.0, t / caida))
        fase += 2 * math.pi * f / FRECUENCIA
        salida.append(math.exp(-t / caida) * math.sin(fase))
    return salida


def envolvente(n, ataque, caida):
    return [min(1.0, (i / FRECUENCIA) / ataque) * math.exp(-max(0.0, i / FRECUENCIA - ataque) / caida)
            for i in range(n)]


def mezclar(*pistas):
    n = max(len(p) for p, _ in pistas)
    salida = [0.0] * n
    for pista, volumen in pistas:
        for i, x in enumerate(pista):
            salida[i] += x * volumen
    return salida


def multiplicar(a, b):
    return [x * y for x, y in zip(a, b)]


def guardar(nombre, senal, pico=0.85):
    maximo = max(abs(x) for x in senal) or 1.0
    # fundido final de 10 ms para que no haya chasquido al terminar
    fin = muestras(0.01)
    senal = [x * (min(1.0, (len(senal) - i) / fin)) for i, x in enumerate(senal)]
    with wave.open(str(AQUI / nombre), "wb") as archivo:
        archivo.setnchannels(1)
        archivo.setsampwidth(2)
        archivo.setframerate(FRECUENCIA)
        archivo.writeframes(b"".join(struct.pack("<h", int(x / maximo * pico * 32767)) for x in senal))
    print(nombre, f"{len(senal) / FRECUENCIA:.2f} s")


def tajo():
    # Silbido de la katana: ruido cuyo tono sube, con forma de ola.
    n = muestras(0.3)
    centro = lambda i: 600.0 * (2600.0 / 600.0) ** (i / n)
    forma = [math.sin(math.pi * i / n) ** 1.6 for i in range(n)]
    return multiplicar(pasa_banda(ruido(n, 1), centro, 2.5), forma)


def estocada():
    # Lanza: más corta y más grave que la espada.
    n = muestras(0.2)
    centro = lambda i: 420.0 * (1300.0 / 420.0) ** (i / n)
    forma = [math.sin(math.pi * i / n) ** 1.3 for i in range(n)]
    return multiplicar(pasa_banda(ruido(n, 2), centro, 2.0), forma)


def golpe():
    # Corte que da en el soldado: chasquido, «pum» grave y un poco de metal de la armadura.
    n = muestras(0.45)
    chasquido = multiplicar(pasa_banda(ruido(n, 3), 3200, 1.2), envolvente(n, 0.001, 0.012))
    metal = resonancias(n, [(1250, 0.5, 0.18), (2090, 0.4, 0.14), (2980, 0.3, 0.11), (4230, 0.2, 0.08)], 4)
    return mezclar((chasquido, 1.0), (golpe_sordo(n, 115, 0.07), 0.9), (metal, 0.45))


def parada():
    # Acero contra acero: campanazo brillante que dura más.
    n = muestras(0.8)
    chasquido = multiplicar(pasa_banda(ruido(n, 5), 4200, 1.0), envolvente(n, 0.001, 0.01))
    parciales = [(1850, 0.5, 0.45), (2760, 0.45, 0.35), (3940, 0.35, 0.28), (5210, 0.25, 0.2), (6630, 0.15, 0.14)]
    metal = resonancias(n, parciales, 6)
    metal_desafinado = resonancias(n, [(f * 1.004, a, c) for f, a, c in parciales], 7)
    return mezclar((chasquido, 1.0), (metal, 0.6), (metal_desafinado, 0.4), (golpe_sordo(n, 180, 0.05), 0.4))


def herido():
    # Akira recibe un golpe: «pum» grave y ruido apagado.
    n = muestras(0.32)
    sordo = multiplicar(pasa_bajo(ruido(n, 8), 900), envolvente(n, 0.002, 0.08))
    return mezclar((golpe_sordo(n, 85, 0.12, 0.5), 1.0), (sordo, 0.8))


def aviso():
    # Hyoshigi: dos tablillas de madera que chocan («¡tac-tac!»), el aviso del teatro kabuki.
    n = muestras(0.26)
    salida = [0.0] * n
    for inicio, semilla in [(0.0, 9), (0.085, 10)]:
        desplazamiento = muestras(inicio)
        m = n - desplazamiento
        clic = multiplicar(ruido(m, semilla), envolvente(m, 0.0005, 0.003))
        madera = resonancias(m, [(2150, 0.6, 0.045), (3380, 0.4, 0.03), (1320, 0.3, 0.05)], semilla)
        golpecito = mezclar((clic, 0.8), (madera, 1.0))
        for i, x in enumerate(golpecito):
            salida[desplazamiento + i] += x
    return salida


def caida():
    # El soldado cae: golpe grave y la armadura que traquetea.
    n = muestras(0.55)
    azar = random.Random(11)
    traqueteo = [0.0] * n
    for _ in range(14):
        centro = azar.randint(0, int(n * 0.6))
        for i in range(centro, min(n, centro + muestras(0.012))):
            traqueteo[i] += azar.uniform(-1, 1) * math.exp(-(i - centro) / muestras(0.004))
    traqueteo = pasa_banda(traqueteo, 2400, 1.5)
    return mezclar((golpe_sordo(n, 70, 0.14, 0.5), 1.0), (traqueteo, 0.7),
                   (multiplicar(pasa_bajo(ruido(n, 12), 600), envolvente(n, 0.005, 0.15)), 0.5))


def moneda():
    # «¡Clin!» de una moneda de cobre: dos toques metálicos agudos, el segundo algo más alto.
    n = muestras(0.35)
    salida = [0.0] * n
    for inicio, subida, semilla in [(0.0, 1.0, 13), (0.055, 1.33, 14)]:
        desplazamiento = muestras(inicio)
        m = n - desplazamiento
        toque = resonancias(m, [(2350 * subida, 0.6, 0.11), (3720 * subida, 0.45, 0.08), (5230 * subida, 0.3, 0.05)], semilla)
        clic = multiplicar(pasa_banda(ruido(m, semilla), 3400, 1.2), envolvente(m, 0.0005, 0.004))
        for i, x in enumerate(mezclar((toque, 1.0), (clic, 0.4))):
            salida[desplazamiento + i] += x * (1.0 if subida == 1.0 else 0.8)
    return salida


def escarbar():
    # Shiro escarba: arañazos rápidos en la tierra y algún terrón que cae.
    n = muestras(1.4)
    azar = random.Random(15)
    salida = [0.0] * n
    t = 0.0
    while t < 1.3:
        desplazamiento = muestras(t)
        m = min(muestras(0.05), n - desplazamiento)
        aranazo = multiplicar(pasa_banda(ruido(m, azar.randint(0, 9999)), azar.uniform(1400, 2600), 1.4),
                              envolvente(m, 0.003, 0.015))
        golpe = multiplicar(pasa_bajo(ruido(m, azar.randint(0, 9999)), 450), envolvente(m, 0.002, 0.02))
        fuerza = azar.uniform(0.6, 1.0)
        for i in range(m):
            salida[desplazamiento + i] += (aranazo[i] * 0.9 + golpe[i] * 0.7) * fuerza
        t += azar.uniform(0.07, 0.11)
    return salida


def ladrido():
    # «¡Guau, guau!» de un perro pequeño: tono que sube y baja, filtrado por dos formantes.
    n = muestras(0.5)
    salida = [0.0] * n
    for inicio, semilla in [(0.0, 16), (0.21, 17)]:
        desplazamiento = muestras(inicio)
        m = min(muestras(0.17), n - desplazamiento)
        fase = 0.0
        sierra = []
        for i in range(m):
            t = i / m
            tono = 480 + 260 * math.sin(math.pi * min(1.0, t * 1.6)) - 120 * t
            fase += tono / FRECUENCIA
            sierra.append(2.0 * (fase - math.floor(fase + 0.5)))
        voz = mezclar((pasa_banda(sierra, 950, 3.0), 1.0), (pasa_banda(sierra, 1900, 4.0), 0.6),
                      (pasa_banda(ruido(m, semilla), 2600, 1.5), 0.25))
        forma = envolvente(m, 0.008, 0.07)
        for i in range(m):
            salida[desplazamiento + i] += voz[i] * forma[i]
    return salida


if __name__ == "__main__":
    for nombre, generador in [("tajo.wav", tajo), ("estocada.wav", estocada), ("golpe.wav", golpe),
                              ("parada.wav", parada), ("herido.wav", herido), ("aviso.wav", aviso),
                              ("caida.wav", caida), ("moneda.wav", moneda), ("escarbar.wav", escarbar),
                              ("ladrido.wav", ladrido)]:
        if len(sys.argv) == 1 or nombre in sys.argv[1:]:
            guardar(nombre, generador())
