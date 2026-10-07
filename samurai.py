# -*- coding: utf-8 -*-
"""
RONIN
=====
Juego 2D en Python + Pygame (un solo archivo).

Contenido
---------
* Introducción de la historia en texto.
* Capítulo 1 - El castillo de Hoshiyama: acción y plataformas con espada.
* Escena de cierre del capítulo.
* Salida del castillo a la planicie: mapa abierto con movimiento libre que
  une el castillo, la aldea, el templo, el dojo y las ruinas.

Controles
---------
Castillo:  A/D o flechas: moverse · W, flecha arriba o ESPACIO: saltar
           S o flecha abajo: bajar de una plataforma de madera · J: atacar
Planicie:  WASD o flechas: moverse · SHIFT: correr · E: entrar · M: mapa
Siempre:   ESC: pausa

Uso
---
    pip install pygame
    python samurai.py
    python samurai.py --planicie    (atajo de desarrollo: empieza en la planicie)
"""

import math
import random
import sys

import pygame


# =============================================================================
# CONFIGURACIÓN GENERAL
# =============================================================================

ANCHO, ALTO = 960, 540
FPS = 60
TITULO = "RONIN"
DURACION_FUNDIDO = 0.45
VELOCIDAD_TEXTO = 45          # caracteres por segundo en las escenas de texto
VIDA_MAXIMA = 5

TECLAS_CONFIRMAR = (pygame.K_RETURN, pygame.K_KP_ENTER, pygame.K_SPACE)
TECLAS_SALTO = (pygame.K_SPACE, pygame.K_w, pygame.K_UP)

# Colores generales
NEGRO = (0, 0, 0)
BLANCO = (255, 255, 255)
CREMA = (238, 228, 200)
GRIS = (160, 160, 176)
DORADO = (226, 186, 98)
DORADO_APAGADO = (170, 138, 70)
ROJO = (200, 50, 46)
ROJO_CLARO = (255, 146, 126)

# Personajes
PIEL = (228, 190, 152)
PELO = (20, 18, 24)
KIMONO = (52, 66, 118)
KIMONO_OSCURO = (36, 46, 86)
HAKAMA = (34, 36, 58)
HAKAMA_OSCURO = (22, 23, 40)
OBI = (160, 46, 42)
HACHIMAKI = (238, 238, 242)
ACERO = (226, 232, 244)
TSUKA = (206, 194, 164)
SAYA = (46, 24, 28)
ARMADURA = (126, 42, 36)
ARMADURA_CLARA = (160, 70, 58)
ARMADURA_OSCURA = (88, 30, 28)
PANTALON = (58, 56, 66)
PANTALON_OSCURO = (40, 38, 48)
SOMBRERO = (92, 74, 50)
MADERA_LANZA = (122, 88, 54)

# Noche en el castillo
CIELO_ARRIBA = (6, 8, 26)
CIELO_ABAJO = (42, 36, 76)
COLOR_LUNA = (248, 240, 210)
PIEDRA = (74, 76, 94)
PIEDRA_OSCURA = (38, 40, 52)
PIEDRA_CLARA = (108, 112, 132)
MADERA = (112, 72, 44)
MADERA_OSCURA = (70, 44, 28)
MADERA_CLARA = (146, 100, 62)
TEJA = (40, 44, 62)
TEJA_CLARA = (70, 76, 100)


# =============================================================================
# HISTORIA (textos)
# =============================================================================

TEXTO_INTRO = [
    "Castillo de Hoshiyama. Akira sirve como guardia del señor Takeda.",
    "Esta noche, el general Genzo, mano derecha de Takeda, lo ha asesinado. "
    "Para Genzo, su señor era demasiado blando para gobernar.",
    "Los soldados del castillo ya obedecen a Genzo. Akira debe abrirse paso "
    "hasta la puerta y escapar.",
]

TEXTO_CIERRE = [
    "Akira cruza la última puerta. El castillo de Hoshiyama queda a su espalda.",
    "Sin señor al que servir, desde esta noche es un ronin.",
    "Fuera buscará justicia. Dentro, intentará recuperar su honor.",
]

TEXTO_DERROTA = [
    "Levántate, Akira. La noche aún no ha terminado.",
]


# =============================================================================
# CAPÍTULO 1: DATOS DEL NIVEL
# =============================================================================

GRAVEDAD = 2200
VEL_CAIDA_MAX = 900
VEL_CAMINAR = 260
VEL_SALTO = 820
DURACION_ATAQUE = 0.28
ENFRIAMIENTO_ATAQUE = 0.36
ALCANCE_ESPADA = 54
ALCANCE_LANZA = 72
DISTANCIA_ATAQUE_SOLDADO = 92
VEL_PERSECUCION = 125

NIVEL_ANCHO = 4200
SUELO_Y = 470

# Bloques de piedra sólidos: (x, y, ancho, alto)
BLOQUES_PIEDRA = [
    (1000, 380, 80, 90),      # muro bajo
    (1900, 400, 70, 70),      # escalón
    (1970, 300, 480, 170),    # muralla con adarve
    (2450, 400, 60, 70),      # escalón
    (3380, 400, 60, 70),      # muro bajo
]
# Límites invisibles a izquierda y derecha del nivel
LIMITES_NIVEL = [
    (-200, -600, 200, 1400),
    (4120, -600, 300, 1400),
]
# Plataformas de madera: se atraviesan desde abajo
PLATAFORMAS_MADERA = [
    (1250, 380, 180, 14),
    (1480, 300, 220, 14),
    (2650, 370, 160, 14),
    (2900, 290, 180, 14),
    (3150, 370, 140, 14),
]
# Antorchas: (x, y de la base, altura del poste)
ANTORCHAS = [
    (320, SUELO_Y, 120), (820, SUELO_Y, 120),
    (1180, SUELO_Y, 120), (1780, SUELO_Y, 120),
    (2100, 300, 90), (2350, 300, 90),
    (2600, SUELO_Y, 120), (3110, SUELO_Y, 120),
    (3560, SUELO_Y, 120), (3940, SUELO_Y, 130),
]
# Soldados: (x del centro, y de los pies, límite izquierdo, límite derecho)
SOLDADOS = [
    (700, SUELO_Y, 480, 900),
    (1600, 300, 1540, 1680),      # deja libre el borde donde se aterriza
    (1640, SUELO_Y, 1180, 1860),
    (2210, 300, 2050, 2420),      # deja libre el borde donde se aterriza
    (2900, SUELO_Y, 2560, 3330),
    (3700, SUELO_Y, 3480, 3920),
]
PUERTA_FINAL = (3990, 300, 130, 170)


# =============================================================================
# PLANICIE: DATOS DEL MUNDO ABIERTO
# =============================================================================

MUNDO_ANCHO, MUNDO_ALTO = 3200, 2400
SEMILLA_MUNDO = 1603
BORDE_MUNDO = 64
RADIO_VIAJERO = 10
VEL_VIAJE = 175
VEL_CORRER = 285
ANCHO_RIO = 84
MITAD_RIO = ANCHO_RIO / 2
ANCHO_CAMINO = 34
ESTANQUE = (2960, 720, 84)          # (x, y, radio)
CELDA_OBSTACULOS = 128

PASTO = (104, 150, 74)
TONOS_PASTO = [(92, 140, 66), (118, 162, 82), (98, 146, 62), (126, 166, 86), (86, 130, 62)]
TIERRA = (190, 160, 110)
TIERRA_BORDE = (160, 130, 88)
ARENA = (204, 190, 140)
AGUA = (64, 118, 172)
AGUA_PROFUNDA = (52, 102, 158)
AGUA_BRILLO = (170, 210, 238)
GRAVA = (184, 176, 158)
GRAVA_CLARA = (210, 206, 192)

# Puerta del castillo en el mapa (punto de salida del capítulo 1)
PUERTA_CASTILLO = (560, 470)

# Lugares del mapa. "entrada" es donde se interactúa (tecla E); "centro" y
# "radio_libre" reservan espacio sin árboles; "radio_zona" activa el cartel.
LUGARES = [
    {"clave": "castillo", "nombre": "Castillo de Hoshiyama",
     "entrada": (560, 505), "centro": (560, 380), "radio_libre": 300,
     "radio_zona": 330, "color": (196, 60, 52),
     "mensaje": "Las puertas del castillo de Hoshiyama están cerradas. "
                "Todavía no es momento de volver."},
    {"clave": "aldea", "nombre": "Aldea",
     "entrada": (1750, 1080), "centro": (1750, 1060), "radio_libre": 330,
     "radio_zona": 320, "color": (214, 166, 92),
     "mensaje": "Próximamente: diálogos, misiones, tienda y descanso."},
    {"clave": "templo", "nombre": "Templo",
     "entrada": (2700, 470), "centro": (2700, 420), "radio_libre": 260,
     "radio_zona": 280, "color": (226, 88, 56),
     "mensaje": "Próximamente: puzzles y acertijos."},
    {"clave": "dojo", "nombre": "Dojo",
     "entrada": (620, 1915), "centro": (620, 1870), "radio_libre": 250,
     "radio_zona": 260, "color": (150, 104, 66),
     "mensaje": "Próximamente: mini juego de ritmo y reflejos para aprender técnicas."},
    {"clave": "ruinas", "nombre": "Ruinas",
     "entrada": (2620, 1880), "centro": (2620, 1900), "radio_libre": 270,
     "radio_zona": 280, "color": (156, 156, 156),
     "mensaje": "Próximamente: exploración y combate."},
]
RADIO_INTERACCION = 90

PUNTOS_RIO = [(1150, -60), (1180, 300), (1100, 600), (1220, 900), (1300, 1200),
              (1200, 1500), (1280, 1800), (1400, 2100), (1380, 2460)]

# Caminos: todos salen de la aldea, que queda en el centro del mapa
CAMINOS = [
    [(560, 490), (575, 640), (760, 800), (1000, 900), (1400, 1000), (1750, 1080)],
    [(1750, 1080), (2050, 900), (2350, 700), (2600, 640), (2700, 590), (2700, 470)],
    [(1750, 1080), (1500, 1350), (1100, 1650), (860, 1880), (700, 1930), (620, 1915)],
    [(1750, 1080), (2050, 1400), (2350, 1700), (2550, 1850), (2620, 1880)],
]

# Bosques: (x, y, radio, cantidad de árboles, tipo)
ZONAS_BOSQUE = [
    (1650, 280, 330, 70, "mixto"),
    (260, 1180, 300, 60, "pino"),
    (1950, 2080, 300, 60, "mixto"),
    (2980, 1300, 250, 45, "redondo"),
    (880, 1260, 200, 30, "redondo"),
    (2250, 330, 170, 22, "pino"),
    (300, 2150, 220, 30, "pino"),
    (3000, 2150, 200, 26, "mixto"),
]
SAKURAS = [(2530, 360), (2870, 360), (2560, 240), (2840, 240), (2450, 520),
           (2930, 540), (2700, 170)]


# =============================================================================
# UTILIDADES
# =============================================================================

def limitar(valor, minimo, maximo):
    """Recorta un valor al intervalo [minimo, maximo]."""
    return max(minimo, min(maximo, valor))


def interpolar(a, b, t):
    return a + (b - a) * t


def mezclar_color(color_a, color_b, t):
    return tuple(int(interpolar(a, b, t)) for a, b in zip(color_a, color_b))


def variar_color(color, azar, cantidad):
    return tuple(int(limitar(c + azar.randint(-cantidad, cantidad), 0, 255)) for c in color)


def variar_brillo(color, azar, cantidad):
    delta = azar.randint(-cantidad, cantidad)
    return tuple(int(limitar(c + delta, 0, 255)) for c in color)


def rectangulo(x, y, ancho, alto):
    """pygame.Rect a partir de valores con decimales."""
    return pygame.Rect(int(round(x)), int(round(y)), int(round(ancho)), int(round(alto)))


def degradado_vertical(ancho, alto, color_arriba, color_abajo):
    superficie = pygame.Surface((ancho, alto))
    for y in range(alto):
        color = mezclar_color(color_arriba, color_abajo, y / max(1, alto - 1))
        pygame.draw.line(superficie, color, (0, y), (ancho - 1, y))
    return superficie


def crear_brillo(radio, color):
    """Círculo difuso para luz aditiva (se dibuja con BLEND_RGB_ADD)."""
    superficie = pygame.Surface((radio * 2, radio * 2))
    for r in range(radio, 0, -2):
        t = (1 - r / radio) ** 1.8
        pygame.draw.circle(superficie, tuple(int(c * t) for c in color), (radio, radio), r)
    return superficie


def cargar_fuente(tamano, negrita=False):
    nombres = "georgia,palatinolinotype,bookantiqua,cambria,dejavuserif,liberationserif,freeserif"
    return pygame.font.SysFont(nombres, tamano, bold=negrita)


def dibujar_texto(superficie, texto, fuente, color, posicion, alineacion="izquierda",
                  sombra=True, alfa=255):
    """Dibuja texto con sombra. alineacion: 'izquierda', 'centro' o 'derecha'."""
    imagen = fuente.render(texto, True, color)
    rect = imagen.get_rect()
    ancla = {"izquierda": "topleft", "centro": "midtop", "derecha": "topright"}[alineacion]
    setattr(rect, ancla, (int(posicion[0]), int(posicion[1])))
    if sombra:
        imagen_sombra = fuente.render(texto, True, NEGRO)
        if alfa < 255:
            imagen_sombra.set_alpha(alfa)
        superficie.blit(imagen_sombra, rect.move(2, 2))
    if alfa < 255:
        imagen.set_alpha(alfa)
    superficie.blit(imagen, rect)
    return rect


def partir_en_lineas(texto, fuente, ancho_maximo):
    lineas, actual = [], ""
    for palabra in texto.split():
        prueba = palabra if not actual else actual + " " + palabra
        if fuente.size(prueba)[0] <= ancho_maximo:
            actual = prueba
        else:
            if actual:
                lineas.append(actual)
            actual = palabra
    if actual:
        lineas.append(actual)
    return lineas


def dibujar_panel(superficie, rect, alfa=210, borde=DORADO):
    panel = pygame.Surface(rect.size, pygame.SRCALPHA)
    panel.fill((10, 9, 16, alfa))
    superficie.blit(panel, rect.topleft)
    pygame.draw.rect(superficie, borde, rect, 2, border_radius=6)


def dibujar_vida(superficie, fuente, x, y, vida):
    """Nombre de Akira y sus puntos de vida (rombos rojos)."""
    rect = dibujar_texto(superficie, "AKIRA", fuente, CREMA, (x, y))
    for i in range(VIDA_MAXIMA):
        cx, cy = rect.right + 22 + i * 24, rect.centery
        puntos = [(cx, cy - 9), (cx + 8, cy), (cx, cy + 9), (cx - 8, cy)]
        if i < vida:
            pygame.draw.polygon(superficie, ROJO, puntos)
            pygame.draw.polygon(superficie, ROJO_CLARO, puntos, 2)
        else:
            pygame.draw.polygon(superficie, (46, 28, 32), puntos)
            pygame.draw.polygon(superficie, (110, 74, 78), puntos, 2)


def distancia_a_segmento(px, py, ax, ay, bx, by):
    dx, dy = bx - ax, by - ay
    largo2 = dx * dx + dy * dy
    if largo2 == 0:
        return math.hypot(px - ax, py - ay)
    t = limitar(((px - ax) * dx + (py - ay) * dy) / largo2, 0.0, 1.0)
    return math.hypot(px - (ax + t * dx), py - (ay + t * dy))


def distancia_a_polilinea(px, py, puntos):
    return min(distancia_a_segmento(px, py, *puntos[i], *puntos[i + 1])
               for i in range(len(puntos) - 1))


def suavizar(puntos, pasos=10):
    """Curva Catmull-Rom que pasa por todos los puntos de control."""
    extendidos = [puntos[0]] + list(puntos) + [puntos[-1]]
    resultado = []
    for i in range(1, len(extendidos) - 2):
        p0, p1, p2, p3 = extendidos[i - 1], extendidos[i], extendidos[i + 1], extendidos[i + 2]
        for paso in range(pasos):
            t = paso / pasos
            t2, t3 = t * t, t * t * t
            resultado.append(tuple(
                0.5 * (2 * p1[k] + (-p0[k] + p2[k]) * t
                       + (2 * p0[k] - 5 * p1[k] + 4 * p2[k] - p3[k]) * t2
                       + (-p0[k] + 3 * p1[k] - 3 * p2[k] + p3[k]) * t3)
                for k in (0, 1)))
    resultado.append(tuple(puntos[-1]))
    return resultado


