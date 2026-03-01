extends Node3D

@export var settings :TerrainGenerationSettings = TerrainGenerationSettings.new()
@onready var terrain :TerrainGenerationNode = $Terrain
@onready var camera :Camera3D = $Camera3D
@onready var golden_fruit :Node3D = $GoldenFruit

@onready var golden_fruit_scene :PackedScene = load("res://models/objects/Strawberry_gold.tscn")
@onready var fruit_scene :PackedScene = load("res://models/objects/Strawberry.tscn")


func _ready() -> void:
	Global.player_global_pos = camera.global_position
	terrain.map_generation_finished.connect(_on_map_generated)

	settings.init(-1)
	terrain.init(settings)


func _on_map_generated():
	var max_nb_pos = terrain.availablePositions.size()
	var nb_fruits :int = min(SaveManager.save_game_res.progress_variables.nb_level_completed, max_nb_pos)

	if SaveManager.save_game_res.progress_variables.secret_level_completed:
		golden_fruit.visible = true

	for i in range(nb_fruits):
		var pos = terrain.availablePositions.pop_at(randi() % terrain.availablePositions.size())
		var fruit_node = fruit_scene.instantiate()
		add_child(fruit_node)
		fruit_node.global_position = pos
