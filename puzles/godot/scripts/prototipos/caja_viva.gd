# La caja viva: una himitsu-bako (caja secreta de Hakone) de cien años que se ha vuelto tsukumogami.
# Alguien le quitó la cara para que durmiera: le faltan un ojo, la boca y el cuerno. Le queda un ojo,
# que vigila: mientras te ve, no deja tocar ni el costado izquierdo ni la cara. Las piezas que faltan
# están repartidas por la propia caja, por la mesa y por la habitación. Con la cara completa, la caja
# despierta y abre la boca.
#
# El corazón (la cara) y lo que lo rodea:
#  - costado derecho → la llave de bambú;
#  - tapa, en dos tramos (tras cada costado) → la boca, y la ola pintada que resuelve el disco;
#  - costado izquierdo, sin que el ojo te vea → el disco → el cajoncito con el ojo dormido;
#  - zócalo de olas: una cerradura escondida (la llave) y el cordón de seda → la ficha y una nota;
#  - trasera: la ficha duerme al ojo (sin eso, la cara no se deja tocar);
#  - mesa: el incensario, cuyo león solo se abre mirando lo que pinta el rollo del tokonoma → el cuerno.
# Al final, la caja abre la boca y dentro hay un altar sellado con un ofuda.
# 19 pasos. La caja está sobre una mesa baja en un washitsu de noche (salas/washitsu.gd).
extends Puzle

const Washitsu := preload("res://scripts/salas/washitsu.gd")

const ANCHO := 0.28
const ALTO := 0.165
const FONDO := 0.19
const MARGEN := 0.008
const PLACA := 0.006                  # grosor de los paneles de mosaico
const ZOCALO := 0.026
const VUELO := 0.008                  # cuánto sobresale el zócalo
const MESA_Y := -0.0815               # tablero de la mesa baja
const CENTRO_Y := MESA_Y + ZOCALO + PLACA + ALTO / 2.0
const CORRE := 0.07                   # cuánto se corren los costados hacia atrás
const TAPA_1 := 0.02
const TAPA_2 := 0.095
const SALE_CAJON := 0.075
const SALE_CAJONCITO := 0.04
const CORTE := -0.012                 # altura de la cara por donde se abre la boca
const SIMBOLOS := ["luna", "llama", "ola", "monte"]
const OLA := 2                        # tope del disco con la ola arriba
const MONTE := 6                      # tope del incensario (de 8) en el que el león mira a la montaña
const CONO_OJO := 0.42                # coseno del ángulo de visión del ojo (unos 65 grados)
const INCENSARIO := Vector3(0.2, MESA_Y, 0.215)
const BANDEJA := Vector3(-0.235, MESA_Y, -0.19)
const ROLLO := Vector3(-0.91, 0.74, -2.42)

var caja: Node3D
var tapa: PiezaDeslizante
var lado_derecho: PiezaDeslizante
var lado_izquierdo: PiezaDeslizante
var disco: PiezaGiratoria
var cajoncito: PiezaDeslizante
var cajon: PiezaDeslizante            # el del zócalo; se saca tirando del cordón de seda
var cerradura: PiezaRanura
var llave: PiezaRecogible
var boca: PiezaRecogible
var ojo_dormido: PiezaRecogible
var koma: PiezaRecogible
var nota_cajon: PiezaNota
var ranura: PiezaRanura               # la de la ficha, en la trasera
var hueco_ojo: PiezaRanura
var hueco_boca: PiezaRanura
var hueco_cuerno: PiezaRanura
var incensario: PiezaGiratoria
var cuerno: PiezaRecogible
var ofuda: PiezaDeslizante
var cara_arriba: Node3D
var mandibula: Node3D
var ojo: Node3D
var parpado_arriba: Node3D
var parpado_abajo: Node3D
var material_iris: StandardMaterial3D
var pupila: Node3D
var luz_ojo: OmniLight3D
var ojo_puesto_cerrado: Node3D        # el ojo que se pone en la cara: cerrado hasta que despierta
var ojo_puesto_abierto: Node3D
var tapa_incensario: Node3D           # sube cuando el león mira a la montaña
var humo: CPUParticles3D
var puertas_altar: Array = []         # [hoja, ángulo abierta]
var espiritu: Node3D
var luz_espiritu: OmniLight3D
var luz_interior: OmniLight3D
var farol: OmniLight3D
var sala: Node3D
var dormida := false
var cara_completa := false
var bloqueo_por_ojo := 0              # veces que el ojo frenó algo (lo mira la prueba)
var _cierre := 1.0                    # párpados: 0 abiertos, 1 cerrados
var _despierta := false
var _enfado := 0.0
var _parpadeo := 4.0
var _parpadeando := 0.0
var _tiempo := 0.0
var _avisado_ojo := false
var _ruido := FastNoiseLite.new()

var madera: Material
var madera_clara: Material
var laca_roja: Material
var laca_negra: Material
var oro: Material
var laton: Material
var bronce: Material
var seigaiha: Material


func construir() -> void:
	madera = Materiales.con_textura("madera_oscura", 4.0, 0.5)
	madera_clara = Materiales.con_textura("madera_clara", 8.0, 0.45)
	laca_roja = Materiales.liso(Color(0.42, 0.05, 0.035), 0.2)
	laca_negra = Materiales.liso(Color(0.03, 0.025, 0.025), 0.18)
	oro = Materiales.liso(Color(0.86, 0.66, 0.3), 0.28, 1.0)
	laton = Materiales.laton(0.3)
	bronce = Materiales.con_textura("laton", 7.0, 0.55, 0.85, Color(0.48, 0.34, 0.22))
	seigaiha = Materiales.con_textura("seigaiha", 12.0, 0.3, 0.2, Color.WHITE, 1.0)
	caja = Escena.grupo(self, Vector3(0.0, CENTRO_Y, 0.0), "Caja")
	_cuerpo()
	_zocalo()
	_tapa()
	_costados()
	_disco_y_cajoncito()
	_trasera()
	_cara()
	_interior()
	_hueco_de_la_tapa()
	if not vitrina:
		_incensario()
		_juego_de_te()
	_pasos()
	_zonas()


func construir_sala() -> void:
	sala = Washitsu.new()
	add_child(sala)
	sala.construir()


func _bloque(desde: Vector3, hasta: Vector3, material: Material = null, padre: Node3D = null, opaco := true) -> MeshInstance3D:
	return Escena.bloque(desde, hasta, material if material else madera, padre if padre else caja, 0.0012, opaco)


func _mosaico(nombre: String) -> Material:
	return Materiales.con_textura("yosegi_" + nombre, 11.0, 0.34, 0.0, Color(0.74, 0.72, 0.72), 0.8)


# Placa de mosaico: madera oscura con la chapa de marquetería encima, un poco más pequeña
func _placa(padre: Node3D, tamano: Vector3, normal: Vector3, mosaico: String) -> void:
	Geometria.pieza(Geometria.caja(tamano, 0.0012), madera, Vector3.ZERO, padre)
	var chapa := tamano - (Vector3.ONE - normal.abs()) * 0.009
	chapa = chapa * (Vector3.ONE - normal.abs()) + normal.abs() * 0.0008
	Geometria.pieza(Geometria.caja(chapa, 0.0), _mosaico(mosaico), normal * (tamano * normal.abs()).length() / 2.0, padre)


func _opaco(padre: Node3D, tamano: Vector3, posicion := Vector3.ZERO) -> void:
	var cuerpo := StaticBody3D.new()
	var forma := CollisionShape3D.new()
	forma.shape = BoxShape3D.new()
	(forma.shape as BoxShape3D).size = tamano
	cuerpo.add_child(forma)
	cuerpo.position = posicion
	padre.add_child(cuerpo)


# Cinta cerrada a lo largo de un contorno (rebordes de latón de los huecos)
func _reborde(padre: Node3D, contorno: PackedVector2Array, ancho: float, material: Material, z := 0.0) -> MeshInstance3D:
	var puntos := PackedVector3Array()
	for punto in contorno:
		puntos.append(Vector3(punto.x, punto.y, z))
	puntos.append(Vector3(contorno[0].x, contorno[0].y, z))
	var malla := Geometria.pieza(Geometria.cinta(puntos, ancho, Vector3.BACK), material, Vector3.ZERO, padre)
	malla.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return malla


# Trazo pintado (cejas, mejillas): una cinta abierta por unos puntos del plano XY
func _trazo(padre: Node3D, puntos_2d: Array, ancho: float, material: Material, z: float) -> void:
	var puntos := PackedVector3Array()
	for punto in puntos_2d:
		puntos.append(Vector3(punto.x, punto.y, z))
	var malla := Geometria.pieza(Geometria.cinta(puntos, ancho, Vector3.BACK), material, Vector3.ZERO, padre)
	malla.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _cilindro(radio_arriba: float, radio_abajo: float, alto: float, material: Material, padre: Node3D,
		posicion := Vector3.ZERO, lados := 24) -> MeshInstance3D:
	var malla := CylinderMesh.new()
	malla.top_radius = radio_arriba
	malla.bottom_radius = radio_abajo
	malla.height = alto
	malla.radial_segments = lados
	malla.rings = 1
	return Geometria.pieza(malla, material, posicion, padre)


func _esfera(radio: float, material: Material, padre: Node3D, posicion := Vector3.ZERO) -> MeshInstance3D:
	var malla := SphereMesh.new()
	malla.radius = radio
	malla.height = radio * 2.0
	malla.radial_segments = 16
	malla.rings = 8
	return Geometria.pieza(malla, material, posicion, padre)


func _toro(radio_interior: float, radio_exterior: float, material: Material, padre: Node3D, posicion := Vector3.ZERO) -> MeshInstance3D:
	var malla := TorusMesh.new()
	malla.inner_radius = radio_interior
	malla.outer_radius = radio_exterior
	malla.rings = 32
	malla.ring_segments = 8
	return Geometria.pieza(malla, material, posicion, padre)


# --- Cuerpo: madera maciza con la cámara de delante, el nicho de la llave, el hueco del cajoncito
# y el hueco de la tapa ----------------------------------------------------------------------------

