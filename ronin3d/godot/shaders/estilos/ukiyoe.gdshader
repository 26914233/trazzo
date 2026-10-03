// Estilo «ukiyo-e» (prueba de la DECISIÓN 20): estampa japonesa de madera. Cada color pasa al
// pigmento más parecido de una paleta corta (añil, bermellón, ocre, sumi…), sobre papel washi.
// Va con luz plana en los materiales y la línea del cel-shading algo más gruesa.
shader_type canvas_item;

uniform float exposicion = 1.45;

const vec3 PALETA[11] = {
	vec3(0.1, 0.09, 0.1),      // sumi (negro de tinta)
	vec3(0.13, 0.17, 0.3),     // añil oscuro
	vec3(0.2, 0.3, 0.48),      // azul de Prusia
	vec3(0.42, 0.5, 0.62),     // azul grisáceo
	vec3(0.72, 0.22, 0.15),    // bermellón
	vec3(0.45, 0.16, 0.13),    // rojo oscuro
	vec3(0.8, 0.62, 0.34),     // ocre
	vec3(0.42, 0.3, 0.2),      // marrón
	vec3(0.88, 0.75, 0.6),     // carne
	vec3(0.48, 0.52, 0.38),    // verde salvia
	vec3(0.93, 0.89, 0.78)     // papel
};

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
	vec3 c = clamp(texture(TEXTURE, UV).rgb * exposicion, 0.0, 1.0);
	float mejor = 1e9;
	vec3 elegido = c;
	for (int i = 0; i < 11; i++) {
		vec3 diferencia = (c - PALETA[i]) * vec3(1.0, 1.25, 0.8);
		float distancia = dot(diferencia, diferencia);
		if (distancia < mejor) {
			mejor = distancia;
			elegido = PALETA[i];
		}
	}
	float escala = (1.0 / SCREEN_PIXEL_SIZE.y) / 720.0;
	vec2 pantalla = FRAGCOORD.xy / escala;
	float fibras = ruido(pantalla * vec2(0.03, 0.4)) * 0.6 + ruido(pantalla * 0.5) * 0.4;
	COLOR = vec4(elegido * (0.92 + 0.1 * fibras), 1.0);
}
