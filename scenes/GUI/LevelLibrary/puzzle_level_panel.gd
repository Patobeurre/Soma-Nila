extends Control
class_name PuzzleLevelPanel


@onready var thumbnail :TextureRect = %Thumbnail
@onready var level_name :RichTextLabel = %LevelNameText
@onready var abilities_panel = %AbilitiesPanel
@onready var completed_icon_panel = %CompletedIconPanel

@onready var ability_icon_panel :PackedScene = load("res://scenes/GUI/LevelLibrary/ability_icon_level_panel.tscn")

@export var level_res :PuzzleLevelRes = PuzzleLevelRes.new()


func init(new_level_res :PuzzleLevelRes) -> void:
	level_res = new_level_res

	level_name.text = tr(level_res.name)
	thumbnail.texture = level_res.thumbnail

	for ability :AbilityStats in level_res.abilities:
		var ability_icon :TextureRect = ability_icon_panel.instantiate()
		ability_icon.texture = ability.to_state_res().icon
		abilities_panel.add_child(ability_icon)
	
	_update_completed_icon()
	


func _update_completed_icon() -> void:
	var level_stats :LevelStats = SaveManager.save_game_res.puzzle_levels.try_get_completed_level(level_res.ID)
	if level_stats != null:
		completed_icon_panel.visible = true



func _on_btn_level_pressed() -> void:
	Global.game_controller.start_puzzle_level(level_res)
