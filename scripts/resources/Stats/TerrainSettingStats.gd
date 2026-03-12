extends Resource
class_name TerrainSettingStats


@export_range(0, 3) var spice_level :int = 0
var max_spice_level :int = 3
var spice_curve :Curve = load("res://scripts/resources/Stats/SpiceLevelCurve.tres")


func convert_spice_level_to_ratio() -> float:
	return snapped(spice_curve.sample(spice_level), 0.01)
