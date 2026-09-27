// Contorno negro por «casco invertido»: se dibuja la cara de atrás un poco inflada.
shader_type spatial;
render_mode unshaded, cull_front, depth_draw_opaque, shadows_disabled;

uniform vec4 color : source_color = vec4(0.05, 0.04, 0.07, 1.0);
uniform float grosor = 0.025;
uniform bool por_normal = true;        // false para cajas: se infla desde el centro

void vertex() {
	if (por_normal) {
		VERTEX += NORMAL * grosor;
	} else {
		VERTEX += normalize(VERTEX) * grosor * 1.4;
	}
}

void fragment() {
	ALBEDO = color.rgb;
}
