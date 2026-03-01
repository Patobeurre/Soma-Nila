extends State
class_name triggerRopeState

var stateName : String = "TriggerRope"

var parentNode :Node3D
var stateRes : StateRes


var isRopeStateAvailable :bool = false


func _ready() -> void:
	SignalBus.rope_state_performed.connect(_on_rope_ability_consumed)

func enter(res : Variant):
	#pass state resource
	stateRes = res

func exit():
	setIsRopeStateAvailable(false)


func physics_update(delta : float):
	if stateRes.amount > 0:
		setIsRopeStateAvailable(parentNode.player.check_rope_state_transition())
		inputManagement()


func setIsRopeStateAvailable(available :bool):
	if isRopeStateAvailable != available:
		isRopeStateAvailable = available
		SignalBus.rope_state_available.emit(isRopeStateAvailable)


func inputManagement():
	if Input.is_action_just_pressed("interact3D"):
		perform()


func perform() -> void:
	SignalBus.use_rope_requested.emit()


func _on_rope_ability_consumed():
	stateRes.set_amount(stateRes.amount - 1)

func setRefNode(node :Node3D):
	parentNode = node
