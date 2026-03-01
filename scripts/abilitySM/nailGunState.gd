extends State
class_name nailGunState

var stateName : String = "NailGun"

var parentNode :Node3D
var stateRes : StateRes

var timer :Timer = Timer.new()
var is_auto_fire_triggered :bool = false
var is_firing :bool = false


func _ready() -> void:
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)


func enter(res : Variant):
	#pass state resource
	stateRes = res


func physics_update(delta : float):
	if stateRes.amount > 0:
		inputManagement()


func inputManagement():

	if Input.is_action_just_pressed("interact3D"):
		is_auto_fire_triggered = true
		perform()
		
	elif stateRes.res.enable_auto_fire:
		if Input.is_action_pressed("interact3D") and is_auto_fire_triggered and !is_firing:
			perform()


func perform() -> void:
	is_firing = true
	timer.start(stateRes.res.fire_rate)

	var obj :Node3D = stateRes.res.projectile_scene.instantiate()
	parentNode.placeableObject_node.add_child(obj)
	obj.global_position = Global.player_global_pos
	obj.rotation = parentNode.placeholder_node.rotation
	obj.rotate_y(deg_to_rad(180))
	obj.scale = stateRes.res.scale
	obj.linear_velocity = Global.player_camera_orientation * stateRes.res.speed
	stateRes.set_amount(stateRes.amount - 1)


func _on_timer_timeout():
	is_firing = false


func setRefNode(node :Node3D):
	parentNode = node
