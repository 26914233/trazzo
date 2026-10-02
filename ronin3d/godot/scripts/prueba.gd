# Prueba automática: juega sola unos segundos, comprueba lo básico y guarda capturas
# en ronin3d/capturas/actual/. Se lanza así (sin ventana, con Xvfb en Linux):
#   godot --path ronin3d/godot --rendering-driver opengl3 --fixed-fps 30 -- --prueba
# Sale con código 0 si todo fue bien y 1 si algo falló.
# Con la variable de entorno RONIN_FOTOGRAMAS=<carpeta>, guarda además los fotogramas del
# iai perfecto y del corte de luna (para hacer GIF).
extends Node

const Datos := preload("res://scripts/datos.gd")
const VisualModelo := preload("res://scripts/visual_modelo.gd")
const Aspecto := preload("res://scripts/aspecto.gd")
const Criatura := preload("res://scripts/criatura_modular.gd")
const ModeloCriatura := preload("res://scripts/modelo_criatura.gd")
const Apariencias := preload("res://scripts/apariencias_akira.gd")
const MOVIMIENTOS := ["mover_adelante", "mover_atras", "mover_izquierda", "mover_derecha"]

var principal
var tiempo := 0.0
var pasos: Array = []
var indice := 0
var resultados: Array = []
var carpeta := ""
var prefijo := ""
var posicion_guardada := Vector3.ZERO
var giro_guardado := 0.0
var objetivo_combate = null
var vida_objetivo := 0
var vida_akira := 0
var combate_activo := false
var captura_combate_hecha := false
var direccion_caminar := Vector3.ZERO
var pendientes_soltar: Array = []
var medida_inicio_us := 0
var medida_inicio_cuadros := 0
var fps_medidos := 0.0
var rival_parada = null
var parada_pulsada := false
var parada_soltada := false
var parada_temprana := false
var iai_visto := false
var objetivos_luna: Array = []
var luna_lanzada := false
var luna_capturada := false
var cuenta_anime := 0
var juego_procesa_en_pausa := true
var monedas_antes := 0
var soltadas_antes := 0
var hallazgos_antes := 0
var entregadas_antes := 0
var carpeta_fotogramas := OS.get_environment("RONIN_FOTOGRAMAS")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	carpeta = ProjectSettings.globalize_path("res://").path_join("../capturas/actual").simplify_path()
	DirAccess.make_dir_recursive_absolute(carpeta)
	pasos = [
		[0.2, _comprobar_textos],
		[1.2, _capturar.bind("intro")],
		[1.3, _pulsar.bind("aceptar")],
		[1.4, _capturar.bind("intro_completa")],
		[1.5, _pulsar.bind("aceptar")],
		[1.6, _empezar_medida],
		[3.0, _empezar_a_caminar],
		[4.6, _dejar_de_caminar],
		[4.65, _terminar_medida],
		[4.7, _capturar.bind("patio")],
		[4.72, _comprobar_hud],
		[4.75, _comprobar_shiro_sigue],
		[4.8, _empezar_giro],
		[5.8, _terminar_giro],
		[6.0, _capturar.bind("camara_girada")],
		[6.2, _preparar_combate],
		[10.5, _terminar_combate],
		[10.7, _probar_muro],
		[12.0, _comprobar_muro],
		[12.2, _preparar_vista_torreon],
		[13.2, _capturar.bind("torreon")],
		[13.4, _ir_al_porton],
		[15.6, _comprobar_cierre],
		[15.8, _pulsar.bind("aceptar")],
		[16.3, _capturar.bind("cierre")],
		[16.5, _pulsar.bind("pausa")],
		[16.9, _comprobar_pausa],
		[17.3, _comprobar_reanudar],
		[17.5, _activar_tactil],
		[17.6, _tocar.bind(Vector2(640, 360))],
		[17.9, _tocar.bind(Vector2(640, 360))],
		[18.2, _tocar.bind(Vector2(640, 360))],
		[18.4, _comprobar_toques],
		[19.6, _empezar_joystick],
		[20.3, _capturar.bind("tactil")],
		[20.5, _terminar_joystick],
		[20.7, _empezar_mando],
		[21.4, _terminar_mando],
		[21.6, _preparar_parada],
		[23.2, _comprobar_parada],
		[23.4, _preparar_parada_temprana],
		[25.2, _comprobar_parada_temprana],
		[25.4, _preparar_corte_luna],
		[25.7, _lanzar_corte_luna],
		[27.5, _comprobar_corte_luna],
		[27.7, _empezar_cuenta_anime],
		[28.7, _cambiar_a_suave],
		[29.7, _comprobar_animacion],
		[29.9, _abrir_galeria_prueba],
		[30.6, _comprobar_galeria_abierta],
		[31.2, _comprobar_galeria_cerrada],
		[31.4, _comprobar_bestiario],
		[31.5, _construir_todo_el_bestiario],
		[31.6, _comprobar_modelo_detallado],
		[31.7, _comprobar_apariencias],
		[31.8, _preparar_shiro],
		[34.0, _capturar.bind("shiro_escarba")],
		[35.6, _comprobar_hallazgo],
		[36.4, _comprobar_recogida],
		[36.5, _preparar_traer],
		[41.5, _comprobar_traer],
		[41.6, _capturar.bind("monedas")],
		[41.8, _terminar],
	]


