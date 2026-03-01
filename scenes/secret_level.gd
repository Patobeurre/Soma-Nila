extends Node3D


@export var preloaded_abilities :Array[AbilityStats] = []

@onready var layers: Node3D = $Layers
@onready var player :PlayerCharacter = $PlayerCharacter
@onready var portal :LevelPortal = $Objective/Portal
@onready var ability_selector :AbilitySelector = $AbilitySelector

@onready var abilityStateMachine :StateMachineStrategy = $AbilitiesStateMachine
@onready var ability_disabled_state :State = $AbilitiesStateMachine/DisabledState

@onready var placeableObject_node :Node3D = $PlaceableObjects
@onready var placeholder_node :Node3D = $TilePlaceholderNode
@export var DISTANCE :float = 10.0
@export var boundOffset :float = 2.0

@onready var ability_settings_default :AbilitiesSettings = load("res://scripts/resources/AbilitiesSettingsDefault.tres")

var isFruitTaken = false


func _ready() -> void:
	$PlayerCharacter.set_enable(false)

	SignalBus.selected_ability_changed.connect(_on_selected_ability_changed)
	SignalBus.use_rope_requested.connect(player.rope_ability_requested)
	SignalBus.use_bubble_requested.connect(player.bubble_ability_requested)
	SignalBus.use_glide_requested.connect(player.glide_ability_requested)
	SignalBus.fruit_picked.connect(_on_fruit_picked)
	SignalBus.enter_level_portal.connect(_on_enter_level_portal)

	generate_terrain()
	load_abilities()
	start_level()

	AudioBus.play_music("SecretLevelMusic")


func _physics_process(delta: float) -> void:

	update_placeholder_position()
	update_placeholder_rotation()

	if Global.player_global_pos.y < -150:
		start_level()
	
	inputManagement()


func inputManagement():
	if Input.is_action_just_pressed("restart"):
		start_level()
	if Input.is_action_just_pressed("ui_cancel"):
		Global.game_controller.return_to_main_menu()


func update_placeholder_position() -> void:
	var new_position = get_placeholder_position()
	
	var space_state = get_world_3d().direct_space_state
	
	var origin :Vector3 = Global.player_global_pos
	var end :Vector3 = new_position
	
	var query = PhysicsRayQueryParameters3D.create(origin, end, 1)
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


func start_level() -> void:
	player.global_position = Vector3(0,-50,0)
	player.set_enable(true)
	abilityStateMachine.transition(ability_selector.get_selected_ability())
	AudioBus.play_sfx("PORTAL_OUT")


func generate_terrain() -> void:
	
	for layer :TerrainGenerationNode in layers.get_children():
		center_layer(layer)
		await layer.init(null)


func center_layer(layer :TerrainGenerationNode) -> void:

	var terrainOffset = (layer.settings.terrainSize * layer.settings.terrain_scale) / 2
	terrainOffset.y = 0

	layer.global_position -= terrainOffset


func load_abilities() -> void:
	var abilities = []
	if !preloaded_abilities.is_empty():
		for preloaded_ability in preloaded_abilities:
			var ability :StateRes = preloaded_ability.ability.duplicate(true)
			ability.initial_amount = preloaded_ability.amount_used
			abilities.append(ability)
	else:
		abilities = SaveManager.save_game_res.remaining_abilities.remaining_abilities
	ability_selector.populate(abilities)
	ability_selector.set_selected_ability(0)


func _on_selected_ability_changed(abilityRes :StateRes) -> void:
	if abilityStateMachine.currState != ability_disabled_state:
		abilityStateMachine.transition(abilityRes)


func _on_fruit_picked(fruit_node :Node3D) -> void:
	if not isFruitTaken:
		fruit_node.visible = false
		isFruitTaken = true
		AudioBus.play_sfx("PICK_FRUIT")
		portal.set_activated(true)
		await get_tree().create_timer(1.0).timeout
		AudioBus.play_sfx("PORTAL_IN")


func _on_enter_level_portal() -> void:
	if isFruitTaken:
		end_level()


func end_level():
	AudioBus.play_sfx("PORTAL_IN")
	SaveManager.save_game_res.progress_variables.broken_level_found = true
	SignalBus.save_requested.emit()
	Global.game_controller.return_to_main_menu()
