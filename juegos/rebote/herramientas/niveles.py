#!/usr/bin/env python3
"""Genera los niveles de Rebotazz -> datos/niveles.json.

6 mundos x 20 niveles. Mezcla dibujos de pixeles propios hechos de ladrillos y
patrones; la dificultad sube dentro del mundo y de un mundo a otro (mas filas,
mas ladrillos duros, metal y explosivos, algo mas de velocidad).

Caracteres: . vacio, 1-6 color, D duro (2), T duro (3), M metal, X explosivo, ? sorpresa.
Ningun ladrillo rompible puede quedar encerrado por metal (se comprueba).

Uso: python3 herramientas/niveles.py
"""
import json
import os
import random

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
COLS = 10

MUNDOS = [
    ("Espacio", ["#0B1026", "#1E1B4B"]),
    ("Océano", ["#04223A", "#0E4D6E"]),
    ("Bosque", ["#0B2A1C", "#1F4D2E"]),
    ("Desierto", ["#3A1F0B", "#7A4A1F"]),
    ("Volcán", ["#2A0A0A", "#5C1A12"]),
    ("Cristal", ["#1A0B33", "#3B1F6B"]),
]

# Dibujos propios de 10 columnas (digitos = color; . = vacio).
DIBUJOS = {
    "corazon": [".11...11..", "1111.1111.", "1111111111", "1111111111", ".11111111.", "..111111..", "...1111...", "....11...."],
    "estrella": ["....33....", "....33....", "...3333...", "3333333333", ".33333333.", "..333333..", ".333..333.", "33......33"],
    "invasor": ["..2....2..", "...2..2...", "..222222..", ".22.22.22.", "2222222222", "2.222222.2", "2.2....2.2", "...22.22.."],
    "pez": ["....444...", "..4444444.", ".44.444444", "4444444444", ".444444444", "..4444444.", "....444...", "...4..4..."],
    "flor": ["...5..5...", "..555555..", ".55533555.", ".55333355.", ".55533555.", "..555555..", "....44....", "...4444..."],
    "hongo": ["...1111...", ".11611611.", "1166111661", "1111111111", ".66666666.", "...6..6...", "...6666...", "...6666..."],
    "cohete": ["....22....", "...2222...", "...2662...", "...2222...", "..222222..", ".22.22.22.", "2...33...2", "....33...."],
    "arbol": ["....44....", "...4444...", "..444444..", ".44444444.", "...4444...", "..444444..", "....66....", "....66...."],
    "corona": ["3...33...3", "33.3333.33", "3333333333", "3311331133", "3333333333", ".33333333.", ".11111111.", "..........."[:10]],
    "fantasma": ["...5555...", "..555555..", ".55155155.", ".55555555.", ".55555555.", ".55555555.", ".5.55.55.5", "..........",],
    "diamante": ["....22....", "...2222...", "..222222..", ".22222222.", "2222222222", ".22222222.", "..222222..", "...2222...", "....22...."],
    "sol": ["3...33...3", ".3.3333.3.", "..333333..", "3333333333", "3333333333", "..333333..", ".3.3333.3.", "3...33...3"],
    "luna": ["...6666...", "..66......", ".666......", ".666......", ".666......", ".666......", "..66......", "...6666..."],
    "gato": ["1......1..", "11....11..", "1111111...", "1.11.111..", "1111111...", "11.1.11...", ".11111....", "..1..1...."],
    "manzana": ["....4.....", "...44.....", "..11111...", ".1111111..", ".1111111..", ".1111111..", "..11111...", "...1.1...."],
    "ancla": ["....44....", "...4..4...", "....44....", "....44....", "4...44...4", "44..44..44", ".44444444.", "...4444..."],
    "casa": ["....11....", "...1111...", "..111111..", ".11111111.", "..666666..", "..6.66.6..", "..666666..", "..66..66.."],
    "planeta": ["...2222...", ".22222222.", "2222222222", "5555555555", "2222222222", ".22222222.", "...2222...", ".........."],
    "cara": ["..333333..", ".33333333.", "3313333133", "3333333333", "3133333313", "3311111133", ".33333333.", "..333333.."],
    "llave": ["..333.....", ".3...3....", ".3...3....", "..333.....", "...3......", "...33.....", "...3......", "...33....."],
}


