# Criatura con modelo propio: un GLB detallado (hecho con IA a partir de su concepto 2D) con el
# mismo cel-shading, el mismo contorno y los mismos rangos que las criaturas de piezas.
# Misma interfaz que criatura_modular.gd: configurar(aspecto, receta), actualizar(delta),
# y las variables piezas y cuerpo (las usa la galería).
#
# Rangos: 1 base · 2 alfa (más grande, más oscura y con grietas que laten del color de su
#        elemento, más brasas si es de fuego) · 3 silenciada (sin color, blanca y gris).
# Sin esqueleto todavía: respira y se balancea por código, a 12 poses por segundo como Akira.
# Mira hacia +Z local, como VisualModelo y las criaturas de piezas.
extends Node3D

const VisualModelo := preload("res://scripts/visual_modelo.gd")
const SHADER_TOON_TEXTURA := preload("res://shaders/toon_textura.gdshader")
const SHADER_CONTORNO := preload("res://shaders/contorno.gdshader")

const ESCALA := {"S": 0.55, "M": 1.0, "L": 1.9, "XL": 3.8}
# Altura con tamaño M (metros), parecida a la de las criaturas de piezas de cada familia
const ALTO_FAMILIA := {"bipedo": 1.9, "cuadrupedo": 1.2, "serpentino": 1.0, "alado": 1.4,
	"acuatico": 1.0, "flotante": 1.2, "artropodo": 0.9}
const GROSOR_CONTORNO := 0.014           # metros: igual para todos los tamaños
const EMPUJE_CONTORNO := 0.06            # metros: el contorno solo asoma por la silueta (ver contorno.gdshader)
# Modelos propios disponibles: id del bestiario → archivo, giro para que mire a +Z y el color
# que brilla por sí solo (ojos, llamas). Cómo se hicieron: ../modelos/criaturas/LEEME.md
const MODELOS := {
	2315: {"ruta": "res://modelos/criaturas/aka_oni.glb", "giro": 0.0, "brillo": Color("f0d040"),
		# El modelo salió sin el garrote: se le pone uno aparte en el puño levantado (unidades del GLB)
		"garrote": {"agarre": Vector3(-0.27, 0.33, 0.03), "giro": Vector3(-18.0, 0.0, -38.0)}},
	353: {"ruta": "res://modelos/criaturas/kappa.glb", "giro": 0.0, "brillo": Color("f2d21e"),
		# El plato salió hueco y negro: se repintó de acero en la textura y el agua va aparte
		"agua": {"centro": Vector3(0.04, 0.468, 0.204), "radio": 0.15}},
	# Hecha con el conector de Trimble SketchUp (por código, sin IA): colores planos en una paleta;
	# brillan la boca (la llama de dentro) y el iris
	680: {"ruta": "res://modelos/criaturas/chochin_obake.glb", "giro": 0.0, "brillo": Color("ff9632")},
}
const COLOR_ELEMENTO := {
	"fuego": Color("ff5a12"), "agua": Color("38d6e8"), "hielo": Color("a8e8ff"), "rayo": Color("fff070"),
	"viento": Color("9cf0c0"), "tierra": Color("ffa040"), "veneno": Color("9cff40"), "sombra": Color("a070ff"),
	"luz": Color("ffe9a0"), "sangre": Color("ff2a3c"), "ninguno": Color("ff7a2a"),
}

var receta: Dictionary = {}
var cuerpo: Node3D
var modelo: Node3D
var materiales: Array = []
var piezas := 0                           # superficies (llamadas de dibujo sin contar el contorno)
var triangulos := 0
var rango := 1
var tiempo := 0.0
var acumulado := 0.0
var escala_base := 1.0
var animador: AnimationPlayer


static func tiene_modelo(id: int) -> bool:
	return MODELOS.has(id)


