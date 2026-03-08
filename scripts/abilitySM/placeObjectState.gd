extends State
class_name PlaceObjectState

var stateName : String = "PlaceObject"

var parentNode :Node3D
var stateRes : StateRes

func enter(res : Variant):
	#pass state resource
	stateRes = res
	
	_init_placeholder_mesh()
	show_placeholder(true)
	parentNode.DISTANCE = stateRes.res.maxDistance

func exit():
	show_placeholder(false)


func physics_update(delta : float):
	if stateRes.amount > 0:
		inputManagement()
	else:
		show_placeholder(false)

func inputManagement():
	if Input.is_action_just_pressed("interact3D"):
		perform()


func _init_placeholder_mesh() -> void:
	var placeholder_mesh :Node3D = stateRes.res.placeholder_mesh.instantiate()
	Utils.remove_children(parentNode.placeholder_node)
	parentNode.placeholder_node.add_child(placeholder_mesh)
	placeholder_mesh.scale = stateRes.res.scale


func show_placeholder(shown : bool):
	parentNode.placeholder_node.visible = shown


func perform() -> void:
	var obj :Node3D = stateRes.res.scene.instantiate()
	parentNode.placeableObject_node.add_child(obj)
	obj.global_position = parentNode.placeholder_node.global_position
	obj.rotation = parentNode.placeholder_node.rotation
	obj.rotate_y(deg_to_rad(180))
	obj.scale = stateRes.res.scale
	stateRes.set_amount(stateRes.amount - 1)
	_play_audio()


# ToDo : refactor this shit
func _play_audio():
	match stateRes.name:
		"PO_BOX":
			AudioBus.play_sfx("PLOC_PLACEMENT")
		"PO_MOVINGPLATFORM_V":
			AudioBus.play_sfx("ROCK_PLATFORM")
		"PO_MOVINGPLATFORM_H":
			AudioBus.play_sfx("ROCK_PLATFORM")
		"PO_WATERLILIES":
			AudioBus.play_sfx("WATERLILIES")
		"PO_BUBBLE":
			AudioBus.play_sfx("BUBBLE_PLACEMENT")


func setRefNode(node :Node3D):
	parentNode = node
