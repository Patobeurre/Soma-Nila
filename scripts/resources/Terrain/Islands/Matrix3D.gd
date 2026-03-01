extends Resource
class_name Matrix3D


@export var mat :Array = [[[]]]
@export var size :Vector3 = Vector3.ZERO


func initialize_with(new_size :Vector3, value :Variant) -> void:
	var array_value :Array = []
	size = new_size
	mat = []
	
	for i in range(size.z):
		array_value.append(value)
	
	for x in range(size.x):
		mat.append([])
		for y in range(size.y):
			mat[x].append(array_value.duplicate())


func set_value(pos :Vector3, value :Variant):
	mat[pos.x][pos.y][pos.z] = value

func get_value(pos :Vector3) -> Variant:
	if pos.x >= size.x or pos.y >= size.y or pos.z >= size.z:
		return null
	if pos.x < 0 or pos.y < 0 or pos.z < 0:
		return null
	return mat[pos.x][pos.y][pos.z]


func save() -> void:
	ResourceSaver.save(self, "user://matrix.tres")
