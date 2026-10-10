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
const Partida := preload("res://scripts/partida.gd")
const VisualSprite := preload("res://scripts/visual_sprite.gd")
const VisualHoja := preload("res://scripts/visual_hoja.gd")
const Escenarios := preload("res://scripts/escenarios.gd")
const Enemigos := preload("res://scripts/enemigos.gd")
const Proyectil := preload("res://scripts/proyectil.gd")
const ZonaPeligro := preload("res://scripts/zona_peligro.gd")
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
		[14.6, _comprobar_bloqueo_del_jefe],
		[15.6, _comprobar_cierre],
		[15.8, _pulsar.bind("aceptar")],
		[16.3, _capturar.bind("cierre")],
		[16.4, _comprobar_siguiente_escenario],
		[16.5, _pulsar.bind("pausa")],
		[16.9, _comprobar_pausa],
		[17.3, _comprobar_reanudar],
		[17.5, _activar_tactil],
		[17.6, _tocar_centro],
		[17.9, _tocar_centro],
		[18.2, _tocar_centro],
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
		[31.75, _comprobar_sprites],
		[31.8, _preparar_shiro],
		[34.0, _capturar.bind("shiro_escarba")],
		[35.6, _comprobar_hallazgo],
		[36.4, _comprobar_recogida],
		[36.5, _preparar_traer],
		[41.5, _comprobar_traer],
		[41.6, _capturar.bind("monedas")],
		[41.7, _abrir_sastre],
		[41.8, _capturar.bind("sastre")],
		[41.9, _comprobar_sastre],
		[42.0, _preparar_jizo],
		[42.3, _comprobar_jizo],
		[42.5, _capturar.bind("jizo")],
		[42.6, _comprobar_guardado],
		[42.7, _preparar_combo],
		[42.72, _comprobar_reticula_y_depuracion],
	]
	# Cadena de la katana: pulsar atacar cada 0,1 s (las pulsaciones se guardan y encadenan).
	for i in 16:
		pasos.append([42.8 + i * 0.1, _pulsar.bind("atacar")])
	pasos.append_array([
		[44.6, _comprobar_combo],
		[44.7, _preparar_carga],
		[44.8, _enviar_accion.bind("atacar", true)],
		[45.8, _enviar_accion.bind("atacar", false)],
		[46.6, _comprobar_carga],
		[46.7, _preparar_esquiva],
		[46.8, _pulsar.bind("atacar")],
		[47.0, _pulsar.bind("esquivar")],
		[47.12, _comprobar_esquiva],
		[47.6, _pulsar.bind("cambiar_arma")],
		[47.8, _comprobar_cambio_arma],
		[47.9, _preparar_postura],
		[48.0, _pulsar.bind("atacar")],
		[48.4, _pulsar.bind("atacar")],
		[48.6, _pulsar.bind("atacar")],
		[49.7, _comprobar_postura],
		[49.8, _preparar_tras_iai],
		[49.85, _pulsar.bind("atacar")],
		[50.0, _comprobar_tras_iai],
		[50.2, _preparar_kappa],
		[50.3, _enviar_accion.bind("parar", true)],
		[50.4, _despertar_kappa],
		[52.9, _comprobar_reverencia],
		[53.0, _enviar_accion.bind("parar", false)],
		[53.4, _acercarse_al_kappa],
		[53.5, _pulsar.bind("atacar")],
		[54.2, _comprobar_kappa],
		[54.3, _comprobar_oni_y_onibi],
		[54.5, _preparar_jefe],
		[57.6, _comprobar_punetazo],
		[57.7, _romper_postura],
		[58.0, _preparar_embestida],
		[62.6, _comprobar_remate_jefe],
	])
	# Capítulos 2 a 4 (0.16): cada escenario carga con su mundo, sus enemigos y su jefe, y las
	# conductas nuevas del bestiario funcionan.
	pasos.append([62.9, _comprobar_hojas_del_bestiario])
	var t := 63.0
	for n in range(1, Escenarios.cantidad()):
		pasos.append([t, _cargar_escenario.bind(n)])
		pasos.append([t + 0.5, _comprobar_escenario.bind(n)])
		t += 0.9
	pasos.append_array([
		[t, _probar_escudo_y_coraza],
		[t + 0.2, _probar_division_y_copias],
		[t + 0.6, _comprobar_division_y_copias],
		[t + 0.8, _probar_disfraces_y_piedra],
		[t + 1.4, _comprobar_disfraces],
		[t + 1.6, _probar_gashadokuro_y_vampiro],
		[t + 5.6, _comprobar_gashadokuro],
		[t + 5.8, _probar_proyectil_y_zona],
		[t + 7.4, _comprobar_proyectil_y_zona],
		[t + 7.6, _cargar_escenario.bind(6)],
		[t + 8.0, _probar_sellos_de_bahamut],
		[t + 8.4, _cargar_escenario.bind(3)],
		[t + 8.8, _probar_barrera_del_templo],
		[t + 9.2, _comprobar_barrera_del_templo],
		[t + 9.4, _cargar_escenario.bind(8)],
		[t + 9.8, _vencer_jefe_actual],
		[t + 12.8, _comprobar_jefe_siguiente.bind("tamamo")],
		[t + 12.9, _vencer_jefe_actual],
		[t + 15.9, _comprobar_jefe_siguiente.bind("tamamo_zorro")],
		[t + 16.0, _vencer_jefe_actual],
		[t + 20.0, _comprobar_final],
		[t + 20.4, _cargar_escenario.bind(4)],
		[t + 20.8, _terminar_escenario_con_tecnica],
		[t + 21.4, _comprobar_tecnica],
		[t + 21.8, _terminar],
	])


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
	if embestida_activa:
		_paso_embestida()
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
	# Los yōkai y el jefe se quedan quietos siempre: sus propias pruebas los despiertan.
	for soldado in _juego().soldados_vivos():
		var es_soldado: bool = soldado is Soldado
		soldado.process_mode = Node.PROCESS_MODE_DISABLED if activo or not es_soldado else Node.PROCESS_MODE_INHERIT


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


