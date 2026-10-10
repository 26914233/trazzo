# Aspecto de un enemigo con hoja de sprites de perfil, en el estilo del oni del usuario (DECISIÓN
# del 10-10-2026: «utiliza el mismo estilo para los demás enemigos»). Las hojas salen de
# herramientas/recortar_hoja.py (kappa, onibi, soldado) y recortar_oni_jefe.py (oni); tienen las
# filas reposo, caminar, ataque, golpe y muerte, dibujadas mirando a la derecha.
# Recibe el mismo «info» que visual_sprite.gd y visual_yokai.gd (pose, mirando, moviendose,
# destello, muerte, aviso, rojo) y elige animación y cuadro; se voltea según la cámara.
extends Node3D

var sprite: Sprite3D
var datos: Dictionary
var aviso: Label3D
var tiempo := 0.0
var tiempo_pose := 0.0
var ultima_pose := ""
var mirando := Vector3.RIGHT
var animacion := ""
var cuadro := 0
var flota := false


func configurar(id_hoja: String, alto_metros: float, flota_nueva := false) -> void:
	flota = flota_nueva
	datos = JSON.parse_string(FileAccess.get_file_as_string("res://recursos/sprites/%s.json" % id_hoja))
	sprite = Sprite3D.new()
	sprite.texture = load("res://recursos/sprites/%s.png" % id_hoja)
	sprite.region_enabled = true
	sprite.pixel_size = alto_metros / float(datos.get("alto_px", 100))
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	sprite.shaded = false
	var celda: Array = datos.tam
	var pies: Array = datos.pies
	sprite.position.y = (float(pies[1]) - float(celda[1]) / 2.0) * sprite.pixel_size + (0.5 if flota else 0.0)
	add_child(sprite)
	aviso = Label3D.new()
	aviso.text = "!"
	aviso.font_size = 96
	aviso.pixel_size = 0.006
	aviso.outline_size = 18
	aviso.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	aviso.no_depth_test = true
	aviso.position.y = alto_metros + 0.4 + (0.5 if flota else 0.0)
	aviso.visible = false
	add_child(aviso)
	_poner("reposo", 0)


func actualizar(delta: float, info: Dictionary) -> void:
	tiempo += delta
	var pose: String = info.get("pose", "normal")
	if pose != ultima_pose:
		ultima_pose = pose
		tiempo_pose = 0.0
	tiempo_pose += delta
	mirando = info.get("mirando", mirando)
	var muerte: float = info.get("muerte", -1.0)
	if muerte >= 0.0:
		var n: int = datos.animaciones.muerte.cuadros
		_poner("muerte", mini(n - 1, int(muerte * float(n) * 1.3)))
		sprite.modulate.a = clampf((1.0 - muerte) * 3.0, 0.0, 1.0)
	else:
		match pose:
			"preparando":
				# Anticipación: los primeros cuadros del ataque.
				_poner("ataque", 0 if tiempo_pose < 0.2 else 1)
			"estocada":
				var n: int = datos.animaciones.ataque.cuadros
				_poner("ataque", mini(n - 1, 2 + int(tiempo_pose * 10.0)))
			"aturdido":
				var n: int = datos.animaciones.golpe.cuadros
				_poner("golpe", mini(n - 1, int(tiempo_pose * 10.0)))
			"reverencia":
				_poner("golpe", datos.animaciones.golpe.cuadros - 1)
			_:
				_bucle("caminar" if info.get("moviendose", false) else "reposo")
		sprite.modulate.a = 1.0
	var destello: float = info.get("destello", 0.0)
	sprite.modulate = Color(1, 1, 1, sprite.modulate.a).lerp(Color(3, 3, 3, sprite.modulate.a), destello * 0.6)
	if flota:
		sprite.position.y += sin(tiempo * 2.2) * 0.002
	aviso.visible = info.get("aviso", false) and int(tiempo * 12.0) % 2 == 0
	var rojo: bool = info.get("rojo", false)
	aviso.text = "!!" if rojo else "!"
	aviso.modulate = Color(1.0, 0.18, 0.12) if rojo else Color(1.0, 0.92, 0.6)
	aviso.outline_modulate = Color(0.15, 0.0, 0.0) if rojo else Color(0.1, 0.07, 0.0)
	_orientar()


func _bucle(nombre: String) -> void:
	var anim: Dictionary = datos.animaciones[nombre]
	var fps := float(anim.fps) if float(anim.fps) > 0.0 else 8.0
	_poner(nombre, int(tiempo * fps) % int(anim.cuadros))


func _poner(nombre: String, k: int) -> void:
	animacion = nombre
	cuadro = k
	var anim: Dictionary = datos.animaciones[nombre]
	var numero: int = int(anim.inicio) + clampi(k, 0, int(anim.cuadros) - 1)
	var celda: Array = datos.tam
	var columnas: int = datos.columnas
	sprite.region_rect = Rect2((numero % columnas) * float(celda[0]), (numero / columnas) * float(celda[1]),
		float(celda[0]), float(celda[1]))


# Las hojas miran a la derecha: se voltea si, vista desde la cámara, mira a la izquierda.
func _orientar() -> void:
	if not is_inside_tree():
		return
	var camara := get_viewport().get_camera_3d()
	if camara == null:
		return
	var hacia_derecha := mirando.dot(camara.global_transform.basis.x) >= 0.0
	sprite.flip_h = not hacia_derecha
	var celda: Array = datos.tam
	var pies: Array = datos.pies
	var desvio := float(celda[0]) / 2.0 - float(pies[0])
	sprite.offset.x = desvio if hacia_derecha else -desvio
