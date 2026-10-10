// Personajes en pixel art (DECISIÓN 20, opción E): un cartel que siempre mira a la cámara y muestra
// un cuadro de su hoja de sprites (recursos/sprites/). Gira sobre los pies del personaje, que son
// el origen del nodo. Recibe la luz de la escena (antorchas, luna) como una tarjeta plana, sin
// sombrear por la normal, porque el sombreado ya viene dibujado en el sprite.
shader_type spatial;
render_mode cull_disabled, specular_disabled, depth_draw_opaque;

uniform sampler2D hoja : source_color, filter_nearest;
uniform vec4 region = vec4(0.0, 0.0, 1.0, 1.0);    // x, y, ancho y alto del cuadro, en UV de la hoja
uniform float destello = 0.0;                        // 1 = blanco (golpe recibido)
uniform float luz_propia = 0.22;                     // de noche, que el sprite no se pierda
uniform vec3 tinte : source_color = vec3(1.0);       // el doble oscuro de Akira (capítulo 4)

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	vec4 color = texture(hoja, region.xy + UV * region.zw);
	if (color.a < 0.5) {
		discard;
	}
	vec3 base = mix(color.rgb * tinte, vec3(1.0), destello);
	ALBEDO = base;
	ROUGHNESS = 1.0;
	EMISSION = base * luz_propia;
}

void light() {
	DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * ATTENUATION * 0.75;
}
