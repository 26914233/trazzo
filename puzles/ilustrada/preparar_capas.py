#!/usr/bin/env python3
"""Capas de la prueba ilustrada de la caja viva (DECISIÓN 29).

Recorta de las ilustraciones de `fuentes/` (Gemini, todas con el mismo encuadre) las piezas que se
mueven y los parches de cada estado, y las deja en `pagina/capas/` con su posición en `capas.json`.
También pasa a 22 kHz los sonidos del juego de Godot que usa la página (`pagina/sonidos/`).

    python3 puzles/ilustrada/preparar_capas.py

Coordenadas: píxeles de la ilustración (1376 × 768). Las formas se trazaron a mano sobre ampliaciones.
"""
import json
import os
import wave

import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage, signal

AQUI = os.path.dirname(os.path.abspath(__file__))
FUENTES = os.path.join(AQUI, 'fuentes')
CAPAS = os.path.join(AQUI, 'pagina', 'capas')
SONIDOS = os.path.join(AQUI, 'pagina', 'sonidos')
SONIDOS_GODOT = os.path.join(AQUI, '..', 'godot', 'recursos', 'sonidos')
ANCHO, ALTO = 1376, 768

# Sonidos del juego de Godot (generar_sonidos.py) que usa la página
LISTA_SONIDOS = ['noche', 'fuego', 'trabado', 'recoger', 'encajar', 'despertar', 'final_caja_viva',
                 'suspiro', 'ojo_abre', 'grunido', 'espiritu', 'papel', 'llave', 'candado_abre',
                 'tope_madera', 'clic_madera', 'acercar', 'pista', 'toque', 'mecanismo', 'racha', 'bisagra']


# --- Utilidades ---------------------------------------------------------------------------------

def cargar(nombre):
    return np.asarray(Image.open(os.path.join(FUENTES, nombre)).convert('RGB')).astype(np.float32)


def poligono(puntos, sobre=4):
    """Máscara 0..1 de un polígono, con el borde suavizado por sobremuestreo."""
    m = Image.new('L', (ANCHO * sobre, ALTO * sobre), 0)
    ImageDraw.Draw(m).polygon([(x * sobre, y * sobre) for x, y in puntos], fill=255)
    return np.asarray(m.resize((ANCHO, ALTO), Image.LANCZOS)).astype(np.float32) / 255.0


def elipse(cx, cy, rx, ry, sobre=4):
    m = Image.new('L', (ANCHO * sobre, ALTO * sobre), 0)
    ImageDraw.Draw(m).ellipse([(cx - rx) * sobre, (cy - ry) * sobre, (cx + rx) * sobre, (cy + ry) * sobre],
                              fill=255)
    return np.asarray(m.resize((ANCHO, ALTO), Image.LANCZOS)).astype(np.float32) / 255.0


def rectangulo(x0, y0, x1, y1):
    m = np.zeros((ALTO, ANCHO), np.float32)
    m[y0:y1, x0:x1] = 1.0
    return m


def suave(m, radio):
    return ndimage.gaussian_filter(m, radio) if radio > 0 else m


def crecer(m, px):
    return ndimage.grey_dilation(m, size=(2 * px + 1, 2 * px + 1))


def diferencia(a, b, desenfoque=1.0):
    return ndimage.gaussian_filter(np.abs(a - b).mean(2), desenfoque)


def rellenar(img, zona, iteraciones=2500):
    """Rellena la zona resolviendo la ecuación de Laplace desde su borde (sin costuras)."""
    salida = img.copy()
    ys, xs = np.where(zona)
    y0, y1 = max(ys.min() - 2, 0), min(ys.max() + 3, img.shape[0])
    x0, x1 = max(xs.min() - 2, 0), min(xs.max() + 3, img.shape[1])
    trozo = salida[y0:y1, x0:x1].copy()
    m = zona[y0:y1, x0:x1]
    trozo[m] = trozo[ndimage.binary_dilation(m) & ~m].mean(0)
    for _ in range(iteraciones):
        trozo[m] = ((np.roll(trozo, 1, 0) + np.roll(trozo, -1, 0) + np.roll(trozo, 1, 1) + np.roll(trozo, -1, 1)) / 4)[m]
    salida[y0:y1, x0:x1] = trozo
    return salida


def textura(img, zona, fuerza=2.5, semilla=1):
    """Un grano suave de papel, para que el relleno no quede liso."""
    ruido = ndimage.gaussian_filter(np.random.default_rng(semilla).normal(0, 1, img.shape[:2]), 1.0)
    salida = img.copy()
    salida[zona] += (ruido / ruido.std() * fuerza)[..., None][zona]
    return salida


