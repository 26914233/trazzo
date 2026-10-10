# Herramienta: saca un LOD de un modelo importado (posiciones, UV e índices) a un archivo binario,
# para enseñarlo ligero fuera de Godot (visor 3D del chat). Uso:
#   godot --headless --path ronin3d/godot --script res://scripts/extraer_lod.gd -- <res://modelo.glb> <salida.bin> [triangulos_objetivo]
extends SceneTree


func _initialize() -> void:
	var argumentos := OS.get_cmdline_user_args()
	var ruta: String = argumentos[0]
	var salida: String = argumentos[1]
	var objetivo := int(argumentos[2]) if argumentos.size() > 2 else 3000
	var escena: Node = (load(ruta) as PackedScene).instantiate()
	var malla: MeshInstance3D = _buscar_malla(escena)
	var datos := RenderingServer.mesh_get_surface(malla.mesh.get_rid(), 0)
	var arrays := malla.mesh.surface_get_arrays(0)
	var posiciones: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	print("vértices ", posiciones.size(), " · triángulos ", indices.size() / 3)
	var elegido := indices
	for lod in datos.get("lods", []):
		var bytes: PackedByteArray = lod["index_data"]
		var cuenta: int = bytes.size() / (2 if posiciones.size() <= 65535 else 4)
		print("LOD: ", cuenta / 3, " triángulos (borde ", lod["edge_length"], ")")
		if cuenta / 3 >= objetivo and cuenta < elegido.size():
			elegido = bytes.to_int32_array() if posiciones.size() > 65535 else _de_16(bytes)
	print("elegido: ", elegido.size() / 3, " triángulos")
	var archivo := FileAccess.open(salida, FileAccess.WRITE)
	archivo.store_32(posiciones.size())
	archivo.store_32(elegido.size())
	for p in posiciones:
		archivo.store_float(p.x)
		archivo.store_float(p.y)
		archivo.store_float(p.z)
	for uv in uvs:
		archivo.store_float(uv.x)
		archivo.store_float(uv.y)
	for i in elegido:
		archivo.store_32(i)
	archivo.close()
	quit()


func _de_16(bytes: PackedByteArray) -> PackedInt32Array:
	var lista := PackedInt32Array()
	for i in range(0, bytes.size(), 2):
		lista.append(bytes.decode_u16(i))
	return lista


func _buscar_malla(nodo: Node) -> MeshInstance3D:
	if nodo is MeshInstance3D:
		return nodo
	for hijo in nodo.get_children():
		var encontrada := _buscar_malla(hijo)
		if encontrada != null:
			return encontrada
	return null
