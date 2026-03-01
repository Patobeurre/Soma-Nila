extends Control
class_name InputRemapPanel

@onready var actions_container = self
@onready var action_button_scene = load("res://UI/Components/KeybindButton.tscn")

@export var input_actions :Dictionary = {
	"move_forward": "INPUT_MOVE_FORWARD",
	"move_left": "INPUT_MOVE_LEFT",
	"move_back": "INPUT_MOVE_BACK",
	"move_right": "INPUT_MOVE_RIGHT",
	"jump": "INPUT_JUMP",
	"interact3D": "INPUT_USE_ITEM",
	"wheelUp": "INPUT_CHANGE_ITEM_UP",
	"wheelDown": "INPUT_CHANGE_ITEM_DOWN",
	"restart": "INPUT_RESTART",
	"restart_forced": "INPUT_NEXT_LEVEL",
	"interact_with_object": "INPUT_INTERACT",
}

var isRemapping :bool = false
var actionToRemap = null
var remappingBtn = null


func _ready() -> void:
	_create_action_list()


func _create_action_list() -> void:
	InputMap.load_from_project_settings()
	
	Utils.remove_children(actions_container)
	
	for action in input_actions:
		var actionBtn = action_button_scene.instantiate()
		var action_label = actionBtn.find_child("ActionLabel")
		var input_btn = actionBtn.find_child("InputKeyBtn")

		action_label.text = tr(input_actions[action])

		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			_update_action_list(input_btn, events[0])
		else:
			input_btn.text = ""

		actions_container.add_child(actionBtn)
		input_btn.pressed.connect(_on_input_btn_pressed.bind(input_btn, action))


func _on_input_btn_pressed(input_btn, action) -> void:
	if !isRemapping:
		isRemapping = true
		actionToRemap = action
		remappingBtn = input_btn
		input_btn.set_button_icon(ImageTexture.new())
		input_btn.text = tr("TEXT_ASSIGN_KEY")


func _input(event: InputEvent) -> void:
	if isRemapping:
		if (
			event is InputEventKey or
			(event is InputEventMouseButton and event.pressed)
		):
			if event is InputEventMouseButton and event.double_click:
				event.double_click = false
			
			InputMap.action_erase_events(actionToRemap)
			InputMap.action_add_event(actionToRemap, event)
			_update_project_settings(actionToRemap, event)
			_update_action_list(remappingBtn, event)

			actionToRemap = null
			remappingBtn = null
			isRemapping = false

			accept_event()


func _update_action_list(button, event) -> void:
	var keyMap = InputKeyImageMapper.get_key_map_from_event(event)
	if keyMap.has_image():
		button.set_button_icon(load(keyMap.image_path))
		button.text = ""
	else:
		button.text = keyMap.display_name


func _update_project_settings(action, event):
	var input_name = "input/%s" % [action]
	ProjectSettings.set_setting(input_name, {"events": [event]})
