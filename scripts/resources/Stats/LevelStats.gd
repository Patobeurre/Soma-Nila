extends Resource
class_name LevelStats


@export var seed :int = -1
@export var excluded_abilities :Array[StateRes] = []

@export var completionTime :float = 0
@export var used_abilities :Array[AbilityStats] = []


func set_used_abilities_from_remainings(abilities :Array):
	for ability :StateRes in abilities:
		var abilityStat = AbilityStats.new()
		abilityStat.ability = ability.duplicate(true)
		abilityStat.amount_used = ability.initial_amount - ability.amount
		used_abilities.append(abilityStat)


func equals(other :LevelStats) -> bool:
	if seed != other.seed: return false
	for ability in excluded_abilities:
		if not other.excluded_abilities.has(ability):
			return false
	return true
