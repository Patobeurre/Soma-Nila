extends Node3D


@onready var player :PlayerCharacter = $PlayerCharacter
@onready var fruit :Node3D = $Objectives/Strawberry
@onready var portal :LevelPortal = $Objectives/Portal
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
@onready var boundaries_node :Node3D = $BoundariesBrokenBloc


# Place Object State
@onready var placeholder_node :Node3D = $TilePlaceholderNode
@export var DISTANCE :float = 10.0
@export var boundOffset :float = 2.0

var isMapGenerated :bool = false
var starting_pos :Vector3 = Vector3.ZERO
var isFruitTaken :bool = false
var currentTimer :float = 0

@export var level_res :MainLevelRes
@export var level_stats :LevelStats

@onready var terminalScene = load("res://models/terminal/terminal.tscn")


func _ready() -> void:
	SignalBus.abilities_setup.connect(_on_abilities_setup, CONNECT_ONE_SHOT)
	SignalBus.level_intro_finished.connect(_on_level_intro_finished)
	SignalBus.selected_ability_changed.connect(_on_selected_ability_changed)
	SignalBus.use_rope_requested.connect(player.rope_ability_requested)
	SignalBus.use_bubble_requested.connect(player.bubble_ability_requested)
	SignalBus.use_glide_requested.connect(player.glide_ability_requested)
	SignalBus.use_jetpack_requested.connect(player.jetpack_ability_requested)
	SignalBus.fruit_picked.connect(_on_fruit_picked)
	SignalBus.enter_level_portal.connect(_on_enter_level_portal)
	SignalBus.terminal_cam_transition_requested.connect(_on_terminal_interaction_request)
	map_node.map_generation_finished.connect(_on_map_generated)

	SaveManager.save_game_res.progress_variables.broken_level_found = true
	SignalBus.save_requested.emit()
	
	isFruitTaken = false
	level_sm.transition(disabled_state)
	
	level_stats = LevelStats.new()
	
	if Global.main_level_res:
		level_res = Global.main_level_res
		level_res.abilitiesSettings.pick_random_abilities()
	else:
		level_res.init()
		level_res.abilitiesSettings.pick_random_abilities()
		_on_level_intro_finished()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact3D"):
		print(abilityStateMachine.currStateName)
	pass


func inputManagement() -> void:
	if Input.is_action_just_pressed("restart"):
		restart_level_keep_params()
	if Input.is_action_just_pressed("restart_forced"):
		restart_level_regenerate()
	if Input.is_action_just_pressed("ui_cancel"):
		Global.game_controller.return_to_main_menu()


func _physics_process(delta: float) -> void:
	update_placeholder_position()
	update_placeholder_rotation()
	currentTimer += delta

	if Global.player_global_pos.y < -50:
		restart_level_keep_params()


func update_placeholder_position() -> void:
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


func update_placeholder_rotation() -> void:
	var rotation = get_placeholder_rotation()
	if Vector2(rotation.x, rotation.z) == Vector2(placeholder_node.global_position.x, placeholder_node.global_position.z):
		return
	placeholder_node.look_at(get_placeholder_rotation())


func get_placeholder_rotation() -> Vector3:
	var pos = Global.player_global_pos
	pos.y = placeholder_node.global_position.y
	return pos


func restart_level_regenerate():
	Global.game_controller.start_new_game()


func restart_level_keep_params():
	Global.game_controller.restart_level()


func remove_placeable_objects() -> void:
	for objects in placeableObject_node.get_children():
		objects.queue_free()


func place_objectives():
	var possible_positions = map_node.availablePositions
	
	var nearestPos :Vector3 = possible_positions[0]
	var minDist :float = Vector3.ZERO.distance_to(nearestPos)
	var farestPos :Vector3 = possible_positions[0]
	var maxDist :float = Vector3.ZERO.distance_to(farestPos)
	
	for pos in possible_positions:
		var distance = Vector3.ZERO.distance_to(pos)
		if distance < minDist:
			minDist = distance
			nearestPos = pos
		if distance > maxDist:
			maxDist = distance
			farestPos = pos
	
	starting_pos = nearestPos
	player.global_position = starting_pos
	portal.global_position = starting_pos
	fruit.global_position = farestPos
	fruit.visible = true


func place_terminal() -> void:
	var possible_positions = map_node.availablePositions
	var directions = [Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK]
	
	for pos in possible_positions:
		if pos == starting_pos: continue
		for direction in directions:
			var end_pos = pos + (direction * level_res.terrainSettings.tile_scale)
			if map_node.allBlocsPositions.has(end_pos):
				var obj = terminalScene.instantiate()
				add_child(obj)
				obj.global_position = pos + direction * level_res.terrainSettings.tile_scale/2
				obj.look_at(pos + direction)
				for bloc in map_node.allBlocs:
					if bloc.global_position == pos + direction * level_res.terrainSettings.tile_scale:
						obj.reparent(bloc.mesh)
				return


func place_bondaries():
	boundaries_node.global_position = (level_res.terrainSettings.terrainSize * level_res.terrainSettings.terrain_scale) / 2
	boundaries_node.global_position.y = 0
	var size :float = (level_res.terrainSettings.terrainSize.x * level_res.terrainSettings.terrain_scale.x)
	boundaries_node.scale = Vector3(size, size, size)



func _on_fruit_picked(fruit_node :Node3D) -> void:
	if not isFruitTaken:
		fruit.visible = false
		isFruitTaken = true
		AudioBus.play_sfx("PICK_FRUIT")
	portal.set_activated(true)


func _on_enter_level_portal() -> void:
	if isFruitTaken:
		end_level()


func end_level():
	AudioBus.play_sfx("PORTAL_IN")
	var remaining_abilities = abilitySelector.items.items
	SaveManager.save_game_res.progress_variables.nb_level_completed += 1
	SaveManager.save_game_res.remaining_abilities.add_all(remaining_abilities)
	SignalBus.save_requested.emit()

	level_stats.game_version = SaveManager.save_game_res.VERSION
	level_stats.set_used_abilities_from_remainings(remaining_abilities)
	level_stats.completionTime = currentTimer
	level_stats.seed = level_res.seed
	for excluded_ability in level_res.abilitiesSettings.excluded_abilities:
		level_stats.excluded_abilities.append(AbilityStats.create(excluded_ability))
	
	Global.current_level_stats = level_stats
	Global.game_controller.end_level_transition()


func _on_level_intro_finished():
	AudioBus.play_sfx("PORTAL_OUT")
	#if isMapGenerated:
	level_sm.transition(playing_state)
	abilitySelector.set_selected_ability(0)
	currentTimer = 0


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
	place_bondaries()
	place_terminal()
	isMapGenerated = true


func _on_abilities_setup(abilities :Array):
	var abilityWeights = level_res.abilitiesSettings.get_picked_abilities_weights()
	level_res.terrainSettings.adjust_params_by_ability_weights(abilityWeights)
	map_node.init(level_res.terrainSettings)
	abilitySelector.populate(abilities)
