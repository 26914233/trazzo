# La caja del relojero: Londres, 1891. Edmund Whitcombe desapareció y dejó esta caja de caoba y
# latón sobre su escritorio. El reloj de la tapa es la llave: hay que darle cuerda y poner las horas
# que importan (las que cuentan la carta y el billete de tren). Le falta un engranaje a la maquinaria.
#
# Pasos: cuerda → las tres en punto (se suelta el cajón) → abrir el cajón → coger el engranaje →
# ponerlo en la maquinaria de atrás → las 9:45 (se suelta la tapa) → abrir la tapa.
# El escritorio está en medio de su taller (salas/taller.gd), con la carta y la lámpara de banquero.
extends Puzle

const Taller := preload("res://scripts/salas/taller.gd")

const ANCHO := 0.3
const ALTO := 0.14
const FONDO := 0.2
const ALTO_CUERPO := 0.11             # la tapa va de 0.11 a 0.14
const PASO_HORA := TAU / 12.0
const VUELTAS_CUERDA := 2.0
const CAJON_SUELTO := 0.012
const CAJON_ABIERTO := 0.085

var caja: Node3D
var tapa: PiezaBisagra
var aguja_hora: PiezaGiratoria
var aguja_minuto: PiezaGiratoria
var manivela: PiezaGiratoria
var cajon: PiezaDeslizante
var engranaje: PiezaRecogible
var eje_vacio: PiezaRanura
var maquinaria: Array = []            # engranajes que giran cuando la máquina está completa
var reloj_bolsillo: Node3D
var aguja_bolsillo: Node3D
var lampara: OmniLight3D
var sala: Node3D
var en_marcha := false
var cierre_suelto := false
var cajon_bloqueado_antes := false    # para la prueba: el cajón no se abría antes de tiempo
var meneos := 0                       # veces que el minutero dijo que no (lo mira la prueba)
var _tiempo := 0.0
var _ruido := FastNoiseLite.new()

var caoba: Material
var laton: Material
var terciopelo: Material


func construir() -> void:
	caoba = Materiales.con_textura("caoba", 5.0, 0.3, 0.0, Color(0.62, 0.5, 0.46), 0.6)
	laton = Materiales.laton(0.3)
	terciopelo = Materiales.liso(Color(0.32, 0.03, 0.05), 0.95)
	caja = Escena.grupo(self, Vector3.ZERO, "Caja")
	_cuerpo()
	_tapa_y_reloj()
	_manivela()
	_cajon()
	_maquinaria()
	_pasos()
	_zonas()


func construir_sala() -> void:
	sala = Taller.new()
	add_child(sala)
	sala.construir()
	_escritorio()


# --- Escritorio, carta, lámpara y otros objetos ------------------------------------------------------

