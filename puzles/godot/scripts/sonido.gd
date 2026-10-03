# Sonidos de un prototipo: efectos sueltos (varias voces a la vez), el roce continuo mientras se
# arrastra una pieza (más fuerte y agudo cuanto más rápido) y los ambientes en bucle.
# Los WAV salen de herramientas/generar_sonidos.py. Si falta alguno, simplemente no suena.
extends Node

const RUTA := "res://recursos/sonidos/%s.wav"
const VOCES := 10

var azar := RandomNumberGenerator.new()
var _voces: Array = []
var _siguiente := 0
var _cache := {}
var _bucles := {}
var _roce: AudioStreamPlayer
var _roce_nombre := ""
var _roce_objetivo := 0.0
var _roce_actual := 0.0
var sonados: Array = []               # últimos sonidos (lo usa la prueba automática)


func _ready() -> void:
	for i in VOCES:
		var voz := AudioStreamPlayer.new()
		add_child(voz)
		_voces.append(voz)
	_roce = AudioStreamPlayer.new()
	_roce.volume_db = -80.0
	add_child(_roce)


func _cargar(nombre: String) -> AudioStream:
	if not _cache.has(nombre):
		var ruta := RUTA % nombre
		_cache[nombre] = load(ruta) if ResourceLoader.exists(ruta) else null
	return _cache[nombre]


func _en_bucle(nombre: String) -> AudioStream:
	var clave := nombre + "@bucle"
	if not _cache.has(clave):
		var original := _cargar(nombre)
		if original is AudioStreamWAV:
			var copia: AudioStreamWAV = original.duplicate()
			copia.loop_mode = AudioStreamWAV.LOOP_FORWARD
			copia.loop_begin = 0
			copia.loop_end = int(copia.get_length() * copia.mix_rate) - 1
			_cache[clave] = copia
		else:
			_cache[clave] = original
	return _cache[clave]


func sonar(nombre: String, volumen_db := 0.0, tono := 1.0, variacion := 0.05) -> void:
	if nombre == "":
		return
	sonados.append(nombre)
	if sonados.size() > 40:
		sonados.pop_front()
	var flujo := _cargar(nombre)
	if flujo == null:
		return
	var voz: AudioStreamPlayer = _voces[_siguiente]
	_siguiente = (_siguiente + 1) % VOCES
	voz.stream = flujo
	voz.volume_db = volumen_db
	voz.pitch_scale = tono * (1.0 + azar.randf_range(-variacion, variacion))
	voz.play()


# --- Ambientes en bucle ----------------------------------------------------------------------

func bucle(nombre: String, volumen_db := 0.0, fundido := 1.5) -> AudioStreamPlayer:
	var jugador: AudioStreamPlayer = _bucles.get(nombre)
	if jugador == null:
		jugador = AudioStreamPlayer.new()
		jugador.stream = _en_bucle(nombre)
		jugador.volume_db = -60.0
		add_child(jugador)
		_bucles[nombre] = jugador
		if jugador.stream:
			jugador.play()
	var animacion := create_tween()
	animacion.tween_property(jugador, "volume_db", volumen_db, fundido)
	return jugador


func parar_bucle(nombre: String, fundido := 0.8) -> void:
	var jugador: AudioStreamPlayer = _bucles.get(nombre)
	if jugador == null:
		return
	_bucles.erase(nombre)
	var animacion := create_tween()
	animacion.tween_property(jugador, "volume_db", -60.0, fundido)
	animacion.tween_callback(jugador.queue_free)


# --- Roce al arrastrar ------------------------------------------------------------------------

func empezar_roce(nombre: String) -> void:
	if nombre == "":
		return
	if _roce_nombre != nombre:
		_roce_nombre = nombre
		_roce.stream = _en_bucle(nombre)
	if _roce.stream and not _roce.playing:
		_roce.play()


func roce(intensidad: float) -> void:
	_roce_objetivo = maxf(_roce_objetivo, clampf(intensidad, 0.0, 1.0))


func terminar_roce() -> void:
	_roce_objetivo = 0.0


func _process(delta: float) -> void:
	_roce_actual = lerpf(_roce_actual, _roce_objetivo, 1.0 - exp(-delta * 20.0))
	_roce_objetivo = maxf(0.0, _roce_objetivo - delta * 5.0)
	_roce.volume_db = linear_to_db(maxf(_roce_actual, 0.0001)) - 3.0
	_roce.pitch_scale = 0.85 + _roce_actual * 0.3
