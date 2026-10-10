"""Nivel 5 · La cómoda: lo que sale de la pintura (sin imágenes nuevas).

1. El costado izquierdo sin la borla de abajo (el lazo, el cordón, la cabeza y los flecos), en su repintado de frente
   (capas/cara_izquierda.webp) y en el boceto de espaldas (capas/sala_detras.webp): juego.js dibuja la borla por
   código para poder desatarla y tirar de ella. Lo de arriba del cordón se queda pintado. El hueco se rellena con
   trozos del propio mosaico (rellenar_parches.py).
2. En el boceto de espaldas, el cajón de en medio a la izquierda (m1), que la pintura enseña abierto, cerrado en su
   sitio: su frente pintado, llevado al hueco. En 3D sale y entra con esa pintura.
3. Su secreto: un dibujo a tinta de la sala de noche, con la lámpara apagada y la caja temblando (capas/secreto.webp).
4. capas/nivel5.json: los cajones de la espalda (esquina de arriba a la izquierda y de abajo a la derecha, en el
   boceto de espaldas), el panel escondido, la borla (en píxeles del repintado del costado, 1024 × 1024).

Uso: python3 puzles/ilustrada/herramientas/nivel5_capas.py   (tarda unos minutos: el relleno es en Python)
"""
import json
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter
from scipy import ndimage

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rellenar_parches import rellenar  # noqa: E402

AQUI = os.path.dirname(os.path.abspath(__file__))
CAPAS = os.path.normpath(os.path.join(AQUI, '..', 'pagina', 'capas'))

# --- los cajones de la espalda, en el boceto de espaldas: [x0, y0, x1, y1] = esquina de arriba a la izquierda y de
# abajo a la derecha de su frente (la caja se ve un poco en perspectiva: el borde derecho queda más abajo) ---
CAJONES_DETRAS = {
    't1': [714, 234, 784, 295], 't2': [794, 241, 899, 309], 't3': [909, 250, 990, 319],
    'm1': [715, 302, 785, 368], 'm2': [715, 369, 785, 471],
    'c': [795, 428, 899, 482],
    'r1': [909, 322, 990, 386], 'r2': [909, 388, 989, 440], 'r3': [910, 443, 989, 502],
}
PANEL = [794, 311, 899, 426]           # el panel del hueco de la ficha: es el frente del cajón escondido (p)
HUECO_FICHA = [816, 334, 876, 404]

# --- la borla en el repintado del costado (1024 × 1024): hasta CORTE se queda pintada; de ahí abajo, a código ---
CORTE = 418
BORLA = {
    'corte': CORTE,
    'hebras': [[566, CORTE], [604, CORTE]],          # las dos hebras del cordón doblado, donde se cortan
    'nudo': [600, 486],
    'lazo_izq': {'centro': [432, 484], 'rx': 120, 'ry': 54},
    'lazo_der': {'centro': [704, 470], 'rx': 88, 'ry': 52},
    'cabeza': {'centro': [616, 712], 'rx': 92, 'ry': 50},
    'flecos': {'arriba': 748, 'abajo': 1024, 'ancho_arriba': 216, 'ancho_abajo': 280},
}


def mascara_figuras(tam, figuras, margen=0):
    m = Image.new('L', tam, 0)
    d = ImageDraw.Draw(m)
    for f in figuras:
        tipo = f[0]
        if tipo == 'elipse':
            _, cx, cy, rx, ry = f
            d.ellipse([cx - rx - margen, cy - ry - margen, cx + rx + margen, cy + ry + margen], fill=255)
        elif tipo == 'rect':
            _, x0, y0, x1, y1 = f
            d.rectangle([x0 - margen, y0 - margen, x1 + margen, y1 + margen], fill=255)
        elif tipo == 'poli':
            d.polygon([tuple(p) for p in f[1]], fill=255)
    a = np.asarray(m) > 0
    return ndimage.binary_dilation(a, iterations=margen) if margen else a


def tono(a):
    """Matiz (grados), saturación y valor de una matriz RGB 0-1."""
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    mx, mn = a.max(axis=2), a.min(axis=2)
    d = np.maximum(mx - mn, 1e-6)
    h = np.where(mx == r, ((g - b) / d) % 6, np.where(mx == g, (b - r) / d + 2, (r - g) / d + 4)) * 60
    s = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1e-6), 0)
    return h, s, mx


