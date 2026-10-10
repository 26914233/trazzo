# Capa unica de anuncios y compras: el juego solo habla con este archivo.
#
#  - Anuncios: AdMob (scripts/proveedores/anuncios_admob.gd) si el plugin esta
#    instalado (export con Gradle). Sin plugin: en el editor y en builds de
#    depuracion se SIMULAN (un aviso en pantalla) para poder probar donde salen;
#    en una build de release sin plugin no hay anuncios (y no dan premio).
#  - Compras: Google Play Billing (scripts/proveedores/pagos_play.gd). Sin plugin,
#    la compra solo se simula desde el editor; un APK nunca regala nada.
# Nada aqui deja una pantalla esperando para siempre: todo tiene tiempo limite.
extends Node

signal compra_completada(producto: String)
signal anuncio_simulado(tipo: String)       # la escena muestra un aviso de prueba

# IDs de prueba OFICIALES de AdMob (publicos). Los reales van en Ajustes del
# proyecto (rebotazz/admob/*) al exportar, nunca en el repo.
const ADMOB_TEST_INTERSTICIAL := "ca-app-pub-3940256099942544/1033173712"
const ADMOB_TEST_PREMIADO := "ca-app-pub-3940256099942544/5224354917"

## Catalogo. Los IDs deben crearse igual en Play Console (productos in-app).
const PRODUCTOS := {
	"sin_anuncios": {"tipo": "permanente", "precio": "2,99 US$", "nombre": "Quitar anuncios"},
	"gemas_500": {"tipo": "consumible", "precio": "0,99 US$", "gemas": 500, "nombre": "500 gemas"},
	"gemas_1500": {"tipo": "consumible", "precio": "2,49 US$", "gemas": 1500, "nombre": "1.500 gemas"},
	"gemas_4000": {"tipo": "consumible", "precio": "4,99 US$", "gemas": 4000, "nombre": "4.000 gemas", "destacado": true},
}

var timeout_anuncio_s := 120.0
var anuncios: AnunciosAdMob = null
var pagos: PagosPlay = null
var permitir_compra_simulada := OS.has_feature("editor")
var permitir_anuncio_simulado := OS.has_feature("editor") or OS.is_debug_build()
var simulado_exito := true
var simulado_demora_s := 1.2

var _ultimo_intersticial_ms := -1
var _superados_desde_ultimo := 0


func _ready() -> void:
	# Tambien con "quitar anuncios": esa compra quita los intersticiales (las
	# reglas lo impiden), pero los premiados son voluntarios y siguen ahi.
	if AnunciosAdMob.disponible():
		anuncios = AnunciosAdMob.new()
		anuncios.iniciar(ids_anuncios())
	if OS.get_name() == "Android" and ClasesPlugin.existe("BillingClient"):
		pagos = PagosPlay.new(ClasesPlugin.nueva("BillingClient"), PackedStringArray(PRODUCTOS.keys()), consumibles())
		pagos.compra_confirmada.connect(conceder)
		pagos.permanentes_sincronizados.connect(sincronizar_permanentes)


## En depuracion SIEMPRE las unidades de prueba: tocar anuncios reales propios
## puede suspender la cuenta de AdMob.
func ids_anuncios() -> Dictionary:
	if OS.is_debug_build():
		return {"intersticial": ADMOB_TEST_INTERSTICIAL, "premiado": ADMOB_TEST_PREMIADO}
	var ids := {
		"intersticial": str(ProjectSettings.get_setting("rebotazz/admob/intersticial", ADMOB_TEST_INTERSTICIAL)),
		"premiado": str(ProjectSettings.get_setting("rebotazz/admob/premiado", ADMOB_TEST_PREMIADO)),
	}
	if ids["premiado"] == ADMOB_TEST_PREMIADO:
		push_warning("Build de release con unidades de anuncio de PRUEBA: no genera ingresos.")
	return ids


func consumibles() -> PackedStringArray:
	return PackedStringArray(PRODUCTOS.keys().filter(func(p): return PRODUCTOS[p]["tipo"] == "consumible"))


func hay_anuncios() -> bool:
	return anuncios != null or permitir_anuncio_simulado


# ---------------------------------------------------------------- intersticial

func nivel_superado() -> void:
	_superados_desde_ultimo += 1


func contexto_intersticial(tras_perder: bool = false, abandono: bool = false) -> Dictionary:
	var desde := INF
	if _ultimo_intersticial_ms >= 0:
		desde = (Time.get_ticks_msec() - _ultimo_intersticial_ms) / 1000.0
	return {"sin_anuncios": Progreso.sin_anuncios(), "tras_perder": tras_perder, "abandono": abandono,
		"superados": int(Progreso.datos["superados"]), "desde_ultimo_s": desde,
		"superados_desde_ultimo": _superados_desde_ultimo}


