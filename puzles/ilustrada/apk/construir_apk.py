#!/usr/bin/env python3
"""Construye el APK de La caja viva: la página del juego (../pagina, la técnica B) dentro de un WebView, sin conexión.

    python3 puzles/ilustrada/apk/construir_apk.py [--version 0.1] [--codigo 1] [--solo-web]

Qué hace:
1. Arma la web del APK en construccion/assets/web/: la página tal cual (los .js, capas/ y sonidos/), su index.html
   completo (como lo envuelve la página privada al publicarla) con Three.js y las fuentes en local, no en internet.
   Three.js r170 y las fuentes (Shippori Mincho y Zen Kaku Gothic New, licencia OFL) se bajan de jsDelivr la primera
   vez a .cache/ y se comprueban con SHA-256.
2. Compila la app (java/, res/, AndroidManifest.xml) con aapt2, javac y d8, la alinea y la firma con apksigner.
3. Deja salida/caja-viva-<versión>-prueba.apk y comprueba la firma y el manifiesto.

Con --solo-web se queda en el paso 1 (para probar esa web con Playwright, ver LEEME.md).

Necesita el SDK de Android (ANDROID_SDK, por defecto /root/android-sdk, con build-tools 35.0.1 y platforms/android-35),
un JDK y la clave de prueba de La caja viva: la carpeta CAJA_VIVA_FIRMA (por defecto
/root/.local/share/caja_viva/firma) con caja-viva-prueba.keystore y su contraseña en clave.txt. La crea
herramientas/crear_firma.py; su copia está en Drive (Respaldos Claude/puzles/firma-prueba/). Nunca en GitHub.
"""
import argparse
import hashlib
import os
import shutil
import subprocess
import sys
import urllib.request
import zipfile

AQUI = os.path.dirname(os.path.abspath(__file__))
PAGINA = os.path.normpath(os.path.join(AQUI, '..', 'pagina'))
CACHE = os.path.join(AQUI, '.cache')
CONSTRUCCION = os.path.join(AQUI, 'construccion')
WEB = os.path.join(CONSTRUCCION, 'assets', 'web')
SALIDA = os.path.join(AQUI, 'salida')

SDK = os.environ.get('ANDROID_SDK', '/root/android-sdk')
HERRAMIENTAS = os.path.join(SDK, 'build-tools', '35.0.1')
ANDROID_JAR = os.path.join(SDK, 'platforms', 'android-35', 'android.jar')
FIRMA = os.environ.get('CAJA_VIVA_FIRMA', '/root/.local/share/caja_viva/firma')
ALMACEN, ALIAS = os.path.join(FIRMA, 'caja-viva-prueba.keystore'), 'cajaviva'
SDK_MINIMO, SDK_OBJETIVO = 24, 34          # Android 7 en adelante; el 34 evita el borde a borde forzado de Android 15

