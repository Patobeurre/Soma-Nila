extends Resource
class_name PuzzleLevelRes


@export var ID :int = 0
@export var name :String = ""
@export var abilities :Array[AbilityStats] = []
@export var blocs_positions :Array[Vector3] = []
@export var fruits_positions :Array[Vector3] = []
@export var start_position :Vector3 = Vector3.ZERO


func copy() -> PuzzleLevelRes:
	var res : PuzzleLevelRes = PuzzleLevelRes.new()
	res.ID = ID
	res.name = name
	res.abilities = abilities.duplicate(true)
	res.blocs_positions = blocs_positions.duplicate(true)
	res.fruits_positions = fruits_positions.duplicate(true)
	res.start_position = start_position
	return res