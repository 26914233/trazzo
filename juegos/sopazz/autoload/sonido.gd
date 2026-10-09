# Efectos de sonido cortos. Respeta el ajuste "sonido" del jugador.
extends Node

const SONIDOS := {
	"clic": preload("res://arte/sonidos/clic.wav"),
	"acierto": preload("res://arte/sonidos/acierto.wav"),
	"error": preload("res://arte/sonidos/error.wav"),
	"victoria": preload("res://arte/sonidos/victoria.wav"),
}

var _reproductores: Array[AudioStreamPlayer] = []


func _ready() -> void:
	for i in 4:
		var r := AudioStreamPlayer.new()
		add_child(r)
		_reproductores.append(r)


func tocar(nombre: String) -> void:
	if not Progreso.ajuste("sonido") or not SONIDOS.has(nombre):
		return
	for r in _reproductores:
		if not r.playing:
			r.stream = SONIDOS[nombre]
			r.play()
			return


func vibrar(ms: int = 30) -> void:
	if Progreso.ajuste("vibracion"):
		Input.vibrate_handheld(ms)
