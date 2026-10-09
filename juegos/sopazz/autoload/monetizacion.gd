# Capa unica de anuncios y compras. El juego solo habla con este archivo.
#
# Proveedores:
#  - "stub": sin plugin (escritorio, pruebas, este entorno). Simula anuncios y
#    compras para que el juego entero sea jugable y probable sin SDK.
#  - "android": AdMob + Google Play Billing via plugins de Godot. Se activa solo
#    si los singletons existen en el APK. La conexion fina con cada plugin esta
#    en _android_*; ver docs/INTEGRACION_ANDROID.md antes de publicar.
#
# Regla de oro: nada aqui puede dejar una pantalla esperando para siempre.
# Todo anuncio tiene timeout y todo fallo devuelve false.
extends Node

signal compra_completada(producto: String)

var timeout_anuncio_s := 8.0

# IDs de prueba OFICIALES de AdMob (publicos, no son secretos). Sustituir por los
# reales de la cuenta del dueño solo en export, nunca en el repo.
const ADMOB_TEST_INTERSTICIAL := "ca-app-pub-3940256099942544/1033173712"
const ADMOB_TEST_PREMIADO := "ca-app-pub-3940256099942544/5224354917"

## Catalogo. Los IDs deben crearse igual en Play Console.
const PRODUCTOS := {
	"sin_anuncios": {"tipo": "permanente", "fichas": 300, "precio": "2,99 US$", "nombre": "Quitar anuncios"},
	"fichas_500": {"tipo": "consumible", "fichas": 500, "precio": "0,99 US$", "nombre": "500 fichas"},
	"fichas_1500": {"tipo": "consumible", "fichas": 1500, "precio": "2,49 US$", "nombre": "1.500 fichas"},
	"fichas_4000": {"tipo": "consumible", "fichas": 4000, "precio": "4,99 US$", "nombre": "4.000 fichas", "destacado": true},
	"fichas_10000": {"tipo": "consumible", "fichas": 10000, "precio": "9,99 US$", "nombre": "10.000 fichas"},
	"todos_los_temas": {"tipo": "permanente", "fichas": 0, "precio": "7,99 US$", "nombre": "Todos los temas"},
}
## Cada tema de pago se vende tambien suelto como "tema_<id>" a 1,99 US$.
const PRECIO_TEMA := "1,99 US$"

var proveedor := "stub"
## Solo para el stub: que resultado simula (las pruebas lo cambian).
var stub_exito := true
var stub_demora_s := 0.4

var _ultimo_intersticial_ms := -1
var _completados_desde_ultimo := 0


func _ready() -> void:
	if OS.get_name() == "Android" and Engine.has_singleton("PoingGodotAdMob"):
		proveedor = "android"
	_android_iniciar()


# ---------------------------------------------------------------- intersticial

## Llamar al completar un nivel (antes de volver al menu).
func nivel_completado() -> void:
	_completados_desde_ultimo += 1


func contexto_intersticial(abandono: bool = false) -> Dictionary:
	var desde := INF
	if _ultimo_intersticial_ms >= 0:
		desde = (Time.get_ticks_msec() - _ultimo_intersticial_ms) / 1000.0
	return {
		"sin_anuncios": Progreso.sin_anuncios(),
		"en_partida": false,
		"abandono": abandono,
		"niveles_completados": Progreso.niveles_completados(),
		"desde_ultimo_s": desde,
		"completados_desde_ultimo": _completados_desde_ultimo,
	}


## Muestra un intersticial si las reglas lo permiten. Devuelve si se mostro.
func intentar_intersticial(abandono: bool = false) -> bool:
	if not ReglasAnuncios.intersticial_permitido(contexto_intersticial(abandono)):
		return false
	var ok := await _mostrar("intersticial")
	if ok:
		_ultimo_intersticial_ms = Time.get_ticks_msec()
		_completados_desde_ultimo = 0
	return ok


# ---------------------------------------------------------------- premiado

