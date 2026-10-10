# Cuando se puede mostrar un anuncio a pantalla completa (intersticial).
# Reglas acordadas con el dueño (docs/MONETIZACION.md), contra la queja n.º 1 del
# genero ("anuncio tras cada nivel"). Separado para probarlo sin plugin ni red.
class_name ReglasAnuncios
extends RefCounted

const NIVELES_SIN_ANUNCIOS := 10    ## los 10 primeros niveles superados, limpios
const SEPARACION_MIN_S := 180.0     ## nunca dos en menos de 3 minutos
const CADA_N_NIVELES := 3           ## como mucho uno cada 3 niveles superados


## contexto:
##   sin_anuncios: bool            compro "quitar anuncios"
##   tras_perder: bool             sale tras perder (nunca se castiga al que se frustra)
##   abandono: bool                sale de un nivel sin terminarlo
##   superados: int                niveles superados en total
##   desde_ultimo_s: float         segundos desde el ultimo (INF si nunca)
##   superados_desde_ultimo: int   niveles superados desde el ultimo
static func intersticial_permitido(contexto: Dictionary) -> bool:
	if contexto.get("sin_anuncios", false):
		return false
	if contexto.get("tras_perder", false) or contexto.get("abandono", false):
		return false
	if contexto.get("superados", 0) <= NIVELES_SIN_ANUNCIOS:
		return false
	if contexto.get("desde_ultimo_s", INF) < SEPARACION_MIN_S:
		return false
	return contexto.get("superados_desde_ultimo", 0) >= CADA_N_NIVELES
