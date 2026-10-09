# Modelo de negocio — Palabrario

**App de pago: 4,99 US$ en Google Play.** Todo incluido desde la primera partida:
545 sopas, cuatro dificultades, pistas sin límite, tres diseños.
**Sin anuncios, sin compras dentro de la app, sin suscripción.**

Decisión del dueño (octubre 2026). La misma fórmula se usará en Pintazz.

## Por qué funciona (y qué hay que tener en cuenta)

- **A favor:** es el argumento de venta. "Sin anuncios" es lo que más se pide en las
  reseñas de este género. El juego es más simple: no hay SDK de anuncios ni de pagos,
  no pide permisos de red y el formulario de datos de Play queda en "no recoge datos".
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
| 3 pistas al día | Pistas ilimitadas (cuestan estrellas) |
| Plugins de AdMob y Play Billing | No hacen falta |

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
