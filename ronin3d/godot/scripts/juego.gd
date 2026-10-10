# Un escenario del juego en 3D (escenarios.gd: del castillo de Hoshiyama del capítulo 1 al regreso
# del capítulo 4): construye su mundo, crea a Akira, a Shiro (su perro), los soldados, los yōkai y los
# jefes, resuelve los golpes de espada, lleva la cuenta de las monedas y decide cuándo se gana o se
# pierde. También los aldeanos, los kodama que guían, la hoguera del descanso y la barrera de sellos.
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
const VisualHoja := preload("res://scripts/visual_hoja.gd")
const Escenarios := preload("res://scripts/escenarios.gd")
const ConstructorEscenarios := preload("res://scripts/constructor_escenarios.gd")
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
signal pedir_sastre                  # el sastre de la aldea: el juego abre su género (en la pausa)

var aspecto
var efectos
var constructor
var akira
var camara
var soldados: Array = []             # todos los enemigos: soldados, yōkai y el jefe
var jefe                             # el jefe que está en pie (jefe_oni.gd o un yōkai jefe)
var escenario: Dictionary = {}
var indice_escenario := 0
var jefes_pendientes: Array = []     # los que aparecen cuando cae el anterior (Genzo → Tamamo)
var espera_jefe := -1.0
var tiempo_final := -1.0             # último escenario: tras el último jefe, el cierre
var fraccion_jefe := -2.0
var objetivos: Array = []            # sellos que abren la barrera del santuario
var barrera: Node3D
var aviso_barrera := 0.0
var kodamas: Array = []
var aldeanos: Array = []             # {nodo, visual, nombre, frases, indice}
var descanso := Vector3.INF
var interaccion: Dictionary = {}
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


func iniciar(con_intro := true, indice := 0) -> void:
	indice_escenario = clampi(indice, 0, Escenarios.cantidad() - 1)
	escenario = Escenarios.datos(indice_escenario)
	monedas = Partida.monedas
	azar.seed = 5 + indice_escenario
	aspecto = Aspecto.new()
	if String(escenario.mundo) == "castillo":
		constructor = ConstructorMundo.new()
		constructor.construir(self, aspecto, escenario.ambiente)
	else:
		constructor = ConstructorEscenarios.new()
		constructor.construir_escenario(self, aspecto, escenario)

	akira = Akira.new()
	add_child(akira)
	akira.position = escenario.inicio
	akira.coste_esquiva = 0.5 if Partida.tiene_tecnica("paso_del_tengu") else 1.0
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
	akira.buscar_rival = rival_para_akira
	akira.ataco.connect(func(): efectos.tajo(akira.global_position + Vector3.UP * 1.2))
	akira.desenvaino.connect(func(): efectos.desenvaine(akira.global_position + Vector3.UP * 1.2))
	akira.paro.connect(_al_iai_perfecto)
	akira.pidio_corte_de_luna.connect(_al_pedir_corte_de_luna)
	akira.espiritu_cambiado.connect(func(valor): espiritu_cambiado.emit(valor))
	akira.aguante_cambiado.connect(func(valor): aguante_cambiado.emit(valor))
	akira.arma_cambiada.connect(func(arma): arma_cambiada.emit(arma))
	akira.esquivo.connect(func(): efectos.esquiva(akira.global_position + Vector3.UP * 0.4))
	akira.vida_cambiada.connect(func(_vida): efectos.herido(akira.global_position + Vector3.UP * 1.1))

	if escenario.has("jizo"):
		jizo = Jizo.new()
		add_child(jizo)
		jizo.configurar(aspecto)
		jizo.position = escenario.jizo
		jizo.rotation.y = PI / 2.0              # mira al patio (al este)
	descanso = escenario.get("descanso", Vector3.INF)

	monedas_suelo = Monedas.new()
	add_child(monedas_suelo)
	monedas_suelo.configurar(aspecto, akira)
	monedas_suelo.recogidas.connect(_al_recoger_monedas)
	_crear_shiro()

	for patrulla in escenario.patrullas:
		crear_soldado(patrulla[0], patrulla[1])
	_crear_yokai()
	for entrada in escenario.get("objetivos", []):
		objetivos.append(crear_yokai(entrada[0], entrada[1]))
	jefes_pendientes = escenario.jefes.duplicate()
	_siguiente_jefe()
	if not objetivos.is_empty():
		_crear_barrera()
	_crear_kodamas()
	_crear_aldeanos()
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


