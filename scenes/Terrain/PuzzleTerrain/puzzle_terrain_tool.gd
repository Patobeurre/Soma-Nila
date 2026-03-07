@tool
extends Node

@export var terrain_node :Node3D
@export var fruits_node :Node3D

@export var save_path :String = "res://scripts/resources/Levels/Puzzles/"
@export var file_name :String = ""
@export var puzzle_res :PuzzleLevelRes = PuzzleLevelRes.new()

@export_tool_button("Save Level") var save_button :Callable = save_level


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
	print(filePath)
	ResourceSaver.save(res, filePath)
