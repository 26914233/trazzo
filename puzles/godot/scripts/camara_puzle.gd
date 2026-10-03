# Cámara de los puzles, con dos modos:
#  - órbita: el dedo gira alrededor del objeto (con inercia suave). El pellizco acerca hacia donde
#    están los dedos y, al alejar, el centro vuelve solo al de la vista general. El doble toque viaja a
#    una zona de cerca con un movimiento suave, como en The Room;
#  - puntos de vista: posiciones fijas de una habitación, con margen para mirar alrededor y acercar la
#    vista a un punto (doble toque o pellizco).
# Además hace el recorrido de entrada (de la puerta de la habitación hasta la caja) y lleva una luz
# suave que ilumina lo que se mira, para que ningún lado de la caja quede a oscuras.
class_name CamaraPuzle
extends Node3D

signal entrada_terminada

enum Modo { ORBITA, PUNTO }

const SENSIBILIDAD := 0.0068          # radianes por píxel, a 720 píxeles de alto
const SUAVIDAD := 14.0                 # cuanto más alto, antes alcanza la cámara su destino

var camara: Camera3D
var luz: OmniLight3D                   # luz de relleno que acompaña a la cámara
var modo := Modo.ORBITA
# Órbita
var objetivo := Vector3.ZERO
var guinada := 0.0
var cabeceo := 0.35
var distancia := 0.6
var limite_cabeceo := Vector2(-1.35, 1.35)
var limite_distancia := Vector2(0.3, 1.2)
var limite_guinada := Vector2(-INF, INF)
var altura_minima := -INF              # la cámara no baja de esta altura (la mesa sobre la que está la caja)
var inicial := {}
var zona_actual := ""                  # zona de cerca en la que está la cámara ("" = vista general)
var _objetivo_suave := Vector3.ZERO
var _guinada_suave := 0.0
var _cabeceo_suave := 0.35
var _distancia_suave := 0.6
var _inercia := Vector2.ZERO
var _arrastrando := false
var _viaje := {}                       # movimiento suave en curso (doble toque, centrar, enfoques)
# Puntos de vista
var puntos := {}                       # nombre -> Transform3D
var punto_actual := ""
var punto_inicial := ""
var historial: Array = []              # puntos anteriores (para «Volver»)
var limite_mirada := Vector2(0.4, 0.28)
var fov_base := 50.0
var de_cerca := false                  # vista acercada a un punto (doble toque en una habitación)
var _base := Transform3D.IDENTITY
var _mirada := Vector2.ZERO
var _mirada_suave := Vector2.ZERO
var _desde := Transform3D.IDENTITY
var _progreso := 1.0
var _fov := 50.0
# Entrada
var en_entrada := false
var _ruta: Curve3D
var _ruta_mirada: Curve3D
var _entrada_t := 1.0
var _entrada_duracion := 1.0
var _fov_entrada := 55.0
var _fov_final := 40.0


func _init() -> void:
	camara = Camera3D.new()
	camara.fov = 40.0
	camara.near = 0.02
	camara.far = 80.0
	add_child(camara)
	luz = OmniLight3D.new()
	luz.position = Vector3(0.0, 0.16, 0.05)
	luz.light_color = Color(1.0, 0.93, 0.84)
	luz.light_energy = 0.45
	luz.light_specular = 0.2
	luz.omni_range = 1.5
	luz.omni_attenuation = 1.6
	luz.shadow_enabled = false
	camara.add_child(luz)


func _ready() -> void:
	camara.current = true


func poner_luz(energia: float, alcance := 1.5, color := Color(1.0, 0.93, 0.84)) -> void:
	luz.light_energy = energia
	luz.omni_range = alcance
	luz.light_color = color
	luz.visible = energia > 0.0


# --- Órbita --------------------------------------------------------------------------------