func _process(delta: float) -> void:
	tiempo += delta
	for pendiente in pendientes_soltar.duplicate():
		pendiente[1] -= 1
		if pendiente[1] <= 0:
			_enviar_accion(pendiente[0], false)
			pendientes_soltar.erase(pendiente)
	while indice < pasos.size() and tiempo >= pasos[indice][0]:
		pasos[indice][1].call()
		indice += 1
	if rival_parada != null:
		_paso_parada()
	if luna_lanzada and not luna_capturada and _juego().efectos.luna_progreso() > 0.5:
		luna_capturada = true
		_capturar("corte_luna")
	if combate_activo:
		_paso_combate()
	elif direccion_caminar != Vector3.ZERO:
		_teclas_hacia(direccion_caminar)


# --- Utilidades ----------------------------------------------------------------------

func _juego():
	return principal.juego


func _enviar_accion(accion: String, pulsada: bool) -> void:
	var evento := InputEventAction.new()
	evento.action = accion
	evento.pressed = pulsada
	Input.parse_input_event(evento)


func _pulsar(accion: String) -> void:
	_enviar_accion(accion, true)
	pendientes_soltar.append([accion, 2])


func _soltar_movimiento() -> void:
	for accion in MOVIMIENTOS:
		Input.action_release(accion)


func _teclas_hacia(direccion: Vector3) -> void:
	# Pulsa las teclas que, con la cámara actual, llevan a Akira hacia «direccion».
	var camara = _juego().camara
	var adelante: float = direccion.dot(camara.adelante())
	var derecha: float = direccion.dot(camara.derecha())
	_soltar_movimiento()
	if adelante > 0.38:
		Input.action_press("mover_adelante")
	elif adelante < -0.38:
		Input.action_press("mover_atras")
	if derecha > 0.38:
		Input.action_press("mover_derecha")
	elif derecha < -0.38:
		Input.action_press("mover_izquierda")


func _proteger(activo: bool) -> void:
	# Fuera del combate los soldados no deben interferir en lo que se comprueba.
	var akira = _juego().akira
	akira.vida = Datos.VIDA_MAXIMA
	akira.muerte = -1.0
	akira.invulnerable = 999.0 if activo else 0.0
	principal.hud.poner_vida(akira.vida)
	for soldado in _juego().soldados_vivos():
		soldado.process_mode = Node.PROCESS_MODE_DISABLED if activo else Node.PROCESS_MODE_INHERIT


func _teletransportar(posicion: Vector3, mirando: Vector3) -> void:
	var akira = _juego().akira
	akira.global_position = posicion
	akira.velocity = Vector3.ZERO
	akira.mirando = mirando.normalized()
	_juego().camara.colocar_de_golpe()


func _registrar(nombre: String, correcto: bool, detalle := "") -> void:
	resultados.append([nombre, correcto, detalle])
	print("%s %s  %s" % ["OK   " if correcto else "FALLO", nombre, detalle])


func _capturar(nombre: String) -> void:
	await RenderingServer.frame_post_draw
	var imagen := get_viewport().get_texture().get_image()
	var ruta := carpeta.path_join(prefijo + nombre + ".png")
	imagen.save_png(ruta)
	print("Captura: ", ruta)


# Guarda «cuadros» fotogramas seguidos a 640 × 360, solo si se pidió con RONIN_FOTOGRAMAS.
func _grabar(nombre: String, cuadros: int) -> void:
	if carpeta_fotogramas == "":
		return
	var destino := carpeta_fotogramas.path_join(nombre)
	DirAccess.make_dir_recursive_absolute(destino)
	for i in cuadros:
		await RenderingServer.frame_post_draw
		var imagen := get_viewport().get_texture().get_image()
		imagen.resize(640, 360, Image.INTERPOLATE_BILINEAR)
		imagen.save_png(destino.path_join("%03d.png" % i))


