extends Node3D


@onready var player :PlayerCharacter = $PlayerCharacter
@onready var portal :LevelPortal = $Portal
@onready var abilitySelector :AbilitySelector = $AbilitySelector
@onready var abilityStateMachine :StateMachineStrategy = $AbilitiesStateMachine
@onready var ability_disabled_state: DisabledState = $AbilitiesStateMachine/DisabledState

@onready var level_sm: LevelStateMachineStrategy = $LevelSM
@onready var playing_state: LevelPlayingState = $LevelSM/PlayingState
@onready var disabled_state: LevelDisabledState = $LevelSM/DisabledState
@onready var interacting_state: LevelInteractingState = $LevelSM/InteractingState
var interacting_camera :Camera3D

@onready var map_node :TerrainGenerationNode = $MapTiles
@onready var placeableObject_node :Node3D = $PlaceableObjects
@onready var objectives_node :Node3D = $Objectives
@onready var boundaries_node :Node3D = $Boundaries


# Place Object State
@onready var placeholder_node :Node3D = $TilePlaceholderNode
@export var DISTANCE :float = 10.0
@export var boundOffset :float = 2.0

var starting_pos :Vector3 = Vector3.ZERO
var nbFruitTaken :int = 0
var currentTimer :float = 0

var abilitiesSettings :AbilitiesSettings = load("res://scripts/resources/AbilitiesSettingsDefault.tres")
var terrainSettings :TerrainGenerationSettings = load("res://scripts/resources/Terrain/PuzzleTerrainSettings.tres")

@export var puzzle_res :PuzzleLevelRes = PuzzleLevelRes.new()
@export var level_stats :LevelStats

@onready var fruit_scene = load("res://models/objects/Strawberry.tscn")
@onready var terminalScene = load("res://models/terminal/terminal.tscn")


func _ready() -> void:
	AudioBus.play_music("LEVEL_PLAYLIST")
	SignalBus.abilities_setup.connect(_on_abilities_setup)
	SignalBus.level_intro_finished.connect(_on_level_intro_finished, CONNECT_ONE_SHOT)
	SignalBus.selected_ability_changed.connect(_on_selected_ability_changed)
	SignalBus.use_rope_requested.connect(player.rope_ability_requested)
	SignalBus.use_bubble_requested.connect(player.bubble_ability_requested)
	SignalBus.use_glide_requested.connect(player.glide_ability_requested)
	SignalBus.use_jetpack_requested.connect(player.jetpack_ability_requested)
	SignalBus.fruit_picked.connect(_on_fruit_picked)
	SignalBus.enter_level_portal.connect(_on_enter_level_portal)
	SignalBus.terminal_cam_transition_requested.connect(_on_terminal_interaction_request)
	map_node.map_generation_finished.connect(_on_map_generated)
	
	map_node.settings = terrainSettings
	place_bondaries()

	if Global.puzzle_level_res.ID >= 0:
		puzzle_res = Global.puzzle_level_res.duplicate(true)
		init()
	#ToDo : remove
	else:
		init()
		_on_level_intro_finished()


func init() -> void:

	level_sm.transition(disabled_state)

	portal.set_activated(false)
	Utils.remove_children(placeableObject_node)
	Utils.remove_children(objectives_node)

	nbFruitTaken = 0
	
	var saved_stats = SaveManager.save_game_res.puzzle_levels.try_get_completed_level(puzzle_res.ID)
	if saved_stats != null:
		Global.current_level_stats = saved_stats
	
	level_stats = LevelStats.new()

	SignalBus.current_level_stats_updated.emit(Global.current_level_stats)
	
	abilitiesSettings.set_picked_abilities(puzzle_res.abilities)


func inputManagement() -> void:
	if Input.is_action_just_pressed("restart"):
		restart_level_keep_params()
	if Input.is_action_just_pressed("ui_cancel"):
		Global.game_controller.return_to_main_menu()


func _physics_process(delta: float) -> void:
	_update_placeholder_position()
	_update_placeholder_rotation()
	_update_timer(delta)

	if Global.player_global_pos.y < -50:
		restart_level_keep_params()


func _update_timer(delta: float):
	currentTimer += delta
	SignalBus.level_timer_updated.emit(currentTimer)


