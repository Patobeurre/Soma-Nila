extends Resource
class_name TangramSolutionStat


@export var name :String = ""
@export var pieces :Array[TangramPieceStat] = []
@export var center_of_mass :Vector2 = Vector2.ZERO
var offset_pos :float = 0.15


func checkSolution(solution_to_check :TangramSolutionStat) -> bool:

	if solution_to_check.pieces.size() != pieces.size():
		return false
	
	solution_to_check.compute_center_of_mass()

	for piece in pieces:
		if not has_valid_piece(piece, solution_to_check):
			return false

	return true


func has_valid_piece(piece_to_check :TangramPieceStat, solution :TangramSolutionStat) -> bool:
	for piece in solution.pieces:
		if piece.equals(piece_to_check, solution.center_of_mass, offset_pos): return true
	return false


func compute_center_of_mass() -> void:
	center_of_mass = Vector2.ZERO
	for piece in pieces:
		center_of_mass += piece.position
	center_of_mass /= pieces.size()


func apply_center_of_mass() -> void:
	for piece in pieces:
		piece.position -= center_of_mass


static func create(piece_stats :Array[TangramPieceStat]) -> TangramSolutionStat:
	var solution :TangramSolutionStat = TangramSolutionStat.new()
	for stat in piece_stats:
		solution.pieces.append(stat)
	#ToDo compute center and distances
	return solution
