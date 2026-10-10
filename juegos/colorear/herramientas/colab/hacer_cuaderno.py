"""Genera generar_laminas.ipynb con prompts.py incrustado: python3 hacer_cuaderno.py"""
import json

prompts_src = open("prompts.py", encoding="utf-8").read()


def md(t):
    return {"cell_type": "markdown", "metadata": {}, "source": t}


def code(t):
    return {"cell_type": "code", "metadata": {}, "execution_count": None, "outputs": [], "source": t}


GENERAR = r"""
# Genera las láminas. Se ejecuta en un proceso aparte (!python) para usar las
# versiones recién instaladas aunque Colab tenga otras cargadas en memoria.
import argparse, os, sys, time, traceback
sys.path.insert(0, "/content")
from prompts import lista

ap = argparse.ArgumentParser()
ap.add_argument("--modo", default="rapido")
ap.add_argument("--semillas", type=int, default=2)
ap.add_argument("--prueba", type=int, default=0)
ap.add_argument("--carpeta", default="/content/drive/MyDrive/colorear_lotes")
ap.add_argument("--tanda", default="")
a = ap.parse_args()

try:
    import torch
    from diffusers import StableDiffusionXLPipeline, EulerDiscreteScheduler, AutoencoderKL
    from huggingface_hub import hf_hub_download
except Exception as e:
    causa = e
    while causa.__cause__ is not None:
        causa = causa.__cause__
    print("\n*** NO SE PUDO CARGAR diffusers ***\nCausa:", repr(causa), "\nMándale esta línea a Claude.\n")
    traceback.print_exc()
    sys.exit(1)

if not torch.cuda.is_available():
    print("*** No hay GPU. Entorno de ejecución -> Cambiar tipo -> GPU, y vuelve a ejecutar todo. ***")
    sys.exit(1)

vae = AutoencoderKL.from_pretrained("madebyollin/sdxl-vae-fp16-fix", torch_dtype=torch.float16)
pipe = StableDiffusionXLPipeline.from_pretrained(
    "stabilityai/stable-diffusion-xl-base-1.0", vae=vae, torch_dtype=torch.float16, variant="fp16").to("cuda")
pipe.set_progress_bar_config(disable=True)
if a.modo == "rapido":
    pipe.load_lora_weights(hf_hub_download("ByteDance/SDXL-Lightning", "sdxl_lightning_8step_lora.safetensors"))
    pipe.fuse_lora()
    pipe.scheduler = EulerDiscreteScheduler.from_config(pipe.scheduler.config, timestep_spacing="trailing")
    pasos, guia = 8, 0.0
else:
    pasos, guia = 30, 6.0
negativo = ("color, colored, gray, grey, shading, shadow, gradient, hatching, crosshatching, stippling, "
            "photo, 3d render, blurry, noisy, text, letters, watermark, signature, frame border, cropped")
print("Modelo listo:", a.modo, pasos, "pasos,", torch.cuda.get_device_name(0), flush=True)

trabajos = [(pid, cat, p, s) for pid, cat, p in lista(a.tanda) for s in range(a.semillas)]
if a.prueba:
    trabajos = trabajos[::max(1, len(trabajos) // a.prueba)][:a.prueba]
hechas, t0 = 0, time.time()
for n, (pid, cat, prompt, s) in enumerate(trabajos):
    os.makedirs(f"{a.carpeta}/{cat}", exist_ok=True)
    ruta = f"{a.carpeta}/{cat}/{pid}_s{s}.png"
    if os.path.exists(ruta):
        continue
    gen = torch.Generator("cuda").manual_seed(1000 + s * 7919 + n)
    img = pipe(prompt, negative_prompt=negativo if guia > 0 else None, num_inference_steps=pasos,
               guidance_scale=guia, width=1024, height=1024, generator=gen).images[0]
    img.convert("L").save(ruta, optimize=True)
    hechas += 1
    if hechas % 10 == 0:
        ritmo = (time.time() - t0) / hechas
        print(f"{n + 1}/{len(trabajos)}  ({ritmo:.1f} s por imagen, faltan ~{ritmo * (len(trabajos) - n - 1) / 60:.0f} min)", flush=True)
print("Terminado:", hechas, "imágenes nuevas")
"""

celdas = [
    md("""# Láminas para colorear con SDXL (gratis en Colab)

**Solo dos pasos:** pulsa **Conectar** (arriba a la derecha) y luego
*Entorno de ejecución → Ejecutar todo*. Acepta el permiso de Google Drive cuando lo pida.

- Ya viene con GPU. Si dijera que no hay GPU: *Entorno de ejecución → Cambiar tipo → GPU*.
- Guarda cada imagen en `Mi unidad/colorear_lotes/<categoría>/` al momento.
- Si Colab se desconecta, vuelve a *Ejecutar todo*: salta las que ya hizo y sigue.
- Al terminar crea `Mi unidad/colorear_zip/` con un .zip por categoría. Avisa a Claude:
  las lee directamente de tu Drive, no hace falta compartir nada.

Modelos: SDXL base 1.0 (Stability AI) + SDXL-Lightning 8 pasos (ByteDance), ambos con
licencia `openrail++`, que permite uso comercial respetando sus restricciones de uso."""),
    code("""# Ajustes
MODO = "rapido"      # "rapido" (Lightning) o "calidad" (SDXL normal, 30 pasos, usa el prompt negativo)
TANDA = "criaturas"  # "criaturas" = animales fantásticos (180 prompts); "" = la tanda original
SEMILLAS = 3         # imágenes por prompt (180 x 3 = 540)
SOLO_PRUEBA = 0      # 0 = todas; un número (p. ej. 20) para hacer solo una prueba
CARPETA = "/content/drive/MyDrive/colorear_lotes"
CARPETA_ZIP = "/content/drive/MyDrive/colorear_zip\""""),
    code("""# torchao viene preinstalado en Colab en una versión vieja que choca con diffusers; no se usa.
!pip -q uninstall -y torchao
!pip -q install -U diffusers transformers accelerate safetensors peft"""),
    code("""from google.colab import drive
drive.mount('/content/drive')"""),
    code("%%writefile /content/prompts.py\n" + prompts_src),
    code("%%writefile /content/generar.py\n" + GENERAR.lstrip("\n")),
    code('!python /content/generar.py --modo {MODO} --semillas {SEMILLAS} --prueba {SOLO_PRUEBA} --carpeta {CARPETA} --tanda "{TANDA}"'),
    code("""# Un .zip por categoría para que Claude las recoja de tu Drive
import os, shutil
if not os.path.isdir(CARPETA) or not os.listdir(CARPETA):
    raise SystemExit("Todavía no hay imágenes: revisa el error de la celda anterior y mándaselo a Claude.")
os.makedirs(CARPETA_ZIP, exist_ok=True)
for cat in sorted(os.listdir(CARPETA)):
    if TANDA and cat != TANDA:
        continue
    shutil.make_archive(f"{CARPETA_ZIP}/{cat}", "zip", f"{CARPETA}/{cat}")
    print(cat, len(os.listdir(f"{CARPETA}/{cat}")), "imágenes")"""),
]

nb = {"nbformat": 4, "nbformat_minor": 5,
      "metadata": {"accelerator": "GPU", "colab": {"provenance": [], "gpuType": "T4"},
                   "kernelspec": {"name": "python3", "display_name": "Python 3"}},
      "cells": celdas}
json.dump(nb, open("generar_laminas.ipynb", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("generar_laminas.ipynb listo")
