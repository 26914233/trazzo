# El capítulo 1 en 3D: construye el patio, crea a Akira, a Shiro (su perro), los soldados y
# la cámara, resuelve los golpes de espada, lleva la cuenta de las monedas y decide cuándo se
# gana o se pierde.
extends Node3D

const Datos := preload("res://scripts/datos.gd")
const Aspecto := preload("res://scripts/aspecto.gd")
const ConstructorMundo := preload("res://scripts/constructor_mundo.gd")
const Akira := preload("res://scripts/akira.gd")
const Soldado := preload("res://scripts/soldado.gd")
const CamaraOrbital := preload("res://scripts/camara_orbital.gd")
const VisualModelo := preload("res://scripts/visual_modelo.gd")
const Efectos := preload("res://scripts/efectos.gd")
const Shiro := preload("res://scripts/shiro.gd")
const VisualShiro := preload("res://scripts/visual_shiro.gd")
const VisualSprite := preload("res://scripts/visual_sprite.gd")
const Monedas := preload("res://scripts/monedas.gd")
const Apariencias := preload("res://scripts/apariencias_akira.gd")
const Partida := preload("res://scripts/partida.gd")
const Jizo := preload("res://scripts/jizo.gd")
const Yokai := preload("res://scripts/yokai.gd")
const JefeOni := preload("res://scripts/jefe_oni.gd")
const Enemigos := preload("res://scripts/enemigos.gd")
const Depuracion := preload("res://scripts/depuracion.gd")
const ALCANCE_FIJADO := 7.0          # el enemigo más cercano a esta distancia queda fijado
const SHADER_PROFUNDIDAD := preload("res://shaders/profundidad.gdshader")

signal fase_cambiada(fase: String)
signal vida_cambiada(vida: int)
signal derrotados_cambiados(cantidad: int, total: int)
signal espiritu_cambiado(valor: float)
signal mensaje(texto: String)
signal monedas_cambiadas(total: int)
signal vida_maxima_cambiada(maxima: int)
signal aviso_interaccion(texto: String)     # vacío: no hay nada con lo que interactuar
signal aguante_cambiado(valor: float)
signal jefe_cambiado(nombre: String, fraccion: float)   # fraccion < 0: ocultar la barra
signal arma_cambiada(arma: String)

var aspecto
var efectos
var constructor
var akira
var camara
var soldados: Array = []             # todos los enemigos: soldados, yōkai y el jefe
var jefe                             # el oni gigante del portón
var aviso_porton := 0.0
var depuracion
var reticula: Node3D                 # anillo rojo bajo el enemigo fijado (como en EthrA)
var objetivo_fijado = null
var shiro
var monedas_suelo                    # las monedas que hay por el suelo (monedas.gd)
var monedas := 0                     # las que lleva Akira (las guarda partida.gd)
var jizo
var cerca_del_jizo := false
var aviso_actual := ""
var azar := RandomNumberGenerator.new()
var derrotados := 0
var fase := "intro"          # intro, jugando, cierre, derrota
var tiempo_derrota := 0.0


