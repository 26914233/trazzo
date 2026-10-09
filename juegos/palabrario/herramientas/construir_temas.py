"""Construye datos/categorias/*.json a partir de datos/fuente/*.txt y lo valida.

Formato de la fuente (una categoría por archivo):

    # Nombre de la categoría | #COLOR
    Nombre del subtema: palabra, palabra, ...   (12 palabras = una sopa)

Uso:  python3 herramientas/construir_temas.py        (falla con código 1 si algo no cuadra)
"""
import json
import re
import sys
import unicodedata
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
FUENTE = RAIZ / "datos" / "fuente"
SALIDA = RAIZ / "datos" / "categorias"
PALABRAS_POR_SOPA = 12
LARGO_MIN, LARGO_MAX = 3, 12          # 12 = lado de la cuadrícula en Difícil
MIN_SOPAS = 500

# Misma tabla que GeneradorSopa.normalizar() en GDScript. Si una palabra trae una
# letra que no está aquí, el juego la perdería: se comprueba más abajo.
TABLA_GD_DE = "ÁÉÍÓÚÀÈÌÒÙÄËÏÖÜÂÊÎÔÛÃÕÇ"
TABLA_GD_A = "AEIOUAEIOUAEIOUAEIOUAOC"


def normalizar(palabra: str) -> str:
    """Mayúsculas, sin tildes, sin espacios ni signos. La Ñ se conserva."""
    salida = []
    for ch in palabra.upper():
        if ch == "Ñ":
            salida.append("Ñ")
            continue
        base = unicodedata.normalize("NFD", ch)[0]
        if "A" <= base <= "Z":
            salida.append(base)
    return "".join(salida)


def normalizar_como_gdscript(palabra: str) -> str:
    salida = []
    for ch in palabra.upper():
        pos = TABLA_GD_DE.find(ch)
        if pos != -1:
            ch = TABLA_GD_A[pos]
        if "A" <= ch <= "Z" or ch == "Ñ":
            salida.append(ch)
    return "".join(salida)


def slug(texto: str) -> str:
    ascii_ = unicodedata.normalize("NFD", texto.lower()).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "-", ascii_).strip("-")


def main() -> int:
    errores: list[str] = []
    categorias = []
    for orden, archivo in enumerate(sorted(FUENTE.glob("*.txt"))):
        lineas = [l.strip() for l in archivo.read_text(encoding="utf-8").splitlines() if l.strip()]
        cab = re.match(r"#\s*(.+?)\s*\|\s*(#[0-9A-Fa-f]{6})$", lineas[0])
        if not cab:
            errores.append(f"{archivo.name}: cabecera inválida")
            continue
        nombre, color = cab.groups()
        cat = {"id": slug(nombre), "nombre": nombre, "color": color.upper(), "orden": orden, "subtemas": []}
        vistos = set()
        for n, linea in enumerate(lineas[1:], start=2):
            if ":" not in linea:
                errores.append(f"{archivo.name}:{n}: falta ':'")
                continue
            sub, resto = linea.split(":", 1)
            sub = sub.strip()
            palabras = [p.strip() for p in resto.split(",") if p.strip()]
            donde = f"{archivo.name}:{n} [{sub}]"
            if sub in vistos:
                errores.append(f"{donde}: subtema repetido")
            vistos.add(sub)
            if len(palabras) != PALABRAS_POR_SOPA:
                errores.append(f"{donde}: tiene {len(palabras)} palabras, deben ser {PALABRAS_POR_SOPA}")
            normas = {}
            for p in palabras:
                nrm = normalizar(p)
                if nrm != normalizar_como_gdscript(p):
                    errores.append(f"{donde}: '{p}' tiene una letra que el juego no sabe normalizar")
                if not LARGO_MIN <= len(nrm) <= LARGO_MAX:
                    errores.append(f"{donde}: '{p}' mide {len(nrm)} letras ({LARGO_MIN}-{LARGO_MAX})")
                if nrm in normas:
                    errores.append(f"{donde}: '{p}' repite '{normas[nrm]}' en la cuadrícula")
                normas[nrm] = p
            cat["subtemas"].append({
                "id": slug(sub),
                "nombre": sub,
                "palabras": [p.upper() for p in palabras],
            })
        categorias.append(cat)

    ids = [c["id"] for c in categorias]
    for i in {x for x in ids if ids.count(x) > 1}:
        errores.append(f"categoría repetida: {i}")
    total = sum(len(c["subtemas"]) for c in categorias)
    if total < MIN_SOPAS:
        errores.append(f"solo hay {total} sopas; el mínimo es {MIN_SOPAS}")

    if errores:
        print("\n".join(errores))
        print(f"\n{len(errores)} errores")
        return 1

    SALIDA.mkdir(parents=True, exist_ok=True)
    for viejo in SALIDA.glob("*.json"):
        viejo.unlink()
    for c in categorias:
        destino = SALIDA / f"{c['orden'] + 1:02d}-{c['id']}.json"
        destino.write_text(json.dumps(c, ensure_ascii=False, indent=1), encoding="utf-8")
    palabras = sum(len(s["palabras"]) for c in categorias for s in c["subtemas"])
    print(f"{len(categorias)} categorías, {total} sopas, {palabras} palabras → {SALIDA.relative_to(RAIZ)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