def _sin_motas(m, minimo):
    """Quita las manchas sueltas de menos de «minimo» píxeles."""
    etiquetas, n = ndimage.label(m)
    if n == 0:
        return m
    tamanos = ndimage.sum(m, etiquetas, range(1, n + 1))
    return np.isin(etiquetas, [i + 1 for i, t in enumerate(tamanos) if t >= minimo])


def sin_rojo(img, m, oscuro=58):
    """Quita de una silueta lo que es bermellón o ceniza encendida (el cajón, las brasas), salvo la
    tinta, y las manchas que queden sueltas."""
    rojizo = (img[..., 0] - img[..., 2] > 80) & (img[..., 1] / (img[..., 0] + 1) < 0.66) & (img.mean(2) >= oscuro)
    m = m & ~rojizo
    etiquetas, n = ndimage.label(m)
    if n > 1:
        m = etiquetas == (np.argmax(ndimage.sum(m, etiquetas, range(1, n + 1))) + 1)
    return m


def igualar_tono(img, ref, zona):
    """Las ediciones de Gemini salen un poco más oscuras: se igualan con la ilustración base en las
    partes que no cambian (por canal)."""
    sin_cambio = (diferencia(img, ref) < 10) & (zona > 0)
    if sin_cambio.sum() < 200:
        return img
    ganancia = ref[sin_cambio].mean(0) / (img[sin_cambio].mean(0) + 1e-6)
    return img * ganancia


capas = {}


def guardar(nombre, img, alfa, caja=None, calidad=90, sin_perdida=False):
    """Guarda la parte con alfa > 0 (o la caja dada) como WebP y anota su posición."""
    if caja is None:
        ys, xs = np.where(alfa > 0.004)
        caja = (int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1)
    x0, y0, x1, y1 = caja
    rgb = np.clip(img[y0:y1, x0:x1], 0, 255).astype(np.uint8)
    a = np.clip(alfa[y0:y1, x0:x1] * 255 + 0.5, 0, 255).astype(np.uint8)
    imagen = Image.fromarray(np.dstack([rgb, a]), 'RGBA')
    ruta = os.path.join(CAPAS, nombre + '.webp')
    if sin_perdida:
        imagen.save(ruta, 'WEBP', lossless=True, quality=100, method=6)
    else:
        imagen.save(ruta, 'WEBP', quality=calidad, alpha_quality=95, method=6)
    capas[nombre] = {'x': x0, 'y': y0, 'w': x1 - x0, 'h': y1 - y0}
    print(f'  {nombre}.webp  {x1 - x0}x{y1 - y0} en ({x0},{y0})  {os.path.getsize(ruta) // 1024} KB')


# --- Formas trazadas a mano ---------------------------------------------------------------------

# Tapa del incensario con el león (sala.jpg)
TAPA = [(560, 438.5), (554, 443), (551, 450), (550, 464), (548, 476), (544, 486), (530, 494), (522, 500),
        (520, 507), (524, 512), (532, 515), (550, 517.5), (580, 518.5), (606, 516.5), (622, 512), (630, 506),
        (629, 498), (621, 491), (612, 487), (606, 484), (608, 474), (607, 466), (603, 457), (599, 452),
        (596, 455), (594, 462), (589, 461), (584, 459), (581, 450), (578, 443), (572, 439), (566, 437.5)]

# Primera fila de la boca del incensario abierto (por encima, la pared que tapaba la tapa)
BOCA_Y = 489

# Franja donde está la llave, en el cajón de abajo
FRANJA_LLAVE = [(1043, 511), (1043, 497), (1066, 493), (1099, 468), (1115, 473), (1113, 493), (1080, 503),
                (1074, 512)]

# Cuerno de la frente ya puesto (despierta.jpg) y el hueco de la ilustración base
CUERNO = [(905, 237.5), (901.7, 243.3), (898.3, 251.7), (895.8, 260), (894.7, 270), (894.2, 280), (894.7, 291.7),
          (895.8, 300), (898.3, 306.7), (903.3, 310), (910, 310.8), (918.3, 309.2), (925, 305), (929.2, 298.3),
          (930, 291.7), (928.3, 285), (923.3, 276.7), (917.5, 268.3), (912.5, 258.3), (908.3, 246.7)]
HUECO = (912, 295.5, 23, 21)

# Cuerno que Gemini añadió de más a la izquierda al despertar: se queda la ilustración base
CUERNO_DE_MAS = [(736, 228), (806, 228), (808, 318), (734, 318)]

