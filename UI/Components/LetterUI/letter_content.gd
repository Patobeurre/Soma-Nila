extends VBoxContainer
class_name Letter

@export var letter_res :LetterRes = LetterRes.new()

@onready var openning :RichTextLabel = %Openning
@onready var content :RichTextLabel = %Content
@onready var closing :RichTextLabel = %Closing


func _ready() -> void:
	update_letter_content()


func init(new_letter_res :LetterRes) -> void:
	letter_res = new_letter_res
	update_letter_content()


func update_letter_content() -> void:
	openning.text = letter_res.openning
	content.text = letter_res.content
	closing.text = letter_res.closing