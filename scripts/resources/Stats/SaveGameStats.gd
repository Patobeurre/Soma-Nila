extends Resource
class_name SaveGameStats

const SAVE_GAME_PATH := "user://save"

var VERSION :String = "1.1"

@export var current_version :String = "0"
@export var favorite_levels :SavedLevelStats = SavedLevelStats.new()
@export var remaining_abilities :RemainingAbilitiesStats = RemainingAbilitiesStats.new()
@export var progress_variables :ProgressVariablesStats = ProgressVariablesStats.new()


func write_savegame() -> void:
	print("write save game...")
	ResourceSaver.save(self, get_save_path())
	print("done")

static func save_exists() -> bool:
	print(get_save_path())
	return ResourceLoader.exists(get_save_path())


static func load_savegame() -> Resource:
	var save_path := get_save_path()
	var save_res = ResourceLoader.load(save_path)
	#ToDo:
	return save_res


static func make_random_path() -> String:
	return "user://temp_file_" + str(randi()) + ".tres"


# This function allows us to save and load a text resource in debug builds and a
# binary resource in the released product.
static func get_save_path() -> String:
	var extension := ".tres" if OS.is_debug_build() else ".res"
	return SAVE_GAME_PATH + extension