## Muestra un anuncio premiado. Devuelve true solo si el jugador lo vio entero.
## Comprar "quitar anuncios" NO quita los premiados: son voluntarios y el
## jugador los quiere (pistas). Es la practica habitual y la que espera Play.
func mostrar_premiado() -> bool:
	var hoy := Progreso.hoy()
	if not Progreso.premiado_disponible(hoy):
		return false
	var ok := await _mostrar("premiado")
	if ok:
		Progreso.registrar_premiado(hoy)
	return ok


# ---------------------------------------------------------------- compras

func comprar(producto: String) -> bool:
	if not (PRODUCTOS.has(producto) or producto.begins_with("tema_")):
		push_error("Producto desconocido: %s" % producto)
		return false
	var ok: bool
	if proveedor == "android":
		ok = await _android_comprar(producto)
	else:
		await get_tree().create_timer(stub_demora_s).timeout
		ok = stub_exito
	if ok:
		conceder(producto)
	return ok


## Entrega lo comprado. Separado de comprar() para reutilizarlo al restaurar
## compras y para probarlo sin pasarela de pago.
func conceder(producto: String) -> void:
	if producto.begins_with("tema_"):
		Progreso.desbloquear_tema(producto.trim_prefix("tema_"))
	elif producto == "todos_los_temas":
		for t in Temas.lista:
			if not t.get("gratis", false):
				Progreso.desbloquear_tema(t["id"])
	elif producto == "sin_anuncios":
		var ya := Progreso.sin_anuncios()
		Progreso.activar_sin_anuncios()
		if not ya:
			Progreso.sumar_fichas(PRODUCTOS[producto]["fichas"])
	else:
		Progreso.sumar_fichas(PRODUCTOS[producto]["fichas"])
	compra_completada.emit(producto)


## Restaura las compras permanentes (obligatorio para no perder "quitar
## anuncios" al cambiar de movil). Con el stub no hay nada que restaurar.
func restaurar_compras() -> int:
	if proveedor != "android":
		return 0
	var permanentes: Array = await _android_compras_permanentes()
	for p in permanentes:
		conceder(p)
	return permanentes.size()


# ---------------------------------------------------------------- comun

func _mostrar(tipo: String) -> bool:
	if proveedor == "android":
		return await _con_timeout(_android_mostrar(tipo))
	await get_tree().create_timer(stub_demora_s).timeout
	return stub_exito


## Espera un resultado como mucho timeout_anuncio_s. Si no llega: false.
func _con_timeout(senal: Signal) -> bool:
	var estado := {"listo": false, "ok": false}
	var al_terminar := func(ok: bool) -> void:
		if not estado["listo"]:
			estado["listo"] = true
			estado["ok"] = ok
	senal.connect(al_terminar, CONNECT_ONE_SHOT)
	var limite := Time.get_ticks_msec() + int(timeout_anuncio_s * 1000)
	while not estado["listo"] and Time.get_ticks_msec() < limite:
		await get_tree().process_frame
	return estado["ok"]


# ---------------------------------------------------------------- Android
# Puntos de enganche con los plugins. Se dejan aislados aqui a proposito:
# la API concreta de cada plugin cambia entre versiones y tiene que
# verificarse contra la version instalada (docs/INTEGRACION_ANDROID.md).
# Mientras no este hecho, en Android sin plugins el juego cae al stub y
# simplemente no muestra anuncios (no se rompe).

signal _android_resultado(ok: bool)


func _android_iniciar() -> void:
	if proveedor != "android":
		return
	# TODO(integracion): inicializar AdMob con consentimiento UMP y cargar
	# el primer intersticial y el primer premiado.
	push_warning("Monetizacion: plugin detectado pero integracion pendiente; sin anuncios.")


func _android_mostrar(_tipo: String) -> Signal:
	# TODO(integracion): mostrar el anuncio cargado y emitir _android_resultado.
	_android_resultado.emit.call_deferred(false)
	return _android_resultado


func _android_comprar(_producto: String) -> bool:
	# TODO(integracion): lanzar el flujo de Google Play Billing, esperar la
	# compra, verificarla (acknowledge) y devolver el resultado.
	return false


func _android_compras_permanentes() -> Array:
	# TODO(integracion): consultar compras de tipo "inapp" no consumibles.
	return []
