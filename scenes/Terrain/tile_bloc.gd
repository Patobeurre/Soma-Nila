extends Node3D
class_name TileBloc


@onready var mesh = %BaseMesh
@onready var collision = %CollisionShape3D
@onready var decoration_node = %Decoration
@onready var dirt_material = load("res://materials/dirt_material.tres")

@onready var highlight_material :ShaderMaterial = load("res://materials/highlight_material.tres")
@onready var highlight_red_material :ShaderMaterial = load("res://materials/highlight_red_material.tres")

@export var isTop :bool = true

@export_group("Decoration variables")
@export var hasDecoration :bool = true
@export var MAX_DECO_ELEMENTS :int = 5
@export var border_offset :float = 0.1

@onready var grass_scene :PackedScene = load("res://models/decoration/grass.tscn")
@onready var stick_scene :PackedScene = load("res://models/decoration/stick.tscn")
@onready var pebble_scene :PackedScene = load("res://models/decoration/pebble.tscn")



var isMoving :bool = false
var move_speed :float = 0
var move_dir :Vector3 = Vector3.ZERO
var to_position :Vector3 = Vector3.ZERO


func _ready() -> void:
	update_material()
	_update_decorations()


func set_is_top(value :bool) -> void:
	isTop = value
	update_material()
	_update_decorations()


func deactivate_collision(disabled :bool):
	collision.set_deferred("disabled", disabled)


func _physics_process(delta: float) -> void:
	if isMoving:
		var dir = _get_current_dir()
		position += dir * move_speed * delta
		if dir.dot(move_dir) < 0 :
			isMoving = false


func start_moving(to :Vector3, speed :float):
	to_position = to
	move_dir = _get_current_dir()
	move_speed = speed
	isMoving = true


func _get_current_dir() -> Vector3:
	return (to_position - global_position).normalized()


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


func _update_decorations() -> void:
	if !isTop or !hasDecoration:
		Utils.remove_children(decoration_node)
		return
	
	var nb_deco_elem :int = randi_range(0, MAX_DECO_ELEMENTS)

	for i in range(nb_deco_elem):
		var obj = grass_scene.instantiate()
		decoration_node.add_child(obj)
		obj.position = Vector3(randf_range(border_offset, 1.0 - border_offset) - 0.5, 0.5, randf_range(border_offset, 1.0 - border_offset) - 0.5)
		obj.rotation.y = deg_to_rad(randi_range(0, 180))
	
	if nb_deco_elem == MAX_DECO_ELEMENTS:
		if randi() % 10 > 7:
			var obj = stick_scene.instantiate()
			decoration_node.add_child(obj)
			obj.position = Vector3(randf_range(border_offset*2, 1.0 - border_offset*2) - 0.5, 0.5, randf_range(border_offset, 1.0 - border_offset) - 0.5)
			obj.rotation.y = deg_to_rad(randi_range(0, 180))
	
	if randi() % 10 > 8:
		for i in range(randi_range(0,3)):
			var obj = pebble_scene.instantiate()
			decoration_node.add_child(obj)
			obj.position = Vector3(randf_range(border_offset*2, 1.0 - border_offset*2) - 0.5, 0.5, randf_range(border_offset, 1.0 - border_offset) - 0.5)
			obj.rotation.y = deg_to_rad(randi_range(0, 180))
			obj.scale = Vector3.ONE * randf()