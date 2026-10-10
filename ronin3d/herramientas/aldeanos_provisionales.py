#!/usr/bin/env python3
"""Aldeanos PROVISIONALES para la aldea: salen de los cuadros de reposo del noppera-bō (el samurái
sin rostro), con la ropa teñida y una cara pintada (ojos, cejas y boca). Se hicieron así el
10-10-2026 porque el crédito de Gemini se acabó a mitad del trabajo; cuando vuelva a haberlo, se
genera su hoja de verdad (ver arte/conceptos/LEEME_ENEMIGOS.md) y se borra este paso.

Salida: godot/recursos/sprites/aldeanos_hoja.png y .json, una fila por aldeano (anciano, aldeana,
sastre, monje), cuatro cuadros cada una.

Uso:  python3 ronin3d/herramientas/aldeanos_provisionales.py
"""
import json
import os

import numpy as np
from PIL import Image

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SPRITES = os.path.join(RAIZ, "godot", "recursos", "sprites")
# (fila, color de la ropa, si lleva sombrero de paja)
ALDEANOS = [
    ("anciano", (0.62, 0.45, 0.30), True),
    ("aldeana", (0.30, 0.38, 0.70), True),
    ("sastre", (0.75, 0.28, 0.24), True),
    ("monje", (0.55, 0.55, 0.52), False),
]


def pintar(cuadro: np.ndarray, ropa, con_sombrero: bool) -> np.ndarray:
    rgb = cuadro[..., :3].astype(float)
    alfa = cuadro[..., 3] > 0
    maximo = rgb.max(2)
    minimo = rgb.min(2)
    saturacion = (maximo - minimo) / np.maximum(maximo, 1.0)
    ropa_oscura = alfa & (saturacion < 0.22) & (maximo < 120)
    resultado = rgb.copy()
    resultado[ropa_oscura] = rgb[ropa_oscura] * 1.5 * np.array(ropa)
    # La cara lisa: los píxeles pálidos justo debajo del ala del sombrero (la fila ancha de arriba).
    filas = np.where(alfa.any(1))[0]
    arriba = filas.min()
    alto = filas.max() - arriba
    ala = arriba
    visto_ala = False
    for y in range(arriba, arriba + int(alto * 0.25)):
        xs_fila = np.where(alfa[y])[0]
        ancha = len(xs_fila) > 0 and xs_fila.max() - xs_fila.min() > 24
        if ancha:
            ala = y
            visto_ala = True
        elif visto_ala:
            break
    cara = alfa & (maximo > 185) & (saturacion < 0.3)
    cara[:ala + 2] = False
    cara[ala + 20:] = False
    ys, xs = np.nonzero(cara)
    if len(ys):
        y0, y1, x0, x1 = ys.min(), ys.max(), xs.min(), xs.max()
        ojo_y = y0 + (y1 - y0) * 2 // 5
        ojo_x = x1 - 2
        oscuro = np.array([40, 26, 22])
        resultado[ojo_y:ojo_y + 2, ojo_x - 1:ojo_x + 1] = oscuro
        resultado[ojo_y - 2, ojo_x - 2:ojo_x + 1] = oscuro * 1.4
        boca_y = y0 + (y1 - y0) * 4 // 5
        resultado[boca_y, ojo_x - 2:ojo_x + 1] = np.array([120, 60, 52])
    if not con_sombrero:
        # Sin sombrero, el de paja se tiñe de gris como una capucha de monje.
        paja = alfa & (saturacion > 0.3) & (rgb[..., 0] > rgb[..., 2] + 30)
        paja[arriba + int(alto * 0.25):] = False
        resultado[paja] = rgb[paja].mean(1, keepdims=True) * np.array([0.6, 0.6, 0.6])
    salida = cuadro.copy()
    salida[..., :3] = np.clip(resultado, 0, 255).astype(np.uint8)
    return salida


def main() -> None:
    with open(os.path.join(SPRITES, "noppera_bo_hoja.json"), encoding="utf-8") as archivo:
        datos = json.load(archivo)
    hoja = np.array(Image.open(os.path.join(SPRITES, "noppera_bo_hoja.png")).convert("RGBA"))
    ancho, alto = datos["tam"]
    columnas = datos["columnas"]
    reposo = datos["animaciones"]["reposo"]
    cuadros = []
    for k in range(reposo["cuadros"]):
        n = reposo["inicio"] + k
        x, y = (n % columnas) * ancho, (n // columnas) * alto
        cuadros.append(hoja[y:y + alto, x:x + ancho])
    por_fila = len(cuadros)
    salida = np.zeros((alto * len(ALDEANOS), ancho * por_fila, 4), np.uint8)
    animaciones = {}
    for fila, (nombre, ropa, sombrero) in enumerate(ALDEANOS):
        animaciones[nombre] = {"inicio": fila * por_fila, "cuadros": por_fila, "fps": 4.0}
        for k, cuadro in enumerate(cuadros):
            salida[fila * alto:(fila + 1) * alto, k * ancho:(k + 1) * ancho] = pintar(cuadro, ropa, sombrero)
    # visual_hoja.gd necesita las filas de siempre: «reposo» es la del anciano.
    for comun in ("reposo", "caminar", "ataque", "golpe", "muerte"):
        animaciones[comun] = dict(animaciones["anciano"])
    Image.fromarray(salida, "RGBA").save(os.path.join(SPRITES, "aldeanos_hoja.png"))
    nuevo = {"id": "aldeanos_hoja", "tam": datos["tam"], "pies": datos["pies"], "columnas": por_fila,
             "alto_px": datos["alto_px"], "animaciones": animaciones}
    with open(os.path.join(SPRITES, "aldeanos_hoja.json"), "w", encoding="utf-8") as archivo:
        json.dump(nuevo, archivo, ensure_ascii=False, indent=1)
    print(f"aldeanos_hoja: {len(ALDEANOS)} aldeanos provisionales, {por_fila} cuadros cada uno")


if __name__ == "__main__":
    main()
