extends Node

class_name State

signal transitioned

func enter(charReference : Variant):
	#enter state
	pass
	
func exit():
	#exit state
	pass
	
func update(_delta : float):
	#process update
	pass
	
func physics_update(_delta : float):
	#physics_process update
	pass 
