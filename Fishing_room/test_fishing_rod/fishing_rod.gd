extends Node3D
class_name FishingRod


@onready var rope_node = %Rope
@onready var rope_path :Path3D = %RopePath3D

@export var end_point_node = null

@export var min_subdivision :int = 20
@export var curve_smooth :CurveTexture


func drawRope(smooth :bool = false):
	clearRope()

	if not end_point_node:
		return

	var local_start_pos = rope_path.position
	var local_end_pos = rope_node.to_local(end_point_node.global_position)

	rope_path.curve.add_point(local_start_pos)

	if smooth:
		var direction = local_start_pos.direction_to(local_end_pos)
		var distance = local_start_pos.distance_to(local_end_pos)
		var h = local_start_pos.y - local_end_pos.y
		var nb_subdivision = max(floor(distance), min_subdivision)

		if h > 0:
			for i in range(1, nb_subdivision):
				var p :Vector3 = i * direction * distance/nb_subdivision
				p.y = local_start_pos.y - (curve_smooth.curve.sample(float(i)/nb_subdivision) * h)
				rope_path.curve.add_point(p)

	rope_path.curve.add_point(local_end_pos)


func clearRope():
	rope_path.curve.clear_points()


func set_end_point_node(end_point :Node3D) -> void:
	end_point_node = end_point