PANEL_IZQ = (76, 76, 946, 940)       # el mosaico del costado, dentro del marco (x0, y0, x1, y1)
MARCO_Y = 942                        # de aquí abajo, el marco y el canto de la caja (franjas horizontales)


def hueco_borla_frente(a):
    """El cordón de la borla (por su rojo) dentro de las figuras del lazo, más su contorno de tinta; la cabeza y los flecos,
    enteros. El interior de los lazos es madera de verdad y se queda."""
    h, s, v = tono(a / 255)
    rojo = ((h < 13) | (h > 335)) & (s > 0.33) & (v > 0.07)
    lazos = mascara_figuras((1024, 1024), [('elipse', 432, 482, 136, 76), ('elipse', 702, 472, 106, 74),
                                          ('rect', 536, 420, 666, 550), ('rect', 526, 518, 670, 706)])
    solido = mascara_figuras((1024, 1024), [('elipse', 617, 714, 112, 66),
                                           ('poli', [[498, 730], [742, 730], [784, 1024], [464, 1024]])], margen=3)
    nucleo = ndimage.binary_closing(ndimage.binary_opening(rojo & lazos, iterations=1), iterations=4)
    etq, n = ndimage.label(nucleo)
    tam = ndimage.sum(nucleo, etq, range(1, n + 1))
    nucleo = np.isin(etq, [i + 1 for i, t in enumerate(tam) if t > 150])
    hueco = ndimage.binary_dilation(nucleo, iterations=7) | solido
    hueco[:CORTE - 2] = False
    # el cordón de arriba (el que se queda pintado): que no se copie al rellenar
    cordon = ndimage.binary_dilation(rojo & mascara_figuras((1024, 1024), [('rect', 440, 0, 660, CORTE)]), iterations=8)
    return hueco, cordon


def quitar_borla_frente():
    im = Image.open(os.path.join(CAPAS, 'cara_izquierda.webp')).convert('RGB')
    a = np.asarray(im).astype(np.float32)
    hueco, cordon = hueco_borla_frente(a)
    nueva = a.copy()
    # 1. el marco de abajo (franjas horizontales): se copia de lo de su izquierda, fila a fila
    for y in range(MARCO_Y - 4, 1024):
        for x in np.nonzero(hueco[y])[0]:
            nueva[y, x] = nueva[y, x - 170]
    resto = hueco.copy()
    resto[MARCO_Y - 4:] = False
    # 2. el mosaico: con parches del propio mosaico de cerca (no del cordón, ni del marco, ni de la otra punta)
    x0, y0, x1, y1 = PANEL_IZQ
    panel = np.zeros_like(hueco)
    panel[y0:y1, x0:x1] = True
    cerca = ndimage.distance_transform_edt(~resto) < 230
    fuente = panel & ~cordon & cerca & ~resto
    nueva = rellenar(nueva, resto, fuente=fuente, radio=4, iteraciones=(10, 8, 7, 6))
    # un poco de grano encima, para que lo rehecho no quede más liso que lo de alrededor
    ruido = np.random.default_rng(3).normal(0, 3.0, a.shape).astype(np.float32)
    nueva[hueco] = np.clip(nueva[hueco] + ruido[hueco], 0, 255)
    Image.fromarray(nueva.astype(np.uint8)).save(os.path.join(CAPAS, 'cara_izquierda_l5.webp'), quality=90, method=6)
    return hueco.sum(), nueva


def cerrar_m1(a):
    """El frente abierto de m1 (en la pintura) llevado a su hueco (cerrado). a: matriz del boceto de espaldas."""
    im = Image.fromarray(a.astype(np.uint8))
    abierto = [(690, 311.5), (763.5, 317), (763.5, 368.5), (690, 360.5)]          # su frente, tal como está pintado
    x0, y0, x1, y1 = CAJONES_DETRAS['m1']
    pendiente = 0.107                                                              # la del borde de los cajones
    cerrado = [(x0, y0), (x1, y0 + pendiente * (x1 - x0)), (x1, y1), (x0, y1 - pendiente * (x1 - x0))]
    # transformación de perspectiva: de cada punto del cerrado al del abierto (PIL pide los coeficientes así)
    A, B = [], []
    for (xc, yc), (xa, ya) in zip(cerrado, abierto):
        A.append([xc, yc, 1, 0, 0, 0, -xa * xc, -xa * yc]); B.append(xa)
        A.append([0, 0, 0, xc, yc, 1, -ya * xc, -ya * yc]); B.append(ya)
    coef = np.linalg.solve(np.array(A, float), np.array(B, float))
    llevado = im.transform(im.size, Image.PERSPECTIVE, tuple(coef), Image.BICUBIC)
    m = Image.new('L', im.size, 0)
    ImageDraw.Draw(m).polygon(cerrado, fill=255)
    m = m.filter(ImageFilter.GaussianBlur(0.8))
    salida = Image.composite(llevado, im, m)
    # una sombra fina bajo el borde de arriba: el frente está metido en su hueco
    d = ImageDraw.Draw(salida, 'RGBA')
    d.line([cerrado[0], cerrado[1]], fill=(20, 12, 8, 150), width=2)
    return np.asarray(salida).astype(np.float32)


