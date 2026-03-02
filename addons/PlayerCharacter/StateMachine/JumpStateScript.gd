extends State

class_name JumpState

var stateName : String = "Jump"

var cR : CharacterBody3D

func enter(charRef : Variant):
	cR = charRef as CharacterBody3D
	cR.isJumping = true
	
	verifications()
	
	jump()

func verifications():
	if cR.floor_snap_length != 0.0:  cR.floor_snap_length = 0.0
	if cR.jumpCooldown < cR.jumpCooldownRef: cR.jumpCooldown = cR.jumpCooldownRef
	if cR.hitGroundCooldown != cR.hitGroundCooldownRef: cR.hitGroundCooldown = cR.hitGroundCooldownRef
	
	cR.is_jump_released = false

func physics_update(delta : float):
	
	applies(delta)
	
	cR.gravityApply(delta)
	
	inputManagement(delta)
	
	checkIfFloor()
	
	move(delta)
	
	if cR.is_jump_released:
		decelerate_jump(delta)


func applies(delta : float):
	if !cR.is_on_floor(): 
		if cR.jumpCooldown > 0.0: cR.jumpCooldown -= delta
		if cR.coyoteJumpCooldown > 0.0: cR.coyoteJumpCooldown -= delta
		
	cR.hitbox.shape.height = lerp(cR.hitbox.shape.height, cR.baseHitboxHeight, cR.heightChangeSpeed * delta)
	cR.model.scale.y = lerp(cR.model.scale.y, cR.baseModelHeight, cR.heightChangeSpeed * delta)
	
func inputManagement(delta :float):
	if cR.isRopeAbilityRequested:
		if cR.check_rope_state_transition():
			transitioned.emit(self, "RopeState")
	
	if cR.isClimbAreaAbilityRequested:
		transitioned.emit(self, "ClimbAreaState")
	
	if cR.isBubbleAbilityRequested:
		transitioned.emit(self, "BubbleState")
	
	if cR.isJetpackAbilityRequested:
		transitioned.emit(self, "JetpackState")

	if Input.is_action_just_pressed(cR.jumpAction):
		if cR.checkStamina(cR.jumpStaminaConsumption):
			transitioned.emit(self, "JumpState")
			
	if Input.is_action_just_pressed(cR.jumpAction):
		jump()
	if Input.is_action_just_released(cR.jumpAction):
		cR.is_jump_released = true

func checkIfFloor():
	if !cR.is_on_floor() and cR.velocity.y < 0.0:
		transitioned.emit(self, "InairState")
	if cR.is_on_floor():
		if cR.moveDirection: transitioned.emit(self, cR.walkOrRun)
		else: transitioned.emit(self, "IdleState")
		
func move(delta : float):
	cR.inputDirection = Input.get_vector(cR.moveLeftAction, cR.moveRightAction, cR.moveForwardAction, cR.moveBackwardAction)
	cR.moveDirection = (cR.camHolder.global_basis * Vector3(cR.inputDirection.x, 0.0, cR.inputDirection.y)).normalized()
	
	#move only apply when the character is not on the floor (so if he's in the air)
	if !cR.is_on_floor():
		if cR.moveDirection:
			if cR.desiredMoveSpeed < cR.maxSpeed: cR.desiredMoveSpeed += cR.bunnyHopDmsIncre * delta
			var contrdDesMoveSpeed : float = cR.desiredMoveSpeedCurve.sample(cR.desiredMoveSpeed/100)
			var contrdInAirMoveSpeed : float = cR.inAirMoveSpeedCurve.sample(cR.desiredMoveSpeed/100)
			
			cR.velocity.x = lerp(cR.velocity.x, cR.moveDirection.x * contrdDesMoveSpeed, contrdInAirMoveSpeed * delta)
			cR.velocity.z = lerp(cR.velocity.z, cR.moveDirection.z * contrdDesMoveSpeed, contrdInAirMoveSpeed * delta)
		else:
			#accumulate desired speed for bunny hopping
			cR.desiredMoveSpeed = cR.velocity.length()
			
	#if cR.desiredMoveSpeed >= cR.maxSpeed: cR.desiredMoveSpeed = cR.maxSpeed
	if cR.desiredMoveSpeed >= cR.moveSpeed: cR.desiredMoveSpeed = cR.moveSpeed
	
func jump(): 
	#manage the jump behaviour, depending of the different variables and states the character is
	var canJump : bool = false #jump condition
	
	#in air jump
	if !cR.is_on_floor():
		if !cR.coyoteJumpOn and cR.nbJumpsInAirAllowed > 0:
			cR.nbJumpsInAirAllowed -= 1
			cR.jumpCooldown = cR.jumpCooldownRef
			canJump = true
		if cR.coyoteJumpOn:
			cR.jumpCooldown = cR.jumpCooldownRef
			cR.coyoteJumpCooldown = -1.0 #so that the character cannot immediately make another coyote jump
			cR.coyoteJumpOn = false
			canJump = true 
			
	#on floor jump
	if cR.is_on_floor():
		cR.jumpCooldown = cR.jumpCooldownRef
		canJump = true
		
	#jump buffering
	if cR.bufferedJump:
		cR.bufferedJump = false
		cR.nbJumpsInAirAllowed = cR.nbJumpsInAirAllowedRef
		
	#apply jump
	if canJump:
		cR.velocity.y = cR.jumpVelocity
		cR.currStamina -= cR.jumpStaminaConsumption
		canJump = false


func decelerate_jump(delta) -> void:
	cR.velocity.y -= cR.jumpDeccel * delta
