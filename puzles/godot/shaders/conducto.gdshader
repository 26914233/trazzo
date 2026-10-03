// Surco de luz de la reliquia: tenue cuando está apagado y, al llegar la luz, se llena desde la
// entrada hasta la salida (relleno de 0 a 1) con un pulso que corre por dentro.
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque;

uniform vec4 color : source_color = vec4(0.3, 0.9, 1.0, 1.0);
uniform float relleno = 0.0;
uniform float base = 0.12;
uniform float fuerza = 2.6;

void fragment() {
	float t = UV.x;
	float encendido = smoothstep(relleno + 0.02, relleno - 0.02, t);
	float pulso = 0.65 + 0.35 * sin(TIME * 7.0 - t * 14.0);
	float centro = 1.0 - abs(UV.y - 0.5) * 2.0;
	vec3 luz = color.rgb * (base + encendido * fuerza * pulso) * (0.35 + 0.65 * centro);
	ALBEDO = luz;
}
