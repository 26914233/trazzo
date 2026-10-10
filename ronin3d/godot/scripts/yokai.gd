# Criatura del bestiario como enemigo (kappa, oni, onibi y las de los capítulos 2 a 4) y también los
# jefes de esos capítulos (Sōjōbō, Bahamut, Genzo, Tamamo-no-Mae). El perfil sale de enemigos.gd y el
# aspecto es su hoja de sprites (visual_hoja.gd). Tiene la misma interfaz que soldado.gd, así que la
# espada, el iai, el corte de luna y la ayuda para encarar funcionan igual con todos.
#
# Cada criatura es una suma de conductas que se activan por claves de su perfil (enemigos.gd explica
# cada una): ataques con forma (franja, disparo, área, invocación) y en cadena, disfraces que
# despiertan, escudos y corazas, copias falsas, manadas, curanderas, crías, división, resurrección,
# niebla, piedra si se le mira, vuelo y fases de jefe.
extends CharacterBody3D

const Datos := preload("res://scripts/datos.gd")
const Enemigos := preload("res://scripts/enemigos.gd")
const VisualYokai := preload("res://scripts/visual_yokai.gd")
const VisualHoja := preload("res://scripts/visual_hoja.gd")
const VisualSprite := preload("res://scripts/visual_sprite.gd")
const VisualObjeto := preload("res://scripts/visual_objeto.gd")
const Proyectil := preload("res://scripts/proyectil.gd")
const ZonaPeligro := preload("res://scripts/zona_peligro.gd")
const Jizo := preload("res://scripts/jizo.gd")

enum Estado { QUIETO, ALERTA, PREPARANDO, ATACANDO, RECUPERANDO, ATURDIDO, REVERENCIA, MUERTO,
	DORMIDO, NIEBLA, DESARMADO }

signal derrotado
signal aviso_iniciado
signal estocada_iniciada
signal desperto
signal mensaje(texto: String)
signal impacto_area(punto: Vector3)
signal transformado                   # Tamamo: termina su forma humana (el juego trae la siguiente)

# Solo uno de cada enjambre o manada se lanza a la vez (onibi, okuri-inu…).
static var lanzandose := {}

var tipo := ""
var perfil: Dictionary = {}
var visual: Node3D
var objetivo
var aspecto
var efectos                           # lo pone el juego (proyectiles, zonas y textos)
var invocador: Callable               # lo pone el juego: crea un enemigo (tipo, lugar) y lo devuelve
var puesto := Vector3.ZERO
var estado := Estado.QUIETO
var vida := 1
var vida_maxima := 1
var mirando := Vector3.FORWARD
var temporizador := 0.0
var destello := 0.0
var postura := 0.0
var peso := 1.0
var rota := 0.0
var muerte := -1.0
var moviendose := false
var golpe_dado := false
var ataque: Dictionary = {}
var indice_ataque := 0
var golpes_restantes := 0             # golpes que quedan de una cadena
var tiempo_reverencia := 0.0          # (kappa) segundos con Akira en postura delante
var sin_agua := false                 # (kappa) derramó el agua del plato: un golpe lo derriba
var angulo_orbita := 0.0
var azar := RandomNumberGenerator.new()
var protegido := false                # el juego lo protege (jefe tras una barrera de sellos)
var sellos: Array = []                # (Bahamut) los dogū que lo encadenan
var cadenas: Array = []
var libre_anunciado := false
var bloqueo := false                  # el último golpe se bloqueó (el juego enseña «¡Bloqueado!»)
var en_piedra := false                # (gárgola) quieta e intocable mientras Akira la mira
var golpes_recibidos := 0
var revivio := false
var golpes_en_el_suelo := 0
var fases_hechas: Array = []
var mult_velocidad := 1.0
var mult_aviso := 1.0
var mult_danio_recibido := 1.0
var patron: Array = []
var espera_espejo := 0.0
var espera_cura := 0.0
var espera_crias := 0.0
var crias: Array = []
var ultimo_corte_visto := 0
var tiempo_rastro := 0.0
var zona_actual = null
var disfraz: Node3D                   # el jizō de piedra del tanuki
var despierto_anunciado := false
var altura_vuelo := 0.0
var golpe_de_iai := false             # el iai no rebota en corazas ni escudos (rompe la guardia)
var sin_alcanzar := 0.0               # segundos sin poder usar el ataque que toca en su patrón


