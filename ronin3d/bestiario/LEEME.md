# Bestiario de RONIN · datos

Aquí está el catálogo de criaturas ya limpio y clasificado. La estrategia y las decisiones están en
`../BESTIARIO_UNIVERSAL.md`; las criaturas de cada capítulo, con su ficha, en `../BESTIARIO.md`.

| Archivo | Qué es |
| --- | --- |
| `catalogo_limpio.csv` | Una fila por criatura con todos los campos (abre bien en Excel y en Google Sheets) |
| `catalogo_limpio.json` | Lo mismo en JSON |
| `prompts_colab.csv` | Lo que lee el cuaderno de Colab para dibujar cada criatura (`../colab/`) |
| `informe_calidad.md` | Cifras de la auditoría y del reparto (se genera solo) |
| `RUBRICA_CLASIFICACION.md` | Las reglas con las que se clasificó cada criatura |
| `../godot/datos/bestiario.json` | Lo que usa el juego (sin los textos de imagen) |

## De dónde sale

1. Tus dos catálogos (`Bestiario_Universal_500.xlsx` y `Bestiario_Universal_501-1000_Detallado.xlsx`),
   respaldados en Drive › `ronin/06-Bestiario/fuentes/`. No están en GitHub.
2. `herramientas/bestiario/leer_catalogo.py` → `fusionar.py` (duplicados y casi duplicados) →
   clasificación criatura a criatura según la rúbrica → `unir_clasificacion.py`, que une todo con
   las criaturas que añadí (`criaturas_extra.py`: ángeles, infierno, yōkai que faltaban y aliados).

## Campos

| Campo | Valores |
| --- | --- |
| `tipo_entrada` | `criatura`, `deidad`, `generica` (relleno del catálogo), `no_criatura` |
| `familia` | `bipedo`, `cuadrupedo`, `serpentino`, `alado`, `acuatico`, `flotante`, `artropodo` |
| `tamano` | `S`, `M`, `L`, `XL` |
| `rol` | `veloz`, `poderoso`, `enjambre`, `gigante`, `engano`, `distancia`, `emboscador`, `apoyo` |
| `elemento` | `ninguno`, `fuego`, `agua`, `hielo`, `rayo`, `viento`, `tierra`, `veneno`, `sombra`, `luz`, `sangre` |
| `modelado` | `propio` (modelo hecho a medida), `variante` (familia + piezas + paleta), `reskin` (otra criatura con otra paleta; ver `base_de`) |
| `sensibilidad` | `0` libre · `1` con cuidado · `2` no enemigo (solo PNJ o lore) |
| `ola` | 1 capítulo 1 · 2 capítulo 2 (Japón) · 3 capítulo 3 (continente y Oriente Próximo) · 4 capítulo 4 (Europa) · 5 y 6 después del lanzamiento. Sale de la cultura, con unas pocas excepciones por nombre (`OLA_POR_NOMBRE` en `unir_clasificacion.py`) |

## Cómo rehacerlo

La fuente de verdad de la clasificación es `clasificacion/` (`canonicos.json` y `clasif_01…10.json`) más
`herramientas/bestiario/criaturas_extra.py`. Todo lo demás se regenera:

```
python3 ronin3d/herramientas/bestiario/unir_clasificacion.py ronin3d/bestiario/clasificacion ronin3d
```

Cifras actuales: 807 filas del catálogo + 132 añadidas = **939** (el *Oni* del catálogo se fundió con el
*Aka-oni* añadido: `FUNDIR_EN_ANADIDA` en `unir_clasificacion.py`); 825 utilizables como enemigos.

Si se corrige una criatura, se corrige en su `clasif_NN.json` (o en `criaturas_extra.py`) y se vuelve a
ejecutar esa orden. Para partir de los xlsx originales: `leer_catalogo.py` → `fusionar.py` →
clasificar según `RUBRICA_CLASIFICACION.md` → `unir_clasificacion.py`. La clasificación es **trabajo
manual de revisión**: no sale de reglas automáticas. La hicieron varios agentes de Claude con la rúbrica y
se revisó por muestras y con comprobaciones automáticas; no se leyeron las 939 entradas una por una.
