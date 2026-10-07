"""Arreglo del kappa de SAM 3D: el plato de la cabeza salió hueco y casi negro. Se pinta de acero
(gris medio, más claro hacia el borde) en la textura y se guarda dentro del GLB. El agua no se
pinta: va aparte, como pieza con reflejos (modelo_criatura.gd, «agua» en MODELOS).

Uso: python3 pintar_plato_kappa.py <kappa_sam3d.glb> <salida.glb> [depurar]
Con «depurar» pinta el plato de magenta, para ver qué caras se eligen.
Necesita numpy, Pillow y trimesh.
"""
import io
import os
import sys

import numpy as np
import trimesh
from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cambiar_textura_glb import cambiar_textura  # noqa: E402

CENTRO = np.array([0.04, 0.485, 0.204])   # centro del borde del plato (unidades del GLB, alto 1)
ALTURA_MIN = 0.392                         # por debajo empieza el pelo de la cabeza
RADIO_MAX = 0.21


def pintar(entrada, salida, depurar=False):
    g = list(trimesh.load(entrada).geometry.values())[0]
    v, f, uv = g.vertices, g.faces, g.visual.uv
    textura = g.visual.material.baseColorTexture.convert("RGB")
    ancho, alto = textura.size
    centros = v[f].mean(1)
    radial = np.hypot(centros[:, 0] - CENTRO[0], centros[:, 2] - CENTRO[2])
    plato = (centros[:, 1] > ALTURA_MIN) & (radial < RADIO_MAX)
    print("caras del plato:", int(plato.sum()), "de", len(f))
    dibujo = ImageDraw.Draw(textura)
    for i in np.where(plato)[0]:
        if depurar:
            color = (255, 0, 255)
        else:
            t = np.clip((centros[i, 1] - ALTURA_MIN) / (0.49 - ALTURA_MIN), 0, 1)
            claro = 78 + 52 * t * t
            color = (int(claro), int(claro + 4), int(claro + 10))
        puntos = [(uv[j, 0] * ancho, (1 - uv[j, 1]) * alto) for j in f[i]]
        # Un poco más grande que el triángulo, para que el filtrado no traiga el negro de al lado
        dibujo.polygon(puntos, fill=color, outline=color, width=3)
    memoria = io.BytesIO()
    textura.save(memoria, format="PNG", optimize=True)
    total = cambiar_textura(entrada, salida, memoria.getvalue())
    comprobado = list(trimesh.load(salida).geometry.values())[0]
    assert np.allclose(comprobado.vertices, v) and (comprobado.faces == f).all() \
        and np.allclose(comprobado.visual.uv, uv), "la malla cambió"
    print(salida, total, "bytes · malla y UV idénticas")


if __name__ == "__main__":
    pintar(sys.argv[1], sys.argv[2], len(sys.argv) > 3)
