# Chōchin-obake (id 680 del bestiario) modelada con el conector de Trimble SketchUp.
# No es un script suelto: es el código que se pasa a build_model (Python dentro de SketchUp en la
# nube, sin import; «model», «math», «SUPoint3D»… ya vienen cargados). Unidades: pulgadas, Z arriba,
# el frente mira a −Y. Ficha: farol de papel viejo y roto con un ojo enorme, la boca rasgada con la
# lengua larga, una sola pierna con geta y una llama dentro.

# --- Ayudantes ---------------------------------------------------------------------------------
def material(nombre, r, g, b, a=255):
    existentes = {m.get_name(): m for m in model.get_materials()}
    if nombre in existentes:
        return existentes[nombre]
    m = Material()
    m.set_name(nombre)
    m.set_color(SUColor(r, g, b, a))
    model.add_materials([m])
    return m

def todos(valores):                          # «all» no existe en el entorno de SketchUp
    for v in valores:
        if not v:
            return False
    return True

def pintar(grupo, mat):
    for f in grupo.get_entities().get_faces():
        f.set_front_material(mat)
        f.set_back_material(mat)

def circle_pts(cx, cy, cz, r, n=10):
    return [SUPoint3D(cx + r * math.cos(2 * math.pi * i / n), cy + r * math.sin(2 * math.pi * i / n), cz) for i in range(n)]

def skin_rings(geom, ring_b, ring_t, n):
    for j in range(n):
        j2 = (j + 1) % n
        lp = LoopInput()
        lp.add_vertex_index(ring_b[j]); lp.add_vertex_index(ring_b[j2]); lp.add_vertex_index(ring_t[j2])
        _, geom = geom.add_face(lp)
        lp2 = LoopInput()
        lp2.add_vertex_index(ring_b[j]); lp2.add_vertex_index(ring_t[j2]); lp2.add_vertex_index(ring_t[j])
        _, geom = geom.add_face(lp2)
    return geom

def skin_fan_to_pole(geom, ring, pole_idx, n, pole_is_top):
    for j in range(n):
        j2 = (j + 1) % n
        lp = LoopInput()
        if pole_is_top:
            lp.add_vertex_index(ring[j]); lp.add_vertex_index(ring[j2]); lp.add_vertex_index(pole_idx)
        else:
            lp.add_vertex_index(ring[j]); lp.add_vertex_index(pole_idx); lp.add_vertex_index(ring[j2])
        _, geom = geom.add_face(lp)
    return geom

def cap_ngon(geom, ring_indices, rev=False):
    loop = LoopInput()
    for i in (list(reversed(ring_indices)) if rev else ring_indices):
        loop.add_vertex_index(i)
    _, geom = geom.add_face(loop)
    return geom

def cap_circle_edges(geom, start_vertex_idx, center, normal, n):
    _, _, geom = geom.add_arc_curve(start_vertex_idx, start_vertex_idx, center, normal, n)
    return geom

def build_lofted_solid(profile, n=10):
    geom = GeometryInput()
    all_verts = []
    rings = []
    last_i = len(profile) - 1
    for i, (h, r) in enumerate(profile):
        if r == 0 and (i == 0 or i == last_i):
            all_verts.append(SUPoint3D(0, 0, h))
            rings.append(('pole', len(all_verts) - 1))
        else:
            ring_start = len(all_verts)
            all_verts.extend(circle_pts(0, 0, h, r, n))
            rings.append(('ring', list(range(ring_start, ring_start + n))))
    geom.set_vertices(all_verts)
    for i, (kind, payload) in enumerate(rings):
        if kind != 'ring':
            continue
        h = profile[i][0]
        normal = SUVector3D(0, 0, -1) if i == 0 else SUVector3D(0, 0, 1)
        geom = cap_circle_edges(geom, payload[0], SUPoint3D(0, 0, h), normal, n)
    for i in range(len(rings) - 1):
        a_kind, a_pay = rings[i]
        b_kind, b_pay = rings[i + 1]
        if a_kind == 'ring' and b_kind == 'ring':
            geom = skin_rings(geom, a_pay, b_pay, n)
        elif a_kind == 'pole' and b_kind == 'ring':
            geom = skin_fan_to_pole(geom, b_pay, a_pay, n, pole_is_top=False)
        elif a_kind == 'ring' and b_kind == 'pole':
            geom = skin_fan_to_pole(geom, a_pay, b_pay, n, pole_is_top=True)
    if rings[0][0] == 'ring':
        geom = cap_ngon(geom, rings[0][1], rev=True)
    if rings[-1][0] == 'ring':
        geom = cap_ngon(geom, rings[-1][1], rev=False)
    return geom