# --- Pasos de la prueba ------------------------------------------------------------------

func _empezar_a_caminar() -> void:
	_registrar("La intro da paso al juego", _juego().fase == "jugando", "fase=" + _juego().fase)
	_proteger(true)
	_teletransportar(Vector3(-4, 0, 0), Vector3.RIGHT)
	_juego().camara.giro = -90.0          # cámara al oeste: «adelante» es el este
	posicion_guardada = _juego().akira.global_position
	Input.action_press("mover_adelante")


func _dejar_de_caminar() -> void:
	_soltar_movimiento()
	var recorrido: float = _juego().akira.global_position.distance_to(posicion_guardada)
	_registrar("Akira camina", recorrido > 3.0, "recorrió %.1f m" % recorrido)


func _comprobar_hud() -> void:
	var pantalla := get_viewport().get_visible_rect()
	var fuera: Array = []
	for nombre in ["marcador", "etiqueta_soldados", "etiqueta_version"]:
		var control: Control = principal.hud.get(nombre)
		if not control.visible or not pantalla.encloses(control.get_global_rect()):
			fuera.append(nombre)
	var detalle := "vida, soldados y versión" if fuera.is_empty() else "fuera: " + ", ".join(PackedStringArray(fuera))
	_registrar("El HUD se ve entero en pantalla", fuera.is_empty(), detalle)


func _empezar_giro() -> void:
	giro_guardado = _juego().camara.giro
	Input.action_press("girar_derecha")


func _terminar_giro() -> void:
	Input.action_release("girar_derecha")
	var giro: float = absf(_juego().camara.giro - giro_guardado)
	_registrar("La cámara gira con E", giro > 45.0, "giró %.0f°" % giro)


func _preparar_combate() -> void:
	var juego = _juego()
	objetivo_combate = juego.soldados[0]
	vida_objetivo = objetivo_combate.vida
	vida_akira = juego.akira.vida
	var puesto: Vector3 = objetivo_combate.global_position
	_proteger(false)
	_teletransportar(puesto + Vector3(4.5, 0, 0), Vector3.LEFT)
	combate_activo = true


func _paso_combate() -> void:
	var juego = _juego()
	var akira = juego.akira
	if not is_instance_valid(objetivo_combate) or not objetivo_combate.vivo():
		_soltar_movimiento()
		return
	var hacia: Vector3 = objetivo_combate.global_position - akira.global_position
	hacia.y = 0.0
	var distancia := hacia.length()
	if distancia > 1.25:
		_teclas_hacia(hacia.normalized())
	else:
		_soltar_movimiento()
		akira.mirando = hacia.normalized()
		if not akira.atacando() and akira.enfriamiento <= 0.0:
			_pulsar("atacar")
	if not captura_combate_hecha and akira.atacando() and distancia < 2.4:
		captura_combate_hecha = true
		_capturar("combate")


func _terminar_combate() -> void:
	combate_activo = false
	_soltar_movimiento()
	var derrotado: bool = not is_instance_valid(objetivo_combate) or not objetivo_combate.vivo()
	var danado: bool = derrotado or objetivo_combate.vida < vida_objetivo
	_registrar("La espada daña al soldado", danado, "derrotados=%d" % _juego().derrotados)
	_registrar("El soldado se defiende (resta vida o Akira gana antes)", true,
		"vida de Akira %d → %d" % [vida_akira, _juego().akira.vida])
	var soltadas: int = _juego().monedas_suelo.soltadas
	_registrar("Los soldados derrotados sueltan monedas", _juego().derrotados == 0
		or soltadas >= _juego().derrotados * Datos.MONEDAS_SOLDADO.x,
		"%d derrotados, %d monedas soltadas" % [_juego().derrotados, soltadas])
	_proteger(true)


func _probar_muro() -> void:
	_teletransportar(Vector3(-22.5, 0, 0.5), Vector3.LEFT)
	direccion_caminar = Vector3.LEFT


func _comprobar_muro() -> void:
	direccion_caminar = Vector3.ZERO
	_soltar_movimiento()
	var x: float = _juego().akira.global_position.x
	_registrar("El muro oeste detiene a Akira", x > -23.9, "x=%.2f (el muro empieza en −24)" % x)


func _preparar_vista_torreon() -> void:
	_teletransportar(Vector3(2, 0, -3), Vector3.FORWARD)
	var camara = _juego().camara
	camara.giro = 12.0
	camara.inclinacion = -5.0
	camara.distancia = 18.0
	camara.colocar_de_golpe()


