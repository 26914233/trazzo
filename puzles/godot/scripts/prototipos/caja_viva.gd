# La caja viva: una himitsu-bako (caja secreta de Hakone) de cien años que se ha vuelto
# tsukumogami. Sus paneles se abren en orden, como en las de verdad, pero tiene un ojo: mientras
# te ve, no se deja tocar. Hay que girarla para trabajar por su punto ciego y, al final, dormirla.
#
# Pasos: costado derecho → tapa (1) → costado izquierdo (sin que el ojo te vea) → tapa (2) →
# ficha de shōgi → ficha en el hueco de atrás (la caja se duerme) → disco en la ola → abrir la cara
# delantera. La caja está sobre una mesa baja en un washitsu de noche (salas/washitsu.gd).
extends Puzle

const Washitsu := preload("res://scripts/salas/washitsu.gd")

const ANCHO := 0.26
const ALTO := 0.15
const FONDO := 0.17
const MARGEN := 0.008
const PLACA := 0.006                  # grosor de los paneles de mosaico
const BAJADA := 0.012                 # cuánto bajan los costados
const TAPA_1 := 0.016
const TAPA_2 := 0.08
const SIMBOLOS := ["luna", "llama", "ola", "monte"]
const OLA := 2                        # símbolo que hay que dejar arriba (pintado en el hueco)
const CONO_OJO := 0.42                # coseno del ángulo de visión del ojo (unos 65 grados)

var caja: Node3D
var tapa: PiezaDeslizante
var lado_derecho: PiezaDeslizante
var lado_izquierdo: PiezaDeslizante
var frente: PiezaBisagra
var disco: PiezaGiratoria
var koma: PiezaRecogible
var ranura: PiezaRanura
var ojo: Node3D
var parpado_arriba: Node3D
var parpado_abajo: Node3D
var material_iris: StandardMaterial3D
var pupila: Node3D
var luz_ojo: OmniLight3D
var farol: OmniLight3D
var espiritu: Node3D
var luz_espiritu: OmniLight3D
var dormida := false
var bloqueo_por_ojo := 0              # veces que el ojo frenó un panel (lo mira la prueba)
var _cierre := 1.0                    # párpados: 0 abiertos, 1 cerrados
var _despierta := false
var _enfado := 0.0
var _parpadeo := 4.0
var _parpadeando := 0.0
var _tiempo := 0.0
var _avisado_ojo := false
var _ruido := FastNoiseLite.new()

var madera: Material
var laca_roja: Material
var laca_negra: Material
var sala: Node3D


func construir() -> void:
	madera = Materiales.con_textura("madera_oscura", 4.0, 0.5)
	laca_roja = Materiales.liso(Color(0.42, 0.05, 0.035), 0.22)
	laca_negra = Materiales.liso(Color(0.03, 0.025, 0.025), 0.2)
	caja = Escena.grupo(self, Vector3.ZERO, "Caja")
	_cuerpo()
	_tapa()
	_costados()
	_fondo_y_base()
	_frente()
	_hueco()
	_camara_interior()
	_pasos()
	_zonas()


func construir_sala() -> void:
	sala = Washitsu.new()
	add_child(sala)
	sala.construir()


func _mosaico(nombre: String) -> Material:
	return Materiales.con_textura("yosegi_" + nombre, 7.5, 0.36, 0.0, Color(0.74, 0.72, 0.72), 0.8)


# --- Cuerpo: bloques de madera con una cámara por delante y un hueco arriba a la izquierda ---------

