extends Node3D


@onready var photoDocument :PhotoDocument = %Sprite3D

var screenshot_path = "user://screenshots/screenshot_2026-05-22_083749.tres"


func _ready() -> void:
	load_screenshot()


func load_screenshot():
	var screenshot_res :ScreenshotRes = ResourceLoader.load(screenshot_path)

	photoDocument.load_texture(screenshot_res.texture)
