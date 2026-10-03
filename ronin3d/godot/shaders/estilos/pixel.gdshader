// Estilo «pixel art 3D» (prueba de la DECISIÓN 20): el mundo se dibuja a un cuarto de la resolución
// (stretch_shrink del SubViewportContainer, con filtro «nearest») y aquí se reducen los colores con
// un tramado ordenado, como en los juegos de 16 bits.
shader_type canvas_item;

uniform float niveles = 7.0;           // tonos por canal de color
uniform float tramado = 0.75;          // fuerza del tramado (Bayer 4 × 4)
uniform float exposicion = 1.15;

const float BAYER[16] = {0.0, 8.0, 2.0, 10.0, 12.0, 4.0, 14.0, 6.0, 3.0, 11.0, 1.0, 9.0, 15.0, 7.0, 13.0, 5.0};

void fragment() {
	vec2 tam = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 pixel = floor(UV * tam);
	vec3 c = texture(TEXTURE, (pixel + 0.5) / tam).rgb * exposicion;
	int x = int(mod(pixel.x, 4.0));
	int y = int(mod(pixel.y, 4.0));
	float umbral = (BAYER[y * 4 + x] + 0.5) / 16.0 - 0.5;
	c = floor((c + umbral * tramado / niveles) * niveles + 0.5) / niveles;
	COLOR = vec4(clamp(c, 0.0, 1.0), 1.0);
}