func _cuerpo() -> void:
	var w := ANCHO / 2.0
	var h := ALTO / 2.0
	var f := FONDO / 2.0
	# cámara interior (se ve al abrir la cara delantera)
	var cx := 0.09
	var abajo_c := -0.045
	var arriba_c := 0.03
	var fondo_c := -0.055
	Escena.bloque(Vector3(-w, -h, -f), Vector3(w, abajo_c, f), madera, caja)
	Escena.bloque(Vector3(-w, abajo_c, -f), Vector3(-cx, arriba_c, f), madera, caja)
	Escena.bloque(Vector3(cx, abajo_c, -f), Vector3(w, arriba_c, f), madera, caja)
	Escena.bloque(Vector3(-cx, abajo_c, -f), Vector3(cx, arriba_c, fondo_c), madera, caja)
	# capa de arriba, con el hueco de la ficha (x de -0.118 a -0.058, z de -0.035 a 0.035)
	var hx0 := -0.118
	var hx1 := -0.058
	var hz := 0.035
	var suelo_hueco := 0.05
	Escena.bloque(Vector3(hx0, arriba_c, -hz), Vector3(hx1, suelo_hueco, hz), laca_roja, caja)
	Escena.bloque(Vector3(-w, arriba_c, -f), Vector3(hx0, h, f), madera, caja)
	Escena.bloque(Vector3(hx1, arriba_c, -f), Vector3(w, h, f), madera, caja)
	Escena.bloque(Vector3(hx0, arriba_c, hz), Vector3(hx1, h, f), madera, caja)
	Escena.bloque(Vector3(hx0, arriba_c, -f), Vector3(hx1, h, -hz), madera, caja)
	# forro de laca roja dentro de la cámara
	var g := 0.0012
	Escena.bloque(Vector3(-cx, abajo_c, fondo_c), Vector3(cx, abajo_c + g, f - 0.002), laca_roja, caja, 0.0, false)
	Escena.bloque(Vector3(-cx, arriba_c - g, fondo_c), Vector3(cx, arriba_c, f - 0.002), laca_roja, caja, 0.0, false)
	Escena.bloque(Vector3(-cx, abajo_c, fondo_c), Vector3(cx, arriba_c, fondo_c + g), laca_roja, caja, 0.0, false)
	Escena.bloque(Vector3(-cx, abajo_c, fondo_c), Vector3(-cx + g, arriba_c, f - 0.002), laca_roja, caja, 0.0, false)
	Escena.bloque(Vector3(cx - g, abajo_c, fondo_c), Vector3(cx, arriba_c, f - 0.002), laca_roja, caja, 0.0, false)


# Placa de mosaico: madera oscura con la chapa de marquetería encima, un poco más pequeña
func _placa(padre: Node3D, tamano: Vector3, normal: Vector3, mosaico: String) -> void:
	Geometria.pieza(Geometria.caja(tamano, 0.0012), madera, Vector3.ZERO, padre)
	var chapa := tamano - (Vector3.ONE - normal.abs()) * 0.009
	chapa = chapa * (Vector3.ONE - normal.abs()) + normal.abs() * 0.0008
	Geometria.pieza(Geometria.caja(chapa, 0.0), _mosaico(mosaico), normal * (tamano * normal.abs()).length() / 2.0, padre)


# --- Tapa de arriba: se corre a la derecha en dos tramos ------------------------------------------

func _tapa() -> void:
	tapa = PiezaDeslizante.new()
	tapa.id = "tapa"
	var tamano := Vector3(ANCHO - 2.0 * MARGEN, PLACA, FONDO - 2.0 * MARGEN)
	tapa.position = Vector3(0.0, ALTO / 2.0 + PLACA / 2.0, 0.0)
	tapa.configurar(Vector3.RIGHT, 0.0, TAPA_2, [0.0, TAPA_1, TAPA_2])
	tapa.limite = func() -> Vector2:
		if not lado_derecho.en(BAJADA):
			return Vector2(0.0, 0.0)
		if not lado_izquierdo.en(BAJADA):
			return Vector2(0.0, TAPA_1)
		return Vector2(0.0, TAPA_2)
	_placa(tapa, tamano, Vector3.UP, "asanoha")
	tapa.colisor_caja(tamano + Vector3(0.0, 0.002, 0.0))
	agregar(tapa, caja)
	tapa.accionada.connect(func(_p):
		if tapa.en(TAPA_1):
			completar("tapa_1")
		elif tapa.en(TAPA_2) and not hecho("tapa_2"):
			completar("tapa_2")
			mesa.camara.enfocar(Vector3(-0.088, 0.055, 0.0), 0.34, NAN, 1.05, 1.4)
			mesa.mensaje("Bajo la tapa había un hueco."))


# --- Costados: bajan un poco. El izquierdo no se mueve si el ojo te ve ----------------------------

func _costados() -> void:
	var alto := ALTO + PLACA - MARGEN
	var tamano := Vector3(PLACA, alto, FONDO - 2.0 * MARGEN)
	var centro_y := (ALTO / 2.0 + PLACA) - alto / 2.0
	for lado in [1.0, -1.0]:
		var pieza := PiezaDeslizante.new()
		pieza.id = "lado_derecho" if lado > 0.0 else "lado_izquierdo"
		pieza.position = Vector3(lado * (ANCHO / 2.0 + PLACA / 2.0), centro_y, 0.0)
		pieza.configurar(Vector3.DOWN, 0.0, BAJADA, [0.0, BAJADA])
		_placa(pieza, tamano, Vector3(lado, 0.0, 0.0), "uroko")
		pieza.colisor_caja(tamano + Vector3(0.002, 0.0, 0.0))
		agregar(pieza, caja)
		if lado > 0.0:
			lado_derecho = pieza
		else:
			lado_izquierdo = pieza
	lado_derecho.permiso = func() -> bool: return tapa.reposo < 0.002
	lado_derecho.accionada.connect(func(_p):
		if lado_derecho.en(BAJADA):
			completar("lado_derecho"))
	lado_izquierdo.permiso = func() -> bool: return tapa.en(TAPA_1) and not ve()
	lado_izquierdo.rechazada.connect(func(_p):
		if tapa.en(TAPA_1):
			_quizas_enfadar())
	lado_izquierdo.accionada.connect(func(_p):
		if lado_izquierdo.en(BAJADA):
			completar("lado_izquierdo"))


