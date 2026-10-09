# GDD — Sopazz (sopa de letras)

**Plataforma:** Android (Google Play) · **Motor:** Godot 4.7 · **Orientación:** vertical
**Público:** jugador casual hispanohablante, 25–65 años, juega en ratos muertos
**Nombre de trabajo:** Sopazz (coherente con Curtzz / Trazzo)

## 1. Qué es

Una sopa de letras que se juega con un dedo. Arrastras sobre las letras, si la línea
forma una palabra de la lista queda marcada. Cuando encuentras todas, pasas de nivel.
Sin presión de tiempo obligatoria, sin derrota: el cronómetro solo decide las estrellas.

**Por qué este juego y no otro:** es el género casual con el coste de producción más
bajo por nivel (los niveles se generan, no se diseñan a mano) y con el público más
dispuesto a ver un anuncio premiado a cambio de una pista. No compite con Curtzz:
Curtzz es precisión y castigo, Sopazz es calma y rutina diaria.

## 2. Bucle principal

```
Menú → elegir tema → elegir dificultad → partida
   ↓                                        ↓
rutina diaria ← recompensa (fichas, estrellas) ← victoria
```

Una sesión objetivo son 3 niveles, unos 8 minutos.

## 3. Controles

- **Arrastrar**: desde la primera letra hasta la última. La selección se ajusta a una
  de las 8 direcciones rectas; el dedo no tiene que ser preciso, la celda más cercana
  a la línea gana.
- **Soltar**: valida. Correcta → se fija con el color del tema y se tacha en la lista.
  Incorrecta → la selección se deshace con una sacudida corta.
- Las palabras cuentan **en los dos sentidos**: encontrar `OSO` al revés es encontrar `OSO`.
- **Pista**: botón en el HUD. Resalta la primera letra de una palabra que falte.

Nada de menús dentro de la partida más allá de pausa. El pulgar no debe salir de la
mitad inferior de la pantalla para jugar.

## 4. Dificultades

| Nivel | Cuadrícula | Palabras | Direcciones | Público |
|---|---|---|---|---|
| Fácil | 8×8 | 5 | horizontal y vertical, sin invertir | primeras partidas |
| Normal | 10×10 | 8 | + diagonales | el grueso del juego |
| Difícil | 12×12 | 11 | + invertidas | jugador habitual |
| Experto | 14×14 | 14 | todas, palabras largas | el que ya domina |

La primera partida de cada jugador es Fácil y sin anuncios. El juego no se pone
difícil hasta que el jugador ha ganado tres veces: la curva empieza amable, igual que
en Curtzz, pero aquí **nunca** llega al tramo sin concesiones — no es ese tipo de juego.

## 5. Temas

Cada tema es un archivo JSON con su lista de palabras y su color. Añadir un tema no
toca código.

**Gratis:** Animales, Comida, Colombia, Cuerpo humano, Deportes, Naturaleza.
**De pago o desbloqueables con fichas:** Países del mundo, Cine y series, Ciencia,
Mitología, Música, Oficios.

Las palabras se normalizan antes de entrar en la cuadrícula: mayúsculas, sin tildes, la
Ñ pasa a N y los espacios desaparecen. Lo que se muestra en la lista mantiene su
forma correcta (`MÚSICA` en la lista, `MUSICA` en el tablero).

## 6. Progresión

- **Estrellas por nivel** (1–3) según tiempo y pistas usadas. Sin pistas y rápido = 3.
- **Fichas** (moneda del juego) por completar niveles; detalle en `MONETIZACION.md`.
- **Rutina diaria**: un nivel del día con recompensa doble. Mantener la racha es el
  gancho de retención; perderla no castiga, solo reinicia el contador.
- **Desbloqueo de temas** con fichas o con compra directa.

## 7. Accesibilidad

- Las palabras encontradas se distinguen por **color y por el tachado en la lista**,
  nunca solo por color (daltonismo).
- Escala de texto del tablero ajustable en Ajustes; la cuadrícula se reajusta.
- Vibración opcional y desactivable.
- Sin dependencias de audio: el juego es completo en silencio.

## 8. Audio

- Pulsación de celda: clic corto y seco.
- Palabra correcta: acorde ascendente de tres notas.
- Nivel completado: fanfarria breve, menos de 2 s.
- Música de fondo: colchón suave en bucle, apagada por defecto en móvil.

## 9. Fuera de alcance (a propósito)

- Multijugador y tablas de clasificación online: no en la primera versión.
- Cuenta de usuario / nube: el progreso es local y firmado. Guardado en nube cuando
  haya razón de negocio, no antes.
- Generación de palabras con IA: el banco curado es más barato y no produce vergüenzas.