def costado_en_detras(frente, recorte):
    """El repintado del costado izquierdo, visto con la cámara del boceto de espaldas (la caja girada media vuelta: el
    costado izquierdo cae donde el derecho en el de frente). Devuelve la imagen y dónde cae dentro del costado."""
    with open(os.path.join(CAPAS, 'camara.json'), encoding='utf-8') as f:
        cam = json.load(f)
    with open(os.path.join(CAPAS, 'escena.json'), encoding='utf-8') as f:
        alto = 0.21 * json.load(f)['alto_caja']
    R, P0, foco = np.array(cam['mundo_a_camara']), np.array(cam['posicion']), cam['focal_px']
    ancho_img, alto_img = cam['imagen']
    x0, y0, x1, y1 = recorte
    vs, us = np.mgrid[y0:y1, x0:x1].astype(np.float64)
    d = np.stack([(us - ancho_img / 2) / foco, (vs - alto_img / 2) / foco, np.ones_like(us)], -1) @ R
    t = (0.11 - P0[0]) / d[..., 0]
    col = (P0[1] + t * d[..., 1] + 0.11) / 0.22 * 1024
    fila = (0.034 + alto - (P0[2] + t * d[..., 2])) / alto * 1024
    dentro = (col >= 0) & (col < 1023) & (fila >= 0) & (fila < 1023)
    # visto tan de lado, el costado se encoge mucho a lo ancho: se suaviza antes (si no, salen granos)
    suave = np.stack([ndimage.gaussian_filter(frente[..., k], (1.6, 4.5)) for k in range(3)], -1)
    muestra = np.stack([ndimage.map_coordinates(suave[..., k], [fila, col], order=1) for k in range(3)], -1)
    return muestra, dentro, fila


def quitar_borla_detras(frente_l5):
    im = Image.open(os.path.join(CAPAS, 'sala_detras.webp')).convert('RGB')
    a = np.asarray(im).astype(np.float32)
    a = cerrar_m1(a)
    figuras = [
        ('elipse', 1070, 379, 16, 24), ('elipse', 1100, 357, 23, 23), ('rect', 1079, 348, 1106, 388),
        ('rect', 1084, 380, 1106, 433), ('elipse', 1098, 440, 16, 15),
        ('poli', [[1081, 448], [1116, 448], [1126, 564], [1073, 564]]),
    ]
    hueco = mascara_figuras(im.size, figuras, margen=3)
    hueco[:333] = False
    # el costado sin borla, proyectado desde su repintado (ya sin ella): las dos pinturas coinciden casi al píxel
    recorte = (990, 180, 1170, 600)
    x0, y0, x1, y1 = recorte
    muestra, dentro, _ = costado_en_detras(frente_l5, recorte)
    h = hueco[y0:y1, x0:x1] & dentro
    # igualar el color: la media y la desviación de un anillo alrededor del hueco, en las dos pinturas
    anillo = ndimage.binary_dilation(h, iterations=10) & ~ndimage.binary_dilation(h, iterations=3) & dentro
    orig = a[y0:y1, x0:x1]
    ajustada = muestra.copy()
    for k in range(3):
        mo, so = orig[..., k][anillo].mean(), orig[..., k][anillo].std() + 1e-3
        mm, sm = muestra[..., k][anillo].mean(), muestra[..., k][anillo].std() + 1e-3
        ajustada[..., k] = (muestra[..., k] - mm) * (so / sm) + mo
    # y fundido suave en el borde
    peso = ndimage.gaussian_filter(h.astype(np.float32), 1.2)
    peso = np.maximum(peso, h.astype(np.float32))[..., None]
    a[y0:y1, x0:x1] = orig * (1 - peso) + ajustada * peso
    Image.fromarray(np.clip(a, 0, 255).astype(np.uint8)).save(os.path.join(CAPAS, 'sala_detras_l5.webp'), quality=90, method=6)
    return h.sum()


