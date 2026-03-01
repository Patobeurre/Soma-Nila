extends Node3D

@export var bodyToMove :Node3D = self
@export var speed : float = 2.0
@export var start_pos : Vector3 = Vector3.ZERO
@export var end_pos : Vector3 = Vector3(0,0,-5)
@export var back_and_forth : bool = true

@export var distance :float = 5.0
@export var initial_distance :float = 0
var moveDir : Vector3
var isStopped : bool = false


func _ready() -> void:
	moveDir = (end_pos - start_pos).normalized().floor()
	end_pos = start_pos + moveDir * distance
	bodyToMove.position = start_pos + moveDir * initial_distance


func _get_current_dir() -> Vector3:
	return (end_pos - bodyToMove.position).normalized().floor()


func _physics_process(delta: float) -> void:
	#checkDirection()
	if isStopped:
		return
	
	var new_dir = _get_current_dir()
	
	if new_dir.dot(moveDir) == 1:
		bodyToMove.position += moveDir * speed * delta
		return
	
	if back_and_forth:
		moveDir = -moveDir
		end_pos = start_pos
		start_pos = bodyToMove.position
	else:
		isStopped = true


func checkDirection():
	var new_dir = (end_pos - bodyToMove.position).normalized().floor()
	
	if new_dir == moveDir:
		return
	
	if back_and_forth:
		moveDir = new_dir
		end_pos = start_pos
		start_pos = bodyToMove.position
	else:
		bodyToMove.position = end_pos
