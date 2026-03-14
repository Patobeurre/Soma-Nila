extends Node


func remove_children(parent :Node) -> void:
	for child in parent.get_children():
		parent.remove_child(child)


func find(parent, type):
	for child in parent.get_children():
		if is_instance_of(child, type):
			return child
		var grandchild = find(child, type)
		if grandchild != null:
			return grandchild
	return null


func get_all_file_paths(path: String) -> Array[String]:  
	var file_paths: Array[String] = []
	var dir = DirAccess.open(path)  
	dir.list_dir_begin()  
	var file_name = dir.get_next()
	while file_name != "":  
		var file_path = path + "/" + file_name  
		if dir.current_is_dir():  
			file_paths += get_all_file_paths(file_path)  
		else:  
			file_paths.append(file_path)  
		file_name = dir.get_next()  
	return file_paths


func extract_all_zip_files(zip_path :String, to_path :String) -> void:

	var reader = ZIPReader.new()
	reader.open(zip_path)

    # Destination directory for the extracted files (this folder must exist before extraction).
    # Not all ZIP archives put everything in a single root folder,
    # which means several files/folders may be created in `root_dir` after extraction.
	var root_dir = DirAccess.open(to_path)

	var files = reader.get_files()
	for file_path in files:
        # If the current entry is a directory.
		if file_path.ends_with("/"):
			root_dir.make_dir_recursive(file_path)
			continue

        # Write file contents, creating folders automatically when needed.
        # Not all ZIP archives are strictly ordered, so we need to do this in case
        # the file entry comes before the folder entry.
		root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
		var file = FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
		var buffer = reader.read_file(file_path)
		file.store_buffer(buffer)


func world_environment_transition(from :Environment, to :Environment, duration :float = 2.0):
	var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC)

	# Ambient light
	tween.parallel().tween_property(from, "ambient_light_color", to.ambient_light_color, duration)

	# Fog
	tween.parallel().tween_property(from, "fog_light_color", to.fog_light_color, duration)
	tween.parallel().tween_property(from, "fog_light_energy", to.fog_light_energy, duration)
	tween.parallel().tween_property(from, "fog_sun_scatter", to.fog_sun_scatter, duration)
	tween.parallel().tween_property(from, "fog_density", to.fog_density, duration)
	tween.parallel().tween_property(from, "fog_aerial_perspective", to.fog_aerial_perspective, duration)
	tween.parallel().tween_property(from, "fog_depth_begin", to.fog_depth_begin, duration)
	tween.parallel().tween_property(from, "fog_depth_curve", to.fog_depth_curve, duration)
	tween.parallel().tween_property(from, "fog_depth_end", to.fog_depth_end, duration)

	# Sky
	var from_sky_material :ProceduralSkyMaterial = from.sky.sky_material
	tween.parallel().tween_property(from_sky_material, "sky_horizon_color", to.sky.sky_material.sky_horizon_color, duration)
	tween.parallel().tween_property(from_sky_material, "sky_top_color", to.sky.sky_material.sky_top_color, duration)
	tween.parallel().tween_property(from_sky_material, "sky_curve", to.sky.sky_material.sky_curve, duration)
	tween.parallel().tween_property(from_sky_material, "ground_horizon_color", to.sky.sky_material.sky_horizon_color, duration)
	tween.parallel().tween_property(from_sky_material, "ground_bottom_color", to.sky.sky_material.ground_bottom_color, duration)
	tween.parallel().tween_property(from_sky_material, "ground_curve", to.sky.sky_material.ground_curve, duration)
	#from_sky_material.sky

	tween.play()
	return


static func get_unique_array(original_array: Array) -> Array:
	var unique_array = []
	
	for item in original_array:
		if not unique_array.has(item):
			unique_array.append(item)
	
	return unique_array


static func subtractArr(a: Array, b: Array) -> Array:
	var result := []
	var bag := {}
	for item in b:
		if not bag.has(item):
			bag[item] = 0
		bag[item] += 1
	for item in a:
		if bag.has(item):
			bag[item] -= 1
			if bag[item] == 0:
				bag.erase(item)
		else:
			result.append(item)
	return result


static func seconds2hhmmss(total_seconds: float, keepMinimum) -> String:
	var seconds: float = fmod(total_seconds, 60.0)
	var minutes: int = int(total_seconds / 60.0) % 60
	var hours: int = int(total_seconds / 3600.0)
	
	var constructedStr = ""
	if keepMinimum:
		if hours > 0:
			return "%02d:%02d:%05.2f" % [hours, minutes, seconds]
		if minutes > 0:
			return "%02d:%05.2f" % [minutes, seconds]
		else:
			return "%05.2f" % [seconds]
	
	return "%02d:%02d:%05.2f" % [hours, minutes, seconds]


static func get_closest_factor(target :int, factorOf :int) -> int:
	for i in range(factorOf):
		if (factorOf % (target + i) == 0):
			return target + i
		elif (factorOf % (target - i) == 0):
			return target - i
	
	return factorOf


# TO REMOVE

#func raycast(world :Node3D, origin :Vector3, end :Vector3 = Vector3.ZERO, distance :float = 1):
func raycast(world :Node3D, origin :Vector3, end :Vector3 = Vector3.ZERO, mask :int = 1) -> Dictionary:
	var space_state = world.get_world_3d().direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(origin, end, mask)
	return space_state.intersect_ray(query)
