# Caja viva A+C (prueba de calidad, DECISIONES 27 y 28): la caja de mosaico yosegi con la máscara
# incompleta delante y los costados de cómoda tansu, sobre su zócalo de laca con olas doradas; y en la
# mesa baja, el incensario y el juego de té. Todo por código, para Godot (GLB).
#
#   /root/herramientas/blender-4.5.14-linux-x64/blender -b -P puzles/herramientas/blender/caja_viva_ac.py \
#       -- [--vista /ruta/vista.png]
#
# Antes, `preparar_cara.py` saca el relieve y el color de la cara. Ejes de Blender: X a la derecha,
# Y hacia el fondo, Z arriba; el frente de la caja mira a -Y (en Godot, a +Z). Medidas en metros.
import math
import os
import sys

import bmesh
import bpy
from mathutils import Matrix, Vector

AQUI = os.path.dirname(os.path.abspath(__file__))
PUZLES = os.path.normpath(os.path.join(AQUI, "..", ".."))
TEXTURAS = os.path.join(PUZLES, "godot", "recursos", "texturas")
ARTE = os.path.join(PUZLES, "arte", "caja_viva")
MODELOS = os.path.join(PUZLES, "godot", "modelos", "caja_viva")
SALIDA = os.path.join(MODELOS, "caja_viva_ac.glb")              # la caja
SALIDA_MESA = os.path.join(MODELOS, "mesa_caja_viva.glb")       # el incensario y el juego de té

ANCHO = 0.22                 # X
FONDO = 0.22                 # Y
ALTO = 0.21                  # Z, sin el zócalo
ZOCALO = 0.034
MARCO = 0.014                # listones de laca negra en las aristas
SALE = 0.003                 # lo que sobresalen los listones de los paneles
HUECO = 0.0028               # junta entre cajones
BASE_Z = ZOCALO              # la caja empieza encima del zócalo


# --- Utilidades -----------------------------------------------------------------------------------

def textura(nombre):
    return os.path.join(TEXTURAS, nombre + ".png")


_imagenes = {}


def imagen(ruta, datos=False):
    if ruta not in _imagenes:
        img = bpy.data.images.load(ruta)
        if datos:
            img.colorspace_settings.name = "Non-Color"
        _imagenes[ruta] = img
    return _imagenes[ruta]


