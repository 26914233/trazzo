"""Convierte la malla que saca el conector de SketchUp (triángulos por material, en pulgadas y con
Z arriba) en un GLB para Godot (metros, Y arriba, el frente a +Z), con normales suaves por ángulo y
una paleta de colores como textura: una sola malla y una sola llamada de dibujo.

Uso: python3 sketchup_a_glb.py <resultado_build_model.txt|json> <salida.glb>
El resultado es el JSON que devuelve build_model con {"colores": {...}, "posiciones": {...}}.
Necesita numpy, Pillow y trimesh.
"""
import json
import math
import sys

import numpy as np
import trimesh
from PIL import Image

PULGADA = 0.0254
ANGULO_SUAVE = 40.0          # grados: por debajo, las caras vecinas se ven redondeadas


def leer(ruta):
    texto = open(ruta, encoding="utf-8").read()
    datos = json.loads(texto)
    if isinstance(datos, list):                        # algunas herramientas lo envuelven en [{"text": ...}]
        datos = json.loads(datos[0]["text"])
    return datos.get("result", datos)


def convertir(entrada, salida):
    datos = leer(entrada)
    colores = datos["colores"]
    nombres = sorted(datos["posiciones"])
    # Paleta: un bloque de 8×8 píxeles por material (el filtrado no mezcla colores vecinos)
    paleta = Image.new("RGB", (8 * len(nombres), 8))
    for i, nombre in enumerate(nombres):
        paleta.paste(tuple(colores.get(nombre, [255, 0, 255])), (8 * i, 0, 8 * i + 8, 8))
    posiciones, uvs, materiales = [], [], []
    for i, nombre in enumerate(nombres):
        p = np.array(datos["posiciones"][nombre], dtype=np.float64).reshape(-1, 3)
        # SketchUp (x, y, z) con Z arriba y el frente a −Y → Godot (x, z, −y), en metros
        p = np.stack([p[:, 0], p[:, 2], -p[:, 1]], axis=1) * PULGADA
        posiciones.append(p)
        uvs.append(np.tile([(i + 0.5) / len(nombres), 0.5], (len(p), 1)))
        materiales.append(np.full(len(p) // 3, i))
    v = np.concatenate(posiciones)
    uv = np.concatenate(uvs)
    material = np.concatenate(materiales)
    tri = v.reshape(-1, 3, 3)
    normal_cara = np.cross(tri[:, 1] - tri[:, 0], tri[:, 2] - tri[:, 0])
    normal_cara /= np.maximum(np.linalg.norm(normal_cara, axis=1, keepdims=True), 1e-12)
    # Normales suaves: en cada esquina se promedian las caras del mismo material que la tocan y no
    # se separan más de ANGULO_SUAVE de la propia (los aros, tapas y cantos quedan marcados)
    clave = [tuple(np.round(x / 1e-4).astype(np.int64)) + (int(material[k // 3]),) for k, x in enumerate(v)]
    vecinas = {}
    for k, c in enumerate(clave):
        vecinas.setdefault(c, []).append(k // 3)
    limite = math.cos(math.radians(ANGULO_SUAVE))
    normales = np.zeros_like(v)
    for k, c in enumerate(clave):
        propia = normal_cara[k // 3]
        suma = np.zeros(3)
        for t in vecinas[c]:
            if np.dot(normal_cara[t], propia) >= limite:
                suma += normal_cara[t]
        normales[k] = suma / max(np.linalg.norm(suma), 1e-12)
    caras = np.arange(len(v)).reshape(-1, 3)
    malla = trimesh.Trimesh(vertices=v, faces=caras, vertex_normals=normales, process=False,
                            visual=trimesh.visual.TextureVisuals(uv=uv, material=trimesh.visual.material.PBRMaterial(
                                baseColorTexture=paleta, metallicFactor=0.0, roughnessFactor=1.0)))
    malla.export(salida, file_type="glb", include_normals=True)
    alto = v[:, 1].max() - v[:, 1].min()
    print(salida, "·", len(caras), "triángulos ·", len(nombres), "materiales · alto %.3f m" % alto)
    return {nombre: int((material == i).sum()) for i, nombre in enumerate(nombres)}


if __name__ == "__main__":
    print(convertir(sys.argv[1], sys.argv[2]))
