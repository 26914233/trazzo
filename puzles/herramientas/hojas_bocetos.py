# Hojas de bocetos para revisarlos en el móvil: las imágenes de puzles/bocetos/ en columna, con su
# título y sus notas, y las viñetas numeradas.
#   python3 puzles/herramientas/hojas_bocetos.py <carpeta de salida>
from PIL import Image, ImageDraw, ImageFont
import os, sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASE = os.path.join(RAIZ, "bocetos") + "/"
FUENTES = os.path.join(RAIZ, "godot", "recursos", "fuentes") + "/"
SALIDA = (sys.argv[1] if len(sys.argv) > 1 else os.path.join(BASE, "hojas")).rstrip("/") + "/"
ANCHO = 1200
MARGEN = 28
FONDO = (24, 21, 19)
PAPEL = (238, 228, 210)
ACENTO = (214, 84, 52)
GRIS = (190, 178, 160)

def fuente(tipo, tam):
    return ImageFont.truetype(FUENTES + "LiberationSerif-%s.ttf" % tipo, tam)

TITULO = fuente("Bold", 54)
SUBTITULO = fuente("Bold", 38)
TEXTO = fuente("Regular", 30)
NUMERO = fuente("Bold", 40)

def lineas(texto, letra, ancho):
    # Parte el texto en líneas que caben en «ancho» píxeles.
    resultado = []
    for parrafo in texto.split("\n"):
        palabras = parrafo.split()
        actual = ""
        for palabra in palabras:
            prueba = (actual + " " + palabra).strip()
            if letra.getlength(prueba) <= ancho:
                actual = prueba
            else:
                resultado.append(actual)
                actual = palabra
        resultado.append(actual)
    return resultado

def bloque_texto(texto, letra, color, alto_linea):
    filas = lineas(texto, letra, ANCHO - 2 * MARGEN)
    img = Image.new("RGB", (ANCHO, alto_linea * len(filas) + 8), FONDO)
    d = ImageDraw.Draw(img)
    for i, fila in enumerate(filas):
        d.text((MARGEN, i * alto_linea), fila, font=letra, fill=color)
    return img

def imagen(nombre, numeros=False):
    img = Image.open(BASE + nombre).convert("RGB")
    alto = round(img.height * (ANCHO - 2 * MARGEN) / img.width)
    img = img.resize((ANCHO - 2 * MARGEN, alto), Image.LANCZOS)
    if numeros:
        # Números 1-4 en las esquinas de las cuatro viñetas (rejilla de 2 x 2).
        d = ImageDraw.Draw(img)
        for i, (x, y) in enumerate([(0, 0), (1, 0), (0, 1), (1, 1)]):
            cx = 14 + x * img.width // 2
            cy = 12 + y * img.height // 2
            d.ellipse((cx, cy, cx + 52, cy + 52), fill=ACENTO, outline=(255, 240, 220), width=3)
            d.text((cx + 26, cy + 27), str(i + 1), font=NUMERO, fill=(255, 245, 235), anchor="mm")
    lienzo = Image.new("RGB", (ANCHO, img.height + 12), FONDO)
    lienzo.paste(img, (MARGEN, 0))
    return lienzo

