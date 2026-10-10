# El gabinete: el menú del juego, en 3D. La sala oscura de un coleccionista con los cuatro objetos
# en sus pedestales, cada uno bajo su foco. Tres pantallas:
#   portada: el título sobre la sala; un toque empieza;
#   juegos: la cámara se acerca a un pedestal; se pasa de un juego a otro deslizando o con las
#     flechas, y «Entrar» lleva a sus cajas;
#   cajas: las cajas (niveles) de ese juego; las selladas llevan candado.
# Al salir de una caja se vuelve aquí, a la lista de cajas de su juego.
extends Node3D

signal elegida(id: String)

const Catalogo := preload("res://scripts/catalogo.gd")
const Estilo := preload("res://scripts/estilo.gd")
const Sonido := preload("res://scripts/sonido.gd")
const Hud := preload("res://scripts/hud.gd")

const POSICION_PORTADA := Vector3(0.0, 1.45, 2.75)
const MIRA_PORTADA := Vector3(0.0, 1.18, -0.45)
const ALTO_PEDESTAL := 1.0
const MARGEN := 22.0
const BOTON := 92.0

var resultados: ConfigFile
var pantalla_inicial := "portada"
var juego_inicial := ""
var pantalla := ""
var indice := 0
var camara: Camera3D
var sonido
var vitrinas: Array = []              # [{juego, ancla, puzle, centro, foco}]
var botones_cajas := {}               # id de la caja -> Button (lo usa la prueba automática)
var ui: CanvasLayer
var capa_portada: Control
var capa_juegos: Control
var capa_cajas: Control
var _empezar: Label
var _juego_numero: Label
var _juego_titulo: Label
var _juego_frase: Label
var _juego_progreso: Label
var _puntos: Label
var _cajas_titulo: Label
var _lista_cajas: VBoxContainer
var _botones_ui: Array = []           # para saber si un toque cayó en la interfaz
var _desde := Transform3D.IDENTITY
var _hacia := Transform3D.IDENTITY
var _fov_desde := 46.0
var _fov_hacia := 46.0
var _progreso := 1.0
var _tiempo := 0.0
var _toque := {}
var _focos := []                      # energía objetivo de cada foco


func _ready() -> void:
	_ambiente()
	camara = Camera3D.new()
	camara.fov = 46.0
	camara.near = 0.03
	camara.far = 60.0
	add_child(camara)
	var relleno := OmniLight3D.new()
	relleno.position = Vector3(0.0, 0.2, 0.1)
	relleno.light_color = Color(1.0, 0.9, 0.8)
	relleno.light_energy = 0.25
	relleno.light_specular = 0.15
	relleno.omni_range = 1.6
	relleno.omni_attenuation = 1.6
	camara.add_child(relleno)
	camara.current = true
	sonido = Sonido.new()
	add_child(sonido)
	_sala()
	_pedestales()
	_interfaz()
	sonido.bucle("gabinete", -12.0, 2.0)
	sonido.bucle("tictac", -24.0, 2.0)
	var numero := 0
	for i in Catalogo.JUEGOS.size():
		if Catalogo.JUEGOS[i].id == juego_inicial:
			numero = i
	camara.global_transform = _transformada(POSICION_PORTADA, MIRA_PORTADA)
	_desde = camara.global_transform
	_hacia = _desde
	match pantalla_inicial:
		"cajas":
			ir_a_cajas(numero, 0.01)
		"juegos":
			ir_a_juegos(numero, 0.01)
		_:
			ir_a_portada(0.01)


# --- Sala ----------------------------------------------------------------------------------------

func _ambiente() -> void:
	var mundo := WorldEnvironment.new()
	var entorno := Environment.new()
	entorno.background_mode = Environment.BG_COLOR
	entorno.background_color = Color(0.02, 0.016, 0.014)
	entorno.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	entorno.ambient_light_color = Color(0.55, 0.45, 0.4)
	entorno.ambient_light_energy = 0.16
	entorno.tonemap_mode = Environment.TONE_MAPPER_ACES
	entorno.tonemap_exposure = 1.05
	entorno.glow_enabled = true
	entorno.glow_intensity = 0.8
	entorno.glow_bloom = 0.04
	entorno.glow_hdr_threshold = 1.0
	entorno.fog_enabled = true
	entorno.fog_light_color = Color(0.05, 0.04, 0.035)
	entorno.fog_density = 0.03
	# un cielo cálido y tenue solo para los reflejos (sin él, el latón y el metal se ven negros)
	Escena.cielo(entorno, {
		"arriba": Color(0.12, 0.1, 0.09), "horizonte": Color(0.3, 0.24, 0.18), "abajo": Color(0.06, 0.05, 0.04),
		"resplandor": Color(0.6, 0.45, 0.3), "direccion_resplandor": Vector3(0.3, 0.6, 0.8), "apertura": 3.0,
		"nubes": 0.0, "estrellas": 0.0}, false)
	mundo.environment = entorno
	add_child(mundo)


