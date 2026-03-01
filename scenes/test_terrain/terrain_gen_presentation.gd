extends Node3D


@onready var fruit :Node3D = $Objectives/Strawberry
@onready var portal :LevelPortal = $Objectives/Portal

@onready var map_node :TerrainGenerationNode = $MapTiles
@onready var objectives_node :Node3D = $Objectives

@onready var camera_node :Node3D = $CameraNode
@onready var camera :Camera3D = $CameraNode/Camera3D
@export var cam_rotate_speed :float = 5.0

var starting_pos :Vector3 = Vector3.ZERO
var isFruitTaken :bool = false
var currentTimer :float = 0

@export var level_res :MainLevelRes

@onready var terminalScene = load("res://models/terminal/terminal.tscn")


func _ready() -> void:
	map_node.map_generation_finished.connect(_on_map_generated)

	if Global.main_level_res:
		level_res = Global.main_level_res
	else:
		level_res.init()
	
	map_node.init(null)


func _process(delta: float) -> void:
	rotate_camera(delta)
	inputManagement()


func inputManagement() -> void:
	if Input.is_action_just_pressed("interact3D"):
		map_node.init(null)


func rotate_camera(delta: float) -> void:
	camera_node.rotate(Vector3.UP, delta * cam_rotate_speed)
	Global.player_global_pos = camera.global_position


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
	portal.global_position = starting_pos
	fruit.global_position = farestPos
	fruit.visible = true
	portal.set_activated(true)


func place_camera() -> void:
	var possible_positions = map_node.availablePositions

	var center :Vector3 = Vector3.ZERO

	for pos in possible_positions:
		center += pos
	center /= possible_positions.size()

	camera_node.global_position = center



func _on_map_generated():
	place_objectives()
	place_camera()


func _on_timer_timeout() -> void:
	map_node.init(null)
