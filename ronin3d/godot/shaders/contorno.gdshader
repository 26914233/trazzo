// Contorno negro por «casco invertido»: se dibuja la cara de atrás un poco inflada.
shader_type spatial;
render_mode unshaded, cull_front, depth_draw_opaque, shadows_disabled;

uniform vec4 color : source_color = vec4(0.05, 0.04, 0.07, 1.0);
uniform float grosor = 0.025;
uniform bool por_normal = true;        // false para cajas: se infla desde el centro
// Metros que el casco se aleja de la cámara. En los modelos detallados (muchas curvas y
// huecos) evita que el casco asome por delante de la piel como manchas negras: así solo se ve
// en la silueta. 0 = sin empuje (piezas y escenario).
uniform float empuje = 0.0;

void vertex() {
	vec3 inflado = por_normal ? VERTEX + NORMAL * grosor : VERTEX + normalize(VERTEX) * grosor * 1.4;
	// Se calcula la posición a mano en los dos casos: si POSITION se escribe solo en uno, Godot
	// deja de transformar los vértices en el otro y el contorno desaparece.
	vec4 vista = MODELVIEW_MATRIX * vec4(inflado, 1.0);
	if (empuje > 0.0) {
		vista.xyz += normalize(vista.xyz) * empuje;
	}
	POSITION = PROJECTION_MATRIX * vista;
}

void fragment() {
	ALBEDO = color.rgb;
}