func configurar_orbita(centro: Vector3, guinada_inicial: float, cabeceo_inicial: float,
		distancia_inicial: float, limites_distancia := Vector2(0.3, 1.2),
		limites_cabeceo := Vector2(-1.35, 1.35), limites_guinada := Vector2(-INF, INF)) -> void:
	modo = Modo.ORBITA
	objetivo = centro
	guinada = guinada_inicial
	cabeceo = cabeceo_inicial
	distancia = distancia_inicial
	limite_distancia = limites_distancia
	limite_cabeceo = limites_cabeceo
	limite_guinada = limites_guinada
	inicial = {"objetivo": centro, "guinada": guinada_inicial, "cabeceo": cabeceo_inicial,
		"distancia": distancia_inicial}
	zona_actual = ""
	_viaje = {}
	_saltar()


# El dedo toca la pantalla: se para la inercia
func detener() -> void:
	_inercia = Vector2.ZERO


func orbitar(relativo: Vector2) -> void:
	if en_entrada:
		return
	_cortar_viaje()
	var escala := 720.0 / maxf(1.0, get_viewport().get_visible_rect().size.y)
	var paso := relativo * escala
	_arrastrando = true
	if modo == Modo.ORBITA:
		guinada = clampf(guinada - paso.x * SENSIBILIDAD, limite_guinada.x, limite_guinada.y)
		cabeceo = clampf(cabeceo + paso.y * SENSIBILIDAD, _cabeceo_minimo(), limite_cabeceo.y)
		_inercia = paso
	else:
		# más despacio cuanto más acercada está la vista
		var factor := _fov / fov_base
		var limite := limite_mirada * (1.5 if de_cerca else 1.0)
		_mirada.x = clampf(_mirada.x + paso.x * SENSIBILIDAD * 0.5 * factor, -limite.x, limite.x)
		_mirada.y = clampf(_mirada.y + paso.y * SENSIBILIDAD * 0.5 * factor, -limite.y, limite.y)


func soltar() -> void:
	_arrastrando = false


# Acerca (factor < 1) o aleja (factor > 1). Al acercar, el centro de giro va hacia «punto» (lo que
# hay bajo los dedos); al alejar, vuelve poco a poco al centro de la vista general.
func pellizcar(factor: float, punto: Variant = null) -> void:
	if en_entrada:
		return
	if modo == Modo.PUNTO:
		_fov = clampf(_fov * factor, fov_base * 0.45, fov_base)
		de_cerca = _fov < fov_base * 0.9
		if not de_cerca and factor > 1.0:
			_mirada = _mirada * 0.9
		return
	_cortar_viaje()
	var antes := distancia
	distancia = clampf(distancia * factor, limite_distancia.x, limite_distancia.y)
	if distancia < antes and punto is Vector3:
		objetivo = objetivo.lerp(punto, clampf((1.0 - distancia / antes) * 1.1, 0.0, 1.0))
	elif distancia > antes and not inicial.is_empty():
		var falta: float = inicial.distancia - antes
		var t := 1.0 if falta <= 0.0 else clampf((distancia - antes) / falta, 0.0, 1.0)
		objetivo = objetivo.lerp(inicial.objetivo, t)
		if t >= 1.0:
			zona_actual = ""
	cabeceo = maxf(cabeceo, _cabeceo_minimo())


# Rueda del ratón (en el PC)
func acercar(factor: float) -> void:
	pellizcar(factor)


# Viaja con suavidad a mirar un punto. Los valores NAN se dejan como están.
func enfocar(centro: Vector3, distancia_nueva: float, guinada_nueva := NAN, cabeceo_nuevo := NAN,
		duracion := 1.0) -> void:
	if modo != Modo.ORBITA:
		return
	var g := guinada if is_nan(guinada_nueva) else _angulo_cercano(guinada_nueva, _guinada_suave)
	g = clampf(g, limite_guinada.x, limite_guinada.y)
	var c := cabeceo if is_nan(cabeceo_nuevo) else cabeceo_nuevo
	var d := clampf(distancia_nueva, limite_distancia.x, limite_distancia.y)
	c = clampf(c, _cabeceo_minimo_para(centro, d), limite_cabeceo.y)
	# en los giros largos la cámara se aleja un poco a mitad de camino, como si rodeara la caja
	var arco := clampf(absf(g - _guinada_suave) / PI, 0.0, 1.0) * 0.22
	_viaje = {"objetivo": _objetivo_suave, "distancia": _distancia_suave, "guinada": _guinada_suave,
		"cabeceo": _cabeceo_suave, "arco": arco, "t": 0.0, "duracion": maxf(duracion, 0.05)}
	objetivo = centro
	distancia = d
	guinada = g
	cabeceo = c
	_inercia = Vector2.ZERO
	zona_actual = "enfoque"


