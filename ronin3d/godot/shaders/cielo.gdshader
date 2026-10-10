// Cielo nocturno: degradado, estrellas que titilan y luna con halo.
shader_type sky;

uniform vec3 color_arriba : source_color = vec3(0.024, 0.031, 0.102);
uniform vec3 color_horizonte : source_color = vec3(0.165, 0.141, 0.298);
uniform vec3 color_suelo : source_color = vec3(0.03, 0.03, 0.05);
uniform vec3 direccion_luna = vec3(-0.35, 0.5, -0.8);
uniform float tamano_luna = 0.05;
uniform vec3 tinte_luna : source_color = vec3(1.0, 1.0, 1.0);   // la luna roja de los capítulos siguientes

float azar(vec3 p) {
	p = fract(p * 0.3183099 + 0.1);
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

void sky() {
	vec3 direccion = normalize(EYEDIR);
	float altura = clamp(direccion.y, 0.0, 1.0);
	vec3 color = mix(color_horizonte, color_arriba, pow(altura, 0.55));
	if (direccion.y < 0.0) {
		color = mix(color_horizonte, color_suelo, clamp(-direccion.y * 6.0, 0.0, 1.0));
	}

	// Estrellas: la esfera se divide en celdas; en unas pocas hay un punto pequeño que titila.
	vec3 punto = direccion * 260.0;
	vec3 celda = floor(punto);
	float valor = azar(celda);
	vec3 dentro = fract(punto) - 0.5;
	float nitidez = 1.0 - smoothstep(0.08, 0.3, length(dentro));
	float estrella = step(0.985, valor) * nitidez * smoothstep(0.02, 0.25, direccion.y);
	color += vec3(0.85, 0.88, 1.0) * estrella * (0.6 + 0.4 * sin(TIME * 2.3 + valor * 60.0));

	// Luna: disco con manchas y halo.
	vec3 luna = normalize(direccion_luna);
	float distancia = distance(direccion, luna);
	float disco = 1.0 - smoothstep(tamano_luna - 0.003, tamano_luna, distancia);
	vec3 local = (direccion - luna) / tamano_luna;
	float manchas = smoothstep(0.35, 0.3, length(local.xy - vec2(-0.3, 0.2)))
		+ smoothstep(0.28, 0.22, length(local.xy - vec2(0.35, -0.25)))
		+ smoothstep(0.18, 0.13, length(local.xy - vec2(0.1, 0.5)));
	vec3 color_luna = mix(vec3(0.98, 0.95, 0.84), vec3(0.86, 0.82, 0.7), clamp(manchas, 0.0, 1.0));
	color += vec3(0.32, 0.33, 0.42) * tinte_luna * exp(-distancia * 9.0) * 0.55;
	color = mix(color, color_luna * tinte_luna * 1.6, disco);

	COLOR = color;
}
