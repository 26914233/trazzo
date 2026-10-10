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
- Gemini a veces escribe el nombre de cada fila («IDLE», «WALK CYCLE»…) o dibuja una línea de suelo
  bajo cada fila: las bandas bajas de píxeles grises y claros (texto) y las filas de píxeles con un
  tramo seguido de más de un tercio del ancho (líneas) se borran antes de buscar los cuadros.

Uso:  python3 ronin3d/herramientas/recortar_hoja.py <imagen> <id> <fila1,fila2,...> [fila:cuadro,...]
      p. ej.  ... hojas/kappa.png kappa reposo,caminar,ataque,golpe,muerte
      El cuarto argumento, opcional, arregla cuadros, contados desde 0 dentro de cada fila:
        «ataque:0» quita ese cuadro (salió mal);
        «caminar:1/3» parte ese cuadro en 3 (figuras pegadas que se tocan con las patas).
      Una fila con dos animaciones se escribe «golpe+muerte@3»: los 3 primeros cuadros son «golpe»
      y el resto, «muerte».
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
ALTO_MINIMO_FILA = 60        # una banda más baja no es una fila de cuadros: es texto, una línea o un trozo
LINEA = 0.34                 # un tramo seguido más largo que esta parte del ancho es una línea dibujada
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


def tramo_mas_largo(fila: np.ndarray) -> int:
    mejor = actual = 0
    for valor in fila:
        actual = actual + 1 if valor else 0
        mejor = max(mejor, actual)
    return mejor


def es_texto(imagen: np.ndarray, contenido: np.ndarray) -> bool:
    """Una banda baja es texto si casi todo lo que tiene es gris claro (las letras de los rótulos)."""
    return gris_claro(imagen[contenido])


def gris_claro(pixeles: np.ndarray) -> bool:
    pixeles = pixeles.astype(int)
    if len(pixeles) == 0:
        return True
    gris = (pixeles.max(1) - pixeles.min(1)) < 40
    claro = pixeles.max(1) > 110
    return float((gris & claro).mean()) > 0.5


def borrar_palabras(imagen: np.ndarray, contenido: np.ndarray, amplia: np.ndarray) -> None:
    """Borra los rótulos pegados a una fila: letras sueltas (figuras pequeñas de gris claro) que
    forman una línea, al menos tres seguidas con la misma altura y poca separación. Las partículas
    grises de una muerte no se tocan, porque están desperdigadas."""
    letras = []
    for figura in figuras(contenido):
        ys, xs = figura[:, 0], figura[:, 1]
        alto, ancho = ys.max() - ys.min() + 1, xs.max() - xs.min() + 1
        if 4 <= alto <= 20 and ancho <= 36 and gris_claro(imagen[ys, xs]):
            letras.append((ys.min(), ys.max(), xs.min(), xs.max(), figura))
    letras.sort(key=lambda l: (l[0], l[2]))
    usadas = set()
    for i, letra in enumerate(letras):
        if i in usadas:
            continue
        palabra = [i]
        for j in range(i + 1, len(letras)):
            otra = letras[j]
            ultima = letras[palabra[-1]]
            if j not in usadas and abs(otra[1] - ultima[1]) <= 2 and 0 <= otra[2] - ultima[3] <= 10:
                palabra.append(j)
        if len(palabra) >= 2 and letras[palabra[-1]][3] - letras[palabra[0]][2] >= 18:
            for k in palabra:
                usadas.add(k)
                figura = letras[k][4]
                y0, y1 = letras[k][0] - 1, letras[k][1] + 2
                x0, x1 = letras[k][2] - 1, letras[k][3] + 2
                contenido[max(0, y0):y1, max(0, x0):x1] = False
                amplia[max(0, y0):y1, max(0, x0):x1] = False


