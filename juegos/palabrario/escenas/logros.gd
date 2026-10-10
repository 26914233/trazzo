# Estadisticas y logros (calculados del progreso, ver scripts/logros.gd).
extends Control


func _ready() -> void:
	var col := Estilo.pantalla(self)
	Estilo.barra(col, "Logros", func(): Estilo.ir(self, "menu"))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	var lista := VBoxContainer.new()
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lista.add_theme_constant_override("separation", 18)
	scroll.add_child(lista)

	var d := Progreso.datos
	lista.add_child(Estilo.titulo("Estadísticas", 48))
	var rejilla := GridContainer.new()
	rejilla.columns = 2
	rejilla.add_theme_constant_override("h_separation", 18)
	rejilla.add_theme_constant_override("v_separation", 18)
	var racha := "%d (mejor %d)" % [int(d["racha"]), int(d["racha_max"])]
	var comodin := "Disponible" if Economia.comodin_disponible(d["comodin_usado"], Progreso.hoy()) else "Usado esta semana"
	for dato in [
		["Sopas resueltas", "%d de %d" % [Progreso.resueltas_total(), Temas.total_sopas()]],
		["Partidas ganadas", str(Progreso.completadas())],
		["Racha", racha],
		["Comodín de racha", comodin],
		["Sopas del día", str(int(d["diarias"]))],
		["Sopas al azar", str(int(d["aleatorias"]))],
		["Palabras encontradas", str(int(d["palabras"]))],
		["Pistas usadas", str(int(d["pistas_usadas"]))],
		["Palabras extra", str(int(d["extras"]))],
		["Ganadas a contrarreloj", str(int(d["reloj_ganadas"]))],
	]:
		rejilla.add_child(_dato(dato[0], dato[1]))
	lista.add_child(rejilla)
	var tiempos := PackedStringArray()
	for i in Economia.DIFICULTADES.size():
		var t := int(d["mejor_tiempo"][i])
		tiempos.append("%s %s" % [Economia.DIFICULTADES[i]["nombre"], "%d:%02d" % [t / 60, t % 60] if t > 0 else "—"])
	lista.add_child(Estilo.etiqueta("Mejor tiempo: " + " · ".join(tiempos), 34, Estilo.TEXTO_SUAVE, false))

	var logros := Logros.lista(d)
	var hechos := logros.filter(func(l): return l["hecho"]).size()
	lista.add_child(Estilo.titulo("Logros  %d/%d" % [hechos, logros.size()], 48))
	for l in logros:
		lista.add_child(_logro(l))


func _dato(nombre: String, valor: String) -> Control:
	var p := PanelContainer.new()
	var caja := Estilo.caja(Estilo.SUPERFICIE)
	caja.content_margin_left = 28
	caja.content_margin_right = 28
	caja.content_margin_top = 20
	caja.content_margin_bottom = 20
	p.add_theme_stylebox_override("panel", caja)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	v.add_child(Estilo.etiqueta(nombre, 30, Estilo.TEXTO_SUAVE, false))
	v.add_child(Estilo.titulo(valor, 44))
	p.add_child(v)
	return p


func _logro(l: Dictionary) -> Control:
	var p := PanelContainer.new()
	var caja := Estilo.caja(Estilo.tinte(Estilo.ACENTO) if l["hecho"] else Estilo.SUPERFICIE)
	caja.content_margin_left = 28
	caja.content_margin_right = 28
	caja.content_margin_top = 22
	caja.content_margin_bottom = 22
	p.add_theme_stylebox_override("panel", caja)
	var h := HBoxContainer.new()
	var marca := Estilo.titulo("★" if l["hecho"] else "☆", 56)
	marca.add_theme_color_override("font_color", Estilo.ACENTO if l["hecho"] else Estilo.TEXTO_SUAVE)
	h.add_child(marca)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 2)
	v.add_child(Estilo.etiqueta(l["nombre"], 42, Estilo.TEXTO, false))
	v.add_child(Estilo.etiqueta(l["detalle"], 32, Estilo.TEXTO_SUAVE, false))
	h.add_child(v)
	if not l["hecho"] and l["meta"] > 1:
		h.add_child(Estilo.etiqueta("%d/%d" % [l["actual"], l["meta"]], 34, Estilo.TEXTO_SUAVE, false, false))
	p.add_child(h)
	return p


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		Estilo.ir(self, "menu")