func configurar(tipo_nuevo: String, lugar: Vector3, akira, aspecto_del_juego) -> void:
	tipo = tipo_nuevo
	perfil = Enemigos.perfil(tipo)
	aspecto = aspecto_del_juego
	vida = int(perfil.vida)
	vida_maxima = vida
	peso = float(perfil.peso)
	objetivo = akira
	puesto = lugar
	position = lugar
	mirando = perfil.get("mirando", Vector3.FORWARD)
	azar.seed = hash(lugar) + hash(tipo)
	angulo_orbita = azar.randf() * TAU
	patron = perfil.get("patron", [])
	if perfil.has("modelo"):
		visual = VisualObjeto.new()
		visual.configurar(String(perfil.modelo), aspecto)
	elif perfil.get("visual_akira", false) and VisualSprite.activo:
		visual = VisualSprite.new()
		visual.configurar(aspecto, "akira", "joven")
		visual.material.set_shader_parameter("tinte", perfil.get("tinte", Color(0.4, 0.3, 0.45)))
	elif perfil.has("hoja") and (VisualSprite.activo or not perfil.has("receta")):
		visual = VisualHoja.new()
		visual.configurar(String(perfil.hoja), float(perfil.alto), perfil.get("flota", false), {
			"tinte": perfil.get("tinte", Color(1, 1, 1, 1)), "sin_sombra": perfil.get("falsa", false),
			"altura_flota": perfil.get("altura_flota", 0.5)})
	else:
		visual = VisualYokai.new()
		visual.configurar(aspecto, perfil)
	add_child(visual)
	if perfil.get("disfraz", "") == "jizo":
		disfraz = Jizo.new()
		add_child(disfraz)
		disfraz.configurar(aspecto)
		disfraz.rotation.y = PI / 2.0
	if perfil.has("disfraz") or perfil.has("despierta") or perfil.has("despierta_si_corre") \
			or perfil.get("objetivo", false):
		estado = Estado.DORMIDO
	add_to_group("yokai")


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1 | 2
	floor_snap_length = 0.25
	var capsula := CapsuleShape3D.new()
	var tamano := String(perfil.get("receta", {}).get("tamano", perfil.get("tamano", "M")))
	var escala: float = {"S": 0.6, "M": 1.0, "L": 1.5, "XL": 2.2}.get(tamano, 1.0)
	capsula.radius = Datos.RADIO_PERSONAJE * maxf(escala, 0.8)
	capsula.height = maxf(Datos.ALTO_PERSONAJE * escala, capsula.radius * 2.0 + 0.1)
	var forma := CollisionShape3D.new()
	forma.shape = capsula
	forma.position.y = capsula.height / 2.0 + (0.6 if perfil.get("flota", false) else 0.0)
	add_child(forma)
	if perfil.get("flota", false) or perfil.has("vuela"):
		collision_mask = 1
	if perfil.get("objetivo", false) or float(perfil.velocidad) <= 0.0:
		# Los sellos y los dogū gigantes no se mueven ni los empujan.
		axis_lock_linear_x = true
		axis_lock_linear_z = true


func vivo() -> bool:
	return estado not in [Estado.MUERTO]


func persigue() -> bool:
	return estado in [Estado.ALERTA, Estado.PREPARANDO, Estado.ATACANDO, Estado.RECUPERANDO, Estado.ATURDIDO]


func postura_rota() -> bool:
	return rota > 0.0


func despierto() -> bool:
	return estado != Estado.DORMIDO


func fraccion_vida() -> float:
	return clampf(float(vida) / float(vida_maxima), 0.0, 1.0) if vivo() else 0.0


func es_jefe() -> bool:
	return perfil.get("jefe", false)


func _plano(v: Vector3) -> Vector3:
	return Vector3(v.x, 0.0, v.z)


func _hacia_objetivo() -> Vector3:
	return _plano(objetivo.global_position - global_position)


func lo_ve() -> bool:
	if objetivo == null or not objetivo.vivo():
		return false
	return _hacia_objetivo().length() < float(perfil.vision) and absf(objetivo.global_position.y - global_position.y) < 2.5


func encadenado() -> bool:
	return sellos.any(func(s): return is_instance_valid(s) and s.vivo())


# El juego lo pregunta tras cada golpe para enseñar «¡Bloqueado!» en vez del daño.
func consumir_bloqueo() -> bool:
	var habia := bloqueo
	bloqueo = false
	return habia


# --- Recibir golpes ---------------------------------------------------------------------------

# ¿Este golpe rebota? Escudo de frente (komainu, hombre lagarto), coraza (gólem, ōmukade: solo con
# la postura rota), piedra (gárgola mirada), protección de los sellos o de la barrera.
func _bloquea(desde: Vector3, letal: bool) -> bool:
	if protegido or encadenado():
		return true
	if letal or rota > 0.0 or sin_agua or golpe_de_iai:
		return false
	if estado == Estado.DORMIDO and perfil.get("disfraz", "") == "estatua":
		return false
	if perfil.get("coraza", false) or en_piedra:
		return true
	if perfil.has("escudo_frontal") and estado != Estado.ATACANDO:
		var hacia := _plano(desde - global_position)
		if hacia.length() > 0.01 and mirando.angle_to(hacia) < deg_to_rad(float(perfil.escudo_frontal) / 2.0):
			return true
	return false


