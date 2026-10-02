# Cámara de los puzles, con dos modos:
#  - órbita: el dedo gira alrededor del objeto (con inercia suave) y el pellizco acerca o aleja;
#  - puntos de vista: posiciones fijas de una habitación, con un poco de margen para mirar alrededor.
# Además enfoca detalles cuando algo se abre y se sacude con los golpes.
class_name CamaraPuzle
extends Node3D

enum Modo { ORBITA, PUNTO }

const SENSIBILIDAD := 0.0068          # radianes por píxel, a 720 píxeles de alto
const SUAVIDAD := 14.0                 # cuanto más alto, antes alcanza la cámara su destino

var camara: Camera3D
var modo := Modo.ORBITA
var suavidad := SUAVIDAD
# Órbita
var objetivo := Vector3.ZERO
var guinada := 0.0
var cabeceo := 0.35
var distancia := 0.6
var limite_cabeceo := Vector2(-1.35, 1.35)
var limite_distancia := Vector2(0.3, 1.2)
var limite_guinada := Vector2(-INF, INF)
var inicial := {}
var _objetivo_suave := Vector3.ZERO
var _guinada_suave := 0.0
var _cabeceo_suave := 0.35
var _distancia_suave := 0.6
var _inercia := Vector2.ZERO
var _arrastrando := false
var _fin_enfoque := 0.0
# Puntos de vista
var puntos := {}                       # nombre -> Transform3D
var punto_actual := ""
var punto_inicial := ""
var historial: Array = []              # puntos anteriores (para «Volver»)
var limite_mirada := Vector2(0.4, 0.28)
var fov_base := 50.0
var _base := Transform3D.IDENTITY
var _mirada := Vector2.ZERO
var _mirada_suave := Vector2.ZERO
var _desde := Transform3D.IDENTITY
var _progreso := 1.0
var _fov := 50.0
# Sacudida
var _sacudida := 0.0
var _ruido := FastNoiseLite.new()
var _tiempo := 0.0


func _init() -> void:
	camara = Camera3D.new()
	camara.fov = 40.0
	camara.near = 0.02
	camara.far = 80.0
	add_child(camara)
	_ruido.frequency = 2.0


func _ready() -> void:
	camara.current = true


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
	_saltar()


func orbitar(relativo: Vector2) -> void:
	var escala := 720.0 / maxf(1.0, get_viewport().get_visible_rect().size.y)
	var paso := relativo * escala
	_arrastrando = true
	if modo == Modo.ORBITA:
		guinada = clampf(guinada - paso.x * SENSIBILIDAD, limite_guinada.x, limite_guinada.y)
		cabeceo = clampf(cabeceo + paso.y * SENSIBILIDAD, limite_cabeceo.x, limite_cabeceo.y)
		_inercia = paso
	else:
		_mirada.x = clampf(_mirada.x + paso.x * SENSIBILIDAD * 0.5, -limite_mirada.x, limite_mirada.x)
		_mirada.y = clampf(_mirada.y + paso.y * SENSIBILIDAD * 0.5, -limite_mirada.y, limite_mirada.y)


func soltar() -> void:
	_arrastrando = false


func acercar(factor: float) -> void:
	if modo == Modo.ORBITA:
		distancia = clampf(distancia * factor, limite_distancia.x, limite_distancia.y)
	else:
		_fov = clampf(_fov * factor, fov_base * 0.55, fov_base)


# Lleva la cámara a mirar un detalle (algo que se acaba de abrir). Los valores NAN se dejan igual.
func enfocar(centro: Vector3, distancia_nueva: float, guinada_nueva := NAN, cabeceo_nuevo := NAN,
		duracion := 1.2) -> void:
	if modo != Modo.ORBITA:
		return
	objetivo = centro
	distancia = clampf(distancia_nueva, limite_distancia.x, limite_distancia.y)
	if not is_nan(guinada_nueva):
		guinada = _angulo_cercano(guinada_nueva, guinada)
	if not is_nan(cabeceo_nuevo):
		cabeceo = clampf(cabeceo_nuevo, limite_cabeceo.x, limite_cabeceo.y)
	_inercia = Vector2.ZERO
	suavidad = 3.2
	_fin_enfoque = _tiempo + duracion


func centrar() -> void:
	if modo == Modo.ORBITA and not inicial.is_empty():
		enfocar(inicial.objetivo, inicial.distancia, inicial.guinada, inicial.cabeceo, 0.9)
	elif modo == Modo.PUNTO:
		volver()


# ¿Está la cámara cerca de la vista pedida? (lo usa la prueba automática)
func quieta() -> bool:
	if modo == Modo.PUNTO:
		return _progreso >= 1.0
	return absf(_guinada_suave - guinada) < 0.01 and absf(_cabeceo_suave - cabeceo) < 0.01 \
		and absf(_distancia_suave - distancia) < 0.005 and _objetivo_suave.distance_to(objetivo) < 0.003


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
	_viajar(nombre, duracion)


func volver() -> void:
	if historial.is_empty():
		if punto_actual != punto_inicial:
			_viajar(punto_inicial, 0.8)
		return
	_viajar(historial.pop_back(), 0.8)


func _viajar(nombre: String, duracion: float) -> void:
	_desde = camara.global_transform
	_base = puntos[nombre]
	punto_actual = nombre
	_mirada = Vector2.ZERO
	_mirada_suave = Vector2.ZERO
	_fov = fov_base
	_progreso = 0.0
	var animacion := create_tween()
	animacion.tween_property(self, "_progreso", 1.0, duracion).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


# --- Sacudida ------------------------------------------------------------------------------

func sacudir(fuerza: float) -> void:
	_sacudida = maxf(_sacudida, fuerza)


# --- Cada cuadro ---------------------------------------------------------------------------

func _process(delta: float) -> void:
	_tiempo += delta
	if _tiempo > _fin_enfoque:
		suavidad = SUAVIDAD
	if modo == Modo.ORBITA and not _arrastrando and _inercia.length() > 0.05:
		guinada = clampf(guinada - _inercia.x * SENSIBILIDAD * delta * 60.0, limite_guinada.x, limite_guinada.y)
		cabeceo = clampf(cabeceo + _inercia.y * SENSIBILIDAD * delta * 60.0, limite_cabeceo.x, limite_cabeceo.y)
		_inercia *= pow(0.004, delta)
	var t := 1.0 - exp(-delta * suavidad)
	_objetivo_suave = _objetivo_suave.lerp(objetivo, t)
	_guinada_suave = lerpf(_guinada_suave, guinada, t)
	_cabeceo_suave = lerpf(_cabeceo_suave, cabeceo, t)
	_distancia_suave = lerpf(_distancia_suave, distancia, t)
	_mirada_suave = _mirada_suave.lerp(_mirada, 1.0 - exp(-delta * 8.0))
	camara.fov = lerpf(camara.fov, _fov if modo == Modo.PUNTO else camara.fov, t)
	_sacudida = maxf(0.0, _sacudida - delta * 2.5)
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
	if _sacudida > 0.0:
		var fuerza := _sacudida * _sacudida * 0.006
		camara.global_position += camara.global_basis * Vector3(_ruido.get_noise_2d(_tiempo * 40.0, 0.0),
			_ruido.get_noise_2d(0.0, _tiempo * 40.0), 0.0) * fuerza
