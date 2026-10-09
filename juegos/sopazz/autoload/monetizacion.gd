# Capa unica de anuncios y compras. El juego solo habla con este archivo.
#
# Proveedores:
#  - stub: sin plugins (escritorio, pruebas, este entorno). Simula anuncios y
#    compras para que el juego entero sea jugable y probable sin SDK.
#  - reales: AdMob (scripts/proveedores/anuncios_admob.gd) y Google Play
#    Billing (scripts/proveedores/pagos_play.gd). Se activan solos en Android
#    cuando los plugins estan instalados. Ver docs/INTEGRACION_ANDROID.md.
#
# Regla de oro: nada aqui puede dejar una pantalla esperando para siempre.
# Todo anuncio tiene timeout y todo fallo devuelve false.
extends Node

signal compra_completada(producto: String)

# Red de seguridad, no limite de visionado: un premiado dura hasta 30 s y el
# "no hay anuncio cargado" ya se resuelve al instante en el adaptador.
var timeout_anuncio_s := 180.0

# IDs de prueba OFICIALES de AdMob (publicos, no son secretos). Sustituir por los
# reales de la cuenta del dueño solo en export, nunca en el repo.
const ADMOB_TEST_INTERSTICIAL := "ca-app-pub-3940256099942544/1033173712"
const ADMOB_TEST_PREMIADO := "ca-app-pub-3940256099942544/5224354917"

## Catalogo. Los IDs deben crearse igual en Play Console.
const PRODUCTOS := {
	"sin_anuncios": {"tipo": "permanente", "fichas": 300, "precio": "2,99\u00a0US$", "nombre": "Quitar anuncios"},
	"fichas_500": {"tipo": "consumible", "fichas": 500, "precio": "0,99\u00a0US$", "nombre": "500 fichas"},
	"fichas_1500": {"tipo": "consumible", "fichas": 1500, "precio": "2,49\u00a0US$", "nombre": "1.500 fichas"},
	"fichas_4000": {"tipo": "consumible", "fichas": 4000, "precio": "4,99\u00a0US$", "nombre": "4.000 fichas", "destacado": true},
	"fichas_10000": {"tipo": "consumible", "fichas": 10000, "precio": "9,99\u00a0US$", "nombre": "10.000 fichas"},
	"todos_los_temas": {"tipo": "permanente", "fichas": 0, "precio": "7,99\u00a0US$", "nombre": "Todos los temas"},
}
## Cada tema de pago se vende tambien suelto como "tema_<id>" a 1,99 US$.
const PRECIO_TEMA := "1,99\u00a0US$"

var anuncios: AnunciosAdMob = null
var pagos: PagosPlay = null
## Solo para el stub: que resultado simula (las pruebas lo cambian).
var stub_exito := true
var stub_demora_s := 0.4

var _ultimo_intersticial_ms := -1
var _completados_desde_ultimo := 0


func _ready() -> void:
	if AnunciosAdMob.disponible():
		anuncios = AnunciosAdMob.new()
		anuncios.iniciar(ids_anuncios())
	if OS.get_name() == "Android" and ClasesPlugin.existe("BillingClient"):
		pagos = PagosPlay.new(ClasesPlugin.nueva("BillingClient"), ids_productos(), ids_consumibles())
		# Toda entrega real pasa por aqui: compra normal, pendiente que se paga
		# mas tarde, compra a medias recuperada al abrir y restauracion.
		pagos.compra_confirmada.connect(conceder)
		pagos.permanentes_sincronizados.connect(sincronizar_permanentes)


## Unidades de anuncio. En builds de depuracion SIEMPRE las de prueba: hacer
## clic en anuncios reales propios puede suspender la cuenta de AdMob.
## Las reales se ponen en Ajustes del proyecto > sopazz/admob/* al exportar.
func ids_anuncios() -> Dictionary:
	if OS.is_debug_build():
		return {"intersticial": ADMOB_TEST_INTERSTICIAL, "premiado": ADMOB_TEST_PREMIADO}
	var ids := {
		"intersticial": str(ProjectSettings.get_setting("sopazz/admob/intersticial", ADMOB_TEST_INTERSTICIAL)),
		"premiado": str(ProjectSettings.get_setting("sopazz/admob/premiado", ADMOB_TEST_PREMIADO)),
	}
	if ids["premiado"] == ADMOB_TEST_PREMIADO:
		push_warning("Build de release con unidades de anuncio de PRUEBA: no genera ingresos.")
	return ids


func ids_productos() -> PackedStringArray:
	var ids := PackedStringArray(PRODUCTOS.keys())
	for t in Temas.lista:
		if not t.get("gratis", false):
			ids.append("tema_" + t["id"])
	return ids


func ids_consumibles() -> PackedStringArray:
	var ids := PackedStringArray()
	for id in PRODUCTOS:
		if PRODUCTOS[id]["tipo"] == "consumible":
			ids.append(id)
	return ids


func anuncios_reales() -> bool:
	return anuncios != null


func pagos_reales() -> bool:
	return pagos != null


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

## Lista blanca: solo el catalogo y los temas de pago que existen (SEC-005).
func producto_valido(producto: String) -> bool:
	if PRODUCTOS.has(producto):
		return true
	if producto.begins_with("tema_"):
		var t := Temas.tema(producto.trim_prefix("tema_"))
		return not t.is_empty() and not t.get("gratis", false)
	return false


## Compras permanentes que Play dice que existen -> estado local.
func sincronizar_permanentes(productos: Array) -> void:
	var temas: Array = []
	if "todos_los_temas" in productos:
		for t in Temas.lista:
			if not t.get("gratis", false):
				temas.append(t["id"])
	for p in productos:
		if str(p).begins_with("tema_") and producto_valido(p):
			var id := str(p).trim_prefix("tema_")
			if not id in temas:
				temas.append(id)
	Progreso.sincronizar_permanentes("sin_anuncios" in productos, temas)


func comprar(producto: String) -> bool:
	if not producto_valido(producto):
		push_error("Producto desconocido: %s" % producto)
		return false
	if pagos:
		# La entrega la hace la señal compra_confirmada, no este retorno: asi
		# no se entrega dos veces ni se pierde una compra pendiente.
		return await pagos.comprar(producto, get_tree())
	await get_tree().create_timer(stub_demora_s).timeout
	if stub_exito:
		conceder(producto)
	return stub_exito


## Entrega lo comprado. Separado de comprar() para reutilizarlo al restaurar
## compras y para probarlo sin pasarela de pago.
func conceder(producto: String) -> void:
	if not producto_valido(producto):
		push_error("Producto fuera del catalogo, no se entrega: %s" % producto)
		return
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
## anuncios" al cambiar de movil). Al abrir la app ya se restauran solas;
## esto es el boton manual. Con el stub no hay nada que restaurar.
func restaurar_compras() -> int:
	if pagos == null:
		return 0
	var recibidas := []
	var contar := func(p: String) -> void: recibidas.append(p)
	pagos.compra_confirmada.connect(contar)
	pagos.pedir_restauracion()
	await get_tree().create_timer(4.0).timeout
	pagos.compra_confirmada.disconnect(contar)
	return recibidas.size()


# ---------------------------------------------------------------- comun

func _mostrar(tipo: String) -> bool:
	if anuncios:
		return await _con_timeout(anuncios.mostrar(tipo))
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
