extends Node3D
class_name LevelPortal


@export var rotation_speed :float = 10
var isActivated :bool = false

@onready var portal_mesh :MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	set_activated(false)


func _physics_process(delta: float) -> void:
	if isActivated:
		portal_mesh.rotate_z(delta * rotation_speed)
		look_at(Global.player_global_pos)


func set_activated(activated :bool) -> void:
	isActivated = activated
	portal_mesh.visible = isActivated
	$GPUParticles3D.visible = isActivated


func _on_area_3d_body_entered(body: Node3D) -> void:
	SignalBus.enter_level_portal.emit()
