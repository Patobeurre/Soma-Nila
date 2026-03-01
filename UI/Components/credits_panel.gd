extends PanelContainer


@onready var btn_creator_link = $MarginContainer/VBoxContainer/VBoxContainer/VBoxContainer2/BtnCreatorLink


func _ready() -> void:
	btn_creator_link.grab_focus()


func _on_btn_music_link_pressed() -> void:
	OS.shell_open("https://omnigardens.bandcamp.com/album/golden-pear")


func _on_btn_creator_link_pressed() -> void:
	OS.shell_open("https://brice-maussang.xyz")
