extends MeshInstance3D

@export var text :String = ""

@onready var label :Label3D = $Label3D


func _ready() -> void:
	_update_label(text)


func _update_label(new_text :String):
	label.text = new_text