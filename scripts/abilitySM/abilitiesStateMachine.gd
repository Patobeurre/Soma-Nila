extends Node
class_name StateMachineStrategy

@onready var parentNode = $".."
@export var initialState : State

var currState : State
var currStateName  : String
var states : Dictionary = {}


func _ready():
	#get all the state childrens
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.setRefNode(parentNode)
			#child.transitioned.connect(onStateChildTransition)
			print(child.name.to_lower())
			
	#if initial state, transition to it
	if initialState:
		initialState.enter(null)
		currState = initialState
		currStateName = currState.stateName


func _process(delta : float):
	if currState: currState.update(delta)
	
func _physics_process(delta: float):
	if currState: currState.physics_update(delta)


func transition(stateRes :StateRes):
	#manage the transition from one state to another
	var newState = states.get(stateRes.stateName.to_lower())
	if !newState: return
	
	#exit the current state
	if currState: currState.exit()
	
	#enter the new state
	newState.enter(stateRes)
	
	currState = newState
	currStateName = currState.stateName
	print(currStateName)


func reset_to_initial_state():
	if currState: currState.exit()
	
	if initialState:
		initialState.enter(null)
		currState = initialState
		currStateName = currState.stateName
