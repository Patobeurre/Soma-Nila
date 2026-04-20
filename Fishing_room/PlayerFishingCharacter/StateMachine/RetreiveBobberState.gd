extends State
class_name RetreiveBobberState

var stateName : String = "RetreiveBobber"
var cR : CharacterBody3D


func enter(charRef : Variant):
	cR = charRef as CharacterBody3D


func exit():
	
	cR.fishingRod.clearRope()

	if cR.bobberRef:
		cR.bobberRef.queue_free()


func _process(delta: float) -> void:

	_retreive_bobber(delta)


func _retreive_bobber(delta :float) -> void:
	transitioned.emit(self, "DefaultFishingState")
	pass