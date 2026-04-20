extends State
class_name DefaultFishingState

var stateName : String = "DefaultFishing"
var cR : CharacterBody3D


func enter(charRef : Variant):
	cR = charRef as CharacterBody3D


func physics_update(delta: float) -> void:

	inputManagement()


func inputManagement() -> void:
	
	#manage the state transitions depending on the actions inputs
	if Input.is_action_just_pressed(cR.slingAction):
		transitioned.emit(self, "ChargeFishingRodState")