func _update_placeholder_position() -> void:
	var new_position = get_placeholder_position()
	
	var space_state = get_world_3d().direct_space_state
	
	var origin :Vector3 = Global.player_global_pos
	var end :Vector3 = new_position
	
	var query = PhysicsRayQueryParameters3D.create(origin, end, 1 + 64)
	var result = space_state.intersect_ray(query)
	
	if not result.is_empty():
		new_position = result.position + result.normal * 0.6
	
	placeholder_node.global_position = new_position


func get_placeholder_position() -> Vector3:
	var pos = Global.player_global_pos + Global.player_camera_orientation * DISTANCE
	var boundDown = Global.player_global_pos.y - 1.55 - boundOffset
	var boundUp = Global.player_global_pos.y - 1.55 + boundOffset
	if pos.y < boundDown:
		pos.y = boundDown
	if pos.y > boundUp:
		pos.y = boundUp
	
	return pos


func _update_placeholder_rotation() -> void:
	var rotation = get_placeholder_rotation()
	if Vector2(rotation.x, rotation.z) == Vector2(placeholder_node.global_position.x, placeholder_node.global_position.z):
		return
	placeholder_node.look_at(get_placeholder_rotation())


func get_placeholder_rotation() -> Vector3:
	var pos = Global.player_global_pos
	pos.y = placeholder_node.global_position.y
	return pos


func restart_level_keep_params():
	if Global.game_controller:
		Global.game_controller.restart_puzzle_level(puzzle_res)
	#ToDo : remove
	else:
		init()
		_on_level_intro_finished()


func restart_level_regenerate():
	pass


func exit_level_requested():
	Global.game_controller.return_to_puzzles_menu()


func remove_placeable_objects() -> void:
	for objects in placeableObject_node.get_children():
		objects.queue_free()


func place_objectives():
	starting_pos = puzzle_res.start_position * terrainSettings.tile_scale
	player.global_position = starting_pos
	portal.global_position = starting_pos

	for fruit_pos in puzzle_res.fruits_positions:
		var fruit = fruit_scene.instantiate()
		objectives_node.add_child(fruit)
		fruit.global_position = fruit_pos * terrainSettings.tile_scale
		fruit.visible = true


func place_bondaries():
	boundaries_node.global_position = (terrainSettings.terrainSize * terrainSettings.terrain_scale) / 2
	boundaries_node.global_position.y = 0
	boundaries_node.init(terrainSettings.terrainSize.x * terrainSettings.terrain_scale.x)


func _on_fruit_picked(fruit_node :Node3D) -> void:
	fruit_node.queue_free()
	nbFruitTaken += 1
	AudioBus.play_sfx("PICK_FRUIT")
	portal.set_activated(nbFruitTaken >= puzzle_res.fruits_positions.size())


func _on_enter_level_portal() -> void:
	if nbFruitTaken >= puzzle_res.fruits_positions.size():
		end_level()


func end_level():
	AudioBus.play_sfx("PORTAL_IN")
	var remaining_abilities = abilitySelector.items.items
	SaveManager.save_game_res.remaining_abilities.add_all(remaining_abilities)
	SignalBus.save_requested.emit()

	level_stats.seed = puzzle_res.ID
	level_stats.game_version = SaveManager.save_game_res.VERSION
	level_stats.set_used_abilities_from_remainings(remaining_abilities)
	level_stats.completionTime = currentTimer
	
	Global.current_level_stats = level_stats
	Global.game_controller.end_puzzle_level_transition()


func _on_level_intro_finished():
	AudioBus.play_sfx("PORTAL_OUT")
	abilitySelector.set_selected_ability(0)
	currentTimer = 0
	level_sm.transition(playing_state)


func _on_terminal_interaction_request(camera :Camera3D) -> void:
	if level_sm.currState != interacting_state:
		interacting_camera = camera
		level_sm.transition(interacting_state)


func exit_interaction() -> void:
	level_sm.transition(playing_state)


func enable_ability_selector(enabled :bool) -> void:
	if enabled:
		abilityStateMachine.transition(abilitySelector.get_selected_ability())
	else:
		abilityStateMachine.reset_to_initial_state()


func _on_selected_ability_changed(abilityRes :StateRes):
	if abilityStateMachine.currState != ability_disabled_state:
		abilityStateMachine.transition(abilityRes)


func _on_map_generated():
	place_objectives()


func _on_abilities_setup(abilities :Array):
	map_node.generate_from_positions(puzzle_res.blocs_positions)
	abilitySelector.populate(abilities)
