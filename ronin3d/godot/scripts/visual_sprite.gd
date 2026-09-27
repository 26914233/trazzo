# Personaje HD-2D: sprite pixel art que siempre mira a la cámara (billboard vertical)
# y elige la vista (frente, espalda o lado) según hacia dónde mira el personaje.
# Incluye sombra en el suelo, aviso «!» y estela del tajo.
extends Node3D

const TAMANO_PIXEL := 0.04
const HOJA_AKIRA := preload("res://recursos/akira.png")
const HOJA_SOLDADO := preload("res://recursos/soldado.png")
const TEXTURA_SOMBRA := preload("res://recursos/sombra.png")
const TEXTURA_TAJO := preload("res://recursos/tajo.png")

var sprite: Sprite3D
var sombra: Sprite3D
var aviso: Label3D
var tajo: Sprite3D
var es_soldado := false
var tiempo := 0.0


func configurar(soldado: bool) -> void:
	es_soldado = soldado
	sprite = Sprite3D.new()
	sprite.texture = HOJA_SOLDADO if soldado else HOJA_AKIRA
	sprite.hframes = 5
	sprite.vframes = 3
	sprite.pixel_size = TAMANO_PIXEL
	sprite.offset = Vector2(0, 24)          # cuadros de 48 px de alto: los pies en el origen
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	sprite.shaded = true
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	add_child(sprite)

	sombra = Sprite3D.new()
	sombra.texture = TEXTURA_SOMBRA
	sombra.pixel_size = 0.034 if soldado else 0.03
	sombra.axis = Vector3.AXIS_Y
	sombra.position.y = 0.03
	sombra.shaded = false
	sombra.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
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
	aviso.position.y = 2.25
	aviso.visible = false
	add_child(aviso)

	if not soldado:
		tajo = Sprite3D.new()
		tajo.texture = TEXTURA_TAJO
		tajo.pixel_size = 0.036
		tajo.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		tajo.shaded = false
		tajo.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		tajo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		tajo.visible = false
		add_child(tajo)


func actualizar(delta: float, info: Dictionary) -> void:
	tiempo += delta
	var camara := get_viewport().get_camera_3d()
	if camara == null:
		return
	var mirando: Vector3 = info.mirando
	var hacia_camara := camara.global_position - global_position
	hacia_camara.y = 0.0
	hacia_camara = hacia_camara.normalized()
	var derecha_camara := camara.global_transform.basis.x
	derecha_camara.y = 0.0
	derecha_camara = derecha_camara.normalized()

	# Vista: frente, espalda o lado (volteado si mira hacia la izquierda de la pantalla).
	var producto := mirando.dot(hacia_camara)
	var fila := 2
	if producto > 0.707:
		fila = 0
	elif producto < -0.707:
		fila = 1
	var hacia_izquierda := mirando.dot(derecha_camara) < 0.0
	sprite.flip_h = fila == 2 and hacia_izquierda

	# Pose: quieto, dos pasos, y las dos poses de ataque.
	var columna := 0
	match info.pose:
		"ataque":
			columna = 3 if info.progreso < 0.5 else 4
		"preparando":
			columna = 3
		"estocada":
			columna = 4
		_:
			if info.en_aire:
				columna = 1
			elif info.moviendose:
				var periodo := 0.1 if info.corriendo else 0.15
				columna = 1 + int(tiempo / periodo) % 2
	sprite.frame = fila * 5 + columna

	sprite.visible = info.visible
	var tinte := Color.WHITE.lerp(Color(1.0, 0.35, 0.35), info.destello)
	if info.muerte >= 0.0:
		sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
		tinte.a = 1.0 - info.muerte
		sprite.position.y = -0.35 * info.muerte
		sombra.modulate.a = 1.0 - info.muerte
		aviso.visible = false
	sprite.modulate = tinte
	aviso.visible = info.aviso and int(tiempo * 12.0) % 2 == 0

	if tajo:
		var progreso: float = info.progreso
		var mostrar: bool = info.pose == "ataque" and progreso > 0.12 and progreso < 0.75
		tajo.visible = mostrar
		if mostrar:
			tajo.position = mirando * 0.8 + Vector3(0, 0.95, 0)
			tajo.flip_h = hacia_izquierda
			tajo.modulate = Color(1, 1, 1, 1.0 - progreso)
