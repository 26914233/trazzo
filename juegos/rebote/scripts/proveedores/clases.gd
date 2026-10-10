# Resuelve clases de plugins en tiempo de ejecucion.
# Los plugins (AdMob, Billing) solo existen en el proyecto cuando se instalan
# para exportar a Android. Nombrar sus clases directamente haria que el
# proyecto no compilase sin ellos; asi el juego funciona con y sin plugins.
class_name ClasesPlugin
extends RefCounted


## Devuelve el script de una clase global (class_name) o null si no existe.
static func script_de(nombre: String) -> Script:
	for c in ProjectSettings.get_global_class_list():
		if c["class"] == nombre:
			return load(c["path"])
	return null


static func existe(nombre: String) -> bool:
	return script_de(nombre) != null or ClassDB.class_exists(nombre)


## Instancia una clase de plugin (script global o clase nativa).
static func nueva(nombre: String) -> Object:
	var s := script_de(nombre)
	if s:
		return s.new()
	if ClassDB.class_exists(nombre):
		return ClassDB.instantiate(nombre)
	return null


## Lee un valor de un enum de la clase, con un valor por defecto documentado.
static func enum_de(clase: Object, nombre_enum: String, clave: String, defecto: int) -> int:
	var s: Script = clase if clase is Script else (clase.get_script() if clase else null)
	if s:
		var e = s.get_script_constant_map().get(nombre_enum)
		if typeof(e) == TYPE_DICTIONARY and e.has(clave):
			return int(e[clave])
	return defecto
