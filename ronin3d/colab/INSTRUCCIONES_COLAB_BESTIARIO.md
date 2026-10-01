# Instrucciones para la sesión con Colab: RONIN, imágenes del bestiario (C9)

Lo manejas con colab-mcp, igual que en `COLAB_INSTRUCCIONES.md` de Heredera del Hielo (las reglas 1-8
de ese archivo valen también aquí). Reglas propias de esta receta:

1. Entorno nuevo con **T4 GPU**; lo elige el usuario. Esta receta usa SDXL base 1.0 (licencia CreativeML
   Open RAIL++-M, uso comercial permitido con restricciones de uso responsable). No hace falta ningún token.
2. A Drive le quedan unos **6,8 GB libres** (medido el 1-10-2026). Guarda solo los `.jpg` (unos 250 KB
   cada uno), el `registro.csv` y las hojas de contacto. NUNCA los pesos de SDXL (unos 7 GB): se
   descargan a Colab, no a Drive.
3. Ruta en el PC: `G:\Mi unidad\Respaldos Claude\ronin\06-Bestiario\` = `/content/drive/MyDrive/Respaldos Claude/ronin/06-Bestiario/` en Colab.
   Comprueba con `!ls "/content/drive/MyDrive/Respaldos Claude/ronin/06-Bestiario"`: debe aparecer
   `prompts_colab.csv`. Si no aparece, la cuenta de Colab no es la del Drive del PC
   (prueba1bysisne@gmail.com): PARA y avisa.
4. Trabaja en **tandas de 50** (unos 15-20 minutos cada una). Si `run_code_cell` vuelve antes de que
   termine la celda 6, NO la relances: espera y relee la salida con `get_cells`. La celda se puede
   interrumpir y repetir: se salta lo que ya existe.
5. Para la tanda siguiente, en el mismo entorno: edita `DESDE` y `HASTA` en la celda de ajustes y vuelve a
   ejecutar las celdas de elección, de generación y de hoja de contacto (no recargues el modelo).
6. Tras cada tanda, indica al usuario la ruta de la hoja de contacto (`hojas/hoja_00N.jpg`) para que
   la revise antes de seguir. Las que salgan mal se rehacen con `REPETIR` y otra `SEMILLA_EXTRA`.
7. Al terminar: Entorno de ejecución > Desconectar y eliminar entorno. Tiempo estimado (sin medir):
   ~20 s por imagen en T4, es decir, 1.000 imágenes ≈ 5-6 h de GPU repartidas en varios días.
8. Orden recomendado: `RANGOS = "1"` (criatura base) para todo el catálogo; las variantes fuertes
   (`RANGOS = "1,2"`) más adelante, solo para las criaturas de cada capítulo.
9. Las pruebas de este cuaderno se hicieron sin GPU (modo `SIMULAR = True`): el flujo, las rutas, la
   reanudación y las hojas funcionan; la carga y la difusión de SDXL **no se han probado en una T4**.
   Si la celda de carga o la de generar falla, copia el error y avisa; no actualices paquetes por tu cuenta.

---------------------------------------------------------------
## C9 · Imágenes del bestiario (T4, entorno nuevo)

Requisitos en Drive: `Respaldos Claude/ronin/06-Bestiario/prompts_colab.csv`.
Pega cada bloque como una celda de código, en este orden (son las celdas del cuaderno
`bestiario_imagenes.ipynb`; aquí van sin los comentarios de formulario):

Celda 1 (1 · Ajustes):
```python
MODELO = "sdxl"            # ["sdxl", "zimage"]
RANGOS = "1"               # ["1", "1,2"]
DESDE = 0                  # {type:"integer"}
HASTA = 50                 # {type:"integer"}
SOLO_MODELADO = "todos"    # ["todos", "propio", "variante", "reskin"]
INCLUIR_SENSIBLES = False  # {type:"boolean"}
REPETIR = ""               # {type:"string"}
SEMILLA_EXTRA = 0          # {type:"integer"}
FORMATO = "jpg"            # ["jpg", "png"]
TAMANO = 1024              # [768, 1024] {type:"raw"}
PASOS = 28                 # {type:"integer"}
CFG = 6.5                  # {type:"number"}
SIMULAR = False            # {type:"boolean"}

