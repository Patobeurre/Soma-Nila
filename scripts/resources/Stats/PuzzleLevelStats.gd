extends Resource
class_name PuzzleLevelStats


@export var completed_puzzle_levels :Array[LevelStats] = []


func save(level_stats :LevelStats) -> void:

	var saved_level :LevelStats = try_get_completed_level(level_stats.seed)

	if saved_level != null:
		saved_level.completionTime = min(saved_level.completionTime, level_stats.completionTime)
	else:
		completed_puzzle_levels.append(level_stats)

	SignalBus.save_requested.emit()
	

func try_get_completed_level(id :int) -> LevelStats:

	for completed_level in completed_puzzle_levels:
		if completed_level.seed == id:
			return completed_level
	
	return null