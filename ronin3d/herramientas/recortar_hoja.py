#!/usr/bin/env python3
"""Recorta una hoja de sprites de enemigo (filas de cuadros sobre un fondo oscuro liso, sin texto) y
la monta como hoja del juego: godot/recursos/sprites/<id>.png y .json.

Sirve para las hojas en el estilo del oni del usuario (arte/conceptos/oni_jefe_hoja.webp) que se
generan con Gemini usándolo de referencia (ver arte/conceptos/LEEME_ENEMIGOS.md).

- Las filas se encuentran solas (bandas con píxeles que no son fondo) y, dentro de cada fila, los
  cuadros son las figuras conectadas. Los trozos pequeños (la punta de una lanza, una salpicadura)
  se unen a la figura más cercana, y los que solo tienen trozos (una nube de partículas) se agrupan
  como un cuadro propio. Así vale aunque un cuadro se meta en la columna del siguiente.
- El fondo se quita con un relleno desde los bordes de cada cuadro, así los oscuros de dentro del
  personaje se quedan.
- Todos los cuadros se alinean por los pies, igual que en recortar_oni_jefe.py.
- En el .json va «alto_px»: lo que mide el personaje en reposo, para darle su altura en el juego.

Uso:  python3 ronin3d/herramientas/recortar_hoja.py <imagen> <id> <fila1,fila2,...>
      p. ej.  ... hojas/kappa.png kappa reposo,caminar,ataque,golpe,muerte
"""
import json
import os
import sys
from collections import deque

import numpy as np
from PIL import Image

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOLERANCIA_FONDO = 48        # suma de diferencias RGB que aún cuenta como fondo (las hojas vienen en JPEG)
UMBRAL_CONTENIDO = 70        # más que esto respecto al fondo es personaje (para encontrar filas y cuadros)
HUECO_FILA = 6               # filas vacías seguidas que separan dos filas de cuadros
HUECO_CUADRO = 5             # columnas vacías seguidas que separan dos cuadros
MARGEN = 3
ENGROSAR = 3                 # píxeles con que se engrosa la máscara para agrupar figuras
FPS = {"reposo": 6.0, "caminar": 9.0}


def color_de_fondo(imagen: np.ndarray) -> np.ndarray:
    esquinas = np.concatenate([imagen[:8, :8].reshape(-1, 3), imagen[:8, -8:].reshape(-1, 3),
                               imagen[-8:, :8].reshape(-1, 3), imagen[-8:, -8:].reshape(-1, 3)])
    return np.median(esquinas, axis=0)


def tramos(perfil: np.ndarray, hueco: int, minimo: int) -> list:
    """Tramos de índices con contenido, uniendo los separados por menos de «hueco»."""
    resultado = []
    inicio = None
    vacio = 0
    for i, valor in enumerate(perfil):
        if valor:
            if inicio is None:
                inicio = i
            vacio = 0
            fin = i
        elif inicio is not None:
            vacio += 1
            if vacio >= hueco:
                resultado.append((inicio, fin + 1))
                inicio = None
    if inicio is not None:
        resultado.append((inicio, fin + 1))
    return [t for t in resultado if t[1] - t[0] >= minimo]


def figuras(mascara: np.ndarray) -> list:
    """Figuras conectadas (8 vecinos) de la máscara: lista de arrays de índices (y, x)."""
    alto, ancho = mascara.shape
    vista = np.zeros_like(mascara)
    resultado = []
    for y0, x0 in zip(*np.nonzero(mascara)):
        if vista[y0, x0]:
            continue
        cola = deque([(y0, x0)])
        vista[y0, x0] = True
        puntos = []
        while cola:
            y, x = cola.popleft()
            puntos.append((y, x))
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    ny, nx = y + dy, x + dx
                    if 0 <= ny < alto and 0 <= nx < ancho and mascara[ny, nx] and not vista[ny, nx]:
                        vista[ny, nx] = True
                        cola.append((ny, nx))
        resultado.append(np.array(puntos))
    return resultado


def engrosar(mascara: np.ndarray, radio: int) -> np.ndarray:
    resultado = mascara.copy()
    for dy in range(-radio, radio + 1):
        for dx in range(-radio, radio + 1):
            resultado |= np.roll(np.roll(mascara, dy, 0), dx, 1)
    return resultado


def cuadros_de_fila(original: np.ndarray) -> list:
    """Agrupa las figuras de una fila en cuadros; cada cuadro es una máscara del tamaño de la fila.
    Las figuras se buscan en la máscara engrosada (une la lanza fina o la armadura oscura que el
    JPEG parte en trozos) y el cuadro se queda con los píxeles de la original."""
    mascara = engrosar(original, ENGROSAR)
    piezas = [f for f in figuras(mascara) if len(f) >= 4]
    if not piezas:
        return []
    mayor = max(len(f) for f in piezas)
    grandes = [f for f in piezas if len(f) >= mayor * 0.2]
    pequenas = [f for f in piezas if len(f) < mayor * 0.2]
    grupos = [[f] for f in grandes]

    def distancia(a, b) -> float:
        ax0, ax1 = a[:, 1].min(), a[:, 1].max()
        bx0, bx1 = b[:, 1].min(), b[:, 1].max()
        return max(0, max(ax0, bx0) - min(ax1, bx1))

    sueltas = []
    for pieza in pequenas:
        cercana = min(range(len(grupos)), key=lambda i: min(distancia(pieza, g) for g in grupos[i]), default=None)
        if cercana is not None and min(distancia(pieza, g) for g in grupos[cercana]) <= 12:
            grupos[cercana].append(pieza)
        else:
            sueltas.append(pieza)
    # Las piezas sueltas cercanas entre sí forman un cuadro (partículas) si suman bastante.
    sueltas.sort(key=lambda f: f[:, 1].min())
    nube = []
    for pieza in sueltas:
        if nube and distancia(pieza, np.concatenate(nube)) <= 20:
            nube.append(pieza)
        else:
            if nube and sum(len(f) for f in nube) >= mayor * 0.15:
                grupos.append(nube)
            nube = [pieza]
    if nube and sum(len(f) for f in nube) >= mayor * 0.15:
        grupos.append(nube)
    resultado = []
    for grupo in grupos:
        puntos = np.concatenate(grupo)
        m = np.zeros_like(mascara)
        m[puntos[:, 0], puntos[:, 1]] = True
        resultado.append((puntos[:, 1].min(), m & original))
    resultado.sort(key=lambda r: r[0])
    return [m for _x, m in resultado]


