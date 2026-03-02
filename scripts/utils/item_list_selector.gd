extends Resource
class_name ItemListSelector


@export var items :Array = []
@export var isCircular :bool = true
var selectedItemIdx :int = 0

signal list_populated(Array)
signal item_added
signal selected_item_changed(int)


func set_items(list :Array) -> void:
	items.clear()
	for item in list:
		items.append(item)
	selectedItemIdx = 0
	list_populated.emit(items)


func add_item(item :Variant, pos :int = -1):
	if pos < 0:
		items.append(item)
		item_added.emit(item)
	elif items.insert(pos, item):
		item_added.emit(item)

func set_selected(new_idx :int) -> void:
	if new_idx < items.size() and new_idx >= 0:
		selectedItemIdx = new_idx
		selected_item_changed.emit(selectedItemIdx)

func previous():
	if !items.size():
		return
	if selectedItemIdx > 0:
		set_selected(selectedItemIdx - 1)
	elif isCircular:
		set_selected(items.size() - 1)

func next():
	if !items.size():
		return
	if isCircular:
		set_selected((selectedItemIdx + 1) % items.size())
	elif selectedItemIdx < items.size() - 1:
		set_selected(selectedItemIdx + 1)


func get_selected_item():
	if selectedItemIdx >= items.size() or selectedItemIdx < 0:
		return null
	return items[selectedItemIdx]