func iniciar(con_intro := true) -> void:
	monedas = Partida.monedas
	azar.seed = 5
	aspecto = Aspecto.new()
	constructor = ConstructorMundo.new()
	constructor.construir(self, aspecto)

	akira = Akira.new()
	add_child(akira)
	akira.position = Datos.INICIO_AKIRA
	akira.vida_maxima = Datos.VIDA_MAXIMA + Partida.bendiciones
	akira.vida = akira.vida_maxima
	akira.visual = _crear_visual(false)
	akira.add_child(akira.visual)
	akira.vida_cambiada.connect(func(vida): vida_cambiada.emit(vida))

	camara = CamaraOrbital.new()
	camara.objetivo = akira
	add_child(camara)
	akira.camara = camara

	efectos = Efectos.new()
	efectos.camara = camara
	add_child(efectos)
	_crear_profundidad()
	akira.buscar_rival = soldado_mas_cercano
	akira.ataco.connect(func(): efectos.tajo(akira.global_position + Vector3.UP * 1.2))
	akira.desenvaino.connect(func(): efectos.desenvaine(akira.global_position + Vector3.UP * 1.2))
	akira.paro.connect(_al_iai_perfecto)
	akira.pidio_corte_de_luna.connect(_al_pedir_corte_de_luna)
	akira.espiritu_cambiado.connect(func(valor): espiritu_cambiado.emit(valor))
	akira.aguante_cambiado.connect(func(valor): aguante_cambiado.emit(valor))
	akira.arma_cambiada.connect(func(arma): arma_cambiada.emit(arma))
	akira.esquivo.connect(func(): efectos.esquiva(akira.global_position + Vector3.UP * 0.4))
	akira.vida_cambiada.connect(func(_vida): efectos.herido(akira.global_position + Vector3.UP * 1.1))

	jizo = Jizo.new()
	add_child(jizo)
	jizo.configurar(aspecto)
	jizo.position = Datos.JIZO_POSICION
	jizo.rotation.y = PI / 2.0              # mira al patio (al este)

	monedas_suelo = Monedas.new()
	add_child(monedas_suelo)
	monedas_suelo.configurar(aspecto, akira)
	monedas_suelo.recogidas.connect(_al_recoger_monedas)
	_crear_shiro()

	for patrulla in Datos.PATRULLAS:
		var soldado = Soldado.new()
		add_child(soldado)
		soldado.configurar(patrulla[0], patrulla[1], akira)
		soldado.visual = _crear_visual(true)
		soldado.add_child(soldado.visual)
		soldado.derrotado.connect(_al_derrotar)
		soldado.derrotado.connect(func(): _soltar_monedas(soldado))
		soldado.aviso_iniciado.connect(func(): efectos.aviso(soldado.global_position + Vector3.UP * 2.0))
		soldado.estocada_iniciada.connect(func(): efectos.estocada(soldado.global_position + Vector3.UP * 1.1))
		soldados.append(soldado)
	_crear_yokai()
	_crear_jefe()
	_crear_reticula()
	depuracion = Depuracion.new()
	depuracion.juego = self
	add_child(depuracion)

	if con_intro:
		camara.modo_presentacion = true
		_cambiar_fase("intro")
	else:
		comenzar()


# Retícula del objetivo fijado: un anillo rojo en el suelo y un rombo encima. El fijado es
# automático (el enemigo vivo más cercano), pensado para jugar con el pulgar en el móvil; los
# cortes de Akira se orientan hacia él (akira.gd, _encarar_al_atacar).
func _crear_reticula() -> void:
	reticula = Node3D.new()
	reticula.top_level = true
	var anillo := MeshInstance3D.new()
	var toro := TorusMesh.new()
	toro.inner_radius = 0.62
	toro.outer_radius = 0.72
	anillo.mesh = toro
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1.0, 0.2, 0.15, 0.85)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	anillo.material_override = material
	anillo.scale = Vector3(1, 0.05, 1)
	reticula.add_child(anillo)
	var rombo := Label3D.new()
	rombo.text = "◆"
	rombo.font_size = 64
	rombo.pixel_size = 0.005
	rombo.modulate = Color(1.0, 0.25, 0.2)
	rombo.outline_size = 10
	rombo.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	rombo.no_depth_test = true
	rombo.name = "Rombo"
	reticula.add_child(rombo)
	reticula.visible = false
	add_child(reticula)


func _actualizar_reticula() -> void:
	objetivo_fijado = soldado_mas_cercano(akira.global_position, ALCANCE_FIJADO) if akira.vivo() else null
	reticula.visible = objetivo_fijado != null and fase == "jugando"
	if not reticula.visible:
		return
	var puntos := puntos_de_golpe(objetivo_fijado)
	var lugar: Vector3 = objetivo_fijado.global_position
	if not puntos.is_empty() and objetivo_fijado.has_method("puntos_de_golpe"):
		lugar = puntos[0].posicion
	var radio := 1.0 if objetivo_fijado.has_method("puntos_de_golpe") else 0.7
	reticula.global_position = Vector3(lugar.x, objetivo_fijado.global_position.y + 0.06, lugar.z)
	reticula.scale = Vector3.ONE * radio
	var rombo: Label3D = reticula.get_node("Rombo")
	rombo.position.y = 2.3 / radio + sin(Time.get_ticks_msec() / 160.0) * 0.08


# Yōkai del bestiario (kappa, oni, onibi), con las fichas del capítulo 1.
func _crear_yokai() -> void:
	for entrada in Enemigos.OLEADA_CAPITULO_1:
		crear_yokai(entrada[0], entrada[1])