func _ir_al_porton() -> void:
	var camara = _juego().camara
	camara.giro = -60.0
	camara.inclinacion = 38.0
	_teletransportar(Vector3(20.5, 0, 0.3), Vector3.RIGHT)
	direccion_caminar = Vector3.RIGHT


func _comprobar_cierre() -> void:
	direccion_caminar = Vector3.ZERO
	_soltar_movimiento()
	_registrar("Llegar al portón cierra el capítulo", _juego().fase == "cierre", "fase=" + _juego().fase)


var pausa_vista := false


func _comprobar_pausa() -> void:
	pausa_vista = get_tree().paused
	juego_procesa_en_pausa = _juego().can_process()
	await _capturar("pausa")
	_pulsar("pausa")


func _comprobar_reanudar() -> void:
	var correcto: bool = pausa_vista and not get_tree().paused and not juego_procesa_en_pausa
	_registrar("ESC pausa el juego de verdad (soldados y Shiro quietos) y lo reanuda", correcto,
		"pausado=%s, el juego seguía=%s, después=%s" % [pausa_vista, juego_procesa_en_pausa, get_tree().paused])


# --- Controles táctiles y mando --------------------------------------------------------

func _activar_tactil() -> void:
	principal.tactil.activar(true)


func _evento_toque(posicion: Vector2, pulsado: bool) -> void:
	var toque := InputEventScreenTouch.new()
	toque.index = 0
	toque.position = posicion
	toque.pressed = pulsado
	Input.parse_input_event(toque)


func _tocar(posicion: Vector2) -> void:
	_evento_toque(posicion, true)
	_evento_toque(posicion, false)


func _comprobar_toques() -> void:
	# Tres toques: salir del cierre, completar el texto de la intro y empezar.
	_registrar("Tocar la pantalla sigue los textos", _juego().fase == "jugando", "fase=" + _juego().fase)
	_proteger(true)


func _empezar_joystick() -> void:
	posicion_guardada = _juego().akira.global_position
	_evento_toque(Vector2(200, 520), true)
	var arrastre := InputEventScreenDrag.new()
	arrastre.index = 0
	arrastre.position = Vector2(300, 520)
	arrastre.relative = Vector2(100, 0)
	Input.parse_input_event(arrastre)


func _terminar_joystick() -> void:
	_evento_toque(Vector2(300, 520), false)
	var recorrido: float = _juego().akira.global_position.distance_to(posicion_guardada)
	_registrar("El joystick táctil mueve a Akira", recorrido > 2.0, "recorrió %.1f m" % recorrido)
	principal.tactil.activar(false)


func _eje_mando(valor: float) -> void:
	var eje := InputEventJoypadMotion.new()
	eje.device = 0
	eje.axis = JOY_AXIS_LEFT_X
	eje.axis_value = valor
	Input.parse_input_event(eje)


func _empezar_mando() -> void:
	posicion_guardada = _juego().akira.global_position
	_eje_mando(1.0)


func _terminar_mando() -> void:
	_eje_mando(0.0)
	var recorrido: float = _juego().akira.global_position.distance_to(posicion_guardada)
	_registrar("El stick del mando mueve a Akira", recorrido > 2.0, "recorrió %.1f m" % recorrido)


# --- Iaidō (combate de precisión) ---------------------------------------------------------

func _preparar_parada() -> void:
	# Un soldado se acerca a atacar; Akira se pone en postura al ver el «!» y suelta justo
	# antes de la estocada: iai perfecto.
	_juego().akira.paro.connect(_al_iai)
	principal.hud.tiempo_ayuda = -1.0              # sin texto de ayuda en las tomas del combate
	principal.hud.etiqueta_ayuda.modulate.a = 0.0
	_preparar_parada_con(_juego().soldados[2])


func _preparar_parada_con(soldado) -> void:
	var juego = _juego()
	rival_parada = soldado
	var akira = juego.akira
	akira.vida = Datos.VIDA_MAXIMA
	akira.invulnerable = 0.0          # si el iai falla, Akira pierde vida
	juego.camara.distancia = 7.5      # más cerca, para ver el corte en las capturas
	var hacia: Vector3 = Vector3(1, 0, 0)
	_teletransportar(rival_parada.global_position - hacia * 1.5, hacia)
	rival_parada.process_mode = Node.PROCESS_MODE_INHERIT