func configurar(_aspecto, receta_nueva: Dictionary) -> void:
	receta = receta_nueva
	rango = int(receta.get("rango", 1))
	var datos: Dictionary = MODELOS.get(int(receta.get("id", receta.get("semilla", 0))), {})
	var ruta := String(receta.get("modelo", datos.get("ruta", "")))
	cuerpo = Node3D.new()
	add_child(cuerpo)
	var escena = load(ruta) if ruta != "" and ResourceLoader.exists(ruta) else null
	if not escena is PackedScene:
		push_warning("Modelo no encontrado: %s" % ruta)
		return
	modelo = escena.instantiate()
	cuerpo.add_child(modelo)
	# Normaliza: centrado, con los pies en el suelo y la altura de su familia
	var caja := _caja(modelo)
	var alto: float = ALTO_FAMILIA.get(String(receta.get("familia", "bipedo")), 1.9)
	var s := alto / maxf(caja.size.y, 0.001)
	modelo.rotation.y = deg_to_rad(float(datos.get("giro", 0.0)))
	modelo.scale = Vector3.ONE * s
	var centro := caja.get_center()
	modelo.position = modelo.basis * Vector3(-centro.x, -caja.position.y, -centro.z)
	escala_base = ESCALA.get(String(receta.get("tamano", "M")), 1.0) * (1.2 if rango == 2 else 1.0)
	cuerpo.scale = Vector3.ONE * escala_base
	_aplicar_materiales(modelo, s * escala_base, caja.size.y, datos)
	animador = _buscar_animador(modelo)
	if animador != null and animador.get_animation_list().size() > 0:
		animador.play(animador.get_animation_list()[0])
	if rango == 2 and String(receta.get("elemento", "ninguno")) in ["fuego", "ninguno", "sangre"]:
		_brasas(alto)
	if datos.has("garrote"):
		_garrote(datos["garrote"], s * escala_base)
	if datos.has("agua"):
		_agua(datos["agua"])


# --- Materiales ------------------------------------------------------------------------------

func _aplicar_materiales(raiz: Node3D, escala_total: float, alto_original: float, datos: Dictionary) -> void:
	var elemento := String(receta.get("elemento", "ninguno"))
	for malla in _mallas(raiz):
		var m: Mesh = malla.mesh
		for i in m.get_surface_count():
			var original: Material = malla.get_active_material(i)
			var toon := ShaderMaterial.new()
			toon.shader = SHADER_TOON_TEXTURA
			if original is BaseMaterial3D and original.albedo_texture != null:
				toon.set_shader_parameter("textura", original.albedo_texture)
			toon.set_shader_parameter("color_brillo", datos.get("brillo", Color("f0d040")))
			toon.set_shader_parameter("escala_grietas", 8.0 / maxf(alto_original, 0.001))
			match rango:
				2:
					toon.set_shader_parameter("tinte", Color(0.82, 0.74, 0.74))
					toon.set_shader_parameter("saturacion", 1.25)
					toon.set_shader_parameter("fuerza_grietas", 1.0)
					toon.set_shader_parameter("oscurecer", 0.55)
					toon.set_shader_parameter("color_grietas", COLOR_ELEMENTO.get(elemento, COLOR_ELEMENTO["ninguno"]))
					toon.set_shader_parameter("fuerza_brillo", 2.4)
				3:
					toon.set_shader_parameter("tinte", Color(1.12, 1.12, 1.18))
					toon.set_shader_parameter("saturacion", 0.0)
					toon.set_shader_parameter("fuerza_borde", 0.4)
				_:
					toon.set_shader_parameter("fuerza_brillo", 1.4)
			var contorno := ShaderMaterial.new()
			contorno.shader = SHADER_CONTORNO
			contorno.set_shader_parameter("grosor", GROSOR_CONTORNO / maxf(escala_total, 0.001))
			contorno.set_shader_parameter("empuje", EMPUJE_CONTORNO)
			toon.next_pass = contorno
			malla.set_surface_override_material(i, toon)
			materiales.append(toon)
			piezas += 1
			var indices: int = m.surface_get_array_index_len(i)
			triangulos += (indices if indices > 0 else m.surface_get_array_len(i)) / 3


func poner_destello(cantidad: float) -> void:
	for material in materiales:
		material.set_shader_parameter("destello", cantidad)


