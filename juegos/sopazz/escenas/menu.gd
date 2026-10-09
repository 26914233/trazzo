# Menu principal: titulo, fichas, racha y acceso a todo lo demas.
extends Control

static var _dia_registrado := ""


func _ready() -> void:
	var col := Estilo.pantalla(self)
	var arriba := HBoxContainer.new()
	arriba.alignment = BoxContainer.ALIGNMENT_END
	arriba.add_child(Estilo.pildora_fichas())
	col.add_child(arriba)

	var hueco := Control.new()
	hueco.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(hueco)
	col.add_child(Estilo.etiqueta("SOPAZZ", 170, Estilo.TEXTO))
	col.add_child(Estilo.etiqueta("Arrastra el dedo. Encuentra las palabras.", 46, Estilo.TEXTO_SUAVE))
	var racha := int(Progreso.datos["racha"])
	if racha > 1:
		col.add_child(Estilo.etiqueta("Racha: %d días seguidos" % racha, 46, Estilo.PRIMARIO))
	var hueco2 := Control.new()
	hueco2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(hueco2)

	var jugar := Estilo.boton("Jugar", Estilo.PRIMARIO, 190)
	jugar.add_theme_font_size_override("font_size", 70)
	jugar.pressed.connect(func(): Estilo.ir(self, "selector"))
	col.add_child(jugar)

	var hoy := Progreso.hoy()
	var diario := Estilo.boton("Nivel del día  ·  premio doble", Estilo.ORO, 160)
	if Progreso.diario_hecho(hoy):
		diario.text = "Nivel del día  ·  hecho, vuelve mañana"
		diario.disabled = true
	diario.pressed.connect(func():
		# Tema rotativo entre los gratis, para que todos puedan jugarlo.
		var gratis := Temas.lista.filter(func(t): return t.get("gratis", false))
		var tema: Dictionary = gratis[absi(Temas.semilla_diaria(hoy)) % gratis.size()]
		Temas.seleccion = {"tema": tema["id"], "dificultad": 1, "nivel": 0, "diario": true}
		Estilo.ir(self, "juego"))
	col.add_child(diario)

	var fila := HBoxContainer.new()
	var tienda := Estilo.boton("Tienda")
	tienda.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tienda.pressed.connect(func(): Estilo.ir(self, "tienda"))
	var ajustes := Estilo.boton("Ajustes")
	ajustes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ajustes.pressed.connect(func(): Estilo.ir(self, "ajustes"))
	fila.add_child(tienda)
	fila.add_child(ajustes)
	col.add_child(fila)

	# Recompensa de racha: una vez por dia y por sesion de la app.
	if _dia_registrado != hoy:
		_dia_registrado = hoy
		var premio := Progreso.registrar_dia(hoy)
		if premio > 0:
			Estilo.aviso.call_deferred(self, "Día %d de racha: +%d fichas" % [int(Progreso.datos["racha"]), premio])


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
