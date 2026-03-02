extends State

class_name JetpackState

var stateName : String = "Jetpack"

var cR : CharacterBody3D


func enter(charRef : Variant):
	cR = charRef as CharacterBody3D
	
	verifications()


func exit():
	cR.isJetpackAbilityRequested = false
	SignalBus.jetpack_state_performed.emit()

func verifications():
	cR.moveSpeed = cR.jetpackAirMoveSpeed
	cR.moveAccel = cR.inAirMoveAccel
	cR.moveDeccel = cR.inAirMoveDeccel


func physics_update(delta :float):
	
	inputManagement(delta)
	
	move(delta)


func inputManagement(delta :float):
	if cR.isRopeAbilityRequested:
		if cR.check_rope_state_transition():
			transitioned.emit(self, "RopeState")
	
	if cR.isBubbleAbilityRequested:
		transitioned.emit(self, "BubbleState")
	
	if !cR.isJetpackAbilityRequested:
		transitioned.emit(self, "InAirState")
	
	if Input.is_action_pressed("interact3D"):
		apply_boost_force(delta)
	else:
		transitioned.emit(self, "InAirState")


func apply_boost_force(delta :float):
	cR.velocity.y = lerp(cR.velocity.y, cR.jetpackBoostSpeed, cR.jetpackBoostAccel * delta)


func move(delta : float):
	cR.inputDirection = Input.get_vector(cR.moveLeftAction, cR.moveRightAction, cR.moveForwardAction, cR.moveBackwardAction)
	cR.moveDirection = (cR.camHolder.global_basis * Vector3(cR.inputDirection.x, 0.0, cR.inputDirection.y)).normalized()
	
	if !cR.is_on_floor():
		if cR.moveDirection:
			cR.velocity.x = lerp(cR.velocity.x, cR.moveDirection.x * cR.moveSpeed, cR.moveAccel * delta)
			cR.velocity.z = lerp(cR.velocity.z, cR.moveDirection.z * cR.moveSpeed, cR.moveAccel * delta)
		else:
			cR.desiredMoveSpeed = cR.velocity.length()
			#apply smooth stop
			cR.velocity.x = lerp(cR.velocity.x, 0.0, cR.moveDeccel * delta)
			cR.velocity.z = lerp(cR.velocity.z, 0.0, cR.moveDeccel * delta)
	
	if cR.desiredMoveSpeed >= cR.maxSpeed: cR.desiredMoveSpeed = cR.maxSpeed
