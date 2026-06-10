extends State
class_name DefaultDragState

var stateName : String = "Default"
var parent :Node3D


func enter(parentRef : Variant):
	parent = parentRef as Node3D

	parent.intersect_ray = {}


func physics_update(delta: float) -> void:

	var intersect_ray = parent.raycast_at_mouse_position(parent.DRAGGABLE_LAYER_MASK)

	if not intersect_ray.is_empty():
		if parent.intersect_ray.is_empty():
			SignalBus.on_drag_hover_enter.emit()
			if intersect_ray.collider.has_method("on_hover_enter"):
				intersect_ray.collider.on_hover_enter()
	else:
		if not parent.intersect_ray.is_empty():
			SignalBus.on_drag_hover_exit.emit()
			if parent.intersect_ray.collider.has_method("on_hover_exit"):
				parent.intersect_ray.collider.on_hover_exit()
	
	parent.intersect_ray = intersect_ray

	inputManagement()


func inputManagement() -> void:
	
	#manage the state transitions depending on the actions inputs
	if Input.is_action_just_pressed("interact3D"):
		if not parent.intersect_ray.is_empty():
			transitioned.emit(self, "DraggingState")