# Con el oni vivo, el portón no deja salir. Su combate tiene sus propias pruebas: aquí
# se le da por vencido para seguir con el cierre.
func _comprobar_bloqueo_del_jefe() -> void:
	var juego = _juego()
	_registrar("El oni bloquea el portón mientras vive", juego.fase == "jugando"
		and juego.akira.global_position.x > Datos.LIMITE_PORTON_X - 1.0,
		"fase=%s, x=%.1f" % [juego.fase, juego.akira.global_position.x])
	juego.jefe.process_mode = Node.PROCESS_MODE_INHERIT     # que haga su caída
	juego.jefe._morir()


# Desde la 0.16, el cierre del castillo lleva a la planicie. La prueba vuelve al castillo (con su
# historia) para seguir con lo de siempre.
func _comprobar_siguiente_escenario() -> void:
	principal.hud.completar_texto()
	principal.aceptar()
	_registrar("Tras el cierre del castillo se sigue en la planicie", _juego().indice_escenario == 1
		and _juego().fase == "intro" and Partida.alcanzado >= 1,
		"escenario=%d, fase=%s" % [_juego().indice_escenario, _juego().fase])
	principal._iniciar_juego(true, 0)


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


# Las posiciones de la prueba son de la pantalla del juego (720×1280); los toques llegan en
# píxeles de la ventana, que en el escritorio es más pequeña.
func _a_ventana(posicion: Vector2) -> Vector2:
	return get_viewport().get_final_transform() * posicion


func _evento_toque(posicion: Vector2, pulsado: bool) -> void:
	var toque := InputEventScreenTouch.new()
	toque.index = 0
	toque.position = _a_ventana(posicion)
	toque.pressed = pulsado
	Input.parse_input_event(toque)


func _tocar(posicion: Vector2) -> void:
	_evento_toque(posicion, true)
	_evento_toque(posicion, false)


func _tocar_centro() -> void:
	_tocar(get_viewport().get_visible_rect().size / 2.0)


func _comprobar_toques() -> void:
	# Tres toques: salir del cierre, completar el texto de la intro y empezar.
	_registrar("Tocar la pantalla sigue los textos", _juego().fase == "jugando", "fase=" + _juego().fase)
	_proteger(true)