func crear_yokai(tipo: String, lugar: Vector3):
		var yokai = Yokai.new()
		yokai.configurar(tipo, lugar, akira, aspecto)
		add_child(yokai)
		yokai.derrotado.connect(_al_derrotar)
		yokai.derrotado.connect(func():
			akira.ganar_espiritu(float(yokai.perfil.get("espiritu_al_morir", 0.0)))
			monedas_suelo.soltar(yokai.global_position + Vector3.UP * 0.7, azar.randi_range(1, 2)))
		yokai.aviso_iniciado.connect(func(): efectos.aviso(yokai.global_position + Vector3.UP * 1.8))
		yokai.estocada_iniciada.connect(func(): efectos.estocada(yokai.global_position + Vector3.UP * 1.0))
		soldados.append(yokai)
		return yokai


func _crear_jefe() -> void:
	jefe = JefeOni.new()
	jefe.configurar(Datos.JEFE_POSICION, akira, aspecto)
	add_child(jefe)
	soldados.append(jefe)
	jefe.desperto.connect(func():
		efectos.sacudir(0.9)
		efectos.sonar("caida", jefe.global_position, 6.0, 0.0)
		mensaje.emit("¡El oni gigante derriba el portón y cierra la huida!")
		jefe_cambiado.emit("Oni gigante", 1.0))
	jefe.vida_cambiada.connect(func(fraccion): jefe_cambiado.emit("Oni gigante", fraccion))
	jefe.punetazo.connect(func(punto):
		efectos.sacudir(0.75)
		efectos.pausa_de_impacto(0.06)
		efectos.sonar("caida", punto, 4.0, 0.05)
		efectos.polvo(punto)
		efectos.polvo(punto + Vector3(1, 0, 0)))
	jefe.brazo_roto.connect(func(_lado):
		efectos.sacudir(0.6)
		mensaje.emit("¡Brazo inutilizado!" if jefe.brazo_vivo.has(true) else "¡El oni cae de rodillas!"))
	jefe.aviso_iniciado.connect(func(): efectos.aviso(jefe.global_position + Vector3.UP * 4.0))
	jefe.derrotado.connect(func():
		_al_derrotar()
		efectos.camara_lenta(0.3, 0.8)
		efectos.sacudir(1.0)
		efectos.polvo_de_pixeles(jefe.global_position + Vector3.UP * 1.5)
		monedas_suelo.soltar(jefe.global_position + Vector3(-2, 1, 0), 12)
		mensaje.emit("El oni gigante ha caído. El portón queda libre.")
		jefe_cambiado.emit("", -1.0))


# Los personajes son sprites pixel art (DECISIÓN 20E); con --modelos3d, los modelos de piezas de
# antes (de ellos se hornean los sprites).
# Desenfoque de profundidad (tilt-shift) del aire HD-2D: en la capa 1, por debajo de los controles
# táctiles (8), la tinta (9) y el HUD (10).
func _crear_profundidad() -> void:
	var capa := CanvasLayer.new()
	capa.layer = 1
	var filtro := ColorRect.new()
	filtro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	filtro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader = SHADER_PROFUNDIDAD
	filtro.material = material
	capa.add_child(filtro)
	capa.name = "Profundidad"
	add_child(capa)


func _crear_visual(soldado: bool, apariencia := "") -> Node3D:
	if apariencia == "":
		apariencia = Apariencias.elegida
	if VisualSprite.activo:
		var sprite = VisualSprite.new()
		sprite.configurar(aspecto, "soldado" if soldado else "akira", "" if soldado else apariencia)
		return sprite
	var modelo = VisualModelo.new()
	modelo.configurar(aspecto, soldado, "" if soldado else apariencia)
	return modelo


func _crear_shiro() -> void:
	shiro = Shiro.new()
	add_child(shiro)
	shiro.position = Datos.INICIO_AKIRA + Vector3(-1.0, 0, 1.1)
	shiro.mirando = Vector3.RIGHT
	shiro.akira = akira
	shiro.monedas = monedas_suelo
	shiro.en_calma = en_calma
	if VisualSprite.activo:
		shiro.visual = VisualSprite.new()
		shiro.visual.configurar(aspecto, "shiro")
	else:
		shiro.visual = VisualShiro.new()
		shiro.visual.configurar(aspecto)
	shiro.add_child(shiro.visual)
	shiro.ladro.connect(func(punto): efectos.ladrido(punto))
	shiro.empezo_a_escarbar.connect(func(punto): efectos.escarbar(punto, Datos.SHIRO_ESCARBADO))
	shiro.desenterro.connect(_al_desenterrar)
	shiro.entrego.connect(_al_recoger_monedas)
	shiro.aparecio.connect(func(punto): efectos.polvo(punto))


