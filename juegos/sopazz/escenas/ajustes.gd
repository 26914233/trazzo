# Ajustes: sonido, vibracion, tamaño de letra, privacidad.
extends Control

## Pagina publica de privacidad (la web de Curtzz, GitHub Pages). Verificar
## la URL definitiva antes de subir: Play la exige y debe responder.
const URL_PRIVACIDAD := "https://26914233.github.io/trazzo/sopazz-privacidad.html"


func _ready() -> void:
	var col := Estilo.pantalla(self)
	var barra := HBoxContainer.new()
	var atras := Estilo.boton("‹", Estilo.TARJETA, 120)
	atras.custom_minimum_size.x = 120
	atras.pressed.connect(func(): Estilo.ir(self, "menu"))
	barra.add_child(atras)
	barra.add_child(Estilo.etiqueta("Ajustes", 64, Estilo.TEXTO, false, false))
	col.add_child(barra)

	col.add_child(_interruptor("Sonido", "sonido"))
	col.add_child(_interruptor("Vibración", "vibracion"))

	# Tamaño de letra como opciones grandes: un deslizador es incomodo con el
	# pulgar y el de Godot por defecto se ve diminuto a esta resolucion.
	col.add_child(Estilo.etiqueta("Tamaño de las letras del tablero", 44, Estilo.TEXTO, false))
	var tamanos := HBoxContainer.new()
	tamanos.add_theme_constant_override("separation", 12)
	var opciones := [["A", 0.85], ["A", 1.0], ["A", 1.15], ["A", 1.3]]
	var botones: Array[Button] = []
	for i in opciones.size():
		var b := Estilo.boton(opciones[i][0], Estilo.TARJETA, 130)
		b.add_theme_font_size_override("font_size", int(36 + i * 12))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		botones.append(b)
		tamanos.add_child(b)
	var pintar := func() -> void:
		var actual := float(Progreso.ajuste("escala_texto"))
		for i in botones.size():
			var elegido := absf(opciones[i][1] - actual) < 0.01
			_colorear(botones[i], Estilo.SECUNDARIO if elegido else Estilo.TARJETA, Color.WHITE if elegido else Estilo.TEXTO)
	for i in botones.size():
		botones[i].pressed.connect(func():
			Progreso.fijar_ajuste("escala_texto", opciones[i][1])
			pintar.call())
	pintar.call()
	col.add_child(tamanos)

	var hueco := Control.new()
	hueco.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(hueco)

	var privacidad := Estilo.boton("Política de privacidad", Estilo.TARJETA, 130)
	privacidad.pressed.connect(func(): OS.shell_open(URL_PRIVACIDAD))
	col.add_child(privacidad)
	var restaurar := Estilo.boton("Restaurar compras", Estilo.TARJETA, 130)
	restaurar.pressed.connect(func():
		var n := await Monetizacion.restaurar_compras()
		Estilo.aviso(self, "Compras restauradas: %d" % n if n > 0 else "No hay compras que restaurar."))
	col.add_child(restaurar)
	var version := str(ProjectSettings.get_setting("application/config/version", "1.0.0"))
	col.add_child(Estilo.etiqueta("Sopazz %s · thunderDarkness" % version, 34, Estilo.TEXTO_SUAVE))


func _interruptor(texto: String, clave: String) -> Button:
	var b := Estilo.boton("", Estilo.TARJETA, 140)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var pintar := func() -> void:
		var on := bool(Progreso.ajuste(clave))
		b.text = "%s:  %s" % [texto, "Activado" if on else "Desactivado"]
		_colorear(b, Estilo.PRIMARIO if on else Estilo.BLOQUEADO, Estilo.TEXTO)
	b.pressed.connect(func():
		Progreso.fijar_ajuste(clave, not bool(Progreso.ajuste(clave)))
		pintar.call())
	pintar.call()
	return b


func _colorear(b: Button, fondo: Color, texto: Color) -> void:
	for estado in ["normal", "hover", "pressed", "hover_pressed"]:
		b.add_theme_stylebox_override(estado, Estilo.caja(fondo))
	for estado in ["font_color", "font_pressed_color", "font_hover_color", "font_focus_color"]:
		b.add_theme_color_override(estado, texto)


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		Estilo.ir(self, "menu")