func _empezar_joystick() -> void:
	posicion_guardada = _juego().akira.global_position
	_evento_toque(Vector2(200, 520), true)
	var arrastre := InputEventScreenDrag.new()
	arrastre.index = 0
	arrastre.position = _a_ventana(Vector2(300, 520))
	arrastre.relative = _a_ventana(Vector2(300, 520)) - _a_ventana(Vector2(200, 520))
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
	_registrar("Los textos del capítulo 1 son los aprobados (shōgun Takeda, yōkai, cicatriz, Shiro, luna roja)",
		intro.contains("shōgun Takeda") and intro.contains("yōkai") and intro.contains("le cruzó la cara")
		and intro.contains("Solo Shiro") and cierre.contains("con Shiro a su lado") and cierre.contains("luna brilla más roja"),
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


# Triángulos de todas las mallas: cada aspecto tiene su peinado (y el veterano, barba), así que
# salen distintos. (Contar piezas ya no sirve: el pelo se une en una sola malla.)
func _contar_triangulos(nodo: Node) -> int:
	var cuenta := 0
	if nodo is MeshInstance3D and nodo.mesh != null:
		cuenta = nodo.mesh.get_faces().size() / 3
	for hijo in nodo.get_children():
		cuenta += _contar_triangulos(hijo)
	return cuenta


func _comprobar_apariencias() -> void:
	var aspecto = Aspecto.new()
	var triangulos := {}
	var con_cicatriz := 0
	for id in Apariencias.ORDEN:
		var modelo = VisualModelo.new()
		modelo.configurar(aspecto, false, id)
		triangulos[id] = _contar_triangulos(modelo)
		if modelo.find_child("Cicatriz0", true, false) != null:
			con_cicatriz += 1
		modelo.free()
	var distintas := {}
	for id in triangulos:
		distintas[triangulos[id]] = true
	# En la pausa se cambia el aspecto en el momento; cuatro cambios devuelven el de antes.
	var antes := Apariencias.elegida
	var cambios_bien := true
	principal.alternar_pausa()
	for i in Apariencias.ORDEN.size():
		principal.cambiar_apariencia()
		cambios_bien = cambios_bien and _juego().akira.visual.apariencia == Apariencias.mostrada
	principal.alternar_pausa()
	_registrar("Los cuatro aspectos de Akira llevan la cicatriz y el sastre los enseña en la pausa",
		con_cicatriz == 4 and distintas.size() == 4 and cambios_bien and Apariencias.elegida == antes,
		"triángulos: %s" % str(triangulos))


# Pixel art (DECISIÓN 20E): las seis hojas cargan con todas sus poses y caben en una textura de
# móvil (2048 como mucho); en el juego, Akira, los soldados y Shiro son sprites, y si la cámara da
# media vuelta alrededor de Akira, lo ve desde el otro lado.
func _comprobar_sprites() -> void:
	var necesarias := {
		"akira": ["normal", "andar", "correr", "salto", "muerte", "ataque", "postura", "desenvaine", "remate",
			"kesa", "gyaku", "giro", "tsuki", "barrido", "barrido_giro", "esquiva"],
		"soldado": ["normal", "andar", "correr", "salto", "muerte", "preparando", "estocada"],
		"shiro": ["quieto", "sentado", "andar", "correr", "olfatear", "escarbar", "alerta", "salto"],
	}
	var hojas_bien := 0
	for id in ["akira_joven", "akira_curtido", "akira_veterano", "akira_mujer", "soldado", "shiro"]:
		var datos = JSON.parse_string(FileAccess.get_file_as_string("res://recursos/sprites/%s.json" % id))
		var textura: Texture2D = load("res://recursos/sprites/%s.png" % id)
		var tipo: String = "akira" if id.begins_with("akira") else id
		var bien: bool = datos is Dictionary and textura != null and int(datos.direcciones) == 8 \
			and textura.get_width() <= 2048 and textura.get_height() <= 2048
		if bien:
			for nombre in necesarias[tipo]:
				bien = bien and datos.animaciones.has(nombre)
		hojas_bien += 1 if bien else 0
	var juego = _juego()
	# Los enemigos van en el estilo del oni del usuario: hojas de perfil (visual_hoja.gd).
	var son_sprites: bool = juego.akira.visual is VisualSprite and juego.shiro.visual is VisualSprite \
		and juego.soldados.all(func(e): return not is_instance_valid(e) or not (e is Soldado or e is Yokai) \
			or e.visual is VisualHoja)
	var hojas_enemigos := 0
	for id in ["soldado_hoja", "kappa_hoja", "onibi_hoja", "oni_jefe"]:
		var hoja = JSON.parse_string(FileAccess.get_file_as_string("res://recursos/sprites/%s.json" % id))
		var completa: bool = hoja is Dictionary and load("res://recursos/sprites/%s.png" % id) != null
		if completa:
			for nombre in ["reposo", "caminar", "ataque", "golpe", "muerte"]:
				completa = completa and hoja.animaciones.has(nombre) and int(hoja.animaciones[nombre].cuadros) >= 2
		hojas_enemigos += 1 if completa else 0
	var antes: int = juego.akira.visual._direccion()
	juego.camara.giro += 180.0
	juego.camara.colocar_de_golpe()
	var despues: int = juego.akira.visual._direccion()
	juego.camara.giro -= 180.0
	juego.camara.colocar_de_golpe()
	_registrar("Personajes en pixel art: Akira y Shiro en 8 direcciones; los enemigos, en hojas del estilo del oni",
		hojas_bien == 6 and hojas_enemigos == 4 and son_sprites and posmod(despues - antes, 8) == 4,
		"hojas bien: %d de 6 · hojas de enemigos: %d de 4 · dirección %d → %d al girar la cámara 180°" % [hojas_bien,
		hojas_enemigos, antes, despues])


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


# Sastre (DECISIÓN 16C): las skins empiezan bloqueadas y se compran con monedas en la pausa; lo
# que no se compra no se queda puesto al salir.
func _abrir_sastre() -> void:
	Partida.monedas = 100
	principal.alternar_pausa()
	principal.cambiar_apariencia()                     # curtido, aún bloqueada


func _comprobar_sastre() -> void:
	var bloqueada: bool = Apariencias.mostrada == "curtido" and Apariencias.mostrada_bloqueada() \
		and Apariencias.elegida == "joven" and principal.hud.boton_comprar.visible
	principal.comprar_apariencia()
	var comprada: bool = Partida.tiene("curtido") and Apariencias.elegida == "curtido" \
		and Partida.monedas == 100 - Partida.precio("curtido") and principal.hud.marcador.monedas == Partida.monedas
	principal.cambiar_apariencia()                     # veterano: se ve, pero no se compra
	var viendo_otra: bool = _juego().akira.visual.apariencia == "veterano"
	principal.alternar_pausa()                         # al salir, vuelve la comprada
	var vuelve: bool = _juego().akira.visual.apariencia == "curtido" and Apariencias.mostrada == "curtido"
	_registrar("Las skins están bloqueadas y se compran al sastre con monedas",
		bloqueada and comprada and viendo_otra and vuelve,
		"bloqueada=%s, comprada=%s (quedan %d mon), al salir=%s" % [bloqueada, comprada, Partida.monedas, vuelve])


func _preparar_jizo() -> void:
	_proteger(true)
	_teletransportar(Datos.JIZO_POSICION + Vector3(1.2, 0, 0.3), Vector3.LEFT)
	Partida.monedas = maxi(Partida.monedas, 50)
	monedas_antes = Partida.monedas


# Jizō (DECISIÓN 16A): junto a él sale el aviso; rezar cuesta monedas y da +1 de vida máxima.
func _comprobar_jizo() -> void:
	var juego = _juego()
	var aviso_visto: bool = juego.cerca_del_jizo and principal.hud.aviso_interaccion.visible
	var precio := Partida.precio_bendicion()
	juego.interactuar()
	var akira = juego.akira
	var bien: bool = aviso_visto and precio == Partida.PRECIOS_BENDICION[0] \
		and akira.vida_maxima == Datos.VIDA_MAXIMA + 1 and akira.vida == akira.vida_maxima \
		and Partida.monedas == monedas_antes - precio and principal.hud.marcador.maximo == akira.vida_maxima
	_registrar("El jizō da +1 de vida máxima a cambio de monedas", bien,
		"aviso=%s, vida máxima %d, monedas %d → %d" % [aviso_visto, akira.vida_maxima, monedas_antes, Partida.monedas])


# La partida (monedas, skins y bendiciones) se guarda y se vuelve a cargar igual.
func _comprobar_guardado() -> void:
	var ruta := "user://prueba_partida.cfg"
	var antes := [Partida.monedas, Partida.compradas.duplicate(), Partida.bendiciones]
	Partida.guardar(ruta)
	Partida.reiniciar()
	Partida.cargar(ruta)
	var despues := [Partida.monedas, Partida.compradas.duplicate(), Partida.bendiciones]
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta))
	_registrar("La partida se guarda y se carga (monedas, skins y bendiciones)", antes == despues,
		"%s → %s" % [str(antes), str(despues)])


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


# --- Combate al estilo de EthrA: combos, carga, esquiva, armas y postura -------------------

const Soldado := preload("res://scripts/soldado.gd")
const Armas := preload("res://scripts/armas.gd")
var muneco = null
var pasos_vistos: Array = []
var cargados_vistos := 0
var numeros_antes := 0


