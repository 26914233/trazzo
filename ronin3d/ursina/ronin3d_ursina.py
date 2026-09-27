# -*- coding: utf-8 -*-
"""
RONIN 3D · Capítulo 1: El castillo de Hoshiyama
===============================================
Versión en Ursina (motor 3D de Python sobre Panda3D) con estética HD-2D: sprites
pixel art de pie (billboard vertical) iluminados por la luna y las antorchas, escenario
3D con texturas pixel art repetidas por metro, niebla, resplandor y desenfoque de maqueta.

Sigue la especificación común ../DISENO_3D.md (medidas, personajes, cámara, controles).
Los sprites y texturas se leen de ../recursos/ sin modificarlos.

Uso
---
    pip install ursina
    python ronin3d_ursina.py            juego normal
    python ronin3d_ursina.py --ligero   sin sombras reales ni posproceso (PC muy justo)
    python ronin3d_ursina.py --prueba   prueba automática: simula teclas, comprueba el
                                        juego y guarda capturas en ../capturas/ (ursina_*)

Ejes
----
La especificación usa X este, Y arriba y Z sur (norte = −Z). Ursina usa un sistema de mano
izquierda con Z hacia delante, así que aquí el mundo es X este, Y arriba, Z norte. La
función `convertir()` pasa un punto de la especificación al mundo invirtiendo Z; todas las
medidas del patio están escritas tal cual en la especificación y se convierten al usarlas.
"""

import math
import random
import sys
import time
from pathlib import Path

MODO_PRUEBA = '--prueba' in sys.argv
MODO_LIGERO = '--ligero' in sys.argv

from panda3d.core import loadPrcFileData  # noqa: E402

loadPrcFileData('', 'audio-library-name null')      # el capítulo no tiene sonido
loadPrcFileData('', 'notify-level-device fatal')     # sin avisos de mandos o joysticks
if MODO_PRUEBA:
    loadPrcFileData('', 'sync-video #f')

from panda3d.core import (ColorBlendAttrib, Filename, Point2, Point3, SamplerState,  # noqa: E402
                          TextNode, TransparencyAttrib)
from PIL import Image, ImageDraw  # noqa: E402  (Pillow se instala con Ursina)
from ursina import (AmbientLight, Color, DirectionalLight, Entity, Mesh, PointLight,  # noqa: E402
                    Shader, Text, Texture, Ursina, Vec2, Vec3, Vec4, application, camera,
                    held_keys, mouse, window)


# =============================================================================
# CONFIGURACIÓN
# =============================================================================

CARPETA_JUEGO = Path(__file__).resolve().parent
CARPETA_RECURSOS = CARPETA_JUEGO.parent / 'recursos'
CARPETA_CAPTURAS = CARPETA_JUEGO.parent / 'capturas'

ANCHO_VENTANA, ALTO_VENTANA = 1280, 720
ROTULO_MOTOR = 'Ursina · HD-2D'
PASO_PRUEBA = 1 / 30            # la prueba avanza con un paso fijo (independiente de los FPS)
PASO_MAXIMO_FISICA = 1 / 60     # subpasos de física para no atravesar nada

# --- Textos (copiados tal cual de samurai.py) ---------------------------------
TITULO = 'RONIN'
SUBTITULO = 'Capítulo 1 · El castillo de Hoshiyama'

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

TEXTO_AYUDA = ('WASD / flechas: moverse · SHIFT: correr · ESPACIO: saltar · J / clic: atacar\n'
               'Q / E o botón derecho: girar la cámara · rueda o + / −: zoom · '
               'R / F: inclinar · ESC: pausa')
VELOCIDAD_TEXTO = 45            # letras por segundo, como en samurai.py
DURACION_FUNDIDO = 0.45
DURACION_AYUDA = 10.0

# --- Patio (medidas de la especificación, en sus ejes: X este, Y arriba, Z sur) ---
MUROS = [((0, 2, -16.5), (50, 4, 1)), ((0, 2, 16.5), (50, 4, 1)), ((-24.5, 2, 0), (1, 4, 32)),
         ((24.5, 2, -9.5), (1, 4, 13)), ((24.5, 2, 9.5), (1, 4, 13))]
ALTURA_PIEDRA = 1.2             # base de piedra de los muros; encima, yeso blanco
PORTON = ((24.6, 2.2, 0), (0.3, 4.4, 6))
POSTES_PORTON = [((24.5, 2.5, 3.5), (1, 5, 1)), ((24.5, 2.5, -3.5), (1, 5, 1))]
DINTEL_PORTON = ((24.5, 5.3, 0), (1.4, 0.6, 8.5))
PASARELA = ((-3, 0.6, -12), (10, 1.2, 4))
ESCALON = ((-3, 0.3, -9.5), (2, 0.6, 1))
MURO_BAJO = ((-8, 0.6, 4), (0.8, 1.2, 6))
BLOQUES = [((6, 0.4, -6), (2, 0.8, 2)), ((8.2, 0.8, -6), (2, 1.6, 2))]
LINTERNAS = [(12, 8), (12, -8), (-12, 8), (-12, -8)]          # cilindro r 0,4, alto 1,6
POZO = (0, 8)                                                   # cilindro r 1,0, alto 0,9
CAJAS = [(16, 0.5, 12), (17.2, 0.5, 12.4), (16.6, 1.5, 12.2)]
BARRILES = [(-18, 0.5, -12), (-18.9, 0.5, -11.3)]               # cilindro r 0,45, alto 1
ANTORCHAS = [(-12, -14.5), (8, -14.5), (-8, 14.5), (8, 14.5),
             (-23, -6), (-23, 6), (22.5, -4.5), (22.5, 4.5)]
CENTRO_TORREON = (0, -32)
DIRECCION_LUNA = (-0.3, 0.32, -0.9)                             # hacia la luna

# --- Personajes ---------------------------------------------------------------
ESCALA_PIXEL = 0.04             # metros por píxel de sprite
INICIO_AKIRA = (-20, 0, 0)
ALTURA_AKIRA = 1.7
RADIO_PERSONAJE = 0.35
VEL_CAMINAR = 5.0
VEL_CORRER = 8.0
VEL_SALTO = 7.5
GRAVEDAD = 22.0
VIDA_MAXIMA = 5
TIEMPO_INVULNERABLE = 1.0
VEL_RETROCESO = 6.0
TIEMPO_RETROCESO = 0.25
DURACION_ATAQUE = 0.3
INICIO_CORTE, FIN_CORTE = 0.05, 0.2
ALCANCE_ESPADA = 1.6
ANGULO_ESPADA = 100.0
ENFRIAMIENTO_ATAQUE = 0.4
TIEMPO_CAIDA = 1.2              # caer y desvanecerse

PATRULLAS = [((-14, 0, -4), (-14, 0, 6)), ((-7, 1.2, -12), (1, 1.2, -12)),
             ((-2, 0, 4), (6, 0, 10)), ((10, 0, -12), (16, 0, -4)),
             ((8, 0, 2), (16, 0, 8)), ((19, 0, -2), (19, 0, 2))]
VIDA_SOLDADO = 2
VEL_PATRULLA = 2.0
VEL_PERSECUCION = 3.5
DISTANCIA_VISION = 9.0
ANGULO_VISION = 120.0
DISTANCIA_OIDO = 3.0
CORREA = 8.0
DISTANCIA_ATAQUE = 1.8
TIEMPO_AVISO = 0.5
TIEMPO_ESTOCADA = 0.2
ALCANCE_LANZA = 2.1
ANCHO_LANZA = 0.8
TIEMPO_RECUPERACION = 0.6
TIEMPO_ATURDIDO = 0.4
VEL_RETROCESO_SOLDADO = 5.0
TIEMPO_OLVIDO = 2.0
ALTURA_LANZA = 1.05             # altura de la estocada sobre los pies del soldado

# --- Cámara -------------------------------------------------------------------
CAMARA_DISTANCIA = 12.0
CAMARA_INCLINACION = 38.0
CAMARA_GIRO = -60.0
CAMARA_FOV = 38.0               # vertical, como en Three.js y Godot
CAMARA_VEL_GIRO = 90.0
CAMARA_VEL_INCLINACION = 45.0
CAMARA_VEL_ZOOM = 6.0
CAMARA_PASO_RUEDA = 1.2
CAMARA_DIST_MIN, CAMARA_DIST_MAX = 7.0, 18.0
CAMARA_INCL_MIN, CAMARA_INCL_MAX = -5.0, 60.0
PRESENTACION_POSICION = (6, 3, 12)
PRESENTACION_MIRA = (0, 9, -20)
DURACION_TRANSICION = 1.0

# --- Luz y color --------------------------------------------------------------
COLOR_ANTORCHA = '#ffae5c'
COLOR_LUNA = '#9fb4ff'
COLOR_AMBIENTE = '#1a1f3a'
CIELO_ARRIBA = '#06081a'
CIELO_HORIZONTE = '#2a244c'
INTENSIDAD_AMBIENTE = 1.25
INTENSIDAD_LUNA = 0.55
INTENSIDAD_ANTORCHA = 1.25
ALCANCE_ANTORCHA = 9.0
INTENSIDAD_LINTERNA = 0.55
ALCANCE_LINTERNA = 3.5
DENSIDAD_NIEBLA = 0.012
NUM_LUCES = 1 + len(ANTORCHAS) + len(LINTERNAS)     # luna + antorchas + linternas

BLANCO = (1.0, 1.0, 1.0, 1.0)
MADERA_OSCURA = (0.5, 0.42, 0.38, 1.0)
MADERA_BARRIL = (0.85, 0.72, 0.6, 1.0)
HIERRO = (0.22, 0.22, 0.26, 1.0)
ORO = (0.95, 0.74, 0.3, 1.0)
PIEDRA_LINTERNA = (0.82, 0.82, 0.88, 1.0)
AGUA = (0.05, 0.07, 0.12, 1.0)

DORADO = (226, 186, 98)
CREMA = (238, 228, 200)
GRIS = (160, 160, 176)
ROJO = (200, 50, 46)


def color_rgb(rgb, alfa=1.0):
    return Color(rgb[0] / 255, rgb[1] / 255, rgb[2] / 255, alfa)


def color_hex(codigo, intensidad=1.0, alfa=1.0):
    codigo = codigo.lstrip('#')
    r, g, b = (int(codigo[i:i + 2], 16) / 255 for i in (0, 2, 4))
    return Color(r * intensidad, g * intensidad, b * intensidad, alfa)


# =============================================================================
# UTILIDADES MATEMÁTICAS (tuplas simples: más rápidas que Vec3 en Python)
# =============================================================================

def convertir(x, y, z):
    """Punto de la especificación (Z al sur) → mundo de Ursina (Z al norte)."""
    return (x, y, -z)


def sumar(a, b):
    return (a[0] + b[0], a[1] + b[1], a[2] + b[2])


def restar(a, b):
    return (a[0] - b[0], a[1] - b[1], a[2] - b[2])


def escalar(a, k):
    return (a[0] * k, a[1] * k, a[2] * k)


def producto_escalar(a, b):
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]


def producto_vectorial(a, b):
    return (a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0])


def longitud(a):
    return math.sqrt(producto_escalar(a, a))


def normalizar(a):
    largo = longitud(a)
    return (0.0, 0.0, 0.0) if largo < 1e-9 else escalar(a, 1 / largo)


def limitar(valor, minimo, maximo):
    return max(minimo, min(maximo, valor))


def suavizar(t):
    t = limitar(t, 0.0, 1.0)
    return t * t * (3 - 2 * t)


def mezclar(a, b, t):
    return a + (b - a) * t


def mezclar_puntos(a, b, t):
    return tuple(mezclar(a[i], b[i], t) for i in range(3))


def angulo_corto(grados):
    """Lleva un ángulo a (−180, 180]."""
    return (grados + 180.0) % 360.0 - 180.0


def distancia_a_segmento(px, pz, ax, az, bx, bz):
    dx, dz = bx - ax, bz - az
    largo2 = dx * dx + dz * dz
    t = 0.0 if largo2 < 1e-9 else limitar(((px - ax) * dx + (pz - az) * dz) / largo2, 0.0, 1.0)
    cx, cz = ax + dx * t, az + dz * t
    return math.hypot(px - cx, pz - cz)


# =============================================================================
# SOMBREADORES (GLSL)
# =============================================================================

VERTICES_COMUN = '''
#version 130
uniform mat4 p3d_ModelViewProjectionMatrix;
uniform mat4 p3d_ModelViewMatrix;
uniform mat4 p3d_ModelMatrix;
uniform mat3 p3d_NormalMatrix;
uniform vec2 texture_scale;
uniform vec2 texture_offset;
in vec4 p3d_Vertex;
in vec3 p3d_Normal;
in vec2 p3d_MultiTexCoord0;
in vec4 p3d_Color;
out vec2 coord_textura;
out vec3 posicion_vista;
out vec3 posicion_mundo;
out vec3 normal_vista;
out vec4 color_vertice;
void main() {
    gl_Position = p3d_ModelViewProjectionMatrix * p3d_Vertex;
    posicion_vista = (p3d_ModelViewMatrix * p3d_Vertex).xyz;
    posicion_mundo = (p3d_ModelMatrix * p3d_Vertex).xyz;
    normal_vista = normalize(p3d_NormalMatrix * p3d_Normal);
    coord_textura = p3d_MultiTexCoord0 * texture_scale + texture_offset;
    color_vertice = p3d_Color;
}
'''

# Luz por píxel: ambiente + luna (con sombra) + antorchas y linternas (luces puntuales con
# alcance). La luna se liga aparte como estructura para no indexar muestreadores en bucles.
FRAGMENTOS_ILUMINADO = '''
#version 130
const int NUM_LUCES = %d;
uniform struct {
    vec4 color;
    vec4 position;
    vec3 attenuation;
} p3d_LightSource[NUM_LUCES];
uniform struct {
    vec4 color;
    vec4 position;
    sampler2DShadow shadowMap;
    mat4 shadowViewMatrix;
} luna;
uniform struct { vec4 ambient; } p3d_LightModel;
uniform sampler2D p3d_Texture0;
uniform vec4 p3d_ColorScale;

uniform float envoltura;        // luz envolvente (sprites: la luz de detrás también alumbra)
uniform float umbral_alfa;      // recorte de transparencia (sprites pixel art)
uniform vec4 destello;          // color del destello al recibir un golpe (a = cantidad)
uniform float opacidad;         // < 1: desvanecer con tramado (sin ordenar transparencias)
uniform float recortable;       // 1: se abre un hueco si tapa a Akira
uniform vec4 recorte;           // x, y (píxeles), radio (píxeles), distancia de Akira
uniform float altura_corte;     // tramo de muralla que tapa a Akira: se corta a esta altura
uniform float usar_sombras;
uniform vec3 color_niebla;
uniform float densidad_niebla;

in vec2 coord_textura;
in vec3 posicion_vista;
in vec3 posicion_mundo;
in vec3 normal_vista;
in vec4 color_vertice;
out vec4 color_salida;

float umbral_bayer(vec2 p) {
    int x = int(mod(p.x, 4.0));
    int y = int(mod(p.y, 4.0));
    float m[16] = float[16](0.0, 8.0, 2.0, 10.0, 12.0, 4.0, 14.0, 6.0,
                            3.0, 11.0, 1.0, 9.0, 15.0, 7.0, 13.0, 5.0);
    return (m[x + y * 4] + 0.5) / 16.0;
}

void main() {
    if (posicion_mundo.y > altura_corte) discard;
    vec4 base = texture(p3d_Texture0, coord_textura) * color_vertice * p3d_ColorScale;
    if (base.a < umbral_alfa) discard;
    float umbral = umbral_bayer(gl_FragCoord.xy);
    if (opacidad < 0.999 && opacidad <= umbral) discard;
    float distancia = length(posicion_vista);
    if (recortable > 0.5 && recorte.z > 0.0 && distancia < recorte.w - 1.0) {
        float r = length(gl_FragCoord.xy - recorte.xy) / recorte.z;
        if (umbral > smoothstep(0.55, 1.0, r)) discard;
    }

    vec3 N = normalize(normal_vista);
    if (!gl_FrontFacing) N = -N;
    vec3 luz = p3d_LightModel.ambient.rgb;

    // Luna (direccional, con sombra)
    vec3 L = normalize(luna.position.xyz);
    float difusa = clamp((dot(N, L) + envoltura) / (1.0 + envoltura), 0.0, 1.0);
    float sombra = 1.0;
    if (usar_sombras > 0.5 && difusa > 0.0) {
        vec4 coord = luna.shadowViewMatrix * vec4(posicion_vista + N * 0.06, 1.0);
        vec3 c = coord.xyz / coord.w;
        if (c.x > 0.0 && c.x < 1.0 && c.y > 0.0 && c.y < 1.0 && c.z < 1.0) {
            sombra = textureProj(luna.shadowMap, coord);
        }
    }
    luz += luna.color.rgb * difusa * sombra;

    // Antorchas y linternas
    for (int i = 0; i < NUM_LUCES; ++i) {
        vec4 p = p3d_LightSource[i].position;
        if (p.w == 0.0) continue;
        vec3 hacia_luz = p.xyz - posicion_vista;
        float d2 = dot(hacia_luz, hacia_luz);
        float t = clamp(1.0 - d2 * p3d_LightSource[i].attenuation.z, 0.0, 1.0);
        if (t <= 0.0) continue;
        vec3 Lp = hacia_luz * inversesqrt(d2);
        float dp = clamp((dot(N, Lp) + envoltura) / (1.0 + envoltura), 0.0, 1.0);
        luz += p3d_LightSource[i].color.rgb * dp * t * t;
    }

    vec3 color = base.rgb * luz;
    color = mix(color, destello.rgb, destello.a);
    float niebla = 1.0 - exp(-pow(densidad_niebla * distancia, 2.0));
    color = mix(color, color_niebla, niebla);
    color_salida = vec4(color, 1.0);
}
''' % NUM_LUCES

