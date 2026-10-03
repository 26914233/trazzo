# La mesa de una caja: monta la escena (ambiente, habitación, cámara, sonido, interfaz), carga el
# puzle, hace la entrada (la cámara cruza la habitación hasta la caja), reparte los toques entre la
# cámara y las piezas, y lleva las pistas, el inventario y las métricas.
#   Un dedo sobre una pieza: la arrastra; un toque corto la acciona.
#   Un dedo en el vacío: gira la cámara (o mira alrededor en las habitaciones).
#   Dos toques seguidos: la cámara viaja a esa zona de la caja (o vuelve, si ya estaba cerca).
#   Dos dedos: acercar o alejar hacia donde están los dedos. Rueda del ratón: lo mismo en el PC.
extends Node3D

signal salir
signal repetir
signal terminado(id: String, segundos: float, pistas: int)

const Hud := preload("res://scripts/hud.gd")
const Sonido := preload("res://scripts/sonido.gd")
const Estilo := preload("res://scripts/estilo.gd")

const UMBRAL_ARRASTRE := 10.0         # píxeles (a 720 de alto) que hay que mover el dedo para arrastrar
const TIEMPO_TOQUE := 400             # milisegundos que puede durar un toque
const DOBLE_TOQUE := 280              # milisegundos entre los dos toques de un doble toque
const DISTANCIA_DOBLE := 70.0         # píxeles (a 720 de alto) entre los dos toques

var datos: Dictionary
var puzle: Puzle
var camara: CamaraPuzle
var hud
var sonido
var entorno: Environment
var bloqueado := false                # sin toques (entrada y animación del final)
var con_entrada := true               # la prueba automática puede saltarse la entrada
var dobles_toques := 0                # cuántas veces se usó el doble toque (lo mira la prueba)

var _toques := {}
var _agarre: Pieza = null
var _candidato := {}
var _toque_inicio := Vector2.ZERO
var _toque_ms := 0
var _movido := 0.0
var _orbitando := false
var _hubo_pellizco := false
var _pellizco := 0.0
var _punto_pellizco: Variant = null
var _pendiente := {}                  # toque corto que espera por si llega el segundo

var inventario: Array = []            # [{id, nombre, icono, modelo}]
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
	puzle.construir_sala()
	puzle.construir()
	puzle.preparar_camara(camara)
	puzle.preparar_entorno(entorno)

	hud = Hud.new()
	hud.mesa = self
	add_child(hud)
	hud.configurar(datos, puzle.pasos.size())
	hud.modo_habitacion(camara.modo == CamaraPuzle.Modo.PUNTO)

	inicio_ms = Time.get_ticks_msec()
	var ruta: Dictionary = puzle.ruta_entrada()
	if con_entrada and not ruta.is_empty():
		bloqueado = true
		camara.entrada(ruta.puntos, ruta.miradas, ruta.get("duracion", 5.5), ruta.get("fov", 55.0))
		camara.entrada_terminada.connect(_fin_entrada, CONNECT_ONE_SHOT)
		hud.empezar_entrada()
		puzle.empezar()
	else:
		puzle.empezar()
		_fin_entrada()


func _fin_entrada() -> void:
	bloqueado = false
	inicio_ms = Time.get_ticks_msec()
	hud.mostrar_interfaz()
	puzle.al_llegar()


func _process(delta: float) -> void:
	if not _pendiente.is_empty() and Time.get_ticks_msec() - int(_pendiente.ms) >= DOBLE_TOQUE:
		var toque := _pendiente
		_pendiente = {}
		_toque_simple(toque)
	puzle.actualizar(delta)


func segundos() -> float:
	return (Time.get_ticks_msec() - inicio_ms) / 1000.0


# --- Toques ----------------------------------------------------------------------------------

