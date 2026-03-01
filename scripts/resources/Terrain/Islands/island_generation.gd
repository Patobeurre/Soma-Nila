extends Node3D


@export var terrain_gen_settings :IslandGenerationSettings

@onready var ISLAND_NOISE = load("res://scripts/resources/Terrain/Islands/IslandNoise.tres")
@onready var TILE_BLOC = load("res://models/islands/tile_bloc_smart.tscn")

@onready var meshes: Node3D = $Meshes
@onready var collisions: StaticBody3D = $StaticBody3D

var tile_bloc_matrix :Matrix3D = Matrix3D.new()
var load_frame_matrix :Matrix3D = Matrix3D.new()
@export var load_frame_size :int = 5
var current_player_pos :Vector3 = Vector3.ZERO

@export var enable :bool = false

var neighbour_directions :Array = [Vector3.UP, Vector3.DOWN, Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]


func _ready() -> void:
	if !enable: return
	tile_bloc_matrix.initialize_with(terrain_gen_settings.terrainSize, null)
	#_initialize_load_frame_mat()
	init()
	SignalBus.on_player_pos_changed.connect(_on_player_pos_changed)


func init():
	if !enable:
		return
	Utils.remove_children(meshes)
	Utils.remove_children(collisions)
	terrain_gen_settings.init()
	generate_terrain()


func _initialize_load_frame_mat() -> void:
	var size = Vector3(load_frame_size, load_frame_size, load_frame_size)
	load_frame_matrix.initialize_with(size, 0)
	for x in range(size.x):
		for y in range(size.y):
			for z in range(size.z):
				var pos = Vector3(x, y, z)
				load_frame_matrix.set_value(pos, pos - size/2)


func generate_terrain() -> void:
	await terrain_gen_settings.generate_noise_texture()
	terrain_gen_settings.compute_all_positions()
	_instantiate_terrain()


func _instantiate_bloc(pos :Vector3):
	var obj = TILE_BLOC.instantiate()
	meshes.add_child(obj)
	obj.global_position = pos * terrain_gen_settings.tile_scale + global_position
	obj.scale = terrain_gen_settings.tile_scale
	
	if not check_is_surrounded(pos):
		obj.get_collision_shape().reparent(collisions)
		obj.update_material(check_is_top(pos))
	
	tile_bloc_matrix.set_value(pos, obj)


func check_is_top(pos :Vector3) -> bool:
	return terrain_gen_settings.positions_matrix.get_value(Vector3(pos.x, pos.y+1, pos.z)) != 1


func check_is_surrounded(pos :Vector3) -> bool:
	for direction in neighbour_directions:
		if terrain_gen_settings.positions_matrix.get_value(pos + direction) != 1:
			return false
	return true


func _instantiate_terrain():
	for x in range(terrain_gen_settings.positions_matrix.size.x):
		for y in range(terrain_gen_settings.positions_matrix.size.y):
			for z in range(terrain_gen_settings.positions_matrix.size.z):
				var pos = Vector3(x, y, z)
				if terrain_gen_settings.positions_matrix.get_value(pos):
					_instantiate_bloc(pos)


func update_tile_collisions(player_pos :Vector3) -> void:
	var tile_pos = player_pos
	
	#var positions = [
	#	tile_pos,
	#	tile_pos+Vector3(1,0,0),
	#	tile_pos+Vector3(0,0,1),
	#	tile_pos+Vector3(1,0,1),
	#	tile_pos-Vector3(1,0,0),
	#	tile_pos-Vector3(0,0,1),
	#	tile_pos-Vector3(1,0,1),
	#	tile_pos+Vector3(1,0,-1),
	#	tile_pos+Vector3(-1,0,1),
	#	tile_pos-Vector3(0,1,0),
	#	tile_pos-Vector3(0,2,0),
	#	tile_pos-Vector3(0,3,0),
	#]
	
	#for p in positions:
	#	var tile = tile_bloc_matrix.get_value(p)
	#	if tile != null:
	#		tile.get_collision_shape().reparent(collisions)
	
	for x in range(load_frame_matrix.size.x):
		for y in range(load_frame_matrix.size.y):
			for z in range(load_frame_matrix.size.z):
				var pos = load_frame_matrix.get_value(Vector3(x, y, z))
				var tile = tile_bloc_matrix.get_value(tile_pos + pos)
				if tile != null:
					tile.get_collision_shape().reparent(collisions)


func get_relative_position(global_pos :Vector3):
	var pos = (global_pos - global_position) / terrain_gen_settings.terrain_scale / terrain_gen_settings.tile_scale
	return Vector3(floor(pos.x), floor(pos.y), floor(pos.z))


func _on_player_pos_changed(new_pos :Vector3):
	return
	var player_pos = get_relative_position(new_pos)
	if current_player_pos != player_pos:
		current_player_pos = player_pos
		update_tile_collisions(current_player_pos)