# Un soldado quieto (sin pensar) delante de Akira, para golpearlo.
func _crear_muneco(vida: int) -> void:
	var juego = _juego()
	var akira = juego.akira
	_proteger(true)
	var lugar: Vector3 = Datos.INICIO_AKIRA + Vector3(3.0, 0.0, 0.0)
	muneco = Soldado.new()
	juego.add_child(muneco)
	muneco.configurar(lugar, lugar + Vector3(0.1, 0, 0), akira)
	muneco.visual = juego._crear_visual(true)
	muneco.add_child(muneco.visual)
	muneco.global_position = lugar
	muneco.vida = vida
	muneco.process_mode = Node.PROCESS_MODE_DISABLED
	juego.soldados.append(muneco)
	_teletransportar(lugar - Vector3(1.3, 0, 0), Vector3.RIGHT)
	akira.aguante = Armas.AGUANTE_MAXIMO


func _preparar_combo() -> void:
	var akira = _juego().akira
	akira.cambiar_arma("katana")
	akira.ataco.connect(func():
		pasos_vistos.append(akira.paso_combo)
		if akira.ataque.get("cargado", false):
			cargados_vistos += 1)
	numeros_antes = _juego().efectos.numeros_creados
	_crear_muneco(Datos.VIDA_SOLDADO)
	pasos_vistos.clear()


func _comprobar_reticula_y_depuracion() -> void:
	var juego = _juego()
	juego.depuracion.activa = true
	await get_tree().process_frame
	await get_tree().process_frame
	_capturar("depuracion")
	_registrar("La retícula fija al enemigo más cercano y F3 dibuja conos y zonas de golpe",
		juego.reticula.visible and juego.objetivo_fijado == muneco and juego.depuracion.malla.get_surface_count() > 0,
		"retícula=%s, fijado=%s, superficies=%d" % [juego.reticula.visible, juego.objetivo_fijado == muneco,
		juego.depuracion.malla.get_surface_count()])
	juego.depuracion.alternar()
	# «Fijar» salta al siguiente enemigo cercano y vuelve.
	var otro = Soldado.new()
	juego.add_child(otro)
	otro.configurar(muneco.global_position + Vector3(0, 0, 2.0), muneco.global_position + Vector3(0.1, 0, 2.0), juego.akira)
	otro.visual = juego._crear_visual(true)
	otro.add_child(otro.visual)
	otro.process_mode = Node.PROCESS_MODE_DISABLED
	juego.soldados.append(otro)
	juego.objetivo_fijado = muneco
	juego.cambiar_objetivo()
	var salto: bool = juego.objetivo_fijado != muneco and juego.objetivo_fijado != null
	juego.cambiar_objetivo()
	juego.cambiar_objetivo()
	_registrar("«Fijar» cambia de objetivo entre los enemigos cercanos", salto, "cambió=%s" % salto)
	juego.objetivo_fijado = muneco
	otro.recibir_golpe(Vector3.ZERO, true)


func _comprobar_combo() -> void:
	var cadena: bool = pasos_vistos.slice(0, 4) == [0, 1, 2, 3]
	var derribado: bool = not muneco.vivo()
	var numeros: int = _juego().efectos.numeros_creados - numeros_antes
	_registrar("La katana encadena 4 cortes de iai y derriba al soldado (4 de vida)", cadena and derribado,
		"pasos=%s, derribado=%s" % [str(pasos_vistos), derribado])
	_registrar("Cada impacto muestra su número de daño", numeros >= 4, "%d números" % numeros)


func _preparar_carga() -> void:
	cargados_vistos = 0
	_crear_muneco(Datos.VIDA_SOLDADO)


func _comprobar_carga() -> void:
	_registrar("Mantener atacar suelta el corte cargado (iai de luna creciente, 360°)",
		cargados_vistos == 1 and muneco.vida < Datos.VIDA_SOLDADO,
		"cargados=%d, vida del soldado %d → %d" % [cargados_vistos, Datos.VIDA_SOLDADO, muneco.vida])


func _preparar_esquiva() -> void:
	_crear_muneco(99)


func _comprobar_esquiva() -> void:
	var akira = _juego().akira
	_registrar("La esquiva cancela el corte, gasta aguante y da invulnerabilidad",
		akira.esquivando() and not akira.atacando() and akira.invulnerable_por_esquiva()
		and akira.aguante < Armas.AGUANTE_MAXIMO,
		"esquivando=%s, atacando=%s, invulnerable=%s, aguante=%.0f" % [akira.esquivando(),
		akira.atacando(), akira.invulnerable_por_esquiva(), akira.aguante])


func _comprobar_cambio_arma() -> void:
	var akira = _juego().akira
	_registrar("«Arma» cambia de katana a yari, con su propia cadena", akira.arma == "yari"
		and akira.datos_arma().combo.size() == 3 and principal.hud.marcador.arma == "Yari",
		"arma=%s, cortes=%d, HUD=%s" % [akira.arma, akira.datos_arma().combo.size(), principal.hud.marcador.arma])


func _preparar_postura() -> void:
	_juego().akira.cambiar_arma("nodachi")
	_crear_muneco(99)


func _comprobar_postura() -> void:
	var nodachi: Dictionary = Armas.datos("nodachi").combo[0]
	var katana: Dictionary = Armas.datos("katana").combo[0]
	_registrar("El nodachi es lento y rompe la postura en dos barridos",
		muneco.postura_rota() and nodachi.anticipacion > katana.anticipacion * 4.0,
		"postura rota=%s, preparación %.2f s frente a %.2f s" % [muneco.postura_rota(),
		nodachi.anticipacion, katana.anticipacion])


func _preparar_tras_iai() -> void:
	var akira = _juego().akira
	akira.cambiar_arma("katana")
	akira.enfriamiento = 0.0
	akira.tras_iai = Armas.VENTANA_TRAS_IAI


