extends SceneTree
# Revisión visual: fotos de una caja desde sus zonas y resolviéndola paso a paso. No va en el APK.
#   xvfb-run -a godot --path puzles/godot --rendering-driver opengl3 --fixed-fps 30 \
#     --script res://scripts/vistas.gd -- --ver=caja_viva --zonas=cara,tapa --pasos=ojo,dormir --salida=/ruta/
# Sin --salida, las fotos van a user://vistas/.
var caja := "caja_viva"
var salida := "user://vistas/"
var zonas_ver: Array = []
var pasos_ver: Array = []

func _initialize() -> void:
	for argumento in OS.get_cmdline_user_args():
		if argumento.begins_with("--ver="):
			caja = argumento.split("=")[1]
		if argumento.begins_with("--zonas="):
			zonas_ver = argumento.split("=")[1].split(",")
		if argumento.begins_with("--pasos="):
			pasos_ver = argumento.split("=")[1].split(",")
		if argumento.begins_with("--salida="):
			salida = argumento.split("=")[1].trim_suffix("/") + "/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(salida))
	change_scene_to_file("res://principal.tscn")
	correr.call_deferred()

func esperar(segundos: float) -> void:
	for i in int(segundos * 30.0) + 1:
		await process_frame

func capturar(nombre: String) -> void:
	await process_frame
	root.get_viewport().get_texture().get_image().save_png(salida + nombre + ".png")

func ir_a_zona(mesa, id: String) -> void:
	for datos in mesa.puzle.zonas:
		if datos.id == id:
			var zona: Dictionary = datos.duplicate()
			zona.centro = mesa.puzle.to_global(datos.centro)
			mesa.camara.enfocar_zona(zona, 0.2)
	await esperar(1.0)

func correr() -> void:
	await esperar(0.3)
	var mesa = current_scene.abrir_caja(caja, false)
	await esperar(3.0)
	await capturar(caja + "_00_inicio")
	var n := 1
	for id in zonas_ver:
		await ir_a_zona(mesa, id)
		await capturar("%s_%02d_%s" % [caja, n, id])
		n += 1
	mesa.camara.centrar()
	await esperar(1.0)
	for paso in mesa.puzle.pasos:
		var id: String = paso.id
		await mesa.puzle.resolver_paso(id)
		var tope := 0
		while not mesa.puzle.hecho(id) and tope < 300:
			await process_frame
			tope += 1
		print("paso ", id, " hecho: ", mesa.puzle.hecho(id))
		await esperar(0.5)
		if id in pasos_ver:
			await esperar(1.5)
			await capturar("%s_p_%s" % [caja, id])
	await esperar(6.0)
	await capturar(caja + "_99_final")
	quit()
