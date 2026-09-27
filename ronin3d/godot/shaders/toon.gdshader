// Cel-shading: la luz se reparte en bandas planas, con brillo de borde.
shader_type spatial;
render_mode cull_back, specular_disabled;

uniform vec4 color : source_color = vec4(1.0);
uniform float destello = 0.0;          // 1 = blanco (golpe recibido)
uniform float emision = 0.0;           // para ventanas, fuego, etc.
uniform float fuerza_borde = 0.18;

void fragment() {
	vec3 base = mix(color.rgb, vec3(1.0), destello);
	ALBEDO = base;
	ROUGHNESS = 1.0;
	EMISSION = base * emision;
	float borde = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	EMISSION += base * borde * fuerza_borde;
}

void light() {
	float intensidad = dot(NORMAL, LIGHT);
	float banda = smoothstep(-0.05, 0.0, intensidad) * 0.45 + smoothstep(0.5, 0.55, intensidad) * 0.55;
	DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * ATTENUATION * banda;
}
