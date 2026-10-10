# Oni, jefe del capítulo 1 en el portón, en pixel art con el estilo que eligió el usuario el
# 10-10-2026 (su hoja: arte/conceptos/oni_jefe_hoja.webp; los cuadros los recorta
# herramientas/recortar_oni_jefe.py). Su combate sigue la idea de la ficha de BESTIARIO.md §3
# (avisos enormes, un punto débil tras cada golpe y un iai perfecto que remata), adaptada a sus
# animaciones:
#   1. Golpes de área: salta hacia Akira y estampa el kanabō; la sombra roja marca dónde (no se
#      puede parar: hay que apartarse). Después queda agachado con el kanabō clavado: 3 cortes le
#      rompen la postura. A la segunda rotura entra en furia.
#   2. Furia: más rápido y teñido de rojo. Su barrido de kanabō («!») se puede parar y un iai
#      perfecto lo remata; los cortes también le quitan vida.
# Mientras viva, el portón no deja salir del castillo. Interfaz como soldado.gd, más
# puntos_de_golpe() y recibir_golpe_en() (dónde se le corta).
extends Node3D

const Datos := preload("res://scripts/datos.gd")
const HOJA := preload("res://recursos/sprites/oni_jefe.png")

enum Fase { DORMIDO, AREA, FURIA, MUERTO }
enum Paso { ESPERA, SOMBRA, SALTO, EN_SUELO, ROTO, AVISO_GOLPE, GOLPE, RECUPERA }

signal derrotado
signal desperto
signal vida_cambiada(fraccion: float)
signal aviso_iniciado
signal estocada_iniciada
signal punetazo(punto: Vector3)       # el kanabō golpea el suelo
signal postura_quebrada(roturas: int)

const ALTO := 2.6                      # metros (la hoja dice unos 2,2 m; algo más grande, por ser jefe)
const ALTO_PX := 105.0                 # alto del oni en los cuadros de la hoja
const RADIO_DESPERTAR := 13.0
const ALCANCE_SALTO := 8.0
const RADIO_IMPACTO := 2.0
const AVISO_SOMBRA := 1.1
const SALTO := 0.28
const EN_SUELO := 1.9
const ROTO := 2.0
const CORTES_POR_POSTURA := 3
const ROTURAS_PARA_FURIA := 2
const VIDA_FURIA := 6
const AVISO_GOLPE := 0.8
const GOLPE := 0.3
const ALCANCE_GOLPE := 2.8
const CONO_GOLPE := 160.0
const DISTANCIA_GOLPE := 3.4           # más cerca que esto, en vez de saltar, barre con el kanabō
const VELOCIDAD := 1.8

var objetivo
var aspecto
var sprite: Sprite3D
var datos: Dictionary
var sombra: MeshInstance3D
var material_sombra: StandardMaterial3D
var aviso: Label3D
var fase := Fase.DORMIDO
var paso := Paso.ESPERA
var temporizador := 1.2
var tiempo := 0.0
var punto_golpe := Vector3.ZERO
var salida_salto := Vector3.ZERO
var cortes := 0                        # cortes de la ventana actual (fase 1)
var roturas := 0
var vida_furia := VIDA_FURIA
var vida := 1                          # para el HUD y las pruebas: lo que le queda en total
var destello := 0.0
var mirando := Vector3.LEFT
var golpe_dado := false
var muerte := -1.0
var animacion := "reposo"
var inicio_golpe := 0.0
var cuadro := 0
var cuerpo_estatico: StaticBody3D


func configurar(lugar: Vector3, akira, aspecto_del_juego) -> void:
	objetivo = akira
	aspecto = aspecto_del_juego
	position = lugar
	vida = CORTES_POR_POSTURA * ROTURAS_PARA_FURIA + VIDA_FURIA