# Golpe de Akira. Con la postura rota (o el kappa sin agua) el golpe remata.
func recibir_golpe(desde: Vector3, letal := false, danio := 1, postura_golpe := 0.0,
		empuje_golpe := -1.0) -> bool:
	if not vivo():
		return false
	if estado == Estado.NIEBLA:
		bloqueo = true                     # la espada atraviesa la niebla
		return false
	if estado == Estado.DESARMADO:
		# Gashadokuro: los huesos en el suelo se rompen a golpes antes de que vuelva a montarse.
		golpes_en_el_suelo += 1
		destello = 1.0
		if golpes_en_el_suelo >= 3 or letal:
			_morir_del_todo(_plano(global_position - desde).normalized())
			return true
		return false
	_despertar()
	if _bloquea(desde, letal):
		bloqueo = true
		destello = 0.5
		# Los golpes bloqueados también cansan: muchos seguidos le rompen la guardia.
		if not protegido and not encadenado():
			_sumar_postura(postura_golpe * 1.2)
		return false
	if perfil.get("falsa", false):
		_morir(Vector3.ZERO)
		return true
	if rota > 0.0 or sin_agua:
		letal = true
	if perfil.get("jefe", false) and letal and vida > 3:
		# A un jefe, el corte de luna o un golpe con la postura rota le quitan mucho, pero no todo.
		letal = false
		danio = maxi(danio, 3)
	var quita := vida if letal else int(ceil(float(danio) * mult_danio_recibido))
	vida -= quita
	destello = 1.0
	golpes_recibidos += 1
	var empuje := _plano(global_position - desde)
	empuje = empuje.normalized() if empuje.length() > 0.01 else -mirando
	if vida <= 0:
		_morir(empuje)
		return true
	_revisar_fases()
	if perfil.get("niebla", false) and golpes_recibidos % 2 == 0:
		_volverse_niebla()
		return false
	_sumar_postura(postura_golpe)
	if (estado != Estado.ATACANDO or peso < 2.0) and estado != Estado.ATURDIDO and rota <= 0.0:
		# Los pesados no se inmutan si les pegan mientras golpean: solo el iai o romperles la postura.
		estado = Estado.ATURDIDO
		temporizador = Datos.TIEMPO_ATURDIDO * (0.5 if perfil.get("jefe", false) else 1.0)
		_soltar_zona()
	var fuerza := Datos.EMPUJE_SOLDADO if empuje_golpe < 0.0 else empuje_golpe
	if not (perfil.get("objetivo", false) or float(perfil.velocidad) <= 0.0):
		velocity = empuje * fuerza / peso
	return false


func _sumar_postura(cantidad: float) -> void:
	postura += cantidad / maxf(peso * 0.6, 0.5)
	if postura >= 1.0:
		postura = 0.0
		rota = Datos.TIEMPO_POSTURA_ROTA * (1.6 if perfil.get("coraza", false) else 1.0)
		estado = Estado.ATURDIDO
		temporizador = rota
		_soltar_zona()


# Iai perfecto contra su ataque. Los fuertes lo aguantan (aturdidos y con menos vida); al kappa le
# derrama el agua del plato; a los demás los derriba.
func recibir_iai(desde: Vector3) -> bool:
	if perfil.has("resiste_iai") or protegido or encadenado():
		var resiste: Dictionary = perfil.get("resiste_iai", {"danio": 2, "aturdido": 1.0})
		var antes_protegido := protegido
		protegido = false
		var sellado := encadenado()
		var murio := false
		if not sellado:
			golpe_de_iai = true
			murio = recibir_golpe(desde, false, int(resiste.danio), 0.0, 4.0)
			golpe_de_iai = false
		protegido = antes_protegido
		if not murio and vivo():
			estado = Estado.ATURDIDO
			temporizador = float(resiste.aturdido)
			rota = float(resiste.aturdido)
			_soltar_zona()
		return murio
	return recibir_golpe(desde, true)


func _morir(empuje: Vector3) -> void:
	if perfil.get("revive", false) and not revivio:
		# Gashadokuro: se desarma… y vuelve a montarse si no se rompen los huesos a tiempo.
		revivio = true
		estado = Estado.DESARMADO
		temporizador = 3.5
		golpes_en_el_suelo = 0
		vida = 0
		_soltar_zona()
		mensaje.emit("¡Los huesos se mueven! Rómpelos antes de que se vuelva a montar")
		return
	_morir_del_todo(empuje)


func _morir_del_todo(empuje: Vector3) -> void:
	estado = Estado.MUERTO
	vida = 0
	muerte = 0.0
	velocity = empuje * 3.0
	collision_layer = 0
	collision_mask = 1
	_soltar_zona()
	for clave in lanzandose.keys():
		if lanzandose[clave] == self:
			lanzandose[clave] = null
	if disfraz:
		disfraz.visible = false
	for cadena in cadenas:
		cadena.queue_free()
	cadenas.clear()
	if perfil.has("divide") and invocador.is_valid():
		var divide: Dictionary = perfil.divide
		for i in int(divide.cantidad):
			var lado := Vector3(cos(i * TAU / float(divide.cantidad)), 0.0, sin(i * TAU / float(divide.cantidad)))
			invocador.call(String(divide.tipo), global_position + lado * 0.9)
	if perfil.get("transforma", false):
		transformado.emit()
	derrotado.emit()


