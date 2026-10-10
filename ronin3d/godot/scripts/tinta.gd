# Capa de tinta sobre el juego: los cuadros de impacto (la imagen se vuelve tinta negra
# sobre papel un instante) y las líneas de corte del corte de luna.
# La maneja efectos.gd con tiempo real, porque el juego va congelado mientras se ve.
extends CanvasLayer

const SHADER := preload("res://shaders/tinta.gdshader")


# Dibuja las líneas del corte de luna: aparecen una tras otra y luego se apagan.
class Cortes extends Control:
	var lineas: Array = []            # [desde, hasta, momento en que aparece (0-1)]
	var progreso := 0.0
	var opacidad := 1.0

	func _draw() -> void:
		for linea in lineas:
			var avance := clampf((progreso - linea[2]) / 0.1, 0.0, 1.0)
			if avance <= 0.0:
				continue
			var desde: Vector2 = linea[0]
			var hasta: Vector2 = desde.lerp(linea[1], ease(avance, 0.3))
			draw_line(desde, hasta, Color(0.02, 0.02, 0.04, opacidad), 11.0, true)
			draw_line(desde, hasta, Color(0.98, 0.97, 0.92, opacidad), 4.5, true)


var filtro: ColorRect
var material_filtro: ShaderMaterial
var cortes: Cortes
var fuerza := 0.0                     # filtro de tinta: 0 nada, 1 todo tinta
var impacto_restante := 0.0           # segundos reales de cuadro de impacto (invertido)


func _ready() -> void:
	layer = 9                         # encima del juego y de los controles; debajo del HUD
	filtro = ColorRect.new()
	filtro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	filtro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	material_filtro = ShaderMaterial.new()
	material_filtro.shader = SHADER
	filtro.material = material_filtro
	filtro.visible = false
	add_child(filtro)
	cortes = Cortes.new()
	cortes.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cortes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cortes)


# Cuadro de impacto: dos o tres cuadros de tinta invertida, como en el anime.
func impacto(segundos := 0.1) -> void:
	impacto_restante = maxf(impacto_restante, segundos)


func preparar_cortes(puntos: Array, azar: RandomNumberGenerator) -> void:
	var pantalla := get_viewport().get_visible_rect().size
	var lineas: Array = []
	var total := maxi(puntos.size() * 2, 6)
	var orden := 0
	# Dos cortes cruzados sobre cada enemigo y algunos sueltos que cruzan la pantalla.
	for punto in puntos:
		for i in 2:
			var angulo := azar.randf_range(-0.9, 0.9) + (PI / 2.0 if i == 1 else 0.0)
			var largo := azar.randf_range(220.0, 360.0)
			var direccion := Vector2(cos(angulo), sin(angulo))
			lineas.append([punto - direccion * largo, punto + direccion * largo, float(orden) / total * 0.85])
			orden += 1
	while orden < total:
		var centro := Vector2(azar.randf_range(0.2, 0.8) * pantalla.x, azar.randf_range(0.25, 0.75) * pantalla.y)
		var angulo := azar.randf_range(0.0, PI)
		var direccion := Vector2(cos(angulo), sin(angulo)) * pantalla.length() * 0.45
		lineas.append([centro - direccion, centro + direccion, float(orden) / total * 0.85])
		orden += 1
	cortes.lineas = lineas
	cortes.progreso = 0.0
	cortes.opacidad = 1.0
	cortes.queue_redraw()


func poner_cortes(progreso: float, opacidad: float) -> void:
	cortes.progreso = progreso
	cortes.opacidad = opacidad
	if opacidad <= 0.0:
		cortes.lineas = []
	cortes.queue_redraw()


func actualizar(real: float) -> void:
	impacto_restante = maxf(0.0, impacto_restante - real)
	var invertido := impacto_restante > 0.0
	var visible_fuerza := 1.0 if invertido else fuerza
	filtro.visible = visible_fuerza > 0.001
	material_filtro.set_shader_parameter("fuerza", visible_fuerza)
	material_filtro.set_shader_parameter("invertir", 1.0 if invertido else 0.0)
