extends PanelContainer


@export var saved_levels_res = SavedLevelStats.new()

@onready var saved_level_container: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/MarginContainer/SavedLevelContainer

@onready var abilities_settings :AbilitiesSettings = load("res://scripts/resources/AbilitiesSettingsDefault.tres")
@onready var terrain_settings :TerrainGenerationSettings = load("res://scripts/resources/Terrain/GenerationSettings.tres")
@onready var noise_params :FastNoiseLite = load("res://scripts/resources/Terrain/SimplexNoise.tres")
@onready var tile_gen_settings :TileGenerationSettings = load("res://scripts/resources/Terrain/TileGenSettings.tres")

@onready var savedLevelPanel :PackedScene = load("res://UI/Components/SavedLevelContainer.tscn")


func _ready() -> void:
	saved_levels_res = SaveManager.save_game_res.favorite_levels
	_fill_levels()


func _fill_levels() -> void:
	for level in saved_levels_res.levels:
		var obj :SavedLevelPanel = savedLevelPanel.instantiate()
		saved_level_container.add_child(obj)
		obj.init(level)
		obj.on_clicked.connect(_on_level_clicked)


func _on_level_clicked(stats :LevelStats) -> void:

	AudioBus.play_sfx("BTN_OK")
	
	var level_res = MainLevelRes.new()
	
	level_res.abilitiesSettings = abilities_settings.duplicate(true)
	level_res.terrainSettings = terrain_settings.duplicate(true)
	level_res.terrainSettings.noiseParams = noise_params.duplicate(true)
	level_res.terrainSettings.tileGenSettings = tile_gen_settings.duplicate(true)
	
	level_res.isCustom = true
	level_res.seed = stats.seed
	level_res.useRandomSeed = false
	for excluded_ability in stats.excluded_abilities:
		level_res.abilitiesSettings.excluded_abilities.append(excluded_ability.to_state_res(false))
	
	Global.current_level_stats = stats
	Global.main_level_res = level_res
	Global.main_level_res.init()
	Global.game_controller.start_new_game()
