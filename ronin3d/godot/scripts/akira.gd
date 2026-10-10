# Akira en 3D: se mueve relativo a la cámara, corre, salta y ataca con la espada.
# Iaidō: mantener «parar» lo pone en postura con la espada envainada; al soltar desenvaina.
# Si una estocada llega justo entonces, la desvía y derriba al rival de un corte (iai
# perfecto). Con la barra de espíritu llena puede lanzar el corte de luna.
# Combate al estilo de EthrA (ver ETHRA_REFERENCIA.md): cada arma tiene su cadena de cortes
# (armas.gd), mantener atacar carga un golpe fuerte, la esquiva cancela la recuperación y tras
# un iai perfecto la cadena sigue desde el segundo corte.
extends CharacterBody3D

const Datos := preload("res://scripts/datos.gd")
const Armas := preload("res://scripts/armas.gd")

signal vida_cambiada(vida: int)
signal cayo
signal ataco
signal desenvaino                     # soltó la postura: corte de iai, acierte o no
signal paro(atacante)                 # iai perfecto contra «atacante»
signal espiritu_cambiado(valor: float)
signal pidio_corte_de_luna
signal arma_cambiada(arma: String)
signal aguante_cambiado(valor: float)
signal esquivo

var visual: Node3D
var camara
var vida_maxima := Datos.VIDA_MAXIMA   # sube con las bendiciones del jizō
var vida := Datos.VIDA_MAXIMA
var mirando := Vector3.RIGHT
var controlable := false
var invulnerable := 0.0
var protegido := 0.0                  # intocable durante el corte de luna (sin parpadeo)
var empujado := 0.0
var enfriamiento := 0.0              # tras acabar una cadena, antes de poder empezar otra
var arma := "katana"
var ataque: Dictionary = {}           # el corte en curso (de armas.gd); vacío si no ataca
var paso_combo := 0                   # índice del corte en curso dentro de la cadena
var tiempo_en_ataque := 0.0
var buffer_ataque := 0.0              # pulsación guardada para encadenar el siguiente corte
var tiempo_pulsado := -1.0            # cuánto lleva mantenido atacar (-1: suelto)
var carga_lista := false
var tras_iai := 0.0                   # ventana para seguir la cadena tras un iai perfecto
var esquiva := 0.0                    # segundos que quedan de esquiva
var direccion_esquiva := Vector3.ZERO
var enfriamiento_esquiva := 0.0
var aguante := Armas.AGUANTE_MAXIMO
var espera_aguante := 0.0
var cortes_dados := 0                 # cortes que han empezado (para pruebas y estadísticas)
var golpeados: Array = []
var destello := 0.0
var muerte := -1.0
var moviendose := false
var corriendo := false
var buffer_salto := 0.0
var coyote := 0.0
var en_postura := false
var tiempo_parada := 0.0              # ventana del iai tras soltar
var enfriamiento_parada := 0.0
var tiempo_desenvaine := 0.0
var tiempo_remate := 0.0
var espiritu := 0.0                   # de 0 a 1
var atrapado := 0.0                   # (tela de la jorōgumo, agarrón del gaki) ni andar ni iai
var coste_esquiva := 1.0              # el paso del tengu (Sōjōbō, capítulo 2) lo deja en la mitad
var buscar_rival: Callable            # lo pone el juego: devuelve el soldado más cercano


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1 | 2
	floor_snap_length = 0.25
	var capsula := CapsuleShape3D.new()
	capsula.radius = Datos.RADIO_PERSONAJE
	capsula.height = Datos.ALTO_PERSONAJE
	var forma := CollisionShape3D.new()
	forma.shape = capsula
	forma.position.y = Datos.ALTO_PERSONAJE / 2.0
	add_child(forma)


func vivo() -> bool:
	return vida > 0


func atacando() -> bool:
	return not ataque.is_empty()


