extends State

class_name DisableState

var stateName : String = "Disable"

var cR : CharacterBody3D

func enter(charRef : Variant):
	cR = charRef as CharacterBody3D


func physics_update(delta : float):
	return
