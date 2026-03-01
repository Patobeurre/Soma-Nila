extends State

class_name RopeState

var stateName : String = "Rope"

var cR : CharacterBody3D

var end_rope_position : Vector3
var distance_to_end_point : float

var timer :Timer = Timer.new()


func enter(charReference : Variant):
	cR = charReference as CharacterBody3D
	end_rope_position = Vector3.ZERO
	
	verifications()
	
	cR.currStamina -= cR.ropeStaminaConsumption
	cR.ropeCooldownRef = cR.ropeDuration
	
	SignalBus.rope_state_performed.emit()

func verifications():	
	if cR.ropeCheck.is_colliding():
		end_rope_position = cR.ropeCheck.get_collision_point()
	
	cR.moveSpeed = cR.ropeSpeed
	cR.moveAccel = cR.ropeAccel
	cR.moveDeccel = cR.ropeDeccel

func exit():
	clearRope()
	timer.stop()
	cR.isRopeAbilityRequested = false
	SignalBus.exit_rope_state.emit()

func update(_delta : float):
	drawRope()
	inputManagement()

func inputManagement():
	if Input.is_action_just_pressed(cR.jumpAction):
		transitioned.emit(self, "IdleState")
	
	if cR.isClimbAreaAbilityRequested:
		transitioned.emit(self, "ClimbAreaState")
	
	if cR.isBubbleAbilityRequested:
		transitioned.emit(self, "BubbleState")


func checkConditions():
	# check distance
	distance_to_end_point = cR.rope_node.global_position.distance_to(end_rope_position)
	if (distance_to_end_point < cR.ropeMinDistance):
		transitioned.emit(self, "IdleState")
	
	# check duration
	if (cR.ropeCooldownRef <= 0):
		transitioned.emit(self, "IdleState")
	
	# check on floor
	#if (cR.is_on_floor()):
	#	transitioned.emit(self, "IdleState")

func physics_update(_delta : float):
	checkConditions()
	
	move(_delta)
	
	cR.ropeCooldownRef -= _delta

func move(delta : float):
	var end_position = end_rope_position
	end_position.y -= 1.55
	cR.moveDirection = (end_position - cR.global_position).normalized()
	
	cR.velocity = lerp(cR.velocity, cR.moveDirection * cR.moveSpeed, cR.moveAccel * delta)

func drawRope():
	clearRope()
	var local_end_pos = cR.to_local(end_rope_position)
	cR.rope_path.curve.add_point(cR.rope_node.position)
	cR.rope_path.curve.add_point(cR.to_local(end_rope_position))

func clearRope():
	cR.rope_path.curve.clear_points()