# Progreso para los cuadros del sprite: la anticipación ocupa el primer 30 %, el corte hasta el
# 70 % (ahí brilla la estela) y la recuperación el resto.
func progreso_ataque() -> float:
	if ataque.is_empty():
		return 0.0
	var t := tiempo_en_ataque
	var fin_activo: float = ataque.anticipacion + ataque.activo
	if t < ataque.anticipacion:
		return 0.3 * t / maxf(ataque.anticipacion, 0.001)
	if t < fin_activo:
		return 0.3 + 0.4 * (t - ataque.anticipacion) / maxf(ataque.activo, 0.001)
	return clampf(0.7 + 0.3 * (t - fin_activo) / maxf(ataque.recuperacion, 0.001), 0.0, 1.0)


func corte_activo() -> bool:
	return atacando() and tiempo_en_ataque >= ataque.anticipacion \
		and tiempo_en_ataque <= ataque.anticipacion + ataque.activo


func en_recuperacion() -> bool:
	return atacando() and tiempo_en_ataque > ataque.anticipacion + ataque.activo


func esquivando() -> bool:
	return esquiva > 0.0


func cargando() -> bool:
	return carga_lista and not atacando()


func datos_arma() -> Dictionary:
	return Armas.datos(arma)


# Pulsar atacar: empieza la cadena o guarda la pulsación para encadenar el siguiente corte.
func iniciar_ataque() -> void:
	if not vivo() or en_postura or empujado > 0.0 or esquivando():
		return
	buffer_ataque = 0.25
	_resolver_buffer()


func _resolver_buffer() -> void:
	if buffer_ataque <= 0.0:
		return
	var combo: Array = datos_arma().combo
	if atacando():
		# Encadenar: solo en la recuperación, si la cadena sigue y el corte no es el cargado.
		if en_recuperacion() and not ataque.get("cargado", false) and paso_combo + 1 < combo.size():
			_empezar_corte(combo[paso_combo + 1], paso_combo + 1)
		return
	if tras_iai > 0.0:
		_empezar_corte(combo[mini(1, combo.size() - 1)], mini(1, combo.size() - 1))
		tras_iai = 0.0
	elif enfriamiento <= 0.0 and corriendo and is_on_floor():
		# Atacar corriendo: el ataque a la carrera de cada arma; la cadena sigue desde el 2.º corte.
		_empezar_corte(datos_arma().carrera, 0)
	elif enfriamiento <= 0.0:
		_empezar_corte(combo[0], 0)


func _empezar_corte(corte: Dictionary, paso: int, cargado := false) -> void:
	ataque = corte.duplicate()
	ataque["cargado"] = cargado
	paso_combo = paso
	tiempo_en_ataque = 0.0
	buffer_ataque = 0.0
	golpeados.clear()
	tiempo_parada = 0.0
	tiempo_desenvaine = 0.0
	tiempo_remate = 0.0
	cortes_dados += 1
	_encarar_al_atacar()
	ataco.emit()


# Al empezar un corte, Akira se gira hacia donde se empuja el stick; si no se empuja, hacia el
# rival más cercano (ayuda pensada para el móvil, como el fijado de objetivo de EthrA).
func _encarar_al_atacar() -> void:
	var entrada := Input.get_vector("mover_izquierda", "mover_derecha", "mover_adelante", "mover_atras") \
		if controlable else Vector2.ZERO
	if entrada.length() > 0.2 and camara:
		var direccion: Vector3 = camara.derecha() * entrada.x - camara.adelante() * entrada.y
		if direccion.length() > 0.01:
			mirando = direccion.normalized()
			return
	_mirar_al_rival(3.5)


func _terminar_corte() -> void:
	var era_cargado: bool = ataque.get("cargado", false)
	ataque = {}
	tiempo_en_ataque = 0.0
	if buffer_ataque > 0.0 and not era_cargado:
		return                         # _resolver_buffer empieza el siguiente en este cuadro
	paso_combo = 0
	enfriamiento = 0.08


func soltar_carga() -> void:
	if not carga_lista:
		return
	carga_lista = false
	if aguante < Armas.AGUANTE_CARGA or not vivo():
		return
	gastar_aguante(Armas.AGUANTE_CARGA)
	_empezar_corte(datos_arma().cargado, 0, true)


