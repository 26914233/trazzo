# GDD — juego de colorear y mandalas (nombre por decidir; de trabajo «Pintazz»)

## Concepto
App tranquila para colorear en el móvil, sin prisa ni derrota. Tres modos:

1. **Colorear láminas:** tocas una zona y se rellena con el color elegido. Láminas de
   mandalas, vitrales, flores y geometría.
2. **Mandala libre:** dibujas con el dedo y el trazo se repite en N sectores (6–16),
   con espejo opcional. Siempre sale algo bonito.
3. **Lienzo libre:** pinceles, goma, colores y deshacer.

Las obras se guardan solas y se ven en «Mis obras».

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
