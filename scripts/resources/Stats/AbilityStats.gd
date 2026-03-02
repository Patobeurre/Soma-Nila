extends Resource
class_name AbilityStats


@export var ability_name :String = ""
@export var initial_amount :int = 0
@export var amount_left :int = 0
@export var amount_used :int = 0


static func create(stateRes :StateRes, amount :int = 0) -> AbilityStats:
	var abilityStat = AbilityStats.new()
	abilityStat.ability_name = stateRes.name
	abilityStat.initial_amount = stateRes.initial_amount
	abilityStat.amount_left = stateRes.amount
	abilityStat.amount_used = amount
	return abilityStat


func to_state_res(duplicated :bool = true) -> StateRes:
	var abilitySettings :AbilitiesSettings = load("res://scripts/resources/AbilitiesSettingsDefault.tres")
	for ability in abilitySettings.all_abilities:
		if ability.name == ability_name:
			var stateRes :StateRes = ability.duplicate(true) if duplicated else ability
			stateRes.initial_amount = initial_amount
			return stateRes
	return null
