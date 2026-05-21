extends State
class_name DefaultDragState

var stateName : String = "Default"
var parent :Node3D


func enter(parentRef : Variant):
	parent = parentRef as Node3D

	parent.intersect_ray = {}


func physics_update(delta: float) -> void:

	inputManagement()


func inputManagement() -> void:
	
	#manage the state transitions depending on the actions inputs
	if Input.is_action_just_pressed("interact3D"):
		parent.intersect_ray = parent.raycast_at_mouse_position(parent.DRAGGABLE_LAYER_MASK)
		if not parent.intersect_ray.is_empty():
			transitioned.emit(self, "DraggingState")
