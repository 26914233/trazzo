#!/usr/bin/env python3
"""Sirve la página de la caja viva ilustrada para probarla en local.

La página es un fragmento: al publicarla, el servidor le pone el doctype, el charset y el viewport.
Aquí se hace lo mismo al pedir «/». El resto de archivos se sirve tal cual desde `pagina/`.

    python3 puzles/ilustrada/prueba/servir.py [puerto]     (por defecto, 8765)
"""
import http.server
import os
import sys

PAGINA = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'pagina')
CABECERA = ('<!doctype html><html lang="es"><head><meta charset="utf-8">'
            '<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">'
            '<style>:root{padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}'
            'body{margin:0}img{max-width:100%}[hidden]{display:none!important}</style></head><body>')


class Manejador(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=PAGINA, **kwargs)

    def do_GET(self):
        if self.path == '/favicon.ico':          # el visor de la página pone su propio icono
            self.send_response(204)
            self.end_headers()
            return
        if self.path.split('?')[0] in ('/', '/index.html'):
            with open(os.path.join(PAGINA, 'index.html'), encoding='utf-8') as f:
                cuerpo = (CABECERA + f.read() + '</body></html>').encode('utf-8')
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.send_header('Content-Length', str(len(cuerpo)))
            self.send_header('Cache-Control', 'no-store')
            self.end_headers()
            self.wfile.write(cuerpo)
            return
        super().do_GET()

    def log_message(self, *args):
        pass


if __name__ == '__main__':
    puerto = int(sys.argv[1]) if len(sys.argv) > 1 else 8765
    print(f'http://localhost:{puerto}/')
    http.server.ThreadingHTTPServer(('127.0.0.1', puerto), Manejador).serve_forever()
