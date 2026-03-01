extends Control


@onready var abilitiesContainer = $MarginContainer/PanelContainer/HBoxContainer
@onready var arrowReticle = $Crosshair/ArrowReticle
@onready var interactKey = $Crosshair/InteractKey
@onready var fruitTextureRect :TextureRect = $FruitTexture

@onready var abilitySelectorIconScene = preload("res://UI/Components/AbilitySelectorIcon.tscn")


func _ready() -> void:
	
	_display_arrow_reticle(false)
	
	SignalBus.ability_selector_populated.connect(_on_abilities_changed)
	SignalBus.selected_ability_changed.connect(_on_selected_ability_changed)
	SignalBus.rope_state_available.connect(_display_arrow_reticle)
	SignalBus.fruit_picked.connect(_display_fruit)
	SignalBus.can_interact.connect(_display_interact_key)


func _clear_ability_container() -> void:
	
	for child in abilitiesContainer.get_children():
		child.unbind()
		child.queue_free()


func _process(delta: float) -> void:
	pass


func instantiate_ability_panel(ability :StateRes) -> void:
	
	var obj :AbilitySelectorIcon = abilitySelectorIconScene.instantiate()
	abilitiesContainer.add_child(obj)
	obj.init(ability)


func _on_selected_ability_changed(ability :StateRes) -> void:
	
	for child :AbilitySelectorIcon in abilitiesContainer.get_children():
		child.set_selected(child.res == ability)


func _on_abilities_changed(abilities :Array) -> void:
	
	_clear_ability_container()
	fruitTextureRect.visible = false
	
	for ability in abilities:
		instantiate_ability_panel(ability)


func _display_arrow_reticle(enabled :bool) -> void:
	arrowReticle.visible = enabled

func _display_fruit(fruitNode :Fruit) -> void:
	fruitTextureRect.texture = fruitNode.icon
	fruitTextureRect.visible = true

func _display_interact_key(enabled :bool) -> void:
	if enabled:
		var inputEvent :InputEvent = InputMap.action_get_events("interact_with_object")[0]
		var keyMap = InputKeyImageMapper.get_key_map_from_event(inputEvent)
		interactKey.texture = load(keyMap.image_path)
	else:
		interactKey.texture = null
	
	interactKey.visible = enabled
