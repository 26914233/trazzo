#!/usr/bin/env python3
"""Monta la hoja comparativa de estilos de render (DECISIÓN 20) con las capturas que deja
godot/scripts/estilos_render.gd en capturas/estilos_render/.

Uso:  python3 ronin3d/herramientas/hoja_estilos.py
Escribe ronin3d/capturas/comparativa_estilos_personajes.jpg. El coste de cada estilo se copia a
mano de lo que imprime estilos_render.gd («COSTE …»).
"""

import os

from PIL import Image, ImageDraw, ImageFont

CARPETA = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "capturas")
NEGRITA = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
NORMAL = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
ESTILOS = [
    ("cel", "Cel-shading", ["El de ahora (decidido", "el 27-09-2026)"], "84 ms · referencia"),
    ("tinta", "Manga de tinta", ["Blanco y negro, trama", "de puntos y rojo de acento"], "91 ms · +8 %"),
    ("sumie", "Sumi-e", ["Aguadas de tinta sobre", "papel, como Ōkami"], "92 ms · +10 %"),
    ("ukiyoe", "Ukiyo-e", ["Estampa de madera:", "pocos pigmentos y washi"], "86 ms · +2 %"),
    ("pixel", "Pixel art 3D", ["A ¼ de resolución,", "con tramado de 16 bits"], "48 ms · −43 %"),
    ("realista", "3D realista", ["Luz y sombras normales,", "sin línea ni bandas"], "121 ms · +44 %"),
]
CORTES = {"fila": (80, 90, 1200, 720), "cara": (190, 0, 1090, 506), "juego": (0, 0, 1280, 720)}
COLUMNAS = ["En fila (4 skins, soldado, Shiro)", "La cara de cerca", "En el patio, cámara del juego"]


def main():
    f_titulo = ImageFont.truetype(NEGRITA, 26)
    f_nombre = ImageFont.truetype(NEGRITA, 19)
    f_texto = ImageFont.truetype(NORMAL, 14)
    f_columna = ImageFont.truetype(NEGRITA, 16)
    ancho_etiqueta, ancho_img, alto_img, margen, cabecera = 250, 342, 192, 6, 92
    alto = cabecera + len(ESTILOS) * (alto_img + margen) + margen
    hoja = Image.new("RGB", (ancho_etiqueta + 3 * (ancho_img + 2) + 4, alto), (232, 224, 204))
    d = ImageDraw.Draw(hoja)
    d.text((16, 12), "Los mismos personajes con otros estilos de render", font=f_titulo, fill=(28, 24, 48))
    d.text((16, 48), "Coste: ms por cuadro dibujando el patio en la nube (OpenGL por software); "
           "en un móvil cambia la proporción.", font=f_texto, fill=(70, 60, 80))
    for j, titulo in enumerate(COLUMNAS):
        d.text((ancho_etiqueta + j * (ancho_img + 2) + 6, 70), titulo, font=f_columna, fill=(28, 24, 48))
    for i, (clave, nombre, lineas, coste) in enumerate(ESTILOS):
        y = cabecera + margen + i * (alto_img + margen)
        d.text((16, y + 22), nombre, font=f_nombre, fill=(28, 24, 48) if clave == "cel" else (150, 30, 30))
        for k, linea in enumerate(lineas):
            d.text((16, y + 54 + k * 19), linea, font=f_texto, fill=(50, 44, 60))
        d.text((16, y + 104), coste, font=f_texto, fill=(28, 24, 48))
        for j, vista in enumerate(["fila", "cara", "juego"]):
            ruta = os.path.join(CARPETA, "estilos_render", f"{clave}_{vista}.jpg")
            imagen = Image.open(ruta).convert("RGB").crop(CORTES[vista]).resize((ancho_img, alto_img), Image.LANCZOS)
            hoja.paste(imagen, (ancho_etiqueta + j * (ancho_img + 2), y))
    salida = os.path.join(CARPETA, "comparativa_estilos_personajes.jpg")
    hoja.save(salida, quality=88)
    print("Hoja:", salida)


if __name__ == "__main__":
    main()
