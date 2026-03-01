extends State

class_name ClimbLedgeState

var stateName : String = "ClimbLedge"

var cR : CharacterBody3D

@export var playerCam :Camera3D
@export var camTmp :Camera3D

var dest_pos : Vector3
var is_dest_pos_ready : bool = false
var is_transitionning :bool = false

signal end_camera_transition


func enter(charRef : Variant):
	cR = charRef as CharacterBody3D
	
	verifications()
	
	end_camera_transition.connect(camera_transition_finished, CONNECT_ONE_SHOT)


func verifications():
	is_dest_pos_ready = false
	if cR.ledgeCheckLow.is_colliding():
		var dir = -cR.ledgeCheckLow.get_collision_normal().normalized()
		var origin = cR.ledgeCheckLow.get_collision_point()
		origin += 0.05 * dir
		var end = origin
		end.y += 1
		var query = PhysicsRayQueryParameters3D.create(end, origin)
		query.set_hit_from_inside(true)
		var result = get_tree().root.get_world_3d().direct_space_state.intersect_ray(query)
		if result.has("position"):
			print(result)
			dest_pos = result.position
			dest_pos.y += 0.05
			is_dest_pos_ready = true


func move_to_destination():
	var to :Transform3D = playerCam.global_transform
	var offsetPos :Vector3 = dest_pos - cR.global_position
	to.origin += offsetPos
	
	var duration :float = 0.6#dest_pos.distance_to(cR.global_position) / cR.moveSpeed
	
	transition_camera(playerCam, to, duration)
	


func transition_camera(from :Camera3D, to :Transform3D, duration :float = 1.0):
	
	camTmp.global_transform = from.global_transform
	camTmp.fov = from.fov
	
	is_transitionning = true
	camTmp.make_current()
	
	var tween = get_tree().create_tween().bind_node(camTmp).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(camTmp, "global_position", to.origin, duration)
	tween.play()
	
	await tween.finished
	
	cR.global_position = dest_pos
	
	from.make_current()
	
	is_transitionning = false
	end_camera_transition.emit()


func physics_update(delta : float):
	if is_transitionning:
		cR.velocity = Vector3.ZERO
	if is_dest_pos_ready:
		is_dest_pos_ready = false
		move_to_destination()


func camera_transition_finished():
	transitioned.emit(self, "IdleState")