def hoja(nombre_salida, piezas):
    partes = []
    for tipo, valor in piezas:
        if tipo == "titulo":
            partes.append(Image.new("RGB", (ANCHO, 26), FONDO))
            partes.append(bloque_texto(valor, TITULO, PAPEL, 64))
        elif tipo == "sub":
            partes.append(Image.new("RGB", (ANCHO, 14), FONDO))
            partes.append(bloque_texto(valor, SUBTITULO, ACENTO, 46))
        elif tipo == "texto":
            partes.append(bloque_texto(valor, TEXTO, GRIS, 38))
        elif tipo == "img":
            partes.append(imagen(valor))
        elif tipo == "viñetas":
            partes.append(imagen(valor, numeros=True))
        elif tipo == "espacio":
            partes.append(Image.new("RGB", (ANCHO, valor), FONDO))
    alto = sum(p.height for p in partes) + 30
    final = Image.new("RGB", (ANCHO, alto), FONDO)
    y = 0
    for p in partes:
        final.paste(p, (0, y))
        y += p.height
    os.makedirs(SALIDA, exist_ok=True)
    final.save(SALIDA + nombre_salida, quality=86, optimize=True, progressive=True)
    print(nombre_salida, final.size, os.path.getsize(SALIDA + nombre_salida) // 1024, "KB")

hoja("1_caja_viva_tres_caminos.jpg", [
    ("titulo", "La caja viva: tres caminos"),
    ("texto", "La misma idea (la cara del tsukumogami, incompleta, que te vigila) con tres diseños. Elige uno o mézclalos."),
    ("sub", "A · Mosaico yosegi y máscara de paulownia"),
    ("texto", "La artesanía real de las cajas secretas de Hakone. Cara serena e inquietante. La sala, cálida."),
    ("img", "caja_viva_a.jpg"),
    ("sub", "B · Laca negra, oro y un oni"),
    ("texto", "La más amenazante y la que más llama en una miniatura. Los cajones rojos del costado son los satélites."),
    ("img", "caja_viva_b.jpg"),
    ("sub", "C · Cómoda tansu de cajones"),
    ("texto", "Muchísimo que explorar, pero se pierde la cara: cuesta ver que está viva."),
    ("img", "caja_viva_c.jpg"),
    ("sub", "Las piezas que se llevan de un sitio a otro"),
    ("texto", "Ojo dormido, boca con colmillos, cuerno, llave de bambú, ficha de shōgi, incensario, cuatro placas y la tapa del león."),
    ("img", "caja_viva_piezas.jpg"),
])

hoja("2_caja_viva_como_se_abre.jpg", [
    ("titulo", "La caja viva (A): cómo se abre"),
    ("viñetas", "caja_viva_a_secuencia.jpg"),
    ("texto", "1. Llegas: la cara está incompleta y su único ojo te sigue.\n"
              "2. La caja se expande: el costado se desliza, la tapa se levanta y sale el cajón del zócalo. "
              "(La llave saldrá de bambú, no como la del dibujo.)\n"
              "3. Ir y volver: el incensario de la mesa esconde el cuerno; el ojo y la boca salen de otros rincones. "
              "El rollo de la pared da la pista.\n"
              "4. Con la cara completa, despierta: la mandíbula cae, la cabeza se levanta y dentro hay un altar rojo con el sello."),
])

hoja("3_relojero.jpg", [
    ("titulo", "La caja del relojero: el reloj sin corazón"),
    ("img", "relojero.jpg"),
    ("texto", "Caja de caoba en el taller de 1891, con su chimenea y sus relojes. En la secuencia, a la esfera le faltan las agujas y a la ventanita, el volante: su corazón."),
    ("viñetas", "relojero_secuencia.jpg"),
    ("texto", "1. La esfera sin agujas y el hueco del volante.\n"
              "2. Se expande: la tapa se parte en dos, el medallón del costado gira y guarda la llave de cuerda, "
              "el cajón trae un billete de tren.\n"
              "3. Ir y volver: el reloj de bolsillo esconde el volante, el reloj de la chimenea guarda las agujas, la carta da la hora.\n"
              "4. Con su corazón, el reloj late: el frente se abre en tres puertas y sale un pájaro autómata que canta."),
])

hoja("4_reliquia.jpg", [
    ("titulo", "La reliquia: el corazón de cuatro pétalos"),
    ("img", "reliquia.jpg"),
    ("texto", "Ojo con este primer dibujo: los huecos (triángulo, cuadrado, círculo y rombo) recuerdan a los botones de PlayStation. "
              "En la secuencia ya son una luna, un ojo, una ola y una semilla."),
    ("viñetas", "reliquia_secuencia.jpg"),
    ("texto", "1. La flor de piedra flota cerrada sobre el pedestal.\n"
              "2. Los anillos llevan un rayo de luz por sus surcos y se abre el primer pétalo.\n"
              "3. Ir y volver: cuatro nichos en la pared (un disco que gira, losas que se deslizan, una pila de agua, un brasero) "
              "guardan los cuatro cristales.\n"
              "4. Con los cuatro cristales, el núcleo despierta en ámbar y enciende la banda de runas."),
])

hoja("5_farero.jpg", [
    ("titulo", "El cuarto del farero: la lámpara de señales"),
    ("img", "farero.jpg"),
    ("texto", "Aquí la caja es la habitación. Tormenta de 1903 y un barco junto a las rocas."),
    ("viñetas", "farero_secuencia.jpg"),
    ("texto", "1. La lámpara de señales está desmontada sobre la mesa, sin lentes.\n"
              "2. El baúl del candado guarda las herramientas y la mecha; tras los libros, el reflector.\n"
              "3. El barómetro esconde un engranaje, la trampilla da a la tormenta y el diario tiene las señales de puntos y rayas.\n"
              "4. La lámpara montada responde al barco y lo aparta de las rocas."),
])
