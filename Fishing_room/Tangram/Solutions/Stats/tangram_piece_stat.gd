extends Resource
class_name TangramPieceStat


@export var type :TangramPieceSchema.ETangramPieceType
@export var position :Vector2 = Vector2.ZERO
@export var rot_angle :int = 0
@export var dist_to_center :float = 0.0
var solution_pos :Vector2 = Vector2.ZERO


func set_rotation(degree :float):
	rot_angle = degree
	if type == TangramPieceSchema.ETangramPieceType.SQUARE:
		rot_angle = abs(degree) % 90


func add_rotation(degree :int):
	rot_angle = (rot_angle + degree)
	if type == TangramPieceSchema.ETangramPieceType.SQUARE:
		rot_angle = rot_angle % 90
	elif type == TangramPieceSchema.ETangramPieceType.PARALLELEPIPED:
		rot_angle = rot_angle % 180
	else:
		rot_angle = rot_angle % 360


func equals(other :TangramPieceStat, center_of_mass :Vector2, offset_pos :float) -> bool:
	if type != other.type:
		return false
	if rot_angle != other.rot_angle:
		return false
	var centered_pos = position - center_of_mass
	var dist_offset = centered_pos.distance_to(other.position)
	if (dist_offset > offset_pos):
		return false
	
	print(str(type) + " | " + str(position - center_of_mass) + " : " + str(other.position))
	
	return true


static func from_schema(schema : TangramPieceSchema) -> TangramPieceStat:
	var stat :TangramPieceStat = TangramPieceStat.new()
	stat.type = schema.type
	return stat