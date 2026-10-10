# El aspecto del juego (cel-shading): materiales con la luz en bandas y contorno negro,
# colores del escenario y ambiente de la noche (cielo, niebla, brillo).
extends RefCounted

const Datos := preload("res://scripts/datos.gd")
const SHADER_TOON := preload("res://shaders/toon.gdshader")
const SHADER_CONTORNO := preload("res://shaders/contorno.gdshader")
const SHADER_CARA := preload("res://shaders/toon_cara.gdshader")
const SHADER_CIELO := preload("res://shaders/cielo.gdshader")

# Color plano de cada superficie del escenario
const COLORES := {
	"losa": Color("585a68"),
	"muro_piedra": Color("707078"),
	"yeso": Color("e8e4d8"),
	"madera": Color("7e5634"),
	"tejas": Color("4c5270"),
	"tierra": Color("1c2016"),
	"madera_oscura": Color("3e2a1a"),
	"hierro": Color("34343c"),
	"dorado": Color("e2ba62"),
	"piedra_clara": Color("9c9c96"),
	"agua": Color("16243a"),
	"porton": Color("744a2a"),
	# Escenarios de los capítulos siguientes (escenarios.gd, constructor_escenarios.gd)
	"hierba": Color("26301e"),
	"hierba_roja": Color("3a1e1a"),
	"camino": Color("4a3e2c"),
	"roca": Color("5a5852"),
	"roca_oscura": Color("3a3a3c"),
	"corteza": Color("3a2a20"),
	"hojas_pino": Color("1e3426"),
	"hojas_cedro": Color("1a2c24"),
	"paja": Color("8a7444"),
	"papel": Color("e6dcc0"),
	"bermellon": Color("b8402a"),
	"piedra_musgo": Color("56604c"),
	"barro": Color("8a5a3a"),
	"ruina": Color("7a7266"),
	"glifo": Color("6ad8e0"),
	"nacar": Color("cfd6e6"),
	"cadena": Color("8a7a52"),
	"kakuriyo_suelo": Color("221c32"),
	"kakuriyo_hojas": Color("3a2a5a"),
	"tatami": Color("a89a64"),
	"hueso": Color("c8bc96"),
}
# Superficies grandes y planas: sin contorno (se vería como una raya en el suelo)
const SIN_CONTORNO := ["losa", "tierra", "agua", "hierba", "hierba_roja", "camino", "kakuriyo_suelo", "tatami"]
# Con los personajes en pixel art (DECISIÓN 20E), el escenario va sin la línea negra del cel-shading,
# como los decorados HD-2D: así destacan los sprites, que llevan su propio contorno de un píxel.
static var contorno_escenario := false

var _cache := {}


# --- Escenario -----------------------------------------------------------------------------

func material_superficie(nombre: String) -> Material:
	if not _cache.has(nombre):
		_cache[nombre] = material_toon(COLORES[nombre], contorno_escenario and not nombre in SIN_CONTORNO, false)
	return _cache[nombre]


func material_emisivo(color: Color, energia := 2.0) -> Material:
	var toon := material_toon(color, false, false)
	toon.set_shader_parameter("emision", energia)
	return toon


func material_toon(color: Color, con_contorno := true, por_normal := true) -> ShaderMaterial:
	var toon := ShaderMaterial.new()
	toon.shader = SHADER_TOON
	toon.set_shader_parameter("color", color)
	if con_contorno:
		var contorno := ShaderMaterial.new()
		contorno.shader = SHADER_CONTORNO
		contorno.set_shader_parameter("por_normal", por_normal)
		contorno.set_shader_parameter("grosor", 0.03 if por_normal else 0.045)
		toon.next_pass = contorno
	return toon


# --- Personajes (un material nuevo por pieza, para poder hacerla destellar) -------------------

# Como en el anime: la línea es un tono muy oscuro del propio color (no negro puro), y la piel
# puede ir con luz plana para que las caras no se partan en dos con la sombra.
func material_personaje(color: Color, por_normal := true, plano := false) -> Material:
	var material := material_toon(color, true, por_normal)
	if plano:
		material.set_shader_parameter("plano", 1.0)
	material.next_pass.set_shader_parameter("color", Color(0.05, 0.04, 0.07).lerp(color.darkened(0.7), 0.45))
	return material


# Cara con los rasgos dibujados (recursos/caras/): la piel con luz plana y, encima, la imagen de
# los ojos, las cejas y la boca. «a_cabeza» lleva la malla al espacio de la cabeza, que es donde
# está medida la imagen. La línea de la cara es fina y del tono de la piel: gruesa y oscura
# parecía barba.
func material_cara(color: Color, rasgos: Texture2D, a_cabeza: Transform3D) -> Material:
	var cara := ShaderMaterial.new()
	cara.shader = SHADER_CARA
	cara.set_shader_parameter("color", color)
	cara.set_shader_parameter("rasgos", rasgos)
	cara.set_shader_parameter("a_cabeza", Projection(a_cabeza))
	var contorno := ShaderMaterial.new()
	contorno.shader = SHADER_CONTORNO
	contorno.set_shader_parameter("grosor", 0.011)
	contorno.set_shader_parameter("color", color.darkened(0.55))
	cara.next_pass = contorno
	return cara


func poner_destello(material: Material, cantidad: float) -> void:
	material.set_shader_parameter("destello", cantidad)


# --- Ambiente: cielo, luz, niebla y brillo ------------------------------------------------------

# «ambiente» cambia el de cada escenario (escenarios.gd); sin él, la noche del castillo.
func configurar_entorno(entorno: Environment, ambiente := {}) -> void:
	entorno.background_mode = Environment.BG_SKY
	var cielo := Sky.new()
	var material_cielo := ShaderMaterial.new()
	material_cielo.shader = SHADER_CIELO
	material_cielo.set_shader_parameter("direccion_luna", ambiente.get("direccion_luna", Datos.DIRECCION_LUNA))
	for clave in ["cielo_arriba", "cielo_horizonte", "cielo_suelo"]:
		if ambiente.has(clave):
			var parametro: String = {"cielo_arriba": "color_arriba", "cielo_horizonte": "color_horizonte",
				"cielo_suelo": "color_suelo"}[clave]
			material_cielo.set_shader_parameter(parametro, ambiente[clave])
	if ambiente.has("tinte_luna"):
		material_cielo.set_shader_parameter("tinte_luna", ambiente.tinte_luna)
	cielo.sky_material = material_cielo
	entorno.sky = cielo
	entorno.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	entorno.ambient_light_color = ambiente.get("ambiente", Datos.AMBIENTE)
	entorno.ambient_light_energy = ambiente.get("energia_ambiente", 2.4)   # noche, pero personajes legibles
	entorno.fog_enabled = true
	entorno.fog_light_color = ambiente.get("niebla", Color("1a1f3c"))
	entorno.fog_density = ambiente.get("densidad_niebla", 0.011)
	entorno.fog_sky_affect = 0.0
	entorno.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	entorno.tonemap_exposure = ambiente.get("exposicion", 1.1)
	entorno.glow_enabled = true
	entorno.glow_intensity = 0.9
	entorno.glow_bloom = 0.06
	entorno.glow_hdr_threshold = 1.0
