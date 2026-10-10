// Color de cada zona: id en la textura de regiones (R + G*256), color en la paleta.
// "resaltada" late con un tono de aviso (boton buscar zona sin pintar).
shader_type canvas_item;

uniform sampler2D paleta : filter_nearest;
uniform int resaltada = 0;
uniform vec4 color_resalte : source_color = vec4(0.86, 0.11, 0.45, 1.0);
uniform float fuerza_resalte = 0.0;   // 0..1, la mueve vista_lamina.gd
uniform float fase_resalte = 0.0;     // desplaza las rayas

void fragment() {
	vec4 r = texture(TEXTURE, UV);
	int id = int(round(r.r * 255.0)) + int(round(r.g * 255.0)) * 256;
	COLOR = texelFetch(paleta, ivec2(id % 64, id / 64), 0);
	if (id == resaltada && resaltada > 0) {
		// rayas diagonales que se mueven: se distinguen sobre cualquier color
		float raya = step(0.5, fract((FRAGCOORD.x + FRAGCOORD.y) / 28.0 - fase_resalte));
		COLOR.rgb = mix(COLOR.rgb, color_resalte.rgb, fuerza_resalte * (0.35 + 0.65 * raya));
	}
}
