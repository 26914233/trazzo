#!/usr/bin/env python3
"""Mete en el juego las ilustraciones elegidas (generadas en Colab).

Lee una lista de rutas (una por línea; la categoría sale del nombre del archivo,
p. ej. animales_023_tatuaje_s1.png -> "animales"), convierte cada imagen en
lámina pintable con la limpieza de sombreados y la añade al índice, junto a las
categorías hechas por código.

Uso: python3 herramientas/importar.py elegidas.txt
"""
import json
import os
import sys
from multiprocessing import Pool

from PIL import Image

from convertir import tinta_de
from laminas import RAIZ, procesar_tinta

NOMBRES = {
    "animales": "Animales", "aves": "Aves", "oceano": "Océano", "insectos": "Insectos",
    "fantasia": "Fantasía", "flores": "Flores", "comida": "Comida", "objetos": "Objetos",
    "vehiculos": "Vehículos", "lugares": "Lugares", "mandalas": "Mandalas",
}
# Orden en el menú: primero lo ilustrado, luego lo hecho por código.
ORDEN = ["animales", "aves", "fantasia", "oceano", "insectos", "flores", "mandalas", "comida",
         "objetos", "vehiculos", "lugares", "vitrales", "geometria", "fachadas"]
DESTINO = os.path.join(RAIZ, "datos", "laminas")


def _convertir(trabajo):
    ruta, cat, lid = trabajo
    lin, reg, mini, k = procesar_tinta(tinta_de(Image.open(ruta), 0, limpiar=True))
    base = os.path.join(DESTINO, cat, lid)
    lin.save(base + "_lineas.png", optimize=True)
    reg.save(base + "_regiones.png", optimize=True)
    mini.save(base + "_mini.png", optimize=True)
    return cat, lid, k


def main():
    rutas = [l.strip() for l in open(sys.argv[1], encoding="utf-8") if l.strip()]
    indice = json.load(open(os.path.join(DESTINO, "indice.json"), encoding="utf-8"))
    cats = {c["id"]: c for c in indice["categorias"]}
    trabajos = []
    cuenta = {}
    for ruta in rutas:
        cat = os.path.basename(ruta).split("_")[0]
        os.makedirs(os.path.join(DESTINO, cat), exist_ok=True)
        cats.setdefault(cat, {"id": cat, "nombre": NOMBRES.get(cat, cat.title()), "laminas": []})
        # las ilustradas llevan prefijo "i": no chocan con las hechas por código
        cuenta[cat] = cuenta.get(cat, 0) + 1
        trabajos.append((ruta, cat, "%s_i%03d" % (cat, cuenta[cat])))
    for c in cats.values():   # vuelve a importar sin duplicar
        c["laminas"] = [l for l in c["laminas"] if "_i" not in l["id"]]
    with Pool() as pool:
        for cat, lid, k in pool.imap(_convertir, trabajos, chunksize=2):
            cats[cat]["laminas"].append({"id": lid, "zonas": k})
    indice["categorias"] = [cats[c] for c in ORDEN if c in cats] + [c for i, c in cats.items() if i not in ORDEN]
    with open(os.path.join(DESTINO, "indice.json"), "w", encoding="utf-8") as f:
        json.dump(indice, f, ensure_ascii=False, indent=1)
    total = sum(len(c["laminas"]) for c in indice["categorias"])
    print("importadas", len(trabajos), "- total en el juego:", total, file=sys.stderr)


if __name__ == "__main__":
    main()