# Sin luz: llamas, ventanas encendidas, cielo, luna, halos, sombras de los pies, efectos.
FRAGMENTOS_SIN_LUZ = '''
#version 130
uniform sampler2D p3d_Texture0;
uniform vec4 p3d_ColorScale;
uniform float umbral_alfa;
uniform float con_niebla;       // 0: sin niebla · 1: mezcla con la niebla · 2: aditivo (se apaga)
uniform vec3 color_niebla;
uniform float densidad_niebla;
in vec2 coord_textura;
in vec3 posicion_vista;
in vec3 normal_vista;
in vec4 color_vertice;
out vec4 color_salida;
void main() {
    vec4 c = texture(p3d_Texture0, coord_textura) * color_vertice * p3d_ColorScale;
    if (c.a < umbral_alfa) discard;
    if (con_niebla > 0.5) {
        float niebla = 1.0 - exp(-pow(densidad_niebla * length(posicion_vista), 2.0));
        if (con_niebla > 1.5) c.rgb *= 1.0 - niebla;
        else c.rgb = mix(c.rgb, color_niebla, niebla);
    }
    color_salida = c;
}
'''

# Posproceso HD-2D: desenfoque de maqueta arriba y abajo, resplandor barato y viñeta.
VERTICES_POSPROCESO = '''
#version 130
uniform mat4 p3d_ModelViewProjectionMatrix;
in vec4 p3d_Vertex;
in vec2 p3d_MultiTexCoord0;
out vec2 uv;
void main() {
    gl_Position = p3d_ModelViewProjectionMatrix * p3d_Vertex;
    uv = p3d_MultiTexCoord0;
}
'''

FRAGMENTOS_POSPROCESO = '''
#version 130
uniform sampler2D tex;
uniform vec2 window_size;
uniform float desenfoque_maximo;    // píxeles en los bordes superior e inferior
uniform float franja_nitida;        // media altura de la franja central nítida (0..0.5)
uniform float fuerza_resplandor;
uniform float umbral_resplandor;
in vec2 uv;
out vec4 color_salida;

const vec2 DISCO[12] = vec2[12](
    vec2(-0.326, -0.406), vec2(-0.840, -0.074), vec2(-0.696, 0.457), vec2(-0.203, 0.621),
    vec2(0.962, -0.195), vec2(0.473, -0.480), vec2(0.519, 0.767), vec2(0.185, -0.893),
    vec2(0.507, 0.064), vec2(0.896, 0.412), vec2(-0.322, -0.933), vec2(-0.792, -0.598));

void main() {
    vec2 px = 1.0 / window_size;
    vec3 base = texture(tex, uv).rgb;
    vec3 color = base;
    float cantidad = smoothstep(franja_nitida, 0.5, abs(uv.y - 0.5));
    if (cantidad > 0.01) {
        vec3 suma = base;
        for (int i = 0; i < 12; ++i)
            suma += texture(tex, uv + DISCO[i] * cantidad * desenfoque_maximo * px).rgb;
        color = suma / 13.0;
    }
    vec3 brillo = vec3(0.0);
    for (int i = 0; i < 12; ++i) {
        vec3 cerca = texture(tex, uv + DISCO[i] * 7.0 * px).rgb;
        vec3 lejos = texture(tex, uv + DISCO[i].yx * 18.0 * px).rgb;
        brillo += max(cerca - umbral_resplandor, 0.0) + 0.7 * max(lejos - umbral_resplandor, 0.0);
    }
    color += brillo / 12.0 * fuerza_resplandor;
    vec2 c = uv - 0.5;
    c.x *= window_size.x / window_size.y;
    color *= 1.0 - 0.32 * smoothstep(0.45, 1.05, length(c));
    color_salida = vec4(color, 1.0);
}
'''

SOMBREADOR_ILUMINADO = Shader(name='ronin_iluminado', language=Shader.GLSL,
                              vertex=VERTICES_COMUN, fragment=FRAGMENTOS_ILUMINADO,
                              default_input={'texture_scale': Vec2(1, 1), 'texture_offset': Vec2(0, 0)})
SOMBREADOR_SIN_LUZ = Shader(name='ronin_sin_luz', language=Shader.GLSL,
                            vertex=VERTICES_COMUN, fragment=FRAGMENTOS_SIN_LUZ,
                            default_input={'texture_scale': Vec2(1, 1), 'texture_offset': Vec2(0, 0)})
SOMBREADOR_POSPROCESO = Shader(name='ronin_posproceso', language=Shader.GLSL,
                               vertex=VERTICES_POSPROCESO, fragment=FRAGMENTOS_POSPROCESO,
                               default_input={'desenfoque_maximo': 4.5, 'franja_nitida': 0.2,
                                              'fuerza_resplandor': 0.55, 'umbral_resplandor': 0.62,
                                              'window_size': Vec2(ANCHO_VENTANA, ALTO_VENTANA)})


def poner_valores_por_defecto():
    """Valores de todos los uniformes propios en la raíz de la escena (los hereda todo)."""
    raiz = application.base.render
    raiz.set_shader_input('texture_scale', Vec2(1, 1))
    raiz.set_shader_input('texture_offset', Vec2(0, 0))
    raiz.set_shader_input('envoltura', 0.0)
    raiz.set_shader_input('umbral_alfa', 0.0)
    raiz.set_shader_input('destello', Vec4(1, 1, 1, 0))
    raiz.set_shader_input('opacidad', 1.0)
    raiz.set_shader_input('recortable', 0.0)
    raiz.set_shader_input('recorte', Vec4(0, 0, 0, 0))
    raiz.set_shader_input('altura_corte', 1000.0)
    raiz.set_shader_input('usar_sombras', 0.0 if MODO_LIGERO else 1.0)
    raiz.set_shader_input('con_niebla', 1.0)
    niebla = color_hex(CIELO_HORIZONTE, 0.78)
    raiz.set_shader_input('color_niebla', Vec3(niebla[0], niebla[1], niebla[2]))
    raiz.set_shader_input('densidad_niebla', DENSIDAD_NIEBLA)


# =============================================================================
# TEXTURAS
# =============================================================================

def ajustar_textura(textura, suave=False, repetir=True):
    textura.filtering = 'bilinear' if suave else None      # None = nearest: píxel nítido
    modo = SamplerState.WM_repeat if repetir else SamplerState.WM_clamp
    textura._texture.set_wrap_u(modo)
    textura._texture.set_wrap_v(modo)
    return textura


def cargar_textura(nombre, repetir=True):
    ruta = CARPETA_RECURSOS / nombre
    if not ruta.exists():
        raise FileNotFoundError(f'Falta el recurso {ruta}')
    return ajustar_textura(Texture(ruta), repetir=repetir)


def textura_de_imagen(imagen, suave=False, repetir=False):
    return ajustar_textura(Texture(imagen.convert('RGBA')), suave=suave, repetir=repetir)


def imagen_tierra():
    """Tierra oscura del exterior (32 × 32, generada aquí; no se toca recursos/)."""
    azar = random.Random(11)
    imagen = Image.new('RGBA', (32, 32))
    pixeles = imagen.load()
    for y in range(32):
        for x in range(32):
            v = azar.randint(-5, 5)
            pixeles[x, y] = (44 + v, 40 + v, 44 + v, 255)
    for _ in range(46):
        x, y = azar.randint(0, 31), azar.randint(0, 31)
        v = azar.choice((-14, -10, 12, 16))
        pixeles[x, y] = (44 + v, 40 + v, 42 + v, 255)
    return imagen


def imagen_ventana():
    """Ventana de papel iluminada desde dentro, con listones (8 × 12)."""
    imagen = Image.new('RGBA', (8, 12), (46, 28, 20, 255))
    dibujo = ImageDraw.Draw(imagen)
    dibujo.rectangle((1, 1, 6, 10), fill=(255, 190, 104, 255))
    dibujo.rectangle((2, 2, 5, 9), fill=(255, 216, 150, 255))
    dibujo.line((4, 1, 4, 10), fill=(120, 70, 36, 255))
    dibujo.line((1, 4, 6, 4), fill=(120, 70, 36, 255))
    dibujo.line((1, 7, 6, 7), fill=(120, 70, 36, 255))
    return imagen


def imagen_halo():
    """Resplandor radial suave (blanco con alfa decreciente)."""
    lado = 64
    imagen = Image.new('RGBA', (lado, lado))
    pixeles = imagen.load()
    for y in range(lado):
        for x in range(lado):
            d = math.hypot(x - lado / 2 + 0.5, y - lado / 2 + 0.5) / (lado / 2)
            alfa = max(0.0, 1.0 - d) ** 2.2
            pixeles[x, y] = (255, 255, 255, int(255 * alfa))
    return imagen


def imagen_exclamacion():
    """«!» rojo pixel art con contorno oscuro (8 × 16)."""
    imagen = Image.new('RGBA', (8, 16), (0, 0, 0, 0))
    dibujo = ImageDraw.Draw(imagen)
    contorno = (20, 12, 16, 255)
    dibujo.rectangle((2, 0, 5, 10), fill=contorno)
    dibujo.rectangle((2, 12, 5, 15), fill=contorno)
    dibujo.rectangle((3, 1, 4, 9), fill=(236, 58, 46, 255))
    dibujo.rectangle((3, 13, 4, 14), fill=(236, 58, 46, 255))
    dibujo.point((3, 1), fill=(255, 150, 130, 255))
    return imagen


def cargar_texturas():
    return {
        'akira': cargar_textura('akira.png', repetir=False),
        'soldado': cargar_textura('soldado.png', repetir=False),
        'losa': cargar_textura('losa.png'),
        'piedra': cargar_textura('muro_piedra.png'),
        'yeso': cargar_textura('yeso.png'),
        'madera': cargar_textura('madera.png'),
        'tejas': cargar_textura('tejas.png'),
        'porton': cargar_textura('porton.png', repetir=False),
        'fuego': cargar_textura('fuego.png', repetir=False),
        'sombra': cargar_textura('sombra.png', repetir=False),
        'luna': cargar_textura('luna.png', repetir=False),
        'tajo': cargar_textura('tajo.png', repetir=False),
        'tierra': textura_de_imagen(imagen_tierra(), repetir=True),
        'ventana': textura_de_imagen(imagen_ventana()),
        'halo': textura_de_imagen(imagen_halo(), suave=True),
        'exclamacion': textura_de_imagen(imagen_exclamacion()),
        'liso': textura_de_imagen(Image.new('RGBA', (4, 4), (255, 255, 255, 255)), repetir=True),
    }


TEXTURAS = {}


# =============================================================================
# MALLAS
# =============================================================================

class ConstructorMalla:
    """Acumula caras en coordenadas del mundo y crea una sola malla por material
    (una sola llamada de dibujo). Las UV van en metros × densidad: la textura se repite
    por metro y no se estira, sea cual sea el tamaño de la pieza."""

    def __init__(self):
        self.vertices = []
        self.triangulos = []
        self.uvs = []
        self.normales = []
        self.colores = []

    @property
    def vacio(self):
        return not self.vertices

    def poligono(self, puntos, normal, arriba, densidad=1.0, tinte=BLANCO, uvs=None):
        """Polígono plano convexo. 'normal' apunta hacia fuera y 'arriba' es el sentido
        vertical de la textura sobre la cara (se corrige para que sea perpendicular)."""
        normal = normalizar(normal)
        derecha = normalizar(producto_vectorial(normal, arriba))
        arriba = producto_vectorial(derecha, normal)
        lista = list(puntos)
        lista_uv = list(uvs) if uvs else None
        # En Ursina la cara visible tiene (p1 − p0) × (p2 − p0) opuesto a la normal.
        cruz = producto_vectorial(restar(lista[1], lista[0]), restar(lista[2], lista[0]))
        if producto_escalar(cruz, normal) > 0:
            lista.reverse()
            if lista_uv:
                lista_uv.reverse()
        inicio = len(self.vertices)
        for i, p in enumerate(lista):
            self.vertices.append(p)
            self.normales.append(normal)
            self.colores.append(tinte)
            if lista_uv:
                self.uvs.append(lista_uv[i])
            else:
                self.uvs.append((producto_escalar(p, derecha) * densidad,
                                 producto_escalar(p, arriba) * densidad))
        for i in range(1, len(lista) - 1):
            self.triangulos.extend((inicio, inicio + i, inicio + i + 1))

    def caja(self, centro, tamano, densidad=1.0, tinte=BLANCO, con_base=False, caras=None):
        cx, cy, cz = centro
        sx, sy, sz = tamano
        x0, x1 = cx - sx / 2, cx + sx / 2
        y0, y1 = cy - sy / 2, cy + sy / 2
        z0, z1 = cz - sz / 2, cz + sz / 2
        todas = {
            'x+': ([(x1, y0, z0), (x1, y0, z1), (x1, y1, z1), (x1, y1, z0)], (1, 0, 0), (0, 1, 0)),
            'x-': ([(x0, y0, z0), (x0, y0, z1), (x0, y1, z1), (x0, y1, z0)], (-1, 0, 0), (0, 1, 0)),
            'z+': ([(x0, y0, z1), (x1, y0, z1), (x1, y1, z1), (x0, y1, z1)], (0, 0, 1), (0, 1, 0)),
            'z-': ([(x0, y0, z0), (x1, y0, z0), (x1, y1, z0), (x0, y1, z0)], (0, 0, -1), (0, 1, 0)),
            'y+': ([(x0, y1, z0), (x1, y1, z0), (x1, y1, z1), (x0, y1, z1)], (0, 1, 0), (0, 0, 1)),
            'y-': ([(x0, y0, z0), (x1, y0, z0), (x1, y0, z1), (x0, y0, z1)], (0, -1, 0), (0, 0, 1)),
        }
        for clave, (puntos, normal, arriba) in todas.items():
            if caras is not None and clave not in caras:
                continue
            if caras is None and clave == 'y-' and not con_base:
                continue
            self.poligono(puntos, normal, arriba, densidad, tinte)

    def suelo(self, centro, ancho, fondo, densidad=1.0, tinte=BLANCO):
        cx, y, cz = centro
        self.poligono([(cx - ancho / 2, y, cz - fondo / 2), (cx + ancho / 2, y, cz - fondo / 2),
                       (cx + ancho / 2, y, cz + fondo / 2), (cx - ancho / 2, y, cz + fondo / 2)],
                      (0, 1, 0), (0, 0, 1), densidad, tinte)

    def tejado_dos_aguas(self, centro_base, largo, ancho, alto, eje, densidad=1.0, tinte=BLANCO,
                         tinte_lados=(0.55, 0.55, 0.62, 1.0)):
        """Tejadillo a dos aguas con la cumbrera a lo largo de 'eje' ('x' o 'z')."""
        cx, y0, cz = centro_base
        y1 = y0 + alto
        m = ancho / 2
        if eje == 'x':
            a, b = cx - largo / 2, cx + largo / 2
            self.poligono([(a, y0, cz + m), (b, y0, cz + m), (b, y1, cz), (a, y1, cz)],
                          (0, m, alto), (0, alto, -m), densidad, tinte)
            self.poligono([(a, y0, cz - m), (b, y0, cz - m), (b, y1, cz), (a, y1, cz)],
                          (0, m, -alto), (0, alto, m), densidad, tinte)
            for x, signo in ((a, -1), (b, 1)):
                self.poligono([(x, y0, cz - m), (x, y0, cz + m), (x, y1, cz)],
                              (signo, 0, 0), (0, 1, 0), densidad, tinte_lados)
            self.poligono([(a, y0, cz - m), (b, y0, cz - m), (b, y0, cz + m), (a, y0, cz + m)],
                          (0, -1, 0), (0, 0, 1), densidad, tinte_lados)
        else:
            a, b = cz - largo / 2, cz + largo / 2
            self.poligono([(cx + m, y0, a), (cx + m, y0, b), (cx, y1, b), (cx, y1, a)],
                          (alto, m, 0), (-m, alto, 0), densidad, tinte)
            self.poligono([(cx - m, y0, a), (cx - m, y0, b), (cx, y1, b), (cx, y1, a)],
                          (-alto, m, 0), (m, alto, 0), densidad, tinte)
            for z, signo in ((a, -1), (b, 1)):
                self.poligono([(cx - m, y0, z), (cx + m, y0, z), (cx, y1, z)],
                              (0, 0, signo), (0, 1, 0), densidad, tinte_lados)
            self.poligono([(cx - m, y0, a), (cx + m, y0, a), (cx + m, y0, b), (cx - m, y0, b)],
                          (0, -1, 0), (1, 0, 0), densidad, tinte_lados)

    def tronco_piramide(self, centro_base, abajo, arriba, alto, densidad=1.0, tinte=BLANCO,
                        con_tapa=True, con_base=False, tinte_base=(0.5, 0.5, 0.56, 1.0)):
        """Tejado a cuatro aguas (o tronco de pirámide): base 'abajo' (x, z) en y y
        techo 'arriba' (x, z) en y + alto. Con arriba = (l, 0) queda una cumbrera."""
        cx, y0, cz = centro_base
        y1 = y0 + alto
        ax, az = abajo[0] / 2, abajo[1] / 2
        bx, bz = arriba[0] / 2, arriba[1] / 2
        lados = [
            ([(cx - ax, y0, cz + az), (cx + ax, y0, cz + az), (cx + bx, y1, cz + bz), (cx - bx, y1, cz + bz)], (0, 0, 1)),
            ([(cx - ax, y0, cz - az), (cx + ax, y0, cz - az), (cx + bx, y1, cz - bz), (cx - bx, y1, cz - bz)], (0, 0, -1)),
            ([(cx + ax, y0, cz - az), (cx + ax, y0, cz + az), (cx + bx, y1, cz + bz), (cx + bx, y1, cz - bz)], (1, 0, 0)),
            ([(cx - ax, y0, cz - az), (cx - ax, y0, cz + az), (cx - bx, y1, cz + bz), (cx - bx, y1, cz - bz)], (-1, 0, 0)),
        ]
        for puntos, fuera in lados:
            p0, p1, p2, p3 = puntos
            subida = restar(escalar(sumar(p2, p3), 0.5), escalar(sumar(p0, p1), 0.5))
            normal = normalizar(producto_vectorial(restar(p1, p0), subida))
            if producto_escalar(normal, fuera) < 0:
                normal = escalar(normal, -1)
            if longitud(restar(p2, p3)) < 0.05:
                puntos = [p0, p1, p2]
            self.poligono(puntos, normal, subida, densidad, tinte)
        if con_tapa and bx > 0.05 and bz > 0.05:
            self.suelo((cx, y1, cz), 2 * bx, 2 * bz, densidad, tinte)
        if con_base:
            self.poligono([(cx - ax, y0, cz - az), (cx + ax, y0, cz - az), (cx + ax, y0, cz + az), (cx - ax, y0, cz + az)],
                          (0, -1, 0), (0, 0, 1), densidad, tinte_base)

    def cilindro(self, centro_base, radio, alto, lados=12, densidad=1.0, tinte=BLANCO,
                 con_tapa=True, hacia_dentro=False):
        cx, y0, cz = centro_base
        y1 = y0 + alto
        for i in range(lados):
            a0 = 2 * math.pi * i / lados
            a1 = 2 * math.pi * (i + 1) / lados
            am = (a0 + a1) / 2
            p0 = (cx + radio * math.cos(a0), y0, cz + radio * math.sin(a0))
            p1 = (cx + radio * math.cos(a1), y0, cz + radio * math.sin(a1))
            p2 = (p1[0], y1, p1[2])
            p3 = (p0[0], y1, p0[2])
            normal = (math.cos(am), 0, math.sin(am))
            if hacia_dentro:
                normal = escalar(normal, -1)
            u0, u1 = a0 * radio * densidad, a1 * radio * densidad
            v0, v1 = y0 * densidad, y1 * densidad
            self.poligono([p0, p1, p2, p3], normal, (0, 1, 0), tinte=tinte,
                          uvs=[(u0, v0), (u1, v0), (u1, v1), (u0, v1)])
        if con_tapa:
            puntos = [(cx + radio * math.cos(2 * math.pi * i / lados), y1,
                       cz + radio * math.sin(2 * math.pi * i / lados)) for i in range(lados)]
            self.poligono(puntos, (0, 1, 0), (0, 0, 1), densidad, tinte)

    def anillo(self, centro, radio_dentro, radio_fuera, lados=16, densidad=1.0, tinte=BLANCO):
        cx, y, cz = centro
        for i in range(lados):
            a0 = 2 * math.pi * i / lados
            a1 = 2 * math.pi * (i + 1) / lados
            self.poligono([(cx + radio_dentro * math.cos(a0), y, cz + radio_dentro * math.sin(a0)),
                           (cx + radio_fuera * math.cos(a0), y, cz + radio_fuera * math.sin(a0)),
                           (cx + radio_fuera * math.cos(a1), y, cz + radio_fuera * math.sin(a1)),
                           (cx + radio_dentro * math.cos(a1), y, cz + radio_dentro * math.sin(a1))],
                          (0, 1, 0), (0, 0, 1), densidad, tinte)

    def rectangulo_vertical(self, centro, normal, ancho, alto, tinte=BLANCO):
        """Rectángulo en una pared (ventanas) con la textura entera (UV 0..1)."""
        derecha = normalizar(producto_vectorial(normal, (0, 1, 0)))
        a, h = ancho / 2, alto / 2
        esquinas = [sumar(sumar(centro, escalar(derecha, sx * a)), (0, sy * h, 0))
                    for sx, sy in ((-1, -1), (1, -1), (1, 1), (-1, 1))]
        self.poligono(esquinas, normal, (0, 1, 0), tinte=tinte,
                      uvs=[(0, 0), (1, 0), (1, 1), (0, 1)])

    def crear_malla(self):
        return Mesh(vertices=self.vertices, triangles=self.triangulos, uvs=self.uvs,
                    normals=self.normales, colors=self.colores)


