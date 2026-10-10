# Efectos de sonido cortos (sintetizados con herramientas/sonidos.py). Respeta los
# ajustes de sonido y vibracion: apagados, no suena ni vibra nada.
extends Node

const SONIDOS := {
	"clic": preload("res://arte/sonidos/clic.wav"),
	"paleta": preload("res://arte/sonidos/paleta.wav"),
	"pared": preload("res://arte/sonidos/pared.wav"),
	"rompe": preload("res://arte/sonidos/rompe.wav"),
	"agrieta": preload("res://arte/sonidos/agrieta.wav"),
	"metal": preload("res://arte/sonidos/metal.wav"),
	"explota": preload("res://arte/sonidos/explota.wav"),
	"laser": preload("res://arte/sonidos/laser.wav"),
	"potenciador": preload("res://arte/sonidos/potenciador.wav"),
	"pierde": preload("res://arte/sonidos/pierde.wav"),
	"gana": preload("res://arte/sonidos/gana.wav"),
}

var _reproductores: Array[AudioStreamPlayer] = []


func _ready() -> void:
	for i in 8:
		var r := AudioStreamPlayer.new()
		add_child(r)
		_reproductores.append(r)


## tono: 1.0 normal; mas alto en combos largos.
func tocar(nombre: String, tono: float = 1.0) -> void:
	if not Ajustes.valor("sonido") or not SONIDOS.has(nombre):
		return
	for r in _reproductores:
		if not r.playing:
			r.stream = SONIDOS[nombre]
			r.pitch_scale = tono
			r.play()
			return


func vibrar(ms: int = 30) -> void:
	if Ajustes.valor("vibracion"):
		Input.vibrate_handheld(ms)
