extends Node

@export var initialState : State

var currState : State
var currStateName  : String
var states : Dictionary = {}
var isEnabled :bool = true

@onready var parentRef = $".."

func _ready():
	#get all the state childrens
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(onStateChildTransition)
			print(child.name.to_lower())
			
	#if initial state, transition to it
	if initialState:
		initialState.enter(parentRef)
		currState = initialState
		currStateName = currState.stateName
		
func _process(delta : float):
	if not isEnabled: return
	if currState: currState.update(delta)

func _physics_process(delta: float):
	if not isEnabled: return
	if currState: currState.physics_update(delta)

func set_enabled(enabled :bool) -> void:
	isEnabled = enabled
	if !isEnabled and initialState != null:
		onStateChildTransition(currState, initialState.stateName + "State")

func onStateChildTransition(state : State, newStateName : String):
	#manage the transition from one state to another
	
	if state != currState: return
	
	print(newStateName)
	
	var newState = states.get(newStateName.to_lower())
	print(newState)
	if !newState: return
	
	#exit the current state
	if currState: currState.exit()
	
	#enter the new state
	newState.enter(parentRef)
	
	currState = newState
	currStateName = currState.stateName
	print(currStateName)