def malla_sprite(ancho, alto):
    """Rectángulo vertical con los pies en el origen, visible desde −Z."""
    constructor = ConstructorMalla()
    constructor.poligono([(-ancho / 2, 0, 0), (ancho / 2, 0, 0), (ancho / 2, alto, 0), (-ancho / 2, alto, 0)],
                         (0, 0, -1), (0, 1, 0), uvs=[(0, 0), (1, 0), (1, 1), (0, 1)])
    return constructor.crear_malla()


def malla_centrada(ancho, alto):
    constructor = ConstructorMalla()
    constructor.poligono([(-ancho / 2, -alto / 2, 0), (ancho / 2, -alto / 2, 0),
                          (ancho / 2, alto / 2, 0), (-ancho / 2, alto / 2, 0)],
                         (0, 0, -1), (0, 1, 0), uvs=[(0, 0), (1, 0), (1, 1), (0, 1)])
    return constructor.crear_malla()


def malla_plana(ancho, fondo):
    """Rectángulo horizontal (sombras bajo los pies)."""
    constructor = ConstructorMalla()
    constructor.poligono([(-ancho / 2, 0, -fondo / 2), (ancho / 2, 0, -fondo / 2),
                          (ancho / 2, 0, fondo / 2), (-ancho / 2, 0, fondo / 2)],
                         (0, 1, 0), (0, 0, 1), uvs=[(0, 0), (1, 0), (1, 1), (0, 1)])
    return constructor.crear_malla()


def hacer_opaco(entidad):
    """Ursina pone transparencia 'dual' a todo modelo; lo opaco se dibuja una sola vez."""
    entidad.model.setTransparency(TransparencyAttrib.M_none)


def hacer_mezclado(entidad, aditivo=False, orden=10):
    """Transparencia real (sombras de los pies, halos, tajo): sin escribir profundidad."""
    entidad.model.setTransparency(TransparencyAttrib.M_alpha)
    entidad.setDepthWrite(False)
    entidad.setBin('transparent', orden)
    if aditivo:
        entidad.setAttrib(ColorBlendAttrib.make(ColorBlendAttrib.M_add, ColorBlendAttrib.O_incoming_alpha,
                                                ColorBlendAttrib.O_one))


def poner_visible(entidad, visible):
    """Muestra u oculta solo el modelo: el hide(0b0001) de la entidad (no proyectar sombra
    de luna) se conserva. Entity.visible haría show() y lo anularía."""
    if getattr(entidad, '_visible_ronin', True) != visible:
        entidad._visible_ronin = visible
        if visible:
            entidad.model.show()
        else:
            entidad.model.hide()


def entidad_sin_luz(malla, textura, **ajustes):
    entidad = Entity(model=malla, texture=textura, shader=SOMBREADOR_SIN_LUZ)
    for nombre, valor in ajustes.items():
        entidad.set_shader_input(nombre, valor)
    entidad.hide(0b0001)          # no proyecta sombra de luna
    return entidad


# =============================================================================
# COLISIONES (cajas alineadas y cilindros, programadas a mano)
# =============================================================================

class Caja:
    def __init__(self, centro, tamano):
        cx, cy, cz = centro
        sx, sy, sz = tamano
        self.x0, self.x1 = cx - sx / 2, cx + sx / 2
        self.y0, self.y1 = cy - sy / 2, cy + sy / 2
        self.z0, self.z1 = cz - sz / 2, cz + sz / 2

    def punto_cercano(self, x, z):
        return limitar(x, self.x0, self.x1), limitar(z, self.z0, self.z1)

    def dentro(self, x, z):
        return self.x0 < x < self.x1 and self.z0 < z < self.z1


class Cilindro:
    def __init__(self, x, z, radio, y0, y1):
        self.x, self.z, self.radio = x, z, radio
        self.y0, self.y1 = y0, y1


class Mundo:
    """Sólidos del patio para empujar a los personajes y saber dónde está el suelo."""

    TOLERANCIA_PISAR = 0.05

    def __init__(self):
        self.solidos = []

    def agregar_caja(self, centro_espec, tamano):
        self.solidos.append(Caja(convertir(*centro_espec), tamano))

    def agregar_cilindro(self, x_espec, z_espec, radio, y0, y1):
        x, _, z = convertir(x_espec, 0, z_espec)
        self.solidos.append(Cilindro(x, z, radio, y0, y1))

    def empujar(self, x, y, z, radio, altura):
        """Saca el círculo (x, z) de los sólidos que están a la altura del cuerpo."""
        for _ in range(2):
            for s in self.solidos:
                if s.y1 <= y + self.TOLERANCIA_PISAR or s.y0 >= y + altura:
                    continue
                if isinstance(s, Caja):
                    px, pz = s.punto_cercano(x, z)
                    dx, dz = x - px, z - pz
                    d2 = dx * dx + dz * dz
                    if d2 >= radio * radio:
                        continue
                    if d2 > 1e-10:
                        d = math.sqrt(d2)
                        x, z = px + dx / d * radio, pz + dz / d * radio
                    else:           # el centro quedó dentro: sale por el lado más cercano
                        opciones = [(x - s.x0, s.x0 - radio, z), (s.x1 - x, s.x1 + radio, z),
                                    (z - s.z0, x, s.z0 - radio), (s.z1 - z, x, s.z1 + radio)]
                        _, nx, nz = min(opciones, key=lambda o: o[0])
                        x, z = (nx, z) if nz == z else (x, nz)
                else:
                    dx, dz = x - s.x, z - s.z
                    d = math.hypot(dx, dz)
                    minimo = s.radio + radio
                    if d >= minimo:
                        continue
                    if d < 1e-6:
                        dx, dz, d = 1.0, 0.0, 1.0
                    x, z = s.x + dx / d * minimo, s.z + dz / d * minimo
        return x, z

    def altura_suelo(self, x, z, y, radio):
        """Altura del suelo bajo (x, z): la cara superior más alta que no esté por encima
        de los pies (y). Sin nada debajo, el suelo del patio (0)."""
        suelo = 0.0
        pie = radio * 0.6
        for s in self.solidos:
            if s.y1 > y + self.TOLERANCIA_PISAR or s.y1 <= suelo:
                continue
            if isinstance(s, Caja):
                px, pz = s.punto_cercano(x, z)
                if (x - px) ** 2 + (z - pz) ** 2 <= pie * pie:
                    suelo = s.y1
            elif math.hypot(x - s.x, z - s.z) <= s.radio + pie:
                suelo = s.y1
        return suelo


# =============================================================================
# ESCENARIO
# =============================================================================

class TramoMuralla:
    """Un tramo de la muralla (o el portón). Si la cámara queda fuera y el tramo tapa a
    Akira, se «corta» a la altura de la base de piedra (como una maqueta abierta)."""

    VELOCIDAD_CORTE = 22.0

    def __init__(self, x0, x1, z0, z1, alto, exterior):
        self.x0, self.x1, self.z0, self.z1 = x0, x1, z0, z1
        self.alto = alto
        self.exterior = exterior        # (eje, signo, valor): la cámara está fuera si signo·(p − valor) > 0
        self.materiales = {nombre: ConstructorMalla() for nombre in ('piedra', 'yeso', 'madera', 'tejas', 'porton')}
        self.entidades = []
        self.altura_corte = 1000.0

    def crear_entidades(self, padre):
        for nombre, constructor in self.materiales.items():
            if constructor.vacio:
                continue
            entidad = Entity(parent=padre, model=constructor.crear_malla(), texture=TEXTURAS[nombre],
                             shader=SOMBREADOR_ILUMINADO)
            entidad.set_shader_input('recortable', 1.0)
            hacer_opaco(entidad)
            self.entidades.append(entidad)

    def tapa(self, camara, objetivo):
        """¿La cámara está fuera de este lado de la muralla y la línea hasta los pies de
        Akira pasa por el tramo por debajo de su techo?"""
        cx, cy, cz = camara
        ax, ay, az = objetivo
        eje, signo, valor = self.exterior
        if signo * ((cx if eje == 'x' else cz) - valor) <= 0:
            return False
        t0, t1 = 0.0, 1.0
        for p, d, bajo, alto in ((cx, ax - cx, self.x0, self.x1), (cz, az - cz, self.z0, self.z1)):
            if abs(d) < 1e-9:
                if p < bajo or p > alto:
                    return False
                continue
            ta, tb = (bajo - p) / d, (alto - p) / d
            if ta > tb:
                ta, tb = tb, ta
            t0, t1 = max(t0, ta), min(t1, tb)
            if t0 > t1:
                return False
        return min(cy + (ay - cy) * t0, cy + (ay - cy) * t1) < self.alto

    def actualizar(self, dt, cortar):
        """Baja o sube la altura de corte poco a poco (sin saltos bruscos)."""
        tope = self.alto + 0.5
        actual = min(self.altura_corte, tope)
        objetivo = ALTURA_PIEDRA + 0.01 if cortar else tope
        paso = self.VELOCIDAD_CORTE * dt
        if abs(objetivo - actual) <= paso:
            nuevo = objetivo
        else:
            nuevo = actual + math.copysign(paso, objetivo - actual)
        if not cortar and nuevo >= tope - 1e-6:
            nuevo = 1000.0                      # sin corte
        if nuevo != self.altura_corte:
            self.altura_corte = nuevo
            for entidad in self.entidades:
                entidad.set_shader_input('altura_corte', nuevo)


