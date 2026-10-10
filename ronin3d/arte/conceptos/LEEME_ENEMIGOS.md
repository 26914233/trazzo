# Enemigos en el estilo del oni del usuario

El 10-10-2026 el usuario eligió el estilo de su hoja del oni (`oni_jefe_hoja.webp`) para el jefe
y pidió el mismo estilo para los demás enemigos. Cada enemigo tiene una hoja de perfil, mirando a la
derecha, con cinco filas: **reposo, caminar, ataque, golpe y muerte**.

| Enemigo | Hoja original | Sprites del juego | Altura en el juego |
| --- | --- | --- | --- |
| Oni (jefe) | `oni_jefe_hoja.webp` (del usuario) | `godot/recursos/sprites/oni_jefe.png` | 2,6 m |
| Aka-oni | la misma del oni | la misma | 2,2 m |
| Kappa | `hoja_kappa.png` (Gemini) | `kappa_hoja.png` | 1,3 m |
| Onibi | `hoja_onibi.png` (Gemini) | `onibi_hoja.png` | 0,9 m, flotando |
| Soldado de Genzo | `hoja_soldado.png` (Gemini) | `soldado_hoja.png` | 2,2 m con la yari |

## Cómo se hacen

1. Se genera la hoja con Gemini (`generar_imagen_gemini` del servidor MCP Central, modelo
   `gemini-3.1-flash-image`, proporción 1:1, unos 0,045 USD por imagen). La referencia de estilo es
   la URL pública de `oni_jefe_hoja.webp` en el repositorio. El prompt pide:
   - el mismo estilo de pixel art que la referencia;
   - el personaje entero, de perfil y mirando a la derecha, con el mismo tamaño en cada cuadro;
   - 5 filas (reposo 4, caminar 6, ataque 4, golpe 3, muerte 4) sobre un fondo liso #0c0f17, sin
     texto ni paneles.
2. Se recorta:
   `python3 ronin3d/herramientas/recortar_hoja.py ronin3d/arte/conceptos/hoja_<id>.png <id>_hoja reposo,caminar,ataque,golpe,muerte`
   Encuentra las filas y los cuadros solo, quita el fondo y alinea por los pies. El oni del usuario
   tiene su propio recorte (`recortar_oni_jefe.py`), porque su hoja trae textos y paneles.
3. En `godot/scripts/enemigos.gd`, el perfil lleva `hoja` y `alto`. Para los soldados está en
   `juego.gd`, con `Datos.ALTO_SOLDADO_HOJA`. Las muestra `visual_hoja.gd`.
4. Al reimportar: `detect_3d/compress_to=0` y sin mipmaps en su `.import`.