# Zona de cerca de una caja (la elige la mesa al hacer doble toque)
func enfocar_zona(zona: Dictionary, duracion := 0.85) -> void:
	enfocar(zona.centro, zona.distancia, zona.get("guinada", NAN), zona.get("cabeceo", NAN), duracion)
	zona_actual = zona.get("id", "zona")


# Vuelve a la distancia y al centro de la vista general, sin cambiar el lado desde el que se mira
func alejar(duracion := 0.8) -> void:
	if modo == Modo.PUNTO:
		alejar_vista()
		return
	if inicial.is_empty():
		return
	enfocar(inicial.objetivo, inicial.distancia, NAN, maxf(cabeceo, inicial.cabeceo * 0.5), duracion)
	zona_actual = ""


# Vuelve a la vista de partida (botón «Centrar»)
func centrar() -> void:
	if modo == Modo.ORBITA and not inicial.is_empty():
		enfocar(inicial.objetivo, inicial.distancia, inicial.guinada, inicial.cabeceo, 0.9)
		zona_actual = ""
	elif modo == Modo.PUNTO:
		if de_cerca:
			alejar_vista()
		else:
			volver()


func acercada() -> bool:
	if modo == Modo.PUNTO:
		return de_cerca
	return zona_actual != "" or (not inicial.is_empty() and distancia < inicial.distancia * 0.75)


# ¿Está la cámara quieta en la vista pedida? (lo usa la prueba automática)
func quieta() -> bool:
	if en_entrada:
		return false
	if modo == Modo.PUNTO:
		return _progreso >= 1.0
	return _viaje.is_empty() and absf(_guinada_suave - guinada) < 0.01 and absf(_cabeceo_suave - cabeceo) < 0.01 \
		and absf(_distancia_suave - distancia) < 0.005 and _objetivo_suave.distance_to(objetivo) < 0.003


func _cortar_viaje() -> void:
	if _viaje.is_empty():
		return
	_viaje = {}
	objetivo = _objetivo_suave
	distancia = clampf(_distancia_suave, limite_distancia.x, limite_distancia.y)
	guinada = _guinada_suave
	cabeceo = _cabeceo_suave


func _cabeceo_minimo() -> float:
	return _cabeceo_minimo_para(objetivo, distancia)


# Ángulo más bajo al que puede mirar sin meterse por debajo de la mesa
func _cabeceo_minimo_para(centro: Vector3, d: float) -> float:
	if altura_minima == -INF or d <= 0.0:
		return limite_cabeceo.x
	var seno := (altura_minima - centro.y) / d
	if seno <= -1.0:
		return limite_cabeceo.x
	return maxf(limite_cabeceo.x, asin(clampf(seno, -1.0, 1.0)))


# Salta al destino sin animación
func _saltar() -> void:
	_objetivo_suave = objetivo
	_guinada_suave = guinada
	_cabeceo_suave = cabeceo
	_distancia_suave = distancia
	_mirada_suave = _mirada
	_progreso = 1.0
	if is_inside_tree():
		_aplicar()


func _angulo_cercano(angulo: float, referencia: float) -> float:
	return referencia + wrapf(angulo - referencia, -PI, PI)


static func _suave(t: float) -> float:
	return t * t * t * (t * (t * 6.0 - 15.0) + 10.0)


# --- Puntos de vista (habitaciones) -----------------------------------------------------------

