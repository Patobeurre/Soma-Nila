extends State
class_name MoveObjectState

var stateName : String = "MoveObject"

var parentNode :Node3D
var stateRes : StateRes

@export var maxDistance :float = 10
@export var minDistance :float = 5
var collisionResult = {}
var isDragging :bool = false

@onready var highlight_material :ShaderMaterial = load("res://materials/highlight_material.tres")
@onready var highlight_red_material :ShaderMaterial = load("res://materials/highlight_red_material.tres")


func enter(res : Variant):
	#pass state resource
	stateRes = res

func exit():
	clearCollisionResult()
	if isDragging:
		release_drag()


func physics_update(delta : float):
	if isDragging:
		drag_object()
		inputManagement()
	elif stateRes.amount > 0:
		if check_ray_collides():
			highlight_mesh(true)
			inputManagement()


func set_collision_result(result) -> void:
	clearCollisionResult()
	collisionResult = result
	highlight_mesh(true)


func clearCollisionResult() -> void:
	if not collisionResult.is_empty():
		highlight_mesh(false)
	collisionResult = {}


func highlight_mesh(toHighlight :bool) -> void:
	if collisionResult.is_empty():
		return
	
	#collisionResult.collider.get_parent().highlight(toHighlight, !(collisionResult.distance > minDistance))
	
	var collider :Node3D = collisionResult.collider
	var meshInstances = collider.find_children("BaseTileMesh")
	for mesh :MeshInstance3D in meshInstances:
		if toHighlight:
			mesh.material_overlay = highlight_material if collisionResult.distance > minDistance else highlight_red_material
		else:
			mesh.material_overlay = null


func inputManagement():
	if !isDragging and Input.is_action_just_pressed("interact3D"):
		perform_drag()
	elif isDragging and Input.is_action_just_pressed("interact3D"):
		release_drag()


func perform_drag() -> void:
	#var tile_bloc = collisionResult.collider.get_parent()
	#await tile_bloc.deactivate_collision(true)
	#tile_bloc.reparent.call_deferred(parentNode.map_node)
	isDragging = true

func release_drag() -> void:
	#var tile_bloc = collisionResult.collider.get_parent()
	#tile_bloc.reparent.call_deferred(parentNode.map_node)
	#tile_bloc.deactivate_collision(false)
	isDragging = false
	clearCollisionResult()
	stateRes.set_amount(stateRes.amount - 1)


func drag_object() -> void:
	var new_position :Vector3 = Global.player_global_pos + Global.player_camera_orientation * collisionResult.distance
	collisionResult.collider.global_position = new_position


func check_ray_collides() -> bool:
	var space_state = parentNode.get_world_3d().direct_space_state
	
	# cast stair detection ray
	var origin :Vector3 = Global.player_global_pos
	var end :Vector3 = origin + Global.player_camera_orientation * maxDistance
	
	var query = PhysicsRayQueryParameters3D.create(origin, end, 4096)
	var result = space_state.intersect_ray(query)
	
	if result.is_empty():
		clearCollisionResult()
		return false
	
	var distance = origin.distance_to(result.collider.global_position)
	result.set("distance", distance)
	
	set_collision_result(result)
	
	if distance <= minDistance:
		return false
	
	return true

func setRefNode(node :Node3D):
	parentNode = node