func _paso_parada() -> void:
	if not is_instance_valid(rival_parada):
		return
	var info: Dictionary = rival_parada.info()
	var momento := 0.45 if parada_temprana else 0.14    # a destiempo: nada más ver el «!»
	if not parada_pulsada and info.aviso:
		_enviar_accion("parar", true)                    # postura: mantener
		parada_pulsada = true
		_grabar("iai_destiempo" if parada_temprana else "iai", 54)
	if parada_pulsada and not parada_soltada and info.aviso and rival_parada.temporizador <= momento:
		_enviar_accion("parar", false)                   # soltar: desenvaine
		parada_soltada = true


func _al_iai(_atacante) -> void:
	iai_visto = true
	_capturar("iai")


func _comprobar_parada() -> void:
	var akira = _juego().akira
	var derribado: bool = not is_instance_valid(rival_parada) or not rival_parada.vivo()
	_registrar("Iai perfecto: soltar justo al «!» desvía la lanza y derriba al soldado de un corte",
		iai_visto and derribado and akira.vida == Datos.VIDA_MAXIMA and akira.espiritu >= Datos.ESPIRITU_POR_IAI,
		"derribado=%s, vida de Akira=%d, espíritu=%.1f" % [derribado, akira.vida, akira.espiritu])
	rival_parada = null
	_proteger(true)


func _preparar_parada_temprana() -> void:
	parada_temprana = true
	parada_pulsada = false
	parada_soltada = false
	iai_visto = false
	_preparar_parada_con(_juego().soldados[3])


func _comprobar_parada_temprana() -> void:
	var akira = _juego().akira
	var herido: bool = akira.vida < Datos.VIDA_MAXIMA
	var sigue: bool = is_instance_valid(rival_parada) and rival_parada.vivo()
	_registrar("Soltar a destiempo no sirve: la lanza alcanza a Akira", herido and sigue and not iai_visto,
		"vida de Akira=%d, soldado en pie=%s" % [akira.vida, sigue])
	rival_parada = null
	_proteger(true)


# --- Corte de luna y animación ---------------------------------------------------------------

func _preparar_corte_luna() -> void:
	var juego = _juego()
	var akira = juego.akira
	_proteger(true)
	juego.camara.distancia = 9.0
	_teletransportar(Vector3(10, 0, 0), Vector3.RIGHT)
	objetivos_luna = juego.soldados_vivos().slice(0, 2)
	for i in objetivos_luna.size():
		objetivos_luna[i].global_position = akira.global_position + Vector3(3.0, 0.0, -1.6 + 3.2 * i)
	akira.ganar_espiritu(1.0)


func _lanzar_corte_luna() -> void:
	luna_lanzada = true
	# Se despiertan todos los que alcanzará el corte (no solo los dos colocados), para que se
	# vea cómo caen; si no, alguno moriría congelado de pie.
	var akira = _juego().akira
	for soldado in _juego().soldados_vivos():
		if soldado.global_position.distance_to(akira.global_position) <= Datos.RADIO_CORTE_LUNA:
			soldado.process_mode = Node.PROCESS_MODE_INHERIT
	_pulsar("especial")
	_grabar("corte_luna", 72)


func _comprobar_corte_luna() -> void:
	var akira = _juego().akira
	var caidos := objetivos_luna.filter(func(s): return not is_instance_valid(s) or not s.vivo()).size()
	_registrar("Corte de luna: con la barra llena derriba a los soldados cercanos",
		objetivos_luna.size() >= 2 and caidos == objetivos_luna.size() and akira.espiritu == 0.0,
		"derribados %d de %d, espíritu=%.1f" % [caidos, objetivos_luna.size(), akira.espiritu])


# --- Textos aprobados y bestiario ---------------------------------------------------------------

func _comprobar_textos() -> void:
	var intro: String = " ".join(Datos.TEXTO_INTRO)
	var cierre: String = " ".join(Datos.TEXTO_CIERRE)
	_registrar("Los textos del capítulo 1 son los aprobados (shōgun Takeda, yōkai, luna roja)",
		intro.contains("shōgun Takeda") and intro.contains("yōkai") and cierre.contains("luna brilla más roja"),
		"intro: %d párrafos; cierre: %d" % [Datos.TEXTO_INTRO.size(), Datos.TEXTO_CIERRE.size()])


func _abrir_galeria_prueba() -> void:
	principal.alternar_pausa()            # la galería se abre desde la pausa
	principal.abrir_galeria()


