extends Node3D


@export var size :float

@onready var meshes_node :Node3D = $Meshes


func init(new_size :float) -> void:
	size = new_size
	for child in meshes_node.get_children():
		var dir = -child.get_global_transform().basis.z
		child.position = size * dir
		child.scale.x = size * 2
		child.scale.y = size * 2
		child.scale.z = size * 2

