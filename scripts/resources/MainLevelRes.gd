extends Resource
class_name MainLevelRes


@export var seed :int = -1
@export var useRandomSeed :bool = true

@export var nb_fruits :int = 1
@export var abilitiesSettings :AbilitiesSettings = AbilitiesSettings.new()
@export var terrainSettings :TerrainGenerationSettings = TerrainGenerationSettings.new()

@export var isCustom :bool = false


func init():
	if useRandomSeed:
		seed = randi() % 10000000
	abilitiesSettings.init(seed)
	terrainSettings.init(seed)

func restart():
	abilitiesSettings.init(seed)
	terrainSettings.init(seed)


static func from_level_stats(levelStats :LevelStats) -> MainLevelRes:
	var level_res = MainLevelRes.new()
	
	level_res.isCustom = true
	level_res.seed = levelStats.seed
	level_res.useRandomSeed = false
	
	level_res.abilitiesSettings.excluded_abilities = levelStats.excluded_abilities
	
	return level_res