# Ojo abierto: el hueco entre los párpados (almendra) y el iris
ALMENDRA = [(754, 363.5), (760, 361.5), (767, 360.5), (775, 360.5), (783, 361), (791, 362.5), (799, 365),
            (806, 369), (812, 375), (817, 381), (811, 380.5), (803, 380), (795, 379.5), (787, 379), (779, 378.5),
            (772, 377), (766, 374.5), (761, 371), (757, 367)]
IRIS = (784.5, 369.0, 11.2)

# Silueta de la caja con su peana y sus cajones (lo que respira)
CAJA = [(688, 205), (782, 170), (1150, 178), (1158, 200), (1188, 213), (1192, 300), (1205, 430), (1205, 525),
        (1178, 545), (1172, 590), (1050, 672), (1000, 688), (905, 668), (660, 612), (655, 585), (690, 548)]

# Regiones del despertar, para que aparezca por partes
REGION_OJOS = [(640, 322), (1075, 322), (1075, 418), (640, 418)]
REGION_TRAMPILLA = [(735, 0), (1160, 0), (1160, 214), (1000, 222), (860, 222), (735, 214)]


def principal():
    os.makedirs(CAPAS, exist_ok=True)
    os.makedirs(SONIDOS, exist_ok=True)
    sala = cargar('sala.jpg')
    sin_llave = cargar('sala_sin_llave.jpg')
    abierto = cargar('incensario_abierto.jpg')
    vacio = cargar('incensario_vacio.jpg')
    despierta = cargar('despierta.jpg')

    print('Capas:')
    # 1. La sala entera (fondo)
    Image.fromarray(sala.astype(np.uint8)).save(os.path.join(CAPAS, 'sala.webp'), 'WEBP', quality=92, method=6)
    capas['sala'] = {'x': 0, 'y': 0, 'w': ANCHO, 'h': ALTO}
    print(f"  sala.webp  {os.path.getsize(os.path.join(CAPAS, 'sala.webp')) // 1024} KB")

    # 2. Tapa del incensario con el león: silueta = lo que cambia al abrirlo, dentro del trazo
    tapa_pol = poligono(TAPA)
    tapa = (diferencia(sala, abierto, 0.8) > 18) & (tapa_pol > 0.5)
    tapa = ndimage.binary_fill_holes(ndimage.binary_closing(tapa, iterations=2))
    etiquetas, n = ndimage.label(tapa)
    tapa = etiquetas == (np.argmax(ndimage.sum(tapa, etiquetas, range(1, n + 1))) + 1)
    tapa = ndimage.binary_erosion(ndimage.binary_fill_holes(tapa), iterations=1)
    alfa_tapa = np.clip(np.minimum(suave(tapa.astype(np.float32), 0.6) * 1.2, tapa_pol), 0, 1)
    guardar('tapa', sala, alfa_tapa)

    # 3. Incensario abierto (con el cuerno y sin él). Gemini pintó una columna de humo donde estaba la
    # tapa: por encima del borde de la boca se rellena con la pared de la sala, porque el humo lo
    # anima la página. Después, lo que cambia (el brillo de las brasas en el bronce y en la mesa).
    zona_inc = poligono([(495, 430), (660, 430), (660, 705), (495, 705)])
    abierto = igualar_tono(abierto, sala, zona_inc)
    vacio = igualar_tono(vacio, sala, zona_inc)

    # Cuerno entre las brasas: lo que cambia entre el incensario con cuerno y sin él
    # (sin la ceniza naranja que rodea su base: el marfil y la tinta tienen poco rojo de más)
    rojo_de_mas = abierto[..., 0] - abierto[..., 2]
    marfil_o_tinta = (rojo_de_mas < 75) | (abierto.mean(2) < 70)
    cuerno_brasas = (diferencia(abierto, vacio, 0.7) > 22) & (rectangulo(570, 448, 616, 516) > 0) & marfil_o_tinta
    cuerno_brasas = ndimage.binary_fill_holes(ndimage.binary_closing(cuerno_brasas, iterations=2))
    etiquetas, n = ndimage.label(cuerno_brasas)
    cuerno_brasas = etiquetas == (np.argmax(ndimage.sum(cuerno_brasas, etiquetas, range(1, n + 1))) + 1)

    hueco_tapa = crecer(tapa_pol, 3) > 0.5
    sobre_boca = hueco_tapa.copy()
    sobre_boca[BOCA_Y:] = False
    for img, quitar_cuerno in ((abierto, False), (vacio, True)):
        mezcla = sala.copy()
        mezcla[hueco_tapa] = img[hueco_tapa]
        rellenar_zona = sobre_boca.copy()
        if not quitar_cuerno:
            rellenar_zona &= ~ndimage.binary_dilation(cuerno_brasas, iterations=1)
        relleno = rellenar(mezcla, rellenar_zona)
        img[rellenar_zona] = textura(relleno, rellenar_zona)[rellenar_zona]
    cambio = np.maximum(diferencia(sala, abierto, 1.5), diferencia(sala, vacio, 1.5))
    cambio_limpio = _sin_motas((cambio > 9) & (zona_inc > 0.5), 60)
    alfa_inc = np.maximum(suave(crecer(cambio_limpio.astype(np.float32), 5), 4.0), suave(hueco_tapa.astype(np.float32), 1.0))
    alfa_inc = np.clip(alfa_inc * 1.15, 0, 1) * zona_inc
    guardar('incensario_abierto', abierto, alfa_inc)
    caja = capas['incensario_abierto']
    guardar('incensario_vacio', vacio, alfa_inc, caja=(caja['x'], caja['y'], caja['x'] + caja['w'], caja['y'] + caja['h']))
    guardar('cuerno_brasas', abierto, np.clip(suave(sin_rojo(abierto, cuerno_brasas).astype(np.float32), 0.5) * 1.2, 0, 1))

    # 5. Llave de bambú (color oliva frente al bermellón del cajón) y el cajón vacío
    rojo, verde = sala[..., 0], sala[..., 1]
    oliva = (verde / (rojo + 1) > 0.6) & (rojo > 40) & (poligono(FRANJA_LLAVE) > 0.5)
    llave = ndimage.binary_closing(oliva, iterations=1) & (poligono(FRANJA_LLAVE) > 0.5)
    etiquetas, n = ndimage.label(llave)
    tamanos = ndimage.sum(llave, etiquetas, range(1, n + 1))
    llave = np.isin(etiquetas, [i + 1 for i, t in enumerate(tamanos) if t > 25 or t == tamanos.max()])
    # más su contorno de tinta (lo oscuro que la toca), sin el bermellón del cajón
    oscuro = sala.mean(2) < 58
    llave = llave | (ndimage.binary_dilation(llave, iterations=1) & oscuro)
    guardar('llave', sala, np.clip(suave(llave.astype(np.float32), 0.5) * 1.3, 0, 1))
    zona_cajon = poligono([(1020, 455), (1125, 455), (1125, 520), (1020, 520)])
    sin_llave = igualar_tono(sin_llave, sala, zona_cajon)
    alfa_cajon = suave(crecer(llave.astype(np.float32), 6), 2.5) * zona_cajon
    guardar('cajon_vacio', sin_llave, np.clip(alfa_cajon * 1.2, 0, 1))

    # 6. Cuerno de la frente: suelto (para llevarlo) y puesto (parche que tapa el hueco)
    zona_cuerno = poligono([(880, 225), (945, 225), (945, 325), (880, 325)])
    despierta_t = igualar_tono(despierta, sala, poligono([(600, 420), (1250, 420), (1250, 720), (600, 720)]))
    cuerno = poligono(CUERNO)
    guardar('cuerno', despierta_t, np.clip(suave(crecer(cuerno, 1), 0.5), 0, 1))
    alfa_puesto = np.maximum(crecer(cuerno, 2), elipse(*HUECO))
    guardar('cuerno_puesto', despierta_t, np.clip(suave(alfa_puesto, 1.5) * 1.25, 0, 1) * zona_cuerno)

    # 7. El despertar, por partes: ojos, trampilla con su luz y humo. Solo lo que cambia.
    cambio = _sin_motas(diferencia(sala, despierta_t, 1.5) > 14, 150)
    alfa_desp = suave(crecer(cambio.astype(np.float32), 4), 4.0)
    alfa_desp = np.clip(alfa_desp * 1.3, 0, 1)
    fuera = np.maximum(suave(poligono(CUERNO_DE_MAS), 3.0), suave(crecer(alfa_puesto, 3), 2.0))
    alfa_desp *= 1 - np.clip(fuera * 1.2, 0, 1)
    ojos = suave(poligono(REGION_OJOS), 8.0)
    trampilla = suave(poligono(REGION_TRAMPILLA), 8.0) * (1 - ojos)
    humo = np.clip(1 - ojos - trampilla, 0, 1)
    guardar('despierta_ojos', despierta_t, alfa_desp * ojos)
    guardar('despierta_trampilla', despierta_t, alfa_desp * trampilla)
    guardar('despierta_humo', despierta_t, alfa_desp * humo)

    # 8. El ojo: la almendra sin iris (se rellena fila a fila entre los lados) y el iris suelto
    almendra = poligono(ALMENDRA)
    cx, cy, r = IRIS
    ojo = sala.copy()
    izquierda, derecha = int(cx - r - 2.5), int(cx + r + 2.5)
    for y in range(352, 392):
        fila = almendra[y]
        if fila.max() < 0.5:
            continue
        a, b = sala[y, izquierda - 1:izquierda + 1].mean(0), sala[y, derecha:derecha + 2].mean(0)
        for x in range(izquierda, derecha + 1):
            t = (x - izquierda) / (derecha - izquierda)
            ojo[y, x] = a * (1 - t) + b * t
    ruido = ndimage.gaussian_filter(np.random.default_rng(7).normal(0, 1, (ALTO, ANCHO)), 0.7)
    ojo += (ruido / ruido.std() * 4.0)[..., None] * (almendra[..., None] > 0.5)
    alfa_ojo = np.clip(suave(crecer(almendra, 1), 0.5) * 1.2, 0, 1)
    guardar('ojo_vacio', ojo, alfa_ojo, calidad=95)
    lado = int(np.ceil(r)) + 2
    yy, xx = np.mgrid[-lado:lado + 1, -lado:lado + 1]
    iris = np.zeros((2 * lado + 1, 2 * lado + 1, 3), np.float32)
    for j in range(2 * lado + 1):
        fila_origen = cy + abs(yy[j, 0])  # la mitad de abajo, reflejada arriba (la de arriba la tapa el párpado)
        for i in range(2 * lado + 1):
            iris[j, i] = _muestra(sala, cx + xx[j, i], fila_origen)
    distancia = np.hypot(xx, yy)
    alfa_iris = np.clip(r + 0.5 - distancia, 0, 1)
    imagen = Image.fromarray(np.dstack([np.clip(iris, 0, 255).astype(np.uint8),
                                        (alfa_iris * 255).astype(np.uint8)]), 'RGBA')
    imagen.save(os.path.join(CAPAS, 'iris.webp'), 'WEBP', lossless=True, quality=100, method=6)
    capas['iris'] = {'x': cx - lado, 'y': cy - lado, 'w': 2 * lado + 1, 'h': 2 * lado + 1, 'cx': cx, 'cy': cy, 'r': r}
    print(f'  iris.webp  {2 * lado + 1}px')

    # 9. Máscara de la caja para la respiración: blanca, con el borde difuminado hacia fuera
    alfa_caja = np.clip(suave(crecer(poligono(CAJA), 4), 5.0) * 1.1, 0, 1)
    guardar('caja_mascara', np.full((ALTO, ANCHO, 3), 255, np.float32), alfa_caja, calidad=80)

    # Formas que usa la página (párpado, almendra)
    datos = {'ancho': ANCHO, 'alto': ALTO, 'capas': capas, 'almendra': ALMENDRA, 'iris': IRIS}
    with open(os.path.join(CAPAS, 'capas.json'), 'w', encoding='utf-8') as f:
        json.dump(datos, f, ensure_ascii=False, indent=1)

    print('Sonidos (22 kHz):')
    for nombre in LISTA_SONIDOS:
        _sonido_22k(nombre)


