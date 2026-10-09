# Cuando se puede mostrar un intersticial. Reglas duras en docs/MONETIZACION.md.
# Separado de la capa de anuncios para poder probarlo sin plugin ni red.
class_name ReglasAnuncios
extends RefCounted

const NIVELES_SIN_ANUNCIOS := 3     ## onboarding: los 3 primeros niveles, limpios
const SEPARACION_MIN_S := 90.0
const CADA_N_NIVELES := 3


## `contexto`:
##   sin_anuncios: bool            compro "quitar anuncios"
##   en_partida: bool              hay una partida en curso
##   abandono: bool                vuelve al menu tras abandonar el nivel
##   niveles_completados: int      total historico del jugador
##   desde_ultimo_s: float         segundos desde el ultimo intersticial (INF si nunca)
##   completados_desde_ultimo: int niveles completados desde el ultimo intersticial
static func intersticial_permitido(contexto: Dictionary) -> bool:
	if contexto.get("sin_anuncios", false):
		return false
	if contexto.get("en_partida", false):
		return false
	if contexto.get("abandono", false):
		return false
	if contexto.get("niveles_completados", 0) <= NIVELES_SIN_ANUNCIOS:
		return false
	if contexto.get("desde_ultimo_s", INF) < SEPARACION_MIN_S:
		return false
	return contexto.get("completados_desde_ultimo", 0) >= CADA_N_NIVELES
