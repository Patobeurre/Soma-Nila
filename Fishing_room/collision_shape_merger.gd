extends Node3D


@export var parent_node :Node3D
@export var physics_body :CollisionObject3D


func _ready() -> void:
	var children = find_children("*", "CollisionShape3D")
	for child in children:
		child.reparent(physics_body)