func configurar_puntos(lista: Dictionary, inicial_nombre: String, fov := 50.0) -> void:
	modo = Modo.PUNTO
	puntos = lista
	fov_base = fov
	_fov = fov
	punto_inicial = inicial_nombre
	punto_actual = inicial_nombre
	historial.clear()
	_base = puntos[inicial_nombre]
	_saltar()


func ir_a(nombre: String, duracion := 0.9) -> void:
	if not puntos.has(nombre) or nombre == punto_actual:
		return
	historial.append(punto_actual)
	_ir_al_punto(nombre, duracion)


func volver() -> void:
	if historial.is_empty():
		if punto_actual != punto_inicial:
			_ir_al_punto(punto_inicial, 0.8)
		return
	_ir_al_punto(historial.pop_back(), 0.8)


func _ir_al_punto(nombre: String, duracion: float) -> void:
	_desde = camara.global_transform
	_base = puntos[nombre]
	punto_actual = nombre
	_mirada = Vector2.ZERO
	_mirada_suave = Vector2.ZERO
	_fov = fov_base
	de_cerca = false
	_progreso = 0.0
	var animacion := create_tween()
	animacion.tween_property(self, "_progreso", 1.0, duracion).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


# Acerca la vista hacia un punto de la pantalla (y la aleja si ya estaba acercada)
func mirar_de_cerca(posicion: Vector2) -> void:
	if modo != Modo.PUNTO or en_entrada:
		return
	if de_cerca:
		alejar_vista()
		return
	var direccion := _base.basis.orthonormalized().inverse() * camara.project_ray_normal(posicion)
	var limite := limite_mirada * 1.5
	var horizontal := Vector2(direccion.x, direccion.z).length()
	_mirada = Vector2(clampf(atan2(-direccion.x, -direccion.z), -limite.x, limite.x),
		clampf(atan2(direccion.y, horizontal), -limite.y, limite.y))
	_fov = fov_base * 0.5
	de_cerca = true


func alejar_vista() -> void:
	_fov = fov_base
	_mirada = Vector2.ZERO
	de_cerca = false


# --- Recorrido de entrada ------------------------------------------------------------------

# La cámara va desde la puerta hasta la vista de partida pasando por «lista_puntos» y mirando a
# «lista_miradas» (un punto de mira por cada punto del recorrido). Acaba justo en la vista inicial.
func entrada(lista_puntos: Array, lista_miradas: Array, duracion := 5.5, fov_inicio := 55.0) -> void:
	var final := _vista_inicial()
	var recorrido := lista_puntos.duplicate()
	var miradas := lista_miradas.duplicate()
	recorrido.append(final.posicion)
	miradas.append(final.mira)
	_ruta = _curva(recorrido)
	_ruta_mirada = _curva(miradas)
	_fov_entrada = fov_inicio
	_fov_final = fov_base if modo == Modo.PUNTO else camara.fov
	_entrada_t = 0.0
	_entrada_duracion = maxf(duracion, 0.1)
	en_entrada = true
	_aplicar_entrada()


func saltar_entrada() -> void:
	if en_entrada:
		_entrada_t = 1.0


func _vista_inicial() -> Dictionary:
	if modo == Modo.PUNTO:
		var vista: Transform3D = puntos[punto_inicial]
		return {"posicion": vista.origin, "mira": vista.origin - vista.basis.z * 2.0}
	var g: float = inicial.guinada
	var c: float = inicial.cabeceo
	var direccion := Vector3(sin(g) * cos(c), sin(c), cos(g) * cos(c))
	return {"posicion": inicial.objetivo + direccion * float(inicial.distancia), "mira": inicial.objetivo}