# --- Trasera y base (con la ranura de la ficha) -------------------------------------------------

func _fondo_y_base() -> void:
	var trasera := Escena.grupo(caja, Vector3(0.0, 0.0, -(FONDO / 2.0 + PLACA / 2.0)), "Trasera")
	var tamano := Vector3(ANCHO - 2.0 * MARGEN, ALTO - 2.0 * MARGEN, PLACA)
	_placa(trasera, tamano, Vector3.BACK * -1.0, "ichimatsu")
	_opaco(trasera, tamano)

	var base := Escena.grupo(caja, Vector3(0.0, -(ALTO / 2.0 + PLACA / 2.0), 0.0), "Base")
	tamano = Vector3(ANCHO - 2.0 * MARGEN, PLACA, FONDO - 2.0 * MARGEN)
	_placa(base, tamano, Vector3.DOWN, "yabane")
	_opaco(base, tamano)

	# el hueco de la ficha, en la cara de atrás (la caja está sobre la mesa: por debajo no se ve)
	ranura = PiezaRanura.new()
	ranura.id = "ranura"
	ranura.acepta = "koma"
	ranura.aviso_vacia = "Hay un hueco con forma de ficha de shōgi."
	ranura.position = Vector3(0.0, -0.004, -(FONDO / 2.0 + PLACA) - 0.0004)
	var hueco := Geometria.pieza(Geometria.extruir(_contorno_koma(1.1), 0.001), laca_negra, Vector3.ZERO, ranura)
	hueco.rotation = Vector3(0.0, PI, 0.0)
	var dentro := Escena.grupo(ranura, Vector3(0.0, 0.0, -0.003), "Colocada")
	_modelo_koma(dentro).rotation = Vector3(0.0, PI, 0.0)
	dentro.hide()
	ranura.colocado = dentro
	ranura.desde = Vector3(0.0, 0.0, -0.03)
	ranura.colisor_caja(Vector3(0.042, 0.046, 0.006))
	agregar(ranura, caja)
	ranura.accionada.connect(func(_p):
		completar("dormir")
		_dormir())


func _opaco(padre: Node3D, tamano: Vector3) -> void:
	var cuerpo := StaticBody3D.new()
	var forma := CollisionShape3D.new()
	forma.shape = BoxShape3D.new()
	(forma.shape as BoxShape3D).size = tamano
	cuerpo.add_child(forma)
	padre.add_child(cuerpo)


# --- Cara delantera: el ojo y el disco de los símbolos. Al final se abre hacia ti ------------------

func _frente() -> void:
	frente = PiezaBisagra.new()
	frente.id = "frente"
	var alto := ALTO - 2.0 * MARGEN
	var tamano := Vector3(ANCHO - 2.0 * MARGEN, alto, PLACA)
	frente.position = Vector3(0.0, -ALTO / 2.0 + MARGEN, FONDO / 2.0 + PLACA)
	frente.configurar_bisagra(Vector3.RIGHT, 1.72)
	var placa := Escena.grupo(frente, Vector3(0.0, alto / 2.0, -PLACA / 2.0), "Placa")
	_placa(placa, tamano, Vector3.BACK, "kikko")
	frente.colisor_caja(tamano + Vector3(0.0, 0.0, 0.002), Vector3(0.0, alto / 2.0, -PLACA / 2.0))
	frente.permiso = func() -> bool: return dormida and disco.tope(4) == OLA
	frente.rechazada.connect(func(_p): _quizas_enfadar())
	agregar(frente, caja)
	frente.accionada.connect(func(_p):
		if frente.abierta():
			completar("abrir"))
	_ojo(Vector3(0.0, alto * 0.7, 0.0006))
	_disco(Vector3(0.0, alto * 0.27, 0.0))


