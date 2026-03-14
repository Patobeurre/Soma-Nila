extends Resource
class_name T_ResWithImage

@export var name :String = ""
@export var image :CompressedTexture2D = null

func _to_string() -> String:
	return name