func _ready() -> void:
	datos = JSON.parse_string(FileAccess.get_file_as_string("res://recursos/sprites/oni_jefe.json"))
	sprite = Sprite3D.new()
	sprite.texture = HOJA
	sprite.region_enabled = true
	sprite.pixel_size = ALTO / ALTO_PX
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	sprite.shaded = false
	# Los pies del cuadro caen en el origen del jefe.
	var celda: Array = datos.tam
	var pies: Array = datos.pies
	sprite.position.y = (float(pies[1]) - float(celda[1]) / 2.0) * sprite.pixel_size
	add_child(sprite)
	_poner("reposo", 0)
	sombra = MeshInstance3D.new()
	var disco := CylinderMesh.new()
	disco.top_radius = RADIO_IMPACTO
	disco.bottom_radius = RADIO_IMPACTO
	disco.height = 0.03
	sombra.mesh = disco
	material_sombra = StandardMaterial3D.new()
	material_sombra.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material_sombra.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material_sombra.albedo_color = Color(0.55, 0.02, 0.02, 0.5)
	sombra.material_override = material_sombra
	sombra.top_level = true
	sombra.visible = false
	add_child(sombra)
	aviso = Label3D.new()
	aviso.font_size = 128
	aviso.pixel_size = 0.008
	aviso.outline_size = 22
	aviso.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	aviso.no_depth_test = true
	aviso.position.y = ALTO + 0.6
	aviso.visible = false
	add_child(aviso)
	cuerpo_estatico = StaticBody3D.new()
	cuerpo_estatico.collision_layer = 2
	var forma := CollisionShape3D.new()
	var capsula := CapsuleShape3D.new()
	capsula.radius = 0.6
	capsula.height = ALTO
	forma.shape = capsula
	forma.position.y = ALTO / 2.0
	cuerpo_estatico.add_child(forma)
	add_child(cuerpo_estatico)


func vivo() -> bool:
	return fase != Fase.MUERTO


func persigue() -> bool:
	return fase in [Fase.AREA, Fase.FURIA]


func postura_rota() -> bool:
	return paso == Paso.ROTO


func despierto() -> bool:
	return fase != Fase.DORMIDO


func fraccion_vida() -> float:
	return float(vida) / float(CORTES_POR_POSTURA * ROTURAS_PARA_FURIA + VIDA_FURIA)


# Dónde se le puede cortar: el cuerpo, solo agachado tras el golpe de área (o vendido con la
# postura rota) en la fase 1; siempre en la furia.
func puntos_de_golpe() -> Array:
	var vulnerable: bool = fase == Fase.FURIA or (fase == Fase.AREA and paso in [Paso.EN_SUELO, Paso.ROTO])
	if not vulnerable:
		return []
	return [{"posicion": global_position + Vector3.UP * 0.2, "radio": 0.9, "parte": "cuerpo"}]


func recibir_golpe(desde: Vector3, letal := false, danio := 1, _postura := 0.0, _empuje := -1.0) -> bool:
	# Golpes sin parte (el corte de luna): solo cuentan si ahora se le puede cortar.
	if puntos_de_golpe().is_empty():
		return false
	return recibir_golpe_en("cuerpo", desde, 2 if letal else danio)


func recibir_golpe_en(_parte: String, _desde: Vector3, danio := 1, _postura := 0.0, _empuje := -1.0) -> bool:
	if not vivo() or puntos_de_golpe().is_empty():
		return false
	destello = 1.0
	if fase == Fase.AREA:
		if paso == Paso.ROTO:
			return false                 # vendido: ya está roto, se recupera para la furia
		cortes += 1
		vida -= 1
		_animar_golpe()
		if cortes >= CORTES_POR_POSTURA:
			cortes = 0
			roturas += 1
			postura_quebrada.emit(roturas)
			paso = Paso.ROTO
			temporizador = ROTO
			if roturas >= ROTURAS_PARA_FURIA:
				_entrar_en_furia()
	else:
		vida_furia -= danio
		vida -= danio
		_animar_golpe()
		if vida_furia <= 0:
			_morir()
			vida_cambiada.emit(0.0)
			return true
	vida_cambiada.emit(fraccion_vida())
	return false


# Iai perfecto contra su barrido (fase de furia): lo remata.
func recibir_iai(_desde: Vector3) -> bool:
	if fase != Fase.FURIA:
		return false
	vida -= vida_furia
	vida_furia = 0
	_morir()
	vida_cambiada.emit(0.0)
	return true


func _entrar_en_furia() -> void:
	fase = Fase.FURIA
	paso = Paso.ROTO
	temporizador = ROTO


func _morir() -> void:
	fase = Fase.MUERTO
	muerte = 0.0
	aviso.visible = false
	sombra.visible = false
	cuerpo_estatico.collision_layer = 0
	derrotado.emit()


