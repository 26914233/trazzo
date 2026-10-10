# Menu principal: sopa del dia, continuar, jugar y ajustes.
extends Control

static var _dia_registrado := ""


func _ready() -> void:
	var hoy := Progreso.hoy()
	var racha: int = int(Progreso.datos["racha"])
	if _dia_registrado != hoy:
		_dia_registrado = hoy
		racha = Progreso.registrar_dia(hoy)

	var col := Estilo.columna_desplazable(Estilo.pantalla(self))
	var arriba := HBoxContainer.new()
	if racha > 1:
		arriba.add_child(Estilo.etiqueta("Racha: %d días" % racha, 36, Estilo.ACENTO, false, false))
	col.add_child(arriba)

	var hueco := Control.new()
	hueco.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(hueco)
	# El nombre sale de project.godot (application/config/name): un solo sitio.
	col.add_child(Estilo.titulo(str(ProjectSettings.get_setting("application/config/name")), 150, true))
	col.add_child(Estilo.etiqueta("%d sopas de letras en español" % Temas.total_sopas(), 42, Estilo.TEXTO_SUAVE))
	var hueco2 := Control.new()
	hueco2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(hueco2)

	col.add_child(_tarjeta_del_dia(hoy))
	var ev := Eventos.activo(hoy)
	if not ev.is_empty():
		col.add_child(_tarjeta_evento(ev, hoy))

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
	jugar.pressed.connect(func(): Estilo.ir(self, "mapa"))
	col.add_child(jugar)

	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 20)
	var azar := Estilo.boton("Al azar", "normal", 130)
	azar.pressed.connect(func():
		Temas.seleccion = Temas.nueva_aleatoria(int(Progreso.ajuste("dificultad")))
		Estilo.ir(self, "juego"))
	var logros := Estilo.boton("Logros", "normal", 130)
	logros.pressed.connect(func(): Estilo.ir(self, "logros"))
	var ajustes := Estilo.boton("Ajustes", "normal", 130)
	ajustes.pressed.connect(func(): Estilo.ir(self, "ajustes"))
	for b in [azar, logros, ajustes]:
		b.add_theme_font_size_override("font_size", 40)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.add_child(b)
	col.add_child(fila)
	col.add_child(Estilo.etiqueta("%d de %d sopas resueltas" % [Progreso.resueltas_total(), Temas.total_sopas()], 34, Estilo.TEXTO_SUAVE))

	Estilo.permitir_arrastre(col)
	# Si el guardado se descarto al abrir, se dice una vez en vez de borrar
	# el progreso en silencio (SEC-007).
	if Progreso.ultimo_rechazo != "":
		Progreso.ultimo_rechazo = ""
		Estilo.aviso(self, "No se pudo leer tu progreso guardado. Empiezas de cero.")
	elif Progreso.comodin_recien_usado:
		Progreso.comodin_recien_usado = false
		Estilo.aviso(self, "Ayer no jugaste: usaste el comodín de la semana y tu racha sigue.")


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
		var estado := "Resuelta. Vuelve mañana" if hecha else "%s · una nueva cada día" % cat["nombre"]
		v.add_child(Estilo.etiqueta(estado, 36, Estilo.TEXTO_SUAVE, false))
	for h in v.get_children():
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t[0]


func _tarjeta_evento(ev: Dictionary, hoy: String) -> Button:
	var t := Estilo.tarjeta(150, Estilo.SUPERFICIE, func(): Estilo.ir(self, "evento"))
	var v: VBoxContainer = t[1]
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	var dias := Eventos.dias_restantes(ev, hoy)
	var cabecera := "EVENTO · " + ("último día" if dias <= 1 else "quedan %d días" % dias)
	v.add_child(Estilo.etiqueta(cabecera, 30, Estilo.TEXTO_SUAVE, false))
	var hecho := Progreso.evento_hecho(ev)
	var linea := "%s  ·  %s" % [ev["nombre"], "completado ✓" if hecho else "%d de %d" % [Progreso.avance_evento(ev), ev["sopas"].size()]]
	var titulo := Estilo.titulo(linea, 44)
	titulo.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	titulo.clip_text = true
	v.add_child(titulo)
	for h in v.get_children():
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t[0]


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
