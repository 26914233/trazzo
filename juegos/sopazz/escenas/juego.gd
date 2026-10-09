# Pantalla de partida: tablero, lista de palabras, pista y victoria.
extends Control

var _sopa: GeneradorSopa.Sopa
var _cat: Dictionary
var _sub: Dictionary
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
	_cat = Temas.categoria(_sel["categoria"])
	_sub = Temas.subtema(_sel["categoria"], _sel["subtema"])
	_color = Color(_cat.get("color", "#A16207"))
	_sopa = Temas.generar(_sel["categoria"], _sel["subtema"], _sel["dificultad"])
	if not _sel["diario"]:
		Progreso.fijar_ultima(_sel["categoria"], _sel["subtema"])
	_construir()


func _construir() -> void:
	var col := Estilo.pantalla(self)
	_reloj = Estilo.etiqueta("0:00", 40, Estilo.TEXTO_SUAVE, false, false)
	Estilo.barra(col, _sub.get("nombre", ""), _salir, _reloj)
	var detalle: String = "Sopa del día" if _sel["diario"] else _cat.get("nombre", "")
	col.add_child(Estilo.etiqueta("%s · %s" % [detalle, Economia.DIFICULTADES[_sel["dificultad"]]["nombre"]], 34, Estilo.TEXTO_SUAVE, false))

	_tablero = Tablero.new()
	_tablero.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tablero.custom_minimum_size = Vector2(0, 900)
	_tablero.escala_texto = float(Progreso.ajuste("escala_texto"))
	_tablero.seleccion_hecha.connect(_al_seleccionar)
	col.add_child(_tablero)
	_tablero.preparar(_sopa, _color)

	_contador = Estilo.etiqueta("", 34, Estilo.TEXTO_SUAVE)
	col.add_child(_contador)
	_lista = RichTextLabel.new()
	_lista.bbcode_enabled = true
	_lista.fit_content = true
	_lista.scroll_active = false
	_lista.add_theme_font_size_override("normal_font_size", 42)
	_lista.add_theme_font_size_override("bold_font_size", 42)
	col.add_child(_lista)

	_boton_pista = Estilo.boton("", "acento", 140)
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
	var hecho := Estilo.TEXTO_SUAVE.to_html(false)
	for c in _sopa.colocadas:
		var texto := Estilo.escapar_bbcode(c.original)
		if _encontradas.has(c.palabra):
			partes.append("[color=#%s][s]%s[/s][/color]" % [hecho, texto])
		else:
			partes.append("[b]%s[/b]" % texto)
	_lista.text = "[center]" + "    ".join(partes) + "[/center]"
	_contador.text = "%d de %d palabras" % [_encontradas.size(), _sopa.colocadas.size()]
	if Progreso.es_premium():
		_boton_pista.text = "Pista"
	elif Progreso.pistas_restantes(_hoy) > 0:
		_boton_pista.text = "Pista  ·  %d gratis hoy" % Progreso.pistas_restantes(_hoy)
	else:
		_boton_pista.text = "Pista  ·  ver un anuncio"


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
	if Progreso.pagar_pista(_hoy) == "":
		var elegido := await Estilo.dialogo(self, "¿Otra pista?",
			"Ya usaste las %d pistas gratis de hoy. Mira un anuncio corto, o desbloquea el juego completo para tener pistas ilimitadas." % Economia.PISTAS_GRATIS_DIA,
			["Ver anuncio", "Juego completo", "Ahora no"])
		if elegido == 1:
			Estilo.ir(self, "completo")
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
		_ir_tras_sopa("menu" if _sel["diario"] else "sopas")
		return
	var elegido := await Estilo.dialogo(self, "¿Salir de la sopa?", "Perderás lo que llevas.", ["Seguir jugando", "Salir"])
	if elegido == 1:
		# Nunca intersticial tras abandonar: castigar al que se frustra es perderlo.
		Estilo.ir(self, "menu" if _sel["diario"] else "sopas")


# ---------------------------------------------------------------- victoria

func _victoria() -> void:
	_terminado = true
	_tablero.activo = false
	Sonido.tocar("victoria")
	Sonido.vibrar(60)
	var estrellas := Economia.estrellas(_segundos, _sopa.colocadas.size(), _pistas_usadas)
	Progreso.registrar_victoria(_sel["categoria"], _sel["subtema"], _sel["dificultad"], estrellas, _sel["diario"], _hoy)
	Monetizacion.nivel_completado()
	await get_tree().create_timer(0.6).timeout
	_panel_victoria(estrellas)


func _panel_victoria(estrellas: int) -> void:
	var m := Estilo.modal(self)
	var col: VBoxContainer = m[1]
	col.add_child(Estilo.titulo("¡Sopa resuelta!", 68, true))
	col.add_child(Estilo.etiqueta(Estilo.estrellas_texto(estrellas), 120, Estilo.ACENTO))
	col.add_child(Estilo.etiqueta("%d:%02d  ·  %d %s" % [int(_segundos) / 60, int(_segundos) % 60, _pistas_usadas, "pista" if _pistas_usadas == 1 else "pistas"], 40, Estilo.TEXTO_SUAVE))
	if not _sel["diario"]:
		var sig := Temas.siguiente(_sel["categoria"], _sel["subtema"])
		if not sig.is_empty():
			var boton_sig := Estilo.boton("Siguiente sopa", "primario", 150)
			boton_sig.pressed.connect(func():
				if not Progreso.desbloqueada(sig["categoria"], sig["subtema"]):
					_ir_tras_sopa("completo")
					return
				Temas.seleccion = {"categoria": sig["categoria"], "subtema": sig["subtema"], "dificultad": _sel["dificultad"], "diario": false}
				_ir_tras_sopa("juego"))
			col.add_child(boton_sig)
	var volver := Estilo.boton("Volver al menú" if _sel["diario"] else "Volver al tema", "suave", 130)
	volver.pressed.connect(func(): _ir_tras_sopa("menu" if _sel["diario"] else "sopas"))
	col.add_child(volver)


## Entre sopas (nunca durante una) es el unico sitio del intersticial;
## las reglas deciden si toca.
func _ir_tras_sopa(destino: String) -> void:
	await Monetizacion.intentar_intersticial()
	Estilo.ir(self, destino)
