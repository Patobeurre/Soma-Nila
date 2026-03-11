extends Control


@export var cooldown_in_s :float = 1.0
var timer :Timer = Timer.new()


func _ready() -> void:
	add_child(timer)
	timer.timeout.connect(_on_timeout)
	timer.start(cooldown_in_s)


func _on_timeout():
	visible = !visible
	timer.start(cooldown_in_s)