func _escritorio() -> void:
	var nogal := Materiales.con_textura("madera_oscura", 2.0, 0.45)
	Escena.bloque(Vector3(-0.8, -0.045, -0.5), Vector3(0.8, 0.0, 0.45), nogal, self, 0.004, false)
	Escena.bloque(Vector3(-0.62, 0.0, -0.36), Vector3(0.62, 0.0012, 0.32), Materiales.con_textura("cuero_verde", 3.0, 0.75), self, 0.0, false)
	# cajoneras a los lados y el faldón: un escritorio de socios, con hueco para las piernas
	var suelo: float = Taller.SUELO
	for lado in [-1.0, 1.0]:
		Escena.bloque(Vector3(lado * 0.78 - 0.21, suelo, -0.46), Vector3(lado * 0.78 + 0.21, -0.045, 0.41), nogal, self, 0.006, false)
		for k in 3:
			var y := suelo + 0.08 + k * 0.21
			Escena.bloque(Vector3(lado * 0.78 - 0.18, y, 0.41), Vector3(lado * 0.78 + 0.18, y + 0.18, 0.425), nogal, self, 0.004, false)
			var tirador := SphereMesh.new()
			tirador.radius = 0.012
			tirador.height = 0.024
			Geometria.pieza(tirador, Materiales.laton(0.3), Vector3(lado * 0.78, y + 0.09, 0.437), self)
	Escena.bloque(Vector3(-0.57, -0.2, -0.44), Vector3(0.57, -0.045, -0.4), nogal, self, 0.004, false)
	Escena.bloque(Vector3(-0.57, -0.14, 0.39), Vector3(0.57, -0.045, 0.43), nogal, self, 0.004, false)
	var carta := PiezaNota.new()
	carta.id = "carta"
	carta.titulo = "Carta sin enviar"
	carta.texto = "Querido Arthur:\n\nSi esta caja ha llegado a tus manos, es que no he vuelto. No la fuerces: dale cuerda y escucha. Recuerda las horas que importan, como yo las recuerdo.\n\nTe escribo a las tres en punto, la hora a la que todo empezó.\n\n— E. Whitcombe, Londres, 1891"
	carta.position = Vector3(-0.27, 0.0016, 0.13)
	carta.rotation = Vector3(0.0, 0.28, 0.0)
	Escena.calcomania(Materiales.textura("carta"), Vector2(0.115, 0.158), Color.WHITE, carta,
		Transform3D(Basis(Vector3.RIGHT, -PI / 2.0), Vector3.ZERO))
	carta.colisor_caja(Vector3(0.12, 0.004, 0.16))
	agregar(carta)
	# lámpara de banquero: pie de latón y pantalla verde
	var lampara_nodo := Escena.grupo(self, Vector3(-0.44, 0.0, -0.24), "Lampara")
	var pie := CylinderMesh.new()
	pie.top_radius = 0.05
	pie.bottom_radius = 0.065
	pie.height = 0.02
	Geometria.pieza(pie, laton, Vector3(0.0, 0.01, 0.0), lampara_nodo)
	var palo := CylinderMesh.new()
	palo.top_radius = 0.007
	palo.bottom_radius = 0.007
	palo.height = 0.27
	Geometria.pieza(palo, laton, Vector3(0.0, 0.15, 0.0), lampara_nodo)
	var pantalla := CylinderMesh.new()
	pantalla.top_radius = 0.035
	pantalla.bottom_radius = 0.1
	pantalla.height = 0.07
	var verde := Materiales.liso(Color(0.06, 0.28, 0.12), 0.15)
	verde.emission_enabled = true
	verde.emission = Color(0.1, 0.5, 0.2)
	verde.emission_energy_multiplier = 0.3
	Geometria.pieza(pantalla, verde, Vector3(0.0, 0.29, 0.0), lampara_nodo)
	lampara = Escena.luz(lampara_nodo, Vector3(0.0, 0.25, 0.04), Color(1.0, 0.78, 0.5), 1.6, 2.2, true)
	# tintero y libros
	var tintero := CylinderMesh.new()
	tintero.top_radius = 0.02
	tintero.bottom_radius = 0.028
	tintero.height = 0.04
	Geometria.pieza(tintero, Materiales.liso(Color(0.02, 0.03, 0.05), 0.08), Vector3(0.33, 0.02, -0.16), self)
	var pluma := Geometria.pieza(Geometria.caja(Vector3(0.004, 0.18, 0.012), 0.001), Materiales.liso(Color(0.85, 0.82, 0.75), 0.7),
		Vector3(0.35, 0.09, -0.15), self)
	pluma.rotation = Vector3(0.0, 0.4, -0.35)
	for k in 2:
		var color: Color = [Color(0.35, 0.08, 0.06), Color(0.1, 0.16, 0.3)][k]
		var libro := Geometria.pieza(Geometria.caja(Vector3(0.18, 0.035, 0.24), 0.004), Materiales.liso(color, 0.7),
			Vector3(0.46, 0.0175 + k * 0.035, 0.06), self)
		libro.rotation.y = 0.2 - k * 0.25


# --- Cuerpo de caoba con un hueco forrado de terciopelo arriba -------------------------------------