def patron(nombre, filas, rng):
    g = [["." for _ in range(COLS)] for _ in range(filas)]
    for f in range(filas):
        for c in range(COLS):
            col = str(1 + (f + c) % 6)
            if nombre == "lleno":
                g[f][c] = str(1 + f % 6)
            elif nombre == "piramide":
                if abs(c - 4.5) <= f * 0.6 + 0.5:
                    g[f][c] = str(1 + f % 6)
            elif nombre == "ajedrez":
                if (f + c) % 2 == 0:
                    g[f][c] = col
            elif nombre == "rayas":
                if f % 2 == 0:
                    g[f][c] = str(1 + (f // 2) % 6)
            elif nombre == "columnas":
                if c % 3 != 2:
                    g[f][c] = str(1 + c % 6)
            elif nombre == "rombo":
                if abs(c - 4.5) + abs(f - (filas - 1) / 2) <= filas / 2 + 1:
                    g[f][c] = col
            elif nombre == "olas":
                if (f + int(2 * abs(((c / 2.0) % 2) - 1))) % 3 != 0:
                    g[f][c] = str(1 + f % 6)
            elif nombre == "marco":
                if f in (0, filas - 1) or c in (0, COLS - 1) or (2 <= f <= filas - 3 and 2 <= c <= COLS - 3):
                    g[f][c] = col
    return ["".join(r) for r in g]


def dibujo(nombre, color_extra, rng):
    filas = [r[:COLS].ljust(COLS, ".") for r in DIBUJOS[nombre]]
    # variar colores: rota la paleta del dibujo segun el nivel
    salida = []
    for r in filas:
        salida.append("".join(str((int(ch) - 1 + color_extra) % 6 + 1) if ch.isdigit() else ch for ch in r))
    return salida


def endurecer(filas, mundo, pos, rng, metal=True):
    """Mete duros, metal, explosivos y sorpresas segun la dificultad."""
    dific = mundo + pos / 20.0          # 0 .. 6
    p_duro = min(0.05 + 0.045 * dific, 0.3)
    p_tres = min(max(0.0, 0.03 * (dific - 2)), 0.1)
    p_metal = 0.0 if dific < 0.6 or not metal else min(0.02 + 0.01 * dific, 0.08)
    p_expl = 0.0 if dific < 0.3 else 0.03
    p_sorp = 0.04
    g = [list(r) for r in filas]
    for f, r in enumerate(g):
        for c, ch in enumerate(r):
            if not ch.isdigit():
                continue
            x = rng.random()
            if x < p_metal and f > 0:
                g[f][c] = "M"
            elif x < p_metal + p_tres:
                g[f][c] = "T"
            elif x < p_metal + p_tres + p_duro:
                g[f][c] = "D"
            elif x < p_metal + p_tres + p_duro + p_expl:
                g[f][c] = "X"
            elif x < p_metal + p_tres + p_duro + p_expl + p_sorp:
                g[f][c] = "?"
    # ninguna fila casi entera de metal salvo las de las fortalezas (que ya traen huecos)
    if metal:
        for r in g:
            while r.count("M") > 5:
                r[r.index("M")] = "D"
    return ["".join(r) for r in g]


def liberar_encerrados(filas):
    """Ningun rompible encerrado: los metales que lo impiden pasan a duro."""
    alto = len(filas)
    g = [list(r) for r in filas]
    while True:
        # celdas alcanzables desde abajo (y desde arriba, que tambien es zona libre)
        vistos = set()
        pila = [(alto, c) for c in range(COLS)] + [(-1, c) for c in range(COLS)]
        while pila:
            f, c = pila.pop()
            if (f, c) in vistos or c < 0 or c >= COLS or f < -1 or f > alto:
                continue
            if 0 <= f < alto and g[f][c] == "M":
                continue
            vistos.add((f, c))
            pila += [(f + 1, c), (f - 1, c), (f, c + 1), (f, c - 1)]
        encerrado = [(f, c) for f in range(alto) for c in range(COLS) if g[f][c] not in ".M" and (f, c) not in vistos]
        if not encerrado:
            return ["".join(r) for r in g]
        f, c = encerrado[0]
        for df, dc in ((1, 0), (0, 1), (0, -1), (-1, 0)):
            ff, cc = f + df, c + dc
            if 0 <= ff < alto and 0 <= cc < COLS and g[ff][cc] == "M":
                g[ff][cc] = "D"
                break


def main():
    rng = random.Random(2026)
    dibujos = list(DIBUJOS)
    patrones = ["lleno", "piramide", "ajedrez", "rayas", "columnas", "rombo", "olas", "marco"]
    mundos = []
    k = 0
    for m, (nombre, fondo) in enumerate(MUNDOS):
        niveles = []
        for pos in range(20):
            filas_n = min(5 + m + pos // 4, 13)
            if pos % 2 == 0:
                d = dibujos[k % len(dibujos)]
                filas = dibujo(d, k, rng)
                tema = d
            else:
                pt = patrones[k % len(patrones)]
                filas = patron(pt, filas_n, rng)
                tema = pt
            if pos == 9 or pos == 19:          # especiales: fortaleza de metal con huecos
                filas = patron("lleno", filas_n, rng)
                filas = [("M" if f % 4 == 2 and c % 3 != 1 else ch) for f, r in enumerate(filas) for c, ch in enumerate(r)]
                filas = ["".join(filas[i * COLS:(i + 1) * COLS]) for i in range(filas_n)]
                tema = "fortaleza"
            if tema == "fortaleza":
                filas = endurecer(filas, max(m - 2, 0), pos, rng, metal=False)
            else:
                filas = endurecer(filas, m, pos, rng)
            filas = liberar_encerrados(filas)
            niveles.append({"filas": filas, "velocidad": round(0.92 + 0.05 * m + 0.004 * pos, 3), "tema": tema})
            k += 1
        mundos.append({"nombre": nombre, "fondo": fondo, "niveles": niveles})
    os.makedirs(os.path.join(RAIZ, "datos"), exist_ok=True)
    with open(os.path.join(RAIZ, "datos", "niveles.json"), "w", encoding="utf-8") as f:
        json.dump({"mundos": mundos}, f, ensure_ascii=False, indent=1)
    print(sum(len(m["niveles"]) for m in mundos), "niveles")


if __name__ == "__main__":
    main()
