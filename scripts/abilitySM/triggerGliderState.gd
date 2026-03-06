extends State
class_name triggerGlideState

var stateName : String = "TriggerGlide"

var parentNode :Node3D
var stateRes : StateRes


func _ready() -> void:
	SignalBus.glide_state_performed.connect(_on_glide_ability_consumed)

func enter(res : Variant):
	#pass state resource
	stateRes = res


func physics_update(delta : float):
	if stateRes.amount > 0:
		inputManagement()


func inputManagement():
	if Input.is_action_just_pressed("interact3D"):
		perform()


func perform() -> void:
	SignalBus.use_glide_requested.emit()


func _on_glide_ability_consumed():
	stateRes.set_amount(stateRes.amount - 1)
	AudioBus.play_sfx("OPEN_GLIDER")
	#AudioBus.play_sfx("GLIDER_WIND")

func setRefNode(node :Node3D):
	parentNode = node
