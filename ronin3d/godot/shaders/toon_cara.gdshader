// Cel-shading de las caras: como toon.gdshader con luz plana, y encima los rasgos (ojos, cejas,
// nariz, boca) dibujados en una imagen 2D que se proyecta desde delante, como en los juegos de
// anime en 3D. La imagen sale de recursos/caras/generar_caras.py: su alfa dice dónde hay rasgo
// y el resto es el color de la piel.
shader_type spatial;
render_mode cull_back, specular_disabled;

uniform vec4 color : source_color = vec4(1.0);
uniform float destello = 0.0;          // 1 = blanco (golpe recibido)
uniform float emision = 0.0;
uniform float fuerza_borde = 0.18;
uniform float plano = 1.0;             // 1 = luz plana, sin la banda de sombra
uniform sampler2D rasgos : source_color, filter_linear_mipmap, repeat_disable;
// De la malla al espacio de la cabeza (la cara y el mentón son mallas distintas con la misma
// imagen), y el recuadro de la cara que cubre la imagen: x izquierda, y arriba, ancho y alto.
uniform mat4 a_cabeza;
uniform vec4 recuadro = vec4(-0.12, 0.11, 0.24, 0.24);

varying vec3 posicion_cabeza;

void vertex() {
	posicion_cabeza = (a_cabeza * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 uv = vec2((posicion_cabeza.x - recuadro.x) / recuadro.z, (recuadro.y - posicion_cabeza.y) / recuadro.w);
	vec4 rasgo = texture(rasgos, uv);
	// Solo por delante: la proyección atraviesa la cabeza y saldría también en la nuca.
	float dentro = step(0.0, uv.x) * step(uv.x, 1.0) * step(0.0, uv.y) * step(uv.y, 1.0);
	rasgo.a *= dentro * smoothstep(0.0, 0.04, posicion_cabeza.z);
	vec3 base = mix(color.rgb, rasgo.rgb, rasgo.a);
	base = mix(base, vec3(1.0), destello);
	ALBEDO = base;
	ROUGHNESS = 1.0;
	EMISSION = base * emision;
	float borde = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	EMISSION += base * borde * fuerza_borde;
}

void light() {
	float intensidad = dot(NORMAL, LIGHT);
	float banda = smoothstep(-0.05, 0.0, intensidad) * 0.45 + smoothstep(0.5, 0.55, intensidad) * 0.55;
	banda = mix(banda, 0.8, plano);
	DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * ATTENUATION * banda;
}
