extends State
class_name LevelDisabledState

var stateName : String = "Disabled"

var parentNode :Node3D

func enter(res : Variant):
	parentNode.player.set_enable(false)
	parentNode.enable_ability_selector(false)


func physics_update(delta : float):
	return


func update(delta : float):
	pass


func setRefNode(node :Node3D):
	parentNode = node
