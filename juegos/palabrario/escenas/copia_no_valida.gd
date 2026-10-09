# Se muestra solo si Android dice que esta copia no se instalo desde Google
# Play (ver autoload/integridad.gd). Quien compro el juego lo reinstala gratis.
extends Control


func _ready() -> void:
	var col := Estilo.pantalla(self)
	var hueco := Control.new()
	hueco.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(hueco)
	col.add_child(Estilo.titulo("Palabrario", 120, true))
	col.add_child(Estilo.etiqueta("Esta copia no se instaló desde Google Play.", 48, Estilo.TEXTO))
	col.add_child(Estilo.etiqueta("Si ya compraste el juego, instálalo de nuevo desde Google Play: no tendrás que pagar otra vez y conservarás tus compras de pistas.", 40, Estilo.TEXTO_SUAVE))
	var hueco2 := Control.new()
	hueco2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(hueco2)
	var play := Estilo.boton("Abrir en Google Play", "primario", 160)
	play.pressed.connect(Integridad.abrir_ficha)
	col.add_child(play)
	var salir := Estilo.boton("Salir", "suave", 120)
	salir.pressed.connect(func(): get_tree().quit())
	col.add_child(salir)


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
