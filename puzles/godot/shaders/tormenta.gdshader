// Lo que se ve por la ventana del faro: cielo de tormenta, mar oscuro con olas, la luz lejana de un
// barco que se acerca, lluvia que cae en diagonal y gotas en el cristal. «destello» ilumina el cielo
// cuando cae un rayo.
shader_type spatial;
render_mode unshaded, cull_back;

uniform float destello = 0.0;
uniform float horizonte = 0.56;
uniform vec2 barco = vec2(0.68, 0.585);

float azar(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float ruido(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(azar(i), azar(i + vec2(1.0, 0.0)), f.x), mix(azar(i + vec2(0.0, 1.0)), azar(i + vec2(1.0, 1.0)), f.x), f.y);
}

void fragment() {
	vec2 uv = UV;
	float y = 1.0 - uv.y;
	vec3 color;
	if (y > 1.0 - horizonte) {
		float nubes = ruido(vec2(uv.x * 3.0 + TIME * 0.02, y * 5.0)) * 0.6 + ruido(vec2(uv.x * 9.0 - TIME * 0.05, y * 14.0)) * 0.4;
		color = mix(vec3(0.03, 0.04, 0.06), vec3(0.09, 0.11, 0.15), nubes);
		color += vec3(0.55, 0.62, 0.8) * destello * (0.6 + nubes);
	} else {
		float ola = sin(uv.x * 40.0 + TIME * 1.3 + sin(y * 30.0) * 2.0) * 0.5 + 0.5;
		color = mix(vec3(0.008, 0.015, 0.025), vec3(0.03, 0.05, 0.07), ola * smoothstep(0.0, 1.0 - horizonte, y));
		color += vec3(0.25, 0.3, 0.4) * destello * 0.4;
	}
	// luz del barco, que parpadea con el oleaje
	float distancia = length((uv - barco) * vec2(1.0, 1.6));
	color += vec3(1.0, 0.8, 0.45) * smoothstep(0.012, 0.0, distancia) * (0.6 + 0.4 * sin(TIME * 2.3));
	// lluvia: rayas finas en diagonal que caen
	vec2 l = vec2(uv.x * 60.0 + uv.y * 12.0, uv.y * 3.0 - TIME * 2.6);
	float raya = step(0.93, azar(floor(vec2(l.x, l.y * 6.0)))) * smoothstep(0.5, 0.0, abs(fract(l.x) - 0.5));
	color += vec3(0.35, 0.4, 0.5) * raya * 0.35;
	// gotas en el cristal
	vec2 g = uv * vec2(18.0, 24.0);
	vec2 celda = floor(g);
	vec2 centro = vec2(azar(celda), azar(celda + 7.0));
	float gota = smoothstep(0.18, 0.05, length(fract(g) - centro)) * step(0.7, azar(celda + 3.0));
	color = mix(color, color * 0.6 + vec3(0.06, 0.07, 0.09), gota * 0.6);
	ALBEDO = color;
}
