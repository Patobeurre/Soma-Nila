extends Node3D
class_name TangramPiece


var stats :TangramPieceStat = TangramPieceStat.new()

signal stats_updated


func init(schema :TangramPieceSchema) -> void:
	stats = TangramPieceStat.from_schema(schema)


func rotate_degree(angle_degree :int):
	stats.add_rotation(angle_degree)
	rotation.z = deg_to_rad(stats.rot_angle)
	update_stats()


func set_stats(stat :TangramPieceStat) -> void:
	stats = stat.duplicate(true)
	position.x = stats.position.x
	position.y = stats.position.y
	rotation.z = deg_to_rad(stats.rot_angle)


func update_stats():
	stats.position = Vector2(position.x, position.y)
	stats_updated.emit(stats)


func moved():
	update_stats()