func _cuerpo() -> void:
	var w := ANCHO / 2.0
	var f := FONDO / 2.0
	var h := ALTO_CUERPO
	var hx := 0.11
	var hz := 0.065
	var suelo := 0.08
	Escena.bloque(Vector3(-w, 0.0, -f), Vector3(w, suelo, f), caoba, caja, 0.003)
	Escena.bloque(Vector3(-w, suelo, -f), Vector3(-hx, h, f), caoba, caja, 0.002)
	Escena.bloque(Vector3(hx, suelo, -f), Vector3(w, h, f), caoba, caja, 0.002)
	Escena.bloque(Vector3(-hx, suelo, hz), Vector3(hx, h, f), caoba, caja, 0.002)
	Escena.bloque(Vector3(-hx, suelo, -f), Vector3(hx, h, -hz), caoba, caja, 0.002)
	Escena.bloque(Vector3(-hx, suelo, -hz), Vector3(hx, suelo + 0.0015, hz), terciopelo, caja, 0.0, false)
	# esquinas de latón y la placa del frente
	for x in [-w, w]:
		for z in [-f, f]:
			Escena.bloque(Vector3(x - 0.007, 0.0, z - 0.007), Vector3(x + 0.007, 0.03, z + 0.007), laton, caja, 0.002, false)
	Escena.bloque(Vector3(-0.055, 0.04, f), Vector3(0.055, 0.064, f + 0.002), laton, caja, 0.001, false)
	var grabado := Label3D.new()
	grabado.text = "E. WHITCOMBE · RELOJERO"
	grabado.font = load("res://recursos/fuentes/LiberationSerif-Bold.ttf")
	grabado.font_size = 64
	grabado.pixel_size = 0.00013
	grabado.modulate = Color(0.18, 0.1, 0.05)
	grabado.outline_size = 0
	grabado.shaded = true
	grabado.position = Vector3(0.0, 0.052, f + 0.0026)
	caja.add_child(grabado)
	# reloj de bolsillo y nota en el hueco (se ven al final)
	reloj_bolsillo = Escena.grupo(caja, Vector3(0.03, suelo + 0.004, 0.0), "RelojBolsillo")
	var cuerpo_reloj := CylinderMesh.new()
	cuerpo_reloj.top_radius = 0.026
	cuerpo_reloj.bottom_radius = 0.026
	cuerpo_reloj.height = 0.008
	cuerpo_reloj.radial_segments = 40
	Geometria.pieza(cuerpo_reloj, laton, Vector3.ZERO, reloj_bolsillo)
	var esfera := QuadMesh.new()
	esfera.size = Vector2(0.044, 0.044)
	var material_esfera := StandardMaterial3D.new()
	material_esfera.albedo_texture = Materiales.textura("esfera_reloj")
	material_esfera.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	var cara := Geometria.pieza(esfera, material_esfera, Vector3(0.0, 0.0042, 0.0), reloj_bolsillo)
	cara.rotation = Vector3(-PI / 2.0, 0.0, 0.0)
	aguja_bolsillo = Escena.grupo(reloj_bolsillo, Vector3(0.0, 0.0046, 0.0), "Aguja")
	Geometria.pieza(Geometria.caja(Vector3(0.0016, 0.0008, 0.018), 0.0), Materiales.liso(Color(0.05, 0.05, 0.06), 0.4),
		Vector3(0.0, 0.0, -0.008), aguja_bolsillo)
	var nota := Escena.calcomania(Materiales.textura("papel"), Vector2(0.06, 0.04), Color(0.95, 0.92, 0.85), caja,
		Transform3D(Basis(Vector3.UP, 0.3) * Basis(Vector3.RIGHT, -PI / 2.0), Vector3(-0.055, suelo + 0.002, 0.01)))
	nota.material_override.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED


# --- Tapa con el reloj: las agujas se mueven con el dedo -------------------------------------------

func _tapa_y_reloj() -> void:
	tapa = PiezaBisagra.new()
	tapa.id = "tapa"
	tapa.position = Vector3(0.0, ALTO_CUERPO, -FONDO / 2.0)
	tapa.configurar_bisagra(Vector3.RIGHT, -1.85)
	var alto_tapa := ALTO - ALTO_CUERPO
	Escena.bloque(Vector3(-ANCHO / 2.0, 0.0, 0.0), Vector3(ANCHO / 2.0, alto_tapa, FONDO), caoba, tapa, 0.003, false)
	Escena.bloque(Vector3(-0.105, -0.001, 0.04), Vector3(0.105, 0.0, FONDO - 0.04), terciopelo, tapa, 0.0, false)
	for x in [-ANCHO / 2.0, ANCHO / 2.0]:
		for z in [0.0, FONDO]:
			Escena.bloque(Vector3(x - 0.007, 0.0, z - 0.007), Vector3(x + 0.007, alto_tapa, z + 0.007), laton, tapa, 0.002, false)
	tapa.colisor_caja(Vector3(ANCHO, alto_tapa + 0.002, FONDO), Vector3(0.0, alto_tapa / 2.0, FONDO / 2.0))
	tapa.permiso = func() -> bool: return cierre_suelto
	tapa.aviso_bloqueo = "La tapa está cerrada por dentro. Quizá el reloj tenga algo que ver."
	agregar(tapa, caja)
	tapa.accionada.connect(func(_p):
		if tapa.abierta():
			completar("tapa"))
	# esfera y bisel de latón
	var centro := Vector3(0.0, alto_tapa, FONDO / 2.0)
	var aro := MeshInstance3D.new()
	var toro := TorusMesh.new()
	toro.inner_radius = 0.064
	toro.outer_radius = 0.071
	toro.rings = 64
	toro.ring_segments = 10
	aro.mesh = toro
	aro.material_override = laton
	aro.scale = Vector3(1.0, 0.5, 1.0)
	aro.position = centro + Vector3(0.0, 0.001, 0.0)
	tapa.add_child(aro)
	var esfera := QuadMesh.new()
	esfera.size = Vector2(0.13, 0.13)
	var material := StandardMaterial3D.new()
	material.albedo_texture = Materiales.textura("esfera_reloj")
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.roughness = 0.35
	var cara := Geometria.pieza(esfera, material, centro + Vector3(0.0, 0.0006, 0.0), tapa)
	cara.rotation = Vector3(-PI / 2.0, 0.0, 0.0)
	aguja_hora = _aguja("aguja_hora", centro + Vector3(0.0, 0.0016, 0.0), 0.036, 0.007, 7)
	aguja_minuto = _aguja("aguja_minuto", centro + Vector3(0.0, 0.003, 0.0), 0.055, 0.0045, 2)
	var tapon := CylinderMesh.new()
	tapon.top_radius = 0.005
	tapon.bottom_radius = 0.005
	tapon.height = 0.004
	Geometria.pieza(tapon, laton, centro + Vector3(0.0, 0.004, 0.0), tapa)