# RANGOS: 1 = criatura base · "1,2" = además su variante fuerte (alfa).
# DESDE / HASTA: posición en la lista (HASTA no incluido). Para 50 por tanda: 0-50, 50-100, ...
# REPETIR: ids separados por comas ("0353, 2301") para rehacer solo esas con otra semilla (SEMILLA_EXTRA).
# INCLUIR_SENSIBLES: las entradas con sensibilidad 2 (dioses y seres sagrados) no se dibujan por defecto.
# MODELO "zimage": 9 pasos y CFG 0; necesita una GPU de 16 GB o más (L4, A100) y NO está probado en T4.
```

Celda 2 (2 · Instalar):
```python
import os, subprocess, sys, time, csv, glob, math

if not SIMULAR:
    import torch
    if not torch.cuda.is_available():
        raise SystemExit("No hay GPU: Entorno de ejecución → Cambiar tipo de entorno de ejecución → GPU T4.")
    if MODELO == "zimage":
        paquetes = ["git+https://github.com/huggingface/diffusers", "transformers", "accelerate", "safetensors"]
    else:
        paquetes = ["diffusers>=0.30", "transformers", "accelerate", "safetensors"]
    subprocess.run([sys.executable, "-m", "pip", "install", "-q", *paquetes], check=True)
    try:   # si guardaste HF_TOKEN en los «Secretos» de Colab, se usa (no hace falta para estos modelos)
        from google.colab import userdata
        os.environ["HF_TOKEN"] = userdata.get("HF_TOKEN")
    except Exception:
        pass
print("Listo.")
```

Celda 3 (3 · Conectar con Drive):
```python
if SIMULAR:
    RAIZ = "/tmp/ronin_colab_simulado/ronin"
    os.makedirs(RAIZ + "/06-Bestiario", exist_ok=True)
else:
    from google.colab import drive
    drive.mount("/content/drive")
    RAIZ = "/content/drive/MyDrive/Respaldos Claude/ronin"
    if not os.path.isdir(RAIZ):
        encontrados = glob.glob("/content/drive/**/Respaldos Claude/ronin", recursive=True)
        if not encontrados:
            raise SystemExit("No encuentro «Respaldos Claude/ronin» en tu Drive. Cambia RAIZ a mano.")
        RAIZ = encontrados[0]
CSV_PROMPTS = RAIZ + "/06-Bestiario/prompts_colab.csv"
SALIDA = RAIZ + "/06-Bestiario/imagenes"
HOJAS = RAIZ + "/06-Bestiario/hojas"
os.makedirs(SALIDA, exist_ok=True)
os.makedirs(HOJAS, exist_ok=True)
if not os.path.exists(CSV_PROMPTS):
    raise SystemExit(f"Falta {CSV_PROMPTS}. Súbelo desde ronin3d/bestiario/prompts_colab.csv (o pídeselo a Claude).")
with open(CSV_PROMPTS, encoding="utf-8", newline="") as f:
    FILAS = list(csv.DictReader(f))
print(len(FILAS), "criaturas en la lista · carpeta de salida:", SALIDA)
```

Celda 4 (4 · Estilo y elección de criaturas):
```python
ESTILO = ("2D anime monster concept art, cel-shaded illustration, bold black ink outlines, flat color bands "
          "with two-tone shading, sumi-e ink brush splatter accents, plain warm parchment background, "
          "full body, whole creature visible, centered, feudal Japan dark fantasy bestiary page. ")
CIERRE = ", no text, no watermark"
NEGATIVO = ("photo, photorealistic, 3d render, text, letters, watermark, signature, frame, border, cropped, "
            "multiple creatures, duplicate, deformed, extra limbs, blurry, low resolution, nsfw, gore")
