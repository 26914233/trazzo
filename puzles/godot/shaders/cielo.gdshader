// Fondo de los prototipos: un degradado con nubes de tinta y un resplandor hacia la fuente de luz
// (farol, lámpara, nebulosa). Sin TIME, para que el reflejo del cielo se calcule una sola vez.
shader_type sky;

uniform vec3 arriba : source_color = vec3(0.02, 0.025, 0.06);
uniform vec3 horizonte : source_color = vec3(0.09, 0.07, 0.12);
uniform vec3 abajo : source_color = vec3(0.01, 0.01, 0.02);
uniform vec3 resplandor : source_color = vec3(0.5, 0.25, 0.12);
uniform vec3 direccion_resplandor = vec3(-0.6, 0.3, 0.7);
uniform float apertura = 6.0;
uniform float nubes = 0.35;
uniform vec3 color_nubes : source_color = vec3(0.16, 0.14, 0.2);
uniform float estrellas = 0.0;

float azar(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float ruido(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(azar(i), azar(i + vec2(1.0, 0.0)), f.x), mix(azar(i + vec2(0.0, 1.0)), azar(i + vec2(1.0, 1.0)), f.x), f.y);
}

float fbm(vec2 p) {
	float suma = 0.0;
	float peso = 0.5;
	for (int i = 0; i < 5; i++) {
		suma += ruido(p) * peso;
		p *= 2.03;
		peso *= 0.5;
	}
	return suma;
}

void sky() {
	vec3 d = EYEDIR;
	float h = d.y;
	vec3 color = mix(horizonte, arriba, smoothstep(0.0, 0.75, h));
	color = mix(color, abajo, smoothstep(0.0, -0.6, h));
	float brillo = pow(max(dot(d, normalize(direccion_resplandor)), 0.0), apertura);
	color += resplandor * brillo;
	vec2 plano = d.xz / (abs(d.y) + 0.35);
	float n = fbm(plano * 1.6 + vec2(3.1, 7.7));
	color = mix(color, color_nubes, smoothstep(0.48, 0.82, n) * nubes);
	if (estrellas > 0.0) {
		// estrellas pequeñas: un punto suave dentro de cada celda, solo en algunas
		vec2 coordenada = d.xz / (abs(d.y) + 0.6) * 220.0;
		vec2 celda = floor(coordenada);
		vec2 dentro = fract(coordenada) - 0.5;
		float hay = step(0.992, azar(celda));
		float punto = smoothstep(0.18, 0.0, length(dentro));
		color += vec3(hay * punto * smoothstep(0.05, 0.35, h)) * estrellas * (0.5 + azar(celda + 3.0));
	}
	COLOR = color;
}