func _cuerpo() -> void:
	var w := ANCHO / 2.0
	var h := ALTO / 2.0
	var f := FONDO / 2.0
	# abajo, entero
	_bloque(Vector3(-w, -h, -f), Vector3(w, -0.062, f))
	# en medio: detrás, macizo; delante, la cámara interior (x ±0.085) entre los dos laterales
	_bloque(Vector3(-w, -0.062, -f), Vector3(w, 0.045, -0.04))
	# lateral izquierdo, con el hueco del cajoncito (x -w..-0.092, y -0.062..-0.022, z 0.025..0.08)
	_bloque(Vector3(-0.092, -0.062, -0.04), Vector3(-0.085, 0.045, f))
	_bloque(Vector3(-w, -0.022, -0.04), Vector3(-0.092, 0.045, f))
	_bloque(Vector3(-w, -0.062, -0.04), Vector3(-0.092, -0.022, 0.025))
	_bloque(Vector3(-w, -0.062, 0.08), Vector3(-0.092, -0.022, f))
	# lateral derecho, con el nicho de la llave (x 0.112..w, y -0.028..0.028, z 0.025..0.08)
	_bloque(Vector3(0.085, -0.062, -0.04), Vector3(0.112, 0.045, f))
	_bloque(Vector3(0.112, -0.062, -0.04), Vector3(w, -0.028, f))
	_bloque(Vector3(0.112, 0.028, -0.04), Vector3(w, 0.045, f))
	_bloque(Vector3(0.112, -0.028, -0.04), Vector3(w, 0.028, 0.025))
	_bloque(Vector3(0.112, -0.028, 0.08), Vector3(w, 0.028, f))
	# arriba, con el hueco de la tapa (x -0.125..-0.06, z ±0.05, desde y 0.0625)
	_bloque(Vector3(-w, 0.045, -f), Vector3(w, 0.0625, f))
	_bloque(Vector3(-w, 0.0625, -f), Vector3(-0.125, h, f))
	_bloque(Vector3(-0.06, 0.0625, -f), Vector3(w, h, f))
	_bloque(Vector3(-0.125, 0.0625, -f), Vector3(-0.06, h, -0.05))
	_bloque(Vector3(-0.125, 0.0625, 0.05), Vector3(-0.06, h, f))
	# forros de laca roja en el nicho y en el hueco de la tapa
	var g := 0.0012
	_bloque(Vector3(0.112, -0.028, 0.025), Vector3(0.112 + g, 0.028, 0.08), laca_roja, null, false)
	_bloque(Vector3(0.112, -0.028, 0.025), Vector3(w - 0.001, -0.028 + g, 0.08), laca_roja, null, false)
	_bloque(Vector3(-0.125, 0.0625, -0.05), Vector3(-0.06, 0.0625 + g, 0.05), laca_negra, null, false)
	_bloque(Vector3(-0.125, 0.0625, -0.05), Vector3(-0.125 + g, h - 0.001, 0.05), laca_negra, null, false)
	_bloque(Vector3(-0.06 - g, 0.0625, -0.05), Vector3(-0.06, h - 0.001, 0.05), laca_negra, null, false)
	_bloque(Vector3(-0.125, 0.0625, -0.05), Vector3(-0.06, h - 0.001, -0.05 + g), laca_negra, null, false)
	_bloque(Vector3(-0.125, 0.0625, 0.05 - g), Vector3(-0.06, h - 0.001, 0.05), laca_negra, null, false)
	_bloque(Vector3(-0.124, 0.0625 + g, -0.049), Vector3(-0.061, 0.0625 + g + 0.0004, 0.049), oro, null, false)
	_bloque(Vector3(-0.1225, 0.0625 + g + 0.0004, -0.0475), Vector3(-0.0625, 0.0625 + g + 0.0008, 0.0475), laca_negra, null, false)
	# la llave de bambú, tumbada en el nicho
	llave = PiezaRecogible.new()
	llave.id = "llave"
	llave.nombre_objeto = "Llave de bambú"
	llave.position = Vector3(0.124, -0.021, 0.052)
	llave.modelo = Escena.grupo(llave, Vector3.ZERO, "Modelo")
	_modelo_llave(llave.modelo).rotation = Vector3(0.0, 0.0, PI / 2.0)
	llave.colisor_caja(Vector3(0.016, 0.012, 0.05))
	llave.permiso = func() -> bool: return lado_derecho.en(CORRE)
	agregar(llave, caja)
	llave.accionada.connect(func(_p): completar("llave"))


# La llave: un tallo de bambú con dos nudos y un paletón plano con dos dientes
func _modelo_llave(padre: Node3D) -> Node3D:
	var nodo := Escena.grupo(padre, Vector3.ZERO, "Llave")
	var bambu := Materiales.liso(Color(0.66, 0.6, 0.3), 0.42)
	var nudo := Materiales.liso(Color(0.5, 0.42, 0.18), 0.5)
	_cilindro(0.0031, 0.0031, 0.044, bambu, nodo, Vector3(0.0, 0.004, 0.0), 12)
	for y in [-0.006, 0.014]:
		_toro(0.0029, 0.0037, nudo, nodo, Vector3(0.0, y, 0.0))
	_toro(0.0028, 0.0042, laton, nodo, Vector3(0.0, 0.026, 0.0))
	Escena.bloque(Vector3(-0.0011, -0.026, -0.0018), Vector3(0.0011, -0.016, 0.0058), laton, nodo, 0.0003, false)
	Escena.bloque(Vector3(-0.0011, -0.026, 0.0058), Vector3(0.0011, -0.023, 0.0085), laton, nodo, 0.0003, false)
	Escena.bloque(Vector3(-0.0011, -0.02, 0.0058), Vector3(0.0011, -0.017, 0.0085), laton, nodo, 0.0003, false)
	return nodo


# --- Zócalo de olas, con el cajón que se saca por la derecha tirando del cordón de seda --------------