func _volverse_niebla() -> void:
	estado = Estado.NIEBLA
	temporizador = 1.1
	_soltar_zona()
	if efectos:
		efectos.texto_flotante(global_position + Vector3.UP * 2.0, "Niebla…", Color(0.85, 0.6, 0.65), 0.006)


func _soltar_zona() -> void:
	if zona_actual != null and is_instance_valid(zona_actual) and not zona_actual.activada:
		zona_actual.queue_free()
	zona_actual = null


# --- Despertar ------------------------------------------------------------------------------------

func _despertar() -> void:
	if estado != Estado.DORMIDO or protegido or perfil.get("objetivo", false):
		return
	estado = Estado.ALERTA
	if disfraz:
		disfraz.visible = false
		if efectos:
			efectos.polvo(global_position + Vector3.UP * 0.5)
	if perfil.has("copias") and invocador.is_valid():
		for i in int(perfil.copias):
			var lado := Vector3(cos(angulo_orbita + i * 2.4), 0.0, sin(angulo_orbita + i * 2.4))
			invocador.call(String(perfil.copia), global_position + lado * 2.2)
	if perfil.has("mensaje_despertar") and not despierto_anunciado:
		mensaje.emit(String(perfil.mensaje_despertar))
	despierto_anunciado = true
	desperto.emit()


func _debe_despertar(hacia: Vector3) -> bool:
	if protegido or perfil.get("objetivo", false) or objetivo == null or not objetivo.vivo():
		return false
	var distancia := hacia.length()
	if perfil.has("despierta_si_corre"):
		# Komainu: duermen como estatuas mientras se camina con respeto; correr cerca los despierta.
		return distancia < float(perfil.despierta_si_corre) and (objetivo.corriendo or distancia < 1.6)
	if perfil.has("despierta"):
		return distancia < float(perfil.despierta)
	return distancia < 3.0


# --- Fases de jefe --------------------------------------------------------------------------------

func _revisar_fases() -> void:
	var fases: Array = perfil.get("fases", [])
	for i in fases.size():
		var fase: Dictionary = fases[i]
		if i in fases_hechas or fraccion_vida() > float(fase.umbral):
			continue
		fases_hechas.append(i)
		mult_velocidad *= float(fase.get("velocidad", 1.0))
		mult_aviso *= float(fase.get("aviso", 1.0))
		mult_danio_recibido *= float(fase.get("recibe", 1.0))
		if fase.has("patron"):
			patron = fase.patron
			indice_ataque = 0
		if fase.has("mensaje"):
			mensaje.emit(String(fase.mensaje))
		if fase.has("invoca") and invocador.is_valid():
			var invoca: Array = fase.invoca
			for k in int(invoca[1]):
				var lado := Vector3(cos(k * 2.1 + 0.5), 0.0, sin(k * 2.1 + 0.5))
				invocador.call(String(invoca[0]), global_position + lado * 3.0)


# --- Ataques --------------------------------------------------------------------------------------

func _uso(a: Dictionary) -> float:
	if a.has("uso"):
		return float(a.uso)
	match String(a.get("forma", "franja")):
		"disparo":
			return 11.0
		"invoca":
			return 30.0
		"area":
			match String(a.get("centro", "objetivo")):
				"propio":
					return float(a.radio) * 0.9
				"frente":
					return float(a.get("largo", a.get("radio", 2.0) * 2.0))
				_:
					return 9.0
	return float(a.alcance) + 0.6


# El ataque que toca: el siguiente del patrón del perfil (o de su fase), si ya llega a Akira. Así
# los jefes se leen: siempre el mismo orden. Si lleva un rato sin poder usarlo, pasa al siguiente.
func _elegir_ataque(distancia: float) -> Dictionary:
	var ataques: Array = perfil.ataques
	if ataques.is_empty():
		return {}
	if patron.is_empty():
		if distancia > float(perfil.distancia_ataque):
			return {}
		var elegido: Dictionary = ataques[indice_ataque % ataques.size()] if ataques.size() < 2 \
			else ataques[1 if indice_ataque % 3 == 2 else 0]
		indice_ataque += 1
		return elegido
	var toca := _ataque_que_toca()
	if distancia <= _uso(toca):
		indice_ataque += 1
		sin_alcanzar = 0.0
		return toca
	return {}


func _ataque_que_toca() -> Dictionary:
	return perfil.ataques[int(patron[indice_ataque % patron.size()])]


# Ataca si el que toca en el patrón llega a Akira; si lleva «paciencia» segundos sin llegar, pasa al
# siguiente (así un arquero no se queda esperando para usar su daga desde lejos).
func _intentar_atacar(delta: float, distancia: float, paciencia: float) -> bool:
	if distancia <= _uso(_ataque_que_toca()):
		_empezar_ataque()
		return true
	sin_alcanzar += delta
	if sin_alcanzar > paciencia:
		sin_alcanzar = 0.0
		indice_ataque += 1
	return false


