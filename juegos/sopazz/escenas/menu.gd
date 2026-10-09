# Menu principal: sopa del dia, continuar, jugar, version completa y ajustes.
extends Control

static var _dia_registrado := ""


func _ready() -> void:
	var hoy := Progreso.hoy()
	var racha: int = int(Progreso.datos["racha"])
	if _dia_registrado != hoy:
		_dia_registrado = hoy
		racha = Progreso.registrar_dia(hoy)

	var col := Estilo.pantalla(self)
	var arriba := HBoxContainer.new()
	if racha > 1:
		arriba.add_child(Estilo.etiqueta("Racha: %d días" % racha, 36, Estilo.ACENTO, false, false))
	col.add_child(arriba)

	var hueco := Control.new()
	hueco.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(hueco)
	col.add_child(Estilo.titulo("Sopazz", 168, true))
	col.add_child(Estilo.etiqueta("%d sopas de letras en español" % Temas.total_sopas(), 42, Estilo.TEXTO_SUAVE))
	var hueco2 := Control.new()
	hueco2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(hueco2)

	col.add_child(_tarjeta_del_dia(hoy))

	var u := Progreso.ultima()
	if not u.is_empty() and not Temas.subtema(u["categoria"], u["subtema"]).is_empty():
		var nombre: String = Temas.subtema(u["categoria"], u["subtema"])["nombre"]
		var seguir := Estilo.boton("Continuar: %s" % nombre, "normal", 140)
		seguir.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		seguir.pressed.connect(func():
			Temas.seleccion["categoria"] = u["categoria"]
			Estilo.ir(self, "sopas"))
		col.add_child(seguir)

	var jugar := Estilo.boton("Jugar", "primario", 170)
	jugar.add_theme_font_size_override("font_size", 60)
	jugar.pressed.connect(func(): Estilo.ir(self, "categorias"))
	col.add_child(jugar)

	var fila := HBoxContainer.new()
	var completo := Estilo.boton("Completo ✓" if Progreso.es_premium() else "Desbloquear todo", "normal", 130)
	completo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	completo.add_theme_font_size_override("font_size", 40)
	completo.pressed.connect(func(): Estilo.ir(self, "completo"))
	var ajustes := Estilo.boton("Ajustes", "normal", 130)
	ajustes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ajustes.add_theme_font_size_override("font_size", 40)
	ajustes.pressed.connect(func(): Estilo.ir(self, "ajustes"))
	fila.add_child(completo)
	fila.add_child(ajustes)
	col.add_child(fila)
	col.add_child(Estilo.etiqueta("%d de %d sopas resueltas" % [Progreso.resueltas_total(), Temas.total_sopas()], 34, Estilo.TEXTO_SUAVE))


func _tarjeta_del_dia(hoy: String) -> Button:
	var d := Temas.sopa_del_dia(hoy)
	var hecha := Progreso.diario_hecho(hoy)
	var t := Estilo.tarjeta(230, Estilo.tinte(Estilo.ACENTO), func():
		if hecha or d.is_empty():
			return
		Temas.seleccion = {"categoria": d["categoria"], "subtema": d["subtema"], "dificultad": 1, "diario": true}
		Estilo.ir(self, "juego"))
	var v: VBoxContainer = t[1]
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(Estilo.etiqueta("SOPA DEL DÍA", 32, Estilo.TEXTO_SUAVE, false))
	if not d.is_empty():
		var cat := Temas.categoria(d["categoria"])
		var sub := Temas.subtema(d["categoria"], d["subtema"])
		v.add_child(Estilo.titulo(sub["nombre"], 56))
		var estado := "Resuelta. Vuelve mañana" if hecha else "%s · gratis para todos" % cat["nombre"]
		v.add_child(Estilo.etiqueta(estado, 36, Estilo.TEXTO_SUAVE, false))
	for h in v.get_children():
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t[0]


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