func cambiar_arma(nueva := "") -> void:
	if atacando() or en_postura or not vivo():
		return
	arma = nueva if nueva != "" else Armas.siguiente(arma)
	paso_combo = 0
	carga_lista = false
	arma_cambiada.emit(arma)


func gastar_aguante(cantidad: float) -> void:
	aguante = maxf(0.0, aguante - cantidad)
	espera_aguante = Armas.AGUANTE_ESPERA
	aguante_cambiado.emit(aguante)


# Esquiva: paso rápido hacia donde se empuja el stick (atrás si no se empuja). Cancela la
# recuperación de un corte y la postura del iai.
func empezar_esquiva() -> void:
	if not vivo() or esquivando() or enfriamiento_esquiva > 0.0 or empujado > 0.0:
		return
	if aguante < Armas.AGUANTE_ESQUIVA * coste_esquiva or atrapado > 0.0:
		return
	if atacando() and tiempo_en_ataque < ataque.esquiva_desde:
		return
	var entrada := Input.get_vector("mover_izquierda", "mover_derecha", "mover_adelante", "mover_atras") \
		if controlable else Vector2.ZERO
	var direccion := -mirando
	if entrada.length() > 0.2 and camara:
		direccion = (camara.derecha() * entrada.x - camara.adelante() * entrada.y).normalized()
	direccion_esquiva = direccion
	ataque = {}
	paso_combo = 0
	buffer_ataque = 0.0
	carga_lista = false
	en_postura = false
	esquiva = Armas.ESQUIVA_DURACION
	gastar_aguante(Armas.AGUANTE_ESQUIVA * coste_esquiva)
	esquivo.emit()


# Atrapado por una tela o un agarrón: no anda ni puede ponerse en postura de iai un momento.
func atrapar(segundos: float) -> void:
	atrapado = maxf(atrapado, segundos)
	en_postura = false


func _actualizar_aguante(delta: float) -> void:
	espera_aguante = maxf(0.0, espera_aguante - delta)
	if espera_aguante <= 0.0 and aguante < Armas.AGUANTE_MAXIMO and not cargando():
		aguante = minf(Armas.AGUANTE_MAXIMO, aguante + Armas.AGUANTE_RECARGA * delta)
		aguante_cambiado.emit(aguante)


func invulnerable_por_esquiva() -> bool:
	if not esquivando():
		return false
	var transcurrido := Armas.ESQUIVA_DURACION - esquiva
	return transcurrido >= Armas.ESQUIVA_INVULNERABLE.x and transcurrido <= Armas.ESQUIVA_INVULNERABLE.y


# --- Iaidō ---------------------------------------------------------------------------------

func empezar_postura() -> void:
	if not vivo() or empujado > 0.0 or atacando() or esquivando() or enfriamiento_parada > 0.0 or atrapado > 0.0:
		return
	en_postura = true
	_mirar_al_rival()


func desenvainar() -> void:
	if not en_postura:
		return
	en_postura = false
	tiempo_parada = Datos.VENTANA_PARADA
	enfriamiento_parada = Datos.ENFRIAMIENTO_PARADA
	tiempo_desenvaine = Datos.DURACION_DESENVAINE
	_mirar_al_rival()
	desenvaino.emit()


# Ayuda: en postura Akira se gira hacia el soldado más cercano, para que el iai dependa
# del momento y no de apuntar.
func _mirar_al_rival(alcance := Datos.ALCANCE_AYUDA_PARADA) -> void:
	if not buscar_rival.is_valid():
		return
	var rival = buscar_rival.call(global_position, alcance)
	if rival:
		var hacia: Vector3 = rival.global_position - global_position
		hacia.y = 0.0
		if hacia.length() > 0.01:
			mirando = hacia.normalized()