# Aguja: un rombo alargado de acero pavonado que gira en pasos de una hora (o de cinco minutos)
func _aguja(id_aguja: String, posicion: Vector3, largo: float, ancho: float, inicial: int) -> PiezaGiratoria:
	var aguja := PiezaGiratoria.new()
	aguja.id = id_aguja
	aguja.position = posicion
	aguja.configurar(Vector3.UP, PASO_HORA)
	aguja.sonido_tope = "clic_metal"
	aguja.volumen_tope = -10.0
	var forma := PackedVector2Array([Vector2(0.0, -largo * 0.18), Vector2(ancho / 2.0, 0.0), Vector2(0.0, largo),
		Vector2(-ancho / 2.0, 0.0)])
	# la malla va en un pivote propio: así la aguja puede menearse («no, no») sin cambiar la hora
	var meneo := Escena.grupo(aguja, Vector3.ZERO, "Meneo")
	aguja.set_meta("meneo", meneo)
	var malla := Geometria.pieza(Geometria.extruir(forma, 0.0012), Materiales.liso(Color(0.05, 0.06, 0.1), 0.3, 0.6),
		Vector3.ZERO, meneo)
	malla.rotation = Vector3(-PI / 2.0, 0.0, 0.0)
	# solo la parte de fuera de cada aguja se puede agarrar, para no confundirlas
	var desde := 0.012 if id_aguja == "aguja_hora" else 0.04
	aguja.colisor_caja(Vector3(0.016, 0.004, largo - desde + 0.006), Vector3(0.0, 0.0, -(desde + largo) / 2.0))
	aguja.angulo = -inicial * PASO_HORA
	aguja.reposo = aguja.angulo
	aguja.permiso = func() -> bool: return en_marcha
	aguja.aviso_bloqueo = "Las agujas no se mueven: el reloj está parado."
	agregar(aguja, tapa)
	aguja.accionada.connect(func(_p): _comprobar_hora())
	return aguja


# --- La resistencia: el reloj dice que no -------------------------------------------------------------

# Cuando algo no se deja, ni se mueve ni se marca: el minutero se menea como un dedo («no, no») y cae
# polvo de latón de lo que tocaste. Si insistes, se menean las dos agujas. Si lo que no se deja son las
# propias agujas, es que el reloj está parado y ni siquiera puede menearse: solo cae el polvo.
func resistir(pieza: Pieza, punto: Vector3, veces: int) -> void:
	Efectos.polvo(self, punto, Color(0.95, 0.78, 0.42), 18 + 6 * mini(veces, 3), 1.6)
	if pieza == aguja_hora or pieza == aguja_minuto:
		return
	meneos += 1
	_menear(aguja_minuto, 0.34)
	if veces >= 3:
		_menear(aguja_hora, 0.26)


func _menear(aguja: PiezaGiratoria, amplitud: float) -> void:
	var meneo: Node3D = aguja.get_meta("meneo")
	if aguja.has_meta("animacion_meneo"):
		var anterior: Tween = aguja.get_meta("animacion_meneo")
		if anterior and anterior.is_valid():
			anterior.kill()
	var animacion := create_tween()
	for angulo in [amplitud, -amplitud, amplitud * 0.6, -amplitud * 0.6, 0.0]:
		animacion.tween_property(meneo, "rotation:y", angulo, 0.085).set_trans(Tween.TRANS_SINE)
	aguja.set_meta("animacion_meneo", animacion)
	mesa.sonido.sonar("clic_metal", -16.0, 1.6)


func hora() -> int:
	return posmod(-aguja_hora.tope(), 12)


func minutos() -> int:
	return posmod(-aguja_minuto.tope(), 12) * 5


func _comprobar_hora() -> void:
	if not en_marcha:
		return
	if hora() == 3 and minutos() == 0 and not hecho("tres"):
		completar("tres")
		_campanadas(3)
		mesa.sonido.sonar("mecanismo", -4.0)
		cajon.mover_a(CAJON_SUELTO, 0.25)
		mesa.mensaje("Tres campanadas… y algo se ha soltado en un costado.", 3.6)
	elif hora() == 9 and minutos() == 45 and hecho("insertar") and not hecho("tren"):
		completar("tren")
		_campanadas(1)
		mesa.sonido.sonar("mecanismo", -2.0)
		cierre_suelto = true
		tapa.mover_a(-0.07, 0.2)
		mesa.mensaje("Un chasquido en la tapa: el cierre se ha soltado.", 3.6)


func _campanadas(veces: int) -> void:
	for k in veces:
		mesa.sonido.sonar("campanada", -4.0, 1.0, 0.0)
		await get_tree().create_timer(1.1).timeout


# --- Manivela de la cuerda (costado derecho) ------------------------------------------------------

