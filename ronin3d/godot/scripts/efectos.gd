# Sensación de combate: pausa de impacto (el juego se congela un instante al golpear),
# cámara lenta en las paradas, sacudida de cámara, chispas y sonidos.
extends Node3D

const SONIDOS := {
	"tajo": preload("res://sonidos/tajo.wav"),
	"estocada": preload("res://sonidos/estocada.wav"),
	"golpe": preload("res://sonidos/golpe.wav"),
	"parada": preload("res://sonidos/parada.wav"),
	"herido": preload("res://sonidos/herido.wav"),
	"aviso": preload("res://sonidos/aviso.wav"),
	"caida": preload("res://sonidos/caida.wav"),
}
const VOCES := 8                      # sonidos que pueden sonar a la vez

var camara                            # CamaraOrbital: recibe las sacudidas
var voces: Array = []
var siguiente_voz := 0
var azar := RandomNumberGenerator.new()
var congelado := 0.0                  # segundos reales que quedan de pausa de impacto
var lento := 0.0                      # segundos reales que quedan de cámara lenta
var escala_lenta := 1.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	azar.seed = 7
	for i in VOCES:
		var voz := AudioStreamPlayer3D.new()
		voz.unit_size = 6.0
		voz.max_distance = 60.0
		add_child(voz)
		voces.append(voz)


func _exit_tree() -> void:
	Engine.time_scale = 1.0


func _process(delta: float) -> void:
	# «delta» viene escalado por Engine.time_scale: se recupera el tiempo real.
	var real := delta / maxf(Engine.time_scale, 0.001)
	congelado = maxf(0.0, congelado - real)
	lento = maxf(0.0, lento - real)
	if get_tree().paused:
		return
	if congelado > 0.0:
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


func chispas(punto: Vector3, cantidad: int, color: Color, rapidez := 5.0) -> void:
	var chispas := CPUParticles3D.new()
	chispas.one_shot = true
	chispas.explosiveness = 1.0
	chispas.amount = cantidad
	chispas.lifetime = 0.4
	chispas.direction = Vector3.UP
	chispas.spread = 180.0
	chispas.initial_velocity_min = rapidez * 0.5
	chispas.initial_velocity_max = rapidez
	chispas.gravity = Vector3(0, -12.0, 0)
	chispas.scale_amount_min = 0.6
	chispas.scale_amount_max = 1.2
	var degradado := Gradient.new()
	degradado.set_color(0, Color(1, 1, 1, 1))
	degradado.set_color(1, Color(color.r, color.g, color.b, 0.0))
	chispas.color_ramp = degradado
	var punto_malla := QuadMesh.new()
	punto_malla.size = Vector2(0.07, 0.07)
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


func parada(punto: Vector3) -> void:
	pausa_de_impacto(0.09)
	camara_lenta(0.35, 0.45)
	sacudir(0.25)
	chispas(punto, 34, Color(0.75, 0.85, 1.0), 6.5)
	sonar("parada", punto, 2.0, 0.04)


func herido(punto: Vector3) -> void:
	pausa_de_impacto(0.1)
	sacudir(0.7)
	chispas(punto, 10, Color(0.9, 0.2, 0.15), 3.5)
	sonar("herido", punto)


func aviso(punto: Vector3) -> void:
	sonar("aviso", punto, -2.0, 0.03)


func estocada(punto: Vector3) -> void:
	sonar("estocada", punto, -3.0)
