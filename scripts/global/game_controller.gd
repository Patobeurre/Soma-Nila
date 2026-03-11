extends Node
class_name GameController

@export var world_3d : Node3D
@export var world_2d : Node2D
@export var gui : Control

var current_3d_scene : Node3D
var current_2d_scene : Node2D
var current_gui_scene : Control

@onready var abilities_settings :AbilitiesSettings = load("res://scripts/resources/AbilitiesSettingsDefault.tres")
@onready var terrain_settings :TerrainGenerationSettings = load("res://scripts/resources/Terrain/GenerationSettings.tres")
@onready var noise_params :FastNoiseLite = load("res://scripts/resources/Terrain/SimplexNoise.tres")
@onready var tile_gen_settings :TileGenerationSettings = load("res://scripts/resources/Terrain/TileGenSettings.tres")


func _ready() -> void:
	Global.game_controller = self
	change_gui_scene("res://scenes/GUI/splash_screen.tscn")


func _init_new_level_resource():
	var level_res = MainLevelRes.new()
	level_res.abilitiesSettings = abilities_settings.duplicate(true)
	level_res.terrainSettings = terrain_settings.duplicate(true)
	level_res.terrainSettings.noiseParams = noise_params.duplicate(true)
	level_res.terrainSettings.tileGenSettings = tile_gen_settings.duplicate(true)
	level_res.init()
	Global.current_level_stats = LevelStats.new()
	Global.main_level_res = level_res


func start_new_game() -> void:
	if not Global.main_level_res.isCustom:
		_init_new_level_resource()
	else:
		Global.main_level_res.terrainSettings = terrain_settings.duplicate(true)
		Global.main_level_res.terrainSettings.noiseParams = noise_params.duplicate(true)
		Global.main_level_res.terrainSettings.tileGenSettings = tile_gen_settings.duplicate(true)
		Global.main_level_res.init()

	var levelScenePath = get_level_scene_path()
	start_game(levelScenePath, !is_secret_level(Global.main_level_res))


func get_level_scene_path() -> String:
	if is_secret_level(Global.main_level_res):
		return "res://scenes/secret_level.tscn"
	else:
		return "res://scenes/procedural_level.tscn"


func start_game(level_scene_path :String, show_level_intro :bool = true) -> void:
	change_gui_scene("res://scenes/GUI/game_hud.tscn")
	if show_level_intro:
		change_gui_scene("res://scenes/GUI/level_intro_screen.tscn", false, true)
	change_3d_scene(level_scene_path)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func restart_level() -> void:
	Global.main_level_res.terrainSettings = terrain_settings.duplicate(true)
	Global.main_level_res.terrainSettings.noiseParams = noise_params.duplicate(true)
	Global.main_level_res.terrainSettings.tileGenSettings = tile_gen_settings.duplicate(true)
	Global.main_level_res.restart()
	var levelScenePath = get_level_scene_path()
	start_game(levelScenePath, false)
	SignalBus.level_intro_finished.emit()


func start_puzzle_level(puzzle_res :PuzzleLevelRes, show_level_intro :bool = true):
	Global.puzzle_level_res = puzzle_res
	change_gui_scene("res://scenes/GUI/game_hud.tscn")
	if show_level_intro:
		change_gui_scene("res://scenes/GUI/level_intro_screen.tscn", false, true)
	change_3d_scene("res://scenes/puzzle_level.tscn")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func restart_puzzle_level(puzzle_res :PuzzleLevelRes) -> void:
	Global.puzzle_level_res = PuzzleLevelRes.new()
	start_puzzle_level(puzzle_res, false)
	SignalBus.level_intro_finished.emit()


func is_secret_level(level_res :MainLevelRes) -> bool:
	if level_res.seed != Global.SECRET_LEVEL_SEED:
		return false
	if !(level_res.abilitiesSettings.get_available_abilities().size() == 1 and !level_res.abilitiesSettings.allowSameAbilities):
		return false
	
	return true


func end_level_transition() -> void:
	change_gui_scene("res://scenes/GUI/level_outro_screen.tscn")
	if current_3d_scene != null:
		current_3d_scene.queue_free()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func end_puzzle_level_transition():
	change_gui_scene("res://scenes/GUI/puzzle_level_outro_screen.tscn")
	if current_3d_scene != null:
		current_3d_scene.queue_free()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func return_to_main_menu() -> void:
	AudioBus.play_music("TITLE_SCREEN")
	Utils.remove_children(gui)
	change_gui_scene("res://scenes/GUI/main_menu.tscn")
	if current_3d_scene != null:
		current_3d_scene.queue_free()
	change_3d_scene("res://scenes/Terrain/waving_terrain.tscn")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func return_to_puzzles_menu():
	AudioBus.play_music("TITLE_SCREEN")
	Utils.remove_children(gui)
	open_puzzles_menu()
	if current_3d_scene != null:
		current_3d_scene.queue_free()
	change_3d_scene("res://scenes/Terrain/waving_terrain.tscn")


func open_custom_game_menu() -> void:
	change_gui_scene("res://scenes/GUI/custom_game_menu.tscn")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func open_settings_menu() -> void:
	change_gui_scene("res://scenes/GUI/settings_menu.tscn")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func open_saved_levels_menu() -> void:
	change_gui_scene("res://scenes/GUI/favorite_levels_menu.tscn")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func open_puzzles_menu() -> void:
	change_gui_scene("res://scenes/GUI/puzzle_levels_menu.tscn")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func display_current_gui(visible :bool) -> void:
	current_gui_scene.visible = visible

func end_level_intro():
	SignalBus.level_intro_finished.emit()
	change_gui_scene("", false)


func pause_game(paused :bool):
	var pause_mode = Node.PROCESS_MODE_PAUSABLE
	if paused: 
		pause_mode = Node.PROCESS_MODE_DISABLED

	current_3d_scene.process_mode = pause_mode


func change_gui_scene(new_scene :String, delete :bool = true, keep_running :bool = false) -> void:
	if current_gui_scene != null:
		if delete:
			current_gui_scene.queue_free()
		elif keep_running:
			current_gui_scene.visible = false
		else:
			gui.remove_child(current_gui_scene)
	
	if new_scene.is_empty():
		current_gui_scene = gui.get_children().back()
		if current_gui_scene != null:
			current_gui_scene.visible = true
		return
	
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_gui_scene = new


func change_2d_scene(new_scene :String, delete :bool = true, keep_running :bool = false) -> void:
	if current_2d_scene != null:
		if delete:
			current_2d_scene.queue_free()
		elif keep_running:
			current_2d_scene.visible = false
		else:
			world_2d.remove_child(current_2d_scene)
	
	var new = load(new_scene).instantiate()
	world_2d.add_child(new)
	current_2d_scene = new


func change_3d_scene(new_scene :String, delete :bool = true, keep_running :bool = false) -> void:
	if current_3d_scene != null:
		if delete:
			current_3d_scene.queue_free()
		elif keep_running:
			current_3d_scene.visible = false
		else:
			world_3d.remove_child(current_3d_scene)
	
	var new = load(new_scene).instantiate()
	world_3d.add_child(new)
	current_3d_scene = new
