#!/usr/bin/env python3
"""Las capas del nivel 6 de La caja viva («La noche»; NIVELES.md §9).

    python3 puzles/ilustrada/herramientas/nivel6_capas.py

Sale, en `pagina/capas/`:
  - `lampara_apagada.webp`: la lámpara andon del boceto, apagada. El papel de la pantalla deja de brillar (sin el
    resplandor de dentro: papel gris y apagado, con su textura) y la madera se oscurece, porque ya no la alumbra la
    llama. Con transparencia en el borde, para ponerla encima de la sala en su sitio.
  - `nivel6.json`: dónde está cada cosa del nivel, en píxeles del boceto (1376 × 768): el recorte de la lámpara, su
    puertecilla de papel y la mecha; la hoja del shoji que se entreabre y el hueco que deja; y las brasas.

Sin imágenes nuevas ni IA: todo sale de capas/sala.webp.
"""
import json
import os

import numpy as np
from PIL import Image
from scipy import ndimage

AQUI = os.path.dirname(os.path.abspath(__file__))
CAPAS = os.path.join(AQUI, '..', 'pagina', 'capas')

# la lámpara (andon): su recorte y la pantalla de papel (las dos caras que se ven), en píxeles del boceto
RECORTE = [536, 208, 672, 336]                 # x0, y0, x1, y1
CARA_FRENTE = [[549, 223], [609, 223], [609, 322], [549, 322]]
CARA_LADO = [[619, 222], [660, 222], [660, 316], [619, 322]]
# la puertecilla: el panel de abajo de la cara de delante (se desliza hacia la izquierda) y la mecha, dentro
PUERTA = [552, 297, 607, 321]
MECHA = [586, 312]
# la hoja de la derecha del shoji: se desliza hacia la derecha y deja un hueco junto al poste (con la noche fuera)
SHOJI = {'hueco': [1238, 0, 1376, 448], 'poste': 1238, 'abre': 74}
# las brasas del incensario (las mismas que alumbran en juego.js: luces('incensario'))
BRASAS = [578, 500]


def poligono(forma, ancho, alto):
    from PIL import ImageDraw
    m = Image.new('L', (ancho, alto), 0)
    ImageDraw.Draw(m).polygon([tuple(p) for p in forma], fill=255)
    return np.asarray(m) > 0


def main():
    sala = np.asarray(Image.open(os.path.join(CAPAS, 'sala.webp')).convert('RGB')).astype(np.float32)
    x0, y0, x1, y1 = RECORTE
    trozo = sala[y0:y1, x0:x1].copy()
    alto, ancho = trozo.shape[:2]
    rel = lambda forma: [[x - x0, y - y0] for x, y in forma]
    pantalla = poligono(rel(CARA_FRENTE), ancho, alto) | poligono(rel(CARA_LADO), ancho, alto)

    lum = trozo @ np.array([0.299, 0.587, 0.114], np.float32)
    calido = trozo[..., 0] - trozo[..., 2]
    # el papel que brilla: claro y cálido, dentro de la pantalla (las varillas, más oscuras, se quedan)
    papel = pantalla & (lum > 150) & (calido > 18)
    papel = ndimage.binary_opening(papel, iterations=1)
    suave = ndimage.gaussian_filter(papel.astype(np.float32), 0.9)

    # 1. el papel apagado: gris cálido y sin el resplandor (la luminosidad se aplana, con algo de su textura)
    dentro = lum[papel]
    lo, hi = np.percentile(dentro, 5), np.percentile(dentro, 95)
    textura = np.clip((lum - lo) / max(1.0, hi - lo), 0, 1)
    base = np.array([140, 131, 114], np.float32)
    apagado = base[None, None, :] * (0.88 + 0.16 * textura[..., None])
    # un poco más oscuro abajo (la mecha ya no alumbra desde dentro) y en el borde de cada cara
    yy = np.linspace(0, 1, alto, dtype=np.float32)[:, None, None]
    apagado *= 1.02 - 0.12 * yy
    resultado = trozo * (1 - suave[..., None]) + apagado * suave[..., None]

    # 2. la madera y las varillas de la pantalla: sin la luz de dentro, más oscuras y menos rojizas (solo la pantalla
    # con su marco y el remate de arriba: la parte de abajo es un armazón abierto y por él se ve la pared)
    lampara = ndimage.binary_dilation(pantalla, iterations=5) | poligono(rel([[543, 214], [667, 214], [667, 225], [543, 225]]), ancho, alto)
    madera = lampara & ~papel
    gris = resultado @ np.array([0.299, 0.587, 0.114], np.float32)
    sin_luz = 0.62 * (0.75 * resultado + 0.25 * gris[..., None])
    peso = ndimage.gaussian_filter(madera.astype(np.float32), 0.8)[..., None]
    resultado = resultado * (1 - peso) + sin_luz * peso

    # 3. el borde: la pantalla con su marco tapa; lo demás del recorte (la pared de alrededor) no se toca
    alfa = np.clip(ndimage.gaussian_filter(lampara.astype(np.float32), 1.2) * 1.2, 0, 1)
    rgba = np.dstack([np.clip(resultado, 0, 255), alfa * 255]).astype(np.uint8)
    Image.fromarray(rgba, 'RGBA').save(os.path.join(CAPAS, 'lampara_apagada.webp'), lossless=False, quality=92)

    datos = {
        'lampara': {'recorte': RECORTE, 'centro': [604, 272], 'zona': [540, 212, 670, 432], 'puerta': PUERTA,
                    'mecha': MECHA, 'humo': [600, 218]},
        'shoji': SHOJI,
        'brasas': BRASAS,
        'nota': ('Píxeles del boceto (capas/sala.webp, 1376 × 768). lampara.recorte es dónde va '
                 'capas/lampara_apagada.webp; puerta, la puertecilla de papel (se desliza a la izquierda); shoji.hueco, '
                 'la hoja que se entreabre (hasta shoji.abre píxeles, desde shoji.poste).'),
    }
    with open(os.path.join(CAPAS, 'nivel6.json'), 'w', encoding='utf-8') as f:
        json.dump(datos, f, ensure_ascii=False)
    print('lampara_apagada.webp', rgba.shape, 'papel', int(papel.sum()), 'px')


if __name__ == '__main__':
    main()
