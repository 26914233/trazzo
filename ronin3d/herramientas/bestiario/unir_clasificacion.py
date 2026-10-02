"""Paso 3 · Une las criaturas canónicas, su clasificación y las criaturas extra.

Uso:
    python3 unir_clasificacion.py <carpeta_de_trabajo> <carpeta_ronin3d>

En la carpeta de trabajo esperan: canonicos.json y clasif_01.json … clasif_NN.json (la fuente de
verdad de la clasificación: ronin3d/bestiario/clasificacion/). Las criaturas añadidas salen de
criaturas_extra.py.
Escribe en <carpeta_ronin3d>:
    bestiario/catalogo_limpio.csv      una fila por criatura, con todos los campos (abre bien en Excel)
    bestiario/catalogo_limpio.json     lo mismo, en JSON
    bestiario/prompts_colab.csv        lo que lee el cuaderno de Colab para dibujar
    bestiario/informe_calidad.md       cifras de la auditoría y del reparto
    godot/datos/bestiario.json         lo que el juego necesita (sin textos de imagen)
"""
import csv
import glob
import json
import os
import sys
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from criaturas_extra import LISTA as EXTRAS  # noqa: E402
from validar_clasificacion import CLAVES, validar  # noqa: E402

# En qué ola de contenido entra cada tradición (propuesta; se decide con el usuario). Sigue la
# DECISIÓN 10B (1-10-2026): lo que no es japonés llega a partir del capítulo 3, cuando despierta Bahamut.
#   1 capítulo 1 (las 4 de la ficha) · 2 capítulo 2 (el resto de Japón)
#   3 capítulo 3: primeras otras tierras, el continente y Oriente Próximo (el camino de la Seda)
#   4 capítulo 4: Europa · 5 después del lanzamiento: África, América, Oceanía y lo moderno
#   6 después: huestes celestiales e infierno
OLA_POR_CULTURA = {
    "Japón": 2,
    "China": 3, "Corea": 3, "Sudeste Asiático": 3, "Tíbet y Himalaya": 3, "India": 3,
    "Asia Central y Siberia": 3,
    "Mesopotamia": 3, "Egipto": 3, "Persia y Cáucaso": 3, "Árabe e islámica": 3, "Hebrea y Levante": 3,
    "Grecia": 4, "Roma": 4,
    "Nórdica": 4, "Celta e Irlanda": 4, "Británica": 4, "Eslava y Balcanes": 4, "Germánica y Alpes": 4,
    "Francia, Iberia y Vasca": 4, "Báltica y Uralica": 4,
    "África Occidental y Central": 5, "África Oriental y Austral": 5, "Norte de África": 5,
    "Mesoamérica": 5, "Sudamérica y Caribe": 5, "Norteamérica indígena": 5, "Australia y Oceanía": 5,
    "Moderna y críptidos": 5,
    "Huestes celestiales": 6, "Grimorios e infierno": 6,
}
# Excepciones por nombre: las que ya tienen capítulo en BESTIARIO.md §8 (goblins en el 3, ifrit en el 4,
# y sirenas, Fenrir, Leviatán y fénix «después del lanzamiento»).
OLA_POR_NOMBRE = {"Hobgoblin": 3, "Ifrit": 4, "Sirenas": 5, "Fenrir": 5, "Leviathan": 5, "Bennu": 5}
IDS_CAPITULO_1 = {353, 2301, 2315, 2326}      # kappa, onibi, aka-oni y el oni gigante
# Entradas del catálogo que ya cubre una criatura añadida: se funden en ella (la añadida conserva el
# nombre del catálogo como alias y su id en «ids_origen»). «Oni» y «Aka-oni» son el oni rojo de siempre.
FUNDIR_EN_ANADIDA = {"Oni": "Aka-oni"}

CAMPOS_CSV = ["id", "nombre", "alias", "ids_origen", "origen", "cultura", "tipo_entrada", "familia",
              "tamano", "rol", "elemento", "bioma", "modelado", "base_de", "sensibilidad", "ola", "nota",
              "prompt_en"]
CAMPOS_JUEGO = ["id", "nombre", "cultura", "tipo_entrada", "familia", "tamano", "rol", "elemento", "bioma",
                "modelado", "base_de", "sensibilidad", "ola"]


def contar(filas, clave):
    return Counter(f[clave] for f in filas).most_common()