# La reacción al golpe se ve cuando le rompen la postura (paso ROTO); los demás cortes solo lo
# hacen destellar, porque agachado con el kanabō clavado se queda en su pose.
func _animar_golpe() -> void:
	inicio_golpe = tiempo


func _plano(v: Vector3) -> Vector3:
	return Vector3(v.x, 0.0, v.z)


func _hacia_akira() -> Vector3:
	return _plano(objetivo.global_position - global_position)


func _physics_process(delta: float) -> void:
	tiempo += delta
	destello = maxf(0.0, destello - delta * 5.0)
	match fase:
		Fase.DORMIDO:
			_animar("reposo")
			if objetivo and objetivo.vivo() and _hacia_akira().length() < RADIO_DESPERTAR:
				fase = Fase.AREA
				paso = Paso.ESPERA
				temporizador = 1.0
				desperto.emit()
		Fase.AREA, Fase.FURIA:
			_combatir(delta)
		Fase.MUERTO:
			muerte = minf(1.0, muerte + delta / 1.6)
			_poner("muerte", mini(4, int(muerte * 6.0)))
			if muerte >= 1.0:
				sprite.modulate.a = maxf(0.0, sprite.modulate.a - delta * 1.5)
	_orientar()
	var furia := 0.5 + 0.5 * sin(tiempo * 7.0) if fase == Fase.FURIA else 0.0
	var color := Color(1.0, 1.0 - furia * 0.35, 1.0 - furia * 0.35, sprite.modulate.a)
	sprite.modulate = color.lerp(Color(3.0, 3.0, 3.0, color.a), destello * 0.6)


func _combatir(delta: float) -> void:
	temporizador -= delta
	var rapidez := 1.35 if fase == Fase.FURIA else 1.0
	var hacia := _hacia_akira()
	match paso:
		Paso.ESPERA:
			if hacia.length() > 0.01:
				mirando = hacia.normalized()
			if hacia.length() > DISTANCIA_GOLPE + 1.5 and hacia.length() > ALCANCE_SALTO * 0.6:
				global_position += mirando * VELOCIDAD * rapidez * delta
				_animar("caminar")
			else:
				_animar("reposo")
			if temporizador <= 0.0:
				if hacia.length() < DISTANCIA_GOLPE:
					_empezar_barrido()
				else:
					_empezar_area()
		Paso.SOMBRA:
			var t := 1.0 - temporizador / (AVISO_SOMBRA / rapidez)
			sombra.scale = Vector3.ONE * lerpf(0.35, 1.0, t)
			material_sombra.albedo_color.a = lerpf(0.25, 0.7, t)
			_poner("area", 0)
			if temporizador <= 0.0:
				paso = Paso.SALTO
				temporizador = SALTO
				salida_salto = global_position
				aviso.visible = false
		Paso.SALTO:
			# Salta hasta quedar delante de la sombra y estampa el kanabō.
			var t := 1.0 - temporizador / SALTO
			var llegada := punto_golpe - mirando * 1.4
			llegada.y = salida_salto.y
			global_position = salida_salto.lerp(llegada, t) + Vector3.UP * sin(t * PI) * 1.2
			_poner("area", 1 if t > 0.6 else 0)
			if temporizador <= 0.0:
				global_position = llegada
				sombra.visible = false
				paso = Paso.EN_SUELO
				temporizador = EN_SUELO
				punetazo.emit(punto_golpe)
				var akira_plano := _plano(objetivo.global_position - punto_golpe)
				if akira_plano.length() < RADIO_IMPACTO + Datos.RADIO_PERSONAJE and objetivo.global_position.y < 1.6:
					objetivo.recibir_golpe(punto_golpe)
		Paso.EN_SUELO:
			# Estallido y después agachado con el kanabō clavado: el hueco para cortarle.
			_poner("area", 1 if temporizador > EN_SUELO - 0.25 else (2 if temporizador > EN_SUELO - 0.6 else 3))
			if temporizador <= 0.0:
				paso = Paso.ESPERA
				temporizador = 0.8 / rapidez
		Paso.ROTO:
			_poner("golpe", mini(4, int((tiempo - inicio_golpe) * 7.0)))
			if temporizador <= 0.0:
				paso = Paso.ESPERA
				temporizador = 0.6
		Paso.AVISO_GOLPE:
			if hacia.length() > 0.01 and temporizador > (AVISO_GOLPE / rapidez) * 0.4:
				mirando = hacia.normalized()
			_poner("ataque", 0 if temporizador > (AVISO_GOLPE / rapidez) * 0.5 else 1)
			if temporizador <= 0.0:
				paso = Paso.GOLPE
				temporizador = GOLPE
				golpe_dado = false
				aviso.visible = false
				estocada_iniciada.emit()
		Paso.GOLPE:
			_poner("ataque", 2 if temporizador > GOLPE * 0.5 else 3)
			if not golpe_dado:
				_intentar_barrido()
			if temporizador <= 0.0 and vivo():
				paso = Paso.RECUPERA
				temporizador = 0.7 / rapidez
		Paso.RECUPERA:
			_poner("ataque", 3)
			if temporizador <= 0.0:
				paso = Paso.ESPERA
				temporizador = 0.5 / rapidez