def secreto():
    """Su secreto: la sala a tinta, de noche, con la lámpara apagada y la caja temblando."""
    sala = Image.open(os.path.join(CAPAS, 'sala.webp')).convert('RGB')
    w, h = 640, 357
    peq = sala.resize((w, h), Image.LANCZOS)
    g = np.asarray(peq.convert('L')).astype(np.float32)
    # las líneas: diferencia de dos desenfoques (lo oscuro y fino de la pintura)
    dog = ndimage.gaussian_filter(g, 0.9) - ndimage.gaussian_filter(g, 2.4)
    linea = np.clip((-dog - 2.5) / 9, 0, 1) ** 0.8
    # una aguada de tinta según lo oscuro, en tres tonos (de noche, más oscura)
    tono = 1 - g / 255
    aguada = np.round(np.clip(tono * 1.25 - 0.1, 0, 1) * 3) / 3 * 0.38
    # la lámpara, apagada: su papel ya no brilla (en tinta, gris oscuro)
    sx, sy = w / 1376, h / 768
    yy, xx = np.mgrid[0:h, 0:w]
    lampara = (xx > 535 * sx) & (xx < 676 * sx) & (yy > 212 * sy) & (yy < 434 * sy)
    aguada = np.where(lampara, np.maximum(aguada, 0.5), aguada)
    tinta = np.clip(np.maximum(linea, aguada), 0, 1)
    papel = np.array([239, 230, 210], np.float32)
    color = np.array([30, 30, 44], np.float32)
    rng = np.random.default_rng(5)
    fibras = ndimage.gaussian_filter(rng.normal(0, 1, (h, w)), (0.6, 3.0)) * 5
    salida = papel[None, None] * (1 - tinta[..., None]) + color[None, None] * tinta[..., None] + fibras[..., None]
    im = Image.fromarray(np.clip(salida, 0, 255).astype(np.uint8))
    d = ImageDraw.Draw(im, 'RGBA')
    # la caja tiembla: trazos cortos a su alrededor, como en un manga
    cx, cy = 928 * sx, 420 * sy
    for i in range(14):
        ang = -2.6 + i * 0.4
        r0, r1 = 150 * sx * (1.05 + 0.05 * (i % 2)), 150 * sx * (1.22 + 0.05 * (i % 3))
        for k in range(2):
            a0 = ang + k * 0.06
            d.line([(cx + np.cos(a0) * r0, cy + np.sin(a0) * r0 * 0.95), (cx + np.cos(a0) * r1, cy + np.sin(a0) * r1 * 0.95)],
                   fill=(30, 30, 44, 200), width=2)
    # el borde del papel
    d.rectangle([4, 4, w - 5, h - 5], outline=(120, 100, 80, 160), width=2)
    im.save(os.path.join(CAPAS, 'secreto.webp'), quality=88, method=6)


def main():
    print('costado izquierdo sin borla…', flush=True)
    n, frente = quitar_borla_frente()
    print('  hueco', n, 'píxeles', flush=True)
    print('boceto de espaldas: m1 cerrado y sin borla…', flush=True)
    n = quitar_borla_detras(frente)
    print('  hueco', n, 'píxeles', flush=True)
    secreto()
    datos = {
        'cajones': CAJONES_DETRAS, 'panel': PANEL, 'hueco_ficha': HUECO_FICHA, 'borla': BORLA,
        'nota': 'Cajones y panel: píxeles del boceto de espaldas, [x0, y0, x1, y1] (esquina de arriba a la izquierda y de '
                'abajo a la derecha). Borla: píxeles del repintado del costado izquierdo (capas/cara_izquierda.webp, '
                '1024 × 1024); de «corte» abajo la dibuja juego.js.',
    }
    with open(os.path.join(CAPAS, 'nivel5.json'), 'w', encoding='utf-8') as f:
        json.dump(datos, f, ensure_ascii=False, indent=1)
    print('listo')


if __name__ == '__main__':
    main()
