#!/usr/bin/env python3
"""Cara de la caja viva: del dibujo de alturas que dio Gemini (cara_gemini.png) saca lo que usa Blender.

- cara_altura.png (16 bits): 0,3 es el nivel de la placa; la cara sube hasta 1; los agujeros (la cuenca
  vacía, el del cuerno y las grietas) bajan a 0. En Blender: punto medio 0,3.
- cara_color.png: madera de paulownia con las cavidades oscurecidas, los agujeros casi negros y el iris
  rojo en el ojo abierto.
- cara_emision.png: solo el iris, para que brille.

Uso:  python3 puzles/herramientas/blender/preparar_cara.py
"""
import os
import numpy as np
from PIL import Image
from scipy import ndimage

AQUI = os.path.dirname(os.path.abspath(__file__))
ARTE = os.path.normpath(os.path.join(AQUI, "..", "..", "arte", "caja_viva"))
TEXTURAS = os.path.normpath(os.path.join(AQUI, "..", "..", "godot", "recursos", "texturas"))
LADO = 1024
OJO = (335, 478)          # centro del iris del ojo abierto, en píxeles del dibujo (medido a mano)
RADIO_IRIS = 24
RADIO_PUPILA = 9
NIVEL_PLACA = 0.3


def main():
    alto = np.asarray(Image.open(os.path.join(ARTE, "cara_gemini.png")).convert("L").resize((LADO, LADO),
        Image.LANCZOS)).astype(np.float64) / 255.0
    oscuro = alto < 0.06
    # Lo oscuro que toca el borde es el fondo; lo oscuro encerrado por la cara son agujeros
    etiquetas, cuantas = ndimage.label(oscuro)
    borde = set(np.unique(np.concatenate([etiquetas[0], etiquetas[-1], etiquetas[:, 0], etiquetas[:, -1]])))
    fondo = np.isin(etiquetas, list(borde - {0}))
    agujeros = oscuro & ~fondo
    agujeros = ndimage.binary_dilation(agujeros, iterations=2) & ~fondo
    cara = ~fondo & ~agujeros
    # Altura: la cara, suavizada un poco para quitar escalones del JPG; los agujeros, abajo
    suave = ndimage.gaussian_filter(alto, 1.2)
    altura = np.full_like(alto, NIVEL_PLACA)
    altura[cara] = NIVEL_PLACA + (1.0 - NIVEL_PLACA) * np.clip(suave[cara], 0.0, 1.0)
    # los agujeros, con las paredes en pendiente (si no, en Godot se ven dientes de sierra)
    hondura = ndimage.gaussian_filter(agujeros.astype(np.float64), 2.5)
    altura = altura * (1.0 - np.clip(hondura * 1.4, 0.0, 1.0))
    altura = ndimage.gaussian_filter(altura, 1.0)
    Image.fromarray((altura * 65535).astype(np.uint16)).save(os.path.join(ARTE, "cara_altura.png"))

    # Color: veta de paulownia (madera clara, un poco más pálida) repetida
    # veta vertical, como en una máscara sacada de un tablón; la paulownia es pálida y de veta suave
    madera = Image.open(os.path.join(TEXTURAS, "madera_clara.png")).convert("RGB").rotate(90).resize((LADO, LADO))
    madera = np.asarray(madera).astype(np.float64) / 255.0
    madera = (madera * 0.4 + np.array([0.9, 0.82, 0.68]) * 0.6) * 0.74
    # Oclusión: donde el entorno está más alto que el punto, entra menos luz
    media = ndimage.gaussian_filter(altura, 9.0)
    oclusion = np.clip(1.0 - (media - altura) * 5.0, 0.35, 1.0)
    color = madera * oclusion[..., None]
    # Agujeros casi negros, con el borde quemado
    sombra = ndimage.gaussian_filter(agujeros.astype(np.float64), 3.0)
    color = color * (1.0 - 0.94 * np.clip(sombra * 1.8, 0.0, 1.0))[..., None]
    # Iris rojo con la pupila negra, en el ojo abierto
    yy, xx = np.mgrid[0:LADO, 0:LADO]
    distancia = np.hypot(xx - OJO[0], yy - OJO[1])
    iris = np.clip((RADIO_IRIS + 1.0 - distancia), 0.0, 1.0)
    pupila = np.clip((RADIO_PUPILA + 1.0 - distancia), 0.0, 1.0)
    rojo = np.array([0.78, 0.07, 0.04]) * (0.75 + 0.25 * np.clip(distancia / RADIO_IRIS, 0, 1))[..., None]
    color = color * (1.0 - iris[..., None]) + rojo * iris[..., None]
    color = color * (1.0 - pupila[..., None]) + np.array([0.02, 0.0, 0.0]) * pupila[..., None]
    Image.fromarray((np.clip(color, 0, 1) * 255).astype(np.uint8)).save(os.path.join(ARTE, "cara_color.png"),
        optimize=True)
    brillo = np.array([1.0, 0.18, 0.08]) * (iris - pupila)[..., None]
    Image.fromarray((np.clip(brillo, 0, 1) * 255).astype(np.uint8)).save(os.path.join(ARTE, "cara_emision.png"),
        optimize=True)
    print("cara: %d agujeros, %.0f %% de cara" % (cuantas - len(borde - {0}), 100.0 * cara.mean()))


if __name__ == "__main__":
    main()