func _zocalo() -> void:
	var y1 := -ALTO / 2.0 - PLACA
	var y0 := y1 - ZOCALO
	var wx := ANCHO / 2.0 + PLACA + VUELO
	var wz := FONDO / 2.0 + PLACA + VUELO
	var zocalo := Escena.grupo(caja, Vector3.ZERO, "Zocalo")
	# base de laca negra con un filo de oro entre la caja y el zócalo
	_bloque(Vector3(-ANCHO / 2.0 - PLACA, -ALTO / 2.0 - PLACA, -FONDO / 2.0 - PLACA),
		Vector3(ANCHO / 2.0 + PLACA, -ALTO / 2.0, FONDO / 2.0 + PLACA), laca_negra, zocalo)
	_bloque(Vector3(-ANCHO / 2.0 - PLACA - 0.0006, -ALTO / 2.0 - PLACA - 0.0014, -FONDO / 2.0 - PLACA - 0.0006),
		Vector3(ANCHO / 2.0 + PLACA + 0.0006, -ALTO / 2.0 - PLACA + 0.0004, FONDO / 2.0 + PLACA + 0.0006), oro, zocalo, false)
	# macizo de la izquierda y el marco del cajón
	_bloque(Vector3(-wx, y0, -wz), Vector3(-0.06, y1, wz), seigaiha, zocalo)
	_bloque(Vector3(-0.06, y0, -wz), Vector3(wx, y1, -0.07), seigaiha, zocalo)
	_bloque(Vector3(-0.06, y0, 0.07), Vector3(wx, y1, wz), seigaiha, zocalo)
	_bloque(Vector3(-0.06, y0, -0.07), Vector3(wx, y0 + 0.003, 0.07), laca_negra, zocalo)
	_bloque(Vector3(-0.06, y1 - 0.003, -0.07), Vector3(wx, y1, 0.07), laca_negra, zocalo)
	# cantoneras de latón en las cuatro esquinas
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			var x: float = sx * wx
			var z: float = sz * wz
			_bloque(Vector3(minf(x, x - sx * 0.02), y0 + 0.001, z - sz * 0.0006),
				Vector3(maxf(x, x - sx * 0.02), y1 - 0.001, z + sz * 0.0006), laton, zocalo, false)
			_bloque(Vector3(x - sx * 0.0006, y0 + 0.001, minf(z, z - sz * 0.02)),
				Vector3(x + sx * 0.0006, y1 - 0.001, maxf(z, z - sz * 0.02)), laton, zocalo, false)

	cajon = PiezaDeslizante.new()
	cajon.id = "cajon"
	cajon.position = Vector3(0.0, (y0 + y1) / 2.0, 0.0)
	cajon.configurar(Vector3.RIGHT, 0.0, SALE_CAJON, [0.0, SALE_CAJON])
	cajon.sonido_mover = "corredera"
	var alto_c := ZOCALO - 0.0075
	var abajo := -alto_c / 2.0
	_bloque(Vector3(wx - 0.006, abajo, -0.0695), Vector3(wx, -abajo, 0.0695), seigaiha, cajon, false)
	_bloque(Vector3(-0.058, abajo, -0.068), Vector3(wx - 0.006, abajo + 0.002, 0.068), laca_roja, cajon, false)
	_bloque(Vector3(-0.058, abajo, -0.068), Vector3(-0.055, -abajo - 0.002, 0.068), laca_negra, cajon, false)
	_bloque(Vector3(-0.058, abajo, -0.068), Vector3(wx - 0.006, -abajo - 0.002, -0.065), laca_negra, cajon, false)
	_bloque(Vector3(-0.058, abajo, 0.065), Vector3(wx - 0.006, -abajo - 0.002, 0.068), laca_negra, cajon, false)
	cajon.colisor_caja(Vector3(0.008, alto_c, 0.139), Vector3(wx - 0.003, 0.0, 0.0))
	# el cordón: anilla de latón, cordón rojo que baja y borla tumbada en la mesa
	var seda := Materiales.liso(Color(0.62, 0.06, 0.05), 0.75)
	var anilla := _toro(0.0022, 0.0034, laton, cajon, Vector3(wx + 0.0008, 0.002, 0.036))
	anilla.rotation = Vector3(0.0, 0.0, PI / 2.0)
	var cordon := _cilindro(0.0011, 0.0011, 0.016, seda, cajon, Vector3(wx + 0.006, -0.004, 0.036), 8)
	cordon.rotation = Vector3(0.0, 0.0, 0.62)
	_esfera(0.0027, seda, cajon, Vector3(wx + 0.011, abajo + 0.0022, 0.036))
	var borla := _cilindro(0.0012, 0.0042, 0.022, seda, cajon, Vector3(wx + 0.024, abajo + 0.002, 0.036), 12)
	borla.rotation = Vector3(0.0, 0.0, -PI / 2.0)
	_toro(0.0024, 0.0034, oro, cajon, Vector3(wx + 0.0145, abajo + 0.002, 0.036)).rotation = Vector3(0.0, 0.0, PI / 2.0)
	cajon.colisor_caja(Vector3(0.04, 0.012, 0.016), Vector3(wx + 0.018, abajo + 0.004, 0.036))
	cajon.permiso = func() -> bool: return cerradura.llena
	cajon.aviso_bloqueo = "El cordón no cede: algo traba el cajón del zócalo."
	agregar(cajon, caja)
	cajon.accionada.connect(func(_p):
		if cajon.en(SALE_CAJON):
			completar("cajon"))

	# la cerradura: una placa de latón con forma de ola, perdida entre las olas del frente del cajón
	cerradura = PiezaRanura.new()
	cerradura.id = "cerradura"
	cerradura.acepta = "llave"
	cerradura.sonido_encajar = "llave"
	cerradura.aviso_vacia = "Entre las olas hay una cerradura diminuta, con forma de nudo de bambú."
	cerradura.aviso_otro = "Eso no entra en la cerradura."
	cerradura.position = Vector3(wx + 0.0004, 0.0, -0.032)
	var placa := Escena.grupo(cerradura, Vector3.ZERO, "Placa")
	placa.rotation = Vector3(0.0, PI / 2.0, 0.0)
	var abanico := PackedVector2Array()
	for k in 13:
		var t := PI * k / 12.0
		abanico.append(Vector2(cos(t) * 0.0085, sin(t) * 0.0085 - 0.0035))
	Geometria.pieza(Geometria.extruir(abanico, 0.0008), laton, Vector3.ZERO, placa)
	Escena.bloque(Vector3(-0.0011, -0.0028, 0.0002), Vector3(0.0011, 0.0034, 0.0007), laca_negra, placa, 0.0002, false)
	var metida := Escena.grupo(cerradura, Vector3(0.012, 0.0, 0.0), "Metida")
	_modelo_llave(metida).rotation = Vector3(0.0, 0.0, PI / 2.0)
	metida.hide()
	cerradura.colocado = metida
	cerradura.desde = Vector3(0.02, 0.0, 0.0)
	cerradura.colisor_caja(Vector3(0.004, 0.012, 0.02))
	agregar(cerradura, cajon)
	cerradura.accionada.connect(func(_p):
		completar("cerradura")
		if mesa:
			mesa.sonido.sonar("mecanismo", -6.0)
			mesa.mensaje("La llave gira entre las olas: algo del zócalo se ha soltado.", 3.2))

	# dentro del cajón: la ficha de shōgi y una nota doblada
	koma = PiezaRecogible.new()
	koma.id = "koma"
	koma.nombre_objeto = "Ficha de shōgi"
	koma.position = Vector3(wx - 0.045, abajo + 0.007, 0.022)
	koma.rotation = Vector3(-PI / 2.0, 0.3, 0.0)
	koma.modelo = Escena.grupo(koma, Vector3.ZERO, "Modelo")
	_modelo_koma(koma.modelo)
	koma.colisor_caja(Vector3(0.034, 0.038, 0.012))
	koma.permiso = func() -> bool: return cajon.en(SALE_CAJON)
	agregar(koma, cajon)
	koma.accionada.connect(func(_p): completar("koma"))

	nota_cajon = PiezaNota.new()
	nota_cajon.id = "nota"
	nota_cajon.titulo = "Nota doblada"
	nota_cajon.texto = "Cumplió cien años y despertó. Le quité la cara y la escondí en ella misma, para que durmiera.\n\n" \
		+ "El ojo que le dejé vigila día y noche; solo la ficha que guardo aquí lo hace dormir.\n\n" \
		+ "El cuerno se lo di al incensario. Su león solo se abre cuando mira lo mismo que cuelga en el tokonoma."
	nota_cajon.position = Vector3(wx - 0.048, abajo + 0.0035, -0.032)
	var papel := Materiales.con_textura("papel", 18.0, 0.85)
	Escena.bloque(Vector3(-0.019, -0.0012, -0.014), Vector3(0.019, 0.0012, 0.014), papel, nota_cajon, 0.0004, false)
	nota_cajon.colisor_caja(Vector3(0.04, 0.006, 0.03))
	nota_cajon.permiso = func() -> bool: return cajon.en(SALE_CAJON)
	agregar(nota_cajon, cajon)


# --- Tapa de arriba: se corre a la derecha en dos tramos --------------------------------------------

func _tapa() -> void:
	tapa = PiezaDeslizante.new()
	tapa.id = "tapa"
	var tamano := Vector3(ANCHO - 2.0 * MARGEN, PLACA, FONDO - 2.0 * MARGEN)
	tapa.position = Vector3(0.0, ALTO / 2.0 + PLACA / 2.0, 0.0)
	tapa.configurar(Vector3.RIGHT, 0.0, TAPA_2, [0.0, TAPA_1, TAPA_2])
	tapa.limite = func() -> Vector2:
		if not lado_derecho.en(CORRE):
			return Vector2(0.0, 0.0)
		if not lado_izquierdo.en(CORRE):
			return Vector2(0.0, TAPA_1)
		return Vector2(0.0, TAPA_2)
	_placa(tapa, tamano, Vector3.UP, "asanoha")
	# marco fino de madera oscura alrededor del mosaico
	var y := PLACA / 2.0 + 0.0004
	var mx := tamano.x / 2.0
	var mz := tamano.z / 2.0
	for barra in [[Vector3(-mx, y - 0.0008, -mz), Vector3(mx, y + 0.0004, -mz + 0.005)],
			[Vector3(-mx, y - 0.0008, mz - 0.005), Vector3(mx, y + 0.0004, mz)],
			[Vector3(-mx, y - 0.0008, -mz), Vector3(-mx + 0.005, y + 0.0004, mz)],
			[Vector3(mx - 0.005, y - 0.0008, -mz), Vector3(mx, y + 0.0004, mz)]]:
		Escena.bloque(barra[0], barra[1], madera, tapa, 0.0004, false)
	tapa.colisor_caja(tamano + Vector3(0.0, 0.002, 0.0))
	agregar(tapa, caja)
	tapa.accionada.connect(func(_p):
		if tapa.en(TAPA_1):
			completar("tapa_1")
		elif tapa.en(TAPA_2) and not hecho("tapa_2"):
			completar("tapa_2")
			if mesa:
				mesa.camara.enfocar(caja.to_global(Vector3(-0.092, ALTO / 2.0, 0.0)), 0.3, NAN, 1.05, 1.3)
				mesa.mensaje("Bajo la tapa había un hueco forrado de laca."))


# --- Costados: se corren hacia atrás. El izquierdo no se mueve si el ojo te ve ------------------------

func _costados() -> void:
	var alto := ALTO + PLACA - MARGEN
	var tamano := Vector3(PLACA, alto, FONDO - 2.0 * MARGEN)
	var centro_y := (ALTO / 2.0 + PLACA) - alto / 2.0
	for lado in [1.0, -1.0]:
		var pieza := PiezaDeslizante.new()
		pieza.id = "lado_derecho" if lado > 0.0 else "lado_izquierdo"
		pieza.position = Vector3(lado * (ANCHO / 2.0 + PLACA / 2.0), centro_y, 0.0)
		pieza.configurar(Vector3.FORWARD, 0.0, CORRE, [0.0, CORRE])
		_placa(pieza, tamano, Vector3(lado, 0.0, 0.0), "uroko")
		pieza.colisor_caja(tamano + Vector3(0.002, 0.0, 0.0))
		agregar(pieza, caja)
		if lado > 0.0:
			lado_derecho = pieza
		else:
			lado_izquierdo = pieza
	lado_derecho.permiso = func() -> bool: return tapa.reposo < 0.002
	lado_derecho.accionada.connect(func(_p):
		if lado_derecho.en(CORRE):
			completar("costado_derecho"))
	lado_izquierdo.permiso = func() -> bool: return tapa.en(TAPA_1) and not ve()
	lado_izquierdo.rechazada.connect(func(_p):
		if tapa.en(TAPA_1):
			_quizas_enfadar())
	lado_izquierdo.accionada.connect(func(_p):
		if lado_izquierdo.en(CORRE):
			completar("costado_izquierdo"))


# --- Costado izquierdo, debajo del panel: el disco de los símbolos y el cajoncito -------------------