## Muestra un intersticial si las reglas lo permiten. Devuelve si se mostro.
func intentar_intersticial(tras_perder: bool = false, abandono: bool = false) -> bool:
	if not ReglasAnuncios.intersticial_permitido(contexto_intersticial(tras_perder, abandono)):
		return false
	var ok := await _mostrar("intersticial")
	if ok:
		_ultimo_intersticial_ms = Time.get_ticks_msec()
		_superados_desde_ultimo = 0
	return ok


# ---------------------------------------------------------------- premiado

## Anuncio voluntario. true solo si se vio entero. motivo "gemas" cuenta para el
## tope diario; "seguir" y "doble" no (van ligados a un nivel concreto).
func mostrar_premiado(motivo: String = "gemas") -> bool:
	if motivo == "gemas" and Progreso.premiados_restantes(Progreso.hoy()) <= 0:
		return false
	var ok := await _mostrar("premiado")
	if ok and motivo == "gemas":
		Progreso.registrar_premiado(Progreso.hoy())
		Progreso.sumar_gemas(Economia.GEMAS_PREMIADO)
	return ok


# ---------------------------------------------------------------- compras

## Precio a mostrar: el de Play si ya llego (moneda local); si no, el de
## referencia del catalogo marcado como aproximado.
func precio(producto: String) -> String:
	if pagos and pagos.precios.has(producto):
		return pagos.precios[producto]
	return "≈ " + str(PRODUCTOS.get(producto, {}).get("precio", ""))


func producto_valido(producto: String) -> bool:
	return PRODUCTOS.has(producto)


## Compras permanentes que Play dice que existen -> estado local.
func sincronizar_permanentes(productos: Array) -> void:
	Progreso.fijar_sin_anuncios("sin_anuncios" in productos)


func comprar(producto: String) -> bool:
	if not producto_valido(producto):
		push_error("Producto desconocido: %s" % producto)
		return false
	if pagos:
		return await pagos.comprar(producto, get_tree())   # entrega via compra_confirmada
	if not permitir_compra_simulada:
		push_error("Compra sin plugin de pagos fuera del editor: no se entrega nada.")
		return false
	await get_tree().create_timer(0.3).timeout
	if simulado_exito:
		conceder(producto)
	return simulado_exito


## Entrega lo comprado (solo cuando Play confirma). Idempotente para lo permanente.
func conceder(producto: String) -> void:
	if not producto_valido(producto):
		push_error("Producto fuera del catalogo, no se entrega: %s" % producto)
		return
	var p: Dictionary = PRODUCTOS[producto]
	if producto == "sin_anuncios":
		Progreso.fijar_sin_anuncios(true)
	elif p.has("gemas"):
		Progreso.sumar_gemas(int(p["gemas"]))
	compra_completada.emit(producto)


func restaurar_compras() -> void:
	if pagos:
		pagos.pedir_restauracion()


# ---------------------------------------------------------------- comun

func _mostrar(tipo: String) -> bool:
	if anuncios:
		return await _con_timeout(anuncios.mostrar(tipo))
	if not permitir_anuncio_simulado:
		return false
	anuncio_simulado.emit(tipo)
	var velo := _velo_simulado(tipo) if simulado_demora_s > 0.0 else null
	await get_tree().create_timer(simulado_demora_s).timeout
	if velo:
		velo.queue_free()
	return simulado_exito


## Lo que se ve en depuracion en lugar del anuncio: una capa que tapa el juego
## (asi se comprueba donde y cuando saldria uno de verdad).
func _velo_simulado(tipo: String) -> CanvasLayer:
	var capa := CanvasLayer.new()
	capa.layer = 100
	var fondo := ColorRect.new()
	fondo.color = Color(0.02, 0.02, 0.05, 0.94)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_STOP     # como un anuncio real: no se toca el juego
	capa.add_child(fondo)
	var texto := Estilo.etiqueta("Anuncio de prueba\n(%s)\n\nSolo en depuración: aquí saldría AdMob." % tipo, 52)
	texto.set_anchors_preset(Control.PRESET_FULL_RECT)
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fondo.add_child(texto)
	add_child(capa)
	return capa


func _con_timeout(senal: Signal) -> bool:
	var estado := {"listo": false, "ok": false}
	senal.connect(func(ok: bool):
		if not estado["listo"]:
			estado["listo"] = true
			estado["ok"] = ok, CONNECT_ONE_SHOT)
	var limite := Time.get_ticks_msec() + int(timeout_anuncio_s * 1000)
	while not estado["listo"] and Time.get_ticks_msec() < limite:
		await get_tree().process_frame
	return estado["ok"]
