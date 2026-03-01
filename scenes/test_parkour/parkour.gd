extends Node3D

@onready var player :PlayerCharacter = $PlayerCharacter
var restart_pos :Vector3 = Vector3.ZERO


func _ready() -> void:
	restart_pos = player.global_position

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		player.global_position = restart_pos