AURA = {"fuego": "wreathed in flames", "agua": "dripping with water and mist", "hielo": "coated in frost",
        "rayo": "crackling with lightning", "viento": "swirling with wind", "tierra": "covered in rock and moss",
        "veneno": "oozing toxic green vapor", "sombra": "trailing black shadow", "luz": "glowing with holy light",
        "sangre": "marked with crimson runes", "ninguno": "surrounded by a ghostly aura"}
FUERTE = (", elite alpha variant: larger and more menacing, ornate bone and gold adornments, glowing eyes, "
          "darker and more saturated palette, {aura}")


def construir_prompt(fila, rango):
    texto = ESTILO + fila["prompt_en"].strip().rstrip(".")
    if rango == 2:
        texto += FUERTE.format(aura=AURA.get(fila.get("elemento", "ninguno"), AURA["ninguno"]))
    return texto + CIERRE, NEGATIVO


rangos = [int(r) for r in RANGOS.split(",")]
repetir = {r.strip().zfill(4) for r in REPETIR.split(",") if r.strip()}
if repetir:
    elegidas = [f for f in FILAS if f["id"].zfill(4) in repetir]
else:
    elegidas = FILAS[DESDE:HASTA]
if SOLO_MODELADO != "todos":
    elegidas = [f for f in elegidas if f["modelado"] == SOLO_MODELADO]
if not INCLUIR_SENSIBLES:
    elegidas = [f for f in elegidas if f.get("sensibilidad", "0") != "2"]
trabajos = [(f, r) for f in elegidas for r in rangos]
print(len(elegidas), "criaturas ×", len(rangos), "rango(s) =", len(trabajos), "imágenes")
if trabajos:
    print("Ejemplo de prompt:\n ", construir_prompt(*trabajos[0])[0])
```

Celda 5 (5 · Cargar el modelo):
```python
class Simulado:
    """Sin GPU: dibuja un degradado con el nombre, para probar el flujo."""
    def __call__(self, prompt, semilla, **_):
        from PIL import Image, ImageDraw
        azar = semilla % 255
        degradado = Image.linear_gradient("L").resize((TAMANO, TAMANO))
        rojo = degradado.point(lambda v: (v + azar) % 256)
        verde = degradado.transpose(Image.ROTATE_90)
        azul = Image.new("L", (TAMANO, TAMANO), 140)
        imagen = Image.merge("RGB", (rojo, verde, azul))
        ImageDraw.Draw(imagen).text((20, 20), prompt[-60:], fill=(255, 255, 255))
        return imagen


def cargar_modelo():
    if SIMULAR:
        return Simulado()
    import torch
    if MODELO == "zimage":
        from diffusers import ZImagePipeline
        tuberia = ZImagePipeline.from_pretrained("Tongyi-MAI/Z-Image-Turbo", torch_dtype=torch.bfloat16,
                                                 low_cpu_mem_usage=False)
        tuberia.enable_model_cpu_offload()
        def generar(prompt, semilla, **_):
            return tuberia(prompt=prompt, height=TAMANO, width=TAMANO, num_inference_steps=PASOS if PASOS <= 12 else 9,
                           guidance_scale=0.0, generator=torch.Generator("cuda").manual_seed(semilla)).images[0]
        return generar
    from diffusers import StableDiffusionXLPipeline, EulerAncestralDiscreteScheduler
    tuberia = StableDiffusionXLPipeline.from_pretrained(
        "stabilityai/stable-diffusion-xl-base-1.0", torch_dtype=torch.float16, variant="fp16", use_safetensors=True)
    tuberia.scheduler = EulerAncestralDiscreteScheduler.from_config(tuberia.scheduler.config)
    tuberia.to("cuda")
    def generar(prompt, semilla, negativo="", **_):
        return tuberia(prompt=prompt, negative_prompt=negativo, num_inference_steps=PASOS, guidance_scale=CFG,
                       width=TAMANO, height=TAMANO, generator=torch.Generator("cuda").manual_seed(semilla)).images[0]
    return generar


