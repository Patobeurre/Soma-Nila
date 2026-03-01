extends Node3D
class_name ClimbingArea


@export var wallNormal :Vector3 = Vector3.LEFT
@export var normalEpsilon :float = 0.1


func set_wallNormal(normal :Vector3) -> void:
	var dotZ = normal.dot(Vector3.FORWARD)
	var dotX = normal.dot(Vector3.LEFT)
	var dotY = normal.dot(Vector3.UP)
	
	if abs(dotY) > (1 - normalEpsilon):
		normal = Vector3.UP if dotY > 0 else Vector3.DOWN
	elif abs(dotZ) > abs(dotX):
		normal = Vector3.FORWARD if dotZ > 0 else Vector3.BACK
	else:
		normal = Vector3.LEFT if dotX > 0 else Vector3.RIGHT
	
	wallNormal = normal


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is PlayerCharacter:
		body.climbing_area_entered(self)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is PlayerCharacter:
		body.climbing_area_exited(self)
