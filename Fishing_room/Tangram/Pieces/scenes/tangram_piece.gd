extends Node3D
class_name TangramPiece


@onready var mesh :MeshInstance3D = %Mesh
@onready var highlight_material :ShaderMaterial = load("res://materials/highlight_material.tres")

var stats :TangramPieceStat = TangramPieceStat.new()


signal stats_updated


func init(schema :TangramPieceSchema) -> void:
	stats = TangramPieceStat.from_schema(schema)


func rotate_degree(angle_degree :int):
	stats.add_rotation(angle_degree)
	rotation.z = deg_to_rad(stats.rot_angle)


func set_stats(stat :TangramPieceStat) -> void:
	stats = stat.duplicate(true)
	position.x = stats.position.x
	position.y = stats.position.y
	rotation.z = deg_to_rad(stats.rot_angle)


func update_stats():
	stats.position = Vector2(position.x, position.y)
	stats_updated.emit(stats)


func on_hover_enter():
	#mesh.material_overlay = highlight_material
	pass


func on_hover_exit():
	mesh.material_overlay = null


func on_drag():
	pass


func on_released():
	update_stats()