func _ojo(posicion: Vector3) -> void:
	ojo = Escena.grupo(frente, posicion, "Ojo")
	var a := 0.036                    # semieje horizontal
	var b := 0.018                    # semieje vertical
	var cuenca := Geometria.pieza(Geometria.extruir(_elipse(a, b, 48), 0.001), laca_negra, Vector3(0, 0, 0.0005), ojo)
	cuenca.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# iris rojo con luz propia y la pupila que te sigue
	material_iris = Materiales.emisivo(Color(1.0, 0.16, 0.08), 2.4, Color(0.3, 0.02, 0.01))
	var iris := MeshInstance3D.new()
	var disco_iris := CylinderMesh.new()
	disco_iris.top_radius = 0.0155
	disco_iris.bottom_radius = 0.0155
	disco_iris.height = 0.001
	disco_iris.radial_segments = 40
	iris.mesh = disco_iris
	iris.material_override = material_iris
	iris.rotation = Vector3(PI / 2.0, 0.0, 0.0)
	iris.position = Vector3(0.0, 0.0, 0.0016)
	ojo.add_child(iris)
	pupila = Escena.grupo(ojo, Vector3(0.0, 0.0, 0.0024), "Pupila")
	var negra := MeshInstance3D.new()
	var disco_pupila := CylinderMesh.new()
	disco_pupila.top_radius = 0.0062
	disco_pupila.bottom_radius = 0.0062
	disco_pupila.height = 0.0008
	disco_pupila.radial_segments = 32
	negra.mesh = disco_pupila
	negra.material_override = Materiales.liso(Color(0.01, 0.005, 0.005), 0.08)
	negra.rotation = Vector3(PI / 2.0, 0.0, 0.0)
	negra.scale = Vector3(0.55, 1.0, 1.0)
	pupila.add_child(negra)
	# párpados de mosaico: medias elipses que crecen desde arriba y desde abajo
	parpado_arriba = Escena.grupo(ojo, Vector3(0.0, b, 0.0034), "ParpadoArriba")
	parpado_abajo = Escena.grupo(ojo, Vector3(0.0, -b, 0.0034), "ParpadoAbajo")
	var media := _media_elipse(a * 1.02, b * 1.02, 24)
	Geometria.pieza(Geometria.extruir(media, 0.0012), _mosaico("kikko"), Vector3(0.0, -b * 1.02, 0.0), parpado_arriba)
	var abajo := Geometria.pieza(Geometria.extruir(media, 0.0012), _mosaico("kikko"), Vector3(0.0, b * 1.02, 0.0), parpado_abajo)
	abajo.rotation = Vector3(0.0, 0.0, PI)
	# reborde de latón
	var reborde := MeshInstance3D.new()
	var toro := TorusMesh.new()
	toro.inner_radius = 0.0348
	toro.outer_radius = 0.0378
	toro.rings = 48
	toro.ring_segments = 8
	reborde.mesh = toro
	reborde.material_override = Materiales.laton(0.28)
	reborde.rotation = Vector3(PI / 2.0, 0.0, 0.0)
	reborde.scale = Vector3(1.0, 1.0, 0.52)
	reborde.position = Vector3(0.0, 0.0, 0.0034)
	ojo.add_child(reborde)
	luz_ojo = Escena.luz(ojo, Vector3(0.0, 0.0, 0.03), Color(1.0, 0.2, 0.1), 0.0, 0.3)
	_poner_parpados()


