// Efecto maqueta (tilt-shift) y viñeta para la estética HD-2D:
// el centro queda nítido y la parte de arriba y de abajo se desenfocan.
shader_type canvas_item;

uniform sampler2D pantalla : hint_screen_texture, filter_linear;
uniform float fuerza = 2.2;            // radio del desenfoque en píxeles, en los bordes
uniform float banda_nitida = 0.2;      // media altura de la franja nítida
uniform float centro_y = 0.56;
uniform float vineta = 0.55;

void fragment() {
	vec2 uv = SCREEN_UV;
	float distancia = abs(uv.y - centro_y);
	float desenfoque = smoothstep(banda_nitida, 0.55, distancia) * fuerza;
	vec2 paso = SCREEN_PIXEL_SIZE * max(desenfoque, 0.0001);
	vec3 color = texture(pantalla, uv).rgb * 0.2;
	color += texture(pantalla, uv + vec2(paso.x, 0.0)).rgb * 0.1;
	color += texture(pantalla, uv - vec2(paso.x, 0.0)).rgb * 0.1;
	color += texture(pantalla, uv + vec2(0.0, paso.y)).rgb * 0.1;
	color += texture(pantalla, uv - vec2(0.0, paso.y)).rgb * 0.1;
	color += texture(pantalla, uv + paso * vec2(1.4, 1.4)).rgb * 0.1;
	color += texture(pantalla, uv + paso * vec2(-1.4, 1.4)).rgb * 0.1;
	color += texture(pantalla, uv + paso * vec2(1.4, -1.4)).rgb * 0.1;
	color += texture(pantalla, uv + paso * vec2(-1.4, -1.4)).rgb * 0.1;
	vec2 desde_centro = uv - vec2(0.5);
	color *= 1.0 - dot(desde_centro, desde_centro) * vineta;
	COLOR = vec4(color, 1.0);
}
