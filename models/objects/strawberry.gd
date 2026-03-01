extends Node3D
class_name Fruit

@export var background_effect_rotate_speed :float = 2.0
@export var rotate_speed :float = 1.0
@export var icon :Texture2D

@onready var item_node :Node3D = $Item
@onready var glow_light_mesh :MeshInstance3D = $Background/MeshInstance3D
@onready var background :Node3D = $Background


func _physics_process(delta: float) -> void:
	item_node.rotate_y(rotate_speed * delta)
	
	var pos :Vector3 = Global.player_global_pos
	background.look_at(pos)
	glow_light_mesh.rotate_z(background_effect_rotate_speed * delta)


func _on_area_3d_body_entered(body: Node3D) -> void:
	SignalBus.fruit_picked.emit(self)
