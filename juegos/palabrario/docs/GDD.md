# GDD — Palabrario (sopa de letras)

**Plataforma:** Android (Google Play), app de pago · **Motor:** Godot 4.7 · **Orientación:** vertical
**Público:** jugador casual hispanohablante, 25–65 años, que busca calma y no soporta los anuncios
**Diseño visual:** Cielo (principal); Papel y Noche elegibles en Ajustes

## 1. Qué es

Una colección de **545 sopas de letras en español** repartidas en **44 temas**, de Comida
y Cocina del mundo a Química, Electricidad, Países, Colombia o Mitología. Se juega con
un dedo: arrastras sobre las letras y, si forman una palabra de la lista, queda marcada.
Sin derrota y sin presión: el reloj y las pistas solo deciden las estrellas.

**Por qué de pago:** el público de este género está cansado de juegos llenos de anuncios.
Palabrario se vende como lo contrario: pagas una vez y tienes todo, sin anuncios, sin
compras dentro y sin límites. Ver `MONETIZACION.md`.

## 2. Bucle principal

```
Menú → Temas → Sopas del tema → Partida → Victoria → Siguiente sopa
  └── Sopa del día (una distinta cada día, igual para todos)
```

Una sesión típica son 3–4 sopas, unos 10 minutos.

## 3. Contenido

- **545 sopas**, cada una con **12 palabras** sobre un subtema concreto
  (p. ej. Comida → Frutas tropicales; Electricidad → Componentes; Países → Capitales de Asia).
- El contenido vive en `datos/fuente/*.txt`, una línea por sopa, editable a mano.
  `python3 herramientas/construir_temas.py` lo valida y genera `datos/categorias/*.json`:
  12 palabras por sopa, sin repetidas, de 3 a 12 letras y sin letras raras.
- Las palabras se muestran con su ortografía (MARACUYÁ, BANDEJA PAISA) y en la
  cuadrícula van en mayúsculas sin tildes ni espacios. **La Ñ se conserva**: AÑO no puede
  convertirse en ANO.

## 4. Dificultades

| Dificultad | Cuadrícula mínima | Palabras | Direcciones |
|---|---|---|---|
| Fácil | 8×8 | las 6 más cortas | horizontal y vertical |
| Normal | 10×10 | las 9 más cortas | + diagonales |
| Difícil | 12×12 | las 12 | + al revés |
| Experto | 14×14 | las 12 | todas, con más relleno |

Si una palabra no cabe en la cuadrícula mínima, la cuadrícula crece lo justo. Cada sopa
tiene una disposición fija por dificultad: la sopa 7 de Comida en Normal es la misma
para todo el mundo. Las 2.180 combinaciones sopa/dificultad están probadas.

## 5. Controles

- **Arrastrar** de la primera a la última letra; la selección se ajusta sola a una de
  las 8 direcciones.
- **Soltar** valida. Correcta: se marca con el color del tema y se tacha en la lista.
  Incorrecta: pequeña sacudida.
- Las palabras cuentan en los dos sentidos.
- **Pista**: marca dónde empieza una palabra que falta. Sin límite; cada pista resta
  una estrella.

## 6. Progresión

- **Estrellas (1–3)** por sopa y dificultad, según el tiempo (unos 12 s por palabra es
  un buen ritmo) y las pistas usadas. Se guarda la mejor marca.
- Progreso por tema ("5 de 17") y global ("128 de 545 resueltas").
- **Continuar** vuelve al último tema jugado.
- **Sopa del día** y **racha de días seguidos**: el gancho para volver, sin premios
  que comprar ni perder.

## 7. Accesibilidad

- Encontradas = color + tachado en la lista (no solo color).
- Cuatro tamaños de letra del tablero.
- Contraste medido en pruebas: texto ≥ 4,5:1 y letras del tablero ≥ 7:1 en los tres diseños.
- Modo oscuro (diseño Noche).
- Juego completo sin sonido; vibración opcional.

## 8. Fuera de alcance de la v1

- Multijugador, tablas online, cuentas y nube.
- Otros idiomas.
- Generación de palabras con IA: el banco curado no produce errores embarazosos.
