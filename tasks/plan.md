# Plan de implementación: Sopazz (sopa de letras) y familia de juegos

## Resumen

Cuatro juegos nuevos para Android / Google Play, hechos en **Godot 4.7**, monetizados
con anuncios (AdMob) y compras dentro de la app. Se construye **uno completo primero**
—la sopa de letras, nombre de trabajo **Sopazz**— y de él sale el molde reutilizable
(plantilla de proyecto, capa de monetización, guardado, flujo de exportación y subida)
que heredan los otros tres.

Orden acordado con el dueño:

1. **Sopazz** — sopa de letras. Jugable y publicable. *Esta tanda.*
2. **Pintazz** — dibujo libre, colorear y mandalas.
3. **Rebotazz** — plataforma, bola y bloques (tipo Arkanoid).
4. **Zona Zero** — supervivencia zombi 2D top-down, alcance acotado (no es un clon de
   Project Zomboid; eso es un proyecto de años con equipo).

## Decisiones de arquitectura

- **Motor: Godot 4.7 stable.** Elegido por el dueño. Exporta a Android, un solo
  proyecto por juego. Verificado en este entorno en modo `--headless`.
- **Renderizador: `gl_compatibility`.** Es el que llega a los Android viejos y
  baratos, que son la mayor parte del mercado hispanohablante donde se publica.
- **Vertical, 1080x1920, `canvas_items` con `expand`.** Un juego de sopa de letras
  se juega con una mano.
- **Lógica separada de la escena.** El generador de sopas (`scripts/generador.gd`) es
  una clase pura, sin nodos ni `Node2D`: así se prueba en `--headless` sin abrir
  ventana. Las pruebas son reales, no decorativas.
- **Monetización detrás de una interfaz (`autoload/monetizacion.gd`).** El juego
  nunca llama a AdMob directamente. Si el plugin no está presente (como en este
  entorno, que no tiene SDK de Android), la capa responde con un stub que simula
  el resultado y el juego sigue funcionando y probándose.
- **Guardado firmado.** `user://progreso.save` con HMAC del dispositivo, para que
  editar el archivo no regale monedas ni niveles (ver `security-audit-juegos`).
- **Datos en JSON, no en código.** Los temas de palabras viven en `datos/temas/*.json`:
  añadir un paquete nuevo (y venderlo) no exige recompilar la lógica.

## Lista de tareas

### Fase 1: Fundamentos
- [ ] T1: Proyecto Godot configurado para Android vertical
- [ ] T2: Banco de palabras en español por temas (JSON)
- [ ] T3: Generador de sopas (8 direcciones, relleno, semilla reproducible)
- [ ] T4: Pruebas headless del generador

### Punto de control: Fundamentos
- [ ] `godot --headless --script res://tests/pruebas.gd` pasa en verde
- [ ] El proyecto importa sin errores de parseo

### Fase 2: Juego jugable
- [ ] T5: Guardado persistente y firmado (progreso, monedas, ajustes)
- [ ] T6: Tablero táctil: selección por arrastre, detección de palabra, resaltado
- [ ] T7: HUD, lista de palabras, victoria de nivel y estrellas
- [ ] T8: Menú principal, selector de temas y dificultades, ajustes

### Punto de control: Juego jugable
- [ ] Una partida completa de principio a fin sin tocar código
- [ ] El progreso sobrevive a cerrar y abrir la app

### Fase 3: Monetización
- [ ] T9: Capa de monetización con stub + hueco para el plugin de AdMob
- [ ] T10: Pistas: gratis al principio, luego monedas o anuncio premiado
- [ ] T11: Intersticial con reglas de frecuencia (y nunca tras perder)
- [ ] T12: Tienda: paquetes de monedas, "quitar anuncios", paquetes de temas
- [ ] T13: Consentimiento de privacidad (UMP/GDPR) y modo sin anuncios

### Punto de control: Monetización
- [ ] El juego es jugable y vendible con el stub, sin plugin instalado
- [ ] Ninguna pantalla se queda bloqueada si un anuncio falla

### Fase 4: Subida a Google Play
- [ ] T14: `export_presets.cfg` de Android, nombre de paquete, iconos, versión
- [ ] T15: Ficha de tienda (título, descripciones, capturas) y textos
- [ ] T16: Política de privacidad y formulario de Data safety
- [ ] T17: Auditoría `security-audit-juegos` del guardado y la economía
- [ ] T18: Checklist de lanzamiento repasado

### Punto de control: Listo para subir
- [ ] Lo que falta para el AAB firmado está escrito y es solo trabajo de máquina
      local (SDK de Android + clave de firma, que no existen en este entorno)

## Riesgos y mitigaciones

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Este entorno no tiene SDK de Android ni plantillas de exportación | Alto | No puedo generar el AAB aquí. Se deja todo configurado y documentado paso a paso; el AAB se firma en la máquina del dueño. Se dice claramente, no se finge. |
| AdMob en Godot depende de un plugin de terceros | Medio | La capa de monetización aísla el plugin. Si cambia o se abandona, se reemplaza un archivo y no el juego. |
| Google Play rechaza por anuncios intrusivos o Data safety mal declarado | Alto | Reglas de frecuencia explícitas, sin intersticial tras derrota ni en el primer nivel, y formulario de Data safety redactado junto a la política. |
| Cuatro juegos a la vez diluyen la calidad | Alto | Se entrega uno completo y el molde. Los otros tres heredan y se construyen después. |
| "Tipo Project Zomboid" es inabordable tal cual | Alto | Se redefine como roguelike de supervivencia acotado, con su propio GDD cuando toque. |

## Preguntas abiertas para el dueño

- Nombre definitivo: ¿**Sopazz** (coherente con Curtzz/Trazzo) u otro?
- ¿Moneda propia del juego o reutilizar **Prismas** de Curtzz para que una compra
  sirva en toda la familia de juegos?
- Precio del "quitar anuncios": sugiero 2,99 US$ (ver `docs/MONETIZACION.md`).
- ¿Se publica bajo la misma cuenta de desarrollador que Curtzz (thunderDarkness)?
