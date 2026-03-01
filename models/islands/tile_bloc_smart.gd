extends Node3D

@onready var base_tile_mesh: MeshInstance3D = $StaticBody3D/BaseTileMesh
@onready var collision_shape_3d: CollisionShape3D = $StaticBody3D/CollisionShape3D

@onready var dirt_material = load("res://materials/dirt_material.tres")

@export var isTop :bool = false


func _ready() -> void:
	update_material(isTop)


func update_material(isTop :bool) -> void:
	if not isTop:
		base_tile_mesh.material_override = dirt_material
	else:
		base_tile_mesh.material_override = null


func create_static_collision() -> void:
	base_tile_mesh.create_convex_collision(true, true)


func get_collision_shape() -> CollisionShape3D:
	return collision_shape_3d
