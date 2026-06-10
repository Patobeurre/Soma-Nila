extends Node


@export var actionName = "take_screenshot"

@export_group("Animation")
@export var fade_duration :float = 0.3
@export var display_duration :float = 1.5

var is_animated :bool = false

@onready var screenshot_label :RichTextLabel = %ScreenshotTakenLabel


func _ready() -> void:
	screenshot_label.visible = false


func _process(delta :float):
	if Input.is_action_just_pressed(actionName):
		Utils.take_screenshot()
		animate()


func animate() -> void:
	if is_animated: return

	is_animated = true

	screenshot_label.visible = true
	screenshot_label.self_modulate.a = 0

	var tween :Tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(screenshot_label, "self_modulate:a", 1, fade_duration)
	tween.play()
	
	await tween.finished

	await get_tree().create_timer(display_duration).timeout

	tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(screenshot_label, "self_modulate:a", 0, fade_duration)
	tween.play()

	await tween.finished

	is_animated = false