# Kanabō (garrote de hierro con tachas) en una sola malla: una llamada de dibujo más el contorno.
# Va dentro del modelo, en sus unidades (el GLB mide 1 de alto), y hereda su escala.
func _garrote(datos: Dictionary, escala_total: float) -> void:
	var herramienta := SurfaceTool.new()
	herramienta.begin(Mesh.PRIMITIVE_TRIANGLES)
	var mango := CylinderMesh.new()
	mango.top_radius = 0.016
	mango.bottom_radius = 0.018
	mango.height = 0.2
	mango.radial_segments = 8
	herramienta.append_from(mango, 0, Transform3D(Basis(), Vector3(0, 0.02, 0)))
	var pomo := CylinderMesh.new()
	pomo.top_radius = 0.024
	pomo.bottom_radius = 0.024
	pomo.height = 0.025
	pomo.radial_segments = 8
	herramienta.append_from(pomo, 0, Transform3D(Basis(), Vector3(0, -0.085, 0)))
	var cabeza := CylinderMesh.new()
	cabeza.top_radius = 0.05
	cabeza.bottom_radius = 0.03
	cabeza.height = 0.44
	cabeza.radial_segments = 8
	herramienta.append_from(cabeza, 0, Transform3D(Basis(), Vector3(0, 0.34, 0)))
	var tacha := CylinderMesh.new()
	tacha.top_radius = 0.0
	tacha.bottom_radius = 0.01
	tacha.height = 0.026
	tacha.radial_segments = 4
	tacha.rings = 1
	for anillo in 5:
		var y := 0.17 + anillo * 0.085
		var radio := 0.03 + (0.05 - 0.03) * (y - 0.12) / 0.44
		for k in 8:
			var angulo := TAU * (k + 0.5 * (anillo % 2)) / 8.0
			var fuera := Vector3(cos(angulo), 0, sin(angulo))
			var base := Basis(Quaternion(Vector3.UP, fuera))
			herramienta.append_from(tacha, 0, Transform3D(base, Vector3(0, y, 0) + fuera * (radio + 0.008)))
	herramienta.generate_normals()
	var malla := MeshInstance3D.new()
	malla.name = "Garrote"                   # la prueba lo deja fuera al medir el cuerpo
	malla.mesh = herramienta.commit()
	var toon := ShaderMaterial.new()
	toon.shader = SHADER_TOON_TEXTURA
	toon.set_shader_parameter("tinte", Color(0.3, 0.29, 0.33))
	toon.set_shader_parameter("fuerza_borde", 0.35)
	if rango == 2:
		toon.set_shader_parameter("fuerza_grietas", 1.0)
		toon.set_shader_parameter("oscurecer", 0.3)
		toon.set_shader_parameter("escala_grietas", 14.0)
		toon.set_shader_parameter("color_grietas", COLOR_ELEMENTO.get(String(receta.get("elemento", "ninguno")), COLOR_ELEMENTO["ninguno"]))
	elif rango == 3:
		toon.set_shader_parameter("tinte", Color(0.45, 0.45, 0.5))
		toon.set_shader_parameter("saturacion", 0.0)
	var contorno := ShaderMaterial.new()
	contorno.shader = SHADER_CONTORNO
	contorno.set_shader_parameter("grosor", GROSOR_CONTORNO / maxf(escala_total, 0.001))
	contorno.set_shader_parameter("empuje", EMPUJE_CONTORNO)
	toon.next_pass = contorno
	malla.material_override = toon
	materiales.append(toon)
	malla.position = datos.get("agarre", Vector3.ZERO)
	malla.rotation_degrees = datos.get("giro", Vector3.ZERO)
	modelo.add_child(malla)
	piezas += 1
	triangulos += malla.mesh.surface_get_array_len(0) / 3


# Agua del plato del kappa: un disco claro con reflejos que laten (las grietas del shader, finas y
# blancas, hacen de reflejos). Sin contorno: el borde del plato ya lo marca.
func _agua(datos: Dictionary) -> void:
	var disco := CylinderMesh.new()
	disco.top_radius = float(datos.get("radio", 0.15))
	disco.bottom_radius = disco.top_radius
	disco.height = 0.006
	disco.radial_segments = 24
	disco.rings = 1
	var malla := MeshInstance3D.new()
	malla.name = "Agua"
	malla.mesh = disco
	var toon := ShaderMaterial.new()
	toon.shader = SHADER_TOON_TEXTURA
	toon.set_shader_parameter("tinte", Color("78bcd6"))
	toon.set_shader_parameter("emision", 0.15)
	toon.set_shader_parameter("fuerza_borde", 0.0)
	toon.set_shader_parameter("fuerza_grietas", 0.4)
	toon.set_shader_parameter("color_grietas", Color("eafcff"))
	toon.set_shader_parameter("escala_grietas", 40.0)
	toon.set_shader_parameter("ancho_grietas", 0.05)
	toon.set_shader_parameter("velocidad_pulso", 3.0)
	if rango == 3:
		toon.set_shader_parameter("saturacion", 0.0)
	malla.material_override = toon
	materiales.append(toon)
	malla.position = datos.get("centro", Vector3.ZERO)
	modelo.add_child(malla)
	piezas += 1
	var indices: PackedInt32Array = disco.surface_get_arrays(0)[Mesh.ARRAY_INDEX]
	triangulos += indices.size() / 3


