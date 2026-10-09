"""Comprueba los límites de caracteres de la ficha de Google Play."""
import re
import sys
from pathlib import Path

LIMITES = {"titulo": 30, "breve": 80, "completa": 4000}
texto = Path(__file__).with_name("FICHA_PLAY.md").read_text(encoding="utf-8")
mal = False
for campo, limite in LIMITES.items():
    m = re.search(rf"<!-- {campo} -->\n(.*?)\n<!-- /{campo} -->", texto, re.S)
    if not m:
        print(f"{campo}: NO ENCONTRADO")
        mal = True
        continue
    n = len(m.group(1))
    estado = "ok" if n <= limite else "SE PASA"
    mal |= n > limite
    print(f"{campo:9} {n:5}/{limite}  {estado}")
sys.exit(1 if mal else 0)