func _sala() -> void:
	var sala := Escena.grupo(self, Vector3.ZERO, "Sala")
	var x0 := -3.2
	var x1 := 3.2
	var z0 := -2.4
	var z1 := 4.8
	var alto := 3.3
	var friso := 1.05
	var suelo := Materiales.con_textura("tablones", 0.7, 0.62, 0.0, Color(0.6, 0.5, 0.45))
	var papel := Materiales.con_textura("papel_pintado", 1.2, 0.85, 0.0, Color(0.72, 0.8, 0.72), 0.6)
	var madera := Materiales.con_textura("madera_oscura", 1.6, 0.42)
	var techo := Materiales.con_textura("madera_oscura", 1.0, 0.8, 0.0, Color(0.45, 0.4, 0.36))
	Arquitectura.losa(Vector3(x0, -0.05, z0), Vector3(x1, 0.0, z1), suelo, sala)
	Arquitectura.losa(Vector3(-2.4, 0.0, -1.5), Vector3(2.4, 0.012, 0.9), Materiales.con_textura("alfombra", 0.42, 0.95), sala)
	Arquitectura.losa(Vector3(x0, alto, z0), Vector3(x1, alto + 0.05, z1), techo, sala)
	for x in [-1.8, 0.0, 1.8]:
		Arquitectura.losa(Vector3(x - 0.09, alto - 0.18, z0), Vector3(x + 0.09, alto, z1), madera, sala, 0.01)
	# paredes: friso de madera abajo y papel pintado arriba (la de la izquierda, con la ventana)
	var paredes := [
		[Vector3(x0, 0.0, z0), Vector3.RIGHT, x1 - x0, Vector3.BACK, []],
		[Vector3(x0, 0.0, z1), Vector3.FORWARD, z1 - z0, Vector3.RIGHT, [[2.0, 3.6, 0.0, 1.65]]],
		[Vector3(x1, 0.0, z0), Vector3.BACK, z1 - z0, Vector3.LEFT, []],
		[Vector3(x1, 0.0, z1), Vector3.LEFT, x1 - x0, Vector3.FORWARD, []],
	]
	for datos in paredes:
		var inicio: Vector3 = datos[0]
		Arquitectura.pared(inicio, datos[1], datos[2], friso, datos[3], madera, sala)
		Arquitectura.pared(inicio + Vector3.UP * friso, datos[1], datos[2], alto - friso, datos[3], papel, sala, datos[4])
	# molduras
	Arquitectura.losa(Vector3(x0, friso - 0.02, z0), Vector3(x1, friso + 0.03, z0 + 0.05), madera, sala, 0.01)
	Arquitectura.losa(Vector3(x0, 0.0, z0), Vector3(x1, 0.16, z0 + 0.03), madera, sala, 0.005)
	Arquitectura.losa(Vector3(x0, alto - 0.12, z0), Vector3(x1, alto, z0 + 0.08), madera, sala, 0.01)
	# fondo: dos librerías y una carta celeste enmarcada en medio
	for lado in [-1.0, 1.0]:
		var librero := Escena.grupo(sala, Vector3(lado * 2.05, 0.0, z0 + 0.22), "Libreria")
		Escena.bloque(Vector3(-0.62, 0.0, -0.2), Vector3(0.62, 2.55, -0.17), madera, librero, 0.004, false)
		for x in [-0.62, 0.62]:
			Escena.bloque(Vector3(x - 0.03, 0.0, -0.2), Vector3(x + 0.03, 2.6, 0.2), madera, librero, 0.006, false)
		Escena.bloque(Vector3(-0.66, 2.55, -0.2), Vector3(0.66, 2.66, 0.22), madera, librero, 0.008, false)
		for k in 5:
			var y := 0.12 + k * 0.5
			Escena.bloque(Vector3(-0.6, y - 0.025, -0.17), Vector3(0.6, y, 0.18), madera, librero, 0.004, false)
			if k < 4:
				Arquitectura.libros(librero, -0.58, 0.58, y, 0.0, 0.24, 700 + k * 13 + int(lado * 5.0))
	var carta := Materiales.con_textura("carta_celeste", 1.0, 0.7)
	var material_carta: StandardMaterial3D = carta.duplicate()
	material_carta.uv1_scale = Vector3.ONE
	material_carta.emission_enabled = true
	material_carta.emission_texture = Materiales.textura("carta_celeste")
	material_carta.emission = Color(1.0, 0.85, 0.55)
	material_carta.emission_energy_multiplier = 0.25
	Arquitectura.cuadro(sala, Vector3(0.0, 2.05, z0 + 0.02), Vector2(1.5, 1.0), material_carta)
	# luz de cuadro sobre la carta celeste
	Escena.luz(sala, Vector3(0.0, 2.75, z0 + 0.45), Color(1.0, 0.82, 0.6), 0.7, 1.8)
	# ventana a la izquierda, con la tormenta y el barco del farero a lo lejos
	var tormenta := ShaderMaterial.new()
	tormenta.shader = preload("res://shaders/tormenta.gdshader")
	Arquitectura.ventana(sala, Vector3(x0 + 0.02, 1.9, 2.0), Vector2(1.2, 1.5), madera, tormenta, PI / 2.0)
	var luna := DirectionalLight3D.new()
	luna.light_color = Color(0.55, 0.65, 1.0)
	luna.light_energy = 0.28
	sala.add_child(luna)
	luna.look_at_from_position(Vector3(-4.0, 3.0, 2.0), Vector3(0.0, 1.0, -0.5), Vector3.UP)
	# velador con un quinqué a la derecha
	var velador := Escena.grupo(sala, Vector3(2.55, 0.0, 1.6), "Velador")
	var tablero := CylinderMesh.new()
	tablero.top_radius = 0.3
	tablero.bottom_radius = 0.3
	tablero.height = 0.03
	Geometria.pieza(tablero, madera, Vector3(0.0, 0.72, 0.0), velador)
	var pata := CylinderMesh.new()
	pata.top_radius = 0.035
	pata.bottom_radius = 0.06
	pata.height = 0.72
	Geometria.pieza(pata, madera, Vector3(0.0, 0.36, 0.0), velador)
	var quinque := Geometria.torno(PackedVector2Array([Vector2(0.06, 0.0), Vector2(0.075, 0.05), Vector2(0.03, 0.09),
		Vector2(0.05, 0.16), Vector2(0.045, 0.26), Vector2(0.03, 0.3)]), 24)
	Geometria.pieza(quinque, Materiales.vidrio(Color(1.0, 0.85, 0.6, 0.35)), Vector3(0.0, 0.735, 0.0), velador)
	var llama := MeshInstance3D.new()
	var gota := SphereMesh.new()
	gota.radius = 0.012
	gota.height = 0.036
	llama.mesh = gota
	llama.material_override = Materiales.emisivo(Color(1.0, 0.66, 0.28), 5.0, Color(1.0, 0.7, 0.3))
	llama.position = Vector3(0.0, 0.88, 0.0)
	velador.add_child(llama)
	Escena.luz(velador, Vector3(0.0, 0.95, 0.0), Color(1.0, 0.68, 0.38), 1.1, 4.0)
	Escena.polvo(sala, Vector3(2.6, 1.2, 1.6), Color(1.0, 0.85, 0.65, 0.4), 70, 0.008).position = Vector3(0.0, 1.4, 0.0)


