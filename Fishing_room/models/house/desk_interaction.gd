extends Node3D
class_name Interactable


@export var camera_3d :Camera3D


func interact() -> void:
	SignalBus.interact_cam_transition_requested.emit(camera_3d)
