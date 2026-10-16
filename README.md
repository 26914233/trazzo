# thunderDarkness — web del estudio

> **Desde el 16-10-2026 este repositorio solo contiene la web** (público, para GitHub Pages). El código de los juegos
> está en repositorios privados; el historial antiguo completo está en el repositorio privado `trazzo-archivo`.
> No subas aquí nada que no sea la web.

Web estática del estudio de videojuegos thunderDarkness (se publica con GitHub Pages desde `main`, en `https://26914233.github.io/trazzo/`).

| Archivo | Qué es |
|---|---|
| `index.html` | Portada del estudio: tablero de proyectos (de la idea al lanzamiento), bitácora y testers |
| `curtzz.html` | Página del juego Curtzz. Neutral: sin tienda, precios ni bonos (ver «Web neutral para Google Play») |
| `privacidad.html` | Política de privacidad (la que se pega en Play Console). Misma dirección de siempre |
| `tienda.html` | Tienda web de Prismas (Mercado Pago). **No está enlazada desde ninguna página** y lleva `noindex,nofollow`. Misma dirección de siempre: el servidor vuelve aquí tras pagar |
| `404.html` | Página de error (GitHub Pages la sirve en cualquier ruta que no exista). `noindex` |
| `robots.txt`, `sitemap.xml` | SEO. El mapa del sitio lista index, curtzz y privacidad (no tienda) |
| `assets/estudio.css` | Estilos comunes, con las tipografías incluidas (no se carga nada de Google) |
| `assets/comun.js` | Año del pie (`index.html`, `curtzz.html` y `tienda.html`) |
| `assets/curtzz.js` | Animación del tablero de fondo de `curtzz.html` y botón «Pausar animación» |
| `assets/tienda.js` | Lógica de la tienda: `SERVIDOR`, paquetes, pago y seguimiento del pedido |
| `assets/img/` | `og.png` (1200×630, tarjeta al compartir), `apple-touch-icon.png` (180×180), logo y captura de Curtzz, skins en WebP |
| `assets/mark.svg` | Logo del estudio y favicon de todas las páginas |

## Cómo se edita

- **Estado de un proyecto:** en `index.html`, mueve su tarjeta a otra columna del tablero (`<li class="col">`) y cambia el texto de la terminal de la cabecera.
- **Proyecto nuevo:** copia una tarjeta (`.card`) a la columna que toque. Para una idea, usa `.card.id`.
- **Bitácora:** añade un `<li class="ev">` arriba de la lista (`ev r` si es de RONIN).
- **Ilustración de RONIN:** `assets/ronin-art.svg` es provisional. Cámbiala por el arte real cuando exista.
- **Skins:** son WebP de 240×240 (se muestran a 130 px). Si añades una, conviértela a WebP y pon `width` y `height` en el `<img>`.
- **Imagen al compartir:** `assets/img/og.png` puede sustituirse por cualquier PNG o JPG de 1200×630 que pese menos de 200 KB (mismo nombre, o cambia la ruta en las tres páginas).

No hay analítica, cookies ni peticiones a terceros. Las tipografías van incluidas en `assets/fonts/`.

### Probarla en local

`404.html` usa rutas que empiezan por `/trazzo/`, y el precargado de tipografías (`crossorigin`) da errores de CORS al abrir los archivos con `file://`. Para ver la web como se verá publicada:

```sh
mkdir /tmp/sitio && ln -s "$PWD" /tmp/sitio/trazzo && python3 -m http.server -d /tmp/sitio 8000
# http://localhost:8000/trazzo/
```

## Web neutral para Google Play

La web que irá en la ficha de Google Play no debe llevar al usuario a otro medio de pago (política de pagos). Por eso `index.html`, `curtzz.html` y `privacidad.html` no tienen enlaces a `tienda.html` ni precios, bono del 25 %, «Prismas por dinero» ni menú «Tienda». `tienda.html` se conserva pero sin enlazar y con `noindex,nofollow`; arriba muestra «La tienda web abre más adelante.» mientras `SERVIDOR` esté vacío.

La única mención que queda es la sección 5 de `privacidad.html` («Tienda web y códigos»), que dice que la tienda todavía no está abierta y qué datos se guardarán cuando abra. Es texto legal, sin enlace.

### Reactivar la tienda web

1. **Servidor:** en `assets/tienda.js` rellena `const SERVIDOR = '…'` con la URL https del servidor de compras, sin barra final. El aviso se oculta solo y el botón de pago se activa. El servidor debe volver a `https://26914233.github.io/trazzo/tienda.html?pedido=…` (variable `WEB_URL` = `https://26914233.github.io/trazzo`).
2. **CSP de `tienda.html`:** en `connect-src` cambia `https:` por el origen exacto del servidor (por ejemplo `connect-src 'self' https://curtzz-servidor.up.railway.app`).
3. **Enlaces que hay que volver a poner** (el texto original está en el commit `2d75510`: `git show 2d75510:curtzz.html`):
   - `index.html`: en el menú de la cabecera `<a href="tienda.html">/tienda</a>` y en el pie `<a href="tienda.html">tienda</a>`.
   - `curtzz.html`: en el menú `<a href="#tienda">/prismas</a><a href="tienda.html">/tienda</a>`, en el pie `tienda`, y la sección `<section id="tienda">` con los 4 paquetes (con su CSS `.pack`, `.price`, `.best`, `.note` y `.c-violet`).
   - `privacidad.html`: en el menú `<a href="tienda.html">/tienda</a>` y en el pie `tienda`.