func _disco_y_cajoncito() -> void:
	var w := ANCHO / 2.0
	disco = PiezaGiratoria.new()
	disco.id = "disco"
	disco.position = Vector3(-w - 0.0024, 0.012, 0.052)
	disco.configurar(Vector3.LEFT, TAU / 4.0)
	disco.sonido_tope = "clic_madera"
	var cara_disco := Escena.grupo(disco, Vector3.ZERO, "Cara")
	cara_disco.rotation = Vector3(0.0, -PI / 2.0, 0.0)
	var radio := 0.022
	var rueda := _cilindro(radio, radio, 0.004, madera_clara, cara_disco, Vector3.ZERO, 48)
	rueda.rotation = Vector3(PI / 2.0, 0.0, 0.0)
	for k in SIMBOLOS.size():
		var angulo := -k * TAU / 4.0
		var lugar := Vector3(-sin(angulo), cos(angulo), 0.0) * radio * 0.6
		Escena.calcomania(Materiales.textura("simbolo_" + SIMBOLOS[k]), Vector2(0.012, 0.012), Color(0.12, 0.06, 0.04),
			cara_disco, Transform3D(Basis(Vector3.BACK, angulo), lugar + Vector3(0.0, 0.0, 0.0021)))
	_toro(radio - 0.0012, radio + 0.0014, laton, cara_disco).rotation = Vector3(PI / 2.0, 0.0, 0.0)
	disco.colisor(_forma_cilindro(radio, 0.008), Transform3D(Basis(Vector3.FORWARD, PI / 2.0), Vector3.ZERO))
	disco.permiso = func() -> bool: return lado_izquierdo.en(CORRE) and not ve()
	disco.rechazada.connect(func(_p): _quizas_enfadar())
	agregar(disco, caja)
	disco.accionada.connect(func(_p):
		if disco.tope(4) == OLA and not hecho("simbolo"):
			completar("simbolo")
			if mesa:
				mesa.sonido.sonar("mecanismo", -6.0)
				mesa.mensaje("Algo hizo clic bajo el disco.", 2.6)
			cajoncito.mover_a(0.006, 0.3))
	# muesca de latón encima del disco: señala el símbolo elegido
	var muesca := Escena.grupo(caja, Vector3(-w - 0.001, 0.012 + radio + 0.004, 0.052), "Muesca")
	muesca.rotation = Vector3(0.0, -PI / 2.0, 0.0)
	Geometria.pieza(Geometria.extruir(PackedVector2Array([Vector2(-0.004, 0.0035), Vector2(0.004, 0.0035), Vector2(0.0, -0.002)]), 0.002), laton, Vector3.ZERO, muesca)

	# el cajoncito: un cajón pequeño con tirador de latón en forma de flor (parece un adorno)
	cajoncito = PiezaDeslizante.new()
	cajoncito.id = "cajoncito"
	cajoncito.position = Vector3(-w, -0.042, 0.0525)
	cajoncito.configurar(Vector3.LEFT, 0.0, SALE_CAJONCITO, [0.0, 0.006, SALE_CAJONCITO])
	_bloque(Vector3(-0.0005, -0.019, -0.0265), Vector3(0.0045, 0.019, 0.0265), madera, cajoncito, false)
	_bloque(Vector3(0.0045, -0.019, -0.0265), Vector3(0.047, -0.017, 0.0265), laca_roja, cajoncito, false)
	_bloque(Vector3(0.0045, -0.019, -0.0265), Vector3(0.047, 0.012, -0.0245), laca_negra, cajoncito, false)
	_bloque(Vector3(0.0045, -0.019, 0.0245), Vector3(0.047, 0.012, 0.0265), laca_negra, cajoncito, false)
	_bloque(Vector3(0.045, -0.019, -0.0265), Vector3(0.047, 0.012, 0.0265), laca_negra, cajoncito, false)
	var flor := Escena.grupo(cajoncito, Vector3(-0.0012, 0.0, 0.0), "Tirador")
	flor.rotation = Vector3(0.0, -PI / 2.0, 0.0)
	for k in 5:
		var angulo := k * TAU / 5.0
		_esfera(0.0026, laton, flor, Vector3(cos(angulo) * 0.003, sin(angulo) * 0.003, 0.0))
	_esfera(0.0022, laca_roja, flor, Vector3(0.0, 0.0, 0.0012))
	cajoncito.colisor_caja(Vector3(0.008, 0.038, 0.053), Vector3(0.002, 0.0, 0.0))
	cajoncito.permiso = func() -> bool: return hecho("simbolo")
	cajoncito.aviso_bloqueo = "El cajoncito no se mueve: algo lo traba por dentro."
	agregar(cajoncito, caja)
	cajoncito.accionada.connect(func(_p):
		if cajoncito.en(SALE_CAJONCITO):
			completar("cajoncito"))

	ojo_dormido = PiezaRecogible.new()
	ojo_dormido.id = "ojo"
	ojo_dormido.nombre_objeto = "Ojo dormido"
	ojo_dormido.position = Vector3(0.026, -0.0145, 0.0)
	ojo_dormido.rotation = Vector3(-PI / 2.0, 0.0, PI / 2.0)
	ojo_dormido.modelo = Escena.grupo(ojo_dormido, Vector3.ZERO, "Modelo")
	_modelo_ojo(ojo_dormido.modelo, false)
	ojo_dormido.colisor_caja(Vector3(0.04, 0.024, 0.01))
	ojo_dormido.permiso = func() -> bool: return cajoncito.en(SALE_CAJONCITO)
	agregar(ojo_dormido, cajoncito)
	ojo_dormido.accionada.connect(func(_p): completar("ojo"))


# El ojo de madera que le falta a la cara: cerrado (con pestañas) o, al despertar, abierto y dorado
func _modelo_ojo(padre: Node3D, abierto: bool) -> Node3D:
	var nodo := Escena.grupo(padre, Vector3.ZERO, "Ojo")
	Geometria.pieza(Geometria.extruir(_elipse(0.017, 0.0085, 32), 0.004), madera_clara, Vector3.ZERO, nodo)
	if abierto:
		var iris := _cilindro(0.0062, 0.0062, 0.001, Materiales.emisivo(Color(1.0, 0.72, 0.25), 2.2, Color(0.4, 0.25, 0.05)), nodo, Vector3(0.0, 0.0, 0.0021), 24)
		iris.rotation = Vector3(PI / 2.0, 0.0, 0.0)
		var pupila_puesta := _cilindro(0.0026, 0.0026, 0.0008, laca_negra, nodo, Vector3(0.0, 0.0, 0.0027), 16)
		pupila_puesta.rotation = Vector3(PI / 2.0, 0.0, 0.0)
		pupila_puesta.scale = Vector3(0.55, 1.0, 1.0)
	else:
		var linea: Array = []
		for k in 9:
			var t := lerpf(-1.0, 1.0, k / 8.0)
			linea.append(Vector2(t * 0.014, -0.002 - (1.0 - t * t) * 0.0028))
		_trazo(nodo, linea, 0.0013, laca_negra, 0.0022)
		for k in 5:
			var t := lerpf(-0.75, 0.75, k / 4.0)
			var x := t * 0.014
			var y := -0.002 - (1.0 - t * t) * 0.0028
			_trazo(nodo, [Vector2(x, y), Vector2(x * 1.15, y - 0.0035)], 0.0007, laca_negra, 0.0022)
	return nodo


func _forma_cilindro(radio: float, alto: float) -> CylinderShape3D:
	var forma := CylinderShape3D.new()
	forma.radius = radio
	forma.height = alto
	return forma


# --- Trasera, con el hueco de la ficha (la caja está sobre la mesa: por debajo no se ve) -------------

func _trasera() -> void:
	var trasera := Escena.grupo(caja, Vector3(0.0, 0.0, -(FONDO / 2.0 + PLACA / 2.0)), "Trasera")
	var tamano := Vector3(ANCHO - 2.0 * MARGEN, ALTO - 2.0 * MARGEN, PLACA)
	_placa(trasera, tamano, Vector3.FORWARD, "ichimatsu")
	_opaco(trasera, tamano)
	ranura = PiezaRanura.new()
	ranura.id = "ranura"
	ranura.acepta = "koma"
	ranura.aviso_vacia = "Hay un hueco con forma de ficha de shōgi."
	ranura.position = Vector3(0.0, -0.004, -(FONDO / 2.0 + PLACA) - 0.0004)
	var hueco := Geometria.pieza(Geometria.extruir(_contorno_koma(1.1), 0.001), laca_negra, Vector3.ZERO, ranura)
	hueco.rotation = Vector3(0.0, PI, 0.0)
	var reborde := _reborde(ranura, _contorno_koma(1.2), 0.0026, laton, 0.0009)
	reborde.rotation = Vector3(0.0, PI, 0.0)
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


# La ficha: un pentágono de boj con la ola grabada (aquí, en tinta)
func _modelo_koma(padre: Node3D) -> Node3D:
	var modelo := Geometria.pieza(Geometria.extruir(_contorno_koma(1.0), 0.009), madera_clara, Vector3.ZERO, padre)
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


# Labios de laca: el de abajo de izquierda a derecha y el de arriba de vuelta (sentido antihorario)
func _contorno_boca(escala: float) -> PackedVector2Array:
	var puntos := PackedVector2Array([Vector2(-0.03, 0.0), Vector2(-0.022, -0.0062), Vector2(-0.012, -0.0098),
		Vector2(0.0, -0.0112), Vector2(0.012, -0.0098), Vector2(0.022, -0.0062), Vector2(0.03, 0.0),
		Vector2(0.021, 0.0062), Vector2(0.011, 0.0094), Vector2(0.004, 0.0098), Vector2(0.0, 0.0078),
		Vector2(-0.004, 0.0098), Vector2(-0.011, 0.0094), Vector2(-0.021, 0.0062)])
	for k in puntos.size():
		puntos[k] *= escala
	return puntos


# --- La cara: el ojo que vigila y los tres huecos (ojo, boca y cuerno). Al final se abre -------------