JSDELIVR = 'https://cdn.jsdelivr.net/npm/'
TRES = 'three@0.170.0/'
SHIPPORI, ZEN = '@fontsource/shippori-mincho@5.3.0/', '@fontsource/zen-kaku-gothic-new@5.3.0/'
# (dirección en jsDelivr, sitio dentro de la web, SHA-256)
TERCEROS = [
    (TRES + 'build/three.module.js', 'vendor/three/build/three.module.js', 'ce1fa418de16a19495a9f72495580e3015d7745c296d3ce0485897f902ddedfb'),
    (TRES + 'examples/jsm/loaders/GLTFLoader.js', 'vendor/three/examples/jsm/loaders/GLTFLoader.js', '45139faddd5aaf48ed2d62203d976e5cbd703db1a592de40527f9f6cf58abd44'),
    (TRES + 'examples/jsm/utils/BufferGeometryUtils.js', 'vendor/three/examples/jsm/utils/BufferGeometryUtils.js', 'c25b7930e570e9ec56173cd3b866ec8d2e10016630db3937efb439daf1cedbf6'),
    (TRES + 'LICENSE', 'vendor/three/LICENSE.txt', '4c40a1ef62450b857c3b2aaf294936304cd552d965fbcd9d32d4c5bcf4ba4454'),
    (SHIPPORI + 'LICENSE', 'fuentes/OFL-shippori-mincho.txt', 'e1351ed30eb311d8eaeb3d6f915f1035ab359e767c73510f73cc8d43a7c63822'),
    (ZEN + 'LICENSE', 'fuentes/OFL-zen-kaku-gothic-new.txt', 'f985b5f317c6b25b73f86d0071c584f3159c0de6cf1126e6ef57ab04698b0592'),
]
FUENTES = {
    SHIPPORI + 'files/shippori-mincho-latin-400-normal.woff2': '65624096ca9a30ccc9a32bb915fb5a4dd9052e571b342ece09ef2f20a682862f',
    SHIPPORI + 'files/shippori-mincho-latin-600-normal.woff2': 'f9418b06c09cd545a7676e26779798fa4776d07f2be2eaf97983b240a1981fcb',
    SHIPPORI + 'files/shippori-mincho-latin-800-normal.woff2': '6c971f2ae8e2ff4269f648a20baa5e1801a482d1302923c8e8e9d81183bc7728',
    SHIPPORI + 'files/shippori-mincho-latin-ext-400-normal.woff2': '6c66b797c70240e1d93c3f3da25b3c8b028d5b92b646315b766d6fbbcfb5c96c',
    SHIPPORI + 'files/shippori-mincho-latin-ext-600-normal.woff2': 'e0d7eaf88d8a4fb9c0937c4f980bde426e6ff1f7c558e46417cd42c8bd02d088',
    SHIPPORI + 'files/shippori-mincho-latin-ext-800-normal.woff2': 'b3ed82e3e240b877ae18d0f42b80f763181e40ab8139d9affd3afb70d4ef2cb2',
    # los sellos: 箱 (portada y nota), 角, 目 y 声 (la tarjeta de nivel), en Shippori Mincho 800
    SHIPPORI + 'files/shippori-mincho-99-800-normal.woff2': '6ff47f39b8ceabdf442f5337d7932b4cb900ba735e0cd42c745ed159eba3a19d',
    SHIPPORI + 'files/shippori-mincho-102-800-normal.woff2': '275194defdfe0faae78acc47791f7126829da331d17f67fee765613dfffaf37c',
    SHIPPORI + 'files/shippori-mincho-108-800-normal.woff2': '3bb2e33a56af66df01bada12857b71a8fd00abead1258618fc397a341efd1de1',
    SHIPPORI + 'files/shippori-mincho-117-800-normal.woff2': '3089d3e819284f385efa61d93476b815d04f9e97d04397c27cd555aaa21096e4',
    ZEN + 'files/zen-kaku-gothic-new-latin-400-normal.woff2': '5b1bfc34d603aef66d247bd22b8344f19de165da7ea07d114d87fe7ff4cdc770',
    ZEN + 'files/zen-kaku-gothic-new-latin-500-normal.woff2': 'e4ab8e9dc6984461551cf416f31f8e976cccee7359464ba4b86163c62d233251',
    ZEN + 'files/zen-kaku-gothic-new-latin-ext-400-normal.woff2': '960fdc9411c5b40f1f8270b857278c1c8cddd6e4cd70efb4d0e8f3b27a419f4c',
    ZEN + 'files/zen-kaku-gothic-new-latin-ext-500-normal.woff2': 'e0ebecb0594a41e19415a2a596b35245e0e549a2668d1c9b8f194ce5126dfc69',
}
RANGO_LATIN = ('U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+0304,U+0308,U+0329,U+2000-206F,U+20AC,'
               'U+2122,U+2191,U+2193,U+2212,U+2215,U+FEFF,U+FFFD')
RANGO_LATIN_EXT = ('U+0100-02BA,U+02BD-02C5,U+02C7-02CC,U+02CE-02D7,U+02DD-02FF,U+0304,U+0308,U+0329,U+1D00-1DBF,'
                   'U+1E00-1E9F,U+1EF2-1EFF,U+2020,U+20A0-20AB,U+20AD-20C0,U+2113,U+2C60-2C7F,U+A720-A7FF')
SELLOS = {99: 'U+7BB1', 102: 'U+89D2', 108: 'U+58F0', 117: 'U+76EE'}

# Lo que la página publicada recibe del servidor alrededor del fragmento (prueba/servir.py hace lo mismo), con el zoom
# de la página bloqueado: en el móvil, pellizcar es cosa del juego
CABECERA = ('<!doctype html><html lang="es"><head><meta charset="utf-8">'
            '<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover">'
            '<style>:root{padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}'
            'body{margin:0}img{max-width:100%}[hidden]{display:none!important}</style></head><body>')
SIN_RED = {
    # las fuentes de Google → las del APK
    '<link rel="preconnect" href="https://fonts.googleapis.com">\n': '',
    '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>\n': '',
    ('<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Shippori+Mincho:wght@400;600;800'
     '&family=Zen+Kaku+Gothic+New:wght@400;500&display=swap">'): '<link rel="stylesheet" href="fuentes/fuentes.css">',
    # Three.js de jsDelivr → el del APK
    '"three": "https://cdn.jsdelivr.net/npm/three@0.170.0/build/three.module.js"': '"three": "./vendor/three/build/three.module.js"',
    '"three/addons/": "https://cdn.jsdelivr.net/npm/three@0.170.0/examples/jsm/"': '"three/addons/": "./vendor/three/examples/jsm/"',
}


