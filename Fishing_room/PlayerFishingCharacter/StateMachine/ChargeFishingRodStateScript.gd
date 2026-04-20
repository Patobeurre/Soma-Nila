extends State
class_name ChargeFishingRodState

var stateName : String = "ChargeFishingRod"
var cR : CharacterBody3D


func enter(charRef : Variant):
	cR = charRef as CharacterBody3D

	cR.moveSpeed = cR.chargeSlingMoveSpeed
	cR.moveAccel = cR.chargeSlingMoveAccel
	cR.moveDeccel = cR.chargeSlingMoveDeccel
	cR.currentSlingForce = cR.minSlingForce


func physics_update(delta : float):

	inputManagement()

	buildUpForce(delta)

	#move(delta)



func inputManagement() -> void:

	if not Input.is_action_pressed(cR.slingAction):
		transitioned.emit(self, "SlingFishingRodState")
	

func buildUpForce(delta :float) -> void:
	cR.currentSlingForce += cR.chargeSlingSpeed * delta


func move(delta : float):
	cR.inputDirection = Input.get_vector(cR.moveLeftAction, cR.moveRightAction, cR.moveForwardAction, cR.moveBackwardAction)
	cR.moveDirection = (cR.camHolder.global_basis * Vector3(cR.inputDirection.x, 0.0, cR.inputDirection.y)).normalized()
	
	if cR.moveDirection and cR.is_on_floor():
		#apply smooth move
		cR.velocity.x = lerp(cR.velocity.x, cR.moveDirection.x * cR.moveSpeed, cR.moveAccel * delta)
		cR.velocity.z = lerp(cR.velocity.z, cR.moveDirection.z * cR.moveSpeed, cR.moveAccel * delta)
		
		if cR.hitGroundCooldown <= 0: cR.desiredMoveSpeed = cR.velocity.length()
		
	else:
		cR.velocity.x = 0
		cR.velocity.z = 0
		
	if cR.desiredMoveSpeed >= cR.maxSpeed: cR.desiredMoveSpeed = cR.maxSpeed