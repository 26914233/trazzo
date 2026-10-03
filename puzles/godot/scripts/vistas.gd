extends SceneTree
# Revisión visual: fotos de una caja desde sus zonas y resolviéndola paso a paso. No va en el APK.
#   xvfb-run -a godot --path puzles/godot --rendering-driver opengl3 --fixed-fps 30 \
#     --script res://scripts/vistas.gd -- --ver=caja_viva --zonas=cara,tapa --pasos=ojo,dormir --salida=/ruta/
# Con --resistencia[=zona o punto de vista] graba cuadro a cuadro (JPG) cómo se resiste la caja a tres
# toques sobre su pieza bloqueada de prueba.
# Sin --salida, las fotos van a user://vistas/.
var caja := "caja_viva"
var salida := "user://vistas/"
var zonas_ver: Array = []
var pasos_ver: Array = []
var resistencia := false
var encuadre := ""

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
		if argumento.begins_with("--resistencia"):
			resistencia = true
			if "=" in argumento:
				encuadre = argumento.split("=")[1]
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

# Tres toques sobre la pieza bloqueada (el tercero ya es insistir), grabados a 30 cuadros por segundo
func grabar_resistencia(mesa) -> void:
	var puzle = mesa.puzle
	while mesa.bloqueado:
		await process_frame
	if encuadre != "" and puzle.has_method("_ir"):
		await puzle._ir(encuadre)
	elif encuadre != "":
		await ir_a_zona(mesa, encuadre)
	elif puzle.has_method("encuadre_de_prueba"):
		var datos: Dictionary = puzle.encuadre_de_prueba()
		mesa.camara.enfocar(puzle.to_global(datos.centro), datos.distancia, datos.guinada, datos.cabeceo, 0.4)
	await esperar(2.0)
	var pieza: Pieza = puzle.bloqueo_de_prueba()
	var camara: Camera3D = mesa.camara.camara
	var centro: Vector3 = (pieza.get_parent() as Node3D).to_global(mesa.caja_de(pieza).get_center())
	var toque: Dictionary = mesa.pieza_en(camara.unproject_position(centro))
	for cuadro in int(4.8 * 30.0):
		if cuadro in [6, 54, 78]:
			# como un dedo de verdad, si el rayo da en la pieza; si no, la cara que se ve
			if not toque.is_empty() and toque.pieza == pieza:
				mesa.pieza_tocada = pieza
				mesa.punto_tocado = toque.punto
			else:
				mesa.pieza_tocada = null
			pieza.tocar()
		await process_frame
		var imagen: Image = root.get_viewport().get_texture().get_image()
		imagen.resize(768, 432, Image.INTERPOLATE_BILINEAR)
		imagen.save_jpg(salida + "%s_r%03d.jpg" % [caja, cuadro], 0.9)


func correr() -> void:
	await esperar(0.3)
	var mesa = current_scene.abrir_caja(caja, false)
	await esperar(3.0)
	if resistencia:
		await grabar_resistencia(mesa)
		quit()
		return
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
