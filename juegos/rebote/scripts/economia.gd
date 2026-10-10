# Reglas de la economia de gemas. Clase pura y estatica: se prueba sin escena.
# Principio (de las reseñas del genero): todo se puede ganar jugando, nada bloquea
# niveles y nada de lo que se compra es necesario para terminar el juego.
class_name Economia
extends RefCounted

const GEMAS_NIVEL := 5            ## por superar un nivel
const GEMAS_ESTRELLA := 5         ## por cada estrella nueva (mejor marca del nivel)
const GEMAS_PREMIADO := 25        ## anuncio voluntario en la tienda
const PREMIADOS_DIA := 10         ## tope de anuncios con gemas al dia (no es una granja)
const PRECIO_SEGUIR := 50         ## seguir con una vida tras perder, sin anuncio
const GEMAS_MAX := 9_999_999

## Potenciadores al empezar un nivel.
const ARRANQUES := {
	"ancha": {"nombre": "Paleta ancha", "precio": 30, "potenciador": Partida.ANCHA},
	"multibola": {"nombre": "Multibola", "precio": 45, "potenciador": Partida.MULTIBOLA},
	"vida": {"nombre": "Vida extra", "precio": 60, "potenciador": Partida.VIDA},
}


## Gemas por superar un nivel: base + las estrellas nuevas.
static func gemas_por_nivel(estrellas_antes: int, estrellas_ahora: int) -> int:
	return GEMAS_NIVEL + GEMAS_ESTRELLA * maxi(0, estrellas_ahora - estrellas_antes)