def construir_escenario(mundo):
    """Geometría fija del patio y del torreón (una malla por textura) y sus colisiones.
    Devuelve la raíz del escenario y los tramos de muralla recortables."""
    materiales = {nombre: ConstructorMalla() for nombre in
                  ('losa', 'piedra', 'yeso', 'madera', 'tejas', 'porton', 'liso')}
    ventanas = ConstructorMalla()
    m = materiales
    tramos = []

    # Suelo del patio (el terreno exterior va aparte para no agrandar la zona de sombras)
    m['losa'].suelo(convertir(0, 0, 0), 48, 32)

    # Muros: base de piedra de 1,2 m, yeso blanco encima, bandas de madera y tejadillo
    for (cx, cy, cz), (sx, sy, sz) in MUROS:
        x, _, z = convertir(cx, 0, cz)
        if sx > sz:     # muro norte o sur: fuera según Z
            exterior = ('z', 1 if z > 0 else -1, z - sz / 2 if z > 0 else z + sz / 2)
        else:           # muro oeste o este: fuera según X
            exterior = ('x', 1 if x > 0 else -1, x - sx / 2 if x > 0 else x + sx / 2)
        tramo = TramoMuralla(x - sx / 2 - 0.3, x + sx / 2 + 0.3, z - sz / 2 - 0.3, z + sz / 2 + 0.3, sy + 0.4,
                             exterior)
        t = tramo.materiales
        t['piedra'].caja((x, ALTURA_PIEDRA / 2, z), (sx, ALTURA_PIEDRA, sz))
        t['yeso'].caja((x, ALTURA_PIEDRA + (sy - ALTURA_PIEDRA) / 2, z), (sx, sy - ALTURA_PIEDRA, sz))
        t['madera'].caja((x, ALTURA_PIEDRA + 0.08, z), (sx + 0.06, 0.16, sz + 0.06), tinte=MADERA_OSCURA)
        t['madera'].caja((x, sy - 0.17, z), (sx + 0.06, 0.34, sz + 0.06), tinte=MADERA_OSCURA)
        eje = 'x' if sx > sz else 'z'
        t['tejas'].tejado_dos_aguas((x, sy, z), max(sx, sz) + 0.3, 1.6, 0.4, eje)
        mundo.agregar_caja((cx, cy, cz), (sx, sy, sz))
        tramos.append(tramo)

    # Portón (macizo), postes, dintel y tejado
    (px, py, pz), (psx, psy, psz) = PORTON
    x, _, z = convertir(px, 0, pz)
    tramo = TramoMuralla(x - 1.3, x + 1.3, z - 4.8, z + 4.8, 6.6, ('x', 1, x - psx / 2))
    t = tramo.materiales
    x0, x1 = x - psx / 2, x + psx / 2
    z0, z1 = z - psz / 2, z + psz / 2
    t['porton'].poligono([(x0, 0, z1), (x0, 0, z0), (x0, psy, z0), (x0, psy, z1)], (-1, 0, 0), (0, 1, 0),
                         uvs=[(0, 0), (1, 0), (1, 1), (0, 1)])
    t['porton'].poligono([(x1, 0, z0), (x1, 0, z1), (x1, psy, z1), (x1, psy, z0)], (1, 0, 0), (0, 1, 0),
                         uvs=[(0, 0), (1, 0), (1, 1), (0, 1)])
    t['madera'].caja((x, psy / 2, z), (psx, psy, psz), tinte=MADERA_OSCURA, caras=('y+', 'z+', 'z-'))
    mundo.agregar_caja((px, py, pz), (psx, psy, psz))
    for centro, tamano in POSTES_PORTON:
        t['madera'].caja(convertir(*centro), tamano, tinte=MADERA_OSCURA)
        mundo.agregar_caja(centro, tamano)
    centro, tamano = DINTEL_PORTON
    t['madera'].caja(convertir(*centro), tamano, tinte=MADERA_OSCURA, con_base=True)
    dx, _, dz = convertir(24.5, 0, 0)
    t['tejas'].tejado_dos_aguas((dx, 5.6, dz), 9.6, 2.6, 1.0, 'z')
    tramos.append(tramo)

    # Pasarela de madera y su escalón
    for centro, tamano in (PASARELA, ESCALON):
        m['madera'].caja(convertir(*centro), tamano)
        mundo.agregar_caja(centro, tamano)
    cx, _, cz = convertir(*PASARELA[0])
    for sx in (-1, 1):                      # vigas oscuras en los bordes, a modo de marco
        m['madera'].caja((cx + sx * 4.93, 0.6, cz), (0.16, 1.21, 4.02), tinte=MADERA_OSCURA)

    # Muro bajo y bloques de piedra
    for centro, tamano in [MURO_BAJO] + BLOQUES:
        m['piedra'].caja(convertir(*centro), tamano)
        mundo.agregar_caja(centro, tamano)

    # Linternas de piedra (tōrō) con una luz tenue dentro
    for lx, lz in LINTERNAS:
        x, _, z = convertir(lx, 0, lz)
        piedra = m['piedra']
        piedra.caja((x, 0.1, z), (0.8, 0.2, 0.8), 2, PIEDRA_LINTERNA)
        piedra.caja((x, 0.5, z), (0.26, 0.6, 0.26), 2, PIEDRA_LINTERNA)
        piedra.caja((x, 0.85, z), (0.62, 0.1, 0.62), 2, PIEDRA_LINTERNA, con_base=True)
        piedra.caja((x, 1.08, z), (0.44, 0.36, 0.44), 2, PIEDRA_LINTERNA)
        piedra.tronco_piramide((x, 1.26, z), (0.8, 0.8), (0.12, 0.12), 0.26, 2, PIEDRA_LINTERNA, con_base=True)
        piedra.caja((x, 1.56, z), (0.12, 0.08, 0.12), 2, PIEDRA_LINTERNA)
        for normal in ((1, 0, 0), (-1, 0, 0), (0, 0, 1), (0, 0, -1)):
            centro_ventana = (x + normal[0] * 0.225, 1.08, z + normal[2] * 0.225)
            ventanas.rectangulo_vertical(centro_ventana, normal, 0.2, 0.2)
        mundo.agregar_cilindro(lx, lz, 0.4, 0, 1.6)

    # Pozo con tejadillo sobre dos postes
    x, _, z = convertir(POZO[0], 0, POZO[1])
    m['piedra'].cilindro((x, 0, z), 1.0, 0.9, lados=16, con_tapa=False)
    m['piedra'].cilindro((x, 0.3, z), 0.8, 0.6, lados=16, con_tapa=False, hacia_dentro=True)
    m['piedra'].anillo((x, 0.9, z), 0.8, 1.0, lados=16, tinte=(0.9, 0.9, 0.95, 1.0))
    m['liso'].cilindro((x, 0.0, z), 0.8, 0.45, lados=16, tinte=AGUA)
    for sx in (-1, 1):
        m['madera'].caja((x + sx * 0.9, 1.675, z), (0.14, 1.55, 0.14), tinte=MADERA_OSCURA)
    m['madera'].caja((x, 2.2, z), (1.94, 0.1, 0.1), tinte=MADERA_OSCURA, con_base=True)
    m['tejas'].tejado_dos_aguas((x, 2.45, z), 2.7, 1.7, 0.55, 'x')
    mundo.agregar_cilindro(POZO[0], POZO[1], 1.0, 0, 3.0)

    # Cajas y barriles
    for i, (bx, by, bz) in enumerate(CAJAS):
        tono = (0.95, 0.88, 0.8, 1.0) if i % 2 == 0 else (0.82, 0.74, 0.66, 1.0)
        m['madera'].caja(convertir(bx, by, bz), (1, 1, 1), tinte=tono)
        m['madera'].caja(convertir(bx, by, bz), (1.02, 0.12, 1.02), tinte=MADERA_OSCURA, caras=('x+', 'x-', 'z+', 'z-'))
        mundo.agregar_caja((bx, by, bz), (1, 1, 1))
    for bx, by, bz in BARRILES:
        x, _, z = convertir(bx, 0, bz)
        m['madera'].cilindro((x, 0, z), 0.45, 1.0, lados=12, tinte=MADERA_BARRIL)
        for altura in (0.16, 0.76):
            m['liso'].cilindro((x, altura, z), 0.465, 0.08, lados=12, tinte=HIERRO, con_tapa=False)
        mundo.agregar_cilindro(bx, bz, 0.45, 0, 1.0)

    # Postes de las antorchas (la llama y la luz van en Antorcha)
    for ax, az in ANTORCHAS:
        x, _, z = convertir(ax, 0, az)
        m['madera'].caja((x, 1.3, z), (0.14, 2.6, 0.14), tinte=MADERA_OSCURA)
        m['liso'].tronco_piramide((x, 2.5, z), (0.16, 0.16), (0.38, 0.38), 0.18, tinte=HIERRO,
                                  con_base=True, tinte_base=HIERRO)
        mundo.agregar_cilindro(ax, az, 0.15, 0, 2.6)

    construir_torreon(m, ventanas)

    raiz = Entity(name='escenario')
    for tramo in tramos:
        tramo.crear_entidades(raiz)
    for nombre, constructor in materiales.items():
        if constructor.vacio:
            continue
        entidad = Entity(parent=raiz, model=constructor.crear_malla(), texture=TEXTURAS[nombre],
                         shader=SOMBREADOR_ILUMINADO)
        entidad.set_shader_input('recortable', 0.0 if nombre == 'losa' else 1.0)
        hacer_opaco(entidad)
    brillo = entidad_sin_luz(ventanas.crear_malla(), TEXTURAS['ventana'])
    brillo.parent = raiz
    hacer_opaco(brillo)

    terreno = ConstructorMalla()
    terreno.suelo(convertir(0, -0.01, 0), 220, 220, densidad=0.5)
    exterior = Entity(model=terreno.crear_malla(), texture=TEXTURAS['tierra'], shader=SOMBREADOR_ILUMINADO)
    hacer_opaco(exterior)
    return raiz, tramos


def construir_torreon(m, ventanas):
    """Tenshu al norte, fuera del patio: base de piedra y tres pisos con tejados."""
    tx, _, tz = convertir(CENTRO_TORREON[0], 0, CENTRO_TORREON[1])
    m['piedra'].caja((tx, 3, tz), (18, 6, 18), tinte=(0.78, 0.78, 0.84, 1.0))
    m['madera'].caja((tx, 6.05, tz), (18.1, 0.1, 18.1), tinte=MADERA_OSCURA)
    # (ancho, y inicial, alto, ancho del tejado, alto del tejado, techo del tejado, ventanas por cara)
    pisos = [(13, 6.0, 4.5, 17, 2.5, (8.0, 8.0), 4),
             (10, 11.0, 4.0, 13, 2.2, (5.0, 5.0), 3),
             (7, 15.5, 3.5, 10, 3.0, (3.4, 0.0), 2)]
    for ancho, y0, alto, ancho_tejado, alto_tejado, techo, num_ventanas in pisos:
        m['yeso'].caja((tx, y0 + alto / 2, tz), (ancho, alto, ancho))
        m['madera'].caja((tx, y0 + 0.2, tz), (ancho + 0.08, 0.4, ancho + 0.08), tinte=MADERA_OSCURA)
        m['madera'].caja((tx, y0 + alto - 0.3, tz), (ancho + 0.08, 0.6, ancho + 0.08), tinte=MADERA_OSCURA)
        m['tejas'].tronco_piramide((tx, y0 + alto, tz), (ancho_tejado, ancho_tejado), techo, alto_tejado,
                                   con_base=True, con_tapa=False)
        alto_ventana = min(1.3, alto * 0.3)
        ancho_ventana = alto_ventana * 0.68
        y_ventana = y0 + alto * 0.52
        separacion = ancho / (num_ventanas + 0.6)
        for normal in ((1, 0, 0), (-1, 0, 0), (0, 0, 1), (0, 0, -1)):
            derecha = producto_vectorial(normal, (0, 1, 0))
            for i in range(num_ventanas):
                desplazamiento = (i - (num_ventanas - 1) / 2) * separacion
                centro = (tx + normal[0] * (ancho / 2 + 0.03) + derecha[0] * desplazamiento, y_ventana,
                          tz + normal[2] * (ancho / 2 + 0.03) + derecha[2] * desplazamiento)
                ventanas.rectangulo_vertical(centro, normal, ancho_ventana, alto_ventana)
    # Remate dorado: dos peces (shachihoko) en los extremos de la cumbrera
    for sx in (-1, 1):
        m['liso'].caja((tx + sx * 1.55, 22.2, tz), (0.34, 0.5, 0.28), tinte=ORO)
        m['liso'].caja((tx + sx * 1.72, 22.5, tz), (0.22, 0.3, 0.2), tinte=ORO)
    m['liso'].caja((tx, 22.03, tz), (3.3, 0.1, 0.16), tinte=ORO)


# =============================================================================
# CIELO: degradado, estrellas, luna con halo y montes lejanos
# =============================================================================

class Cielo:
    RADIO = 900.0

    def __init__(self):
        self.raiz = Entity(name='cielo')
        self.raiz.hide(0b0001)
        self.raiz.setLightOff(10)
        arriba, horizonte = color_hex(CIELO_ARRIBA), color_hex(CIELO_HORIZONTE)

        # Cúpula con color por vértice (del horizonte al cenit)
        vertices, colores, triangulos = [], [], []
        anillos, segmentos = 14, 24
        for i in range(anillos + 1):
            elevacion = math.radians(-25 + 115 * i / anillos)
            t = limitar(math.degrees(elevacion) / 65.0, 0.0, 1.0) ** 0.55
            if elevacion < 0:
                tono = tuple(horizonte[k] * 0.55 for k in range(3))
            else:
                tono = tuple(mezclar(horizonte[k], arriba[k], t) for k in range(3))
            for j in range(segmentos + 1):
                acimut = 2 * math.pi * j / segmentos
                vertices.append((self.RADIO * math.cos(elevacion) * math.cos(acimut),
                                 self.RADIO * math.sin(elevacion),
                                 self.RADIO * math.cos(elevacion) * math.sin(acimut)))
                colores.append((tono[0], tono[1], tono[2], 1.0))
        for i in range(anillos):
            for j in range(segmentos):
                a = i * (segmentos + 1) + j
                b = a + segmentos + 1
                triangulos.extend((a, b, a + 1, a + 1, b, b + 1))
        cupula = Entity(parent=self.raiz, model=Mesh(vertices=vertices, colors=colores, triangles=triangulos),
                        texture=TEXTURAS['liso'], shader=SOMBREADOR_SIN_LUZ, double_sided=True)
        cupula.set_shader_input('con_niebla', 0.0)
        self._al_fondo(cupula, 0)

        # Estrellas: puntos de 2 píxeles, sin sombreador (más baratos imposible)
        azar = random.Random(5)
        hacia_luna = normalizar(convertir(*DIRECCION_LUNA))
        puntos, tonos = [], []
        while len(puntos) < 420:
            acimut = azar.uniform(0, 2 * math.pi)
            elevacion = math.asin(azar.uniform(math.sin(math.radians(6)), 1.0))
            direccion = (math.cos(elevacion) * math.cos(acimut), math.sin(elevacion),
                         math.cos(elevacion) * math.sin(acimut))
            if producto_escalar(direccion, hacia_luna) > math.cos(math.radians(9)):
                continue
            puntos.append(escalar(direccion, self.RADIO * 0.95))
            brillo = azar.choice((0.45, 0.55, 0.65, 0.8, 1.0))
            tonos.append((brillo * 0.9, brillo * 0.92, brillo, 1.0))
        estrellas = Entity(parent=self.raiz, model=Mesh(vertices=puntos, colors=tonos, mode='point',
                                                        thickness=2, render_points_in_3d=False))
        self._al_fondo(estrellas, 1)

        # Luna grande, baja, detrás del torreón, con su halo
        distancia = self.RADIO * 0.8
        centro_luna = escalar(hacia_luna, distancia)
        lado = 2 * distancia * math.tan(math.radians(3.6))
        self.halo_luna = entidad_sin_luz(malla_centrada(lado * 3.4, lado * 3.4), TEXTURAS['halo'], con_niebla=0.0)
        self.halo_luna.parent = self.raiz
        self.halo_luna.position = Vec3(*escalar(hacia_luna, distancia * 1.01))
        self.halo_luna.color = Color(0.55, 0.6, 0.9, 0.45)
        self._al_fondo(self.halo_luna, 2, aditivo=True)
        self.luna = entidad_sin_luz(malla_centrada(lado, lado), TEXTURAS['luna'], con_niebla=0.0,
                                    umbral_alfa=0.5)
        self.luna.parent = self.raiz
        self.luna.position = Vec3(*centro_luna)
        self._al_fondo(self.luna, 3)
        for entidad in (self.luna, self.halo_luna):
            entidad.look_at(Vec3(0, 0, 0))
            entidad.double_sided = True

        # Montes lejanos: silueta oscura alrededor del horizonte
        azar = random.Random(21)
        radio = self.RADIO * 0.7
        alturas = []
        for i in range(72):
            base = 0.5 + 0.5 * math.sin(i * 0.37) * math.sin(i * 0.11 + 1.3)
            alturas.append(radio * math.tan(math.radians(1.2 + 4.0 * base + azar.uniform(0, 1.3))))
        vertices, colores, triangulos = [], [], []
        pie = (horizonte[0] * 0.45, horizonte[1] * 0.45, horizonte[2] * 0.5, 1.0)
        cima = (horizonte[0] * 0.62, horizonte[1] * 0.6, horizonte[2] * 0.7, 1.0)
        for i in range(73):
            acimut = 2 * math.pi * i / 72
            c, s = math.cos(acimut), math.sin(acimut)
            vertices.append((radio * c, -60, radio * s))
            vertices.append((radio * c, alturas[i % 72], radio * s))
            colores.extend((pie, cima))
        for i in range(72):
            a = 2 * i
            triangulos.extend((a, a + 2, a + 1, a + 1, a + 2, a + 3))
        montes = Entity(parent=self.raiz, model=Mesh(vertices=vertices, colors=colores, triangles=triangulos),
                        texture=TEXTURAS['liso'], shader=SOMBREADOR_SIN_LUZ, double_sided=True)
        montes.set_shader_input('con_niebla', 0.0)
        self._al_fondo(montes, 4)

    @staticmethod
    def _al_fondo(entidad, orden, aditivo=False):
        entidad.setBin('background', orden)
        entidad.setDepthWrite(False)
        entidad.hide(0b0001)
        if aditivo:
            entidad.model.setTransparency(TransparencyAttrib.M_alpha)
            entidad.setAttrib(ColorBlendAttrib.make(ColorBlendAttrib.M_add, ColorBlendAttrib.O_incoming_alpha,
                                                    ColorBlendAttrib.O_one))
        else:
            entidad.model.setTransparency(TransparencyAttrib.M_none)

    def seguir(self, posicion):
        self.raiz.position = posicion


# =============================================================================
# LUCES
# =============================================================================

def crear_luna(escenario):
    """Luz direccional azulada de la luna; su sombra cubre el patio y el torreón."""
    luna = DirectionalLight(shadows=False)
    luna.color = color_hex(COLOR_LUNA, INTENSIDAD_LUNA)
    hacia_luna = normalizar(convertir(*DIRECCION_LUNA))
    centro = convertir(0, 0, -8)
    luna.position = Vec3(*sumar(centro, escalar(hacia_luna, 120)))
    luna.look_at(Vec3(*centro))
    nodo = luna.getChild(0)
    if not MODO_LIGERO:
        luna._light.set_shadow_caster(True, 2048, 2048)
        limites = escenario.getTightBounds(luna)
        if limites:
            minimo, maximo = limites
            lente = luna._light.get_lens()
            lente.set_film_size(maximo.x - minimo.x + 2, maximo.y - minimo.y + 2)
            lente.set_film_offset((minimo.x + maximo.x) / 2, (minimo.y + maximo.y) / 2)
            lente.set_near_far(max(0.5, minimo.z - 2), maximo.z + 2)
    application.base.render.set_shader_input('luna', nodo)
    return luna