def clean_geometry(group, profile, erase_threshold=0.9999, smooth=False):
    first_h, first_r = profile[0]
    last_h, last_r = profile[-1]
    cap_heights = set()
    if first_r > 0:
        cap_heights.add(round(first_h, 2))
    if last_r > 0:
        cap_heights.add(round(last_h, 2))
    if smooth:
        preserve_heights = set(cap_heights)
        for i in range(1, len(profile) - 1):
            h_prev, r_prev = profile[i - 1]
            h_curr, r_curr = profile[i]
            h_next, r_next = profile[i + 1]
            slope_in = (r_curr - r_prev) / (h_curr - h_prev) if h_curr != h_prev else None
            slope_out = (r_next - r_curr) / (h_next - h_curr) if h_next != h_curr else None
            if (slope_in is not None and abs(slope_in) < 1e-6) or (slope_out is not None and abs(slope_out) < 1e-6):
                preserve_heights.add(round(h_curr, 2))
    else:
        transition_heights = set()
        for i in range(1, len(profile) - 1):
            if abs(profile[i - 1][1] - profile[i][1]) > 0.001 or abs(profile[i][1] - profile[i + 1][1]) > 0.001:
                transition_heights.add(round(profile[i][0], 2))
        preserve_heights = cap_heights | transition_heights
    for _ in range(2000):
        found = False
        for edge in group.get_entities().get_edges():
            faces = edge.get_faces()
            if len(faces) == 2:
                n0 = faces[0].get_normal()
                n1 = faces[1].get_normal()
                if n0.x * n1.x + n0.y * n1.y + n0.z * n1.z > erase_threshold:
                    group.get_entities().erase_entities([edge])
                    found = True
                    break
        if not found:
            break
    for edge in group.get_entities().get_edges():
        if len(edge.get_faces()) == 2:
            edge.set_soft(True)
            edge.set_smooth(True)
    for edge in group.get_entities().get_edges():
        sv = edge.get_start_vertex().get_position()
        ev = edge.get_end_vertex().get_position()
        if abs(round(sv.z, 2) - round(ev.z, 2)) < 0.01 and round(sv.z, 2) in preserve_heights:
            edge.set_soft(False)
            edge.set_smooth(False)

def make_quad_box(w, d, h):
    geom = GeometryInput()
    geom.set_vertices([SUPoint3D(0, 0, 0), SUPoint3D(w, 0, 0), SUPoint3D(w, d, 0), SUPoint3D(0, d, 0),
                       SUPoint3D(0, 0, h), SUPoint3D(w, 0, h), SUPoint3D(w, d, h), SUPoint3D(0, d, h)])
    for fv in [[0, 1, 5, 4], [1, 2, 6, 5], [2, 3, 7, 6], [3, 0, 4, 7], [4, 5, 6, 7], [0, 3, 2, 1]]:
        loop = LoopInput()
        for i in fv:
            loop.add_vertex_index(i)
        _, geom = geom.add_face(loop)
    return geom

def tras(x, y, z, sx=1.0, sy=1.0, sz=1.0):
    return SUTransformation([sx, 0, 0, 0, 0, sy, 0, 0, 0, 0, sz, 0, x, y, z, 1])

def nuevo_grupo(entidades, nombre):
    g = Group()
    entidades.add_group(g)
    g.set_name(nombre)
    return g

def revolucion(entidades, nombre, perfil, n, mat, suave=False):
    g = nuevo_grupo(entidades, nombre)
    g.get_entities().fill(build_lofted_solid(perfil, n=n), weld_vertices=True)
    clean_geometry(g, perfil, smooth=suave)
    pintar(g, mat)
    return g

