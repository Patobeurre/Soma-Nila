extends Control


@onready var customSettingsPanel = $MarginContainer/PanelContainer


func _process(delta: float) -> void:

	inputManagement()


func inputManagement():
	if Input.is_action_just_pressed("ui_cancel"):
		_on_btn_replay_pressed()


func _on_btn_start_pressed() -> void:
	AudioBus.play_sfx("BTN_OK")
	customSettingsPanel.fix_seed_value()
	Global.main_level_res = customSettingsPanel.custom_level_res
	Global.main_level_res.init()
	Global.game_controller.start_new_game()


func _on_btn_replay_pressed() -> void:
	AudioBus.play_sfx("BTN_BACK")
	Global.game_controller.return_to_main_menu()
