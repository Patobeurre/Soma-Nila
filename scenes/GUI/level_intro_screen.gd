extends Control


@onready var abilitiesContainer = $CenterContainer2/HBoxContainer
@onready var catchFruitTextLabel = $CenterContainer3/CatchFruitTextLabel
@onready var passPortalTextLabel = $CenterContainer4/PassPortalTextLabel

@onready var whirl_background = $CenterContainer
@export var background_rotate_speed :float = 10.0
@export var startAnimationDelay :float = 1.0
@export var stepAnimationDelay :float = 0.5

@onready var abilityImage :PackedScene = load("res://UI/Components/Ability_PresentationIcon.tscn")

var isInputActive :bool = false


func _ready() -> void:
	SignalBus.ability_selector_populated.connect(_on_abilities_populated)
	isInputActive = !Input.is_action_just_pressed("interact3D") and !Input.is_action_just_pressed("jump")
	_fill_texts()


func _fill_texts() -> void:
	catchFruitTextLabel.text = BBCodeString.new( \
		tr("TEXT_FRUITNAME")).rainbow() \
		.prepend(" ") \
		.prepend(tr("TEXT_INTRO_CATCH")) \
		.prepend(" ") \
		.append(" ! ") \
		.wave().get_text()
	passPortalTextLabel.text = BBCodeString.new(tr("TEXT_INTRO_PORTAL")).append(" ").prepend(" ").wave().get_text()


func _process(delta: float) -> void:
	
	whirl_background.rotation_degrees += delta * background_rotate_speed
	
	if Input.is_action_just_released("interact3D") or Input.is_action_just_released("jump"):
		isInputActive = true
	
	if isInputActive:
		inputManagement()


func inputManagement():
	if Input.is_action_just_pressed("interact3D") \
		or Input.is_action_just_pressed("jump") \
		or Input.is_action_just_pressed("ui_accept"):
		SignalBus.ability_selector_populated.disconnect(_on_abilities_populated)
		Global.game_controller.end_level_intro()


func instantiate_ability_image(ability :StateRes, animationDelay :float = 0) -> void:
	var obj :AbilityPresentationIcon = abilityImage.instantiate()
	abilitiesContainer.add_child(obj)
	obj.init(ability, animationDelay)


func _on_abilities_populated(abilities :Array) -> void:
	print(abilities.size())
	var animationDelay :float = startAnimationDelay
	for ability :StateRes in abilities:
		instantiate_ability_image(ability, animationDelay)
		animationDelay += stepAnimationDelay
