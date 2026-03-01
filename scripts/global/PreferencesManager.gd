extends Node

signal controls_changed

const CONTROLS_SAVE_PATH := "user://controls.tres"


func _ready():
	load_controls()


func save_controls():
	var actions = InputMap.get_actions()
	var data = ControlsData.new()
	for action in actions:
		if action.begins_with("editor_") or action.begins_with("ui_"):
			continue
		data.controls[action] = InputMap.action_get_events(action)
	var error = ResourceSaver.save(data, CONTROLS_SAVE_PATH)
	if error != OK:
		printerr("Failed to save controls! Error: ", error_string(error))


func load_controls():
	if not ResourceLoader.exists(CONTROLS_SAVE_PATH, "ControlsData"):
		save_controls()
		#printerr("No saved controls data in ", CONTROLS_SAVE_PATH)
		return
	var data = ResourceLoader.load(CONTROLS_SAVE_PATH, "ControlsData")
	if not is_instance_valid(data):
		printerr("Failed to load controls!")
		return
	for action in data.controls.keys():
		InputMap.action_erase_events(action)
		for event in data.controls[action]:
			InputMap.action_add_event(action, event)
	controls_changed.emit()
