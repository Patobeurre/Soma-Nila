extends Control


@onready var animation_player := $AnimationPlayer
@onready var timer := $Timer


func _ready() -> void:
	animation_player.play("reveal_splash_screen")
	await animation_player.animation_finished
	timer.start()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact3D") or Input.is_action_just_pressed("ui_accept"):
		timer.stop()
		_on_timer_timeout()


func _on_timer_timeout() -> void:
	AudioBus.play_music("TITLE_SCREEN")
	animation_player.play_backwards("reveal_splash_screen")
	await animation_player.animation_finished
	Global.game_controller.return_to_main_menu()