def material(nombre, color=(0.8, 0.8, 0.8), rugosidad=0.5, metalico=0.0, mapa=None, normal=None,
             fuerza_normal=1.0, emision=None, fuerza_emision=0.0, capa=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    nodos = m.node_tree.nodes
    enlaces = m.node_tree.links
    bsdf = nodos["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value = rugosidad
    bsdf.inputs["Metallic"].default_value = metalico
    if capa > 0.0:
        bsdf.inputs["Coat Weight"].default_value = capa
        bsdf.inputs["Coat Roughness"].default_value = 0.08
    if mapa:
        nodo = nodos.new("ShaderNodeTexImage")
        nodo.image = imagen(mapa)
        enlaces.new(nodo.outputs["Color"], bsdf.inputs["Base Color"])
    if normal:
        nodo = nodos.new("ShaderNodeTexImage")
        nodo.image = imagen(normal, datos=True)
        relieve = nodos.new("ShaderNodeNormalMap")
        relieve.inputs["Strength"].default_value = fuerza_normal
        enlaces.new(nodo.outputs["Color"], relieve.inputs["Color"])
        enlaces.new(relieve.outputs["Normal"], bsdf.inputs["Normal"])
    if emision:
        nodo = nodos.new("ShaderNodeTexImage")
        nodo.image = imagen(emision)
        enlaces.new(nodo.outputs["Color"], bsdf.inputs["Emission Color"])
        bsdf.inputs["Emission Strength"].default_value = fuerza_emision
    return m


def objeto(nombre, bm, mat, posicion=(0.0, 0.0, 0.0), padre=None, suave=False):
    malla = bpy.data.meshes.new(nombre)
    bm.to_mesh(malla)
    bm.free()
    if suave:
        for poligono in malla.polygons:
            poligono.use_smooth = True
    obj = bpy.data.objects.new(nombre, malla)
    bpy.context.scene.collection.objects.link(obj)
    if isinstance(mat, (list, tuple)):
        for m in mat:
            malla.materials.append(m)
    elif mat:
        malla.materials.append(mat)
    obj.location = posicion
    if padre:
        obj.parent = padre
    return obj


def uv_caja(bm, origen, tamano, giro=0.0):
    """UV por proyección en caja, con el origen en el mundo para que el dibujo case entre piezas."""
    capa = bm.loops.layers.uv.verify()
    c, s = math.cos(giro), math.sin(giro)
    for cara in bm.faces:
        n = cara.normal
        eje = max(range(3), key=lambda i: abs(n[i]))
        for bucle in cara.loops:
            p = bucle.vert.co + origen
            if eje == 0:
                u, v = p.y, p.z
            elif eje == 1:
                u, v = p.x, p.z
            else:
                u, v = p.x, p.y
            u, v = u * c - v * s, u * s + v * c
            bucle[capa].uv = (u / tamano, v / tamano)


def biselar(obj, ancho=0.0012, segmentos=2):
    mod = obj.modifiers.new("Bisel", "BEVEL")
    mod.width = ancho
    mod.segments = segmentos
    mod.limit_method = "ANGLE"
    mod.harden_normals = True
    for poligono in obj.data.polygons:
        poligono.use_smooth = True
    return obj


def caja(nombre, tamano, centro, mat, bisel=0.0012, uv=0.08, giro_uv=0.0, padre=None, origen_uv=None):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co = Vector((v.co.x * tamano[0], v.co.y * tamano[1], v.co.z * tamano[2]))
    bm.normal_update()
    uv_caja(bm, Vector(origen_uv if origen_uv is not None else centro), uv, giro_uv)
    obj = objeto(nombre, bm, mat, centro, padre)
    if bisel > 0.0:
        biselar(obj, bisel)
    return obj


def torno(nombre, perfil, centro, mat, lados=48, uv=0.06, padre=None, plano=False):
    """Pieza torneada: perfil = [(radio, z), ...] de abajo arriba. Un radio 0 cierra con un polo.
    plano: UV vistas desde arriba (para tableros), en vez de alrededor."""
    bm = bmesh.new()
    capa = bm.loops.layers.uv.verify()
    anillos = []
    for radio, z in perfil:
        if radio < 1e-6:
            anillos.append([bm.verts.new((0.0, 0.0, z))])
        else:
            anillos.append([bm.verts.new((radio * math.cos(2 * math.pi * i / lados),
                                          radio * math.sin(2 * math.pi * i / lados), z))
                            for i in range(lados)])
    largo = 0.0
    alturas = [0.0]
    for k in range(1, len(perfil)):
        largo += math.hypot(perfil[k][0] - perfil[k - 1][0], perfil[k][1] - perfil[k - 1][1])
        alturas.append(largo)
    vuelta = 2 * math.pi * max(r for r, _ in perfil)
    for k in range(len(anillos) - 1):
        a, b = anillos[k], anillos[k + 1]
        for i in range(lados):
            j = (i + 1) % lados
            if len(a) == 1:
                cara = bm.faces.new((a[0], b[i], b[j]))
            elif len(b) == 1:
                cara = bm.faces.new((a[i], a[j], b[0]))
            else:
                cara = bm.faces.new((a[i], a[j], b[j], b[i]))
            for bucle in cara.loops:
                vert = bucle.vert
                fila = k if vert in a else k + 1
                indice = i if (len(anillos[fila]) == 1 or vert == anillos[fila][i]) else i + 1
                bucle[capa].uv = (indice / lados * vuelta / uv, alturas[fila] / uv)
    bm.normal_update()
    if plano:
        uv_caja(bm, Vector(centro), uv)
    return objeto(nombre, bm, mat, centro, padre, suave=not plano)


def toro(nombre, radio, grosor, centro, mat, rotacion=(0.0, 0.0, 0.0), lados=32, seccion=10, padre=None):
    bm = bmesh.new()
    capa = bm.loops.layers.uv.verify()
    filas = []
    for i in range(lados):
        a = 2 * math.pi * i / lados
        fila = []
        for j in range(seccion):
            b = 2 * math.pi * j / seccion
            r = radio + grosor * math.cos(b)
            fila.append(bm.verts.new((r * math.cos(a), r * math.sin(a), grosor * math.sin(b))))
        filas.append(fila)
    for i in range(lados):
        for j in range(seccion):
            cara = bm.faces.new((filas[i][j], filas[(i + 1) % lados][j], filas[(i + 1) % lados][(j + 1) % seccion],
                                 filas[i][(j + 1) % seccion]))
            for bucle in cara.loops:
                bucle[capa].uv = (0.5, 0.5)
    bm.transform(Matrix.Rotation(rotacion[0], 4, "X") @ Matrix.Rotation(rotacion[1], 4, "Y")
                 @ Matrix.Rotation(rotacion[2], 4, "Z"))
    bm.normal_update()
    return objeto(nombre, bm, mat, centro, padre, suave=True)


def prisma(nombre, contorno, grosor, matriz, mat, padre=None, bisel=0.0004):
    """Polígono 2D (en metros) extruido «grosor» y colocado con «matriz» (su Z es la normal)."""
    bm = bmesh.new()
    abajo = [bm.verts.new((x, y, 0.0)) for x, y in contorno]
    cara = bm.faces.new(abajo)
    extruido = bmesh.ops.extrude_face_region(bm, geom=[cara])
    for v in [e for e in extruido["geom"] if isinstance(e, bmesh.types.BMVert)]:
        v.co.z += grosor
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.transform(matriz)
    bm.normal_update()
    uv_caja(bm, Vector((0.0, 0.0, 0.0)), 0.05)
    obj = objeto(nombre, bm, mat, (0.0, 0.0, 0.0), padre)
    if bisel > 0.0:
        biselar(obj, bisel, 1)
    return obj


def esfera(nombre, radio, centro, mat, escala=(1.0, 1.0, 1.0), padre=None):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=20, v_segments=12, radius=radio)
    for v in bm.verts:
        v.co = Vector((v.co.x * escala[0], v.co.y * escala[1], v.co.z * escala[2]))
    bm.normal_update()
    uv_caja(bm, Vector(centro), 0.04)
    return objeto(nombre, bm, mat, centro, padre, suave=True)


# --- Materiales -------------------------------------------------------------------------------------

def materiales():
    return {
        "laca_negra": material("LacaNegra", (0.018, 0.015, 0.013), 0.16, capa=0.6),
        "bermellon": material("LacaBermellon", (0.55, 0.06, 0.03), 0.22, capa=0.4),
        "oro": material("OroViejo", (0.72, 0.52, 0.24), 0.38, 1.0, mapa=None, normal=textura("laton_n"),
                        fuerza_normal=0.35),
        "hierro": material("Hierro", (0.07, 0.065, 0.06), 0.45, 0.85),
        "yabane": material("YosegiYabane", rugosidad=0.42, mapa=textura("yosegi_yabane"),
                           normal=textura("yosegi_yabane_n"), fuerza_normal=0.6),
        "asanoha": material("YosegiAsanoha", rugosidad=0.42, mapa=textura("yosegi_asanoha"),
                            normal=textura("yosegi_asanoha_n"), fuerza_normal=0.6),
        "kikko": material("YosegiKikko", rugosidad=0.42, mapa=textura("yosegi_kikko"),
                          normal=textura("yosegi_kikko_n"), fuerza_normal=0.6),
        "ichimatsu": material("YosegiIchimatsu", rugosidad=0.42, mapa=textura("yosegi_ichimatsu"),
                              normal=textura("yosegi_ichimatsu_n"), fuerza_normal=0.6),
        "uroko": material("YosegiUroko", rugosidad=0.42, mapa=textura("yosegi_uroko"),
                          normal=textura("yosegi_uroko_n"), fuerza_normal=0.6),
        "paulownia": material("Paulownia", rugosidad=0.55, mapa=textura("madera_clara"),
                              normal=textura("madera_clara_n"), fuerza_normal=0.4),
        "cara": material("Cara", rugosidad=0.5, mapa=os.path.join(ARTE, "cara_color.png"),
                         emision=os.path.join(ARTE, "cara_emision.png"), fuerza_emision=3.0),
        "seigaiha": material("Seigaiha", rugosidad=0.3, mapa=textura("seigaiha"), normal=textura("seigaiha_n"),
                             fuerza_normal=0.8),
        "seda": material("SedaRoja", (0.5, 0.04, 0.05), 0.55),
        "papel": material("Papel", rugosidad=0.85, mapa=textura("papel")),
        "bambu": material("Bambu", (0.62, 0.5, 0.28), 0.45),
        "mesa": material("MesaLacada", rugosidad=0.14, mapa=textura("madera_oscura"),
                         normal=textura("madera_oscura_n"), fuerza_normal=0.3, capa=0.8),
        "bronce": material("Bronce", (0.2, 0.15, 0.09), 0.48, 1.0, normal=textura("laton_n"),
                           fuerza_normal=0.8),
        "barro": material("Barro", (0.42, 0.22, 0.13), 0.62),
        "te": material("Te", (0.36, 0.24, 0.06), 0.05),
    }


# --- La caja ------------------------------------------------------------------------------------------

def nucleo(m, raiz):
    """Cuerpo de laca negra: los listones de las doce aristas, un poco más salientes que los paneles."""
    x, y, z = ANCHO / 2.0, FONDO / 2.0, ALTO / 2.0
    cz = BASE_Z + z
    caja("Cuerpo", (ANCHO - 2 * SALE, FONDO - 2 * SALE, ALTO - 2 * SALE), (0.0, 0.0, cz), m["laca_negra"],
         bisel=0.0, padre=raiz)
    for sx in (-1, 1):
        for sy in (-1, 1):
            caja("Liston", (MARCO, MARCO, ALTO), (sx * (x - MARCO / 2), sy * (y - MARCO / 2), cz), m["laca_negra"],
                 bisel=0.0016, padre=raiz)
        for sz in (-1, 1):
            caja("Liston", (MARCO, FONDO - 2 * MARCO, MARCO), (sx * (x - MARCO / 2), 0.0, cz + sz * (z - MARCO / 2)),
                 m["laca_negra"], bisel=0.0016, padre=raiz)
    for sy in (-1, 1):
        for sz in (-1, 1):
            caja("Liston", (ANCHO - 2 * MARCO, MARCO, MARCO), (0.0, sy * (y - MARCO / 2), cz + sz * (z - MARCO / 2)),
                 m["laca_negra"], bisel=0.0016, padre=raiz)


def frente(m, raiz):
    """El frente: mosaico en diagonal y, en medio, la placa de paulownia con la cara tallada."""
    y = -FONDO / 2.0 + SALE / 2.0
    cz = BASE_Z + ALTO / 2.0
    caja("PanelFrente", (ANCHO - 2 * MARCO + 0.002, SALE, ALTO - 2 * MARCO + 0.002), (0.0, y, cz), m["yabane"],
         bisel=0.0, uv=0.07, giro_uv=math.pi / 4, padre=raiz)
    # placa de la cara: rejilla con el relieve (punto medio 0,3; sube 1,4 cm y los agujeros bajan 6 mm)
    ancho, alto = 0.158, 0.172
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, x_segments=180, y_segments=196, size=0.5)
    capa = bm.loops.layers.uv.verify()
    for cara_rejilla in bm.faces:
        for bucle in cara_rejilla.loops:
            bucle[capa].uv = (bucle.vert.co.x + 0.5, bucle.vert.co.y + 0.5)
    bm.transform(Matrix.Diagonal((ancho, alto, 1.0, 1.0)))
    bm.transform(Matrix.Rotation(math.pi / 2, 4, "X"))
    bm.normal_update()
    delante = 0.008
    cara = objeto("Cara", bm, m["cara"], (0.0, -FONDO / 2.0 - delante, cz + 0.002), raiz, suave=True)
    textura_altura = bpy.data.textures.new("AlturaCara", type="IMAGE")
    textura_altura.image = imagen(os.path.join(ARTE, "cara_altura.png"), datos=True)
    textura_altura.extension = "EXTEND"
    desplazar = cara.modifiers.new("Relieve", "DISPLACE")
    desplazar.texture = textura_altura
    desplazar.texture_coords = "UV"
    desplazar.mid_level = 0.3
    desplazar.strength = 0.02            # sube hasta 1,4 cm; los agujeros bajan 6 mm
    desplazar.direction = "NORMAL"
    # marco fino de laca alrededor de la placa
    for sx in (-1, 1):
        caja("MarcoCara", (0.006, delante + 0.004, alto + 0.012),
             (sx * (ancho / 2 + 0.003), -FONDO / 2.0 - delante / 2.0 + 0.001, cz + 0.002), m["laca_negra"],
             bisel=0.0012, padre=raiz)
    for sz in (-1, 1):
        caja("MarcoCara", (ancho, delante + 0.004, 0.006),
             (0.0, -FONDO / 2.0 - delante / 2.0 + 0.001, cz + 0.002 + sz * (alto / 2 + 0.003)), m["laca_negra"],
             bisel=0.0012, padre=raiz)
    # fondo negro detrás de la placa, por si algún agujero llega más allá
    caja("FondoCara", (ancho, 0.002, alto), (0.0, -FONDO / 2.0 - 0.001, cz + 0.002), m["laca_negra"], bisel=0.0,
         padre=raiz)


