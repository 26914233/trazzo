# La mesa de un prototipo: monta la escena (ambiente, cámara, sonido, interfaz), carga el puzle,
# reparte los toques entre la cámara y las piezas, y lleva las pistas, el inventario y las métricas.
#   Un dedo sobre una pieza: la arrastra (o la toca, si apenas se movió).
#   Un dedo en el vacío: gira la cámara (o mira alrededor en las habitaciones).
#   Dos dedos: acercar o alejar. Rueda del ratón: lo mismo en el PC.
extends Node3D

signal salir
signal repetir
signal terminado(id: String, segundos: float, pistas: int)

const Hud := preload("res://scripts/hud.gd")
const Sonido := preload("res://scripts/sonido.gd")
const Menu := preload("res://scripts/menu.gd")

const UMBRAL_TOQUE := 14.0            # píxeles (a 720 de alto) que se puede mover un toque
const TIEMPO_TOQUE := 380             # milisegundos

var datos: Dictionary
var puzle: Puzle
var camara: CamaraPuzle
var hud
var sonido
var entorno: Environment
var bloqueado := false                # sin toques (animación del final)

var _toques := {}
var _agarre: Pieza = null
var _toque_inicio := Vector2.ZERO
var _toque_ms := 0
var _movido := 0.0
var _orbitando := false
var _pellizco := 0.0

var inventario: Array = []            # [{id, nombre, icono}]
var seleccionado := ""

var inicio_ms := 0
var tiempos := {}                     # paso -> segundos desde el inicio
var pistas_por_paso := {}
var pistas_total := 0
var bloqueos := 0
var toques_total := 0
var acabado := false


func _ready() -> void:
	var mundo := WorldEnvironment.new()
	entorno = Environment.new()
	entorno.background_mode = Environment.BG_COLOR
	entorno.background_color = datos.get("fondo", Color.BLACK)
	entorno.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	entorno.ambient_light_color = Color(0.5, 0.5, 0.55)
	entorno.ambient_light_energy = 0.4
	entorno.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	entorno.tonemap_exposure = 1.0
	entorno.glow_enabled = true
	entorno.glow_intensity = 0.8
	entorno.glow_bloom = 0.05
	entorno.glow_hdr_threshold = 1.1
	mundo.environment = entorno
	add_child(mundo)

	camara = CamaraPuzle.new()
	add_child(camara)
	sonido = Sonido.new()
	add_child(sonido)

	puzle = load(datos.script).new()
	puzle.mesa = self
	add_child(puzle)
	puzle.construir()
	puzle.preparar_camara(camara)
	puzle.preparar_entorno(entorno)

	hud = Hud.new()
	hud.mesa = self
	add_child(hud)
	hud.configurar(datos, puzle.pasos.size())
	hud.modo_habitacion(camara.modo == CamaraPuzle.Modo.PUNTO)

	inicio_ms = Time.get_ticks_msec()
	puzle.empezar()


func _process(delta: float) -> void:
	puzle.actualizar(delta)


func segundos() -> float:
	return (Time.get_ticks_msec() - inicio_ms) / 1000.0


# --- Toques ----------------------------------------------------------------------------------

func _unhandled_input(evento: InputEvent) -> void:
	if bloqueado or hud == null:
		return
	if evento is InputEventScreenTouch:
		_toque(evento)
	elif evento is InputEventScreenDrag:
		_arrastre(evento)
	elif evento is InputEventMouseButton and evento.pressed:
		if evento.button_index == MOUSE_BUTTON_WHEEL_UP:
			camara.acercar(0.92)
		elif evento.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camara.acercar(1.09)


func _toque(evento: InputEventScreenTouch) -> void:
	if evento.pressed:
		if _toques.is_empty() and hud.toca_interfaz(evento.position):
			return
		if hud.bloquea_todo():
			return
		_toques[evento.index] = evento.position
		if _toques.size() == 1:
			_empezar(evento.position)
		elif _toques.size() == 2:
			_cancelar_agarre()
			_orbitando = false
			camara.soltar()
			_pellizco = _distancia_toques()
	else:
		if not _toques.has(evento.index):
			return
		_toques.erase(evento.index)
		if _toques.is_empty():
			_terminar(evento.position)


