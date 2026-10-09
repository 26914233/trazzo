# Escritura atomica: si la app muere a mitad, queda el archivo anterior entero.
class_name Archivo
extends RefCounted


static func escribir(ruta: String, texto: String) -> bool:
	var tmp := ruta + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_error("No se pudo escribir %s: %s" % [ruta, error_string(FileAccess.get_open_error())])
		return false
	f.store_string(texto)
	f.close()
	var err := DirAccess.rename_absolute(tmp, ruta)
	if err != OK:
		push_error("No se pudo reemplazar %s: %s" % [ruta, error_string(err)])
		return false
	return true