def cajonera(m, raiz, lado, filas, abiertos, prefijo, materiales_frentes, extras=None):
    """Cómoda de cajones en una cara de la caja. lado: «derecha» (+X) o «detras» (+Y).
    filas: de abajo arriba, [(alto, [anchos...]), ...]; abiertos: {(fila, columna): cuánto sale}."""
    interior_y = FONDO - 2 * MARCO if lado == "derecha" else ANCHO - 2 * MARCO
    z = BASE_Z + MARCO
    indice = 0
    for f, (alto, anchos) in enumerate(filas):
        u = -interior_y / 2.0
        for c, ancho in enumerate(anchos):
            sale = abiertos.get((f, c), 0.0)
            centro_u = u + ancho / 2.0
            centro_z = z + alto / 2.0
            frente_tamano = (ancho - HUECO, alto - HUECO)
            nombre = "%s_%d" % (prefijo, indice)
            if extras and (f, c) in extras:
                extras[(f, c)](centro_u, centro_z, frente_tamano)
            else:
                cajon(m, raiz, lado, nombre, centro_u, centro_z, frente_tamano, sale,
                      materiales_frentes[indice % len(materiales_frentes)])
            u += ancho
            indice += 1
        z += alto


def cajon(m, raiz, lado, nombre, u, z, tamano, sale, mat_frente):
    """Un cajón: frente de mosaico, tirador de anilla de hierro y, por dentro, laca bermellón."""
    ancho, alto = tamano
    hondo = 0.08
    if lado == "derecha":
        normal = Vector((1.0, 0.0, 0.0))
        base = Vector((ANCHO / 2.0 - SALE + sale, u, z))
        tam_frente = (0.006, ancho, alto)
        tam_lado = (hondo, 0.003, alto * 0.82)
        eje_u = Vector((0.0, 1.0, 0.0))
    else:
        normal = Vector((0.0, 1.0, 0.0))
        base = Vector((u, FONDO / 2.0 - SALE + sale, z))
        tam_frente = (ancho, 0.006, alto)
        tam_lado = (0.003, hondo, alto * 0.82)
        eje_u = Vector((1.0, 0.0, 0.0))
    padre = bpy.data.objects.new(nombre, None)
    bpy.context.scene.collection.objects.link(padre)
    padre.parent = raiz
    padre.location = base
    caja(nombre + "_frente", tam_frente, normal * 0.0, mat_frente, bisel=0.0008, uv=0.045, padre=padre,
         origen_uv=base)
    if sale > 0.0:
        # costados, fondo y suelo del cajón, de laca bermellón, que se ven al tirar de él
        for s in (-1, 1):
            caja(nombre + "_costado", tam_lado, -normal * (hondo / 2.0) + eje_u * s * (ancho / 2.0 - 0.003),
                 m["bermellon"], bisel=0.0, padre=padre)
        suelo = (hondo, ancho - 0.004, 0.003) if lado == "derecha" else (ancho - 0.004, hondo, 0.003)
        caja(nombre + "_suelo", suelo, -normal * (hondo / 2.0) - Vector((0.0, 0.0, alto * 0.38)), m["bermellon"],
             bisel=0.0, padre=padre)
    # tirador: chapita de hierro y anilla colgando
    chapa = 0.0045 if alto > 0.035 else 0.0036
    giro = (0.0, math.pi / 2, 0.0) if lado == "derecha" else (math.pi / 2, 0.0, 0.0)
    toro(nombre + "_chapa", chapa, 0.0011, normal * 0.0035, m["hierro"], giro, padre=padre)
    anilla = toro(nombre + "_anilla", chapa * 1.35, 0.0009, normal * 0.0042 - Vector((0.0, 0.0, chapa * 1.3)),
                  m["hierro"], (0.0, 0.0, 0.0), padre=padre)
    anilla.rotation_euler = (math.pi / 2, 0.0, math.pi / 2) if lado == "derecha" else (math.pi / 2, 0.0, 0.0)
    return padre


