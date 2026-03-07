extends Control
class_name TerminalWindow

@export var XAxisSensibility : float = 1
@export var YAxisSensibility : float = 1

@onready var title_label: RichTextLabel = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var content_panel = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/MarginContainer/ScrollContainer/ContentPanel
@onready var cursor: Sprite2D = $Cursor

@export var secret_puzzle_window :TerminalWindowRes
@export var conversation_window :TerminalWindowRes
@export var survey_form_window :TerminalWindowRes
var currentWindowRes :TerminalWindowRes = null


func _ready() -> void:
	if Global.main_level_res:
		init(Global.main_level_res.seed)


func init(seed :int):
	if seed != Global.SECRET_LEVEL_SEED:
		currentWindowRes = secret_puzzle_window
	if seed == ChatMessageRes.employees.get('Amandine'):
		currentWindowRes = survey_form_window
	if Global.all_conversation_seeds.has(seed):
		currentWindowRes = conversation_window
	_update()


func move_cursor() -> void:
	var mouse_pos = get_tree().get_root().get_viewport().get_mouse_position()
	cursor.position = mouse_pos


func _process(delta: float) -> void:
	move_cursor()


func _update() -> void:
	if currentWindowRes == null:
		return
		
	title_label.text = currentWindowRes.title
	Utils.remove_children(content_panel)
	var content = currentWindowRes.content.instantiate()
	content_panel.add_child(content)
