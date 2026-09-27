# Las tres estéticas: cada una decide los materiales, cómo se ven los personajes
# y los efectos de pantalla. El resto del juego es igual para las tres.
extends RefCounted

const Datos := preload("res://scripts/datos.gd")
const SHADER_TOON := preload("res://shaders/toon.gdshader")
const SHADER_CONTORNO := preload("res://shaders/contorno.gdshader")
const SHADER_CIELO := preload("res://shaders/cielo.gdshader")
const SHADER_PIXELADO := preload("res://shaders/pixelado.gdshader")

const ORDEN := ["hd2d", "pixel", "cel"]
const NOMBRES := {"hd2d": "HD-2D", "pixel": "Pixel art 3D", "cel": "Cel-shading"}

# Superficies con textura pixel art: [ruta, metros que ocupa una repetición, color plano]
const SUPERFICIES := {
	"losa": ["res://recursos/losa.png", 2.0, Color("585a68")],
	"muro_piedra": ["res://recursos/muro_piedra.png", 2.0, Color("707078")],
	"yeso": ["res://recursos/yeso.png", 2.0, Color("e8e4d8")],
	"madera": ["res://recursos/madera.png", 1.5, Color("7e5634")],
	"tejas": ["res://recursos/tejas.png", 1.2, Color("4c5270")],
}
# Superficies de color liso
const PLANOS := {
	"tierra": Color("1c2016"),
	"madera_oscura": Color("3e2a1a"),
	"hierro": Color("34343c"),
	"dorado": Color("e2ba62"),
	"piedra_clara": Color("9c9c96"),
	"agua": Color("16243a"),
}

var estilo := "hd2d"
var _cache := {}


func _init(nombre_estilo: String) -> void:
	estilo = nombre_estilo if nombre_estilo in ORDEN else "hd2d"


func nombre() -> String:
	return NOMBRES[estilo]


func usa_sprites() -> bool:
	return estilo == "hd2d"


func factor_pixelado() -> int:
	return 3 if estilo == "pixel" else 1


func usa_maqueta() -> bool:
	return estilo == "hd2d"


func usa_contornos() -> bool:
	return estilo == "cel"


# --- Materiales del escenario ---------------------------------------------------

func material_superficie(nombre_superficie: String) -> Material:
	if _cache.has(nombre_superficie):
		return _cache[nombre_superficie]
	var material: Material
	if estilo == "cel":
		var color: Color = SUPERFICIES[nombre_superficie][2] if SUPERFICIES.has(nombre_superficie) else PLANOS[nombre_superficie]
		material = material_toon(color, nombre_superficie not in ["losa", "tierra", "agua"], false)
	elif SUPERFICIES.has(nombre_superficie):
		var datos: Array = SUPERFICIES[nombre_superficie]
		var estandar := StandardMaterial3D.new()
		estandar.albedo_texture = load(datos[0])
		estandar.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
		estandar.uv1_triplanar = true
		estandar.uv1_world_triplanar = true
		estandar.uv1_scale = Vector3.ONE / float(datos[1])
		estandar.roughness = 1.0
		material = estandar
	else:
		var liso := StandardMaterial3D.new()
		liso.albedo_color = PLANOS[nombre_superficie]
		liso.roughness = 1.0
		material = liso
	_cache[nombre_superficie] = material
	return material


func material_porton() -> Material:
	if estilo == "cel":
		return material_toon(Color("744a2a"), true, false)
	var estandar := StandardMaterial3D.new()
	estandar.albedo_texture = load("res://recursos/porton.png")
	estandar.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	estandar.uv1_triplanar = true
	estandar.uv1_world_triplanar = true
	estandar.uv1_scale = Vector3(1.0 / 6.0, 1.0 / 4.4, 1.0 / 6.0)
	estandar.uv1_offset = Vector3(0.5, 0.0, 0.5)
	estandar.roughness = 1.0
	return estandar


func material_emisivo(color: Color, energia := 2.0) -> Material:
	if estilo == "cel":
		var toon := material_toon(color, false, false)
		toon.set_shader_parameter("emision", energia)
		return toon
	var estandar := StandardMaterial3D.new()
	estandar.albedo_color = color
	estandar.emission_enabled = true
	estandar.emission = color
	estandar.emission_energy_multiplier = energia
	return estandar


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


# --- Materiales de los personajes (uno nuevo por pieza, para el destello) ----------

func material_personaje(color: Color, por_normal := true) -> Material:
	if estilo == "cel":
		return material_toon(color, true, por_normal)
	var estandar := StandardMaterial3D.new()
	estandar.albedo_color = color
	estandar.roughness = 0.9
	return estandar


func poner_destello(material: Material, cantidad: float) -> void:
	if material is ShaderMaterial:
		material.set_shader_parameter("destello", cantidad)
	elif material is StandardMaterial3D:
		material.emission_enabled = cantidad > 0.0
		material.emission = Color(1.0, 0.85, 0.8)
		material.emission_energy_multiplier = cantidad * 1.2


# --- Ambiente: cielo, luz, niebla y brillo ------------------------------------------

func configurar_entorno(entorno: Environment) -> void:
	entorno.background_mode = Environment.BG_SKY
	var cielo := Sky.new()
	var material_cielo := ShaderMaterial.new()
	material_cielo.shader = SHADER_CIELO
	material_cielo.set_shader_parameter("direccion_luna", Datos.DIRECCION_LUNA)
	cielo.sky_material = material_cielo
	entorno.sky = cielo
	entorno.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	entorno.ambient_light_color = Datos.AMBIENTE
	entorno.ambient_light_energy = 1.2 if estilo == "cel" else 2.0
	entorno.fog_enabled = true
	entorno.fog_light_color = Color("1a1f3c")
	entorno.fog_density = 0.011
	entorno.fog_sky_affect = 0.0
	entorno.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	entorno.tonemap_exposure = 1.1 if estilo == "cel" else 1.2
	entorno.glow_enabled = estilo != "pixel"
	entorno.glow_intensity = 0.9
	entorno.glow_bloom = 0.06
	entorno.glow_hdr_threshold = 1.0


func material_contenedor() -> Material:
	if estilo != "pixel":
		return null
	var material := ShaderMaterial.new()
	material.shader = SHADER_PIXELADO
	return material
