extends Resource
class_name PuzzlePlaylistRes


@export var levels :Array[PuzzleLevelRes] = []
@export var current_level :int = 0


func get_current_level() -> PuzzleLevelRes:
	if current_level >= levels.size():
		return null

	return levels[current_level].duplicate(true)

func get_next_level() -> PuzzleLevelRes:
	current_level += 1
	return get_current_level()

static func create(levels :Array[PuzzleLevelRes]) -> PuzzlePlaylistRes:
	var playlist :PuzzlePlaylistRes = PuzzlePlaylistRes.new()
	playlist.levels = levels.duplicate(true)
	playlist.current_level = 0
	return playlist
