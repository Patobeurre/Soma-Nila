extends PanelContainer


@onready var puzzle_pack_container = %PuzzlePackContainer

@onready var level_pack_panel = load("res://scenes/GUI/LevelLibrary/level_pack_panel.tscn")


func _ready() -> void:
	_init_directory()
	_load_puzzle_packs()


func _load_puzzle_packs() -> void:
	var file_paths :Array[String] = Utils.get_all_file_paths("user://puzzle_packs")

	for filePath :String in file_paths:
		if filePath.ends_with(".tres"):
			var res = ResourceLoader.load(filePath)
			if res is LevelPackRes:
				_intantiate_level_pack(res)


func _intantiate_level_pack(res :LevelPackRes):
	var pack_panel :LibraryLevelPackPanel = level_pack_panel.instantiate()
	puzzle_pack_container.add_child(pack_panel)
	pack_panel.init(res)


func _init_directory() -> void:
	var dir_access = DirAccess.open("user://puzzle_packs")
	if !dir_access:
		DirAccess.open("user://").make_dir("puzzle_packs")