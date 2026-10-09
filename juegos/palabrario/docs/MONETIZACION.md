# Modelo de negocio — Palabrario

**App de pago: 4,99 US$ en Google Play.** Todo el contenido incluido desde la primera
partida: 545 sopas, cuatro dificultades, tres diseños. **Sin anuncios y sin suscripción.**

**Única compra dentro: paquetes de pistas (opcionales).** Cada día se regalan 3 pistas;
quien quiera más compra un paquete:

| Producto (ID en Play Console) | Tipo | Pistas | Precio |
|---|---|---|---|
| `pistas_10` | consumible | 10 | 0,99 US$ |
| `pistas_30` | consumible | 30 | 1,99 US$ |
| `pistas_100` | consumible | 100 | 4,99 US$ |

Las pistas compradas no caducan y se gastan después de las 3 gratis del día. Nada del
contenido depende de ellas: se puede terminar el juego sin comprar ninguna.

Decisiones del dueño (octubre 2026): app de pago; pistas monetizadas con paquetes y sin
anuncios. La misma fórmula de base se usará en Pintazz.

## Por qué funciona (y qué hay que tener en cuenta)

- **A favor:** es el argumento de venta. "Sin anuncios" es lo que más se pide en las
  reseñas de este género. No hay SDK de anuncios ni analítica: el formulario de datos de
  Play queda en "no recoge datos".
- **Pistas:** un ingreso extra de los jugadores más enganchados, sin tocar la promesa
  "todo el contenido incluido". La ficha debe decir que hay compras opcionales.
- **En contra:** en Play casi todo lo casual es gratis y una app de pago se descarga
  mucho menos. La ficha (capturas, descripción y primeras reseñas) tiene que convencer
  sin que nadie pueda probar antes.
- **Irreversible en un sentido:** Google Play deja pasar una app de pago a gratis,
  pero **no una gratis a de pago**. Empezar de pago deja abierta la otra vía si las ventas
  no arrancan.

## Precio

- Precio base: **4,99 US$**. Play propone el precio local por país; revisar los de
  Colombia, México y España para que queden en cifras redondas y razonables.
- Las promociones (rebajas temporales) se configuran en Play Console sin tocar el juego.

## Lo que ya no hay (y por qué)

| Antes | Ahora |
|---|---|
| Anuncios premiados e intersticiales (AdMob) | Eliminados |
| Fichas, paquetes y temas de pago | Eliminados |
| Versión gratis con 3 sopas por tema | Todo abierto |
| 3 pistas al día + anuncio premiado | 3 pistas al día + paquetes de pistas |
| Plugin de AdMob | No hace falta |
| Plugin de Play Billing | Sí, solo para las pistas |

El código de anuncios y compras sigue en el historial de git
(hasta el commit `e0ed81a`; se quitó en `a98b1df`) por si algún día se quiere un modelo gratis.

## Ingresos esperables (honesto)

Cada venta deja 4,99 US$ menos la comisión de Google Play y los impuestos locales.
La cifra de descargas de una app de pago nueva sin marketing es baja: cuentan las
reseñas, las capturas, el vídeo y el boca a boca. **La palanca es la ficha y la
promoción en los canales del dueño**, no el código.

## Piratería

Una app de pago se puede copiar fuera de Play. Sin servidor no hay protección fuerte en
el cliente. Antes de publicar, revisar en Play Console las opciones de integridad de la
app (*App integrity*) y decidir si se activan.
