extends Node3D

@onready var camera_3d :Camera3D = %Camera3D


func interact() -> void:
	SignalBus.terminal_cam_transition_requested.emit(camera_3d)