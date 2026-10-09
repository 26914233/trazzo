# Comprobacion antipirateria: ¿esta copia se instalo desde Google Play?
#
# Es una segunda capa. La primera, y la mas fuerte, es la "proteccion
# automatica de integridad" de Play Console (docs/PUBLICAR.md), que Google
# inyecta y endurece al subir el AAB. Esta comprobacion es del lado del
# cliente: frena el caso comun (pasar el APK de un movil a otro), no a quien
# modifique el juego.
#
# Principio: ante cualquier duda, se deja jugar. Solo se bloquea cuando
# Android responde con claridad que el instalador no es Google Play. Quien
# compro el juego siempre puede reinstalarlo gratis desde Play.
extends Node

const TIENDA_PLAY := "com.android.vending"


## "ok", "copia" (no viene de Play) o "desconocido" (no se pudo saber).
var resultado := "desconocido"
var instalador := ""


func _ready() -> void:
	var exigir := bool(ProjectSettings.get_setting("juego/integridad/exigir_play", true))
	instalador = _leer_instalador() if _aplica() else ""
	resultado = evaluar(_aplica(), exigir, instalador)
	if resultado == "copia":
		# Cuando la escena principal ya esta cargada.
		(func(): get_tree().change_scene_to_file("res://escenas/copia_no_valida.tscn")).call_deferred()


## Solo en Android y en builds de release: en depuracion se instala con adb.
func _aplica() -> bool:
	return OS.get_name() == "Android" and not OS.is_debug_build()


## Decision pura (probada en tests/pruebas.gd).
## `instalador`: null -> no se pudo preguntar; "" -> Android dice que nadie
## (instalado a mano); otro -> el paquete instalador.
static func evaluar(aplica: bool, exigir: bool, instalador) -> String:
	if not aplica or not exigir:
		return "ok"
	if instalador == null:
		return "desconocido"   # fallo al preguntar: se deja jugar
	if str(instalador) == TIENDA_PLAY:
		return "ok"
	return "copia"


## En Android 11+ hay dos nombres: quien inicio la instalacion y quien consta
## como instalador. El segundo se falsea con `adb install -i com.android.vending`;
## en ese caso el iniciador es la shell de adb y es el que manda (NV-01). En el
## resto se usa el instalador: el iniciador de una restauracion de Play no esta
## documentado y no se arriesga a bloquear a quien pago.
const SHELL_ADB := "com.android.shell"

static func elegir_instalador(iniciador, instalador):
	if iniciador != null and str(iniciador) == SHELL_ADB:
		return SHELL_ADB
	return instalador


## Pregunta a Android quien instalo la app (Godot 4.4+: AndroidRuntime y
## JavaClassWrapper). Devuelve null si algo de la cadena no esta disponible.
## Sin probar en dispositivo desde el entorno de desarrollo: por eso cualquier
## hueco devuelve null y se deja jugar.
func _leer_instalador():
	if not Engine.has_singleton("AndroidRuntime"):
		return null
	var rt = Engine.get_singleton("AndroidRuntime")
	var ctx = rt.getApplicationContext() if rt else null
	if ctx == null:
		return null
	var pm = ctx.getPackageManager()
	var paquete = ctx.getPackageName()
	if pm == null or paquete == null:
		return null
	var version = JavaClassWrapper.wrap("android.os.Build$VERSION")
	var sdk: int = int(version.SDK_INT) if version else 0
	var quien = null
	if sdk >= 30:
		var info = pm.getInstallSourceInfo(paquete)
		if info == null:
			return null
		quien = elegir_instalador(info.getInitiatingPackageName(), info.getInstallingPackageName())
	elif sdk > 0:
		quien = pm.getInstallerPackageName(paquete)
	else:
		return null
	return "" if quien == null else str(quien)


func abrir_ficha() -> void:
	var paquete := str(ProjectSettings.get_setting("juego/paquete", ""))
	OS.shell_open("https://play.google.com/store/apps/details?id=" + paquete)