def quitar_fondo(rgb: np.ndarray, fondo: np.ndarray) -> np.ndarray:
    alto, ancho, _ = rgb.shape
    parecido = np.abs(rgb.astype(int) - fondo).sum(2) <= TOLERANCIA_FONDO
    es_fondo = np.zeros((alto, ancho), bool)
    cola = deque((y, x) for y in range(alto) for x in (0, ancho - 1) if parecido[y, x])
    cola.extend((y, x) for x in range(ancho) for y in (0, alto - 1) if parecido[y, x])
    while cola:
        y, x = cola.popleft()
        if es_fondo[y, x]:
            continue
        es_fondo[y, x] = True
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < alto and 0 <= nx < ancho and parecido[ny, nx] and not es_fondo[ny, nx]:
                cola.append((ny, nx))
    return np.dstack([rgb, np.where(es_fondo, 0, 255).astype(np.uint8)])


def main() -> None:
    if len(sys.argv) < 4:
        print(__doc__)
        sys.exit(1)
    ruta, ident, nombres = sys.argv[1], sys.argv[2], sys.argv[3].split(",")
    imagen = np.array(Image.open(ruta).convert("RGB"))
    fondo = color_de_fondo(imagen)
    contenido = np.abs(imagen.astype(int) - fondo).sum(2) > UMBRAL_CONTENIDO
    filas = tramos(contenido.sum(1) > 2, HUECO_FILA, 20)
    if len(filas) != len(nombres):
        sys.exit(f"{ident}: salen {len(filas)} filas y se esperaban {len(nombres)}: {filas}")
    recortes = []           # (nombre de la fila, rgba, base, centro)
    for nombre, (y0, y1) in zip(nombres, filas):
        y0, y1 = max(0, y0 - MARGEN), min(imagen.shape[0], y1 + MARGEN)
        banda = imagen[y0:y1]
        # Máscara amplia (tolerancia del fondo) para que el contorno oscuro entre en la figura.
        amplia = np.abs(banda.astype(int) - fondo).sum(2) > TOLERANCIA_FONDO
        for mascara in cuadros_de_fila(amplia):
            ys, xs = np.nonzero(mascara)
            cy0, cy1, cx0, cx1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
            alfa = np.where(mascara[cy0:cy1, cx0:cx1], 255, 0).astype(np.uint8)
            rgba = np.dstack([banda[cy0:cy1, cx0:cx1], alfa])
            solido = alfa > 0
            if solido.sum() < 30:
                continue
            ys = np.where(solido.any(1))[0]
            base = ys.max()
            abajo = solido[max(0, base - (base - ys.min()) // 4):base + 1]
            centro = int(np.median(np.where(abajo)[1]))
            recortes.append((nombre, rgba, base, centro, ys.max() - ys.min()))
    # Celda común: lo bastante grande para el cuadro más ancho y el más alto, con los pies abajo.
    izquierda = max(r[3] for r in recortes) + MARGEN
    derecha = max(r[1].shape[1] - r[3] for r in recortes) + MARGEN
    arriba = max(r[2] for r in recortes) + MARGEN
    celda = (int(izquierda + derecha), int(arriba + MARGEN))
    pies = (int(izquierda), int(arriba))
    columnas_hoja = max(1, 2048 // celda[0])
    filas_hoja = (len(recortes) + columnas_hoja - 1) // columnas_hoja
    hoja = Image.new("RGBA", (celda[0] * columnas_hoja, celda[1] * filas_hoja), (0, 0, 0, 0))
    descripcion = {"id": ident, "tam": list(celda), "pies": list(pies), "columnas": columnas_hoja,
                   "alto_px": int(recortes[0][4]), "animaciones": {}}
    for i, (nombre, rgba, base, centro, _alto) in enumerate(recortes):
        if nombre not in descripcion["animaciones"]:
            descripcion["animaciones"][nombre] = {"inicio": i, "cuadros": 0, "fps": FPS.get(nombre, 0.0)}
        descripcion["animaciones"][nombre]["cuadros"] += 1
        destino = (int((i % columnas_hoja) * celda[0] + pies[0] - centro), int((i // columnas_hoja) * celda[1] + pies[1] - base))
        hoja.alpha_composite(Image.fromarray(rgba, "RGBA"), destino)
    salida = os.path.join(RAIZ, "godot", "recursos", "sprites", ident)
    hoja.save(salida + ".png")
    with open(salida + ".json", "w", encoding="utf-8") as archivo:
        json.dump(descripcion, archivo, ensure_ascii=False, indent=1)
    resumen = ", ".join(f"{n} {a['cuadros']}" for n, a in descripcion["animaciones"].items())
    print(f"{ident}: {len(recortes)} cuadros ({resumen}); celda {celda[0]}×{celda[1]}, "
          f"alto en reposo {descripcion['alto_px']} px; hoja {hoja.size[0]}×{hoja.size[1]}")


if __name__ == "__main__":
    main()
