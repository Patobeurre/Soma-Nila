extends Control
class_name MainMenu

@onready var btn_new_game = $MarginContainer/PanelContainer/VBoxContainer/BtnNewGame
@onready var credits_container = $CreditsContainer
@onready var game_version_label = $MarginContainer/PanelContainer/VBoxContainer/GameVersionTxt


func _ready() -> void:
	btn_new_game.grab_focus()
	credits_container.visible = false
	game_version_label.text = "version " + SaveManager.save_game_res.VERSION


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		credits_container.visible = false


func _on_btn_new_game_pressed() -> void:
	Global.main_level_res.isCustom = false
	Global.game_controller.start_new_game()


func _on_btn_custom_game_pressed() -> void:
	AudioBus.play_sfx("BTN_OK")
	Global.game_controller.open_custom_game_menu()


func _on_btn_favorite_levels_pressed() -> void:
	AudioBus.play_sfx("BTN_OK")
	Global.game_controller.open_saved_levels_menu()


func _on_btn_settings_pressed() -> void:
	AudioBus.play_sfx("BTN_OK")
	Global.game_controller.open_settings_menu()


func _on_btn_quit_pressed() -> void:
	get_tree().quit()


func _on_btn_credits_pressed() -> void:
	credits_container.visible = !credits_container.visible
