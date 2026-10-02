# Menú: las cuatro piezas en tarjetas, cada una con su frase y, si ya se jugó, el mejor tiempo.
extends Control

signal elegido(id: String)

const Catalogo := preload("res://scripts/catalogo.gd")
const Estilo := preload("res://scripts/estilo.gd")

var resultados: ConfigFile
var tarjetas := {}                    # id -> Button (lo usa la prueba automática)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = Estilo.tema(Color(0.85, 0.7, 0.45))
	var fondo := ColorRect.new()
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fondo.material = _material_fondo()
	add_child(fondo)

	var margen := MarginContainer.new()
	margen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for lado in ["left", "right"]:
		margen.add_theme_constant_override("margin_" + lado, 56)
	margen.add_theme_constant_override("margin_top", 34)
	margen.add_theme_constant_override("margin_bottom", 26)
	add_child(margen)
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 14)
	margen.add_child(columna)

	columna.add_child(Estilo.etiqueta("Cuatro cajas", 54, Estilo.TEXTO, Estilo.FUENTE_NEGRITA))
	columna.add_child(Estilo.etiqueta(
		"Prototipos para probar. Juega los cuatro y fíjate en cuál te dan ganas de seguir.",
		24, Estilo.TEXTO_SUAVE, Estilo.FUENTE_CURSIVA))

	var rejilla := GridContainer.new()
	rejilla.columns = 2
	rejilla.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rejilla.add_theme_constant_override("h_separation", 22)
	rejilla.add_theme_constant_override("v_separation", 18)
	columna.add_child(rejilla)
	for datos in Catalogo.PROTOTIPOS:
		rejilla.add_child(_tarjeta(datos))

	var pie := Estilo.etiqueta(Catalogo.VERSION + "  ·  al terminar, apunta tu tiempo y las pistas que usaste",
		18, Color(0.6, 0.57, 0.52))
	pie.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	columna.add_child(pie)


func _tarjeta(datos: Dictionary) -> Control:
	var acento: Color = datos.acento
	var boton := Button.new()
	boton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	boton.size_flags_vertical = Control.SIZE_EXPAND_FILL
	boton.custom_minimum_size = Vector2(300, 150)
	boton.theme = Estilo.tema(acento)
	boton.pressed.connect(func(): elegido.emit(datos.id))
	tarjetas[datos.id] = boton

	# portada del prototipo de fondo, oscurecida hacia la izquierda para que se lea el texto
	var ruta_portada := "res://recursos/portadas/%s.png" % datos.id
	if ResourceLoader.exists(ruta_portada):
		var portada := TextureRect.new()
		portada.texture = load(ruta_portada)
		portada.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portada.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		portada.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		for lado in ["left", "top"]:
			portada.set("offset_" + lado, 3)
		for lado in ["right", "bottom"]:
			portada.set("offset_" + lado, -3)
		portada.mouse_filter = Control.MOUSE_FILTER_IGNORE
		portada.clip_contents = true
		boton.add_child(portada)
		var sombra := ColorRect.new()
		sombra.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		sombra.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sombra.material = _material_sombra()
		boton.add_child(sombra)
	var margen := MarginContainer.new()
	margen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for lado in ["left", "right", "top", "bottom"]:
		margen.add_theme_constant_override("margin_" + lado, 22)
	margen.add_theme_constant_override("margin_right", 200)
	boton.add_child(margen)
	var columna := VBoxContainer.new()
	columna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.add_theme_constant_override("separation", 6)
	margen.add_child(columna)

	var titulo := Estilo.etiqueta(datos.titulo, 34, acento.lightened(0.25), Estilo.FUENTE_NEGRITA)
	titulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.add_child(titulo)
	var frase := Estilo.etiqueta(datos.frase, 22, Estilo.TEXTO)
	frase.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	frase.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frase.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.add_child(frase)
	var marca := Estilo.etiqueta(_texto_resultado(datos.id), 19, Estilo.TEXTO_SUAVE, Estilo.FUENTE_CURSIVA)
	marca.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.add_child(marca)
	return boton


func _texto_resultado(id: String) -> String:
	if resultados == null or not resultados.has_section(id):
		return "Sin jugar"
	var mejor: float = resultados.get_value(id, "mejor_tiempo", INF)
	var pistas: int = resultados.get_value(id, "pistas_mejor", 0)
	return "Abierta · mejor tiempo %s · %d %s" % [formato_tiempo(mejor), pistas, "pista" if pistas == 1 else "pistas"]


static func formato_tiempo(segundos: float) -> String:
	if segundos == INF:
		return "—"
	var total := int(round(segundos))
	return "%d:%02d" % [total / 60, total % 60]


func _material_sombra() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
void fragment() {
	float oscuro = mix(0.9, 0.15, smoothstep(0.15, 0.85, UV.x));
	COLOR = vec4(0.02, 0.015, 0.025, max(oscuro, smoothstep(0.55, 1.0, UV.y) * 0.75));
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material


func _material_fondo() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
void fragment() {
	vec2 p = UV - vec2(0.5, 0.42);
	float luz = 1.0 - smoothstep(0.0, 0.85, length(p * vec2(1.0, 1.6)));
	vec3 fondo = mix(vec3(0.02, 0.018, 0.026), vec3(0.13, 0.095, 0.07), luz);
	float grano = fract(sin(dot(floor(FRAGCOORD.xy * 0.5), vec2(12.9898, 78.233))) * 43758.5453);
	COLOR = vec4(fondo + (grano - 0.5) * 0.018, 1.0);
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material
