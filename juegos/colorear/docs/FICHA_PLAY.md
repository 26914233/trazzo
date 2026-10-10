# Ficha de Google Play — Lienzo Zen

Textos listos para pegar en *Play Console → Store presence → Main store listing*.
Los límites de caracteres se comprueban con `python3 docs/comprobar_ficha.py`.
Sin nombres de otras apps (regla de Play y del método replica).

## Título (máx. 30)

<!-- titulo -->
Lienzo Zen: Colorear y Relajar
<!-- /titulo -->

## Descripción breve (máx. 80)

<!-- breve -->
749 láminas para colorear con calma. Sin anuncios y con todo incluido.
<!-- /breve -->

## Descripción completa (máx. 4000)

<!-- completa -->
Lienzo Zen es una app para colorear con calma: 749 láminas incluidas desde el primer día, sin anuncios, sin suscripciones y sin láminas bloqueadas.

Elige un color y toca una zona para rellenarla, o arrastra el dedo como si fuera un pincel y se pintan todas las zonas por las que pasas. Acércate con dos dedos para los detalles más pequeños y deshaz cuando quieras.

★ 749 LÁMINAS, MUCHOS ESTILOS
Animales con estilo de tatuaje, aves, criaturas de fantasía, océano, insectos, flores, mandalas, objetos, vehículos, lugares, vitrales, geometría y fachadas. Cada lámina es distinta: hay para un rato corto y para tardes enteras.

★ PENSADA PARA RELAJARSE
• Dos formas de pintar: tocando cada zona o con el dedo como pincel.
• Botón para encontrar la siguiente zona sin pintar: nada de buscar puntos diminutos.
• 8 paletas curadas y «Mis colores», con una rueda para elegir cualquier color.
• Música ambiental opcional, que se apaga de verdad.
• No hay tiempo, puntos ni derrota.

★ CADA DÍA ALGO NUEVO
• Una lámina del día, la misma para todos, y una racha suave: faltar un día no la rompe.
• Un misterio cada semana: el dibujo se descubre mientras lo coloreas.

★ TUS OBRAS
• Se guardan solas en «Mis obras»: retoma cualquier lámina cuando quieras.
• Al terminar, una pequeña celebración y la opción de guardar tu obra como imagen.
• Oculta las láminas que ya terminaste para ver solo las nuevas.

★ SIN SORPRESAS
• Un único pago: todo el contenido incluido, sin anuncios ni compras dentro.
• Funciona sin conexión y no recoge ningún dato tuyo.

Desconecta un rato, elige tus colores y deja que la lámina cobre vida.
<!-- /completa -->

## Precio y categoría
- **Precio:** 4,99 US$ (app de pago). Revisar los precios locales que propone Play.
- Aplicación: **Aplicación** · Categoría: **Arte y diseño** (alternativa: Juego → Casual; decidir
  según dónde compiten las apps de colorear que se quieren alcanzar).
- Etiquetas sugeridas: Colorear, Mandalas, Relajación, Arte, Sin conexión

## Clasificación de contenido (cuestionario IARC)
Sin violencia, sin contenido sexual, sin lenguaje ofensivo, sin apuestas, sin interacción
entre usuarios, sin compras digitales, sin anuncios. Resultado esperado: PEGI 3 / Para todos.

## Público objetivo (App content → Target audience)
Recomendado: **13 años o más**. Colorear atrae a niños: sin anuncios ni datos es más sencillo
cumplir la política de Familias, pero marcar menores la activa; revisarla antes si el dueño lo quiere.

## Seguridad de los datos
No recoge ni comparte datos. El APK solo pide el permiso VIBRATE (sin INTERNET).

## Antes de publicar (pendiente)
- Comprobar en un teléfono que «Guardar imagen» deja la obra visible en la galería: la
  descripción lo promete. Si no aparece, cambiar ese texto o añadir el plugin de MediaStore.
- Si entran las láminas de criaturas de Colab, actualizar «749» en la ficha, en las capturas
  (`docs/tienda/html/`) y en el gráfico destacado.

## Recursos gráficos
| Recurso | Formato | Estado |
|---|---|---|
| Icono | 512×512 PNG | `docs/tienda/icono-512.png` (copia de `arte/icono.png`) |
| Gráfico destacado | 1024×500 PNG | `docs/tienda/destacado-obras.png` |
| Capturas de teléfono | 6, 1080×1920 PNG | `docs/tienda/captura-1..6-*.png` (con titular, en orden). Sin marco: `docs/capturas/` |

Las capturas sin marco salen de `tests/tienda.tscn` (xvfb-run); las composiciones de
`docs/tienda/html/` se exportan con `node docs/tienda/exportar.js` (Playwright).