func _comprobar_galeria_abierta() -> void:
	var galeria = principal.galeria_abierta
	var abierta: bool = galeria != null and not principal.juego.is_inside_tree() and not get_tree().paused
	var paginas: int = galeria.paginas.size() if galeria else 0
	var criaturas := 0
	var piezas := 0
	if galeria:
		for i in galeria.paginas.size():      # la de las siete familias
			if "7 familias" in String(galeria.paginas[i].titulo):
				galeria._mostrar_pagina(i)
		criaturas = galeria.criaturas.size()
		for c in galeria.criaturas:
			piezas += c.piezas
	_registrar("La galería de criaturas se abre desde la pausa y reparte páginas",
		abierta and criaturas >= 7 and paginas >= 4 and piezas > 0,
		"%d páginas; la tercera tiene %d criaturas y %d piezas" % [paginas, criaturas, piezas])
	principal.cerrar_galeria(false)


func _comprobar_galeria_cerrada() -> void:
	var vuelta: bool = principal.galeria_abierta == null and principal.juego.is_inside_tree() and get_tree().paused
	_registrar("Al cerrar la galería se vuelve a la pausa y el juego sigue entero",
		vuelta and _juego().akira.vivo() and principal.hud.visible,
		"en pausa=%s, juego en el árbol=%s" % [get_tree().paused, principal.juego.is_inside_tree()])
	principal.alternar_pausa()            # reanuda


func _leer_bestiario() -> Array:
	var texto := FileAccess.get_file_as_string("res://datos/bestiario.json")
	var datos = JSON.parse_string(texto)
	return datos if datos is Array else []


func _comprobar_bestiario() -> void:
	var datos := _leer_bestiario()
	var familias := ["bipedo", "cuadrupedo", "serpentino", "alado", "acuatico", "flotante", "artropodo"]
	var tamanos := ["S", "M", "L", "XL"]
	var mal := 0
	var propios := 0
	for e in datos:
		if not (e.get("familia") in familias and e.get("tamano") in tamanos and int(e.get("sensibilidad", -1)) in [0, 1, 2]):
			mal += 1
		if e.get("modelado") == "propio":
			propios += 1
	_registrar("El catálogo del bestiario se carga y todos sus datos son válidos",
		datos.size() >= 700 and mal == 0,
		"%d criaturas (%d con modelo propio), %d con datos no válidos" % [datos.size(), propios, mal])


# Construye cada criatura del catálogo (y sus rangos 2 y 3 en una de cada ocho) y mide el
# presupuesto de piezas. Si alguna combinación de familia, tamaño y partes falla, se nota aquí.
func _construir_todo_el_bestiario() -> void:
	var datos := _leer_bestiario()
	var aspecto = Aspecto.new()
	var inicio := Time.get_ticks_msec()
	var construidas := 0
	var construcciones := 0
	var piezas_rango1 := 0
	var maximo_rango1 := 0
	var maximo := 0
	var sin_piezas := 0
	for e in datos:
		if e.get("tipo_entrada") == "no_criatura":
			continue
		var rangos := [1, 2, 3] if construidas % 8 == 0 else [1]
		for rango in rangos:
			var criatura = Criatura.new()
			criatura.configurar(aspecto, {"familia": e.familia, "tamano": e.tamano, "elemento": e.elemento,
				"rol": e.rol, "semilla": int(e.id), "rango": rango})
			criatura.actualizar(0.1)
			if criatura.piezas <= 0:
				sin_piezas += 1
			construcciones += 1
			maximo = maxi(maximo, criatura.piezas)
			if rango == 1:
				piezas_rango1 += criatura.piezas
				maximo_rango1 = maxi(maximo_rango1, criatura.piezas)
			criatura.free()
		construidas += 1
	var media := float(piezas_rango1) / maxf(construidas, 1.0)
	_registrar("Todas las criaturas del catálogo se construyen dentro del presupuesto de piezas",
		construidas >= 700 and sin_piezas == 0 and maximo <= 80,
		"%d criaturas (%d construcciones con los rangos 2 y 3 de 1 de cada 8) en %d ms; rango 1: media %.1f piezas, máximo %d; máximo con rangos: %d" % [
			construidas, construcciones, Time.get_ticks_msec() - inicio, media, maximo_rango1, maximo])