# Cambia el aspecto de Akira en el momento (también en pausa, en el sastre): la pose se aplica
# al instante.
func cambiar_apariencia_akira(apariencia := "") -> void:
	var anterior: Node3D = akira.visual
	akira.visual = _crear_visual(false, apariencia)
	akira.add_child(akira.visual)
	akira.visual.actualizar(0.0, akira.info())
	anterior.queue_free()


# En calma: ningún soldado persigue a Akira cerca. Solo entonces Shiro busca monedas.
func en_calma() -> bool:
	for soldado in soldados_vivos():
		if soldado.persigue() and soldado.global_position.distance_to(akira.global_position) < Datos.SHIRO_CALMA:
			return false
	return akira.vivo()


func _soltar_monedas(soldado) -> void:
	var cantidad := azar.randi_range(Datos.MONEDAS_SOLDADO.x, Datos.MONEDAS_SOLDADO.y)
	monedas_suelo.soltar(soldado.global_position + Vector3.UP * 0.9, cantidad)


func _al_desenterrar(punto: Vector3) -> void:
	efectos.desenterrar(punto)
	efectos.sonar("moneda", punto, -4.0, 0.0)
	monedas_suelo.soltar(punto + Vector3.UP * 0.2, azar.randi_range(Datos.MONEDAS_HALLAZGO.x, Datos.MONEDAS_HALLAZGO.y), 0.9)
	if shiro.hallazgos == 1:
		mensaje.emit("¡Shiro ha desenterrado unas monedas!")


func _al_recoger_monedas(cantidad: int, punto: Vector3) -> void:
	Partida.sumar_monedas(cantidad)
	monedas = Partida.monedas
	monedas_cambiadas.emit(monedas)
	efectos.moneda(punto)


# --- El jizō -----------------------------------------------------------------------------

func _texto_jizo() -> String:
	var precio := Partida.precio_bendicion()
	if precio < 0:
		return "Jizō: ya te ha bendecido dos veces"
	if Partida.monedas >= precio:
		return "Jizō: rezar por %d mon (+1 de vida)" % precio
	return "Jizō: %d mon por +1 de vida (tienes %d)" % [precio, Partida.monedas]


# ENTER (o B en el mando, o tocar el aviso en el móvil) junto al jizō.
func interactuar() -> void:
	if not cerca_del_jizo:
		return
	var precio := Partida.precio_bendicion()
	if precio < 0:
		mensaje.emit("El jizō ya te ha bendecido dos veces")
	elif Partida.bendecir():
		akira.vida_maxima += 1
		akira.vida = akira.vida_maxima
		monedas = Partida.monedas
		vida_maxima_cambiada.emit(akira.vida_maxima)
		vida_cambiada.emit(akira.vida)
		monedas_cambiadas.emit(monedas)
		jizo.bendecir()
		efectos.bendicion(jizo.global_position + Vector3.UP * 0.9)
		mensaje.emit("El jizō te bendice: +1 de vida")
	else:
		mensaje.emit("Te faltan %d mon para la ofrenda" % (precio - Partida.monedas))
	aviso_actual = ""                       # que el aviso se rehaga con el saldo nuevo


func comenzar() -> void:
	if camara.modo_presentacion:
		camara.empezar_a_seguir()
	akira.controlable = true
	_cambiar_fase("jugando")


func _cambiar_fase(nueva: String) -> void:
	fase = nueva
	shiro.activo = fase == "jugando"
	fase_cambiada.emit(fase)


func _al_derrotar() -> void:
	derrotados += 1
	derrotados_cambiados.emit(derrotados, soldados.size())


# Alcance y cono del corte en curso (cada corte de armas.gd tiene los suyos).
func _en_alcance(punto: Vector3, radio: float) -> bool:
	var hacia: Vector3 = punto - akira.global_position
	if absf(hacia.y) > 1.2 + radio:
		return false
	hacia.y = 0.0
	var distancia := hacia.length()
	if distancia > float(akira.ataque.alcance) + radio:
		return false
	if distancia < 0.5 + radio:
		return true
	return akira.mirando.angle_to(hacia) <= deg_to_rad(float(akira.ataque.cono) / 2.0)


