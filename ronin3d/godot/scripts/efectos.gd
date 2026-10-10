# Sensación de combate: pausa de impacto (el juego se congela un instante al golpear),
# cámara lenta en el iai perfecto, sacudida de cámara, chispas, sonidos, cuadros de
# impacto en tinta y la secuencia del corte de luna.
extends Node3D

const Datos := preload("res://scripts/datos.gd")
const Tinta := preload("res://scripts/tinta.gd")

const SONIDOS := {
	"tajo": preload("res://sonidos/tajo.wav"),
	"estocada": preload("res://sonidos/estocada.wav"),
	"golpe": preload("res://sonidos/golpe.wav"),
	"parada": preload("res://sonidos/parada.wav"),
	"herido": preload("res://sonidos/herido.wav"),
	"aviso": preload("res://sonidos/aviso.wav"),
	"caida": preload("res://sonidos/caida.wav"),
	"moneda": preload("res://sonidos/moneda.wav"),
	"escarbar": preload("res://sonidos/escarbar.wav"),
	"ladrido": preload("res://sonidos/ladrido.wav"),
}
const VOCES := 8                      # sonidos que pueden sonar a la vez

var camara                            # CamaraOrbital: recibe las sacudidas
var voces: Array = []
var siguiente_voz := 0
var azar := RandomNumberGenerator.new()
var congelado := 0.0                  # segundos reales que quedan de pausa de impacto
var lento := 0.0                      # segundos reales que quedan de cámara lenta
var escala_lenta := 1.0
var tinta
var luna_restante := 0.0              # segundos reales que quedan del corte de luna
var luna_al_cortar: Callable
var luna_cortado := false
var luna_cortes_sonados := 0
var racha_monedas := 0                # monedas seguidas: cada una suena un poco más aguda
var tiempo_racha := 0.0
var numeros_vivos := 0                # números de daño en pantalla (para las pruebas)
var numeros_creados := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	azar.seed = 7
	for i in VOCES:
		var voz := AudioStreamPlayer3D.new()
		voz.unit_size = 6.0
		voz.max_distance = 60.0
		add_child(voz)
		voces.append(voz)
	tinta = Tinta.new()
	add_child(tinta)


func _exit_tree() -> void:
	Engine.time_scale = 1.0


func _process(delta: float) -> void:
	# «delta» viene escalado por Engine.time_scale: se recupera el tiempo real.
	var real := delta / maxf(Engine.time_scale, 0.001)
	congelado = maxf(0.0, congelado - real)
	lento = maxf(0.0, lento - real)
	tiempo_racha = maxf(0.0, tiempo_racha - real)
	if tiempo_racha <= 0.0:
		racha_monedas = 0
	tinta.actualizar(real)
	if get_tree().paused:
		return
	if luna_restante > 0.0:
		_avanzar_luna(real)
	elif congelado > 0.0:
		Engine.time_scale = 0.05
	elif lento > 0.0:
		Engine.time_scale = escala_lenta
	else:
		Engine.time_scale = 1.0


# --- Piezas ------------------------------------------------------------------------------

func sonar(nombre: String, punto: Vector3, volumen_db := 0.0, variacion := 0.08) -> void:
	var voz: AudioStreamPlayer3D = voces[siguiente_voz]
	siguiente_voz = (siguiente_voz + 1) % VOCES
	voz.stream = SONIDOS[nombre]
	voz.global_position = punto
	voz.volume_db = volumen_db
	voz.pitch_scale = 1.0 + azar.randf_range(-variacion, variacion)
	voz.play()


func pausa_de_impacto(segundos: float) -> void:
	congelado = maxf(congelado, segundos)


func camara_lenta(escala: float, segundos: float) -> void:
	escala_lenta = escala
	lento = maxf(lento, segundos)


func sacudir(fuerza: float) -> void:
	if camara:
		camara.sacudir(fuerza)


func chispas(punto: Vector3, cantidad: int, color: Color, rapidez := 5.0, vida := 0.4, gravedad := -12.0,
		tamano := 0.07) -> void:
	var chispas := CPUParticles3D.new()
	chispas.one_shot = true
	chispas.explosiveness = 1.0
	chispas.amount = cantidad
	chispas.lifetime = vida
	chispas.direction = Vector3.UP
	chispas.spread = 180.0
	chispas.initial_velocity_min = rapidez * 0.5
	chispas.initial_velocity_max = rapidez
	chispas.gravity = Vector3(0, gravedad, 0)
	chispas.scale_amount_min = 0.6
	chispas.scale_amount_max = 1.2
	var degradado := Gradient.new()
	degradado.set_color(0, Color(1, 1, 1, 1))
	degradado.set_color(1, Color(color.r, color.g, color.b, 0.0))
	chispas.color_ramp = degradado
	var punto_malla := QuadMesh.new()
	punto_malla.size = Vector2(tamano, tamano)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	punto_malla.material = material
	chispas.mesh = punto_malla
	chispas.position = punto
	add_child(chispas)
	chispas.emitting = true
	get_tree().create_timer(1.2, true, false, true).timeout.connect(chispas.queue_free)


