extends Node3D
class_name TileBloc


@onready var mesh = $StaticBody3D/BaseMesh
@onready var collision = $StaticBody3D/CollisionShape3D
@onready var dirt_material = load("res://materials/dirt_material.tres")

@onready var highlight_material :ShaderMaterial = load("res://materials/highlight_material.tres")
@onready var highlight_red_material :ShaderMaterial = load("res://materials/highlight_red_material.tres")

@export var isTop :bool = true


func _ready() -> void:
	update_material()


func set_is_top(value :bool) -> void:
	isTop = value
	update_material()

func deactivate_collision(disabled :bool):
	collision.set_deferred("disabled", disabled)


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
