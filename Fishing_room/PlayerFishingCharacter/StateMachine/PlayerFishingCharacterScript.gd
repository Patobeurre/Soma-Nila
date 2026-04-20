extends CharacterBody3D

class_name PlayerFishingCharacter


@export_group("Movement variables")
var moveSpeed : float
var moveAccel : float
var moveDeccel : float
var desiredMoveSpeed : float 
@export var desiredMoveSpeedCurve : Curve
@export var maxSpeed : float
@export var inAirMoveSpeedCurve : Curve
var inputDirection : Vector2 
var moveDirection : Vector3 
@export var hitGroundCooldown : float #amount of time the character keep his accumulated speed before losing it (while being on ground)
var hitGroundCooldownRef : float 
@export var bunnyHopDmsIncre : float #bunny hopping desired move speed incrementer
@export var autoBunnyHop : bool = false
var lastFramePosition : Vector3 
var lastFrameVelocity : Vector3
var wasOnFloor : bool
var walkOrRun : String = "WalkState" #keep in memory if play char was walking or running before being in the air
#for crouch visible changes
@export var baseHitboxHeight : float
@export var baseModelHeight : float
@export var heightChangeSpeed : float

@export_group("In Air variables")
@export var inAirMoveAccel : float
@export var inAirMoveDeccel : float

@export_group("Crouch variables")
@export var crouchSpeed : float
@export var crouchAccel : float
@export var crouchDeccel : float
@export var continiousCrouch : bool = false #if true, doesn't need to keep crouch button on to crouch
@export var crouchHitboxHeight : float
@export var crouchModelHeight : float
@export var snap_to_edge_on_crouch :bool = false
var previous_position :Vector3

@export_group("Walk variables")
@export var walkSpeed : float
@export var walkAccel : float
@export var walkDeccel : float

@export_group("Run variables")
@export var runSpeed : float
@export var runAccel : float 
@export var runDeccel : float 
@export var continiousRun : bool = false #if true, doesn't need to keep run button on to run

@export_group("Jump variables")
@export var jumpHeight : float
@export var jumpTimeToPeak : float
@export var jumpTimeToFall : float
@onready var jumpVelocity : float = (2.0 * jumpHeight) / jumpTimeToPeak
@export var jumpCooldown : float
var jumpCooldownRef : float
@export var jumpDeccel : float = 100.0
var is_jump_released : bool = false
@export var nbJumpsInAirAllowed : int 
var nbJumpsInAirAllowedRef : int 
var jumpBuffOn : bool = false
var bufferedJump : bool = false
@export var coyoteJumpCooldown : float
var coyoteJumpCooldownRef : float
var coyoteJumpOn : bool = false
var isJumping : bool = false

@export_group("Climb Stair variables")
@export var MIN_STAIR_HEIGHT :float = 0.1
@export var MAX_STAIR_HEIGHT :float = 1.0
@export var stairDistance : float = 0.8
@export var climbStairDuration : float = 0.2
var result_stair_check = {}

@export_group("Gravity variables")
@onready var jumpGravity : float = (-2.0 * jumpHeight) / (jumpTimeToPeak * jumpTimeToPeak)
@onready var fallGravity : float = (-2.0 * jumpHeight) / (jumpTimeToFall * jumpTimeToFall)

@export_group("Fishing variables")
@export var chargeSlingMoveSpeed :float
@export var chargeSlingMoveAccel :float
@export var chargeSlingMoveDeccel :float
@export var chargeSlingSpeed :float
@export var chargeSlingAccel :float
@export var minSlingForce :float = 5.0
@export var maxSlingForce :float = 50.0
var currentSlingForce :float = 0.0
var bobberRef :Bobber = null

@export_group("Keybind variables")
@export var moveForwardAction : String = ""
@export var moveBackwardAction : String = ""
@export var moveLeftAction : String = ""
@export var moveRightAction : String = ""
@export var runAction : String = ""
@export var crouchAction : String = ""
@export var jumpAction : String = ""
@export var slingAction : String = ""

#references variables
@onready var camHolder : Node3D = $CameraHolder
@onready var model : MeshInstance3D = $Model
@onready var hitbox : CollisionShape3D = $Hitbox
@onready var stateMachine : Node = $StateMachine
@onready var hud : CanvasLayer = $HUD
@onready var ceilingCheck : RayCast3D = $Raycasts/CeilingCheck
@onready var floorCheck : RayCast3D = $Raycasts/FloorCheck
@onready var wallCheck : RayCast3D = $CameraHolder/Camera/CameraWallCheck
@onready var stairDetector : Node3D = $StairDetector
@onready var stairCheck : RayCast3D = $StairDetector/StairCheck
@onready var bobberSpawner :Node3D = %BobberSpawner
@onready var fishingRod :FishingRod = %FishingRod

