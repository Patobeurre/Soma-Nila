@tool
extends Node

@export var terrain_node :Node3D
@export var fruits_node :Node3D

@export var save_path :String = "res://scripts/resources/Levels/Puzzles/"
@export var file_name :String = ""
@export var puzzle_res :PuzzleLevelRes = PuzzleLevelRes.new()

@export_tool_button("Save Level") var save_button :Callable = save_level
@export_tool_button("Load Level") var load_button :Callable = load_level
@export_tool_button("Clear") var clear_button :Callable = clear


@onready var tile_bloc_scene = load("res://scenes/Terrain/tile_bloc.tscn")
@onready var fruit_scene = load("res://models/objects/Strawberry.tscn")


func save_level():

	var res :PuzzleLevelRes = PuzzleLevelRes.new()
	res.ID = puzzle_res.ID
	res.name = puzzle_res.name
	res.abilities = puzzle_res.abilities.duplicate(true)
	res.start_position = puzzle_res.start_position

	res.blocs_positions = []
	for tile in terrain_node.get_children():
		res.blocs_positions.append(tile.global_position)
	
	res.fruits_positions = []
	for fruit in fruits_node.get_children():
		res.fruits_positions.append(fruit.global_position)

	var filePath :String = save_path + str(res.ID) + "-" + file_name + ".tres"
	ResourceSaver.save(res, filePath)


func clear() -> void:
	puzzle_res = PuzzleLevelRes.new()
	file_name = ""

	clear_nodes()


func clear_nodes() -> void:
	var terrain = get_node("./Terrain")
	for child in terrain.get_children():
		terrain.remove_child(child)

	var fruits = get_node("./Fruits")
	for child in fruits.get_children():
		fruits.remove_child(child)


func load_level():

	if puzzle_res == null:
		return
	
	clear_nodes()

	file_name = puzzle_res.name

	var terrain = get_node("./Terrain")
	for bloc_pos in puzzle_res.blocs_positions:
		var tile = tile_bloc_scene.instantiate()
		terrain.add_child(tile)
		tile.set_owner(get_tree().edited_scene_root)
		tile.global_position = bloc_pos

	var fruits = get_node("./Fruits")
	for fruit_pos in puzzle_res.fruits_positions:
		var fruit = fruit_scene.instantiate()
		fruits.add_child(fruit)
		fruit.set_owner(get_tree().edited_scene_root)
		fruit.global_position = fruit_pos
		fruit.scale = Vector3.ONE * 0.2