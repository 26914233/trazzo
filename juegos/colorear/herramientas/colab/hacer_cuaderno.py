"""Genera generar_laminas.ipynb con prompts.py incrustado: python3 hacer_cuaderno.py"""
import json

prompts_src = open("prompts.py", encoding="utf-8").read()


def md(t):
    return {"cell_type": "markdown", "metadata": {}, "source": t}


def code(t):
    return {"cell_type": "code", "metadata": {}, "execution_count": None, "outputs": [], "source": t}


celdas = [
    md("""# Láminas para colorear con SDXL (gratis en Colab)

**Antes de empezar:** menú *Entorno de ejecución → Cambiar tipo de entorno de ejecución → GPU T4*.
Luego *Entorno de ejecución → Ejecutar todo*. Pedirá permiso para usar tu Google Drive.

- Guarda cada imagen en `Mi unidad/colorear_lotes/<categoría>/` en cuanto la hace.
- Si Colab se desconecta, vuelve a *Ejecutar todo*: salta las que ya existen y sigue.
- Al terminar crea `Mi unidad/colorear_zip/` con un .zip por categoría. Comparte esa carpeta
  como *Cualquier persona con el enlace* y pásale el enlace a Claude.

Modelos: SDXL base 1.0 (Stability AI) + SDXL-Lightning 8 pasos (ByteDance), ambos con
licencia `openrail++`, que permite uso comercial respetando sus restricciones de uso."""),
    code("""# Ajustes
MODO = "rapido"      # "rapido" (Lightning, ~5 s por imagen) o "calidad" (SDXL normal, ~25 s, usa el prompt negativo)
SEMILLAS = 2         # imágenes por prompt (855 prompts x 2 = 1710)
SOLO_PRUEBA = 0      # pon por ejemplo 20 para probar antes de lanzar todo (0 = todas)
CARPETA = "/content/drive/MyDrive/colorear_lotes"
CARPETA_ZIP = "/content/drive/MyDrive/colorear_zip\""""),
    code("!pip -q install diffusers==0.31.0 transformers accelerate safetensors"),
    code("""from google.colab import drive
drive.mount('/content/drive')"""),
    code(prompts_src.replace('if __name__ == "__main__":', 'if False:')),
    code("""import os, torch
from diffusers import StableDiffusionXLPipeline, EulerDiscreteScheduler, AutoencoderKL
from huggingface_hub import hf_hub_download

vae = AutoencoderKL.from_pretrained("madebyollin/sdxl-vae-fp16-fix", torch_dtype=torch.float16)
pipe = StableDiffusionXLPipeline.from_pretrained(
    "stabilityai/stable-diffusion-xl-base-1.0", vae=vae, torch_dtype=torch.float16, variant="fp16").to("cuda")
if MODO == "rapido":
    pipe.load_lora_weights(hf_hub_download("ByteDance/SDXL-Lightning", "sdxl_lightning_8step_lora.safetensors"))
    pipe.fuse_lora()
    pipe.scheduler = EulerDiscreteScheduler.from_config(pipe.scheduler.config, timestep_spacing="trailing")
    PASOS, GUIA = 8, 0.0
else:
    PASOS, GUIA = 30, 6.0
NEGATIVO = ("color, colored, gray, grey, shading, shadow, gradient, hatching, crosshatching, stippling, "
            "photo, 3d render, blurry, noisy, text, letters, watermark, signature, frame border, cropped")
print("Listo:", MODO, PASOS, "pasos")"""),
    code("""import time
trabajos = [(pid, cat, p, s) for pid, cat, p in lista() for s in range(SEMILLAS)]
if SOLO_PRUEBA:
    trabajos = trabajos[::max(1, len(trabajos) // SOLO_PRUEBA)][:SOLO_PRUEBA]
hechas, t0 = 0, time.time()
for n, (pid, cat, prompt, s) in enumerate(trabajos):
    os.makedirs(f"{CARPETA}/{cat}", exist_ok=True)
    ruta = f"{CARPETA}/{cat}/{pid}_s{s}.png"
    if os.path.exists(ruta):
        continue
    gen = torch.Generator("cuda").manual_seed(1000 + s * 7919 + n)
    img = pipe(prompt, negative_prompt=NEGATIVO if GUIA > 0 else None, num_inference_steps=PASOS,
               guidance_scale=GUIA, width=1024, height=1024, generator=gen).images[0]
    img.convert("L").save(ruta, optimize=True)
    hechas += 1
    if hechas % 10 == 0:
        ritmo = (time.time() - t0) / hechas
        print(f"{n + 1}/{len(trabajos)}  ({ritmo:.1f} s por imagen, faltan ~{ritmo * (len(trabajos) - n - 1) / 60:.0f} min)")
print("Terminado")"""),
    code("""# Un .zip por categoría para pasárselo a Claude
import shutil
os.makedirs(CARPETA_ZIP, exist_ok=True)
for cat in sorted(os.listdir(CARPETA)):
    shutil.make_archive(f"{CARPETA_ZIP}/{cat}", "zip", f"{CARPETA}/{cat}")
    print(cat, len(os.listdir(f"{CARPETA}/{cat}")), "imágenes")"""),
]

nb = {"nbformat": 4, "nbformat_minor": 5,
      "metadata": {"accelerator": "GPU", "colab": {"provenance": [], "gpuType": "T4"},
                   "kernelspec": {"name": "python3", "display_name": "Python 3"}},
      "cells": celdas}
json.dump(nb, open("generar_laminas.ipynb", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("generar_laminas.ipynb listo")