# --- Momentos del combate -------------------------------------------------------------------

func tajo(punto: Vector3) -> void:
	sonar("tajo", punto, -4.0, 0.12)


func golpe(punto: Vector3, mortal: bool) -> void:
	pausa_de_impacto(0.11 if mortal else 0.07)
	sacudir(0.45 if mortal else 0.3)
	chispas(punto, 22 if mortal else 14, Color(1.0, 0.75, 0.35))
	sonar("golpe", punto)
	if mortal:
		sonar("caida", punto, -3.0)


# Golpe de un corte de armas.gd: la congelación y la sacudida salen del propio corte (más
# fuertes con el mandoble y en el remate), y se ven el daño y la postura rota, como en EthrA.
func golpe_de(punto: Vector3, mortal: bool, corte: Dictionary, danio: int, rota: bool) -> void:
	var extra := 1.4 if mortal else (1.25 if rota else 1.0)
	pausa_de_impacto(float(corte.pausa) * extra)
	sacudir(minf(1.0, float(corte.sacudida) * extra))
	var color: Color = Color(1.0, 0.75, 0.35) if not corte.get("cargado", false) else Color(0.75, 0.85, 1.0)
	chispas(punto, 22 if mortal else 12 + int(float(corte.sacudida) * 12.0), color)
	sonar("golpe", punto, 0.0 if float(corte.pausa) < 0.1 else 2.0)
	numero(punto + Vector3.UP * 0.5, str(danio) if not mortal or danio > 0 else "", mortal)
	if rota and not mortal:
		texto_flotante(punto + Vector3.UP * 0.9, "¡Postura rota!", Color(1.0, 0.85, 0.3), 0.007)
		sonar("parada", punto, -2.0)
	if mortal:
		sonar("caida", punto, -3.0)
		polvo_de_pixeles(punto)


# Número de daño que sube y se desvanece sobre el enemigo.
func numero(punto: Vector3, texto: String, mortal := false) -> void:
	if texto == "":
		return
	texto_flotante(punto, texto, Color(1.0, 0.35, 0.25) if mortal else Color(1, 1, 1), 0.006)


