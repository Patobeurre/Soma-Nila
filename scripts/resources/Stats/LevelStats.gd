extends Resource
class_name LevelStats


@export var game_version :String = "0"
@export var seed :int = -1
@export var excluded_abilities :Array[AbilityStats] = []

@export var completionTime :float = 0
@export var used_abilities :Array[AbilityStats] = []

@export var terrain_stats :TerrainSettingStats = TerrainSettingStats.new()


func set_used_abilities_from_remainings(abilities :Array):
	for ability :StateRes in abilities:
		var abilityStat :AbilityStats = AbilityStats.create(ability.duplicate(true), ability.initial_amount - ability.amount)
		used_abilities.append(abilityStat)


func equals(other :LevelStats) -> bool:
	if seed != other.seed:
		return false
	if terrain_stats.spice_level != other.terrain_stats.spice_level:
		return false
	for ability in excluded_abilities:
		if not has_ability(other.excluded_abilities, ability):
			return false
	return true


func has_ability(abilities :Array[AbilityStats], ability_to_find :AbilityStats) -> bool:
	for ability in abilities:
		if ability.ability_name == ability_to_find.ability_name:
			return true
	return false