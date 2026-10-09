# Paquetes de pistas: la unica compra dentro de Palabrario (app de pago, sin
# anuncios). Cobro con Google Play Billing (scripts/proveedores/pagos_play.gd)
# cuando el plugin esta instalado; ver docs/PUBLICAR.md.
#
# Lo comprado se entrega solo cuando Play confirma (la compra se consume):
# sin dobles entregas, y una compra pendiente o a medias se entrega sola
# cuando Play avise, aunque sea en otra sesion.
extends Node

signal compra_completada(producto: String)

## Catalogo. Los IDs deben crearse igual en Play Console (productos in-app consumibles).
const PAQUETES := {
	"pistas_10": {"pistas": 10, "precio": "0,99 US$"},
	"pistas_30": {"pistas": 30, "precio": "1,99 US$"},
	"pistas_100": {"pistas": 100, "precio": "4,99 US$", "destacado": true},
}

var pagos: PagosPlay = null
## Sin plugin de pagos, la compra se simula SOLO en depuracion (escritorio,
## pruebas). En una build de release sin plugin, comprar falla: nunca regala.
var permitir_simulada := OS.is_debug_build()
var simulada_exito := true
var simulada_demora_s := 0.4


func _ready() -> void:
	if OS.get_name() == "Android" and ClasesPlugin.existe("BillingClient"):
		var ids := PackedStringArray(PAQUETES.keys())
		pagos = PagosPlay.new(ClasesPlugin.nueva("BillingClient"), ids, ids)
		# Toda entrega real pasa por aqui: compra normal, pendiente que se paga
		# mas tarde y compra a medias recuperada al abrir la app.
		pagos.compra_confirmada.connect(conceder)


func pagos_reales() -> bool:
	return pagos != null


## Lista blanca: solo el catalogo.
func producto_valido(producto: String) -> bool:
	return PAQUETES.has(producto)


func comprar(producto: String) -> bool:
	if not producto_valido(producto):
		push_error("Producto desconocido: %s" % producto)
		return false
	if pagos:
		# La entrega la hace la señal compra_confirmada, no este retorno.
		return await pagos.comprar(producto, get_tree())
	if not permitir_simulada:
		push_error("Compra sin plugin de pagos en una build de release: no se entrega nada.")
		return false
	await get_tree().create_timer(simulada_demora_s).timeout
	if simulada_exito:
		conceder(producto)
	return simulada_exito


func conceder(producto: String) -> void:
	if not producto_valido(producto):
		push_error("Producto fuera del catalogo, no se entrega: %s" % producto)
		return
	Progreso.sumar_pistas(int(PAQUETES[producto]["pistas"]))
	compra_completada.emit(producto)
