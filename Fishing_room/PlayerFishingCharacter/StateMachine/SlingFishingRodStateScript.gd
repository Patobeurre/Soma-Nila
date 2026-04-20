extends State
class_name SlingFishingRodState

var stateName : String = "SlingFishingRod"
var cR : CharacterBody3D


@onready var bobber_scene = load("res://Fishing_room/models/bobber.tscn")


func enter(charRef : Variant):
	cR = charRef as CharacterBody3D

	cR.moveSpeed = cR.chargeSlingMoveSpeed
	cR.moveAccel = cR.chargeSlingMoveAccel
	cR.moveDeccel = cR.chargeSlingMoveDeccel

	_throw_bobber()


func exit():

	print("STATE exited")
	
	cR.fishingRod.clearRope()

	if cR.bobberRef:
		cR.bobberRef.queue_free()


func physics_update(delta : float):

	cR.fishingRod.drawRope(true)

	inputManagement()


func inputManagement() -> void:
	
	if Input.is_action_just_pressed(cR.slingAction):
		transitioned.emit(self, "DefaultFishingState")
		#transitioned.emit(self, "RetreiveBobberState")


func _throw_bobber() -> void:
	var bobber :Bobber = bobber_scene.instantiate()
	get_tree().root.add_child(bobber)
	bobber.global_position = cR.bobberSpawner.global_position
	bobber.linear_velocity = Global.player_camera_orientation * cR.currentSlingForce
	cR.bobberRef = bobber as Bobber
	cR.fishingRod.set_end_point_node(bobber.get_rope_point())