@export var isEnabled :bool = true


func _ready():
	#set move variables, and value references
	moveSpeed = walkSpeed
	moveAccel = walkAccel
	moveDeccel = walkDeccel
	
	hitGroundCooldownRef = hitGroundCooldown
	jumpCooldownRef = jumpCooldown
	nbJumpsInAirAllowedRef = nbJumpsInAirAllowed
	coyoteJumpCooldownRef = coyoteJumpCooldown


func _process(_delta: float):
	displayProperties()

func _physics_process(_delta : float):
	if not isEnabled: return
	
	modifyPhysicsProperties()
	
	previous_position = global_position
	
	move_and_slide()
	
	if isJumping and is_on_floor():
		isJumping = false
	
	Global.player_global_pos = camHolder.global_position
	SignalBus.on_player_pos_changed.emit(camHolder.global_position)
	Global.player_camera_orientation = -$CameraHolder/Camera.get_global_transform().basis.z


func set_enable(move_enabled :bool = true, camera_enabled :bool = true):
	isEnabled = move_enabled
	camHolder.set_enable(camera_enabled)
	stateMachine.set_enabled(move_enabled)
	if not isEnabled:
		velocity = Vector3.ZERO


func updateStairDetector():
	var look_dir : Vector3 = Vector3(velocity.x, 0, velocity.z)
	if look_dir == Vector3.ZERO:
		return
	look_dir += stairDetector.global_position
	stairDetector.look_at(look_dir, Vector3.UP)


func stair_check() -> bool:
	# return if not moving
	if inputDirection == Vector2.ZERO:
		return false
	
	result_stair_check = {}
	
	var space_state = get_world_3d().direct_space_state
	
	# cast stair detection ray
	var origin :Vector3 = global_position
	origin.y += MIN_STAIR_HEIGHT
	var velocity_dir : Vector3 = Vector3(velocity.x, 0, velocity.z)
	var end :Vector3 = origin
	end += velocity_dir.normalized() * stairDistance
	
	var query = PhysicsRayQueryParameters3D.create(origin, end, 1)
	var result = space_state.intersect_ray(query)
	
	if result.is_empty():
		return false
	
	# check wall normal on y axis
	if abs(result.normal.y) > 0.4:
		return false
	#var dot_product = result.normal.dot(velocity_dir.normalized())
	#if dot_product + 1 > 0.4:
	#	return false
	
	# cast stair height detection ray
	origin.y += MAX_STAIR_HEIGHT
	end.y += MAX_STAIR_HEIGHT
	
	query = PhysicsRayQueryParameters3D.create(origin, end, 1)
	var result_height = space_state.intersect_ray(query)
	
	if not result_height.is_empty():
		return false
	
	# cast stair end position ray
	origin = end
	end.y -= 1
	
	query = PhysicsRayQueryParameters3D.create(origin, end, 1)
	result_stair_check = space_state.intersect_ray(query)
	
	if result_stair_check.is_empty():
		return false
	
	# check destination normal points up
	var dot_product = result_stair_check.normal.dot(velocity_dir.normalized())
	print(dot_product)
	if dot_product + 1 < 0.6:
		return false
	
	return true


func applyExternalForce(force :Vector3) -> void:
	velocity += force


func displayProperties():
	#display properties on the hud
	if hud != null:
		hud.displayCurrentState(stateMachine.currStateName)
		hud.displayDesiredMoveSpeed(desiredMoveSpeed)
		hud.displayVelocity(velocity.length())
		hud.displayNbJumpsInAirAllowed(nbJumpsInAirAllowed)
		hud.displayCameraWallCheck(wallCheck.is_colliding())
		

func modifyPhysicsProperties():
	lastFramePosition = position #get play char position every frame
	lastFrameVelocity = velocity #get play char velocity every frame
	wasOnFloor = !is_on_floor() #check if play char was on floor every frame
	
func gravityApply(delta : float):
	#if play char goes up, apply jump gravity
	#otherwise, apply fall gravity
	if velocity.y >= 0.0: velocity.y += jumpGravity * delta
	elif velocity.y < 0.0: velocity.y += fallGravity * delta

func isMovingLeft() -> bool:
	return inputDirection.x < 0
	
func isMovingRight() -> bool:
	return inputDirection.x > 0
