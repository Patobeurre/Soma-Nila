extends State
class_name ClimbStairState

var stateName : String = "ClimbStair"
var cR : CharacterBody3D

@export var playerCam :Camera3D
@export var camTmp :Camera3D

var previousVelocity :Vector3 = Vector3.ZERO
var is_transitionning :bool = false


signal end_camera_transition


func enter(charRef : Variant):
	cR = charRef as CharacterBody3D
	
	verifications()
	
	climb_stair_transition()


func verifications():
	if cR.result_stair_check.is_empty():
		transitioned.emit(self, "IdleState")
	
	previousVelocity = cR.velocity
	previousVelocity.y = 0
	
	end_camera_transition.connect(camera_transition_finished, CONNECT_ONE_SHOT)


func climb_stair_transition():
	
	var to :Transform3D = playerCam.global_transform
	var offsetPos :Vector3 = cR.result_stair_check.position - cR.global_position
	to.origin += offsetPos
	
	var duration :float = cR.result_stair_check.position.distance_to(cR.global_position) / cR.moveSpeed
	
	transition_camera(playerCam, to, duration)


func transition_camera(from :Camera3D, to :Transform3D, duration :float = 1.0):
	
	camTmp.global_transform = from.global_transform
	camTmp.fov = from.fov
	
	is_transitionning = true
	camTmp.make_current()
	
	var tween :Tween = get_tree().create_tween().bind_node(camTmp).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(camTmp, "global_position", to.origin, duration)
	tween.play()
	
	await tween.finished
	
	cR.global_position = cR.result_stair_check.position
	
	from.make_current()
	
	is_transitionning = false
	end_camera_transition.emit()


func camera_transition_finished():
	cR.velocity = previousVelocity
	transitioned.emit(self, "IdleState")


func physics_update(delta : float):
	if is_transitionning:
		cR.velocity = Vector3.ZERO
