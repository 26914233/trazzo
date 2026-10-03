"""Versión ligera del modelo de Blender de la caja viva para la página (técnica C).

Abre caja_viva_ac.glb y mesa_caja_viva.glb, simplifica la cara (70 000 triángulos → unos 18 000), reduce
las texturas a 512 px y exporta en glTF: la geometría va dentro del JSON (las páginas privadas no sirven
.glb ni .bin) y las texturas, en JPEG aparte. Sale en pagina/modelos/ (caja_viva.json, mesa.json y los .jpg).

Uso (Blender por código, sin ventana):
  /root/herramientas/blender-4.5.14-linux-x64/blender -b --factory-startup \
      --python puzles/ilustrada/herramientas/modelo_web.py
"""
import base64
import json
import os
import shutil
import tempfile

import bpy

AQUI = os.path.dirname(os.path.abspath(__file__))
MODELOS = os.path.normpath(os.path.join(AQUI, '..', '..', 'godot', 'modelos', 'caja_viva'))
SALIDA = os.path.normpath(os.path.join(AQUI, '..', 'pagina', 'modelos'))
LADO_TEXTURA = 512


def vaciar():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def aligerar_imagenes():
    for imagen in bpy.data.images:
        if imagen.size[0] > LADO_TEXTURA:
            imagen.scale(LADO_TEXTURA, LADO_TEXTURA)


def exportar(nombre):
    """Exporta a glTF separado en una carpeta temporal y deja en SALIDA el JSON con la geometría dentro y las
    texturas con el nombre del modelo delante (caja_…jpg, mesa_…jpg)."""
    os.makedirs(SALIDA, exist_ok=True)
    temporal = tempfile.mkdtemp()
    bpy.ops.export_scene.gltf(
        filepath=os.path.join(temporal, nombre + '.gltf'), export_format='GLTF_SEPARATE', export_image_format='JPEG',
        export_jpeg_quality=86, export_apply=True, export_yup=True, export_extras=False,
        export_animations=False, export_cameras=False, export_lights=False)
    with open(os.path.join(temporal, nombre + '.gltf'), encoding='utf-8') as f:
        gltf = json.load(f)
    for b in gltf['buffers']:
        with open(os.path.join(temporal, b['uri']), 'rb') as f:
            b['uri'] = 'data:application/octet-stream;base64,' + base64.b64encode(f.read()).decode('ascii')
    prefijo = nombre.split('_')[0] + '_'
    for im in gltf.get('images', []):
        nuevo = prefijo + os.path.basename(im['uri'])
        shutil.copyfile(os.path.join(temporal, im['uri']), os.path.join(SALIDA, nuevo))
        im['uri'] = nuevo
    with open(os.path.join(SALIDA, nombre + '.json'), 'w', encoding='utf-8') as f:
        json.dump(gltf, f, separators=(',', ':'))
    shutil.rmtree(temporal)


# La caja: la cara pesa casi todo (un relieve sacado de un mapa de alturas)
vaciar()
bpy.ops.import_scene.gltf(filepath=os.path.join(MODELOS, 'caja_viva_ac.glb'))
cara = bpy.data.objects['Cara']
mod = cara.modifiers.new('simplificar', 'DECIMATE')
mod.ratio = 0.26
aligerar_imagenes()
exportar('caja_viva')

# Lo que hay en la mesa: el incensario con su león, la tetera y las tazas
vaciar()
bpy.ops.import_scene.gltf(filepath=os.path.join(MODELOS, 'mesa_caja_viva.glb'))
aligerar_imagenes()
exportar('mesa')
print('modelos web listos en', SALIDA)
