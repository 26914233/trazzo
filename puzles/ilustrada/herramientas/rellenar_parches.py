"""Rellena un hueco de una pintura con trozos de la misma pintura (sin IA ni descargas).

Es la idea de PatchMatch (Barnes y otros, 2009) con el «voto» de Wexler y otros (2007), en varias escalas: para cada
parche que toca el hueco se busca el parche más parecido de la parte conocida, y cada píxel del hueco se rehace con lo
que dicen los parches que lo cubren. Va bien con texturas regulares como el mosaico yosegi de los costados de la caja
(nivel 5: quitar la borla pintada para dibujarla por código y poder desatarla).

Uso: from rellenar_parches import rellenar
     nueva = rellenar(imagen, hueco, fuente=None, radio=3)
  imagen: matriz H×W×3 (0-255); hueco: H×W booleano (True = rellenar); fuente: H×W booleano, de dónde se pueden copiar
  parches (por defecto, todo lo conocido).
"""
import numpy as np
from scipy import ndimage


def _reducir(imagen, hueco, fuente):
    """La mitad de tamaño: la media de cada 2×2; un píxel es hueco si lo es alguno de los cuatro."""
    h, w = imagen.shape[0] // 2 * 2, imagen.shape[1] // 2 * 2
    im = imagen[:h, :w].reshape(h // 2, 2, w // 2, 2, -1).mean(axis=(1, 3))
    hu = hueco[:h, :w].reshape(h // 2, 2, w // 2, 2).max(axis=(1, 3))
    fu = fuente[:h, :w].reshape(h // 2, 2, w // 2, 2).min(axis=(1, 3))
    return im, hu, fu


def _difundir(imagen, hueco, pasadas=300):
    """Un primer relleno suave (difusión desde el borde del hueco) para la escala más pequeña."""
    im = imagen.copy()
    conocido = ~hueco
    im[hueco] = imagen[conocido].mean(axis=0)
    for _ in range(pasadas):
        suave = ndimage.uniform_filter(im, size=(3, 3, 1), mode='nearest')
        im[hueco] = suave[hueco]
    return im


def _por_capas(imagen, hueco, fuente, r=3, rng=None):
    """Relleno de partida para la escala más pequeña: del borde hacia dentro, parche a parche (como Criminisi y otros,
    2004). Cada vez se elige el sitio del borde que más sabe de su alrededor y se le copia el parche de la fuente que
    mejor encaja con lo conocido. Así el hueco empieza con el dibujo de verdad, no liso."""
    rng = rng or np.random.default_rng(0)
    im = imagen.copy()
    h, w = hueco.shape
    falta = hueco.copy()
    dentro = np.zeros((h, w), bool)
    dentro[r:h - r, r:w - r] = True
    valido = ~ndimage.binary_dilation(hueco, iterations=r) & dentro & ndimage.binary_erosion(fuente, iterations=r)
    if valido.sum() < 50:
        valido = ~ndimage.binary_dilation(hueco, iterations=r) & dentro
    vy, vx = np.nonzero(valido)
    dy, dx = np.mgrid[-r:r + 1, -r:r + 1]
    dy, dx = dy.ravel(), dx.ravel()
    fuentes = im[vy[:, None] + dy[None], vx[:, None] + dx[None]]            # N × P × 3
    lado = 2 * r + 1
    while falta.any():
        conocido = (~falta).astype(np.float32)
        borde = falta & ndimage.binary_dilation(~falta)
        cuenta = ndimage.uniform_filter(conocido, size=lado, mode='constant')
        cuenta[~borde] = -1
        cuenta[~dentro] = -1
        if cuenta.max() < 0:                      # (lo que quede junto al borde de la imagen: difusión)
            im = _difundir(im, falta, pasadas=60)
            break
        py, px = np.unravel_index(np.argmax(cuenta), cuenta.shape)
        ys, xs = py + dy, px + dx
        sabe = ~falta[ys, xs]
        objetivo = im[ys, xs]
        dif = fuentes[:, sabe, :] - objetivo[None, sabe, :]
        d = (dif * dif).sum(axis=(1, 2))
        # uno de los tres mejores, para que no se repita siempre el mismo parche
        mejores = np.argpartition(d, min(3, len(d) - 1))[:3]
        i = mejores[rng.integers(0, len(mejores))]
        poner = ~sabe
        im[ys[poner], xs[poner]] = fuentes[i, poner]
        falta[ys[poner], xs[poner]] = False
    return im


def _distancias(im, ty, tx, sy, sx, desplazamientos, confianza=None):
    """Lo distinto que es cada parche de destino de su parche fuente. Con «confianza», cada píxel del destino cuenta
    según lo que nos fiamos de él (en la primera escala, lo del hueco aún no vale nada: así no se buscan parches lisos)."""
    d = np.zeros(len(ty), np.float32)
    for dy, dx in desplazamientos:
        dif = im[ty + dy, tx + dx] - im[sy + dy, sx + dx]
        e = (dif * dif).sum(axis=1)
        d += e if confianza is None else e * confianza[ty + dy, tx + dx]
    return d


def _escala(im, hueco, fuente, radio, nnf_y, nnf_x, iteraciones, rng, final, primera=False, promediar=False):
    """Una escala: varias vueltas de buscar parches (PatchMatch) y rehacer el hueco (voto)."""
    h, w = hueco.shape
    r = radio
    dentro = np.zeros((h, w), bool)
    dentro[r:h - r, r:w - r] = True
    # centros de parche que tocan el hueco (los que hay que emparejar) y centros válidos de donde copiar
    objetivo = ndimage.binary_dilation(hueco, iterations=r) & dentro
    valido = ~ndimage.binary_dilation(hueco, iterations=r) & dentro & ndimage.binary_erosion(fuente, iterations=r)
    if valido.sum() < 50:            # (en una escala muy pequeña, la fuente puede quedarse sin sitio: vale todo lo conocido)
        valido = ~ndimage.binary_dilation(hueco, iterations=r) & dentro
    vy, vx = np.nonzero(valido)
    if len(vy) == 0:
        raise ValueError('no hay de dónde copiar parches')
    ty, tx = np.nonzero(objetivo)
    n = len(ty)
    desplazamientos = [(dy, dx) for dy in range(-r, r + 1) for dx in range(-r, r + 1)]

    def aleatorios(k):
        i = rng.integers(0, len(vy), k)
        return vy[i].copy(), vx[i].copy()

    # el emparejamiento de partida: el de la escala anterior (si sirve) o al azar
    sy, sx = nnf_y[ty, tx].copy(), nnf_x[ty, tx].copy()
    malos = (sy < 0) | ~valido[np.clip(sy, 0, h - 1), np.clip(sx, 0, w - 1)]
    sy[malos], sx[malos] = aleatorios(malos.sum())
    # en la primera escala, el hueco empieza liso: al principio no cuenta al comparar (si no, se buscan parches lisos)
    confianza = None
    rejilla_y = np.full((h, w), -1, np.int32)
    rejilla_x = np.full((h, w), -1, np.int32)

    def probar(cy, cx):
        nonlocal sy, sx, mejor
        cy = np.clip(cy, 0, h - 1)
        cx = np.clip(cx, 0, w - 1)
        ok = valido[cy, cx]
        if not ok.any():
            return
        idx = np.nonzero(ok)[0]
        d = _distancias(im, ty[idx], tx[idx], cy[idx], cx[idx], desplazamientos, confianza)
        gana = d < mejor[idx]
        g = idx[gana]
        sy[g], sx[g], mejor[g] = cy[idx][gana], cx[idx][gana], d[gana]

    for vuelta in range(iteraciones):
        if primera and vuelta < 3:
            confianza = np.ones((h, w), np.float32)
            confianza[hueco] = (0.0, 0.2, 0.6)[vuelta]
        else:
            confianza = None
        mejor = _distancias(im, ty, tx, sy, sx, desplazamientos, confianza)
        for _ in range(2):
            # propagar: el vecino ya tiene un buen parche; el mío es probablemente el de al lado del suyo
            rejilla_y[ty, tx], rejilla_x[ty, tx] = sy, sx
            for dy, dx in ((0, 1), (0, -1), (1, 0), (-1, 0)):
                ny, nx = np.clip(ty + dy, 0, h - 1), np.clip(tx + dx, 0, w - 1)
                cy, cx = rejilla_y[ny, nx], rejilla_x[ny, nx]
                tiene = cy >= 0
                probar(np.where(tiene, cy - dy, -1), np.where(tiene, cx - dx, -1))
            # buscar al azar alrededor del mejor, cada vez más cerca
            radio_busqueda = max(h, w)
            while radio_busqueda >= 1:
                probar(sy + rng.integers(-radio_busqueda, radio_busqueda + 1, n),
                       sx + rng.integers(-radio_busqueda, radio_busqueda + 1, n))
                radio_busqueda //= 2
            # y unos cuantos al azar de cualquier sitio (para no quedarse en un mínimo local)
            probar(*aleatorios(n))
        # votar: cada píxel del hueco, la media de lo que proponen los parches que lo cubren, pesada por lo bien que
        # encaja cada parche. En la última vuelta de la escala fina no se promedia: cada píxel toma lo que dice el parche
        # que mejor encaja de los que lo cubren (si no, el dibujo se emborrona)
        sigma2 = np.percentile(mejor, 25) + 1e-3
        peso = np.exp(-mejor / (2 * sigma2)).astype(np.float32) + 1e-6
        if not promediar or (final and vuelta == iteraciones - 1):
            mejor_peso = np.zeros((h, w), np.float32)
            nuevo = im.copy()
            for dy, dx in desplazamientos:
                py, px = ty + dy, tx + dx
                gana = peso > mejor_peso[py, px]           # (en un mismo desplazamiento no se repite ningún píxel)
                mejor_peso[py[gana], px[gana]] = peso[gana]
                nuevo[py[gana], px[gana]] = im[sy[gana] + dy, sx[gana] + dx]
            im[hueco] = nuevo[hueco]
            continue
        suma = np.zeros_like(im)
        pesos = np.zeros((h, w), np.float32)
        for dy, dx in desplazamientos:
            py, px = ty + dy, tx + dx
            np.add.at(suma, (py, px), im[sy + dy, sx + dx] * peso[:, None])
            np.add.at(pesos, (py, px), peso)
        cubierto = hueco & (pesos > 0)
        im[cubierto] = suma[cubierto] / pesos[cubierto][:, None]
    nnf_y[:], nnf_x[:] = -1, -1
    nnf_y[ty, tx], nnf_x[ty, tx] = sy, sx
    return im


def rellenar(imagen, hueco, fuente=None, radio=3, iteraciones=(8, 7, 6, 5, 4, 4), semilla=1):
    imagen = np.asarray(imagen, np.float32)
    hueco = np.asarray(hueco, bool)
    fuente = ~hueco if fuente is None else (np.asarray(fuente, bool) & ~hueco)
    rng = np.random.default_rng(semilla)
    # la pirámide: hasta que el hueco sea de pocos píxeles de ancho
    piramide = [(imagen, hueco, fuente)]
    while min(piramide[-1][1].shape) >= 160 and len(piramide) < 4:
        grosor = ndimage.distance_transform_edt(piramide[-1][1]).max()
        if grosor <= 3:
            break
        piramide.append(_reducir(*piramide[-1]))
    im = _por_capas(piramide[-1][0], piramide[-1][1], piramide[-1][2], r=3, rng=rng)
    nnf_y = np.full(piramide[-1][1].shape, -1, np.int32)
    nnf_x = np.full(piramide[-1][1].shape, -1, np.int32)
    for nivel in range(len(piramide) - 1, -1, -1):
        base, hu, fu = piramide[nivel]
        if nivel != len(piramide) - 1:
            # de la escala anterior: la imagen (ampliada) dentro del hueco y el emparejamiento (×2)
            h, w = hu.shape
            ampliada = np.repeat(np.repeat(im, 2, axis=0), 2, axis=1)
            ampliada = np.pad(ampliada, ((0, max(0, h - ampliada.shape[0])), (0, max(0, w - ampliada.shape[1])), (0, 0)), mode='edge')[:h, :w]
            nueva = base.copy()
            nueva[hu] = ampliada[hu]
            im = nueva
            ny = np.repeat(np.repeat(nnf_y, 2, axis=0), 2, axis=1)
            nx = np.repeat(np.repeat(nnf_x, 2, axis=1), 2, axis=0)
            ny = np.pad(ny, ((0, max(0, h - ny.shape[0])), (0, max(0, w - ny.shape[1]))), constant_values=-1)[:h, :w]
            nx = np.pad(nx, ((0, max(0, h - nx.shape[0])), (0, max(0, w - nx.shape[1]))), constant_values=-1)[:h, :w]
            yy, xx = np.mgrid[0:h, 0:w]
            nnf_y = np.where(ny >= 0, ny * 2 + yy % 2, -1).astype(np.int32)
            nnf_x = np.where(nx >= 0, nx * 2 + xx % 2, -1).astype(np.int32)
        else:
            im = im.copy()
        vueltas = iteraciones[min(len(iteraciones) - 1, len(piramide) - 1 - nivel)]
        # (en las escalas pequeñas, parches más pequeños: si no, el parche es más grande que lo que se ve del dibujo)
        r = radio if nivel == 0 else min(radio, 3)
        im = _escala(im, hu, fu, r, nnf_y, nnf_x, vueltas, rng, final=nivel == 0)
    return np.clip(im, 0, 255)
