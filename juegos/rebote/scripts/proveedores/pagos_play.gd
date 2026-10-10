# Compras con Google Play Billing a traves del plugin oficial de Godot
# (godot-sdk-integrations/godot-google-play-billing, Godot 4.2+).
# API segun su documentacion: BillingClient, start_connection(),
# query_product_details(), purchase(), consume_purchase(),
# acknowledge_purchase(), query_purchases() y sus señales.
#
# El cliente se inyecta: en el juego es BillingClient.new(); en las pruebas,
# un falso con las mismas señales (tests/falso_billing.gd).
class_name PagosPlay
extends RefCounted

## Una compra quedo pagada y confirmada. Monetizacion la entrega.
signal compra_confirmada(producto: String)
## Respuesta correcta de query_purchases: compras permanentes que Play dice
## que el usuario tiene. Monetizacion las usa como fuente de verdad.
signal permanentes_sincronizados(productos: Array)

# Valores de la Play Billing Library (BillingResponseCode.OK = 0;
# PurchaseState: UNSPECIFIED=0, PURCHASED=1, PENDING=2). Se leen del cliente
# si los expone, y estos son el respaldo.
var OK := 0
var COMPRADO := 1
var PENDIENTE := 2
var INAPP := 0

var cliente: Object
var consumibles: PackedStringArray
var conectado := false
var _pendientes_token := {}   ## token -> producto, esperando consume/acknowledge
var _ultimo_resultado := {}   ## producto -> "ok" | "pendiente" | "error"
var _en_vuelo := {}           ## productos con compra lanzada y sin resultado
var precios := {}             ## producto -> precio en la moneda del jugador ("1,09 €")


func _init(cliente_billing: Object, ids_productos: PackedStringArray, ids_consumibles: PackedStringArray) -> void:
	cliente = cliente_billing
	consumibles = ids_consumibles
	OK = ClasesPlugin.enum_de(cliente, "BillingResponseCode", "OK", 0)
	COMPRADO = ClasesPlugin.enum_de(cliente, "PurchaseState", "PURCHASED", 1)
	PENDIENTE = ClasesPlugin.enum_de(cliente, "PurchaseState", "PENDING", 2)
	INAPP = ClasesPlugin.enum_de(cliente, "ProductType", "INAPP", 0)
	cliente.connected.connect(func():
		conectado = true
		cliente.query_product_details(ids_productos, INAPP)
		# Al conectar se revisan compras previas: recupera las que quedaron
		# sin entregar (la app se cerro a mitad) y restaura las permanentes.
		cliente.query_purchases(INAPP))
	cliente.disconnected.connect(func(): conectado = false)
	cliente.query_product_details_response.connect(_al_recibir_detalles)
	cliente.on_purchase_updated.connect(_al_actualizar)
	cliente.query_purchases_response.connect(_al_consultar)
	cliente.consume_purchase_response.connect(_al_confirmar)
	cliente.acknowledge_purchase_response.connect(_al_confirmar)
	cliente.start_connection()


## Lanza la compra y espera el resultado. true solo si quedo pagada y
## confirmada (consumida o reconocida). Una compra PENDIENTE (pago en
## efectivo, por ejemplo) devuelve false y se entrega mas tarde sola,
## cuando Play avise, via compra_confirmada.
func comprar(producto: String, arbol: SceneTree, espera_max_s: float = 300.0) -> bool:
	if not conectado:
		return false
	_ultimo_resultado.erase(producto)
	var lanzado: Dictionary = cliente.purchase(producto)
	if int(lanzado.get("response_code", -1)) != OK:
		return false
	_en_vuelo[producto] = true
	var limite := Time.get_ticks_msec() + int(espera_max_s * 1000)
	while not _ultimo_resultado.has(producto) and Time.get_ticks_msec() < limite:
		await arbol.process_frame
	_en_vuelo.erase(producto)
	return _ultimo_resultado.get(producto, "") == "ok"


## Precios reales de Play (moneda e impuestos del pais del jugador). Claves
## segun Utils.productDetailsToDictionary del plugin: product_id y
## one_time_purchase_offer_details_list[i].formatted_price.
func _al_recibir_detalles(resultado: Dictionary) -> void:
	if int(resultado.get("response_code", -1)) != OK:
		return
	for d in resultado.get("product_details", []):
		if typeof(d) != TYPE_DICTIONARY:
			continue
		var ofertas = d.get("one_time_purchase_offer_details_list")
		if typeof(ofertas) == TYPE_ARRAY and not ofertas.is_empty() and typeof(ofertas[0]) == TYPE_DICTIONARY:
			var precio := str(ofertas[0].get("formatted_price", ""))
			if precio != "":
				precios[str(d.get("product_id", ""))] = precio


func pedir_restauracion() -> void:
	if conectado:
		cliente.query_purchases(INAPP)


func _al_consultar(resultado: Dictionary) -> void:
	if int(resultado.get("response_code", -1)) != OK:
		return  # sin respuesta valida no se revoca nada ni se cancela nada en curso
	var permanentes: Array = []
	for compra in resultado.get("purchases", []):
		var productos: Array = compra.get("product_ids", [])
		if productos.is_empty() or int(compra.get("purchase_state", 0)) != COMPRADO:
			continue
		if not (productos[0] in consumibles):
			permanentes.append(productos[0])
	permanentes_sincronizados.emit(permanentes)
	_al_actualizar(resultado)


func _al_actualizar(resultado: Dictionary) -> void:
	if int(resultado.get("response_code", -1)) != OK:
		# Cancelada por el jugador o error: se marca para que comprar() vuelva.
		for p in _productos_en_vuelo():
			_ultimo_resultado[p] = "error"
		return
	for compra in resultado.get("purchases", []):
		var productos: Array = compra.get("product_ids", [])
		if productos.is_empty():
			continue
		var producto: String = productos[0]
		var estado := int(compra.get("purchase_state", 0))
		if estado == PENDIENTE:
			_ultimo_resultado[producto] = "pendiente"
			continue
		if estado != COMPRADO:
			continue
		var token: String = compra.get("purchase_token", "")
		if producto in consumibles:
			_pendientes_token[token] = producto
			cliente.consume_purchase(token)
		elif not compra.get("is_acknowledged", false):
			_pendientes_token[token] = producto
			cliente.acknowledge_purchase(token)
		else:
			# Permanente ya reconocida: es una restauracion. Se entrega (es
			# idempotente: desbloquear dos veces no regala nada).
			_ultimo_resultado[producto] = "ok"
			compra_confirmada.emit(producto)


## Respuesta de consume/acknowledge. Solo aqui se entrega lo comprado: si se
## entregase antes y la confirmacion fallase, Play reembolsaria y el jugador
## se quedaria con el producto gratis.
func _al_confirmar(resultado: Dictionary) -> void:
	var token: String = resultado.get("token", "")
	if not _pendientes_token.has(token):
		return
	var producto: String = _pendientes_token[token]
	_pendientes_token.erase(token)
	if int(resultado.get("response_code", -1)) == OK:
		_ultimo_resultado[producto] = "ok"
		compra_confirmada.emit(producto)
	else:
		_ultimo_resultado[producto] = "error"


func _productos_en_vuelo() -> Array:
	# Play no dice que producto se cancelo; se marcan todas las compras en
	# curso que aun no tienen resultado.
	var r: Array = []
	for p in _en_vuelo:
		if not _ultimo_resultado.has(p):
			r.append(p)
	return r
