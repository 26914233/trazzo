# Datos del capítulo 1 en 3D: medidas, reglas del combate, textos y colores.
# Todo sale de ronin3d/DISENO_3D.md; si cambia allí, se cambia aquí.
extends RefCounted

# --- Historia (textos aprobados el 1-10-2026, DECISIÓN 8A de ronin3d/HISTORIA.md) --
# El prototipo 2D (samurai.py) conserva los textos anteriores.
const TITULO := "RONIN"
const SUBTITULO := "Capítulo 1 · El castillo de Hoshiyama"
const TEXTO_INTRO := [
	"Castillo de Hoshiyama. Akira sirve como guardia del shōgun Takeda, el señor de Japón.",
	"Esta noche, el general Genzo, su mano derecha, lo ha asesinado. Para Genzo, el shōgun era demasiado blando con los yōkai.",
	"Con el shōgun cae la barrera que separaba los mundos. Los soldados ya obedecen a Genzo y algo se mueve en las sombras del patio. Akira debe abrirse paso hasta la puerta y escapar.",
]
const TITULO_CIERRE := "Fin del capítulo 1"
const TEXTO_CIERRE := [
	"Akira cruza la última puerta. El castillo de Hoshiyama queda a su espalda.",
	"Sin señor al que servir, desde esta noche es un ronin.",
	"Fuera buscará justicia. Dentro, intentará recuperar su honor. Y sobre Japón, la luna brilla más roja que nunca.",
]
const TITULO_DERROTA := "Akira ha caído"
const TEXTO_DERROTA := ["Levántate, Akira. La noche aún no ha terminado."]

# --- Akira --------------------------------------------------------------------
const VIDA_MAXIMA := 5
const INICIO_AKIRA := Vector3(-20, 0, 0)
const VELOCIDAD := 5.0
const VELOCIDAD_CORRER := 8.0
const IMPULSO_SALTO := 7.5
const GRAVEDAD := 22.0
const DURACION_ATAQUE := 0.3
const INICIO_CORTE := 0.05
const FIN_CORTE := 0.2
const ENFRIAMIENTO_ATAQUE := 0.4
const ALCANCE_ESPADA := 1.6
const CONO_ESPADA := 100.0
const TIEMPO_INVULNERABLE := 1.0
const EMPUJE_GOLPE := 6.0
const TIEMPO_EMPUJE := 0.25
const ALTO_PERSONAJE := 1.7
const RADIO_PERSONAJE := 0.35
# Iaidō (combate de precisión): mantener «parar» pone a Akira en postura con la espada
# envainada; al soltar desenvaina. Si una estocada llega dentro de la ventana, la desvía
# y derriba al rival de un solo corte (iai perfecto).
const VENTANA_PARADA := 0.3           # segundos tras soltar en los que el iai desvía el golpe
const ENFRIAMIENTO_PARADA := 0.6      # tras un iai fallido, no se puede repetir antes
const DURACION_DESENVAINE := 0.28     # cuánto se ve el corte del desenvaine
const POSE_REMATE := 0.45             # pose final tras un iai perfecto (zanshin)
const ALCANCE_AYUDA_PARADA := 4.0     # en postura, Akira se gira hacia el soldado más cercano
const CONO_PARADA := 110.0
# Espíritu: se llena con iai perfectos y cortes; lleno permite el corte de luna.
const ESPIRITU_POR_IAI := 0.5
const ESPIRITU_POR_GOLPE := 0.1
const RADIO_CORTE_LUNA := 7.0         # metros alrededor de Akira
const DURACION_CORTE_LUNA := 1.4      # segundos reales de la secuencia
# Animación limitada estilo anime: las poses cambian 12 veces por segundo («en dos»).
const PASO_ANIME := 1.0 / 12.0

# --- Soldados -----------------------------------------------------------------
const VIDA_SOLDADO := 2
const VEL_PATRULLA := 2.0
const VEL_PERSECUCION := 3.5
const VISION := 9.0
const CONO_VISION := 120.0
const VISION_CERCANA := 3.0
const CORREA := 8.0
const DISTANCIA_ATAQUE := 1.8
const TIEMPO_AVISO := 0.5
const TIEMPO_ESTOCADA := 0.2
const ALCANCE_LANZA := 2.1
const ANCHO_LANZA := 0.8
const TIEMPO_RECUPERACION := 0.6
const TIEMPO_ATURDIDO := 0.4
const EMPUJE_SOLDADO := 5.0
const TIEMPO_SIN_VER := 2.0
const TIEMPO_DESAPARECER := 1.2
const PATRULLAS := [
	[Vector3(-14, 0, -4), Vector3(-14, 0, 6)],
	[Vector3(-7, 1.2, -12), Vector3(1, 1.2, -12)],
	[Vector3(-2, 0, 4), Vector3(6, 0, 10)],
	[Vector3(10, 0, -12), Vector3(16, 0, -4)],
	[Vector3(8, 0, 2), Vector3(16, 0, 8)],
	[Vector3(19, 0, -2), Vector3(19, 0, 2)],
]

# --- Cámara ---------------------------------------------------------------------
const CAMARA_DISTANCIA := 12.0
const CAMARA_INCLINACION := 38.0
const CAMARA_GIRO := -60.0
const CAMARA_FOV := 38.0
const CAMARA_DISTANCIA_MIN := 7.0
const CAMARA_DISTANCIA_MAX := 18.0
const CAMARA_INCLINACION_MIN := -5.0
const CAMARA_INCLINACION_MAX := 60.0
const CAMARA_PRESENTACION_POSICION := Vector3(6, 3, 12)
const CAMARA_PRESENTACION_MIRA := Vector3(0, 9, -20)

# --- Escenario ------------------------------------------------------------------
const ANTORCHAS := [
	Vector2(-12, -14.5), Vector2(8, -14.5), Vector2(-8, 14.5), Vector2(8, 14.5),
	Vector2(-23, -6), Vector2(-23, 6), Vector2(22.5, -4.5), Vector2(22.5, 4.5),
]
const LINTERNAS := [Vector2(-12, -8), Vector2(-12, 8), Vector2(12, -8), Vector2(12, 8)]
const DIRECCION_LUNA := Vector3(-0.3, 0.32, -0.9)
const LIMITE_PORTON_X := 23.0

# --- Colores (DISENO_3D.md, sección 10) -----------------------------------------
const KIMONO := Color("344276")
const KIMONO_OSCURO := Color("242e56")
const HAKAMA := Color("22243a")
const OBI := Color("a02e2a")
const HACHIMAKI := Color("eeeef2")
const PIEL := Color("e4be98")
const PELO := Color("141218")
const TABI := Color("dedee2")
const ACERO := Color("e0e8f6")
const TSUKA := Color("cec2a4")
const SAYA := Color("461a1e")
const ARMADURA := Color("7e2a24")
const ARMADURA_CLARA := Color("a8483a")
const ARMADURA_OSCURA := Color("541a18")
const SOMBRERO := Color("5c4a32")
const PANTALON := Color("3a3842")
const MADERA_LANZA := Color("7a5836")
const LUZ_ANTORCHA := Color("ffae5c")
const LUZ_LUNA := Color("9fb4ff")
const AMBIENTE := Color("1a1f3a")
const DORADO := Color("e2ba62")
const ROJO_VIDA := Color("c8322e")
const CREMA := Color("eee4c8")