func _disco(posicion: Vector3) -> void:
	disco = PiezaGiratoria.new()
	disco.id = "disco"
	disco.position = posicion + Vector3(0.0, 0.0, 0.0022)
	disco.configurar(Vector3.BACK, TAU / 4.0)
	disco.sonido_tope = "clic_madera"
	var radio := 0.024
	var rueda := MeshInstance3D.new()
	var cilindro := CylinderMesh.new()
	cilindro.top_radius = radio
	cilindro.bottom_radius = radio
	cilindro.height = 0.004
	cilindro.radial_segments = 48
	rueda.mesh = cilindro
	rueda.material_override = Materiales.con_textura("madera_clara", 6.0, 0.4)
	rueda.rotation = Vector3(PI / 2.0, 0.0, 0.0)
	disco.add_child(rueda)
	for k in SIMBOLOS.size():
		var angulo := -k * TAU / 4.0
		var lugar := Vector3(-sin(angulo), cos(angulo), 0.0) * radio * 0.6
		Escena.calcomania(Materiales.textura("simbolo_" + SIMBOLOS[k]), Vector2(0.013, 0.013), Color(0.12, 0.06, 0.04),
			disco, Transform3D(Basis(Vector3.BACK, angulo), lugar + Vector3(0.0, 0.0, 0.0021)))
	var aro := MeshInstance3D.new()
	var toro := TorusMesh.new()
	toro.inner_radius = radio - 0.0012
	toro.outer_radius = radio + 0.0014
	toro.rings = 48
	toro.ring_segments = 8
	aro.mesh = toro
	aro.material_override = Materiales.laton(0.3)
	aro.rotation = Vector3(PI / 2.0, 0.0, 0.0)
	aro.scale = Vector3(1.0, 0.6, 1.0)
	disco.add_child(aro)
	disco.colisor(_forma_cilindro(radio, 0.008), Transform3D(Basis(Vector3.RIGHT, PI / 2.0), Vector3(0.0, 0.0, 0.002)))
	disco.permiso = func() -> bool: return not ve()
	disco.rechazada.connect(func(_p): _quizas_enfadar())
	agregar(disco, frente)
	disco.accionada.connect(func(_p):
		if disco.tope(4) == OLA:
			completar("simbolo")
			if dormida:
				mesa.sonido.sonar("mecanismo", -6.0)
				mesa.mensaje("Algo hizo clic dentro de la caja."))
	# muesca de latón que señala el símbolo elegido
	var muesca := PackedVector2Array([Vector2(-0.004, 0.0035), Vector2(0.004, 0.0035), Vector2(0.0, -0.002)])
	Geometria.pieza(Geometria.extruir(muesca, 0.002), Materiales.laton(0.3), posicion + Vector3(0.0, radio + 0.004, 0.001), frente)


func _forma_cilindro(radio: float, alto: float) -> CylinderShape3D:
	var forma := CylinderShape3D.new()
	forma.radius = radio
	forma.height = alto
	return forma


# --- Hueco de arriba: la ficha y la ola pintada ----------------------------------------------------

func _hueco() -> void:
	koma = PiezaRecogible.new()
	koma.id = "koma"
	koma.nombre_objeto = "Ficha de shōgi"
	koma.position = Vector3(-0.1, 0.054, -0.004)
	koma.rotation = Vector3(-PI / 2.0, 0.25, 0.0)
	koma.modelo = Escena.grupo(koma, Vector3.ZERO, "Modelo")
	_modelo_koma(koma.modelo)
	koma.colisor_caja(Vector3(0.034, 0.038, 0.014))
	koma.permiso = func() -> bool: return tapa.reposo > TAPA_2 - 0.002
	agregar(koma, caja)
	koma.accionada.connect(func(_p): completar("koma"))
	Escena.calcomania(Materiales.textura("simbolo_ola"), Vector2(0.02, 0.02), Color(0.85, 0.12, 0.08), caja,
		Transform3D(Basis(Vector3.RIGHT, -PI / 2.0), Vector3(-0.07, 0.0505, 0.017)))


# La ficha: un pentágono de boj con la ola grabada (aquí, en tinta)
func _modelo_koma(padre: Node3D) -> Node3D:
	var modelo := Geometria.pieza(Geometria.extruir(_contorno_koma(1.0), 0.009),
		Materiales.con_textura("madera_clara", 8.0, 0.45), Vector3.ZERO, padre)
	Escena.calcomania(Materiales.textura("simbolo_ola"), Vector2(0.016, 0.016), Color(0.1, 0.05, 0.03), modelo,
		Transform3D(Basis.IDENTITY, Vector3(0.0, -0.002, 0.0047)))
	return modelo


func _contorno_koma(escala: float) -> PackedVector2Array:
	var puntos := PackedVector2Array([Vector2(0.0, 0.019), Vector2(0.012, 0.012), Vector2(0.016, -0.017),
		Vector2(-0.016, -0.017), Vector2(-0.012, 0.012)])
	for k in puntos.size():
		puntos[k] *= escala
	return puntos


func _elipse(a: float, b: float, lados: int) -> PackedVector2Array:
	var puntos := PackedVector2Array()
	for k in lados:
		var t := TAU * k / lados
		puntos.append(Vector2(cos(t) * a, sin(t) * b))
	return puntos


# Media elipse de arriba (de y = 0 a y = b), para un párpado
func _media_elipse(a: float, b: float, lados: int) -> PackedVector2Array:
	var puntos := PackedVector2Array()
	for k in lados + 1:
		var t := PI * k / lados
		puntos.append(Vector2(cos(t) * a, sin(t) * b))
	return puntos


# --- Cámara interior: el ofuda y la luz que estaba encerrada ----------------------------------------

