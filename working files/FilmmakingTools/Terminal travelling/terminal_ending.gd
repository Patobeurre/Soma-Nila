extends Node3D


@onready var camera :Camera3D = %Camera3D
@onready var animation_player :AnimationPlayer = %AnimationPlayer
@onready var world_environment :WorldEnvironment = %WorldEnvironment


@export var env_foggy_gray :Environment = load("res://working files/FilmmakingTools/Terminal travelling/foggy_gray_env.tres")


func _ready() -> void:
	init_for_recording()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		start_travelling_anim()


func init_for_recording():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func start_travelling_anim() -> void:
	animation_player.play("camera_traveling_in", -1, 0.5)
	Utils.world_environment_transition(world_environment.environment, env_foggy_gray, 20)
	await animation_player.animation_finished
	await get_tree().create_timer(1).timeout
