# Aspecto de un enemigo con hoja de sprites de perfil, en el estilo del oni del usuario (DECISIÓN
# del 10-10-2026: «utiliza el mismo estilo para los demás enemigos»). Las hojas salen de
# herramientas/recortar_hoja.py (kappa, onibi, soldado) y recortar_oni_jefe.py (oni); tienen las
# filas reposo, caminar, ataque, golpe y muerte, dibujadas mirando a la derecha.
# Recibe el mismo «info» que visual_sprite.gd y visual_yokai.gd (pose, mirando, moviendose,
# destello, muerte, aviso, rojo) y elige animación y cuadro; se voltea según la cámara.
# Desde la 0.16 (capítulos 2 a 4) también entiende:
#   anim_ataque  «ataque» o «area» (la fila que usa el golpe en curso)
#   fijo         [animación, cuadro]: congelado (el farolillo o el komainu dormidos)
#   oculto       el sprite no se ve (el tanuki disfrazado de jizō)
#   tinte, alfa  color y transparencia (piedra de la gárgola, niebla del vampiro, ilusiones)
#   queda        al morir se queda en su último cuadro (Genzo de rodillas)
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
var altura_flota := 0.5
var tinte_base := Color(1, 1, 1, 1)
var bucle_fijo := ""                  # aldeanos y kodama: una fila en bucle


# opciones: tinte (Color), sin_sombra (las ilusiones no dan sombra: así se distinguen), altura_flota.
func configurar(id_hoja: String, alto_metros: float, flota_nueva := false, opciones := {}) -> void:
	flota = flota_nueva
	altura_flota = float(opciones.get("altura_flota", 0.5))
	tinte_base = opciones.get("tinte", Color(1, 1, 1, 1))
	datos = JSON.parse_string(FileAccess.get_file_as_string("res://recursos/sprites/%s.json" % id_hoja))
	sprite = Sprite3D.new()
	if opciones.get("sin_sombra", false):
		sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	sprite.texture = load("res://recursos/sprites/%s.png" % id_hoja)
	sprite.region_enabled = true
	sprite.pixel_size = alto_metros / float(datos.get("alto_px", 100))
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	sprite.shaded = false
	var celda: Array = datos.tam
	var pies: Array = datos.pies
	sprite.position.y = (float(pies[1]) - float(celda[1]) / 2.0) * sprite.pixel_size + (altura_flota if flota else 0.0)
	add_child(sprite)
	aviso = Label3D.new()
	aviso.text = "!"
	aviso.font_size = 96
	aviso.pixel_size = 0.006
	aviso.outline_size = 18
	aviso.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	aviso.no_depth_test = true
	aviso.position.y = alto_metros + 0.4 + (altura_flota if flota else 0.0)
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
	var anim_ataque: String = info.get("anim_ataque", "ataque")
	if not datos.animaciones.has(anim_ataque):
		anim_ataque = "ataque"
	var alfa: float = info.get("alfa", 1.0)
	sprite.visible = not info.get("oculto", false)
	if muerte >= 0.0:
		var n: int = datos.animaciones.muerte.cuadros
		_poner("muerte", mini(n - 1, int(muerte * float(n) * 1.3)))
		if not info.get("queda", false):
			alfa *= clampf((1.0 - muerte) * 3.0, 0.0, 1.0)
	elif info.has("fijo"):
		_poner(String(info.fijo[0]), int(info.fijo[1]))
	elif bucle_fijo != "":
		_bucle(bucle_fijo)
	else:
		match pose:
			"preparando":
				# Anticipación: los primeros cuadros del ataque.
				_poner(anim_ataque, 0 if tiempo_pose < 0.2 else 1)
			"estocada":
				var n: int = datos.animaciones[anim_ataque].cuadros
				_poner(anim_ataque, mini(n - 1, mini(2, n - 1) + int(tiempo_pose * 10.0)))
			"aturdido":
				var n: int = datos.animaciones.golpe.cuadros
				_poner("golpe", mini(n - 1, int(tiempo_pose * 10.0)))
			"reverencia":
				_poner("golpe", datos.animaciones.golpe.cuadros - 1)
			"desarmado":
				var n: int = datos.animaciones.muerte.cuadros
				_poner("muerte", mini(n - 2, int(tiempo_pose * 6.0)))
			_:
				_bucle("caminar" if info.get("moviendose", false) else "reposo")
	var tinte: Color = info.get("tinte", tinte_base)
	var destello: float = info.get("destello", 0.0)
	var base := Color(tinte.r, tinte.g, tinte.b, tinte.a * alfa)
	sprite.modulate = base.lerp(Color(3, 3, 3, base.a), destello * 0.6)
	if flota:
		sprite.position.y += sin(tiempo * 2.2) * 0.002
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD if sprite.modulate.a >= 0.99 else SpriteBase3D.ALPHA_CUT_DISABLED
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


# Aldeanos y kodama: siempre la misma fila en bucle (la hoja de aldeanos trae uno por fila).
func fijar_bucle(nombre: String) -> void:
	bucle_fijo = nombre
	_bucle(nombre)


func tiene_animacion(nombre: String) -> bool:
	return datos.animaciones.has(nombre)
