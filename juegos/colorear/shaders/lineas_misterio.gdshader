// Lineas de una lamina misterio: tenues donde la zona sigue en blanco, nitidas
// donde ya se pinto. El dibujo se descubre al colorearlo.
shader_type canvas_item;

uniform sampler2D regiones : filter_nearest;
uniform sampler2D paleta : filter_nearest;
uniform float tenue = 0.22;

void fragment() {
	vec4 lin = texture(TEXTURE, UV);
	vec4 r = texture(regiones, UV);
	int id = int(round(r.r * 255.0)) + int(round(r.g * 255.0)) * 256;
	vec4 c = texelFetch(paleta, ivec2(id % 64, id / 64), 0);
	bool pintada = any(lessThan(c.rgb, vec3(0.999)));
	COLOR = vec4(lin.rgb, lin.a * (pintada ? 1.0 : tenue));
}
