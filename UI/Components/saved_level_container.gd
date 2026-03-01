extends Control
class_name SavedLevelPanel

@export var levelStats :LevelStats = LevelStats.new()

@onready var seed_label: RichTextLabel = $Button/MarginContainer/HBoxContainer/SeedLabel
@onready var time_label: RichTextLabel = $Button/MarginContainer/HBoxContainer/TimeLabel
@onready var used_abilities_container: HBoxContainer = $Button/MarginContainer/HBoxContainer/UsedAbilitiesContainer
@onready var no_item_used_label: RichTextLabel = $Button/MarginContainer/HBoxContainer/UsedAbilitiesContainer/NoItemUsedLabel

@onready var abilityStatScene :PackedScene = load("res://UI/Components/AbilityStatPanel.tscn")


signal on_clicked(LevelStats)


func init(stat :LevelStats):
	levelStats = stat
	set_seed_label()
	set_time_label()
	fill_used_abilities()


func set_seed_label() -> void:
	seed_label.text = str(levelStats.seed)


func set_time_label() -> void:
	time_label.text = Utils.seconds2hhmmss(levelStats.completionTime, true)


func fill_used_abilities() -> void:
	for ability in levelStats.used_abilities:
		if ability.amount_used > 0:
			var obj :AbilityStatPanel = abilityStatScene.instantiate()
			used_abilities_container.add_child(obj)
			obj.init(ability)
	
	if used_abilities_container.get_children().is_empty():
		no_item_used_label.visible = true


func _on_button_pressed() -> void:
	on_clicked.emit(levelStats)