func _cara() -> void:
	var h := ALTO / 2.0
	var f := FONDO / 2.0
	var ancho := ANCHO - 2.0 * MARGEN
	var alto_arriba := (h - MARGEN) - CORTE
	var alto_abajo := CORTE - (-h + MARGEN)
	# parte de arriba (ojos y cuerno): sube al despertar
	cara_arriba = Escena.grupo(caja, Vector3(0.0, CORTE, f + PLACA / 2.0), "CaraArriba")
	var placa := Escena.grupo(cara_arriba, Vector3(0.0, alto_arriba / 2.0, 0.0), "Placa")
	_placa(placa, Vector3(ancho, alto_arriba, PLACA), Vector3.BACK, "kikko")
	_opaco(cara_arriba, Vector3(ancho, alto_arriba, PLACA), Vector3(0.0, alto_arriba / 2.0, 0.0))
	# mandíbula (boca): baja como una bisagra por el canto de abajo
	mandibula = Escena.grupo(caja, Vector3(0.0, -h + MARGEN, f + PLACA / 2.0), "Mandibula")
	var placa_abajo := Escena.grupo(mandibula, Vector3(0.0, alto_abajo / 2.0, 0.0), "Placa")
	_placa(placa_abajo, Vector3(ancho, alto_abajo, PLACA), Vector3.BACK, "kikko")
	_opaco(mandibula, Vector3(ancho, alto_abajo, PLACA), Vector3(0.0, alto_abajo / 2.0, 0.0))
	# la línea de la boca, en oro, donde se separan
	Escena.bloque(Vector3(-ancho / 2.0 + 0.004, alto_abajo - 0.0009, PLACA / 2.0), Vector3(ancho / 2.0 - 0.004, alto_abajo, PLACA / 2.0 + 0.0009),
		oro, mandibula, 0.0002, false)

	var z := PLACA / 2.0 + 0.0009
	var y_ojos := 0.022 - CORTE
	_ojo(Vector3(0.055, y_ojos, z - 0.0003))
	# cejas de latón y trazos rojos en las mejillas (como el maquillaje del kabuki)
	for lado in [-1.0, 1.0]:
		var ceja: Array = []
		for k in 9:
			var t := k / 8.0
			ceja.append(Vector2(lado * (0.03 + t * 0.05), y_ojos + 0.022 + sin(t * PI) * 0.006 - t * 0.004))
		_trazo(cara_arriba, ceja, 0.0048, laton, z + 0.0002)
		var mejilla: Array = []
		for k in 7:
			var t := k / 6.0
			mejilla.append(Vector2(lado * (0.075 + t * 0.03), y_ojos - 0.016 - t * 0.022 + sin(t * PI) * 0.004))
		_trazo(cara_arriba, mejilla, 0.0042, laca_roja, z + 0.0002)
		# aletas de la nariz: dos puntos de latón
		_esfera(0.0026, laton, cara_arriba, Vector3(lado * 0.007, 0.006, z)).scale = Vector3(1.0, 0.7, 0.45)

	# hueco del ojo (izquierda)
	hueco_ojo = _hueco_cara("hueco_ojo", "ojo", cara_arriba, Vector3(-0.055, y_ojos, z),
		_elipse(0.0185, 0.0095, 32), "Aquí falta un ojo.")
	var puesto := Escena.grupo(hueco_ojo, Vector3(0.0, 0.0, 0.0018), "Puesto")
	ojo_puesto_cerrado = _modelo_ojo(puesto, false)
	ojo_puesto_abierto = _modelo_ojo(puesto, true)
	ojo_puesto_abierto.hide()
	puesto.hide()
	hueco_ojo.colocado = puesto
	# hueco del cuerno (la frente)
	hueco_cuerno = _hueco_cara("hueco_cuerno", "cuerno", cara_arriba, Vector3(0.0, alto_arriba - 0.012, z),
		Geometria.poligono_regular(0.0058, 20), "En la frente hay un agujero pequeño.")
	var cuerno_puesto := Escena.grupo(hueco_cuerno, Vector3(0.0, 0.0, 0.002), "Puesto")
	_modelo_cuerno(cuerno_puesto).rotation = Vector3(PI / 2.0 - 0.5, 0.0, 0.0)
	cuerno_puesto.hide()
	hueco_cuerno.colocado = cuerno_puesto
	# hueco de la boca (en la mandíbula)
	hueco_boca = _hueco_cara("hueco_boca", "boca", mandibula, Vector3(0.0, alto_abajo * 0.5, z),
		_contorno_boca(1.08), "Aquí falta la boca.")
	var boca_puesta := Escena.grupo(hueco_boca, Vector3(0.0, 0.0, 0.0018), "Puesta")
	_modelo_boca(boca_puesta)
	boca_puesta.hide()
	hueco_boca.colocado = boca_puesta


# Hueco de la cara: la silueta de lo que falta en laca negra, con un reborde de latón
func _hueco_cara(id_hueco: String, acepta: String, padre: Node3D, posicion: Vector3, contorno: PackedVector2Array,
		aviso: String) -> PiezaRanura:
	var hueco := PiezaRanura.new()
	hueco.id = id_hueco
	hueco.acepta = acepta
	hueco.aviso_vacia = aviso
	hueco.aviso_otro = "Eso no encaja en la cara."
	hueco.aviso_bloqueo = "La cara no se deja tocar mientras el ojo está despierto."
	hueco.position = posicion
	Geometria.pieza(Geometria.extruir(contorno, 0.0008), Materiales.liso(Color(0.07, 0.015, 0.012), 0.35), Vector3.ZERO, hueco)
	_reborde(hueco, contorno, 0.003, laton, 0.0009)
	hueco.desde = Vector3(0.0, 0.0, 0.03)
	var caja_hueco := Rect2()
	for punto in contorno:
		caja_hueco = caja_hueco.expand(punto)
	hueco.colisor_caja(Vector3(caja_hueco.size.x + 0.008, caja_hueco.size.y + 0.008, 0.006))
	hueco.permiso = func() -> bool: return dormida
	hueco.rechazada.connect(func(_p): _quizas_enfadar())
	agregar(hueco, padre)
	hueco.accionada.connect(func(_p):
		completar("cara_" + acepta)
		_comprobar_cara())
	return hueco


# El ojo que vigila: iris rojo con luz propia, pupila que te sigue y párpados de mosaico
func _ojo(posicion: Vector3) -> void:
	ojo = Escena.grupo(cara_arriba, posicion, "Ojo")
	var a := 0.019
	var b := 0.0098
	var cuenca := Geometria.pieza(Geometria.extruir(_elipse(a, b, 48), 0.001), laca_negra, Vector3(0, 0, 0.0005), ojo)
	cuenca.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	material_iris = Materiales.emisivo(Color(1.0, 0.16, 0.08), 2.4, Color(0.3, 0.02, 0.01))
	var iris := _cilindro(0.0085, 0.0085, 0.001, material_iris, ojo, Vector3(0.0, 0.0, 0.0016), 40)
	iris.rotation = Vector3(PI / 2.0, 0.0, 0.0)
	pupila = Escena.grupo(ojo, Vector3(0.0, 0.0, 0.0024), "Pupila")
	var negra := _cilindro(0.0034, 0.0034, 0.0008, Materiales.liso(Color(0.01, 0.005, 0.005), 0.08), pupila, Vector3.ZERO, 32)
	negra.rotation = Vector3(PI / 2.0, 0.0, 0.0)
	negra.scale = Vector3(0.55, 1.0, 1.0)
	parpado_arriba = Escena.grupo(ojo, Vector3(0.0, b, 0.0034), "ParpadoArriba")
	parpado_abajo = Escena.grupo(ojo, Vector3(0.0, -b, 0.0034), "ParpadoAbajo")
	var media := _media_elipse(a * 1.02, b * 1.02, 24)
	Geometria.pieza(Geometria.extruir(media, 0.0012), _mosaico("kikko"), Vector3(0.0, -b * 1.02, 0.0), parpado_arriba)
	var abajo := Geometria.pieza(Geometria.extruir(media, 0.0012), _mosaico("kikko"), Vector3(0.0, b * 1.02, 0.0), parpado_abajo)
	abajo.rotation = Vector3(0.0, 0.0, PI)
	_reborde(ojo, _elipse(a + 0.0012, b + 0.0012, 48), 0.0018, laton, 0.0034)
	luz_ojo = Escena.luz(ojo, Vector3(0.0, 0.0, 0.03), Color(1.0, 0.2, 0.1), 0.0, 0.3)
	_poner_parpados()


# --- Cámara interior: un altar de laca sellado con un ofuda, y lo que estaba encerrado --------------