def costados(m, raiz):
    # derecha: cómoda tansu (de abajo arriba)
    filas = [(0.05, [0.095, 0.097]), (0.044, [0.062, 0.068, 0.062]), (0.044, [0.11, 0.082]),
             (0.044, [0.062, 0.13])]
    cajonera(m, raiz, "derecha", filas, {(2, 0): 0.034, (0, 1): 0.022}, "CajonDerecho",
             [m["asanoha"], m["kikko"], m["ichimatsu"], m["uroko"]])
    # detrás: cajones, el hueco de la ficha de shōgi y el cajón largo con cerradura
    def hueco_ficha(u, z, tamano):
        y = FONDO / 2.0 - SALE / 2.0 + 0.001
        caja("PanelFicha", (tamano[0], 0.004, tamano[1]), (u, y, z), m["yabane"], bisel=0.0008, uv=0.07,
             giro_uv=math.pi / 4, padre=raiz)
        ficha = [(-0.011, -0.016), (0.011, -0.016), (0.013, 0.006), (0.0, 0.017), (-0.013, 0.006)]
        prisma("HuecoFicha", ficha, 0.001, Matrix.Translation((u, y + 0.0025, z)) @ Matrix.Rotation(-math.pi / 2, 4, "X"),
               m["laca_negra"], padre=raiz)
    def cajon_largo(u, z, tamano):
        cajon(m, raiz, "detras", "CajonLargo", u, z, tamano, 0.0, m["paulownia"])
        cerradura = [(-0.0035, -0.004), (0.0035, -0.004), (0.0012, 0.0), (0.0025, 0.0035), (0.0, 0.0055),
                     (-0.0025, 0.0035), (-0.0012, 0.0)]
        prisma("Cerradura", [(x * 1.4, y * 1.4) for x, y in cerradura], 0.0008,
               Matrix.Translation((u, FONDO / 2.0 + 0.0035, z + 0.004)) @ Matrix.Rotation(-math.pi / 2, 4, "X"),
               m["oro"], padre=raiz)
    filas = [(0.05, [0.192]), (0.044, [0.06, 0.072, 0.06]), (0.044, [0.06, 0.072, 0.06]), (0.044, [0.06, 0.072, 0.06])]
    cajonera(m, raiz, "detras", filas, {(2, 0): 0.02}, "CajonDetras",
             [m["kikko"], m["asanoha"], m["uroko"], m["ichimatsu"]],
             extras={(0, 0): cajon_largo, (1, 1): hueco_ficha, (2, 1): hueco_ficha})
    # izquierda: un panel de mosaico entero
    caja("PanelIzquierdo", (SALE, FONDO - 2 * MARCO + 0.002, ALTO - 2 * MARCO + 0.002),
         (-ANCHO / 2.0 + SALE / 2.0, 0.0, BASE_Z + ALTO / 2.0), m["yabane"], bisel=0.0, uv=0.07, giro_uv=math.pi / 4,
         padre=raiz)
    # arriba: mosaico y la trampilla redonda de latón
    caja("PanelArriba", (ANCHO - 2 * MARCO + 0.002, FONDO - 2 * MARCO + 0.002, SALE),
         (0.0, 0.0, BASE_Z + ALTO - SALE / 2.0), m["asanoha"], bisel=0.0, uv=0.06, padre=raiz)
    torno("Trampilla", [(0.0, 0.0), (0.028, 0.0), (0.03, 0.0012), (0.029, 0.0024), (0.026, 0.0028), (0.0, 0.0028)],
          (0.02, 0.03, BASE_Z + ALTO + 0.0002), m["oro"], padre=raiz)
    torno("TrampillaCentro", [(0.0, 0.0), (0.012, 0.0), (0.012, 0.0008), (0.0, 0.0008)],
          (0.02, 0.03, BASE_Z + ALTO + 0.003), m["laca_negra"], padre=raiz)