func _empezar_ataque(elegido := {}, aviso_forzado := -1.0) -> void:
	if elegido.is_empty():
		elegido = _elegir_ataque(_hacia_objetivo().length())
	if elegido.is_empty():
		return
	ataque = elegido
	golpes_restantes = int(ataque.get("golpes", 1)) - 1
	estado = Estado.PREPARANDO
	temporizador = (float(ataque.aviso) if aviso_forzado < 0.0 else aviso_forzado) * mult_aviso
	_preparar_forma()
	aviso_iniciado.emit()


# Lo que se ve durante el aviso: la marca en el suelo de los golpes de área.
func _preparar_forma() -> void:
	if String(ataque.get("forma", "")) != "area":
		return
	var zona = ZonaPeligro.new()
	var datos: Dictionary = ataque.duplicate()
	datos.aviso = temporizador
	datos.forma_zona = "linea" if ataque.get("linea", false) else "circulo"
	var centro := global_position
	match String(ataque.get("centro", "objetivo")):
		"objetivo":
			centro = objetivo.global_position
		"frente":
			if not ataque.get("linea", false):
				centro = global_position + mirando * float(ataque.radio)
	if ataque.get("linea", false):
		var hacia := _hacia_objetivo()
		datos.direccion = hacia.normalized() if hacia.length() > 0.01 else mirando
		mirando = datos.direccion
	zona.configurar(datos, self, objetivo, efectos)
	get_parent().add_child(zona)
	zona.global_position = Vector3(centro.x, global_position.y + 0.02, centro.z)
	zona.impacto.connect(func(punto): impacto_area.emit(punto))
	zona_actual = zona


func _al_golpear() -> void:
	match String(ataque.get("forma", "franja")):
		"disparo":
			golpe_dado = true
			var bala = Proyectil.new()
			get_parent().add_child(bala)
			var alto := 1.0 + (float(perfil.get("altura_flota", 0.5)) if perfil.get("flota", false) else 0.0)
			bala.lanzar(global_position + Vector3.UP * alto + mirando * 0.6, objetivo.global_position + Vector3.UP,
				ataque, self, objetivo, efectos)
		"invoca":
			golpe_dado = true
			if invocador.is_valid():
				for k in int(ataque.cantidad):
					var lado := Vector3(cos(angulo_orbita + k * 2.3), 0.0, sin(angulo_orbita + k * 2.3))
					invocador.call(String(ataque.tipo), global_position + lado * 2.5)
		"area":
			golpe_dado = true            # la zona hace el daño


func _intentar_golpe() -> void:
	var hacia: Vector3 = objetivo.global_position - global_position
	if absf(hacia.y) > 1.5:
		return
	hacia.y = 0.0
	var a_lo_largo := hacia.dot(mirando)
	var de_lado := (hacia - mirando * a_lo_largo).length()
	if a_lo_largo > -0.3 and a_lo_largo < float(ataque.alcance) + Datos.RADIO_PERSONAJE \
			and de_lado < float(ataque.ancho) / 2.0 + Datos.RADIO_PERSONAJE:
		golpe_dado = true
		if ataque.parable and objetivo.has_method("intentar_parar") and objetivo.intentar_parar(self):
			return
		if perfil.get("falsa", false):
			# La copia falsa no hace daño: al tocar a Akira se deshace en humo.
			if efectos:
				efectos.texto_flotante(global_position + Vector3.UP * 2.0, "¡Una ilusión!", Color(0.75, 0.85, 1.0), 0.007)
			_morir(Vector3.ZERO)
			return
		for i in int(ataque.danio):
			if objetivo.recibir_golpe(global_position) and i + 1 < int(ataque.danio):
				objetivo.invulnerable = 0.0       # el kanabō quita 2: el segundo, sin esperar
		if ataque.get("efecto", "") == "atrapa" and objetivo.has_method("atrapar"):
			objetivo.atrapar(1.0)
		if ataque.get("drena", false) and vida < vida_maxima:
			vida += 1
			if efectos:
				efectos.texto_flotante(global_position + Vector3.UP * 2.2, "+1", Color(0.9, 0.2, 0.3), 0.006)