# Brasas que suben alrededor de la variante fuerte de fuego (partículas por CPU: van en cualquier móvil)
func _brasas(alto: float) -> void:
	var brasas := CPUParticles3D.new()
	brasas.amount = 28
	brasas.lifetime = 1.6
	brasas.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	brasas.emission_box_extents = Vector3(0.45, alto * 0.4, 0.3)
	brasas.position = Vector3(0, alto * 0.5, 0)
	brasas.direction = Vector3.UP
	brasas.spread = 25.0
	brasas.gravity = Vector3(0, 0.6, 0)
	brasas.initial_velocity_min = 0.2
	brasas.initial_velocity_max = 0.6
	brasas.scale_amount_min = 0.5
	brasas.scale_amount_max = 1.2
	var quad := QuadMesh.new()
	quad.size = Vector2(0.09, 0.09)
	var redonda := GradientTexture2D.new()       # brasa redonda y difusa, no un cuadrado
	redonda.fill = GradientTexture2D.FILL_RADIAL
	redonda.fill_from = Vector2(0.5, 0.5)
	redonda.fill_to = Vector2(1.0, 0.5)
	redonda.width = 32
	redonda.height = 32
	var degradado := Gradient.new()
	degradado.set_color(0, Color(1, 1, 1, 1))
	degradado.set_color(1, Color(1, 1, 1, 0))
	redonda.gradient = degradado
	var material := StandardMaterial3D.new()
	material.albedo_texture = redonda
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.albedo_color = Color(1.0, 0.55, 0.15)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.45, 0.1)
	material.emission_energy_multiplier = 2.5
	quad.material = material
	brasas.mesh = quad
	var gradiente := Gradient.new()
	gradiente.set_color(0, Color(1, 0.8, 0.3, 1))
	gradiente.set_color(1, Color(1, 0.2, 0.05, 0))
	brasas.color_ramp = gradiente
	cuerpo.add_child(brasas)


# --- Animación (sin esqueleto: respiración y balanceo) ---------------------------------------

func actualizar(delta: float, movimiento := 1.0) -> void:
	acumulado += delta
	if VisualModelo.estilo_anime and acumulado < 1.0 / 12.0:
		return
	tiempo += acumulado
	acumulado = 0.0
	if animador != null or cuerpo == null:
		return
	var respiro := sin(tiempo * 2.1) * 0.016 * movimiento
	cuerpo.scale = escala_base * Vector3(1.0 - respiro * 0.5, 1.0 + respiro, 1.0 - respiro * 0.5)
	cuerpo.rotation.z = sin(tiempo * 1.15) * 0.022 * movimiento


# --- Utilidades ------------------------------------------------------------------------------

func _mallas(raiz: Node) -> Array:
	var lista: Array = []
	if raiz is MeshInstance3D and raiz.mesh != null:
		lista.append(raiz)
	for hijo in raiz.get_children():
		lista.append_array(_mallas(hijo))
	return lista


func _buscar_animador(raiz: Node) -> AnimationPlayer:
	if raiz is AnimationPlayer:
		return raiz
	for hijo in raiz.get_children():
		var encontrado := _buscar_animador(hijo)
		if encontrado != null:
			return encontrado
	return null


# Caja que ocupa el modelo, en el espacio de su nodo raíz (sin contar la transformación de la raíz)
func _caja(raiz: Node3D) -> AABB:
	var caja := AABB()
	var primera := true
	for malla in _mallas(raiz):
		var t := Transform3D.IDENTITY
		var nodo: Node = malla
		while nodo != raiz and nodo is Node3D:
			t = (nodo as Node3D).transform * t
			nodo = nodo.get_parent()
		var c: AABB = t * malla.get_aabb()
		caja = c if primera else caja.merge(c)
		primera = false
	return caja
