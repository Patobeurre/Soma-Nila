extends Resource
class_name RemainingAbilitiesStats

@export var remaining_abilities :Array[StateRes] = []


func add_all(abilities :Array) -> void:
	for ability :StateRes in abilities:
		add(ability)
	print(remaining_abilities)


func add(ability :StateRes) -> void:
	var dup_ability = ability.duplicate(true)
	dup_ability.initial_amount = ability.amount
	if dup_ability.initial_amount > 0:
		for i in range(remaining_abilities.size()):
			var remaining_ability = remaining_abilities[i]
			if dup_ability.name == remaining_ability.name:
				remaining_ability.add(dup_ability)
				return
		remaining_abilities.append(dup_ability)