# --- Cada cuadro ------------------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	destello = maxf(0.0, destello - delta * 6.0)
	rota = maxf(0.0, rota - delta)
	espera_espejo = maxf(0.0, espera_espejo - delta)
	if estado != Estado.ATURDIDO and rota <= 0.0:
		postura = maxf(0.0, postura - delta * Datos.RECUPERA_POSTURA)
	var deseada := Vector3.ZERO
	moviendose = false
	var hacia := _hacia_objetivo() if objetivo else Vector3.ZERO
	var velocidad_base := float(perfil.velocidad) * mult_velocidad
	if encadenado():
		velocidad_base = 0.0
	elif not sellos.is_empty() and not libre_anunciado:
		libre_anunciado = true
		mensaje.emit(String(perfil.get("mensaje_libre", "¡Las cadenas caen!")))
	en_piedra = false
	if perfil.get("piedra_si_mira", false) and estado in [Estado.ALERTA, Estado.QUIETO] and objetivo and objetivo.vivo():
		var desde_akira := _plano(global_position - objetivo.global_position)
		en_piedra = desde_akira.length() < 14.0 and objetivo.mirando.dot(desde_akira.normalized()) > 0.55
	match estado:
		Estado.MUERTO:
			muerte = minf(1.0, muerte + delta / Datos.TIEMPO_DESAPARECER)
			if muerte >= 1.0 and not perfil.get("queda", false):
				queue_free()
				return
		Estado.DORMIDO:
			if _debe_despertar(hacia):
				_despertar()
		Estado.QUIETO:
			if lo_ve():
				estado = Estado.ALERTA
		Estado.ALERTA:
			if hacia.length() > 0.01:
				mirando = hacia.normalized()
			if en_piedra:
				pass
			elif perfil.get("reverencia", false) and not sin_agua and _esperado_en_postura(hacia):
				_mirar_reverencia(delta)
			elif not lo_ve() and not perfil.get("jefe", false) and _plano(global_position - puesto).length() > 0.5:
				deseada = _plano(puesto - global_position).normalized() * velocidad_base * 0.6
				if _plano(puesto - global_position).length() < 0.6:
					estado = Estado.QUIETO
			elif not lo_ve() and not perfil.get("jefe", false):
				estado = Estado.QUIETO
			elif perfil.get("espejo", false) and _akira_empieza_a_cortar(hacia):
				# Noppera-bō y el doble de Akira: responden a cada corte con el suyo, más rápido.
				espera_espejo = 1.4
				var replica: Dictionary = perfil.ataques[0].duplicate()
				replica.golpes = 1
				_empezar_ataque(replica, 0.28)
			elif perfil.has("orbita"):
				deseada = _orbitar(delta, hacia, velocidad_base)
			elif perfil.has("mantiene_distancia"):
				deseada = _a_distancia(delta, hacia, velocidad_base)
			elif not patron.is_empty():
				if not _intentar_atacar(delta, hacia.length(), 2.5):
					if velocidad_base > 0.0 and (perfil.get("jefe", false) or _plano(global_position + mirando - puesto).length() < float(perfil.correa)):
						deseada = mirando * velocidad_base
			elif hacia.length() > float(perfil.distancia_ataque):
				if velocidad_base > 0.0 and (perfil.get("jefe", false) or _plano(global_position + mirando - puesto).length() < float(perfil.correa)):
					deseada = mirando * velocidad_base
			else:
				_empezar_ataque()
			_curar(delta)
			_criar(delta)
		Estado.PREPARANDO:
			temporizador -= delta
			if ataque.get("salto", false) and zona_actual != null and is_instance_valid(zona_actual):
				# Salta hacia donde caerá el golpe y llega justo al final del aviso.
				var destino := _plano(zona_actual.global_position - global_position)
				deseada = destino / maxf(temporizador, 0.05) if destino.length() > 0.3 else Vector3.ZERO
				deseada = deseada.limit_length(14.0)
			elif temporizador > float(ataque.aviso) * mult_aviso * 0.4 and hacia.length() > 0.01 and not ataque.get("linea", false):
				mirando = hacia.normalized()
			if temporizador <= 0.0:
				estado = Estado.ATACANDO
				temporizador = float(ataque.activo)
				golpe_dado = false
				_al_golpear()
				estocada_iniciada.emit()
		Estado.ATACANDO:
			temporizador -= delta
			deseada = mirando * float(ataque.embestida)
			if ataque.get("rastro_fuego", false):
				_dejar_fuego(delta)
			if not golpe_dado:
				_intentar_golpe()
			if estado == Estado.ATACANDO and temporizador <= 0.0:
				if golpes_restantes > 0 and objetivo.vivo():
					# Cadena: el siguiente golpe con un aviso más corto (hay que parar cada uno).
					golpes_restantes -= 1
					estado = Estado.PREPARANDO
					temporizador = float(ataque.get("aviso_cadena", 0.3)) * mult_aviso
					aviso_iniciado.emit()
				else:
					estado = Estado.RECUPERANDO
					temporizador = float(ataque.recuperacion)
		Estado.RECUPERANDO:
			temporizador -= delta
			if temporizador <= 0.0:
				estado = Estado.ALERTA
				for clave in lanzandose.keys():
					if lanzandose[clave] == self:
						lanzandose[clave] = null
		Estado.ATURDIDO:
			temporizador -= delta
			if temporizador <= 0.0:
				estado = Estado.ALERTA
		Estado.REVERENCIA:
			temporizador -= delta
			if temporizador <= 0.0:
				estado = Estado.ALERTA
		Estado.NIEBLA:
			temporizador -= delta
			if temporizador <= 0.0 and objetivo and objetivo.vivo():
				# Reaparece a la espalda de Akira y ataca enseguida.
				var espalda: Vector3 = objetivo.global_position - objetivo.mirando * 1.7
				global_position = Vector3(espalda.x, global_position.y, espalda.z)
				estado = Estado.ALERTA
				mirando = _hacia_objetivo().normalized()
				_empezar_ataque(perfil.ataques[0], 0.35)
		Estado.DESARMADO:
			temporizador -= delta
			if temporizador <= 0.0:
				vida = maxi(1, vida_maxima / 2)
				estado = Estado.ALERTA
				mensaje.emit("El gashadokuro se vuelve a montar")

	if estado in [Estado.ATURDIDO, Estado.MUERTO, Estado.REVERENCIA, Estado.DORMIDO, Estado.NIEBLA, Estado.DESARMADO] or en_piedra:
		velocity.x = move_toward(velocity.x, 0.0, 14.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 14.0 * delta)
	else:
		velocity.x = deseada.x
		velocity.z = deseada.z
		moviendose = deseada.length() > 0.1
	if perfil.get("flota", false) or perfil.has("vuela"):
		velocity.y = 0.0
	elif not is_on_floor():
		velocity.y -= Datos.GRAVEDAD * delta
	move_and_slide()
	_actualizar_vuelo(delta)
	_actualizar_cadenas()
	if visual:
		visual.actualizar(delta, info())


