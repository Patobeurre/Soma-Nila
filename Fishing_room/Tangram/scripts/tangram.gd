extends Node3D
class_name Tangram



@onready var pieces_node = %Pieces
var pieces :Array[TangramPiece] = []

@export var available_pieces :Array[TangramPieceSchema]
@export var solutions_to_check :Array[TangramSolutionStat] = []

var current_solution :TangramSolutionStat = TangramSolutionStat.new()

@onready var drag_drop_system :DragAndDrop3DSystem = %DragAndDrop3DSystem


signal solution_checked


func _ready() -> void:
	_instantiate_available_pieces()
	current_solution = TangramSolutionStat.create(_retreive_pieces_stats())
	solutions_to_check.append(ResourceLoader.load("user://tangram/initial_square.tres"))
	solutions_to_check.append(ResourceLoader.load("user://tangram/jumping_fish.tres"))


func set_available_pieces(given_pieces :Array[TangramPieceSchema]):
	available_pieces = given_pieces
	_instantiate_available_pieces()
	current_solution = TangramSolutionStat.create(_retreive_pieces_stats())


func load_solution(solution :TangramSolutionStat) -> void:
	_remove_all_pieces()
	for piece in solution.pieces:
		_instantiate_piece_stat(piece)
	current_solution = TangramSolutionStat.create(_retreive_pieces_stats())
	current_solution.center_of_mass = Vector2.ZERO


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		_rotate_piece()


func _rotate_piece() -> void:
	var intersect :Dictionary = drag_drop_system.intersect_ray

	if not intersect.is_empty():
		intersect.collider.rotate_degree(45)


func _remove_all_pieces() -> void:
	for piece :TangramPiece in pieces:
		piece.stats_updated.disconnect(_on_piece_stat_updated)
	Utils.remove_children(pieces_node)
	pieces = []



func _instantiate_piece(piece :TangramPieceSchema):
	var obj :TangramPiece = piece.mesh_scene.instantiate()
	pieces_node.add_child(obj)
	obj.init(piece)
	obj.stats_updated.connect(_on_piece_stat_updated)
	pieces.append(obj)


func _instantiate_piece_stat(stat :TangramPieceStat):
	var piece = TangramPieceSchema.from_type(stat.type)
	var obj :TangramPiece = piece.mesh_scene.instantiate()
	pieces_node.add_child(obj)
	obj.init(piece)
	obj.set_stats(stat)
	obj.stats_updated.connect(_on_piece_stat_updated)
	pieces.append(obj)


func _instantiate_available_pieces() -> void:
	_remove_all_pieces()
	for piece in available_pieces:
		_instantiate_piece(piece)


func _retreive_pieces_stats() -> Array[TangramPieceStat]:
	var piece_stats :Array[TangramPieceStat] = []
	for piece in pieces:
		piece_stats.append(piece.stats)
	return piece_stats


func _check_solution() -> TangramSolutionStat:
	for solution :TangramSolutionStat in solutions_to_check:
		if solution.checkSolution(current_solution.duplicate(true)):
			solution_checked.emit(solution)
			return solution
	return null


func _on_piece_stat_updated(piece_stat :TangramPieceStat) -> void:
	solution_checked.emit(_check_solution())