def tabla(titulo, pares, total):
    lineas = [f"| {titulo} | Criaturas | % |", "| --- | ---: | ---: |"]
    for valor, n in pares:
        lineas.append(f"| {valor} | {n} | {100 * n / total:.0f} % |")
    return "\n".join(lineas)


def main():
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)
    trabajo, raiz = Path(sys.argv[1]), Path(sys.argv[2])
    canonicos = json.load(open(trabajo / "canonicos.json", encoding="utf-8"))
    por_id = {c["id"]: c for c in canonicos}

    clasificadas = []
    for ruta in sorted(glob.glob(str(trabajo / "clasif_*.json"))):
        clasificadas.extend(json.load(open(ruta, encoding="utf-8")))
    errores = validar(canonicos, clasificadas)
    if errores:
        print(f"{len(errores)} errores en la clasificación:")
        for e in errores[:40]:
            print(" -", e)
        sys.exit(1)
    extras = EXTRAS
    errores = validar([], extras, True)
    if errores:
        print("Errores en las criaturas extra:", errores[:20])
        sys.exit(1)

    filas = []
    for c in clasificadas:
        origen = por_id[c["id"]]
        fila = dict(c)
        fila["alias"] = "; ".join(origen["alias"])
        fila["ids_origen"] = " ".join(str(i) for i in origen["ids_origen"])
        fila["origen"] = "catálogo"
        filas.append(fila)
    for c in extras:
        fila = dict(c)
        fila["alias"] = ""
        fila["ids_origen"] = ""
        fila["origen"] = "añadida"
        filas.append(fila)
    for nombre_catalogo, nombre_anadida in FUNDIR_EN_ANADIDA.items():
        del_catalogo = next((f for f in filas if f["nombre"] == nombre_catalogo and f["origen"] == "catálogo"), None)
        anadida = next((f for f in filas if f["nombre"] == nombre_anadida and f["origen"] == "añadida"), None)
        if del_catalogo and anadida:
            anadida["alias"] = "; ".join(x for x in (anadida["alias"], nombre_catalogo, del_catalogo["alias"]) if x)
            anadida["ids_origen"] = " ".join(x for x in (anadida["ids_origen"], del_catalogo["ids_origen"]) if x)
            filas.remove(del_catalogo)
    for f in filas:
        f["ola"] = 1 if f["id"] in IDS_CAPITULO_1 else OLA_POR_NOMBRE.get(f["nombre"], OLA_POR_CULTURA[f["cultura"]])
    filas.sort(key=lambda f: (f["ola"], f["id"]))

    # base_de: que apunte a una criatura que exista y no a otro reskin (se aplanan las cadenas)
    por_nombre = {f["nombre"].lower(): f for f in filas}
    huerfanos = []
    for f in filas:
        if not f["base_de"]:
            continue
        base = por_nombre.get(f["base_de"].lower())
        if base is None:
            huerfanos.append((f["nombre"], f["base_de"]))
            f["base_de"] = ""
            if f["modelado"] == "reskin":
                f["modelado"] = "variante"
            continue
        visitados = set()
        while base["modelado"] == "reskin" and base["base_de"] and base["nombre"] not in visitados:
            visitados.add(base["nombre"])
            siguiente = por_nombre.get(base["base_de"].lower())
            if siguiente is None:
                break
            base = siguiente
        f["base_de"] = base["nombre"]
    if huerfanos:
        print(f"AVISO: {len(huerfanos)} base_de apuntaban a una criatura que no existe (pasan a variante):", huerfanos[:20])

    # ¿Hay nombres repetidos entre el catálogo y las criaturas añadidas?
    vistos = {}
    repetidos = []
    for f in filas:
        clave = f["nombre"].lower()
        if clave in vistos:
            repetidos.append((f["nombre"], vistos[clave], f["id"]))
        vistos[clave] = f["id"]
    if repetidos:
        print("AVISO: nombres repetidos tras unir:", repetidos)

    destino = raiz / "bestiario"
    destino.mkdir(parents=True, exist_ok=True)
    with open(destino / "catalogo_limpio.csv", "w", encoding="utf-8-sig", newline="") as f:
        escritor = csv.DictWriter(f, fieldnames=CAMPOS_CSV, extrasaction="ignore")
        escritor.writeheader()
        escritor.writerows(filas)
    json.dump(filas, open(destino / "catalogo_limpio.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)

    # Datos del juego (sin textos de imagen, y sin las que no son criaturas)
    juego = [{k: f[k] for k in CAMPOS_JUEGO} for f in filas if f["tipo_entrada"] != "no_criatura"]
    carpeta_datos = raiz / "godot" / "datos"
    carpeta_datos.mkdir(parents=True, exist_ok=True)
    json.dump(juego, open(carpeta_datos / "bestiario.json", "w", encoding="utf-8"), ensure_ascii=False,
              separators=(",", ":"))

    # Lista para el cuaderno de Colab: primero lo que antes se necesita
    dibujables = [f for f in filas if f["tipo_entrada"] != "no_criatura" and f["prompt_en"]]
    with open(destino / "prompts_colab.csv", "w", encoding="utf-8", newline="") as f:
        escritor = csv.writer(f)
        escritor.writerow(["id", "nombre", "semilla", "familia", "tamano", "elemento", "bioma", "modelado",
                           "sensibilidad", "ola", "prompt_en"])
        for fila in dibujables:
            escritor.writerow([fila["id"], fila["nombre"], fila["id"] * 10, fila["familia"], fila["tamano"],
                               fila["elemento"], fila["bioma"], fila["modelado"], fila["sensibilidad"], fila["ola"],
                               fila["prompt_en"]])

    # Informe de calidad
    total = len(filas)
    de_catalogo = [f for f in filas if f["origen"] == "catálogo"]
    criaturas = [f for f in filas if f["tipo_entrada"] == "criatura"]
    utilizables = [f for f in filas if f["tipo_entrada"] in ("criatura", "generica") and f["sensibilidad"] < 2]
    informe = [
        "# Informe de calidad del catálogo (generado por `unir_clasificacion.py`)",
        "",
        f"- Criaturas canónicas del catálogo del usuario: **{len(de_catalogo) + len(FUNDIR_EN_ANADIDA)}** (de 998 filas, tras fusionar duplicados); "
        f"{len(FUNDIR_EN_ANADIDA)} de ellas coincide con una añadida y se funde con ella (Oni = Aka-oni), así que quedan **{len(de_catalogo)}** filas del catálogo.",
        f"- Criaturas añadidas (ángeles, infierno, yōkai que faltaban, aliados): **{total - len(de_catalogo)}**.",
        f"- Total en el bestiario: **{total}**; de ellas, criaturas con identidad propia: **{len(criaturas)}**.",
        f"- Utilizables como enemigos (criatura o genérica, sensibilidad 0–1): **{len(utilizables)}**.",
        f"- Con su variante fuerte (rango 2): **{2 * len(utilizables)}** enemigos; con la silenciada (rango 3): **{3 * len(utilizables)}**. "
        "Cuentan variantes, no criaturas distintas: la cifra honesta es la de arriba.",
        "",
        tabla("Tipo de entrada", contar(filas, "tipo_entrada"), total),
        "",
        tabla("Modelado", contar(utilizables, "modelado"), len(utilizables)),
        "",
        tabla("Familia de cuerpo", contar(utilizables, "familia"), len(utilizables)),
        "",
        tabla("Rol", contar(utilizables, "rol"), len(utilizables)),
        "",
        tabla("Tamaño", contar(utilizables, "tamano"), len(utilizables)),
        "",
        tabla("Elemento", contar(utilizables, "elemento"), len(utilizables)),
        "",
        tabla("Sensibilidad cultural (0 libre · 1 con cuidado · 2 no enemigo)", contar(filas, "sensibilidad"), total),
        "",
        tabla("Ola de contenido", sorted(Counter(f["ola"] for f in utilizables).items()), len(utilizables)),
        "",
        tabla("Cultura", contar(utilizables, "cultura"), len(utilizables)),
        "",
    ]
    (destino / "informe_calidad.md").write_text("\n".join(informe), encoding="utf-8")
    print(f"{total} criaturas: {len(de_catalogo)} del catálogo + {total - len(de_catalogo)} añadidas")
    print(f"  utilizables como enemigos: {len(utilizables)} · para dibujar: {len(dibujables)}")
    print("  modelado:", dict(contar(utilizables, "modelado")))
    print("  tipo:", dict(contar(filas, "tipo_entrada")))


if __name__ == "__main__":
    main()