# --- Pedestales y objetos ----------------------------------------------------------------------------

func _pedestales() -> void:
	var madera := Materiales.con_textura("madera_oscura", 3.0, 0.36)
	var laton := Materiales.laton(0.35)
	var cantidad := Catalogo.JUEGOS.size()
	for i in cantidad:
		var datos: Dictionary = Catalogo.JUEGOS[i]
		var t := (float(i) / (cantidad - 1)) * 2.0 - 1.0
		var x := t * 1.62
		var z := -0.62 + 0.36 * t * t
		var pie := Escena.grupo(self, Vector3(x, 0.0, z), "Pedestal_" + datos.id)
		var hacia := POSICION_PORTADA - pie.position
		pie.rotation.y = atan2(hacia.x, hacia.z)
		Escena.bloque(Vector3(-0.25, 0.0, -0.25), Vector3(0.25, 0.09, 0.25), madera, pie, 0.012, false)
		Escena.bloque(Vector3(-0.17, 0.09, -0.17), Vector3(0.17, ALTO_PEDESTAL - 0.07, 0.17), madera, pie, 0.008, false)
		Escena.bloque(Vector3(-0.24, ALTO_PEDESTAL - 0.07, -0.24), Vector3(0.24, ALTO_PEDESTAL, 0.24), madera, pie, 0.012, false)
		Escena.bloque(Vector3(-0.2, ALTO_PEDESTAL - 0.1, -0.2), Vector3(0.2, ALTO_PEDESTAL - 0.07, 0.2), laton, pie, 0.004, false)
		# placa de latón con el nombre
		Escena.bloque(Vector3(-0.13, 0.62, 0.17), Vector3(0.13, 0.72, 0.176), laton, pie, 0.003, false)
		var nombre := Label3D.new()
		nombre.text = datos.titulo.to_upper()
		nombre.font = Estilo.FUENTE_NEGRITA
		nombre.font_size = 48
		nombre.pixel_size = 0.00042
		nombre.width = 560.0
		nombre.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		nombre.modulate = Color(0.16, 0.1, 0.05)
		nombre.outline_size = 0
		nombre.shaded = true
		nombre.position = Vector3(0.0, 0.67, 0.178)
		pie.add_child(nombre)
		var ancla := Escena.grupo(pie, Vector3(0.0, ALTO_PEDESTAL, 0.0), "Ancla")
		var vitrina := {"juego": datos.id, "ancla": ancla, "puzle": null, "alto": 0.12}
		_poner_objeto(vitrina, datos)
		# zona de toque: todo el pedestal y el objeto
		var cuerpo := StaticBody3D.new()
		var forma := CollisionShape3D.new()
		forma.shape = BoxShape3D.new()
		(forma.shape as BoxShape3D).size = Vector3(0.6, ALTO_PEDESTAL + 0.6, 0.6)
		forma.position = Vector3(0.0, (ALTO_PEDESTAL + 0.6) / 2.0, 0.0)
		cuerpo.add_child(forma)
		cuerpo.set_meta("vitrina", i)
		pie.add_child(cuerpo)
		# foco cenital
		var foco := SpotLight3D.new()
		foco.light_color = datos.acento.lerp(Color(1.0, 0.88, 0.7), 0.7)
		foco.light_energy = 0.0
		foco.spot_range = 3.2
		foco.spot_angle = 17.0
		foco.spot_attenuation = 0.6
		foco.light_specular = 0.6
		add_child(foco)
		var centro: Vector3 = pie.to_global(Vector3(0.0, ALTO_PEDESTAL + vitrina.alto, 0.0))
		foco.look_at_from_position(centro + Vector3(0.0, 1.9, 0.55), centro, Vector3.UP)
		vitrina.centro = centro
		vitrina.foco = foco
		vitrinas.append(vitrina)
		_focos.append(0.0)


