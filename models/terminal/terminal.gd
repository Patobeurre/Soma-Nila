extends StaticBody3D
class_name Terminal

@export var camera_3d: Camera3D

func interact() -> void:
	SignalBus.terminal_cam_transition_requested.emit(camera_3d)
