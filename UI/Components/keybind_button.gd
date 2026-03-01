extends HBoxContainer
class_name KeybindButton


@onready var action_label = $ActionLabel
@onready var input_btn :Button = $InputKeyBtn

@export var action :String = ""

signal on_input_key_clicked


func init(actionName :String, actionText :String) -> void:

	action = actionName
	action_label.text = actionText

	var events = InputMap.action_get_events(action)
	if events.size() > 0:
		input_btn.text = events[0].as_text().trim_suffix(" (Physical)")
	else:
		input_btn.text = ""
