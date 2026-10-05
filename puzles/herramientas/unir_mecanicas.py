#!/usr/bin/env python3
"""Une las tablas de mecánicas de la investigación del género (puzles/genero/*_mecanicas.csv) en un catálogo.

Cada tabla tiene las columnas del encargo, separadas por punto y coma:
    ID;Juego;Mecánica;Tipo;Dificultad;Habilidad requerida;Feedback;Cómo podría adaptarse

El guion comprueba cada fila (columnas, ID repetido, dificultad de 1 a 5, tipo conocido, adaptación con su letra
A-H), escribe `genero/catalogo_mecanicas.csv` con todas las filas válidas y cuenta cuántas hay por tipo, por juego
y por letra de adaptación. Las filas con problemas se listan, pero no se pierden: van al catálogo con una nota.

Uso:  python3 puzles/herramientas/unir_mecanicas.py
"""
import csv
import glob
import os
import re
from collections import Counter

AQUI = os.path.dirname(os.path.abspath(__file__))
GENERO = os.path.join(AQUI, '..', 'genero')
COLUMNAS = ['ID', 'Juego', 'Mecánica', 'Tipo', 'Dificultad', 'Habilidad requerida', 'Feedback', 'Cómo podría adaptarse']
TIPOS = {
    'ROTACIÓN', 'DESLIZAMIENTO', 'COMBINACIÓN', 'SECUENCIA', 'SIMETRÍA', 'PATRONES', 'ENGRANAJES', 'PALANCAS',
    'RUEDAS', 'DIALES', 'LLAVES', 'CERRADURAS', 'SÍMBOLOS', 'LUCES', 'SONIDOS', 'PESO', 'FÍSICA', 'PERSPECTIVA',
    'ESCALA', 'REFLEJOS', 'SOMBRAS', 'TIEMPO', 'MEMORIA', 'OBSERVACIÓN', 'ORDEN', 'CONEXIONES', 'TRANSFORMACIÓN',
    'CONSTRUCCIÓN', 'DESMONTAJE', 'RECONSTRUCCIÓN', 'COMBINACIÓN DE OBJETOS', 'INFORMACIÓN CRUZADA', 'MULTIZONA',
    'MULTIOBJETO',
}
LETRAS = {
    'A': 'el principio tal cual', 'B': 'modificado', 'C': 'combinado con otra', 'D': 'invertido',
    'E': 'con una variable nueva', 'F': 'en otro contexto', 'G': 'unido a la narrativa', 'H': 'una mecánica nueva',
}


def leer(ruta):
    with open(ruta, encoding='utf-8-sig', newline='') as f:
        lineas = [l for l in f.read().splitlines() if l.strip()]
    filas = list(csv.reader(lineas, delimiter=';'))
    if filas and [c.strip() for c in filas[0]][:2] == COLUMNAS[:2]:
        filas = filas[1:]
    return filas


def tipos_de(texto):
    partes = re.split(r'\s*[,/+]\s*|\s+y\s+', texto.strip().upper())
    return [p for p in (x.strip() for x in partes) if p]


def principal():
    rutas = sorted(glob.glob(os.path.join(GENERO, '*_mecanicas.csv')))
    if not rutas:
        print('No hay tablas *_mecanicas.csv en', os.path.normpath(GENERO))
        return
    salida, problemas, vistos = [], [], set()
    por_tipo, por_juego, por_letra, por_dificultad = Counter(), Counter(), Counter(), Counter()
    for ruta in rutas:
        nombre = os.path.basename(ruta)
        filas = leer(ruta)
        print(f'{nombre}: {len(filas)} filas')
        for n, fila in enumerate(filas, 2):
            fila = [c.strip() for c in fila]
            notas = []
            if len(fila) != len(COLUMNAS):
                notas.append(f'{len(fila)} columnas')
                fila = (fila + [''] * len(COLUMNAS))[:len(COLUMNAS)] if len(fila) < len(COLUMNAS) else \
                    fila[:len(COLUMNAS) - 1] + [', '.join(fila[len(COLUMNAS) - 1:])]
            ident, juego, _, tipo, dificultad, _, _, adaptacion = fila
            if ident in vistos:
                notas.append('ID repetido')
            vistos.add(ident)
            if dificultad not in {'1', '2', '3', '4', '5'}:
                notas.append(f'dificultad «{dificultad}»')
            else:
                por_dificultad[dificultad] += 1
            desconocidos = [t for t in tipos_de(tipo) if t not in TIPOS]
            for t in tipos_de(tipo):
                por_tipo[t] += 1
            if desconocidos:
                notas.append('tipo nuevo: ' + ', '.join(desconocidos))
            letra = adaptacion[:1].upper()
            if letra in LETRAS:
                por_letra[letra] += 1
            else:
                notas.append('adaptación sin letra A-H')
            por_juego[juego] += 1
            if notas:
                problemas.append(f'  {nombre}:{n} {ident}: ' + '; '.join(notas))
            salida.append(fila + [nombre, '; '.join(notas)])
    destino = os.path.join(GENERO, 'catalogo_mecanicas.csv')
    with open(destino, 'w', encoding='utf-8', newline='') as f:
        w = csv.writer(f, delimiter=';')
        w.writerow(COLUMNAS + ['Tabla', 'Nota'])
        w.writerows(salida)
    print(f'\n{len(salida)} mecánicas de {len(por_juego)} juegos → {os.path.normpath(destino)}')
    print('\nPor tipo:', ', '.join(f'{t} {n}' for t, n in por_tipo.most_common()))
    print('\nPor adaptación:', ', '.join(f'{l} ({LETRAS[l]}) {n}' for l, n in sorted(por_letra.items())))
    print('\nPor dificultad:', ', '.join(f'{d}: {n}' for d, n in sorted(por_dificultad.items())))
    print('\nPor juego:', ', '.join(f'{j} {n}' for j, n in por_juego.most_common()))
    if problemas:
        print(f'\n{len(problemas)} filas con algo que revisar (van al catálogo con su nota):')
        print('\n'.join(problemas[:60]))


if __name__ == '__main__':
    principal()
