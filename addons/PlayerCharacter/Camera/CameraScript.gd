extends Node3D

#class name
class_name CameraObject 

#camera variables
@export_group("Camera variables")
@export var XAxisSensibility : float = 0.5
@export var YAxisSensibility : float = 0.5
@export var maxUpAngleView : float = -90
@export var maxDownAngleView : float = 90

@export_group("FOV variables")
@export var startFOV : float

#movement changes variables
@export_group("Movement changes variables")
@export var baseCamAngle : float
@export var baseCameraLerpSpeed : float
@export var crouchCamAngle : float
@export var crouchCameraLerpSpeed : float
@export var crouchCameraDepth : float 

#bob variables
@export_group("Camera bob variables")
var headBobValue : float
@export var bobFrequency : float
@export var bobAmplitude : float

#tilt variables
@export_group("Camera tilt variables")
@export var camTiltRotationValue : float 
@export var camTiltRotationSpeed : float
@export var onFloorTiltValDivider : float

@export_group("Mouse variables")
var mouseFree : bool = false

@export_group("Keybind variables")
@export var mouseModeAction : String = ""

#references variables
@onready var camera : Camera3D = $Camera
@onready var cameraTmp : Camera3D = $CameraTmp
@onready var playChar : PlayerCharacter = $".."
@onready var hud : CanvasLayer = $"../HUD"

var axisSensibility :Vector2 = Vector2(0.5, 0.5)
var input_direction :Vector2 = Vector2.ZERO
var isEnabled :bool = true

var controller_motion :Vector2 = Vector2.ZERO
var controller_deadzone :float = 0.3


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #set mouse mode as captured
	
	_init_custom_settings()


func _init_custom_settings():
	if XAxisSensibility and YAxisSensibility:
		axisSensibility = Vector2(XAxisSensibility, YAxisSensibility)
	elif ProjectSettings.has_setting("display/mouse_cursor/mouse_sensitivity"):
		axisSensibility = ProjectSettings.get_setting("display/mouse_cursor/mouse_sensitivity")
	
	var fov = 0
	if startFOV:
		fov = startFOV
	elif ProjectSettings.has_setting("rendering/camera/depth_of_field/fov"):
		fov = ProjectSettings.get_setting("rendering/camera/depth_of_field/fov")
	camera.fov = fov
	cameraTmp.fov = fov


func _unhandled_input(event):
	if !isEnabled:
		return
	
	#manage camera rotation (360 on x axis, blocked at specified values on y axis, to not having the character do a complete head turn, which will be kinda weird)
	if event is InputEventMouseMotion:
		input_direction = Vector2(-event.relative.x, -event.relative.y)
		rotate_camera(input_direction)
	if event is InputEventJoypadMotion:
		if event.axis == JOY_AXIS_RIGHT_X:
			controller_motion.x = event.axis_value if abs(event.axis_value) > controller_deadzone else 0
		if event.axis == JOY_AXIS_RIGHT_Y:
			controller_motion.y = event.axis_value if abs(event.axis_value) > controller_deadzone else 0


func rotate_camera(rotationXY :Vector2, delta :float = 1) -> void:
	var radians_per_pixel = axisSensibility / DisplayServer.screen_get_dpi()
	rotate_y(rotationXY.x * radians_per_pixel.x)
	camera.rotate_x(rotationXY.y * radians_per_pixel.y)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(maxUpAngleView), deg_to_rad(maxDownAngleView))
	cameraTmp.rotation = camera.rotation


func inputManagement(delta):
	var controller_input = Vector2(-controller_motion.x, -controller_motion.y)
	rotate_camera(controller_input * 10, delta)


func _process(delta):
	if !isEnabled:
		return
	
	applies(delta)
	
	#cameraBob(delta)
	
	#cameraTilt(delta)
	
	#mouseMode()

	inputManagement(delta)


func applies(delta : float):
	#manage the differents camera modifications relative to a specific state, except for the FOV
	if playChar.stateMachine.currStateName == "Crouch":
		position.y = lerp(position.y, 1.715 + crouchCameraDepth, crouchCameraLerpSpeed * delta)
		rotation.z = lerp(rotation.z, deg_to_rad(crouchCamAngle) * playChar.inputDirection.x if playChar.inputDirection.x != 0.0 else deg_to_rad(crouchCamAngle), crouchCameraLerpSpeed * delta)
	else:
		position.y = lerp(position.y, 1.715, baseCameraLerpSpeed * delta)
		rotation.z = lerp(rotation.z, deg_to_rad(baseCamAngle), baseCameraLerpSpeed * delta)
			
func cameraBob(delta):
	#manage the bobbing of the camera when the character is moving
	headBobValue += delta * playChar.velocity.length() * float(playChar.is_on_floor())
	camera.transform.origin = headbob(headBobValue) #apply the bob effect obtained to the camera

func headbob(time): 
	#some trigonometry stuff here, basically it uses the cosinus and sinus functions (sinusoidal function) to get a nice and smooth bob effect
	var pos = Vector3.ZERO
	pos.y = sin(time * bobFrequency) * bobAmplitude
	pos.x = cos(time * bobFrequency / 4) * bobAmplitude
	return pos

func cameraTilt(delta): 
	#tmanage the camera tilting when the character is moving on the x axis (left and right)
	if !playChar.is_on_floor(): rotation.z = lerp(rotation.z, -playChar.inputDirection.x * camTiltRotationValue/onFloorTiltValDivider, camTiltRotationSpeed * delta)
	else: rotation.z = lerp(rotation.z, -playChar.inputDirection.x * camTiltRotationValue, camTiltRotationSpeed * delta)

func mouseMode():
	#manage the mouse mode (visible = can use mouse on the screen, captured = mouse not visible and locked in at the center of the screen)
	if Input.is_action_just_pressed(mouseModeAction): mouseFree = !mouseFree
	if !mouseFree: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else: Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func set_enable(enabled :bool) -> void:
	isEnabled = enabled
