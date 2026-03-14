extends Node


@onready var parent_res :T_ParentRes = load("res://scenes/test_save_resource/Parent_Res.tres")


func _on_btn_save_pressed() -> void:
	ResourceSaver.save(parent_res, "user://test_save_.tres", ResourceSaver.SaverFlags.FLAG_BUNDLE_RESOURCES)

func _on_btn_load_pressed() -> void:
	var res :T_ParentRes = ResourceLoader.load("user://test_save.tres")
	$BtnLoad.icon = res.res_with_image_list[0].image


func _on_btn_copy_pressed() -> void:
	var file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.connect("dir_selected", _on_dir_selected)
	add_child(file_dialog)
	file_dialog.size = get_viewport().get_visible_rect().size*3/4
	file_dialog.popup_centered()


func _on_dir_selected(path :String) -> void:
	var dir = DirAccess.open(path)
	print(dir.get_files())
	for file in dir.get_files():
		dir.copy("C:/Users/Patobeur/Documents/SomaNila_exports/MagmaPack/" + file, "user://puzzle_packs/" + file)



func _on_btn_zip_pressed() -> void:
	#var dir = DirAccess.open("C:/Users/Patobeur/Documents/SomaNila_exports")
	#dir.copy("C:/Users/Patobeur/Documents/SomaNila_exports/MagmaPack.zip", "user://puzzle_packs/MagmaPack.zip")

	var reader = ZIPReader.new()
	reader.open("C:/Users/Patobeur/Documents/SomaNila_exports/MagmaPack.zip")

    # Destination directory for the extracted files (this folder must exist before extraction).
    # Not all ZIP archives put everything in a single root folder,
    # which means several files/folders may be created in `root_dir` after extraction.
	var root_dir = DirAccess.open("user://puzzle_packs")

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


func _on_btn_iterate_folders_pressed() -> void:
	var dir_access = DirAccess.open("user://puzzle_packs")
	#for dir in dir_access.get_directories():


