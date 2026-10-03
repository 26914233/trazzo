// Estilo «manga de tinta» (prueba de la DECISIÓN 20): la imagen del juego pasa a tinta negra sobre
// papel, con trama de puntos en los medios tonos, líneas en los bordes y el rojo como único color
// (el acento de la DECISIÓN 18A). Se aplica al SubViewportContainer que dibuja el mundo 3D.
shader_type canvas_item;

uniform vec3 papel : source_color = vec3(0.94, 0.91, 0.84);
uniform vec3 tinta : source_color = vec3(0.07, 0.06, 0.08);
uniform vec3 rojo : source_color = vec3(0.78, 0.13, 0.11);
uniform float exposicion = 3.0;        // la noche es oscura: se aclara antes de decidir los tonos
uniform float umbral_negro = 0.1;
uniform float umbral_papel = 0.62;
uniform float trama = 4.0;             // separación de los puntos de la trama, en píxeles a 720
uniform float bordes = 1.0;

float luz(vec3 c) {
	return dot(c, vec3(0.299, 0.587, 0.114));
}

vec3 a_hsv(vec3 c) {
	vec4 k = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, k.wz), vec4(c.gb, k.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + 1e-5)), d / (q.x + 1e-5), q.x);
}

void fragment() {
	vec2 p = TEXTURE_PIXEL_SIZE;
	vec3 c = texture(TEXTURE, UV).rgb;
	float a = luz(texture(TEXTURE, UV + p * vec2(-1.0, -1.0)).rgb);
	float b = luz(texture(TEXTURE, UV + p * vec2(0.0, -1.0)).rgb);
	float d = luz(texture(TEXTURE, UV + p * vec2(1.0, -1.0)).rgb);
	float e = luz(texture(TEXTURE, UV + p * vec2(-1.0, 0.0)).rgb);
	float f = luz(texture(TEXTURE, UV + p * vec2(1.0, 0.0)).rgb);
	float g = luz(texture(TEXTURE, UV + p * vec2(-1.0, 1.0)).rgb);
	float h = luz(texture(TEXTURE, UV + p * vec2(0.0, 1.0)).rgb);
	float k = luz(texture(TEXTURE, UV + p * vec2(1.0, 1.0)).rgb);
	float gx = (d + 2.0 * f + k) - (a + 2.0 * e + g);
	float gy = (g + 2.0 * h + k) - (a + 2.0 * b + d);
	float borde = smoothstep(0.12, 0.32, length(vec2(gx, gy)) * exposicion) * bordes;
	float l = clamp(luz(c) * exposicion, 0.0, 1.0);
	// Trama de puntos girada 45°: en la sombra los puntos crecen hasta juntarse
	float escala = (1.0 / SCREEN_PIXEL_SIZE.y) / 720.0;
	vec2 celda = FRAGCOORD.xy / (trama * escala);
	celda = vec2(celda.x + celda.y, celda.x - celda.y) * 0.7071;
	float distancia = length(fract(celda) - 0.5);
	float radio = mix(0.62, 0.0, smoothstep(umbral_negro, umbral_papel, l));
	float punto = 1.0 - smoothstep(radio - 0.07, radio + 0.07, distancia);
	float valor = l < umbral_negro ? 0.0 : 1.0 - punto;
	valor = min(valor, 1.0 - borde);
	vec3 resultado = mix(tinta, papel, valor);
	// El rojo (cintas, armaduras de los soldados, la cicatriz) se queda: es el acento
	vec3 hsv = a_hsv(c);
	float tono_rojo = 1.0 - smoothstep(0.03, 0.06, min(hsv.x, 1.0 - hsv.x));
	float es_rojo = tono_rojo * smoothstep(0.4, 0.55, hsv.y) * smoothstep(0.04, 0.1, hsv.z);
	resultado = mix(resultado, rojo * mix(0.6, 1.1, l), es_rojo * (1.0 - borde * 0.8));
	float grano = fract(sin(dot(floor(FRAGCOORD.xy), vec2(12.9898, 78.233))) * 43758.5453);
	COLOR = vec4(resultado * (0.95 + 0.05 * grano), 1.0);
}
