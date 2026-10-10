#!/usr/bin/env python3
"""Las caras de la caja vistas de frente (técnica B): los dos costados y la tapa.

En los bocetos, los costados y la tapa se ven muy de lado. Proyectada desde ahí, su pintura se estira en cuanto
la caja gira (lo que el usuario marcó en la B el 03-10-2026). Este guion:

1. **aplana** cada cara con la cámara del boceto (camara.json) a 2000 px/m:
   - el costado derecho (x = 0,11), del boceto de frente con los cajones cerrados (pagina/capas/sala.webp);
   - el costado izquierdo (x = −0,11), del boceto de espaldas (la caja girada media vuelta en su sitio);
   - la tapa (z = arriba), del boceto de frente;
   y deja cada una, ampliada a 1024 px, en fuentes/planos/<cara>_plano.jpg: es lo que se le pasa a Gemini para
   que la repinte nítida sin mover nada;
2. si ya están los repintados (fuentes/planos/<cara>_gemini.jpg), comprueba que no se haya movido nada,
   iguala su color con el aplanado y escribe pagina/capas/cara_<cara>.webp, que la técnica B mezcla con la
   proyección según lo de frente que se vea cada cara.

Orientación de cada imagen (la de las caras de BoxGeometry de Three.js, para usarlas sin tocar las UV):
- derecha: de izquierda a derecha, de delante (y = −0,11) a atrás; de arriba abajo, de la tapa a la base;
- izquierda: de izquierda a derecha, de atrás a delante; de arriba abajo, de la tapa a la base;
- arriba: de izquierda a derecha, x de −0,11 a 0,11; de arriba abajo, de atrás a delante.

Uso:  python3 puzles/ilustrada/herramientas/caras_boceto.py
"""
import json
import os

import numpy as np
from PIL import Image
from scipy import ndimage

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.normpath(os.path.join(AQUI, '..'))
CAPAS = os.path.join(RAIZ, 'pagina', 'capas')
PLANOS = os.path.join(RAIZ, 'fuentes', 'planos')
ESCALA = 2000            # píxeles por metro del aplanado
LADO = 1024              # lo que se le pasa a Gemini y lo que usa la página
MEDIO = 0.11             # media caja (m)


def camara():
    cam = json.load(open(os.path.join(CAPAS, 'camara.json')))
    R = np.array(cam['mundo_a_camara']); C = np.array(cam['posicion']); f = cam['focal_px']

    def proyectar(P):
        c = (np.asarray(P, np.float64) - C) @ R.T
        return 688 + f * c[..., 0] / c[..., 2], 384 + f * c[..., 1] / c[..., 2]
    return cam, proyectar


def muestrear(imagen, u, v):
    img = np.asarray(Image.open(imagen).convert('RGB'), np.float64)
    canales = [ndimage.map_coordinates(img[..., k], [v, u], order=3, mode='nearest') for k in range(3)]
    return np.clip(np.stack(canales, -1), 0, 255)


def aplanar():
    cam, proyectar = camara()
    alto = 0.21 * cam['alto_caja']
    z_abajo, z_arriba = 0.034, 0.034 + alto
    n = int(round(2 * MEDIO * ESCALA))
    a = (np.arange(n) + 0.5) / ESCALA                          # de 0 a 0,22 m
    filas = (np.arange(int(round(alto * ESCALA))) + 0.5) / ESCALA
    caras = {}
    # derecha: columnas de delante a atrás (y de −0,11 a 0,11), filas de arriba abajo
    Y, Z = np.meshgrid(a - MEDIO, z_arriba - filas)
    u, v = proyectar(np.stack([np.full_like(Y, MEDIO), Y, Z], -1))
    caras['derecha'] = muestrear(os.path.join(CAPAS, 'sala.webp'), u, v)
    # izquierda: en el boceto de espaldas la caja está girada media vuelta; su costado izquierdo ocupa el sitio
    # del derecho y sus columnas van de atrás a delante, como las quiere Three.js
    u, v = proyectar(np.stack([np.full_like(Y, MEDIO), Y, Z], -1))
    caras['izquierda'] = muestrear(os.path.join(RAIZ, 'fuentes', 'sala_detras.jpg'), u, v)
    # arriba: columnas x de −0,11 a 0,11; filas de atrás (y = 0,11) a delante
    X, Yt = np.meshgrid(a - MEDIO, MEDIO - a)
    u, v = proyectar(np.stack([X, Yt, np.full_like(X, z_arriba)], -1))
    caras['arriba'] = muestrear(os.path.join(CAPAS, 'sala.webp'), u, v)
    return caras


def igualar(img, ref):
    """Ajuste lineal por canal (como igualar_lineal de preparar_capas.py), con la referencia desenfocada igual."""
    out = np.empty_like(img)
    for k in range(3):
        a, b = np.polyfit(ndimage.gaussian_filter(img[..., k], 3).ravel(), ndimage.gaussian_filter(ref[..., k], 3).ravel(), 1)
        out[..., k] = img[..., k] * a + b
    return np.clip(out, 0, 255)


def desplazamiento(a, b):
    """Correlación de fase entre dos imágenes del mismo tamaño (en gris): cuánto se ha movido b respecto a a."""
    ga, gb = a.mean(-1), b.mean(-1)
    ga = ga - ga.mean(); gb = gb - gb.mean()
    F = np.fft.fft2(ga) * np.conj(np.fft.fft2(gb))
    r = np.fft.ifft2(F / (np.abs(F) + 1e-9)).real
    j, i = np.unravel_index(np.argmax(r), r.shape)
    if j > r.shape[0] // 2: j -= r.shape[0]
    if i > r.shape[1] // 2: i -= r.shape[1]
    return i, j


def principal():
    os.makedirs(PLANOS, exist_ok=True)
    for nombre, plano in aplanar().items():
        grande = Image.fromarray(plano.astype(np.uint8)).resize((LADO, LADO), Image.BICUBIC)
        grande.save(os.path.join(PLANOS, f'{nombre}_plano.jpg'), quality=93)
        repintado = os.path.join(PLANOS, f'{nombre}_gemini.jpg')
        if not os.path.exists(repintado):
            print(f'{nombre}: aplanado ({plano.shape[1]} × {plano.shape[0]}); falta el repintado {os.path.relpath(repintado, RAIZ)}')
            continue
        g = np.asarray(Image.open(repintado).convert('RGB').resize((LADO, LADO), Image.LANCZOS), np.float64)
        ref = np.asarray(grande, np.float64)
        dx, dy = desplazamiento(ref, g)
        g = igualar(g, ref)
        Image.fromarray(g.astype(np.uint8)).save(os.path.join(CAPAS, f'cara_{nombre}.webp'), quality=88, method=6)
        print(f'{nombre}: repintado igualado → capas/cara_{nombre}.webp (desplazamiento {dx}, {dy} px de {LADO})')


if __name__ == '__main__':
    principal()
