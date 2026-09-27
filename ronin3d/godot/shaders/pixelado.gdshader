// Estética pixel art 3D: la escena ya llega a baja resolución (SubViewport encogido);
// aquí se reducen los colores con un tramado ordenado (Bayer 4x4), como en consolas viejas.
shader_type canvas_item;

uniform float niveles = 9.0;
uniform float tramado = 0.6;

float bayer(vec2 celda) {
	int x = int(mod(celda.x, 4.0));
	int y = int(mod(celda.y, 4.0));
	int indice = x + y * 4;
	float matriz[16] = float[16](0.0, 8.0, 2.0, 10.0, 12.0, 4.0, 14.0, 6.0,
								 3.0, 11.0, 1.0, 9.0, 15.0, 7.0, 13.0, 5.0);
	return matriz[indice] / 16.0 - 0.5;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec2 celda = floor(UV * vec2(textureSize(TEXTURE, 0)));
	vec3 tramo = color.rgb * niveles + bayer(celda) * tramado;
	color.rgb = clamp(floor(tramo + 0.5) / niveles, 0.0, 1.0);
	COLOR = color;
}
