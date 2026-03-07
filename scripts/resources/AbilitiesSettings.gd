extends Resource
class_name AbilitiesSettings


@export var seed :int = -1
@export var useRandomSeed :bool = true

@export var nb_abilities_max :int = 3
@export var allowSameAbilities :bool = true
@export var all_abilities :Array[StateRes] = []
@export var excluded_abilities :Array[StateRes] = []
var picked_abilities :Array = []

var rng :RandomNumberGenerator = RandomNumberGenerator.new()


func init(new_seed :int = -1):
	seed = new_seed
	useRandomSeed = (seed < 0)
	initialize_rng()


func initialize_rng() -> void:
	if useRandomSeed:
		rng.randomize()
		rng.seed = randi() % 10000000
	else:
		rng.seed = seed


func get_available_abilities() -> Array:
	return Utils.subtractArr(all_abilities, excluded_abilities)


func pick_random_abilities():
	picked_abilities = []
	var available_abilities = get_available_abilities()
	
	if not allowSameAbilities and available_abilities.size() <= nb_abilities_max:
		picked_abilities = available_abilities
	else:
		while picked_abilities.size() < nb_abilities_max:
			var idx = rng.randi() % available_abilities.size()
			var ability = available_abilities[idx]
			if allowSameAbilities or not picked_abilities.has(ability):
				picked_abilities.append(ability)

	var duplicated_abilities = get_duplicated_abilities()
	
	SignalBus.abilities_setup.emit(duplicated_abilities)


func set_picked_abilities(abilities :Array[AbilityStats]) -> void:
	picked_abilities = []
	
	for ability in abilities:
		picked_abilities.append(ability.to_state_res())

	SignalBus.abilities_setup.emit(get_duplicated_abilities())


func try_merge_abilities(ability :StateRes, merged_abilities :Array) -> bool:
	for merged_ability in merged_abilities:
		if ability.name == merged_ability.name:
			merged_ability.add(ability)
			return true
	return false

func merge_same_abilities(abilities :Array) -> Array:
	var merged_abilities = []
	for ability in abilities:
		if not try_merge_abilities(ability, merged_abilities):
			merged_abilities.append(ability)
	return merged_abilities


func get_duplicated_abilities() -> Array:
	var duplicated_abilities = []
	for ability in picked_abilities:
		ability.amount = ability.initial_amount
		duplicated_abilities.append(ability.duplicate(true))
	duplicated_abilities = merge_same_abilities(duplicated_abilities)
	return duplicated_abilities


func get_picked_abilities_weights() -> Array[AbilityWeights]:
	
	var weights :Array[AbilityWeights] = []
	
	for ability in picked_abilities:
		weights.append(ability.weights)
		
	return weights
