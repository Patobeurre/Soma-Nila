extends State
class_name triggerJetpackState

var stateName : String = "TriggerJetpack"

var parentNode :Node3D
var stateRes : StateRes

var amount :float = 0
var is_performing :bool = false


func _ready() -> void:
	SignalBus.jetpack_state_performed.connect(_on_jetpack_ability_ended)

func enter(res : Variant):
	#pass state resource
	stateRes = res
	amount = stateRes.amount


func physics_update(delta : float):
	if stateRes.amount > 0:
		inputManagement(delta)

	if is_performing:
		amount -= 10 * delta
		stateRes.set_amount(int(amount))
		if amount <= 0:
			SignalBus.use_jetpack_requested.emit(false)


func inputManagement(delta :float):
	if Input.is_action_just_pressed("interact3D"):
		perform()


func perform() -> void:
	AudioBus.play_sfx("JETPACK_BOOST", false, true)
	SignalBus.use_jetpack_requested.emit(true)
	is_performing = true


func _on_jetpack_ability_ended():
	AudioBus.stop_sfx("JETPACK_BOOST")
	is_performing = false


func setRefNode(node :Node3D):
	parentNode = node