def parpadeo(t, fase):
    return (1.0 + 0.07 * math.sin(t * 11.0 + fase) + 0.05 * math.sin(t * 23.0 + fase * 2.3)
            + 0.035 * math.sin(t * 37.0 + fase * 0.7))


class Antorcha:
    """Llama animada (fuego.png), halo y luz puntual cálida que parpadea."""

    def __init__(self, x_espec, z_espec, fase):
        x, _, z = convertir(x_espec, 0, z_espec)
        self.fase = fase
        self.color_base = color_hex(COLOR_ANTORCHA, INTENSIDAD_ANTORCHA)
        self.luz = PointLight(position=Vec3(x, 2.8, z))
        self.luz._light.set_attenuation((1, 0, 1 / ALCANCE_ANTORCHA ** 2))
        self.luz.color = self.color_base
        self.llama = entidad_sin_luz(malla_sprite(0.64, 0.96), TEXTURAS['fuego'], umbral_alfa=0.5,
                                     texture_scale=Vec2(0.25, 1))
        self.llama.position = Vec3(x, 2.56, z)
        hacer_opaco(self.llama)
        self.halo = entidad_sin_luz(malla_centrada(2.6, 2.6), TEXTURAS['halo'], con_niebla=2.0)
        self.halo.position = Vec3(x, 3.0, z)
        self.halo.billboard = True
        hacer_mezclado(self.halo, aditivo=True, orden=20)
        self.cuadro = -1

    def actualizar(self, t, giro_sprites):
        intensidad = parpadeo(t, self.fase)
        c = self.color_base
        self.luz.color = Color(c[0] * intensidad, c[1] * intensidad, c[2] * intensidad, 1)
        cuadro = int(t * 9 + self.fase * 3) % 4
        if cuadro != self.cuadro:
            self.cuadro = cuadro
            self.llama.set_shader_input('texture_offset', Vec2(cuadro * 0.25, 0))
        self.llama.rotation_y = giro_sprites
        self.halo.color = Color(1.0, 0.62, 0.3, 0.36 * intensidad)


class Linterna:
    """Luz tenue dentro de una linterna de piedra."""

    def __init__(self, x_espec, z_espec, fase):
        x, _, z = convertir(x_espec, 0, z_espec)
        self.fase = fase
        self.color_base = color_hex(COLOR_ANTORCHA, INTENSIDAD_LINTERNA)
        self.luz = PointLight(position=Vec3(x, 1.08, z))
        self.luz._light.set_attenuation((1, 0, 1 / ALCANCE_LINTERNA ** 2))
        self.luz.color = self.color_base
        self.halo = entidad_sin_luz(malla_centrada(1.4, 1.4), TEXTURAS['halo'], con_niebla=2.0)
        self.halo.position = Vec3(x, 1.08, z)
        self.halo.billboard = True
        hacer_mezclado(self.halo, aditivo=True, orden=20)

    def actualizar(self, t):
        intensidad = 0.92 + 0.08 * math.sin(t * 5.0 + self.fase)
        c = self.color_base
        self.luz.color = Color(c[0] * intensidad, c[1] * intensidad, c[2] * intensidad, 1)
        self.halo.color = Color(1.0, 0.66, 0.34, 0.3 * intensidad)


# =============================================================================
# SPRITES Y PERSONAJES
# =============================================================================

class SpriteVertical:
    """Sprite pixel art de pie: gira solo en Y hacia la cámara (no se inclina), recorta su
    cuadro de la hoja con texture_offset / texture_scale y lleva sombra.png bajo los pies."""

    def __init__(self, textura, ancho_px, alto_px, columnas=5, filas=3):
        self.ancho = ancho_px * ESCALA_PIXEL
        self.alto = alto_px * ESCALA_PIXEL
        self.columnas, self.filas = columnas, filas
        self.entidad = Entity(model=malla_sprite(self.ancho, self.alto), texture=textura,
                              shader=SOMBREADOR_ILUMINADO)
        self.entidad.set_shader_input('umbral_alfa', 0.5)
        self.entidad.set_shader_input('envoltura', 1.0)
        self.entidad.set_shader_input('destello', Vec4(1, 1, 1, 0))
        self.entidad.set_shader_input('opacidad', 1.0)
        self.entidad.hide(0b0001)            # su sombra es sombra.png, no la de la luna
        hacer_opaco(self.entidad)
        self.sombra = entidad_sin_luz(malla_plana(32 * ESCALA_PIXEL, 16 * ESCALA_PIXEL), TEXTURAS['sombra'])
        hacer_mezclado(self.sombra, orden=5)
        self.cuadro = None

    def poner_cuadro(self, columna, fila, voltear=False):
        clave = (columna, fila, voltear)
        if clave == self.cuadro:
            return
        self.cuadro = clave
        ancho, alto = 1 / self.columnas, 1 / self.filas
        v = (self.filas - 1 - fila) * alto          # la fila 0 está arriba en la imagen
        if voltear:
            self.entidad.set_shader_input('texture_scale', Vec2(-ancho, alto))
            self.entidad.set_shader_input('texture_offset', Vec2((columna + 1) * ancho, v))
        else:
            self.entidad.set_shader_input('texture_scale', Vec2(ancho, alto))
            self.entidad.set_shader_input('texture_offset', Vec2(columna * ancho, v))

    def colocar(self, x, y, z, giro, caida=0.0, suelo=0.0, visible=True, opacidad=1.0):
        self.entidad.position = Vec3(x, y, z)
        self.entidad.rotation = Vec3(0, giro, caida)
        poner_visible(self.entidad, visible)
        self.entidad.set_shader_input('opacidad', opacidad)
        altura = max(0.0, y - suelo)
        escala = limitar(1.0 - altura * 0.25, 0.45, 1.0)
        self.sombra.position = Vec3(x, suelo + 0.015, z)
        self.sombra.rotation_y = giro
        self.sombra.scale = escala
        self.sombra.color = Color(1, 1, 1, escala * opacidad)
        poner_visible(self.sombra, visible and opacidad > 0.02)

    def destellar(self, cantidad, tono=(1.0, 1.0, 1.0)):
        self.entidad.set_shader_input('destello', Vec4(tono[0], tono[1], tono[2], cantidad))

    def ocultar(self):
        poner_visible(self.entidad, False)
        poner_visible(self.sombra, False)


def elegir_vista(fx, fz, px, pz, camara_x, camara_z, derecha_x, derecha_z):
    """Fila de la hoja (0 frente, 1 espalda, 2 lado) y si hay que voltear, según la regla
    de la especificación (f: hacia dónde mira; v: del personaje a la cámara)."""
    vx, vz = camara_x - px, camara_z - pz
    largo = math.hypot(vx, vz)
    if largo > 1e-6:
        vx, vz = vx / largo, vz / largo
    fv = fx * vx + fz * vz
    if fv > 0.707:
        return 0, False
    if fv < -0.707:
        return 1, False
    return 2, (fx * derecha_x + fz * derecha_z) < 0


class Akira:
    def __init__(self, juego):
        self.juego = juego
        self.sprite = SpriteVertical(TEXTURAS['akira'], 48, 48)
        self.tajo = entidad_sin_luz(malla_centrada(1.92, 1.92), TEXTURAS['tajo'], con_niebla=1.0)
        hacer_mezclado(self.tajo, orden=30)
        poner_visible(self.tajo, False)
        self.reiniciar()

    def reiniciar(self):
        self.x, self.y, self.z = convertir(*INICIO_AKIRA)
        self.vel_y = 0.0
        self.en_suelo = True
        self.suelo = 0.0
        self.fx, self.fz = 1.0, 0.0                 # mirando al este
        self.vida = VIDA_MAXIMA
        self.t_invulnerable = 0.0
        self.t_retroceso = 0.0
        self.retroceso = (0.0, 0.0)
        self.t_ataque = -1.0                        # < 0: no ataca
        self.t_enfriamiento = 0.0
        self.golpeados = set()
        self.t_animacion = 0.0
        self.moviendose = False
        self.corriendo = False
        self.t_caida = -1.0                         # ≥ 0: derrotado, cayendo
        self.lado_caida = 1.0
        self.ataques_con_golpe = 0

    @property
    def viva(self):
        return self.t_caida < 0

    @property
    def atacando(self):
        return self.t_ataque >= 0

    def saltar(self):
        if self.viva and self.en_suelo and self.t_retroceso <= 0:
            self.vel_y = VEL_SALTO
            self.en_suelo = False

    def atacar(self):
        if self.viva and self.t_enfriamiento <= 0 and self.t_retroceso <= 0:
            self.t_ataque = 0.0
            self.t_enfriamiento = ENFRIAMIENTO_ATAQUE
            self.golpeados = set()

    def recibir_golpe(self, dx, dz):
        if not self.viva or self.t_invulnerable > 0:
            return False
        self.vida -= 1
        if self.vida <= 0:
            self.vida = 0
            self.t_caida = 0.0
            self.t_ataque = -1.0
            self.lado_caida = 1.0 if random.random() < 0.5 else -1.0
            return True
        self.t_invulnerable = TIEMPO_INVULNERABLE
        self.t_retroceso = TIEMPO_RETROCESO
        self.retroceso = (dx * VEL_RETROCESO, dz * VEL_RETROCESO)
        return True

    def actualizar(self, dt, dir_x, dir_z, correr):
        """dir_x, dir_z: dirección deseada en el mundo (ya relativa a la cámara)."""
        mundo = self.juego.mundo
        self.t_invulnerable = max(0.0, self.t_invulnerable - dt)
        self.t_enfriamiento = max(0.0, self.t_enfriamiento - dt)
        if not self.viva:
            self.t_caida += dt
            dir_x = dir_z = 0.0
        vx = vz = 0.0
        if self.t_retroceso > 0:
            self.t_retroceso -= dt
            vx, vz = self.retroceso
            self.moviendose = False
        elif dir_x or dir_z:
            velocidad = VEL_CORRER if correr else VEL_CAMINAR
            vx, vz = dir_x * velocidad, dir_z * velocidad
            if not self.atacando:
                self.fx, self.fz = dir_x, dir_z
            self.moviendose = True
            self.corriendo = correr
        else:
            self.moviendose = False

        # Movimiento horizontal con colisiones
        self.x, self.z = mundo.empujar(self.x + vx * dt, self.y, self.z + vz * dt,
                                       RADIO_PERSONAJE, ALTURA_AKIRA)
        # Vertical: gravedad y suelo (patio, pasarela, bloques, cajas...)
        y_anterior = self.y
        self.vel_y -= GRAVEDAD * dt
        self.y += self.vel_y * dt
        self.suelo = mundo.altura_suelo(self.x, self.z, y_anterior, RADIO_PERSONAJE)
        if self.y <= self.suelo:
            self.y = self.suelo
            self.vel_y = 0.0
            self.en_suelo = True
        else:
            self.en_suelo = False

        # Ataque: corta entre 0,05 y 0,2 s; cada soldado, una vez por ataque
        if self.atacando:
            self.t_ataque += dt
            if INICIO_CORTE <= self.t_ataque <= FIN_CORTE:
                self._comprobar_corte()
            if self.t_ataque >= DURACION_ATAQUE:
                self.t_ataque = -1.0
        self.t_animacion += dt

    def _comprobar_corte(self):
        coseno_cono = math.cos(math.radians(ANGULO_ESPADA / 2))
        for soldado in self.juego.soldados:
            if soldado in self.golpeados or not soldado.golpeable:
                continue
            dx, dz = soldado.x - self.x, soldado.z - self.z
            d = math.hypot(dx, dz)
            if d > ALCANCE_ESPADA:
                continue
            if d > 1e-3 and (dx * self.fx + dz * self.fz) / d < coseno_cono:
                continue
            if not (self.y + 0.3 < soldado.y + 1.8 and self.y + 1.6 > soldado.y):
                continue
            self.golpeados.add(soldado)
            if d < 1e-3:
                dx, dz, d = self.fx, self.fz, 1.0
            soldado.recibir_golpe(dx / d, dz / d)
            self.ataques_con_golpe += 1

    def actualizar_sprite(self, camara):
        giro = camara.giro_sprites
        fila, voltear = elegir_vista(self.fx, self.fz, self.x, self.z, *camara.posicion_xz,
                                     *camara.derecha_xz)
        if self.atacando:
            columna = 3 if self.t_ataque < DURACION_ATAQUE / 2 else 4
        elif not self.en_suelo:
            columna = 1
        elif self.moviendose:
            periodo = 0.1 if self.corriendo else 0.15
            columna = 1 + int(self.t_animacion / periodo) % 2
        else:
            columna = 0
        self.sprite.poner_cuadro(columna, fila, voltear)
        caida, opacidad = 0.0, 1.0
        if not self.viva:
            caida = self.lado_caida * 90 * suavizar(self.t_caida / 0.45)
        visible = True
        if self.t_invulnerable > 0 and self.viva:
            visible = int(self.t_invulnerable * 12.5) % 2 == 0
        self.sprite.colocar(self.x, self.y, self.z, giro, caida, self.suelo, visible, opacidad)
        self.sprite.destellar(0.0)

        # Efecto del tajo delante de Akira durante el corte
        if self.atacando and 0.03 <= self.t_ataque <= 0.26:
            dx, dz = camara.derecha_xz
            voltea = (self.fx * dx + self.fz * dz) < 0
            adelante_x, adelante_z = camara.adelante_xz
            px = self.x + self.fx * 0.55 - adelante_x * 0.25
            pz = self.z + self.fz * 0.55 - adelante_z * 0.25
            self.tajo.position = Vec3(px, self.y + 0.95, pz)
            self.tajo.rotation = Vec3(0, giro, 0)
            if voltea != getattr(self, '_tajo_volteado', None):
                self._tajo_volteado = voltea
                self.tajo.set_shader_input('texture_scale', Vec2(-1 if voltea else 1, 1))
                self.tajo.set_shader_input('texture_offset', Vec2(1 if voltea else 0, 0))
            alfa = 1.0 - limitar((self.t_ataque - 0.12) / 0.14, 0.0, 1.0)
            self.tajo.color = Color(1, 1, 1, alfa)
            poner_visible(self.tajo, True)
        else:
            poner_visible(self.tajo, False)


