"""Convierte en GIF los fotogramas que guarda la prueba automática de RONIN.

Uso:
    RONIN_FOTOGRAMAS=/ruta/fotogramas godot --path ronin3d/godot --fixed-fps 30 -- --prueba
    python3 ronin3d/herramientas/hacer_gifs.py /ruta/fotogramas ronin3d/capturas/actual

Hace un GIF por cada subcarpeta (iai, iai_destiempo, corte_luna...) a 30 imágenes por
segundo, con 96 colores y en bucle. Necesita Pillow (pip install pillow).
"""
import os
import sys

from PIL import Image


def hacer_gif(carpeta: str, salida: str, milisegundos: int = 33) -> None:
    archivos = sorted(f for f in os.listdir(carpeta) if f.endswith(".png"))
    if not archivos:
        return
    cuadros = [Image.open(os.path.join(carpeta, f)).convert("RGB") for f in archivos]
    # Una sola paleta, tomada del cuadro central, para que los colores no parpadeen.
    paleta = cuadros[len(cuadros) // 2].quantize(colors=96, method=Image.Quantize.MEDIANCUT)
    reducidos = [c.quantize(palette=paleta, dither=Image.Dither.NONE) for c in cuadros]
    reducidos[0].save(salida, save_all=True, append_images=reducidos[1:],
                      duration=milisegundos, loop=0, optimize=True)
    print(f"{salida}: {len(reducidos)} cuadros, {os.path.getsize(salida) // 1024} KB")


def main() -> None:
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)
    origen, destino = sys.argv[1], sys.argv[2]
    os.makedirs(destino, exist_ok=True)
    for nombre in sorted(os.listdir(origen)):
        carpeta = os.path.join(origen, nombre)
        if os.path.isdir(carpeta):
            hacer_gif(carpeta, os.path.join(destino, nombre + ".gif"))


if __name__ == "__main__":
    main()