func _akira_empieza_a_cortar(hacia: Vector3) -> bool:
	if objetivo == null or not objetivo.has_method("atacando"):
		return false
	var nuevo: bool = objetivo.cortes_dados != ultimo_corte_visto
	ultimo_corte_visto = objetivo.cortes_dados
	return nuevo and espera_espejo <= 0.0 and hacia.length() < 3.2


# El karasu-tengu vuela alto y baja en picado al atacar.
func _actualizar_vuelo(delta: float) -> void:
	if not perfil.has("vuela") or visual == null:
		return
	var deseada_altura := 0.0 if estado in [Estado.ATACANDO, Estado.ATURDIDO, Estado.MUERTO] else float(perfil.vuela)
	altura_vuelo = move_toward(altura_vuelo, deseada_altura, delta * (9.0 if deseada_altura < altura_vuelo else 3.0))
	visual.position.y = altura_vuelo


# El enjambre gira alrededor de Akira; de vez en cuando uno se lanza (solo uno a la vez). La manada
# (okuri-inu) solo se lanza de verdad cuando Akira tropieza: si acaba de recibir un golpe.
func _orbitar(delta: float, hacia: Vector3, velocidad_base: float) -> Vector3:
	angulo_orbita += delta * 0.9
	var radio := float(perfil.orbita)
	var punto: Vector3 = objetivo.global_position + Vector3(cos(angulo_orbita), 0.0, sin(angulo_orbita)) * radio
	var deseada := _plano(punto - global_position)
	var familia := String(perfil.get("familia", tipo))
	var prisa := float(perfil.get("prisa", 0.6))
	if perfil.get("manada", false) and objetivo.invulnerable > 0.0:
		prisa = 4.0
	var actual = lanzandose.get(familia)
	var libre: bool = actual == null or not is_instance_valid(actual) or not actual.vivo()
	if libre and hacia.length() < float(perfil.distancia_ataque) and azar.randf() < delta * prisa:
		lanzandose[familia] = self
		_empezar_ataque(perfil.ataques[0])
		return Vector3.ZERO
	return deseada.limit_length(1.0) * velocidad_base


# Elfos e ifrit: guardan la distancia y disparan desde lejos; si Akira se acerca, retroceden o usan
# su ataque corto.
func _a_distancia(delta: float, hacia: Vector3, velocidad_base: float) -> Vector3:
	var lejos := float(perfil.mantiene_distancia)
	var distancia := hacia.length()
	if distancia < 2.4:
		_intentar_atacar(delta, distancia, 0.6)
		return Vector3.ZERO
	if distancia < lejos * 0.7:
		return -hacia.normalized() * velocidad_base
	if distancia > lejos * 1.3:
		return hacia.normalized() * velocidad_base
	_intentar_atacar(delta, distancia, 0.6)
	return Vector3.ZERO


# La kamaitachi curandera cura a sus hermanas mientras viva.
func _curar(delta: float) -> void:
	if not perfil.has("cura"):
		return
	espera_cura -= delta
	if espera_cura > 0.0:
		return
	espera_cura = float(perfil.cura)
	for otra in get_tree().get_nodes_in_group("yokai"):
		if otra == self or not otra.vivo() or otra.perfil.get("familia", "") != perfil.get("familia", "-"):
			continue
		if otra.vida < otra.vida_maxima and otra.global_position.distance_to(global_position) < 12.0:
			otra.vida += 1
			if efectos:
				efectos.texto_flotante(otra.global_position + Vector3.UP * 1.6, "+1", Color(0.4, 1.0, 0.5), 0.006)


# La jorōgumo y la tsuchigumo sueltan crías de araña.
func _criar(delta: float) -> void:
	if not perfil.has("crias") or not invocador.is_valid():
		return
	espera_crias -= delta
	if espera_crias > 0.0:
		return
	var datos: Dictionary = perfil.crias
	espera_crias = float(datos.cada)
	crias = crias.filter(func(c): return is_instance_valid(c) and c.vivo())
	if crias.size() < int(datos.maximo):
		var lado := Vector3(cos(angulo_orbita), 0.0, sin(angulo_orbita))
		angulo_orbita += 2.0
		crias.append(invocador.call(String(datos.tipo), global_position + lado * 1.6))


