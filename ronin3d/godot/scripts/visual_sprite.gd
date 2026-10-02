# Personaje en pixel art (DECISIÓN 20, opción E, elegida el 02-10-2026): los personajes son sprites y
# el mundo sigue en 3D, como en la referencia del usuario. Un cartel muestra el cuadro de su hoja
# según la pose, el momento de la animación y desde dónde lo mira la cámara (8 direcciones).
# Las hojas se hornean desde los modelos de piezas (scripts/hornear_sprites.gd) y se pulen con
# herramientas/pulir_sprites.py. Recibe lo mismo que visual_modelo.gd y visual_shiro.gd:
# actualizar(delta, info).
extends Node3D

const Datos := preload("res://scripts/datos.gd")
const VisualModelo := preload("res://scripts/visual_modelo.gd")
const Apariencias := preload("res://scripts/apariencias_akira.gd")
const Monedas := preload("res://scripts/monedas.gd")
const SHADER := preload("res://shaders/sprite_pixel.gdshader")
const TEXTURA_SOMBRA := preload("res://recursos/sombra.png")
const DIRECCIONES := 8

static var activo := true             # false (--modelos3d): el juego usa los modelos de piezas

var aspecto
var tipo := "akira"                   # akira, soldado o shiro
var es_soldado := false
var apariencia := ""
var hoja: Dictionary = {}             # descripción de la hoja (recursos/sprites/<id>.json)
var tamano_hoja := Vector2.ONE
var cartel: MeshInstance3D
var material: ShaderMaterial
var cuerpo: Node3D                    # gira hacia donde mira el personaje (estelas, moneda)
var estela: MeshInstance3D
var material_estela: StandardMaterial3D
var estela_iai: MeshInstance3D
var material_estela_iai: StandardMaterial3D
var aviso: Label3D
var moneda_boca: MeshInstance3D
var angulo := 0.0
var fase := 0.0
var tiempo := 0.0
var acumulado := 0.0
var ultima_pose := ""
var ultima_muerte := -1.0
var ultimo_destello := 0.0
var actualizaciones := 0              # cuadros aplicados (lo usa la prueba automática)
var animacion := ""                   # la que se ve y desde qué dirección (también para la prueba)
var direccion := 0


# tipo: «akira», «soldado» o «shiro». Para Akira, la apariencia (vacía: la elegida).
func configurar(aspecto_del_juego, tipo_personaje: String, id_apariencia := "") -> void:
	aspecto = aspecto_del_juego
	tipo = tipo_personaje
	es_soldado = tipo == "soldado"
	apariencia = id_apariencia
	var id := tipo
	if tipo == "akira":
		var elegida: String = apariencia if apariencia != "" else Apariencias.elegida
		id = "akira_" + (elegida if Apariencias.APARIENCIAS.has(elegida) else "joven")
	hoja = JSON.parse_string(FileAccess.get_file_as_string("res://recursos/sprites/%s.json" % id))
	var textura: Texture2D = load("res://recursos/sprites/%s.png" % id)
	tamano_hoja = Vector2(textura.get_width(), textura.get_height())
	var px: float = hoja.px_por_metro
	var tam := Vector2(hoja.tam[0], hoja.tam[1])
	var pies := Vector2(hoja.pies[0], hoja.pies[1])
	var quad := QuadMesh.new()
	quad.size = tam / px
	quad.center_offset = Vector3((tam.x / 2.0 - pies.x) / px, (pies.y - tam.y / 2.0) / px, 0.0)
	material = ShaderMaterial.new()
	material.shader = SHADER
	material.set_shader_parameter("hoja", textura)
	cartel = MeshInstance3D.new()
	cartel.mesh = quad
	cartel.material_override = material
	cartel.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	cartel.name = "Sprite"
	add_child(cartel)
	cuerpo = Node3D.new()
	add_child(cuerpo)
	if tipo == "akira":
		estela = VisualModelo.crear_estela(cuerpo, Vector3(-0.15, 1.25, 0.05), false)
		material_estela = estela.material_override
		estela_iai = VisualModelo.crear_estela(cuerpo, Vector3(-0.1, 1.2, 0.0), true)
		material_estela_iai = estela_iai.material_override
	if tipo == "shiro":
		moneda_boca = MeshInstance3D.new()
		moneda_boca.mesh = Monedas.crear_malla_moneda(0.07, 0.016, 0.02)
		moneda_boca.material_override = aspecto.material_emisivo(Datos.COBRE, 0.45)
		moneda_boca.position = Vector3(0, 0.47, 0.39)
		moneda_boca.rotation.y = PI / 2.0
		moneda_boca.visible = false
		cuerpo.add_child(moneda_boca)
	var sombra := Sprite3D.new()
	sombra.texture = TEXTURA_SOMBRA
	sombra.pixel_size = 0.016 if tipo == "shiro" else 0.032
	sombra.axis = Vector3.AXIS_Y
	sombra.position.y = 0.03
	sombra.shaded = false
	sombra.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(sombra)
	aviso = Label3D.new()
	aviso.text = "!"
	aviso.font_size = 96
	aviso.pixel_size = 0.006
	aviso.modulate = Color(1.0, 0.22, 0.16)
	aviso.outline_modulate = Color(0.12, 0.0, 0.0)
	aviso.outline_size = 18
	aviso.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	aviso.no_depth_test = true
	aviso.position.y = 2.3
	aviso.visible = false
	add_child(aviso)
	_poner("quieto" if tipo == "shiro" else "normal", 0)