# Cuerpo de papel: cuadriláteros directos (son planos) y sin arcos registrados en las tapas. Con
# build_lofted_solid + clean_geometry las dos bandas junto a cada tapa quedaban con aristas
# duplicadas (96 bordes abiertos, el sólido no cerraba); así cierra a la primera.
def solido_sin_arcos(perfil, n):
    geom = GeometryInput()
    verts, anillos = [], []
    for h, r in perfil:
        inicio = len(verts)
        verts.extend(circle_pts(0, 0, h, r, n))
        anillos.append(list(range(inicio, inicio + n)))
    geom.set_vertices(verts)
    for i in range(len(anillos) - 1):
        a, b = anillos[i], anillos[i + 1]
        for j in range(n):
            j2 = (j + 1) % n
            lp = LoopInput()
            for k in (a[j], a[j2], b[j2], b[j]):
                lp.add_vertex_index(k)
            _, geom = geom.add_face(lp)
    geom = cap_ngon(geom, anillos[0], rev=True)
    geom = cap_ngon(geom, anillos[-1], rev=False)
    return geom

def cuerpo_papel(entidades, nombre, perfil, boca_z, signo, papel, luz):
    g = nuevo_grupo(entidades, nombre)
    g.get_entities().fill(solido_sin_arcos(perfil, 24), weld_vertices=True)
    for f in g.get_entities().get_faces():
        boca = signo * f.get_normal().z > 0.99 and todos(abs(v.get_position().z - boca_z) < 0.01 for v in f.get_vertices())
        f.set_front_material(luz if boca else papel)
        f.set_back_material(luz if boca else papel)
    for e in g.get_entities().get_edges():         # suave salvo los anillos (las varillas del farol)
        if len(e.get_faces()) == 2:
            p, q = e.get_start_vertex().get_position(), e.get_end_vertex().get_position()
            anillo = abs(p.z - q.z) < 0.01
            e.set_soft(not anillo)
            e.set_smooth(not anillo)
    return g

def perfil_esfera(R, pasos=8):
    return [(-R * math.cos(math.pi * k / pasos), 0.0 if k in (0, pasos) else R * math.sin(math.pi * k / pasos)) for k in range(pasos + 1)]

# Vectores como tuplas
def v_sub(a, b): return (a[0] - b[0], a[1] - b[1], a[2] - b[2])
def v_add(a, b): return (a[0] + b[0], a[1] + b[1], a[2] + b[2])
def v_mul(a, s): return (a[0] * s, a[1] * s, a[2] * s)
def v_dot(a, b): return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]
def v_cross(a, b): return (a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0])
def v_norm(a):
    l = math.sqrt(v_dot(a, a)) or 1.0
    return (a[0] / l, a[1] / l, a[2] / l)

def catmull(ctrl, pasos):
    pts = [ctrl[0]] + list(ctrl) + [ctrl[-1]]
    salida = []
    for i in range(1, len(pts) - 2):
        p0, p1, p2, p3 = pts[i - 1], pts[i], pts[i + 1], pts[i + 2]
        for k in range(pasos):
            t = k / float(pasos)
            fila = []
            for c in range(3):
                fila.append(0.5 * (2 * p1[c] + (-p0[c] + p2[c]) * t + (2 * p0[c] - 5 * p1[c] + 4 * p2[c] - p3[c]) * t * t
                                   + (-p0[c] + 3 * p1[c] - 3 * p2[c] + p3[c]) * t * t * t))
            salida.append((fila[0], fila[1], fila[2]))
    salida.append((ctrl[-1][0], ctrl[-1][1], ctrl[-1][2]))
    return salida