class Soldado:
    """Soldado con lanza: patrulla, persigue con correa, avisa «!», estocada, recuperación."""

    def __init__(self, juego, indice, punto_a, punto_b):
        self.juego = juego
        self.indice = indice
        self.a = convertir(*punto_a)
        self.b = convertir(*punto_b)
        self.sprite = SpriteVertical(TEXTURAS['soldado'], 64, 48)
        self.aviso = entidad_sin_luz(malla_sprite(8 * ESCALA_PIXEL * 1.25, 16 * ESCALA_PIXEL * 1.25),
                                     TEXTURAS['exclamacion'], umbral_alfa=0.5, con_niebla=0.0)
        hacer_opaco(self.aviso)
        self.aviso.setBin('fixed', 40)
        self.aviso.setDepthTest(False)
        self.aviso.setDepthWrite(False)
        poner_visible(self.aviso, False)
        self.reiniciar()

    def reiniciar(self):
        self.x, self.y, self.z = self.a
        self.vel_y = 0.0
        self.suelo = self.a[1]
        dx, dz = self.b[0] - self.a[0], self.b[2] - self.a[2]
        largo = math.hypot(dx, dz)
        self.fx, self.fz = dx / largo, dz / largo
        self.hacia_b = True
        self.vida = VIDA_SOLDADO
        self.estado = 'patrulla'
        self.t_estado = 0.0
        self.t_sin_ver = 0.0
        self.t_animacion = 0.0
        self.t_destello = 0.0
        self.retroceso = (0.0, 0.0)
        self.golpe_dado = False
        self.moviendose = False
        self.lado_caida = 1.0
        self.retirado = False
        self.golpes_recibidos = 0
        self.estocadas = 0

    @property
    def vivo(self):
        return self.estado != 'muerto'

    @property
    def golpeable(self):
        return self.vivo

    def recibir_golpe(self, dx, dz):
        if not self.vivo:
            return
        self.vida -= 1
        self.golpes_recibidos += 1
        self.t_destello = 0.12
        self.retroceso = (dx * VEL_RETROCESO_SOLDADO, dz * VEL_RETROCESO_SOLDADO)
        if self.vida <= 0:
            self.estado = 'muerto'
            self.t_estado = 0.0
            derecha = self.juego.camara.derecha_xz
            self.lado_caida = -1.0 if (dx * derecha[0] + dz * derecha[1]) > 0 else 1.0
            self.juego.soldado_derrotado(self)
        else:
            self.estado = 'aturdido'
            self.t_estado = TIEMPO_ATURDIDO
            self.fx, self.fz = -dx, -dz

    def ve_a_akira(self):
        akira = self.juego.akira
        if not akira.viva or abs(akira.y - self.y) > 3.0:
            return False
        dx, dz = akira.x - self.x, akira.z - self.z
        d = math.hypot(dx, dz)
        if d <= DISTANCIA_OIDO:
            return True
        if d > DISTANCIA_VISION:
            return False
        return (dx * self.fx + dz * self.fz) / d >= math.cos(math.radians(ANGULO_VISION / 2))

    def _lanza_alcanza_altura(self):
        akira = self.juego.akira
        altura_lanza = self.y + ALTURA_LANZA
        return akira.y - 0.1 <= altura_lanza <= akira.y + ALTURA_AKIRA

    def _mover(self, vx, vz, dt, con_correa=False):
        """Mueve con colisiones, sin salirse de su plataforma ni (si persigue) de la correa."""
        mundo = self.juego.mundo
        nx, nz = mundo.empujar(self.x + vx * dt, self.y, self.z + vz * dt, RADIO_PERSONAJE, 1.8)
        if con_correa:
            antes = distancia_a_segmento(self.x, self.z, self.a[0], self.a[2], self.b[0], self.b[2])
            despues = distancia_a_segmento(nx, nz, self.a[0], self.a[2], self.b[0], self.b[2])
            if despues > CORREA and despues > antes:
                return False
        if mundo.altura_suelo(nx, nz, self.y, RADIO_PERSONAJE) < self.y - 0.3:
            return False                    # no se tira de la pasarela ni de los bloques
        moved = abs(nx - self.x) + abs(nz - self.z) > 1e-5
        self.x, self.z = nx, nz
        return moved

    def actualizar(self, dt, ia_activa=True):
        self.t_destello = max(0.0, self.t_destello - dt)
        self.t_animacion += dt
        akira = self.juego.akira
        if self.estado == 'muerto':
            self.t_estado += dt
            factor = max(0.0, 1.0 - self.t_estado / 0.35)
            self._mover(self.retroceso[0] * factor, self.retroceso[1] * factor, dt)
            if self.t_estado >= TIEMPO_CAIDA:
                self.retirado = True
            return
        self.moviendose = False
        if not ia_activa:
            self._gravedad(dt)
            return

        if self.estado == 'aturdido':
            self.t_estado -= dt
            factor = max(0.0, self.t_estado / TIEMPO_ATURDIDO)
            self._mover(self.retroceso[0] * factor, self.retroceso[1] * factor, dt)
            if self.t_estado <= 0:
                self.estado = 'persecucion'
                self.t_sin_ver = 0.0
        elif self.estado == 'aviso':
            self.t_estado -= dt
            if self.t_estado <= 0:
                self.estado = 'estocada'
                self.t_estado = TIEMPO_ESTOCADA
                self.golpe_dado = False
                self.estocadas += 1
        elif self.estado == 'estocada':
            self.t_estado -= dt
            if not self.golpe_dado:
                self._comprobar_estocada()
            if self.t_estado <= 0:
                self.estado = 'recuperacion'
                self.t_estado = TIEMPO_RECUPERACION
        elif self.estado == 'recuperacion':
            self.t_estado -= dt
            if self.t_estado <= 0:
                self.estado = 'persecucion'
        elif self.estado == 'patrulla':
            if self.ve_a_akira():
                self.estado = 'persecucion'
                self.t_sin_ver = 0.0
            else:
                destino = self.b if self.hacia_b else self.a
                dx, dz = destino[0] - self.x, destino[2] - self.z
                d = math.hypot(dx, dz)
                if d < 0.15:
                    self.hacia_b = not self.hacia_b
                else:
                    self.fx, self.fz = dx / d, dz / d
                    paso = min(VEL_PATRULLA, d / dt)
                    self.moviendose = self._mover(self.fx * paso, self.fz * paso, dt)
        elif self.estado == 'persecucion':
            if self.ve_a_akira():
                self.t_sin_ver = 0.0
            else:
                self.t_sin_ver += dt
                if self.t_sin_ver >= TIEMPO_OLVIDO or not akira.viva:
                    self.estado = 'patrulla'
            if self.estado == 'persecucion':
                dx, dz = akira.x - self.x, akira.z - self.z
                d = math.hypot(dx, dz)
                if d > 1e-4:
                    self.fx, self.fz = dx / d, dz / d
                if d <= DISTANCIA_ATAQUE and akira.viva and self._lanza_alcanza_altura():
                    self.estado = 'aviso'           # la dirección queda fija durante el aviso
                    self.t_estado = TIEMPO_AVISO
                elif d > DISTANCIA_ATAQUE * 0.9:
                    self.moviendose = self._mover(self.fx * VEL_PERSECUCION, self.fz * VEL_PERSECUCION,
                                                  dt, con_correa=True)
        self._gravedad(dt)

    def _gravedad(self, dt):
        mundo = self.juego.mundo
        y_anterior = self.y
        self.vel_y -= GRAVEDAD * dt
        self.y += self.vel_y * dt
        self.suelo = mundo.altura_suelo(self.x, self.z, y_anterior, RADIO_PERSONAJE)
        if self.y <= self.suelo:
            self.y = self.suelo
            self.vel_y = 0.0

    def _comprobar_estocada(self):
        akira = self.juego.akira
        dx, dz = akira.x - self.x, akira.z - self.z
        adelante = dx * self.fx + dz * self.fz
        lateral = abs(-dx * self.fz + dz * self.fx)
        if (-0.3 <= adelante <= ALCANCE_LANZA and lateral <= ANCHO_LANZA / 2 + RADIO_PERSONAJE
                and self._lanza_alcanza_altura()):
            if akira.recibir_golpe(self.fx, self.fz):
                self.golpe_dado = True
                self.juego.akira_golpeada()

    def actualizar_sprite(self, camara):
        if self.retirado:
            self.sprite.ocultar()
            poner_visible(self.aviso, False)
            return
        giro = camara.giro_sprites
        fila, voltear = elegir_vista(self.fx, self.fz, self.x, self.z, *camara.posicion_xz,
                                     *camara.derecha_xz)
        if self.estado == 'aviso':
            columna = 3
        elif self.estado == 'estocada':
            columna = 4
        elif self.estado == 'recuperacion':
            columna = 4 if self.t_estado > TIEMPO_RECUPERACION * 0.6 else 0
        elif self.moviendose:
            periodo = 0.1 if self.estado == 'persecucion' else 0.15
            columna = 1 + int(self.t_animacion / periodo) % 2
        else:
            columna = 0
        self.sprite.poner_cuadro(columna, fila, voltear)
        caida, opacidad = 0.0, 1.0
        if self.estado == 'muerto':
            caida = self.lado_caida * 90 * suavizar(self.t_estado / 0.4)
            opacidad = 1.0 - limitar((self.t_estado - 0.45) / (TIEMPO_CAIDA - 0.45), 0.0, 1.0)
        self.sprite.colocar(self.x, self.y, self.z, giro, caida, self.suelo, True, opacidad)
        self.sprite.destellar(0.6 if self.t_destello > 0 else 0.0, (1.0, 0.92, 0.85))
        # «!» sobre la cabeza durante el aviso
        if self.estado == 'aviso':
            salto = 0.06 * math.sin(self.t_estado * 40)
            self.aviso.position = Vec3(self.x, self.y + 2.05 + salto, self.z)
            self.aviso.rotation_y = giro
            poner_visible(self.aviso, True)
        else:
            poner_visible(self.aviso, False)


# =============================================================================
# CÁMARA
# =============================================================================

class CamaraOrbital:
    """Órbita alrededor de Akira según la especificación, con la presentación de la intro."""

    def __init__(self, juego):
        self.juego = juego
        self.reiniciar()
        self.modo = 'presentacion'
        self.t = 0.0
        self.t_transicion = 0.0
        self.posicion = (0.0, 0.0, 0.0)
        self.mira = (0.0, 0.0, 0.0)
        self.raton_anterior = None
        self.giro_sprites = 0.0
        self.posicion_xz = (0.0, 0.0)
        self.derecha_xz = (1.0, 0.0)
        self.adelante_xz = (0.0, 1.0)

    def reiniciar(self):
        self.giro = CAMARA_GIRO
        self.inclinacion = CAMARA_INCLINACION
        self.distancia = CAMARA_DISTANCIA
        self.distancia_deseada = CAMARA_DISTANCIA
        akira = self.juego.akira if hasattr(self.juego, 'akira') else None
        self.objetivo = (akira.x, akira.y, akira.z) if akira else convertir(*INICIO_AKIRA)

    def modo_presentacion(self):
        self.modo = 'presentacion'
        self.t = 0.0

    def iniciar_transicion(self):
        self.modo = 'transicion'
        self.t_transicion = 0.0
        akira = self.juego.akira
        self.objetivo = (akira.x, akira.y, akira.z)

    def modo_orbita(self):
        self.modo = 'orbita'
        akira = self.juego.akira
        self.objetivo = (akira.x, akira.y, akira.z)

    # --- controles (los mismos para teclas, ratón y la prueba automática) ---
    def girar(self, grados):
        self.giro = angulo_corto(self.giro + grados)

    def inclinar(self, grados):
        self.inclinacion = limitar(self.inclinacion + grados, CAMARA_INCL_MIN, CAMARA_INCL_MAX)

    def cambiar_zoom(self, metros):
        self.distancia_deseada = limitar(self.distancia_deseada + metros, CAMARA_DIST_MIN, CAMARA_DIST_MAX)

    def arrastrar(self, dx, dy):
        """Botón derecho + arrastrar (dx, dy en unidades de pantalla de Ursina)."""
        self.girar(-dx * 220)
        self.inclinar(-dy * 160)

    @staticmethod
    def altura_mirada(inclinacion):
        if inclinacion >= 30:
            return 1.0
        return 1.0 + (30 - inclinacion) / (30 - CAMARA_INCL_MIN) * 1.2

    def pose_orbita(self):
        ox, oy, oz = self.objetivo
        mira = (ox, oy + self.altura_mirada(self.inclinacion), oz)
        g, i, d = math.radians(self.giro), math.radians(self.inclinacion), self.distancia
        # Fórmula de la especificación, con Z invertida para los ejes de Ursina
        desplazamiento = (math.sin(g) * math.cos(i) * d, math.sin(i) * d, -math.cos(g) * math.cos(i) * d)
        return sumar(mira, desplazamiento), mira

    def pose_presentacion(self):
        x, y, z = convertir(*PRESENTACION_POSICION)
        vaiven = (0.35 * math.sin(self.t * 0.31), 0.12 * math.sin(self.t * 0.23 + 1.0), 0.0)
        mira = convertir(*PRESENTACION_MIRA)
        mira = (mira[0] + 0.5 * math.sin(self.t * 0.17), mira[1], mira[2])
        return sumar((x, y, z), vaiven), mira

    def leer_controles(self, dt, activo):
        if not activo:
            self.raton_anterior = None
            return
        teclas = held_keys
        self.girar((teclas['q'] - teclas['e']) * CAMARA_VEL_GIRO * dt)
        self.inclinar((teclas['r'] - teclas['f']) * CAMARA_VEL_INCLINACION * dt)
        acercar = teclas['+'] or teclas['='] or teclas['plus']
        alejar = teclas['-'] or teclas['minus']
        self.cambiar_zoom((alejar - acercar) * CAMARA_VEL_ZOOM * dt)
        if teclas['right mouse']:
            actual = (mouse.x, mouse.y)
            if self.raton_anterior is not None:
                self.arrastrar(actual[0] - self.raton_anterior[0], actual[1] - self.raton_anterior[1])
            self.raton_anterior = actual
        else:
            self.raton_anterior = None

    def actualizar(self, dt, controles_activos):
        self.t += dt
        self.leer_controles(dt, controles_activos)
        akira = self.juego.akira
        k = 1.0 - math.exp(-9.0 * dt)
        self.objetivo = mezclar_puntos(self.objetivo, (akira.x, akira.y, akira.z), k)
        self.distancia = mezclar(self.distancia, self.distancia_deseada, 1.0 - math.exp(-10.0 * dt))

        if self.modo == 'presentacion':
            posicion, mira = self.pose_presentacion()
        elif self.modo == 'transicion':
            self.t_transicion += dt
            s = suavizar(self.t_transicion / DURACION_TRANSICION)
            p0, m0 = self.pose_presentacion()
            p1, m1 = self.pose_orbita()
            posicion, mira = mezclar_puntos(p0, p1, s), mezclar_puntos(m0, m1, s)
            if self.t_transicion >= DURACION_TRANSICION:
                self.modo = 'orbita'
        else:
            posicion, mira = self.pose_orbita()
        self.posicion, self.mira = posicion, mira
        camera.position = Vec3(*posicion)
        camera.look_at(Vec3(*mira), up=Vec3(0, 1, 0))

        adelante = normalizar((mira[0] - posicion[0], 0.0, mira[2] - posicion[2]))
        self.adelante_xz = (adelante[0], adelante[2])
        self.derecha_xz = (adelante[2], -adelante[0])
        self.posicion_xz = (posicion[0], posicion[2])
        self.giro_sprites = math.degrees(math.atan2(adelante[0], adelante[2]))

    def direccion_movimiento(self, adelante, lado):
        """Convierte W/S (adelante) y A/D (lado) en una dirección del mundo según la cámara."""
        g = math.radians(self.giro)
        fx, fz = -math.sin(g), math.cos(g)          # hacia donde mira la cámara (plano XZ)
        rx, rz = fz, -fx                            # su derecha
        dx, dz = fx * adelante + rx * lado, fz * adelante + rz * lado
        largo = math.hypot(dx, dz)
        return (0.0, 0.0) if largo < 1e-6 else (dx / largo, dz / largo)


# =============================================================================
# INTERFAZ
# =============================================================================

class Rotulo(Text):
    """Texto de interfaz con una sombra suave para leerse sobre la escena."""

    def create_text_section(self, text, tag='', x=0, y=0):
        nodo = super().create_text_section(text, tag, x, y)
        nodo.setShadow(0.06, 0.06)
        nodo.setShadowColor(0, 0, 0, 0.85)
        return nodo


def partir_en_lineas(texto, ancho_maximo, escala):
    """Parte un párrafo en líneas que quepan en 'ancho_maximo' (unidades de la interfaz)."""
    medidor = TextNode('medidor')
    medidor.setFont(application.base.loader.loadFont(Text.default_font))
    unidad = Text.size * escala
    lineas, actual = [], ''
    for palabra in texto.split(' '):
        prueba = palabra if not actual else actual + ' ' + palabra
        if medidor.calcWidth(prueba) * unidad <= ancho_maximo or not actual:
            actual = prueba
        else:
            lineas.append(actual)
            actual = palabra
    if actual:
        lineas.append(actual)
    return lineas


class PantallaTexto:
    """Textos de la historia (intro, cierre, derrota): letra a letra, como en samurai.py."""

    ESCALA_CUERPO = 1.12
    ANCHO_CUERPO = 1.24

    def __init__(self):
        self.raiz = Entity(parent=camera.ui, enabled=False)
        self.velo = Entity(parent=self.raiz, model='quad', scale=(4, 2), color=Color(0.01, 0.01, 0.04, 0.3), z=0.5)
        self.titulo = Rotulo('', parent=self.raiz, position=(0, 0.405, -0.1), origin=(0, 0), scale=3.4,
                             color=color_rgb(DORADO))
        self.subtitulo = Rotulo('', parent=self.raiz, position=(0, 0.335, -0.1), origin=(0, 0), scale=1.15,
                                color=color_rgb(GRIS))
        self.borde = Entity(parent=self.raiz, model='quad', color=color_rgb((90, 80, 60), 0.9), z=0.2)
        self.panel = Entity(parent=self.raiz, model='quad', color=Color(0.0, 0.0, 0.0, 150 / 255), z=0.1)
        self.cuerpo = Rotulo('', parent=self.raiz, origin=(-0.5, 0.5), scale=self.ESCALA_CUERPO,
                             color=color_rgb(CREMA), z=-0.1)
        self.pie = Rotulo('', parent=self.raiz, position=(0, -0.445, -0.1), origin=(0, 0), scale=1.0,
                          color=color_rgb(DORADO))
        self.lineas = []
        self.total = 0
        self.visibles = 0.0
        self.mostrados = -1
        self.t = 0.0
        self.texto_pie = ''
        self.parrafos = []

    @property
    def activa(self):
        return self.raiz.enabled

    @property
    def completo(self):
        return self.visibles >= self.total

    def mostrar(self, titulo, subtitulo, parrafos, pie):
        self.raiz.enabled = True
        self.parrafos = list(parrafos)
        self.titulo.text = titulo
        self.subtitulo.text = subtitulo
        self.texto_pie = pie
        self.pie.text = ''
        self.lineas = []
        for parrafo in parrafos:
            self.lineas.extend(partir_en_lineas(parrafo, self.ANCHO_CUERPO, self.ESCALA_CUERPO))
            self.lineas.append('')
        if self.lineas:
            self.lineas.pop()
        self.total = sum(len(linea) for linea in self.lineas)
        self.visibles = 0.0
        self.mostrados = -1
        self.t = 0.0
        alto_linea = Text.size * self.ESCALA_CUERPO
        alto = len(self.lineas) * alto_linea
        arriba = -0.07 if len(self.lineas) > 3 else -0.16
        self.cuerpo.position = (-self.ANCHO_CUERPO / 2, arriba, -0.1)
        centro_y = arriba - alto / 2 + 0.004
        self.panel.position = (0, centro_y, 0.1)
        self.panel.scale = (self.ANCHO_CUERPO + 0.1, alto + 0.07)
        self.borde.position = (0, centro_y, 0.2)
        self.borde.scale = (self.ANCHO_CUERPO + 0.108, alto + 0.078)
        self.cuerpo.text = ''

    def completar(self):
        self.visibles = self.total

    def ocultar(self):
        self.raiz.enabled = False

    def actualizar(self, dt):
        if not self.activa:
            return
        self.t += dt
        if self.t > 0.6:
            self.visibles = min(self.total, self.visibles + VELOCIDAD_TEXTO * dt)
        mostrados = int(self.visibles)
        if mostrados != self.mostrados:
            self.mostrados = mostrados
            restantes = mostrados
            partes = []
            for linea in self.lineas:
                partes.append(linea[:max(0, restantes)])
                restantes -= len(linea)
            self.cuerpo.text = '\n'.join(partes).rstrip('\n') or ' '
        alfa = round(limitar(self.t / 0.8, 0.0, 1.0), 2)
        if alfa != getattr(self, '_alfa_titulo', None):
            self._alfa_titulo = alfa
            self.titulo.color = color_rgb(DORADO, alfa)
            self.subtitulo.color = color_rgb(GRIS, alfa)
        parpadea = self.completo and int(self.t * 2) % 2 == 0
        texto_pie = self.texto_pie if parpadea else ''
        if self.pie.text != texto_pie:
            self.pie.text = texto_pie

    @property
    def texto_completo(self):
        return ' '.join(self.parrafos)