def paso(texto):
    print(f'\n== {texto}', flush=True)


def ejecutar(orden, **kw):
    entorno = dict(os.environ)
    entorno.pop('JAVA_TOOL_OPTIONS', None)       # el proxy del contenedor; aquí no hace falta red y ensucia la salida
    r = subprocess.run(orden, env=entorno, capture_output=True, text=True, **kw)
    if r.returncode != 0:
        print(r.stdout[-3000:], r.stderr[-3000:], sep='\n')
        sys.exit(f'Falló: {" ".join(orden[:2])}')
    return r.stdout


def bajar(ruta_npm, suma):
    """Un archivo de jsDelivr, guardado en .cache/ y comprobado con SHA-256."""
    destino = os.path.join(CACHE, ruta_npm.replace('/', '_'))
    if not os.path.exists(destino):
        os.makedirs(CACHE, exist_ok=True)
        with urllib.request.urlopen(JSDELIVR + ruta_npm, timeout=120) as r:
            datos = r.read()
        with open(destino + '.parcial', 'wb') as f:
            f.write(datos)
        os.replace(destino + '.parcial', destino)
    with open(destino, 'rb') as f:
        real = hashlib.sha256(f.read()).hexdigest()
    if real != suma:
        os.remove(destino)
        sys.exit(f'La suma de {ruta_npm} no coincide: {real}')
    return destino


def armar_web():
    paso('La web del APK (assets/web)')
    if os.path.exists(CONSTRUCCION):
        shutil.rmtree(CONSTRUCCION)
    os.makedirs(WEB)
    # la página: sus módulos, sus capas y sus sonidos (los modelos de la técnica C, retirada, no van)
    for nombre in sorted(os.listdir(PAGINA)):
        if nombre.endswith('.js'):
            shutil.copy2(os.path.join(PAGINA, nombre), WEB)
    for carpeta in ('capas', 'sonidos'):
        shutil.copytree(os.path.join(PAGINA, carpeta), os.path.join(WEB, carpeta))
    with open(os.path.join(PAGINA, 'index.html'), encoding='utf-8') as f:
        html = f.read()
    for viejo, nuevo in SIN_RED.items():
        if viejo not in html:
            sys.exit(f'index.html ha cambiado: no encuentro {viejo[:60]}…')
        html = html.replace(viejo, nuevo)
    if 'https://' in html.replace('http://www.w3.org', ''):
        print('  aviso: quedan direcciones https:// en index.html')
    with open(os.path.join(WEB, 'index.html'), 'w', encoding='utf-8') as f:
        f.write(CABECERA + html + '</body></html>')
    # Three.js y las licencias
    for ruta_npm, sitio, suma in TERCEROS:
        destino = os.path.join(WEB, sitio)
        os.makedirs(os.path.dirname(destino), exist_ok=True)
        shutil.copy2(bajar(ruta_npm, suma), destino)
    # las fuentes y su hoja de estilos
    caras = []
    for ruta_npm, suma in FUENTES.items():
        nombre = ruta_npm.rsplit('/', 1)[1]
        destino = os.path.join(WEB, 'fuentes', nombre)
        os.makedirs(os.path.dirname(destino), exist_ok=True)
        shutil.copy2(bajar(ruta_npm, suma), destino)
        familia = 'Shippori Mincho' if nombre.startswith('shippori') else 'Zen Kaku Gothic New'
        partes = nombre.replace('-normal.woff2', '').split('-')
        peso, subconjunto = int(partes[-1]), partes[-2]
        if subconjunto.isdigit():
            rango, orden = SELLOS[int(subconjunto)], 0
        else:
            rango, orden = (RANGO_LATIN_EXT, 1) if subconjunto == 'ext' else (RANGO_LATIN, 2)
        caras.append((orden, f"@font-face {{ font-family: '{familia}'; font-style: normal; font-weight: {peso}; font-display: block;\n"
                             f"  src: url('{nombre}') format('woff2'); unicode-range: {rango}; }}"))
    with open(os.path.join(WEB, 'fuentes', 'fuentes.css'), 'w', encoding='utf-8') as f:
        f.write('/* Las fuentes del juego dentro del APK (Fontsource 5.3.0, licencia OFL: OFL-*.txt). El latín va el último:\n'
                '   así gana donde los subconjuntos se pisan. */\n')
        f.write('\n'.join(c for _, c in sorted(caras, key=lambda c: c[0])) + '\n')
    total = sum(os.path.getsize(os.path.join(d, n)) for d, _, ns in os.walk(WEB) for n in ns)
    print(f'  {sum(len(ns) for _, _, ns in os.walk(WEB))} archivos, {total / 1e6:.1f} MB')


