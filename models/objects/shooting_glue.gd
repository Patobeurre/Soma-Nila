extends RigidBody3D


@onready var collision :CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var area3d :Area3D = $OverlappingArea3D

var check_overlap :bool = false
var has_overlapping_body :bool = false


func _physics_process(delta: float) -> void:

	if check_overlap and !has_overlapping_body:
		check_overlap = false
		collision.set_deferred("disabled", false)



func _on_body_entered(body :Node) -> void:
	freeze = true
	reparent.call_deferred(body)
	check_overlap = true


func _on_overlapping_area_3d_body_entered(body: Node3D) -> void:
	has_overlapping_body = true


func _on_overlapping_area_3d_body_exited(body: Node3D) -> void:
	has_overlapping_body = false