def limpiar(imagen: np.ndarray, fondo: np.ndarray, contenido: np.ndarray, amplia: np.ndarray) -> list:
    """Borra líneas y rótulos (de «contenido» y de «amplia») y devuelve las filas de cuadros."""
    ancho = imagen.shape[1]
    lineas = [y for y in range(imagen.shape[0]) if tramo_mas_largo(amplia[y]) > ancho * LINEA]
    # El borde de una línea (antialias del JPEG) también se va, aunque su tramo sea más corto.
    bordes = [y + d for y in lineas for d in (-2, -1, 1, 2)
              if 0 <= y + d < imagen.shape[0] and tramo_mas_largo(amplia[y + d]) > ancho * LINEA / 2]
    for y in set(lineas + bordes):
        contenido[y] = False
        amplia[y] = False
    borrar_palabras(imagen, contenido, amplia)
    bandas = tramos(contenido.sum(1) > 2, 2, 1)
    filas = [b for b in bandas if b[1] - b[0] >= ALTO_MINIMO_FILA]
    for y0, y1 in bandas:
        if y1 - y0 >= ALTO_MINIMO_FILA:
            continue
        if not filas or es_texto(imagen[y0:y1], contenido[y0:y1]):
            contenido[y0:y1] = False
            amplia[y0:y1] = False
            continue
        # Un trozo suelto (puntas de alas, polvo) va con la fila más cercana.
        i = min(range(len(filas)), key=lambda k: max(filas[k][0] - y1, y0 - filas[k][1], 0))
        filas[i] = (min(filas[i][0], y0), max(filas[i][1], y1))
    return filas


def partir_mascara(mascara: np.ndarray, partes: int) -> list:
    """Parte una figura en «partes» cuadros por las columnas con menos píxeles cerca de los cortes
    iguales (para figuras que se tocan con las patas)."""
    if partes <= 1:
        return [mascara]
    xs = np.where(mascara.any(0))[0]
    x0, x1 = xs.min(), xs.max() + 1
    perfil = mascara.sum(0)
    cortes = [x0]
    for i in range(1, partes):
        ideal = x0 + (x1 - x0) * i // partes
        margen = (x1 - x0) // (partes * 4)
        ventana = perfil[ideal - margen:ideal + margen + 1]
        cortes.append(ideal - margen + int(np.argmin(ventana)))
    cortes.append(x1)
    resultado = []
    for a, b in zip(cortes, cortes[1:]):
        trozo = np.zeros_like(mascara)
        trozo[:, a:b] = mascara[:, a:b]
        resultado.append(trozo)
    return resultado


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
    quitar = set()
    partir = {}
    if len(sys.argv) > 4:
        for par in sys.argv[4].split(","):
            fila, cuadro = par.split(":")
            if "/" in cuadro:
                cuadro, partes = cuadro.split("/")
                partir[(fila, int(cuadro))] = int(partes)
            else:
                quitar.add((fila, int(cuadro)))
    imagen = np.array(Image.open(ruta).convert("RGB"))
    fondo = color_de_fondo(imagen)
    contenido = np.abs(imagen.astype(int) - fondo).sum(2) > UMBRAL_CONTENIDO
    # Máscara amplia (tolerancia del fondo) para que el contorno oscuro entre en la figura.
    amplia_hoja = np.abs(imagen.astype(int) - fondo).sum(2) > TOLERANCIA_FONDO
    filas = limpiar(imagen, fondo, contenido, amplia_hoja)
    if len(filas) != len(nombres):
        sys.exit(f"{ident}: salen {len(filas)} filas y se esperaban {len(nombres)}: {filas}")
    recortes = []           # (nombre de la fila, rgba, base, centro)
    for nombre_fila, (y0, y1) in zip(nombres, filas):
        y0, y1 = max(0, y0 - MARGEN), min(imagen.shape[0], y1 + MARGEN)
        banda = imagen[y0:y1]
        amplia = amplia_hoja[y0:y1]
        mascaras = []
        for k, mascara in enumerate(cuadros_de_fila(amplia)):
            if (nombre_fila, k) in quitar:
                continue
            mascaras.extend(partir_mascara(mascara, partir.get((nombre_fila, k), 1)))
        for k, mascara in enumerate(mascaras):
            nombre = nombre_fila
            if "+" in nombre_fila:
                primera, resto = nombre_fila.split("+")
                segunda, corte = resto.split("@")
                nombre = primera if k < int(corte) else segunda
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
