extends Node3D
class_name TileBloc


@onready var mesh = $StaticBody3D/BaseMesh
@onready var collision = $StaticBody3D/CollisionShape3D
@onready var animated_body = $StaticBody3D
@onready var dirt_material = load("res://materials/dirt_material.tres")

@onready var highlight_material :ShaderMaterial = load("res://materials/highlight_material.tres")
@onready var highlight_red_material :ShaderMaterial = load("res://materials/highlight_red_material.tres")

@export var isTop :bool = true

var isMoving :bool = false
var move_speed :float = 0
var from_position :Vector3 = Vector3.ZERO
var to_position :Vector3 = Vector3.ZERO


func _ready() -> void:
	update_material()


func set_is_top(value :bool) -> void:
	isTop = value
	update_material()


func deactivate_collision(disabled :bool):
	collision.set_deferred("disabled", disabled)


func _physics_process(delta: float) -> void:
	if isMoving:
		global_position = lerp(from_position, to_position, delta)
		if global_position == to_position:
			isMoving = false


func start_moving(to :Vector3, speed :float):
	from_position = global_position
	to_position = to
	move_speed = speed
	isMoving = true



func update_material() -> void:
	if not isTop:
		mesh.material_override = dirt_material
	else:
		mesh.material_override = null


func highlight(toHighlight :bool, is_red :bool = false):
	if toHighlight:
		mesh.material_overlay = highlight_red_material if is_red else highlight_material
	else:
		mesh.material_overlay = null