func _comprobar_tras_iai() -> void:
	var akira = _juego().akira
	_registrar("Tras un iai perfecto, atacar sigue la cadena desde el 2.º corte", akira.paso_combo == 1,
		"paso=%d" % akira.paso_combo)
	# Ataque a la carrera: atacar mientras corre da el corte de carrera del arma.
	akira.ataque = {}
	akira.enfriamiento = 0.0
	akira.corriendo = true
	akira.buffer_ataque = 0.25
	akira._resolver_buffer()
	var nombre: String = akira.ataque.get("nombre", "")
	_registrar("Atacar corriendo da el ataque a la carrera del arma", nombre == "Iai a la carrera",
		"corte=%s" % nombre)
	akira.ataque = {}
	_proteger(true)


# --- Yōkai del bestiario y el oni del portón --------------------------------------------------

const Yokai := preload("res://scripts/yokai.gd")
const JefeOni := preload("res://scripts/jefe_oni.gd")
var kappa = null
var jefe_prueba = null
var vida_antes_jefe := 0
var embestida_activa := false
var embestida_pulsada := false
var embestida_soltada := false


# Un yōkai nuevo y quieto en un sitio despejado del patio (los de la oleada pueden haber
# caído en las pruebas anteriores: el corte de luna también los alcanza).
func _yokai(tipo: String, lugar := Vector3(0, 0, 0)):
	var yokai = _juego().crear_yokai(tipo, lugar)
	yokai.process_mode = Node.PROCESS_MODE_DISABLED
	return yokai


func _preparar_kappa() -> void:
	var akira = _juego().akira
	_proteger(true)
	kappa = _yokai("kappa", Vector3(2.6, 0, 0))
	akira.invulnerable = 0.0
	akira.vida = akira.vida_maxima
	akira.enfriamiento_parada = 0.0
	_teletransportar(Vector3(0, 0, 0), Vector3.RIGHT)


func _despertar_kappa() -> void:
	kappa.estado = Yokai.Estado.ALERTA
	kappa.process_mode = Node.PROCESS_MODE_INHERIT


func _comprobar_reverencia() -> void:
	var akira = _juego().akira
	_capturar("kappa_reverencia")
	_registrar("El kappa, esperado en postura de iai 2 s, hace la reverencia y derrama el agua",
		kappa.sin_agua and akira.vida == akira.vida_maxima,
		"sin agua=%s, vida de Akira=%d" % [kappa.sin_agua, akira.vida])


func _acercarse_al_kappa() -> void:
	var hacia: Vector3 = kappa.global_position - _juego().akira.global_position
	hacia.y = 0.0
	_teletransportar(kappa.global_position - hacia.normalized() * 1.2, hacia)


func _comprobar_kappa() -> void:
	_registrar("Sin agua, el kappa cae de un golpe", not kappa.vivo(), "vivo=%s" % kappa.vivo())
	_proteger(true)


func _comprobar_oni_y_onibi() -> void:
	var akira = _juego().akira
	var oni = _yokai("oni", akira.global_position + Vector3(2.0, 0, 2.0))
	oni.process_mode = Node.PROCESS_MODE_INHERIT
	var murio: bool = oni.recibir_iai(akira.global_position)
	var kanabo: Dictionary = oni.perfil.ataques[1]
	_registrar("El oni aguanta el iai (3 menos y aturdido 1,5 s) y su kanabō («!!») no se para",
		not murio and oni.vida == 3 and oni.estado == Yokai.Estado.ATURDIDO and not kanabo.parable and kanabo.rojo,
		"vida 6 → %d, aturdido=%s, kanabō parable=%s" % [oni.vida, oni.estado == Yokai.Estado.ATURDIDO, kanabo.parable])
	oni.process_mode = Node.PROCESS_MODE_DISABLED
	var onibi = _yokai("onibi", akira.global_position + Vector3(-2.0, 0, 2.0))
	var antes: float = akira.espiritu
	akira.espiritu = minf(antes, 0.5)
	antes = akira.espiritu
	onibi.recibir_golpe(akira.global_position, false, 1)
	_registrar("Cada onibi cae de un golpe y llena el espíritu", not onibi.vivo() and akira.espiritu >= antes + 0.19,
		"espíritu %.2f → %.2f" % [antes, akira.espiritu])


# Un oni nuevo (el del portón se dio por vencido antes): Akira, quieto a 7 m, recibe el golpe de
# área donde marca la sombra (el oni salta hasta ella).
func _preparar_jefe() -> void:
	var juego = _juego()
	var akira = juego.akira
	jefe_prueba = JefeOni.new()
	jefe_prueba.configurar(Datos.JEFE_POSICION, akira, juego.aspecto)
	juego.add_child(jefe_prueba)
	juego.soldados.append(jefe_prueba)
	juego.jefe = jefe_prueba
	jefe_prueba.vida_cambiada.connect(func(f): principal.hud.poner_jefe("Oni", f))
	principal.hud.poner_jefe("Oni", 1.0)
	akira.invulnerable = 0.0
	akira.vida = akira.vida_maxima
	principal.hud.poner_vida(akira.vida)
	vida_antes_jefe = akira.vida
	juego.camara.distancia = 13.0
	_teletransportar(Datos.JEFE_POSICION + Vector3(-7.0, 0, 0), Vector3.RIGHT)
	_grabar("jefe", 70)


func _comprobar_punetazo() -> void:
	var akira = _juego().akira
	_capturar("jefe_oni")
	_registrar("El oni despierta, salta y su golpe de área cae donde marca la sombra",
		jefe_prueba.despierto() and akira.vida < vida_antes_jefe and jefe_prueba.paso == JefeOni.Paso.EN_SUELO,
		"despierto=%s, vida de Akira %d → %d" % [jefe_prueba.despierto(), vida_antes_jefe, akira.vida])
	akira.invulnerable = 999.0


