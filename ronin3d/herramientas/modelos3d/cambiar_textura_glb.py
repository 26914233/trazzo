"""Cambia la textura que va dentro de un GLB sin tocar nada más (malla, UV, material).
Uso como módulo: cambiar_textura(entrada, salida, bytes_png)
Uso suelto:      python3 cambiar_textura_glb.py <entrada.glb> <textura.png> <salida.glb>
"""
import json
import struct
import sys


def cambiar_textura(entrada, salida, png, imagen=0):
    datos = open(entrada, "rb").read()
    largo_json = struct.unpack("<I", datos[12:16])[0]
    js = json.loads(datos[20:20 + largo_json])
    binario = datos[20 + largo_json + 8:]
    vistas = js["bufferViews"]
    indice = js["images"][imagen]["bufferView"]
    trozos = []
    for i, vista in enumerate(vistas):
        inicio = vista.get("byteOffset", 0)
        trozos.append(png if i == indice else binario[inicio:inicio + vista["byteLength"]])
    nuevo = b""
    for i, trozo in enumerate(trozos):
        nuevo += b"\x00" * (-len(nuevo) % 4)       # cada trozo empieza alineado a 4 bytes
        vistas[i]["byteOffset"] = len(nuevo)
        vistas[i]["byteLength"] = len(trozo)
        nuevo += trozo
    nuevo += b"\x00" * (-len(nuevo) % 4)
    js["buffers"][0]["byteLength"] = len(nuevo)
    js["images"][imagen]["mimeType"] = "image/png"
    texto = json.dumps(js, separators=(",", ":")).encode()
    texto += b" " * (-len(texto) % 4)
    total = 12 + 8 + len(texto) + 8 + len(nuevo)
    with open(salida, "wb") as archivo:
        archivo.write(struct.pack("<III", 0x46546C67, 2, total))
        archivo.write(struct.pack("<II", len(texto), 0x4E4F534A) + texto)
        archivo.write(struct.pack("<II", len(nuevo), 0x004E4942) + nuevo)
    return total


if __name__ == "__main__":
    print(cambiar_textura(sys.argv[1], sys.argv[3], open(sys.argv[2], "rb").read()), "bytes")