func _camara_interior() -> void:
	var ofuda := Escena.calcomania(Materiales.textura("ofuda"), Vector2(0.024, 0.072), Color.WHITE, caja,
		Transform3D(Basis(Vector3.RIGHT, -0.12), Vector3(0.035, -0.008, -0.052)))
	var material: StandardMaterial3D = ofuda.material_override
	material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	espiritu = Escena.grupo(caja, Vector3(-0.025, -0.02, 0.0), "Espiritu")
	var esfera := MeshInstance3D.new()
	var bola := SphereMesh.new()
	bola.radius = 0.007
	bola.height = 0.014
	esfera.mesh = bola
	esfera.material_override = Materiales.emisivo(Color(0.75, 0.92, 1.0), 3.0, Color(0.6, 0.8, 1.0))
	espiritu.add_child(esfera)
	luz_espiritu = Escena.luz(espiritu, Vector3.ZERO, Color(0.7, 0.88, 1.0), 0.0, 0.45)
	espiritu.hide()


# --- Pasos y pistas ------------------------------------------------------------------------------

func _pasos() -> void:
	paso("lado_derecho", [
		"Las cajas secretas se abren moviendo sus paneles en orden. Busca uno que ceda.",
		"Mira los costados de la caja.",
		"Desliza hacia abajo el panel del costado derecho."], "lado_derecho")
	paso("tapa_1", [
		"Al bajar ese costado, algo de arriba quedó libre.",
		"La tapa de mosaico de arriba puede correrse un poco.",
		"Desliza la tapa de arriba hacia la derecha."], "tapa")
	paso("lado_izquierdo", [
		"El otro costado también se mueve, pero la caja no se deja mientras te mira.",
		"Gira la caja para que el ojo no te vea antes de tocar el costado izquierdo.",
		"Mira la caja desde atrás y baja el panel del costado izquierdo."], "lado_izquierdo")
	paso("tapa_2", [
		"Ahora la tapa tiene más recorrido.",
		"Sigue corriendo la tapa de arriba.",
		"Desliza la tapa de arriba del todo hacia la derecha."], "tapa")
	paso("koma", [
		"En el hueco que apareció hay algo.",
		"Es una pieza de madera con forma de ficha de shōgi.",
		"Toca la ficha del hueco para guardarla."], "koma")
	paso("dormir", [
		"La ficha encaja en algún sitio de la caja.",
		"Mira la caja por detrás.",
		"Elige la ficha a la izquierda y toca el hueco de la parte de atrás."], "ranura")
	paso("simbolo", [
		"El disco de la cara delantera tiene cuatro símbolos. ¿Cuál viste pintado antes?",
		"En el fondo del hueco de arriba había un símbolo en rojo: una ola.",
		"Gira el disco hasta dejar la ola arriba, bajo la muesca de latón."], "disco")
	paso("abrir", [
		"La caja ya no se resiste.",
		"La cara delantera está suelta.",
		"Tira hacia ti de la cara delantera para abrirla."], "frente")
	titulo_final = "La caja se ha rendido"
	texto_final = "Dentro había un ofuda: «百年封印», sello de cien años. Lo que guardaba ya se ha ido flotando.\n" \
		+ "En la colección quedan otras cajas, y también tienen cien años."


# Zonas de cerca para el doble toque: cada cara de la caja y el hueco de arriba
func _zonas() -> void:
	zona("frente", Vector3(0.0, 0.0, 0.09), 0.36, 0.0, 0.12, 0.1)
	zona("tapa", Vector3(0.0, 0.09, 0.0), 0.42, NAN, 1.05, 0.1)
	zona("hueco", Vector3(-0.088, 0.06, 0.0), 0.27, NAN, 1.15, 0.05)
	zona("derecho", Vector3(0.14, 0.0, 0.0), 0.38, PI / 2.0, 0.15, 0.1)
	zona("izquierdo", Vector3(-0.14, 0.0, 0.0), 0.38, -PI / 2.0, 0.15, 0.1)
	zona("trasera", Vector3(0.0, 0.0, -0.095), 0.36, PI, 0.12, 0.1)


# --- Cámara, luz y ambiente --------------------------------------------------------------------

func preparar_camara(camara: CamaraPuzle) -> void:
	camara.camara.fov = 38.0
	camara.configurar_orbita(Vector3(0.0, 0.0, 0.0), 0.55, 0.42, 0.95, Vector2(0.2, 1.5), Vector2(-1.38, 1.38))
	camara.altura_minima = -0.06
	camara.poner_luz(0.4, 1.4)