# El kasha deja fuego en el suelo al rodar.
func _dejar_fuego(delta: float) -> void:
	tiempo_rastro -= delta
	if tiempo_rastro > 0.0:
		return
	tiempo_rastro = 0.12
	var fuego = ZonaPeligro.new()
	fuego.configurar({"radio": 0.7, "aviso": 0.0, "activo": 2.4, "persistente": true,
		"color": Color(1.0, 0.45, 0.1)}, self, objetivo, efectos)
	get_parent().add_child(fuego)
	fuego.global_position = global_position + Vector3.UP * 0.02


# El kappa es cortés: si Akira lo espera en postura de iai, de frente y cerca, el kappa no
# ataca; a los 2 s hace la reverencia y se le derrama el agua del plato.
func _esperado_en_postura(hacia: Vector3) -> bool:
	var de_frente: bool = objetivo.en_postura and hacia.length() < 4.0 and hacia.length() > 0.01 \
		and objetivo.mirando.dot(-hacia.normalized()) > 0.6
	if not de_frente:
		tiempo_reverencia = 0.0
	return de_frente


func _mirar_reverencia(delta: float) -> void:
	tiempo_reverencia += delta
	if tiempo_reverencia >= 2.0:
		tiempo_reverencia = 0.0
		sin_agua = true
		estado = Estado.REVERENCIA
		temporizador = 1.2


# Las cadenas de Bahamut: una por cada dogū que sigue en pie.
func _actualizar_cadenas() -> void:
	if sellos.is_empty():
		return
	if cadenas.is_empty():
		for sello in sellos:
			var cadena := MeshInstance3D.new()
			var caja := BoxMesh.new()
			caja.size = Vector3(0.12, 0.12, 1.0)
			cadena.mesh = caja
			cadena.material_override = aspecto.material_superficie("cadena")
			cadena.top_level = true
			add_child(cadena)
			cadenas.append(cadena)
	for i in sellos.size():
		var sello = sellos[i]
		var cadena: MeshInstance3D = cadenas[i]
		if not is_instance_valid(sello) or not sello.vivo():
			cadena.visible = false
			continue
		var desde: Vector3 = sello.global_position + Vector3.UP * 1.6
		var hasta: Vector3 = global_position + Vector3.UP * 1.4
		var largo := desde.distance_to(hasta)
		if largo < 0.1:
			continue
		cadena.global_transform = Transform3D(Basis.looking_at(hasta - desde, Vector3.UP).scaled(Vector3(1, 1, largo)),
			(desde + hasta) / 2.0)


func info() -> Dictionary:
	var pose := "normal"
	if estado == Estado.PREPARANDO:
		pose = "preparando"
	elif estado == Estado.ATACANDO:
		pose = "estocada"
	elif estado == Estado.REVERENCIA:
		pose = "reverencia"
	elif estado == Estado.ATURDIDO:
		pose = "aturdido"
	elif estado == Estado.DESARMADO:
		pose = "desarmado"
	var datos := {
		"mirando": mirando,
		"moviendose": moviendose,
		"pose": pose,
		"destello": destello,
		"muerte": muerte,
		"aviso": estado == Estado.PREPARANDO,
		"rojo": estado == Estado.PREPARANDO and ataque.get("rojo", false),
		"rota": rota > 0.0,
		"sin_agua": sin_agua,
		"anim_ataque": String(ataque.get("anim", "ataque")),
		"queda": perfil.get("queda", false),
	}
	var tinte: Color = perfil.get("tinte", Color(1, 1, 1, 1))
	if estado == Estado.DORMIDO:
		match String(perfil.get("disfraz", "")):
			"jizo":
				datos.oculto = true
			"farol":
				datos.fijo = ["reposo", 0]
			"estatua":
				datos.fijo = ["reposo", 0]
				tinte = Color(0.62, 0.62, 0.66)
	if en_piedra:
		datos.fijo = ["reposo", 0]
		tinte = Color(0.55, 0.55, 0.6)
	if encadenado() or protegido:
		tinte = tinte.lerp(Color(0.75, 0.85, 1.0), 0.35)
	if estado == Estado.NIEBLA:
		datos.alfa = 0.25
	if perfil.get("falsa", false):
		datos.alfa = 0.9
	datos.tinte = tinte
	if perfil.has("alfa"):
		datos.alfa = float(datos.get("alfa", 1.0)) * float(perfil.alfa)
	if perfil.get("visual_akira", false):
		# El doble de Akira usa los sprites de Akira: sus poses llevan otros nombres.
		datos.pose = {"preparando": "postura", "estocada": "kesa", "aturdido": "normal"}.get(pose, "normal")
		datos.progreso = clampf(1.0 - temporizador / maxf(float(ataque.get("activo", 0.2)), 0.05), 0.0, 1.0)
		datos.visible = true
		datos.en_aire = false
		datos.corriendo = false
	return datos
