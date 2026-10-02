# Dibuja la portada de cada prototipo para su tarjeta del menú (sin interfaz), en
# recursos/portadas/<id>.png. Se lanza así (con Xvfb en Linux):
#   xvfb-run -a godot --path puzles/godot --rendering-driver opengl3 --script res://scripts/hacer_portadas.gd
extends SceneTree

const Catalogo := preload("res://scripts/catalogo.gd")
# Ángulo de cámara de cada portada: [guiñada, cabeceo, distancia] (en las habitaciones, el punto de vista)
const VISTAS := {
	"caja_viva": [0.62, 0.42, 0.5],
	"relojero": [0.42, 0.62, 0.62],
	"reliquia": [0.3, 0.18, 0.62],
	"farero": "sala",
}

func _initialize() -> void:
	var principal = load("res://principal.tscn").instantiate()
	root.add_child(principal)
	await process_frame
	for datos in Catalogo.PROTOTIPOS:
		var mesa = principal.abrir_prototipo(datos.id)
		for i in 10:
			await process_frame
		mesa.hud.visible = false
		var vista = VISTAS[datos.id]
		if vista is Array:
			mesa.camara.configurar_orbita(mesa.camara.objetivo, vista[0], vista[1], vista[2], Vector2(0.2, 2.0), Vector2(-1.4, 1.4))
		if datos.id == "reliquia":
			mesa.puzle.nucleo.tocar()
			await create_timer(2.0).timeout
		if datos.id == "caja_viva":
			await create_timer(2.5).timeout
		for i in 8:
			await process_frame
		await RenderingServer.frame_post_draw
		var imagen: Image = root.get_viewport().get_texture().get_image()
		imagen.resize(640, 360, Image.INTERPOLATE_LANCZOS)
		imagen.save_png("res://recursos/portadas/%s.png" % datos.id)
		print("portada: ", datos.id)
	quit()