# El objetivo se mantiene mientras siga vivo y cerca (como el fijado de EthrA); si cae o se aleja,
# pasa al más cercano. «Fijar» (TAB, clic del stick derecho o el botón táctil) salta al siguiente.
func _actualizar_reticula() -> void:
	var sigue: bool = objetivo_fijado != null and is_instance_valid(objetivo_fijado) and objetivo_fijado.vivo() \
		and objetivo_fijado.global_position.distance_to(akira.global_position) < ALCANCE_FIJADO * 1.4
	if not akira.vivo():
		objetivo_fijado = null
	elif not sigue:
		objetivo_fijado = soldado_mas_cercano(akira.global_position, ALCANCE_FIJADO)
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


func cambiar_objetivo() -> void:
	var cerca: Array = soldados_vivos().filter(func(e):
		return e.global_position.distance_to(akira.global_position) < ALCANCE_FIJADO * 1.4)
	if cerca.is_empty():
		return
	cerca.sort_custom(func(a, b):
		return a.global_position.distance_to(akira.global_position) < b.global_position.distance_to(akira.global_position))
	var indice: int = cerca.find(objetivo_fijado)
	objetivo_fijado = cerca[(indice + 1) % cerca.size()]


# Para los cortes y el iai: el objetivo fijado si está a mano; si no, el más cercano.
func rival_para_akira(desde: Vector3, alcance: float):
	if objetivo_fijado != null and is_instance_valid(objetivo_fijado) and objetivo_fijado.vivo() \
			and objetivo_fijado.global_position.distance_to(desde) < alcance:
		return objetivo_fijado
	return soldado_mas_cercano(desde, alcance)


func crear_soldado(desde: Vector3, hasta: Vector3):
	var soldado = Soldado.new()
	add_child(soldado)
	soldado.configurar(desde, hasta, akira)
	soldado.visual = _crear_visual(true)
	soldado.add_child(soldado.visual)
	soldado.derrotado.connect(_al_derrotar)
	soldado.derrotado.connect(func(): _soltar_monedas(soldado))
	soldado.aviso_iniciado.connect(func(): efectos.aviso(soldado.global_position + Vector3.UP * 2.0))
	soldado.estocada_iniciada.connect(func(): efectos.estocada(soldado.global_position + Vector3.UP * 1.1))
	soldados.append(soldado)
	return soldado


# Yōkai del bestiario: los del escenario (escenarios.gd), con sus fichas de enemigos.gd.
func _crear_yokai() -> void:
	for entrada in escenario.yokai:
		crear_yokai(entrada[0], entrada[1])


func crear_yokai(tipo: String, lugar: Vector3):
	var yokai = Yokai.new()
	yokai.configurar(tipo, lugar, akira, aspecto)
	yokai.efectos = efectos
	yokai.invocador = _invocar
	add_child(yokai)
	yokai.derrotado.connect(_al_derrotar)
	yokai.derrotado.connect(func():
		akira.ganar_espiritu(float(yokai.perfil.get("espiritu_al_morir", 0.0)))
		if Enemigos.da_monedas(yokai.perfil) and not yokai.es_jefe() and not yokai.perfil.get("objetivo", false):
			monedas_suelo.soltar(yokai.global_position + Vector3.UP * 0.7, azar.randi_range(1, 2))
		if yokai.perfil.get("falsa", false) or yokai.perfil.get("objetivo", false):
			efectos.polvo_de_pixeles(yokai.global_position + Vector3.UP * 1.0))
	yokai.aviso_iniciado.connect(func(): efectos.aviso(yokai.global_position + Vector3.UP * (float(yokai.perfil.get("alto", 1.8)) + 0.2)))
	yokai.estocada_iniciada.connect(func(): efectos.estocada(yokai.global_position + Vector3.UP * 1.0))
	yokai.mensaje.connect(func(texto): mensaje.emit(texto))
	yokai.impacto_area.connect(func(punto):
		efectos.sacudir(0.5)
		efectos.sonar("caida", punto, 2.0, 0.05)
		efectos.polvo(punto))
	soldados.append(yokai)
	return yokai


