extends HBoxContainer


@export var difficulty :int = 0

static var star_texture = load("res://images/UI/star_difficulty_enabled.png")


func init(new_difficulty :int) -> void:
	difficulty = new_difficulty
	_update_difficulty()


func _update_difficulty() -> void:
	var i :int = 0
	for child :TextureRect in get_children():
		if (i < difficulty):
			child.texture = star_texture
		i += 1