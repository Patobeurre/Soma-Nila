extends TextureRect
class_name SpiceTexture


@onready var spice_texture = load("res://images/UI/spice.png")
@onready var spice_disabled_texture = load("res://images/UI/spice_disabled.png")


func set_enabled(enabled :bool = true) -> void:
	texture = spice_texture if enabled else spice_disabled_texture