# Tras cada golpe de área queda agachado: 3 cortes le rompen la postura; a la segunda, furia.
func _romper_postura() -> void:
	for vez in JefeOni.ROTURAS_PARA_FURIA:
		jefe_prueba.paso = JefeOni.Paso.EN_SUELO
		for i in JefeOni.CORTES_POR_POSTURA:
			jefe_prueba.recibir_golpe_en("cuerpo", Vector3.ZERO)
	_registrar("Tres cortes con el kanabō clavado rompen la postura; a la segunda rotura, furia",
		jefe_prueba.roturas == 2 and jefe_prueba.fase == JefeOni.Fase.FURIA,
		"roturas=%d, furia=%s" % [jefe_prueba.roturas, jefe_prueba.fase == JefeOni.Fase.FURIA])


func _preparar_embestida() -> void:
	var akira = _juego().akira
	akira.invulnerable = 0.0
	akira.vida = akira.vida_maxima
	akira.enfriamiento_parada = 0.0
	vida_antes_jefe = akira.vida
	_teletransportar(jefe_prueba.global_position + Vector3(-2.4, 0, 0), Vector3.RIGHT)
	embestida_activa = true


# Postura al ver el «!»; desenvaine justo antes de que caiga el barrido.
func _paso_embestida() -> void:
	if not is_instance_valid(jefe_prueba) or not jefe_prueba.vivo():
		return
	if not embestida_pulsada and jefe_prueba.paso == JefeOni.Paso.AVISO_GOLPE:
		_enviar_accion("parar", true)
		embestida_pulsada = true
	if embestida_pulsada and not embestida_soltada and jefe_prueba.paso == JefeOni.Paso.AVISO_GOLPE \
			and jefe_prueba.temporizador <= 0.12:
		_enviar_accion("parar", false)
		embestida_soltada = true


func _comprobar_remate_jefe() -> void:
	embestida_activa = false
	var akira = _juego().akira
	_capturar("jefe_remate")
	_registrar("En furia, un iai perfecto contra su barrido de kanabō lo remata",
		not jefe_prueba.vivo() and akira.vida == vida_antes_jefe,
		"vivo=%s, vida de Akira %d → %d" % [jefe_prueba.vivo(), vida_antes_jefe, akira.vida])
	_proteger(true)


# --- Capítulos 2 a 4 (0.16) ---------------------------------------------------------------------

var prueba_a = null
var prueba_b = null
var prueba_c = null
var cuenta_antes := 0
var vida_prueba := 0


func _cargar_escenario(n: int) -> void:
	_soltar_movimiento()
	direccion_caminar = Vector3.ZERO
	combate_activo = false
	principal._iniciar_juego(false, n)


# Todos los enemigos quietos salvo los de la prueba, y Akira a salvo.
func _quietos(salvo: Array = []) -> void:
	var juego = _juego()
	juego.akira.invulnerable = 999.0
	for enemigo in juego.soldados:
		if is_instance_valid(enemigo) and not enemigo in salvo:
			enemigo.process_mode = Node.PROCESS_MODE_DISABLED


func _comprobar_escenario(n: int) -> void:
	var juego = _juego()
	var datos: Dictionary = Escenarios.datos(n)
	var esperados: int = datos.patrullas.size() + datos.yokai.size() + datos.get("objetivos", []).size()
	var con_hoja := true
	for enemigo in juego.soldados:
		if enemigo.has_method("es_jefe") and enemigo.perfil.has("hoja") and not enemigo.perfil.get("visual_akira", false) \
				and not enemigo.visual is VisualHoja:
			con_hoja = false
	var jefe_bien: bool = juego.jefe != null and is_instance_valid(juego.jefe) \
		and (not juego.jefe.has_method("es_jefe") or juego.jefe.perfil.nombre != "")
	_registrar("Escenario %d (%s): mundo, %d enemigos y jefe" % [n, datos.id, esperados],
		juego.indice_escenario == n and juego.soldados.size() >= esperados and jefe_bien and con_hoja
		and juego.akira.global_position.distance_to(datos.inicio) < 1.5,
		"enemigos=%d, jefe=%s, hojas=%s" % [juego.soldados.size(),
			juego.jefe.perfil.nombre if juego.jefe and juego.jefe.has_method("es_jefe") else "oni", con_hoja])
	_quietos()
	_capturar("escenario_%s" % datos.id)


# Cada criatura de enemigos.gd tiene su hoja con las filas que usa visual_hoja.gd.
func _comprobar_hojas_del_bestiario() -> void:
	var malas: Array = []
	for tipo in Enemigos.TIPOS:
		var perfil: Dictionary = Enemigos.perfil(tipo)
		if perfil.is_empty():
			malas.append(tipo + " (sin ficha)")
			continue
		if not perfil.has("hoja"):
			continue
		var hoja = JSON.parse_string(FileAccess.get_file_as_string("res://recursos/sprites/%s.json" % perfil.hoja))
		var bien: bool = hoja is Dictionary and load("res://recursos/sprites/%s.png" % perfil.hoja) != null
		if bien:
			for nombre in ["reposo", "caminar", "ataque", "golpe", "muerte"]:
				bien = bien and hoja.animaciones.has(nombre)
			for ataque in perfil.ataques:
				bien = bien and hoja.animaciones.has(String(ataque.get("anim", "ataque")))
		if not bien:
			malas.append(tipo)
	_registrar("Las %d criaturas del bestiario tienen ficha y hoja de sprites" % Enemigos.TIPOS.size(),
		malas.is_empty(), "mal: %s" % ", ".join(malas))


func _nuevo(tipo: String, lugar: Vector3):
	var enemigo = _juego().crear_yokai(tipo, lugar)
	return enemigo


