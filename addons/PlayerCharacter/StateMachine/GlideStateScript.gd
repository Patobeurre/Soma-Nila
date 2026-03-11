extends State

class_name GlideState

var stateName : String = "Glide"

var cR : CharacterBody3D


func enter(charRef : Variant):
	cR = charRef as CharacterBody3D
	
	verifications()
	
	SignalBus.glide_state_performed.emit()
	cR.glider_mesh_node.visible = true


func exit():
	cR.isGlideAbilityRequested = false
	cR.glider_mesh_node.visible = false


func verifications():
	cR.moveSpeed = cR.glideMoveSpeed
	cR.moveAccel = cR.glideMoveAccel
	cR.moveDeccel = cR.glideMoveDeccel
	
	cR.glideCooldownRef = cR.glideDuration


func physics_update(delta : float):
	
	if cR.stair_check():
		transitioned.emit(self, "ClimbStairState")
	
	inputManagement()
	
	checkIfFloor()
	
	checkConditions()
	
	move(delta)
	
	cR.glideCooldownRef -= delta


func checkConditions():
	# check duration
	if (cR.glideCooldownRef <= 0):
		transitioned.emit(self, "IdleState")


func inputManagement():
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
		transitioned.emit(self, "IdleState")


func checkIfFloor():
	if cR.is_on_floor():
		if cR.jumpBuffOn:
			cR.bufferedJump = true
			cR.jumpBuffOn = false
			transitioned.emit(self, "JumpState")
		else:
			if cR.moveDirection: transitioned.emit(self, cR.walkOrRun)
			else: transitioned.emit(self, "IdleState")


func move(delta : float):
	cR.moveDirection =  Global.player_camera_orientation
	
	if !cR.is_on_floor():
		if cR.moveDirection:
			cR.velocity.x = lerp(cR.velocity.x, cR.moveDirection.x * cR.moveSpeed, cR.moveAccel * delta)
			cR.velocity.z = lerp(cR.velocity.z, cR.moveDirection.z * cR.moveSpeed, cR.moveAccel * delta)
		else:
			cR.desiredMoveSpeed = cR.velocity.length()
			#apply smooth stop
			cR.velocity.x = lerp(cR.velocity.x, 0.0, cR.moveDeccel * delta)
			cR.velocity.z = lerp(cR.velocity.z, 0.0, cR.moveDeccel * delta)
	
	var fallVelocity = cR.velocity.y + cR.fallGravity * delta
	cR.velocity.y = max(-cR.glideFallSpeed, fallVelocity)
	
	if cR.desiredMoveSpeed >= cR.maxSpeed: cR.desiredMoveSpeed = cR.maxSpeed