func _interior() -> void:
	var g := 0.0012
	var f := FONDO / 2.0
	# forro de laca roja y fondo de pan de oro
	_bloque(Vector3(-0.085, -0.062, -0.04), Vector3(0.085, -0.062 + g, f - 0.001), laca_roja, null, false)
	_bloque(Vector3(-0.085, 0.045 - g, -0.04), Vector3(0.085, 0.045, f - 0.001), laca_roja, null, false)
	_bloque(Vector3(-0.085, -0.062, -0.04), Vector3(-0.085 + g, 0.045, f - 0.001), laca_roja, null, false)
	_bloque(Vector3(0.085 - g, -0.062, -0.04), Vector3(0.085, 0.045, f - 0.001), laca_roja, null, false)
	_bloque(Vector3(-0.085, -0.062, -0.04), Vector3(0.085, 0.045, -0.04 + g), oro, null, false)
	# el altar (zushi): caja de laca negra con dos puertas y herrajes de oro
	var altar := Escena.grupo(caja, Vector3(0.0, -0.0615, -0.026), "Altar")
	_bloque(Vector3(-0.036, 0.0, -0.013), Vector3(0.036, 0.004, 0.013), laca_negra, altar, false)
	_bloque(Vector3(-0.033, 0.004, -0.012), Vector3(0.033, 0.07, 0.01), laca_negra, altar, false)
	_bloque(Vector3(-0.038, 0.07, -0.015), Vector3(0.038, 0.076, 0.015), laca_negra, altar, false)
	_bloque(Vector3(-0.03, 0.008, 0.0095), Vector3(0.03, 0.066, 0.0105), laca_roja, altar, false)
	# cada hoja gira por su canto de fuera
	for lado in [-1.0, 1.0]:
		var hoja := Escena.grupo(altar, Vector3(lado * 0.03, 0.037, 0.0115), "Puerta")
		var x0 := -0.03 if lado > 0.0 else 0.0
		var x1 := 0.0 if lado > 0.0 else 0.03
		Escena.bloque(Vector3(x0, -0.029, 0.0), Vector3(x1, 0.029, 0.002), laca_negra, hoja, 0.0003, false)
		Escena.bloque(Vector3(x0 + 0.003, -0.026, 0.002), Vector3(x1 - 0.003, 0.026, 0.0026), oro, hoja, 0.0002, false)
		Escena.bloque(Vector3(x0 + 0.005, -0.024, 0.0026), Vector3(x1 - 0.005, 0.024, 0.003), laca_negra, hoja, 0.0002, false)
		puertas_altar.append([hoja, lado * 1.9])
	# el ofuda: papel que sella las dos puertas; se despega tirando hacia abajo
	ofuda = PiezaDeslizante.new()
	ofuda.id = "ofuda"
	ofuda.position = Vector3(0.0, -0.0615 + 0.037, -0.026 + 0.015)
	ofuda.configurar(Vector3.DOWN, 0.0, 0.03, [0.0, 0.03])
	ofuda.sonido_mover = "papel"
	ofuda.sonido_tope = "papel"
	var papel := Escena.calcomania(Materiales.textura("ofuda"), Vector2(0.02, 0.056), Color.WHITE, ofuda,
		Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, 0.0006)))
	(papel.material_override as StandardMaterial3D).transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	ofuda.colisor_caja(Vector3(0.024, 0.06, 0.004))
	ofuda.permiso = func() -> bool: return cara_completa
	agregar(ofuda, caja)
	ofuda.accionada.connect(func(_p):
		if ofuda.en(0.03) and not hecho("ofuda"):
			ofuda.habilitada = false
			ofuda.controla_transform = false
			var caida := create_tween().set_parallel()
			caida.tween_property(ofuda, "position:y", ofuda.position.y - 0.03, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			caida.tween_property(ofuda, "rotation:z", 0.9, 0.6)
			caida.tween_property(ofuda, "position:z", ofuda.position.z + 0.03, 0.6)
			completar("ofuda"))
	# lo que estaba encerrado: una luz que flota
	espiritu = Escena.grupo(caja, Vector3(0.0, -0.022, -0.02), "Espiritu")
	_esfera(0.0065, Materiales.emisivo(Color(0.75, 0.92, 1.0), 3.0, Color(0.6, 0.8, 1.0)), espiritu)
	luz_espiritu = Escena.luz(espiritu, Vector3.ZERO, Color(0.7, 0.88, 1.0), 0.0, 0.45)
	espiritu.hide()
	luz_interior = Escena.luz(caja, Vector3(0.0, 0.02, 0.06), Color(1.0, 0.72, 0.42), 0.0, 0.32)


# --- Hueco de debajo de la tapa: la boca de laca y la ola pintada ------------------------------------

func _hueco_de_la_tapa() -> void:
	boca = PiezaRecogible.new()
	boca.id = "boca"
	boca.nombre_objeto = "Boca de laca"
	boca.position = Vector3(-0.0925, 0.0695, 0.014)
	boca.rotation = Vector3(-PI / 2.0, 0.0, 0.25)
	boca.modelo = Escena.grupo(boca, Vector3.ZERO, "Modelo")
	_modelo_boca(boca.modelo)
	boca.colisor_caja(Vector3(0.064, 0.026, 0.012))
	boca.permiso = func() -> bool: return tapa.reposo > TAPA_2 - 0.002
	agregar(boca, caja)
	boca.accionada.connect(func(_p): completar("boca"))
	Escena.calcomania(Materiales.textura("simbolo_ola"), Vector2(0.022, 0.022), Color(0.85, 0.12, 0.08), caja,
		Transform3D(Basis(Vector3.RIGHT, -PI / 2.0), Vector3(-0.0925, 0.0638, -0.03)))


# La boca: labios de laca roja con una línea de oro y dos colmillos pequeños
func _modelo_boca(padre: Node3D) -> Node3D:
	var nodo := Escena.grupo(padre, Vector3.ZERO, "Boca")
	Geometria.pieza(Geometria.extruir(_contorno_boca(1.0), 0.004), laca_roja, Vector3.ZERO, nodo)
	var linea: Array = []
	for k in 9:
		var t := lerpf(-1.0, 1.0, k / 8.0)
		linea.append(Vector2(t * 0.026, 0.0004 - t * t * 0.0006))
	_trazo(nodo, linea, 0.0011, oro, 0.0021)
	for lado in [-1.0, 1.0]:
		var colmillo := _cilindro(0.0, 0.0017, 0.0055, Materiales.liso(Color(0.95, 0.92, 0.85), 0.3), nodo,
			Vector3(lado * 0.013, -0.0035, 0.0021), 10)
		colmillo.rotation = Vector3(PI, 0.0, 0.0)
	return nodo


# El cuerno: de hueso, con un aro de latón en la base
func _modelo_cuerno(padre: Node3D) -> Node3D:
	var nodo := Escena.grupo(padre, Vector3.ZERO, "Cuerno")
	var hueso := Materiales.liso(Color(0.92, 0.86, 0.74), 0.34)
	_cilindro(0.0036, 0.0054, 0.016, hueso, nodo, Vector3(0.0, 0.008, 0.0), 16)
	var arriba := _cilindro(0.0004, 0.0036, 0.016, hueso, nodo, Vector3(0.0, 0.0225, 0.0018), 16)
	arriba.rotation = Vector3(0.22, 0.0, 0.0)
	_toro(0.0046, 0.0062, laton, nodo, Vector3(0.0, 0.001, 0.0))
	return nodo


# --- En la mesa: el incensario (con el cuerno dentro) y el juego de té -------------------------------

func _incensario() -> void:
	var koro := Escena.grupo(self, INCENSARIO, "Incensario")
	koro.rotation.y = -0.35
	# tres patas, el cuenco (con la ceniza dentro) y las cuatro placas de los símbolos
	for k in 3:
		var angulo := k * TAU / 3.0 + 0.4
		_cilindro(0.003, 0.005, 0.009, bronce, koro, Vector3(cos(angulo) * 0.03, 0.0045, sin(angulo) * 0.03), 10)
	var perfil := PackedVector2Array([Vector2(0.0, 0.008), Vector2(0.028, 0.008), Vector2(0.04, 0.014), Vector2(0.046, 0.028),
		Vector2(0.0452, 0.04), Vector2(0.04, 0.046), Vector2(0.034, 0.046), Vector2(0.032, 0.032), Vector2(0.0, 0.028)])
	Geometria.pieza(Geometria.torno(perfil, 40), bronce, Vector3.ZERO, koro)
	_cilindro(0.031, 0.031, 0.001, Materiales.liso(Color(0.55, 0.53, 0.5), 0.95), koro, Vector3(0.0, 0.0292, 0.0), 32)
	for k in SIMBOLOS.size():
		var angulo := k * TAU / 4.0
		var direccion := Vector3(sin(angulo), 0.0, cos(angulo))
		var placa := Escena.grupo(koro, direccion * 0.0464 + Vector3(0.0, 0.027, 0.0), "Placa")
		placa.rotation.y = angulo
		Escena.bloque(Vector3(-0.0105, -0.0105, -0.0006), Vector3(0.0105, 0.0105, 0.0006), laton, placa, 0.0003, false)
		Escena.calcomania(Materiales.textura("simbolo_" + SIMBOLOS[k]), Vector2(0.016, 0.016), Color(0.1, 0.06, 0.03),
			placa, Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, 0.0008)))
	# la tapa: gira por topes; el león de encima marca hacia dónde mira
	tapa_incensario = Escena.grupo(koro, Vector3(0.0, 0.046, 0.0), "Tapa")
	incensario = PiezaGiratoria.new()
	incensario.id = "incensario"
	incensario.configurar(Vector3.UP, TAU / 8.0)
	incensario.sonido_tope = "clic_metal"
	var cupula := PackedVector2Array([Vector2(0.037, 0.0), Vector2(0.0365, 0.006), Vector2(0.03, 0.014), Vector2(0.016, 0.0205),
		Vector2(0.0, 0.0215)])
	Geometria.pieza(Geometria.torno(cupula, 40), bronce, Vector3.ZERO, incensario)
	for k in 8:
		var angulo := k * TAU / 8.0 + TAU / 16.0
		_esfera(0.0022, laca_negra, incensario, Vector3(sin(angulo) * 0.026, 0.0118, cos(angulo) * 0.026))
	var leon := Escena.grupo(incensario, Vector3(0.0, 0.0205, 0.0), "Leon")
	leon.scale = Vector3.ONE * 1.55
	Escena.bloque(Vector3(-0.0045, 0.0, -0.007), Vector3(0.0045, 0.0075, 0.003), bronce, leon, 0.0015, false)
	_esfera(0.0056, bronce, leon, Vector3(0.0, 0.0095, 0.0045))
	_toro(0.0042, 0.0072, bronce, leon, Vector3(0.0, 0.0095, 0.0032)).rotation = Vector3(PI / 2.0, 0.0, 0.0)
	var hocico := _cilindro(0.0018, 0.0034, 0.006, bronce, leon, Vector3(0.0, 0.0088, 0.0098), 10)
	hocico.rotation = Vector3(PI / 2.0, 0.0, 0.0)
	for lado in [-1.0, 1.0]:
		_esfera(0.0017, bronce, leon, Vector3(lado * 0.0036, 0.0148, 0.0035))
		_esfera(0.0011, oro, leon, Vector3(lado * 0.0022, 0.0108, 0.0092))
	incensario.colisor(_forma_cilindro(0.04, 0.034), Transform3D(Basis.IDENTITY, Vector3(0.0, 0.014, 0.0)))
	agregar(incensario, tapa_incensario)
	incensario.accionada.connect(func(_p):
		if incensario.tope(8) == MONTE and not hecho("incensario"):
			_abrir_incensario())
	# humo de incienso que sale por los agujeros de la tapa
	humo = CPUParticles3D.new()
	humo.amount = 26
	humo.lifetime = 4.0
	humo.preprocess = 4.0
	humo.local_coords = false
	humo.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	humo.emission_sphere_radius = 0.012
	humo.direction = Vector3.UP
	humo.spread = 10.0
	humo.gravity = Vector3(0.0, 0.004, 0.0)
	humo.initial_velocity_min = 0.012
	humo.initial_velocity_max = 0.022
	humo.scale_amount_min = 0.6
	humo.scale_amount_max = 1.2
	var curva := Curve.new()
	curva.add_point(Vector2(0.0, 0.4))
	curva.add_point(Vector2(1.0, 2.4))
	humo.scale_amount_curve = curva
	var rampa := Gradient.new()
	rampa.set_color(0, Color(0.85, 0.85, 0.88, 0.3))
	rampa.set_color(1, Color(0.85, 0.85, 0.88, 0.0))
	humo.color_ramp = rampa
	var hoja := QuadMesh.new()
	hoja.size = Vector2(0.012, 0.012)
	var material_humo := StandardMaterial3D.new()
	material_humo.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material_humo.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material_humo.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	material_humo.vertex_color_use_as_albedo = true
	material_humo.albedo_texture = Escena._punto()
	material_humo.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	hoja.material = material_humo
	humo.mesh = hoja
	humo.position = Vector3(0.0, 0.07, 0.0)
	koro.add_child(humo)
	# el cuerno, sobre la ceniza (se ve al levantarse la tapa)
	cuerno = PiezaRecogible.new()
	cuerno.id = "cuerno"
	cuerno.nombre_objeto = "Cuerno"
	cuerno.position = Vector3(0.0, 0.032, 0.0)
	cuerno.rotation = Vector3(PI / 2.0 - 0.25, 0.6, 0.0)
	cuerno.modelo = Escena.grupo(cuerno, Vector3.ZERO, "Modelo")
	_modelo_cuerno(cuerno.modelo)
	cuerno.colisor_caja(Vector3(0.014, 0.034, 0.014), Vector3(0.0, 0.014, 0.0))
	cuerno.permiso = func() -> bool: return hecho("incensario")
	cuerno.habilitada = false
	agregar(cuerno, koro)
	cuerno.accionada.connect(func(_p): completar("cuerno"))


