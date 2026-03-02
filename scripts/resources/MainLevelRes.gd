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

