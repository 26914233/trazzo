#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Construye ronin3d.html, el juego en un solo archivo HTML autocontenido.

Lee la plantilla ronin3d_fuente.html, busca los marcadores {{nombre.png}} y los
sustituye por la imagen de ../recursos/nombre.png incrustada como data URI base64.
Three.js no se incrusta: se carga desde cdn.jsdelivr.net (importmap de la plantilla).

Uso:
    python3 construir.py
"""

import base64
import pathlib
import re
import sys

CARPETA = pathlib.Path(__file__).resolve().parent
RECURSOS = CARPETA.parent / "recursos"
PLANTILLA = CARPETA / "ronin3d_fuente.html"
SALIDA = CARPETA / "ronin3d.html"
PATRON_MARCADOR = re.compile(r"\{\{([A-Za-z0-9_.\-]+\.png)\}\}")


def main():
    if not PLANTILLA.exists():
        sys.exit(f"No encuentro la plantilla: {PLANTILLA}")
    texto = PLANTILLA.read_text(encoding="utf-8")
    nombres = sorted(set(PATRON_MARCADOR.findall(texto)))
    if not nombres:
        sys.exit("La plantilla no tiene marcadores {{nombre.png}}.")

    tamano_imagenes = 0
    for nombre in nombres:
        ruta = RECURSOS / nombre
        if not ruta.exists():
            sys.exit(f"Falta el recurso {ruta}")
        datos = ruta.read_bytes()
        tamano_imagenes += len(datos)
        uri = "data:image/png;base64," + base64.b64encode(datos).decode("ascii")
        texto = texto.replace("{{" + nombre + "}}", uri)

    if PATRON_MARCADOR.search(texto):
        sys.exit("Han quedado marcadores sin sustituir.")

    # El aviso de la plantilla no tiene sentido en el archivo generado
    texto = re.sub(r"<!--\s*PLANTILLA\..*?-->\n?", "<!-- Generado por construir.py a partir de "
                   "ronin3d_fuente.html. No lo edites a mano. -->\n", texto, count=1, flags=re.S)

    SALIDA.write_text(texto, encoding="utf-8")
    print(f"Escrito {SALIDA.name}: {SALIDA.stat().st_size / 1024:.1f} KB "
          f"({len(nombres)} imágenes incrustadas, {tamano_imagenes / 1024:.1f} KB de PNG).")


if __name__ == "__main__":
    main()
