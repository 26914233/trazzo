# Imita BillingClient del plugin godot-google-play-billing (mismas señales y
# metodos) para probar el flujo de cobro sin Play Store.
extends RefCounted

signal connected
signal disconnected
signal connect_error(code: int, msg: String)
signal query_product_details_response(r: Dictionary)
signal query_purchases_response(r: Dictionary)
signal on_purchase_updated(r: Dictionary)
signal consume_purchase_response(r: Dictionary)
signal acknowledge_purchase_response(r: Dictionary)

enum BillingResponseCode { OK = 0, USER_CANCELED = 1, ERROR = 6 }
enum PurchaseState { UNSPECIFIED, PURCHASED, PENDING }
enum ProductType { INAPP, SUBS }

var modo := "ok"                 ## ok | cancelar | pendiente | falla_confirmar
var compras_previas: Array = []  ## lo que devuelve query_purchases
var consumidos: Array = []
var reconocidos: Array = []
var _n := 0


func start_connection() -> void:
	connected.emit.call_deferred()


func query_product_details(_ids, _tipo) -> void:
	query_product_details_response.emit.call_deferred({"response_code": 0, "product_details": []})


func query_purchases(_tipo) -> void:
	query_purchases_response.emit.call_deferred({"response_code": 0, "purchases": compras_previas})


func purchase(id: String) -> Dictionary:
	_n += 1
	var token := "tok_%s_%d" % [id, _n]
	match modo:
		"cancelar":
			on_purchase_updated.emit.call_deferred({"response_code": BillingResponseCode.USER_CANCELED, "debug_message": "cancelada"})
		"pendiente":
			on_purchase_updated.emit.call_deferred({"response_code": 0, "purchases": [compra(id, PurchaseState.PENDING, token)]})
		_:
			on_purchase_updated.emit.call_deferred({"response_code": 0, "purchases": [compra(id, PurchaseState.PURCHASED, token)]})
	return {"response_code": 0}


static func compra(id: String, estado: int, token: String, reconocida := false) -> Dictionary:
	return {"product_ids": [id], "purchase_state": estado, "purchase_token": token, "is_acknowledged": reconocida}


func consume_purchase(token: String) -> void:
	consumidos.append(token)
	consume_purchase_response.emit.call_deferred({"response_code": 6 if modo == "falla_confirmar" else 0, "token": token})


func acknowledge_purchase(token: String) -> void:
	reconocidos.append(token)
	acknowledge_purchase_response.emit.call_deferred({"response_code": 6 if modo == "falla_confirmar" else 0, "token": token})
