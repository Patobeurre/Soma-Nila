extends Control



func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_on_btn_back_pressed()


func _on_btn_random_mode_pressed() -> void:
	Global.main_level_res.isCustom = false
	Global.game_controller.start_new_game()


func _on_btn_custom_mode_pressed() -> void:
	Global.game_controller.open_custom_game_menu()


func _on_btn_puzzle_mode_pressed() -> void:
	Global.game_controller.open_puzzles_menu()


func _on_btn_back_pressed() -> void:
	Global.game_controller.return_to_main_menu()
