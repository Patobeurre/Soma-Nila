extends Node3D
class_name DragAndDrop3DSystem

## Represents main drag system behaviours
enum EDragType {
	## Draggable objects can move freely
	FREE,
	## Draggable objects will snap to defined slot locations
	SNAP_TO_SLOTS,
	## Draggable objects will snap to a defined grid
	SNAP_TO_GRID,
}


@export_group("Global variables")
## The layer mask value of draggable objects collider
@export var DRAGGABLE_LAYER_MASK :int = 0
## The layer mask value of the surface where draggable objects will be placed on
@export var BACKGROUND_LAYER_MASK :int = 0
## The raycast's length used to detect objects
@export var RAYCAST_LENGTH :float = 10.0

## The actual [enum EDragType]
@export var drag_type :EDragType = EDragType.FREE
## Defines if snap is active while draging
@export var snap_while_dragging : bool = false
## Defines if the drag input must be holded while performing
@export var hold_input :bool = true

@export_group("Grid variables")
@export var TILE_SIZE :Vector3 = Vector3(1,1,1)


var intersect_ray :Dictionary = {}


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func raycast_at_mouse_position(mask :int = 255) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	var origin = get_viewport().get_camera_3d().project_ray_origin(mousepos)
	var end = origin + get_viewport().get_camera_3d().project_ray_normal(mousepos) * RAYCAST_LENGTH
	var raycast_param :PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	raycast_param.from = origin
	raycast_param.to = end
	raycast_param.collision_mask = mask
	raycast_param.collide_with_areas = true
	return space_state.intersect_ray(raycast_param)