# Barrido con un marco que gira con el camino (lengua, asa): sección elíptica, triángulos y tapas.
def barrido(entidades, nombre, camino, anchos, gruesos, n, normal0, mat):
    geom = GeometryInput()
    verts, anillos = [], []
    N = v_norm(normal0)
    m = len(camino)
    for i in range(m):
        if i == 0:
            T = v_norm(v_sub(camino[1], camino[0]))
        elif i == m - 1:
            T = v_norm(v_sub(camino[-1], camino[-2]))
        else:
            T = v_norm(v_sub(camino[i + 1], camino[i - 1]))
        N = v_norm(v_sub(N, v_mul(T, v_dot(N, T))))
        S = v_cross(T, N)
        anillo = []
        for j in range(n):
            a = 2 * math.pi * j / n
            p = v_add(camino[i], v_add(v_mul(S, anchos[i] * 0.5 * math.cos(a)), v_mul(N, gruesos[i] * 0.5 * math.sin(a))))
            verts.append(SUPoint3D(p[0], p[1], p[2]))
            anillo.append(len(verts) - 1)
        anillos.append(anillo)
    geom.set_vertices(verts)
    for i in range(m - 1):
        a, b = anillos[i], anillos[i + 1]
        for j in range(n):
            j2 = (j + 1) % n
            for tri in ((a[j], a[j2], b[j2]), (a[j], b[j2], b[j])):
                lp = LoopInput()
                for k in tri:
                    lp.add_vertex_index(k)
                _, geom = geom.add_face(lp)
    geom = cap_ngon(geom, anillos[0], rev=True)
    geom = cap_ngon(geom, anillos[-1], rev=False)
    g = nuevo_grupo(entidades, nombre)
    g.get_entities().fill(geom, weld_vertices=True)
    for e in g.get_entities().get_edges():
        if len(e.get_faces()) == 2:
            e.set_soft(True)
            e.set_smooth(True)
    pintar(g, mat)
    return g

# --- Materiales (colores planos: en la nube no hay texturas de SketchUp) ------------------------
PAPEL = material("Papel_Farol", 238, 205, 150)
LACA = material("Laca_Negra", 35, 28, 30)
LUZ = material("Luz_Interior", 255, 150, 50)
LENGUA = material("Lengua", 205, 55, 75)
BLANCO = material("Ojo_Blanco", 245, 240, 225)
IRIS = material("Ojo_Iris", 235, 165, 40)
PUPILA = material("Ojo_Pupila", 20, 14, 18)
MADERA = material("Madera", 110, 75, 45)

# --- Medidas ------------------------------------------------------------------------------------
Z0, ALTO = 15.5, 22.0                       # cuerpo de papel: de 15,5" a 37,5"
def radio(t):
    return 5.0 + 4.0 * math.sin(math.pi * t)  # barril: 5" en los aros, 9" en medio
TM = 0.42                                   # altura de la boca (fracción del cuerpo)
ZM, RM = Z0 + TM * ALTO, radio(TM)

raiz = nuevo_grupo(model.get_entities(), "Chochin_Obake")
E = raiz.get_entities()

# Pierna y geta
revolucion(E, "Pierna", [(2.0, 0.55), (14.0, 0.45)], 10, MADERA)
geta = nuevo_grupo(E, "Geta")
for nombre, caja, pos in [("Geta_Tabla", (3.4, 7.0, 0.8), (-1.7, -3.5, 1.2)),
                          ("Geta_Diente_Delantero", (3.2, 0.7, 1.2), (-1.6, -3.0, 0.0)),
                          ("Geta_Diente_Trasero", (3.2, 0.7, 1.2), (-1.6, 2.3, 0.0))]:
    pieza = nuevo_grupo(geta.get_entities(), nombre)
    pieza.get_entities().fill(make_quad_box(*caja), weld_vertices=True)
    pieza.set_transform(tras(*pos))
    pintar(pieza, MADERA)

# Mitad de abajo del farol: aro de laca y papel con costillas (cada anillo se ve como una varilla)
revolucion(E, "Aro_Inferior", [(14.0, 5.5), (15.5, 5.5)], 24, LACA)
cuerpo_papel(E, "Cuerpo_Inferior", [(Z0 + t * ALTO, radio(t)) for t in [0, .05, .10, .15, .20, .25, .30, .35, TM]], ZM, 1, PAPEL, LUZ)  # el suelo de la boca brilla: la llama de dentro