func _abrir_incensario() -> void:
	completar("incensario")
	incensario.habilitada = false
	cuerno.habilitada = true
	if mesa:
		mesa.sonido.sonar("mecanismo", -5.0)
		mesa.mensaje("El león mira a la montaña y la tapa se levanta.", 3.0)
	var animacion := create_tween().set_parallel()
	animacion.tween_property(tapa_incensario, "position", tapa_incensario.position + Vector3(0.0, 0.045, -0.035), 1.1) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	animacion.tween_property(tapa_incensario, "rotation:x", -0.6, 1.1).set_trans(Tween.TRANS_SINE)
	humo.amount = 40
	humo.initial_velocity_max = 0.05
	await get_tree().create_timer(1.2).timeout
	humo.emitting = false


func _juego_de_te() -> void:
	var te := Escena.grupo(self, BANDEJA, "JuegoDeTe")
	te.rotation.y = 0.3
	# bandeja de laca negra con filo rojo
	Escena.bloque(Vector3(-0.085, 0.0, -0.055), Vector3(0.085, 0.006, 0.055), laca_negra, te, 0.002, false)
	Escena.bloque(Vector3(-0.0855, 0.006, -0.0555), Vector3(0.0855, 0.0085, -0.0525), laca_roja, te, 0.0006, false)
	Escena.bloque(Vector3(-0.0855, 0.006, 0.0525), Vector3(0.0855, 0.0085, 0.0555), laca_roja, te, 0.0006, false)
	Escena.bloque(Vector3(-0.0855, 0.006, -0.0555), Vector3(-0.0825, 0.0085, 0.0555), laca_roja, te, 0.0006, false)
	Escena.bloque(Vector3(0.0825, 0.006, -0.0555), Vector3(0.0855, 0.0085, 0.0555), laca_roja, te, 0.0006, false)
	# tetera (kyūsu) de barro, con el asa de lado
	var barro := Materiales.liso(Color(0.5, 0.22, 0.13), 0.55)
	var tetera := Escena.grupo(te, Vector3(-0.03, 0.006, -0.005), "Tetera")
	Geometria.pieza(Geometria.torno(PackedVector2Array([Vector2(0.0, 0.0), Vector2(0.024, 0.0), Vector2(0.032, 0.01),
		Vector2(0.0335, 0.026), Vector2(0.026, 0.038), Vector2(0.02, 0.04), Vector2(0.0, 0.0405)]), 32), barro, Vector3.ZERO, tetera)
	Geometria.pieza(Geometria.torno(PackedVector2Array([Vector2(0.0205, 0.0), Vector2(0.021, 0.003), Vector2(0.012, 0.007),
		Vector2(0.0, 0.008)]), 24), barro, Vector3(0.0, 0.0395, 0.0), tetera)
	_esfera(0.0035, barro, tetera, Vector3(0.0, 0.049, 0.0))
	var pico := _cilindro(0.003, 0.0055, 0.03, barro, tetera, Vector3(0.036, 0.024, 0.0), 12)
	pico.rotation = Vector3(0.0, 0.0, -1.0)
	var asa := _cilindro(0.0042, 0.005, 0.042, barro, tetera, Vector3(0.0, 0.022, -0.048), 12)
	asa.rotation = Vector3(PI / 2.0 - 0.15, 0.0, 0.0)
	# dos tazas de celadón
	var celadon := Materiales.liso(Color(0.6, 0.72, 0.62), 0.22)
	for lugar in [Vector3(0.04, 0.006, 0.026), Vector3(0.05, 0.006, -0.024)]:
		Geometria.pieza(Geometria.torno(PackedVector2Array([Vector2(0.0, 0.0), Vector2(0.015, 0.0), Vector2(0.018, 0.004),
			Vector2(0.0205, 0.031), Vector2(0.019, 0.032), Vector2(0.0165, 0.007), Vector2(0.0, 0.006)]), 28), celadon, lugar, te)
		_cilindro(0.0165, 0.0165, 0.0005, Materiales.liso(Color(0.36, 0.42, 0.12), 0.15), te, lugar + Vector3(0.0, 0.024, 0.0), 24)
	# para el doble toque (se mira de cerca, pero no se toca)
	_opaco(te, Vector3(0.17, 0.05, 0.11), Vector3(0.0, 0.025, 0.0))


# --- Pasos y pistas ------------------------------------------------------------------------------

func _pasos() -> void:
	paso("costado_derecho", [
		"Las cajas secretas se abren moviendo sus paneles en orden. Busca uno que ceda.",
		"El costado derecho no lo vigila el ojo.",
		"Desliza hacia atrás el panel del costado derecho."], "lado_derecho")
	paso("llave", [
		"Detrás del panel había un nicho.",
		"Dentro hay algo pequeño, de bambú.",
		"Toca la llave de bambú para guardarla."], "llave")
	paso("tapa_1", [
		"Al correr ese costado, algo de arriba quedó libre.",
		"La tapa de mosaico puede correrse un poco.",
		"Desliza la tapa hacia la derecha."], "tapa")
	paso("costado_izquierdo", [
		"El otro costado también se mueve, pero el ojo no deja mientras te mira.",
		"Gira hasta que el ojo no te vea y prueba otra vez.",
		"Desde atrás, desliza hacia atrás el panel del costado izquierdo."], "lado_izquierdo")
	paso("tapa_2", [
		"Ahora la tapa tiene más recorrido.",
		"Sigue corriendo la tapa.",
		"Desliza la tapa del todo hacia la derecha."], "tapa")
	paso("boca", [
		"Bajo la tapa hay un hueco con algo rojo.",
		"Es una boca de laca: a alguien le falta.",
		"Toca la boca para guardarla."], "boca")
	paso("simbolo", [
		"En el costado izquierdo apareció un disco con cuatro símbolos.",
		"En el hueco de la tapa hay un símbolo pintado en rojo: una ola.",
		"Sin que el ojo te vea, gira el disco hasta dejar la ola arriba, bajo la muesca."], "disco")
	paso("cajoncito", [
		"Algo hizo clic bajo el disco.",
		"La flor de latón de debajo del disco es el tirador de un cajoncito.",
		"Tira del cajoncito."], "cajoncito")
	paso("ojo", [
		"En el cajoncito hay un ojo de madera, cerrado.",
		"Es el ojo que le falta a la cara.",
		"Toca el ojo dormido para guardarlo."], "ojo")
	paso("cerradura", [
		"La llave de bambú abre algo de la propia caja.",
		"Mira de cerca el zócalo de olas, por el lado derecho.",
		"Elige la llave y toca la placa de latón escondida entre las olas del zócalo."], "cerradura")
	paso("cajon", [
		"La llave giró. Algo del zócalo quedó suelto.",
		"El cordón de seda no es un adorno.",
		"Tira del cordón para sacar el cajón del zócalo."], "cajon")
	paso("koma", [
		"En el cajón hay una ficha de madera y una nota.",
		"La nota cuenta para qué sirve la ficha.",
		"Toca la ficha para guardarla."], "koma")
	paso("dormir", [
		"El ojo no deja tocar la cara. La ficha lo hace dormir.",
		"Mira la caja por detrás: hay un hueco con forma de ficha.",
		"Elige la ficha y toca el hueco de la parte de atrás."], "ranura")
	paso("incensario", [
		"La nota habla del incensario de la mesa y de lo que cuelga en el tokonoma.",
		"El rollo del fondo de la habitación pinta una montaña. Las placas del incensario tienen símbolos.",
		"Gira la tapa del incensario hasta que el león mire la placa de la montaña."], "incensario")
	paso("cuerno", [
		"La tapa del incensario se ha levantado.",
		"Sobre la ceniza hay un cuerno pequeño.",
		"Toca el cuerno para guardarlo."], "cuerno")
	paso("cara_ojo", [
		"Con el ojo dormido, la cara ya se deja tocar.",
		"La cara tiene un hueco con forma de ojo.",
		"Elige el ojo dormido y toca el hueco vacío de la cara."], "hueco_ojo")
	paso("cara_boca", [
		"A la cara le falta la boca.",
		"La boca de laca encaja debajo de los ojos.",
		"Elige la boca y toca su hueco en la cara."], "hueco_boca")
	paso("cara_cuerno", [
		"En la frente hay un agujero pequeño.",
		"Ahí va el cuerno.",
		"Elige el cuerno y toca el agujero de la frente."], "hueco_cuerno")
	paso("ofuda", [
		"La caja abrió la boca. Dentro hay un altar sellado.",
		"Un papel, el ofuda, sella sus puertas.",
		"Arrastra el ofuda hacia abajo para despegarlo."], "ofuda")
	titulo_final = "La caja ha despertado"
	texto_final = "Le devolviste la cara: el ojo, la boca y el cuerno. Al despertar abrió la boca, y lo que guardaba " \
		+ "bajo el sello se fue flotando.\nEn la colección quedan otras cajas, y también tienen cien años."