def interseccion_segmentos(a, b, c, d):
    """Punto donde se cruzan los segmentos AB y CD, o None."""
    r = (b[0] - a[0], b[1] - a[1])
    s = (d[0] - c[0], d[1] - c[1])
    denominador = r[0] * s[1] - r[1] * s[0]
    if abs(denominador) < 1e-9:
        return None
    t = ((c[0] - a[0]) * s[1] - (c[1] - a[1]) * s[0]) / denominador
    u = ((c[0] - a[0]) * r[1] - (c[1] - a[1]) * r[0]) / denominador
    if 0 <= t <= 1 and 0 <= u <= 1:
        return (a[0] + t * r[0], a[1] + t * r[1])
    return None


def dibujar_franja(superficie, color, puntos, ancho):
    """Línea gruesa con uniones redondeadas (caminos y río)."""
    for i in range(len(puntos) - 1):
        pygame.draw.line(superficie, color, puntos[i], puntos[i + 1], ancho)
    for x, y in puntos:
        pygame.draw.circle(superficie, color, (int(x), int(y)), ancho // 2)


def dibujar_techo(superficie, color, cx, base_y, ancho, alto, vuelo=12, borde=None):
    """Tejado japonés visto de frente, con los aleros curvados hacia arriba."""
    mitad = ancho / 2
    puntos = [
        (cx - mitad - vuelo, base_y - vuelo * 0.7),
        (cx - mitad + vuelo * 0.6, base_y),
        (cx + mitad - vuelo * 0.6, base_y),
        (cx + mitad + vuelo, base_y - vuelo * 0.7),
        (cx + mitad * 0.52, base_y - alto),
        (cx - mitad * 0.52, base_y - alto),
    ]
    pygame.draw.polygon(superficie, color, puntos)
    if borde:
        pygame.draw.lines(superficie, borde, False, puntos[:4], 2)
        pygame.draw.line(superficie, borde, puntos[5], puntos[4], 2)


def dibujar_tenshu(superficie, cx, base_y, colores, escala=1.0):
    """Torre principal de un castillo japonés: base de piedra y tres pisos."""
    e = escala
    borde = colores.get("borde")
    pygame.draw.polygon(superficie, colores["piedra"], [
        (cx - 100 * e, base_y), (cx + 100 * e, base_y),
        (cx + 84 * e, base_y - 46 * e), (cx - 84 * e, base_y - 46 * e)])
    if "junta" in colores:
        for k in range(1, 5):
            y = base_y - k * 9 * e
            mitad = 100 * e - (base_y - y) * 16 / 46
            pygame.draw.line(superficie, colores["junta"], (cx - mitad, y), (cx + mitad, y))
    y = base_y - 46 * e
    pisos = [(150, 40, 196, 28), (116, 34, 156, 26), (84, 30, 122, 34)]
    for i, (ancho_muro, alto_muro, ancho_techo, alto_techo) in enumerate(pisos):
        pygame.draw.rect(superficie, colores["muro"],
                         rectangulo(cx - ancho_muro * e / 2, y - alto_muro * e,
                                    ancho_muro * e, alto_muro * e))
        ventanas = 4 - i
        for k in range(ventanas):
            vx = cx - ancho_muro * e / 2 + (k + 0.5) * ancho_muro * e / ventanas
            pygame.draw.rect(superficie, colores["ventana"],
                             rectangulo(vx - 5 * e, y - alto_muro * e * 0.66, 10 * e, 9 * e))
        y -= alto_muro * e
        dibujar_techo(superficie, colores["techo"], cx, y + 7 * e,
                      ancho_techo * e, alto_techo * e, 12 * e, borde)
        y -= (alto_techo - 9) * e
    adorno = colores.get("adorno", colores["techo"])
    for lado in (-1, 1):
        x = cx + lado * 30 * e
        pygame.draw.polygon(superficie, adorno, [(x, y + 2 * e), (x + lado * 7 * e, y - 8 * e),
                                                 (x + lado * 2 * e, y + 2 * e)])


# =============================================================================
# PARTÍCULAS
# =============================================================================

class Particula:
    """Chispas, polvo y destellos. Se encogen al terminar su vida."""

    def __init__(self, x, y, vel_x, vel_y, duracion, color, radio,
                 color_final=None, gravedad=0.0):
        self.x, self.y = x, y
        self.vel_x, self.vel_y = vel_x, vel_y
        self.duracion = self.restante = duracion
        self.color = color
        self.color_final = color_final
        self.radio = radio
        self.gravedad = gravedad

    def actualizar(self, dt):
        self.restante -= dt
        self.vel_y += self.gravedad * dt
        self.x += self.vel_x * dt
        self.y += self.vel_y * dt
        return self.restante > 0

    def dibujar(self, superficie, camara_x, camara_y=0):
        t = max(0.0, self.restante / self.duracion)
        color = mezclar_color(self.color_final, self.color, t) if self.color_final else self.color
        radio = max(1, int(self.radio * (0.4 + 0.6 * t)))
        pygame.draw.circle(superficie, color,
                           (int(self.x - camara_x), int(self.y - camara_y)), radio)


def lanzar_chispas(particulas, azar, x, y, cantidad, color, color_final, velocidad=260,
                   direccion=0, gravedad=500):
    for _ in range(cantidad):
        angulo = azar.uniform(-math.pi, math.pi)
        rapidez = azar.uniform(0.3, 1.0) * velocidad
        vel_x = math.cos(angulo) * rapidez + direccion * velocidad * 0.5
        vel_y = math.sin(angulo) * rapidez - velocidad * 0.25
        particulas.append(Particula(x, y, vel_x, vel_y, azar.uniform(0.25, 0.55), color,
                                    azar.uniform(1.5, 3.2), color_final, gravedad))


# =============================================================================
# MOTOR: JUEGO Y ESCENAS
# =============================================================================

class Escena:
    """Base de todas las escenas: intro, niveles, mapa..."""

    def __init__(self, juego):
        self.juego = juego

    def manejar_evento(self, evento):
        pass

    def actualizar(self, dt):
        pass

    def dibujar(self, pantalla):
        pass


class Juego:
    """Ventana, bucle principal, pausa y cambio de escenas con fundido a negro."""

    def __init__(self, escena_inicial="intro"):
        pygame.init()
        pygame.display.set_caption(TITULO)
        self.pantalla = pygame.display.set_mode((ANCHO, ALTO))
        self.reloj = pygame.time.Clock()
        self.fuente_titulo = cargar_fuente(60, negrita=True)
        self.fuente_grande = cargar_fuente(34, negrita=True)
        self.fuente = cargar_fuente(22)
        self.fuente_chica = cargar_fuente(17)
        self.velo = pygame.Surface((ANCHO, ALTO))
        self.velo.fill(NEGRO)
        self.corriendo = True
        self.pausado = False
        self.fabrica_siguiente = None
        self.estado_fundido = "entrando"
        self.fundido = 1.0
        if escena_inicial == "planicie":
            self.escena = EscenaPlanicie(self)
        else:
            self.escena = crear_intro(self)

    def cambiar_escena(self, fabrica):
        """Funde a negro y, con la pantalla en negro, crea la escena nueva.

        fabrica es una función sin argumentos que devuelve la escena.
        """
        if self.estado_fundido == "saliendo":
            return
        self.fabrica_siguiente = fabrica
        self.estado_fundido = "saliendo"

    def procesar_eventos(self):
        for evento in pygame.event.get():
            if evento.type == pygame.QUIT:
                self.corriendo = False
            elif self.estado_fundido == "saliendo":
                continue
            elif self.pausado:
                if evento.type == pygame.KEYDOWN:
                    if evento.key in (pygame.K_ESCAPE, pygame.K_RETURN, pygame.K_KP_ENTER):
                        self.pausado = False
                    elif evento.key == pygame.K_q:
                        self.corriendo = False
            elif evento.type == pygame.KEYDOWN and evento.key == pygame.K_ESCAPE:
                self.pausado = True
            else:
                self.escena.manejar_evento(evento)

    def actualizar(self, dt):
        if self.estado_fundido == "saliendo":
            self.fundido = min(1.0, self.fundido + dt / DURACION_FUNDIDO)
            if self.fundido >= 1.0:
                self.escena = self.fabrica_siguiente()
                self.fabrica_siguiente = None
                self.estado_fundido = "entrando"
            return
        if self.estado_fundido == "entrando":
            self.fundido = max(0.0, self.fundido - dt / DURACION_FUNDIDO)
            if self.fundido <= 0.0:
                self.estado_fundido = None
        if not self.pausado:
            self.escena.actualizar(dt)

    def dibujar(self):
        self.escena.dibujar(self.pantalla)
        if self.fundido > 0:
            self.velo.set_alpha(int(255 * self.fundido))
            self.pantalla.blit(self.velo, (0, 0))
        if self.pausado:
            self.velo.set_alpha(150)
            self.pantalla.blit(self.velo, (0, 0))
            dibujar_texto(self.pantalla, "PAUSA", self.fuente_titulo, DORADO,
                          (ANCHO // 2, ALTO // 2 - 80), "centro")
            dibujar_texto(self.pantalla, "ESC o ENTER: continuar      Q: salir del juego",
                          self.fuente, CREMA, (ANCHO // 2, ALTO // 2 + 10), "centro")

    def paso(self, dt):
        """Un cuadro completo: eventos, lógica y dibujo."""
        self.procesar_eventos()
        self.actualizar(dt)
        self.dibujar()

    def ejecutar(self):
        while self.corriendo:
            dt = min(self.reloj.tick(FPS) / 1000.0, 1 / 30)
            self.paso(dt)
            pygame.display.flip()
        pygame.quit()


# =============================================================================
# FONDO NOCTURNO (intro, cierre y capítulo 1)
# =============================================================================

class FondoNocturno:
    """Cielo con estrellas, luna y siluetas lejanas con paralaje."""

    FACTOR_LEJANO = 0.12

    def __init__(self, ancho_escenario=ANCHO, horizonte=ALTO, luna=(800, 104), semilla=3):
        azar = random.Random(semilla)
        self.horizonte = horizonte
        self.luna_x, self.luna_y = luna
        self.cielo = degradado_vertical(ANCHO, ALTO, CIELO_ARRIBA, CIELO_ABAJO)
        self.estrellas = [(azar.uniform(0, ANCHO), azar.uniform(0, horizonte * 0.8),
                           azar.uniform(0, math.tau), azar.choice((1, 1, 1, 2)))
                          for _ in range(130)]
        self.luna = self._crear_luna(46)
        self.halo = crear_brillo(170, (70, 66, 52))
        ancho_capa = int(ANCHO + max(0, ancho_escenario - ANCHO) * self.FACTOR_LEJANO) + 2
        self.capa_lejana = self._crear_siluetas(ancho_capa, azar)

    @staticmethod
    def _crear_luna(radio):
        luna = pygame.Surface((radio * 2, radio * 2), pygame.SRCALPHA)
        pygame.draw.circle(luna, COLOR_LUNA, (radio, radio), radio)
        for dx, dy, r in ((-14, -10, 10), (12, 8, 13), (-6, 18, 7), (18, -16, 6)):
            pygame.draw.circle(luna, (226, 218, 190), (radio + dx, radio + dy), r)
        return luna

    def _crear_siluetas(self, ancho, azar):
        alto = 260
        capa = pygame.Surface((ancho, alto), pygame.SRCALPHA)
        for color, minimo, maximo in (((28, 26, 54), 90, 170), ((20, 19, 40), 50, 110)):
            crestas = [(x, alto - azar.randint(minimo, maximo)) for x in range(-100, ancho + 200, 130)]
            puntos = [(0, alto)] + suavizar(crestas, 6) + [(ancho, alto)]
            pygame.draw.polygon(capa, color, puntos)
        siluetas = {"piedra": (13, 12, 26), "muro": (13, 12, 26), "techo": (13, 12, 26),
                    "ventana": (214, 150, 70)}
        dibujar_tenshu(capa, self.luna_x + 10, alto - 16, siluetas, escala=0.8)
        return capa

    def dibujar(self, superficie, camara_x, tiempo):
        superficie.blit(self.cielo, (0, 0))
        for x, y, fase, tam in self.estrellas:
            brillo = 0.6 + 0.4 * math.sin(tiempo * 1.7 + fase)
            c = int(120 + 120 * brillo)
            sx = (x - camara_x * 0.02) % ANCHO
            superficie.fill((c, c, min(255, c + 12)), (int(sx), int(y), tam, tam))
        lx = int(self.luna_x - camara_x * 0.03)
        superficie.blit(self.halo, (lx - 170, self.luna_y - 170), special_flags=pygame.BLEND_RGB_ADD)
        superficie.blit(self.luna, (lx - 46, self.luna_y - 46))
        superficie.blit(self.capa_lejana, (-int(camara_x * self.FACTOR_LEJANO),
                                           self.horizonte - self.capa_lejana.get_height()))


# =============================================================================
# ESCENAS DE TEXTO (intro, cierre, derrota)
# =============================================================================

class EscenaTexto(Escena):
    """Texto que aparece letra a letra sobre el cielo nocturno."""

    def __init__(self, juego, titulo, parrafos, al_continuar, subtitulo="",
                 pie="Pulsa ENTER para continuar"):
        super().__init__(juego)
        self.titulo = titulo
        self.subtitulo = subtitulo
        self.al_continuar = al_continuar
        self.pie = pie
        self.fondo = FondoNocturno()
        self.lineas = []
        for parrafo in parrafos:
            self.lineas.extend(partir_en_lineas(parrafo, juego.fuente, 700))
            self.lineas.append("")
        if self.lineas:
            self.lineas.pop()
        self.total = sum(len(linea) for linea in self.lineas)
        self.visibles = 0.0
        self.tiempo = 0.0

    @property
    def completo(self):
        return self.visibles >= self.total

    def manejar_evento(self, evento):
        if evento.type == pygame.KEYDOWN and evento.key in TECLAS_CONFIRMAR:
            if not self.completo:
                self.visibles = self.total
            else:
                self.juego.cambiar_escena(self.al_continuar)

    def actualizar(self, dt):
        self.tiempo += dt
        if self.tiempo > 0.6:
            self.visibles = min(self.total, self.visibles + VELOCIDAD_TEXTO * dt)

    def dibujar(self, pantalla):
        juego = self.juego
        self.fondo.dibujar(pantalla, 0, self.tiempo)
        alfa = int(255 * limitar(self.tiempo / 0.8, 0, 1))
        rect = dibujar_texto(pantalla, self.titulo, juego.fuente_titulo, DORADO,
                             (ANCHO // 2, 46), "centro", alfa=alfa)
        y = rect.bottom + 4
        if self.subtitulo:
            rect = dibujar_texto(pantalla, self.subtitulo, juego.fuente, GRIS,
                                 (ANCHO // 2, y), "centro", alfa=alfa)
            y = rect.bottom
        y += 26
        alto_linea = juego.fuente.get_linesize()
        alto_texto = sum(alto_linea if linea else alto_linea // 2 for linea in self.lineas)
        dibujar_panel(pantalla, pygame.Rect(100, y - 16, ANCHO - 200, alto_texto + 32), alfa=150,
                      borde=(90, 80, 60))
        restantes = int(self.visibles)
        for linea in self.lineas:
            if linea and restantes > 0:
                dibujar_texto(pantalla, linea[:restantes], juego.fuente, CREMA, (130, y))
            restantes -= len(linea)
            y += alto_linea if linea else alto_linea // 2
        if self.completo and int(self.tiempo * 2) % 2 == 0:
            dibujar_texto(pantalla, self.pie, juego.fuente_chica, DORADO,
                          (ANCHO // 2, ALTO - 42), "centro")


def crear_intro(juego):
    return EscenaTexto(juego, "RONIN", TEXTO_INTRO, lambda: EscenaCastillo(juego),
                       subtitulo="Capítulo 1 · El castillo de Hoshiyama")


def crear_cierre(juego, vida):
    return EscenaTexto(juego, "Fin del capítulo 1", TEXTO_CIERRE,
                       lambda: EscenaPlanicie(juego, vida),
                       subtitulo="El castillo de Hoshiyama",
                       pie="Pulsa ENTER para salir a la planicie")


def crear_derrota(juego):
    return EscenaTexto(juego, "Akira ha caído", TEXTO_DERROTA, lambda: EscenaCastillo(juego),
                       pie="Pulsa ENTER para intentarlo de nuevo")


# =============================================================================
# CAPÍTULO 1: ESCENARIO DEL CASTILLO
# =============================================================================

def crear_muralla_fondo(ancho):
    """Muralla interior del castillo (capa intermedia con paralaje)."""
    alto = SUELO_Y - 200 + 10
    capa = pygame.Surface((ancho, alto), pygame.SRCALPHA)
    yeso, madera, viga = (84, 88, 114), (30, 30, 42), (24, 24, 34)
    pygame.draw.rect(capa, yeso, (0, 22, ancho, 130))
    pygame.draw.rect(capa, madera, (0, 152, ancho, alto - 152))
    for x in range(0, ancho, 14):
        pygame.draw.line(capa, (38, 38, 52), (x, 156), (x, alto))
    pygame.draw.rect(capa, viga, (0, 146, ancho, 8))
    for x in range(60, ancho, 240):
        pygame.draw.rect(capa, viga, (x, 22, 16, alto - 22))
        # troneras: triángulo, cuadrado y círculo
        pygame.draw.polygon(capa, (26, 26, 36), [(x + 70, 96), (x + 86, 96), (x + 78, 82)])
        pygame.draw.rect(capa, (26, 26, 36), (x + 130, 84, 13, 13))
        pygame.draw.circle(capa, (26, 26, 36), (x + 196, 90), 7)
    pygame.draw.rect(capa, TEJA, (0, 6, ancho, 18))
    for x in range(0, ancho, 9):
        pygame.draw.line(capa, TEJA_CLARA, (x, 9), (x, 22))
    pygame.draw.rect(capa, TEJA_CLARA, (0, 2, ancho, 5))
    pygame.draw.line(capa, (18, 18, 26), (0, 24), (ancho, 24), 2)
    return capa


def crear_textura_piedra(ancho, alto, azar, alto_fila=22):
    superficie = pygame.Surface((ancho, alto))
    superficie.fill(PIEDRA_OSCURA)
    y, fila = 0, 0
    while y < alto:
        x = -azar.randint(10, 30) if fila % 2 else 0
        while x < ancho:
            largo = azar.randint(34, 62)
            pygame.draw.rect(superficie, variar_brillo(PIEDRA, azar, 9),
                             (x + 1, y + 1, largo - 2, alto_fila - 2))
            pygame.draw.line(superficie, variar_brillo(PIEDRA_CLARA, azar, 6),
                             (x + 1, y + 1), (x + largo - 3, y + 1))
            x += largo
        y += alto_fila
        fila += 1
    pygame.draw.rect(superficie, PIEDRA_CLARA, (0, 0, ancho, 3))
    return superficie


def crear_textura_madera(ancho, alto, azar):
    superficie = pygame.Surface((ancho, alto))
    superficie.fill(MADERA)
    pygame.draw.rect(superficie, MADERA_CLARA, (0, 0, ancho, 3))
    pygame.draw.rect(superficie, MADERA_OSCURA, (0, alto - 3, ancho, 3))
    x = 0
    while True:
        x += azar.randint(26, 44)
        if x >= ancho:
            break
        pygame.draw.line(superficie, MADERA_OSCURA, (x, 3), (x, alto - 4))
    return superficie


def crear_puerta_final(puerta, azar):
    """Portón de salida del castillo con su muro. Devuelve (imagen, posición)."""
    izquierda, arriba = puerta.left - 60, 150
    imagen = pygame.Surface((NIVEL_ANCHO - izquierda, SUELO_Y - arriba), pygame.SRCALPHA)
    ox, oy = -izquierda, -arriba
    # muro de piedra a la derecha del portón (fin del nivel)
    muro = crear_textura_piedra(NIVEL_ANCHO - puerta.right, SUELO_Y - 150, azar)
    imagen.blit(muro, (puerta.right + ox, 150 + oy))
    # postes y dintel
    for x in (puerta.left - 16, puerta.right):
        pygame.draw.rect(imagen, MADERA_OSCURA, (x + ox, puerta.top - 24 + oy, 16, puerta.height + 24))
        pygame.draw.line(imagen, MADERA, (x + 3 + ox, puerta.top - 20 + oy), (x + 3 + ox, SUELO_Y + oy))
    pygame.draw.rect(imagen, MADERA_OSCURA, (puerta.left - 28 + ox, puerta.top - 38 + oy,
                                             puerta.width + 56, 16))
    dibujar_techo(imagen, TEJA, puerta.centerx + ox, puerta.top - 34 + oy, puerta.width + 76, 40,
                  18, TEJA_CLARA)
    # hojas del portón
    mitad = puerta.width // 2
    for x in (puerta.left, puerta.left + mitad + 1):
        hoja = pygame.Rect(x + ox, puerta.top + oy, mitad - 1, puerta.height)
        pygame.draw.rect(imagen, MADERA, hoja)
        for k in range(1, 4):
            pygame.draw.line(imagen, MADERA_OSCURA, (hoja.left + k * hoja.width // 4, hoja.top),
                             (hoja.left + k * hoja.width // 4, hoja.bottom))
        for banda in (0.22, 0.72):
            y = hoja.top + int(hoja.height * banda)
            pygame.draw.rect(imagen, (58, 58, 66), (hoja.left, y, hoja.width, 8))
            for k in range(5):
                pygame.draw.circle(imagen, (150, 150, 160),
                                   (hoja.left + 7 + k * (hoja.width - 14) // 4, y + 4), 2)
    # rendija de luz entre las hojas: afuera espera el mundo
    pygame.draw.line(imagen, (255, 214, 140), (puerta.centerx + ox, puerta.top + 4 + oy),
                     (puerta.centerx + ox, SUELO_Y - 2 + oy), 2)
    return imagen, (izquierda, arriba)


class Antorcha:
    """Poste con fuego, luz cálida y chispas."""

    def __init__(self, x, base_y, altura, azar):
        self.x = x
        self.base_y = base_y
        self.llama_y = base_y - altura
        self.fase = azar.uniform(0, 10)
        self.proxima_chispa = azar.uniform(0, 0.5)

    def visible(self, camara_x, margen=60):
        return -margen < self.x - camara_x < ANCHO + margen

    def actualizar(self, dt, particulas, azar):
        self.proxima_chispa -= dt
        if self.proxima_chispa <= 0:
            self.proxima_chispa = azar.uniform(0.12, 0.45)
            particulas.append(Particula(
                self.x + azar.uniform(-4, 4), self.llama_y - 12, azar.uniform(-18, 18),
                azar.uniform(-110, -60), azar.uniform(0.5, 1.1), (255, 214, 120), 2.2,
                color_final=(150, 40, 10), gravedad=-20))

    def dibujar_poste(self, superficie, camara_x):
        if not self.visible(camara_x):
            return
        x = self.x - camara_x
        pygame.draw.rect(superficie, MADERA_OSCURA, (x - 3, self.llama_y + 6, 6,
                                                     self.base_y - self.llama_y - 6))
        pygame.draw.polygon(superficie, (62, 60, 68), [
            (x - 11, self.llama_y + 1), (x + 11, self.llama_y + 1),
            (x + 6, self.llama_y + 9), (x - 6, self.llama_y + 9)])

    def dibujar_llama(self, superficie, camara_x, tiempo):
        if not self.visible(camara_x):
            return
        x = self.x - camara_x
        t = tiempo * 9 + self.fase
        alto = 24 + math.sin(t) * 4 + math.sin(t * 2.3) * 3
        vaiven = math.sin(t * 1.3) * 3
        for escala, color in ((1.0, (220, 70, 20)), (0.72, (255, 150, 40)), (0.42, (255, 236, 150))):
            ancho = 9 * escala
            base = self.llama_y - ancho * 0.5
            pygame.draw.circle(superficie, color, (int(x), int(base)), int(ancho))
            pygame.draw.polygon(superficie, color, [(x - ancho, base), (x + ancho, base),
                                                    (x + vaiven, base - alto * escala)])

    def dibujar_luz(self, superficie, camara_x, brillo):
        radio = brillo.get_width() // 2
        if self.visible(camara_x, radio):
            superficie.blit(brillo, (int(self.x - camara_x - radio), int(self.llama_y - 12 - radio)),
                            special_flags=pygame.BLEND_RGB_ADD)


# =============================================================================
# CAPÍTULO 1: AKIRA (plataformas) Y SOLDADOS
# =============================================================================

class Jugador:
    """Akira en el nivel de plataformas: correr, saltar y atacar con la espada."""

    ANCHO = 28
    ALTO = 56

    def __init__(self, x, pie_y):
        self.x = float(x)
        self.y = float(pie_y - self.ALTO)
        self.vel_x = 0.0
        self.vel_y = 0.0
        self.en_suelo = True
        self.sobre_plataforma = False
        self.mirando = 1
        self.vida = VIDA_MAXIMA
        self.invulnerable = 0.0
        self.empujado = 0.0
        self.tiempo_ataque = 0.0
        self.enfriamiento = 0.0
        self.golpeados = set()
        self.coyote = 0.0
        self.buffer_salto = 0.0
        self.atravesar = 0.0
        self.anim = 0.0
        self.tiempo_muerto = 0.0

    @property
    def rect(self):
        return pygame.Rect(int(self.x), int(self.y), self.ANCHO, self.ALTO)

    @property
    def centro_x(self):
        return self.x + self.ANCHO / 2

    @property
    def pie_y(self):
        return self.y + self.ALTO

    @property
    def vivo(self):
        return self.vida > 0

    def pedir_salto(self):
        self.buffer_salto = 0.12

    def iniciar_ataque(self):
        if self.vivo and self.enfriamiento <= 0:
            self.tiempo_ataque = DURACION_ATAQUE
            self.enfriamiento = ENFRIAMIENTO_ATAQUE
            self.golpeados = set()

    def caja_espada(self):
        """Zona donde corta la espada, solo en la primera parte del ataque."""
        if self.tiempo_ataque <= 0:
            return None
        progreso = 1 - self.tiempo_ataque / DURACION_ATAQUE
        if progreso > 0.7:
            return None
        if self.mirando > 0:
            x = self.x + self.ANCHO - 4
        else:
            x = self.x - ALCANCE_ESPADA + 4
        return pygame.Rect(int(x), int(self.y + 4), ALCANCE_ESPADA, 44)

    def recibir_golpe(self, desde_x):
        if self.invulnerable > 0 or not self.vivo:
            return False
        self.vida -= 1
        self.invulnerable = 1.1
        self.empujado = 0.25
        direccion = 1 if self.centro_x >= desde_x else -1
        self.vel_x = direccion * 260
        self.vel_y = -320
        self.en_suelo = False
        self.tiempo_ataque = 0.0
        return True

    def actualizar(self, dt, teclas, solidos, plataformas, particulas, azar):
        self.anim += dt
        for nombre in ("invulnerable", "empujado", "tiempo_ataque", "enfriamiento",
                       "buffer_salto", "coyote", "atravesar"):
            setattr(self, nombre, max(0.0, getattr(self, nombre) - dt))

        if not self.vivo:
            self.tiempo_muerto += dt
            self.vel_x *= math.exp(-6 * dt)
        elif self.empujado <= 0:
            derecha = teclas[pygame.K_d] or teclas[pygame.K_RIGHT]
            izquierda = teclas[pygame.K_a] or teclas[pygame.K_LEFT]
            direccion = (1 if derecha else 0) - (1 if izquierda else 0)
            velocidad = VEL_CAMINAR * (0.55 if self.tiempo_ataque > 0 and self.en_suelo else 1.0)
            self.vel_x = direccion * velocidad
            if direccion and self.tiempo_ataque <= 0:
                self.mirando = direccion
            if (teclas[pygame.K_s] or teclas[pygame.K_DOWN]) and self.sobre_plataforma:
                self.atravesar = 0.22
            if self.buffer_salto > 0 and (self.en_suelo or self.coyote > 0):
                self.vel_y = -VEL_SALTO
                self.buffer_salto = 0.0
                self.coyote = 0.0
                self.en_suelo = False
            salto_presionado = any(teclas[tecla] for tecla in TECLAS_SALTO)
            if self.vel_y < -VEL_SALTO * 0.45 and not salto_presionado:
                self.vel_y = -VEL_SALTO * 0.45

        estaba_en_suelo = self.en_suelo
        velocidad_caida = self.vel_y
        self.mover(dt, solidos, plataformas)
        if estaba_en_suelo and not self.en_suelo and self.vel_y >= 0:
            self.coyote = 0.09
        if not estaba_en_suelo and self.en_suelo and velocidad_caida > 420:
            for _ in range(7):
                particulas.append(Particula(self.centro_x + azar.uniform(-12, 12), self.pie_y - 2,
                                            azar.uniform(-70, 70), azar.uniform(-60, -20),
                                            azar.uniform(0.25, 0.45), (120, 118, 130), 3,
                                            color_final=(60, 60, 72)))

    def mover(self, dt, solidos, plataformas):
        """Movimiento con colisiones, primero en horizontal y luego en vertical."""
        self.x += self.vel_x * dt
        arriba, abajo = self.y, self.y + self.ALTO
        for bloque in solidos:
            if (abajo > bloque.top and arriba < bloque.bottom
                    and self.x + self.ANCHO > bloque.left and self.x < bloque.right):
                if self.vel_x > 0:
                    self.x = bloque.left - self.ANCHO
                elif self.vel_x < 0:
                    self.x = bloque.right

        pie_anterior = self.pie_y
        cabeza_anterior = self.y
        self.vel_y = min(self.vel_y + GRAVEDAD * dt, VEL_CAIDA_MAX)
        self.y += self.vel_y * dt
        self.en_suelo = False
        self.sobre_plataforma = False
        izquierda, derecha = self.x, self.x + self.ANCHO
        if self.vel_y >= 0:
            candidatos = [(bloque, False) for bloque in solidos]
            if self.atravesar <= 0:
                candidatos += [(plataforma, True) for plataforma in plataformas]
            for bloque, es_plataforma in candidatos:
                if (derecha > bloque.left and izquierda < bloque.right
                        and pie_anterior <= bloque.top + 1 and self.pie_y >= bloque.top):
                    self.y = bloque.top - self.ALTO
                    self.vel_y = 0.0
                    self.en_suelo = True
                    self.sobre_plataforma = es_plataforma
        else:
            for bloque in solidos:
                if (derecha > bloque.left and izquierda < bloque.right
                        and cabeza_anterior >= bloque.bottom - 1 and self.y <= bloque.bottom):
                    self.y = bloque.bottom
                    self.vel_y = 0.0

    def _dibujar_tajo(self, lienzo, centro, angulo_actual, progreso):
        """Estela de la espada. pygame.draw.arc usa ángulos antihorarios."""
        alfa = int(220 * (1 - progreso / 0.8))
        inicio = math.radians(-75)
        for radio, grosor, factor in ((40, 5, 1.0), (34, 3, 0.6), (28, 2, 0.35)):
            rect = pygame.Rect(0, 0, radio * 2, radio * 2)
            rect.center = (int(centro[0]), int(centro[1]))
            pygame.draw.arc(lienzo, (225, 235, 255, int(alfa * factor)), rect,
                            -angulo_actual, -inicio, grosor)

    def _crear_lienzo(self, tiempo):
        """Dibuja a Akira mirando a la derecha sobre una superficie transparente."""
        lienzo = pygame.Surface((120, 104), pygame.SRCALPHA)
        cx, pie = 60, 100
        en_aire = not self.en_suelo
        caminando = self.en_suelo and abs(self.vel_x) > 10
        paso = math.sin(self.anim * 13) * 6 if caminando else 0.0
        atacando = self.tiempo_ataque > 0

        # Vaina de la katana (detrás del cuerpo)
        pygame.draw.line(lienzo, SAYA, (cx + 4, pie - 27), (cx - 26, pie - 15), 4)

        # Hakama
        if en_aire:
            pygame.draw.polygon(lienzo, HAKAMA, [(cx - 11, pie - 25), (cx + 11, pie - 25),
                                                 (cx + 15, pie - 9), (cx - 13, pie - 7)])
            pygame.draw.rect(lienzo, HAKAMA_OSCURO, (cx - 12, pie - 10, 10, 4))
            pygame.draw.rect(lienzo, HAKAMA_OSCURO, (cx + 3, pie - 12, 10, 4))
        elif caminando:
            for desfase, color in ((-paso, HAKAMA_OSCURO), (paso, HAKAMA)):
                pygame.draw.polygon(lienzo, color, [(cx - 7, pie - 25), (cx + 7, pie - 25),
                                                    (cx + desfase + 8, pie), (cx + desfase - 8, pie)])
        else:
            pygame.draw.polygon(lienzo, HAKAMA, [(cx - 11, pie - 25), (cx + 11, pie - 25),
                                                 (cx + 15, pie), (cx - 15, pie)])
            pygame.draw.line(lienzo, HAKAMA_OSCURO, (cx, pie - 19), (cx, pie - 1), 2)

        # Torso, cuello del kimono y obi
        torso = pygame.Rect(cx - 11, pie - 45, 22, 22)
        pygame.draw.rect(lienzo, KIMONO, torso, border_radius=4)
        pygame.draw.lines(lienzo, HACHIMAKI, False, [(cx - 3, torso.top + 1), (cx + 3, torso.top + 10),
                                                     (cx + 8, torso.top + 1)], 2)
        pygame.draw.rect(lienzo, OBI, (torso.left, torso.bottom - 6, torso.width, 5))

        # Cabeza, moño y hachimaki
        hx, hy = cx + 2, pie - 53
        pygame.draw.circle(lienzo, PIEL, (hx, hy), 8)
        pygame.draw.circle(lienzo, PELO, (hx - 1, hy - 1), 8, draw_top_left=True,
                           draw_top_right=True, draw_bottom_left=True)
        pygame.draw.ellipse(lienzo, PELO, (hx - 5, hy - 14, 9, 6))
        pygame.draw.line(lienzo, NEGRO, (hx + 4, hy), (hx + 6, hy), 2)
        pygame.draw.line(lienzo, HACHIMAKI, (hx - 8, hy - 4), (hx + 8, hy - 4), 3)
        ondeo = math.sin(tiempo * 10) * 3
        if caminando or en_aire:
            extremos = [(hx - 22, hy - 5 + ondeo), (hx - 20, hy + ondeo * 0.5)]
        else:
            extremos = [(hx - 12, hy + 7), (hx - 15, hy + 5)]
        for extremo in extremos:
            pygame.draw.line(lienzo, HACHIMAKI, (hx - 8, hy - 4), extremo, 2)

        # Brazo y espada
        if atacando:
            progreso = 1 - self.tiempo_ataque / DURACION_ATAQUE
            angulo = math.radians(-75 + 140 * min(1.0, progreso / 0.55))
            hombro = (cx + 3, pie - 41)
            mano = (cx + 17, pie - 37)
            if progreso < 0.8:
                self._dibujar_tajo(lienzo, mano, angulo, progreso)
            punta = (mano[0] + math.cos(angulo) * 38, mano[1] + math.sin(angulo) * 38)
            mango = (mano[0] - math.cos(angulo) * 9, mano[1] - math.sin(angulo) * 9)
            pygame.draw.line(lienzo, KIMONO_OSCURO, hombro, mano, 6)
            pygame.draw.line(lienzo, TSUKA, mango, mano, 4)
            pygame.draw.line(lienzo, ACERO, mano, punta, 3)
            pygame.draw.circle(lienzo, PIEL, mano, 3)
        else:
            pygame.draw.line(lienzo, TSUKA, (cx + 5, pie - 28), (cx + 16, pie - 33), 4)
            pygame.draw.circle(lienzo, DORADO_APAGADO, (cx + 5, pie - 28), 3)
            pygame.draw.line(lienzo, KIMONO_OSCURO, (cx + 1, pie - 42), (cx + 6, pie - 30), 6)
            pygame.draw.circle(lienzo, PIEL, (cx + 7, pie - 29), 3)
        return lienzo

    def dibujar(self, superficie, camara_x, tiempo):
        if self.vivo and self.invulnerable > 0 and int(self.invulnerable * 16) % 2 == 0:
            return
        lienzo = self._crear_lienzo(tiempo)
        if self.mirando < 0:
            lienzo = pygame.transform.flip(lienzo, True, False)
        pie_x, pie_y = self.centro_x - camara_x, self.pie_y
        if self.vivo:
            superficie.blit(lienzo, (int(pie_x - 60), int(pie_y - 100)))
        else:
            # cae de espaldas girando sobre los pies
            angulo = 80 * min(1.0, self.tiempo_muerto / 0.35) * self.mirando
            girado = pygame.transform.rotate(lienzo, angulo)
            radianes = math.radians(angulo)
            centro = (pie_x - 48 * math.sin(radianes), pie_y - 48 * math.cos(radianes))
            superficie.blit(girado, girado.get_rect(center=(int(centro[0]), int(centro[1]))))


class Soldado:
    """Soldado con lanza: patrulla, persigue, avisa (!) y ataca."""

    ANCHO = 30
    ALTO = 56

    def __init__(self, centro_x, pie_y, limite_izq, limite_der, azar):
        self.x = float(centro_x)
        self.pie_y = pie_y
        self.limite_izq, self.limite_der = limite_izq, limite_der
        self.direccion = azar.choice((-1, 1))
        self.velocidad = azar.uniform(55, 75)
        self.vida = 2
        self.estado = "patrulla"
        self.temporizador = 0.0
        self.destello = 0.0
        self.empuje = 0.0
        self.sin_ver = 0.0
        self.anim = azar.uniform(0, 5)
        self.moviendose = True
        self.tiempo_muerto = 0.0

    @property
    def rect(self):
        return pygame.Rect(int(self.x - self.ANCHO / 2), int(self.pie_y - self.ALTO),
                           self.ANCHO, self.ALTO)

    @property
    def vivo(self):
        return self.estado != "muerto"

    @property
    def desaparecido(self):
        return self.estado == "muerto" and self.tiempo_muerto > 1.2

    def caja_lanza(self):
        if self.estado != "atacando":
            return None
        frente = self.x + self.direccion * self.ANCHO / 2
        x = frente if self.direccion > 0 else frente - ALCANCE_LANZA
        return pygame.Rect(int(x), int(self.pie_y - 46), ALCANCE_LANZA, 14)

    def hiere(self, rect_jugador):
        """¿Toca al jugador con la lanza o con el cuerpo en este cuadro?"""
        if self.estado in ("muerto", "aturdido"):
            return False
        lanza = self.caja_lanza()
        if lanza and lanza.colliderect(rect_jugador):
            return True
        return self.rect.inflate(-8, -6).colliderect(rect_jugador)

    def actualizar(self, dt, jugador):
        self.anim += dt
        self.destello = max(0.0, self.destello - dt)
        if self.estado == "muerto":
            self.tiempo_muerto += dt
            return
        dx = jugador.centro_x - self.x
        mismo_nivel = abs(jugador.pie_y - self.pie_y) < 50
        de_frente = (dx > 0) == (self.direccion > 0)
        lo_ve = jugador.vivo and mismo_nivel and (abs(dx) < 110 or (abs(dx) < 280 and de_frente))
        self.moviendose = False

        if self.estado == "patrulla":
            self.moviendose = True
            self.x += self.direccion * self.velocidad * dt
            if self.x <= self.limite_izq:
                self.x, self.direccion = self.limite_izq, 1
            elif self.x >= self.limite_der:
                self.x, self.direccion = self.limite_der, -1
            if lo_ve:
                self.estado = "alerta"
        elif self.estado == "alerta":
            self.direccion = 1 if dx > 0 else -1
            self.sin_ver = 0.0 if lo_ve else self.sin_ver + dt
            if self.sin_ver > 1.5:
                self.estado = "patrulla"
                self.sin_ver = 0.0
            elif abs(dx) > DISTANCIA_ATAQUE_SOLDADO:
                anterior = self.x
                self.x = limitar(self.x + self.direccion * VEL_PERSECUCION * dt,
                                 self.limite_izq, self.limite_der)
                self.moviendose = self.x != anterior
            elif lo_ve:
                self.estado = "preparando"
                self.temporizador = 0.45
        elif self.estado == "preparando":
            self.temporizador -= dt
            if self.temporizador <= 0:
                self.estado = "atacando"
                self.temporizador = 0.2
        elif self.estado == "atacando":
            self.temporizador -= dt
            if self.temporizador <= 0:
                self.estado = "recuperando"
                self.temporizador = 0.55
        elif self.estado == "recuperando":
            self.temporizador -= dt
            if self.temporizador <= 0:
                self.estado = "alerta"
        elif self.estado == "aturdido":
            self.temporizador -= dt
            self.x = limitar(self.x + self.empuje * dt, self.limite_izq, self.limite_der)
            self.empuje *= math.exp(-8 * dt)
            if self.temporizador <= 0:
                self.estado = "alerta"

    def recibir_golpe(self, direccion_golpe, particulas, azar):
        """Devuelve True si el golpe lo derrota."""
        if not self.vivo:
            return False
        self.vida -= 1
        self.destello = 0.12
        lanzar_chispas(particulas, azar, self.x, self.pie_y - 34, 12, (255, 250, 220),
                       (200, 60, 30), 240, direccion_golpe)
        if self.vida <= 0:
            self.estado = "muerto"
            self.direccion = -direccion_golpe
            self.tiempo_muerto = 0.0
            return True
        self.estado = "aturdido"
        self.temporizador = 0.4
        self.empuje = direccion_golpe * 260
        return False

    def _crear_lienzo(self):
        """Dibuja al soldado mirando a la derecha."""
        lienzo = pygame.Surface((200, 104), pygame.SRCALPHA)
        cx, pie = 100, 100
        paso = math.sin(self.anim * 11) * 5 if self.moviendose else 0.0
        tx = cx + {"preparando": -4, "atacando": 5}.get(self.estado, 0)

        for desfase, color in ((-paso, PANTALON_OSCURO), (paso, PANTALON)):
            pygame.draw.line(lienzo, color, (cx, pie - 22), (cx + desfase, pie - 3), 7)
            pygame.draw.rect(lienzo, (26, 24, 28), (cx + desfase - 4, pie - 4, 10, 4))
        pygame.draw.polygon(lienzo, ARMADURA_OSCURA, [(tx - 13, pie - 30), (tx + 13, pie - 30),
                                                      (tx + 16, pie - 18), (tx - 16, pie - 18)])
        coraza = pygame.Rect(tx - 12, pie - 50, 24, 22)
        pygame.draw.rect(lienzo, ARMADURA, coraza, border_radius=3)
        for y in range(coraza.top + 5, coraza.bottom - 1, 5):
            pygame.draw.line(lienzo, ARMADURA_CLARA, (coraza.left + 2, y), (coraza.right - 3, y))
        hx, hy = tx + 2, pie - 57
        pygame.draw.circle(lienzo, PIEL, (hx, hy), 7)
        pygame.draw.line(lienzo, NEGRO, (hx + 3, hy), (hx + 5, hy), 2)
        pygame.draw.polygon(lienzo, SOMBRERO, [(hx - 16, hy - 3), (hx, hy - 14), (hx + 16, hy - 3)])
        pygame.draw.line(lienzo, DORADO_APAGADO, (hx - 16, hy - 3), (hx + 16, hy - 3), 2)

        y_lanza = pie - 40
        if self.estado == "atacando":
            pygame.draw.line(lienzo, MADERA_LANZA, (cx - 16, y_lanza), (cx + 74, y_lanza), 3)
            punta = [(cx + 74, y_lanza - 4), (cx + 74, y_lanza + 4), (cx + 87, y_lanza)]
            mano = (cx + 22, y_lanza)
        elif self.estado == "preparando":
            pygame.draw.line(lienzo, MADERA_LANZA, (cx - 52, y_lanza), (cx + 20, y_lanza), 3)
            punta = [(cx + 20, y_lanza - 4), (cx + 20, y_lanza + 4), (cx + 33, y_lanza)]
            mano = (cx + 2, y_lanza)
        else:
            pygame.draw.line(lienzo, MADERA_LANZA, (cx + 15, pie - 2), (cx + 15, pie - 84), 3)
            punta = [(cx + 11, pie - 84), (cx + 19, pie - 84), (cx + 15, pie - 97)]
            mano = (cx + 15, pie - 42)
        pygame.draw.polygon(lienzo, ACERO, punta)
        pygame.draw.line(lienzo, ARMADURA_OSCURA, (tx + 2, pie - 46), mano, 6)
        pygame.draw.circle(lienzo, PIEL, mano, 3)

        if self.destello > 0:
            lienzo.fill((170, 170, 170), special_flags=pygame.BLEND_RGB_ADD)
        return lienzo

    def dibujar(self, superficie, camara_x):
        pie_x = self.x - camara_x
        if not -120 < pie_x < ANCHO + 120:
            return
        lienzo = self._crear_lienzo()
        if self.direccion < 0:
            lienzo = pygame.transform.flip(lienzo, True, False)
        if self.vivo:
            superficie.blit(lienzo, (int(pie_x - 100), int(self.pie_y - 100)))
            if self.estado == "preparando":
                ax, ay = int(pie_x), int(self.pie_y - 84)
                pygame.draw.rect(superficie, ROJO, (ax - 3, ay - 16, 6, 11), border_radius=2)
                pygame.draw.circle(superficie, ROJO, (ax, ay), 3)
        else:
            angulo = 85 * min(1.0, self.tiempo_muerto / 0.35) * self.direccion
            girado = pygame.transform.rotate(lienzo, angulo)
            if self.tiempo_muerto > 0.6:
                girado.set_alpha(int(255 * max(0.0, 1 - (self.tiempo_muerto - 0.6) / 0.6)))
            radianes = math.radians(angulo)
            centro = (pie_x - 48 * math.sin(radianes), self.pie_y - 48 * math.cos(radianes))
            superficie.blit(girado, girado.get_rect(center=(int(centro[0]), int(centro[1]))))


# =============================================================================
# CAPÍTULO 1: ESCENA DEL CASTILLO
# =============================================================================

class EscenaCastillo(Escena):
    """Nivel de acción y plataformas dentro del castillo de Hoshiyama."""

    FACTOR_MURALLA = 0.5

    def __init__(self, juego):
        super().__init__(juego)
        azar = random.Random(11)
        self.azar = random.Random()
        self.fondo = FondoNocturno(NIVEL_ANCHO, horizonte=330, luna=(760, 96))
        self.muralla = crear_muralla_fondo(int(ANCHO + (NIVEL_ANCHO - ANCHO) * self.FACTOR_MURALLA) + 2)
        self.bloques = [pygame.Rect(bloque) for bloque in BLOQUES_PIEDRA]
        self.suelo = pygame.Rect(0, SUELO_Y, NIVEL_ANCHO, ALTO - SUELO_Y)
        self.solidos = [self.suelo] + self.bloques + [pygame.Rect(l) for l in LIMITES_NIVEL]
        self.plataformas = [pygame.Rect(p) for p in PLATAFORMAS_MADERA]
        self.textura_suelo = crear_textura_piedra(NIVEL_ANCHO, ALTO - SUELO_Y, azar, 18)
        self.texturas_bloques = [crear_textura_piedra(b.w, b.h, azar) for b in self.bloques]
        self.texturas_plataformas = [crear_textura_madera(p.w, p.h, azar) for p in self.plataformas]
        self.brillo_antorcha = crear_brillo(130, (150, 82, 32))
        self.antorchas = [Antorcha(x, base, altura, azar) for x, base, altura in ANTORCHAS]
        self.puerta = pygame.Rect(PUERTA_FINAL)
        self.imagen_puerta, self.posicion_puerta = crear_puerta_final(self.puerta, azar)
        self.jugador = Jugador(110, SUELO_Y)
        self.soldados = [Soldado(x, pie, izq, der, azar) for x, pie, izq, der in SOLDADOS]
        self.total_soldados = len(self.soldados)
        self.derrotados = 0
        self.particulas = []
        self.camara_x = 0.0
        self.tiempo = 0.0
        self.sacudida = 0.0
        self.terminado = False
        self.tiempo_derrota = 0.0

    def manejar_evento(self, evento):
        if evento.type != pygame.KEYDOWN:
            return
        if evento.key in TECLAS_SALTO:
            self.jugador.pedir_salto()
        elif evento.key == pygame.K_j:
            self.jugador.iniciar_ataque()

    def actualizar(self, dt):
        self.tiempo += dt
        jugador = self.jugador
        jugador.actualizar(dt, pygame.key.get_pressed(), self.solidos, self.plataformas,
                           self.particulas, self.azar)

        espada = jugador.caja_espada()
        for soldado in self.soldados:
            soldado.actualizar(dt, jugador)
            if (espada and soldado.vivo and soldado not in jugador.golpeados
                    and espada.colliderect(soldado.rect)):
                jugador.golpeados.add(soldado)
                if soldado.recibir_golpe(jugador.mirando, self.particulas, self.azar):
                    self.derrotados += 1
                self.sacudida = 0.12
            if jugador.vivo and soldado.hiere(jugador.rect) and jugador.recibir_golpe(soldado.x):
                self.sacudida = 0.2
                lanzar_chispas(self.particulas, self.azar, jugador.centro_x, jugador.y + 24, 10,
                               (255, 120, 100), (120, 20, 20), 200)
        self.soldados = [s for s in self.soldados if not s.desaparecido]

        for antorcha in self.antorchas:
            antorcha.actualizar(dt, self.particulas, self.azar)
        self.particulas = [p for p in self.particulas if p.actualizar(dt)]
        self.sacudida = max(0.0, self.sacudida - dt)

        objetivo = jugador.centro_x - ANCHO / 2 + jugador.mirando * 70
        self.camara_x += (objetivo - self.camara_x) * min(1.0, dt * 5)
        self.camara_x = limitar(self.camara_x, 0, NIVEL_ANCHO - ANCHO)

        if self.terminado:
            return
        if jugador.vivo and jugador.rect.colliderect(self.puerta):
            self.terminado = True
            vida = jugador.vida
            self.juego.cambiar_escena(lambda: crear_cierre(self.juego, vida))
        elif not jugador.vivo:
            self.tiempo_derrota += dt
            if self.tiempo_derrota > 1.3:
                self.terminado = True
                self.juego.cambiar_escena(lambda: crear_derrota(self.juego))

    def dibujar(self, pantalla):
        temblor = self.azar.randint(-3, 3) if self.sacudida > 0 else 0
        cam = int(self.camara_x) + temblor
        self.fondo.dibujar(pantalla, cam, self.tiempo)
        pantalla.blit(self.muralla, (-int(cam * self.FACTOR_MURALLA), 200))

        # postes que sostienen las plataformas
        for plataforma in self.plataformas:
            if plataforma.right - cam > -20 and plataforma.left - cam < ANCHO + 20:
                for x in (plataforma.left + 10, plataforma.right - 18):
                    pygame.draw.rect(pantalla, MADERA_OSCURA,
                                     (x - cam, plataforma.bottom, 8, SUELO_Y - plataforma.bottom))
                    pygame.draw.line(pantalla, MADERA, (x - cam + 2, plataforma.bottom),
                                     (x - cam + 2, SUELO_Y))
        for antorcha in self.antorchas:
            antorcha.dibujar_poste(pantalla, cam)
        pantalla.blit(self.imagen_puerta, (self.posicion_puerta[0] - cam, self.posicion_puerta[1]))
        for bloque, textura in zip(self.bloques, self.texturas_bloques):
            if bloque.right - cam > 0 and bloque.left - cam < ANCHO:
                pantalla.blit(textura, (bloque.x - cam, bloque.y))
        pantalla.blit(self.textura_suelo, (-cam, SUELO_Y))
        for plataforma, textura in zip(self.plataformas, self.texturas_plataformas):
            if plataforma.right - cam > 0 and plataforma.left - cam < ANCHO:
                pantalla.blit(textura, (plataforma.x - cam, plataforma.y))
        for antorcha in self.antorchas:
            antorcha.dibujar_llama(pantalla, cam, self.tiempo)

        for soldado in self.soldados:
            soldado.dibujar(pantalla, cam)
        self.jugador.dibujar(pantalla, cam, self.tiempo)
        for antorcha in self.antorchas:
            antorcha.dibujar_luz(pantalla, cam, self.brillo_antorcha)
        for particula in self.particulas:
            particula.dibujar(pantalla, cam)
        self.dibujar_hud(pantalla)

    def dibujar_hud(self, pantalla):
        juego = self.juego
        dibujar_vida(pantalla, juego.fuente, 20, 14, self.jugador.vida)
        dibujar_texto(pantalla, f"Soldados derrotados: {self.derrotados}/{self.total_soldados}",
                      juego.fuente_chica, CREMA, (ANCHO - 20, 18), "derecha")
        if self.tiempo < 10:
            alfa = int(255 * limitar((10 - self.tiempo) / 1.5, 0, 1))
            dibujar_texto(pantalla, "A/D: moverse    W o ESPACIO: saltar    S: bajar    "
                                    "J: atacar    ESC: pausa",
                          juego.fuente_chica, CREMA, (ANCHO // 2, ALTO - 34), "centro", alfa=alfa)


# =============================================================================
# PLANICIE: DIBUJOS DEL MAPA (se generan una vez al crear el mundo)
# =============================================================================

def crear_arbol(azar, tipo):
    """Devuelve (imagen, ancla_x, ancla_y); el ancla es la base del tronco."""
    if tipo == "pino":
        ancho, alto = 64, 104
        imagen = pygame.Surface((ancho, alto), pygame.SRCALPHA)
        pygame.draw.ellipse(imagen, (0, 0, 0, 55), (10, alto - 18, 44, 14))
        pygame.draw.rect(imagen, (96, 64, 42), (28, alto - 34, 8, 25))
        verde = variar_color((40, 94, 60), azar, 8)
        claro = mezclar_color(verde, (150, 200, 130), 0.25)
        oscuro = mezclar_color(verde, NEGRO, 0.28)
        for k in range(4):
            base = alto - 28 - k * 17
            mitad = 27 - k * 5
            pygame.draw.polygon(imagen, oscuro, [(32 - mitad, base), (32 + mitad, base), (32, base - 34)])
            pygame.draw.polygon(imagen, verde, [(32 - mitad, base - 2), (32 + mitad - 7, base - 2),
                                                (32, base - 34)])
            pygame.draw.line(imagen, claro, (32 - mitad + 4, base - 4), (32, base - 32), 2)
        return imagen, 32, alto - 11
    if tipo == "sakura":
        base_color = variar_color((238, 172, 194), azar, 8)
        claro, oscuro, tronco = (252, 214, 226), (204, 128, 156), (84, 54, 48)
    else:
        base_color = variar_color((66, 128, 62), azar, 10)
        claro = mezclar_color(base_color, (200, 226, 150), 0.35)
        oscuro = mezclar_color(base_color, NEGRO, 0.3)
        tronco = (98, 68, 44)
    ancho, alto = 84, 100
    imagen = pygame.Surface((ancho, alto), pygame.SRCALPHA)
    pygame.draw.ellipse(imagen, (0, 0, 0, 55), (14, alto - 18, 56, 15))
    pygame.draw.rect(imagen, tronco, (37, alto - 46, 10, 37))
    pygame.draw.line(imagen, tronco, (42, alto - 38), (55, alto - 52), 4)
    racimos = [(42 + azar.randint(-2, 2), 40, 24), (26, 48, 17), (58, 48, 17),
               (33, 29, 16), (52, 29, 16)]
    for x, y, r in racimos:
        pygame.draw.circle(imagen, oscuro, (x + 2, y + 3), r)
    for x, y, r in racimos:
        pygame.draw.circle(imagen, base_color, (x, y), r - 1)
    for x, y, r in racimos:
        pygame.draw.circle(imagen, claro, (x - r // 3, y - r // 3), r // 3)
    return imagen, 42, alto - 11


def crear_roca(azar):
    ancho, alto = 44, 32
    imagen = pygame.Surface((ancho, alto), pygame.SRCALPHA)
    pygame.draw.ellipse(imagen, (0, 0, 0, 50), (4, alto - 12, 36, 10))
    puntos = []
    for k in range(8):
        angulo = k / 8 * math.tau
        r = azar.uniform(0.75, 1.0)
        puntos.append((22 + math.cos(angulo) * 17 * r, 17 + math.sin(angulo) * 12 * r))
    gris = variar_color((138, 136, 130), azar, 10)
    pygame.draw.polygon(imagen, mezclar_color(gris, NEGRO, 0.35), [(x + 1, y + 2) for x, y in puntos])
    pygame.draw.polygon(imagen, gris, puntos)
    pygame.draw.polygon(imagen, mezclar_color(gris, BLANCO, 0.25),
                        [(x * 0.55 + 22 * 0.45 - 3, y * 0.55 + 17 * 0.45 - 3) for x, y in puntos])
    return imagen, 22, alto - 8


def crear_castillo(puerta_abierta):
    """Castillo de Hoshiyama visto desde la planicie. Ancla: base de la puerta."""
    ancho, alto = 440, 330
    imagen = pygame.Surface((ancho, alto), pygame.SRCALPHA)
    cx, base = 220, 326
    piedra, muro, techo = (132, 128, 120), (238, 234, 224), (66, 76, 96)
    borde = (104, 116, 138)
    pygame.draw.ellipse(imagen, (0, 0, 0, 60), (8, base - 26, ancho - 16, 32))
    dibujar_tenshu(imagen, cx, base - 62, {"piedra": piedra, "muro": muro, "techo": techo,
                                           "ventana": (46, 44, 54), "borde": borde,
                                           "adorno": DORADO, "junta": (108, 104, 96)})
    # muralla exterior con base de piedra
    pygame.draw.rect(imagen, piedra, (16, base - 34, ancho - 32, 34))
    for y in range(base - 34, base, 9):
        pygame.draw.line(imagen, (112, 108, 100), (16, y), (ancho - 17, y))
    pygame.draw.rect(imagen, muro, (22, base - 60, ancho - 44, 26))
    pygame.draw.polygon(imagen, techo, [(12, base - 58), (ancho - 12, base - 58),
                                        (ancho - 24, base - 70), (24, base - 70)])
    pygame.draw.line(imagen, borde, (12, base - 58), (ancho - 12, base - 58), 2)
    # torretas de las esquinas
    for tx in (50, ancho - 50):
        pygame.draw.rect(imagen, muro, (tx - 26, base - 96, 52, 36))
        pygame.draw.rect(imagen, (46, 44, 54), (tx - 6, base - 86, 12, 9))
        dibujar_techo(imagen, techo, tx, base - 92, 70, 18, 10, borde)
        pygame.draw.rect(imagen, muro, (tx - 18, base - 124, 36, 22))
        dibujar_techo(imagen, techo, tx, base - 120, 54, 22, 9, borde)
    # portón
    pygame.draw.rect(imagen, piedra, (cx - 54, base - 44, 108, 44))
    pygame.draw.rect(imagen, muro, (cx - 48, base - 96, 96, 40))
    for vx in (cx - 26, cx + 16):
        pygame.draw.rect(imagen, (46, 44, 54), (vx, base - 86, 10, 9))
    dibujar_techo(imagen, techo, cx, base - 92, 124, 26, 12, borde)
    hueco = pygame.Rect(cx - 26, base - 56, 52, 56)
    if puerta_abierta:
        pygame.draw.rect(imagen, (30, 24, 22), hueco)
        pygame.draw.rect(imagen, (60, 44, 32), (hueco.left - 8, hueco.top, 8, hueco.height))
        pygame.draw.rect(imagen, (60, 44, 32), (hueco.right, hueco.top, 8, hueco.height))
    else:
        pygame.draw.rect(imagen, (116, 76, 46), hueco)
        pygame.draw.line(imagen, (70, 44, 28), hueco.midtop, hueco.midbottom, 2)
        for y in (hueco.top + 12, hueco.bottom - 16):
            pygame.draw.rect(imagen, (60, 60, 66), (hueco.left, y, hueco.width, 5))
    pygame.draw.rect(imagen, (70, 44, 28), hueco, 3)
    return imagen, cx, base


def crear_casa(azar):
    ancho, alto = 124, 108
    imagen = pygame.Surface((ancho, alto), pygame.SRCALPHA)
    pygame.draw.ellipse(imagen, (0, 0, 0, 55), (8, alto - 18, 108, 16))
    pygame.draw.rect(imagen, (128, 124, 116), (14, alto - 16, 96, 10))
    pygame.draw.rect(imagen, (122, 84, 50), (16, alto - 52, 92, 38))
    for x in (20, 70, 86):
        pygame.draw.rect(imagen, (228, 216, 190), (x, alto - 48, 14, 28))
    pygame.draw.rect(imagen, (58, 40, 28), (50, alto - 42, 18, 28))
    pygame.draw.rect(imagen, variar_color((52, 70, 130), azar, 15), (48, alto - 44, 22, 9))
    pygame.draw.rect(imagen, (60, 44, 32), (36, alto - 40, 10, 10))
    if azar.random() < 0.6:   # tejado de paja
        paja = variar_color((194, 160, 94), azar, 10)
        oscuro = mezclar_color(paja, NEGRO, 0.2)
        pygame.draw.polygon(imagen, paja, [(4, alto - 46), (62, alto - 96), (120, alto - 46)])
        for k in range(6):
            x = 18 + k * 18
            pygame.draw.line(imagen, oscuro, (x, alto - 48), (62 + (x - 62) * 0.4, alto - 88), 1)
        pygame.draw.line(imagen, mezclar_color(paja, NEGRO, 0.3), (4, alto - 46), (120, alto - 46), 4)
        pygame.draw.rect(imagen, (92, 72, 50), (46, alto - 100, 32, 8))
    else:                     # tejado de tejas
        dibujar_techo(imagen, (78, 86, 104), 62, alto - 46, 104, 44, 12, (110, 120, 140))
    return imagen, 62, alto - 8


def crear_pozo():
    imagen = pygame.Surface((54, 66), pygame.SRCALPHA)
    pygame.draw.ellipse(imagen, (0, 0, 0, 50), (6, 52, 42, 12))
    for x in (13, 39):
        pygame.draw.rect(imagen, (104, 70, 44), (x - 2, 14, 5, 38))
    dibujar_techo(imagen, (86, 92, 108), 27, 18, 40, 12, 7)
    pygame.draw.ellipse(imagen, (136, 134, 128), (8, 38, 38, 20))
    pygame.draw.ellipse(imagen, (46, 70, 96), (14, 41, 26, 11))
    pygame.draw.line(imagen, (70, 60, 50), (27, 18), (27, 36), 1)
    pygame.draw.rect(imagen, (122, 84, 50), (23, 32, 8, 7))
    return imagen, 27, 58


def crear_pagoda():
    ancho, alto = 170, 250
    imagen = pygame.Surface((ancho, alto), pygame.SRCALPHA)
    cx, base = 85, 246
    madera, techo, borde = (178, 60, 44), (56, 60, 74), (96, 102, 120)
    pygame.draw.ellipse(imagen, (0, 0, 0, 55), (18, base - 16, 134, 20))
    pygame.draw.rect(imagen, (150, 148, 140), (cx - 58, base - 18, 116, 18))
    y = base - 18
    for ancho_muro, ancho_techo in ((84, 140), (70, 120), (58, 102)):
        pygame.draw.rect(imagen, madera, rectangulo(cx - ancho_muro / 2, y - 30, ancho_muro, 30))
        pygame.draw.rect(imagen, (236, 226, 196), rectangulo(cx - ancho_muro / 2 + 6, y - 26,
                                                             ancho_muro - 12, 6))
        y -= 30
        dibujar_techo(imagen, techo, cx, y + 6, ancho_techo, 24, 14, borde)
        y -= 16
    pygame.draw.rect(imagen, (40, 30, 28), (cx - 12, base - 44, 24, 26))
    pygame.draw.rect(imagen, DORADO_APAGADO, (cx - 12, base - 44, 24, 26), 2)
    pygame.draw.line(imagen, DORADO_APAGADO, (cx, y + 4), (cx, y - 46), 3)
    for k in range(5):
        pygame.draw.line(imagen, DORADO_APAGADO, (cx - 6, y - 10 - k * 7), (cx + 6, y - 10 - k * 7), 2)
    pygame.draw.circle(imagen, DORADO, (cx, y - 50), 4)
    return imagen, cx, base


def crear_torii():
    ancho, alto = 130, 112
    imagen = pygame.Surface((ancho, alto), pygame.SRCALPHA)
    bermellon, negro = (214, 72, 42), (40, 36, 38)
    for x in (29, 101):
        pygame.draw.ellipse(imagen, (0, 0, 0, 50), (x - 12, alto - 12, 24, 9))
        pygame.draw.rect(imagen, bermellon, (x - 5, 30, 10, alto - 36))
        pygame.draw.rect(imagen, negro, (x - 6, alto - 12, 12, 8))
    pygame.draw.rect(imagen, bermellon, (14, 46, 102, 8))
    pygame.draw.rect(imagen, bermellon, (61, 30, 8, 16))
    pygame.draw.polygon(imagen, bermellon, [(6, 22), (124, 22), (118, 32), (12, 32)])
    pygame.draw.polygon(imagen, negro, [(0, 12), (130, 12), (124, 22), (6, 22)])
    return imagen, 65, alto - 6


def crear_linterna():
    imagen = pygame.Surface((30, 54), pygame.SRCALPHA)
    gris, oscuro = (156, 156, 150), (104, 104, 100)
    pygame.draw.ellipse(imagen, (0, 0, 0, 50), (2, 44, 26, 9))
    pygame.draw.rect(imagen, oscuro, (5, 42, 20, 7))
    pygame.draw.rect(imagen, gris, (11, 26, 8, 16))
    pygame.draw.rect(imagen, gris, (6, 14, 18, 12))
    pygame.draw.rect(imagen, (255, 214, 140), (12, 17, 6, 6))
    pygame.draw.polygon(imagen, oscuro, [(1, 15), (29, 15), (22, 7), (8, 7)])
    pygame.draw.circle(imagen, gris, (15, 5), 3)
    return imagen, 15, 49


def crear_dojo():
    ancho, alto = 300, 190
    imagen = pygame.Surface((ancho, alto), pygame.SRCALPHA)
    cx, base = 150, 186
    pygame.draw.ellipse(imagen, (0, 0, 0, 60), (14, base - 22, 272, 28))
    pygame.draw.rect(imagen, (140, 136, 128), (20, base - 18, 260, 16))
    pygame.draw.rect(imagen, (96, 62, 38), (28, base - 90, 244, 74))
    pygame.draw.rect(imagen, (228, 218, 196), (28, base - 90, 244, 20))
    for x in range(28, 273, 30):
        pygame.draw.rect(imagen, (70, 44, 28), (x, base - 90, 6, 74))
    pygame.draw.rect(imagen, (34, 26, 22), (cx - 30, base - 66, 60, 50))
    pygame.draw.rect(imagen, (170, 130, 86), (cx - 30, base - 66, 16, 50))
    pygame.draw.rect(imagen, (170, 130, 86), (cx + 14, base - 66, 16, 50))
    pygame.draw.rect(imagen, (160, 156, 148), (cx - 38, base - 16, 76, 8))
    dibujar_techo(imagen, (62, 66, 76), cx, base - 84, 300, 74, 16, (104, 110, 124))
    pygame.draw.polygon(imagen, (228, 218, 196), [(cx - 34, base - 150), (cx + 34, base - 150),
                                                  (cx, base - 176)])
    pygame.draw.polygon(imagen, (62, 66, 76), [(cx - 46, base - 146), (cx, base - 184),
                                               (cx + 46, base - 146), (cx + 38, base - 146),
                                               (cx, base - 176), (cx - 38, base - 146)])
    # tablilla con el nombre del dojo (trazos de pincel)
    pygame.draw.rect(imagen, (232, 224, 204), (cx - 22, base - 106, 44, 18))
    pygame.draw.rect(imagen, (70, 44, 28), (cx - 22, base - 106, 44, 18), 2)
    for k in range(3):
        pygame.draw.line(imagen, (30, 26, 24), (cx - 12 + k * 12, base - 102),
                         (cx - 14 + k * 12, base - 92), 3)
    return imagen, cx, base


def crear_makiwara():
    imagen = pygame.Surface((18, 56), pygame.SRCALPHA)
    pygame.draw.ellipse(imagen, (0, 0, 0, 50), (1, 48, 16, 7))
    pygame.draw.rect(imagen, (110, 76, 48), (6, 10, 6, 42))
    pygame.draw.rect(imagen, (200, 170, 104), (4, 10, 10, 14))
    for y in (13, 17, 21):
        pygame.draw.line(imagen, (150, 120, 70), (4, y), (13, y))
    return imagen, 9, 51


def crear_muro_roto(ancho, azar):
    alto = 92
    imagen = pygame.Surface((ancho + 10, alto), pygame.SRCALPHA)
    pygame.draw.ellipse(imagen, (0, 0, 0, 55), (0, alto - 16, ancho + 10, 14))
    piedra = pygame.Surface((ancho, alto - 8), pygame.SRCALPHA)
    piedra.fill((116, 114, 108))
    for y in range(0, alto, 13):
        pygame.draw.line(piedra, (90, 88, 84), (0, y), (ancho, y))
        desfase = (y // 13 % 2) * 14
        for x in range(desfase, ancho, 28):
            pygame.draw.line(piedra, (90, 88, 84), (x, y), (x, y + 13))
    # borde superior quebrado: se borra lo que queda por encima
    perfil = [(0, azar.randint(20, 40))]
    x = 0
    while x < ancho:
        x = min(ancho, x + azar.randint(10, 24))
        perfil.append((x, azar.randint(4, 50)))
    pygame.draw.polygon(piedra, (0, 0, 0, 0), [(0, -1)] + perfil + [(ancho, -1)])
    for px, py in perfil[1:-1:2]:
        pygame.draw.circle(piedra, (88, 124, 70), (px, py + 3), 4)
    imagen.blit(piedra, (5, 0))
    return imagen, (ancho + 10) // 2, alto - 10


def crear_pilar(roto, azar):
    imagen = pygame.Surface((30, 84), pygame.SRCALPHA)
    pygame.draw.ellipse(imagen, (0, 0, 0, 55), (2, 72, 26, 10))
    arriba = azar.randint(24, 44) if roto else 16
    pygame.draw.rect(imagen, (150, 148, 140), (7, arriba, 16, 76 - arriba))
    pygame.draw.rect(imagen, (176, 174, 166), (8, arriba, 4, 76 - arriba))
    pygame.draw.rect(imagen, (116, 114, 108), (19, arriba, 4, 76 - arriba))
    pygame.draw.rect(imagen, (128, 126, 120), (4, 72, 22, 8))
    if roto:
        pygame.draw.polygon(imagen, (0, 0, 0, 0), [(6, arriba - 1), (24, arriba - 1),
                                                   (24, arriba + 6), (15, arriba + 2), (6, arriba + 8)])
    else:
        pygame.draw.rect(imagen, (128, 126, 120), (4, arriba - 5, 22, 6))
    return imagen, 15, 78


def crear_pilar_caido():
    imagen = pygame.Surface((100, 36), pygame.SRCALPHA)
    pygame.draw.ellipse(imagen, (0, 0, 0, 55), (4, 22, 92, 12))
    pygame.draw.rect(imagen, (150, 148, 140), (8, 8, 80, 18))
    pygame.draw.rect(imagen, (176, 174, 166), (8, 9, 80, 5))
    pygame.draw.ellipse(imagen, (170, 168, 160), (80, 6, 14, 22))
    pygame.draw.ellipse(imagen, (130, 128, 120), (84, 10, 7, 14))
    return imagen, 50, 28


def crear_sombra_nube(azar):
    imagen = pygame.Surface((560, 300), pygame.SRCALPHA)
    for _ in range(5):
        ancho = azar.randint(200, 320)
        alto = azar.randint(90, 150)
        x = azar.randint(0, 560 - ancho)
        y = azar.randint(0, 300 - alto)
        pygame.draw.ellipse(imagen, (18, 30, 40, 34), (x, y, ancho, alto))
    return imagen


# =============================================================================
# PLANICIE: EL MUNDO
# =============================================================================

class ObjetoMundo:
    """Algo que se dibuja ordenado por profundidad (árbol, casa, castillo...)."""

    __slots__ = ("imagen", "y", "rect")

    def __init__(self, imagen, x, y, ancla_x, ancla_y):
        self.imagen = imagen
        self.y = y   # línea del suelo: decide qué se dibuja delante
        self.rect = imagen.get_rect(topleft=(int(x - ancla_x), int(y - ancla_y)))


class Puente:
    """Puente de madera donde un camino cruza el río."""

    def __init__(self, x, y, angulo, medio_largo, medio_ancho=26):
        self.x, self.y = x, y
        self.angulo = angulo
        self.coseno, self.seno = math.cos(angulo), math.sin(angulo)
        self.medio_largo = medio_largo
        self.medio_ancho = medio_ancho

    def contiene(self, px, py, holgura=13):
        dx, dy = px - self.x, py - self.y
        a_lo_largo = dx * self.coseno + dy * self.seno
        de_costado = -dx * self.seno + dy * self.coseno
        return abs(a_lo_largo) <= self.medio_largo and abs(de_costado) <= self.medio_ancho - holgura

    def crear_imagen(self):
        largo, ancho = int(self.medio_largo * 2), int(self.medio_ancho * 2)
        imagen = pygame.Surface((largo, ancho), pygame.SRCALPHA)
        imagen.fill((150, 108, 66))
        for x in range(0, largo, 9):
            pygame.draw.line(imagen, (112, 78, 46), (x, 0), (x, ancho))
        for y in (0, ancho - 6):
            pygame.draw.rect(imagen, (96, 64, 38), (0, y, largo, 6))
            for x in range(4, largo - 4, 26):
                pygame.draw.rect(imagen, (74, 48, 28), (x, y - 1, 7, 8))
        return pygame.transform.rotate(imagen, -math.degrees(self.angulo))


class Mundo:
    """Mapa abierto: terreno, caminos, río, lugares, vegetación y colisiones."""

    def __init__(self):
        azar = random.Random(SEMILLA_MUNDO)
        self.rio = suavizar(PUNTOS_RIO, 10)
        self.caminos = [suavizar(camino, 10) for camino in CAMINOS]
        self.puentes = self._calcular_puentes()
        self.circulos = []        # obstáculos redondos: (x, y, radio)
        self.rectangulos = []     # obstáculos rectangulares (pygame.Rect)
        self.arboles = []         # posiciones de los árboles (para los mapas)
        self.objetos = []
        self.ocupado = self._crear_grilla_ocupada()
        self._crear_lugares(azar)
        self._crear_vegetacion(azar)
        self.suelo = self._crear_suelo(azar)
        self.indice = self._indexar_obstaculos()
        self.destellos = self._crear_destellos(azar)
        self.sombras_nube = [crear_sombra_nube(azar) for _ in range(3)]
        self.nubes = [(azar.uniform(0, MUNDO_ANCHO), azar.uniform(0, MUNDO_ALTO), k % 3)
                      for k in range(8)]
        self.mapa, self.escala_mapa = self._crear_mapa((640, 480))
        self.minimapa, self.escala_minimapa = self._crear_mapa((192, 144))

    # --- geometría -----------------------------------------------------------

    def _calcular_puentes(self):
        puentes = []
        for camino in self.caminos:
            for i in range(len(camino) - 1):
                a, b = camino[i], camino[i + 1]
                for k in range(len(self.rio) - 1):
                    c, d = self.rio[k], self.rio[k + 1]
                    cruce = interseccion_segmentos(a, b, c, d)
                    if not cruce or any(math.hypot(cruce[0] - p.x, cruce[1] - p.y) < 80 for p in puentes):
                        continue
                    angulo = math.atan2(b[1] - a[1], b[0] - a[0])
                    rio_x, rio_y = d[0] - c[0], d[1] - c[1]
                    largo_rio = math.hypot(rio_x, rio_y) or 1
                    seno = abs(math.cos(angulo) * rio_y - math.sin(angulo) * rio_x) / largo_rio
                    puentes.append(Puente(cruce[0], cruce[1], angulo, (MITAD_RIO + 28) / max(0.45, seno)))
        return puentes

    def _crear_grilla_ocupada(self):
        """Celdas de 20 px donde no deben crecer árboles (caminos, río, lugares)."""
        columnas, filas = MUNDO_ANCHO // 20 + 1, MUNDO_ALTO // 20 + 1
        ocupado = [bytearray(columnas) for _ in range(filas)]

        def marcar_franja(puntos, radio):
            for i in range(len(puntos) - 1):
                (ax, ay), (bx, by) = puntos[i], puntos[i + 1]
                for fila in range(max(0, int((min(ay, by) - radio) // 20)),
                                  min(filas, int((max(ay, by) + radio) // 20) + 1)):
                    for columna in range(max(0, int((min(ax, bx) - radio) // 20)),
                                         min(columnas, int((max(ax, bx) + radio) // 20) + 1)):
                        if distancia_a_segmento(columna * 20 + 10, fila * 20 + 10, ax, ay, bx, by) < radio:
                            ocupado[fila][columna] = 1

        def marcar_circulo(cx, cy, radio):
            for fila in range(max(0, int((cy - radio) // 20)), min(filas, int((cy + radio) // 20) + 1)):
                for columna in range(max(0, int((cx - radio) // 20)),
                                     min(columnas, int((cx + radio) // 20) + 1)):
                    if math.hypot(columna * 20 + 10 - cx, fila * 20 + 10 - cy) < radio:
                        ocupado[fila][columna] = 1

        for camino in self.caminos:
            marcar_franja(camino, ANCHO_CAMINO / 2 + 30)
        marcar_franja(self.rio, MITAD_RIO + 26)
        marcar_circulo(ESTANQUE[0], ESTANQUE[1], ESTANQUE[2] + 30)
        for lugar in LUGARES:
            marcar_circulo(lugar["centro"][0], lugar["centro"][1], lugar["radio_libre"])
        return ocupado

    def celda_libre(self, x, y):
        fila, columna = int(y // 20), int(x // 20)
        return (0 <= fila < len(self.ocupado) and 0 <= columna < len(self.ocupado[0])
                and not self.ocupado[fila][columna])

    # --- contenido -----------------------------------------------------------

    def _agregar(self, dibujo, x, y):
        imagen, ancla_x, ancla_y = dibujo
        objeto = ObjetoMundo(imagen, x, y, ancla_x, ancla_y)
        self.objetos.append(objeto)
        return objeto

    def _crear_lugares(self, azar):
        # Castillo de Hoshiyama
        px, py = PUERTA_CASTILLO
        self.imagen_castillo_cerrado = crear_castillo(False)[0]
        self.objeto_castillo = self._agregar(crear_castillo(True), px, py)
        self.rectangulos.append(pygame.Rect(px - 205, py - 150, 410, 146))

        # Aldea: casas alrededor de la plaza
        ax, ay = LUGARES[1]["entrada"]
        for dx, dy in ((-150, -170), (0, -200), (140, -185), (230, 60), (-235, 70), (0, 215)):
            self._agregar(crear_casa(azar), ax + dx, ay + dy)
            self.rectangulos.append(pygame.Rect(ax + dx - 50, ay + dy - 40, 100, 36))
        self._agregar(crear_pozo(), ax, ay - 85)
        self.circulos.append((ax, ay - 88, 18))

        # Templo: pagoda, torii y linternas de piedra
        tx, ty = LUGARES[2]["entrada"]
        self._agregar(crear_pagoda(), tx, ty - 90)
        self.rectangulos.append(pygame.Rect(tx - 60, ty - 136, 120, 42))
        self._agregar(crear_torii(), tx, ty + 90)
        for lado in (-1, 1):
            self.circulos.append((tx + lado * 36, ty + 88, 7))
            self._agregar(crear_linterna(), tx + lado * 62, ty + 4)
            self.circulos.append((tx + lado * 62, ty + 2, 9))

        # Dojo con postes de entrenamiento
        dx, dy = LUGARES[3]["entrada"]
        self._agregar(crear_dojo(), dx, dy - 75)
        self.rectangulos.append(pygame.Rect(dx - 125, dy - 160, 250, 82))
        for mx, my in ((dx - 100, dy + 35), (dx + 140, dy + 75)):
            self._agregar(crear_makiwara(), mx, my)
            self.circulos.append((mx, my - 2, 7))

        # Ruinas
        rx, ry = LUGARES[4]["entrada"]
        for ancho, x, y in ((170, rx - 20, ry + 150), (130, rx + 150, ry - 70), (110, rx - 190, ry + 60)):
            self._agregar(crear_muro_roto(ancho, azar), x, y)
            self.rectangulos.append(pygame.Rect(x - ancho // 2, y - 20, ancho, 20))
        for x, y, roto in ((rx - 140, ry - 40, True), (rx + 120, ry + 70, False), (rx + 200, ry + 10, True),
                           (rx - 60, ry - 110, True), (rx + 60, ry - 120, False)):
            self._agregar(crear_pilar(roto, azar), x, y)
            self.circulos.append((x, y - 3, 12))
        self._agregar(crear_pilar_caido(), rx + 20, ry + 95)
        self.rectangulos.append(pygame.Rect(rx - 26, ry + 83, 88, 16))

    def _crear_vegetacion(self, azar):
        variantes = {tipo: [crear_arbol(azar, tipo) for _ in range(4)]
                     for tipo in ("pino", "redondo", "sakura")}
        rocas = [crear_roca(azar) for _ in range(4)]
        separacion = {}

        def espacio_libre(x, y, distancia):
            cx, cy = int(x // 60), int(y // 60)
            for i in range(cx - 1, cx + 2):
                for j in range(cy - 1, cy + 2):
                    for ox, oy in separacion.get((i, j), ()):
                        if (ox - x) ** 2 + (oy - y) ** 2 < distancia * distancia:
                            return False
            return True

        def plantar(x, y, dibujo, radio, es_arbol=True):
            self._agregar(dibujo, x, y)
            self.circulos.append((x, y, radio))
            if es_arbol:
                self.arboles.append((x, y))
            separacion.setdefault((int(x // 60), int(y // 60)), []).append((x, y))

        for x, y in SAKURAS:
            plantar(x, y, azar.choice(variantes["sakura"]), 12)

        for bx, by, radio, cantidad, tipo in ZONAS_BOSQUE:
            plantados, intentos = 0, 0
            while plantados < cantidad and intentos < cantidad * 12:
                intentos += 1
                angulo = azar.uniform(0, math.tau)
                distancia = radio * math.sqrt(azar.random())
                x, y = bx + math.cos(angulo) * distancia, by + math.sin(angulo) * distancia * 0.8
                if (BORDE_MUNDO + 20 < x < MUNDO_ANCHO - BORDE_MUNDO - 20
                        and BORDE_MUNDO + 20 < y < MUNDO_ALTO - BORDE_MUNDO - 20
                        and self.celda_libre(x, y) and espacio_libre(x, y, 40)):
                    especie = tipo if tipo != "mixto" else azar.choice(("pino", "redondo"))
                    plantar(x, y, azar.choice(variantes[especie]), 12)
                    plantados += 1

        for _ in range(170):   # árboles y rocas sueltos por la planicie
            x = azar.uniform(BORDE_MUNDO + 30, MUNDO_ANCHO - BORDE_MUNDO - 30)
            y = azar.uniform(BORDE_MUNDO + 30, MUNDO_ALTO - BORDE_MUNDO - 30)
            if self.celda_libre(x, y) and espacio_libre(x, y, 90):
                if azar.random() < 0.3:
                    plantar(x, y, azar.choice(rocas), 13, es_arbol=False)
                else:
                    plantar(x, y, azar.choice(variantes[azar.choice(("pino", "redondo"))]), 12)

        # Bosque espeso en los bordes del mapa (no se puede salir)
        for y in range(10, MUNDO_ALTO + 60, 46):
            for x in (azar.uniform(0, 30), MUNDO_ANCHO - azar.uniform(0, 30)):
                plantar(x, y, azar.choice(variantes["pino"]), 12)
        for x in range(30, MUNDO_ANCHO, 46):
            for y in (azar.uniform(10, 40), MUNDO_ALTO - azar.uniform(0, 20)):
                if distancia_a_polilinea(x, y, self.rio) > MITAD_RIO + 20:
                    plantar(x, y, azar.choice(variantes["pino"]), 12)

    # --- terreno pre-dibujado ------------------------------------------------

    def _crear_suelo(self, azar):
        suelo = pygame.Surface((MUNDO_ANCHO, MUNDO_ALTO))
        suelo.fill(PASTO)
        for _ in range(170):   # manchas de distintos verdes
            ancho = azar.randint(140, 420)
            alto = int(ancho * azar.uniform(0.45, 0.8))
            mancha = pygame.Surface((ancho, alto), pygame.SRCALPHA)
            color = azar.choice(TONOS_PASTO)
            for paso in range(3):
                reduccion = paso * 0.2
                rect = pygame.Rect(0, 0, int(ancho * (1 - reduccion)), int(alto * (1 - reduccion)))
                rect.center = (ancho // 2, alto // 2)
                pygame.draw.ellipse(mancha, color + (22 * (paso + 1),), rect)
            suelo.blit(mancha, (azar.randint(-150, MUNDO_ANCHO), azar.randint(-150, MUNDO_ALTO)))
        for _ in range(5000):  # matas de hierba
            x, y = azar.randint(0, MUNDO_ANCHO), azar.randint(0, MUNDO_ALTO)
            color = (70, 112, 52) if azar.random() < 0.7 else (140, 180, 96)
            pygame.draw.line(suelo, color, (x, y), (x - 2, y - 5))
            pygame.draw.line(suelo, color, (x + 1, y), (x + 3, y - 6))
        for _ in range(900):   # flores
            color = azar.choice(((240, 240, 232), (250, 214, 90), (236, 150, 176), (170, 190, 250)))
            pygame.draw.circle(suelo, color, (azar.randint(0, MUNDO_ANCHO), azar.randint(0, MUNDO_ALTO)), 2)

        # río y estanque
        dibujar_franja(suelo, ARENA, self.rio, ANCHO_RIO + 18)
        dibujar_franja(suelo, AGUA, self.rio, ANCHO_RIO)
        dibujar_franja(suelo, AGUA_PROFUNDA, self.rio, int(ANCHO_RIO * 0.45))
        ex, ey, er = ESTANQUE
        pygame.draw.circle(suelo, ARENA, (ex, ey), er + 9)
        pygame.draw.circle(suelo, AGUA, (ex, ey), er)
        pygame.draw.circle(suelo, AGUA_PROFUNDA, (ex + 6, ey + 4), int(er * 0.55))
        for _ in range(9):   # hojas de loto
            angulo, distancia = azar.uniform(0, math.tau), azar.uniform(20, er - 18)
            lx, ly = ex + math.cos(angulo) * distancia, ey + math.sin(angulo) * distancia
            pygame.draw.circle(suelo, (70, 140, 70), (int(lx), int(ly)), 9)
            pygame.draw.polygon(suelo, AGUA, [(lx, ly), (lx + 10, ly - 4), (lx + 10, ly + 4)])
            if azar.random() < 0.4:
                pygame.draw.circle(suelo, (246, 190, 210), (int(lx - 3), int(ly - 2)), 3)

        # caminos
        for camino in self.caminos:
            dibujar_franja(suelo, TIERRA_BORDE, camino, ANCHO_CAMINO + 6)
        for camino in self.caminos:
            dibujar_franja(suelo, TIERRA, camino, ANCHO_CAMINO)
            for x, y in camino[::3]:
                for _ in range(2):
                    pygame.draw.circle(suelo, (164, 136, 94),
                                       (int(x + azar.uniform(-12, 12)), int(y + azar.uniform(-12, 12))), 2)

        # suelos de cada lugar
        cx, cy = PUERTA_CASTILLO
        pygame.draw.ellipse(suelo, GRAVA, (cx - 170, cy - 30, 340, 100))
        ax, ay = LUGARES[1]["entrada"]
        pygame.draw.circle(suelo, TIERRA_BORDE, (ax, ay), 158)
        pygame.draw.circle(suelo, TIERRA, (ax, ay), 150)
        tx, ty = LUGARES[2]["entrada"]
        patio = pygame.Rect(tx - 140, ty - 150, 280, 250)
        pygame.draw.rect(suelo, (150, 146, 136), patio.inflate(10, 10), border_radius=10)
        pygame.draw.rect(suelo, GRAVA_CLARA, patio, border_radius=8)
        for y in range(patio.top + 10, patio.bottom - 4, 9):
            pygame.draw.line(suelo, (194, 190, 176), (patio.left + 8, y), (patio.right - 8, y))
        dx, dy = LUGARES[3]["entrada"]
        pygame.draw.rect(suelo, (172, 142, 102), (dx - 165, dy - 80, 330, 190), border_radius=14)
        rx, ry = LUGARES[4]["entrada"]
        for _ in range(170):   # losas agrietadas de las ruinas
            angulo, distancia = azar.uniform(0, math.tau), 200 * math.sqrt(azar.random())
            x, y = rx + math.cos(angulo) * distancia, ry + 20 + math.sin(angulo) * distancia * 0.8
            losa = pygame.Rect(0, 0, azar.randint(18, 34), azar.randint(14, 26))
            losa.center = (int(x), int(y))
            pygame.draw.rect(suelo, variar_brillo((150, 148, 138), azar, 14), losa)
            pygame.draw.rect(suelo, (110, 108, 100), losa, 1)
            if azar.random() < 0.25:
                pygame.draw.circle(suelo, (96, 134, 74), losa.topleft, 4)

        for puente in self.puentes:
            imagen = puente.crear_imagen()
            suelo.blit(imagen, imagen.get_rect(center=(int(puente.x), int(puente.y))))
        return suelo.convert() if pygame.display.get_surface() else suelo

    def _crear_destellos(self, azar):
        destellos = []
        for i in range(0, len(self.rio) - 1):
            (ax, ay), (bx, by) = self.rio[i], self.rio[i + 1]
            largo = math.hypot(bx - ax, by - ay) or 1
            nx, ny = -(by - ay) / largo, (bx - ax) / largo
            for _ in range(2):
                t, lado = azar.random(), azar.uniform(-MITAD_RIO + 10, MITAD_RIO - 10)
                destellos.append((ax + (bx - ax) * t + nx * lado, ay + (by - ay) * t + ny * lado,
                                  azar.uniform(0, math.tau), azar.randint(6, 14)))
        ex, ey, er = ESTANQUE
        for _ in range(10):
            angulo, distancia = azar.uniform(0, math.tau), azar.uniform(0, er - 16)
            destellos.append((ex + math.cos(angulo) * distancia, ey + math.sin(angulo) * distancia,
                              azar.uniform(0, math.tau), azar.randint(5, 10)))
        return destellos

    def _crear_mapa(self, tamano):
        """Mapa en miniatura del mundo (para el minimapa y el mapa grande)."""
        escala = tamano[0] / MUNDO_ANCHO
        mapa = pygame.transform.smoothscale(self.suelo, tamano)
        radio = max(1, int(round(34 * escala)))
        for x, y in self.arboles:
            pygame.draw.circle(mapa, (46, 92, 56), (int(x * escala), int(y * escala)), radio)
        for lugar in LUGARES:
            x, y = lugar["entrada"]
            punto = (int(x * escala), int(y * escala))
            pygame.draw.circle(mapa, (24, 20, 20), punto, max(3, int(22 * escala)) + 2)
            pygame.draw.circle(mapa, lugar["color"], punto, max(3, int(22 * escala)))
        return mapa, escala

    def _indexar_obstaculos(self):
        """Reparte los obstáculos en celdas para consultar solo los cercanos."""
        indice = {}
        margen = RADIO_VIAJERO + 6
        for circulo in self.circulos:
            x, y, r = circulo
            for i in range(int((x - r - margen) // CELDA_OBSTACULOS),
                           int((x + r + margen) // CELDA_OBSTACULOS) + 1):
                for j in range(int((y - r - margen) // CELDA_OBSTACULOS),
                               int((y + r + margen) // CELDA_OBSTACULOS) + 1):
                    indice.setdefault((i, j), ([], []))[0].append(circulo)
        for rect in self.rectangulos:
            for i in range((rect.left - margen) // CELDA_OBSTACULOS,
                           (rect.right + margen) // CELDA_OBSTACULOS + 1):
                for j in range((rect.top - margen) // CELDA_OBSTACULOS,
                               (rect.bottom + margen) // CELDA_OBSTACULOS + 1):
                    indice.setdefault((i, j), ([], []))[1].append(rect)
        return indice

    # --- consultas -----------------------------------------------------------

    def en_agua(self, x, y, radio):
        if any(puente.contiene(x, y) for puente in self.puentes):
            return False
        if distancia_a_polilinea(x, y, self.rio) < MITAD_RIO + radio:
            return True
        ex, ey, er = ESTANQUE
        return math.hypot(x - ex, y - ey) < er + radio

    def bloqueado(self, x, y, radio=RADIO_VIAJERO):
        """¿Puede Akira pararse en (x, y)?"""
        if not (BORDE_MUNDO <= x <= MUNDO_ANCHO - BORDE_MUNDO
                and BORDE_MUNDO <= y <= MUNDO_ALTO - BORDE_MUNDO):
            return True
        if self.en_agua(x, y, radio):
            return True
        celda = self.indice.get((int(x // CELDA_OBSTACULOS), int(y // CELDA_OBSTACULOS)))
        if celda:
            circulos, rectangulos = celda
            for cx, cy, r in circulos:
                if (x - cx) ** 2 + (y - cy) ** 2 < (r + radio) ** 2:
                    return True
            for rect in rectangulos:
                px, py = limitar(x, rect.left, rect.right), limitar(y, rect.top, rect.bottom)
                if (x - px) ** 2 + (y - py) ** 2 < radio * radio:
                    return True
        return False

    def lugar_cercano(self, x, y):
        for lugar in LUGARES:
            if math.hypot(x - lugar["entrada"][0], y - lugar["entrada"][1]) < RADIO_INTERACCION:
                return lugar
        return None

    # --- dibujo --------------------------------------------------------------

    def dibujar_agua(self, pantalla, cx, cy, tiempo):
        for x, y, fase, largo in self.destellos:
            sx, sy = x - cx, y - cy
            if -20 < sx < ANCHO + 20 and -10 < sy < ALTO + 10:
                brillo = math.sin(tiempo * 2.2 + fase)
                if brillo > 0.25:
                    desplazamiento = math.sin(tiempo * 0.8 + fase) * 4
                    pygame.draw.line(pantalla, AGUA_BRILLO, (sx - largo / 2 + desplazamiento, sy),
                                     (sx + largo / 2 + desplazamiento, sy), 2)

    def dibujar_objetos(self, pantalla, cx, cy, viajero, tiempo):
        vista = pygame.Rect(cx, cy, ANCHO, ALTO)
        visibles = [objeto for objeto in self.objetos if objeto.rect.colliderect(vista)]
        visibles.append(viajero)
        visibles.sort(key=lambda objeto: objeto.y)
        for objeto in visibles:
            if objeto is viajero:
                viajero.dibujar(pantalla, cx, cy, tiempo)
            else:
                pantalla.blit(objeto.imagen, (objeto.rect.x - cx, objeto.rect.y - cy))

    def dibujar_nubes(self, pantalla, cx, cy, tiempo):
        for x, y, tipo in self.nubes:
            imagen = self.sombras_nube[tipo]
            wx = (x + tiempo * 16) % (MUNDO_ANCHO + 700) - 350
            sx, sy = int(wx - cx), int(y - cy)
            if -imagen.get_width() < sx < ANCHO and -imagen.get_height() < sy < ALTO:
                pantalla.blit(imagen, (sx, sy))


# =============================================================================
# PLANICIE: AKIRA VIAJERO (vista desde arriba)
# =============================================================================

class AkiraViajero:
    """Akira en el mapa abierto: se mueve libremente en ocho direcciones."""

    def __init__(self, x, y):
        self.x, self.y = float(x), float(y)
        self.direccion = "abajo"
        self.anim = 0.0
        self.moviendose = False
        self.sombra = pygame.Surface((26, 10), pygame.SRCALPHA)
        pygame.draw.ellipse(self.sombra, (0, 0, 0, 70), self.sombra.get_rect())

    def detener(self):
        self.moviendose = False

    def caminar_solo(self, dx, dy, velocidad, dt):
        """Movimiento automático (escenas), sin colisiones."""
        self.x += dx * velocidad * dt
        self.y += dy * velocidad * dt
        self.moviendose = True
        self.anim += dt
        self._orientar(dx, dy)

    def _orientar(self, dx, dy):
        if abs(dx) > abs(dy):
            self.direccion = "derecha" if dx > 0 else "izquierda"
        elif dy:
            self.direccion = "abajo" if dy > 0 else "arriba"

    def mover(self, dx, dy, corriendo, dt, mundo):
        self.moviendose = bool(dx or dy)
        if not self.moviendose:
            return
        if dx and dy:
            dx, dy = dx * 0.7071, dy * 0.7071
        self._orientar(dx, dy)
        velocidad = VEL_CORRER if corriendo else VEL_VIAJE
        self.anim += dt * (1.5 if corriendo else 1.0)
        self._avanzar(mundo, dx * velocidad * dt, 0.0)
        self._avanzar(mundo, 0.0, dy * velocidad * dt)

    def _avanzar(self, mundo, paso_x, paso_y):
        if not paso_x and not paso_y:
            return
        for fraccion in (1.0, 0.5, 0.25):
            nuevo_x, nuevo_y = self.x + paso_x * fraccion, self.y + paso_y * fraccion
            if not mundo.bloqueado(nuevo_x, nuevo_y):
                self.x, self.y = nuevo_x, nuevo_y
                return

    def dibujar(self, pantalla, cx, cy, tiempo):
        x, y = int(self.x - cx), int(self.y - cy)
        pantalla.blit(self.sombra, (x - 13, y - 5))
        paso = math.sin(self.anim * 12) if self.moviendose else 0.0
        rebote = int(abs(paso) * 2)
        d = self.direccion
        lado = 1 if d == "derecha" else -1

        # hakama y pies
        if d in ("abajo", "arriba"):
            pygame.draw.polygon(pantalla, HAKAMA, [(x - 8, y - 17 - rebote), (x + 8, y - 17 - rebote),
                                                   (x + 10, y - 3), (x - 10, y - 3)])
            pygame.draw.line(pantalla, HAKAMA_OSCURO, (x, y - 12 - rebote), (x, y - 3), 1)
            pygame.draw.ellipse(pantalla, HAKAMA_OSCURO, (x - 9, y - 4 - int(paso * 2), 7, 4))
            pygame.draw.ellipse(pantalla, HAKAMA_OSCURO, (x + 2, y - 4 + int(paso * 2), 7, 4))
        else:
            zancada = int(paso * 5)
            pygame.draw.polygon(pantalla, HAKAMA_OSCURO, [(x - 5, y - 17 - rebote), (x + 5, y - 17 - rebote),
                                                          (x - zancada + 5, y - 3), (x - zancada - 5, y - 3)])
            pygame.draw.polygon(pantalla, HAKAMA, [(x - 5, y - 17 - rebote), (x + 5, y - 17 - rebote),
                                                   (x + zancada + 5, y - 3), (x + zancada - 5, y - 3)])

        # torso, brazos y obi
        torso = pygame.Rect(x - 8, y - 31 - rebote, 16, 15)
        balanceo = int(paso * 2)
        if d in ("abajo", "arriba"):
            pygame.draw.rect(pantalla, KIMONO_OSCURO, (torso.left - 4, torso.top + 1 + balanceo, 5, 11),
                             border_radius=2)
            pygame.draw.rect(pantalla, KIMONO_OSCURO, (torso.right - 1, torso.top + 1 - balanceo, 5, 11),
                             border_radius=2)
        pygame.draw.rect(pantalla, KIMONO, torso, border_radius=3)
        pygame.draw.rect(pantalla, OBI, (torso.left, torso.bottom - 4, torso.width, 3))
        if d == "abajo":
            pygame.draw.lines(pantalla, HACHIMAKI, False, [(x - 4, torso.top), (x, torso.top + 6),
                                                           (x + 4, torso.top)], 2)
            pygame.draw.line(pantalla, TSUKA, (x + 7, torso.bottom - 3), (x + 12, torso.bottom - 8), 3)
        elif d == "arriba":
            pygame.draw.line(pantalla, SAYA, (x - 7, torso.bottom - 3), (x - 14, torso.bottom + 7), 3)
        else:
            pygame.draw.line(pantalla, SAYA, (x - lado * 2, torso.bottom - 3), (x - lado * 16, torso.bottom + 3), 3)
            pygame.draw.line(pantalla, TSUKA, (x - lado * 2, torso.bottom - 3), (x + lado * 7, torso.bottom - 7), 3)
            pygame.draw.rect(pantalla, KIMONO_OSCURO, (x - 3 - balanceo * lado, torso.top + 2, 6, 11),
                             border_radius=2)

        # cabeza
        hx, hy = x, torso.top - 7
        pygame.draw.circle(pantalla, PIEL, (hx, hy), 7)
        if d == "abajo":
            pygame.draw.circle(pantalla, PELO, (hx, hy - 1), 7, draw_top_left=True, draw_top_right=True)
            pygame.draw.line(pantalla, NEGRO, (hx - 3, hy + 1), (hx - 2, hy + 1), 2)
            pygame.draw.line(pantalla, NEGRO, (hx + 2, hy + 1), (hx + 3, hy + 1), 2)
        elif d == "arriba":
            pygame.draw.circle(pantalla, PELO, (hx, hy), 7)
        else:
            pygame.draw.circle(pantalla, PELO, (hx - lado, hy - 1), 7, draw_top_left=True, draw_top_right=True,
                               draw_bottom_left=lado > 0, draw_bottom_right=lado < 0)
            pygame.draw.line(pantalla, NEGRO, (hx + lado * 4, hy + 1), (hx + lado * 5, hy + 1), 2)
        pygame.draw.ellipse(pantalla, PELO, (hx - 3, hy - 12, 6, 5))
        pygame.draw.line(pantalla, HACHIMAKI, (hx - 7, hy - 3), (hx + 7, hy - 3), 2)
        ondeo = math.sin(tiempo * 9) * 2
        if d == "arriba":
            pygame.draw.line(pantalla, HACHIMAKI, (hx, hy - 3), (hx - 3 + ondeo, hy + 9), 2)
            pygame.draw.line(pantalla, HACHIMAKI, (hx, hy - 3), (hx + 3 + ondeo, hy + 8), 2)
        elif d != "abajo":
            largo = 12 if self.moviendose else 6
            pygame.draw.line(pantalla, HACHIMAKI, (hx - lado * 6, hy - 3),
                             (hx - lado * (6 + largo), hy - 2 + ondeo), 2)


# =============================================================================
# PLANICIE: ESCENA DEL MAPA ABIERTO
# =============================================================================

class EscenaPlanicie(Escena):
    """Salida del castillo y viaje libre por la planicie."""

    DURACION_SALIDA = 1.6
    FIN_TITULO = DURACION_SALIDA + 3.0

    def __init__(self, juego, vida=VIDA_MAXIMA):
        super().__init__(juego)
        self.mundo = Mundo()
        self.banda = pygame.Surface((ANCHO, 116), pygame.SRCALPHA)
        self.vida = vida
        self.viajero = AkiraViajero(PUERTA_CASTILLO[0], PUERTA_CASTILLO[1] - 14)
        self.salida = self.DURACION_SALIDA   # Akira sale solo por la puerta del castillo
        self.tiempo = 0.0
        self.mostrar_mapa = False
        self.mensaje = None
        self.lugar = None
        self.zona = None
        self.cartel = ""
        self.tiempo_cartel = 0.0
        self.camara_x = self.camara_y = 0.0
        self.actualizar_camara(0, instantaneo=True)

    # --- lógica ----------------------------------------------------------------

    def manejar_evento(self, evento):
        if evento.type != pygame.KEYDOWN or self.salida > 0:
            return
        if self.mensaje:
            if evento.key in (pygame.K_e,) + TECLAS_CONFIRMAR:
                self.mensaje = None
        elif evento.key == pygame.K_m:
            self.mostrar_mapa = not self.mostrar_mapa
        elif self.mostrar_mapa:
            if evento.key in TECLAS_CONFIRMAR:
                self.mostrar_mapa = False
        elif evento.key in (pygame.K_e, pygame.K_RETURN, pygame.K_KP_ENTER) and self.lugar:
            self.entrar(self.lugar)

    def entrar(self, lugar):
        """Punto de conexión con los próximos módulos (aldea, templo, dojo, ruinas)."""
        self.mensaje = (lugar["nombre"], lugar["mensaje"])

    def actualizar(self, dt):
        self.tiempo += dt
        viajero = self.viajero
        if self.salida > 0:
            self.salida -= dt
            viajero.caminar_solo(0, 1, 70, dt)
            if self.salida <= 0:
                self.mundo.objeto_castillo.imagen = self.mundo.imagen_castillo_cerrado
                self.zona = self.calcular_zona()
        elif self.mensaje or self.mostrar_mapa:
            viajero.detener()
        else:
            teclas = pygame.key.get_pressed()
            dx = ((1 if teclas[pygame.K_d] or teclas[pygame.K_RIGHT] else 0)
                  - (1 if teclas[pygame.K_a] or teclas[pygame.K_LEFT] else 0))
            dy = ((1 if teclas[pygame.K_s] or teclas[pygame.K_DOWN] else 0)
                  - (1 if teclas[pygame.K_w] or teclas[pygame.K_UP] else 0))
            corriendo = teclas[pygame.K_LSHIFT] or teclas[pygame.K_RSHIFT]
            viajero.mover(dx, dy, corriendo, dt, self.mundo)

        if self.salida <= 0:
            self.lugar = self.mundo.lugar_cercano(viajero.x, viajero.y)
            zona = self.calcular_zona()
            if zona != self.zona:
                self.zona = zona
                self.cartel = zona
                self.tiempo_cartel = 2.8
        self.tiempo_cartel = max(0.0, self.tiempo_cartel - dt)
        self.actualizar_camara(dt)

    def calcular_zona(self):
        for lugar in LUGARES:
            limite = lugar["radio_zona"] + (40 if self.zona == lugar["nombre"] else 0)
            if math.hypot(self.viajero.x - lugar["centro"][0], self.viajero.y - lugar["centro"][1]) < limite:
                return lugar["nombre"]
        return "La Planicie"

    def actualizar_camara(self, dt, instantaneo=False):
        objetivo_x = self.viajero.x - ANCHO / 2
        objetivo_y = self.viajero.y - ALTO / 2 - (80 if self.salida > 0 else 20)
        if instantaneo:
            self.camara_x, self.camara_y = objetivo_x, objetivo_y
        else:
            suavizado = min(1.0, dt * 6)
            self.camara_x += (objetivo_x - self.camara_x) * suavizado
            self.camara_y += (objetivo_y - self.camara_y) * suavizado
        self.camara_x = limitar(self.camara_x, 0, MUNDO_ANCHO - ANCHO)
        self.camara_y = limitar(self.camara_y, 0, MUNDO_ALTO - ALTO)

    # --- dibujo ----------------------------------------------------------------

    def dibujar(self, pantalla):
        cx, cy = int(self.camara_x), int(self.camara_y)
        pantalla.blit(self.mundo.suelo, (0, 0), (cx, cy, ANCHO, ALTO))
        self.mundo.dibujar_agua(pantalla, cx, cy, self.tiempo)
        self.mundo.dibujar_objetos(pantalla, cx, cy, self.viajero, self.tiempo)
        self.mundo.dibujar_nubes(pantalla, cx, cy, self.tiempo)
        self.dibujar_hud(pantalla)
        if self.mostrar_mapa:
            self.dibujar_mapa(pantalla)
        if self.mensaje:
            self.dibujar_mensaje(pantalla)

    def dibujar_hud(self, pantalla):
        juego = self.juego
        dibujar_vida(pantalla, juego.fuente, 20, 14, self.vida)

        minimapa, escala = self.mundo.minimapa, self.mundo.escala_minimapa
        mx, my = ANCHO - minimapa.get_width() - 16, 14
        pantalla.blit(minimapa, (mx, my))
        pygame.draw.rect(pantalla, DORADO, (mx - 2, my - 2, minimapa.get_width() + 4,
                                            minimapa.get_height() + 4), 2, border_radius=3)
        if int(self.tiempo * 3) % 3:
            pygame.draw.circle(pantalla, BLANCO, (mx + int(self.viajero.x * escala),
                                                  my + int(self.viajero.y * escala)), 4)
            pygame.draw.circle(pantalla, ROJO, (mx + int(self.viajero.x * escala),
                                                my + int(self.viajero.y * escala)), 3)
        dibujar_texto(pantalla, "M: mapa", juego.fuente_chica, CREMA,
                      (mx + minimapa.get_width() // 2, my + minimapa.get_height() + 6), "centro")
        if self.mensaje or self.mostrar_mapa:
            return   # el mapa y los mensajes se dibujan encima, sin carteles debajo

        mostrando_titulo = self.tiempo < self.FIN_TITULO
        if mostrando_titulo:   # título al salir del castillo
            opacidad = limitar(min(self.tiempo / 0.8, (self.FIN_TITULO - self.tiempo) / 1.0), 0, 1)
            self.banda.fill((8, 8, 14, int(140 * opacidad)))
            pantalla.blit(self.banda, (0, 368))
            dibujar_texto(pantalla, "LA PLANICIE", juego.fuente_titulo, DORADO,
                          (ANCHO // 2, 372), "centro", alfa=int(255 * opacidad))
            dibujar_texto(pantalla, "El castillo de Hoshiyama queda atrás.", juego.fuente, CREMA,
                          (ANCHO // 2, 446), "centro", alfa=int(255 * opacidad))
        elif self.tiempo_cartel > 0:
            alfa = int(255 * limitar(min((2.8 - self.tiempo_cartel) / 0.4, self.tiempo_cartel / 0.6), 0, 1))
            dibujar_texto(pantalla, self.cartel, juego.fuente_grande, CREMA, (ANCHO // 2, 70),
                          "centro", alfa=alfa)

        if self.lugar and not mostrando_titulo:
            rect = pygame.Rect(0, 0, 360, 62)
            rect.midbottom = (ANCHO // 2, ALTO - 20)
            dibujar_panel(pantalla, rect)
            dibujar_texto(pantalla, self.lugar["nombre"], juego.fuente, DORADO,
                          (rect.centerx, rect.top + 6), "centro")
            dibujar_texto(pantalla, "Pulsa E para entrar", juego.fuente_chica, CREMA,
                          (rect.centerx, rect.top + 34), "centro")
        elif self.FIN_TITULO < self.tiempo < self.FIN_TITULO + 10:   # ayuda de controles
            alfa = int(255 * limitar((self.tiempo - self.FIN_TITULO) / 0.6, 0, 1)
                       * limitar((self.FIN_TITULO + 10 - self.tiempo) / 1.5, 0, 1))
            dibujar_texto(pantalla, "WASD o flechas: moverse    SHIFT: correr    E: entrar    "
                                    "M: mapa    ESC: pausa",
                          juego.fuente_chica, CREMA, (ANCHO // 2, ALTO - 34), "centro", alfa=alfa)

    def dibujar_mapa(self, pantalla):
        juego = self.juego
        juego.velo.set_alpha(170)
        pantalla.blit(juego.velo, (0, 0))
        mapa, escala = self.mundo.mapa, self.mundo.escala_mapa
        x0, y0 = (ANCHO - mapa.get_width()) // 2, (ALTO - mapa.get_height()) // 2 + 8
        pantalla.blit(mapa, (x0, y0))
        pygame.draw.rect(pantalla, DORADO, (x0 - 3, y0 - 3, mapa.get_width() + 6, mapa.get_height() + 6),
                         3, border_radius=4)
        for lugar in LUGARES:
            x, y = lugar["entrada"]
            dibujar_texto(pantalla, lugar["nombre"], juego.fuente_chica, BLANCO,
                          (x0 + x * escala, y0 + y * escala + 8), "centro")
        px, py = x0 + int(self.viajero.x * escala), y0 + int(self.viajero.y * escala)
        pygame.draw.circle(pantalla, BLANCO, (px, py), 6)
        pygame.draw.circle(pantalla, ROJO, (px, py), 4)
        dibujar_texto(pantalla, "Akira", juego.fuente_chica, ROJO_CLARO, (px, py - 26), "centro")
        dibujar_texto(pantalla, "MAPA DE LA PLANICIE      M: cerrar", juego.fuente_chica, DORADO,
                      (ANCHO // 2, 4), "centro")

    def dibujar_mensaje(self, pantalla):
        juego = self.juego
        titulo, texto = self.mensaje
        rect = pygame.Rect(90, ALTO - 176, ANCHO - 180, 150)
        dibujar_panel(pantalla, rect, alfa=225)
        dibujar_texto(pantalla, titulo, juego.fuente_grande, DORADO, (rect.left + 24, rect.top + 14))
        y = rect.top + 64
        for linea in partir_en_lineas(texto, juego.fuente, rect.width - 48):
            dibujar_texto(pantalla, linea, juego.fuente, CREMA, (rect.left + 24, y))
            y += juego.fuente.get_linesize()
        dibujar_texto(pantalla, "E: cerrar", juego.fuente_chica, GRIS,
                      (rect.right - 20, rect.bottom - 28), "derecha")


# =============================================================================
# INICIO
# =============================================================================

def main():
    escena_inicial = "planicie" if "--planicie" in sys.argv else "intro"
    Juego(escena_inicial).ejecutar()


if __name__ == "__main__":
    main()
