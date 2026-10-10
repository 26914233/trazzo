# Efectos de sonido cortos. Respeta el ajuste "sonido" del jugador.
extends Node

const SONIDOS := {
	"clic": preload("res://arte/sonidos/clic.wav"),
	"acierto": preload("res://arte/sonidos/acierto.wav"),
	"error": preload("res://arte/sonidos/error.wav"),
	"victoria": preload("res://arte/sonidos/victoria.wav"),
}

const MUSICA := preload("res://arte/sonidos/ambiente.ogg")
const VOLUMEN_MUSICA_DB := -10.0

var _reproductores: Array[AudioStreamPlayer] = []
var _musica := AudioStreamPlayer.new()
var _fundido: Tween


func _ready() -> void:
	for i in 4:
		var r := AudioStreamPlayer.new()
		add_child(r)
		_reproductores.append(r)
	_musica.stream = MUSICA        # en bucle desde la importacion (ambiente.ogg.import)
	add_child(_musica)
	actualizar_musica()


## Musica ambiental segun el ajuste "musica" (entra y sale con fundido).
func actualizar_musica(inmediato: bool = false) -> void:
	var quiere := bool(Ajustes.valor("musica"))
	if quiere == musica_activa():
		return
	_activa = quiere
	if _fundido and _fundido.is_valid():
		_fundido.kill()
	if quiere:
		_musica.volume_db = -40.0
		_musica.play()
		_fundido = create_tween()
		_fundido.tween_property(_musica, "volume_db", VOLUMEN_MUSICA_DB, 2.0)
	elif inmediato:
		_musica.stop()
	else:
		_fundido = create_tween()
		_fundido.tween_property(_musica, "volume_db", -40.0, 0.8)
		_fundido.tween_callback(_musica.stop)


var _activa := false


func musica_activa() -> bool:
	return _activa


func tocar(nombre: String) -> void:
	if not Ajustes.valor("sonido") or not SONIDOS.has(nombre):
		return
	for r in _reproductores:
		if not r.playing:
			r.stream = SONIDOS[nombre]
			r.play()
			return


func vibrar(ms: int = 30) -> void:
	if Ajustes.valor("vibracion"):
		Input.vibrate_handheld(ms)
