# Pantalla de partida: tablero, lista de palabras, pista y victoria.
extends Control

var _sopa: GeneradorSopa.Sopa
var _tema: Dictionary
var _color: Color
var _sel: Dictionary
var _encontradas := {}            ## palabra normalizada -> true
var _segundos := 0.0
var _pistas_usadas := 0
var _terminado := false
var _hoy := Progreso.hoy()

var _tablero: Tablero
var _lista: RichTextLabel
var _reloj: Label
var _contador: Label
var _boton_pista: Button


func _ready() -> void:
	_sel = Temas.seleccion
	_tema = Temas.tema(_sel["tema"])
	_color = Color(_tema.get("color", "#EC4899"))
	var semilla: int
	if _sel["diario"]:
		semilla = Temas.semilla_diaria(_hoy)
	else:
		semilla = Temas.semilla_nivel(_sel["tema"], _sel["dificultad"], _sel["nivel"])
	_sopa = Temas.generar_nivel(_sel["tema"], _sel["dificultad"], semilla)
	_construir()


func _construir() -> void:
	var col := Estilo.pantalla(self)

	var barra := HBoxContainer.new()
	var atras := Estilo.boton("‹", Estilo.TARJETA, 120)
	atras.custom_minimum_size.x = 120
	atras.pressed.connect(_salir)
	barra.add_child(atras)
	var titulo := VBoxContainer.new()
	titulo.add_theme_constant_override("separation", 0)
	titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var nombre := "Nivel del día" if _sel["diario"] else "%s · Nivel %d" % [_tema.get("nombre", ""), _sel["nivel"]]
	titulo.add_child(Estilo.etiqueta(nombre, 50, Estilo.TEXTO, false))
	_reloj = Estilo.etiqueta("0:00", 40, Estilo.TEXTO_SUAVE, false)
	titulo.add_child(_reloj)
	barra.add_child(titulo)
	barra.add_child(Estilo.pildora_fichas())
	col.add_child(barra)

	_tablero = Tablero.new()
	_tablero.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tablero.custom_minimum_size = Vector2(0, 900)
	_tablero.escala_texto = float(Progreso.ajuste("escala_texto"))
	_tablero.seleccion_hecha.connect(_al_seleccionar)
	col.add_child(_tablero)
	_tablero.preparar(_sopa, _color)

	_contador = Estilo.etiqueta("", 40, Estilo.TEXTO_SUAVE)
	col.add_child(_contador)
	_lista = RichTextLabel.new()
	_lista.bbcode_enabled = true
	_lista.fit_content = true
	_lista.scroll_active = false
	_lista.add_theme_font_size_override("normal_font_size", 46)
	_lista.add_theme_font_size_override("bold_font_size", 46)
	col.add_child(_lista)

	_boton_pista = Estilo.boton("", Estilo.ORO, 150)
	_boton_pista.pressed.connect(_pedir_pista)
	col.add_child(_boton_pista)
	_refrescar()


func _process(delta: float) -> void:
	if _terminado:
		return
	_segundos += delta
	_reloj.text = "%d:%02d" % [int(_segundos) / 60, int(_segundos) % 60]


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		_salir()


func _refrescar() -> void:
	var partes: PackedStringArray = []
	for c in _sopa.colocadas:
		if _encontradas.has(c.palabra):
			partes.append("[color=#%s][s]%s[/s][/color]" % [_color.darkened(0.35).to_html(false), c.original])
		else:
			partes.append("[b]%s[/b]" % c.original)
	_lista.text = "[center]" + "   ".join(partes) + "[/center]"
	_contador.text = "%d de %d palabras" % [_encontradas.size(), _sopa.colocadas.size()]
	if Progreso.pistas_gratis() > 0:
		_boton_pista.text = "Pista  ·  %d gratis" % Progreso.pistas_gratis()
	elif Progreso.fichas() >= Economia.COSTE_PISTA:
		_boton_pista.text = "Pista  ·  %d fichas" % Economia.COSTE_PISTA
	else:
		_boton_pista.text = "Pista  ·  ver anuncio"


# ---------------------------------------------------------------- jugar

func _al_seleccionar(celdas: Array[Vector2i]) -> void:
	var c := _sopa.buscar_en(celdas)
	if c == null or _encontradas.has(c.palabra):
		_tablero.sacudir()
		Sonido.tocar("error")
		return
	_encontradas[c.palabra] = true
	_tablero.marcar_encontrada(c.celdas, _color)
	Sonido.tocar("acierto")
	Sonido.vibrar(25)
	_refrescar()
	if _encontradas.size() == _sopa.colocadas.size():
		_victoria()