func _probar_escudo_y_coraza() -> void:
	var akira = _juego().akira
	_teletransportar(Vector3(0, 0, 0), Vector3.RIGHT)
	# Komainu despierto mirando a Akira: de frente rebota, por la espalda entra.
	var komainu = _nuevo("komainu", Vector3(2, 0, 0))
	komainu._despertar()
	komainu.mirando = Vector3.LEFT
	var vida: int = komainu.vida
	komainu.recibir_golpe(akira.global_position, false, 1, 0.0)
	var de_frente: bool = komainu.vida == vida and komainu.consumir_bloqueo()
	komainu.recibir_golpe(komainu.global_position + Vector3.RIGHT * 2.0, false, 1, 0.0)
	var por_detras: bool = komainu.vida == vida - 1
	_registrar("Komainu: de frente el golpe rebota y por la espalda entra", de_frente and por_detras,
		"vida %d → %d" % [vida, komainu.vida])
	# Gólem: coraza; tras un iai (postura rota) ya le entra la espada.
	var golem = _nuevo("golem", Vector3(0, 0, 4))
	var vida_golem: int = golem.vida
	golem.recibir_golpe(akira.global_position, false, 1, 0.0)
	var rebota: bool = golem.vida == vida_golem
	golem.recibir_iai(akira.global_position)
	var tras_iai: int = golem.vida
	golem.recibir_golpe(akira.global_position, false, 1, 0.0)
	_registrar("Gólem: la coraza para la espada hasta que un iai le rompe la guardia",
		rebota and tras_iai < vida_golem and golem.vida < tras_iai,
		"vida %d → %d → %d" % [vida_golem, tras_iai, golem.vida])
	_quietos()


func _probar_division_y_copias() -> void:
	var juego = _juego()
	cuenta_antes = juego.soldados.size()
	prueba_a = _nuevo("slime", Vector3(-4, 0, 6))
	prueba_a.recibir_golpe(prueba_a.global_position + Vector3.LEFT, true)
	prueba_b = _nuevo("kitsune", Vector3(-4, 0, -6))
	prueba_b._despertar()


func _comprobar_division_y_copias() -> void:
	var juego = _juego()
	var pequenos: int = juego.soldados.filter(func(e): return is_instance_valid(e) and e.has_method("es_jefe") and e.tipo == "slime_pequeno").size()
	var copias: Array = juego.soldados.filter(func(e): return is_instance_valid(e) and e.has_method("es_jefe") and e.tipo == "kitsune_ilusion")
	_registrar("El limo se divide en dos al morir", pequenos >= 2, "pequeños=%d" % pequenos)
	var copia_sin_dano := false
	if not copias.is_empty():
		var copia = copias[0]
		var akira = juego.akira
		akira.invulnerable = 0.0
		var vida: int = akira.vida
		copia.ataque = copia.perfil.ataques[0]
		copia.mirando = (akira.global_position - copia.global_position).normalized()
		copia.global_position = akira.global_position - copia.mirando * 1.0
		copia._intentar_golpe()
		copia_sin_dano = akira.vida == vida and not copia.vivo()
		akira.invulnerable = 999.0
	_registrar("La kitsune crea dos copias que no hacen daño ni dan sombra", copias.size() == 2 and copia_sin_dano
		and copias[0].visual.sprite.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,
		"copias=%d, sin daño=%s" % [copias.size(), copia_sin_dano])
	_quietos()


func _probar_disfraces_y_piedra() -> void:
	var juego = _juego()
	var akira = juego.akira
	_teletransportar(Vector3(-10, 0, 0), Vector3.RIGHT)
	prueba_a = _nuevo("tanuki", Vector3(-8, 0, 0))
	prueba_b = _nuevo("komainu", Vector3(-10, 0, 4.5))
	prueba_c = _nuevo("gargola", Vector3(-6, 0, 0))
	_quietos([prueba_a, prueba_b, prueba_c])
	var dormido: bool = prueba_a.estado == prueba_a.Estado.DORMIDO and prueba_a.disfraz.visible
	# El komainu no despierta si Akira camina; corriendo, sí.
	akira.corriendo = false
	var caminando: bool = prueba_b._debe_despertar(prueba_b._hacia_objetivo())
	akira.corriendo = true
	var corriendo: bool = prueba_b._debe_despertar(prueba_b._hacia_objetivo())
	akira.corriendo = false
	_registrar("Komainu: duerme si se camina con respeto y despierta si se corre cerca", not caminando and corriendo)
	_registrar("El tanuki empieza disfrazado de jizō", dormido)


func _comprobar_disfraces() -> void:
	_registrar("El tanuki se descubre al acercarse Akira", prueba_a.estado != prueba_a.Estado.DORMIDO
		and not prueba_a.disfraz.visible, "estado=%d" % prueba_a.estado)
	var akira = _juego().akira
	akira.mirando = Vector3.RIGHT
	var vida: int = prueba_c.vida
	prueba_c.estado = prueba_c.Estado.ALERTA
	await get_tree().physics_frame
	await get_tree().physics_frame
	prueba_c.recibir_golpe(akira.global_position, false, 1, 0.0)
	_registrar("La gárgola es de piedra mientras Akira la mira", prueba_c.en_piedra and prueba_c.vida == vida,
		"piedra=%s, vida %d → %d" % [prueba_c.en_piedra, vida, prueba_c.vida])
	_quietos()


func _probar_gashadokuro_y_vampiro() -> void:
	var juego = _juego()
	prueba_a = _nuevo("gashadokuro", Vector3(10, 0, 8))
	prueba_a.vida = 1
	prueba_a.recibir_golpe(prueba_a.global_position + Vector3.LEFT, false, 2)
	_registrar("El gashadokuro se desarma al caer la primera vez", prueba_a.vivo()
		and prueba_a.estado == prueba_a.Estado.DESARMADO, "estado=%d" % prueba_a.estado)
	prueba_b = _nuevo("vampiro", Vector3(10, 0, -8))
	prueba_b._despertar()
	prueba_b.recibir_golpe(prueba_b.global_position + Vector3.LEFT, false, 1)
	prueba_b.recibir_golpe(prueba_b.global_position + Vector3.LEFT, false, 1)
	_registrar("El vampiro se vuelve niebla cada dos golpes", prueba_b.estado == prueba_b.Estado.NIEBLA,
		"estado=%d" % prueba_b.estado)
	_quietos([prueba_a])


