// La cara dibujada (recursos/caras/) con la luz normal de Godot, sin cel-shading: es la que usa el
// estilo «3D realista» de la prueba de estilos (scripts/estilos_render.gd).
shader_type spatial;
render_mode cull_back;

uniform vec4 color : source_color = vec4(1.0);
uniform sampler2D rasgos : source_color, filter_linear_mipmap, repeat_disable;
uniform mat4 a_cabeza;
uniform vec4 recuadro = vec4(-0.12, 0.11, 0.24, 0.24);

varying vec3 posicion_cabeza;

void vertex() {
	posicion_cabeza = (a_cabeza * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 uv = vec2((posicion_cabeza.x - recuadro.x) / recuadro.z, (recuadro.y - posicion_cabeza.y) / recuadro.w);
	vec4 rasgo = texture(rasgos, uv);
	float dentro = step(0.0, uv.x) * step(uv.x, 1.0) * step(0.0, uv.y) * step(uv.y, 1.0);
	rasgo.a *= dentro * smoothstep(0.0, 0.04, posicion_cabeza.z);
	ALBEDO = mix(color.rgb, rasgo.rgb, rasgo.a);
	ROUGHNESS = 0.65;
	SPECULAR = 0.35;
}
