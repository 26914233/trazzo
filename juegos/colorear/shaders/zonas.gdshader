// Color de cada zona: id en la textura de regiones (R + G*256), color en la paleta.
shader_type canvas_item;

uniform sampler2D paleta : filter_nearest;

void fragment() {
	vec4 r = texture(TEXTURE, UV);
	int id = int(round(r.r * 255.0)) + int(round(r.g * 255.0)) * 256;
	COLOR = texelFetch(paleta, ivec2(id % 64, id / 64), 0);
}
