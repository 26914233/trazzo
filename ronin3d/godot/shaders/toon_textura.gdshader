// Cel-shading para modelos detallados (con textura): la textura da el color y la luz va en
// bandas, como en el resto del juego. Añade lo que hace falta para los rangos:
//   alfa (variante fuerte): grietas de lava (o del color del elemento) que laten
//   silenciada: sin color, blanca y gris
shader_type spatial;
render_mode cull_back, specular_disabled;

uniform sampler2D textura : source_color, hint_default_white, filter_linear_mipmap;
uniform vec4 tinte : source_color = vec4(1.0);
uniform float saturacion = 1.0;          // 1 normal · >1 más vivo (alfa) · 0 gris (silenciada)
uniform float destello = 0.0;            // 1 = blanco (golpe recibido)
uniform float emision = 0.0;
uniform float fuerza_borde = 0.18;
// Brillo propio: lo que en la textura se parece a este color brilla (ojos, llamas, joyas)
uniform vec4 color_brillo : source_color = vec4(1.0, 0.85, 0.2, 1.0);
uniform float fuerza_brillo = 0.0;
// Grietas de lava procedurales (variante fuerte)
uniform vec4 color_grietas : source_color = vec4(1.0, 0.42, 0.08, 1.0);
uniform float fuerza_grietas = 0.0;
uniform float escala_grietas = 8.0;
uniform float ancho_grietas = 0.07;
uniform float oscurecer = 0.0;           // 0..1: la piel se vuelve roca oscura entre las grietas
uniform float velocidad_pulso = 2.2;

varying vec3 posicion_objeto;

void vertex() {
	posicion_objeto = VERTEX;
}

vec3 azar3(vec3 p) {
	p = vec3(dot(p, vec3(127.1, 311.7, 74.7)), dot(p, vec3(269.5, 183.3, 246.1)),
		dot(p, vec3(113.5, 271.9, 124.6)));
	return fract(sin(p) * 43758.5453);
}

// Distancia a la arista más cercana de unas celdas (Voronoi): pequeña sobre las grietas
float arista(vec3 p) {
	vec3 celda = floor(p);
	vec3 resto = fract(p);
	float d1 = 8.0;
	float d2 = 8.0;
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			for (int z = -1; z <= 1; z++) {
				vec3 vecina = vec3(float(x), float(y), float(z));
				vec3 r = vecina + azar3(celda + vecina) - resto;
				float d = dot(r, r);
				if (d < d1) {
					d2 = d1;
					d1 = d;
				} else if (d < d2) {
					d2 = d;
				}
			}
		}
	}
	return sqrt(d2) - sqrt(d1);
}

void fragment() {
	vec3 t = texture(textura, UV).rgb;
	float gris = dot(t, vec3(0.299, 0.587, 0.114));
	vec3 base = mix(vec3(gris), t, saturacion) * tinte.rgb;
	float latido = 0.75 + 0.25 * sin(TIME * velocidad_pulso);
	vec3 brillo = vec3(0.0);
	if (fuerza_grietas > 0.0) {
		// Se deforma el espacio para que las placas no salgan regulares, y el grosor varía
		vec3 q = posicion_objeto * escala_grietas;
		q += 0.45 * vec3(sin(q.y * 0.9 + 1.3) + sin(q.z * 1.7), sin(q.z * 1.1 + 0.7) + sin(q.x * 1.3),
			sin(q.x * 0.8 + 2.1) + sin(q.y * 1.9));
		float a = arista(q);
		float ancho = ancho_grietas * (0.45 + 0.9 * (0.5 + 0.5 * sin(q.x * 0.7 + q.y * 1.3 + q.z * 0.5)));
		float linea = 1.0 - smoothstep(0.0, ancho, a);
		float halo = 1.0 - smoothstep(0.0, ancho * 3.5, a);
		base = mix(base, base * 0.35, oscurecer * (1.0 - linea));
		brillo += color_grietas.rgb * (linea * 2.2 + halo * 0.35) * fuerza_grietas * latido;
	}
	if (fuerza_brillo > 0.0) {
		float parecido = 1.0 - clamp(distance(t, color_brillo.rgb) * 1.8, 0.0, 1.0);
		brillo += color_brillo.rgb * smoothstep(0.55, 0.9, parecido) * fuerza_brillo * latido;
	}
	base = mix(base, vec3(1.0), destello);
	ALBEDO = base;
	ROUGHNESS = 1.0;
	EMISSION = base * emision + brillo;
	float borde = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	EMISSION += base * borde * fuerza_borde;
}

void light() {
	float intensidad = dot(NORMAL, LIGHT);
	float banda = smoothstep(-0.05, 0.0, intensidad) * 0.45 + smoothstep(0.5, 0.55, intensidad) * 0.55;
	DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * ATTENUATION * banda;
}