func texto_flotante(punto: Vector3, texto: String, color: Color, tamano: float) -> void:
	var etiqueta := Label3D.new()
	etiqueta.text = texto
	etiqueta.pixel_size = tamano
	etiqueta.font_size = 48
	etiqueta.outline_size = 14
	etiqueta.modulate = color
	etiqueta.outline_modulate = Color(0.05, 0.02, 0.02)
	etiqueta.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	etiqueta.no_depth_test = true
	etiqueta.position = punto + Vector3(azar.randf_range(-0.15, 0.15), 0.0, 0.0)
	add_child(etiqueta)
	numeros_vivos += 1
	numeros_creados += 1
	var subida := create_tween()
	subida.tween_property(etiqueta, "position:y", punto.y + 0.6, 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	subida.parallel().tween_property(etiqueta, "modulate:a", 0.0, 0.35).set_delay(0.35)
	subida.tween_callback(func():
		numeros_vivos -= 1
		etiqueta.queue_free())


# Al morir, el enemigo se deshace en un estallido de cuadraditos (EthrA 12:10, 39:36).
func polvo_de_pixeles(punto: Vector3) -> void:
	chispas(punto, 26, Color(0.85, 0.82, 0.78), 3.0, 0.7, -2.0, 0.12)
	chispas(punto + Vector3.UP * 0.3, 14, Color(0.3, 0.28, 0.3), 2.0, 0.9, 1.0, 0.1)


func esquiva(punto: Vector3) -> void:
	chispas(punto, 8, Color(0.9, 0.9, 0.85), 1.5, 0.3, 0.0, 0.08)
	sonar("tajo", punto, -10.0, 0.2)


func desenvaine(punto: Vector3) -> void:
	sonar("tajo", punto, -2.0, 0.05)


# Iai perfecto: la lanza rebota en la hoja y el rival cae de un corte.
func iai_perfecto(punto: Vector3) -> void:
	pausa_de_impacto(0.12)
	camara_lenta(0.3, 0.55)
	sacudir(0.5)
	tinta.impacto(0.1)
	chispas(punto, 40, Color(0.75, 0.85, 1.0), 7.0)
	sonar("parada", punto, 2.0, 0.04)
	sonar("golpe", punto)
	sonar("caida", punto, -3.0)


# Corte de luna: el mundo se congela en tinta, aparecen los cortes uno tras otro y, al
# final, todo lo cortado cae a la vez. «al_cortar» aplica el daño en ese momento.
func corte_de_luna(puntos: Array, al_cortar: Callable) -> void:
	var pantalla: Array = []
	var camara3d: Camera3D = camara.camara
	for punto in puntos:
		if not camara3d.is_position_behind(punto):
			pantalla.append(camara3d.unproject_position(punto))
	tinta.preparar_cortes(pantalla, azar)
	luna_restante = Datos.DURACION_CORTE_LUNA
	luna_al_cortar = al_cortar
	luna_cortado = false
	luna_cortes_sonados = 0
	sonar("aviso", camara.global_position, 0.0, 0.0)


func luna_progreso() -> float:
	return 1.0 - luna_restante / Datos.DURACION_CORTE_LUNA if luna_restante > 0.0 else 0.0


func _avanzar_luna(real: float) -> void:
	luna_restante = maxf(0.0, luna_restante - real)
	var t := 1.0 - luna_restante / Datos.DURACION_CORTE_LUNA
	# 0-0,18: entra la tinta · 0,18-0,68: aparecen los cortes · 0,68: todo cae · luego se apaga.
	var cortes := clampf((t - 0.18) / 0.5, 0.0, 1.0)
	if t < 0.68:
		tinta.fuerza = clampf(t / 0.18, 0.0, 1.0)
		tinta.poner_cortes(cortes, 1.0)
		var sonados := int(cortes * 6.0)
		while luna_cortes_sonados < sonados:
			luna_cortes_sonados += 1
			sonar("tajo", camara.global_position, -4.0, 0.15)
		Engine.time_scale = 0.02
	else:
		if not luna_cortado:
			luna_cortado = true
			tinta.impacto(0.12)
			sacudir(0.8)
			sonar("golpe", camara.global_position, 2.0)
			sonar("caida", camara.global_position, 0.0)
			if luna_al_cortar.is_valid():
				luna_al_cortar.call()
		var salida := clampf((t - 0.68) / 0.32, 0.0, 1.0)
		tinta.fuerza = 1.0 - salida
		tinta.poner_cortes(1.0, 1.0 - salida)
		Engine.time_scale = 0.35
	if luna_restante <= 0.0:
		tinta.fuerza = 0.0
		tinta.poner_cortes(1.0, 0.0)
		Engine.time_scale = 1.0


func herido(punto: Vector3) -> void:
	pausa_de_impacto(0.1)
	sacudir(0.7)
	chispas(punto, 10, Color(0.9, 0.2, 0.15), 3.5)
	sonar("herido", punto)


func aviso(punto: Vector3) -> void:
	sonar("aviso", punto, -2.0, 0.03)


func estocada(punto: Vector3) -> void:
	sonar("estocada", punto, -3.0)


# --- Shiro y las monedas ----------------------------------------------------------------------

# Cada moneda de una racha suena un poco más aguda (hasta una quinta), como un tintineo que sube.
func moneda(punto: Vector3) -> void:
	var voz: AudioStreamPlayer3D = voces[siguiente_voz]
	sonar("moneda", punto, -6.0, 0.0)
	voz.pitch_scale = 1.0 + minf(racha_monedas, 8) * 0.06
	racha_monedas += 1
	tiempo_racha = 0.6
	chispas(punto, 6, Datos.COBRE.lightened(0.4), 2.0, 0.3, -4.0, 0.05)


func ladrido(punto: Vector3) -> void:
	sonar("ladrido", punto, -5.0, 0.06)


# Shiro escarba: tierra que salta durante el escarbado y su sonido.
func escarbar(punto: Vector3, segundos: float) -> void:
	sonar("escarbar", punto, -7.0, 0.05)
	var tierra := CPUParticles3D.new()
	tierra.amount = 18
	tierra.lifetime = 0.5
	tierra.direction = Vector3.UP
	tierra.spread = 50.0
	tierra.initial_velocity_min = 1.5
	tierra.initial_velocity_max = 3.0
	tierra.gravity = Vector3(0, -12.0, 0)
	tierra.scale_amount_min = 0.7
	tierra.scale_amount_max = 1.3
	tierra.color = Color("5a4630")
	var grano := QuadMesh.new()
	grano.size = Vector2(0.06, 0.06)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	grano.material = material
	tierra.mesh = grano
	tierra.position = punto
	add_child(tierra)
	tierra.emitting = true
	get_tree().create_timer(segundos, false).timeout.connect(func(): tierra.emitting = false)
	get_tree().create_timer(segundos + 1.0, false).timeout.connect(tierra.queue_free)


# Las monedas salen de la tierra: un puñado de tierra y un destello.
func desenterrar(punto: Vector3) -> void:
	chispas(punto, 14, Color("6a5236"), 3.0, 0.5, -12.0, 0.07)
	chispas(punto + Vector3.UP * 0.2, 10, Datos.COBRE.lightened(0.5), 2.5, 0.35, -3.0, 0.05)


# El jizō bendice a Akira: destello dorado y un toque de campana.
func bendicion(punto: Vector3) -> void:
	chispas(punto, 30, Datos.DORADO.lightened(0.3), 3.0, 0.8, -2.0, 0.08)
	sonar("parada", punto, -8.0, 0.0)


# Polvo cuando Shiro aparece junto a Akira (tras quedarse lejos o atascado).
func polvo(punto: Vector3) -> void:
	chispas(punto + Vector3.UP * 0.2, 12, Color(0.75, 0.72, 0.68), 1.5, 0.45, -1.0, 0.12)
