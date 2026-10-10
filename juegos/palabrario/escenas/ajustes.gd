# Ajustes: diseño, sonido, vibracion, tamaño de letra, privacidad.
extends Control

## Pagina publica de privacidad (la web de Curtzz, GitHub Pages). Verificar
## la URL definitiva antes de subir: Play la exige y debe responder.
const URL_PRIVACIDAD := "https://26914233.github.io/trazzo/palabrario-privacidad.html"


func _ready() -> void:
	var col := Estilo.pantalla(self)
	Estilo.barra(col, "Ajustes", func(): Estilo.ir(self, "menu"))

	col.add_child(Estilo.etiqueta("Diseño", 38, Estilo.TEXTO_SUAVE, false))
	var disenos := HBoxContainer.new()
	disenos.add_theme_constant_override("separation", 14)
	for id in Estilo.VARIANTES:
		var elegido: bool = id == Estilo.actual
		var b := Estilo.boton(Estilo.VARIANTES[id]["nombre"], "primario" if elegido else "normal", 120)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.add_theme_font_size_override("font_size", 38)
		b.pressed.connect(func():
			Progreso.fijar_ajuste("diseno", id)
			Estilo.aplicar(id)
			Estilo.ir(self, "ajustes"))
		disenos.add_child(b)
	col.add_child(disenos)

	col.add_child(_interruptor("Sonido", "sonido"))
	col.add_child(_interruptor("Vibración", "vibracion"))
	col.add_child(_interruptor("Contrarreloj", "contrarreloj"))

	col.add_child(Estilo.etiqueta("Tamaño de las letras del tablero", 38, Estilo.TEXTO_SUAVE, false))
	var tamanos := HBoxContainer.new()
	tamanos.add_theme_constant_override("separation", 14)
	var actual := float(Progreso.ajuste("escala_texto"))
	for i in Progreso.ESCALAS.size():
		var escala: float = Progreso.ESCALAS[i]
		var b := Estilo.boton("A", "primario" if absf(escala - actual) < 0.01 else "normal", 120)
		b.add_theme_font_size_override("font_size", int(34 + i * 12))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(func():
			Progreso.fijar_ajuste("escala_texto", escala)
			Estilo.ir(self, "ajustes"))
		tamanos.add_child(b)
	col.add_child(tamanos)

	var hueco := Control.new()
	hueco.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(hueco)
	var privacidad := Estilo.boton("Política de privacidad", "normal", 124)
	privacidad.pressed.connect(func(): OS.shell_open(URL_PRIVACIDAD))
	col.add_child(privacidad)
	var version := str(ProjectSettings.get_setting("application/config/version", "1.0.0"))
	var nombre := str(ProjectSettings.get_setting("application/config/name"))
	col.add_child(Estilo.etiqueta("%s %s · thunderDarkness" % [nombre, version], 32, Estilo.TEXTO_SUAVE))


func _interruptor(texto: String, clave: String) -> Button:
	var b := Estilo.boton("", "normal", 130)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var pintar := func() -> void:
		var on := bool(Progreso.ajuste(clave))
		b.text = "%s:  %s" % [texto, "Activado" if on else "Desactivado"]
		Estilo.colorear(b, Estilo.SUPERFICIE if on else Estilo.BLOQUEADO, Estilo.TEXTO if on else Estilo.TEXTO_SUAVE)
	b.pressed.connect(func():
		Progreso.fijar_ajuste(clave, not bool(Progreso.ajuste(clave)))
		pintar.call())
	pintar.call()
	return b


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		Estilo.ir(self, "menu")