func _comprobar_modelo_detallado() -> void:
	var resultados: Array = []
	var bien := true
	for rango in [1, 2, 3]:
		var criatura = ModeloCriatura.new()
		add_child(criatura)
		criatura.configurar(null, {"familia": "bipedo", "tamano": "M", "elemento": "fuego", "rol": "poderoso",
			"id": 2315, "rango": rango})
		criatura.actualizar(0.1)
		var con_textura := false
		for material in criatura.materiales:
			con_textura = con_textura or material.get_shader_parameter("textura") != null
		# Se mide el cuerpo sin el garrote (va levantado y sobresale por encima de la cabeza)
		var caja := AABB()
		var primera := true
		var con_garrote := false
		for malla in criatura._mallas(criatura.modelo):
			if malla.name == "Garrote":
				con_garrote = true
				continue
			var c: AABB = malla.global_transform * malla.get_aabb()
			caja = c if primera else caja.merge(c)
			primera = false
		var alto_esperado: float = 1.9 * (1.2 if rango == 2 else 1.0)
		bien = bien and con_textura and con_garrote and criatura.triangulos > 1000 and criatura.triangulos <= 40000 \
			and absf(caja.size.y - alto_esperado) < 0.25 and absf(caja.position.y) < 0.15
		resultados.append("rango %d: %d triángulos, %.2f m%s%s" % [rango, criatura.triangulos, caja.size.y,
			"" if con_textura else ", SIN TEXTURA", "" if con_garrote else ", SIN GARROTE"])
		criatura.queue_free()
	# Los demás modelos propios (kappa de SAM 3D, chōchin de SketchUp) se cargan con su textura
	for id in ModeloCriatura.MODELOS:
		if id == 2315:
			continue
		var otra = ModeloCriatura.new()
		add_child(otra)
		otra.configurar(null, {"familia": "bipedo", "tamano": "S", "elemento": "fuego", "id": id, "rango": 1})
		var textura_ok := false
		for material in otra.materiales:
			textura_ok = textura_ok or material.get_shader_parameter("textura") != null
		bien = bien and textura_ok and otra.triangulos > 500 and otra.triangulos <= 50000
		resultados.append("modelo %d: %d triángulos%s" % [id, otra.triangulos, "" if textura_ok else ", SIN TEXTURA"])
		otra.queue_free()
	_registrar("Los modelos detallados se cargan con textura y cel-shading (el Aka-oni, con sus tres rangos)",
		bien, "; ".join(resultados))


# --- Shiro, las monedas y los aspectos de Akira (0.6) ----------------------------------------

func _comprobar_shiro_sigue() -> void:
	var juego = _juego()
	var distancia: float = juego.shiro.global_position.distance_to(juego.akira.global_position)
	_registrar("Shiro sigue a Akira", distancia < 3.5 and juego.shiro.visual.actualizaciones > 0,
		"a %.1f m de Akira tras caminar" % distancia)


func _contar_mallas(nodo: Node) -> int:
	var cuenta := 1 if nodo is MeshInstance3D else 0
	for hijo in nodo.get_children():
		cuenta += _contar_mallas(hijo)
	return cuenta


func _comprobar_apariencias() -> void:
	var aspecto = Aspecto.new()
	var piezas := {}
	var con_cicatriz := 0
	for id in Apariencias.ORDEN:
		var modelo = VisualModelo.new()
		modelo.configurar(aspecto, false, id)
		piezas[id] = _contar_mallas(modelo)
		if modelo.find_child("Cicatriz0", true, false) != null:
			con_cicatriz += 1
		modelo.free()
	var distintas := {}
	for id in piezas:
		distintas[piezas[id]] = true
	# En la pausa se cambia el aspecto en el momento; cuatro cambios devuelven el de antes.
	var antes := Apariencias.elegida
	var cambios_bien := true
	principal.alternar_pausa()
	for i in Apariencias.ORDEN.size():
		principal.cambiar_apariencia()
		cambios_bien = cambios_bien and _juego().akira.visual.apariencia == Apariencias.elegida
	principal.alternar_pausa()
	_registrar("Los cuatro aspectos de Akira llevan la cicatriz y se cambian en la pausa",
		con_cicatriz == 4 and distintas.size() >= 3 and cambios_bien and Apariencias.elegida == antes,
		"piezas: %s" % str(piezas))


func _preparar_shiro() -> void:
	var juego = _juego()
	_proteger(true)
	_teletransportar(Vector3(-18, 0, 10), Vector3.RIGHT)
	juego.camara.distancia = Datos.CAMARA_DISTANCIA_MIN
	juego.shiro.aparecer_junto_a_akira()
	juego.shiro.en_calma = func(): return true      # sin depender de dónde quedaron los soldados
	juego.shiro.forzar_hallazgo()
	monedas_antes = juego.monedas
	soltadas_antes = juego.monedas_suelo.soltadas
	hallazgos_antes = juego.shiro.hallazgos