# Curva suave que pasa por todos los puntos (tangentes de Catmull-Rom). Los puntos repetidos
# seguidos se quitan: un tramo de largo cero rompe la curva.
func _curva(puntos_curva: Array) -> Curve3D:
	var lista: Array = []
	for punto in puntos_curva:
		if lista.is_empty() or (punto as Vector3).distance_to(lista[-1]) > 0.001:
			lista.append(punto)
	var curva := Curve3D.new()
	curva.bake_interval = 0.01
	var n := lista.size()
	for i in n:
		var anterior: Vector3 = lista[maxi(i - 1, 0)]
		var siguiente: Vector3 = lista[mini(i + 1, n - 1)]
		var tangente := (siguiente - anterior) / (3.0 if i == 0 or i == n - 1 else 6.0)
		curva.add_point(lista[i], -tangente, tangente)
	return curva


func _aplicar_entrada() -> void:
	var s := 0.5 - 0.5 * cos(PI * _entrada_t)
	var posicion := _ruta.sample_baked(s * _ruta.get_baked_length(), true)
	var mira := _ruta_mirada.sample_baked(s * _ruta_mirada.get_baked_length(), true)
	camara.fov = lerpf(_fov_entrada, _fov_final, s)
	if posicion.distance_to(mira) > 0.001:
		camara.look_at_from_position(posicion, mira, Vector3.UP)


# --- Cada cuadro ---------------------------------------------------------------------------

func _process(delta: float) -> void:
	if en_entrada:
		_entrada_t = minf(1.0, _entrada_t + delta / _entrada_duracion)
		_aplicar_entrada()
		if _entrada_t >= 1.0:
			en_entrada = false
			camara.fov = _fov_final
			_saltar()
			entrada_terminada.emit()
		return
	if modo == Modo.ORBITA and _viaje.is_empty() and not _arrastrando and _inercia.length() > 0.05:
		guinada = clampf(guinada - _inercia.x * SENSIBILIDAD * delta * 60.0, limite_guinada.x, limite_guinada.y)
		cabeceo = clampf(cabeceo + _inercia.y * SENSIBILIDAD * delta * 60.0, _cabeceo_minimo(), limite_cabeceo.y)
		_inercia *= pow(0.004, delta)
	if not _viaje.is_empty():
		_viaje.t = minf(1.0, float(_viaje.t) + delta / float(_viaje.duracion))
		var s := _suave(_viaje.t)
		_objetivo_suave = (_viaje.objetivo as Vector3).lerp(objetivo, s)
		_distancia_suave = exp(lerpf(log(float(_viaje.distancia)), log(distancia), s)) * (1.0 + float(_viaje.arco) * sin(PI * s))
		_guinada_suave = lerpf(_viaje.guinada, guinada, s)
		_cabeceo_suave = lerpf(_viaje.cabeceo, cabeceo, s)
		if _viaje.t >= 1.0:
			_viaje = {}
	else:
		var t := 1.0 - exp(-delta * SUAVIDAD)
		_objetivo_suave = _objetivo_suave.lerp(objetivo, t)
		_guinada_suave = lerpf(_guinada_suave, guinada, t)
		_cabeceo_suave = lerpf(_cabeceo_suave, cabeceo, t)
		_distancia_suave = lerpf(_distancia_suave, distancia, t)
	_mirada_suave = _mirada_suave.lerp(_mirada, 1.0 - exp(-delta * 8.0))
	if modo == Modo.PUNTO:
		camara.fov = lerpf(camara.fov, _fov, 1.0 - exp(-delta * 7.0))
	_aplicar()


func _aplicar() -> void:
	if modo == Modo.ORBITA:
		var direccion := Vector3(sin(_guinada_suave) * cos(_cabeceo_suave), sin(_cabeceo_suave),
			cos(_guinada_suave) * cos(_cabeceo_suave))
		camara.look_at_from_position(_objetivo_suave + direccion * _distancia_suave, _objetivo_suave, Vector3.UP)
	else:
		# Como al arrastrar una foto: el dedo a la derecha gira la vista a la izquierda
		var mirada := Basis.from_euler(Vector3(_mirada_suave.y, _mirada_suave.x, 0.0))
		var destino := Transform3D(_base.basis * mirada, _base.origin)
		if _progreso < 1.0:
			camara.global_transform = _desde.interpolate_with(destino, _progreso)
		else:
			camara.global_transform = destino