def esquineros(m, raiz):
    """Herrajes dorados en las ocho esquinas: tres chapas triangulares con el borde festoneado."""
    lado = 0.034
    contorno = [(0.0, 0.0), (lado, 0.0)]
    for i in range(1, 8):
        t = i / 8.0
        x, y = lado * (1 - t), lado * t
        hundido = 0.0035 * math.sin(t * math.pi * 3) ** 2
        contorno.append((x - hundido * 0.7, y - hundido * 0.7))
    contorno.append((0.0, lado))
    x, y = ANCHO / 2.0, FONDO / 2.0
    for sx in (-1, 1):
        for sy in (-1, 1):
            for sz in (-1, 1):
                esquina = Vector((sx * x, sy * y, BASE_Z + (ALTO if sz > 0 else 0.0)))
                # en cada cara, la chapa sale de la esquina hacia dentro
                ejes = [(Vector((-sx, 0, 0)), Vector((0, 0, -sz)), Vector((0, sy, 0))),   # cara Y
                        (Vector((0, -sy, 0)), Vector((0, 0, -sz)), Vector((sx, 0, 0))),   # cara X
                        (Vector((-sx, 0, 0)), Vector((0, -sy, 0)), Vector((0, 0, sz)))]   # cara Z
                for a, b, n in ejes:
                    matriz = Matrix((
                        (a.x, b.x, n.x, esquina.x + n.x * 0.0002),
                        (a.y, b.y, n.y, esquina.y + n.y * 0.0002),
                        (a.z, b.z, n.z, esquina.z + n.z * 0.0002),
                        (0, 0, 0, 1)))
                    if matriz.to_3x3().determinant() < 0:
                        matriz = matriz @ Matrix.Scale(-1, 4, (0, 0, 1))
                        matriz = Matrix.Translation(n * 0.0012) @ matriz
                    prisma("Esquinero", contorno, 0.0012, matriz, m["oro"], padre=raiz)