func _empezar_area() -> void:
	var hacia := _hacia_akira()
	punto_golpe = global_position + hacia.limit_length(ALCANCE_SALTO)
	punto_golpe.y = 0.02
	paso = Paso.SOMBRA
	temporizador = AVISO_SOMBRA / (1.35 if fase == Fase.FURIA else 1.0)
	sombra.visible = true
	sombra.global_position = punto_golpe
	aviso.text = "!!"
	aviso.modulate = Color(1.0, 0.18, 0.12)
	aviso.visible = true
	aviso_iniciado.emit()


# Barrido de kanabō: en la fase 1 no se para («!!»); en la furia sí («!»), y ahí está el remate.
func _empezar_barrido() -> void:
	paso = Paso.AVISO_GOLPE
	temporizador = AVISO_GOLPE / (1.35 if fase == Fase.FURIA else 1.0)
	var parable := fase == Fase.FURIA
	aviso.text = "!" if parable else "!!"
	aviso.modulate = Color(1.0, 0.92, 0.6) if parable else Color(1.0, 0.18, 0.12)
	aviso.visible = true
	aviso_iniciado.emit()


func _intentar_barrido() -> void:
	var hacia := _hacia_akira()
	if hacia.length() > ALCANCE_GOLPE + Datos.RADIO_PERSONAJE or absf(objetivo.global_position.y - global_position.y) > 1.6:
		return
	if hacia.length() > 0.6 and mirando.angle_to(hacia) > deg_to_rad(CONO_GOLPE / 2.0):
		return
	golpe_dado = true
	if fase == Fase.FURIA and objetivo.has_method("intentar_parar") and objetivo.intentar_parar(self):
		return
	objetivo.recibir_golpe(global_position)


# --- Sprite ---------------------------------------------------------------------------------

# Animaciones en bucle (reposo, caminar) a sus cuadros por segundo.
func _animar(nombre: String) -> void:
	var anim: Dictionary = datos.animaciones[nombre]
	_poner(nombre, int(tiempo * float(anim.fps)) % int(anim.cuadros))


func _poner(nombre: String, k: int) -> void:
	animacion = nombre
	cuadro = k
	var anim: Dictionary = datos.animaciones[nombre]
	var numero: int = int(anim.inicio) + clampi(k, 0, int(anim.cuadros) - 1)
	var celda: Array = datos.tam
	var columnas: int = datos.columnas
	sprite.region_rect = Rect2((numero % columnas) * float(celda[0]), (numero / columnas) * float(celda[1]),
		float(celda[0]), float(celda[1]))


# La hoja dibuja al oni mirando a la derecha de la pantalla: se voltea según hacia dónde mira
# visto desde la cámara.
func _orientar() -> void:
	if not is_inside_tree():
		return
	var camara := get_viewport().get_camera_3d()
	if camara == null:
		return
	var derecha_pantalla := camara.global_transform.basis.x
	var hacia_derecha := mirando.dot(derecha_pantalla) >= 0.0
	sprite.flip_h = not hacia_derecha
	var celda: Array = datos.tam
	var pies: Array = datos.pies
	var desvio := float(celda[0]) / 2.0 - float(pies[0])
	sprite.offset.x = desvio if hacia_derecha else -desvio


func info() -> Dictionary:
	return {"aviso": aviso.visible, "rojo": aviso.text == "!!"}