func _manivela() -> void:
	manivela = PiezaGiratoria.new()
	manivela.id = "manivela"
	manivela.position = Vector3(ANCHO / 2.0 + 0.006, 0.062, 0.0)
	manivela.configurar(Vector3.RIGHT, TAU / 8.0)
	manivela.sonido_tope = "cuerda"
	manivela.volumen_tope = -2.0
	manivela.radio_minimo = 0.03
	var eje := CylinderMesh.new()
	eje.top_radius = 0.006
	eje.bottom_radius = 0.008
	eje.height = 0.012
	var eje_malla := Geometria.pieza(eje, laton, Vector3.ZERO, manivela)
	eje_malla.rotation = Vector3(0.0, 0.0, PI / 2.0)
	Geometria.pieza(Geometria.caja(Vector3(0.005, 0.042, 0.008), 0.0015), laton, Vector3(0.004, 0.02, 0.0), manivela)
	var pomo := CylinderMesh.new()
	pomo.top_radius = 0.006
	pomo.bottom_radius = 0.007
	pomo.height = 0.022
	var pomo_malla := Geometria.pieza(pomo, Materiales.con_textura("madera_oscura", 10.0, 0.4), Vector3(0.016, 0.038, 0.0), manivela)
	pomo_malla.rotation = Vector3(0.0, 0.0, PI / 2.0)
	manivela.colisor_caja(Vector3(0.04, 0.06, 0.03), Vector3(0.012, 0.022, 0.0))
	agregar(manivela, caja)
	manivela.accionada.connect(func(_p): _comprobar_cuerda())


func _comprobar_cuerda() -> void:
	if absf(manivela.angulo) >= VUELTAS_CUERDA * TAU - 0.05 and not hecho("cuerda"):
		en_marcha = true
		completar("cuerda")
		mesa.sonido.bucle("tictac", -9.0, 0.5)
		mesa.mensaje("El reloj ha empezado a andar.", 3.0)


# --- Cajón del costado izquierdo, con el engranaje y el billete ------------------------------------

func _cajon() -> void:
	cajon = PiezaDeslizante.new()
	cajon.id = "cajon"
	cajon.position = Vector3(-ANCHO / 2.0 - 0.003, 0.035, 0.0)
	cajon.configurar(Vector3.LEFT, 0.0, CAJON_ABIERTO, [0.0, CAJON_SUELTO, CAJON_ABIERTO])
	cajon.sonido_mover = "deslizar_madera"
	cajon.sonido_tope = "tope_madera"
	cajon.permiso = func() -> bool: return hecho("tres")
	cajon.aviso_bloqueo = "Hay un cajón, pero está trabado."
	var frente := Vector3(0.006, 0.05, 0.13)
	Geometria.pieza(Geometria.caja(frente, 0.0015), caoba, Vector3.ZERO, cajon)
	var tirador := SphereMesh.new()
	tirador.radius = 0.0065
	tirador.height = 0.013
	Geometria.pieza(tirador, laton, Vector3(-0.007, 0.0, 0.0), cajon)
	# bandeja (queda dentro de la caja hasta que se abre)
	var bandeja := Escena.grupo(cajon, Vector3(0.05, 0.0, 0.0), "Bandeja")
	Escena.bloque(Vector3(-0.047, -0.022, -0.06), Vector3(0.047, -0.018, 0.06), terciopelo, bandeja, 0.0, false)
	Escena.bloque(Vector3(-0.047, -0.022, -0.062), Vector3(0.047, 0.018, -0.058), caoba, bandeja, 0.0, false)
	Escena.bloque(Vector3(-0.047, -0.022, 0.058), Vector3(0.047, 0.018, 0.062), caoba, bandeja, 0.0, false)
	Escena.bloque(Vector3(0.043, -0.022, -0.06), Vector3(0.047, 0.018, 0.06), caoba, bandeja, 0.0, false)
	cajon.colisor_caja(frente + Vector3(0.004, 0.0, 0.0), Vector3(-0.001, 0.0, 0.0))
	agregar(cajon, caja)
	cajon.accionada.connect(func(_p):
		if cajon.en(CAJON_ABIERTO) and not hecho("cajon"):
			completar("cajon")
			mesa.camara.enfocar(Vector3(-0.2, 0.03, 0.0), 0.42, -1.1, 0.75, 1.4))

	engranaje = PiezaRecogible.new()
	engranaje.id = "engranaje"
	engranaje.nombre_objeto = "Engranaje de latón"
	engranaje.position = Vector3(0.025, -0.0145, -0.02)
	engranaje.modelo = Escena.grupo(engranaje, Vector3.ZERO, "Modelo")
	var rueda := Geometria.pieza(Geometria.engranaje(0.016, 14, 0.004), laton, Vector3.ZERO, engranaje.modelo)
	rueda.rotation = Vector3(-PI / 2.0, 0.0, 0.0)
	engranaje.colisor_caja(Vector3(0.036, 0.012, 0.036))
	engranaje.permiso = func() -> bool: return cajon.reposo > CAJON_ABIERTO - 0.01
	agregar(engranaje, bandeja)
	engranaje.accionada.connect(func(_p): completar("engranaje"))

	var billete := PiezaNota.new()
	billete.id = "billete"
	billete.titulo = "Billete de tren"
	billete.texto = "GREAT NORTHERN RAILWAY\nLondres King's Cross → Whitby\n\nSalida: 9:45\n\n12 de noviembre de 1891 · tercera clase\n\n(Al dorso, a lápiz: «Si no vuelvo, la caja recuerda la hora».)"
	billete.position = Vector3(-0.012, -0.0172, 0.025)
	billete.rotation = Vector3(0.0, -0.3, 0.0)
	Escena.calcomania(Materiales.textura("billete"), Vector2(0.06, 0.03), Color.WHITE, billete,
		Transform3D(Basis(Vector3.RIGHT, -PI / 2.0), Vector3.ZERO))
	billete.colisor_caja(Vector3(0.062, 0.006, 0.032))
	billete.permiso = func() -> bool: return cajon.reposo > CAJON_ABIERTO - 0.01
	agregar(billete, bandeja)


