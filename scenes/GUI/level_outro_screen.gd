extends Control

@onready var seedTxt = $MarginContainer/VSplitContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SeedTxt
@onready var timeTxt = $MarginContainer/VSplitContainer/PanelContainer/MarginContainer/VBoxContainer/TimeContainer/TimeTxt
@onready var usedAbilitiesContainer = $MarginContainer/VSplitContainer/PanelContainer/MarginContainer/VBoxContainer/UsedAbilitiesContainer
@onready var noItemUsed = $MarginContainer/VSplitContainer/PanelContainer/MarginContainer/VBoxContainer/NoItemUsed
@onready var favorite_disabled_texture: TextureRect = $MarginContainer/VSplitContainer/PanelContainer/MarginContainer/VBoxContainer/BtnSave/FavoriteDisabledTexture
@onready var favorite_enabled_texture: TextureRect = $MarginContainer/VSplitContainer/PanelContainer/MarginContainer/VBoxContainer/BtnSave/FavoriteEnabledTexture
@onready var btn_save :Button = $MarginContainer/VSplitContainer/PanelContainer/MarginContainer/VBoxContainer/BtnSave

@onready var bestTimeContainer = $MarginContainer/VSplitContainer/PanelContainer/MarginContainer/VBoxContainer/BestTimeContainer
@onready var bestTimeTxt = $MarginContainer/VSplitContainer/PanelContainer/MarginContainer/VBoxContainer/BestTimeContainer/BestTimeTxt

@onready var hbox_spice_container = %HBoxSpiceContainer
@onready var spice_icon_container = %SpiceIconContainer

@onready var whirl_background = $CenterContainer
@export var background_rotate_speed :float = 10.0
@export var startAnimationDelay :float = 1.0
@export var stepAnimationDelay :float = 0.5

@export var levelStats :LevelStats = LevelStats.new()

@onready var abilityStatScene :PackedScene = load("res://UI/Components/AbilityStatPanel.tscn")
@onready var spiceTextureScene :PackedScene = load("res://UI/Components/spice_texture.tscn")


func _ready() -> void:
	if Global.current_level_stats != null:
		levelStats = Global.current_level_stats
	display_stats(levelStats)

	if SaveManager.save_game_res.favorite_levels.is_level_saved(levelStats):
		display_saved_game_content(SaveManager.save_game_res.favorite_levels.get_level(levelStats))


func _process(delta: float) -> void:
	
	whirl_background.rotation_degrees += delta * background_rotate_speed
	
	inputManagement()


func inputManagement():
	if Input.is_action_just_pressed("ui_cancel"):
		Global.game_controller.return_to_main_menu()
	if Input.is_action_just_pressed("ui_accept"):
		_on_button_pressed()


func display_stats(stats :LevelStats) -> void:
	seedTxt.text = str(stats.seed)
	timeTxt.text = Utils.seconds2hhmmss(stats.completionTime, true)
	if levelStats.terrain_stats.spice_level > 0:
		hbox_spice_container.visible = true
		set_spice()
	fill_used_abilities()


func display_saved_game_content(saved_level :LevelStats) -> void:
	bestTimeContainer.visible = true
	bestTimeTxt.text = Utils.seconds2hhmmss(saved_level.completionTime, true)
	var timeDiff :float = saved_level.completionTime - levelStats.completionTime
	var timeTextColor :String = "green" if timeDiff > 0 else "red"
	if timeDiff == 0 : timeTextColor = "white"
	timeTxt.text = BBCodeString.new(timeTxt.text).set_color(timeTextColor).get_text()
	btn_save.button_pressed = true
	

func set_spice() -> void:
	for i in range(levelStats.terrain_stats.spice_level):
		var spice_texture = spiceTextureScene.instantiate()
		spice_icon_container.add_child(spice_texture)
		spice_texture.set_enabled(true)


func fill_used_abilities() -> void:
	for ability in levelStats.used_abilities:
		if ability.amount_used > 0:
			var obj :AbilityStatPanel = abilityStatScene.instantiate()
			usedAbilitiesContainer.add_child(obj)
			obj.init(ability)
	
	if usedAbilitiesContainer.get_children().is_empty():
		noItemUsed.visible = true


func _on_btn_share_pressed() -> void:
	pass # Replace with function body.


func _on_button_pressed() -> void:
	AudioBus.play_sfx("BTN_OK")
	Global.game_controller.start_new_game()


func _on_btn_replay_pressed() -> void:
	AudioBus.play_sfx("BTN_REPLAY")
	Global.game_controller.restart_level()


func _update_save_toggle_btn_texture(toggled_on: bool) -> void:
	if toggled_on:
		AudioBus.play_sfx("TOGGLE_ON")
	else:
		AudioBus.play_sfx("TOGGLE_OFF")
	favorite_enabled_texture.visible = toggled_on


func _on_btn_save_toggled(toggled_on: bool) -> void:
	if toggled_on:
		SaveManager.save_game_res.favorite_levels.add_level(levelStats)
		SignalBus.save_requested.emit()
	else:
		SaveManager.save_game_res.favorite_levels.remove_level(levelStats)
		SignalBus.save_requested.emit()
	_update_save_toggle_btn_texture(toggled_on)
