# Seleccion de dificultad y tema. Los temas de pago se desbloquean con
# fichas o con compra directa.
extends Control

var _dificultad := 0
var _rejilla: GridContainer
var _botones_dif: Array[Button] = []
const GANAR_PARA_DIFICIL := 3   ## el juego no se pone dificil hasta ganar 3 veces


func _ready() -> void:
	_dificultad = int(Temas.seleccion.get("dificultad", 0))
	if not _dificultad_abierta(_dificultad):
		_dificultad = 0
	var col := Estilo.pantalla(self)

	var barra := HBoxContainer.new()
	var atras := Estilo.boton("‹", Estilo.TARJETA, 120)
	atras.custom_minimum_size.x = 120
	atras.pressed.connect(func(): Estilo.ir(self, "menu"))
	barra.add_child(atras)
	var t := Estilo.etiqueta("Elige tema", 64, Estilo.TEXTO, false)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	barra.add_child(t)
	barra.add_child(Estilo.pildora_fichas())
	col.add_child(barra)

	var difs := HBoxContainer.new()
	difs.add_theme_constant_override("separation", 12)
	for i in Economia.DIFICULTADES.size():
		var b := Estilo.boton(Economia.DIFICULTADES[i]["nombre"], Estilo.TARJETA, 120)
		b.add_theme_font_size_override("font_size", 38)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.toggle_mode = true
		b.pressed.connect(_elegir_dificultad.bind(i))
		_botones_dif.append(b)
		difs.add_child(b)
	col.add_child(difs)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	_rejilla = GridContainer.new()
	_rejilla.columns = 2
	_rejilla.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rejilla.add_theme_constant_override("h_separation", 24)
	_rejilla.add_theme_constant_override("v_separation", 24)
	scroll.add_child(_rejilla)
	_pintar()


func _dificultad_abierta(i: int) -> bool:
	return i == 0 or Progreso.niveles_completados() >= GANAR_PARA_DIFICIL


func _elegir_dificultad(i: int) -> void:
	if not _dificultad_abierta(i):
		Estilo.aviso(self, "Gana %d niveles para desbloquear %s." % [GANAR_PARA_DIFICIL, Economia.DIFICULTADES[i]["nombre"]])
	else:
		_dificultad = i
	_pintar()


func _pintar() -> void:
	for i in _botones_dif.size():
		var b := _botones_dif[i]
		b.set_pressed_no_signal(i == _dificultad)
		var fondo := Estilo.SECUNDARIO if i == _dificultad else (Estilo.TARJETA if _dificultad_abierta(i) else Estilo.BLOQUEADO)
		var texto := Color.WHITE if i == _dificultad else Estilo.TEXTO
		for estado in ["normal", "hover", "pressed", "hover_pressed"]:
			b.add_theme_stylebox_override(estado, Estilo.caja(fondo))
		for estado in ["font_color", "font_pressed_color", "font_hover_color", "font_hover_pressed_color", "font_focus_color"]:
			b.add_theme_color_override(estado, texto)
	for hijo in _rejilla.get_children():
		hijo.queue_free()
	for tema in Temas.lista:
		_rejilla.add_child(_tarjeta(tema))


func _tarjeta(tema: Dictionary) -> Button:
	var id: String = tema["id"]
	var abierto := Progreso.tema_desbloqueado(id)
	var color := Color(tema.get("color", "#EC4899"))
	var nivel := Progreso.nivel_actual(id, _dificultad)
	var b := Estilo.boton("", color.lightened(0.55) if abierto else Estilo.BLOQUEADO, 260)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var detalle := "Nivel %d" % nivel if abierto else "%d fichas o %s" % [Economia.COSTE_TEMA, Monetizacion.PRECIO_TEMA]
	b.text = "%s\n%s" % [tema["nombre"], detalle if abierto else "Bloqueado\n" + detalle]
	b.add_theme_font_size_override("font_size", 44)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.pressed.connect(func(): _abrir(tema, abierto))
	return b


func _abrir(tema: Dictionary, abierto: bool) -> void:
	var id: String = tema["id"]
	if not abierto:
		var elegido := await Estilo.dialogo(self, tema["nombre"], "Tema de pago. ¿Cómo quieres desbloquearlo?",
			["Usar %d fichas" % Economia.COSTE_TEMA, "Comprar por %s" % Monetizacion.PRECIO_TEMA, "Cancelar"])
		if elegido == 0:
			if not Progreso.desbloquear_con_fichas(id):
				Estilo.aviso(self, "Te faltan fichas. Las ganas jugando o en la tienda.")
				return
		elif elegido == 1:
			if not await Monetizacion.comprar("tema_" + id):
				Estilo.aviso(self, "La compra no se completó. No se te ha cobrado.")
				return
		else:
			return
		_pintar()
		return
	Temas.seleccion = {"tema": id, "dificultad": _dificultad, "nivel": Progreso.nivel_actual(id, _dificultad), "diario": false}
	Estilo.ir(self, "juego")


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		Estilo.ir(self, "menu")
