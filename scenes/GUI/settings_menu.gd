extends Control


func _process(delta: float) -> void:
	inputManagement()


func inputManagement():
	if Input.is_action_just_pressed("ui_cancel"):
		save_and_return()


func _on_btn_back_pressed() -> void:
	AudioBus.play_sfx("BTN_BACK")
	save_and_return()


func save_and_return() -> void:
	ProjectSettings.save_custom("override.cfg")
	Global.game_controller.return_to_main_menu()


func _on_btn_save_pressed() -> void:
	pass # Replace with function body.
