extends VBoxContainer
class_name ChatMessagePanel

@onready var title :RichTextLabel = $Title
@onready var content :RichTextLabel = $Content


func init(res :ChatMessageRes):
	title.text = res.written_by + '@' + str(res.get_employee_seed())
	content.text = tr(res.content)


func align_H(new_alignment :HorizontalAlignment) -> void:
	title.horizontal_alignment = new_alignment
	content.horizontal_alignment = new_alignment
