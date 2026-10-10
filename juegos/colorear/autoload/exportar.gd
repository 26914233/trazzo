# Guarda la obra como PNG en la carpeta de imagenes del telefono (Imagenes/Lienzo Zen).
# Si el sistema no deja escribir alli, queda en user://imagenes/ y se avisa.
# PENDIENTE DE VALIDAR EN DISPOSITIVO: que Android la muestre en la galeria sin
# reiniciar el escaneo de medios (en Android 11+ la escritura directa en Pictures
# esta permitida para archivos propios; en 7-9 haria falta permiso de almacenamiento).
extends Node

const RESPALDO := "user://imagenes/"

## Vacia = la carpeta del sistema. Las pruebas la cambian.
var carpeta_galeria := ""


func _carpeta() -> String:
	if carpeta_galeria != "":
		return carpeta_galeria
	var fotos := OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
	return fotos.path_join("Lienzo Zen") + "/" if fotos != "" else RESPALDO


## {ok, ruta, en_galeria}
func guardar(lamina: Lamina) -> Dictionary:
	var img := lamina.imagen()
	var nombre := "lienzo-zen-%s-%s.png" % [lamina.id, Time.get_datetime_string_from_system().replace(":", "").replace("T", "-")]
	for carpeta in [_carpeta(), RESPALDO]:
		if DirAccess.make_dir_recursive_absolute(carpeta) not in [OK, ERR_ALREADY_EXISTS]:
			continue
		var r: String = carpeta.path_join(nombre)
		if img.save_png(r) == OK:
			return {"ok": true, "ruta": r, "en_galeria": carpeta != RESPALDO}
		push_warning("No se pudo guardar en %s" % carpeta)
	return {"ok": false, "ruta": "", "en_galeria": false}