func _poner_objeto(vitrina: Dictionary, datos: Dictionary) -> void:
	var ancla: Node3D = vitrina.ancla
	var primera: Dictionary = Catalogo.caja(datos.cajas[0].id)
	if datos.id == "farero" or not Catalogo.jugable(primera):
		_maqueta_faro(ancla)
		vitrina.alto = 0.2
		return
	var puzle: Puzle = load(primera.script).new()
	puzle.vitrina = true
	ancla.add_child(puzle)
	puzle.construir()
	match datos.id:
		"caja_viva":
			puzle.scale = Vector3.ONE * 1.25
			puzle.position.y = 0.081 * 1.25
			vitrina.alto = 0.1
		"relojero":
			puzle.scale = Vector3.ONE * 1.05
			vitrina.alto = 0.08
		"reliquia":
			puzle.scale = Vector3.ONE * 0.72
			puzle.position.y = 0.33
			vitrina.alto = 0.33
			var aro := TorusMesh.new()
			aro.inner_radius = 0.11
			aro.outer_radius = 0.13
			var base := Geometria.pieza(aro, Materiales.emisivo(Color(0.3, 0.85, 0.95), 1.4, Color(0.05, 0.08, 0.1)), Vector3(0.0, 0.012, 0.0), ancla)
			base.scale = Vector3(1.0, 0.4, 1.0)
	vitrina.puzle = puzle


# Maqueta del faro (el objeto del cuarto del farero): torre a franjas, linterna encendida y su haz
func _maqueta_faro(padre: Node3D) -> void:
	var nodo := Escena.grupo(padre, Vector3.ZERO, "Faro")
	var roca := CylinderMesh.new()
	roca.top_radius = 0.12
	roca.bottom_radius = 0.15
	roca.height = 0.05
	var piedra := Materiales.con_textura("piedra", 6.0, 0.9)
	Geometria.pieza(roca, piedra, Vector3(0.0, 0.025, 0.0), nodo)
	for datos in [[Vector3(0.09, 0.05, 0.05), 0.05], [Vector3(-0.08, 0.045, 0.07), 0.04], [Vector3(-0.05, 0.05, -0.09), 0.045]]:
		var bola := SphereMesh.new()
		bola.radius = datos[1]
		bola.height = float(datos[1]) * 1.4
		Geometria.pieza(bola, piedra, datos[0], nodo)
	var blanco := Materiales.liso(Color(0.88, 0.86, 0.8), 0.6)
	var rojo := Materiales.liso(Color(0.62, 0.08, 0.06), 0.55)
	var torre := CylinderMesh.new()
	torre.top_radius = 0.038
	torre.bottom_radius = 0.058
	torre.height = 0.27
	Geometria.pieza(torre, blanco, Vector3(0.0, 0.185, 0.0), nodo)
	for y in [0.1, 0.19]:
		var franja := CylinderMesh.new()
		var r := lerpf(0.058, 0.038, (y - 0.05) / 0.27)
		franja.top_radius = r - 0.002
		franja.bottom_radius = r + 0.002
		franja.height = 0.035
		Geometria.pieza(franja, rojo, Vector3(0.0, y, 0.0), nodo)
	var galeria := CylinderMesh.new()
	galeria.top_radius = 0.052
	galeria.bottom_radius = 0.052
	galeria.height = 0.008
	var hierro := Materiales.liso(Color(0.08, 0.08, 0.09), 0.5, 0.6)
	Geometria.pieza(galeria, hierro, Vector3(0.0, 0.322, 0.0), nodo)
	var cristal := CylinderMesh.new()
	cristal.top_radius = 0.032
	cristal.bottom_radius = 0.032
	cristal.height = 0.045
	cristal.radial_segments = 8
	Geometria.pieza(cristal, Materiales.vidrio(Color(1.0, 0.92, 0.7, 0.25)), Vector3(0.0, 0.35, 0.0), nodo)
	var luz := SphereMesh.new()
	luz.radius = 0.014
	luz.height = 0.028
	Geometria.pieza(luz, Materiales.emisivo(Color(1.0, 0.8, 0.45), 6.0, Color(1.0, 0.8, 0.45)), Vector3(0.0, 0.35, 0.0), nodo)
	var tejado := CylinderMesh.new()
	tejado.top_radius = 0.004
	tejado.bottom_radius = 0.04
	tejado.height = 0.035
	Geometria.pieza(tejado, rojo, Vector3(0.0, 0.39, 0.0), nodo)
	var puerta := QuadMesh.new()
	puerta.size = Vector2(0.022, 0.035)
	Geometria.pieza(puerta, Materiales.liso(Color(0.12, 0.08, 0.05), 0.7), Vector3(0.0, 0.068, 0.0565), nodo)
	Escena.luz(nodo, Vector3(0.0, 0.35, 0.0), Color(1.0, 0.78, 0.45), 0.5, 0.5)
	var haz := Escena.grupo(nodo, Vector3(0.0, 0.35, 0.0), "Haz")
	var cono := CylinderMesh.new()
	cono.top_radius = 0.07
	cono.bottom_radius = 0.008
	cono.height = 0.42
	cono.cap_top = false
	cono.cap_bottom = false
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(1.0, 0.85, 0.55, 0.1)
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var rayo := Geometria.pieza(cono, material, Vector3(0.0, 0.0, 0.21), haz)
	rayo.rotation.x = PI / 2.0
	rayo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