# De las fusuma del pasillo a la mesa baja
func ruta_entrada() -> Dictionary:
	var piso: float = Washitsu.PISO
	return {"puntos": [Vector3(0.0, piso + 1.47, 3.15), Vector3(0.0, piso + 1.4, 2.25), Vector3(0.12, piso + 1.12, 1.35)],
		"miradas": [Vector3(0.0, -0.1, 0.0), Vector3(0.0, -0.1, 0.0), Vector3(0.0, -0.05, 0.0)],
		"duracion": 6.0, "fov": 52.0}


func preparar_entorno(entorno: Environment) -> void:
	# el cielo solo da reflejos a la laca: la habitación está cerrada
	Escena.cielo(entorno, {
		"arriba": Color(0.015, 0.02, 0.05), "horizonte": Color(0.07, 0.055, 0.1), "abajo": Color(0.01, 0.008, 0.015),
		"resplandor": Color(0.45, 0.2, 0.08), "direccion_resplandor": Vector3(-0.6, 0.3, 0.7), "apertura": 5.0,
		"nubes": 0.5, "color_nubes": Color(0.1, 0.08, 0.13), "estrellas": 0.5}, false)
	entorno.background_mode = Environment.BG_COLOR
	entorno.background_color = Color(0.01, 0.01, 0.015)
	entorno.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	entorno.ambient_light_color = Color(0.42, 0.42, 0.55)
	entorno.ambient_light_energy = 0.24
	entorno.tonemap_mode = Environment.TONE_MAPPER_ACES
	entorno.tonemap_exposure = 1.05
	entorno.glow_enabled = true
	entorno.glow_intensity = 0.9
	entorno.glow_bloom = 0.04
	if sala:
		farol = sala.andon
	else:
		farol = Escena.luz(self, Vector3(-0.46, 0.38, 0.3), Color(1.0, 0.72, 0.48), 1.15, 2.4, true)
	# luz cálida de arriba, como el reflejo del andon en el techo
	Escena.luz(self, Vector3(0.1, 0.9, 0.25), Color(1.0, 0.8, 0.6), 0.35, 1.8)


# Al entrar: el ambiente de la noche y las fusuma que se abren
func empezar() -> void:
	_ruido.frequency = 1.3
	mesa.sonido.bucle("noche", -13.0, 3.0)
	if sala:
		sala.abrir_puertas(mesa.sonido)


# Al llegar a la mesa: la caja abre el ojo
func al_llegar() -> void:
	await get_tree().create_timer(0.5).timeout
	_despierta = true
	mesa.sonido.sonar("ojo_abre", -4.0)
	await get_tree().create_timer(2.2).timeout
	if hechos.is_empty():
		mesa.mensaje("Gira la caja con un dedo. Toca dos veces para mirar de cerca; pellizca para alejarte.", 5.0)


# --- El ojo --------------------------------------------------------------------------------------

func ve() -> bool:
	if dormida or not _despierta or frente.abierta():
		return false
	var hacia: Vector3 = (mesa.camara.camara.global_position - ojo.global_position).normalized()
	return frente.global_basis.z.normalized().dot(hacia) > CONO_OJO


func _quizas_enfadar() -> void:
	if not ve():
		return
	bloqueo_por_ojo += 1
	_enfado = 1.3
	mesa.sonido.sonar("grunido", -2.0)
	mesa.vibrar(60, 0.8)
	if not _avisado_ojo:
		_avisado_ojo = true
		mesa.mensaje("La caja te está mirando. Mientras te vea, no se deja tocar.", 4.5)


func _dormir() -> void:
	dormida = true
	mesa.sonido.sonar("suspiro", -2.0)
	mesa.mensaje("La caja se ha dormido.", 3.0)
	var animacion := create_tween()
	animacion.tween_property(luz_ojo, "light_energy", 0.0, 1.5)


func actualizar(delta: float) -> void:
	if sala:
		sala.actualizar(delta)
	elif farol:
		farol.light_energy = 1.15 + _ruido.get_noise_1d(_tiempo * 3.0) * 0.15
	_animar(delta, mesa.camara.camara.global_position)


# En el gabinete del menú: duerme, y abre el ojo cuando la miras
func animar_vitrina(delta: float, camara: Camera3D, activa: bool) -> void:
	_despierta = activa
	_animar(delta, camara.global_position)


