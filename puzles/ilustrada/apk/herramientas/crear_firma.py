#!/usr/bin/env python3
"""Crea la clave de firma de prueba de La caja viva, solo si no existe.

Es un almacén PKCS12 (caja-viva-prueba.keystore, alias «cajaviva», RSA de 2048 bits, 30 años) con una contraseña al
azar guardada en clave.txt. Los dos van a una carpeta fuera del repositorio (CAJA_VIVA_FIRMA, por defecto
/root/.local/share/caja_viva/firma) con permisos solo para el dueño. La contraseña no se imprime nunca.

Con permiso del usuario (03-10-2026), su copia está en Drive › Respaldos Claude/puzles/firma-prueba/. Nunca en GitHub,
que es público. En un contenedor nuevo, se baja de allí a esa carpeta en lugar de crear otra: con una clave distinta,
el APK nuevo no se instala encima del anterior.

Uso:  python3 puzles/ilustrada/apk/herramientas/crear_firma.py
"""
import os
import secrets
import subprocess
import sys

FIRMA = os.environ.get('CAJA_VIVA_FIRMA', '/root/.local/share/caja_viva/firma')
ALMACEN = os.path.join(FIRMA, 'caja-viva-prueba.keystore')
CLAVE = os.path.join(FIRMA, 'clave.txt')


def principal():
    if os.path.exists(ALMACEN):
        print(f'Ya existe {ALMACEN}: no se toca.')
        return
    os.makedirs(FIRMA, mode=0o700, exist_ok=True)
    descriptor = os.open(CLAVE, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(descriptor, 'w') as f:
        f.write(secrets.token_urlsafe(24) + '\n')
    entorno = dict(os.environ)
    entorno.pop('JAVA_TOOL_OPTIONS', None)
    r = subprocess.run(['keytool', '-genkeypair', '-keystore', ALMACEN, '-storetype', 'PKCS12', '-alias', 'cajaviva',
                        '-keyalg', 'RSA', '-keysize', '2048', '-validity', '10950',
                        '-dname', 'CN=La caja viva prueba, O=thunderDarkness',
                        '-storepass:file', CLAVE, '-keypass:file', CLAVE],
                       env=entorno, capture_output=True, text=True)
    if r.returncode != 0:
        os.remove(CLAVE)
        sys.exit('keytool falló:\n' + r.stderr[-2000:])
    os.chmod(ALMACEN, 0o600)
    print(f'Clave creada en {FIRMA} (almacén y contraseña; la contraseña no se muestra).')


if __name__ == '__main__':
    principal()
