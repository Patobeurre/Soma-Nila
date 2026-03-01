extends Node
class_name BBCodeString


@export var _text :String = ""


func _init(text :String = "") -> void:
	_text = text


func prepend(text :String) -> BBCodeString:
	var new_text = text + _text
	return BBCodeString.new(new_text)

func append(text :String) -> BBCodeString:
	var new_text = _text + text
	return BBCodeString.new(new_text)


func wave(amp :float = 50.0, freq :float = 5.0, connected :int = 1) -> BBCodeString:
	var formated_str = "[wave amp=%s freq=%s connected=%s]%s[/wave]" % [str(amp), str(freq), str(connected), _text]
	return BBCodeString.new(formated_str)


func rainbow() -> BBCodeString:
	var formated_str = "[rainbow]%s[/rainbow]" % [_text]
	return BBCodeString.new(formated_str)


func set_color(colorName :String) -> BBCodeString:
	var formated_str = "[color=%s]%s[/color]" % [colorName, _text]
	return BBCodeString.new(formated_str)


func get_text() -> String:
	return _text