extends RigidBody3D
class_name Bobber

@onready var rope_point_node :Node3D = %RopePoint


func _ready() -> void:
	look_at(global_position + Vector3.DOWN)


func get_rope_point() -> Node3D:
	return rope_point_node


func _on_body_shape_entered(body_rid:RID, body:Node, body_shape_index:int, local_shape_index:int) -> void:
	print("bobber collide")
	freeze = true


func _on_body_entered(body:Node) -> void:
	print("bobber collide")
	freeze = true