# Lo que invoca un enemigo (crías, copias, cuervos, soldados poseídos…), dentro del área de juego.
func _invocar(tipo: String, lugar: Vector3):
	var dentro := Vector3(clampf(lugar.x, -24.0, 24.0), lugar.y, clampf(lugar.z, -15.5, 15.5))
	efectos.polvo(dentro)
	return crear_yokai(tipo, dentro)


# Los jefes del escenario, de uno en uno: el siguiente aparece cuando cae el anterior.
func _siguiente_jefe() -> void:
	fraccion_jefe = -2.0
	if jefes_pendientes.is_empty():
		jefe = null
		return
	var datos: Dictionary = jefes_pendientes.pop_front()
	if String(datos.tipo) == "oni_porton":
		_crear_jefe_oni(datos.posicion)
		return
	jefe = crear_yokai(String(datos.tipo), datos.posicion)
	var este = jefe
	if datos.has("mensaje"):
		mensaje.emit(String(datos.mensaje))
		efectos.polvo_de_pixeles(este.global_position + Vector3.UP * 1.5)
	if not objetivos.is_empty():
		este.protegido = true
	for desplazamiento in este.perfil.get("sellos", []):
		este.sellos.append(crear_yokai("sello_dogu", este.position + desplazamiento))
	este.desperto.connect(func():
		efectos.sacudir(0.6)
		jefe_cambiado.emit(String(este.perfil.nombre), este.fraccion_vida()))
	este.derrotado.connect(func(): _al_caer_jefe(este))


func _al_caer_jefe(caido) -> void:
	efectos.camara_lenta(0.3, 0.8)
	efectos.sacudir(1.0)
	efectos.polvo_de_pixeles(caido.global_position + Vector3.UP * 1.5)
	monedas_suelo.soltar(caido.global_position + Vector3(-1.5, 1, 0), 10)
	jefe_cambiado.emit("", -1.0)
	if not jefes_pendientes.is_empty():
		espera_jefe = 2.6
	elif is_inf(float(escenario.salida_x)):
		tiempo_final = 3.5
	else:
		mensaje.emit("%s ha caído. El camino queda libre." % String(caido.perfil.nombre))


# La barrera del santuario del templo: cierra el paso al jefe hasta cortar todos los sellos.
func _crear_barrera() -> void:
	barrera = Node3D.new()
	var x: float = jefe.position.x - 4.5 if jefe else 14.0
	var muro := StaticBody3D.new()
	var forma := CollisionShape3D.new()
	var caja := BoxShape3D.new()
	caja.size = Vector3(0.6, 6, 34)
	forma.shape = caja
	muro.add_child(forma)
	barrera.add_child(muro)
	var velo := MeshInstance3D.new()
	var plano := BoxMesh.new()
	plano.size = Vector3(0.1, 5, 34)
	velo.mesh = plano
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.75, 0.45, 1.0, 0.28)
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	velo.material_override = material
	velo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	velo.position.y = 2.5
	barrera.add_child(velo)
	barrera.position = Vector3(x, 0, 0)
	add_child(barrera)


func objetivos_vivos() -> int:
	return objetivos.filter(func(o): return is_instance_valid(o) and o.vivo()).size()


func _actualizar_barrera(delta: float) -> void:
	if barrera == null:
		return
	aviso_barrera = maxf(0.0, aviso_barrera - delta)
	var quedan := objetivos_vivos()
	if quedan == 0:
		barrera.queue_free()
		barrera = null
		if jefe and is_instance_valid(jefe) and jefe.has_method("es_jefe"):
			jefe.protegido = false
		efectos.sacudir(0.5)
		mensaje.emit("Los sellos se rompen y la barrera cae")
		return
	if akira.global_position.x > barrera.position.x - 3.0 and aviso_barrera <= 0.0:
		aviso_barrera = 4.0
		mensaje.emit("Una barrera cierra el santuario: corta los sellos de papel (quedan %d)" % quedan)


# Los kodama del Kakuriyo: espíritus de los árboles que señalan el camino cuando Akira se acerca.
func _crear_kodamas() -> void:
	for lugar in escenario.get("kodama", []):
		var kodama := Node3D.new()
		kodama.position = lugar
		add_child(kodama)
		var visual = VisualHoja.new()
		visual.configurar("kodama_hoja", 0.65)
		kodama.add_child(visual)
		kodamas.append(visual)