# --- Interfaz -------------------------------------------------------------------------------------

func _interfaz() -> void:
	ui = CanvasLayer.new()
	ui.layer = 10
	add_child(ui)
	var raiz := Control.new()
	raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.theme = Estilo.tema(Color(0.9, 0.74, 0.46))
	ui.add_child(raiz)
	capa_portada = _capa(raiz)
	capa_juegos = _capa(raiz)
	capa_cajas = _capa(raiz)
	_crear_portada()
	_crear_juegos()
	_crear_cajas()


func _capa(raiz: Control) -> Control:
	var capa := Control.new()
	capa.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	capa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.visible = false
	raiz.add_child(capa)
	return capa


func _crear_portada() -> void:
	var sombra := ColorRect.new()
	sombra.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sombra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sombra.material = _degradado(0.0, 0.0, 0.62, 0.0, 0.42)
	capa_portada.add_child(sombra)
	var columna := VBoxContainer.new()
	columna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.alignment = BoxContainer.ALIGNMENT_CENTER
	columna.add_theme_constant_override("separation", 6)
	capa_portada.add_child(columna)
	columna.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	columna.offset_top = 44
	columna.offset_bottom = 300
	var letras := FontVariation.new()
	letras.base_font = Estilo.FUENTE_NEGRITA
	letras.spacing_glyph = 10
	var titulo := Estilo.sombra(Estilo.etiqueta("CUATRO CAJAS", 104, Color(0.98, 0.9, 0.74), letras), 14)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(titulo)
	var frase := Estilo.sombra(Estilo.etiqueta("Una colección de objetos que no quieren abrirse", 38, Estilo.TEXTO, Estilo.FUENTE_CURSIVA), 10)
	frase.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(frase)
	_empezar = Estilo.sombra(Estilo.etiqueta("Toca para empezar", 36, Color(1.0, 0.86, 0.6)), 10)
	_empezar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empezar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_empezar.offset_top = -110
	_empezar.offset_bottom = -60
	capa_portada.add_child(_empezar)
	var version := Estilo.sombra(Estilo.etiqueta(Catalogo.VERSION, 24, Color(0.7, 0.66, 0.6)))
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	version.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	version.offset_left = -520
	version.offset_top = -48
	version.offset_right = -MARGEN
	version.offset_bottom = -12
	capa_portada.add_child(version)


func _crear_juegos() -> void:
	var sombra := ColorRect.new()
	sombra.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sombra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sombra.material = _degradado(0.9, 0.55, 0.0, 0.0, 0.0)
	capa_juegos.add_child(sombra)
	var atras := _boton_icono(capa_juegos, "volver", Control.PRESET_TOP_LEFT, Vector2(MARGEN, MARGEN))
	atras.pressed.connect(func(): ir_a_portada())
	var columna := VBoxContainer.new()
	columna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.alignment = BoxContainer.ALIGNMENT_CENTER
	columna.add_theme_constant_override("separation", 14)
	capa_juegos.add_child(columna)
	columna.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	columna.offset_left = 70
	columna.offset_right = 70 + 600
	columna.offset_top = 110
	columna.offset_bottom = -40
	var letras := FontVariation.new()
	letras.base_font = Estilo.FUENTE_NEGRITA
	letras.spacing_glyph = 4
	_juego_numero = Estilo.etiqueta("", 26, Color(0.9, 0.74, 0.46), letras)
	columna.add_child(_juego_numero)
	_juego_titulo = Estilo.sombra(Estilo.etiqueta("", 62, Color.WHITE, Estilo.FUENTE_NEGRITA), 8)
	_juego_titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	columna.add_child(_juego_titulo)
	_juego_frase = Estilo.sombra(Estilo.etiqueta("", 34, Estilo.TEXTO), 6)
	_juego_frase.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	columna.add_child(_juego_frase)
	_juego_progreso = Estilo.etiqueta("", 28, Estilo.TEXTO_SUAVE, Estilo.FUENTE_CURSIVA)
	columna.add_child(_juego_progreso)
	var hueco := Control.new()
	hueco.custom_minimum_size = Vector2(0, 10)
	hueco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.add_child(hueco)
	var entrar := Button.new()
	entrar.text = "Entrar"
	entrar.icon = Estilo.icono("jugar")
	entrar.expand_icon = false
	entrar.add_theme_constant_override("icon_max_width", 40)
	entrar.custom_minimum_size = Vector2(300, 90)
	entrar.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	entrar.focus_mode = Control.FOCUS_NONE
	entrar.pressed.connect(func(): ir_a_cajas(indice))
	columna.add_child(entrar)
	_botones_ui.append(entrar)
	var anterior := _boton_icono(capa_juegos, "volver", Control.PRESET_CENTER_BOTTOM, Vector2(130, -MARGEN - BOTON))
	anterior.pressed.connect(func(): _deslizar(-1))
	var siguiente := _boton_icono(capa_juegos, "siguiente", Control.PRESET_CENTER_BOTTOM, Vector2(470, -MARGEN - BOTON))
	siguiente.pressed.connect(func(): _deslizar(1))
	_puntos = Estilo.sombra(Estilo.etiqueta("", 30, Color(0.9, 0.78, 0.55)))
	_puntos.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_puntos.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa_juegos.add_child(_puntos)
	Hud.colocar(_puntos, Control.PRESET_CENTER_BOTTOM, Vector2(130 + BOTON, -MARGEN - BOTON + 22), Vector2(470 - 130 - BOTON, 50))