# --- Maquinaria detrás del cristal (trasera): le falta un engranaje --------------------------------

func _maquinaria() -> void:
	var trasera := Escena.grupo(caja, Vector3(0.0, 0.058, -FONDO / 2.0), "Maquinaria")
	trasera.rotation.y = PI
	Escena.bloque(Vector3(-0.075, -0.04, 0.0), Vector3(0.075, 0.04, 0.002), Materiales.con_textura("laton", 12.0, 0.5, 0.7, Color(0.5, 0.4, 0.28)), trasera, 0.0, false)
	Escena.luz(trasera, Vector3(0.0, 0.03, 0.012), Color(1.0, 0.82, 0.58), 0.22, 0.2)
	for lado in [[Vector3(-0.078, -0.043, 0.0), Vector3(0.078, -0.037, 0.016)], [Vector3(-0.078, 0.037, 0.0), Vector3(0.078, 0.043, 0.016)],
			[Vector3(-0.078, -0.043, 0.0), Vector3(-0.072, 0.043, 0.016)], [Vector3(0.072, -0.043, 0.0), Vector3(0.078, 0.043, 0.016)]]:
		Escena.bloque(lado[0], lado[1], laton, trasera, 0.001, false)
	var cristal := MeshInstance3D.new()
	var plano := QuadMesh.new()
	plano.size = Vector2(0.146, 0.074)
	cristal.mesh = plano
	cristal.material_override = Materiales.vidrio()
	cristal.position = Vector3(0.0, 0.0, 0.0155)
	trasera.add_child(cristal)
	for datos in [[Vector3(-0.045, 0.008, 0.006), 0.022, 16, 1.0], [Vector3(-0.012, -0.012, 0.006), 0.014, 11, -1.45],
			[Vector3(0.048, 0.006, 0.006), 0.024, 18, -0.92]]:
		var nodo := Escena.grupo(trasera, datos[0], "Engranaje")
		Geometria.pieza(Geometria.engranaje(datos[1], datos[2], 0.004), laton, Vector3.ZERO, nodo)
		maquinaria.append([nodo, datos[3]])
	# eje vacío donde va el engranaje que falta
	eje_vacio = PiezaRanura.new()
	eje_vacio.id = "eje_vacio"
	eje_vacio.acepta = "engranaje"
	eje_vacio.aviso_vacia = "Un eje vacío: aquí falta un engranaje."
	eje_vacio.position = Vector3(0.017, 0.018, 0.006)
	var perno := CylinderMesh.new()
	perno.top_radius = 0.0025
	perno.bottom_radius = 0.0025
	perno.height = 0.012
	var perno_malla := Geometria.pieza(perno, laton, Vector3.ZERO, eje_vacio)
	perno_malla.rotation = Vector3(PI / 2.0, 0.0, 0.0)
	var colocado := Escena.grupo(eje_vacio, Vector3.ZERO, "Colocado")
	Geometria.pieza(Geometria.engranaje(0.016, 14, 0.004), laton, Vector3.ZERO, colocado)
	colocado.hide()
	eje_vacio.colocado = colocado
	eje_vacio.desde = Vector3(0.0, 0.0, 0.03)
	eje_vacio.colisor_caja(Vector3(0.04, 0.04, 0.012), Vector3(0.0, 0.0, 0.016))
	agregar(eje_vacio, trasera)
	maquinaria.append([colocado, 1.12])
	eje_vacio.accionada.connect(func(_p):
		completar("insertar")
		mesa.mensaje("La maquinaria está completa: las ruedas giran.", 3.0))


# --- Pasos y pistas ---------------------------------------------------------------------------------

