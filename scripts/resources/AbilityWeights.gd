extends Resource
class_name AbilityWeights

@export var pointUp :float = 0
@export var pointDown :float = 0
@export var pointFar :float = 0
@export var pointSpread :float = 0


func add(other :AbilityWeights) -> void:
	self.pointUp += other.pointUp
	self.pointDown += other.pointDown
	self.pointFar += other.pointFar
	self.pointSpread += other.pointSpread