# Igual que visual_modelo.gd: en estilo anime el cuadro cambia a pasos de 1/12 s, pero un cambio
# de acción, un golpe o la caída se ven al instante.
func actualizar(delta: float, info: Dictionary) -> void:
	acumulado += delta
	var muerte: float = info.get("muerte", -1.0)
	var golpe: float = info.get("destello", 0.0)
	var cambio: bool = info.pose != ultima_pose or (muerte >= 0.0) != (ultima_muerte >= 0.0) \
		or golpe > ultimo_destello + 0.3
	ultimo_destello = golpe
	if VisualModelo.estilo_anime and acumulado < Datos.PASO_ANIME and not cambio:
		return
	ultima_pose = info.pose
	ultima_muerte = muerte
	actualizaciones += 1
	_aplicar(acumulado, info)
	acumulado = 0.0


func _aplicar(delta: float, info: Dictionary) -> void:
	tiempo += delta
	var mirando: Vector3 = info.mirando
	angulo = lerp_angle(angulo, atan2(mirando.x, mirando.z), minf(1.0, delta * 14.0))
	cuerpo.rotation.y = angulo
	direccion = _direccion()
	if tipo == "shiro":
		_animar_perro(delta, info)
		return
	var pose: String = info.pose
	var brillo := 0.0
	var brillo_iai := 0.0
	visible = info.visible
	if info.muerte >= 0.0:
		_poner("muerte", int(minf(1.0, info.muerte * 2.5) * 3.999))
		visible = info.muerte < 0.85
	elif pose in ["ataque", "desenvaine"]:
		var cuadros: int = hoja.animaciones[pose].cuadros
		_poner(pose, clampi(int(info.progreso * cuadros), 0, cuadros - 1))
		if pose == "ataque":
			brillo = VisualModelo.brillo_estela(info.progreso, 0.35, 0.35)
		else:
			brillo_iai = VisualModelo.brillo_estela(info.progreso, 0.45, 0.32)
	elif pose in ["postura", "remate", "preparando", "estocada"]:
		_poner(pose, 0)
	elif info.en_aire:
		_poner("salto", 0)
	elif info.moviendose:
		fase += delta * (13.0 if info.corriendo else 9.0)
		_poner_ciclo("correr" if info.corriendo else "andar")
	else:
		_poner_por_tiempo("normal")
	if estela:
		estela.visible = brillo > 0.01
		material_estela.albedo_color.a = brillo * 0.9
		estela_iai.visible = brillo_iai > 0.01
		material_estela_iai.albedo_color.a = brillo_iai * 0.95
	material.set_shader_parameter("destello", info.destello)
	aviso.visible = info.aviso and int(tiempo * 12.0) % 2 == 0


func _animar_perro(delta: float, info: Dictionary) -> void:
	var pose: String = info.pose
	if pose == "andar" or pose == "correr":
		fase += delta * (17.0 if pose == "correr" else 12.0)
		_poner_ciclo(pose)
	elif hoja.animaciones.has(pose):
		_poner_por_tiempo(pose)
	else:
		_poner_por_tiempo("quieto")
	moneda_boca.visible = info.get("en_boca", false)


# Ciclos de paso: el cuadro lo marca la fase, como el balanceo de piernas del modelo 3D
func _poner_ciclo(nombre: String) -> void:
	var cuadros: int = hoja.animaciones[nombre].cuadros
	_poner(nombre, int(fase / TAU * cuadros) % cuadros)


func _poner_por_tiempo(nombre: String) -> void:
	var datos: Dictionary = hoja.animaciones[nombre]
	var cuadro := int(tiempo * float(datos.fps)) % int(datos.cuadros) if float(datos.fps) > 0.0 else 0
	_poner(nombre, cuadro)


# Muestra el cuadro k de la animación, visto desde la dirección actual
func _poner(nombre: String, k: int) -> void:
	animacion = nombre
	var datos: Dictionary = hoja.animaciones[nombre]
	var numero: int = direccion * int(hoja.cuadros_por_direccion) + int(datos.inicio) + clampi(k, 0, int(datos.cuadros) - 1)
	var columnas: int = hoja.columnas
	var margen: float = hoja.margen
	var celda := Vector2(float(hoja.tam[0]) + margen * 2.0, float(hoja.tam[1]) + margen * 2.0)
	var esquina := Vector2((numero % columnas) * celda.x + margen, (numero / columnas) * celda.y + margen)
	material.set_shader_parameter("region", Vector4(esquina.x / tamano_hoja.x, esquina.y / tamano_hoja.y,
		float(hoja.tam[0]) / tamano_hoja.x, float(hoja.tam[1]) / tamano_hoja.y))


# Desde dónde ve la cámara al personaje: la dirección d es la cámara a 45° · d a su alrededor,
# medido desde su frente (la misma cuenta que hornear_sprites.gd).
func _direccion() -> int:
	if not is_inside_tree():
		return 0
	var camara := get_viewport().get_camera_3d()
	if camara == null:
		return 0
	var hacia := camara.global_position - global_position
	var relativo := atan2(hacia.x, hacia.z) - (angulo + global_rotation.y)
	return posmod(int(round(relativo / (TAU / DIRECCIONES))), DIRECCIONES)
