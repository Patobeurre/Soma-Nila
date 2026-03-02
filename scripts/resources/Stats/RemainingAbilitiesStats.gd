extends Resource
class_name RemainingAbilitiesStats

@export var remaining_abilities :Array[AbilityStats] = []


func add_all(abilities :Array) -> void:
	for ability :StateRes in abilities:
		add(AbilityStats.create(ability))
	print(remaining_abilities)

func add(ability :AbilityStats) -> void:
	ability.initial_amount = ability.amount_left
	if ability.initial_amount > 0:
		for i in range(remaining_abilities.size()):
			var remaining_ability = remaining_abilities[i]
			if ability.ability_name == remaining_ability.ability_name:
				remaining_ability.initial_amount += ability.initial_amount
				return
		remaining_abilities.append(ability)

func to_state_res() -> Array[StateRes]:
	var remaining_state_res :Array[StateRes] = []

	for abilityStats in remaining_abilities:
		remaining_state_res.append(abilityStats.to_state_res())
	
	return remaining_state_res