func _comprobar_hallazgo() -> void:
	var juego = _juego()
	var nuevas: int = juego.monedas_suelo.soltadas - soltadas_antes
	_registrar("Shiro olfatea, escarba y desentierra monedas", juego.shiro.hallazgos > hallazgos_antes
		and nuevas >= Datos.MONEDAS_HALLAZGO.x, "%d monedas desenterradas" % nuevas)
	# Akira va a por ellas
	var centro := Vector3.ZERO
	for moneda in juego.monedas_suelo.monedas:
		centro += moneda.nodo.global_position
	if not juego.monedas_suelo.monedas.is_empty():
		centro /= juego.monedas_suelo.monedas.size()
		_teletransportar(Vector3(centro.x, 0, centro.z), Vector3.RIGHT)


func _comprobar_recogida() -> void:
	var juego = _juego()
	_registrar("Akira recoge las monedas al pasar y el HUD las cuenta", juego.monedas > monedas_antes
		and principal.hud.marcador.monedas == juego.monedas, "%d → %d" % [monedas_antes, juego.monedas])


func _preparar_traer() -> void:
	var juego = _juego()
	_teletransportar(Vector3(-18, 0, 10), Vector3.RIGHT)
	juego.shiro.aparecer_junto_a_akira()
	monedas_antes = juego.monedas
	entregadas_antes = juego.shiro.entregadas
	juego.monedas_suelo.soltar(Vector3(-18, 1.0, 3.5), 3)      # 6,5 m al norte de Akira


func _comprobar_traer() -> void:
	var juego = _juego()
	_registrar("Shiro trae las monedas que Akira deja atrás", juego.shiro.entregadas > entregadas_antes
		and juego.monedas >= monedas_antes + 3, "entregó %d · monedas %d → %d" % [
			juego.shiro.entregadas - entregadas_antes, monedas_antes, juego.monedas])
	juego.shiro.en_calma = juego.en_calma
	juego.camara.distancia = Datos.CAMARA_DISTANCIA


func _empezar_cuenta_anime() -> void:
	_juego().akira.visual.actualizaciones = 0


func _cambiar_a_suave() -> void:
	cuenta_anime = _juego().akira.visual.actualizaciones
	_pulsar("estilo_animacion")
	_juego().akira.visual.actualizaciones = 0


func _comprobar_animacion() -> void:
	var cuenta_suave: int = _juego().akira.visual.actualizaciones
	var suave_activa := not VisualModelo.estilo_anime
	_pulsar("estilo_animacion")       # vuelve a anime
	_registrar("Animación anime: 12 poses por segundo; T cambia a suave (cada paso)",
		cuenta_anime >= 10 and cuenta_anime <= 14 and cuenta_suave >= 50 and suave_activa,
		"anime=%d, suave=%d poses en 1 s" % [cuenta_anime, cuenta_suave])


# FPS reales mientras Akira camina por el patio (sin capturas de por medio). Con
# --fixed-fps cada cuadro avanza el mismo tiempo de juego, así que esto mide cuántos
# cuadros por segundo es capaz de dibujar la máquina.
func _empezar_medida() -> void:
	medida_inicio_us = Time.get_ticks_usec()
	medida_inicio_cuadros = Engine.get_frames_drawn()


func _terminar_medida() -> void:
	var segundos := (Time.get_ticks_usec() - medida_inicio_us) / 1000000.0
	if segundos > 0.0:
		fps_medidos = (Engine.get_frames_drawn() - medida_inicio_cuadros) / segundos


func _terminar() -> void:
	var fallos := resultados.filter(func(r): return not r[1])
	var informe := PackedStringArray()
	informe.append("Prueba automática de RONIN 3D (Godot, cel-shading)")
	for r in resultados:
		informe.append("%s  %s  %s" % ["OK   " if r[1] else "FALLO", r[0], r[2]])
	informe.append("Resultado: %d de %d comprobaciones correctas" % [resultados.size() - fallos.size(), resultados.size()])
	informe.append("FPS al caminar por el patio: %.1f (%s, %s)" % [fps_medidos,
		RenderingServer.get_video_adapter_name(), RenderingServer.get_current_rendering_driver_name()])
	var archivo := FileAccess.open(carpeta.path_join(prefijo + "prueba.txt"), FileAccess.WRITE)
	if archivo:
		archivo.store_string("\n".join(informe) + "\n")
		archivo.close()
	print("\n".join(informe))
	get_tree().quit(0 if fallos.is_empty() else 1)
