extends State

class_name BubbleState

var stateName : String = "Bubble"

var cR : CharacterBody3D

func enter(charRef : Variant):
	cR = charRef as CharacterBody3D
	cR.isBubbleAbilityRequested = false
	
	verifications()

func verifications():
	cR.moveAccel = cR.bubbleMoveAccel


func physics_update(delta : float):
	
	move(delta)
	
	inputManagement()


func inputManagement():
	if cR.isRopeAbilityRequested:
		if cR.check_rope_state_transition():
			transitioned.emit(self, "RopeState")
	
	if cR.isClimbAreaAbilityRequested:
		transitioned.emit(self, "ClimbAreaState")
	
	if Input.is_action_just_pressed(cR.jumpAction):
		cR.velocity = Vector3.ZERO
		var pushForce = Global.player_camera_orientation * cR.bubblePushForce
		pushForce.y /= 2
		cR.applyExternalForce(pushForce)
		transitioned.emit(self, "IdleState")


func move(delta : float):
	cR.moveDirection = cR.bubble_position - cR.global_position
	var distance = cR.bubble_position.distance_to(cR.global_position)
	
	cR.velocity = lerp(cR.velocity, cR.moveDirection * cR.bubblePullForce * distance, delta * cR.moveAccel)
