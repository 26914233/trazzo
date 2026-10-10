# Evento de temporada activo: sus sopas y el avance (ver scripts/eventos.gd).
extends Control


func _ready() -> void:
	var hoy := Progreso.hoy()
	var ev := Eventos.activo(hoy)
	var col := Estilo.pantalla(self)
	Estilo.barra(col, ev.get("nombre", "Eventos"), func(): Estilo.ir(self, "menu"))
	if ev.is_empty():
		col.add_child(Estilo.etiqueta("Hoy no hay evento. Cada fin de semana hay uno con un tema distinto, y en fechas especiales, otros.", 40, Estilo.TEXTO_SUAVE))
		return
	var hechas: Array = Progreso.datos["eventos"].get(ev["clave"], [])
	var dias := Eventos.dias_restantes(ev, hoy)
	var estado := "¡Completado! Tienes la insignia." if Progreso.evento_hecho(ev) else \
		"%d de %d sopas  ·  %s" % [hechas.size(), ev["sopas"].size(), "último día" if dias <= 1 else "quedan %d días" % dias]
	col.add_child(Estilo.etiqueta(estado, 38, Estilo.ACENTO if Progreso.evento_hecho(ev) else Estilo.TEXTO_SUAVE, false))
	col.add_child(Estilo.etiqueta("Resuelve las %d sopas antes de que termine, en la dificultad que quieras." % ev["sopas"].size(), 34, Estilo.TEXTO_SUAVE, false))
	var dif := int(Progreso.ajuste("dificultad"))
	for par in ev["sopas"]:
		var cat := Temas.categoria(par[0])
		var sub := Temas.subtema(par[0], par[1])
		var hecha: bool = (par[0] + "/" + par[1]) in hechas
		var t := Estilo.tarjeta(150, Estilo.tinte(Estilo.ACENTO) if hecha else Estilo.SUPERFICIE, func():
			Temas.seleccion = {"categoria": par[0], "subtema": par[1], "dificultad": dif, "diario": false}
			Estilo.ir(self, "juego"))
		var h := HBoxContainer.new()
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var marca := Estilo.titulo("✓" if hecha else "○", 48)
		marca.custom_minimum_size.x = 70
		var nombre := Estilo.etiqueta(sub.get("nombre", ""), 42, Estilo.TEXTO, false, false)
		nombre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nombre.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		nombre.clip_text = true
		var tema := Estilo.etiqueta(cat.get("nombre", ""), 32, Estilo.TEXTO_SUAVE, false, false)
		for n in [marca, nombre, tema]:
			n.mouse_filter = Control.MOUSE_FILTER_IGNORE
			h.add_child(n)
		(t[1] as VBoxContainer).alignment = BoxContainer.ALIGNMENT_CENTER
		(t[1] as VBoxContainer).add_child(h)
		col.add_child(t[0])


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		Estilo.ir(self, "menu")