func _unhandled_input(evento: InputEvent) -> void:
	if hud == null:
		return
	if camara.en_entrada:
		# un toque durante la entrada la salta
		if evento is InputEventScreenTouch and evento.pressed:
			camara.saltar_entrada()
		return
	if bloqueado:
		return
	if evento is InputEventScreenTouch:
		_toque(evento)
	elif evento is InputEventScreenDrag:
		_arrastre(evento)
	elif evento is InputEventMouseButton and evento.pressed:
		if evento.button_index == MOUSE_BUTTON_WHEEL_UP:
			camara.pellizcar(0.92, _impacto(evento.position))
		elif evento.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camara.pellizcar(1.09)


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
			_hubo_pellizco = true
			camara.soltar()
			_pellizco = _distancia_toques()
			_punto_pellizco = _impacto(_centro_toques())
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
			camara.pellizcar(_pellizco / distancia, _punto_pellizco)
		_pellizco = distancia
		return
	if _hubo_pellizco:
		return
	_movido += evento.relative.length() * _escala()
	if _agarre:
		_agarre.arrastrar(evento.relative, evento.position, camara.camara)
	elif _orbitando:
		camara.orbitar(evento.relative)
	elif _movido > UMBRAL_ARRASTRE:
		var recorrido := evento.position - _toque_inicio
		if not _candidato.is_empty() and _candidato.pieza.arrastrable():
			_agarre = _candidato.pieza
			_agarre.empezar_arrastre(_candidato.punto, camara.camara)
			_agarre.arrastrar(recorrido, evento.position, camara.camara)
		else:
			_orbitando = true
			camara.orbitar(recorrido)


func _empezar(posicion: Vector2) -> void:
	_toque_inicio = posicion
	_toque_ms = Time.get_ticks_msec()
	_movido = 0.0
	_orbitando = false
	_hubo_pellizco = false
	toques_total += 1
	_candidato = pieza_en(posicion)
	camara.detener()


func _terminar(posicion: Vector2) -> void:
	var breve := not _hubo_pellizco and _agarre == null and not _orbitando \
		and Time.get_ticks_msec() - _toque_ms < TIEMPO_TOQUE
	if _agarre:
		_agarre.soltar()
		_agarre = null
	if _orbitando:
		_orbitando = false
		camara.soltar()
	if breve:
		_registrar_toque(posicion)
	_candidato = {}


# Un toque corto espera un instante por si llega el segundo (doble toque)
func _registrar_toque(posicion: Vector2) -> void:
	var ahora := Time.get_ticks_msec()
	if not _pendiente.is_empty() and ahora - int(_pendiente.ms) < DOBLE_TOQUE \
			and posicion.distance_to(_pendiente.posicion) * _escala() < DISTANCIA_DOBLE:
		_pendiente = {}
		_doble_toque(posicion)
		return
	if not _pendiente.is_empty():
		_toque_simple(_pendiente)
	_pendiente = {"posicion": posicion, "ms": ahora, "candidato": _candidato}


func _toque_simple(toque: Dictionary) -> void:
	if bloqueado or hud.bloquea_todo():
		return
	var candidato: Dictionary = toque.candidato
	if not candidato.is_empty() and is_instance_valid(candidato.pieza) and candidato.pieza.interactiva():
		candidato.pieza.tocar()
	elif seleccionado != "":
		seleccionar("")


# Doble toque: la cámara viaja a la zona tocada; si ya estaba cerca (o se toca el vacío), se aleja
func _doble_toque(posicion: Vector2) -> void:
	dobles_toques += 1
	if camara.modo == CamaraPuzle.Modo.PUNTO:
		camara.mirar_de_cerca(posicion)
		sonido.sonar("acercar", -10.0)
		return
	var punto: Variant = _impacto(posicion)
	if punto == null:
		if camara.acercada():
			camara.alejar()
			sonido.sonar("acercar", -12.0, 0.85)
		return
	var zona: Dictionary = puzle.zona_en(punto)
	if not zona.is_empty() and zona.id == camara.zona_actual:
		camara.alejar()
	elif not zona.is_empty():
		camara.enfocar_zona(zona)
	elif camara.distancia < float(camara.inicial.distancia) * 0.6:
		camara.alejar()
	else:
		camara.enfocar(punto, float(camara.inicial.distancia) * 0.45, NAN, NAN, 0.8)
	sonido.sonar("acercar", -10.0)


func _cancelar_agarre() -> void:
	if _agarre:
		_agarre.soltar()
		_agarre = null


func _distancia_toques() -> float:
	var lista := _toques.values()
	return (lista[0] as Vector2).distance_to(lista[1]) if lista.size() >= 2 else 0.0


func _centro_toques() -> Vector2:
	var lista := _toques.values()
	return ((lista[0] as Vector2) + (lista[1] as Vector2)) / 2.0 if lista.size() >= 2 else _toque_inicio


func _escala() -> float:
	return 720.0 / maxf(1.0, get_viewport().get_visible_rect().size.y)


