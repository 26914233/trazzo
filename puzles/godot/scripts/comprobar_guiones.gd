# Carga todos los guiones del proyecto para ver si alguno tiene errores (sin abrir el juego).
#   godot --headless --path puzles/godot --script res://scripts/comprobar_guiones.gd
extends SceneTree

func _initialize() -> void:
	var malos := 0
	for ruta in _guiones("res://scripts"):
		var guion: Script = load(ruta)
		if guion == null or not guion.can_instantiate():
			malos += 1
			print("FALLA: ", ruta)
	print("guiones con errores: ", malos)
	quit(1 if malos > 0 else 0)

func _guiones(carpeta: String) -> Array:
	var lista: Array = []
	for archivo in DirAccess.get_files_at(carpeta):
		if archivo.ends_with(".gd"):
			lista.append(carpeta.path_join(archivo))
	for sub in DirAccess.get_directories_at(carpeta):
		lista += _guiones(carpeta.path_join(sub))
	return lista