class Hud:
    def __init__(self):
        self.raiz = Entity(parent=camera.ui, enabled=False)
        self.nombre = Rotulo('AKIRA', parent=self.raiz, position=(-0.855, 0.468, -0.1), origin=(-0.5, 0.5),
                             scale=1.35, color=color_rgb(CREMA))
        self.rombos = []
        for i in range(VIDA_MAXIMA):
            x = -0.845 + i * 0.045
            fondo = Entity(parent=self.raiz, model='quad', rotation_z=45, scale=0.03, position=(x, 0.405, 0),
                           color=Color(0.05, 0.02, 0.03, 0.9))
            relleno = Entity(parent=self.raiz, model='quad', rotation_z=45, scale=0.021, position=(x, 0.405, -0.05),
                             color=color_rgb(ROJO))
            brillo = Entity(parent=self.raiz, model='quad', rotation_z=45, scale=0.007,
                            position=(x - 0.004, 0.411, -0.06), color=Color(1, 0.72, 0.66, 0.9))
            self.rombos.append((relleno, brillo))
        self.contador = Rotulo('Soldados derrotados: 0/6', parent=self.raiz, position=(0.855, 0.468, -0.1),
                               origin=(0.5, 0.5), scale=1.2, color=color_rgb(CREMA))
        self.ayuda = Rotulo(TEXTO_AYUDA, parent=self.raiz, position=(0, -0.405, -0.1), origin=(0, 0),
                            scale=0.92, color=color_rgb(CREMA))
        self.motor = Rotulo(ROTULO_MOTOR, parent=camera.ui, position=(0.87, -0.475, -0.2), origin=(0.5, -0.5),
                            scale=0.9, color=color_rgb(GRIS, 0.9))
        self.pausa = Entity(parent=camera.ui, enabled=False)
        Entity(parent=self.pausa, model='quad', scale=(4, 2), color=Color(0, 0, 0, 0.55), z=0.3)
        Rotulo('Pausa', parent=self.pausa, origin=(0, 0), position=(0, 0.06, -0.1), scale=3,
               color=color_rgb(DORADO))
        Rotulo('ESC: continuar  ·  Q: salir', parent=self.pausa, origin=(0, 0), position=(0, -0.04, -0.1),
               scale=1.2, color=color_rgb(CREMA))
        self.vida_mostrada = None
        self.derrotados_mostrados = None

    def mostrar(self, visible):
        self.raiz.enabled = visible

    def actualizar(self, vida, derrotados, t_patio):
        if vida != self.vida_mostrada:
            self.vida_mostrada = vida
            for i, (relleno, brillo) in enumerate(self.rombos):
                lleno = i < vida
                relleno.color = color_rgb(ROJO) if lleno else Color(0.22, 0.08, 0.08, 1)
                brillo.visible = lleno
        if derrotados != self.derrotados_mostrados:
            self.derrotados_mostrados = derrotados
            self.contador.text = f'Soldados derrotados: {derrotados}/{len(PATRULLAS)}'
        alfa = round(1.0 - limitar((t_patio - (DURACION_AYUDA - 1.0)) / 1.0, 0.0, 1.0), 2)
        if alfa != getattr(self, '_alfa_ayuda', None):
            self._alfa_ayuda = alfa
            self.ayuda.enabled = alfa > 0
            self.ayuda.color = color_rgb(CREMA, alfa)


class Fundido:
    """Fundido a negro entre escenas (0,45 s, como en samurai.py)."""

    def __init__(self):
        self.velo = Entity(parent=camera.ui, model='quad', scale=(4, 2), color=Color(0, 0, 0, 0), z=-0.9)
        self.t = None
        self.accion = None
        self.hecho = False

    @property
    def activo(self):
        return self.t is not None

    def iniciar(self, accion):
        if self.activo:
            return
        self.t = 0.0
        self.accion = accion
        self.hecho = False

    def actualizar(self, dt):
        if self.t is None:
            return
        self.t += dt
        if self.t < DURACION_FUNDIDO:
            alfa = self.t / DURACION_FUNDIDO
        else:
            if not self.hecho:
                self.hecho = True
                self.accion()
            alfa = 1.0 - (self.t - DURACION_FUNDIDO) / DURACION_FUNDIDO
            if self.t >= 2 * DURACION_FUNDIDO:
                self.t = None
                alfa = 0.0
        self.velo.color = Color(0, 0, 0, limitar(alfa, 0.0, 1.0))


# =============================================================================
# JUEGO
# =============================================================================

def tecla_pulsada(*nombres):
    return 1 if any(held_keys[nombre] for nombre in nombres) else 0


class Juego(Entity):
    def __init__(self):
        super().__init__(name='juego')
        poner_valores_por_defecto()
        self.mundo = Mundo()
        self.escenario, self.tramos = construir_escenario(self.mundo)
        self.cielo = Cielo()
        AmbientLight(color=color_hex(COLOR_AMBIENTE, INTENSIDAD_AMBIENTE))
        self.luna = crear_luna(self.escenario)
        azar = random.Random(3)
        self.antorchas = [Antorcha(x, z, azar.uniform(0, 6.28)) for x, z in ANTORCHAS]
        self.linternas = [Linterna(x, z, azar.uniform(0, 6.28)) for x, z in LINTERNAS]
        self.akira = Akira(self)
        self.soldados = [Soldado(self, i, a, b) for i, (a, b) in enumerate(PATRULLAS)]
        self.camara = CamaraOrbital(self)
        self.hud = Hud()
        self.texto = PantallaTexto()
        self.fundido = Fundido()
        self.posproceso = not MODO_LIGERO
        if self.posproceso:
            camera.shader = SOMBREADOR_POSPROCESO
        camera.clip_plane_far = 2000
        self.tamano_ventana = None
        self.estado = 'intro'
        self.tiempo = 0.0
        self.t_patio = 0.0
        self.t_derrota = -1.0
        self.derrotados = 0
        self.ia_activa = True
        self.probador = Probador(self) if MODO_PRUEBA else None
        self.mostrar_intro()

    # --- flujo de escenas ---------------------------------------------------
    def reiniciar_patio(self):
        self.akira.reiniciar()
        for soldado in self.soldados:
            soldado.reiniciar()
        self.derrotados = 0
        self.t_patio = 0.0
        self.t_derrota = -1.0
        self.camara.reiniciar()

    def mostrar_intro(self):
        self.reiniciar_patio()
        self.estado = 'intro'
        self.camara.modo_presentacion()
        self.hud.mostrar(False)
        self.texto.mostrar(TITULO, SUBTITULO, TEXTO_INTRO, 'Pulsa ENTER para continuar')

    def empezar_partida(self):
        self.texto.ocultar()
        self.estado = 'patio'
        self.t_patio = 0.0
        self.camara.iniciar_transicion()
        self.hud.mostrar(True)

    def terminar_capitulo(self):
        self.estado = 'cierre'
        self.hud.mostrar(False)
        self.texto.mostrar('Fin del capítulo 1', 'El castillo de Hoshiyama', TEXTO_CIERRE,
                           'Pulsa ENTER para volver a empezar')

    def mostrar_derrota(self):
        self.estado = 'derrota'
        self.hud.mostrar(False)
        self.texto.mostrar('Akira ha caído', '', TEXTO_DERROTA, 'Pulsa ENTER para intentarlo de nuevo')

    def reintentar(self):
        self.texto.ocultar()
        self.reiniciar_patio()
        self.camara.modo_orbita()
        self.estado = 'patio'
        self.hud.mostrar(True)

    def continuar(self):
        if self.fundido.activo or not self.texto.activa:
            return
        if not self.texto.completo:
            self.texto.completar()
        elif self.estado == 'intro':
            self.empezar_partida()
        elif self.estado == 'cierre':
            self.fundido.iniciar(self.mostrar_intro)
        elif self.estado == 'derrota':
            self.fundido.iniciar(self.reintentar)

    def alternar_pausa(self):
        if self.estado == 'patio':
            self.estado = 'pausa'
            self.hud.pausa.enabled = True
        elif self.estado == 'pausa':
            self.estado = 'patio'
            self.hud.pausa.enabled = False

    def soldado_derrotado(self, soldado):
        self.derrotados += 1

    def akira_golpeada(self):
        if not self.akira.viva:
            self.t_derrota = 0.0

    # --- entrada ------------------------------------------------------------
    def input(self, tecla):
        if tecla == 'escape':
            self.alternar_pausa()
        elif tecla == 'q' and self.estado == 'pausa':
            application.quit()
        elif tecla in ('enter', 'return'):
            self.continuar()
        elif self.estado == 'patio':
            if tecla == 'space':
                self.akira.saltar()
            elif tecla in ('j', 'left mouse down'):
                self.akira.atacar()
            elif tecla == 'scroll up':
                self.camara.cambiar_zoom(-CAMARA_PASO_RUEDA)
            elif tecla == 'scroll down':
                self.camara.cambiar_zoom(CAMARA_PASO_RUEDA)

    # --- bucle --------------------------------------------------------------
    def update(self):
        dt = PASO_PRUEBA if MODO_PRUEBA else min(time.dt, 0.1)
        if self.probador:
            self.probador.paso(dt)
        self.tiempo += dt
        self.fundido.actualizar(dt)
        if self.estado == 'patio':
            self.actualizar_partida(dt)
        if self.estado in ('cierre', 'derrota'):
            self.camara.girar(5.0 * dt)
        self.camara.actualizar(dt, self.estado == 'patio')
        self.cielo.seguir(camera.world_position)
        self.actualizar_decorado()
        self.akira.actualizar_sprite(self.camara)
        for soldado in self.soldados:
            soldado.actualizar_sprite(self.camara)
        self.hud.actualizar(self.akira.vida, self.derrotados, self.t_patio)
        self.texto.actualizar(dt)
        self.actualizar_recorte(dt)
        self.actualizar_posproceso()

    def actualizar_partida(self, dt):
        self.t_patio += dt
        adelante = tecla_pulsada('w', 'up arrow') - tecla_pulsada('s', 'down arrow')
        lado = tecla_pulsada('d', 'right arrow') - tecla_pulsada('a', 'left arrow')
        correr = bool(tecla_pulsada('shift', 'left shift', 'right shift'))
        dir_x, dir_z = self.camara.direccion_movimiento(adelante, lado)
        pasos = max(1, math.ceil(dt / PASO_MAXIMO_FISICA - 1e-6))
        h = dt / pasos
        for _ in range(pasos):
            self.akira.actualizar(h, dir_x, dir_z, correr)
            for soldado in self.soldados:
                soldado.actualizar(h, self.ia_activa)
            self.separar_personajes()
        akira = self.akira
        if akira.viva and akira.x >= PORTON_X_TOQUE and abs(akira.z) < PORTON_MEDIO_ANCHO and akira.y < 4.0:
            self.terminar_capitulo()
        if not akira.viva:
            self.t_derrota = max(self.t_derrota, 0.0) + dt
            if self.t_derrota >= TIEMPO_CAIDA and not self.fundido.activo:
                self.fundido.iniciar(self.mostrar_derrota)

    def separar_personajes(self):
        akira = self.akira
        vivos = [s for s in self.soldados if s.vivo]
        for s in vivos:
            if abs(s.y - akira.y) > 1.7:
                continue
            dx, dz = akira.x - s.x, akira.z - s.z
            d = math.hypot(dx, dz)
            minimo = 2 * RADIO_PERSONAJE
            if 1e-6 < d < minimo:
                x = s.x + dx / d * minimo
                z = s.z + dz / d * minimo
                akira.x, akira.z = self.mundo.empujar(x, akira.y, z, RADIO_PERSONAJE, ALTURA_AKIRA)
        for i, a in enumerate(vivos):
            for b in vivos[i + 1:]:
                dx, dz = b.x - a.x, b.z - a.z
                d = math.hypot(dx, dz)
                if 1e-6 < d < 2 * RADIO_PERSONAJE:
                    empuje = (2 * RADIO_PERSONAJE - d) / 2
                    a.x -= dx / d * empuje
                    a.z -= dz / d * empuje
                    b.x += dx / d * empuje
                    b.z += dz / d * empuje

    def actualizar_decorado(self):
        for antorcha in self.antorchas:
            antorcha.actualizar(self.tiempo, self.camara.giro_sprites)
        for linterna in self.linternas:
            linterna.actualizar(self.tiempo)

    def actualizar_recorte(self, dt):
        """Si la cámara queda fuera de la muralla, el tramo que tapa a Akira se corta a la
        altura de la piedra; además se abre un hueco tramado alrededor de Akira."""
        raiz = application.base.render
        akira = self.akira
        activo = self.estado in ('patio', 'pausa', 'cierre', 'derrota') and self.camara.modo == 'orbita'
        pies = (akira.x, akira.y + 0.3, akira.z)
        for tramo in self.tramos:
            tramo.actualizar(dt, activo and tramo.tapa(self.camara.posicion, pies))
        if not activo:
            raiz.set_shader_input('recorte', Vec4(0, 0, 0, 0))
            return
        punto = Point3(akira.x, akira.y + 0.9, akira.z)
        relativo = application.base.cam.getRelativePoint(application.base.render, punto)
        proyectado = Point2()
        if not application.base.camLens.project(relativo, proyectado):
            raiz.set_shader_input('recorte', Vec4(0, 0, 0, 0))
            return
        ancho, alto = application.base.win.getXSize(), application.base.win.getYSize()
        distancia = relativo.length()
        radio = 1.15 / (2 * distancia * math.tan(math.radians(CAMARA_FOV / 2))) * alto
        raiz.set_shader_input('recorte', Vec4((proyectado.x + 1) / 2 * ancho, (proyectado.y + 1) / 2 * alto,
                                              radio, distancia))

    def actualizar_posproceso(self):
        if not self.posproceso:
            return
        tamano = (application.base.win.getXSize(), application.base.win.getYSize())
        if tamano != self.tamano_ventana:
            self.tamano_ventana = tamano
            camera.set_shader_input('window_size', Vec2(*tamano))


PORTON_X_TOQUE = PORTON[0][0] - PORTON[1][0] / 2 - RADIO_PERSONAJE - 0.06
PORTON_MEDIO_ANCHO = PORTON[1][2] / 2


# =============================================================================
# PRUEBA AUTOMÁTICA (--prueba)
# =============================================================================