generar = cargar_modelo()
print("Modelo listo:", "simulado" if SIMULAR else MODELO)
```

Celda 6 (6 · Generar (se puede interrumpir y repetir)):
```python
import re, unicodedata


def nombre_archivo(fila, rango):
    base = unicodedata.normalize("NFKD", fila["nombre"]).encode("ascii", "ignore").decode()
    base = re.sub(r"[^A-Za-z0-9]+", "_", base).strip("_").lower() or "criatura"
    return f"{fila['id'].zfill(4)}_{base}_r{rango}.{FORMATO}"


registro = SALIDA + "/registro.csv"
hechas = 0
inicio = time.time()
pendientes = [(f, r) for f, r in trabajos if repetir or not os.path.exists(f"{SALIDA}/{nombre_archivo(f, r)}")]
print(len(trabajos) - len(pendientes), "ya estaban hechas;", len(pendientes), "por hacer")
nuevo_registro = not os.path.exists(registro)
with open(registro, "a", encoding="utf-8", newline="") as salida_csv:
    escritor = csv.writer(salida_csv)
    if nuevo_registro:
        escritor.writerow(["archivo", "id", "nombre", "rango", "modelo", "semilla", "pasos", "segundos", "kb"])
    for i, (fila, rango) in enumerate(pendientes, 1):
        prompt, negativo = construir_prompt(fila, rango)
        semilla = int(fila["semilla"]) + rango + SEMILLA_EXTRA
        t0 = time.time()
        try:
            imagen = generar(prompt, semilla, negativo=negativo)
        except Exception as error:   # p. ej. memoria de GPU: se anota y se sigue
            print("  ✗", fila["nombre"], "→", str(error)[:120])
            if not SIMULAR:
                import torch; torch.cuda.empty_cache()
            continue
        archivo = nombre_archivo(fila, rango)
        if FORMATO == "jpg":
            imagen.convert("RGB").save(f"{SALIDA}/{archivo}", quality=90, optimize=True)
        else:
            imagen.save(f"{SALIDA}/{archivo}")
        escritor.writerow([archivo, fila["id"], fila["nombre"], rango, "simulado" if SIMULAR else MODELO,
                           semilla, PASOS, round(time.time() - t0, 1), os.path.getsize(f"{SALIDA}/{archivo}") // 1024])
        salida_csv.flush()
        hechas += 1
        media = (time.time() - inicio) / hechas
        print(f"  ✓ {i}/{len(pendientes)} {fila['nombre']} (rango {rango}) · {time.time() - t0:.0f} s · "
              f"quedan ≈ {media * (len(pendientes) - i) / 60:.0f} min")
print("Hecho:", hechas, "imágenes nuevas en", SALIDA)
```

Celda 7 (7 · Hoja de contacto (para revisar de un vistazo)):
```python
from PIL import Image, ImageDraw

archivos = sorted(glob.glob(SALIDA + "/*." + FORMATO))
ultimos = [a for a in archivos if any(os.path.basename(nombre_archivo(f, r)) == os.path.basename(a) for f, r in trabajos)]
por_hoja, columnas, lado = 12, 4, 320
for n in range(0, len(ultimos), por_hoja):
    grupo = ultimos[n:n + por_hoja]
    filas_h = math.ceil(len(grupo) / columnas)
    hoja = Image.new("RGB", (columnas * lado, filas_h * (lado + 28)), (236, 228, 210))
    pincel = ImageDraw.Draw(hoja)
    for k, ruta in enumerate(grupo):
        miniatura = Image.open(ruta).convert("RGB").resize((lado, lado))
        x, y = (k % columnas) * lado, (k // columnas) * (lado + 28)
        hoja.paste(miniatura, (x, y))
        pincel.text((x + 6, y + lado + 6), os.path.basename(ruta)[:44], fill=(30, 26, 40))
    destino = f"{HOJAS}/hoja_{n // por_hoja + 1:03d}.jpg"
    hoja.save(destino, quality=88)
    print("Hoja:", destino)
if ultimos:
    from IPython.display import display
    display(Image.open(destino))
```