func _crear_cajas() -> void:
	var sombra := ColorRect.new()
	sombra.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sombra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sombra.material = _degradado(0.92, 0.6, 0.0, 0.0, 0.0)
	capa_cajas.add_child(sombra)
	var atras := _boton_icono(capa_cajas, "volver", Control.PRESET_TOP_LEFT, Vector2(MARGEN, MARGEN))
	atras.pressed.connect(func(): ir_a_juegos(indice))
	_cajas_titulo = Estilo.sombra(Estilo.etiqueta("", 50, Color.WHITE, Estilo.FUENTE_NEGRITA), 8)
	capa_cajas.add_child(_cajas_titulo)
	Hud.colocar(_cajas_titulo, Control.PRESET_TOP_LEFT, Vector2(MARGEN + BOTON + 24, MARGEN + 12), Vector2(760, 70))
	_lista_cajas = VBoxContainer.new()
	_lista_cajas.add_theme_constant_override("separation", 16)
	capa_cajas.add_child(_lista_cajas)
	_lista_cajas.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	_lista_cajas.offset_left = 60
	_lista_cajas.offset_right = 60 + 620
	_lista_cajas.offset_top = MARGEN + BOTON + 30
	_lista_cajas.offset_bottom = -30


func _boton_icono(capa: Control, nombre: String, ancla: Control.LayoutPreset, desplazamiento: Vector2) -> Button:
	var boton := Estilo.boton_icono(nombre, Color(0.9, 0.74, 0.46), BOTON)
	capa.add_child(boton)
	Hud.colocar(boton, ancla, desplazamiento, Vector2(BOTON, BOTON))
	_botones_ui.append(boton)
	return boton


