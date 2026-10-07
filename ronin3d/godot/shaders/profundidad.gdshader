// Desenfoque de profundidad al estilo HD-2D («tilt-shift»), como en la referencia del usuario: lo de
// arriba de la pantalla (lo lejano) y un poco lo de abajo se desenfocan, y la franja donde están
// Akira y el combate queda nítida. El renderizador Compatibility no tiene profundidad de campo,
// así que se decide por la altura en la pantalla. Va en una capa por debajo del HUD.
shader_type canvas_item;

uniform sampler2D pantalla : hint_screen_texture, filter_linear;
uniform float fuerza = 1.0;
uniform float radio = 3.5;             // píxeles (a 720 de alto) en el borde de arriba
uniform float centro = 0.6;            // altura de la franja nítida (0 arriba, 1 abajo)
uniform float ancho = 0.2;             // media altura de la franja nítida

const vec2 DISCO[8] = {
	vec2(1.0, 0.0), vec2(0.707, 0.707), vec2(0.0, 1.0), vec2(-0.707, 0.707),
	vec2(-1.0, 0.0), vec2(-0.707, -0.707), vec2(0.0, -1.0), vec2(0.707, -0.707)
};

void fragment() {
	float distancia = abs(SCREEN_UV.y - centro);
	// abajo (lo cercano) se desenfoca la mitad que arriba
	float lado = SCREEN_UV.y < centro ? 1.0 : 0.5;
	float desenfoque = smoothstep(ancho, ancho + 0.32, distancia) * fuerza * lado;
	vec4 color = texture(pantalla, SCREEN_UV);
	if (desenfoque > 0.01) {
		float escala = (1.0 / SCREEN_PIXEL_SIZE.y) / 720.0;
		vec2 paso = SCREEN_PIXEL_SIZE * radio * escala * desenfoque;
		vec4 suma = color;
		for (int i = 0; i < 8; i++) {
			suma += texture(pantalla, SCREEN_UV + DISCO[i] * paso);
			suma += texture(pantalla, SCREEN_UV + DISCO[i] * paso * 0.5);
		}
		color = suma / 17.0;
	}
	COLOR = vec4(color.rgb, 1.0);
}
