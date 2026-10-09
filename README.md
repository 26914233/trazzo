# thunderDarkness — web del estudio

Web estática del estudio de videojuegos thunderDarkness (se publica con GitHub Pages desde `main`).

| Página | Qué es |
|---|---|
| `index.html` | Portada del estudio: tablero de proyectos (de la idea al lanzamiento), bitácora y testers |
| `curtzz.html` | Página del juego Curtzz (antes era la portada) |
| `tienda.html` | Tienda de Prismas con bono (Mercado Pago). Misma dirección de siempre: el servidor vuelve aquí tras pagar |
| `privacidad.html` | Política de privacidad (la que se pega en Play Console). Misma dirección de siempre |
| `assets/` | Estilos comunes (`estudio.css`, con las tipografías incluidas: no se carga nada de Google), imágenes y el logo del estudio |

## Cómo se edita

- **Estado de un proyecto:** en `index.html`, mueve su tarjeta a otra columna del tablero (`<li class="col">`) y cambia el texto de la terminal de la cabecera.
- **Proyecto nuevo:** copia una tarjeta (`.card`) a la columna que toque. Para una idea, usa `.card.id`.
- **Bitácora:** añade un `<li class="ev">` arriba de la lista (`ev r` si es de RONIN).
- **Correo de contacto:** `prueba1bysisne@gmail.com`, el mismo que ya usa la política de privacidad.
- **Ilustración de RONIN:** `assets/ronin-art.svg` es provisional. Cámbiala por el arte real cuando exista.

No hay analítica ni cookies. Las tipografías van incluidas en `assets/fonts/`.