# La llama el soldado justo antes de que su estocada dé en Akira. Si Akira acaba de
# desenvainar y mira hacia él, desvía el golpe y lo corta (iai perfecto).
func intentar_parar(atacante) -> bool:
	if tiempo_parada <= 0.0 or not vivo():
		return false
	var hacia: Vector3 = atacante.global_position - global_position
	hacia.y = 0.0
	if hacia.length() > 0.01 and mirando.angle_to(hacia) > deg_to_rad(Datos.CONO_PARADA / 2.0):
		return false
	tiempo_parada = 0.0
	enfriamiento_parada = 0.0            # premio: puede volver a ponerse en postura ya
	tiempo_desenvaine = 0.0
	tiempo_remate = Datos.POSE_REMATE
	tras_iai = Armas.VENTANA_TRAS_IAI
	ganar_espiritu(Datos.ESPIRITU_POR_IAI)
	paro.emit(atacante)
	return true


func ganar_espiritu(cantidad: float) -> void:
	var antes := espiritu
	espiritu = clampf(espiritu + cantidad, 0.0, 1.0)
	if espiritu != antes:
		espiritu_cambiado.emit(espiritu)


func pedir_corte_de_luna() -> void:
	if vivo() and espiritu >= 1.0 and not en_postura:
		pidio_corte_de_luna.emit()


# El juego la llama si el corte de luna tiene a quién cortar.
func lanzar_corte_de_luna() -> void:
	espiritu = 0.0
	espiritu_cambiado.emit(espiritu)
	ataque = {}
	tiempo_remate = Datos.POSE_REMATE + 0.3
	protegido = 1.0


func recibir_golpe(desde: Vector3) -> bool:
	if invulnerable > 0.0 or protegido > 0.0 or invulnerable_por_esquiva() or not vivo():
		return false
	vida -= 1
	vida_cambiada.emit(vida)
	invulnerable = Datos.TIEMPO_INVULNERABLE
	destello = 1.0
	ataque = {}
	paso_combo = 0
	carga_lista = false
	esquiva = 0.0
	en_postura = false
	var empuje := global_position - desde
	empuje.y = 0.0
	empuje = empuje.normalized() if empuje.length() > 0.01 else -mirando
	velocity = empuje * Datos.EMPUJE_GOLPE + Vector3(0, 4.0, 0)
	empujado = Datos.TIEMPO_EMPUJE
	if vida <= 0:
		muerte = 0.0
		cayo.emit()
	return true


