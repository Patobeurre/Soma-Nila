extends Node3D


@onready var camera :Camera3D = %Camera3D
@onready var animation_player :AnimationPlayer = %AnimationPlayer
@onready var fruit :Fruit = %Strawberry


func _ready() -> void:
	set_fullscreen()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		start_travelling_anim()


func set_fullscreen():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func start_travelling_anim() -> void:
	animation_player.play("camera_traveling_in", -1, 0.2)
	await animation_player.animation_finished
	await get_tree().create_timer(1).timeout
	animation_player.play("pop_fruit")
	AudioBus.play_sfx("STRAWBERRY_POP")
	await get_tree().create_timer(0.5).timeout
	animation_player.play("display_appleberry_text")