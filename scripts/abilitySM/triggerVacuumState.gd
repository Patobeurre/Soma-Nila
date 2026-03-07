extends State
class_name triggerVacuumState

var stateName : String = "TriggerVacuum"

var parentNode :Node3D
var stateRes : StateRes


var distance_max :float = 30
var angle_degrees :float = 45


func enter(res : Variant):
	#pass state resource
	stateRes = res

func exit():
	pass


func physics_update(delta : float):
	if stateRes.amount > 0:
		inputManagement()


func inputManagement():
	if Input.is_action_just_pressed("interact3D"):
		perform()


func perform() -> void:
	var blocs = _get_blocs_in_range()
	stateRes.set_amount(stateRes.amount - 1)


func _get_blocs_in_range():
	var all_blocs = parentNode.map_node.allBlocs
	for bloc in all_blocs:
		var distance = Global.player_global_pos.distance_to(bloc.global_position)
		if distance > distance_max:
			continue
		var direction = (bloc.global_position - Global.player_global_pos).normalized()
		var dot_product = Global.player_camera_orientation.dot(direction)
		if dot_product > (angle_degrees / 90):
			bloc.start_moving(bloc.global_position + -direction * 500, 50)


func setRefNode(node :Node3D):
	parentNode = node