func _pasos() -> void:
	paso("cuerda", [
		"Un reloj parado no sirve de nada.",
		"En un costado de la caja hay algo para dar cuerda.",
		"Gira la manivela del costado derecho dos vueltas completas."], "manivela")
	paso("tres", [
		"Ahora las agujas se mueven. ¿Qué hora importa?",
		"Lee la carta que hay sobre el escritorio.",
		"Pon las tres en punto: la aguja corta en el III y la larga en el XII."], "aguja_hora")
	paso("cajon", [
		"Al dar la hora se soltó algo.",
		"Mira el costado izquierdo de la caja.",
		"Tira del cajón del costado izquierdo."], "cajon")
	paso("engranaje", [
		"El cajón no está vacío.",
		"Hay una pieza de latón en el cajón.",
		"Toca el engranaje para guardarlo."], "engranaje")
	paso("insertar", [
		"A la máquina del reloj le falta algo.",
		"Mira la caja por detrás: hay una ventanita con ruedas.",
		"Elige el engranaje a la izquierda y toca el eje vacío de la ventanita."], "eje_vacio")
	paso("tren", [
		"La maquinaria ya mueve el cierre de la tapa. Falta la hora.",
		"En el cajón había un billete de tren.",
		"Pon las 9:45: la aguja corta en el IX y la larga también en el IX."], "aguja_minuto")
	paso("tapa", [
		"La tapa ya no está cerrada.",
		"Levanta la tapa del reloj.",
		"Tira de la tapa hacia arriba."], "tapa")
	titulo_final = "La caja se ha abierto"
	texto_final = "Dentro había un reloj de bolsillo que anda hacia atrás y una nota: «No es el tiempo lo que se ha parado, Arthur. Soy yo, que vuelvo».\nWhitcombe nunca regresó de Whitby."


# --- Cámara, luz y ambiente ---------------------------------------------------------------------------

# Zonas de cerca para el doble toque
func _zonas() -> void:
	zona("reloj", Vector3(0.0, ALTO, 0.0), 0.42, NAN, 1.2, 0.09)
	zona("manivela", Vector3(ANCHO / 2.0 + 0.012, 0.062, 0.0), 0.38, PI / 2.0, 0.25, 0.06)
	zona("cajon", Vector3(-ANCHO / 2.0 - 0.01, 0.035, 0.0), 0.42, -PI / 2.0, 0.32, 0.08)
	zona("maquinaria", Vector3(0.0, 0.058, -FONDO / 2.0), 0.36, PI, 0.12, 0.09)
	zona("placa", Vector3(0.0, 0.052, FONDO / 2.0), 0.36, 0.0, 0.2, 0.06)
	zona("carta", Vector3(-0.27, 0.0, 0.13), 0.42, NAN, 1.1, 0.1)


func preparar_camara(camara: CamaraPuzle) -> void:
	camara.camara.fov = 40.0
	camara.configurar_orbita(Vector3(0.0, 0.07, 0.0), 0.35, 0.5, 1.1, Vector2(0.22, 1.7), Vector2(-0.2, 1.4))
	camara.altura_minima = 0.03
	camara.poner_luz(0.45, 1.6)


# De la puerta del taller al escritorio
func ruta_entrada() -> Dictionary:
	var suelo: float = Taller.SUELO
	return {"puntos": [Vector3(0.48, suelo + 1.62, 3.95), Vector3(0.5, suelo + 1.58, 2.7), Vector3(0.45, suelo + 1.35, 1.65)],
		"miradas": [Vector3(0.0, -0.05, 0.0), Vector3(0.0, 0.0, 0.0), Vector3(0.0, 0.05, 0.0)],
		"duracion": 6.0, "fov": 54.0}


func preparar_entorno(entorno: Environment) -> void:
	Escena.cielo(entorno, {
		"arriba": Color(0.025, 0.018, 0.014), "horizonte": Color(0.075, 0.05, 0.032), "abajo": Color(0.02, 0.014, 0.01),
		"resplandor": Color(0.3, 0.18, 0.08), "direccion_resplandor": Vector3(-0.7, 0.4, -0.5), "apertura": 4.0,
		"nubes": 0.25, "color_nubes": Color(0.06, 0.045, 0.03), "estrellas": 0.0})
	entorno.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	entorno.ambient_light_color = Color(0.55, 0.45, 0.38)
	entorno.ambient_light_energy = 0.22
	entorno.tonemap_mode = Environment.TONE_MAPPER_ACES
	entorno.tonemap_exposure = 1.0
	entorno.glow_enabled = true
	entorno.glow_intensity = 0.7
	if sala:
		entorno.background_mode = Environment.BG_COLOR
		entorno.background_color = Color(0.01, 0.008, 0.006)
		entorno.ambient_light_energy = 0.26
	else:
		Escena.luz_lejana(self, Vector3(1.0, 0.8, -0.6), Color(0.6, 0.7, 1.0), 0.5)
	Escena.luz(self, Vector3(0.5, 0.3, 0.6), Color(0.5, 0.55, 0.75), 0.3, 2.0)
	Escena.polvo(self, Vector3(0.6, 0.3, 0.5), Color(1.0, 0.85, 0.6, 0.5), 60, 0.0025).position = Vector3(0.0, 0.32, 0.0)