4. **Política de privacidad:** reescribe la sección 5 (ya no «todavía no está abierta») y actualiza la fecha.
5. **Buscadores:** si quieres que `tienda.html` salga, quita su `<meta name="robots">`, añade su `canonical` y ponla en `sitemap.xml`.
6. Antes de enlazarla desde la web de la ficha, avisa a Soporte de Políticas de Google Play (ver la auditoría de la 1.8, punto P1).

`pagoSeguro` (en `tienda.js`) solo deja salir a `https://` con el dominio exacto `mercadopago.com`, `mercadopago.com.xx` o `www.` delante, sin usuario ni puerto. Un subdominio (por ejemplo el de pruebas `sandbox.`) o `mercadopago.cl` se bloquean; si hiciera falta para probar, amplía la expresión `HOST_MERCADOPAGO` solo en esa prueba.

## Correo de contacto

El correo es `prueba1bysisne@gmail.com`. Cuando se cambie por un alias, hay que editarlo en estos archivos (`grep -rn prueba1bysisne .`):

| Archivo | Dónde |
|---|---|
| `index.html` | 3 enlaces `mailto:` (idea para el estudio, «Quiero probarlo», «contacto» del pie) |
| `curtzz.html` | 2 enlaces `mailto:` («Quiero ser tester» y «contacto» del pie) |
| `privacidad.html` | 3 sitios, cada uno con enlace y texto: responsable (intro), sección 7 (probadores) y sección 12 (derechos) |
| `tienda.html` | 1 enlace en el pie (¿Problemas con un pago?) |
| `README.md` | este apartado |

## Seguridad: CSP

Cada página lleva una política de seguridad de contenido en una etiqueta `<meta http-equiv="Content-Security-Policy">` (GitHub Pages no deja poner cabeceras):

```
default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'; connect-src 'self' https:; base-uri 'self'; form-action 'self'
```

- No hay scripts en línea: todo el JavaScript está en `assets/*.js`. Los datos JSON-LD (`<script type="application/ld+json">`) no se ejecutan y la CSP no los bloquea.
- `'unsafe-inline'` solo en `style-src`, por los bloques `<style>` de cada página.
- `connect-src 'self' https:` es el valor pedido para todas las páginas. Solo `tienda.html` hace peticiones; cuando exista el servidor real, déjalo con su origen exacto (paso 2 de «Reactivar la tienda») y, si quieres, pon `connect-src 'self'` en las demás.
- Una `<meta>` no admite `frame-ancestors`, `report-uri` ni `sandbox`.

## SEO

- `index.html`, `curtzz.html` y `privacidad.html`: `canonical` absoluto con base `https://26914233.github.io/trazzo/`, `og:*` (incluidas `og:image` absoluta y `og:image:alt`), `twitter:card=summary_large_image`. JSON-LD: `Organization` en la portada y `VideoGame` en Curtzz (sin precios ni ofertas).
- Si cambia el dominio, hay que cambiar la base en esas tres páginas, en `sitemap.xml`, en `robots.txt` y en las rutas `/trazzo/` de `404.html`.
- **GitHub Pages de proyecto:** los buscadores solo leen `robots.txt` en la raíz del dominio (`https://26914233.github.io/robots.txt`), no en `/trazzo/`. El que hay aquí sirve con un dominio propio; mientras tanto, envía `sitemap.xml` desde Search Console.
- `tienda.html` y `404.html` llevan `noindex`.

## Rendimiento y accesibilidad

- Se precargan las tipografías críticas (Space Grotesk e Inter, `rel="preload"` con `crossorigin`).
- La imagen principal de `curtzz.html` lleva `fetchpriority="high"`.
- `scroll-behavior:smooth` solo con `prefers-reduced-motion:no-preference`. Con movimiento reducido, `curtzz.html` no arranca la animación y oculta el botón de pausa.
- Objetivos táctiles de 44 px como mínimo en menú y pie; el menú se parte en dos filas en vez de recortar un enlace.
- `.btn[disabled]` tiene colores propios con contraste de 8:1 (no usa `opacity`).

## Pendiente del dueño

- La política de privacidad nombra al responsable: Juan Pablo Ramirez (estudio thunderDarkness), persona natural con domicilio en Colombia, y el correo de contacto. A propósito no publica la dirección de la casa (decisión del dueño, 11/10/2026).
- El correo de contacto se queda en `prueba1bysisne@gmail.com` (decisión del dueño).
