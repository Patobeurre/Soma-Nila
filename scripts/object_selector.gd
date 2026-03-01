extends Node
class_name AbilitySelector

@export var items :ItemListSelector = ItemListSelector.new()

@export var prevAction :String = ""
@export var nextAction :String = ""


func _ready() -> void:
	items = ItemListSelector.new()
	items.selected_item_changed.connect(_on_selected_item_changed)
	items.list_populated.connect(SignalBus.ability_selector_populated.emit)


func _process(delta: float) -> void:
	inputManagement()


func inputManagement() -> void:
	if Input.is_action_just_pressed(prevAction):
		items.previous()
	if Input.is_action_just_pressed(nextAction):
		items.next()


func populate(abilities :Array) -> void:
	for a in abilities:
		a.amount = a.initial_amount
	items.set_items(abilities)

func set_selected_ability(idx :int) -> void:
	items.set_selected(idx)

func get_selected_ability() -> StateRes:
	return items.get_selected_item()


func _on_selected_item_changed(int) -> void:
	SignalBus.selected_ability_changed.emit(items.get_selected_item() as StateRes)
