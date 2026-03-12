extends Node3D
class_name TerrainGenerationNode

@export var settings :TerrainGenerationSettings = TerrainGenerationSettings.new()
@onready var bloc_scene :PackedScene = load("res://scenes/Terrain/tile_bloc.tscn")
@onready var bloc_magma_scene :PackedScene = load("res://scenes/Terrain/tile_bloc_magma.tscn")

var allBlocs :Array = []
var allMagmaBlocs = []
var allBlocsPositions :Array = []
var availablePositions :Array = []

signal map_generation_finished


func init(new_settings :TerrainGenerationSettings) -> void:
	if new_settings != null:
		settings = new_settings
	
	await generate_terrain()
	
	while not is_terrain_valid():
		settings.change_seed()
		await generate_terrain()
	
	map_generation_finished.emit()


func is_terrain_valid() -> bool:
	
	if allBlocs.is_empty():
		return false
	if availablePositions.size() < 3:
		return false
	
	return true


func generate_terrain():
	_clear_terrain()
	
	settings.initialize_rng()
	await settings.generate_noise_texture()
	
	var positions = settings.compute_all_positions()
	
	instantiate_blocs(positions)

	apply_spice(settings.terrainSettingStats.convert_spice_level_to_ratio())
	
	availablePositions = retreive_available_positions()


func apply_spice(spicy_ratio :float):
	var nb_magma_bloc :int = int(allBlocs.size() * spicy_ratio)
	for i in range(nb_magma_bloc):
		var bloc = allBlocs.pop_at(settings.rng.randi_range(0, allBlocs.size()-1))
		var pos = bloc.global_position
		bloc.queue_free()
		var bloc_magma = bloc_magma_scene.instantiate()
		add_child(bloc_magma)
		bloc_magma.global_position = pos
		bloc_magma.scale = settings.tile_scale
		allMagmaBlocs.append(bloc_magma)


func generate_from_positions(positions :Array[Vector3]) -> void:
	_clear_terrain()

	var blocs_positions = []
	for pos :Vector3 in positions:
		var global_pos = Vector3(pos.x * settings.terrain_scale.x, pos.y * settings.terrain_scale.y, pos.z * settings.terrain_scale.z)
		print(global_pos)
		blocs_positions.append(global_pos)

	instantiate_blocs(blocs_positions)
	availablePositions = retreive_available_positions()

	map_generation_finished.emit()


func _clear_terrain() -> void:
	allBlocs = []
	availablePositions = []
	for child in get_children():
		child.queue_free()


func retreive_available_positions() -> Array:
	var topPositions = []
	allBlocsPositions = []
	
	for bloc in allBlocs:
		allBlocsPositions.append(bloc.global_position)
	for bloc in allMagmaBlocs:
		allBlocsPositions.append(bloc.global_position)
	
	for bloc in allBlocs:
		var pos = bloc.global_position + Vector3.UP * settings.tile_scale.y
		if not allBlocsPositions.has(pos):
			topPositions.append(pos)
			bloc.set_is_top(true)
		else:
			bloc.set_is_top(false)
	
	return topPositions


func instantiate_blocs(positions :Array):
	for i in range(positions.size()):
		var position = positions[i]
		var obj = bloc_scene.instantiate()
		add_child(obj)
		obj.global_position = position + global_position
		obj.scale = settings.tile_scale
		allBlocs.append(obj)
