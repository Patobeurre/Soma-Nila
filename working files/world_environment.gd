extends WorldEnvironment

@onready var env_foggy_gray = preload("res://scripts/resources/Environments/outdoor_foggy_gray.tres")
@onready var env_foggy_green = preload("res://scripts/resources/Environments/outdoor_foggy_green.tres")


func _ready() -> void:
	Utils.world_environment_transition(environment, env_foggy_gray, 0)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("crouch"):
		Utils.world_environment_transition(environment, env_foggy_green, 2.0)
	if Input.is_action_just_pressed("dash"):
		Utils.world_environment_transition(environment, env_foggy_gray, 2.0)
