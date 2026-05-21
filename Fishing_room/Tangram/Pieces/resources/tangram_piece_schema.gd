extends Resource
class_name TangramPieceSchema


enum ETangramPieceType {
	SQUARE,
	TRIANGLE_S,
	TRIANGLE_M,
	TRIANGLE_L,
	PARALLELEPIPED,
}


@export var type :ETangramPieceType
@export var mesh_scene :PackedScene


static func from_type(type :ETangramPieceType) -> TangramPieceSchema:
	match type:
		ETangramPieceType.SQUARE:
			return load("res://Fishing_room/Tangram/Pieces/resources/schema_res/Square.tres")
		ETangramPieceType.TRIANGLE_S:
			return load("res://Fishing_room/Tangram/Pieces/resources/schema_res/Triangle_S.tres")
		ETangramPieceType.TRIANGLE_M:
			return load("res://Fishing_room/Tangram/Pieces/resources/schema_res/Triangle_M.tres")
		ETangramPieceType.TRIANGLE_L:
			return load("res://Fishing_room/Tangram/Pieces/resources/schema_res/Triangle_L.tres")
		ETangramPieceType.PARALLELEPIPED:
			return load("res://Fishing_room/Tangram/Pieces/resources/schema_res/Parallelepiped.tres")
	
	return null