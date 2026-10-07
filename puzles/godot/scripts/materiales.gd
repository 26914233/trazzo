# Materiales de los prototipos: madera con veta, mosaico yosegi, latón, metal ajeno, papel, piedra…
# Las texturas salen de herramientas/generar_texturas.py (por código, sin créditos de imágenes);
# si falta alguna, el material queda de color liso. «escala» = repeticiones de la textura por metro.
class_name Materiales
extends RefCounted

const RUTA := "res://recursos/texturas/%s.png"

static var _cache := {}


static func textura(nombre: String) -> Texture2D:
	var ruta := RUTA % nombre
	if not _cache.has(ruta):
		_cache[ruta] = load(ruta) if ResourceLoader.exists(ruta) else null
	return _cache[ruta]


static func con_textura(nombre: String, escala: float, rugosidad := 0.6, metalico := 0.0,
		color := Color.WHITE, relieve := 1.0, triplanar := false) -> StandardMaterial3D:
	var clave := "%s|%s|%s|%s|%s|%s|%s" % [nombre, escala, rugosidad, metalico, color, relieve, triplanar]
	if _cache.has(clave):
		return _cache[clave]
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	var albedo := textura(nombre)
	if albedo:
		material.albedo_texture = albedo
	var normal := textura(nombre + "_n")
	if normal:
		material.normal_enabled = true
		material.normal_texture = normal
		material.normal_scale = relieve
	material.roughness = rugosidad
	material.metallic = metalico
	material.metallic_specular = 0.5
	material.uv1_scale = Vector3(escala, escala, escala)
	material.uv1_triplanar = triplanar
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	_cache[clave] = material
	return material


static func liso(color: Color, rugosidad := 0.7, metalico := 0.0) -> StandardMaterial3D:
	var clave := "liso|%s|%s|%s" % [color, rugosidad, metalico]
	if _cache.has(clave):
		return _cache[clave]
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = rugosidad
	material.metallic = metalico
	_cache[clave] = material
	return material


# Brilla con luz propia (ojos, runas, llamas). Cada llamada da uno nuevo, para poder animarlo.
static func emisivo(color: Color, energia := 2.0, base := Color(0.02, 0.02, 0.02)) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = base
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energia
	material.roughness = 0.5
	return material


static func vidrio(color := Color(0.75, 0.85, 0.95, 0.16), rugosidad := 0.04) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	material.roughness = rugosidad
	material.metallic_specular = 0.9
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


static func laton(rugosidad := 0.32) -> StandardMaterial3D:
	return con_textura("laton", 6.0, rugosidad, 1.0, Color(1.0, 0.86, 0.58))


static func sin_luz(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	return material
