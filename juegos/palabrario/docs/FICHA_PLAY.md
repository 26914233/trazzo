# Ficha de Google Play — Palabrario

Textos listos para pegar en *Play Console → Store presence → Main store listing*.
Los límites de caracteres se comprueban con `python3 docs/comprobar_ficha.py`.

## Título (máx. 30)

<!-- titulo -->
Palabrario: Sopa de Letras
<!-- /titulo -->

## Descripción breve (máx. 80)

<!-- breve -->
545 sopas de letras en español. Sin anuncios y con todo el contenido incluido.
<!-- /breve -->

## Descripción completa (máx. 4000)

<!-- completa -->
Palabrario es una colección de 545 sopas de letras en español para jugar con calma. Sin anuncios y sin suscripciones: las 545 sopas vienen incluidas desde el primer día.

Arrastra el dedo sobre las letras y, si forman una palabra de la lista, queda marcada. Encuéntralas todas y pasa a la siguiente. Aquí no se pierde: el reloj solo decide tus estrellas.

★ 44 TEMAS, 545 SOPAS
Comida, cocina del mundo, química, física, biología, espacio, electricidad, juegos, países, Colombia, animales, naturaleza, cuerpo humano, salud, deportes, música, arte, cine, tecnología, historia, mitología, profesiones, geografía, literatura y muchos más. Cada tema se divide en sopas concretas: frutas tropicales, capitales de Asia, componentes eléctricos, dioses griegos…

★ PARA TODOS LOS NIVELES
• Cuatro dificultades, de 8×8 a 14×14.
• Palabras en horizontal, vertical, diagonal y al revés según la dificultad.
• La selección se ajusta sola en línea recta: no hace falta precisión.
• 3 pistas gratis cada día. Si quieres más, hay paquetes opcionales.

★ HECHO CON CUIDADO
• Palabras bien escritas, con tildes en la lista y con la Ñ en el tablero.
• Una sopa del día nueva cada día y tu racha de días seguidos.
• Tres diseños: Cielo, Papel y Noche (modo oscuro).
• Letras más grandes si las necesitas.
• Funciona sin conexión y no recoge ningún dato tuyo.

Ejercita la mente, aprende palabras nuevas y desconecta un rato. Sin interrupciones.
<!-- /completa -->

## Precio y categoría
- **Precio:** 4,99 US$ (app de pago). Revisar los precios locales que propone Play.
- Aplicación: **Juego** · Categoría: **Palabras**
- Etiquetas sugeridas: Sopa de letras, Palabras, Casual, Un jugador, Sin conexión

## Clasificación de contenido (cuestionario IARC)
Sin violencia, sin contenido sexual, sin lenguaje ofensivo, sin apuestas, sin
interacción entre usuarios, **con compras digitales** (paquetes de pistas opcionales), sin anuncios. Resultado esperado:
PEGI 3 / Para todos.

## Público objetivo (App content → Target audience)
Recomendado: **13 años o más**. Al no tener anuncios ni recoger datos, apuntar también a
menores es mucho más sencillo que antes, pero sigue activando la política de Familias de
Google Play. Si el dueño lo quiere, revisarla antes de marcarlo.

## Recursos gráficos
| Recurso | Formato | Estado |
|---|---|---|
| Icono | 512×512 PNG | `docs/tienda/icono-512.png` |
| Gráfico destacado | 1024×500 PNG | `docs/tienda/destacado-*.png` (3 opciones; recomendada: `destacado-movil.png`) |
| Capturas de teléfono | 2–8, 1080×1920 | `docs/tienda/captura-1..6-*.png` (con titulares, listas para subir). Las capturas sin marco están en `docs/capturas/` |

Las capturas con titular se suben en su orden numérico. Fuentes HTML en `docs/tienda/html/`; se regeneran con `node docs/tienda/exportar.js`.
