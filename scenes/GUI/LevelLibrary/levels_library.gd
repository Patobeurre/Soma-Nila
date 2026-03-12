extends PanelContainer


@onready var puzzle_pack_container = %PuzzlePackContainer

@onready var level_pack_panel = load("res://scenes/GUI/LevelLibrary/level_pack_panel.tscn")


func _ready() -> void:
	_init_directory()
	_load_puzzle_packs()


func _load_puzzle_packs() -> void:
	var file_paths :Array[String] = Utils.get_all_file_paths("user://puzzle_packs")

	for filePath :String in file_paths:
		var res = _try_load_level_pack(filePath)
		if res != null:
			_instantiate_level_pack(res)


func _try_load_level_pack(filePath :String) -> LevelPackRes:
	if filePath.ends_with(".tres"):
		var res = ResourceLoader.load(filePath)
		if res is LevelPackRes:
			if res.game_version_compatibility <= SaveManager.save_game_res.VERSION:		
				return res
	return null


func _instantiate_level_pack(res :LevelPackRes):
	var pack_panel :LibraryLevelPackPanel = level_pack_panel.instantiate()
	puzzle_pack_container.add_child(pack_panel)
	pack_panel.init(res)


func _init_directory() -> void:
	var dir_access = DirAccess.open("user://puzzle_packs")
	if !dir_access:
		DirAccess.open("user://").make_dir("puzzle_packs")


func _on_btn_import_pack_pressed() -> void:
	var file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.add_filter("*.tres;Resource Files")
	file_dialog.connect("file_selected", _on_file_selected)
	add_child(file_dialog)
	file_dialog.size = get_viewport().get_visible_rect().size*3/4
	file_dialog.popup_centered()


func _on_file_selected(path :String) -> void:
	var res = _try_load_level_pack(path)
	if res != null:
		_instantiate_level_pack(res)
		ResourceSaver.save(res, "user://puzzle_packs/" + res.name + ".tres")
