extends Control
class_name SavedLevelPanel

@export var levelStats :LevelStats = LevelStats.new()

@onready var seed_label: RichTextLabel = %SeedLabel
@onready var time_label: RichTextLabel = %TimeLabel
@onready var used_abilities_container: HBoxContainer = %UsedAbilitiesContainer
@onready var no_item_used_label: RichTextLabel = %NoItemUsedLabel
@onready var spice_icon_container = %SpiceIconContainer

@onready var abilityStatScene :PackedScene = load("res://UI/Components/AbilityStatPanel.tscn")
@onready var spiceTextureScene :PackedScene = load("res://UI/Components/spice_texture.tscn")


signal on_clicked(LevelStats)


func init(stat :LevelStats):
	levelStats = stat
	set_seed_label()
	set_spice()
	set_time_label()
	fill_used_abilities()


func set_seed_label() -> void:
	seed_label.text = str(levelStats.seed)


func set_spice() -> void:
	for i in range(levelStats.terrain_stats.spice_level):
		var spice_texture = spiceTextureScene.instantiate()
		spice_icon_container.add_child(spice_texture)
		spice_texture.set_enabled(true)


func set_time_label() -> void:
	time_label.text = Utils.seconds2hhmmss(levelStats.completionTime, true)


func fill_used_abilities() -> void:
	for ability in levelStats.used_abilities:
		if ability.amount_used > 0:
			var obj :AbilityStatPanel = abilityStatScene.instantiate()
			used_abilities_container.add_child(obj)
			obj.init(ability)
	
	if used_abilities_container.get_children().size() <= 1:
		no_item_used_label.visible = true


func _on_button_pressed() -> void:
	on_clicked.emit(levelStats)
