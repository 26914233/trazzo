"""Comprueba que una clasificación sigue la rúbrica (ronin3d/bestiario/RUBRICA_CLASIFICACION.md).

Uso:
    python3 validar_clasificacion.py <entrada.json> <clasificacion.json>
    python3 validar_clasificacion.py --extra <clasificacion.json>      (lista sin archivo de entrada)

Sale con código 0 si todo está bien y con 1 si hay errores (los imprime todos).
"""
import json
import sys

CULTURAS = {
    "Grecia", "Roma", "Nórdica", "Celta e Irlanda", "Británica", "Eslava y Balcanes",
    "Germánica y Alpes", "Francia, Iberia y Vasca", "Báltica y Uralica", "Mesopotamia", "Egipto",
    "Persia y Cáucaso", "Árabe e islámica", "Hebrea y Levante", "India", "Tíbet y Himalaya",
    "Asia Central y Siberia", "China", "Japón", "Corea", "Sudeste Asiático",
    "África Occidental y Central", "África Oriental y Austral", "Norte de África", "Mesoamérica",
    "Sudamérica y Caribe", "Norteamérica indígena", "Australia y Oceanía", "Moderna y críptidos",
    # Criaturas añadidas al catálogo (criaturas_extra.py)
    "Huestes celestiales", "Grimorios e infierno",
}
VALORES = {
    "tipo_entrada": {"criatura", "deidad", "generica", "no_criatura"},
    "familia": {"bipedo", "cuadrupedo", "serpentino", "alado", "acuatico", "flotante", "artropodo"},
    "tamano": {"S", "M", "L", "XL"},
    "rol": {"veloz", "poderoso", "enjambre", "gigante", "engano", "distancia", "emboscador", "apoyo"},
    "elemento": {"ninguno", "fuego", "agua", "hielo", "rayo", "viento", "tierra", "veneno", "sombra",
                 "luz", "sangre"},
    "bioma": {"bosque", "montana", "rio_lago", "mar", "pantano", "desierto", "ciudad_hogar", "cielo",
              "subsuelo", "inframundo", "nieve", "ruinas", "llanura", "selva"},
    "modelado": {"propio", "variante", "reskin"},
}
CLAVES = ["id", "nombre", "cultura", "tipo_entrada", "familia", "tamano", "rol", "elemento", "bioma",
          "modelado", "base_de", "sensibilidad", "prompt_en", "nota"]


def validar(entrada, clasificacion, extra=False):
    errores = []
    ids_entrada = [e["id"] for e in entrada]
    ids_salida = [c.get("id") for c in clasificacion]
    if not extra:
        if ids_salida != ids_entrada:
            faltan = sorted(set(ids_entrada) - set(ids_salida))
            sobran = sorted(set(ids_salida) - set(ids_entrada), key=str)
            errores.append(f"Los ids no coinciden con la entrada (faltan {faltan}, sobran {sobran}) "
                           "o están en otro orden")
    nombres = {c.get("nombre") for c in clasificacion}
    for c in clasificacion:
        etiqueta = f"{c.get('id')} {c.get('nombre')}"
        faltan = [k for k in CLAVES if k not in c]
        sobran = [k for k in c if k not in CLAVES]
        if faltan or sobran:
            errores.append(f"{etiqueta}: claves que faltan {faltan}, claves que sobran {sobran}")
            continue
        if c["cultura"] not in CULTURAS:
            errores.append(f"{etiqueta}: cultura no permitida «{c['cultura']}»")
        for clave, permitidos in VALORES.items():
            if c[clave] not in permitidos:
                errores.append(f"{etiqueta}: {clave} no permitido «{c[clave]}»")
        if c["sensibilidad"] not in (0, 1, 2) or isinstance(c["sensibilidad"], bool):
            errores.append(f"{etiqueta}: sensibilidad debe ser 0, 1 o 2")
        palabras = len(c["prompt_en"].split())
        if c["tipo_entrada"] == "no_criatura":
            if c["prompt_en"] != "":
                errores.append(f"{etiqueta}: una no_criatura lleva prompt_en vacío")
        elif not 12 <= palabras <= 40:
            errores.append(f"{etiqueta}: prompt_en tiene {palabras} palabras (deben ser de 15 a 35)")
        if len(c["nota"].split()) > 20:
            errores.append(f"{etiqueta}: la nota pasa de 15 palabras")
        if c["modelado"] == "reskin" and not c["base_de"]:
            errores.append(f"{etiqueta}: un reskin necesita base_de")
        if c["base_de"] and not extra and c["base_de"] == c["nombre"]:
            errores.append(f"{etiqueta}: base_de no puede ser la propia criatura")
        if c["tamano"] == "XL" and c["rol"] not in ("gigante", "distancia", "poderoso", "apoyo"):
            errores.append(f"{etiqueta}: una criatura XL suele ser gigante/poderoso/distancia/apoyo")
    return errores


def main():
    extra = len(sys.argv) == 3 and sys.argv[1] == "--extra"
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)
    if extra:
        clasificacion = json.load(open(sys.argv[2], encoding="utf-8"))
        entrada = []
    else:
        entrada = json.load(open(sys.argv[1], encoding="utf-8"))
        clasificacion = json.load(open(sys.argv[2], encoding="utf-8"))
    errores = validar(entrada, clasificacion, extra)
    if errores:
        print(f"{len(errores)} errores:")
        for e in errores:
            print(" -", e)
        sys.exit(1)
    propios = sum(1 for c in clasificacion if c["modelado"] == "propio")
    reskins = sum(1 for c in clasificacion if c["modelado"] == "reskin")
    print(f"OK: {len(clasificacion)} entradas ({propios} propios, {reskins} reskins)")


if __name__ == "__main__":
    main()