# Aldeanos con los que se habla (cada vez dicen la frase siguiente).
func _crear_aldeanos() -> void:
	for datos in escenario.get("aldeanos", []):
		var nodo := Node3D.new()
		nodo.position = datos[2]
		add_child(nodo)
		var visual = VisualHoja.new()
		visual.configurar(String(datos[0]), 1.8)
		visual.fijar_bucle(String(datos[1]))
		nodo.add_child(visual)
		aldeanos.append({"nodo": nodo, "visual": visual, "nombre": String(datos[1]).capitalize(),
			"frases": datos[3], "indice": 0})


func _actualizar_guias(delta: float) -> void:
	for visual in kodamas:
		var cerca: bool = visual.global_position.distance_to(akira.global_position) < 5.0
		visual.actualizar(delta, {"pose": "estocada" if cerca else "normal", "mirando": Vector3.RIGHT})
	for aldeano in aldeanos:
		var hacia: Vector3 = akira.global_position - aldeano.nodo.global_position
		hacia.y = 0.0
		aldeano.visual.actualizar(delta, {"mirando": hacia.normalized() if hacia.length() > 0.1 else Vector3.RIGHT})


func _crear_jefe_oni(posicion: Vector3) -> void:
	jefe = JefeOni.new()
	jefe.configurar(posicion, akira, aspecto)
	add_child(jefe)
	soldados.append(jefe)
	jefe.desperto.connect(func():
		efectos.sacudir(0.9)
		efectos.sonar("caida", jefe.global_position, 6.0, 0.0)
		mensaje.emit("¡Un oni derriba el portón y cierra la huida!")
		jefe_cambiado.emit("Oni", 1.0))
	jefe.vida_cambiada.connect(func(fraccion): jefe_cambiado.emit("Oni", fraccion))
	jefe.punetazo.connect(func(punto):
		efectos.sacudir(0.75)
		efectos.pausa_de_impacto(0.06)
		efectos.sonar("caida", punto, 4.0, 0.05)
		efectos.polvo(punto)
		efectos.chispas(punto + Vector3.UP * 0.2, 40, Color(1.0, 0.15, 0.08), 7.0, 0.6, -6.0, 0.1))
	jefe.postura_quebrada.connect(func(roturas):
		efectos.sacudir(0.6)
		efectos.texto_flotante(jefe.global_position + Vector3.UP * 3.0, "¡Postura rota!", Color(1.0, 0.85, 0.3), 0.009)
		if roturas >= JefeOni.ROTURAS_PARA_FURIA:
			mensaje.emit("¡El oni entra en furia! Para su barrido con el iai"))
	jefe.aviso_iniciado.connect(func(): efectos.aviso(jefe.global_position + Vector3.UP * 3.0))
	jefe.estocada_iniciada.connect(func(): efectos.estocada(jefe.global_position + Vector3.UP * 1.2))
	jefe.derrotado.connect(func():
		_al_derrotar()
		efectos.camara_lenta(0.3, 0.8)
		efectos.sacudir(1.0)
		efectos.polvo_de_pixeles(jefe.global_position + Vector3.UP * 1.5)
		monedas_suelo.soltar(jefe.global_position + Vector3(-2, 1, 0), 12)
		mensaje.emit("El oni ha caído. El portón queda libre.")
		jefe_cambiado.emit("", -1.0)
		if not jefes_pendientes.is_empty():
			espera_jefe = 2.6)


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
	if VisualSprite.activo and soldado:
		# Los soldados de Genzo, en el estilo del oni del usuario (hoja de perfil).
		var hoja = VisualHoja.new()
		hoja.configurar("soldado_hoja", Datos.ALTO_SOLDADO_HOJA)
		return hoja
	if VisualSprite.activo:
		var sprite = VisualSprite.new()
		sprite.configurar(aspecto, "akira", apariencia)
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


# Con qué se puede interactuar ahora: el jizō, la hoguera del descanso o un aldeano.
func _interaccion_cercana() -> Dictionary:
	if fase != "jugando" or not akira.vivo():
		return {}
	if cerca_del_jizo:
		return {"texto": _texto_jizo(), "accion": "jizo"}
	if descanso != Vector3.INF and akira.global_position.distance_to(descanso) < 2.2:
		return {"texto": "Hoguera: descansar (recupera toda la vida)", "accion": "descanso"}
	for aldeano in aldeanos:
		if akira.global_position.distance_to(aldeano.nodo.global_position) < 2.2:
			return {"texto": "%s: hablar" % aldeano.nombre, "accion": "aldeano", "aldeano": aldeano}
	return {}


