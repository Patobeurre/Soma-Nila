extends Resource
class_name StateRes


@export var stateName :String = ""
@export var name :String = ""
@export var icon :Texture2D
@export var res :Resource = null
@export var initial_amount :int = 1
var amount :int = 0

@export var weights :AbilityWeights = AbilityWeights.new()

signal amount_changed(int)


func set_amount(new_amount :int):
	amount = new_amount
	amount_changed.emit(amount)


func add(other :StateRes):
	initial_amount += other.initial_amount
	weights.add(other.weights)