func _physics_process(delta: float) -> void:
	invulnerable = maxf(0.0, invulnerable - delta)
	protegido = maxf(0.0, protegido - delta)
	empujado = maxf(0.0, empujado - delta)
	enfriamiento = maxf(0.0, enfriamiento - delta)
	buffer_ataque = maxf(0.0, buffer_ataque - delta)
	tras_iai = maxf(0.0, tras_iai - delta)
	enfriamiento_esquiva = maxf(0.0, enfriamiento_esquiva - delta)
	atrapado = maxf(0.0, atrapado - delta)
	_actualizar_aguante(delta)
	if atacando():
		tiempo_en_ataque += delta
		if tiempo_en_ataque >= Armas.duracion(ataque):
			_terminar_corte()
	if esquivando():
		esquiva = maxf(0.0, esquiva - delta)
		if esquiva <= 0.0:
			enfriamiento_esquiva = Armas.ESQUIVA_ENFRIAMIENTO
	buffer_salto = maxf(0.0, buffer_salto - delta)
	coyote = maxf(0.0, coyote - delta)
	destello = maxf(0.0, destello - delta * 6.0)
	tiempo_parada = maxf(0.0, tiempo_parada - delta)
	enfriamiento_parada = maxf(0.0, enfriamiento_parada - delta)
	tiempo_desenvaine = maxf(0.0, tiempo_desenvaine - delta)
	tiempo_remate = maxf(0.0, tiempo_remate - delta)

	var entrada := Vector2.ZERO
	if controlable and vivo():
		entrada = Input.get_vector("mover_izquierda", "mover_derecha", "mover_adelante", "mover_atras")
		if Input.is_action_just_pressed("saltar"):
			buffer_salto = 0.12
		if Input.is_action_just_pressed("atacar"):
			iniciar_ataque()
			tiempo_pulsado = 0.0
		if Input.is_action_pressed("atacar") and tiempo_pulsado >= 0.0:
			tiempo_pulsado += delta
			if tiempo_pulsado >= Armas.CARGA_MINIMA and not carga_lista and not esquivando():
				carga_lista = true
		elif tiempo_pulsado >= 0.0:
			tiempo_pulsado = -1.0
			soltar_carga()
		if Input.is_action_just_pressed("esquivar"):
			empezar_esquiva()
		if Input.is_action_just_pressed("cambiar_arma"):
			cambiar_arma()
		if Input.is_action_just_pressed("parar"):
			empezar_postura()
		if en_postura and not Input.is_action_pressed("parar"):
			desenvainar()
		if Input.is_action_just_pressed("especial"):
			pedir_corte_de_luna()
	elif en_postura:
		en_postura = false
	_resolver_buffer()
	if en_postura:
		_mirar_al_rival()
	var direccion: Vector3 = camara.derecha() * entrada.x - camara.adelante() * entrada.y

	if not vivo():
		velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)
		muerte = minf(1.0, muerte + delta / 0.8)
		moviendose = false
	elif empujado > 0.0:
		moviendose = false
	elif atrapado > 0.0:
		velocity.x = 0.0
		velocity.z = 0.0
		moviendose = false
	elif esquivando():
		velocity.x = direccion_esquiva.x * Armas.ESQUIVA_RAPIDEZ
		velocity.z = direccion_esquiva.z * Armas.ESQUIVA_RAPIDEZ
		moviendose = true
	else:
		var rapidez := Datos.VELOCIDAD
		if controlable and Input.is_action_pressed("correr"):
			rapidez = Datos.VELOCIDAD_CORRER
		var quieto := en_postura or tiempo_desenvaine > 0.0 or tiempo_remate > 0.0 or cargando()
		if (atacando() or quieto) and is_on_floor():
			rapidez *= 0.4 if not atacando() else 0.15
		velocity.x = direccion.x * rapidez
		velocity.z = direccion.z * rapidez
		if corte_activo() and is_on_floor():
			# El corte lleva el cuerpo hacia delante (transferencia de peso).
			velocity.x += mirando.x * ataque.avance
			velocity.z += mirando.z * ataque.avance
		moviendose = direccion.length() > 0.1
		corriendo = moviendose and rapidez > Datos.VELOCIDAD
		if moviendose and not atacando() and not quieto:
			mirando = direccion.normalized()
		if buffer_salto > 0.0 and (is_on_floor() or coyote > 0.0):
			velocity.y = Datos.IMPULSO_SALTO
			buffer_salto = 0.0
			coyote = 0.0

	if is_on_floor():
		coyote = 0.1
	else:
		velocity.y -= Datos.GRAVEDAD * delta
	move_and_slide()
	if visual:
		visual.actualizar(delta, info())


func pose() -> String:
	if atacando():
		return ataque.pose
	if esquivando():
		return "esquiva"
	if cargando():
		return "postura"
	if tiempo_remate > 0.0:
		return "remate"
	if tiempo_desenvaine > 0.0:
		return "desenvaine"
	if en_postura:
		return "postura"
	return "normal"


func info() -> Dictionary:
	var parpadea := invulnerable > 0.0 and invulnerable <= Datos.TIEMPO_INVULNERABLE \
		and vivo() and int(invulnerable * 14.0) % 2 == 0
	var progreso := progreso_ataque()
	if tiempo_desenvaine > 0.0:
		progreso = 1.0 - tiempo_desenvaine / Datos.DURACION_DESENVAINE
	elif esquivando():
		progreso = 1.0 - esquiva / Armas.ESQUIVA_DURACION
	return {
		"mirando": mirando,
		"moviendose": moviendose,
		"corriendo": corriendo,
		"en_aire": not is_on_floor(),
		"pose": pose(),
		"progreso": progreso,
		"visible": not parpadea,
		"destello": destello,
		"muerte": muerte,
		"aviso": false,
	}