# Dónde se puede cortar a cada enemigo: el centro, o sus partes (los puños y la cabeza del jefe).
func puntos_de_golpe(enemigo) -> Array:
	if enemigo.has_method("puntos_de_golpe"):
		return enemigo.puntos_de_golpe()
	return [{"posicion": enemigo.global_position, "radio": Datos.RADIO_PERSONAJE, "parte": ""}]


func _parte_alcanzada(enemigo):
	for punto in puntos_de_golpe(enemigo):
		if _en_alcance(punto.posicion, float(punto.radio)):
			return punto
	return null


func soldados_vivos() -> Array:
	return soldados.filter(func(s): return is_instance_valid(s) and s.vivo())


func soldado_mas_cercano(desde: Vector3, alcance: float):
	var mejor = null
	var mejor_distancia := alcance
	for soldado in soldados_vivos():
		var distancia: float = soldado.global_position.distance_to(desde)
		if distancia < mejor_distancia:
			mejor = soldado
			mejor_distancia = distancia
	return mejor


func _punto_entre(a: Node3D, b: Node3D) -> Vector3:
	return (a.global_position + b.global_position) / 2.0 + Vector3.UP * 1.15


# Iai perfecto: Akira desvía la estocada y derriba al soldado de un solo corte.
func _al_iai_perfecto(atacante) -> void:
	efectos.iai_perfecto(_punto_entre(akira, atacante))
	if atacante.has_method("recibir_iai"):
		atacante.recibir_iai(akira.global_position)
	else:
		atacante.recibir_golpe(akira.global_position, true)


# Corte de luna: solo se gasta la barra si hay alguien a quien cortar.
func _al_pedir_corte_de_luna() -> void:
	var objetivos: Array = soldados_vivos().filter(func(s):
		return s.global_position.distance_to(akira.global_position) <= Datos.RADIO_CORTE_LUNA)
	if objetivos.is_empty():
		mensaje.emit("No hay enemigos cerca para el corte de luna")
		return
	akira.lanzar_corte_de_luna()
	var puntos: Array = objetivos.map(func(s): return s.global_position + Vector3.UP * 1.1)
	efectos.corte_de_luna(puntos, func():
		for soldado in objetivos:
			if is_instance_valid(soldado) and soldado.vivo():
				soldado.recibir_golpe(akira.global_position, true))


func _physics_process(delta: float) -> void:
	constructor.actualizar(delta)
	_actualizar_reticula()
	if Input.is_action_just_pressed("depurar_golpes"):
		depuracion.alternar()
	cerca_del_jizo = fase == "jugando" and akira.vivo() \
		and akira.global_position.distance_to(jizo.global_position) < Datos.RADIO_JIZO
	var aviso := _texto_jizo() if cerca_del_jizo else ""
	if aviso != aviso_actual:
		aviso_actual = aviso
		aviso_interaccion.emit(aviso)
	if fase != "jugando":
		return
	if akira.corte_activo():
		for soldado in soldados_vivos():
			if akira.golpeados.has(soldado):
				continue
			var parte = _parte_alcanzada(soldado)
			if parte != null:
				akira.golpeados.append(soldado)
				var corte: Dictionary = akira.ataque
				var vida_antes: int = soldado.vida
				var mortal: bool
				if soldado.has_method("recibir_golpe_en"):
					mortal = soldado.recibir_golpe_en(String(parte.parte), akira.global_position, corte.danio)
				else:
					mortal = soldado.recibir_golpe(akira.global_position, false, corte.danio,
						corte.postura, corte.empuje)
				var punto: Vector3 = (akira.global_position + Vector3.UP * 1.15 + Vector3(parte.posicion)) / 2.0
				efectos.golpe_de(punto, mortal, corte, vida_antes - maxi(soldado.vida, 0), soldado.postura_rota())
				akira.ganar_espiritu(Datos.ESPIRITU_POR_GOLPE)
	aviso_porton = maxf(0.0, aviso_porton - delta)
	var en_porton: bool = akira.vivo() and akira.global_position.x > Datos.LIMITE_PORTON_X \
		and absf(akira.global_position.z) < 3.0
	if en_porton and jefe and jefe.vivo():
		if aviso_porton <= 0.0:
			aviso_porton = 3.0
			mensaje.emit("El oni gigante bloquea el portón: derrótalo para salir")
	elif en_porton:
		akira.controlable = false
		_cambiar_fase("cierre")
	elif not akira.vivo():
		tiempo_derrota += delta
		if tiempo_derrota > 1.4:
			_cambiar_fase("derrota")
