extends State
class_name LevelPlayingState

var stateName : String = "Playing"

var parentNode :Node3D

func enter(res : Variant):
	parentNode.player.set_enable(true)
	parentNode.enable_ability_selector(true)


func physics_update(delta : float):
	return


func update(delta : float):
	inputManagement()


func inputManagement():
	if Input.is_action_just_pressed("restart"):
		parentNode.restart_level_keep_params()
	if Input.is_action_just_pressed("restart_forced"):
		parentNode.restart_level_regenerate()
	if Input.is_action_just_pressed("ui_cancel"):
		Global.game_controller.return_to_main_menu()


func setRefNode(node :Node3D):
	parentNode = node
