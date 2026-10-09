# Ficha de Google Play — Sopazz

Textos listos para pegar en *Play Console → Store presence → Main store listing*.
Los límites de caracteres se comprueban con `python3 docs/comprobar_ficha.py`.

## Título (máx. 30)

<!-- titulo -->
Sopazz: Sopa de Letras
<!-- /titulo -->

## Descripción breve (máx. 80)

<!-- breve -->
Sopa de letras en español: arrastra el dedo, encuentra palabras y relájate.
<!-- /breve -->

## Descripción completa (máx. 4000)

<!-- completa -->
Sopazz es la sopa de letras para jugar en ratos libres: tranquila, en español y con un dedo.

Arrastra sobre las letras y, si forman una palabra de la lista, queda marcada. Encuéntralas todas y pasa al siguiente nivel. Sin prisas obligatorias y sin perder: el reloj solo decide tus estrellas.

★ CÓMO SE JUEGA
• Desliza el dedo de la primera a la última letra. La selección se ajusta sola en línea recta.
• Las palabras pueden ir en horizontal, vertical, diagonal y al revés, según la dificultad.
• ¿Atascado? Una pista te marca dónde empieza una palabra.

★ LO QUE TRAE
• 12 temas: Animales, Comida, Colombia, Cuerpo humano, Deportes, Naturaleza y más.
• 4 dificultades, de 8×8 a 14×14.
• Niveles sin fin: cada sopa se genera para ti y nunca se acaba.
• Nivel del día con premio doble y racha diaria.
• Palabras con tildes y Ñ bien escritas en la lista.
• Letras más grandes si las necesitas, y todo funciona sin sonido.
• Se juega sin conexión.

★ HONESTO CON TU TIEMPO
• Los anuncios con premio son siempre opcionales: tú decides si ves uno a cambio de una pista.
• Nunca verás un anuncio en mitad de una sopa, ni en tus primeros niveles.
• Puedes quitar los anuncios entre niveles con una sola compra.

Ejercita la mente, aprende palabras nuevas y desconecta un rato. ¡A buscar!
<!-- /completa -->

## Categoría y etiquetas
- Aplicación: **Juego** · Categoría: **Palabras**
- Etiquetas sugeridas: Sopa de letras, Palabras, Casual, Un jugador, Sin conexión

## Clasificación de contenido (cuestionario IARC)
Sin violencia, sin contenido sexual, sin lenguaje ofensivo, sin apuestas. Interacción
entre usuarios: no. Compras digitales: **sí**. Resultado esperado: PEGI 3 / Para todos.

## Público objetivo (App content → Target audience)
**13 años o más.** Marcar menores de 13 obliga a cumplir la política de Familias (SDK de
anuncios certificados para familias, etiquetado para niños y otras restricciones). Si
el dueño quiere apuntar también a niños, hay que cambiar la configuración de AdMob y
revisar esa política antes; no es un cambio de una casilla.

## Recursos gráficos
| Recurso | Formato | Estado |
|---|---|---|
| Icono | 512×512 PNG | Partir de `arte/icono.svg` (exportar a 512 px) |
| Gráfico destacado | 1024×500 PNG/JPG | **Pendiente** (usar la skill `banner-design`) |
| Capturas de teléfono | 2–8, 1080×1920 | `docs/capturas/` (generadas con `tests/capturas.tscn`) |

Orden sugerido de capturas: partida a medias → victoria → selector de temas → menú → tienda.
