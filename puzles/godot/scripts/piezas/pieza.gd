# Pieza que se puede tocar o arrastrar con el dedo. Las clases hijas deciden cómo se mueve:
# deslizante, giratoria, bisagra, pulsador, recogible, ranura, nota y punto de vista.
# La geometría va como hijos del nodo, así que se mueve con él. «base» es la posición de reposo.
class_name Pieza
extends Node3D

signal accionada(pieza: Pieza)        # llegó a un estado nuevo (tras soltarla o tocarla)
signal rechazada(pieza: Pieza)        # se intentó mover, pero está bloqueada

const SHADER_RESALTE := preload("res://shaders/resalte.gdshader")
const EPSILON := 0.0005

var mesa                              # la mesa del prototipo (sonido, vibración, mensajes)
var id := ""
var habilitada := true                # false: no responde a los toques
var permiso := Callable()             # opcional: func() -> bool; false = bloqueada
var aviso_bloqueo := ""               # mensaje que se enseña la primera vez que se bloquea
var sonido_bloqueo := "trabado"
var solo_desde: Array = []            # en las habitaciones: puntos de vista desde donde se toca
var base := Transform3D.IDENTITY
var controla_transform := true        # false: otro código mueve el nodo (p. ej., al recogerla)
var _base_lista := false
var _avisada := false
var _resalte := 0.0
var _material_resalte: ShaderMaterial


func _ready() -> void:
	if not _base_lista:
		fijar_base(transform)


func fijar_base(transformacion: Transform3D) -> void:
	base = transformacion
	transform = transformacion
	_base_lista = true


func interactiva() -> bool:
	if not habilitada or not is_visible_in_tree():
		return false
	if not solo_desde.is_empty() and mesa and not mesa.camara.punto_actual in solo_desde:
		return false
	return true


func puede() -> bool:
	return not permiso.is_valid() or bool(permiso.call())


# ¿Se mueve arrastrándola? (si no, un arrastre que empiece sobre ella gira la cámara)
func arrastrable() -> bool:
	return false


# --- Formas de choque (para que el dedo la encuentre) --------------------------------------

func colisor(forma: Shape3D, transformacion := Transform3D.IDENTITY) -> StaticBody3D:
	var cuerpo := StaticBody3D.new()
	var figura := CollisionShape3D.new()
	figura.shape = forma
	figura.transform = transformacion
	cuerpo.add_child(figura)
	cuerpo.set_meta("pieza", self)
	add_child(cuerpo)
	return cuerpo


func colisor_caja(tamano: Vector3, posicion := Vector3.ZERO) -> StaticBody3D:
	var forma := BoxShape3D.new()
	forma.size = tamano
	return colisor(forma, Transform3D(Basis.IDENTITY, posicion))


func colisor_malla(malla: Mesh, transformacion := Transform3D.IDENTITY) -> StaticBody3D:
	return colisor(malla.create_trimesh_shape(), transformacion)


# --- Lo que hace cada tipo (las clases hijas lo cambian) ------------------------------------

func empezar_arrastre(_punto: Vector3, _camara: Camera3D) -> void:
	pass


func arrastrar(_relativo: Vector2, _posicion: Vector2, _camara: Camera3D) -> void:
	pass


func soltar() -> void:
	pass


func tocar() -> void:
	pass


func _transform_actual() -> Transform3D:
	return base


# --- Respuestas comunes -------------------------------------------------------------------

# La pieza no se deja. Ni se mueve ni se marca: suena trabada, vibra corto y es el objeto el que se
# resiste a su manera (Puzle.resistir). La primera vez, una línea de texto dice por qué.
func rechazar() -> void:
	if mesa:
		mesa.sonido.sonar(sonido_bloqueo, -2.0)
		mesa.vibrar(35, 0.6)
		mesa.registrar_bloqueo(self)
		mesa.resistir(self)
		if aviso_bloqueo != "" and not _avisada:
			_avisada = true
			mesa.mensaje(aviso_bloqueo)
	rechazada.emit(self)


# Brillo suave que late, para la última pista de cada paso
func resaltar(segundos := 4.0) -> void:
	if _material_resalte == null:
		_material_resalte = ShaderMaterial.new()
		_material_resalte.shader = SHADER_RESALTE
		if mesa:
			_material_resalte.set_shader_parameter("color", mesa.datos.get("acento", Color(1, 0.85, 0.5)))
	_resalte = segundos
	_poner_resalte(_material_resalte)


func _poner_resalte(material: Material) -> void:
	for nodo in find_children("*", "MeshInstance3D", true, false):
		(nodo as MeshInstance3D).material_overlay = material


func _process(delta: float) -> void:
	if _resalte > 0.0:
		_resalte -= delta
		if _resalte <= 0.0:
			_poner_resalte(null)
	if not controla_transform:
		return
	transform = _transform_actual()