def zocalo(m, raiz):
    """Zócalo de laca negra con la banda de olas doradas y cuatro patas en las esquinas."""
    lado = ANCHO + 0.036
    caja("ZocaloTapa", (lado, lado, 0.01), (0.0, 0.0, ZOCALO - 0.005), m["laca_negra"], bisel=0.002, padre=raiz)
    alto_banda = 0.018
    for s in (-1, 1):
        caja("ZocaloBanda", (lado - 0.012, 0.004, alto_banda), (0.0, s * (lado / 2.0 - 0.008), 0.006 + alto_banda / 2.0),
             m["seigaiha"], bisel=0.0006, uv=0.05, padre=raiz)
        caja("ZocaloBanda", (0.004, lado - 0.012, alto_banda), (s * (lado / 2.0 - 0.008), 0.0, 0.006 + alto_banda / 2.0),
             m["seigaiha"], bisel=0.0006, uv=0.05, padre=raiz)
    for sx in (-1, 1):
        for sy in (-1, 1):
            caja("ZocaloPata", (0.03, 0.03, ZOCALO - 0.01), (sx * (lado / 2.0 - 0.017), sy * (lado / 2.0 - 0.017),
                 (ZOCALO - 0.01) / 2.0), m["laca_negra"], bisel=0.0015, padre=raiz)


def borla(m, raiz):
    """Cordón de seda roja con su nudo y la borla, colgando del costado izquierdo."""
    x = -ANCHO / 2.0 - 0.003
    y = FONDO / 2.0 - 0.03
    z0 = BASE_Z + ALTO - 0.004
    puntos = [(x, y, z0 + 0.004), (x - 0.002, y - 0.004, z0 - 0.02), (x - 0.003, y - 0.006, z0 - 0.05),
              (x - 0.003, y - 0.006, z0 - 0.07)]
    curva = bpy.data.curves.new("Cordon", "CURVE")
    curva.dimensions = "3D"
    curva.bevel_depth = 0.0016
    curva.bevel_resolution = 3
    spline = curva.splines.new("POLY")
    spline.points.add(len(puntos) - 1)
    for punto, p in zip(spline.points, puntos):
        punto.co = (*p, 1.0)
    cordon = bpy.data.objects.new("Cordon", curva)
    bpy.context.scene.collection.objects.link(cordon)
    cordon.parent = raiz
    curva.materials.append(m["seda"])
    toro("Nudo", 0.004, 0.0018, (x - 0.003, y - 0.006, z0 - 0.045), m["seda"], (0.0, math.pi / 2, 0.0), padre=raiz)
    torno("Borla", [(0.0, 0.0), (0.006, 0.002), (0.0075, 0.018), (0.005, 0.03), (0.003, 0.034), (0.0, 0.036)],
          (x - 0.003, y - 0.006, z0 - 0.112), m["seda"], lados=24, padre=raiz)


