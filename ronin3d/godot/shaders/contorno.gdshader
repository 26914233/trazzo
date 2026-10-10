// Contorno negro por «casco invertido»: se dibuja la cara de atrás un poco inflada.
// El grosor se da en metros, pero en pantalla se queda entre «minimo_px» y «maximo_px» (en una
// pantalla de 720 de alto; en otras, en proporción): de lejos la línea no desaparece y de cerca no
// se vuelve un borrón. Así se parece al trazo de un dibujo, que tiene casi el mismo grosor a
// cualquier distancia.
shader_type spatial;
render_mode unshaded, cull_front, depth_draw_opaque, shadows_disabled;

uniform vec4 color : source_color = vec4(0.05, 0.04, 0.07, 1.0);
uniform float grosor = 0.025;
uniform bool por_normal = true;        // false para cajas: se infla desde el centro
// Metros que el casco se aleja de la cámara. En los modelos detallados (muchas curvas y
// huecos) evita que el casco asome por delante de la piel como manchas negras: así solo se ve
// en la silueta. 0 = sin empuje (piezas y escenario).
uniform float empuje = 0.0;
uniform float minimo_px = 1.3;
uniform float maximo_px = 3.5;

void vertex() {
	vec3 direccion = por_normal ? NORMAL : normalize(VERTEX) * 1.4;
	// Se calcula la posición a mano: si POSITION se escribe solo en un caso, Godot deja de
	// transformar los vértices en el otro y el contorno desaparece.
	vec4 vista = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec3 inflado = (MODELVIEW_MATRIX * vec4(direccion * grosor, 0.0)).xyz;
	float w = (PROJECTION_MATRIX * vista).w;
	// abs: el renderizador Compatibility da la vuelta a la imagen y ese término sale negativo
	float px_por_metro = 0.5 * VIEWPORT_SIZE.y * abs(PROJECTION_MATRIX[1][1]) / max(w, 0.001);
	float px = length(inflado) * px_por_metro;
	float escala = VIEWPORT_SIZE.y / 720.0;
	float limitado = clamp(px, minimo_px * escala, maximo_px * escala);
	vista.xyz += inflado * (limitado / max(px, 0.0001));
	if (empuje > 0.0) {
		vista.xyz += normalize(vista.xyz) * empuje;
	}
	POSITION = PROJECTION_MATRIX * vista;
}

void fragment() {
	ALBEDO = color.rgb;
}
