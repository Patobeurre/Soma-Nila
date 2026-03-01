extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is PlayerCharacter:
		SignalBus.use_bubble_requested.emit(global_position)