# Punto del objeto que hay bajo un punto de la pantalla (null si no hay nada)
func _impacto(posicion: Vector2) -> Variant:
	var origen := camara.camara.project_ray_origin(posicion)
	var direccion := camara.camara.project_ray_normal(posicion)
	var consulta := PhysicsRayQueryParameters3D.create(origen, origen + direccion * 40.0)
	var resultado := get_world_3d().direct_space_state.intersect_ray(consulta)
	return null if resultado.is_empty() else resultado.position


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
	var objeto := {"id": id, "nombre": nombre, "icono": null, "modelo": modelo}
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
				mensaje("%s: toca dónde quieres usarlo, o la lupa para examinarlo." % objeto.nombre, 3.0)
	sonido.sonar("toque", -10.0)
	hud.poner_inventario(inventario, seleccionado)


func examinar(id: String) -> void:
	for objeto in inventario:
		if objeto.id == id and is_instance_valid(objeto.modelo):
			sonido.sonar("recoger", -8.0, 1.2)
			hud.mostrar_examen(objeto.nombre, objeto.modelo)
			return


# Copia del objeto, sin rastro de su posición en la escena (para el icono y para examinarlo).
# Lo que brilla (cristales, glifos) se ve blanco fuera de la penumbra de su sala: en la copia brilla menos.
func copia_de(modelo: Node3D) -> Node3D:
	var copia: Node3D = modelo.duplicate(0)
	copia.transform = Transform3D(modelo.global_basis.orthonormalized(), Vector3.ZERO)
	copia.show()
	for nodo in copia.find_children("*", "MeshInstance3D", true, false):
		var malla := nodo as MeshInstance3D
		malla.material_overlay = null
		var material := malla.material_override as StandardMaterial3D
		if material and material.emission_enabled:
			material = material.duplicate()
			material.emission_energy_multiplier *= 0.3
			malla.material_override = material
	return copia


# Luz de estudio para ver un objeto suelto (examen e iconos). El cielo no se ve: solo da reflejos, sin
# los que el latón y los metales salen negros.
static func entorno_estudio() -> Environment:
	var entorno := Environment.new()
	Escena.cielo(entorno, {
		"arriba": Color(0.62, 0.56, 0.5), "horizonte": Color(0.36, 0.33, 0.3), "abajo": Color(0.07, 0.06, 0.05),
		"resplandor": Color(1.0, 0.86, 0.62), "direccion_resplandor": Vector3(-0.5, 0.6, 0.6), "apertura": 5.0,
		"nubes": 0.0, "estrellas": 0.0}, false)
	entorno.background_mode = Environment.BG_CLEAR_COLOR
	entorno.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	entorno.ambient_light_color = Color(0.62, 0.6, 0.64)
	entorno.ambient_light_energy = 0.75
	entorno.tonemap_mode = Environment.TONE_MAPPER_ACES
	return entorno


# Dibuja el objeto en una vista aparte para usarlo de icono
func _icono(modelo: Node3D) -> Texture2D:
	var vista := SubViewport.new()
	vista.size = Vector2i(160, 160)
	vista.transparent_bg = true
	vista.own_world_3d = true
	vista.render_target_update_mode = SubViewport.UPDATE_ONCE
	var copia := copia_de(modelo)
	vista.add_child(copia)
	var caja := caja_de(copia)
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
	ambiente.environment = entorno_estudio()
	ambiente.environment.ambient_light_energy = 0.85
	vista.add_child(ambiente)
	add_child(vista)
	camara_icono.look_at_from_position(centro + Vector3(0.35, 0.45, 1.0).normalized() * tamano * 2.1, centro)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var imagen := vista.get_texture().get_image()
	vista.queue_free()
	return ImageTexture.create_from_image(imagen)


static func caja_de(nodo: Node3D) -> AABB:
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


static func _relativa(raiz: Node3D, nodo: Node3D) -> Transform3D:
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
	_pendiente = {}
	hud.cerrar_examen()
	await puzle.final()
	terminado.emit(datos.id, total, pistas_total)
	var resumen := "Tiempo: %s   ·   Pistas: %d   ·   Intentos bloqueados: %d" % [
		Estilo.formato_tiempo(total), pistas_total, bloqueos]
	hud.mostrar_final(puzle.titulo_final, puzle.texto_final, resumen)
