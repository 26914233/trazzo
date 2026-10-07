"""Paso 2 · Fusiona duplicados y deja una lista de criaturas canónicas para clasificar.

Uso:
    python3 fusionar.py <crudo.json> <canonicos.json>

1. Fusiona las filas con el mismo nombre (sin tildes ni mayúsculas ni signos).
2. Aplica las fusiones a mano de fusiones.py.
3. Guarda una entrada por criatura con todos los ids, alias y descripciones de origen.
"""
import json
import re
import sys
import unicodedata
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from fusiones import FUSIONES  # noqa: E402


def normalizar(texto: str) -> str:
    sin_tildes = "".join(c for c in unicodedata.normalize("NFKD", texto) if not unicodedata.combining(c))
    return re.sub(r"[^a-z0-9]+", "", sin_tildes.lower())


def main() -> None:
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)
    filas = json.load(open(sys.argv[1], encoding="utf-8"))

    grupos = {}
    for fila in filas:
        grupos.setdefault(normalizar(fila["nombre"]), []).append(fila)
    exactos = {clave: g for clave, g in grupos.items() if len(g) > 1}

    # Fusiones a mano: el alias se suma al grupo del canónico.
    faltan = []
    for canonico, alias in FUSIONES.items():
        clave_c = normalizar(canonico)
        if clave_c not in grupos:
            faltan.append(canonico)
            continue
        for nombre in alias:
            clave_a = normalizar(nombre)
            if clave_a not in grupos:
                faltan.append(nombre)
            elif clave_a != clave_c:
                grupos[clave_c].extend(grupos.pop(clave_a))
    if faltan:
        print("AVISO: nombres de fusiones.py que no están en el catálogo:", faltan)

    salida = []
    for clave, g in grupos.items():
        g = sorted(g, key=lambda f: f["id"])
        nombres = []
        for f in g:
            if f["nombre"] not in nombres:
                nombres.append(f["nombre"])
        # Si es una fusión a mano, el nombre principal es el que se eligió en fusiones.py.
        elegido = next((c for c in FUSIONES if normalizar(c) == clave), None)
        if elegido and elegido in nombres:
            nombres.remove(elegido)
            nombres.insert(0, elegido)
        salida.append({
            "id": g[0]["id"],
            "nombre": nombres[0],
            "alias": nombres[1:],
            "ids_origen": [f["id"] for f in g],
            "culturas_catalogo": sorted({f["cultura"] for f in g}),
            "categorias_catalogo": sorted({f["categoria"] for f in g}),
            "descripcion": " | ".join(dict.fromkeys(f["descripcion"] for f in g if f["descripcion"])),
        })
    salida.sort(key=lambda e: e["id"])
    json.dump(salida, open(sys.argv[2], "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(f"{len(filas)} filas → {len(salida)} criaturas canónicas "
          f"({len(exactos)} grupos de nombre repetido, {len(FUSIONES)} fusiones a mano)")


if __name__ == "__main__":
    main()
