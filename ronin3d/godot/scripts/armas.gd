# Armas de Akira y sus combos, como datos (para ajustar el combate sin tocar la lógica).
#
# Referencia: el combate de EthrA (ronin3d/ETHRA_REFERENCIA.md). Lo observado allí: cada arma
# tiene su propia cadena (espada: 3 cortes; lanza: estocadas rápidas y largas; mandoble:
# barridos lentos y anchos que rompen la postura), mantener el botón carga un ataque fuerte
# (con la espada, un corte giratorio de 360°), la esquiva cancela la recuperación y cada impacto
# congela la imagen de 2 a 5 cuadros (más con el mandoble).
#
# Tiempos en segundos, desde que empieza el ataque:
#   anticipacion   preparación (el golpe aún no corta)
#   activo         cuánto dura el corte tras la anticipación (ahí se resuelven los impactos)
#   recuperacion   tras el corte; durante ella se puede encadenar el siguiente
#   esquiva_desde  desde cuándo la esquiva cancela el ataque
# Impacto:
#   danio, postura (lo que llena la barra de equilibrio del rival), empuje (m/s), alcance (m),
#   cono (grados; 360 = alrededor), avance (m/s hacia delante durante el corte), pausa (s de
#   congelación), sacudida (0-1), pose (qué animación del sprite usa: desenvaine, kesa, gyaku,
#   ataque, giro, tsuki, barrido o barrido_giro; ver hornear_sprites.gd).
extends RefCounted

const ORDEN := ["katana", "yari", "nodachi"]

# Mantener el botón al menos esto (contando el primer corte) suelta el ataque cargado.
const CARGA_MINIMA := 0.55
# Tras un iai perfecto, pulsar atacar dentro de esta ventana sigue la cadena desde el 2.º corte.
const VENTANA_TRAS_IAI := 0.6
# Esquiva: paso rápido con invulnerabilidad, cancela la recuperación de cualquier ataque.
const ESQUIVA_DURACION := 0.32
const ESQUIVA_RAPIDEZ := 10.0
const ESQUIVA_INVULNERABLE := Vector2(0.03, 0.24)   # desde, hasta
const ESQUIVA_ENFRIAMIENTO := 0.15
# Aguante (barra amarilla del HUD, como en EthrA): lo gastan la esquiva y la carga.
const AGUANTE_MAXIMO := 100.0
const AGUANTE_ESQUIVA := 25.0
const AGUANTE_CARGA := 20.0
const AGUANTE_RECARGA := 40.0                 # por segundo
const AGUANTE_ESPERA := 0.5                   # segundos sin gastar antes de recargar


static func _corte(nombre: String, anticipacion: float, activo: float, recuperacion: float,
		danio: int, postura: float, empuje: float, alcance: float, cono: float, avance: float,
		pausa: float, sacudida: float, pose: String) -> Dictionary:
	return {
		"nombre": nombre, "anticipacion": anticipacion, "activo": activo,
		"recuperacion": recuperacion, "esquiva_desde": anticipacion + activo * 0.5,
		"danio": danio, "postura": postura, "empuje": empuje, "alcance": alcance, "cono": cono,
		"avance": avance, "pausa": pausa, "sacudida": sacudida, "pose": pose,
	}


static func datos(arma: String) -> Dictionary:
	match arma:
		"yari":
			# Lanza: estocadas rápidas, largas y estrechas (EthrA 21:28, 36:00-36:06).
			return {
				"nombre": "Yari", "color": Color(0.85, 0.95, 1.0),
				"combo": [
					_corte("Tsuki", 0.08, 0.10, 0.20, 1, 0.20, 3.5, 2.6, 40.0, 3.0, 0.05, 0.22, "tsuki"),
					_corte("Ni-dan tsuki", 0.06, 0.10, 0.20, 1, 0.20, 3.5, 2.6, 40.0, 3.0, 0.05, 0.22, "tsuki"),
					_corte("Sandan tsuki", 0.12, 0.14, 0.34, 1, 0.35, 6.0, 2.9, 50.0, 5.0, 0.08, 0.35, "tsuki"),
				],
				"carrera": _corte("Tsuki a la carrera", 0.06, 0.16, 0.32, 1, 0.35, 6.0, 2.8, 40.0, 9.0, 0.07, 0.3, "tsuki"),
				"cargado": _corte("Estocada del cometa", 0.10, 0.22, 0.45, 2, 0.6, 8.0, 4.0, 45.0, 12.0, 0.10, 0.5, "tsuki"),
			}
		"nodachi":
			# Mandoble: barridos lentos (unos 20-25 cuadros a 60 fps de preparación) y anchos
			# que rompen la postura y empujan a varios (EthrA 39:20-39:35, 49:22-49:40).
			return {
				"nombre": "Nodachi", "color": Color(1.0, 0.7, 0.45),
				"combo": [
					_corte("Yoko-nagi", 0.36, 0.16, 0.42, 2, 0.55, 7.5, 2.3, 200.0, 1.5, 0.11, 0.5, "barrido"),
					_corte("Gyaku-nagi", 0.34, 0.16, 0.55, 2, 0.75, 10.0, 2.3, 200.0, 1.5, 0.13, 0.6, "barrido"),
				],
				"carrera": _corte("Nagi a la carrera", 0.22, 0.18, 0.5, 2, 0.6, 9.0, 2.4, 160.0, 7.0, 0.12, 0.55, "barrido"),
				"cargado": _corte("Tenchi-giri", 0.30, 0.20, 0.65, 3, 1.2, 11.0, 2.8, 360.0, 0.0, 0.16, 0.8, "barrido_giro"),
			}
		_:
			# Katana con iaidō: la cadena es una serie de cortes de iai. El primero es el
			# desenvaine (nukitsuke) y el último un corte vertical que derriba. Equivale a la
			# espada de EthrA (3 cortes, 02:38-03:03), con un cuarto que remata.
			return {
				"nombre": "Katana", "color": Color(0.75, 0.85, 1.0),
				"combo": [
					_corte("Nukitsuke", 0.05, 0.12, 0.18, 1, 0.25, 4.0, 1.7, 110.0, 2.0, 0.06, 0.28, "desenvaine"),
					_corte("Kesa-giri", 0.06, 0.12, 0.18, 1, 0.25, 4.0, 1.7, 110.0, 2.0, 0.06, 0.28, "kesa"),
					_corte("Gyaku-kesa", 0.06, 0.12, 0.20, 1, 0.25, 4.5, 1.7, 110.0, 2.0, 0.06, 0.30, "gyaku"),
					_corte("Karatake-wari", 0.12, 0.14, 0.36, 1, 0.45, 8.0, 1.9, 90.0, 3.5, 0.10, 0.45, "ataque"),
				],
				# A la carrera: un iai de paso que lleva el cuerpo hacia delante (EthrA 02:46).
				"carrera": _corte("Iai a la carrera", 0.05, 0.16, 0.3, 1, 0.35, 6.0, 1.9, 100.0, 9.0, 0.07, 0.32, "desenvaine"),
				# Como el corte giratorio de la espada de EthrA (02:59): un iai alrededor.
				"cargado": _corte("Iai de luna creciente", 0.08, 0.18, 0.45, 2, 0.8, 7.0, 2.4, 360.0, 0.0, 0.12, 0.55, "giro"),
			}


static func siguiente(arma: String) -> String:
	return ORDEN[(ORDEN.find(arma) + 1) % ORDEN.size()]


static func duracion(ataque: Dictionary) -> float:
	return ataque.anticipacion + ataque.activo + ataque.recuperacion
