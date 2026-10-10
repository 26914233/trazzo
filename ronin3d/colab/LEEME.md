# Colab · imágenes 2D del bestiario de RONIN

Aquí está todo lo que hace falta para dibujar las criaturas en Google Colab (con la GPU gratis), no en
tu PC.

| Archivo | Para qué sirve |
| --- | --- |
| `bestiario_imagenes.ipynb` | El cuaderno. Se abre en Colab, lee la lista de criaturas desde tu Drive y guarda una ilustración por criatura |
| `INSTRUCCIONES_COLAB_BESTIARIO.md` | Lo mismo en forma de receta (celda por celda) para la sesión de Claude que maneja Colab con colab-mcp, y las reglas de esa sesión |
| `crear_cuaderno.py` | Genera los dos archivos de arriba. Se cambia ahí y se vuelve a ejecutar: `python3 crear_cuaderno.py bestiario_imagenes.ipynb INSTRUCCIONES_COLAB_BESTIARIO.md` |

## Dos estilos (ajuste `MODO`)

- **`escena`** (por defecto desde el 02-10-2026): el estilo del Bahamut. Cada criatura sale en su
  sitio (usa la columna `bioma`: río, montaña, ruinas…), con niebla de tinta y un samurái para la
  escala si es mediana o grande. Formato 4:3 (1152 × 896). Es el que pidió el usuario para el
  bestiario; receta y ejemplos en `../arte/conceptos/LEEME.md`.
- **`ficha`**: la criatura sola, de cuerpo entero, cuadrada y sin fondo. Es la que sirve para pasarla
  a 3D (SAM 3D y similares).

## Qué necesita en tu Drive

`Respaldos Claude/ronin/06-Bestiario/prompts_colab.csv` (una copia de `../bestiario/prompts_colab.csv`).
Las imágenes salen en `06-Bestiario/imagenes/` (JPG, unos 250 KB cada una), con un `registro.csv` y
hojas de contacto en `06-Bestiario/hojas/` para revisarlas de un vistazo.

## Cómo se usa (dos caminos)

1. **Tú, a mano.** Abre el cuaderno en Colab, pon *GPU T4*, ejecuta las celdas de arriba abajo y empieza
   con `HASTA = 50`. Si se desconecta, vuelve a ejecutar: se salta lo que ya existe.
2. **Con la sesión de Claude que maneja Colab** (como con Heredera del Hielo): pásale
   `INSTRUCCIONES_COLAB_BESTIARIO.md`. Tú eliges la GPU y aceptas los permisos.

## Lo que está probado y lo que no

- **Probado:** el flujo entero con `SIMULAR = True` (sin GPU): lectura de la lista, rutas de Drive,
  reanudación, registro, hojas de contacto y el texto de cada prompt. El modo `escena` se probó así el
  02-10-2026: 4 criaturas, 1152 × 896, con su sitio en el prompt.
- **Ojo:** el `prompts_colab.csv` de Drive debe ser el nuevo, con la columna `bioma`. Con el antiguo,
  el modo escena pone un paisaje genérico.
- **Sin probar:** la carga y la difusión de SDXL en una T4 real, y cuánto tarda de verdad cada imagen
  (la cifra de ~20 s es una **estimación**). Por eso la primera tanda es de 50 y se mira antes de seguir.
- **Z-Image-Turbo** (`MODELO = "zimage"`) necesita unos 16 GB de GPU: no es para la T4. Se deja como opción
  por si Colab te asigna una L4 o una A100.
- **Licencias** (verificadas el 1-10-2026): SDXL base 1.0 usa CreativeML Open RAIL++-M (uso comercial
  permitido con restricciones de uso responsable); Z-Image-Turbo es Apache 2.0.

## Reglas que no se saltan

- Nada de `files.upload()`, widgets ni Gradio. Nunca se guardan los pesos del modelo en Drive.
- Si no aparece la carpeta `Respaldos Claude/ronin` al montar Drive, es la cuenta equivocada: se para y se avisa.
- Ningún token va en una celda ni en un chat.
- Las criaturas con **sensibilidad 2** (dioses y seres sagrados) **no se dibujan** salvo que se pida a propósito.