func _arrastre(evento: InputEventScreenDrag) -> void:
	if not _toques.has(evento.index):
		return
	_toques[evento.index] = evento.position
	if _toques.size() >= 2:
		var distancia := _distancia_toques()
		if _pellizco > 10.0 and distancia > 10.0:
			camara.acercar(_pellizco / distancia)
		_pellizco = distancia
		return
	_movido += evento.relative.length() * _escala()
	if _agarre:
		if _movido > UMBRAL_TOQUE * 0.5:
			_agarre.arrastrar(evento.relative, evento.position, camara.camara)
	elif _orbitando:
		camara.orbitar(evento.relative)


func _empezar(posicion: Vector2) -> void:
	_toque_inicio = posicion
	_toque_ms = Time.get_ticks_msec()
	_movido = 0.0
	toques_total += 1
	var encontrado := pieza_en(posicion)
	if not encontrado.is_empty():
		_agarre = encontrado.pieza
		_agarre.empezar_arrastre(encontrado.punto, camara.camara)
	else:
		_orbitando = true


func _terminar(posicion: Vector2) -> void:
	var breve := _movido < UMBRAL_TOQUE and Time.get_ticks_msec() - _toque_ms < TIEMPO_TOQUE
	if _agarre:
		var pieza := _agarre
		_agarre = null
		if breve:
			pieza.soltar()
			pieza.tocar()
		else:
			pieza.soltar()
	elif _orbitando:
		_orbitando = false
		camara.soltar()
		if breve and seleccionado != "":
			seleccionar("")


func _cancelar_agarre() -> void:
	if _agarre:
		_agarre.soltar()
		_agarre = null


func _distancia_toques() -> float:
	var lista := _toques.values()
	return (lista[0] as Vector2).distance_to(lista[1]) if lista.size() >= 2 else 0.0


func _escala() -> float:
	return 720.0 / maxf(1.0, get_viewport().get_visible_rect().size.y)


# Pieza que hay bajo un punto de la pantalla. Si la primera que encuentra no se puede tocar desde
# aquí (en las habitaciones), mira detrás de ella.
func pieza_en(posicion: Vector2) -> Dictionary:
	var origen := camara.camara.project_ray_origin(posicion)
	var direccion := camara.camara.project_ray_normal(posicion)
	var excluir: Array[RID] = []
	var espacio := get_world_3d().direct_space_state
	for intento in 6:
		var consulta := PhysicsRayQueryParameters3D.create(origen, origen + direccion * 40.0)
		consulta.exclude = excluir
		var resultado := espacio.intersect_ray(consulta)
		if resultado.is_empty():
			return {}
		var colisor: Object = resultado.collider
		if colisor.has_meta("pieza"):
			var pieza: Pieza = colisor.get_meta("pieza")
			if pieza.interactiva():
				return {"pieza": pieza, "punto": resultado.position}
			if not colisor.has_meta("opaca"):
				excluir.append(resultado.rid)
				continue
		return {}
	return {}


# --- Lo que usan los puzles -------------------------------------------------------------------

func vibrar(milisegundos := 15, fuerza := 0.5) -> void:
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(milisegundos, fuerza)


func mensaje(texto: String, segundos_visible := 3.4) -> void:
	hud.mensaje(texto, segundos_visible)


func nota(titulo: String, texto: String) -> void:
	hud.mostrar_nota(titulo, texto)


func centrar() -> void:
	camara.centrar()


func registrar_bloqueo(_pieza: Pieza) -> void:
	bloqueos += 1


func paso_hecho(id: String) -> void:
	tiempos[id] = segundos()
	hud.poner_progreso(puzle.hechos.size())
	if puzle.hechos.size() < puzle.pasos.size():
		sonido.sonar("paso", -6.0, 1.0, 0.0)
		vibrar(30, 0.6)


func pedir_pista() -> void:
	var paso: Dictionary = puzle.paso_actual()
	if paso.is_empty():
		return
	var lista: Array = paso.pistas
	var nivel: int = pistas_por_paso.get(paso.id, 0)
	if nivel < lista.size():
		pistas_por_paso[paso.id] = nivel + 1
		pistas_total += 1
	var mostrado := mini(nivel, lista.size() - 1)
	hud.mostrar_pista(lista[mostrado], mostrado + 1, lista.size())
	sonido.sonar("pista", -8.0)
	if mostrado == lista.size() - 1 and paso.pieza != "" and puzle.piezas.has(paso.pieza):
		puzle.piezas[paso.pieza].resaltar(5.0)


