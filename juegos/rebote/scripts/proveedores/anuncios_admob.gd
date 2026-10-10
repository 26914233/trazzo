# Anuncios con AdMob a traves del plugin de Poing Studios (Godot 4.5+).
# API segun su documentacion (poingstudios.github.io/godot-admob-plugin/stable):
# MobileAds, InterstitialAdLoader, RewardedAdLoader, FullScreenContentCallback,
# OnUserEarnedRewardListener y UserMessagingPlatform para el consentimiento.
#
# Las clases se resuelven en tiempo de ejecucion (ClasesPlugin) para que el
# proyecto compile sin el plugin instalado.
class_name AnunciosAdMob
extends RefCounted

signal resultado(ok: bool)

var _ids := {}                  ## "intersticial"/"premiado" -> unit id
var _cargados := {}             ## tipo -> objeto de anuncio listo
var _cargando := {}
var _recompensa_ganada := false
var _mostrando := ""


static func disponible() -> bool:
	return OS.get_name() == "Android" and ClasesPlugin.existe("MobileAds")


func iniciar(ids: Dictionary) -> void:
	_ids = ids
	var ump := ClasesPlugin.script_de("UserMessagingPlatform")
	var params := ClasesPlugin.nueva("ConsentRequestParameters")
	if ump == null or params == null:
		_arrancar_sdk()
		return
	params.tag_for_under_age_of_consent = false
	ump.consent_information.update(params,
		func(): _tras_consentimiento(ump),
		func(_error): _arrancar_sdk())  # sin respuesta: se usa el consentimiento previo


func _tras_consentimiento(ump: Script) -> void:
	if not ump.consent_information.get_is_consent_form_available():
		_arrancar_sdk()
		return
	ump.load_consent_form(
		func(formulario):
			var requerido = ump.consent_information.ConsentStatus.REQUIRED
			if ump.consent_information.get_consent_status() == requerido:
				formulario.show(func(_e): _arrancar_sdk())
			else:
				_arrancar_sdk(),
		func(_error): _arrancar_sdk())


func _arrancar_sdk() -> void:
	ClasesPlugin.script_de("MobileAds").initialize()
	cargar("intersticial")
	cargar("premiado")


func listo(tipo: String) -> bool:
	return _cargados.has(tipo)


func cargar(tipo: String) -> void:
	if _cargados.has(tipo) or _cargando.get(tipo, false):
		return
	_cargando[tipo] = true
	var prefijo := "InterstitialAd" if tipo == "intersticial" else "RewardedAd"
	var cb := ClasesPlugin.nueva(prefijo + "LoadCallback")
	cb.on_ad_loaded = func(anuncio):
		_cargando[tipo] = false
		var pantalla := ClasesPlugin.nueva("FullScreenContentCallback")
		pantalla.on_ad_dismissed_full_screen_content = func(): _terminar(tipo, true)
		pantalla.on_ad_failed_to_show_full_screen_content = func(_e): _terminar(tipo, false)
		anuncio.full_screen_content_callback = pantalla
		_cargados[tipo] = anuncio
	cb.on_ad_failed_to_load = func(_error):
		_cargando[tipo] = false
	ClasesPlugin.nueva(prefijo + "Loader").load(_ids[tipo], ClasesPlugin.nueva("AdRequest"), cb)


## Muestra un anuncio. La señal `resultado` llega con true si el intersticial
## se cerro normalmente o si el premiado se vio hasta conceder la recompensa.
func mostrar(tipo: String) -> Signal:
	if not _cargados.has(tipo) or _mostrando != "":
		cargar(tipo)
		resultado.emit.call_deferred(false)
		return resultado
	_mostrando = tipo
	_recompensa_ganada = false
	var anuncio = _cargados[tipo]
	if tipo == "premiado":
		var escucha := ClasesPlugin.nueva("OnUserEarnedRewardListener")
		escucha.on_user_earned_reward = func(_item): _recompensa_ganada = true
		anuncio.show(escucha)
	else:
		anuncio.show()
	return resultado


func _terminar(tipo: String, cerrado_bien: bool) -> void:
	if _mostrando != tipo:
		return
	_mostrando = ""
	var anuncio = _cargados.get(tipo)
	_cargados.erase(tipo)
	if anuncio:
		anuncio.destroy()   # obligatorio segun la doc del plugin: libera memoria nativa
	cargar(tipo)            # el siguiente ya se va cargando
	var ok := cerrado_bien and (tipo != "premiado" or _recompensa_ganada)
	resultado.emit(ok)
