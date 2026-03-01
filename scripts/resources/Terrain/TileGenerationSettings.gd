extends Resource
class_name TileGenerationSettings


@export var seed :int = 0
@export var useRandomSeed :bool = false

@export var nbIter :int = 5
@export var nbIterRndOffset = 2
@export var isParallel :bool = false
@export var nbParallelJobs :int = 1

var rng :RandomNumberGenerator = RandomNumberGenerator.new()
var directions = [Vector3.BACK, Vector3.FORWARD, Vector3.UP, Vector3.DOWN, Vector3.LEFT, Vector3.RIGHT]
var positions :Array = []


func init(new_seed :int = -1):
	seed = new_seed
	useRandomSeed = (seed < 0)
	initialize_rng()


func get_random_walk_positions() -> Array:
	
	var starting_pos = Vector3.ZERO
	positions = [starting_pos]
	
	var maxIter = nbIter + rng.randi_range(-nbIterRndOffset, nbIterRndOffset)
	
	_random_walk(starting_pos, maxIter)
	positions = Utils.get_unique_array(positions)
	
	return positions


func initialize_rng() -> void:
	if useRandomSeed:
		rng.randomize()
		rng.seed = randi() % 10000000
	else:
		rng.seed = seed


func _random_walk(position :Vector3, maxIter :int, curIter :int = 0):
	
	if curIter >= maxIter:
		return
	
	var randIdx = rng.randi() % 6
	var new_position = position + directions[randIdx]
	positions.append(new_position)
	
	_random_walk(new_position, maxIter, curIter + 1)