func _animar(delta: float, posicion_camara: Vector3) -> void:
	_tiempo += delta
	_enfado = maxf(0.0, _enfado - delta)
	var objetivo := 1.0
	if _despierta and not dormida:
		objetivo = 0.5 if _enfado > 0.0 else 0.0
		_parpadeo -= delta
		if _parpadeo <= 0.0:
			_parpadeo = randf_range(3.5, 8.0)
			_parpadeando = 0.16
		if _parpadeando > 0.0:
			_parpadeando -= delta
			objetivo = 1.0
	_cierre = move_toward(_cierre, objetivo, delta * (9.0 if _parpadeando > 0.0 or _enfado > 0.0 else 2.2))
	_poner_parpados()
	var intensidad := 0.0 if dormida else (2.4 + _enfado * 5.0)
	material_iris.emission_energy_multiplier = lerpf(material_iris.emission_energy_multiplier, intensidad, minf(1.0, delta * 6.0))
	if not dormida:
		luz_ojo.light_energy = (0.22 + _enfado * 1.4) if _despierta else 0.0
	# la pupila mira a la cámara
	var hacia: Vector3 = ojo.global_basis.orthonormalized().inverse() * (posicion_camara - ojo.global_position).normalized()
	var mirada := Vector2(hacia.x, hacia.y).limit_length(1.0) * 0.0068
	pupila.position = Vector3(mirada.x, mirada.y, 0.0024)
	pupila.scale = Vector3.ONE * (0.75 if _enfado > 0.0 else 1.0)
	# respira: más despacio cuando duerme
	var respiro := sin(_tiempo * (1.1 if dormida else 2.0)) * (0.004 if dormida else 0.0018)
	caja.scale = Vector3.ONE * (1.0 + respiro)
	if espiritu.visible:
		espiritu.position.x += sin(_tiempo * 3.0) * delta * 0.01


func _poner_parpados() -> void:
	var escala := lerpf(0.03, 1.0, _cierre)
	parpado_arriba.scale = Vector3(1.0, escala, 1.0)
	parpado_abajo.scale = Vector3(1.0, escala, 1.0)


# --- Final ---------------------------------------------------------------------------------------

func final() -> void:
	mesa.camara.enfocar(Vector3(0.0, -0.005, 0.03), 0.36, 0.0, 0.16, 2.2)
	await get_tree().create_timer(0.8).timeout
	espiritu.show()
	mesa.sonido.sonar("espiritu", -2.0)
	mesa.sonido.sonar("final_caja_viva", -1.0, 1.0, 0.0)
	var animacion := create_tween().set_parallel()
	animacion.tween_property(luz_espiritu, "light_energy", 0.7, 0.8)
	animacion.tween_property(espiritu, "position", Vector3(0.0, 0.2, 0.3), 3.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	animacion.chain().tween_property(espiritu, "scale", Vector3.ONE * 0.01, 0.8)
	await get_tree().create_timer(3.8).timeout


# --- Prueba automática ---------------------------------------------------------------------------

func resolver_paso(id: String) -> void:
	match id:
		"lado_derecho":
			lado_derecho.tocar()
		"tapa_1":
			tapa.tocar()
		"lado_izquierdo":
			# primero de frente (el ojo lo impide) y luego desde atrás
			mesa.camara.enfocar(Vector3.ZERO, 0.66, 0.0, 0.25, 0.1)
			await esperar_camara()
			lado_izquierdo.tocar()
			await get_tree().create_timer(0.5).timeout
			mesa.camara.enfocar(Vector3.ZERO, 0.66, -PI * 0.8, 0.25, 0.1)
			await esperar_camara()
			lado_izquierdo.tocar()
		"tapa_2":
			tapa.tocar()
		"koma":
			koma.tocar()
		"dormir":
			mesa.seleccionar("koma")
			mesa.camara.enfocar(Vector3.ZERO, 0.6, PI, 0.15, 0.1)
			await esperar_camara()
			ranura.tocar()
		"simbolo":
			mesa.camara.enfocar(Vector3.ZERO, 0.6, 0.0, 0.2, 0.1)
			await esperar_camara()
			disco.tocar()
			var fin := Time.get_ticks_msec() + 3000
			while disco.tope(4) != 1 and Time.get_ticks_msec() < fin:
				await get_tree().process_frame
			disco.tocar()
		"abrir":
			frente.tocar()


func arrastre_de_prueba() -> Dictionary:
	return {"pieza": lado_derecho, "direccion": Vector3.DOWN, "pixeles": 90.0,
		"comprobar": func() -> bool: return lado_derecho.en(BAJADA)}


# Una pieza bloqueada al empezar (la prueba comprueba que no se mueve al tocarla)
func bloqueo_de_prueba() -> Pieza:
	return tapa

func capturas_de_prueba() -> Array:
	return ["lado_izquierdo", "tapa_2", "dormir", "simbolo"]


func comprobaciones() -> Array:
	return [["el ojo frena el costado izquierdo mientras te ve", bloqueo_por_ojo >= 1],
		["la caja se durmió con la ficha", dormida]]
