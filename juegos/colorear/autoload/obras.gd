# Obras del jugador: los colores de cada lamina y su miniatura, en user://obras/.
# Se guardan solas al salir de la lamina.
extends Node

const MINI := 320

var carpeta := "user://obras/"
var _terminadas = null          # id -> true; se lee del disco la primera vez


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(carpeta)


func _json(id: String) -> String:
	return carpeta + id + ".json"


func _png(id: String) -> String:
	return carpeta + id + ".png"


func tiene(id: String) -> bool:
	return FileAccess.file_exists(_json(id))


## Aplica a la lamina los colores guardados (si hay).
func cargar_en(lamina: Lamina) -> void:
	if not tiene(lamina.id):
		return
	var d = JSON.parse_string(FileAccess.get_file_as_string(_json(lamina.id)))
	if typeof(d) == TYPE_DICTIONARY:
		lamina.desde_datos(d)
	else:
		push_warning("Obra ilegible: %s (se empieza en blanco)" % lamina.id)


func guardar(lamina: Lamina) -> void:
	var d := lamina.a_datos()
	if d["colores"].is_empty() and not tiene(lamina.id):
		return   # abierta y sin tocar: no es una obra
	d["fecha"] = int(Time.get_unix_time_from_system())
	d["terminada"] = lamina.terminada()
	if Archivo.escribir(_json(lamina.id), JSON.stringify(d)):
		miniatura(lamina).save_png(_png(lamina.id))
		_cache()
		if d["terminada"]:
			_terminadas[lamina.id] = true
		else:
			_terminadas.erase(lamina.id)


func borrar(id: String) -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(_json(id)))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(_png(id)))
	if _terminadas != null:
		_terminadas.erase(id)


func terminada(id: String) -> bool:
	return _cache().has(id)


## Quita las terminadas si `ocultar` (filtro del menu).
func filtrar(ids: Array, ocultar: bool) -> Array:
	return ids.filter(func(id): return not terminada(id)) if ocultar else ids


func olvidar_cache() -> void:
	_terminadas = null


func _cache() -> Dictionary:
	if _terminadas == null:
		_terminadas = {}
		for f in DirAccess.get_files_at(carpeta):
			if f.ends_with(".json"):
				var d = JSON.parse_string(FileAccess.get_file_as_string(carpeta + f))
				if typeof(d) == TYPE_DICTIONARY and d.get("terminada", false) == true:
					_terminadas[f.get_basename()] = true
	return _terminadas


## Ids de las obras, la mas reciente primero.
func lista() -> Array:
	var obras := []
	for f in DirAccess.get_files_at(carpeta):
		if f.ends_with(".json"):
			var id := f.get_basename()
			if Laminas.existe(id):
				obras.append({"id": id, "fecha": FileAccess.get_modified_time(carpeta + f)})
	obras.sort_custom(func(a, b): return a["fecha"] > b["fecha"])
	return obras.map(func(o): return o["id"])


## Miniatura coloreada para las listas (la de lineas si aun no hay obra).
func textura_mini(id: String) -> Texture2D:
	if FileAccess.file_exists(_png(id)):
		var img := Image.load_from_file(_png(id))
		if img:
			return ImageTexture.create_from_image(img)
	return load(Laminas.ruta(id, "mini"))


## Color de cada zona multiplicado por la linea, a 320 px. En CPU: se hace una
## vez al guardar y asi se puede probar sin pantalla.
func miniatura(lamina: Lamina) -> Image:
	var lineas: Image = (load(Laminas.ruta(lamina.id, "mini")) as Texture2D).get_image()
	if lineas.is_compressed():
		lineas.decompress()
	var lado := lineas.get_width()
	var paso := float(lamina.regiones.get_width()) / lado
	var img := Image.create_empty(lado, lado, false, Image.FORMAT_RGB8)
	for y in lado:
		for x in lado:
			var z := lamina.zona_en(Vector2i(int((x + 0.5) * paso), int((y + 0.5) * paso)))
			var tinta := lineas.get_pixel(x, y).r
			img.set_pixel(x, y, lamina.colores[z] * tinta if z > 0 else Color(tinta, tinta, tinta))
	return img