# --- Inventario -------------------------------------------------------------------------------

func agregar_objeto(id: String, nombre: String, modelo: Node3D) -> void:
	var objeto := {"id": id, "nombre": nombre, "icono": null}
	inventario.append(objeto)
	hud.poner_inventario(inventario, seleccionado)
	mensaje("Has guardado: %s." % nombre, 2.4)
	objeto.icono = await _icono(modelo)
	if objeto in inventario:
		hud.poner_inventario(inventario, seleccionado)


func quitar_objeto(id: String) -> void:
	for objeto in inventario:
		if objeto.id == id:
			inventario.erase(objeto)
			break
	if seleccionado == id:
		seleccionado = ""
	hud.poner_inventario(inventario, seleccionado)


func tiene(id: String) -> bool:
	for objeto in inventario:
		if objeto.id == id:
			return true
	return false


func seleccionar(id: String) -> void:
	seleccionado = "" if id == seleccionado else id
	if seleccionado != "":
		for objeto in inventario:
			if objeto.id == seleccionado:
				mensaje("%s: toca dónde quieres usarlo." % objeto.nombre, 2.6)
	sonido.sonar("toque", -10.0)
	hud.poner_inventario(inventario, seleccionado)


# Dibuja el objeto en una vista aparte para usarlo de icono
func _icono(modelo: Node3D) -> Texture2D:
	var vista := SubViewport.new()
	vista.size = Vector2i(144, 144)
	vista.transparent_bg = true
	vista.own_world_3d = true
	vista.render_target_update_mode = SubViewport.UPDATE_ONCE
	var copia: Node3D = modelo.duplicate(0)
	copia.transform = Transform3D(modelo.global_basis.orthonormalized(), Vector3.ZERO)
	vista.add_child(copia)
	var caja := _caja_de(copia)
	var centro := caja.get_center()
	var tamano := maxf(caja.size.length(), 0.01)
	var camara_icono := Camera3D.new()
	camara_icono.fov = 30.0
	vista.add_child(camara_icono)
	var luz := DirectionalLight3D.new()
	luz.rotation = Vector3(-0.8, 0.6, 0.0)
	luz.light_energy = 1.6
	vista.add_child(luz)
	var ambiente := WorldEnvironment.new()
	ambiente.environment = Environment.new()
	ambiente.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	ambiente.environment.ambient_light_color = Color(0.7, 0.7, 0.75)
	ambiente.environment.ambient_light_energy = 0.8
	vista.add_child(ambiente)
	add_child(vista)
	camara_icono.look_at_from_position(centro + Vector3(0.35, 0.45, 1.0).normalized() * tamano * 2.1, centro)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var imagen := vista.get_texture().get_image()
	vista.queue_free()
	return ImageTexture.create_from_image(imagen)


func _caja_de(nodo: Node3D) -> AABB:
	var caja := AABB()
	var primera := true
	var lista: Array = nodo.find_children("*", "MeshInstance3D", true, false)
	if nodo is MeshInstance3D:
		lista.append(nodo)
	for malla in lista:
		var instancia := malla as MeshInstance3D
		if instancia.mesh == null:
			continue
		var relativa := _relativa(nodo, instancia)
		var trozo := relativa * instancia.mesh.get_aabb()
		caja = trozo if primera else caja.merge(trozo)
		primera = false
	return caja


func _relativa(raiz: Node3D, nodo: Node3D) -> Transform3D:
	var transformacion := Transform3D.IDENTITY
	var actual := nodo
	while actual and actual != raiz:
		transformacion = actual.transform * transformacion
		actual = actual.get_parent() as Node3D
	return raiz.transform * transformacion


# --- Final ------------------------------------------------------------------------------------

func terminar() -> void:
	if acabado:
		return
	acabado = true
	var total := segundos()
	bloqueado = true
	_cancelar_agarre()
	_toques.clear()
	await puzle.final()
	terminado.emit(datos.id, total, pistas_total)
	var resumen := "Tiempo: %s   ·   Pistas: %d   ·   Intentos bloqueados: %d" % [
		Menu.formato_tiempo(total), pistas_total, bloqueos]
	hud.mostrar_final(puzle.titulo_final, puzle.texto_final, resumen)
