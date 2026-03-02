extends PanelContainer
class_name AbilitySelectorIcon


@export var res :StateRes = null

@onready var image :TextureRect = $Icon
@onready var txtAmount :RichTextLabel = $TxtAmount
@onready var unselectedPanel :PanelContainer = $UnselectedPanel
@onready var disabledPanel :PanelContainer = $DisabledPanel
var isSelected :bool = false


func init(new_res :StateRes) -> void:
	res = new_res
	await get_tree().create_timer(5)
	image.texture = res.icon
	bind()
	enable(true)
	update_amount(res.amount)
	update_selection_panel()


func set_selected(selected :bool) -> void:
	isSelected = selected
	update_selection_panel()


func update_amount(amount :int):
	txtAmount.text = " " + str(amount) + " "
	if amount <= 0:
		enable(false)

func enable(enabled :bool):
	disabledPanel.visible = !enabled
	unselectedPanel.visible = !enabled

func update_selection_panel():
	unselectedPanel.visible = !isSelected


func bind() -> void:
	res.amount_changed.connect(update_amount)

func unbind() -> void:
	if res != null:
		res.amount_changed.disconnect(update_amount)
