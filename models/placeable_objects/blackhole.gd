extends Node3D


@onready var area3d :Area3D = $Area3D
@onready var orbits :Node3D = $Orbits

@export var ROTATION_SPEED :float = 6
@export var area_max_range :float = 8

var orbit_layers :Array[Node] = []


func _ready() -> void:
	orbit_layers = orbits.get_children()
	area3d.monitorable = true
	area3d.monitoring = true


func _physics_process(delta: float) -> void:

	_rotate_layers(delta)


func _rotate_layers(delta: float):
	var i = 1
	for layer :Node3D in orbit_layers:
		layer.rotate_y(ROTATION_SPEED / i * delta)
		i += 1


func _associate_body_to_layer(body :Node3D) -> void:
	var distance = global_position.distance_to(body.global_position)
	var layer_index :int = floor(distance * orbit_layers.size() / area_max_range) - 1
	layer_index = clamp(layer_index, 0, orbit_layers.size() - 1)
	
	body.reparent.call_deferred(orbit_layers[layer_index])


func _on_area_3d_body_entered(body :Node3D) -> void:
	_associate_body_to_layer(body.get_parent())
