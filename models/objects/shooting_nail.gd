extends RigidBody3D


@export var scene_to_instantiate :PackedScene

var _local_collision_position :Vector3 = Vector3.ZERO
var _local_collision_normal :Vector3


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if state.get_contact_count() > 0:
		_local_collision_position = state.get_contact_local_position(0)
		_local_collision_normal = state.get_contact_local_normal(0)


func _on_body_entered(body: Node) -> void:
	if _local_collision_normal != Vector3.ZERO:
		var obj = scene_to_instantiate.instantiate()
		get_parent_node_3d().add_child(obj)
		obj.reparent(body)
		obj.set_wallNormal(_local_collision_normal)
		obj.global_position = _local_collision_position
		obj.look_at(obj.global_position - obj.wallNormal)
	queue_free()