class Probador:
    """Juega solo: pulsa y suelta teclas por el mismo camino que el teclado real (la
    entrada de Ursina), comprueba el resultado y guarda capturas. Avanza con un paso fijo
    de 1/30 s para que el resultado no dependa de lo lento que dibuje la máquina."""

    def __init__(self, juego):
        self.juego = juego
        self.guion = self.ejecutar()
        self.espera = -1.0
        self.resultados = []
        self.mantenidas = set()
        self.fps = None
        self.capturas = []
        self.t_inicio = time.perf_counter()
        CARPETA_CAPTURAS.mkdir(parents=True, exist_ok=True)

    # --- teclado simulado ---
    @staticmethod
    def _es_letra(tecla):
        return len(tecla) == 1 and tecla.isalpha()

    def pulsar(self, tecla):
        application.base.input(tecla, True) if self._es_letra(tecla) else application.base.input(tecla)

    def soltar(self, tecla):
        if self._es_letra(tecla):
            application.base.input_up(tecla, True)
        else:
            application.base.input_up(tecla)

    def tocar(self, tecla):
        self.pulsar(tecla)
        self.soltar(tecla)

    def mantener(self, teclas):
        teclas = set(teclas)
        for tecla in self.mantenidas - teclas:
            self.soltar(tecla)
        for tecla in teclas - self.mantenidas:
            self.pulsar(tecla)
        self.mantenidas = teclas

    # --- utilidades ---
    def comprobar(self, condicion, mensaje):
        self.resultados.append((bool(condicion), mensaje))
        print(('  [OK]    ' if condicion else '  [FALLO] ') + mensaje, flush=True)

    def capturar(self, nombre):
        ruta = CARPETA_CAPTURAS / nombre
        application.base.win.saveScreenshot(Filename.fromOsSpecific(str(ruta)))
        self.capturas.append(str(ruta))
        print(f'  [captura] {ruta}', flush=True)

    def paso(self, dt):
        self.espera -= dt
        if self.espera > 1e-6:
            return
        try:
            self.espera = next(self.guion) or 0.0
        except StopIteration:
            self.terminar()

    def cuadros(self, n=2):
        for _ in range(n):
            yield 0

    def teclas_hacia(self, dx, dz):
        """Teclas WASD que llevan hacia (dx, dz) con la cámara actual (8 direcciones)."""
        g = math.radians(self.juego.camara.giro)
        fx, fz = -math.sin(g), math.cos(g)
        rx, rz = fz, -fx
        adelante, lado = dx * fx + dz * fz, dx * rx + dz * rz
        teclas = set()
        if adelante > 0.38:
            teclas.add('w')
        elif adelante < -0.38:
            teclas.add('s')
        if lado > 0.38:
            teclas.add('d')
        elif lado < -0.38:
            teclas.add('a')
        return teclas

    def ir_a(self, x_espec, z_espec, tolerancia=0.35, tiempo_maximo=12.0, correr=False):
        destino_x, _, destino_z = convertir(x_espec, 0, z_espec)
        t = 0.0
        akira = self.juego.akira
        while t < tiempo_maximo:
            dx, dz = destino_x - akira.x, destino_z - akira.z
            d = math.hypot(dx, dz)
            if d < tolerancia or self.juego.estado != 'patio':
                break
            teclas = self.teclas_hacia(dx / d, dz / d)
            if correr and d > 1.5:
                teclas.add('lshift')
            self.mantener(teclas)
            yield 0
            t += PASO_PRUEBA
        self.mantener(set())

    def girar_camara_a(self, giro_objetivo, tiempo_maximo=5.0):
        camara = self.juego.camara
        t = 0.0
        while t < tiempo_maximo:
            diferencia = angulo_corto(giro_objetivo - camara.giro)
            if abs(diferencia) < 2.0:
                break
            self.mantener({'q'} if diferencia > 0 else {'e'})
            yield 0
            t += PASO_PRUEBA
        self.mantener(set())

    def medir_fps(self, segundos_reales):
        cuadros = 0
        inicio = time.perf_counter()
        while time.perf_counter() - inicio < segundos_reales or cuadros < 5:
            yield 0
            cuadros += 1
        self.fps = cuadros / (time.perf_counter() - inicio)
        print(f'  [FPS]   {self.fps:.1f} cuadros por segundo (render por software, orientativo)', flush=True)

    def soldado_cercano(self, radio):
        akira = self.juego.akira
        candidatos = [s for s in self.juego.soldados if s.vivo and abs(s.y - akira.y) < 1.0]
        if not candidatos:
            return None
        s = min(candidatos, key=lambda s: math.hypot(s.x - akira.x, s.z - akira.z))
        return s if math.hypot(s.x - akira.x, s.z - akira.z) <= radio else None

    def pelear(self, soldado, tiempo_maximo=8.0, al_golpear=None):
        """Se acerca al soldado y lo ataca con J hasta derrotarlo."""
        akira = self.juego.akira
        t = 0.0
        golpes_previos = soldado.golpes_recibidos
        while soldado.vivo and akira.viva and t < tiempo_maximo and self.juego.estado == 'patio':
            dx, dz = soldado.x - akira.x, soldado.z - akira.z
            d = math.hypot(dx, dz)
            mirando = (dx * akira.fx + dz * akira.fz) / max(d, 1e-6)
            if d > 1.25 or (mirando < 0.85 and not akira.atacando):
                # acercarse o, ya cerca, un paso hacia él para quedar de cara
                self.mantener(self.teclas_hacia(dx / d, dz / d))
            else:
                self.mantener(set())
                if akira.t_enfriamiento <= 0 and not akira.atacando:
                    con_aviso = any(s.estado == 'aviso' and math.hypot(s.x - akira.x, s.z - akira.z) < 5
                                    for s in self.juego.soldados)
                    self.tocar('j')
                    if con_aviso and al_golpear:
                        yield 0                     # ese cuadro ya muestra el tajo y el «!»
                        yield from al_golpear(soldado, aviso=True)
            yield 0
            t += PASO_PRUEBA
            if soldado.golpes_recibidos > golpes_previos:
                golpes_previos = soldado.golpes_recibidos
                if al_golpear:
                    yield from al_golpear(soldado)
        self.mantener(set())

    # --- guion de la prueba ---
    def ejecutar(self):
        j = self.juego
        akira, camara = j.akira, j.camara
        print('Prueba automática de RONIN 3D (Ursina)', flush=True)

        # 1. Introducción
        yield 1.2
        self.comprobar(j.estado == 'intro', 'El juego arranca en la introducción')
        self.tocar('enter')
        yield 0.2
        self.comprobar(j.texto.completo and j.texto.texto_completo == ' '.join(TEXTO_INTRO),
                       'ENTER completa el texto de la intro (idéntico a samurai.py)')
        yield 1.0
        self.capturar('ursina_intro.png')

        # 2. Al patio
        self.tocar('enter')
        yield 1.3
        self.comprobar(j.estado == 'patio' and camara.modo == 'orbita',
                       'ENTER pasa al patio y la cámara llega a la órbita')
        j.ia_activa = False          # soldados quietos mientras se comprueba el movimiento
        yield from self.cuadros(2)
        self.capturar('ursina_patio.png')
        yield from self.medir_fps(5.0)

        # 3. Cámara con Q
        giro_inicial = camara.giro
        self.mantener({'q'})
        yield 60 / CAMARA_VEL_GIRO
        self.mantener(set())
        yield 0.4
        girado = angulo_corto(camara.giro - giro_inicial)
        self.comprobar(abs(girado - 60) < 4, f'Q gira la cámara 90°/s ({giro_inicial:.0f}° → {camara.giro:.0f}°)')
        self.capturar('ursina_camara_girada.png')

        # 4. Caminar (W, relativo a la cámara: ahora mira al norte)
        x0, z0 = akira.x, akira.z
        self.mantener({'w'})
        yield 1.0
        self.mantener(set())
        yield 0.1
        recorrido = math.hypot(akira.x - x0, akira.z - z0)
        norte = (akira.z - z0) / max(recorrido, 1e-6)
        self.comprobar(4.4 < recorrido < 5.5, f'W: Akira camina {recorrido:.2f} m en 1 s (5 m/s)')
        self.comprobar(norte > 0.97, 'El movimiento es relativo a la cámara (W = hacia donde mira: norte)')

        # 5. Correr con SHIFT
        x0, z0 = akira.x, akira.z
        self.mantener({'w', 'lshift'})
        yield 0.5
        self.mantener(set())
        yield 0.1
        recorrido = math.hypot(akira.x - x0, akira.z - z0)
        self.comprobar(3.6 < recorrido < 4.4, f'W + SHIFT: Akira corre {recorrido:.2f} m en 0,5 s (8 m/s)')

        # 6. Saltar
        altura_maxima = 0.0
        self.tocar('space')
        for _ in range(30):
            yield 0
            altura_maxima = max(altura_maxima, akira.y)
        self.comprobar(1.15 < altura_maxima < 1.4, f'ESPACIO: salta {altura_maxima:.2f} m (≈1,28 m)')
        self.comprobar(akira.en_suelo and abs(akira.y) < 1e-3, 'Vuelve al suelo por la gravedad')

        # 7. Muro oeste: corre contra él y salta; no lo atraviesa
        yield from self.girar_camara_a(90)
        x0 = akira.x
        self.mantener({'w', 'lshift'})
        yield 1.5
        self.tocar('space')
        yield 0.9
        self.mantener(set())
        limite = -24 + RADIO_PERSONAJE
        self.comprobar(x0 - akira.x > 2.5, f'Corre hacia el oeste ({x0:.1f} → {akira.x:.2f})')
        self.comprobar(akira.x >= limite - 0.01, f'No atraviesa el muro oeste (x = {akira.x:.3f} ≥ {limite:.2f})')

        # 8. Zoom (rueda y + / −) e inclinación (R / F)
        yield 0.3
        distancia = camara.distancia_deseada
        self.tocar('wheel_up')
        self.tocar('wheel_up')
        self.comprobar(abs(camara.distancia_deseada - (distancia - 2 * CAMARA_PASO_RUEDA)) < 1e-3,
                       f'La rueda acerca la cámara ({distancia:.1f} → {camara.distancia_deseada:.1f} m)')
        self.mantener({'-'})
        yield 3.0
        self.mantener(set())
        self.comprobar(abs(camara.distancia_deseada - CAMARA_DIST_MAX) < 1e-3,
                       f'«−» aleja hasta el máximo ({camara.distancia_deseada:.1f} m)')
        self.mantener({'+'})
        yield 0.5
        self.mantener(set())
        self.comprobar(camara.distancia_deseada < CAMARA_DIST_MAX - 2.5,
                       f'«+» acerca ({camara.distancia_deseada:.1f} m)')
        self.mantener({'f'})
        yield 2.0
        self.mantener(set())
        self.comprobar(abs(camara.inclinacion - CAMARA_INCL_MIN) < 1e-3,
                       f'F baja la cámara hasta {camara.inclinacion:.0f}° (mira a {camara.altura_mirada(camara.inclinacion):.1f} m)')
        self.mantener({'r'})
        yield 1.0
        self.mantener(set())
        self.comprobar(abs(camara.inclinacion - (CAMARA_INCL_MIN + CAMARA_VEL_INCLINACION)) < 1.0,
                       f'R la sube ({camara.inclinacion:.0f}°)')
        camara.arrastrar(0.05, 0.0)
        self.comprobar(True, 'Arrastre con botón derecho: misma función de giro (probada por código)')
        yield from self.girar_camara_a(0)

        # 9. Subir al escalón y a la pasarela, y a los bloques de piedra
        yield from self.ir_a(-20, -8.3)
        yield from self.ir_a(-3, -8.3)
        yield from self.girar_camara_a(0)
        self.mantener({'w'})
        self.tocar('space')
        yield 0.45
        self.mantener(set())
        yield 0.6
        self.comprobar(abs(akira.y - 1.2) < 0.02, f'Sube saltando a la pasarela (pies a {akira.y:.2f} m)')
        yield from self.ir_a(-3, -8.0)
        yield from self.ir_a(6, -3.4)
        yield from self.girar_camara_a(0)
        self.mantener({'w'})
        self.tocar('space')
        yield 0.6
        self.mantener(set())
        yield 0.2
        self.comprobar(abs(akira.y - 0.8) < 0.02, f'Sube al bloque A ({akira.y:.2f} m)')
        self.mantener({'d'})
        self.tocar('space')
        yield 0.55
        self.mantener(set())
        yield 0.3
        self.comprobar(abs(akira.y - 1.6) < 0.02, f'Sube al bloque B ({akira.y:.2f} m)')

        # 10. Torreón y luna: cámara baja mirando al norte desde el oeste del patio
        yield from self.ir_a(6, -3.4)
        yield from self.ir_a(-7.5, -3.5)
        yield from self.girar_camara_a(5)
        self.mantener({'f', '-'})
        yield 2.5
        self.mantener(set())
        yield 1.0
        visibles = self.en_pantalla([convertir(0, 20, -32), convertir(0, 8, -32)])
        luna = self.juego.cielo.luna.world_position
        visibles_luna = self.en_pantalla([(luna.x, luna.y, luna.z)])
        self.comprobar(visibles, 'Con la cámara baja (−5°) el torreón entra en la imagen')
        self.comprobar(visibles_luna, 'La luna también se ve (baja, detrás del torreón)')
        self.capturar('ursina_torreon.png')

        # 11. Combate: se activan los soldados y Akira va hacia el portón peleando
        j.ia_activa = True
        self.mantener({'r'})
        yield (CAMARA_INCLINACION - CAMARA_INCL_MIN) / CAMARA_VEL_INCLINACION
        self.mantener({'+'})
        yield (CAMARA_DIST_MAX - CAMARA_DISTANCIA) / CAMARA_VEL_ZOOM
        self.mantener(set())
        self.comprobar(abs(camara.inclinacion - CAMARA_INCLINACION) < 1.6 and
                       abs(camara.distancia_deseada - CAMARA_DISTANCIA) < 0.2,
                       f'R y + devuelven la cámara a {camara.inclinacion:.0f}° y {camara.distancia_deseada:.1f} m')
        yield from self.girar_camara_a(-60)
        vida_inicial = akira.vida
        danados = []
        capturado = [False]

        def al_golpear(soldado, aviso=False):
            if not aviso:
                danados.append(soldado.indice)
            if not capturado[0] and (aviso or len(danados) >= 3):
                capturado[0] = True
                if not aviso:
                    yield 0
                self.capturar('ursina_combate.png')

        yield from self.ir_a(8, -1.5)
        tiempo = 0.0
        destino = convertir(27.0, 0, 0)          # detrás del portón: camina hasta tocarlo
        while j.estado == 'patio' and akira.viva and tiempo < 60:
            soldado = self.soldado_cercano(4.5)
            if soldado:
                yield from self.pelear(soldado, al_golpear=al_golpear)
                continue
            dx, dz = destino[0] - akira.x, destino[2] - akira.z
            d = math.hypot(dx, dz)
            if abs(akira.z) > 2.0 and akira.x > 17:
                dx, dz = 0.0, -akira.z
                d = abs(akira.z)
            self.mantener(self.teclas_hacia(dx / max(d, 1e-6), dz / max(d, 1e-6)) or {'d'})
            yield 0
            tiempo += PASO_PRUEBA
        self.mantener(set())
        self.comprobar(bool(danados), f'Los soldados reciben daño de la espada (golpes a los soldados {sorted(set(danados))})')
        self.comprobar(j.derrotados >= 1, f'Soldados derrotados: {j.derrotados}/6')
        if akira.vida < vida_inicial:
            self.comprobar(True, f'Las lanzas también hieren a Akira (vida {vida_inicial} → {akira.vida})')

        # 12. Portón: macizo y con cierre del capítulo
        yield 0.2
        self.comprobar(j.estado == 'cierre', 'Tocar el portón muestra el texto de cierre')
        limite = PORTON[0][0] - PORTON[1][0] / 2 - RADIO_PERSONAJE
        self.comprobar(akira.x <= limite + 0.01, f'El portón es macizo (x = {akira.x:.2f} ≤ {limite:.2f})')
        self.tocar('enter')
        yield 0.5
        self.comprobar(j.texto.texto_completo == ' '.join(TEXTO_CIERRE) and j.texto.completo,
                       'El texto de cierre es el de samurai.py')
        yield 0.6
        self.capturar('ursina_cierre.png')

        # 13. Derrota y reintento
        self.tocar('enter')                       # vuelve a la intro con un fundido
        yield 1.2
        self.comprobar(j.estado == 'intro', 'Tras el cierre, ENTER vuelve a la introducción')
        self.tocar('enter')
        yield 0.1
        self.tocar('enter')
        yield 1.3
        akira.vida = 1                            # preparación: un golpe basta
        tiempo = 0.0
        while j.estado == 'patio' and tiempo < 12:
            yield 0
            tiempo += PASO_PRUEBA
        yield 1.2
        self.comprobar(j.estado == 'derrota', 'Con vida 0 aparece «Akira ha caído»')
        self.tocar('enter')
        yield 0.3
        self.tocar('enter')
        yield 1.2
        self.comprobar(j.estado == 'patio' and akira.vida == VIDA_MAXIMA and j.derrotados == 0,
                       'ENTER reintenta: patio de nuevo con 5 de vida y los soldados en su sitio')
        yield 0.2

    def en_pantalla(self, puntos):
        base = application.base
        for p in puntos:
            relativo = base.cam.getRelativePoint(base.render, Point3(*p))
            proyectado = Point2()
            if not base.camLens.project(relativo, proyectado):
                return False
        return True

    def terminar(self):
        self.mantener(set())
        fallos = [m for ok, m in self.resultados if not ok]
        duracion = time.perf_counter() - self.t_inicio
        print('', flush=True)
        print(f'Resultado: {len(self.resultados) - len(fallos)}/{len(self.resultados)} comprobaciones correctas '
              f'({duracion:.0f} s reales).', flush=True)
        if self.fps is not None:
            print(f'FPS medidos en el patio: {self.fps:.1f}', flush=True)
        for fallo in fallos:
            print('  Falló: ' + fallo, flush=True)
        sys.exit(1 if fallos else 0)


# =============================================================================
# PRINCIPAL
# =============================================================================

def principal():
    app = Ursina(title='RONIN', size=(ANCHO_VENTANA, ALTO_VENTANA), borderless=False, fullscreen=False,
                 development_mode=True, editor_ui_enabled=False)
    window.editor_ui.enabled = False            # sin la interfaz de desarrollo de Ursina
    if getattr(application, 'hot_reloader', None):
        application.hot_reloader.enabled = False
    window.color = color_hex(CIELO_HORIZONTE)
    mouse.traverse_target = None                # no hacen falta colisionadores para el ratón
    camera.fov = CAMARA_FOV
    camera.perspective_lens.set_min_fov(CAMARA_FOV)   # campo de visión vertical de 38°
    TEXTURAS.update(cargar_texturas())
    Text.default_resolution = 1080 * Text.size * 3
    Juego()
    app.run()


if __name__ == '__main__':
    principal()
