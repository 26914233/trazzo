// Señal de «así no se puede»: un destello cálido recorre la pieza y se apaga, sin moverla.
// «intensidad» la anima la pieza (dos pulsos cortos); el borde brilla más, como un filo de luz.
shader_type spatial;
render_mode unshaded, blend_add, cull_back, depth_draw_never;

uniform vec4 color : source_color = vec4(1.0, 0.42, 0.22, 1.0);
uniform float intensidad = 0.0;

void fragment() {
	float borde = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 1.6);
	ALBEDO = color.rgb * (0.16 + borde * 0.9) * intensidad;
}
