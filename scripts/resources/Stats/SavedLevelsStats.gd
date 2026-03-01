extends Resource
class_name SavedLevelStats


@export var levels :Array[LevelStats] = []


func is_level_saved(levelStat :LevelStats) -> bool:
	for level :LevelStats in levels:
		if level.equals(levelStat):
			return true
	return false


func get_level(levelStat :LevelStats) -> LevelStats:
	for level :LevelStats in levels:
		if level.equals(levelStat):
			return level
	return null


func add_level(levelStat :LevelStats) -> void:

	var saved_level :LevelStats = get_level(levelStat)
	if saved_level != null:
		saved_level.completionTime = min(saved_level.completionTime, levelStat.completionTime)
	else:
		levels.append(levelStat)


func remove_level(levelStat :LevelStats) -> void:
	var idx = levels.find(levelStat)
	levels.remove_at(idx)