# Al entrar: los relojes del taller y la puerta que se abre
func empezar() -> void:
	_ruido.frequency = 0.8
	mesa.sonido.bucle("pendulo", -16.0, 2.0)
	mesa.sonido.bucle("fuego", -20.0, 2.0)
	if sala:
		sala.abrir_puerta(mesa.sonido)


func al_llegar() -> void:
	await get_tree().create_timer(1.2).timeout
	if hechos.is_empty():
		mesa.mensaje("Gira alrededor de la caja con un dedo. Toca dos veces para mirar de cerca. La carta del escritorio se puede leer.", 5.5)


func actualizar(delta: float) -> void:
	_tiempo += delta
	if sala:
		sala.actualizar(delta)
	lampara.light_energy = 1.6 + _ruido.get_noise_1d(_tiempo) * 0.05
	if hecho("insertar"):
		for datos in maquinaria:
			(datos[0] as Node3D).rotation.z += delta * float(datos[1]) * 0.8
	if aguja_bolsillo.is_visible_in_tree():
		aguja_bolsillo.rotation.y += delta * 1.2


# En el gabinete del menú: el reloj de la tapa marca la hora de verdad
func animar_vitrina(_delta: float, _camara: Camera3D, _activa: bool) -> void:
	var ahora := Time.get_time_dict_from_system()
	aguja_hora.angulo = -(float(ahora.hour % 12) + float(ahora.minute) / 60.0) * PASO_HORA
	aguja_minuto.angulo = -float(ahora.minute) / 60.0 * TAU


# --- Final ----------------------------------------------------------------------------------------

func final() -> void:
	mesa.sonido.parar_bucle("tictac")
	mesa.camara.enfocar(Vector3(0.0, 0.085, 0.0), 0.38, 0.0, 1.05, 2.2)
	await get_tree().create_timer(1.0).timeout
	mesa.sonido.sonar("final_relojero", -1.0, 1.0, 0.0)
	await get_tree().create_timer(3.6).timeout


# --- Prueba automática ------------------------------------------------------------------------------

func resolver_paso(id: String) -> void:
	match id:
		"cuerda":
			manivela.mover_a(VUELTAS_CUERDA * TAU, 0.6)
		"tres":
			cajon.tocar()
			await get_tree().create_timer(0.4).timeout
			cajon_bloqueado_antes = cajon.reposo < 0.001
			aguja_minuto.mover_a(0.0, 0.2)
			await get_tree().create_timer(0.4).timeout
			aguja_hora.mover_a(-3.0 * PASO_HORA, 0.2)
		"cajon":
			mesa.camara.enfocar(Vector3(0.0, 0.07, 0.0), 0.8, -0.9, 0.5, 0.1)
			await esperar_camara()
			cajon.tocar()
		"engranaje":
			engranaje.tocar()
		"insertar":
			mesa.seleccionar("engranaje")
			mesa.camara.enfocar(Vector3(0.0, 0.06, 0.0), 0.6, PI, 0.35, 0.1)
			await esperar_camara()
			eje_vacio.tocar()
		"tren":
			mesa.camara.enfocar(Vector3(0.0, 0.07, 0.0), 0.7, 0.2, 1.0, 0.1)
			await esperar_camara()
			aguja_hora.mover_a(-9.0 * PASO_HORA, 0.2)
			await get_tree().create_timer(0.4).timeout
			aguja_minuto.mover_a(-9.0 * PASO_HORA, 0.2)
		"tapa":
			tapa.tocar()


func arrastre_de_prueba() -> Dictionary:
	return {"pieza": manivela, "direccion": Vector3.BACK, "pixeles": 70.0,
		"comprobar": func() -> bool: return absf(manivela.angulo) > 0.3}


# Una pieza bloqueada al empezar (la prueba comprueba que no se mueve al tocarla)
# Para los clips de la resistencia: la esfera del reloj y el cajón del costado a la vez
func encuadre_de_prueba() -> Dictionary:
	return {"centro": Vector3(-0.03, ALTO * 0.6, 0.0), "distancia": 0.6, "guinada": -0.85, "cabeceo": 0.6}


func bloqueo_de_prueba() -> Pieza:
	return cajon

func capturas_de_prueba() -> Array:
	return ["cuerda", "cajon", "insertar", "tren"]


func comprobaciones() -> Array:
	return [["el cajón no se abre antes de la hora", cajon_bloqueado_antes],
		["si algo no se deja, el minutero dice que no (sin destello)", meneos >= 1],
		["la maquinaria completa gira", hecho("insertar")]]