def _muestra(img, x, y):
    """Lectura bilineal de un píxel."""
    x0, y0 = int(np.floor(x)), int(np.floor(y))
    fx, fy = x - x0, y - y0
    a = img[y0, x0] * (1 - fx) + img[y0, x0 + 1] * fx
    b = img[y0 + 1, x0] * (1 - fx) + img[y0 + 1, x0 + 1] * fx
    return a * (1 - fy) + b * fy


def _sonido_22k(nombre):
    with wave.open(os.path.join(SONIDOS_GODOT, nombre + '.wav')) as w:
        frecuencia, canales, ancho = w.getframerate(), w.getnchannels(), w.getsampwidth()
        datos = np.frombuffer(w.readframes(w.getnframes()), np.int16).astype(np.float32)
    if canales > 1:
        datos = datos.reshape(-1, canales).mean(1)
    if frecuencia == 44100:
        datos = signal.resample_poly(datos, 1, 2)
        frecuencia = 22050
    ruta = os.path.join(SONIDOS, nombre + '.wav')
    with wave.open(ruta, 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(frecuencia)
        w.writeframes(np.clip(datos, -32768, 32767).astype(np.int16).tobytes())
    print(f'  {nombre}.wav  {os.path.getsize(ruta) // 1024} KB')


if __name__ == '__main__':
    principal()