# Lengua larga que cuelga de la boca
ctrl = [(0, -RM + 2.5, ZM + 0.4), (0, -RM - 0.4, ZM + 1.0), (0.3, -RM - 2.0, ZM + 0.4), (0.6, -RM - 2.7, ZM - 2.5),
        (0.4, -RM - 2.5, ZM - 6.0), (-0.2, -RM - 1.6, ZM - 8.6), (-0.5, -RM - 0.6, ZM - 9.6)]
camino = catmull(ctrl, 4)
m = len(camino)
anchos = [1.9 - 0.5 * i / (m - 1) for i in range(m)]
gruesos = [0.75 - 0.25 * i / (m - 1) for i in range(m)]
anchos[-2], anchos[-1], gruesos[-2], gruesos[-1] = 1.0, 0.45, 0.35, 0.25
barrido(E, "Lengua", camino, anchos, gruesos, 10, (0, 0, 1), LENGUA)

# Mitad de arriba (se abre como una mandíbula, con la bisagra atrás): papel, aro, asa y el ojo
superior = nuevo_grupo(E, "Parte_Superior")
S = superior.get_entities()
cuerpo_papel(S, "Cuerpo_Superior", [(Z0 + t * ALTO, radio(t)) for t in [TM, .48, .54, .60, .66, .72, .78, .84, .90, .95, 1.0]], ZM, -1, PAPEL, LUZ)
revolucion(S, "Aro_Superior", [(37.5, 5.5), (39.0, 5.5)], 24, LACA)
asa = catmull([(-3.0, 0, 38.8), (-2.6, 0, 41.0), (0, 0, 42.6), (2.6, 0, 41.0), (3.0, 0, 38.8)], 4)
barrido(S, "Asa", asa, [0.7] * len(asa), [0.7] * len(asa), 8, (0, 1, 0), LACA)
ZE = Z0 + 0.69 * ALTO
EY = -radio(0.69) + 1.6                      # el ojo sobresale 2" del papel
R_OJO = 3.6
ojo = revolucion(S, "Ojo", perfil_esfera(R_OJO), 16, BLANCO, suave=True)
ojo.set_transform(tras(0, EY, ZE))
iris = revolucion(S, "Ojo_Iris", perfil_esfera(1.9), 16, IRIS, suave=True)
iris.set_transform(tras(0, EY - R_OJO + 0.75, ZE, sy=1.0 / 1.9))
pupila = revolucion(S, "Ojo_Pupila", perfil_esfera(0.95), 12, PUPILA, suave=True)
pupila.set_transform(tras(0, EY - R_OJO - 0.25 + 0.38, ZE, sy=0.5 / 0.95))
a = math.radians(-14)                         # boca abierta 14°: el frente sube unas 4"
c, s = math.cos(a), math.sin(a)
superior.set_transform(SUTransformation([1, 0, 0, 0, 0, c, s, 0, 0, -s, c, 0,
                                         0, RM - (RM * c - ZM * s), ZM - (RM * s + ZM * c), 1]))

def hojas(entidades, ruta=""):
    lista = []
    for g in entidades.get_groups():
        sub = g.get_entities()
        if sub.get_groups():
            lista.extend(hojas(sub, ruta + g.get_name() + "/"))
        else:
            vol = g.compute_volume()
            lista.append([ruta + g.get_name(), len(sub.get_faces()), None if vol is None else round(vol, 1)])
    return lista

result = {"boca": [round(ZM, 2), round(RM, 2)], "piezas": hojas(model.get_entities())}

# --- Después de construir -----------------------------------------------------------------------
# 1. En cada pieza: orient_faces_consistently / face.reverse() si sus caras miran hacia dentro (la
#    lengua y el asa salieron al revés). 2. Estilo «presentación oscura» y cámara de héroe.
# 3. save_model → .skp (el plan gratis permite 30 guardados). 4. Para Godot (el .skp no se abre):
#    se recorren los grupos componiendo sus transformaciones (t.values, 16 valores por columnas),
#    cada cara se parte en triángulos en abanico (son convexas) orientados con su normal, y se
#    devuelven por material en «result». Pesa más de 100 000 caracteres, así que la respuesta llega
#    como archivo; sketchup_a_glb.py lo convierte en GLB.
