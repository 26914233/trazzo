# Tareas: Palabrario (antes Sopazz; sopa de letras, Godot 4 → Android)

> Estado 2026-10-09 (actualizado): el modelo cambió a **app de pago sin anuncios ni
> compras** y el contenido a **545 sopas en 44 temas**. Las tareas T9–T13 (anuncios,
> pistas de pago, intersticial, tienda, consentimiento) se hicieron y luego se
> **retiraron** por decisión del dueño. Vigente: `tasks/plan.md` y
> `juegos/palabrario/docs/LANZAMIENTO.md`.

Plan completo en `tasks/plan.md`. Marcar solo lo verificado de verdad.

## Fase 1: Fundamentos

- [x] **T1: Proyecto Godot para Android vertical** — S
  - Criterios: `project.godot` con 1080x1920, `gl_compatibility`, orientación retrato;
    autoloads declarados; el proyecto importa sin errores.
  - Verificación: `godot --headless --quit` sin errores de parseo.
- [x] **T2: Banco de palabras por temas** — S
  - Criterios: al menos 6 temas en `datos/temas/*.json`, 30+ palabras por tema, en
    español, sin tildes ni Ñ en la cuadrícula (se normaliza), 3–9 letras.
  - Verificación: prueba que carga todos los temas y valida longitudes y caracteres.
- [x] **T3: Generador de sopas** — M
  - Criterios: coloca N palabras en 8 direcciones sobre una cuadrícula NxN; cruces
    permitidos solo con letras coincidentes; relleno aleatorio; misma semilla → misma
    sopa; informa qué palabras no pudo colocar en vez de fallar en silencio.
  - Verificación: pruebas headless, incluido el caso imposible (cuadrícula pequeña).
- [x] **T4: Pruebas headless** — S
  - Criterios: un comando corre todas las pruebas y devuelve código de salida ≠ 0 al fallar.
  - Verificación: `godot --headless --script res://tests/pruebas.gd`; romper a propósito
    una aserción debe poner el comando en rojo.

## Punto de control: Fundamentos
- [x] Pruebas en verde
- [x] Sin errores de importación

## Fase 2: Juego jugable

- [x] **T5: Guardado persistente y firmado** — M
  - Criterios: progreso, monedas, ajustes y compras en `user://progreso.save`; firma
    HMAC; un archivo manipulado se rechaza y se reinicia a valores seguros, no a premios.
  - Verificación: prueba headless que guarda, carga, manipula y comprueba el rechazo.
- [x] **T6: Tablero táctil** — M
  - Criterios: arrastrar el dedo marca una línea recta de celdas (8 direcciones);
    soltar valida; palabra correcta queda fijada con color; incorrecta se deshace.
    Funciona al revés (palabra escrita de derecha a izquierda cuenta).
  - Verificación: prueba de la lógica de selección + comprobación manual en escritorio.
- [x] **T7: HUD, victoria y estrellas** — M
  - Criterios: lista de palabras con las encontradas tachadas, contador, cronómetro;
    al encontrar todas, pantalla de victoria con estrellas por tiempo y pistas usadas.
  - Verificación: partida completa de un nivel en escritorio.
- [x] **T8: Menú, selector y ajustes** — M
  - Criterios: menú principal; selector de temas (bloqueados/desbloqueados) y de
    dificultad; ajustes de sonido, vibración e idioma; todo navegable con el pulgar.
  - Verificación: recorrido completo de pantallas sin callejones sin salida.

## Punto de control: Juego jugable
- [x] Partida completa sin tocar código
- [x] El progreso sobrevive al reinicio de la app

## Fase 3: Monetización

- [x] **T9: Capa de monetización** — M
  - Criterios: una sola interfaz (`mostrar_intersticial`, `mostrar_premiado`,
    `comprar`); detecta el plugin de AdMob y, si no está, usa el stub; el juego
    nunca se queda esperando un anuncio que no llega (timeout).
  - Verificación: prueba headless con el stub, incluidos los caminos de fallo.
- [x] **T10: Pistas (el motor de ingresos)** — S
  - Criterios: 3 pistas gratis al empezar; después cuestan monedas o un anuncio
    premiado; la pista revela una palabra concreta, nunca el tablero entero.
  - Verificación: prueba de la economía de pistas.
- [x] **T11: Intersticial con reglas** — S
  - Criterios: nunca en el primer nivel, nunca tras perder, nunca dos seguidos en
    menos de 90 s, y jamás durante una partida en curso.
  - Verificación: prueba de las reglas de frecuencia.
- [x] **T12: Tienda** — M
  - Criterios: paquetes de monedas, "quitar anuncios" (no consumible, restaurable),
    paquetes de temas; precios en `docs/MONETIZACION.md`; compra fallida no cobra ni regala.
  - Verificación: prueba de concesión de recompensas y de restauración de compras.
- [x] **T13: Consentimiento de privacidad** — S
  - Criterios: hueco para UMP; sin consentimiento → anuncios no personalizados;
    "quitar anuncios" apaga de verdad toda llamada de anuncios.
  - Verificación: revisión de código y prueba del interruptor.

## Punto de control: Monetización
- [x] Jugable y vendible con el stub, sin plugin
- [x] Ninguna pantalla bloqueada si un anuncio falla

## Fase 4: Subida a Google Play

- [x] **T14: Exportación Android** — M
  - Criterios: `export_presets.cfg` con nombre de paquete, versión, iconos, ABI
    arm64+arm32, AAB; instrucciones de firma sin claves en el repo.
  - Verificación: el preset se lee sin error; el AAB se construye en la máquina del
    dueño (aquí no hay SDK) — queda documentado, no fingido.
- [x] **T15: Ficha de tienda** — S
  - Criterios: título ≤30, descripción corta ≤80, descripción larga, palabras clave,
    guion de capturas.
  - Verificación: límites de caracteres comprobados con un script.
- [x] **T16: Privacidad y Data safety** — S
  - Criterios: página de privacidad publicable y respuestas del formulario de Data
    safety coherentes con lo que el juego recoge de verdad.
  - Verificación: contraste línea por línea con el código de monetización.
- [x] **T17: Auditoría anti-trampa y de economía** — M
  - Criterios: guardado, monedas y pistas revisados con `security-audit-juegos`;
    hallazgos con rastro en el código, los no resueltos como `needs_validation`.
  - Verificación: resumen y estado en `juegos/palabrario/docs/LANZAMIENTO.md` §5.
- [x] **T18: Checklist de lanzamiento** — S
  - Criterios: `launch-checklist` repasado, con lo que falta marcado como pendiente real.
  - Verificación: `docs/LANZAMIENTO.md`.

## Punto de control: Listo para subir
- [ ] Lo pendiente es solo trabajo de máquina local (SDK + clave de firma)
