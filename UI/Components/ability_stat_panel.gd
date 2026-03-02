extends PanelContainer
class_name AbilityStatPanel


@export var abilityStat :AbilityStats

@onready var iconButton :TextureRect = $HBoxContainer/TextureRect
@onready var amountTxt :RichTextLabel = $HBoxContainer/AmountTxt


func init(res :AbilityStats):
	abilityStat = res
	iconButton.texture = abilityStat.to_state_res().icon
	amountTxt.text = " " + str(abilityStat.amount_used) + " "
