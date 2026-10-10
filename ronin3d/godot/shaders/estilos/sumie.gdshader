// Estilo «sumi-e» (prueba de la DECISIÓN 20), en la línea de Ōkami: la imagen se vuelve aguadas de
// tinta sobre papel, con un poco del color de cada cosa, y los bordes se repasan con pincel. El
// filtro de Kuwahara «pinta» la imagen: aplana las zonas y conserva los bordes.
shader_type canvas_item;

uniform vec3 papel : source_color = vec3(0.93, 0.89, 0.8);
uniform vec3 tinta : source_color = vec3(0.1, 0.09, 0.1);
uniform vec3 bermellon : source_color = vec3(0.76, 0.2, 0.13);   // el rojo se queda, como un sello
uniform float exposicion = 1.7;
uniform float color_restante = 0.45;   // cuánto color queda en la aguada (0 = solo tinta)
uniform float paso = 1.5;              // separación de las muestras del filtro, en píxeles a 720

float luz(vec3 c) {
	return dot(c, vec3(0.299, 0.587, 0.114));
}

float ruido(vec2 x) {
	vec2 i = floor(x);
	vec2 f = fract(x);
	float a = fract(sin(dot(i, vec2(127.1, 311.7))) * 43758.5453);
	float b = fract(sin(dot(i + vec2(1.0, 0.0), vec2(127.1, 311.7))) * 43758.5453);
	float c = fract(sin(dot(i + vec2(0.0, 1.0), vec2(127.1, 311.7))) * 43758.5453);
	float d = fract(sin(dot(i + vec2(1.0, 1.0), vec2(127.1, 311.7))) * 43758.5453);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void fragment() {
	float escala = (1.0 / SCREEN_PIXEL_SIZE.y) / 720.0;
	vec2 p = TEXTURE_PIXEL_SIZE * paso * escala;
	// Kuwahara: de los cuatro cuadrantes, el color medio del que menos varía
	vec3 mejor_color = vec3(0.0);
	float mejor_varianza = 1e9;
	for (int cuadrante = 0; cuadrante < 4; cuadrante++) {
		vec2 sentido = vec2(cuadrante % 2 == 0 ? -1.0 : 1.0, cuadrante < 2 ? -1.0 : 1.0);
		vec3 suma = vec3(0.0);
		vec3 suma2 = vec3(0.0);
		for (int i = 0; i <= 2; i++) {
			for (int j = 0; j <= 2; j++) {
				vec3 m = texture(TEXTURE, UV + vec2(float(i), float(j)) * sentido * p).rgb;
				suma += m;
				suma2 += m * m;
			}
		}
		vec3 media = suma / 9.0;
		vec3 varianza = suma2 / 9.0 - media * media;
		float v = varianza.r + varianza.g + varianza.b;
		if (v < mejor_varianza) {
			mejor_varianza = v;
			mejor_color = media;
		}
	}
	// Densidad de tinta según la luz, en tres o cuatro aguadas que se notan
	float l = clamp(luz(mejor_color) * exposicion, 0.0, 1.0);
	float densidad = 1.0 - l;
	densidad = mix(densidad, floor(densidad * 4.0 + 0.5) / 4.0, 0.5);
	// El tono de la aguada: tinta con algo del color original (sin su oscuridad)
	// (los colores apagados, como el pelo negro, se quedan en tinta pura)
	float maximo = max(mejor_color.r, max(mejor_color.g, mejor_color.b));
	float saturacion = (maximo - min(mejor_color.r, min(mejor_color.g, mejor_color.b))) / max(maximo, 0.001);
	vec3 tono = mejor_color / max(maximo, 0.001);
	float con_color = smoothstep(0.25, 0.5, saturacion) * smoothstep(0.15, 0.35, maximo);
	vec3 pigmento = mix(tinta, tinta + (tono - 0.5) * 0.9, color_restante * con_color);
	vec3 resultado = mix(papel, clamp(pigmento, 0.0, 1.0), densidad * 0.92);
	// Bordes repasados con pincel
	vec2 q = TEXTURE_PIXEL_SIZE * 1.2 * escala;
	float gx = luz(texture(TEXTURE, UV + vec2(q.x, 0.0)).rgb) - luz(texture(TEXTURE, UV - vec2(q.x, 0.0)).rgb);
	float gy = luz(texture(TEXTURE, UV + vec2(0.0, q.y)).rgb) - luz(texture(TEXTURE, UV - vec2(0.0, q.y)).rgb);
	float borde = smoothstep(0.04, 0.14, length(vec2(gx, gy)) * exposicion);
	resultado = mix(resultado, tinta, borde * 0.9);
	// El rojo (cintas, armaduras, la cicatriz) se queda en bermellón, como en el manga de tinta
	float es_rojo = smoothstep(0.5, 0.65, saturacion) * step(0.999, tono.r) * step(max(tono.g, tono.b), 0.55)
		* smoothstep(0.08, 0.16, maximo);
	resultado = mix(resultado, bermellon * mix(0.75, 1.05, l), es_rojo * (1.0 - borde));
	// El papel: grano fino y algo de fibra, sin rayas
	vec2 pantalla = FRAGCOORD.xy / escala;
	float grano = ruido(pantalla * 0.45) * 0.6 + ruido(pantalla * 0.07) * 0.4;
	resultado *= 0.94 + 0.08 * grano;
	COLOR = vec4(resultado, 1.0);
}