def dentro_de_los_cajones(m, raiz):
    """Lo que asoma de los dos cajones abiertos del costado: la llave de bambú y un papel doblado."""
    x = ANCHO / 2.0 + 0.012
    z = BASE_Z + MARCO + 0.05 + 0.044 + 0.012
    caja("LlaveBambu", (0.006, 0.05, 0.005), (x, -0.06, z), m["bambu"], bisel=0.0015, padre=raiz)
    caja("Papel", (0.03, 0.04, 0.002), (x - 0.006, 0.05, BASE_Z + MARCO + 0.012), m["papel"], bisel=0.0004, padre=raiz)


# --- La mesa y lo que hay en ella ---------------------------------------------------------------------

def mesa(m, raiz):
    torno("MesaTablero", [(0.0, -0.034), (0.4, -0.034), (0.404, -0.03), (0.405, -0.004), (0.401, 0.0), (0.0, 0.0)],
          (0.05, 0.02, 0.0), m["mesa"], lados=96, uv=0.35, padre=raiz, plano=True)
    for i in range(4):
        a = math.pi / 4 + i * math.pi / 2
        caja("MesaPata", (0.04, 0.04, 0.29), (0.05 + 0.28 * math.cos(a), 0.02 + 0.28 * math.sin(a), -0.034 - 0.145),
             m["mesa"], bisel=0.004, uv=0.3, padre=raiz)


def incensario(m, raiz):
    """Incensario de bronce (kōro) con tres patas, asas y la tapa calada con un león guardián."""
    c = Vector((-0.24, -0.08, 0.0))
    torno("Incensario", [(0.0, 0.014), (0.026, 0.014), (0.038, 0.02), (0.045, 0.031), (0.046, 0.041),
                         (0.042, 0.05), (0.037, 0.054), (0.038, 0.057), (0.033, 0.057), (0.031, 0.052)],
          c, m["bronce"], padre=raiz)
    torno("IncensarioTapa", [(0.0375, 0.0565), (0.036, 0.064), (0.03, 0.073), (0.02, 0.079), (0.009, 0.082),
                             (0.0, 0.0825)], c, m["bronce"], padre=raiz)
    for i in range(3):
        a = math.pi / 2 + i * 2 * math.pi / 3
        pie = Vector((0.03 * math.cos(a), 0.03 * math.sin(a), 0.0))
        torno("IncensarioPata", [(0.0, 0.0), (0.0055, 0.0), (0.006, 0.004), (0.0045, 0.012), (0.006, 0.017),
                                 (0.0, 0.017)], c + pie, m["bronce"], lados=16, padre=raiz)
    for s in (-1, 1):
        toro("IncensarioAsa", 0.008, 0.0018, c + Vector((s * 0.049, 0.0, 0.046)), m["bronce"], (0.0, math.pi / 2, 0.0),
             padre=raiz)
    # león guardián, sentado, hecho de formas suaves
    leon = c + Vector((0.0, 0.0, 0.082))
    esfera("LeonCuerpo", 0.011, leon + Vector((0.0, 0.004, 0.009)), m["bronce"], (0.75, 1.1, 0.9), padre=raiz)
    esfera("LeonMelena", 0.0095, leon + Vector((0.0, -0.006, 0.02)), m["bronce"], (1.05, 0.85, 1.0), padre=raiz)
    esfera("LeonCabeza", 0.0068, leon + Vector((0.0, -0.011, 0.021)), m["bronce"], (1.0, 0.95, 0.9), padre=raiz)
    esfera("LeonHocico", 0.0034, leon + Vector((0.0, -0.0172, 0.0185)), m["bronce"], (1.2, 0.9, 0.8), padre=raiz)
    for s in (-1, 1):
        esfera("LeonPata", 0.0032, leon + Vector((s * 0.0045, -0.012, 0.004)), m["bronce"], (1.0, 1.2, 1.6), padre=raiz)
        esfera("LeonOreja", 0.0022, leon + Vector((s * 0.0062, -0.009, 0.0265)), m["bronce"], padre=raiz)
    toro("LeonCola", 0.005, 0.0016, leon + Vector((0.0, 0.016, 0.017)), m["bronce"], (0.0, math.pi / 2, 0.0),
         padre=raiz)