# Oscurece una parte de la pantalla para que el texto se lea sobre la sala:
# izquierda (alfa en el borde izquierdo y hasta dónde llega), o arriba (alfa y alto)
func _degradado(izquierda: float, hasta: float, arriba: float, abajo: float, alto: float) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
uniform float izquierda;
uniform float hasta;
uniform float arriba;
uniform float abajo;
uniform float alto;
void fragment() {
	float a = 0.0;
	if (hasta > 0.0) { a = max(a, izquierda * (1.0 - smoothstep(0.0, hasta, UV.x))); }
	if (alto > 0.0) { a = max(a, arriba * (1.0 - smoothstep(0.0, alto, UV.y))); }
	a = max(a, abajo * smoothstep(0.7, 1.0, UV.y));
	COLOR = vec4(0.015, 0.012, 0.01, a);
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("izquierda", izquierda)
	material.set_shader_parameter("hasta", hasta)
	material.set_shader_parameter("arriba", arriba)
	material.set_shader_parameter("abajo", abajo)
	material.set_shader_parameter("alto", alto)
	return material


# --- Pantallas ----------------------------------------------------------------------------------

func ir_a_portada(duracion := 1.4) -> void:
	pantalla = "portada"
	_mostrar(capa_portada)
	_mover_camara(POSICION_PORTADA, MIRA_PORTADA, 42.0, duracion)
	for i in _focos.size():
		_focos[i] = 8.0


func ir_a_juegos(numero: int, duracion := 1.1) -> void:
	indice = posmod(numero, vitrinas.size())
	pantalla = "juegos"
	var datos: Dictionary = Catalogo.JUEGOS[indice]
	_juego_numero.text = "JUEGO %d DE %d" % [indice + 1, Catalogo.JUEGOS.size()]
	_juego_titulo.text = datos.titulo
	_juego_titulo.add_theme_color_override("font_color", (datos.acento as Color).lightened(0.25))
	_juego_frase.text = datos.frase
	_juego_progreso.text = _texto_progreso(datos)
	var marcas := ""
	for i in vitrinas.size():
		marcas += ("●" if i == indice else "○") + ("   " if i < vitrinas.size() - 1 else "")
	_puntos.text = marcas
	_mostrar(capa_juegos)
	_mirar_vitrina(1.08, 0.25, duracion)


func ir_a_cajas(numero: int, duracion := 1.0) -> void:
	indice = posmod(numero, vitrinas.size())
	pantalla = "cajas"
	var datos: Dictionary = Catalogo.JUEGOS[indice]
	_cajas_titulo.text = datos.titulo
	_cajas_titulo.add_theme_color_override("font_color", (datos.acento as Color).lightened(0.25))
	_llenar_cajas(datos)
	_mostrar(capa_cajas)
	_mirar_vitrina(0.82, 0.21, duracion)


func _mostrar(capa: Control) -> void:
	for otra in [capa_portada, capa_juegos, capa_cajas]:
		otra.visible = otra == capa
	capa.modulate.a = 0.0
	create_tween().tween_property(capa, "modulate:a", 1.0, 0.45)


func _mirar_vitrina(distancia: float, desplazamiento: float, duracion: float) -> void:
	var centro: Vector3 = vitrinas[indice].centro
	var hacia := POSICION_PORTADA - centro
	hacia.y = 0.0
	hacia = hacia.normalized()
	var derecha := (-hacia).cross(Vector3.UP).normalized()
	var posicion := centro + hacia * distancia + Vector3.UP * distancia * 0.32 - derecha * desplazamiento
	_mover_camara(posicion, centro - derecha * desplazamiento + Vector3.UP * 0.02, 40.0, duracion)
	for i in _focos.size():
		_focos[i] = 9.0 if i == indice else 2.5
	if duracion > 0.05:
		sonido.sonar("acercar", -12.0, 0.9)


func _texto_progreso(datos: Dictionary) -> String:
	var abiertas := 0
	var jugables := 0
	var mejor := INF
	for caja in datos.cajas:
		if caja.has("script"):
			jugables += 1
		if resultados and resultados.has_section(caja.id):
			abiertas += 1
			mejor = minf(mejor, float(resultados.get_value(caja.id, "mejor_tiempo", INF)))
	if abiertas == 0:
		return "%d de %d %s · sin abrir" % [jugables, datos.cajas.size(), "lista" if jugables == 1 else "listas"]
	return "%d de %d abiertas · mejor tiempo %s" % [abiertas, datos.cajas.size(), Estilo.formato_tiempo(mejor)]


func _llenar_cajas(datos: Dictionary) -> void:
	for hijo in _lista_cajas.get_children():
		_botones_ui.erase(hijo)
		hijo.queue_free()
	botones_cajas.clear()
	var acento: Color = datos.acento
	for caja_simple in datos.cajas:
		var caja := Catalogo.caja(caja_simple.id)
		var jugable := Catalogo.jugable(caja)
		var boton := Button.new()
		boton.custom_minimum_size = Vector2(600, 128)
		boton.focus_mode = Control.FOCUS_NONE
		boton.disabled = not jugable
		boton.theme = Estilo.tema(acento)
		_lista_cajas.add_child(boton)
		_botones_ui.append(boton)
		botones_cajas[caja.id] = boton
		var fila := HBoxContainer.new()
		fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fila.add_theme_constant_override("separation", 20)
		fila.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		fila.offset_left = 22
		fila.offset_right = -18
		boton.add_child(fila)
		var icono := TextureRect.new()
		icono.texture = Estilo.icono("jugar" if jugable else "candado")
		icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icono.custom_minimum_size = Vector2(52, 52)
		icono.modulate = acento.lightened(0.2) if jugable else Color(0.55, 0.53, 0.5)
		icono.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fila.add_child(icono)
		var textos := VBoxContainer.new()
		textos.mouse_filter = Control.MOUSE_FILTER_IGNORE
		textos.alignment = BoxContainer.ALIGNMENT_CENTER
		textos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		textos.add_theme_constant_override("separation", 2)
		fila.add_child(textos)
		var nombre := Estilo.etiqueta(caja.nombre, 40, Color.WHITE if jugable else Color(0.62, 0.6, 0.57), Estilo.FUENTE_NEGRITA)
		nombre.mouse_filter = Control.MOUSE_FILTER_IGNORE
		textos.add_child(nombre)
		var detalle := Estilo.etiqueta(caja.frase if jugable else "Sellada · se abrirá si este juego sigue adelante", 26,
			Estilo.TEXTO if jugable else Color(0.6, 0.58, 0.55))
		detalle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		detalle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		textos.add_child(detalle)
		if jugable:
			var marca := Estilo.etiqueta(_texto_resultado(caja.id), 26, acento.lightened(0.3), Estilo.FUENTE_CURSIVA)
			marca.mouse_filter = Control.MOUSE_FILTER_IGNORE
			textos.add_child(marca)
			var id: String = caja.id
			boton.pressed.connect(func(): _elegir(id))


func _texto_resultado(id: String) -> String:
	if resultados == null or not resultados.has_section(id):
		return "Sin abrir"
	var mejor: float = resultados.get_value(id, "mejor_tiempo", INF)
	var pistas: int = resultados.get_value(id, "pistas_mejor", 0)
	return "Abierta · mejor tiempo %s · %d %s" % [Estilo.formato_tiempo(mejor), pistas, "pista" if pistas == 1 else "pistas"]


func _elegir(id: String) -> void:
	sonido.sonar("toque", -6.0)
	elegida.emit(id)


func _deslizar(direccion: int) -> void:
	sonido.sonar("toque", -10.0)
	if pantalla == "cajas":
		ir_a_cajas(indice + direccion)
	else:
		ir_a_juegos(indice + direccion)


# --- Cámara ----------------------------------------------------------------------------------

func _transformada(posicion: Vector3, mira: Vector3) -> Transform3D:
	return Transform3D(Basis.looking_at(mira - posicion, Vector3.UP), posicion)


func _mover_camara(posicion: Vector3, mira: Vector3, fov: float, duracion: float) -> void:
	_desde = camara.global_transform
	_fov_desde = camara.fov
	_hacia = _transformada(posicion, mira)
	_fov_hacia = fov
	_progreso = 0.0
	var animacion := create_tween()
	animacion.tween_property(self, "_progreso", 1.0, maxf(duracion, 0.01)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _process(delta: float) -> void:
	_tiempo += delta
	var vista := _desde.interpolate_with(_hacia, _progreso)
	# respiración lenta de la cámara, para que la sala no parezca una foto
	var amplitud := 0.035 if pantalla == "portada" else 0.008
	vista.origin += vista.basis.x * sin(_tiempo * 0.31) * amplitud + vista.basis.y * sin(_tiempo * 0.23) * amplitud * 0.5
	camara.global_transform = vista
	camara.fov = lerpf(_fov_desde, _fov_hacia, _progreso)
	for i in vitrinas.size():
		var foco: SpotLight3D = vitrinas[i].foco
		foco.light_energy = move_toward(foco.light_energy, _focos[i], delta * 9.0)
		var puzle: Puzle = vitrinas[i].puzle
		if puzle:
			puzle.animar_vitrina(delta, camara, pantalla != "portada" and i == indice)
	if _empezar and capa_portada.visible:
		_empezar.modulate.a = 0.55 + 0.45 * sin(_tiempo * 2.6)
	for haz in find_children("Haz", "Node3D", true, false):
		(haz as Node3D).rotation.y += delta * 0.9


# --- Toques ----------------------------------------------------------------------------------

func _unhandled_input(evento: InputEvent) -> void:
	if not evento is InputEventScreenTouch:
		return
	if evento.pressed:
		if _toca_ui(evento.position):
			_toque = {}
			return
		_toque = {"posicion": evento.position, "ms": Time.get_ticks_msec(), "indice": evento.index}
		return
	if _toque.is_empty() or evento.index != _toque.indice:
		return
	var desplazamiento: Vector2 = evento.position - _toque.posicion
	var escala := 720.0 / maxf(1.0, get_viewport().get_visible_rect().size.y)
	var breve := Time.get_ticks_msec() - int(_toque.ms) < 500
	_toque = {}
	if pantalla == "portada":
		if desplazamiento.length() * escala < 30.0:
			var vitrina := _vitrina_en(evento.position)
			sonido.sonar("toque", -8.0)
			ir_a_juegos(vitrina if vitrina >= 0 else 0)
		return
	if absf(desplazamiento.x) * escala > 70.0 and absf(desplazamiento.x) > absf(desplazamiento.y) * 1.3:
		_deslizar(-1 if desplazamiento.x > 0.0 else 1)
	elif desplazamiento.length() * escala < 18.0 and breve:
		var vitrina := _vitrina_en(evento.position)
		if vitrina < 0:
			return
		if vitrina != indice and pantalla == "juegos":
			ir_a_juegos(vitrina)
		elif vitrina != indice:
			ir_a_cajas(vitrina)
		elif pantalla == "juegos":
			ir_a_cajas(indice)


func _toca_ui(posicion: Vector2) -> bool:
	for boton in _botones_ui:
		if is_instance_valid(boton) and boton.is_visible_in_tree() and (boton as Control).get_global_rect().has_point(posicion):
			return true
	return false


func _vitrina_en(posicion: Vector2) -> int:
	var origen := camara.project_ray_origin(posicion)
	var direccion := camara.project_ray_normal(posicion)
	var consulta := PhysicsRayQueryParameters3D.create(origen, origen + direccion * 30.0)
	var excluir: Array[RID] = []
	for intento in 8:
		consulta.exclude = excluir
		var resultado := get_world_3d().direct_space_state.intersect_ray(consulta)
		if resultado.is_empty():
			return -1
		var nodo: Node = resultado.collider
		while nodo:
			if nodo.has_meta("vitrina"):
				return int(nodo.get_meta("vitrina"))
			nodo = nodo.get_parent()
		excluir.append(resultado.rid)
	return -1
