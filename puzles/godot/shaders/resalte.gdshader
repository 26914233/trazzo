// Brillo que late sobre una pieza (la última pista de cada paso): se suma encima de su material,
// más fuerte en los bordes, como una luz que la rodea.
shader_type spatial;
render_mode unshaded, blend_add, cull_back, depth_draw_never;

uniform vec4 color : source_color = vec4(1.0, 0.85, 0.5, 1.0);

void fragment() {
	float borde = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.0);
	float pulso = 0.5 + 0.5 * sin(TIME * 5.0);
	ALBEDO = color.rgb * (0.1 + borde * 0.7) * (0.35 + 0.65 * pulso);
}