# ENTER (o B en el mando, o tocar el aviso en el móvil) junto al jizō, la hoguera o un aldeano.
func interactuar() -> void:
	match String(interaccion.get("accion", "")):
		"descanso":
			akira.vida = akira.vida_maxima
			vida_cambiada.emit(akira.vida)
			efectos.bendicion(descanso + Vector3.UP * 0.6)
			mensaje.emit("Akira descansa junto al fuego. Shiro se tumba a su lado.")
			return
		"aldeano":
			var aldeano: Dictionary = interaccion.aldeano
			var frases: Array = aldeano.frases
			mensaje.emit(String(frases[aldeano.indice % frases.size()]))
			aldeano.indice += 1
			if aldeano.nombre == "Sastre":
				pedir_sastre.emit()
			return
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
	_actualizar_guias(delta)
	if fase == "jugando" and Input.is_action_just_pressed("cambiar_objetivo"):
		cambiar_objetivo()
	if Input.is_action_just_pressed("depurar_golpes"):
		depuracion.alternar()
	cerca_del_jizo = fase == "jugando" and akira.vivo() and jizo != null \
		and akira.global_position.distance_to(jizo.global_position) < Datos.RADIO_JIZO
	interaccion = _interaccion_cercana()
	var aviso: String = interaccion.get("texto", "")
	if aviso != aviso_actual:
		aviso_actual = aviso
		aviso_interaccion.emit(aviso)
	if fase != "jugando":
		return
	_actualizar_barrera(delta)
	_actualizar_barra_jefe()
	if espera_jefe >= 0.0:
		espera_jefe -= delta
		if espera_jefe < 0.0:
			_siguiente_jefe()
	if tiempo_final >= 0.0:
		tiempo_final -= delta
		if tiempo_final < 0.0:
			akira.controlable = false
			_cambiar_fase("cierre")
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
				if soldado.has_method("consumir_bloqueo") and soldado.consumir_bloqueo():
					efectos.bloqueo(punto)
					continue
				efectos.golpe_de(punto, mortal, corte, vida_antes - maxi(soldado.vida, 0), soldado.postura_rota())
				akira.ganar_espiritu(Datos.ESPIRITU_POR_GOLPE)
	aviso_porton = maxf(0.0, aviso_porton - delta)
	var en_porton: bool = akira.vivo() and akira.global_position.x > float(escenario.salida_x) \
		and absf(akira.global_position.z) < float(escenario.salida_ancho)
	var cerrado: bool = (jefe != null and is_instance_valid(jefe) and jefe.vivo()) or not jefes_pendientes.is_empty() \
		or objetivos_vivos() > 0
	if en_porton and cerrado:
		if aviso_porton <= 0.0:
			aviso_porton = 3.0
			if jefe is JefeOni:
				mensaje.emit("El oni bloquea el portón: derrótalo para salir")
			elif jefe != null and is_instance_valid(jefe):
				mensaje.emit("%s cierra el paso: derrótalo para seguir" % String(jefe.perfil.nombre))
			else:
				mensaje.emit("Todavía no se puede pasar")
	elif en_porton:
		akira.controlable = false
		_cambiar_fase("cierre")
	elif not akira.vivo():
		tiempo_derrota += delta
		if tiempo_derrota > 1.4:
			_cambiar_fase("derrota")


func _exit_tree() -> void:
	Yokai.lanzandose.clear()


# La barra del jefe (yōkai jefes): se enseña al despertar y baja con su vida.
func _actualizar_barra_jefe() -> void:
	if jefe == null or not is_instance_valid(jefe) or not jefe.has_method("es_jefe"):
		return
	if not jefe.despierto() or not jefe.vivo():
		return
	var fraccion: float = jefe.fraccion_vida()
	if absf(fraccion - fraccion_jefe) > 0.001:
		fraccion_jefe = fraccion
		jefe_cambiado.emit(String(jefe.perfil.nombre), fraccion)
