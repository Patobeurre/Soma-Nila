extends VBoxContainer
class_name LibraryLevelPackPanel


@onready var title_name :RichTextLabel = %LevelPackTitleText
@onready var levels_container :HFlowContainer = %LevelPackFlowContainer

@onready var level_panel_scene :PackedScene = load("res://scenes/GUI/LevelLibrary/puzzle_level_panel.tscn")

@export var level_pack_res :LevelPackRes = LevelPackRes.new()


func _ready() -> void:
	init(level_pack_res)
	

func init(new_level_pack_res :LevelPackRes) -> void:
	level_pack_res = new_level_pack_res

	title_name.text = tr(level_pack_res.name)

	Utils.remove_children(levels_container)
	_fill_levels()


func _fill_levels() -> void:
	for level :PuzzleLevelRes in level_pack_res.levels:
		var level_panel :PuzzleLevelPanel = level_panel_scene.instantiate()
		levels_container.add_child(level_panel)
		level_panel.init(level)
