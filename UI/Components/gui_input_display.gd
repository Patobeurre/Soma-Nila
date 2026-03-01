extends Control


@onready var image :TextureRect = $TextureRect
@onready var label :RichTextLabel = $RichTextLabel

@export var input_action_name :String = ""


func _ready() -> void:
	_update()


func _update():
	var inputEvent :InputEvent = InputMap.action_get_events(input_action_name)[0]
	var keyMap = InputKeyImageMapper.get_key_map_from_event(inputEvent)

	image.texture = load(keyMap.image_path)