def compilar(version, codigo):
    for ruta in (HERRAMIENTAS, ANDROID_JAR, ALMACEN, os.path.join(FIRMA, 'clave.txt')):
        if not os.path.exists(ruta):
            sys.exit(f'Falta {ruta} (ver LEEME.md)')
    aapt2, d8 = os.path.join(HERRAMIENTAS, 'aapt2'), os.path.join(HERRAMIENTAS, 'd8')
    zipalign, apksigner = os.path.join(HERRAMIENTAS, 'zipalign'), os.path.join(HERRAMIENTAS, 'apksigner')

    paso('Recursos y manifiesto (aapt2)')
    recursos = os.path.join(CONSTRUCCION, 'recursos.zip')
    ejecutar([aapt2, 'compile', '--dir', os.path.join(AQUI, 'res'), '-o', recursos])
    base = os.path.join(CONSTRUCCION, 'base.apk')
    ejecutar([aapt2, 'link', '-o', base, '-I', ANDROID_JAR, '--manifest', os.path.join(AQUI, 'AndroidManifest.xml'),
              '--min-sdk-version', str(SDK_MINIMO), '--target-sdk-version', str(SDK_OBJETIVO),
              '--version-code', str(codigo), '--version-name', version,
              '-A', os.path.join(CONSTRUCCION, 'assets'), recursos])

    paso('Código (javac y d8)')
    clases = os.path.join(CONSTRUCCION, 'clases')
    fuentes_java = [os.path.join(d, n) for d, _, ns in os.walk(os.path.join(AQUI, 'java')) for n in ns if n.endswith('.java')]
    ejecutar(['javac', '--release', '11', '-encoding', 'UTF-8', '-Xlint:-options', '-cp', ANDROID_JAR, '-d', clases] + fuentes_java)
    dex = os.path.join(CONSTRUCCION, 'dex')
    os.makedirs(dex)
    archivos_clase = [os.path.join(d, n) for d, _, ns in os.walk(clases) for n in ns if n.endswith('.class')]
    ejecutar([d8, '--release', '--min-api', str(SDK_MINIMO), '--lib', ANDROID_JAR, '--output', dex] + archivos_clase)

    paso('Empaquetar, alinear y firmar')
    sin_alinear = os.path.join(CONSTRUCCION, 'sin_alinear.apk')
    shutil.copy2(base, sin_alinear)
    with zipfile.ZipFile(sin_alinear, 'a', zipfile.ZIP_DEFLATED) as z:
        z.write(os.path.join(dex, 'classes.dex'), 'classes.dex')
    alineado = os.path.join(CONSTRUCCION, 'alineado.apk')
    ejecutar([zipalign, '-p', '-f', '4', sin_alinear, alineado])
    os.makedirs(SALIDA, exist_ok=True)
    final = os.path.join(SALIDA, f'caja-viva-{version}-prueba.apk')
    # PKCS12: la clave privada usa la misma contraseña que el almacén (apksigner la prueba sola si no se da otra)
    ejecutar([apksigner, 'sign', '--ks', ALMACEN, '--ks-key-alias', ALIAS, '--ks-pass', 'file:' + os.path.join(FIRMA, 'clave.txt'),
              '--out', final, alineado])

    paso('Comprobaciones')
    certificado = ejecutar([apksigner, 'verify', '--verbose', '--print-certs', final])
    for linea in certificado.splitlines():
        if linea.startswith(('Verified using', 'Signer #1 certificate DN', 'Signer #1 certificate SHA-256')):
            print(' ', linea)
    insignia = ejecutar([aapt2, 'dump', 'badging', final])
    for linea in insignia.splitlines():
        if linea.startswith(('package:', 'application-label:', 'minSdkVersion', 'sdkVersion', 'targetSdkVersion', 'uses-permission', 'launchable-activity')):
            print(' ', linea)
    with open(final, 'rb') as f:
        suma = hashlib.sha256(f.read()).hexdigest()
    print(f'  {final}\n  {os.path.getsize(final) / 1e6:.1f} MB · SHA-256 {suma}')


def principal():
    p = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    p.add_argument('--version', default='0.1')
    p.add_argument('--codigo', type=int, default=1)
    p.add_argument('--solo-web', action='store_true')
    a = p.parse_args()
    armar_web()
    if not a.solo_web:
        compilar(a.version, a.codigo)


if __name__ == '__main__':
    principal()