def juego_de_te(m, raiz):
    tetera = Vector((0.3, 0.06, 0.0))
    torno("Tetera", [(0.0, 0.0), (0.03, 0.0), (0.045, 0.012), (0.05, 0.03), (0.046, 0.05), (0.034, 0.062),
                     (0.02, 0.066), (0.0, 0.066)], tetera, m["barro"], padre=raiz)
    torno("TeteraTapa", [(0.021, 0.066), (0.02, 0.071), (0.012, 0.075), (0.005, 0.077), (0.006, 0.083),
                         (0.0, 0.085)], tetera, m["barro"], padre=raiz)
    pico = bpy.data.curves.new("Pico", "CURVE")
    pico.dimensions = "3D"
    pico.bevel_depth = 0.0055
    spline = pico.splines.new("POLY")
    spline.points.add(2)
    for punto, p in zip(spline.points, [(-0.04, 0.0, 0.03), (-0.062, 0.0, 0.045), (-0.074, 0.0, 0.06)]):
        punto.co = (p[0] + tetera.x, p[1] + tetera.y, p[2], 1.0)
    obj = bpy.data.objects.new("TeteraPico", pico)
    bpy.context.scene.collection.objects.link(obj)
    obj.parent = raiz
    pico.materials.append(m["barro"])
    toro("TeteraAsa", 0.022, 0.0045, tetera + Vector((0.052, 0.0, 0.04)), m["barro"], (math.pi / 2, 0.0, 0.0),
         padre=raiz)
    for i, (x, y) in enumerate([(0.24, -0.16), (0.33, -0.12)]):
        torno("Taza", [(0.0, 0.0), (0.016, 0.0), (0.017, 0.002), (0.021, 0.012), (0.023, 0.03), (0.021, 0.03),
                       (0.019, 0.013), (0.015, 0.004), (0.0, 0.004)], (x, y, 0.0), m["barro"], lados=32, padre=raiz)
        torno("TazaTe", [(0.0, 0.0), (0.0205, 0.0), (0.0, 0.0)], (x, y, 0.024), m["te"], lados=32, padre=raiz)


# --- Vista previa en Blender (para revisar sin abrir Godot) -----------------------------------------------

def vista(ruta):
    escena = bpy.context.scene
    camara = bpy.data.objects.new("Camara", bpy.data.cameras.new("Camara"))
    escena.collection.objects.link(camara)
    camara.location = (0.42, -0.62, 0.42)
    direccion = Vector((0.0, 0.0, 0.12)) - camara.location
    camara.rotation_euler = direccion.to_track_quat("-Z", "Y").to_euler()
    camara.data.lens = 42
    escena.camera = camara
    for nombre, posicion, energia, color, tamano in [
            ("Andon", (-0.6, -0.2, 0.5), 18.0, (1.0, 0.72, 0.42), 0.3),
            ("Luna", (0.6, 0.5, 0.8), 10.0, (0.55, 0.65, 1.0), 0.8),
            ("Relleno", (0.3, -0.8, 0.3), 3.0, (1.0, 0.9, 0.8), 1.0)]:
        luz = bpy.data.objects.new(nombre, bpy.data.lights.new(nombre, "AREA"))
        luz.data.energy = energia
        luz.data.color = color
        luz.data.size = tamano
        luz.location = posicion
        luz.rotation_euler = (Vector((0.0, 0.0, 0.1)) - Vector(posicion)).to_track_quat("-Z", "Y").to_euler()
        escena.collection.objects.link(luz)
    mundo = bpy.data.worlds.new("Mundo")
    mundo.use_nodes = True
    mundo.node_tree.nodes["Background"].inputs[0].default_value = (0.03, 0.03, 0.04, 1.0)
    escena.world = mundo
    escena.render.engine = "CYCLES"
    escena.cycles.device = "CPU"
    escena.cycles.samples = 40
    escena.cycles.use_denoising = True
    escena.render.resolution_x = 1100
    escena.render.resolution_y = 620
    escena.render.filepath = ruta
    bpy.ops.render.render(write_still=True)


def exportar(raiz, ruta):
    """Exporta «raiz» y todo lo que cuelga de ella. En el GLB, el origen es el tablero de la mesa."""
    bpy.ops.object.select_all(action="DESELECT")
    pendientes = [raiz]
    while pendientes:
        obj = pendientes.pop()
        obj.select_set(True)
        pendientes.extend(obj.children)
    bpy.context.view_layer.objects.active = raiz
    bpy.ops.export_scene.gltf(filepath=ruta, export_format="GLB", export_apply=True, export_yup=True,
                              use_selection=True, export_texcoords=True, export_normals=True,
                              export_materials="EXPORT")
    print("GLB:", ruta, os.path.getsize(ruta) // 1024, "KB")


def main():
    argumentos = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    bpy.ops.wm.read_factory_settings(use_empty=True)
    m = materiales()
    caja_viva = bpy.data.objects.new("CajaVivaAC", None)
    bpy.context.scene.collection.objects.link(caja_viva)
    nucleo(m, caja_viva)
    frente(m, caja_viva)
    costados(m, caja_viva)
    esquineros(m, caja_viva)
    zocalo(m, caja_viva)
    borla(m, caja_viva)
    dentro_de_los_cajones(m, caja_viva)
    sobre_la_mesa = bpy.data.objects.new("SobreLaMesa", None)
    bpy.context.scene.collection.objects.link(sobre_la_mesa)
    incensario(m, sobre_la_mesa)
    juego_de_te(m, sobre_la_mesa)
    os.makedirs(MODELOS, exist_ok=True)
    exportar(caja_viva, SALIDA)
    exportar(sobre_la_mesa, SALIDA_MESA)
    # la mesa solo para la vista previa: en el juego es la de la habitación
    solo_vista = bpy.data.objects.new("SoloVista", None)
    bpy.context.scene.collection.objects.link(solo_vista)
    mesa(m, solo_vista)
    if "--vista" in argumentos:
        vista(argumentos[argumentos.index("--vista") + 1])


main()
