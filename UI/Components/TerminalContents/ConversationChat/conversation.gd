extends VBoxContainer
class_name ConversationPanel


@onready var message_scene :PackedScene = load("res://UI/Components/TerminalContents/ConversationChat/Message.tscn")
@export var all_conversations :Dictionary = {}


func _ready() -> void:
	var seed = Global.main_level_res.seed
	var res = all_conversations.get(seed)

	_build_messages(res)


func _build_messages(res :ConversationRes):
	Utils.remove_children(self)
	
	var align_right :bool = false
	for msg :ChatMessageRes in res.messages:
		var obj = message_scene.instantiate()
		add_child(obj)
		obj.init(msg)
		if align_right:
			obj.align_H(HORIZONTAL_ALIGNMENT_RIGHT)
		align_right = !align_right