# Zonas de cerca para el doble toque: las caras de la caja, el zócalo, la mesa y el rollo del tokonoma
func _zonas() -> void:
	var c := CENTRO_Y
	zona("cara", Vector3(0.0, c, FONDO / 2.0 + PLACA), 0.38, 0.0, 0.1, 0.1)
	zona("tapa", Vector3(0.0, c + ALTO / 2.0 + PLACA, 0.0), 0.44, NAN, 1.05, 0.1)
	zona("hueco", Vector3(-0.092, c + ALTO / 2.0, 0.0), 0.28, NAN, 1.15, 0.05)
	zona("derecho", Vector3(ANCHO / 2.0 + PLACA, c + 0.01, 0.02), 0.36, PI / 2.0, 0.12, 0.09)
	zona("izquierdo", Vector3(-ANCHO / 2.0 - PLACA, c, 0.03), 0.34, -PI / 2.0, 0.1, 0.09)
	zona("trasera", Vector3(0.0, c, -FONDO / 2.0 - PLACA), 0.36, PI, 0.12, 0.1)
	zona("zocalo", Vector3(ANCHO / 2.0 + PLACA + VUELO, c - ALTO / 2.0 - PLACA - ZOCALO / 2.0, 0.0), 0.27, PI / 2.0, 0.32, 0.055)
	zona("incensario", INCENSARIO + Vector3(0.0, 0.05, 0.0), 0.3, NAN, 0.55, 0.08)
	zona("te", BANDEJA + Vector3(0.0, 0.03, 0.0), 0.32, NAN, 0.6, 0.09)
	zona("rollo", ROLLO, 1.05, 0.0, 0.02, 0.75)


# --- Cámara, luz y ambiente --------------------------------------------------------------------

func preparar_camara(camara: CamaraPuzle) -> void:
	camara.camara.fov = 38.0
	camara.configurar_orbita(Vector3(0.0, CENTRO_Y - 0.012, 0.0), 0.55, 0.42, 1.02, Vector2(0.2, 1.6), Vector2(-1.38, 1.38))
	camara.altura_minima = MESA_Y + 0.02
	camara.poner_luz(0.4, 1.4)


# De las fusuma del pasillo a la mesa baja
func ruta_entrada() -> Dictionary:
	var piso: float = Washitsu.PISO
	return {"puntos": [Vector3(0.0, piso + 1.47, 3.15), Vector3(0.0, piso + 1.4, 2.25), Vector3(0.12, piso + 1.12, 1.45)],
		"miradas": [Vector3(0.0, -0.1, 0.0), Vector3(0.0, -0.1, 0.0), Vector3(0.0, -0.05, 0.0)],
		"duracion": 6.0, "fov": 52.0}


func preparar_entorno(entorno: Environment) -> void:
	# el cielo solo da reflejos a la laca y al latón: la habitación está cerrada
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
	# luz cálida de arriba, como el reflejo del andon en el techo, y una suave sobre la mesa
	Escena.luz(self, Vector3(0.1, 0.9, 0.25), Color(1.0, 0.8, 0.6), 0.35, 1.8)
	Escena.luz(self, Vector3(0.0, 0.42, 0.42), Color(1.0, 0.86, 0.7), 0.22, 1.0)


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


# --- El ojo y la cara ------------------------------------------------------------------------------

func ve() -> bool:
	if dormida or cara_completa or not _despierta:
		return false
	var hacia: Vector3 = (mesa.camara.camara.global_position - ojo.global_position).normalized()
	return caja.global_basis.z.normalized().dot(hacia) > CONO_OJO


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
	mesa.mensaje("El ojo se ha dormido. Ahora la cara se deja tocar.", 3.2)
	var animacion := create_tween()
	animacion.tween_property(luz_ojo, "light_energy", 0.0, 1.5)


func _comprobar_cara() -> void:
	if hueco_ojo.llena and hueco_boca.llena and hueco_cuerno.llena and not cara_completa:
		_despertar()


# La cara está completa: la caja despierta, abre los dos ojos (ahora dorados) y abre la boca
func _despertar() -> void:
	cara_completa = true
	dormida = false
	mesa.sonido.sonar("despertar", -1.0)
	mesa.vibrar(90, 0.9)
	material_iris.emission = Color(1.0, 0.72, 0.25)
	luz_ojo.light_color = Color(1.0, 0.75, 0.35)
	await get_tree().create_timer(0.5).timeout
	ojo_puesto_cerrado.hide()
	ojo_puesto_abierto.show()
	mesa.camara.enfocar(caja.to_global(Vector3(0.0, 0.0, FONDO / 2.0)), 0.46, 0.0, 0.16, 1.1)
	await get_tree().create_timer(1.1).timeout
	mesa.sonido.sonar("mecanismo", -3.0)
	mesa.sonido.sonar("corredera", -6.0)
	var animacion := create_tween().set_parallel()
	animacion.tween_property(mandibula, "rotation:x", 1.25, 1.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	animacion.tween_property(cara_arriba, "position:y", cara_arriba.position.y + 0.042, 1.3).set_trans(Tween.TRANS_SINE)
	animacion.tween_property(cara_arriba, "rotation:x", -0.16, 1.3).set_trans(Tween.TRANS_SINE)
	animacion.tween_property(luz_interior, "light_energy", 0.55, 1.5)
	mesa.mensaje("La caja ha despertado y abre la boca.", 3.5)
	await get_tree().create_timer(1.3).timeout
	mesa.camara.enfocar(caja.to_global(Vector3(0.0, -0.022, FONDO / 2.0 - 0.03)), 0.34, 0.0, 0.2, 1.4)


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
	if (_despierta and not dormida) or cara_completa:
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
		luz_ojo.light_energy = (0.22 + _enfado * 1.4) if (_despierta or cara_completa) else 0.0
	# la pupila mira a la cámara
	var hacia: Vector3 = ojo.global_basis.orthonormalized().inverse() * (posicion_camara - ojo.global_position).normalized()
	var mirada := Vector2(hacia.x, hacia.y).limit_length(1.0) * 0.0042
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
	mesa.camara.enfocar(caja.to_global(Vector3(0.0, -0.02, FONDO / 2.0 - 0.02)), 0.36, 0.0, 0.18, 1.2)
	var animacion := create_tween().set_parallel()
	for datos in puertas_altar:
		animacion.tween_property(datos[0], "rotation:y", float(datos[1]), 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.8).timeout
	espiritu.show()
	mesa.sonido.sonar("espiritu", -2.0)
	mesa.sonido.sonar("final_caja_viva", -1.0, 1.0, 0.0)
	var vuelo := create_tween().set_parallel()
	vuelo.tween_property(luz_espiritu, "light_energy", 0.7, 0.8)
	vuelo.tween_property(espiritu, "position", espiritu.position + Vector3(0.0, 0.2, 0.36), 3.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	vuelo.chain().tween_property(espiritu, "scale", Vector3.ONE * 0.01, 0.8)
	await get_tree().create_timer(3.8).timeout


# --- Prueba automática ---------------------------------------------------------------------------

func resolver_paso(id: String) -> void:
	match id:
		"costado_derecho":
			lado_derecho.tocar()
		"llave":
			llave.tocar()
		"tapa_1", "tapa_2":
			tapa.tocar()
		"costado_izquierdo":
			# primero de frente (el ojo lo impide) y luego desde atrás
			mesa.camara.enfocar(caja.global_position, 0.7, -0.3, 0.25, 0.1)
			await esperar_camara()
			lado_izquierdo.tocar()
			await get_tree().create_timer(0.5).timeout
			mesa.camara.enfocar(caja.global_position, 0.7, -PI * 0.8, 0.25, 0.1)
			await esperar_camara()
			lado_izquierdo.tocar()
		"boca":
			boca.tocar()
		"simbolo":
			mesa.camara.enfocar(caja.global_position, 0.6, -PI * 0.6, 0.2, 0.1)
			await esperar_camara()
			var fin := Time.get_ticks_msec() + 30000
			while disco.tope(4) != OLA and Time.get_ticks_msec() < fin:
				var antes := disco.tope(4)
				disco.tocar()
				while disco.tope(4) == antes and Time.get_ticks_msec() < fin:
					await get_tree().process_frame
		"cajoncito":
			cajoncito.tocar()
			var fin := Time.get_ticks_msec() + 20000
			while not cajoncito.en(SALE_CAJONCITO) and Time.get_ticks_msec() < fin:
				await get_tree().create_timer(0.35).timeout
				if not cajoncito.en(SALE_CAJONCITO):
					cajoncito.tocar()
		"ojo":
			ojo_dormido.tocar()
		"cerradura":
			mesa.seleccionar("llave")
			cerradura.tocar()
		"cajon":
			cajon.tocar()
		"koma":
			koma.tocar()
		"dormir":
			mesa.seleccionar("koma")
			mesa.camara.enfocar(caja.global_position, 0.6, PI, 0.15, 0.1)
			await esperar_camara()
			ranura.tocar()
		"incensario":
			var fin := Time.get_ticks_msec() + 60000
			while incensario.tope(8) != MONTE and Time.get_ticks_msec() < fin:
				var antes := incensario.tope(8)
				incensario.tocar()
				while incensario.tope(8) == antes and Time.get_ticks_msec() < fin:
					await get_tree().process_frame
		"cuerno":
			await get_tree().create_timer(0.6).timeout
			cuerno.tocar()
		"cara_ojo":
			mesa.seleccionar("ojo")
			hueco_ojo.tocar()
		"cara_boca":
			mesa.seleccionar("boca")
			hueco_boca.tocar()
		"cara_cuerno":
			mesa.seleccionar("cuerno")
			hueco_cuerno.tocar()
		"ofuda":
			var fin := Time.get_ticks_msec() + 30000
			while not cara_completa and Time.get_ticks_msec() < fin:
				await get_tree().process_frame
			await get_tree().create_timer(3.0).timeout
			ofuda.tocar()


func arrastre_de_prueba() -> Dictionary:
	return {"pieza": lado_derecho, "direccion": Vector3.FORWARD, "pixeles": 110.0,
		"comprobar": func() -> bool: return lado_derecho.en(CORRE)}


# Una pieza bloqueada al empezar (la prueba comprueba que no se mueve al tocarla)
func bloqueo_de_prueba() -> Pieza:
	return tapa


func capturas_de_prueba() -> Array:
	return ["tapa_2", "cajon", "incensario", "cara_cuerno", "ofuda"]


func comprobaciones() -> Array:
	return [["el ojo frena el costado izquierdo mientras te ve", bloqueo_por_ojo >= 1],
		["la ficha duerme al ojo y la cara se deja tocar", hecho("dormir")],
		["el incensario se abre cuando el león mira a la montaña", hecho("incensario")],
		["con la cara completa, la caja despierta y abre la boca", cara_completa]]
