// Filtro de tinta para los cuadros de impacto y el corte de luna: convierte la imagen en
// tinta negra sobre papel (o al revés, con «invertir») y la mezcla con el color según
// «fuerza». Solo se dibuja mientras dura el efecto.
shader_type canvas_item;

uniform sampler2D pantalla : hint_screen_texture, filter_linear_mipmap;
uniform float fuerza : hint_range(0.0, 1.0) = 0.0;
uniform float invertir : hint_range(0.0, 1.0) = 0.0;
uniform float umbral = 0.11;
uniform vec3 papel : source_color = vec3(0.93, 0.9, 0.82);
uniform vec3 negro : source_color = vec3(0.04, 0.035, 0.05);

void fragment() {
	vec3 color = textureLod(pantalla, SCREEN_UV, 0.0).rgb;
	float luz = dot(color, vec3(0.299, 0.587, 0.114));
	float tinta = smoothstep(umbral - 0.025, umbral + 0.025, luz);
	tinta = mix(tinta, 1.0 - tinta, invertir);
	vec3 resultado = mix(negro, papel, tinta);
	COLOR = vec4(mix(color, resultado, fuerza), 1.0);
}