func _comprobar_gashadokuro() -> void:
	_registrar("El gashadokuro se vuelve a montar si no se rompen sus huesos", prueba_a.vivo()
		and prueba_a.estado != prueba_a.Estado.DESARMADO and prueba_a.vida > 0, "vida=%d" % prueba_a.vida)
	_quietos()


func _probar_proyectil_y_zona() -> void:
	var juego = _juego()
	var akira = juego.akira
	_teletransportar(Vector3(0, 0, 0), Vector3.RIGHT)
	akira.invulnerable = 0.0
	vida_prueba = akira.vida
	prueba_a = _nuevo("elfo_oscuro", Vector3(8, 0, 0))
	prueba_a.process_mode = Node.PROCESS_MODE_DISABLED
	# Una tela que da a Akira: le quita vida y lo atrapa.
	var tela = Proyectil.new()
	juego.add_child(tela)
	tela.lanzar(Vector3(3, 1, 0), akira.global_position + Vector3.UP, {"danio": 1, "parable": true,
		"efecto": "atrapa", "visual": "tela", "rapidez": 12.0}, prueba_a, akira, juego.efectos)
	# Una flecha devuelta con el iai: vuelve contra el elfo.
	var flecha = Proyectil.new()
	juego.add_child(flecha)
	flecha.lanzar(Vector3(6, 1, 0), Vector3(20, 1, 0), {"danio": 1, "parable": true, "rapidez": 15.0}, prueba_a, akira, juego.efectos)
	flecha.recibir_iai(akira.global_position)
	cuenta_antes = prueba_a.vida
	# Una zona roja lejos de Akira no le hace nada.
	var zona = ZonaPeligro.new()
	zona.configurar({"radio": 1.5, "aviso": 0.3, "activo": 0.3}, prueba_a, akira, juego.efectos)
	juego.add_child(zona)
	zona.global_position = Vector3(0, 0, 8)


func _comprobar_proyectil_y_zona() -> void:
	var akira = _juego().akira
	_registrar("La tela de araña daña y atrapa a Akira", akira.vida == vida_prueba - 1,
		"vida %d → %d" % [vida_prueba, akira.vida])
	_registrar("Un iai devuelve la flecha contra el arquero", prueba_a.vida < cuenta_antes or not prueba_a.vivo(),
		"vida del elfo %d" % prueba_a.vida)
	akira.vida = akira.vida_maxima
	akira.invulnerable = 999.0
	akira.atrapado = 0.0
	_quietos()


func _probar_sellos_de_bahamut() -> void:
	var juego = _juego()
	var bahamut = juego.jefe
	_quietos()
	var vida: int = bahamut.vida
	bahamut.recibir_golpe(bahamut.global_position + Vector3.LEFT * 2.0, false, 2)
	var protegido: bool = bahamut.vida == vida and bahamut.encadenado()
	for sello in bahamut.sellos:
		sello.recibir_golpe(sello.global_position + Vector3.LEFT, true)
	bahamut.recibir_golpe(bahamut.global_position + Vector3.LEFT * 2.0, false, 2)
	_registrar("Bahamut: los tres dogū lo protegen; rotos, la espada le entra",
		bahamut.sellos.size() == 3 and protegido and not bahamut.encadenado() and bahamut.vida < vida,
		"sellos=%d, vida %d → %d" % [bahamut.sellos.size(), vida, bahamut.vida])


func _probar_barrera_del_templo() -> void:
	var juego = _juego()
	_quietos()
	var bien: bool = juego.barrera != null and juego.jefe.protegido and juego.objetivos.size() == 3
	_registrar("Templo: una barrera y tres sellos protegen a la guardiana", bien,
		"barrera=%s, objetivos=%d" % [juego.barrera != null, juego.objetivos.size()])
	for sello in juego.objetivos:
		sello.recibir_golpe(sello.global_position + Vector3.LEFT, false, 1)


func _comprobar_barrera_del_templo() -> void:
	var juego = _juego()
	_registrar("Al cortar los sellos cae la barrera", juego.barrera == null and not juego.jefe.protegido)


func _vencer_jefe_actual() -> void:
	var juego = _juego()
	_quietos()
	var jefe = juego.jefe
	var vueltas := 0
	while jefe.vivo() and vueltas < 60:
		jefe.recibir_golpe(jefe.global_position + Vector3.LEFT * 2.0, false, 4)
		jefe.rota = 0.0
		vueltas += 1


func _comprobar_jefe_siguiente(tipo: String) -> void:
	var juego = _juego()
	_registrar("Hoshiyama: tras caer el jefe aparece %s" % tipo, juego.jefe != null and is_instance_valid(juego.jefe)
		and juego.jefe.tipo == tipo, "jefe=%s" % (juego.jefe.tipo if juego.jefe else "ninguno"))


func _comprobar_final() -> void:
	var juego = _juego()
	_registrar("Al caer la zorra de nueve colas llega el final", juego.fase == "cierre"
		and Partida.alcanzado == Escenarios.cantidad() - 1, "fase=%s, alcanzado=%d" % [juego.fase, Partida.alcanzado])
	principal.hud.completar_texto()
	principal.aceptar()
	_registrar("Tras el final se vuelve al primer escenario", _juego().indice_escenario == 0)


func _terminar_escenario_con_tecnica() -> void:
	var juego = _juego()
	juego.akira.controlable = false
	juego._cambiar_fase("cierre")
	principal.hud.completar_texto()
	principal.aceptar()


func _comprobar_tecnica() -> void:
	var juego = _juego()
	_registrar("Sōjōbō enseña el paso del tengu (esquivar cuesta la mitad)",
		Partida.tiene_tecnica("paso_del_tengu") and juego.indice_escenario == 5 and is_equal_approx(juego.akira.coste_esquiva, 0.5),
		"escenario=%d, coste=%.2f" % [juego.indice_escenario, juego.akira.coste_esquiva])


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
