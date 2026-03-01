extends State
class_name LevelInteractingState


var stateName : String = "Interacting"

var parentNode :Node3D

@export var cam_transition_duration :float = 1.0
var camera_from :Camera3D


func enter(res : Variant):
	parentNode.player.set_enable(false, false)
	parentNode.enable_ability_selector(false)
	camera_from = get_viewport().get_camera_3d()
	CameraTransition.transition_camera(camera_from, parentNode.interacting_camera, cam_transition_duration)
	Global.game_controller.display_current_gui(false)
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN


func exit():
	Global.game_controller.display_current_gui(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func end_interaction():
	CameraTransition.end_camera_transition.connect(on_end_interaction, CONNECT_ONE_SHOT)
	CameraTransition.transition_camera(get_viewport().get_camera_3d(), camera_from, cam_transition_duration)


func update(delta : float):
	if CameraTransition.is_transitioning:
		return
	
	inputManagement()


func inputManagement():
	if Input.is_action_just_pressed("ui_cancel"):
		end_interaction()


func on_end_interaction():
	parentNode.exit_interaction()


func physics_update(delta : float):
	return


func setRefNode(node :Node3D):
	parentNode = node
