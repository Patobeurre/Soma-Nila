class_name KeyMap


var inputEvent :InputEvent
var display_name :String = ""
var image_path :String = ""


func _init(event):
	inputEvent = event


func has_image() -> bool:
	return !image_path.is_empty()


func _to_string() -> String:
	return "event: " + str(inputEvent) + "\n" \
		+ "text: " + display_name + "\n" \
		+ "has image: " + str(has_image())