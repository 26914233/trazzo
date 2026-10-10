# GDD — Lienzo Zen (colorear para relajarse)

## Concepto
App tranquila para colorear en el móvil, sin prisa ni derrota. Tres modos:

1. **Colorear láminas:** tocas una zona y se rellena con el color elegido. Láminas de
   mandalas, vitrales, flores y geometría.
2. **Mandala libre:** dibujas con el dedo y el trazo se repite en N sectores (6–16),
   con espejo opcional. Siempre sale algo bonito.
3. **Lienzo libre:** pinceles, goma, colores y deshacer.

Las obras se guardan solas y se ven en «Mis obras».

**Dos formas de pintar** (botón en la pantalla de la lámina, se recuerda):
- **Pincel:** el dedo pinta cada zona por la que pasa; tocar pinta una.
- **Tocar:** solo se rellena la zona tocada; arrastrar mueve el dibujo.
En las dos, dos dedos hacen zoom. Un trazo se deshace de una vez.

**Ayudas y recompensas** (copiadas como función, no como código ni arte, de las apps
revisadas en `juegos/ANALISIS_COMPETENCIA.md`; matriz en `juegos/replica/features.csv`):
- **Buscar zona sin pintar** (◎): la cámara va a la zona en blanco más cercana al centro
  de lo que se ve, con zoom, y la zona late con rayas magenta unos segundos. Pulsar
  otra vez lleva a otra. Gratis e ilimitado. Datos por zona precalculados
  (`herramientas/zonas.py` → `<id>_zonas.bin`: punto interior y caja).
- **Lámina terminada:** la lámina vuelve a verse entera, las líneas se apagan un
  momento para ver solo el color, confeti con la paleta y opciones (guardar imagen,
  seguir, otra lámina).
- **Guardar imagen** (⤓): PNG 1280x1280 en Imágenes/Lienzo Zen; si el sistema no deja,
  en la carpeta de la app. Pendiente de validar en un teléfono que salga en la galería.
- **Lámina del día** en el menú, la misma para todos, sin repetir hasta recorrer todas.
  **Racha suave:** pintar la del día suma; faltar un solo día no la rompe.
- **Mis colores:** la última paleta es la del jugador. El «+» abre una rueda de color
  con barra de luz y muestra; el color elegido se guarda (hasta 12, sale el más antiguo).
- **Ajustes** (⚙ en el menú): sonido, música ambiental, vibración y ocultar láminas
  terminadas. Las terminadas llevan una marca ✓ en las miniaturas.
- **Música ambiental:** bucle de 64 s sintetizado con `herramientas/musica.py` (licencia
  propia). Apagada por defecto; entra y sale con fundido.

## Público y tono
Adultos que colorean para relajarse (búsquedas «colorear para adultos», «mandalas»), y
familias. Sin anuncios, sin compras, sin datos: encaja con la política de Familias si
algún día se apunta a menores (revisarla antes).

## Negocio
App de pago de 4,99 US$, todo incluido (decisión del dueño, igual que Palabrario).
Antipiratería: protección automática de Play + comprobación del instalador (de Palabrario).

## Reglas de diseño
- Un toque = un relleno. Nunca se pinta fuera de la zona.
- Zonas pequeñas: zoom con dos dedos; el toque cae en la zona más cercana.
- Deshacer ilimitado dentro de la sesión.
- Nada que penalice: no hay tiempo, puntos ni derrota.
- Paletas curadas (6–8) + selector libre.

## Contenido
Láminas generadas por código (`herramientas/laminas.py`), con licencia propia:
mandalas, vitrales (Voronoi), flores y geometría. Cada lámina = imagen de líneas +
mapa de zonas precalculado, así colorear es instantáneo en móviles baratos.
Más adelante: ilustraciones (animales, paisajes) hechas a mano o encargadas.

## Técnica
- Godot 4.7, GL Compatibility, vertical 1080x1920 (molde de Palabrario).
- Coloreado: shader que lee el id de zona de `regiones.png` y su color de una paleta
  (textura 64x64); las líneas van encima. Cambiar un color = 1 píxel de la paleta.
- Dibujo libre: trazos como listas de puntos (deshacer barato), pintados en un SubViewport.
