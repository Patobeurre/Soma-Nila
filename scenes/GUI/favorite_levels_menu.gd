extends Control


func _process(delta: float) -> void:
	inputManagement()


func inputManagement():
	if Input.is_action_just_pressed("ui_cancel"):
		_on_btn_back_pressed()


func _on_btn_back_pressed() -> void:
	AudioBus.play_sfx("BTN_BACK")
	Global.game_controller.return_to_main_menu()
