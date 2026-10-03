// Lo que se ve por la ventana del relojero: Londres de noche entre la niebla. Tejados y chimeneas,
// alguna ventana encendida, el resplandor de las farolas de gas y la lluvia en el cristal.
shader_type spatial;
render_mode unshaded, cull_back;

float azar(float x) {
	return fract(sin(x * 127.1) * 43758.5453);
}

float azar2(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	float y = 1.0 - uv.y;
	vec3 cielo = mix(vec3(0.13, 0.12, 0.14), vec3(0.03, 0.035, 0.06), smoothstep(0.25, 0.95, y));
	vec3 color = cielo;
	// dos filas de tejados: la de atrás más clara (niebla) y la de delante más oscura
	for (int fila = 0; fila < 2; fila++) {
		float f = float(fila);
		float ancho = 7.0 + f * 5.0;
		float celda = floor(uv.x * ancho + f * 3.7);
		float alto = 0.36 + azar(celda + f * 17.0) * 0.16 - f * 0.12;
		float dentro = fract(uv.x * ancho + f * 3.7);
		float chimenea = step(0.62, dentro) * step(dentro, 0.74) * step(0.45, azar(celda + 5.0 + f)) * 0.05;
		float borde = alto + chimenea;
		if (y < borde) {
			vec3 casa = mix(vec3(0.07, 0.07, 0.08), vec3(0.02, 0.02, 0.025), f);
			// ventanas encendidas
			vec2 v = vec2(fract(uv.x * ancho * 4.0 + f), fract(y * 22.0));
			float hueco = step(0.3, v.x) * step(v.x, 0.7) * step(0.25, v.y) * step(v.y, 0.75);
			float encendida = step(0.82, azar2(vec2(floor(uv.x * ancho * 4.0 + f), floor(y * 22.0)) + f * 9.0));
			casa += vec3(0.9, 0.62, 0.3) * hueco * encendida * (0.35 + 0.25 * f) * step(y, borde - 0.03);
			color = casa;
		}
	}
	// niebla que sube desde abajo
	color = mix(color, vec3(0.2, 0.19, 0.2), smoothstep(0.55, 0.0, y) * 0.55);
	// farolas de gas: resplandores cálidos abajo
	for (int k = 0; k < 3; k++) {
		vec2 farola = vec2(0.18 + float(k) * 0.33, 0.83);
		float d = length((uv - farola) * vec2(1.6, 1.0));
		color += vec3(1.0, 0.7, 0.35) * (smoothstep(0.22, 0.0, d) * 0.35 + smoothstep(0.02, 0.0, d) * 1.5);
	}
	// lluvia y gotas en el cristal
	vec2 l = vec2(uv.x * 70.0 + uv.y * 8.0, uv.y * 3.0 - TIME * 2.4);
	float raya = step(0.94, azar2(floor(vec2(l.x, l.y * 6.0)))) * smoothstep(0.5, 0.0, abs(fract(l.x) - 0.5));
	color += vec3(0.4, 0.42, 0.5) * raya * 0.25;
	vec2 g = uv * vec2(16.0, 22.0);
	vec2 celda_gota = floor(g);
	vec2 centro = vec2(azar2(celda_gota), azar2(celda_gota + 7.0));
	float gota = smoothstep(0.18, 0.05, length(fract(g) - centro)) * step(0.72, azar2(celda_gota + 3.0));
	color = mix(color, color * 0.6 + vec3(0.08, 0.08, 0.09), gota * 0.6);
	ALBEDO = color;
}
