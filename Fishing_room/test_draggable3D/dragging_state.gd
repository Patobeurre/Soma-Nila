extends State
class_name DraggingState

var stateName : String = "Dragging"
var parent :Node3D


func enter(parentRef : Variant):
	parent = parentRef
	
	verifications()

	SignalBus.on_drag_started.emit()

	if parent.intersect_ray.collider.has_method("on_drag"):
		parent.intersect_ray.collider.on_drag()


func exit():
	if parent.drag_type == parent.EDragType.SNAP_TO_GRID:
		parent.intersect_ray.collider.global_position = parent.intersect_ray.collider.global_position.snapped(Vector3(parent.TILE_SIZE.x, parent.TILE_SIZE.y, parent.TILE_SIZE.z))
	
	SignalBus.on_drag_released.emit()

	if parent.intersect_ray.collider.has_method("on_released"):
		parent.intersect_ray.collider.on_released()


func verifications() -> void:
	if parent.intersect_ray.is_empty():
		transitioned.emit(self, "DefaultDragState")


func physics_update(delta: float) -> void:

	_update_collider_position()

	inputManagement()


func _update_collider_position() -> void:

	var intersect_ray = parent.raycast_at_mouse_position(parent.BACKGROUND_LAYER_MASK)

	if intersect_ray.is_empty():
		return
	
	var new_position :Vector3 = intersect_ray.position
	
	if parent.snap_while_dragging:
		if parent.drag_type == parent.EDragType.SNAP_TO_GRID:
			new_position = intersect_ray.position.snapped(Vector3(parent.TILE_SIZE.x, parent.TILE_SIZE.y, parent.TILE_SIZE.z))

	parent.intersect_ray.collider.global_position = new_position


func inputManagement() -> void:
	
	if parent.hold_input:
		#manage the state transitions depending on the actions inputs
		if Input.is_action_just_released("interact3D"):
			transitioned.emit(self, "DefaultDragState")
	else:
		if Input.is_action_just_pressed("interact3D"):
			transitioned.emit(self, "DefaultDragState")