func _pedir_pista() -> void:
	if _terminado:
		return
	var falta: GeneradorSopa.Colocada = null
	for c in _sopa.colocadas:
		if not _encontradas.has(c.palabra):
			falta = c
			break
	if falta == null:
		return
	var pago := Progreso.pagar_pista()
	if pago == "":
		var elegido := await Estilo.dialogo(self, "¿Una pista?",
			"Mira un anuncio corto y te marcamos dónde empieza una palabra.",
			["Ver anuncio", "Comprar fichas", "Ahora no"])
		if elegido == 1:
			Estilo.ir(self, "tienda")
			return
		if elegido != 0:
			return
		_boton_pista.disabled = true
		var visto := await Monetizacion.mostrar_premiado()
		_boton_pista.disabled = false
		if not visto:
			# Que una mala conexion no deje a nadie atascado: una de cortesia al dia.
			if Progreso.usar_cortesia(_hoy):
				Estilo.aviso(self, "El anuncio no cargó. Esta pista va por nuestra cuenta.")
			else:
				Estilo.aviso(self, "El anuncio no cargó. Inténtalo en un momento.")
				return
	_pistas_usadas += 1
	_tablero.mostrar_pista(falta.celdas[0])
	_refrescar()


func _salir() -> void:
	if _terminado:
		_ir_tras_nivel("menu")
		return
	var elegido := await Estilo.dialogo(self, "¿Salir del nivel?", "Perderás lo que llevas de esta sopa.", ["Seguir jugando", "Salir"])
	if elegido == 1:
		# Nunca intersticial tras abandonar: castigar al que se frustra es perderlo.
		Estilo.ir(self, "selector")


# ---------------------------------------------------------------- victoria

func _victoria() -> void:
	_terminado = true
	_tablero.activo = false
	Sonido.tocar("victoria")
	Sonido.vibrar(60)
	var n := _sopa.colocadas.size()
	var estrellas := Economia.estrellas(_segundos, n, _pistas_usadas)
	var ganadas := Progreso.completar_nivel(_sel["tema"], _sel["dificultad"], _sel["nivel"], estrellas, _sel["diario"], _hoy)
	Monetizacion.nivel_completado()
	await get_tree().create_timer(0.6).timeout
	_panel_victoria(estrellas, ganadas)


func _panel_victoria(estrellas: int, ganadas: int) -> void:
	var velo := ColorRect.new()
	velo.color = Color(Estilo.TEXTO, 0.55)
	velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(velo)
	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	velo.add_child(centro)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(920, 0)
	centro.add_child(panel)
	var col := VBoxContainer.new()
	panel.add_child(col)

	col.add_child(Estilo.etiqueta("¡Sopa resuelta!", 72))
	var est := Estilo.etiqueta("★".repeat(estrellas) + "☆".repeat(3 - estrellas), 120, Estilo.ORO)
	col.add_child(est)
	col.add_child(Estilo.etiqueta("%d:%02d  ·  %d pistas" % [int(_segundos) / 60, int(_segundos) % 60, _pistas_usadas], 44, Estilo.TEXTO_SUAVE))
	var premio := Estilo.etiqueta("+%d fichas" % ganadas, 60)
	col.add_child(premio)

	var duplicar := Estilo.boton("Duplicar con un anuncio", Estilo.ORO, 140)
	duplicar.pressed.connect(func():
		duplicar.disabled = true
		if await Monetizacion.mostrar_premiado():
			Progreso.sumar_fichas(ganadas)
			premio.text = "+%d fichas" % (ganadas * 2)
			duplicar.text = "¡Duplicado!"
		else:
			duplicar.text = "El anuncio no cargó"
	)
	col.add_child(duplicar)

	if not _sel["diario"]:
		var siguiente := Estilo.boton("Siguiente nivel", Estilo.PRIMARIO, 160)
		siguiente.pressed.connect(func():
			Temas.seleccion["nivel"] = _sel["nivel"] + 1
			_ir_tras_nivel("juego"))
		col.add_child(siguiente)
	var menu := Estilo.boton("Menú", Estilo.TARJETA, 130)
	menu.pressed.connect(func(): _ir_tras_nivel("menu"))
	col.add_child(menu)

	panel.scale = Vector2(0.85, 0.85)
	panel.pivot_offset = panel.custom_minimum_size / 2.0
	var tw := panel.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.28)


## Entre niveles (nunca durante uno) es el unico sitio del intersticial;
## las reglas deciden si toca.
func _ir_tras_nivel(destino: String) -> void:
	await Monetizacion.intentar_intersticial()
	Estilo.ir(self, destino)
